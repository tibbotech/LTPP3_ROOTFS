#!/bin/bash
#---CONSTANTS
BLKID_RETRY_MAX=10
FSCK_RETRY_MAX=3

FIRST_PARTITION_NUM=1
ROOTFS_PARTITION_NUM=8

EXITCODE_1=1

DEV="/dev"
DEV_MMCBLK0=/dev/mmcblk0
DEV_MMCBLK0P=${DEV_MMCBLK0}p
DEV_MMCBLK0P8=${DEV_MMCBLK0P}8
DEV_MMCBLK0P9=${DEV_MMCBLK0P}9
DEV_NONE="none"

FSCK_RETRY_PRINT="fsck_retry"

PATTERN_DISK="Disk"
PATTERN_LABEL="LABEL"
PATTERN_LABELIS="LABEL="
PATTERN_TB_ROOTFS_RO="tb_rootfs_ro"
PATTERN_TB_ROOTFS_RO_IS_TRUE="tb_rootfs_ro=true"

PRINT_TB_INIT_SH_START="\n**************************************************\n"
PRINT_TB_INIT_SH_START+="   TB_INIT.SH\n"
PRINT_TB_INIT_SH_START+="**************************************************\n"

PRINT_TB_INIT_SAFEMODE="\n**************************************************\n"
PRINT_TB_INIT_SAFEMODE+="   SAFE-MODE\n"
PRINT_TB_INIT_SAFEMODE+="**************************************************\n"
PRINT_TB_INIT_SAFEMODE+="To go back to the normal-mode, use command:\n"
PRINT_TB_INIT_SAFEMODE+="\n"
PRINT_TB_INIT_SAFEMODE+="   echo 1 >/proc/sys/kernel/sysrq && echo b >/proc/sysrq-trigger\n"
PRINT_TB_INIT_SAFEMODE+="\n"
PRINT_TB_INIT_SAFEMODE+="**************************************************\n"



#---VARIABLES
bin_bash_exec=/bin/bash

overlay_dir=/overlay
proc_dir=/proc
proc_cmdline_fpath=${proc_dir}/cmdline
proc_sys_kernel_sysrq=${proc_dir}/sys/kernel/sysrq
proc_sysrqtrigger_fpath=${proc_dir}/sysrq-trigger
rootfs_dir=/
rootfs_etc_tibbo_uboot_dir=/etc/tibbo/uboot
tb_reserve_dir=/tb_reserve
usr_sbin_mkfsext4=/usr/sbin/mkfs.ext4

lib_systemd_systemd_exec=/lib/systemd/systemd
fsck_retry_fpath1=${rootfs_etc_tibbo_uboot_dir}/fsck_retry.tmp
fsck_retry_fpath2=${tb_reserve_dir}/.fsck_retry.tmp
tb_init_backup_lst_fpath=/tb_reserve/.tb_init_backup.lst
tb_init_bootargs_tmp_fpath=${tb_reserve_dir}/.tb_init_bootargs.tmp
tb_init_bootargs_cfg_fpath=${tb_reserve_dir}/.tb_init_bootargs.cfg

fsck_retry=0

reboot_exec="echo 1 >${proc_sys_kernel_sysrq} && echo b >${proc_sysrqtrigger_fpath}"



#---FUNCTIONS
function exit_handler__func() {
    #Input args
    local exitcode=${1}

    #Print
    echo -e "${PRINT_TB_INIT_SAFEMODE}"

    #Mount '/proc' to 'none'
    mount -t proc ${DEV_NONE} ${proc_dir}

    #Exit
    exit ${exitcode}
}

function bin_bash_safemode_print__func() {
    echo -e "${PRINT_TB_INIT_SAFEMODE}"
}
function bin_bash_handler__func() {
    bin_bash_safemode_print__func

    ${bin_bash_exec}
}

function cat_showprogress__func {
    #Based on: https://www.baeldung.com/linux/command-line-progress-bar
    #Input args
    local srcpath=${1}
    local dstpath=${2}
    local pid=${3}

    #Define constants
    local WINDOW_NCOLS=$(tput cols)
    local BAR_SIZE=$(( (WINDOW_NCOLS * 50) / 100 )) #50% of terminal window size (in horizontal direction)
    local BAR_CHAR_PROCESSED="#"
    local BAR_CHAR_TODO="-"

    #Get srcsize (which is the size of srcpath)
    local srcsize=$(cat_getsize__func "${srcpath}")

    #Initialize variables
    local pid_isfound=""

    local dstsize=0
    local progressbar_perc=0
    local progressbar_processed=0
    local progressbar_processed_sub=0
    local progressbar_todo=0
    local progressbar_todo_sub=0

    while [ 1 ]; do
        #Get dstpath (which is the size of dstpath)
        dstsize=$(cat_getsize__func "${dstpath}")

        # calculate the progress in percentage 
        progressbar_perc=$(( (dstsize * 100) / srcsize ))

        # The number of progressbar_processed and progressbar_todo characters
        progressbar_processed=$(( (BAR_SIZE * progressbar_perc) / 100 ))
        progressbar_todo=$(( BAR_SIZE - progressbar_processed ))

        # build the progressbar_processed and progressbar_todo sub-bars
        progressbar_processed_sub=$(printf "%${progressbar_processed}s" | tr " " "${BAR_CHAR_PROCESSED}")
        progressbar_todo_sub=$(printf "%${progressbar_todo}s" | tr " " "${BAR_CHAR_TODO}")

        # output the bar
        echo -ne "\rProgress : [${progressbar_processed_sub}${progressbar_todo_sub}] ${progressbar_perc}% (${dstsize}/${srcsize})"

        #Exit loop if 'pid' is not found anymore
        pid_isfound=$(ps axf | grep "${pid}") | grep -v "color"
        if [[ -z "${pid_isfound}" ]] && [[ ${progressbar_perc} -eq 100 ]]; then
            echo -e ""

            break
        fi
    done
}
function cat_getsize__func() {
    #path can also be a partition (e.g. /dev/mmcblk0p11)
    local path=${1}

    #Define variables
    local ret=0

    #Get size
    if [[ ! -z ${path} ]]; then
        if [[ ! -z $(echo "${path}" | grep "/dev") ]]; then #path contains /dev
            ret=$(fdisk -l "${path}" | grep "${PATTERN_DISK}" | grep -o "${path}.*" | cut -d"," -f2 | cut -d" " -f2)
        else    #path does not contain /dev
            ret=$(ls -l "${path}" | awk '{print $5}')
        fi
    fi

    #Output
    echo "${ret}"
}
function cat_killproc() {
    #Input args
    local pattern=${1}
    
    #Get list of pids matching 'pattern' and write to string
    local pid_list_string=$(ps axf | grep "cat ${pattern}" | grep -v "color" | grep -v "grep" | awk '{print $1}')

    if [[ ! -z "${pid_list_string}" ]]; then
        #Convert string to array
        local pid_list_arr=(${pid_list_string})

        #Iterate thru array and kill processes
        local pid_list_arritem=0
        for pid_list_arritem in "${pid_list_arr[@]}"
        do
            kill -9 ${pid_list_arritem}
        done
    fi
}
function cat_w_progress__func() {
    #Input args
    local srcpath=${1}
    local dstpath=${2}

    #Kill all processes that contains the keyword 'cat ${srcpath}'
    #For example: cat /dev/mmcblk0p11
    cat_killproc "${srcpath}"

    #Copy as a background job
    cat "${srcpath}" > "${dstpath}" &
    local pid=$!

    #Show progress bar
    cat_showprogress__func "${srcpath}" "${dstpath}" "${pid}"
}


function create_and_mount_dir__func() {
    #Input args
    local imagefpath=${1}

    #Get directory
    local mountdir=$(dirname ${imagefpath})

    #Retrieve 'blkid' column 1 and 2 data
    #Put data in string
    local blkid_retry=0
    local label_listof_col12_string=""

    #Start loop
    while [ 1 ]
    do
        #Get blkid info and pass to string
        label_listof_col12_string=$(blkid | awk '{print $1, $2}' | grep "${PATTERN_LABEL}" | sed 's/: /;/g' | sed "s/${PATTERN_LABELIS}//g" | sed 's/"//g')
        
        #Convert string to array
        local label_listof_col12_arr=(${label_listof_col12_string})

        #Initialize variables
        local devpart=""
        local label_listof_col12_arritem=""
        local labelname=""

        #Iterate thru array
        for label_listof_col12_arritem in ${label_listof_col12_arr[*]}
        do

            #Get 'labelname'
            labelname=$(echo "${label_listof_col12_arritem}" | cut -d";" -f2)
            #Check if 'labelname' is found in 'mountdir'
            if [[ ${mountdir} == *"${labelname}"* ]]; then
                #Get partition (including /dev)
                devpart=$(echo "${label_listof_col12_arritem}" | cut -d";" -f1)

                break
            fi
        done

        #Check if 'label_listof_col12_string' is contains data
        if [ ! -z ${devpart} ]; then  #contains data
            #Exit loop
            break
        else    #contains no data
            if [[ ${blkid_retry} -lt ${BLKID_RETRY_MAX} ]]; then
                #Increment counter
                ((blkid_retry++))

                #Print
                echo -e "---:TB-INIT:-:BLKID: retry (${blkid_retry} of ${BLKID_RETRY_MAX})"

                #Wait for 1 second
                sleep 1
            else
                #Print
                echo -e "---:TB-INIT:-:BLKID: ***unable to find match for '${mountdir}'***"
            
                exit_handler__func "${EXITCODE_1}"
            fi
        fi
    done

    #Create directory (temporarily)
    echo -e "---:TB-INIT:-:CREATE: ${mountdir}"
    mkdir -p "${mountdir}"

    #Change permission of directory (temporarily)
    echo -e "---:TB-INIT:-:PERMISSION: chmod 777 ${mountdir}"
    chmod 777 "${mountdir}"

    #Mount 'mountdir' to 'devpart'
    echo -e "---:TB-INIT:-:MOUNT: ${mountdir} to ${devpart}"
    mount -t vfat "${devpart}" "${mountdir}"
}
function umount_and_remove_dir__func() {
    #Input args
    local imagefpath=${1}

    #Get directory
    local mountdir=$(dirname ${imagefpath})

    #Unmount
    umount ${mountdir}

    #Remove directory
    rm -rf ${mountdir}
}

function chkdsk__func() {
    #disable trap ERR
    echo -e "---:TB_INIT:-:CHKDSK: TRAP ERR *DISABLE*"
    trap - ERR

    #Get a list containing the partitions belonging to mmclbk0p
    echo -e "---:TB-INIT:-:RETRIEVE: list of partition belonging to mmcblk0p"
    local dev_mmcblk0p_list_arrstring=$(ls -1 /dev | grep "mmcblk0p" | sed "s/mmcblk0p//g" | sort -n)
    local dev_mmcblk0p_list_arr=(${dev_mmcblk0p_list_arrstring})

    local dev_ismounted=false
    local dev_mmcblk0pi=""

    #Unmount all partitions with partition-numbers 8 and above
    #Remark:
    # partition-number 8 belongs to 'rootfs'
    for i in "${dev_mmcblk0p_list_arr[@]}"
    do
        if [[ ${i} -ge ${ROOTFS_PARTITION_NUM} ]]; then
            dev_mmcblk0pi="${DEV_MMCBLK0P}${i}"

            #Check if partition is mounted
            dev_ismounted=$(mount | grep "${dev_mmcblk0pi}")
            if [[ ! -z "${dev_ismounted}" ]]; then  #is NOT mounted
                echo -e "---:TB-INIT:-:UNMOUNT: ${dev_mmcblk0pi}"
                umount "${dev_mmcblk0pi}"

                echo -e "---:TB-INIT:-:CHKDSK: fsck -a ${dev_mmcblk0pi} (${fsck_retry} out-of ${FSCK_RETRY_MAX})"
                fsck -a "${dev_mmcblk0pi}"
            fi
        fi
    done

    #Enable trap ERR
    echo -e "---:TB_INIT:-:CHKDSK: TRAP ERR *ENABLE*"
    trap trap_err__func ERR
}

function fsck_files_remove__func() {
    #Remove files
    remove_file__func "${fsck_retry_fpath1}"  \
            "${DEV_MMCBLK0P8}" \
            "${rootfs_dir}"

    remove_file__func "${fsck_retry_fpath2}" \
            "${DEV_MMCBLK0P9}" \
            "${tb_reserve_dir}"
}

function fsck_retry_retrieve__func() {
    #disable trap ERR
    echo -e "---:TB_INIT:-:FSCK: TRAP ERR *DISABLE*"
    trap - ERR

    #Define variables
    local fsck_retry1=0
    local fsck_retry2=0

    #Temporarily mount /dev/mmcblk0p9
    if [[ ! -f ${fsck_retry_fpath1} ]] && [[ ! -f ${fsck_retry_fpath2} ]]; then  #path exists
        write_to_file__func "${fsck_retry}" \
                "${FSCK_RETRY_PRINT}" \
                "${fsck_retry_fpath1}" \
                "${DEV_MMCBLK0P8}" \
                "${rootfs_dir}" \
                "true"
        write_to_file__func "${fsck_retry}" \
                "${FSCK_RETRY_PRINT}" \
                "${fsck_retry_fpath2}" \
                "${DEV_MMCBLK0P9}" \
                "${tb_reserve_dir}" \
                "true"
    else  #path does not exist
        #Get 'fsck_retry1' value from file 'fsck_retry_fpath1'
        if [[ -f ${fsck_retry_fpath1} ]]; then  #path exists
            fsck_retry1=$(cat ${fsck_retry_fpath1})
        fi
        #Get 'fsck_retry2' value from file 'fsck_retry_fpath2'
        if [[ -f ${fsck_retry_fpath2} ]]; then  #path exists
            fsck_retry2=$(cat ${fsck_retry_fpath2})
        fi

        #Update 'fsck_retry'
        fsck_retry=${fsck_retry1}
        if [[ ${fsck_retry2} -gt ${fsck_retry1} ]]; then
            fsck_retry=${fsck_retry1}
        fi
    fi

    #Enable trap ERR
    echo -e "---:TB_INIT:-:FSCK: TRAP ERR *ENABLE*"
    trap trap_err__func ERR
}

function checkif_ismounted__func() {
    #Input args
    local devpart=${1}
    local mountdir=${2}

    #Initialize
    local ret=false
    local ismounted=""
    
    #Check if 'devpart' is mounted
    if [[ -z "${mountdir}" ]]; then
        ismounted=$(mount | grep "${devpart}")
    else
        ismounted=$(mount | grep "${devpart}" | grep "${mountdir}")
    fi

    #If is mounted, then update 'ret'
    if [[ ! -z ${ismounted} ]]; then
        ret=true
    fi

    #Output
    echo "${ret}"
}
function mount__func() {
   #Input args
    local devpart=${1}
    local mountdir=${2}

    #Check if already mounted
    if [[ $(checkif_ismounted__func "${devpart}" "${mountdir}") == true ]]; then
        return
    fi

    #Print
    echo -e "---:TB-INIT:-:MOUNT: ${devpart} to ${mountdir}"

    if [[ "${mountdir}" == "${rootfs_dir}" ]]; then   #/dev/mmcblk0p8
        mount -o remount,rw ${mountdir}; exitcode=$?
    else    #all other partitions
        mount ${devpart} ${mountdir}; exitcode=$?
    fi

    if [[ ${exitcode} -ne 0 ]]; then  #successful
        echo -e "---:TB-INIT:-:MOUNT: ${devpart} to ${mountdir} *FAILED*"
    fi
}

function unmount_handler__func() {
   #Input args
    local devpart=${1}
    local mountdir=${2}

    #Remove all trailing slash (/) from 'devpart' (if any)
    local devpart_notrailingslash=$(echo "${devpart}" | sed 's/\/*$//g')

    #Unmount
    if [[ "${devpart_notrailingslash}" == "${DEV_MMCBLK0}" ]]; then
        unmount_all_based_on_pattern__func "${DEV_MMCBLK0P}"
    elif [[ "${devpart_notrailingslash}" == "${DEV_MMCBLK0P}" ]]; then
        unmount_all_based_on_pattern__func "${DEV_MMCBLK0P}"
    else
        unmount__func "${devpart}" "${mountdir}"
    fi
}
function unmount__func() {
   #Input args
    local devpart=${1}
    local mountdir=${2}

    #Check if already unmounted
    if [[ $(checkif_ismounted__func "${devpart}" "${mountdir}") == false ]]; then
        return
    fi

    #DISABLE TRAP when UNMOUNTING
    echo -e "---:TB_INIT:-:UNMOUNT: TRAP ERR *DISABLE*"
    trap - ERR

    #Print
    echo -e "---:TB-INIT:-:UNMOUNT: ${devpart}"
    #Unmount
    umount ${devpart}; exitcode=$?

    if [[ ${exitcode} -ne 0 ]]; then  #successful
        local printmsg="--:TB-INIT:-:UNMOUNT: ${devpart} *FAILED*\n"
        printmsg+="------:TB-INIT:-:STATUS: ${devpart} is *IN-USE*\n"
        printmsg+="------:TB-INIT:-:ADVICE: Make sure no script or app is run from ${devpart}\n"
        echo -e "${printmsg}"

        exit_handler__func "${EXITCODE_1}"
    fi

    #Enable trap ERR
    echo -e "---:TB_INIT:-:UNMOUNT: TRAP ERR *ENABLE*"
    trap trap_err__func ERR
}
function unmount_all_based_on_pattern__func() {
    #Input args
    local devpart=${1}

    #Get basename
    local partname=$(basename "${devpart}")

    #Get a list containing the partitions belonging to mmclbk0p
    echo -e "---:TB-INIT:-:RETRIEVE: list of partitions belonging to ${devpart}"
    local partitionlist_string=$(ls -1 "${DEV}"| grep "${partname}")
    local partitionlist_arr=(${partitionlist_string})
    local partitionlist_arritem=""

    local partition_ismounted=false

    #Unmount all partitions belonging to 'mmcblk0'
    for partitionlist_arritem in "${partitionlist_arr[@]}"
    do
        unmount__func "${DEV}/${partitionlist_arritem}" ""
    done
}

function reboot_handler__func() {
    #reboot to make sure the new rootfs is loaded
    echo -e "---:TB_INIT:-:REBOOT: now \n"

    eval ${reboot_exec}
}

function remove_file__func() {
    #Input args
    local targetfpath=${1}
    local devpart=${2}
    local mountdir=${3}

    #Remove file
    if [[ -f ${targetfpath} ]]; then
        echo -e "---:TB-INIT:-:REMOVE: ${targetfpath}"

        rm ${targetfpath}
    fi
}

function sort_and_uniq_filecontent__func() {
    #Input args
    local targetfpath=${1}

    #Remove blank lines
    sed '/^$/d' "${targetfpath}" > "${targetfpath}.tmp"

    #Sort and uniq
    sort -u "${targetfpath}.tmp" > "${targetfpath}"

    #Remove temporary file
    rm "${targetfpath}.tmp"
}

function write_to_file__func() {
    #disable trap ERR
    echo -e "---:TB_INIT:-:WRITE: TRAP ERR *DISABLE*"
    trap - ERR

    #Input args
    local data=${1}
    local printmsg=${2}
    local targetfpath=${3}
    local devpart=${4}
    local mountdir=${5}
    local flag_overwrite=${6}

    #Get directory
    local targetdir=$(dirname ${targetfpath})
    #Create directory if not present
    if [[ ! -d "${targetdir}" ]] && [[ "${targetdir}" != "${rootfs_dir}" ]]; then
        mkdir -p "${targetdir}"
    fi

    #Print
    if [[ -z "${printmsg}" ]]; then
        echo -e "---:TB-INIT:-:UPDATE: file ${targetfpath} with: ${data}"
    else
        echo -e "---:TB-INIT:-:UPDATE: file ${targetfpath} with ${printmsg}: ${data}"
    fi

    #Write data
    if [[ ${flag_overwrite} == true ]]; then
        echo "${data}" | tee "${targetfpath}"
    else
        echo "${data}" | tee -a "${targetfpath}"

        #Remove double-entries in file 'targetfpath'
        sort_and_uniq_filecontent__func "${targetfpath}"
    fi

    #Enable trap ERR
    echo -e "---:TB_INIT:-:WRITE: TRAP ERR *ENABLE*"
    trap trap_err__func ERR
}

#trap all errors into a function called trap_err__func
function trap_err__func() {
    echo -e "---:TB_INIT:***ERROR***:  An error was encountered while running the script"

    #Retrieve 'fsck_retry'
    fsck_retry_retrieve__func

    if [[ ${fsck_retry} -lt ${FSCK_RETRY_MAX} ]]; then
        #Increment fsck
        ((fsck_retry++))

        #Write data to file
        write_to_file__func "${fsck_retry}" \
                "${FSCK_RETRY_PRINT}" \
                "${fsck_retry_fpath1}" \
                "${DEV_MMCBLK0P8}" \
                "${rootfs_dir}" \
                "true"
        write_to_file__func "${fsck_retry}" \
                "${FSCK_RETRY_PRINT}" \
                "${fsck_retry_fpath2}" \
                "${DEV_MMCBLK0P9}" \
                "${tb_reserve_dir}" \
                "true"

        #Unmount partitions and run disk-check (with autorepair)
        chkdsk__func

        #Unmount All


        #Reboot
        reboot_handler__func
    else
        exit_handler__func "${EXITCODE_1}"
    fi
}



#---START
echo -e ""
echo -e "${PRINT_TB_INIT_SH_START}"



#---ENABLE TRAP ERR
trap trap_err__func ERR



#---MOUNT proc to /proc
mount -t proc ${DEV_NONE} ${proc_dir}



#---TB_RESERVE
if [[ ! -d "${tb_reserve_dir}" ]]; then
    echo -e "---:TB-INIT:-:RESERVE: remounting ${rootfs_dir}"
    mount -o remount,rw ${rootfs_dir} #remounting root in emmc as writeable

    #this is also the first boot.
    #Create an 'ext4' partition '/dev/mmcblk0p9'
    echo -e "---:TB-INIT:-:RESERVE: creating ext4-partition ${DEV_MMCBLK0P9}"
    ${usr_sbin_mkfsext4} ${DEV_MMCBLK0P9}

    echo -e "---:TB_INIT:-:RESERVE: create directory ${tb_reserve_dir}"
    mkdir "${tb_reserve_dir}"

    #flag that root is already remounted
    flag_rootfs_is_remounted=true
fi



#---ADDITIONAL PARTITIONS


#---MOUNT /TB_RESERVE (to check if /tb_reserve/.tb_init_bootargs.tmp is present)
mount__func "${DEV_MMCBLK0P9}" "${tb_reserve_dir}"



#----REMOVE 'fsck_retry_fpath1' and 'fsck_retry_fpath2'
fsck_files_remove__func



#---DETERMINE BOOT OPTION SECTION
echo -e "---:TB-INIT:-:RETRIEVE: kernel bootargs"
if [[ -s "${tb_init_bootargs_tmp_fpath}" ]]; then
    #Get /tb_reserve/.tb_init_bootargs.tmp' contents
    echo -e "---:TB-INIT:-:READ: ${tb_init_bootargs_tmp_fpath}"
    cmdline_output=$(cat ${tb_init_bootargs_tmp_fpath})

    #Remove file
    remove_file__func "${tb_init_bootargs_tmp_fpath}" \
            "${DEV_MMCBLK0P9}" \
            "${tb_reserve_dir}"
else
    #Get /proc/cmdline contents
    echo -e "---:TB-INIT:-:READ: ${proc_cmdline_fpath}"
    proc_cmdline_result=$(cat ${proc_cmdline_fpath})

    if [[ -s "${tb_init_bootargs_cfg_fpath}" ]]; then
        #Get '/tb_reserve/.tb_init_bootargs.cfg' content
        echo -e "---:TB-INIT:-:READ: ${tb_init_bootargs_cfg_fpath}"
        tb_init_bootargs_cfg_result=$(cat ${tb_init_bootargs_cfg_fpath})

        if [[ ${tb_init_bootargs_cfg_result} == *"tb_rootfs_ro=true"* ]]; then  #pattern 'tb_rootfs_ro=true' is found
            if [[ ${proc_cmdline_result} != *"tb_rootfs_ro"* ]]; then
                echo -e "---:TB-INIT:-:INCLUDE: ${PATTERN_TB_ROOTFS_RO_IS_TRUE}"
                cmdline_output="${proc_cmdline_result} ${PATTERN_TB_ROOTFS_RO_IS_TRUE}"
            else
                echo -e "---:TB-INIT:-:STATUS: ${PATTERN_TB_ROOTFS_RO_IS_TRUE} is already included"
                cmdline_output="${proc_cmdline_result}"

                remove_file__func "${tb_init_bootargs_cfg_fpath}" \
                        "${DEV_MMCBLK0P9}" \
                        "${tb_reserve_dir}"
            fi
        else    #pattern 'tb_rootfs_ro=true' is NOT found
            if [[ ${proc_cmdline_result} == *"tb_rootfs_ro"* ]]; then
                echo -e "---:TB-INIT:-:EXCLUDE: ${PATTERN_TB_ROOTFS_RO_IS_TRUE}"
                cmdline_output=$(sed "s/${PATTERN_TB_ROOTFS_RO_IS_TRUE}//g" "${proc_cmdline_fpath}")
            else
                echo -e "---:TB-INIT:-:STATUS: ${PATTERN_TB_ROOTFS_RO_IS_TRUE} is already excluded"
                cmdline_output="${proc_cmdline_result}"

                remove_file__func "${tb_init_bootargs_cfg_fpath}" \
                        "${DEV_MMCBLK0P9}" \
                        "${tb_reserve_dir}"
            fi
        fi
    else
        cmdline_output="${proc_cmdline_result}"
    fi
fi

#if cmdline_output contains the string "tb_overlay"
if [[ ${cmdline_output} == *"tb_overlay"* ]]; then
    tb_overlay=$(echo ${cmdline_output} | grep -oP 'tb_overlay=\K[^ ]*')

    echo -e "---:TB-INIT:-:RESULT: tb_overlay=${tb_overlay}"
else
    tb_overlay=""
fi

#if cmdline_output contains the string "tb_rootfs_ro"
if [[ ${cmdline_output} == *"tb_rootfs_ro"* ]]; then
    tb_rootfs_ro=$(echo ${cmdline_output} | grep -oP 'tb_rootfs_ro=\K[^ ]*')

    echo -e "---:TB-INIT:-:RESULT: tb_rootfs_ro=${tb_rootfs_ro}"
else
    tb_rootfs_ro=""
fi

#if cmdline_output contains the string "tb_backup"
if [[ ${cmdline_output} == *"tb_backup"* ]]; then
    tb_backup=$(echo ${cmdline_output} | grep -oP 'tb_backup=\K[^ ]*')

    echo -e "---:TB-INIT:-:RESULT: tb_backup=${tb_backup}"
else
    tb_backup=""
fi

#if cmdline_output contains the string "tb_restore"
if [[ ${cmdline_output} == *"tb_restore"* ]]; then
    tb_restore=$(echo ${cmdline_output} | grep -oP 'tb_restore=\K[^ ]*')

    echo -e "---:TB-INIT:-:RESULT: tb_restore=${tb_restore}"
else
    tb_restore=""
fi

#if cmdline_output contains the string "tb_noboot"
if [[ ${cmdline_output} == *"tb_noboot"* ]]; then
    tb_noboot=$(echo ${cmdline_output} | grep -oP 'tb_noboot=\K[^ ]*')

    echo -e "---:TB-INIT:-:RESULT: tb_noboot=${tb_noboot}"
else
    tb_noboot=""
fi



#---BACKUP SECTION
#if tb_backup is set, then do a backup of the rootfs
if [ ! -z ${tb_backup} ]; then
    #Get result
    tb_backup_if_devpart=$(echo "${tb_backup}" | cut -d";" -f1)
    tb_backup_of_imagefpath=$(echo "${tb_backup}" | cut -d";" -f2)
    echo -e "---:TB_INIT:-:RESULT: tb_backup_if_devpart: ${tb_backup_if_devpart}"
    echo -e "---:TB_INIT:-:RESULT: tb_backup_of_imagefpath: ${tb_backup_of_imagefpath}"

    #Unmount partition 'tb_backup_if_devpart'
    unmount_handler__func "${tb_backup_if_devpart}"

    #Mount 'tb_backup_of_imagefpath' to its partition
    create_and_mount_dir__func "${tb_backup_of_imagefpath}"

    #Backup
    echo -e "---:TB_INIT:-:BACKUP: start"
    # dd if=${tb_backup_if_devpart} of=${tb_backup_of_imagefpath} oflag=direct status=progress
    # sync
    cat_w_progress__func "${tb_backup_if_devpart}" "${tb_backup_of_imagefpath}"
    echo -e "---:TB_INIT:-:BACKUP: completed successfully"

    #Write 'tb_backup' to 'tb_init_backup_lst_fpath'
    write_to_file__func "${tb_backup}" \
            "" \
            "${tb_init_backup_lst_fpath}" \
            "${DEV_MMCBLK0P9}" \
            "${tb_reserve_dir}" \
            "false"

    #Unmount directory
    umount_and_remove_dir__func "${tb_backup_of_imagefpath}"

    #Reboot
    reboot_handler__func
fi



#---RESTORE SECTION
#if tb_restore is set, then restore the rootfs from the backup
if [ ! -z ${tb_restore} ]; then
    #Get result
    tb_restore_if_imagefpath=$(echo "${tb_restore}" | cut -d";" -f1)
    tb_restore_of_devpart=$(echo "${tb_restore}" | cut -d";" -f2)
    echo -e "---:TB_INIT:-:RESULT: tb_restore_if_imagefpath: ${tb_restore_if_imagefpath}"
    echo -e "---:TB_INIT:-:RESULT: tb_restore_of_devpart: ${tb_restore_of_devpart}"

    #Unmount partition 'tb_backup_if_devpart'
    unmount_handler__func "${tb_restore_of_devpart}"

    #Mount
    create_and_mount_dir__func "${tb_restore_if_imagefpath}"

    #Restore
    echo -e "---:TB_INIT:-:RESTORE: start"
    # dd if=${tb_restore_if_imagefpath} of=${tb_restore_of_devpart} oflag=direct status=progress
    # sync
    cat_w_progress__func "${tb_restore_if_imagefpath}" "${tb_restore_of_devpart}"
    echo -e "---:TB_INIT:-:RESTORE: completed successfully"

    #Unmount
    umount_and_remove_dir__func "${tb_restore_if_imagefpath}"

    #Reboot
    reboot_handler__func
fi



#---SAFEMODE SECTION
#if tb_noboot is set, then boot to minimal system
if [ ! -z ${tb_noboot} ]; then
    while [ 1 ]; do
        bin_bash_handler__func
    done
fi



#---OVERLAY SECTION
#if tb_overlay is set, then mount it
#Remarks:
# if overlay does NOT exist or 'size=0', then
# ...DO NOT add 'tb_overlay' in file 'penagram_common.h', line '"b_c=console=tty1 console=ttyS0,115200 earlyprintk\0" \
# However, if overlay exist and 'size>0', then
# ...ADD 'tb_overlay' in file 'penagram_common.h', line '"b_c=console=tty1 console=ttyS0,115200 earlyprintk tb_overlay\0" \
if [ ! -z ${tb_overlay} ]; then
    echo -e "---:TB-INIT:-:OVERLAY: START"

    #create /overlay if it doesn't exist
    if [ ! -d ${overlay_dir} ]; then    
            if [[ ${flag_rootfs_is_remounted} == false ]]; then
                echo -e "------:TB_INIT:-:REMOUNT: ${rootfs_dir}"
                mount -o remount,rw ${rootfs_dir} #remounting root in emmc as writeable

                #Create dir
                if [[ ! -d ${rootfs_etc_tibbo_uboot_dir} ]]; then
                    echo -e "------:TB_INIT:-:CREATE: ${rootfs_etc_tibbo_uboot_dir}"
                    mkdir -p ${rootfs_etc_tibbo_uboot_dir}
                fi
            fi

            echo -e "------:TB_INIT:-:CREATE: ${overlay_dir}"
            mkdir ${overlay_dir}

            #Create an 'ext4' partition '/dev/mmcblk0p9'
            echo -e "------:TB_INIT:-:CREATE: ext4-partition ${tb_overlay}"
            ${usr_sbin_mkfsext4} ${tb_overlay}
    fi

#---UNMOUNT /TB_RESERVE
    echo -e "------:TB_INIT:-:MOUNT: ${overlay_dir}"
    mount ${tb_overlay} ${overlay_dir}

    #if tb_rootfs_ro is equal to true then delete the contents of /overlay
    #Remarks:
    # non-persistent -> remove overlay partition. 
    # ...This means add 'tb_rootfs_ro' in file 'penagram_common.h', line "b_c=console=tty1 console=ttyS0,115200 earlyprintk tb_overlay tb_rootfs_ro\0"
    # persistent -> do not remove overlay partition. 
    # ...This means do NOT add 'tb_rootfs_ro' in file 'penagram_common.h', line "b_c=console=tty1 console=ttyS0,115200 earlyprintk tb_overlay\0"
    if [ "${tb_rootfs_ro}" = "true" ]; then #non-persistent
        echo -e "------:TB_INIT:-:STATUS: tb_rootfs_ro is set, deleting contents of ${overlay_dir}"
        rm -rf ${overlay_dir}/*
    else  #persistent
        echo -e "------:TB_INIT:-:STATUS: tb_rootfs_ro is not set, not deleting contents of ${overlay_dir}"
    fi

    if [ ! -d ${overlay_dir}/root ]; then
        echo -e "------:TB_INIT:-:CREATE: ${overlay_dir}/root"

        mkdir ${overlay_dir}/root
    fi

    #if  /overlay/root_upper does not exist then create it
    if [ ! -d ${overlay_dir}/root_upper ]; then
        echo -e "------:TB_INIT:-:CREATE: ${overlay_dir}/root_upper"

        mkdir ${overlay_dir}/root_upper
    fi

    #if  /overlay/root_work does not exist then create it
    if [ ! -d ${overlay_dir}/root_work ]; then
        echo -e "------:TB_INIT:-:CREATE: ${overlay_dir}/root_work"

        mkdir ${overlay_dir}/root_work
    fi

    echo -e "------:TB_INIT:-:REMOUNT: / in EMMC as READONLY"
    mount -o remount,ro / #remounting root in emmc as readonly

    echo -e "------:TB_INIT:-:MOUNT: mount -t overlay overlay ${overlay_dir}/root -o lowerdir=/,upperdir=${overlay_dir}/root_upper,workdir=${overlay_dir}/root_work"
    mount -t overlay overlay ${overlay_dir}/root -o lowerdir=/,upperdir=${overlay_dir}/root_upper,workdir=${overlay_dir}/root_work

    echo -e "------:TB_INIT:-:GOTO: ${overlay_dir}/root"
    cd ${overlay_dir}/root

    #if oldroot does not exits then create it
    if [ ! -d oldroot ]; then
        echo -e "------:TB_INIT:-:CREATE: oldroot"

        mkdir oldroot
    fi

    #change root from '.' to 'oldroot'
    #Remark:
    # This means that the 'overlay' partition is placed under /oldroot
    echo -e "------:TB_INIT:-:CHANGE: rootfs from '.' to 'oldroot'"
    pivot_root . oldroot


    echo -e "---:TB-INIT:-:OVERLAY: END"
fi



#---UNMOUNT ALL
unmount_handler__func "${DEV_MMCBLK0}"



#---Attempt to start systemd
echo -e "---:TB-INIT:-:EXEC: ${lib_systemd_systemd_exec}"
exec ${lib_systemd_systemd_exec}



trap_err__func
