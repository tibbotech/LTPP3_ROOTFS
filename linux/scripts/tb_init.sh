#!/bin/bash
#---CONSTANTS
EXIT_CODE_1="exit 1"
FSCK_RETRY_MAX=3



#---VARIABLES
bin_bash_exec=/bin/bash
lib_systemd_systemd_exec=/lib/systemd/systemd

dev_mmcblk0=/dev/mmcblk0
dev_mmcblk0p=/dev/mmcblk0p
dev_mmcblk0p9=/dev/mmcblk0p9

overlay_dir=/overlay
proc_dir=/proc
proc_cmdline_fpath=${proc_dir}/cmdline
proc_sys_kernel_sysrq=${proc_dir}/sys/kernel/sysrq
proc_sysrqtrigger_fpath=${proc_dir}/sysrq-trigger
rootfs_dir=/
tb_reserve_dir=/tb_reserve
usr_sbin_mkfsext4=/usr/sbin/mkfs.ext4

dev_mmcblk0p_list_arr=()
dev_mmcblk0p_list_arrstring=""

fsck_retry=0
fsck_retry_fpath1=${rootfs_dir}/fsck_retry.tmp
fsck_retry_fpath2=${tb_reserve_dir}/fsck_retry.bck

dev_ismounted=false
rootfs_partition_num=8



#---FUNCTIONS
function fsck_retry_retrieve__func() {
  #Temporarily mount /dev/mmcblk0p9
  if [[ -f ${fsck_retry_fpath1} ]]; then  #path exists
    fsck_retry=$(cat ${fsck_retry_fpath1})
  else  #path does not exist
    echo "---:STATUS: temporarily mount ${dev_mmcblk0p9}"
    mount ${dev_mmcblk0p9} ${tb_reserve_dir}

    if [[ -f ${fsck_retry_fpath2} ]]; then  #path exists
      fsck_retry=$(cat ${fsck_retry_fpath2})
    else  #path does not exist
      echo "---:STATUS: updating file ${fsck_retry_fpath1} with fsck_retry: ${fsck_retry}"
      echo "0" | tee ${fsck_retry_fpath1}
      echo "---:STATUS: updating file ${fsck_retry_fpath2} with fsck_retry: ${fsck_retry}"
      echo "0" | tee ${fsck_retry_fpath2}
    fi

    echo "---:STATUS: unmount ${dev_mmcblk0p9}"
    umount ${dev_mmcblk0p9}  
  fi
}

#trap all errors into a function called trap_err__func
function trap_err__func() {
  echo "***ERROR:  An error was encountered while running the script."

  #Retrieve 'fsck_retry'
  fsck_retry_retrieve__func

  if [[ ${fsck_retry} -le ${FSCK_RETRY_MAX} ]]; then
    #Increment fsck
    ((fsck_retry++))

    #Write to files
    echo "${fsck_retry}" | tee ${fsck_retry_fpath1}
    echo "${fsck_retry}" | tee ${fsck_retry_fpath2}

    #Get a list containing the partitions belonging to mmclbk0p
    echo "---:STATUS: Get a list of partition-numbers belonging to mmcblk0p"
    dev_mmcblk0p_list_arrstring=$(ls -1 /dev | grep "mmcblk0p" | sed "s/mmcblk0p//g" | sort -n)
    dev_mmcblk0p_list_arr=(${dev_mmcblk0p_list_arrstring})

    #Unmount all partitions with partition-numbers 8 and above
    #Remark:
    # partition-number 8 belongs to 'rootfs'
    for i in "${dev_mmcblk0p_list_arr[@]}"
    do
      if [[ ${i} -ge ${rootfs_partition_num} ]]; then
        echo "---:STATUS: unmounting ${dev_mmcblk0p}${i}"

        umount "${dev_mmcblk0p}${i}"
      fi
    done

    #Check all partitions with partition-numbers 8 and above
    for i in "${dev_mmcblk0p_list_arr[@]}"
    do
      dev_ismounted=false

      if [[ ${i} -ge ${rootfs_partition_num} ]]; then
        #Check if partition is mounted
        dev_ismounted=$(mount | grep "${dev_mmcblk0p}${i}")
        if [[ -n "${dev_ismounted}" ]]; then  #is mounted
          echo "---:STATUS: fsck -a ${dev_mmcblk0p}${i} (${fsck_retry} out-of ${FSCK_RETRY_MAX})"

          fsck -a "${dev_mmcblk0p}${i}"
        fi
      fi
    done

    #Reboot
    reboot now
  else
    ${bin_bash_exec}

    ${EXIT_CODE_1}
  fi
}



#Enable trap ERR
trap trap_err__func ERR



#print out commands before executing them
echo "---:STATUS: Entering tb_overlay.sh"

#echo "enabling trace"
#set -o xtrace

#Mount proc to /proc
mount -t proc none ${proc_dir}



#---TB_RESERVE
if [[ ! -d "${tb_reserve_dir}" ]]; then
  echo "---:STATUS: remounting ${rootfs_dir}"
  mount -o remount,rw ${rootfs_dir} #remounting root in emmc as writeable

  #this is also the first boot.
  #Create an 'ext4' partition '/dev/mmcblk0p9'
  echo "---:STATUS: creating ext4-partition ${dev_mmcblk0p9}"
  ${usr_sbin_mkfsext4} ${dev_mmcblk0p9}

  echo "---:STATUS: create directory ${tb_reserve_dir}"
  mkdir "${tb_reserve_dir}"

  #flag that root is already remounted
  flag_rootfs_is_remounted=true
fi

#>>>>>>>>>>>> THIS PART SHOULD BE REMOVED LATER<<<<<<<<<<<<<<<<<
fsck_retry_retrieve__func

echo ">>>fsck_retry: ${fsck_retry}" && sleep 5

trap_err__func
#>>>>>>>>>>>> THIS PART SHOULD BE REMOVED LATER<<<<<<<<<<<<<<<<<


#---ADDITIONAL PARTITIONS


#---OVERLAY SECTION
echo "---:STATUS: retrieving kernel bootargs"
cmdline_output=$(cat ${proc_cmdline_fpath})

#if cmdline_output contains the string "tb_overlay"
if [[ ${cmdline_output} == *"tb_overlay"* ]]; then
  tb_overlay=$(echo ${cmdline_output} | grep -oP 'tb_overlay=\K[^ ]*')

  echo "---RESULT: tb_overlay=${tb_overlay}"
else
  tb_overlay=""
fi

#if cmdline_output contains the string "tb_rootfs_ro"
if [[ ${cmdline_output} == *"tb_rootfs_ro"* ]]; then
  tb_rootfs_ro=$(echo ${cmdline_output} | grep -oP 'tb_rootfs_ro=\K[^ ]*')

  echo "---RESULT: tb_rootfs_ro=${tb_rootfs_ro}"
else
  tb_rootfs_ro=""
fi

#if cmdline_output contains the string "tb_backup"
if [[ ${cmdline_output} == *"tb_backup"* ]]; then
  tb_backup=$(echo ${cmdline_output} | grep -oP 'tb_backup=\K[^ ]*')

  echo "---RESULT: tb_backup=${tb_backup}"
else
  tb_backup=""
fi

#if cmdline_output contains the string "tb_restore"
if [[ ${cmdline_output} == *"tb_restore"* ]]; then
  tb_restore=$(echo ${cmdline_output} | grep -oP 'tb_restore=\K[^ ]*')

  echo "---RESULT: tb_restore=${tb_restore}"
else
  tb_restore=""
fi

#if cmdline_output contains the string "tb_noboot"
if [[ ${cmdline_output} == *"tb_noboot"* ]]; then
  tb_restore=$(echo ${cmdline_output} | grep -oP 'tb_noboot=\K[^ ]*')

  echo "---RESULT: tb_noboot=${tb_restore}"
else
  tb_noboot=""
fi

#if tb_backup is set, then do a backup of the rootfs
if [ ! -z ${tb_backup} ]; then
  echo "---:STATUS: Backing up of emmc"

  dd if=${dev_mmcblk0} of=${tb_backup} oflag=direct status=progress
  sync
fi

#if tb_restore is set, then restore the rootfs from the backup
if [ ! -z ${tb_restore} ]; then
  trap - ERR #disable error trap

  echo "---:STATUS: Restoring emmc"

  dd if=${tb_restore} of=${dev_mmcblk0} oflag=direct status=progress
  sync
  #reboot to make sure the new rootfs is loaded
  echo 1 >${proc_sys_kernel_sysrq}
  echo b >${proc_sysrqtrigger_fpath}
fi

#if tb_noboot is set, then boot to minimal system
if [ ! -z ${tb_noboot} ]; then
  # wile 1
  while [ 1 ]; do
    echo "---:STATUS: To reboot in this environment enter the following command: "
    echo "---:STATUS: echo 1 >${proc_sys_kernel_sysrq} && echo b >${proc_sysrqtrigger_fpath}"
    
    ${bin_bash_exec}
  done
fi

#if tb_overlay is set, then mount it
#Remarks:
# if overlay does NOT exist or 'size=0', then
# ...DO NOT add 'tb_overlay' in file 'penagram_common.h', line '"b_c=console=tty1 console=ttyS0,115200 earlyprintk\0" \
# However, if overlay exist and 'size>0', then
# ...ADD 'tb_overlay' in file 'penagram_common.h', line '"b_c=console=tty1 console=ttyS0,115200 earlyprintk tb_overlay\0" \
echo "---START: overlay"
if [ -n "${tb_overlay}" ]; then
  echo "-------:STATUS: tb_overlay is set, mounting ${tb_overlay}"

  #create /overlay if it doesn't exist
  if [ ! -d ${overlay_dir} ]; then    
    if [[ ${flag_rootfs_is_remounted} == false ]]; then
        echo "---:STATUS: remounting /"
        mount -o remount,rw ${rootfs_dir} #remounting root in emmc as writeable
    fi

    echo "---:STATUS: creating ${overlay_dir}"
    mkdir ${overlay_dir}

    #Create an 'ext4' partition '/dev/mmcblk0p9'
    echo "---:STATUS: creating ext4-partition ${tb_overlay}"
    ${usr_sbin_mkfsext4} ${tb_overlay}
  fi

  echo "---:STATUS: mounting ${overlay_dir}"
  mount ${tb_overlay} ${overlay_dir}

  #if tb_rootfs_ro is equal to true then delete the contents of /overlay
  #Remarks:
  # non-persistent -> remove overlay partition. 
  # ...This means add 'tb_rootfs_ro' in file 'penagram_common.h', line "b_c=console=tty1 console=ttyS0,115200 earlyprintk tb_overlay tb_rootfs_ro\0"
  # persistent -> do not remove overlay partition. 
  # ...This means do NOT add 'tb_rootfs_ro' in file 'penagram_common.h', line "b_c=console=tty1 console=ttyS0,115200 earlyprintk tb_overlay\0"
  if [ "${tb_rootfs_ro}" = "true" ]; then #non-persistent
      echo "-------:STATUS: tb_rootfs_ro is set, deleting contents of ${overlay_dir}"
      rm -rf ${overlay_dir}/*
  else  #persistent
      echo "-------:STATUS: tb_rootfs_ro is not set, not deleting contents of ${overlay_dir}"
  fi

  if [ ! -d ${overlay_dir}/root ]; then
    echo "-------:STATUS: Creating ${overlay_dir}/root"

    mkdir ${overlay_dir}/root
  fi

  #if  /overlay/root_upper does not exist then create it
  if [ ! -d ${overlay_dir}/root_upper ]; then
    echo "-------:STATUS: Creating ${overlay_dir}/root_upper"

    mkdir ${overlay_dir}/root_upper
  fi

  #if  /overlay/root_work does not exist then create it
  if [ ! -d ${overlay_dir}/root_work ]; then
    echo "-------:STATUS: Creating ${overlay_dir}/root_work"

    mkdir ${overlay_dir}/root_work
  fi

  echo "-------:STATUS: re-mounting / in EMMC as READONLY"
  mount -o remount,ro / #remounting root in emmc as readonly

  echo "-------:STATUS: mount -t overlay overlay ${overlay_dir}/root -o lowerdir=/,upperdir=${overlay_dir}/root_upper,workdir=${overlay_dir}/root_work"
  mount -t overlay overlay ${overlay_dir}/root -o lowerdir=/,upperdir=${overlay_dir}/root_upper,workdir=${overlay_dir}/root_work

  echo "-------:STATUS: navigating to ${overlay_dir}/root"
  cd ${overlay_dir}/root

  #if oldroot does not exits then create it
  if [ ! -d oldroot ]; then
    echo "-------:STATUS: Creating oldroot"

    mkdir oldroot
  fi

  #change root from '.' to 'oldroot'
  #Remark:
  # This means that the 'overlay' partition is placed under /oldroot
  echo "-------:STATUS: change from '.' to 'oldroot'"
  pivot_root . oldroot

  echo "----:COMPLETED: overlay"
fi



#Attempt to start systemd 
exec ${lib_systemd_systemd_exec}



trap_err__func
