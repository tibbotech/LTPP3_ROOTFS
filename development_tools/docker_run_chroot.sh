#!/bin/bash
#---Define PATHS
SP7xxx_foldername="SP7021"
disk_foldername="disk"

usr_dir=/usr
usr_bin_dir=${usr_dir}/bin

home_dir=~
SP7xxx_dir=${home_dir}/${SP7xxx_foldername}
SP7xxx_linux_rootfs_initramfs_dir=${SP7xxx_dir}/linux/rootfs/initramfs
SP7xxx_linux_rootfs_initramfs_disk_dir=${SP7xxx_linux_rootfs_initramfs_dir}/${disk_foldername}

qemu_fpath=${usr_bin_dir}/qemu-arm-static
bash_fpath=${usr_bin_dir}/bash

echo -e "\r"
echo -e "---------------------------------------------------------------"
echo -e "GOING INTO <CHROOT>"
echo -e "---------------------------------------------------------------"
echo -e "REMARK:"
echo -e "\tTo EXIT 'chroot', type 'exit'"
echo -e "---------------------------------------------------------------"
chroot ${SP7xxx_linux_rootfs_initramfs_disk_dir} ${qemu_fpath} ${bash_fpath}
