#!/bin/bash
#---Local Functions
press_any_key__func() {
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



#---Define path variables
press_any_key__func
echo -e "\r"
echo -e "---Define Environmental Variables---"
echo -e "\r"

sp7021_ltpp3g2revD_filename="sp7021-ltpp3g2revD.dtsi"

home_dir=~	#this is the /root directory
etc_dir=/etc
usr_bin_dir=/usr/bin
home_downloads_dir=${home_dir}/Downloads
home_downloads_disk_dir=${home_downloads_dir}/${disk_foldername}
home_downloads_disk_lib_dir=${home_downloads_dir}/disk/lib

scripts_foldername="scripts"
scripts_dir=/${scripts_foldername}
home_lttp3rootfs_dir=${home_dir}/LTPP3_ROOTFS
home_lttp3rootfs_services_automount_dir=${home_lttp3rootfs_dir}/services/automount
home_lttp3rootfs_services_oobe_resize2fs_dir=${home_lttp3rootfs_dir}/services/oobe/resize2fs
home_lttp3rootfs_services_network_dir=${home_lttp3rootfs_dir}/services/network
home_lttp3rootfs_services_ufw_dir=${home_lttp3rootfs_dir}/services/ufw
home_lttp3rootfs_kernel_dir=${home_lttp3rootfs_dir}/kernel
home_lttp3rootfs_kernel_dts_dir=${home_lttp3rootfs_kernel_dir}/dts
home_lttp3rootfs_kernel_dts_uart_dir=${home_lttp3rootfs_kernel_dts_dir}/uart
SP7xxx_dir=${home_dir}/SP7021
SP7xxx_linux_kernel_dir=${SP7xxx_dir}/linux/kernel
SP7xxx_linux_kernel_arch_arm_boot_dts_dir=${SP7xxx_linux_kernel_dir}/arch/arm/boot/dts
SP7xxx_linux_rootfs_initramfs_dir=${SP7xxx_dir}/linux/rootfs/initramfs
SP7xxx_linux_rootfs_initramfs_disk_dir=${SP7xxx_linux_rootfs_initramfs_dir}/${disk_foldername}
SP7xxx_linux_rootfs_initramfs_disk_etc_dir=${SP7xxx_linux_rootfs_initramfs_disk_dir}/etc
SP7xxx_linux_rootfs_initramfs_disk_lib_dir=${SP7xxx_linux_rootfs_initramfs_disk_dir}/lib
SP7xxx_linux_rootfs_initramfs_disk_usr_bin_dir=${SP7xxx_linux_rootfs_initramfs_disk_dir}/usr/bin

SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir=${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}/systemd/system
SP7xxx_linux_rootfs_initramfs_disk_etc_udev_rulesd_dir=${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}/udev/rules.d
SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir=${SP7xxx_linux_rootfs_initramfs_disk_dir}/usr/local/bin
SP7xxx_linux_rootfs_initramfs_disk_scripts_dir=${SP7xxx_linux_rootfs_initramfs_disk_dir}/scripts
# daisychain_dir=/sys/devices/platform/soc\@B/9c108000.l2sw

SP7xxx_linux_rootfs_initramfs_extra_dir=${SP7xxx_linux_rootfs_initramfs_dir}/extra
SP7xxx_linux_rootfs_initramfs_extra_etc_dir=${SP7xxx_linux_rootfs_initramfs_extra_dir}${etc_dir}

src_sp7021_ltpp3g2revD_fpath=${home_lttp3rootfs_kernel_dts_uart_dir}/${sp7021_ltpp3g2revD_filename}
dst_sp7021_ltpp3g2revD_fpath=${SP7xxx_linux_kernel_arch_arm_boot_dts_dir}/${sp7021_ltpp3g2revD_filename}


echo -e "\r"
echo -e "---------------------------------------------------------------"
echo -e "\tADDITIONAL PREPARATION of DISK for CHROOT"
echo -e "---------------------------------------------------------------"

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
