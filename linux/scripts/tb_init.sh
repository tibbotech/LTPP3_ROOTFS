#!/bin/bash
#---CONSTANTS
EXITCODE_1=1

BLKID_RETRY_MAX=10
FSCK_RETRY_MAX=3

FIRST_PARTITION_NUM=1
ROOTFS_PARTITION_NUM=8

TCOUNTER_MAX=10

CHMOD_PERMISSION_644=644
CHMOD_PERMISSION_755=755

COPYTYPE_BACKUP="backup"
COPYTYPE_RESTORE="restore"

DD_TX_SPEED="1M"

DEV="/dev"
DEV_MMCBLK0=/dev/mmcblk0
DEV_MMCBLK0P=${DEV_MMCBLK0}p
DEV_MMCBLK0P8=${DEV_MMCBLK0P}8
DEV_MMCBLK0P9=${DEV_MMCBLK0P}9
DEV_NONE="none"

FOUR_SPACES="    "

FSCK_RETRY_PRINT="fsck_retry"

PATTERN_DISK="Disk"
PATTERN_LABEL="LABEL"
PATTERN_LABELIS="LABEL="
PATTERN_TB_ROOTFS_RO="tb_rootfs_ro"
PATTERN_TB_ROOTFS_RO_IS_TRUE="tb_rootfs_ro=true"

PROC_FSTYPE="proc"



#---VARIABLES
bin_bash_exec=/bin/bash

etc_update_motd_d_dir=/etc/update-motd.d
overlay_dir=/overlay
proc_dir=/proc
proc_cmdline_fpath=${proc_dir}/cmdline
proc_sys_kernel_sysrq_fpath=${proc_dir}/sys/kernel/sysrq
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
tb_overlay_current_cfg_fpath=${tb_reserve_dir}/.tb_overlay_current.cfg

motd_96_overlayboot_notice_fpath=${etc_update_motd_d_dir}/96-overlayboot-notice
motd_98_normalboot_notice_fpath=${etc_update_motd_d_dir}/98-normalboot-notice

reboot_cmd="echo 1 >${proc_sys_kernel_sysrq_fpath} && echo b >${proc_sysrqtrigger_fpath}"

print_cleanboot_mode="\n*********************************************************************\n"
print_cleanboot_mode+="${FOUR_SPACES}Entering *clean-boot* environment\n"
print_cleanboot_mode+="*********************************************************************\n"
print_cleanboot_mode+="${FOUR_SPACES}To go back to the overlay-boot environment, use command:\n"
print_cleanboot_mode+="\n"
print_cleanboot_mode+="${FOUR_SPACES}${FOUR_SPACES}${reboot_cmd}"
print_cleanboot_mode+="\n"
print_cleanboot_mode+="*********************************************************************\n"

print_error_mode="\n*********************************************************************\n"
print_error_mode+="${FOUR_SPACES}An *error* just occured\n"
print_error_mode+="*********************************************************************\n"
print_error_mode+="${FOUR_SPACES}To go back to the overlay-boot environment, use command:\n"
print_error_mode+="\n"
print_error_mode+="${FOUR_SPACES}${FOUR_SPACES}${reboot_cmd}"
print_error_mode+="\n"
print_error_mode+="*********************************************************************\n"

print_start="\n\n*********************************************************************\n"
print_start+="${FOUR_SPACES}TB_INIT.SH\n"
print_start+="*********************************************************************"

print_end="\n*********************************************************************\n"

keyinput=""

fsck_retry=0



#---FUNCTIONS
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

function chmod__func() {
    #Input args
    local targetfpath__input=${1}
    local permission__input=${2}

    #Change permissions
    chmod ${permission__input} ${targetfpath__input}
}

function cleanboot_handler__func() {
    echo -e "${print_cleanboot_mode}"

    ${bin_bash_exec}
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
            
                exit__func "${EXITCODE_1}"
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

function dd_handler__func() {
    #Input args
    local srcpath=${1}
    local dstpath=${2}

    #Print
    local printmsg="\n*********************************************************************\n"
    printmsg+="    COPY-OVERVIEW\n"
    printmsg+="*********************************************************************\n"
    printmsg+="    From:\t${srcpath}\n"
    printmsg+="    To:\t\t${dstpath}\n"
    printmsg+="\n"
    printmsg+="    Note:\n"
    printmsg+="\tIf the copy process appears to be frozen,\n"
    printmsg+="\tPlease don't be alarmed and wait patiently.\n"
    printmsg+="*********************************************************************\n"
    echo -e "${printmsg}"


    #Copy
    dd if=${srcpath} of=${dstpath} bs=${DD_TX_SPEED} oflag=direct status=progress && sync
}

function dst_diskspace_issufficient__func() {
    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    # This function passes the result to 
    # the global variable 'dst_diskspace_issufficient'.
    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    #Input args
    local srcpath=${1}
    local dstpath=${2}
    local copytype=${3}

    #Define constants
    local PHASE_BACKUP_SRCSIZE=10
    local PHASE_BACKUP_DSTSIZE=11
    local PHASE_BACKUP_COMPARE_SIZES=12
    local PHASE_BACKUP_EXIT=13
    local PHASE_RESTORE_SRCSIZE=20
    local PHASE_RESTORE_DSTSIZE=21
    local PHASE_RESTORE_COMPARE_SIZES=22
    local PHASE_RESTORE_EXIT=23

    #Define variables
    local dstdir=""
    local phase=""
    local printmsg=""
    local exitcode=0
    local dstsize_B=0
    local dstsize_KB=0
    local srcsize_B=0
    local srcsize_KB=0

    #Initialize variables
    dst_diskspace_issufficient=false
    
    case "${copytype}" in
        "${COPYTYPE_BACKUP}")
            #Set start phase
            phase="${PHASE_BACKUP_SRCSIZE}"

            while [[ 1 ]]
            do
                case "${phase}" in
                    "${PHASE_BACKUP_SRCSIZE}")
                        #Get source size in KB
                        srcsize_B=$(blockdev --getsize64 "${srcpath}" 2> /dev/null); exitcode=$?

                        if [[ ${exitcode} -eq 0 ]]; then    #succesful
                            #Convert to Kilobytes
                            srcsize_KB=$((srcsize_B / 1024))

                            #Goto next-phase
                            phase="${PHASE_BACKUP_DSTSIZE}"
                        else    #error
                            #Print error-message
                            printmsg+="--:TB-INIT:-:DISKSPACE-ERROR: '${srcpath}' is *NOT* a partition\n"
                            printmsg+="--:TB-INIT:-:DISKSPACE-NOTE: SOURCE *must* be an existing partition (e.g. /dev/mmcblk0)\n"
                            echo -e "${printmsg}"

                            #Goto next-phase
                            phase="${PHASE_BACKUP_EXIT}"
                        fi
                        ;;
                    "${PHASE_BACKUP_DSTSIZE}")
                        #Get directory of 'dstpath'
                        dstdir=$(dirname "${dstpath}")
                        if [[ -d ${dstdir} ]]; then
                            #Get destination size in KB
                            dstsize_KB=$(df --output='avail' -k "${dstdir}" | tail -n1 | sed 's/^ *//g' | sed 's/* $//g'); exitcode=$?

                            #Goto next-phase
                            phase="${PHASE_BACKUP_COMPARE_SIZES}"
                        else
                            #Print error-message
                            printmsg="--:TB-INIT:-:DISKSPACE-ERROR: '${dstdir}' does *NOT* exist\n"
                            printmsg+="--:TB-INIT:-:DISKSPACE-NOTE: please choose an existing DESTINATION location for the backup-file\n"
                            echo -e "${printmsg}"

                            #Set exitcode
                            exitcode=1

                            #Goto next-phase
                            phase="${PHASE_BACKUP_EXIT}"
                        fi
                        ;;
                    "${PHASE_BACKUP_COMPARE_SIZES}")
                        #Compare 'dstsize_KB' with 'srcsize_KB'
                        #Note: dstsize_KB MUST be greater than 'srcsize_KB'
                        if [[ ${dstsize_KB} -gt ${srcsize_KB} ]]; then
                            #Set exitcode
                            exitcode=0
                        else
                            printmsg="--:TB-INIT:-:DISKSPACE-SRC: ${srcpath}: ${srcsize_KB}K\n"
                            printmsg+="--:TB-INIT:-:DISKSPACE-DST: ${dstpath}: ${dstsize_KB}K\n"
                            printmsg+="--:TB-INIT:-:DISKSPACE-ERROR: *insufficient* diskspace (${srcsize_KB}K > ${dstsize_KB}K)\n"
                            printmsg+="--:TB-INIT:-:DISKSPACE-NOTE: free-up diskspace or choose another destination\n"
                            echo -e "${printmsg}"

                            #Set exitcode
                            exitcode=1
                        fi

                        #Goto next-phase
                        phase="${PHASE_BACKUP_EXIT}"
                        ;;
                    "${PHASE_BACKUP_EXIT}")
                        if [[ ${exitcode} -eq 0 ]]; then    #error occurred
                            dst_diskspace_issufficient=true
                        else
                            dst_diskspace_issufficient=false
                        fi

                        break
                        ;;
                esac
            done
            ;;
        "${COPYTYPE_RESTORE}")
            #Set start phase
            phase="${PHASE_RESTORE_SRCSIZE}"

            while [[ 1 ]]
            do
                case "${phase}" in
                    "${PHASE_RESTORE_SRCSIZE}")
                        if [[ -f "${srcpath}" ]]; then  #is a file
                            #Get source size in KB
                            srcsize_B=$(ls -l "${srcpath}" | awk '{print $5}'); exitcode=$?

                            if [[ ${exitcode} -eq 0 ]]; then    #succesful
                                #Convert to Kilobytes
                                srcsize_KB=$((srcsize_B / 1024))

                                #Goto next-phase
                                phase="${PHASE_RESTORE_DSTSIZE}"
                            else
                                #Goto next-phase
                                phase="${PHASE_RESTORE_EXIT}"
                            fi
                        else    #is not a file
                            #Print error-message
                            printmsg="--:TB-INIT:-:DISKSPACE-ERROR: ${srcpath} is *NOT* a backup-file\n"
                            printmsg+="--:TB-INIT:-:DISKSPACE-NOTE: SOURCE *must* be an existing backup-file\n"
                            echo -e "${printmsg}"

                            #Set exitcode
                            exitcode=1

                            #Goto next-phase
                            phase="${PHASE_RESTORE_EXIT}"
                        fi
                        ;;
                    "${PHASE_RESTORE_DSTSIZE}")
                        #Get destination size in KB
                        dstsize_B=$(blockdev --getsize64 "${dstpath}" 2> /dev/null); exitcode=$?
                        if [[ ${exitcode} -eq 0 ]]; then    #succesful
                            #Convert to Kilobytes
                            dstsize_KB=$((dstsize_B / 1024))

                            #Goto next-phase
                            phase="${PHASE_RESTORE_COMPARE_SIZES}"
                        else    #error
                            #Print error-message
                            printmsg+="--:TB-INIT:-:DISKSPACE-ERROR: '${dstpath}' is *NOT* a partition\n"
                            printmsg+="--:TB-INIT:-:DISKSPACE-NOTE: DESTINATION *must* be an existing partition (e.g. /dev/mmcblk0)\n"
                            echo -e "${printmsg}"

                            #Goto next-phase
                            phase="${PHASE_RESTORE_EXIT}"
                        fi

                        ;;
                    "${PHASE_RESTORE_COMPARE_SIZES}")
                        #Compare 'dstsize_KB' with 'srcsize_KB'
                        #Note: dstsize_KB MUST be greater than 'srcsize_KB'
                        if [[ ${dstsize_KB} -lt ${srcsize_KB} ]]; then
                            printmsg="--:TB-INIT:-:DISKSPACE-SRC: ${srcpath}: ${srcsize_KB}K\n"
                            printmsg+="--:TB-INIT:-:DISKSPACE-DST: ${dstpath}: ${dstsize_KB}K\n"
                            printmsg+="--:TB-INIT:-:DISKSPACE-ERROR: *insufficient* diskspace (${srcsize_KB}K > ${dstsize_KB}K)\n"
                            printmsg+="--:TB-INIT:-:DISKSPACE-NOTE: free-up diskspace or choose another destination\n"
                            echo -e "${printmsg}"

                            #Set exitcode
                            exitcode=1
                        else
                            #Set exitcode
                            exitcode=0
                        fi

                        #Goto next-phase
                        phase="${PHASE_RESTORE_EXIT}"
                        ;;
                    "${PHASE_RESTORE_EXIT}")
                        if [[ ${exitcode} -eq 0 ]]; then    #error occurred
                            dst_diskspace_issufficient=true
                        else
                            dst_diskspace_issufficient=false
                        fi

                        break
                        ;;
                esac
            done
            ;;
    esac
}

function exit__func() {
    #Input args
    local exitcode=${1}

    #Print
    echo -e "${print_error_mode}"

    #Mount '/proc' and '/sys
    # mount_proc__func

    #Exit
    exit ${exitcode}
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
    if [[ ! -f ${fsck_retry_fpath1} ]] && [[ ! -f ${fsck_retry_fpath2} ]]; then  #paths do NOT exist
        #Make directory
        mkdir__func "${rootfs_etc_tibbo_uboot_dir}"

        echo "${fsck_retry}" | tee ${fsck_retry_fpath1}
        # write_to_file__func "${fsck_retry}" \
        #         "${FSCK_RETRY_PRINT}" \
        #         "${fsck_retry_fpath1}" \
        #         "${DEV_MMCBLK0P8}" \
        #         "${rootfs_dir}" \
        #         "true"
        echo "${fsck_retry}" | tee ${fsck_retry_fpath2}
        # write_to_file__func "${fsck_retry}" \
        #         "${FSCK_RETRY_PRINT}" \
        #         "${fsck_retry_fpath2}" \
        #         "${DEV_MMCBLK0P9}" \
        #         "${tb_reserve_dir}" \
        #         "true"
    else  #paths DO exist
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

function mkdir__func() {
    #Input args
    local targetfpath=${1}

    #Make directory
    if [[ ! -d "${targetfpath}" ]]; then
        mkdir -p "${rootfs_etc_tibbo_uboot_dir}"
    fi
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

function choose_a_key_to_continue__func() {
    #Remark:
    #   This function passes the result to the global variable 'keyinput'

    #Input args
    local tcountermax=${1}

    #Define variables
    local readdialog=""
    local readdialog_len=0
    local tcounter=${tcountermax}

    #Move cursor down with 1 line
    tput cud1

    #Start loop
    while [[ ${tcounter} -gt 0 ]]
    do
        #Update read-dialog
        readdialog="press (s)afemode or any key to reboot (${tcounter})"
        readdialog_len=${#readdialog}

        #Show read-dialog and automatically continue after 1 second
        read -t1 -rsN1 -p "${readdialog}" keyinput

        #Break in case any-key is pressed
        if [[ ! -z "${keyinput}" ]]; then
            #Move cursor down with 2 line
            tput cud1 && tput cud1

            #Break loop
            break
        fi

        #Decrement counter
        ((tcounter--))

        if [[ ${tcounter} -gt 0 ]]; then
            #Move cursor with 'readdialog_len' to the left
            #Clean all other characters on the right
            tput cub ${readdialog_len} && tput el
        else
            #Move cursor down with 2 line
            tput cud1 && tput cud1
        fi
    done
 }

function unmount_mmcblk0p8_mccblk0p9__func() {
    unmount__func "${DEV_MMCBLK0P9}" ""
    unmount__func "${DEV_MMCBLK0P8}" ""
}

# function unmount_handler__func() {
#    #Input args
#     local devpart=${1}
#     local mountdir=${2}

#     #Remove all trailing slash (/) from 'devpart' (if any)
#     local devpart_notrailingslash=$(echo "${devpart}" | sed 's/\/*$//g')

#     #Unmount
#     if [[ "${devpart_notrailingslash}" == "${DEV_MMCBLK0}" ]]; then
#         unmount_all_based_on_pattern__func "${DEV_MMCBLK0P}"
#     elif [[ "${devpart_notrailingslash}" == "${DEV_MMCBLK0P}" ]]; then
#         unmount_all_based_on_pattern__func "${DEV_MMCBLK0P}"
#     else
#         unmount__func "${devpart}" "${mountdir}"
#     fi
# }
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
        local printmsg="--:TB-INIT:-:UNMOUNT-ERROR: ${devpart} *FAILED*\n"
        printmsg+="------:TB-INIT:-:UNMOUNT-ERROR: ${devpart} is *IN-USE*\n"
        printmsg+="------:TB-INIT:-:UNMOUNT-NOTE: Make sure no script or app is run from ${devpart}\n"
        echo -e "${printmsg}"

        exit__func "${EXITCODE_1}"
    fi

    #Enable trap ERR
    echo -e "---:TB_INIT:-:UNMOUNT: TRAP ERR *ENABLE*"
    trap trap_err__func ERR
}
# function unmount_all_based_on_pattern__func() {
#     #Input args
#     local devpart=${1}

#     #Get basename
#     local partname=$(basename "${devpart}")

#     #Get a list containing the partitions belonging to mmclbk0p
#     echo -e "---:TB-INIT:-:RETRIEVE: list of partitions belonging to ${devpart}"
#     local partitionlist_string=$(ls -1 "${DEV}"| grep "${partname}")
#     local partitionlist_arr=(${partitionlist_string})
#     local partitionlist_arritem=""

#     local partition_ismounted=false

#     #Unmount all partitions belonging to 'mmcblk0'
#     for partitionlist_arritem in "${partitionlist_arr[@]}"
#     do
#         unmount__func "${DEV}/${partitionlist_arritem}" ""
#     done
# }

function unmount_and_remove_dir__func() {
    #Input args
    local imagefpath=${1}

    #Get directory
    local mountdir=$(dirname ${imagefpath})

    #Print
    echo -e "---:TB-INIT:-:UNMOUNT: ${mountdir}"

    #Unmount
    umount ${mountdir}

    #Remove directory
    rm -rf ${mountdir}
}

function reboot__func() {
    eval ${reboot_cmd}
}
function safemode_or_reboot__func() {
    #Choose a key to continue
    #Remark:
    #   This function passes the result to the global variable 'keyinput'
    choose_a_key_to_continue__func "${TCOUNTER_MAX}"

    if [[ "${keyinput}" == "s" ]]; then
        #Go to safe-mode
        exit__func "${EXITCODE_1}"
    else
        #Unmount all
        # unmount_handler__func "${DEV_MMCBLK0}"
        unmount_mmcblk0p8_mccblk0p9__func


        #Reboot to overlay-environment
        reboot__func
    fi
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
    else
        echo -e "---:TB-INIT:-:FILE NOT PRESENT: ${targetfpath}"
        echo -e "---:TB-INIT:-:NOTHING TO REMOVE..."
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

# function write_to_file__func() {
#     #disable trap ERR
#     echo -e "---:TB_INIT:-:WRITE: TRAP ERR *DISABLE*"
#     trap - ERR

#     #Input args
#     local data=${1}
#     local printmsg=${2}
#     local targetfpath=${3}
#     local devpart=${4}
#     local mountdir=${5}
#     local flag_overwrite=${6}

#     #Get directory
#     local targetdir=$(dirname ${targetfpath})
#     #Create directory if not present
#     if [[ ! -d "${targetdir}" ]] && [[ "${targetdir}" != "${rootfs_dir}" ]]; then
#         mkdir -p "${targetdir}"
#     fi

#     #Print
#     if [[ -z "${printmsg}" ]]; then
#         echo -e "---:TB-INIT:-:UPDATE: file ${targetfpath} with: ${data}"
#     else
#         echo -e "---:TB-INIT:-:UPDATE: file ${targetfpath} with ${printmsg}: ${data}"
#     fi

#     #Write data
#     if [[ ${flag_overwrite} == true ]]; then
#         echo "${data}" | tee "${targetfpath}"
#     else
#         echo "${data}" | tee -a "${targetfpath}"

#         #Remove double-entries in file 'targetfpath'
#         sort_and_uniq_filecontent__func "${targetfpath}"
#     fi

#     #Enable trap ERR
#     echo -e "---:TB_INIT:-:WRITE: TRAP ERR *ENABLE*"
#     trap trap_err__func ERR
# }

function mount_proc__func() {
    mount -t ${PROC_FSTYPE} ${DEV_NONE} ${proc_dir}
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
        echo "${fsck_retry}" | tee ${fsck_retry_fpath1}
        # write_to_file__func "${fsck_retry}" \
        #         "${FSCK_RETRY_PRINT}" \
        #         "${fsck_retry_fpath1}" \
        #         "${DEV_MMCBLK0P8}" \
        #         "${rootfs_dir}" \
        #         "true"
        echo "${fsck_retry}" | tee ${fsck_retry_fpath2}
        # write_to_file__func "${fsck_retry}" \
        #         "${FSCK_RETRY_PRINT}" \
        #         "${fsck_retry_fpath2}" \
        #         "${DEV_MMCBLK0P9}" \
        #         "${tb_reserve_dir}" \
        #         "true"

        #Unmount partitions and run disk-check (with autorepair)
        chkdsk__func

        #Reboot
        reboot__func
    else
        exit__func "${EXITCODE_1}"
    fi
}



#---START
echo -e "${print_start}"



#---ENABLE TRAP ERR
trap trap_err__func ERR



#---MOUNT '/proc' and '/sys
mount_proc__func



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

        if [[ ${tb_init_bootargs_cfg_result} == *"tb_rootfs_ro=true"* ]]; then  #'tb_rootfs_ro=true' is found in 'tb_init_bootargs.cfg'
            if [[ ${proc_cmdline_result} != *"tb_rootfs_ro"* ]]; then   #'tb_rootfs_ro=true' is NOT found
                echo -e "---:TB-INIT:-:INCLUDE: ${PATTERN_TB_ROOTFS_RO_IS_TRUE}"
                cmdline_output="${proc_cmdline_result} ${PATTERN_TB_ROOTFS_RO_IS_TRUE}"
            else
                echo -e "---:TB-INIT:-:STATUS: ${PATTERN_TB_ROOTFS_RO_IS_TRUE} is already included"
                cmdline_output="${proc_cmdline_result}"

                remove_file__func "${tb_init_bootargs_cfg_fpath}" \
                        "${DEV_MMCBLK0P9}" \
                        "${tb_reserve_dir}"
            fi
        else    #'tb_rootfs_ro=true' is NOT found in 'tb_init_bootargs.cfg'
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

#---WRITE 'tb_rootfs_ro' value to file
#Remark:
#   This is important, because it will be used in 'tb_init_bootmenu' for validation.
echo "${PATTERN_TB_ROOTFS_RO}=${tb_rootfs_ro}" | tee ${tb_overlay_current_cfg_fpath}


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

#if cmdline_output contains the string "tb_normalboot"
if [[ ${cmdline_output} == *"tb_normalboot"* ]]; then
    tb_normalboot=$(echo ${cmdline_output} | grep -oP 'tb_normalboot=\K[^ ]*')

    echo -e "---:TB-INIT:-:RESULT: tb_normalboot=${tb_normalboot}"
else
    tb_normalboot=""
fi



#---BACKUP SECTION
#if tb_backup is set, then do a backup of the rootfs
if [ ! -z ${tb_backup} ]; then
    #Get result
    tb_backup_if_devpart=$(echo "${tb_backup}" | cut -d";" -f1)
    tb_backup_of_imagefpath=$(echo "${tb_backup}" | cut -d";" -f2)
    echo -e "---:TB_INIT:-:RESULT: tb_backup_if_devpart: ${tb_backup_if_devpart}"
    echo -e "---:TB_INIT:-:RESULT: tb_backup_of_imagefpath: ${tb_backup_of_imagefpath}"

    #Mount 'tb_backup_of_imagefpath' to its partition
    create_and_mount_dir__func "${tb_backup_of_imagefpath}"

    #Check if destination diskspace is sufficient
    #Remark:
    #   This function passes the result to the global variable 'dst_diskspace_issufficient'
    dst_diskspace_issufficient__func "${tb_backup_if_devpart}" \
            "${tb_backup_of_imagefpath}" \
            "${COPYTYPE_BACKUP}"
    if [[ ${dst_diskspace_issufficient} == true ]]; then
        #Backup
        dd_handler__func "${tb_backup_if_devpart}" "${tb_backup_of_imagefpath}"

        #Write 'tb_backup' to 'tb_init_backup_lst_fpath'
        echo "${tb_backup}" | tee -a ${tb_init_backup_lst_fpath}
        # write_to_file__func "${tb_backup}" \
        #         "" \
        #         "${tb_init_backup_lst_fpath}" \
        #         "${DEV_MMCBLK0P9}" \
        #         "${tb_reserve_dir}" \
        #         "false"
    fi

    #Unmount directory 'tb_backup_of_imagefpath'
    unmount_and_remove_dir__func "${tb_backup_of_imagefpath}"

    #Reboot
    safemode_or_reboot__func
fi



#---RESTORE SECTION
#if tb_restore is set, then restore the rootfs from the backup
if [ ! -z ${tb_restore} ]; then
    #Get result
    tb_restore_if_imagefpath=$(echo "${tb_restore}" | cut -d";" -f1)
    tb_restore_of_devpart=$(echo "${tb_restore}" | cut -d";" -f2)
    echo -e "---:TB_INIT:-:RESULT: tb_restore_if_imagefpath: ${tb_restore_if_imagefpath}"
    echo -e "---:TB_INIT:-:RESULT: tb_restore_of_devpart: ${tb_restore_of_devpart}"

    #Mount
    create_and_mount_dir__func "${tb_restore_if_imagefpath}"

    #Check if destination diskspace is sufficient
    #Remark:
    #   This function passes the result to the global variable 'dst_diskspace_issufficient'
    dst_diskspace_issufficient__func "${tb_restore_if_imagefpath}" \
            "${tb_restore_of_devpart}" \
            "${COPYTYPE_RESTORE}"

    if [[ ${dst_diskspace_issufficient} == true ]]; then
        #Restore
        dd_handler__func "${tb_restore_if_imagefpath}" "${tb_restore_of_devpart}"
    fi

    #Unmount 'tb_restore_if_imagefpath'
    unmount_and_remove_dir__func "${tb_restore_if_imagefpath}"

    #Reboot
    safemode_or_reboot__func
fi



#---CLEAN-BOOT SECTION
#if tb_noboot is set, then boot to minimal system
if [ ! -z ${tb_noboot} ]; then
    echo -e "---:TB_INIT:-:BOOT-MODE: clean (without overlay)"

    while [ 1 ]; do
        cleanboot_handler__func
    done
fi



#---NORMAL-BOOT SECTION
if [ ! -z ${tb_normalboot} ]; then
    echo -e "---:TB_INIT:-:BOOT-MODE: normal (without overlay)"

    #Change permission of '96-overlayboot-notice' to 'rw-r--r--'
    #Note: this way this script will NOT be executed.
    chmod__func "${motd_96_overlayboot_notice_fpath}" "${CHMOD_PERMISSION_644}"
    #Change permission of '98-normalboot-notice' to 'rwxr-xr-x'
    chmod__func "${motd_98_normalboot_notice_fpath}" "${CHMOD_PERMISSION_755}"
else
    #Change permission of '96-overlayboot-notice' to 'rwxr-xr-x'
    chmod__func "${motd_96_overlayboot_notice_fpath}" "${CHMOD_PERMISSION_755}"
    #Change permission of '98-normalboot-notice' to 'rw-r--r--'
    #Note: this way this script will NOT be executed.
    chmod__func "${motd_98_normalboot_notice_fpath}" "${CHMOD_PERMISSION_644}"
fi 


#---OVERLAY SECTION
#if tb_overlay is set, then mount it
#Remarks:
# if overlay does NOT exist or 'size=0', then
# ...DO NOT add 'tb_overlay' in file 'pentagram_common.h', line '"b_c=console=tty1 console=ttyS0,115200 earlyprintk\0" \
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
# unmount_mmcblk0p8_mccblk0p9__func



#---Attempt to start systemd
echo -e "---:TB-INIT:-:EXEC: ${lib_systemd_systemd_exec}"
echo -e "${print_end}"

exec ${lib_systemd_systemd_exec}



trap_err__func
