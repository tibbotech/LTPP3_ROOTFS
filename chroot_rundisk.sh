#!/bin/bash
#---Define variables
echo -e "\r"
echo -e "---Defining Environmental variables---"
echo -e "\r"

build_BOOOT_BIN_filename="build_BOOOT_BIN.sh"
disk_foldername="disk"
scripts_foldername="scripts"
SP7xxx_foldername="SP7021"

home_dir=~
usr_dir=/usr
scripts_dir=/scripts
usr_bin_dir=${usr_dir}/bin
home_lttp3rootfs_dir=${home_dir}/LTPP3_ROOTFS

SP7xxx_dir=${home_dir}/${SP7xxx_foldername}
SP7xxx_linux_rootfs_initramfs_dir=${SP7xxx_dir}/linux/rootfs/initramfs
SP7xxx_linux_rootfs_initramfs_disk_dir=${SP7xxx_linux_rootfs_initramfs_dir}/${disk_foldername}
SP7xxx_linux_rootfs_initramfs_disk_scripts_dir=${SP7xxx_linux_rootfs_initramfs_disk_dir}/${scripts_foldername}

qemu_fpath=${usr_bin_dir}/qemu-arm-static
bash_fpath=${usr_bin_dir}/bash

chroot_exec_cmd_inside_chroot_filename="chroot_exec_cmd_inside_chroot.sh"
src_chroot_exec_cmd_inside_chroot_fpath=${home_lttp3rootfs_dir}/${chroot_exec_cmd_inside_chroot_filename}
dst_chroot_exec_cmd_inside_chroot_fpath=${SP7xxx_linux_rootfs_initramfs_disk_scripts_dir}/${chroot_exec_cmd_inside_chroot_filename}
chroot_exec_cmd_inside_chroot_fpath=${scripts_dir}/${chroot_exec_cmd_inside_chroot_filename}


#---Show mmessage
echo -e "\r"
echo -e "---------------------------------------------------------------"
echo -e "\tPREPARING CHROOT"
echo -e "---------------------------------------------------------------"

#---Create directory "~/SP7021/linux/rootfs/initramfs/disk/scripts"
echo -e "\r"
echo -e ">Creating <${scripts_foldername}>"
echo -e ">in: ${SP7xxx_linux_rootfs_initramfs_disk_dir}"
if [[ ! -d ${SP7xxx_linux_rootfs_initramfs_disk_scripts_dir} ]]; then
	mkdir ${SP7xxx_linux_rootfs_initramfs_disk_scripts_dir}
fi

#---Copy "chroot_exec_cmd_inside_chroot.sh" to "~/SP7021/linux/rootfs/initramfs/disk/scripts"
echo -e "\r"
echo -e ">Copying: ${chroot_exec_cmd_inside_chroot_filename}"
echo -e ">from: ${home_lttp3rootfs_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_scripts_dir}"
echo -e "\r"
cp ${src_chroot_exec_cmd_inside_chroot_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_scripts_dir}


#---Make "chroot_exec_cmd_inside_chroot.sh" executable
echo -e "\r"
echo -e ">chmod +x ${chroot_exec_cmd_inside_chroot_filename}"
echo -e ">in: ${SP7xxx_linux_rootfs_initramfs_disk_scripts_dir}"
chmod +x ${dst_chroot_exec_cmd_inside_chroot_fpath}


#---Go into CHROOT
#Note: anything inside EOF is run inside your chrooted directory
echo -e "\r"
echo -e "---------------------------------------------------------------"
echo -e "\tENTERING CHROOT ENVIRONMENT"
echo -e "---------------------------------------------------------------"

echo -e "---------------------------------------------------------------"
echo -e "Auto Initialization and Preparation of <rootfs>...In Progress"
echo -e "Running script:"
echo -e "\t${chroot_exec_cmd_inside_chroot_fpath}"
echo -e "---------------------------------------------------------------"
echo -e "\r"

cat << EOF | chroot ${SP7xxx_linux_rootfs_initramfs_disk_dir} ${qemu_fpath} ${bash_fpath}
	source ${chroot_exec_cmd_inside_chroot_fpath}
EOF

echo -e "\r"
echo -e ">Removing: ${chroot_exec_cmd_inside_chroot_filename}"
echo -e ">from: ${SP7xxx_linux_rootfs_initramfs_disk_scripts_dir}"
echo -e "\r"
rm ${dst_chroot_exec_cmd_inside_chroot_fpath}
