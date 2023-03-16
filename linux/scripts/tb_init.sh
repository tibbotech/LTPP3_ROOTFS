#!/bin/bash
#---CONSTANTS
EXIT_CODE_1="exit 1"



#---VARIABLES
bin_bash_exec=/bin/bash
lib_systemd_systemd_exec=/lib/systemd/systemd

dev_mmcblk0=/dev/mmcblk0
dev_mmcblk0p9=/dev/mmcblk0p9

overlay_dir=/overlay
proc_dir=/proc
proc_cmdline_fpath=${proc_dir}/cmdline
proc_sys_kernel_sysrq=${proc_dir}/sys/kernel/sysrq
proc_sysrqtrigger_fpath=${proc_dir}/sysrq-trigger
tb_reserve_dir=/tb_reserve
usr_sbin_mkfsext4=/usr/sbin/mkfs.ext4



#---FUNCTIONS
#trap all errors into a function called error_trap
function error_trap() {
  echo "***ERROR:  An error was encountered while running the script."

  ${bin_bash_exec}

  ${EXIT_CODE_1}
}



#Enable trap ERR
trap error_trap ERR



#print out commands before executing them
echo "---:STATUS: Entering tb_overlay.sh"

#echo "enabling trace"
#set -o xtrace

#Mount proc to /proc
mount -t proc none ${proc_dir}



#---TB_RESERVE
if [[ ! -d "${tb_reserve_dir}" ]]; then
    echo "---:STATUS: remounting /"
    mount -o remount,rw / #remounting root in emmc as writeable

    #this is also the first boot.
    #Create an 'ext4' partition '/dev/mmcblk0p10'
    echo "---:STATUS: creating ext4-partition ${dev_mmcblk0p9}"
    ${usr_sbin_mkfsext4} ${dev_mmcblk0p9}

    echo "---:STATUS: create directory ${tb_reserve_dir}"
    mkdir "${tb_reserve_dir}"

    #flag that root is already remounted
    flag_root_is_remounted=true
fi



#---ADDITIONAL PARTITIONS


#---MOUNT TB_RESERVE
echo "---:STATUS: mounting ${tb_reserve_dir}"
mount ${dev_mmcblk0p9} ${tb_reserve_dir}



#---MOUNT ADDITIONAL PARTITIONS


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
    if [[ ${flag_root_is_remounted} == false ]]; then
        echo "---:STATUS: remounting /"
        mount -o remount,rw / #remounting root in emmc as writeable
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


#REMARK: DOES NOT WORK TO PLACE TB_RESERVCE HERE!


#Attempt to start systemd 
exec ${lib_systemd_systemd_exec}


#REMARK: DOES NOT WORK TO PLACE TB_RESERVCE HERE!



error_trap
