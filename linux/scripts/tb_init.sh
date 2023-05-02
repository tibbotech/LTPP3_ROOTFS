#!/bin/bash
#---CONSTANTS
EXIT_CODE_1="exit 1"
FSCK_RETRY_PRINT="fsck_retry"
FSCK_RETRY_MAX=3
NULL="null"

PATTERN_TB_OVERLAY_OLD="tb_overlay=\/dev\/mmcblk0p10"
PATTERN_TB_ROOTFS_RO="tb_rootfs_ro"
PATTERN_TB_ROOTFS_RO_IS_TRUE="tb_rootfs_ro=true"

PRINT_ERROR="***ERROR***"
PRINT_TB_INIT_START="---:TB-INIT:-:START"
PRINT_TB_INIT_COMPLETED="---:TB-INIT:-:COMPLETED"
PRINT_TB_INIT_DISABLED="------:TB-INIT:-:DISABLED"
PRINT_TB_INIT_ENABLED="------:TB-INIT:-:ENABLED"
PRINT_TB_INIT_RESULT="------:TB-INIT:-:RESULT"
PRINT_TB_INIT_OVERLAY_SECTION="------:TB-INIT:-:OVERLAY-SECTION"
PRINT_TB_INIT_STATUS="------:TB_INIT:-:STATUS"
PRINT_TB_INIT_REMOVING="------:TB_INIT:-:REMOVING"




#---VARIABLES
bin_bash_exec=/bin/bash

dev_mmcblk0=/dev/mmcblk0
dev_mmcblk0p=/dev/mmcblk0p
dev_mmcblk0p8=/dev/mmcblk0p8
dev_mmcblk0p9=/dev/mmcblk0p9

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
tb_init_bootargs_fpath=${tb_reserve_dir}/.tb_init_bootargs.tmp


fsck_retry=0
rootfs_partition_num=8

cmd_setto_safemode="echo 1 >${proc_sys_kernel_sysrq}"
cmd_reboot="echo b >${proc_sysrqtrigger_fpath}"



#---FUNCTIONS
function reboot_exec() {
    eval ${cmd_setto_safemode}
    eval ${cmd_reboot}
}

function chkdsk__func() {
    #disable trap ERR
    echo -e "${PRINT_TB_INIT_DISABLED}: trap ERR\n"
    trap - ERR

    #Get a list containing the partitions belonging to mmclbk0p
    echo -e "${PRINT_TB_INIT_STATUS}: Get a list of partition-numbers belonging to mmcblk0p\n"
    local dev_mmcblk0p_list_arrstring=$(ls -1 /dev | grep "mmcblk0p" | sed "s/mmcblk0p//g" | sort -n)
    local dev_mmcblk0p_list_arr=(${dev_mmcblk0p_list_arrstring})

    local dev_ismounted=false
    local dev_mmcblk0pi=""

    #Unmount all partitions with partition-numbers 8 and above
    #Remark:
    # partition-number 8 belongs to 'rootfs'
    for i in "${dev_mmcblk0p_list_arr[@]}"
    do
        if [[ ${i} -ge ${rootfs_partition_num} ]]; then
            dev_mmcblk0pi="${dev_mmcblk0p}${i}"

            #Check if partition is mounted
            dev_ismounted=$(mount | grep "${dev_mmcblk0pi}")
            if [[ -n "${dev_ismounted}" ]]; then  #is NOT mounted
                #Must unmount partition before doing the disk-check
                echo -e "${PRINT_TB_INIT_STATUS}: unmounting ${dev_mmcblk0pi}\n"
                umount "${dev_mmcblk0pi}"

                echo -e "${PRINT_TB_INIT_STATUS}: fsck -a ${dev_mmcblk0pi} (${fsck_retry} out-of ${FSCK_RETRY_MAX})\n"
                fsck -a "${dev_mmcblk0pi}"
            fi
        fi
    done

    #Enable trap ERR
    echo -e "${PRINT_TB_INIT_ENABLED}: trap ERR\n"
    trap trap_err__func ERR
}

function mount_or_unmount_partition__func() {
   #Input args
    local devpart=${1}
    local mntdir=${2}
    local mountsetto=${3}

    #Mount or unmount
    if [[ "${mountsetto}" == true ]]; then    #mount
        #Print
        echo -e "${PRINT_TB_INIT_STATUS}: mount ${devpart} to ${mntdir}\n"

        if [[ "${mntdir}" == "${rootfs_dir}" ]]; then   #/dev/mmcblk0p8
            mount -o remount,rw ${mntdir}
        else    #all other partitions
            mount ${devpart} ${mntdir}
        fi
    else    #unmount
        #Print
        echo -e "${PRINT_TB_INIT_STATUS}: unmount ${devpart}\n"

        umount ${devpart}
    fi
}

function mount_partition_and_write_data_to_file__func() {
    #disable trap ERR
    echo -e "${PRINT_TB_INIT_DISABLED}: trap ERR\n"
    trap - ERR

    #Input args
    local data=${1}
    local printmsg=${2}
    local targetfpath=${3}
    local devpart=${4}
    local mntdir=${5}

    #Unmount
    mount_or_unmount_partition__func "${devpart}" "${mntdir}" "false"

    #Mount
    mount_or_unmount_partition__func "${devpart}" "${mntdir}" "true"

    #Get directory
    local targetdir=$(dirname ${targetfpath})
    #Create directory if not present
    if [[ ! -d "${targetdir}" ]] && [[ "${targetdir}" != "${rootfs_dir}" ]]; then
        mkdir -p ${targetdir}
    fi

    #Print
    echo -e "${PRINT_TB_INIT_STATUS}: updating file ${targetfpath} with ${printmsg}: ${data}\n"
    #Write data
    echo "${data}" | tee ${targetfpath}

    #Enable trap ERR
    echo -e "${PRINT_TB_INIT_ENABLED}: trap ERR\n"
    trap trap_err__func ERR
}

function fsck_retry_retrieve__func() {
    #disable trap ERR
    echo -e "${PRINT_TB_INIT_DISABLED}: trap ERR\n"
    trap - ERR

    #Define variables
    local fsck_retry1=0
    local fsck_retry2=0

    #Temporarily mount /dev/mmcblk0p9
    if [[ ! -f "${fsck_retry_fpath1}" ]] && [[ ! -f "${fsck_retry_fpath2}" ]]; then  #path exists
        mount_partition_and_write_data_to_file__func "${fsck_retry}" \
                "${FSCK_RETRY_PRINT}" \
                "${fsck_retry_fpath1}" \
                "${dev_mmcblk0p8}" \
                "${rootfs_dir}"
        mount_partition_and_write_data_to_file__func "${fsck_retry}" \
                "${FSCK_RETRY_PRINT}" \
                "${fsck_retry_fpath2}" \
                "${dev_mmcblk0p9}" \
                "${tb_reserve_dir}"
    else  #path does not exist
        #Get 'fsck_retry1' value from file 'fsck_retry_fpath1'
        if [[ -f "${fsck_retry_fpath1}" ]]; then  #path exists
            fsck_retry1=$(cat ${fsck_retry_fpath1})
        fi
        #Get 'fsck_retry2' value from file 'fsck_retry_fpath2'
        if [[ -f "${fsck_retry_fpath2}" ]]; then  #path exists
            fsck_retry2=$(cat ${fsck_retry_fpath2})
        fi

        #Update 'fsck_retry'
        fsck_retry=${fsck_retry1}
        if [[ ${fsck_retry2} -gt ${fsck_retry1} ]]; then
            fsck_retry=${fsck_retry1}
        fi
    fi

    #Enable trap ERR
    echo -e "${PRINT_TB_INIT_ENABLED}: trap ERR\n"
    trap trap_err__func ERR
}

function remove_file() {
    #Input args
    local targetfpath=${1}

    #Remove file
    if [[ -f ${targetfpath} ]]; then
        echo -e "${PRINT_TB_INIT_REMOVING}: ${targetfpath}\n"

        rm ${targetfpath}
    fi
}

function safemode_print() {
    echo -e "**************************************************\n"
    echo -e "                    SAFE-MODE"
    echo -e "**************************************************\n"
    echo -e "To return back to the normal-mode, use command:"
    echo -e ""
    echo -e "   echo 1 >/proc/sys/kernel/sysrq && echo b >/proc/sysrq-trigger"
    echo -e ""
    echo -e "**************************************************\n"
}

#trap all errors into a function called trap_err__func
function trap_err__func() {
    echo -e "${PRINT_ERROR}:  An error was encountered while running the script\n"

    #Retrieve 'fsck_retry'
    fsck_retry_retrieve__func

    if [[ ${fsck_retry} -lt ${FSCK_RETRY_MAX} ]]; then
        #Increment fsck
        ((fsck_retry++))

        #Write data to file
        mount_partition_and_write_data_to_file__func "${fsck_retry}" \
                "${FSCK_RETRY_PRINT}" \
                "${fsck_retry_fpath1}" \
                "${dev_mmcblk0p8}" \
                "${rootfs_dir}"
        mount_partition_and_write_data_to_file__func "${fsck_retry}" \
                "${FSCK_RETRY_PRINT}" \
                "${fsck_retry_fpath2}" \
                "${dev_mmcblk0p9}" \
                "${tb_reserve_dir}"

        #Unmount partitions and run disk-check (with autorepair)
        chkdsk__func

        #Reboot
        eval ${cmd_reboot}
    else
        ${safemode_print}

        ${bin_bash_exec}

        ${EXIT_CODE_1}
    fi
}



#Print
echo -e "${PRINT_TB_INIT_START}\n"

#Enable trap ERR
trap trap_err__func ERR



#echo -e "enabling trace\n"
#set -o xtrace

#Mount proc to /proc
mount -t proc none ${proc_dir}



#---TB_RESERVE
if [[ ! -d "${tb_reserve_dir}" ]]; then
    echo -e "${PRINT_TB_INIT_STATUS}: remounting ${rootfs_dir}\n"
    mount -o remount,rw ${rootfs_dir} #remounting root in eMMC as writeable

    #this is also the first boot.
    #Create an 'ext4' partition '/dev/mmcblk0p9'
    echo -e "${PRINT_TB_INIT_STATUS}: creating ext4-partition ${dev_mmcblk0p9}\n"
    ${usr_sbin_mkfsext4} ${dev_mmcblk0p9}

    echo -e "${PRINT_TB_INIT_STATUS}: create directory ${tb_reserve_dir}\n"
    mkdir "${tb_reserve_dir}"

    #flag that root is already remounted
    flag_rootfs_is_remounted=true
fi



#---ADDITIONAL PARTITIONS


#---MOUNT /TB_RESERVE (to check if /tb_reserve/.tb_init_bootargs.tmp is present)
mount_or_unmount_partition__func "${dev_mmcblk0p9}" "${tb_reserve_dir}" "true"

#---DETERMINE BOOT OPTION SECTION
echo -e "${PRINT_TB_INIT_STATUS}: initialize bootargs\n"
tb_overlay="${NULL}"
tb_rootfs_ro="${NULL}"
tb_backup="${NULL}"
tb_restore="${NULL}"
tb_noboot="${NULL}"

echo -e "${PRINT_TB_INIT_STATUS}: retrieving kernel bootargs\n"
if [[ -f "${tb_init_bootargs_fpath}" ]]; then
    #Get /tb_reserve/.tb_init_bootargs.tmp' contents
    tb_init_bootargs_result=$(cat ${tb_init_bootargs_fpath})

    if [[ ${tb_init_bootargs_result} == *"tb_rootfs_ro"* ]]; then   #pattern 'tb_rootfs_ro' is found
        if [[ ${tb_init_bootargs_result} == *"tb_rootfs_ro=true"* ]]; then  #pattern 'tb_rootfs_ro=true' is found
            #Get '/proc/cmdline' content
            proc_cmdline_result=$(cat ${proc_cmdline_fpath})

            if [[ ${proc_cmdline_result} != *"tb_rootfs_ro"* ]]; then
                #Update variable
                pattern_tb_overlay_new="${PATTERN_TB_OVERLAY_OLD} ${PATTERN_TB_ROOTFS_RO_IS_TRUE}"

                #Insert 'tb_rootfs_ro=true' into result
                sed -i "s/${PATTERN_TB_OVERLAY_OLD}/${pattern_tb_overlay_new}/g" "${proc_cmdline_fpath}"

                #Get '/proc/cmdline' content
                bootargs_result=$(cat ${proc_cmdline_fpath})
            fi
        else    #pattern 'tb_rootfs_ro=true' is NOT found
            #Exclude 'tb_rootfs_ro=true' from result
            bootargs_result=$(sed "s/${PATTERN_TB_ROOTFS_RO_IS_TRUE}//g" "${proc_cmdline_fpath}")
        fi
    else    #pattern 'tb_rootfs_ro' is NOT found
        bootargs_result="${tb_init_bootargs_result}"
    fi

    remove_file "${tb_init_bootargs_fpath}"
else
    bootargs_result=$(cat ${proc_cmdline_fpath})
fi

#if bootargs_result contains the string "tb_overlay=/dev/mmcblk0p10"
if [[ ${bootargs_result} == *"tb_overlay"* ]]; then
    tb_overlay=$(echo ${bootargs_result} | grep -oP 'tb_overlay=\K[^ ]*')

    echo -e "${PRINT_TB_INIT_RESULT}: tb_overlay=${tb_overlay}\n"
fi

#if bootargs_result contains the string "tb_rootfs_ro=true"
if [[ ${bootargs_result} == *"tb_rootfs_ro"* ]]; then
    tb_rootfs_ro=$(echo ${bootargs_result} | grep -oP 'tb_rootfs_ro=\K[^ ]*')

    echo -e "${PRINT_TB_INIT_RESULT}: tb_rootfs_ro=${tb_rootfs_ro}\n"
fi

#if bootargs_result contains the string "tb_backup=<destination path>"
if [[ ${bootargs_result} == *"tb_backup"* ]]; then
    tb_backup=$(echo ${bootargs_result} | grep -oP 'tb_backup=\K[^ ]*')

    echo -e "${PRINT_TB_INIT_RESULT}: tb_backup=${tb_backup}\n"
fi

#if bootargs_result contains the string "tb_restore=<source path>""
if [[ ${bootargs_result} == *"tb_restore"* ]]; then
    tb_restore=$(echo ${bootargs_result} | grep -oP 'tb_restore=\K[^ ]*')

    echo -e "${PRINT_TB_INIT_RESULT}: tb_restore=${tb_restore}\n"
fi

#if bootargs_result contains the string "tb_noboot=true"
if [[ ${bootargs_result} == *"tb_noboot"* ]]; then
    tb_noboot=$(echo ${bootargs_result} | grep -oP 'tb_noboot=\K[^ ]*')

    echo -e "${PRINT_TB_INIT_RESULT}: tb_noboot=${tb_noboot}\n"
fi


#---UNMOUNT /TB_RESERVE
mount_or_unmount_partition__func "${dev_mmcblk0p9}" "${tb_reserve_dir}" "false"



#---BACKUP SECTION
#if tb_backup is set, then do a backup of the rootfs
if [[ "${tb_backup}" != "${NULL}" ]]; then
    #Print
    echo -e "${PRINT_TB_INIT_STATUS}: backing up eMMC\n"

    #Backup 'eMMC'
    dd if=${dev_mmcblk0} of=${tb_backup} oflag=direct status=progress
    sync

    #Check exit-code
    if [[ $? -ne 0 ]]; then
        #Print
        echo -e ""
        echo -e "${PRINT_ERROR}: backing up eMMC: FAILED\n"

        #Wait for 2 seeconds
        sleep 3
    else
        #Print
        echo -e ""
        echo -e "${PRINT_TB_INIT_STATUS}: backing up eMMC: DONE\n"
    fi
fi



#---RESTORE SECTION
#if tb_restore is set, then restore the rootfs from the backup
if [[ "${tb_restore}" != "${NULL}" ]]; then
    #Disable
    trap - ERR

    #Print
    echo -e "${PRINT_TB_INIT_STATUS}: restoring eMMC\n"

    #Restoring 'eMMC'
    dd if=${tb_restore} of=${dev_mmcblk0} oflag=direct status=progress
    sync

    #Check exit-code
    if [[ $? -ne 0 ]]; then
        #Print
        echo -e ""
        echo -e "${PRINT_ERROR}: restoring eMMC: FAILED\n"

        #Wait for 2 seeconds
        sleep 3
    else
        #Print
        echo -e ""
        echo -e "${PRINT_TB_INIT_STATUS}: restoring eMMC: DONE\n"
    fi

    #reboot to make sure the new rootfs is loaded
    reboot_exec
fi



#---SAFEMODE SECTION
#if tb_noboot is set, then boot to minimal system
if [[ "${tb_noboot}" != "${NULL}" ]]; then
    #Print
    while [ 1 ]; do
        ${safemode_print}
        
        ${bin_bash_exec}
    done
fi



#---OVERLAY SECTION
#if tb_overlay is set, then mount it
#Remarks:
# if overlay does NOT exist or 'size=0', then
# ...DO NOT add 'tb_overlay' in file 'penagram_common.h', line '"b_c=console=tty1 console=ttyS0,115200 earlyprintk\0" \
# However, if overlay exist and 'size>0', then
# ...ADD 'tb_overlay' in file 'penagram_common.h', line '"b_c=console=tty1 console=ttyS0,115200 earlyprintk tb_overlay\0" \
if [[ "${tb_overlay}"  != "${NULL}" ]]; then
    echo -e "${PRINT_TB_INIT_OVERLAY_SECTION}: START\n"

    #create /overlay if it doesn't exist
    if [[ ! -d "${overlay_dir}" ]]; then    
            if [[ "${flag_rootfs_is_remounted}" == false ]]; then
                echo -e "${PRINT_TB_INIT_STATUS}: remounting ${rootfs_dir}\n"
                mount -o remount,rw ${rootfs_dir} #remounting root in eMMC as writeable

                #Create dir
                if [[ ! -d "${rootfs_etc_tibbo_uboot_dir}" ]]; then
                    echo -e "${PRINT_TB_INIT_STATUS}: create dir ${rootfs_etc_tibbo_uboot_dir}\n"
                    mkdir -p ${rootfs_etc_tibbo_uboot_dir}
                fi
            fi

            echo -e "${PRINT_TB_INIT_STATUS}: creating ${overlay_dir}\n"
            mkdir ${overlay_dir}

            #Create an 'ext4' partition '/dev/mmcblk0p9'
            echo -e "${PRINT_TB_INIT_STATUS}: creating ext4-partition ${tb_overlay}\n"
            ${usr_sbin_mkfsext4} ${tb_overlay}
    fi

    echo -e "${PRINT_TB_INIT_STATUS}: mounting ${overlay_dir}"
    mount ${tb_overlay} ${overlay_dir}

    #if tb_rootfs_ro is equal to true then delete the contents of /overlay
    #Remarks:
    # non-persistent -> remove overlay partition. 
    # ...This means add 'tb_rootfs_ro' in file 'penagram_common.h', line "b_c=console=tty1 console=ttyS0,115200 earlyprintk tb_overlay tb_rootfs_ro\0"
    # persistent -> do not remove overlay partition. 
    # ...This means do NOT add 'tb_rootfs_ro' in file 'penagram_common.h', line "b_c=console=tty1 console=ttyS0,115200 earlyprintk tb_overlay\0"
    if [[ "${tb_rootfs_ro}" = "true" ]]; then #non-persistent
        echo -e "${PRINT_TB_INIT_STATUS}: tb_rootfs_ro is set, deleting contents of ${overlay_dir}\n"
        rm -rf "${overlay_dir}/*"
    else  #persistent
        echo -e "${PRINT_TB_INIT_STATUS}: tb_rootfs_ro is not set, not deleting contents of ${overlay_dir}\n"
    fi

    if [[ ! -d "${overlay_dir}/root" ]]; then
        echo -e "${PRINT_TB_INIT_STATUS}: creating ${overlay_dir}/root\n"

        mkdir "${overlay_dir}/root"
    fi

    #if  /overlay/root_upper does not exist then create it
    if [[ ! -d "${overlay_dir}/root_upper" ]]; then
        echo -e "${PRINT_TB_INIT_STATUS}: creating ${overlay_dir}/root_upper\n"

        mkdir "${overlay_dir}/root_upper"
    fi

    #if  /overlay/root_work does not exist then create it
    if [[ ! -d "${overlay_dir}/root_work" ]]; then
        echo -e "${PRINT_TB_INIT_STATUS}: creating ${overlay_dir}/root_work\n"

        mkdir "${overlay_dir}/root_work"
    fi

    echo -e "${PRINT_TB_INIT_STATUS}: re-mounting / in EMMC as READONLY\n"
    mount -o remount,ro / #remounting root in eMMC as readonly

    echo -e "${PRINT_TB_INIT_STATUS}: mount -t overlay overlay ${overlay_dir}/root -o lowerdir=/,upperdir=${overlay_dir}/root_upper,workdir=${overlay_dir}/root_work\n"
    mount -t overlay overlay ${overlay_dir}/root -o lowerdir=/,upperdir=${overlay_dir}/root_upper,workdir=${overlay_dir}/root_work

    echo -e "${PRINT_TB_INIT_STATUS}: navigating to ${overlay_dir}/root\n"
    cd ${overlay_dir}/root

    #if oldroot does not exits then create it
    if [[ ! -d "oldroot" ]]; then
        echo -e "${PRINT_TB_INIT_STATUS}: creating oldroot\n"

        mkdir "oldroot"
    fi

    #change root from '.' to 'oldroot'
    #Remark:
    # This means that the 'overlay' partition is placed under /oldroot
    echo -e "${PRINT_TB_INIT_STATUS}: change from '.' to 'oldroot'\n"
    pivot_root . "oldroot"


    echo -e "${PRINT_TB_INIT_OVERLAY_SECTION}: END\n"
fi



#Remove all temporary files
echo -e "${PRINT_TB_INIT_STATUS}: remove temporary files\n"
remove_file "${fsck_retry_fpath1}"
remove_file "${fsck_retry_fpath2}"



#Attempt to start systemd
echo -e "${PRINT_TB_INIT_STATUS}: attempting to start systemd\n"
exec "${lib_systemd_systemd_exec}"



#Print
echo -e "${PRINT_TB_INIT_COMPLETED}\n"



trap_err__func
