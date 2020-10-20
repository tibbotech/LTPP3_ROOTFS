disk_foldername="disk"
scripts_foldername="scripts"
SP7xxx_foldername="SP7021"

home_dir=~
usr_dir=/usr
scripts_dir=/scripts
usr_bin_dir=${usr_dir}/bin

SP7xxx_dir=${home_dir}/${SP7xxx_foldername}
SP7xxx_linux_rootfs_initramfs_dir=${SP7xxx_dir}/linux/rootfs/initramfs
SP7xxx_linux_rootfs_initramfs_disk_dir=${SP7xxx_linux_rootfs_initramfs_dir}/${disk_foldername}

qemu_fpath=${usr_bin_dir}/qemu-arm-static
bash_fpath=${usr_bin_dir}/bash

cat << EOF | chroot ${SP7xxx_linux_rootfs_initramfs_disk_dir} ${qemu_fpath} ${bash_fpath}
	apt-get install -y bsdmainutils
EOF
