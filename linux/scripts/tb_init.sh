#!/bin/bash
#---CONSTANTS
EXIT_CODE_1="exit 1"
FSCK_RETRY_PRINT="fsck_retry"
FSCK_RETRY_MAX=3

PRINT_START_TB_INIT_SH="---:START: TB_INIT.SH"
PRINT_COMPLETED_TB_INIT_SH="---:COMPLETED: TB_INIT.SH"




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

fsck_retry=0
rootfs_partition_num=8

cmd_setto_safemode="echo 1 >${proc_sys_kernel_sysrq}"
cmd_reboot="echo b >${proc_sysrqtrigger_fpath}"



#---FUNCTIONS
function mount_partition_and_write_data_to_file__func() {
    #disable trap ERR
    echo -e "------:DISABLED: trap ERR\n"
    trap - ERR

    #Input args
    local data=${1}
    local printmsg=${2}
    local targetfpath=${3}
    local devpart=${4}
    local mntdir=${5}

    #Print
    echo -e "------:STATUS: first: unmounting ${devpart}\n"
    #Unmount
    umount ${devpart}

    #Print
    echo -e "------:TB_INIT:-:STATUS: then: temporarily mounting ${devpart}\n"
    #Mount
    if [[ "${mntdir}" == "${rootfs_dir}" ]]; then   #/dev/mmcblk0p8
        mount -o remount,rw ${mntdir}
    else    #all other partitions
        mount ${devpart} ${mntdir}
    fi

    #Get directory
    local targetdir=$(dirname ${targetfpath})
    #Create directory if not present
    if [[ ! -d "${targetdir}" ]] && [[ "${targetdir}" != "${rootfs_dir}" ]]; then
        mkdir -p ${targetdir}
    fi

    #Print
    echo -e "------:TB_INIT:-:STATUS: updating file ${targetfpath} with ${printmsg}: ${data}\n"
    #Write data
    echo "${data}" | tee ${targetfpath}

    #Enable trap ERR
    echo -e "------:ENABLED: trap ERR\n"
    trap trap_err__func ERR
}

function fsck_retry_retrieve__func() {
    #disable trap ERR
    echo -e "------:DISABLED: trap ERR\n"
    trap - ERR

    #Define variables
    local fsck_retry1=0
    local fsck_retry2=0

    #Temporarily mount /dev/mmcblk0p9
    if [[ ! -f ${fsck_retry_fpath1} ]] && [[ ! -f ${fsck_retry_fpath2} ]]; then  #path exists
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
    echo -e "------:ENABLED: trap ERR\n"
    trap trap_err__func ERR
}

function chkdsk__func() {
    #disable trap ERR
    echo -e "------:DISABLED: trap ERR\n"
    trap - ERR

    #Get a list containing the partitions belonging to mmclbk0p
    echo -e "------:TB_INIT:-:STATUS: Get a list of partition-numbers belonging to mmcblk0p\n"
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
                echo -e "------:TB_INIT:-:STATUS: unmounting ${dev_mmcblk0pi}\n"
                umount "${dev_mmcblk0pi}"

                echo -e "------:TB_INIT:-:STATUS: fsck -a ${dev_mmcblk0pi} (${fsck_retry} out-of ${FSCK_RETRY_MAX})\n"
                fsck -a "${dev_mmcblk0pi}"
            fi
        fi
    done

    #Enable trap ERR
    echo -e "------:ENABLED: trap ERR\n"
    trap trap_err__func ERR
}

#trap all errors into a function called trap_err__func
function trap_err__func() {
    echo -e "***ERROR***:  An error was encountered while running the script\n"

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
        ${bin_bash_exec}

        ${EXIT_CODE_1}
    fi
}




echo -e "${PRINT_START_TB_INIT_SH}\n"

#Enable trap ERR
trap trap_err__func ERR



#print out commands before executing them
echo -e "------:TB_INIT:-:STATUS: Entering tb_overlay.sh\n"

#echo -e "enabling trace\n"
#set -o xtrace

#Mount proc to /proc
mount -t proc none ${proc_dir}



#---TB_RESERVE
if [[ ! -d "${tb_reserve_dir}" ]]; then
    echo -e "------:TB_INIT:-:STATUS: remounting ${rootfs_dir}\n"
    mount -o remount,rw ${rootfs_dir} #remounting root in emmc as writeable

    #this is also the first boot.
    #Create an 'ext4' partition '/dev/mmcblk0p9'
    echo -e "------:TB_INIT:-:STATUS: creating ext4-partition ${dev_mmcblk0p9}\n"
    ${usr_sbin_mkfsext4} ${dev_mmcblk0p9}

    echo -e "------:TB_INIT:-:STATUS: create directory ${tb_reserve_dir}\n"
    mkdir "${tb_reserve_dir}"

    #flag that root is already remounted
    flag_rootfs_is_remounted=true
fi



#---ADDITIONAL PARTITIONS


#---OVERLAY SECTION
echo -e "------:TB_INIT:-:STATUS: retrieving kernel bootargs\n"
cmdline_output=$(cat ${proc_cmdline_fpath})

#if cmdline_output contains the string "tb_overlay"
if [[ ${cmdline_output} == *"tb_overlay"* ]]; then
    tb_overlay=$(echo ${cmdline_output} | grep -oP 'tb_overlay=\K[^ ]*')

    echo -e "-------:TB-INIT:-:RESULT: tb_overlay=${tb_overlay}\n"
else
    tb_overlay=""
fi

#if cmdline_output contains the string "tb_rootfs_ro"
if [[ ${cmdline_output} == *"tb_rootfs_ro"* ]]; then
    tb_rootfs_ro=$(echo ${cmdline_output} | grep -oP 'tb_rootfs_ro=\K[^ ]*')

    echo -e "-------:TB-INIT:-:RESULT: tb_rootfs_ro=${tb_rootfs_ro}\n"
else
    tb_rootfs_ro=""
fi

#if cmdline_output contains the string "tb_backup"
if [[ ${cmdline_output} == *"tb_backup"* ]]; then
    tb_backup=$(echo ${cmdline_output} | grep -oP 'tb_backup=\K[^ ]*')

    echo -e "-------:TB-INIT:-:RESULT: tb_backup=${tb_backup}\n"
else
    tb_backup=""
fi

#if cmdline_output contains the string "tb_restore"
if [[ ${cmdline_output} == *"tb_restore"* ]]; then
    tb_restore=$(echo ${cmdline_output} | grep -oP 'tb_restore=\K[^ ]*')

    echo -e "-------:TB-INIT:-:RESULT: tb_restore=${tb_restore}\n"
else
    tb_restore=""
fi

#if cmdline_output contains the string "tb_noboot"
if [[ ${cmdline_output} == *"tb_noboot"* ]]; then
    tb_restore=$(echo ${cmdline_output} | grep -oP 'tb_noboot=\K[^ ]*')

    echo -e "-------:TB-INIT:-:RESULT: tb_noboot=${tb_restore}\n"
else
    tb_noboot=""
fi

#if tb_backup is set, then do a backup of the rootfs
if [ ! -z ${tb_backup} ]; then
    echo -e "------:TB_INIT:-:STATUS: Backing up of emmc\n"
    dd if=${dev_mmcblk0} of=${tb_backup} oflag=direct status=progress
    sync
fi

#if tb_restore is set, then restore the rootfs from the backup
if [ ! -z ${tb_restore} ]; then
    trap - ERR #disable error trap

    echo -e "------:TB_INIT:-:STATUS: Restoring emmc\n"
    dd if=${tb_restore} of=${dev_mmcblk0} oflag=direct status=progress
    sync

    #reboot to make sure the new rootfs is loaded
    eval ${cmd_setto_safemode}
    eval ${cmd_reboot}
fi

#if tb_noboot is set, then boot to minimal system
if [ ! -z ${tb_noboot} ]; then
    while [ 1 ]; do
        echo -e "------:TB_INIT:-:STATUS: To reboot in this environment enter the following command: "
        echo -e "------:TB_INIT:-:STATUS: ${cmd_setto_safemode} && ${cmd_reboot}\n"
        
        ${bin_bash_exec}
    done
fi

#if tb_overlay is set, then mount it
#Remarks:
# if overlay does NOT exist or 'size=0', then
# ...DO NOT add 'tb_overlay' in file 'penagram_common.h', line '"b_c=console=tty1 console=ttyS0,115200 earlyprintk\0" \
# However, if overlay exist and 'size>0', then
# ...ADD 'tb_overlay' in file 'penagram_common.h', line '"b_c=console=tty1 console=ttyS0,115200 earlyprintk tb_overlay\0" \
if [ -n "${tb_overlay}" ]; then
    echo -e "-------:TB-INIT:-:START: OVERLAY-SECTION\n"

    #create /overlay if it doesn't exist
    if [ ! -d ${overlay_dir} ]; then    
            if [[ ${flag_rootfs_is_remounted} == false ]]; then
                echo -e "------:TB_INIT:-:STATUS: remounting ${rootfs_dir}\n"
                mount -o remount,rw ${rootfs_dir} #remounting root in emmc as writeable

                #Create dir
                if [[ ! -d ${rootfs_etc_tibbo_uboot_dir} ]]; then
                    echo -e "------:TB_INIT:-:STATUS: create dir ${rootfs_etc_tibbo_uboot_dir}\n"
                    mkdir -p ${rootfs_etc_tibbo_uboot_dir}
                fi
            fi

            echo -e "------:TB_INIT:-:STATUS: creating ${overlay_dir}\n"
            mkdir ${overlay_dir}

            #Create an 'ext4' partition '/dev/mmcblk0p9'
            echo -e "------:TB_INIT:-:STATUS: creating ext4-partition ${tb_overlay}\n"
            ${usr_sbin_mkfsext4} ${tb_overlay}
    fi

    echo -e "------:TB_INIT:-:STATUS: mounting ${overlay_dir}"
    mount ${tb_overlay} ${overlay_dir}

    #if tb_rootfs_ro is equal to true then delete the contents of /overlay
    #Remarks:
    # non-persistent -> remove overlay partition. 
    # ...This means add 'tb_rootfs_ro' in file 'penagram_common.h', line "b_c=console=tty1 console=ttyS0,115200 earlyprintk tb_overlay tb_rootfs_ro\0"
    # persistent -> do not remove overlay partition. 
    # ...This means do NOT add 'tb_rootfs_ro' in file 'penagram_common.h', line "b_c=console=tty1 console=ttyS0,115200 earlyprintk tb_overlay\0"
    if [ "${tb_rootfs_ro}" = "true" ]; then #non-persistent
        echo -e "-------:TB-INIT:-:STATUS: tb_rootfs_ro is set, deleting contents of ${overlay_dir}\n"
        rm -rf ${overlay_dir}/*
    else  #persistent
        echo -e "-------:TB-INIT:-:STATUS: tb_rootfs_ro is not set, not deleting contents of ${overlay_dir}\n"
    fi

    if [ ! -d ${overlay_dir}/root ]; then
        echo -e "-------:TB-INIT:-:STATUS: Creating ${overlay_dir}/root\n"

        mkdir ${overlay_dir}/root
    fi

    #if  /overlay/root_upper does not exist then create it
    if [ ! -d ${overlay_dir}/root_upper ]; then
        echo -e "-------:TB-INIT:-:STATUS: Creating ${overlay_dir}/root_upper\n"

        mkdir ${overlay_dir}/root_upper
    fi

    #if  /overlay/root_work does not exist then create it
    if [ ! -d ${overlay_dir}/root_work ]; then
        echo -e "-------:TB-INIT:-:STATUS: Creating ${overlay_dir}/root_work\n"

        mkdir ${overlay_dir}/root_work
    fi

    echo -e "-------:TB-INIT:-:STATUS: re-mounting / in EMMC as READONLY\n"
    mount -o remount,ro / #remounting root in emmc as readonly

    echo -e "-------:TB-INIT:-:STATUS: mount -t overlay overlay ${overlay_dir}/root -o lowerdir=/,upperdir=${overlay_dir}/root_upper,workdir=${overlay_dir}/root_work\n"
    mount -t overlay overlay ${overlay_dir}/root -o lowerdir=/,upperdir=${overlay_dir}/root_upper,workdir=${overlay_dir}/root_work

    echo -e "-------:TB-INIT:-:STATUS: navigating to ${overlay_dir}/root\n"
    cd ${overlay_dir}/root

    #if oldroot does not exits then create it
    if [ ! -d oldroot ]; then
        echo -e "-------:TB-INIT:-:STATUS: Creating oldroot\n"

        mkdir oldroot
    fi

    #change root from '.' to 'oldroot'
    #Remark:
    # This means that the 'overlay' partition is placed under /oldroot
    echo -e "-------:TB-INIT:-:STATUS: change from '.' to 'oldroot'\n"
    pivot_root . oldroot


    echo -e "-------:TB-INIT:-:END: OVERLAY-SECTION\n"
fi



#Attempt to start systemd 
exec ${lib_systemd_systemd_exec}



#Print
echo -e "${PRINT_COMPLETED_TB_INIT_SH}\n"


trap_err__func
