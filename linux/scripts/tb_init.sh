#!/bin/bash

#trap all errors into a function called error_trap
function error_trap() {
  echo "ERROR:  An error was encountered while running the script."
  /bin/bash
  exit 1
}

trap error_trap ERR

#print out commands before executing them
echo "Entering tb_overlay.sh"

#echo "enabling trace"
#set -o xtrace

mount -t proc none /proc

tb_reserve_partname="tb_reserve"
tb_reserve_devmmcblk0p10=/dev/mmcblk0p10
echo "Mounting ${tb_reserve_partname}"
#create /overlay if it doesn't exist
if [[ ! -d "/${tb_reserve_partname}" ]]; then
  mount -o remount,rw / #remounting root in emmc as writeable
  mkdir "/${tb_reserve_partname}"        
  #this is also the first boot.
  #Create an 'ext4' partition '/dev/mmcblk0p9'
  /usr/sbin/mkfs.ext4 ${tb_reserve_devmmcblk0p10}
fi

#check if tb_overlay is an ext4 partition
mount $tb_overlay /overlay



echo "Processing kernel bootargs"
cmdline=$(cat /proc/cmdline)

#if cmdline contains the string "tb_overlay"
if [[ $cmdline == *"tb_overlay"* ]]; then
  tb_overlay=$(echo $cmdline | grep -oP 'tb_overlay=\K[^ ]*')
  echo "tb_overlay=$tb_overlay"
else
  tb_overlay=""
fi

#if cmdline contains the string "tb_rootfs_ro"
if [[ $cmdline == *"tb_rootfs_ro"* ]]; then
  tb_rootfs_ro=$(echo $cmdline | grep -oP 'tb_rootfs_ro=\K[^ ]*')
  echo "tb_rootfs_ro=$tb_rootfs_ro"
else
  tb_rootfs_ro=""
fi

#if cmdline contains the string "tb_backup"
if [[ $cmdline == *"tb_backup"* ]]; then
  tb_backup=$(echo $cmdline | grep -oP 'tb_backup=\K[^ ]*')
  echo "tb_backup=$tb_backup"
else
  tb_backup=""
fi

#if cmdline contains the string "tb_restore"
if [[ $cmdline == *"tb_restore"* ]]; then
  tb_restore=$(echo $cmdline | grep -oP 'tb_restore=\K[^ ]*')
  echo "tb_restore=$tb_restore"
else
  tb_restore=""
fi

#if cmdline contains the string "tb_noboot"
if [[ $cmdline == *"tb_noboot"* ]]; then
  tb_restore=$(echo $cmdline | grep -oP 'tb_noboot=\K[^ ]*')
  echo "tb_noboot=$tb_restore"
else
  tb_noboot=""
fi

#if tb_backup is set, then do a backup of the rootfs
if [ ! -z $tb_backup ]; then
  echo "Backing up of emmc"
  dd if=/dev/mmcblk0 of=$tb_backup oflag=direct status=progress
  sync
fi

#if tb_restore is set, then restore the rootfs from the backup
if [ ! -z $tb_restore ]; then
  trap - ERR #disable error trap
  echo "Restoring emmc"
  dd if=$tb_restore of=/dev/mmcblk0 oflag=direct status=progress
  sync
  #reboot to make sure the new rootfs is loaded
  echo 1 >/proc/sys/kernel/sysrq
  echo b >/proc/sysrq-trigger
fi

#if tb_noboot is set, then boot to minimal system
if [ ! -z $tb_noboot ]; then
  # wile 1
  while [ 1 ]; do
    echo "To reboot in this environment enter the following command: "
    echo "echo 1 >/proc/sys/kernel/sysrq && echo b >/proc/sysrq-trigger"
    /bin/bash
  done
fi

#if tb_overlay is set, then mount it
#Remarks:
# if overlay does NOT exist or 'size=0', then
# ...DO NOT add 'tb_overlay' in file 'penagram_common.h', line '"b_c=console=tty1 console=ttyS0,115200 earlyprintk\0" \
# However, if overlay exist and 'size>0', then
# ...ADD 'tb_overlay' in file 'penagram_common.h', line '"b_c=console=tty1 console=ttyS0,115200 earlyprintk tb_overlay\0" \
if [ -n "$tb_overlay" ]; then
  echo "tb_overlay is set, mounting $tb_overlay"
  #create /overlay if it doesn't exist
  if [ ! -d /overlay ]; then
    mount -o remount,rw / #remounting root in emmc as writeable
    mkdir /overlay        
    #this is also the first boot.
    #Create an 'ext4' partition '/dev/mmcblk0p9'
    /usr/sbin/mkfs.ext4 $tb_overlay
  fi

  #check if tb_overlay is an ext4 partition
  mount $tb_overlay /overlay

  #if tb_rootfs_ro is equal to true then delete the contents of /overlay
  #Remarks:
  # non-persistent -> remove overlay partition. 
  # ...This means add 'tb_rootfs_ro' in file 'penagram_common.h', line "b_c=console=tty1 console=ttyS0,115200 earlyprintk tb_overlay tb_rootfs_ro\0"
  # persistent -> do not remove overlay partition. 
  # ...This means do NOT add 'tb_rootfs_ro' in file 'penagram_common.h', line "b_c=console=tty1 console=ttyS0,115200 earlyprintk tb_overlay\0"
  if [ "$tb_rootfs_ro" = "true" ]; then #non-persistent
      echo "tb_rootfs_ro is set, deleting contents of /overlay"
      rm -rf /overlay/*
  else  #persistent
      echo "tb_rootfs_ro is not set, not deleting contents of /overlay"
  fi

  if [ ! -d /overlay/root ]; then
    echo "Creating /overlay/root"
    mkdir /overlay/root
  fi

  #if  /overlay/root_upper does not exist then create it
  if [ ! -d /overlay/root_upper ]; then
    echo "Creating /overlay/root_upper"
    mkdir /overlay/root_upper
  fi

  #if  /overlay/root_work does not exist then create it
  if [ ! -d /overlay/root_work ]; then
    echo "Creating /overlay/root_work"
    mkdir /overlay/root_work
  fi

  mount -o remount,ro / #remounting root in emmc as readonly

  mount -t overlay overlay /overlay/root -o lowerdir=/,upperdir=/overlay/root_upper,workdir=/overlay/root_work

  cd /overlay/root

  #if oldroot does not exits then create it
  if [ ! -d oldroot ]; then
    echo "Creating oldroot"
    mkdir oldroot
  fi

  pivot_root . oldroot

fi

#Attempt to start systemd 
exec /lib/systemd/systemd

error_trap
