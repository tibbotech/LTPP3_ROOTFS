#!/bin/bash
#---Local Functions
press_any_key__localfunc() {
	#Define constants
	local cTIMEOUT_ANYKEY=0

	#Initialize variables
	local keypressed=""
	local tcounter=0

	#Show Press Any Key message with count-down
	echo -e "\r"
	while [[ ${tcounter} -le ${cTIMEOUT_ANYKEY} ]];
	do
		delta_tcounter=$(( ${cTIMEOUT_ANYKEY} - ${tcounter} ))

		echo -e "\rPress (a)bort or any key to continue... (${delta_tcounter}) \c"
		read -N 1 -t 1 -s -r keypressed

		if [[ ! -z "${keypressed}" ]]; then
			if [[ "${keypressed}" == "a" ]] || [[ "${keypressed}" == "A" ]]; then
				echo -e "\r"
				echo -e "\r"
				
				exit
			else
				break
			fi
		fi
		
		tcounter=$((tcounter+1))
	done
	echo -e "\r"
}



#---Check if currently NOT logged in as "root"
echo -e "\r"
echo "---Checking current user---"
echo -e "\r"
current_user=`whoami`

if [[ ${current_user} == "root" ]]; then
	echo -e "\r"
	echo ">Current user is <root>..."
	echo ">>>Please login as a normal user (e.g. imcase)"
	echo -e "\r"
	echo ">Exiting Now..."
	echo -e "\r"
	echo -e "\r"

	exit
fi



#---Define path variables
press_any_key__localfunc
echo -e "\r"
echo "---Defining Varabiles (Filenames, Directories, Paths, Full-Paths)---"
echo -e "\r"
armhf_filename="ubuntu-base-20.04.1-base-armhf.tar.gz"
disk_foldername="disk"
make_menuconfig_filename="armhf_kernel.config"
make_menuconfig_default_filename=".config"
qemu_arm_static_filename="qemu-arm-static"
resolve_filename="resolv.conf"
usb_mount_rules_filename="usb-mount.rules"
usb_mount_service_filename="usb-mount@.service"
usb_mount_sh_filename="usb-mount.sh"

sd_detect_rules_filename="sd-detect.rules"
sd_detect_service_filename="sd-detect@.service"
sd_detect_add_sh_filename="sd-detect-add.sh"
sd_detect_remove_sh_filename="sd-detect-remove.sh"

sunplus_foldername="SP7021"
resize2fs_exec_filename="resize2fs_exec.sh"
profile_filename="profile"
chroot_exec_cmd_inside_chroot_filename="chroot_exec_cmd_inside_chroot.sh"
# daisychain_mode_filename="mode"
enable_eth1_before_login_service_filename="enable-eth1-before-login.service"
enable_eth1_before_login_sh_filename="enable-eth1-before-login.sh"
resize2fs_before_login_service_filename="resize2fs-before-login.service"
resize2fs_before_login_sh_filename="resize2fs-before-login.sh"
enable_ufw_before_login_service_filename="enable-ufw-before-login.service"
enable_ufw_before_login_sh_filename="enable-ufw-before-login.sh"

home_dir=~
etc_dir=/etc
usr_dir=/usr
usr_bin_dir=${usr_dir}/bin
Downloads_dir=${home_dir}/Downloads
Downloads_disk_dir=${Downloads_dir}/${disk_foldername}
Downloads_disk_lib_dir=${Downloads_dir}/disk/lib
scripts_dir=/scripts
home_scripts_dir=${home_dir}${scripts_dir}
work_dir=${home_dir}/SP7021
kernel_dir=${work_dir}/linux/kernel
initramfs_dir=${work_dir}/linux/rootfs/initramfs
disk_dir=${initramfs_dir}/${disk_foldername}
disk_etc_dir=${disk_dir}/etc
disk_lib_dir=${disk_dir}/lib
disk_root_dir=${disk_dir}/root
disk_home_ubuntu_dir=${disk_dir}/home/ubuntu
disk_usr_bin_dir=${disk_dir}${usr_dir}/bin

disk_etc_systemd_system_dir=${disk_etc_dir}/systemd/system
disk_etc_udev_rules_d_dir=${disk_etc_dir}/udev/rules.d
disk_usr_local_bin_dir=${disk_dir}${usr_dir}/local/bin
disk_scripts_dir=${disk_dir}/scripts
# daisychain_dir=/sys/devices/platform/soc\@B/9c108000.l2sw

# dev_dir=/dev
# mmcblk0p8_part="mmcblk0p8"
# dev_mmcblk0p8_dir=${dev_dir}/${mmcblk0p8_part}

src_resolve_fpath=${etc_dir}/${resolve_filename}
armhf_fpath=${Downloads_dir}/${armhf_filename}
disk_etc_profile_fpath=${disk_etc_dir}/${profile_filename}
chroot_exec_cmd_inside_chroot_fpath=${scripts_dir}/${chroot_exec_cmd_inside_chroot_filename}
disk_scripts_chroot_exec_cmd_inside_chroot_fpath=${disk_scripts_dir}/${chroot_exec_cmd_inside_chroot_filename}
# daisychain_mode_fpath=${daisychain_dir}/${daisychain_mode_filename}

src_make_menuconfig_fpath=${home_scripts_dir}/${make_menuconfig_filename}
dst_make_menuconfig_fpath=${kernel_dir}/${make_menuconfig_default_filename}

src_usb_mount_service_fpath=${home_scripts_dir}/${usb_mount_service_filename}
dst_usb_mount_service_fpath=${disk_etc_systemd_system_dir}/${usb_mount_service_filename}

src_usb_mount_sh_fpath=${home_scripts_dir}/${usb_mount_sh_filename}
dst_usb_mount_sh_fpath=${disk_usr_local_bin_dir}/${usb_mount_sh_filename}

src_usb_mount_rules_fpath=${home_scripts_dir}/${usb_mount_rules_filename}
dst_usb_mount_rules_fpath=${disk_etc_udev_rules_d_dir}/${usb_mount_rules_filename}

src_sd_detect_service_fpath=${home_scripts_dir}/${sd_detect_service_filename}
dst_sd_detect_service_fpath=${disk_etc_systemd_system_dir}/${sd_detect_service_filename}

src_sd_detect_rules_fpath=${home_scripts_dir}/${sd_detect_rules_filename}
dst_sd_detect_rules_fpath=${disk_etc_udev_rules_d_dir}/${sd_detect_rules_filename}

src_sd_detect_add_sh_fpath=${home_scripts_dir}/${sd_detect_add_sh_filename}
dst_sd_detect_add_sh_fpath=${disk_usr_local_bin_dir}/${sd_detect_add_sh_filename}

src_sd_detect_remove_sh_fpath=${home_scripts_dir}/${sd_detect_remove_sh_filename}
dst_sd_detect_remove_sh_fpath=${disk_usr_local_bin_dir}/${sd_detect_remove_sh_filename}

scripts_resize2fs_exec_fpath=${scripts_dir}/${resize2fs_exec_filename}
src_resize2fs_exec_fpath=${home_scripts_dir}/${resize2fs_exec_filename}
dst_resize2fs_exec_fpath=${disk_scripts_dir}/${resize2fs_exec_filename}

src_enable_eth1_before_login_service_fpath=${home_scripts_dir}/${enable_eth1_before_login_service_filename}
dst_enable_eth1_before_login_service_fpath=${disk_etc_systemd_system_dir}/${enable_eth1_before_login_service_filename}

src_enable_eth1_before_login_sh_fpath=${home_scripts_dir}/${enable_eth1_before_login_sh_filename}
dst_enable_eth1_before_login_sh_fpath=${disk_usr_local_bin_dir}/${enable_eth1_before_login_sh_filename}

src_resize2fs_before_login_service_fpath=${home_scripts_dir}/${resize2fs_before_login_service_filename}
dst_resize2fs_before_login_service_fpath=${disk_etc_systemd_system_dir}/${resize2fs_before_login_service_filename}

src_resize2fs_before_login_sh_fpath=${home_scripts_dir}/${resize2fs_before_login_sh_filename}
dst_resize2fs_before_login_sh_fpath=${disk_usr_local_bin_dir}/${resize2fs_before_login_sh_filename}

src_enable_ufw_before_login_service_fpath=${home_scripts_dir}/${enable_ufw_before_login_service_filename}
dst_enable_ufw_before_login_service_fpath=${disk_etc_systemd_system_dir}/${enable_ufw_before_login_service_filename}

src_enable_ufw_before_login_sh_fpath=${home_scripts_dir}/${enable_ufw_before_login_sh_filename}
dst_enable_ufw_before_login_sh_fpath=${disk_usr_local_bin_dir}/${enable_ufw_before_login_sh_filename}


echo -e "\r"
echo "---------------------------------------------------------------"
echo -e "\tPRE-PREPARATION of DISK for CHROOT"
echo "---------------------------------------------------------------"


press_any_key__localfunc
#---Download armhf-image (if needed)
if [[ ! -f ${armhf_fpath} ]]; then
	echo -e "\r"
	echo ">Navigate to <~/Downloads>"
	cd ${Downloads_dir}

	echo -e "\r"
	echo ">Downloading ${armhf_filename}"
	press_any_key__localfunc
	sudo wget http://cdimage.ubuntu.com/cdimage/ubuntu-base/releases//20.04/release/${armhf_filename}
fi


if [[ -d ${Downloads_disk_dir} ]]; then
	press_any_key__localfunc
	echo -e "\r"
	echo ">Removing: ${disk_foldername}"
	sudo rm -r ${Downloads_disk_dir}
fi

press_any_key__localfunc
echo -e "\r"
echo ">Moving: ${disk_foldername}"
echo ">from: ${initramfs_dir}"
echo ">to: ${Downloads_dir}"
	sudo mv ${disk_dir} ${Downloads_dir}/

press_any_key__localfunc
echo -e "\r"
echo ">Navigate to ${Downloads_dir}"
	cd ${Downloads_dir}

press_any_key__localfunc
	disk_tspan=$(date +%Y%m%d%H%M%S)
	disk_targz_filename="disk.diskPREprep.${disk_tspan}.tar.gz"
echo -e "\r"
echo ">Compressing: ${disk_foldername}"
echo ">at: ${Downloads_dir}"
	sudo tar -czvf ${disk_targz_filename} ${disk_foldername}

press_any_key__localfunc
echo -e "\r"
echo ">Creating: ${disk_foldername}"
echo ">at: ${initramfs_dir}"
	sudo mkdir ${disk_dir}

press_any_key__localfunc
echo -e "\r"
echo ">Copying: ${armhf_filename}"
echo ">from: ${Downloads_dir}"
echo ">to: ${disk_dir}"
	sudo cp ${Downloads_dir}/${armhf_filename} ${disk_dir}

press_any_key__localfunc
echo -e "\r"
echo ">Navigate to ${disk_dir}"
	cd ${disk_dir}

press_any_key__localfunc
echo -e "\r"
echo ">Extracting: ${armhf_filename}"
	sudo tar -xzvf ${armhf_filename}

press_any_key__localfunc
echo -e "\r"
echo ">Removing: ${armhf_filename}"
	sudo rm ${armhf_filename}

press_any_key__localfunc
echo -e "\r"
echo ">Navigate to ${Downloads_disk_lib_dir}"
	cd ${Downloads_disk_lib_dir}

press_any_key__localfunc
echo -e "\r"
echo ">Copying folders (incl. contents): firmware and modules"
echo ">from: ${Downloads_disk_lib_dir}"
echo ">to: ${disk_dir}"
	sudo cp -R firmware/ ${disk_lib_dir}
	sudo cp -R modules/ ${disk_lib_dir}

press_any_key__localfunc
echo -e "\r"
echo ">Copying: ${qemu_arm_static_filename}"
echo ">from: ${usr_bin_dir}"
echo ">to: ${disk_usr_bin_dir}"
	sudo cp ${usr_bin_dir}/${qemu_arm_static_filename} ${disk_usr_bin_dir}


# press_any_key__localfunc
# #For directory: ~/SP7021/linux/rootfs/initramfs/disk, change ownership to imcase:imcase
# current_user=`whoami`
# if [[ "${current_user}" == "root" ]]; then
# 	read -e -p "Provide name of new owner of <disk> folder: " -i "${current_user}" current_user
# fi
# echo -e "\r"
# echo ">Changing ownerschip of folder: ${disk_foldername}"
# echo ">in: ${initramfs_dir}"
# echo ">to: ${current_user}:${current_user}"
# sudo chown ${current_user}:${current_user} -R ${disk_dir}

press_any_key__localfunc
echo -e "\r"
echo ">Removing: ${disk_foldername}"
echo ">in: ${Downloads_dir}"
	sudo rm -rf ${Downloads_disk_dir}

press_any_key__localfunc
echo -e "\r"
echo ">Copying: ${resolve_filename}"
echo ">from: ${etc_dir}"
echo ">to: ${disk_etc_dir}"
echo -e "\r"
echo -e "\r"
	sudo cp ${src_resolve_fpath} ${disk_etc_dir}

press_any_key__localfunc
echo -e "\r"
echo "---AUTO-MOUNT USB & MMC-SD---"
echo -e "\r"
echo ">Checking if directory <${disk_etc_systemd_system_dir}> exists?"
if [[ -d ${disk_etc_systemd_system_dir} ]]; then
	echo -e "\r"
	echo ">>>--does exist"
	echo -e "\r"
	echo ">>>>>Checking if file <${usb_mount_service_filename}> exists"
	if [[ -f ${dst_usb_mount_service_fpath} ]]; then
		echo ">>>>>--does exist"
		echo -e "\r"
		echo ">>>>>>>Removing file <${usb_mount_service_filename}>"
			sudo rm ${dst_usb_mount_service_fpath}
	fi
else
	echo -e "\r"
	echo ">>>--does NOT exist"
	echo -e "\r"
	echo ">>>>>Creating directory <${disk_etc_systemd_system_dir}>"
		sudo mkdir -p ${disk_etc_systemd_system_dir}
	
	echo -e "\r"
	echo ">>>>>Change ownership to <root> for directory: ${disk_etc_systemd_system_dir}"
		sudo chown root:root ${disk_etc_systemd_system_dir}

	echo -e "\r"
	echo ">>>>>Change permission to <drwxr-xr-x> for directory: ${disk_etc_systemd_system_dir}"
		sudo chmod 755 ${disk_etc_systemd_system_dir}
fi

echo -e "\r"
echo ">Copy file <systemd unit service>: ${usb_mount_service_filename}"
echo ">from: ${home_scripts_dir}"
echo ">to: ${disk_etc_systemd_system_dir}"
	sudo sudo cp ${src_usb_mount_service_fpath} ${disk_etc_systemd_system_dir}

echo -e "\r"
echo ">>>Change ownership to <root> for file: ${usb_mount_service_filename}"
	sudo chown root:root ${dst_usb_mount_service_fpath}

echo -e "\r"
echo ">>>Change permission to <-rw-r--r--> for file: ${usb_mount_service_filename}"
	sudo chmod 644 ${dst_usb_mount_service_fpath}


echo -e "\r"
echo ">Copy file <systemd unit service>: ${sd_detect_service_filename}"
echo ">from: ${home_scripts_dir}"
echo ">to: ${disk_etc_systemd_system_dir}"
	sudo sudo cp ${src_sd_detect_service_fpath} ${disk_etc_systemd_system_dir}

echo -e "\r"
echo ">>>Change ownership to <root> for file: ${sd_detect_service_filename}"
	sudo chown root:root ${dst_sd_detect_service_fpath}

echo -e "\r"
echo ">>>Change permission to <-rw-r--r--> for file: ${sd_detect_service_filename}"
	sudo chmod 644 ${dst_sd_detect_service_fpath}



press_any_key__localfunc
echo -e "\r"
echo -e "\r"
echo ">Checking if directory <${disk_usr_local_bin_dir}> exists?"
if [[ -d ${disk_usr_local_bin_dir} ]]; then
	echo -e "\r"
	echo ">>>--does exist"
	echo -e "\r"
	echo ">>>>>Checking if file <${usb_mount_sh_filename}> exists"
	if [[ -f ${dst_usb_mount_sh_fpath} ]]; then
		echo ">>>>>--does exist"
		echo -e "\r"
		echo ">>>>>>>Removing file <${usb_mount_sh_filename}>"
			sudo rm ${dst_usb_mount_sh_fpath}
	fi
else
	echo -e "\r"
	echo ">>>--does NOT exist"
	echo -e "\r"
	echo ">>>>>Creating directory <${disk_usr_local_bin_dir}>"
		sudo mkdir -p ${disk_usr_local_bin_dir}

	echo -e "\r"
	echo ">>>>>Change ownership to <root> for directory: ${disk_usr_local_bin_dir}"
		sudo chown root:root ${disk_usr_local_bin_dir}

	echo -e "\r"
	echo ">>>>>Change permission to <drwxr-xr-x> for directory: ${disk_usr_local_bin_dir}"
		sudo chmod 755 ${disk_usr_local_bin_dir}
fi

echo -e "\r"
echo ">Copy file: ${usb_mount_sh_filename}"
echo ">from: ${home_scripts_dir}"
echo ">to: ${disk_usr_local_bin_dir}"
	sudo cp ${src_usb_mount_sh_fpath} ${disk_usr_local_bin_dir}

echo -e "\r"
echo ">>>Change ownership to <root> for file: ${usb_mount_sh_filename}"
	sudo chown root:root ${dst_usb_mount_sh_fpath}

echo -e "\r"
echo ">>>Change permission to <-rwxr-xr-x> for file: ${usb_mount_sh_filename}"
	sudo chmod 755 ${dst_usb_mount_sh_fpath}


echo -e "\r"
echo ">Copy file: ${sd_detect_add_sh_filename}"
echo ">from: ${home_scripts_dir}"
echo ">to: ${disk_usr_local_bin_dir}"
	sudo cp ${src_sd_detect_add_sh_fpath} ${disk_usr_local_bin_dir}

echo -e "\r"
echo ">>>Change ownership to <root> for file: ${sd_detect_add_sh_filename}"
	sudo chown root:root ${dst_sd_detect_add_sh_fpath}

echo -e "\r"
echo ">>>Change permission to <-rwxr-xr-x> for file: ${sd_detect_add_sh_filename}"
	sudo chmod 755 ${dst_sd_detect_add_sh_fpath}

echo -e "\r"
echo ">Copy file: ${sd_detect_remove_sh_filename}"
echo ">from: ${home_scripts_dir}"
echo ">to: ${disk_usr_local_bin_dir}"
	sudo cp ${src_sd_detect_remove_sh_fpath} ${disk_usr_local_bin_dir}

echo -e "\r"
echo ">>>Change ownership to <root> for file: ${sd_detect_remove_sh_filename}"
	sudo chown root:root ${dst_sd_detect_remove_sh_fpath}

echo -e "\r"
echo ">>>Change permission to <-rwxr-xr-x> for file: ${sd_detect_remove_sh_filename}"
	sudo chmod 755 ${dst_sd_detect_remove_sh_fpath}



press_any_key__localfunc
echo -e "\r"
echo -e "\r"
echo ">Checking if directory <${disk_etc_udev_rules_d_dir}> exists"
if [[ -d ${disk_etc_udev_rules_d_dir} ]]; then
	echo -e "\r"
	echo ">>>--does exist"
	echo -e "\r"
	echo ">>>>>Checking if file <${usb_mount_rules_filename}> exists"
	if [[ -f ${dst_usb_mount_rules_fpath} ]]; then
		echo ">>>>>--does exist"
		echo -e "\r"
		echo ">>>>>>>Removing file <${usb_mount_rules_filename}>"
			sudo rm ${dst_usb_mount_rules_fpath}
	fi
else
	echo -e "\r"
	echo ">>>--does NOT exist"
	echo -e "\r"
	echo ">>>>>Creating directory <${disk_etc_udev_rules_d_dir}>"
		sudo mkdir -p ${disk_etc_udev_rules_d_dir}

	echo -e "\r"
	echo ">>>>>Change ownership to <root> for directory: ${disk_etc_udev_rules_d_dir}"
		sudo chown root:root ${disk_etc_udev_rules_d_dir}

	echo -e "\r"
	echo ">>>>>Change permission to <drwxr-xr-x> for directory: ${disk_etc_udev_rules_d_dir}"
		sudo chmod 755 ${disk_etc_udev_rules_d_dir}
fi

echo -e "\r"
echo ">Copy file: ${usb_mount_rules_filename}"
echo ">from: ${home_scripts_dir}"
echo ">to: ${disk_etc_udev_rules_d_dir}"
	sudo cp ${src_usb_mount_rules_fpath} ${disk_etc_udev_rules_d_dir}

echo -e "\r"
echo ">>>Change ownership to <root> for file: ${usb_mount_rules_filename}"
	sudo chown root:root ${dst_usb_mount_rules_fpath}

echo -e "\r"
echo ">>>Change permission to <-rw-r--r--> for file: ${usb_mount_rules_filename}"
	sudo chmod 644 ${dst_usb_mount_rules_fpath}


echo -e "\r"
echo ">Copy file: ${sd_detect_rules_filename}"
echo ">from: ${home_scripts_dir}"
echo ">to: ${disk_etc_udev_rules_d_dir}"
	sudo cp ${src_sd_detect_rules_fpath} ${disk_etc_udev_rules_d_dir}

echo -e "\r"
echo ">>>Change ownership to <root> for file: ${sd_detect_rules_filename}"
	sudo chown root:root ${dst_sd_detect_rules_fpath}

echo -e "\r"
echo ">>>Change permission to <-rw-r--r--> for file: ${sd_detect_rules_filename}"
	sudo chmod 644 ${dst_sd_detect_rules_fpath}



press_any_key__localfunc
echo -e "\r"
echo "---Services to run BEFORE login---"
echo -e "\r"

echo -e "\r"
echo ">Creating <${scripts_foldername}>"
echo ">in: ${disk_dir}"
if [[ ! -d ${disk_scripts_dir} ]]; then
	sudo mkdir ${disk_scripts_dir}
fi

echo -e "\r"
echo ">Copying: ${resize2fs_exec_filename}"
echo ">from: ${home_scripts_dir}"
echo ">to: ${disk_scripts_dir}"
	sudo cp ${src_resize2fs_exec_fpath} ${disk_scripts_dir}

echo -e "\r"
echo ">>>Change ownership to <root> for file: ${resize2fs_exec_filename}"
	sudo chown root:root ${dst_resize2fs_exec_fpath}

echo -e "\r"
echo ">>>Change permission to <-rw-r--r--> for file: ${resize2fs_exec_filename}"
	sudo chmod 755 ${dst_resize2fs_exec_fpath}

echo -e "\r"
echo ">Copying: ${enable_eth1_before_login_service_filename}>"
echo ">from: ${home_scripts_dir}"
echo ">to: ${disk_etc_systemd_system_dir}"
	sudo cp ${src_enable_eth1_before_login_service_fpath} ${disk_etc_systemd_system_dir}

echo -e "\r"
echo ">>>Change ownership to <root> for file: ${enable_eth1_before_login_service_filename}"
	sudo chown root:root ${dst_enable_eth1_before_login_service_fpath}

echo -e "\r"
echo ">>>Change permission to <-rw-r--r--> for file: ${enable_eth1_before_login_service_filename}"
	sudo chmod 644 ${dst_enable_eth1_before_login_service_fpath}

echo -e "\r"
echo ">Copying: ${enable_eth1_before_login_sh_filename}>"
echo ">from: ${home_scripts_dir}"
echo ">to: ${disk_usr_local_bin_dir}"
	sudo cp ${src_enable_eth1_before_login_sh_fpath} ${disk_usr_local_bin_dir}

echo -e "\r"
echo ">>>Change ownership to <root> for file: ${enable_eth1_before_login_sh_filename}"
	sudo chown root:root ${dst_enable_eth1_before_login_sh_fpath}

echo -e "\r"
echo ">>>Change permission to <-rw-r--r--> for file: ${enable_eth1_before_login_sh_filename}"
	sudo chmod 755 ${dst_enable_eth1_before_login_sh_fpath}

echo -e "\r"
echo ">Copying: ${resize2fs_before_login_service_filename}>"
echo ">from: ${home_scripts_dir}"
echo ">to: ${disk_etc_systemd_system_dir}"
	sudo cp ${src_resize2fs_before_login_service_fpath} ${disk_etc_systemd_system_dir}

echo -e "\r"
echo ">>>Change ownership to <root> for file: ${resize2fs_before_login_service_filename}"
	sudo chown root:root ${dst_resize2fs_before_login_service_fpath}

echo -e "\r"
echo ">>>Change permission to <-rw-r--r--> for file: ${resize2fs_before_login_service_filename}"
	sudo chmod 644 ${dst_resize2fs_before_login_service_fpath}

echo -e "\r"
echo ">Copying: ${resize2fs_before_login_sh_filename}>"
echo ">from: ${home_scripts_dir}"
echo ">to: ${disk_usr_local_bin_dir}"
	sudo cp ${src_resize2fs_before_login_sh_fpath} ${disk_usr_local_bin_dir}

echo -e "\r"
echo ">>>Change ownership to <root> for file: ${resize2fs_before_login_sh_filename}"
	sudo chown root:root ${dst_resize2fs_before_login_sh_fpath}

echo -e "\r"
echo ">>>Change permission to <-rw-r--r--> for file: ${resize2fs_before_login_sh_filename}"
	sudo chmod 755 ${dst_resize2fs_before_login_sh_fpath}

echo -e "\r"
echo ">Copying: ${enable_ufw_before_login_service_filename}>"
echo ">from: ${home_scripts_dir}"
echo ">to: ${disk_etc_systemd_system_dir}"
	sudo cp ${src_enable_ufw_before_login_service_fpath} ${disk_etc_systemd_system_dir}

echo -e "\r"
echo ">>>Change ownership to <root> for file: ${enable_ufw_before_login_service_filename}"
	sudo chown root:root ${dst_enable_ufw_before_login_service_fpath}

echo -e "\r"
echo ">>>Change permission to <-rw-r--r--> for file: ${enable_ufw_before_login_service_filename}"
	sudo chmod 644 ${dst_enable_ufw_before_login_service_fpath}

echo -e "\r"
echo ">Copying: ${enable_ufw_before_login_sh_filename}>"
echo ">from: ${home_scripts_dir}"
echo ">to: ${disk_usr_local_bin_dir}"
	sudo cp ${src_enable_ufw_before_login_sh_fpath} ${disk_usr_local_bin_dir}

echo -e "\r"
echo ">>>Change ownership to <root> for file: ${enable_ufw_before_login_sh_filename}"
	sudo chown root:root ${dst_enable_ufw_before_login_sh_fpath}

echo -e "\r"
echo ">>>Change permission to <-rw-r--r--> for file: ${enable_ufw_before_login_sh_filename}"
	sudo chmod 755 ${dst_enable_ufw_before_login_sh_fpath}


press_any_key__localfunc
echo -e "\r"
echo "---Kernel Configuration File"
echo ">Copying: ${make_menuconfig_filename}"
echo ">from: ${home_scripts_dir}"
echo ">to: ${kernel_dir}"
echo ">as: ${make_menuconfig_default_filename}"
echo -e "\r"
echo -e "\r"
	sudo cp ${src_make_menuconfig_fpath} ${dst_make_menuconfig_fpath}

press_any_key__localfunc
echo -e "\r"
echo ">>>Navigate to ${kernel_dir}"
	cd ${kernel_dir}

press_any_key__localfunc
echo -e "\r"
echo ">>>>>Importing Kernel config-file: ${make_menuconfig_default_filename}"
echo ">from: ${kernel_dir}"
	sudo make oldconfig
echo -e "\r"
echo -e "\r"
