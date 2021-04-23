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
usr_bin_dir=/usr/bin

scripts_foldername="scripts"
scripts_dir=/${scripts_foldername}
home_LTPP3_ROOTFS_dir=${home_dir}/LTPP3_ROOTFS
home_LTPP3_ROOTFS_preferences_dir=${home_LTPP3_ROOTFS_dir}/preferences
home_LTPP3_ROOTFS_preferences_dts_dir=${home_LTPP3_ROOTFS_preferences_dir}/dts
SP7xxx_dir=${home_dir}/SP7021
SP7xxx_linux_kernel_dir=${SP7xxx_dir}/linux/kernel
SP7xxx_linux_kernel_arch_arm_boot_dts_dir=${SP7xxx_linux_kernel_dir}/arch/arm/boot/dts

src_sp7021_ltpp3g2revD_fpath=${home_LTPP3_ROOTFS_preferences_dts_dir}/${sp7021_ltpp3g2revD_filename}
dst_sp7021_ltpp3g2revD_fpath=${SP7xxx_linux_kernel_arch_arm_boot_dts_dir}/${sp7021_ltpp3g2revD_filename}


echo -e "\r"
echo -e "---------------------------------------------------------------"
echo -e "\tADDITIONAL PREPARATION of DISK for CHROOT"
echo -e "---------------------------------------------------------------"

press_any_key__func
echo -e "\r"
echo -e "---MY PREFERENCES: Disabled UART2, UART3---"
echo -e ">Copying: ${sp7021_ltpp3g2revD_filename}>"
echo -e ">from: ${home_LTPP3_ROOTFS_preferences_dts_dir}"
echo -e ">to: ${SP7xxx_linux_kernel_arch_arm_boot_dts_dir}"
	cp ${src_sp7021_ltpp3g2revD_fpath} ${SP7xxx_linux_kernel_arch_arm_boot_dts_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${sp7021_ltpp3g2revD_filename}"
	chown root:root ${dst_sp7021_ltpp3g2revD_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rw-r--r--> for file: ${sp7021_ltpp3g2revD_filename}"
	chmod 644 ${dst_sp7021_ltpp3g2revD_fpath}
