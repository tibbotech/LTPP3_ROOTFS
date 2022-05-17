#!/bin/bash
#---FUNCTIONS
function press_any_key__func() {
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

function checkIf_website_exists__func() {
    #Input args
    local url__input=${1}

    #Define constants
    local FAILED="failed"

    #Check if url exists
    local wget_spider_result=`wget --spider "${url__input}" 2>&1 /dev/null`
    local failed_isFound=`echo -e ${wget_spider_result} | grep "${FAILED}"`

    #Output
    if [[ -z ${failed_isFound} ]]; then #failed not found
        echo "true"
    else    #failed was found
        echo "false"
    fi
}



#---ENVIRONMENT VARIABLES
press_any_key__func
echo -e "\r"
echo -e "---Define Environmental Variables---"
echo -e "\r"

armhf_filename="ubuntu-base-20.04.1-base-armhf.tar.gz"

disk_foldername="disk"
firmware_foldername="firmware"

clkspq628c_filename="clk-sp-q628.c"

brcm_patchram_plus_filename="brcm_patchram_plus"

make_menuconfig_filename="armhf_kernel.config"
make_menuconfig_default_filename=".config"

sp7021_ltpp3g2revD_filename="sp7021-ltpp3g2revD.dtsi"

qemu_user_static_filename="qemu-arm-static"

resolve_filename="resolv.conf"

usb_mount_rules_filename="usb-mount.rules"
usb_mount_service_filename="usb-mount@.service"
usb_mount_sh_filename="usb-mount.sh"

sd_detect_rules_filename="sd-detect.rules"
sd_detect_service_filename="sd-detect@.service"
sd_detect_add_sh_filename="sd-detect-add.sh"
sd_detect_remove_sh_filename="sd-detect-remove.sh"

gpio_gpio_set_group_rules_filename="gpio-set_group.rules"

sunplus_foldername="SP7021"
profile_filename="profile"
chroot_exec_cmd_inside_chroot_filename="chroot_exec_cmd_inside_chroot.sh"
# daisychain_mode_filename="mode"
daisychain_state_service_filename="daisychain_state.service"
daisychain_state_sh_filename="daisychain_state.sh"
enable_eth1_before_login_service_filename="enable-eth1-before-login.service"
enable_eth1_before_login_sh_filename="enable-eth1-before-login.sh"
create_chown_pwm_service_filename="create-chown-pwm.service"
create_chown_pwm_sh_filename="create-chown-pwm.sh"
one_time_exec_sh_filename="one-time-exec.sh"
one_time_exec_before_login_sh_filename="one-time-exec-before-login.sh"
one_time_exec_before_login_service_filename="one-time-exec-before-login.service"
enable_ufw_before_login_service_filename="enable-ufw-before-login.service"
enable_ufw_before_login_sh_filename="enable-ufw-before-login.sh"

hostname_filename="hostname"
hosts_filename="hosts"

build_disk_filename="build_disk.sh"
build_disk_bck_filename=${build_disk_filename}.bak
build_disk_mod_filename=${build_disk_filename}.mod

home_dir=~	#this is the /root directory
etc_dir=/etc
usr_bin_dir=/usr/bin
home_downloads_dir=${home_dir}/Downloads
home_downloads_disk_dir=${home_downloads_dir}/${disk_foldername}
home_downloads_disk_lib_dir=${home_downloads_dir}/disk/lib

scripts_foldername="scripts"
scripts_dir=/${scripts_foldername}
home_lttp3rootfs_dir=${home_dir}/LTPP3_ROOTFS
home_lttp3rootfs_rootfs_initramfs_dir=${home_lttp3rootfs_dir}/rootfs/initramfs
home_lttp3rootfs_rootfs_initramfs_disk_etc_dir=${home_lttp3rootfs_rootfs_initramfs_dir}/disk/etc
home_lttp3rootfs_services_automount_dir=${home_lttp3rootfs_dir}/services/automount
home_lttp3rootfs_services_oobe_oneshot_dir=${home_lttp3rootfs_dir}/services/oobe/oneshot
home_lttp3rootfs_services_network_dir=${home_lttp3rootfs_dir}/services/network
home_lttp3rootfs_services_pwm_dir=${home_lttp3rootfs_dir}/services/pwm
home_lttp3rootfs_services_ufw_dir=${home_lttp3rootfs_dir}/services/ufw
home_lttp3rootfs_services_permissions_dir=${home_lttp3rootfs_dir}/services/permissions
home_lttp3rootfs_kernel_dir=${home_lttp3rootfs_dir}/kernel
home_lttp3rootfs_kernel_makeconfig_dir=${home_lttp3rootfs_kernel_dir}/makeconfig
home_lttp3rootfs_kernel_drivers_clk_dir=${home_lttp3rootfs_kernel_dir}/drivers/clk
home_lttp3rootfs_kernel_dts_dir=${home_lttp3rootfs_kernel_dir}/dts
home_lttp3rootfs_usr_bin_dir=${home_lttp3rootfs_dir}/usr/bin
SP7xxx_dir=${home_dir}/SP7021
SP7xxx_linux_kernel_dir=${SP7xxx_dir}/linux/kernel
SP7xxx_linux_kernel_drivers_clk=${SP7xxx_linux_kernel_dir}/drivers/clk
SP7xxx_linux_kernel_arch_arm_boot_dts_dir=${SP7xxx_linux_kernel_dir}/arch/arm/boot/dts
SP7xxx_linux_rootfs_initramfs_dir=${SP7xxx_dir}/linux/rootfs/initramfs
SP7xxx_linux_rootfs_initramfs_disk_dir=${SP7xxx_linux_rootfs_initramfs_dir}/${disk_foldername}
SP7xxx_linux_rootfs_initramfs_disk_etc_dir=${SP7xxx_linux_rootfs_initramfs_disk_dir}/etc
SP7xxx_linux_rootfs_initramfs_disk_lib_dir=${SP7xxx_linux_rootfs_initramfs_disk_dir}/lib
SP7xxx_linux_rootfs_initramfs_disk_usr_bin_dir=${SP7xxx_linux_rootfs_initramfs_disk_dir}/usr/bin
SP7xxx_linux_rootfs_initramfs_disk_var_backups_gpio_dir=${SP7xxx_linux_rootfs_initramfs_disk_dir}/var/backups/gpio

SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir=${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}/systemd/system
SP7xxx_linux_rootfs_initramfs_disk_etc_udev_rulesd_dir=${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}/udev/rules.d
SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir=${SP7xxx_linux_rootfs_initramfs_disk_dir}/usr/local/bin
SP7xxx_linux_rootfs_initramfs_disk_scripts_dir=${SP7xxx_linux_rootfs_initramfs_disk_dir}/scripts
# daisychain_dir=/sys/devices/platform/soc\@B/9c108000.l2sw

SP7xxx_linux_rootfs_initramfs_extra_dir=${SP7xxx_linux_rootfs_initramfs_dir}/extra
SP7xxx_linux_rootfs_initramfs_extra_etc_dir=${SP7xxx_linux_rootfs_initramfs_extra_dir}${etc_dir}

build_disk_fpath=${SP7xxx_linux_rootfs_initramfs_dir}/${build_disk_filename}
build_disk_bck_fpath=${SP7xxx_linux_rootfs_initramfs_dir}/${build_disk_bck_filename} 
build_disk_mod_fpath=${home_lttp3rootfs_rootfs_initramfs_dir}/${build_disk_mod_filename} 

# dev_dir=/dev
# mmcblk0p8_part="mmcblk0p8"
# dev_mmcblk0p8_dir=${dev_dir}/${mmcblk0p8_part}

src_resolve_fpath=${etc_dir}/${resolve_filename}
armhf_fpath=${home_downloads_dir}/${armhf_filename}
disk_etc_profile_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}/${profile_filename}

src_firmware_fpath=${home_lttp3rootfs_rootfs_initramfs_disk_etc_dir}/${firmware_foldername}
dst_firmware_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}/${firmware_foldername}

src_clkspq628c_fpath=${home_lttp3rootfs_kernel_drivers_clk_dir}/${clkspq628c_filename}
dst_clkspq628c_fpath=${SP7xxx_linux_kernel_drivers_clk}/${clkspq628c_filename}

src_brcm_patchram_plus_fpath=${home_lttp3rootfs_usr_bin_dir}/${brcm_patchram_plus_filename}
dst_brcm_patchram_plus_fpath=${SP7xxx_linux_rootfs_initramfs_disk_usr_bin_dir}/${brcm_patchram_plus_filename}

src_make_menuconfig_fpath=${home_lttp3rootfs_kernel_makeconfig_dir}/${make_menuconfig_filename}
dst_make_menuconfig_fpath=${SP7xxx_linux_kernel_dir}/${make_menuconfig_default_filename}

src_sp7021_ltpp3g2revD_fpath=${home_lttp3rootfs_kernel_dts_dir}/${sp7021_ltpp3g2revD_filename}
dst_sp7021_ltpp3g2revD_fpath=${SP7xxx_linux_kernel_arch_arm_boot_dts_dir}/${sp7021_ltpp3g2revD_filename}

src_usb_mount_service_fpath=${home_lttp3rootfs_services_automount_dir}/${usb_mount_service_filename}
dst_usb_mount_service_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}/${usb_mount_service_filename}

src_usb_mount_sh_fpath=${home_lttp3rootfs_services_automount_dir}/${usb_mount_sh_filename}
dst_usb_mount_sh_fpath=${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}/${usb_mount_sh_filename}

src_usb_mount_rules_fpath=${home_lttp3rootfs_services_automount_dir}/${usb_mount_rules_filename}
dst_usb_mount_rules_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_udev_rulesd_dir}/${usb_mount_rules_filename}

src_sd_detect_service_fpath=${home_lttp3rootfs_services_automount_dir}/${sd_detect_service_filename}
dst_sd_detect_service_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}/${sd_detect_service_filename}

src_sd_detect_rules_fpath=${home_lttp3rootfs_services_automount_dir}/${sd_detect_rules_filename}
dst_sd_detect_rules_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_udev_rulesd_dir}/${sd_detect_rules_filename}

src_gpio_set_group_rules_fpath=${home_lttp3rootfs_services_permissions_dir}/${gpio_gpio_set_group_rules_filename}
dst_gpio_set_group_rules_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_udev_rulesd_dir}/${gpio_gpio_set_group_rules_filename}

src_sd_detect_add_sh_fpath=${home_lttp3rootfs_services_automount_dir}/${sd_detect_add_sh_filename}
dst_sd_detect_add_sh_fpath=${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}/${sd_detect_add_sh_filename}

src_sd_detect_remove_sh_fpath=${home_lttp3rootfs_services_automount_dir}/${sd_detect_remove_sh_filename}
dst_sd_detect_remove_sh_fpath=${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}/${sd_detect_remove_sh_filename}

src_daisychain_state_service_fpath=${home_lttp3rootfs_services_network_dir}/${daisychain_state_service_filename}
dst_daisychain_state_service_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}/${daisychain_state_service_filename}

src_daisychain_state_sh_fpath=${home_lttp3rootfs_services_network_dir}/${daisychain_state_sh_filename}
dst_daisychain_state_sh_fpath=${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}/${daisychain_state_sh_filename}

src_enable_eth1_before_login_service_fpath=${home_lttp3rootfs_services_network_dir}/${enable_eth1_before_login_service_filename}
dst_enable_eth1_before_login_service_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}/${enable_eth1_before_login_service_filename}

src_enable_eth1_before_login_sh_fpath=${home_lttp3rootfs_services_network_dir}/${enable_eth1_before_login_sh_filename}
dst_enable_eth1_before_login_sh_fpath=${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}/${enable_eth1_before_login_sh_filename}

src_create_chown_pwm_service_fpath=${home_lttp3rootfs_services_pwm_dir}/${create_chown_pwm_service_filename}
dst_create_chown_pwm_service_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}/${create_chown_pwm_service_filename}

src_create_chown_pwm_sh_fpath=${home_lttp3rootfs_services_pwm_dir}/${create_chown_pwm_sh_filename}
dst_create_chown_pwm_sh_fpath=${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}/${create_chown_pwm_sh_filename}

src_one_time_exec_sh_fpath=${home_lttp3rootfs_services_oobe_oneshot_dir}/${one_time_exec_sh_filename}
dst_one_time_exec_sh_fpath=${SP7xxx_linux_rootfs_initramfs_disk_scripts_dir}/${one_time_exec_sh_filename}

src_one_time_exec_before_login_sh_fpath=${home_lttp3rootfs_services_oobe_oneshot_dir}/${one_time_exec_before_login_sh_filename}
dst_one_time_exec_before_login_sh_fpath=${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}/${one_time_exec_before_login_sh_filename}

src_one_time_exec_before_login_service_fpath=${home_lttp3rootfs_services_oobe_oneshot_dir}/${one_time_exec_before_login_service_filename}
dst_one_time_exec_before_login_service_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}/${one_time_exec_before_login_service_filename}

src_enable_ufw_before_login_service_fpath=${home_lttp3rootfs_services_ufw_dir}/${enable_ufw_before_login_service_filename}
dst_enable_ufw_before_login_service_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}/${enable_ufw_before_login_service_filename}

src_enable_ufw_before_login_sh_fpath=${home_lttp3rootfs_services_ufw_dir}/${enable_ufw_before_login_sh_filename}
dst_enable_ufw_before_login_sh_fpath=${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}/${enable_ufw_before_login_sh_filename}

src_hostname_fpath=${home_lttp3rootfs_rootfs_initramfs_disk_etc_dir}/${hostname_filename} 
dst_hostname_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}/${hostname_filename} 

src_hosts_fpath=${home_lttp3rootfs_rootfs_initramfs_disk_etc_dir}/${hosts_filename} 
dst_hosts_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}/${hosts_filename} 


echo -e "\r"
echo -e "---------------------------------------------------------------"
echo -e "\tPRE-PREPARATION of DISK for CHROOT"
echo -e "---------------------------------------------------------------"

press_any_key__func
#---Create Download directory (if needed)
if [[ ! -d ${home_downloads_dir} ]]; then
	echo -e "\r"
	echo -e ">Create ${home_downloads_dir}"
	mkdir ${home_downloads_dir}
fi


#---Download armhf-image (if needed)
if [[ ! -f ${armhf_fpath} ]]; then
	#Define url variables
	#Remark:
	#	Change these values if needed
	ubuntu_releases_weblink="http://cdimage.ubuntu.com/cdimage/ubuntu-base/releases"
	ubuntu_version_webfolder="20.04"
	ubuntu_release_webfolder="release"

	#Compose weblink
	ubuntu_download_weblink="${ubuntu_releases_weblink}/"
	ubuntu_download_weblink+="${ubuntu_version_webfolder}/"
	ubuntu_download_weblink+="${ubuntu_release_webfolder}/"
	ubuntu_download_weblink+="${armhf_filename}"

	#Check if weblink exists
	url_isFound=`checkIf_website_exists__func "${ubuntu_download_weblink}"`
	if [[ ${url_isFound} == true ]]; then
		echo -e "\r"
		echo -e ">Navigate to <~/Downloads>"
		cd ${home_downloads_dir}

		echo -e "\r"
		echo -e ">Downloading ${armhf_filename}"
		press_any_key__func
		wget ${ubuntu_download_weblink}
	else
		errmsg_url_does_not_exist="The specified url '${ubuntu_releases_weblink}' does NOT exist.\n"
		errmsg_url_does_not_exist+="Exiting now..."

		echo -e "\r"
		echo -e "${errmsg_url_does_not_exist}"
		echo -e "\r"
	fi
fi


if [[ -d ${home_downloads_disk_dir} ]]; then
	press_any_key__func
	echo -e "\r"
	echo -e ">Removing (OLD): ${disk_foldername}"
	rm -r ${home_downloads_disk_dir}
fi

press_any_key__func
echo -e "\r"
echo -e ">Moving (UBUNTU): ${disk_foldername}"
echo -e ">from: ${SP7xxx_linux_rootfs_initramfs_dir}"
echo -e ">to: ${home_downloads_dir}"
	mv ${SP7xxx_linux_rootfs_initramfs_disk_dir} ${home_downloads_dir}/

press_any_key__func
echo -e "\r"
echo -e ">Navigate to ${home_downloads_dir}"
	cd ${home_downloads_dir}

press_any_key__func
	disk_tspan=$(date +%Y%m%d%H%M%S)
	disk_targz_filename="disk.${disk_tspan}.tar.gz"
echo -e "\r"
echo -e ">Compressing (BACKUP): ${disk_foldername}"
echo -e ">at: ${home_downloads_dir}"
	tar -czvf ${disk_targz_filename} ${disk_foldername}

press_any_key__func
echo -e "\r"
echo -e ">Creating: ${disk_foldername}"
echo -e ">at: ${SP7xxx_linux_rootfs_initramfs_dir}"
	mkdir ${SP7xxx_linux_rootfs_initramfs_disk_dir}

press_any_key__func
echo -e "\r"
echo -e ">Copying: ${armhf_filename}"
echo -e ">from: ${home_downloads_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_dir}"
	cp ${home_downloads_dir}/${armhf_filename} ${SP7xxx_linux_rootfs_initramfs_disk_dir}

press_any_key__func
echo -e "\r"
echo -e ">Navigate to ${SP7xxx_linux_rootfs_initramfs_disk_dir}"
	cd ${SP7xxx_linux_rootfs_initramfs_disk_dir}

press_any_key__func
echo -e "\r"
echo -e ">Extracting: ${armhf_filename}"
	tar -xzvf ${armhf_filename}

press_any_key__func
echo -e "\r"
echo -e ">Removing: ${armhf_filename}"
	rm ${armhf_filename}

press_any_key__func
echo -e "\r"
echo -e ">Navigate to ${home_downloads_disk_lib_dir}"
	cd ${home_downloads_disk_lib_dir}

press_any_key__func
echo -e "\r"
echo -e ">Copying folders (incl. contents): firmware and modules"
echo -e ">from: ${home_downloads_disk_lib_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_dir}"
	cp -R firmware/ ${SP7xxx_linux_rootfs_initramfs_disk_lib_dir}
	cp -R modules/ ${SP7xxx_linux_rootfs_initramfs_disk_lib_dir}

press_any_key__func
echo -e "\r"
echo -e ">Copying: ${qemu_user_static_filename}"
echo -e ">from: ${usr_bin_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_usr_bin_dir}"
	cp ${usr_bin_dir}/${qemu_user_static_filename} ${SP7xxx_linux_rootfs_initramfs_disk_usr_bin_dir}


# press_any_key__func
# #For directory: ~/SP7021/linux/rootfs/initramfs/disk, change ownership to imcase:imcase
# current_user=`whoami`
# if [[ "${current_user}" == "root" ]]; then
# 	read -e -p "Provide name of new owner of <disk> folder: " -i "${current_user}" current_user
# fi
# echo -e "\r"
# echo -e ">Changing ownerschip of folder: ${disk_foldername}"
# echo -e ">in: ${SP7xxx_linux_rootfs_initramfs_dir}"
# echo -e ">to: ${current_user}:${current_user}"
# chown ${current_user}:${current_user} -R ${SP7xxx_linux_rootfs_initramfs_disk_dir}

press_any_key__func
echo -e "\r"
echo -e ">Removing (NEW): ${disk_foldername}"
echo -e ">in: ${home_downloads_dir}"
	rm -rf ${home_downloads_disk_dir}

press_any_key__func
echo -e "\r"
echo -e ">Copying: ${resolve_filename}"
echo -e ">from: ${etc_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}"
echo -e "\r"
echo -e "\r"
	cp ${src_resolve_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}

press_any_key__func
echo -e "\r"
echo -e "---AUTO-MOUNT USB & MMC-SD---"
echo -e "\r"
echo -e ">Checking if directory <${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}> exists?"
if [[ -d ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir} ]]; then
	echo -e "\r"
	echo -e ">>>--does exist"
	echo -e "\r"
	echo -e ">>>>>Checking if file <${usb_mount_service_filename}> exists"
	if [[ -f ${dst_usb_mount_service_fpath} ]]; then
		echo -e ">>>>>--does exist"
		echo -e "\r"
		echo -e ">>>>>>>Removing file <${usb_mount_service_filename}>"
			rm ${dst_usb_mount_service_fpath}
	else
		echo -e ">>>>>--does not exist, continue..."
	fi
else
	echo -e "\r"
	echo -e ">>>--does NOT exist"
	echo -e "\r"
	echo -e ">>>>>Creating directory <${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}>"
		mkdir -p ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}
	
	echo -e "\r"
	echo -e ">>>>>Change ownership to <root> for directory: ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}"
		chown root:root ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}

	echo -e "\r"
	echo -e ">>>>>Change permission to <drwxr-xr-x> for directory: ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}"
		chmod 755 ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}
fi



echo -e "\r"
echo -e ">Copy file <systemd unit service>: ${usb_mount_service_filename}"
echo -e ">from: ${home_lttp3rootfs_services_automount_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}"
	cp ${src_usb_mount_service_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${usb_mount_service_filename}"
	chown root:root ${dst_usb_mount_service_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rw-r--r--> for file: ${usb_mount_service_filename}"
	chmod 644 ${dst_usb_mount_service_fpath}


echo -e "\r"
echo -e ">Copy file <systemd unit service>: ${sd_detect_service_filename}"
echo -e ">from: ${home_lttp3rootfs_services_automount_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}"
	cp ${src_sd_detect_service_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${sd_detect_service_filename}"
	chown root:root ${dst_sd_detect_service_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rw-r--r--> for file: ${sd_detect_service_filename}"
	chmod 644 ${dst_sd_detect_service_fpath}



press_any_key__func
echo -e "\r"
echo -e "\r"
echo -e ">Checking if directory <${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}> exists?"
if [[ -d ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir} ]]; then
	echo -e "\r"
	echo -e ">>>--does exist"
	echo -e "\r"
	echo -e ">>>>>Checking if file <${usb_mount_sh_filename}> exists"
	if [[ -f ${dst_usb_mount_sh_fpath} ]]; then
		echo -e ">>>>>--does exist"
		echo -e "\r"
		echo -e ">>>>>>>Removing file <${usb_mount_sh_filename}>"
			rm ${dst_usb_mount_sh_fpath}
	fi
else
	echo -e "\r"
	echo -e ">>>--does NOT exist"
	echo -e "\r"
	echo -e ">>>>>Creating directory <${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}>"
		mkdir -p ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}

	echo -e "\r"
	echo -e ">>>>>Change ownership to <root> for directory: ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}"
		chown root:root ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}

	echo -e "\r"
	echo -e ">>>>>Change permission to <drwxr-xr-x> for directory: ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}"
		chmod 755 ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}
fi

echo -e "\r"
echo -e ">Copy file: ${usb_mount_sh_filename}"
echo -e ">from: ${home_lttp3rootfs_services_automount_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}"
	cp ${src_usb_mount_sh_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${usb_mount_sh_filename}"
	chown root:root ${dst_usb_mount_sh_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rwxr-xr-x> for file: ${usb_mount_sh_filename}"
	chmod 755 ${dst_usb_mount_sh_fpath}


echo -e "\r"
echo -e ">Copy file: ${sd_detect_add_sh_filename}"
echo -e ">from: ${home_lttp3rootfs_services_automount_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}"
	cp ${src_sd_detect_add_sh_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${sd_detect_add_sh_filename}"
	chown root:root ${dst_sd_detect_add_sh_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rwxr-xr-x> for file: ${sd_detect_add_sh_filename}"
	chmod 755 ${dst_sd_detect_add_sh_fpath}

echo -e "\r"
echo -e ">Copy file: ${sd_detect_remove_sh_filename}"
echo -e ">from: ${home_lttp3rootfs_services_automount_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}"
	cp ${src_sd_detect_remove_sh_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${sd_detect_remove_sh_filename}"
	chown root:root ${dst_sd_detect_remove_sh_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rwxr-xr-x> for file: ${sd_detect_remove_sh_filename}"
	chmod 755 ${dst_sd_detect_remove_sh_fpath}



press_any_key__func
echo -e "\r"
echo -e "\r"
echo -e ">Checking if directory <${SP7xxx_linux_rootfs_initramfs_disk_etc_udev_rulesd_dir}> exists"
if [[ -d ${SP7xxx_linux_rootfs_initramfs_disk_etc_udev_rulesd_dir} ]]; then
	echo -e "\r"
	echo -e ">>>--does exist"
	echo -e "\r"
	echo -e ">>>>>Checking if file <${usb_mount_rules_filename}> exists"
	if [[ -f ${dst_usb_mount_rules_fpath} ]]; then
		echo -e ">>>>>--does exist"
		echo -e "\r"
		echo -e ">>>>>>>Removing file <${usb_mount_rules_filename}>"
			rm ${dst_usb_mount_rules_fpath}
	fi
else
	echo -e "\r"
	echo -e ">>>--does NOT exist"
	echo -e "\r"
	echo -e ">>>>>Creating directory <${SP7xxx_linux_rootfs_initramfs_disk_etc_udev_rulesd_dir}>"
		mkdir -p ${SP7xxx_linux_rootfs_initramfs_disk_etc_udev_rulesd_dir}

	echo -e "\r"
	echo -e ">>>>>Change ownership to <root> for directory: ${SP7xxx_linux_rootfs_initramfs_disk_etc_udev_rulesd_dir}"
		chown root:root ${SP7xxx_linux_rootfs_initramfs_disk_etc_udev_rulesd_dir}

	echo -e "\r"
	echo -e ">>>>>Change permission to <drwxr-xr-x> for directory: ${SP7xxx_linux_rootfs_initramfs_disk_etc_udev_rulesd_dir}"
		chmod 755 ${SP7xxx_linux_rootfs_initramfs_disk_etc_udev_rulesd_dir}
fi

echo -e "\r"
echo -e ">Copy file: ${usb_mount_rules_filename}"
echo -e ">from: ${home_lttp3rootfs_services_automount_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_etc_udev_rulesd_dir}"
	cp ${src_usb_mount_rules_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_etc_udev_rulesd_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${usb_mount_rules_filename}"
	chown root:root ${dst_usb_mount_rules_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rw-r--r--> for file: ${usb_mount_rules_filename}"
	chmod 644 ${dst_usb_mount_rules_fpath}


echo -e "\r"
echo -e ">Copy file: ${sd_detect_rules_filename}"
echo -e ">from: ${home_lttp3rootfs_services_automount_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_etc_udev_rulesd_dir}"
	cp ${src_sd_detect_rules_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_etc_udev_rulesd_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${sd_detect_rules_filename}"
	chown root:root ${dst_sd_detect_rules_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rw-r--r--> for file: ${sd_detect_rules_filename}"
	chmod 644 ${dst_sd_detect_rules_fpath}


press_any_key__func
echo -e "\r"
echo -e "\r"
echo -e ">Checking if directory <${SP7xxx_linux_rootfs_initramfs_disk_var_backups_gpio_dir}> exists"
if [[ -d ${SP7xxx_linux_rootfs_initramfs_disk_var_backups_gpio_dir} ]]; then
	echo -e "\r"
	echo -e ">>>--does exist"
	echo -e "\r"
else
	echo -e "\r"
	echo -e ">>>--does NOT exist"
	echo -e "\r"
	echo -e ">>>>>Creating directory <${SP7xxx_linux_rootfs_initramfs_disk_var_backups_gpio_dir}>"
		mkdir -p ${SP7xxx_linux_rootfs_initramfs_disk_var_backups_gpio_dir}

fi

echo -e "\r"
echo -e ">Copy file: ${gpio_gpio_set_group_rules_filename}"
echo -e ">from: ${home_lttp3rootfs_services_permissions_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_etc_udev_rulesd_dir}"
	cp ${src_gpio_set_group_rules_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_etc_udev_rulesd_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${gpio_gpio_set_group_rules_filename}"
	chown root:root ${dst_gpio_set_group_rules_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rw-r--r--> for file: ${gpio_gpio_set_group_rules_filename}"
	chmod 644 ${dst_gpio_set_group_rules_fpath}


press_any_key__func
echo -e "\r"
echo -e "---Services to run BEFORE login---"
echo -e "\r"

echo -e "\r"
echo -e ">Creating <${scripts_foldername}>"
echo -e ">in: ${SP7xxx_linux_rootfs_initramfs_disk_dir}"
if [[ ! -d ${SP7xxx_linux_rootfs_initramfs_disk_scripts_dir} ]]; then
	mkdir ${SP7xxx_linux_rootfs_initramfs_disk_scripts_dir}
fi

echo -e "\r"
echo -e ">Copying: ${daisychain_state_service_filename}>"
echo -e ">from: ${home_lttp3rootfs_services_network_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}"
	cp ${src_daisychain_state_service_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${daisychain_state_service_filename}"
	chown root:root ${dst_daisychain_state_service_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rwxr-xr-x> for file: ${daisychain_state_service_filename}"
	chmod 644 ${dst_daisychain_state_service_fpath}

echo -e "\r"
echo -e ">Copying: ${daisychain_state_sh_filename}>"
echo -e ">from: ${home_lttp3rootfs_services_network_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}"
	cp ${src_daisychain_state_sh_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${daisychain_state_sh_filename}"
	chown root:root ${dst_daisychain_state_sh_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rwxr-xr-x> for file: ${daisychain_state_sh_filename}"
	chmod 755 ${dst_daisychain_state_sh_fpath}

echo -e "\r"
echo -e ">Copying: ${enable_eth1_before_login_service_filename}>"
echo -e ">from: ${home_lttp3rootfs_services_network_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}"
	cp ${src_enable_eth1_before_login_service_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${enable_eth1_before_login_service_filename}"
	chown root:root ${dst_enable_eth1_before_login_service_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rwxr-xr-x> for file: ${enable_eth1_before_login_service_filename}"
	chmod 644 ${dst_enable_eth1_before_login_service_fpath}

echo -e "\r"
echo -e ">Copying: ${enable_eth1_before_login_sh_filename}>"
echo -e ">from: ${home_lttp3rootfs_services_network_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}"
	cp ${src_enable_eth1_before_login_sh_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${enable_eth1_before_login_sh_filename}"
	chown root:root ${dst_enable_eth1_before_login_sh_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rwxr-xr-x> for file: ${enable_eth1_before_login_sh_filename}"
	chmod 755 ${dst_enable_eth1_before_login_sh_fpath}



echo -e "\r"
echo -e ">Copying: ${create_chown_pwm_service_filename}>"
echo -e ">from: ${home_lttp3rootfs_services_pwm_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}"
	cp ${src_create_chown_pwm_service_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${create_chown_pwm_service_filename}"
	chown root:root ${dst_create_chown_pwm_service_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rwxr-xr-x> for file: ${create_chown_pwm_service_filename}"
	chmod 644 ${dst_create_chown_pwm_service_fpath}

echo -e "\r"
echo -e ">Copying: ${create_chown_pwm_sh_filename}>"
echo -e ">from: ${home_lttp3rootfs_services_pwm_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}"
	cp ${src_create_chown_pwm_sh_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${create_chown_pwm_sh_filename}"
	chown root:root ${dst_create_chown_pwm_sh_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rwxr-xr-x> for file: ${create_chown_pwm_sh_filename}"
	chmod 755 ${dst_create_chown_pwm_sh_fpath}



echo -e "\r"
echo -e ">Copying: ${one_time_exec_sh_filename}"
echo -e ">from: ${home_lttp3rootfs_services_oobe_oneshot_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_scripts_dir}"
	cp ${src_one_time_exec_sh_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_scripts_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${one_time_exec_sh_filename}"
	chown root:root ${dst_one_time_exec_sh_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rwxr-xr-x> for file: ${one_time_exec_sh_filename}"
	chmod 755 ${dst_one_time_exec_sh_fpath}

echo -e "\r"
echo -e ">Copying: ${one_time_exec_before_login_service_filename}>"
echo -e ">from: ${home_lttp3rootfs_services_oobe_oneshot_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}"
	cp ${src_one_time_exec_before_login_service_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${one_time_exec_before_login_service_filename}"
	chown root:root ${dst_one_time_exec_before_login_service_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rw-r--r--> for file: ${one_time_exec_before_login_service_filename}"
	chmod 644 ${dst_one_time_exec_before_login_service_fpath}

echo -e "\r"
echo -e ">Copying: ${one_time_exec_before_login_sh_filename}>"
echo -e ">from: ${home_lttp3rootfs_services_oobe_oneshot_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}"
	cp ${src_one_time_exec_before_login_sh_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${one_time_exec_before_login_sh_filename}"
	chown root:root ${dst_one_time_exec_before_login_sh_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rwxr-xr-x> for file: ${one_time_exec_before_login_sh_filename}"
	chmod 755 ${dst_one_time_exec_before_login_sh_fpath}

echo -e "\r"
echo -e ">Copying: ${enable_ufw_before_login_service_filename}>"
echo -e ">from: ${home_lttp3rootfs_services_ufw_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}"
	cp ${src_enable_ufw_before_login_service_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${enable_ufw_before_login_service_filename}"
	chown root:root ${dst_enable_ufw_before_login_service_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rw-r--r--> for file: ${enable_ufw_before_login_service_filename}"
	chmod 644 ${dst_enable_ufw_before_login_service_fpath}

echo -e "\r"
echo -e ">Copying: ${enable_ufw_before_login_sh_filename}"
echo -e ">from: ${home_lttp3rootfs_services_ufw_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}"
	cp ${src_enable_ufw_before_login_sh_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${enable_ufw_before_login_sh_filename}"
	chown root:root ${dst_enable_ufw_before_login_sh_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rwxr-xr-x> for file: ${enable_ufw_before_login_sh_filename}"
	chmod 755 ${dst_enable_ufw_before_login_sh_fpath}


#---HOSTNAME/HOSTS
press_any_key__func
echo -e "\r"
echo -e ">Copying: ${hostname_filename}"
echo -e ">from: ${home_lttp3rootfs_rootfs_initramfs_disk_etc_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}"
	cp ${src_hostname_fpath} ${dst_hostname_fpath}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${hostname_filename}"
	chown root:root ${dst_hostname_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rw-r--r--> for file: ${hostname_filename}"
	chmod 644 ${dst_hostname_fpath}


echo -e "\r"
echo -e ">Copying: ${hosts_filename}"
echo -e ">from: ${home_lttp3rootfs_rootfs_initramfs_disk_etc_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}"
	cp ${src_hosts_fpath} ${dst_hosts_fpath}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${hosts_filename}"
	chown root:root ${dst_hosts_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rw-r--r--> for file: ${hosts_filename}"
	chmod 644 ${dst_hosts_fpath}


#---FIRMWARE FOLDER
press_any_key__func
echo -e "\r"
echo -e ">Copying: ${firmware_foldername}"
echo -e ">from: ${home_lttp3rootfs_rootfs_initramfs_disk_etc_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}"
	cp -rf ${src_firmware_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for folder: ${firmware_foldername}"
	chown -R root:root ${dst_firmware_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rw-r--r--> for folder: ${firmware_foldername}"
	chmod -R 644 ${dst_firmware_fpath}


#---FILE: clk-sp-q628.c
press_any_key__func
echo -e "\r"
echo -e ">Copying: ${clkspq628c_filename}"
echo -e ">from: ${home_lttp3rootfs_kernel_drivers_clk_dir}"
echo -e ">to: ${SP7xxx_linux_kernel_drivers_clk}"
	cp ${src_clkspq628c_fpath} ${SP7xxx_linux_kernel_drivers_clk}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${clkspq628c_filename}"
	chown root:root ${dst_clkspq628c_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rwxr-xr-x> for file: ${clkspq628c_filename}"
	chmod 755 ${dst_clkspq628c_fpath}


#---FILE: brcm_patchram_plus
press_any_key__func
echo -e "\r"
echo -e ">Copying: ${brcm_patchram_plus_filename}"
echo -e ">from: ${home_lttp3rootfs_usr_bin_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_usr_bin_dir}"
	cp ${src_brcm_patchram_plus_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_usr_bin_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${brcm_patchram_plus_filename}"
	chown root:root ${dst_brcm_patchram_plus_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rwxr-xr-x> for file: ${brcm_patchram_plus_filename}"
	chmod 755 ${dst_brcm_patchram_plus_fpath}


#---KERNEL: MAKE MENUCONFIG
press_any_key__func
echo -e "\r"
echo -e "---Kernel Configuration File"
echo -e ">Copying: ${make_menuconfig_filename}"
echo -e ">from: ${home_lttp3rootfs_kernel_makeconfig_dir}"
echo -e ">to: ${SP7xxx_linux_kernel_dir}"
echo -e ">as: ${make_menuconfig_default_filename}"
echo -e "\r"
echo -e "\r"
	cp ${src_make_menuconfig_fpath} ${dst_make_menuconfig_fpath}

press_any_key__func
echo -e "\r"
echo -e ">>>Navigate to ${SP7xxx_linux_kernel_dir}"
	cd ${SP7xxx_linux_kernel_dir}

press_any_key__func
echo -e "\r"
echo -e ">>>>>Importing Kernel config-file: ${make_menuconfig_default_filename}"
echo -e ">from: ${SP7xxx_linux_kernel_dir}"
	make olddefconfig
echo -e "\r"
echo -e "\r"

#---DTSI
press_any_key__func
echo -e "\r"
echo -e "---UART config file"
echo -e ">Copying: ${sp7021_ltpp3g2revD_filename}>"
echo -e ">from: ${home_lttp3rootfs_kernel_dts_uart_dir}"
echo -e ">to: ${SP7xxx_linux_kernel_arch_arm_boot_dts_dir}"
	cp ${src_sp7021_ltpp3g2revD_fpath} ${SP7xxx_linux_kernel_arch_arm_boot_dts_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${sp7021_ltpp3g2revD_filename}"
	chown root:root ${dst_sp7021_ltpp3g2revD_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rw-r--r--> for file: ${sp7021_ltpp3g2revD_filename}"
	chmod 644 ${dst_sp7021_ltpp3g2revD_fpath}



###FIX error messages:
#	WARN:	uid is 0 but '/etc' is owned by 1000
echo -e "\r"
echo -e ">chown root:root ${etc_dir}"
echo -e ">in: ${SP7xxx_linux_rootfs_initramfs_extra_dir}"
	chown root:root ${SP7xxx_linux_rootfs_initramfs_extra_etc_dir}


###FIX error messages:
#	WARN:	owner has write permission for '/etc' folder
echo -e "\r"
echo -e ">Change permission of folder: ${etc_dir}"
echo -e ">in: ${SP7xxx_linux_rootfs_initramfs_extra_dir}"
echo -e ">to: drwxr-xr-x"
	chmod 755 ${SP7xxx_linux_rootfs_initramfs_extra_etc_dir}


press_any_key__func
echo -e "\r"
echo -e ">Backup '${build_disk_filename}' by renaming" 
echo -e ">to: ${build_disk_bck_filename}"
echo -e ">in: ${SP7xxx_linux_rootfs_initramfs_dir}"
echo -e "\r"
mv ${build_disk_fpath} ${build_disk_bck_fpath}



#Copy modified file to location: ~/SP7021/linux/rootfs/initramfs
press_any_key__func
echo -e "\r"
echo -e ">Copying ${build_disk_mod_filename}" 
echo -e ">as: ${build_disk_filename}"
echo -e ">from: ${home_lttp3rootfs_rootfs_initramfs_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_dir}"
echo -e "\r"
cp ${build_disk_mod_fpath}  ${build_disk_fpath}


#Make file "build_disk.sh" executable
press_any_key__func
echo -e "\r"
echo -e ">Changing permission of ${build_disk_filename}"
echo -e ">in: ${SP7xxx_linux_rootfs_initramfs_dir}"
echo -e ">to: -rwxr-xr-x"
echo -e "\r"
chmod +x ${build_disk_fpath}

