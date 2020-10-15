#!/bin/bash
#---Define variables
echo -e "\r"
echo -e "---Defining Environmental variables---"
echo -e "\r"
home_dir=~
usr_dir=/usr
scripts_dir=/scripts
usr_bin_dir=${usr_dir}/bin
scripts_foldername="scripts"
home_scripts_dir=${home_dir}/${scripts_foldername}
sunplus_foldername="SP7021"
sunplus_dir=${home_dir}/${sunplus_foldername}
initramfs_dir=${sunplus_dir}/linux/rootfs/initramfs
disk_foldername="disk"
disk_dir=${initramfs_dir}/${disk_foldername}
disk_scripts_dir=${disk_dir}/${scripts_foldername}
qemu_fpath=${usr_bin_dir}/qemu-arm-static
bash_fpath=${usr_bin_dir}/bash

chroot_exec_cmd_inside_chroot_filename="chroot_exec_cmd_inside_chroot.sh"
scripts_chroot_exec_cmd_inside_chroot_fpath=${home_scripts_dir}/${chroot_exec_cmd_inside_chroot_filename}
disk_scripts_chroot_exec_cmd_inside_chroot_fpath=${disk_scripts_dir}/${chroot_exec_cmd_inside_chroot_filename}
chroot_scripts_chroot_exec_cmd_inside_chroot_fpath=${scripts_dir}/${chroot_exec_cmd_inside_chroot_filename}

build_BOOOT_BIN_filename="build_BOOOT_BIN.sh"
scripts_build_BOOOT_BIN_fpath=${home_scripts_dir}/${build_BOOOT_BIN_filename}

#---Show mmessage
echo -e "\r"
echo -e "---------------------------------------------------------------"
echo -e "\tPREPARING CHROOT"
echo -e "---------------------------------------------------------------"

#---Create directory "~/SP7021/linux/rootfs/initramfs/disk/scripts"
echo -e "\r"
echo -e ">Creating <${scripts_foldername}>"
echo -e ">in: ${disk_dir}"
if [[ ! -d ${disk_scripts_dir} ]]; then
	sudo mkdir ${disk_scripts_dir}
fi

#---Copy "chroot_exec_cmd_inside_chroot.sh" to "~/SP7021/linux/rootfs/initramfs/disk/scripts"
echo -e "\r"
echo -e ">Copying: ${chroot_exec_cmd_inside_chroot_filename}"
echo -e ">from: ${home_scripts_dir}"
echo -e ">to: ${disk_scripts_dir}"
echo -e "\r"
sudo cp ${scripts_chroot_exec_cmd_inside_chroot_fpath} ${disk_scripts_dir}


#---Make "chroot_exec_cmd_inside_chroot.sh" executable
echo -e "\r"
echo -e ">chmod +x ${chroot_exec_cmd_inside_chroot_filename}"
echo -e ">in: ${disk_scripts_dir}"
sudo chmod +x ${disk_scripts_chroot_exec_cmd_inside_chroot_fpath}


#---Go into CHROOT
#Note: anything inside EOF is run inside your chrooted directory
echo -e "\r"
echo -e "---------------------------------------------------------------"
echo -e "\tENTERING CHROOT ENVIRONMENT"
echo -e "---------------------------------------------------------------"
echo -e "\r"
read -N 1 -p "Do you wish to auto-run scripts within CHROOT (y/n): " answer
echo -e "\r"

if [[ ${answer} == "n" ]] || [[ ${answer} == "N" ]]; then
	echo -e "---------------------------------------------------------------"
	echo -e "To Manually Initialize and Prepare <rootfs>..."
	echo -e "...run the following script:"
	echo -e "\t${chroot_scripts_chroot_exec_cmd_inside_chroot_fpath}"
	echo -e "---------------------------------------------------------------"
	echo -e "\r"
 	sudo chroot ${disk_dir} ${qemu_fpath} ${bash_fpath}
		
	exit
fi


#---answer == "y" or "Y"
echo -e "---------------------------------------------------------------"
echo -e "Auto Initialization and Preparation of <rootfs>...In Progress"
echo -e "Running script:"
echo -e "\t${chroot_scripts_chroot_exec_cmd_inside_chroot_fpath}"
echo -e "---------------------------------------------------------------"
echo -e "\r"

cat << EOF | sudo chroot ${disk_dir} ${qemu_fpath} ${bash_fpath}
	source ${chroot_scripts_chroot_exec_cmd_inside_chroot_fpath}
EOF

echo -e "---------------------------------------------------------------"
echo -e "Auto Initialization and Preparation of <rootfs>...Completed"
echo -e "\r"
echo -e "To BUILD the <ISPBOOOT.BIN>, please run the following command:"
echo -e "\t${scripts_build_BOOOT_BIN_fpath}"
echo -e "---------------------------------------------------------------"
echo -e "\r"

#---Enter CHROOT
echo -e "\r"
echo -e ">Removing: ${chroot_exec_cmd_inside_chroot_filename}"
echo -e ">from: ${disk_scripts_dir}"
echo -e "\r"
sudo rm ${disk_scripts_chroot_exec_cmd_inside_chroot_fpath}
