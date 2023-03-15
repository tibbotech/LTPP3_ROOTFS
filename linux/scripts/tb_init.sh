#!/bin/bash
#---CONSTANTS
RESET_COLOR="\e[0;0m"
FG_LIGHTGREY="\e[30;38;5;246m"

STATUS_COLOR="${STATUS_COLOR}"
ERROR_COLOR="${ERROR_COLOR}"



#---VARIABLES
bin_bash_fpath="/bin/bash"
dev_mmcblk0_dir="/dev/mmcblk0"
proc_dir="/proc"
cmdline_fpath="${proc_dir}/cmdline"
mkfs_ext4_fpath="/usr/sbin/mkfs.ext4"
overlay_foldername="overlay"
overlay_dir="/${overlay_foldername}"
oldroot_foldername="oldroot"
root_upper_foldername="root_upper"
root_work_foldername="root_work"
tb_reserve_foldername="tb_reserve"
tb_reserve_dir="/${tb_reserve_foldername}"
tb_reserve_devmmcblk0p10="/dev/mmcblk0p10"



#---FUNCTIONS
#---Trap all errors into a function called error_trap
function error_trap() {
  #Print error
  echo "${ERROR_COLOR}: an error was encountered while running the script."
  
  #Go into bash
  ${bin_bash_fpath}

  #Exit with 'exit-code=1'
  exit 1
}

#---Enable ERR trap
trap error_trap ERR

#print out commands before executing them
echo -e "${STATUS_COLOR}: Entering ${FG_LIGHTGREY}tb_init.sh${RESET_COLOR}"

#echo "enabling trace"
#set -o xtrace

#Mount
mount -t proc none "${proc_dir}"

#Print
echo -e "${STATUS_COLOR}: Processing ${FG_LIGHTGREY}kernel bootargs${RESET_COLOR}"
cmdline=$(cat "${cmdline_fpath}")

#if cmdline contains the string "tb_overlay"
if [[ $cmdline == *"tb_overlay"* ]]; then
  tb_overlay=$(echo $cmdline | grep -oP 'tb_overlay=\K[^ ]*')

  echo -e "${STATUS_COLOR}: tb_overlay=${FG_LIGHTGREY}${tb_overlay}${RESET_COLOR}"
else
  tb_overlay=""
fi

#if cmdline contains the string "tb_rootfs_ro"
if [[ $cmdline == *"tb_rootfs_ro"* ]]; then
  tb_rootfs_ro=$(echo $cmdline | grep -oP 'tb_rootfs_ro=\K[^ ]*')

  echo -e "${STATUS_COLOR}: tb_rootfs_ro=${FG_LIGHTGREY}${tb_rootfs_ro}${RESET_COLOR}"
else
  tb_rootfs_ro=""
fi

#if cmdline contains the string "tb_backup"
if [[ $cmdline == *"tb_backup"* ]]; then
  tb_backup=$(echo $cmdline | grep -oP 'tb_backup=\K[^ ]*')

  echo -e "${STATUS_COLOR}: tb_backup=${FG_LIGHTGREY}${tb_backup}${RESET_COLOR}"
else
  tb_backup=""
fi

#if cmdline contains the string "tb_restore"
if [[ $cmdline == *"tb_restore"* ]]; then
  tb_restore=$(echo $cmdline | grep -oP 'tb_restore=\K[^ ]*')

  echo -e "${STATUS_COLOR}: tb_restore=${FG_LIGHTGREY}${tb_restore}${RESET_COLOR}"
else
  tb_restore=""
fi

#if cmdline contains the string "tb_noboot"
if [[ $cmdline == *"tb_noboot"* ]]; then
  tb_restore=$(echo $cmdline | grep -oP 'tb_noboot=\K[^ ]*')

  echo -e "${STATUS_COLOR}: tb_noboot=${FG_LIGHTGREY}${tb_noboot}${RESET_COLOR}"
else
  tb_noboot=""
fi

#if tb_backup is set, then do a backup of the rootfs
if [ ! -z $tb_backup ]; then
  echo -e "${STATUS_COLOR}: Backing up ${FG_LIGHTGREY}emmc${RESET_COLOR}"

  dd if="${dev_mmcblk0_dir}" of=$tb_backup oflag=direct status=progress
  sync
fi

sysrq_fpath="/proc/sys/kernel/sysrq"
sysrq_trigger_fpath="/proc/sysrq-trigger"

#if tb_restore is set, then restore the rootfs from the backup
if [ ! -z $tb_restore ]; then
  #Disable ERR trap
  trap - ERR

  echo -e "${STATUS_COLOR}: Restoring ${FG_LIGHTGREY}emmc${RESET_COLOR}"

  dd if=$tb_restore of="${dev_mmcblk0_dir}" oflag=direct status=progress
  sync

  #reboot to make sure the new rootfs is loaded
  echo 1 >"${sysrq_fpath}"
  echo b >"${sysrq_trigger_fpath}"
fi

#if tb_noboot is set, then boot to minimal system
if [ ! -z $tb_noboot ]; then
  # wile 1
  while [ 1 ]; do
    echo -e "${STATUS_COLOR}: To reboot in this environment enter the following command: "
    echo "echo 1 >${sysrq_fpath} && echo b >${sysrq_trigger_fpath}"

    #Go into bash
    "${bin_bash_fpath}"
  done
fi

#if tb_overlay is set, then mount it
#Remarks:
# if overlay does NOT exist or 'size=0', then
# ...DO NOT add 'tb_overlay' in file 'penagram_common.h', line '"b_c=console=tty1 console=ttyS0,115200 earlyprintk\0" \
# However, if overlay exist and 'size>0', then
# ...ADD 'tb_overlay' in file 'penagram_common.h', line '"b_c=console=tty1 console=ttyS0,115200 earlyprintk tb_overlay\0" \
if [ -n "${tb_overlay}" ]; then
  echo -e "${STATUS_COLOR}: tb_overlay is set..."
  echo -e "${STATUS_COLOR}: mounting ${tb_overlay}"

  #create /overlay if it doesn't exist
  if [ ! -d "${overlay_dir}" ]; then
    mount -o remount,rw / #remounting root in emmc as writeable

    mkdir "${overlay_dir}" 
    
    #this is also the first boot.
    #Create an 'ext4' partition '/dev/mmcblk0p9'
    ${mkfs_ext4_fpath} "${tb_overlay}"
  fi

  #check if tb_overlay is an ext4 partition
  mount "${tb_overlay}" "${overlay_dir}"

  #if tb_rootfs_ro is equal to true then delete the contents of /overlay
  #Remarks:
  # non-persistent -> remove overlay partition. 
  # ...This means add 'tb_rootfs_ro' in file 'penagram_common.h', line "b_c=console=tty1 console=ttyS0,115200 earlyprintk tb_overlay tb_rootfs_ro\0"
  # persistent -> do not remove overlay partition. 
  # ...This means do NOT add 'tb_rootfs_ro' in file 'penagram_common.h', line "b_c=console=tty1 console=ttyS0,115200 earlyprintk tb_overlay\0"
  if [ "$tb_rootfs_ro" = "true" ]; then #non-persistent
      echo -e "${STATUS_COLOR}: tb_rootfs_ro is set..."
      echo -e "${STATUS_COLOR}: deleting contents of ${overlay_dir}"

      rm -rf "${overlay_dir}/*"
  else  #persistent
      echo -e "${STATUS_COLOR}: tb_rootfs_ro is not set..."
      echo -e "${STATUS_COLOR}: NOT deleting contents of ${overlay_dir}"
  fi

  if [ ! -d "${overlay_dir}/root" ]; then
    echo -e "${STATUS_COLOR}: creating ${overlay_dir}/root"
  
    mkdir "${overlay_dir}/root"
  fi

  #if  /overlay/root_upper does not exist then create it
  if [ ! -d "${overlay_dir}/${root_upper_foldername}" ]; then
    echo -e "${STATUS_COLOR}:  creating ${overlay_dir}/${root_upper_foldername}"
  
    mkdir "${overlay_dir}/${root_upper_foldername}"
  fi

  #if  /overlay/root_work does not exist then create it
  if [ ! -d "${overlay_dir}/${root_work_foldername}" ]; then
    echo -e "${STATUS_COLOR}:  creating ${overlay_dir}/${root_work_foldername}"
  
    mkdir "${overlay_dir}/${root_work_foldername}"
  fi

  mount -o remount,ro / #remounting root in emmc as readonly

  mount -t overlay overlay "${overlay_dir}/root" -o lowerdir=/,upperdir="${overlay_dir}/${root_upper_foldername}",workdir="${overlay_dir}/${root_work_foldername}"

  cd "${overlay_dir}/root"

  #if oldroot does not exits then create it
  if [ ! -d "${${oldroot_foldername}}" ]; then
    echo -e "${STATUS_COLOR}: creating ${${oldroot_foldername}}"

    mkdir "${${oldroot_foldername}}"
  fi

  pivot_root . "${${oldroot_foldername}}"
fi



#---tb_reserve partition
echo "---:STATUS: mounting ${tb_reserve_foldername}"
#create /overlay if it doesn't exist
if [[ ! -d "${tb_reserve_dir}" ]]; then
  mount -o remount,rw / #remounting root in emmc as writeable
  mkdir "${tb_reserve_dir}"    
    
  #this is also the first boot.
  #Create an 'ext4' partition '/dev/mmcblk0p9'
  "${mkfs_ext4_fpath}" "${tb_reserve_devmmcblk0p10}"
fi

#check if tb_overlay is an ext4 partition
mount "${tb_reserve_devmmcblk0p10}" "${tb_reserve_dir}"
#---tb_reserve partition



#---user-defined partitions




#---Attempt to start systemd 
exec /lib/systemd/systemd

error_trap
