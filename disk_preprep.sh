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

bcmdhd_foldername="bcmdhd"
sunplus_foldername="SP7021"
tpd_foldername="tpd"



armhf_filename="ubuntu-base-20.04.1-base-armhf.tar.gz"
brcm_patchram_plus_filename="brcm_patchram_plus"
bcmdhd_targz_filename="bcmdhd.tar.gz"
build_disk_filename="build_disk.sh"
build_disk_bck_filename=${build_disk_filename}.bak
build_disk_mod_filename=${build_disk_filename}.mod
chroot_exec_cmd_inside_chroot_filename="chroot_exec_cmd_inside_chroot.sh"
#clkspq628c_filename="clk-sp-q628.c"# daisychain_mode_filename="mode"
create_chown_pwm_service_filename="create-chown-pwm.service"
create_chown_pwm_sh_filename="create-chown-pwm.sh"
daisychain_state_service_filename="daisychain_state.service"
daisychain_state_sh_filename="daisychain_state.sh"
disk_foldername="disk"
ehci_sched_c_filename="ehci-sched.c"
ehci_sched_c_patch_filename="ehci-sched.c.patch"
enable_eth1_before_login_service_filename="enable-eth1-before-login.service"
enable_eth1_before_login_sh_filename="enable-eth1-before-login.sh"
enable_ufw_before_login_service_filename="enable-ufw-before-login.service"
enable_ufw_before_login_sh_filename="enable-ufw-before-login.sh"
firmware_foldername="firmware"
gpio_gpio_set_group_rules_filename="gpio-set_group.rules"
hostname_filename="hostname"
hosts_filename="hosts"
ispboootbin_version_txt_filename="ispboootbin_version.txt"
irq_sp7021_intc_c_filename="irq-sp7021-intc.c"
irq_sp7021_intc_c_patch_filename="irq-sp7021-intc.c.patch"
isp_c_filename="isp.c"
isp_c_patch_filename="isp.c.patch"
Kconfig_filename="Kconfig"
Kconfig_patch_filename="Kconfig.patch"
makefile_filename="Makefile"
makefile_patch_filename="Makefile.patch"
make_menuconfig_filename="armhf_kernel.config"
make_menuconfig_default_filename=".config"
media_sync_sh_filename="media_sync.sh"
media_sync_service_filename="media_sync.service"
media_sync_timer_filename="media_sync.timer"
modules_filename="modules"
ninetynine_wlan_notice_filename="99-wlan-notice"
ntios_su_add_filename="ntios-su-add"
ntios_su_addasperand_filename="${ntios_su_add_filename}@"
ntios_su_add_monitor_filename="${ntios_su_add_filename}-monitor"
ntios_su_add_sh_filename="${ntios_su_add_filename}.sh"
ntios_su_addasperand_service_filename="${ntios_su_addasperand_filename}.service"
ntios_su_add_monitor_service_filename="${ntios_su_add_monitor_filename}.service"
ntios_su_add_monitor_sh_filename="${ntios_su_add_monitor_filename}.sh"
ntios_su_add_monitor_timer_filename="${ntios_su_add_monitor_filename}.timer"
one_time_exec_sh_filename="one-time-exec.sh"
one_time_exec_before_login_sh_filename="one-time-exec-before-login.sh"
one_time_exec_before_login_service_filename="one-time-exec-before-login.service"
pentagram_common_h_filename="pentagram_common.h"
pentagram_common_h_patch_filename="pentagram_common.h.patch"
profile_filename="profile"
qemu_user_static_filename="qemu-arm-static"
resolve_filename="resolv.conf"
scripts_foldername="scripts"
sd_detect_rules_filename="sd-detect.rules"
sd_detect_service_filename="sd-detect@.service"
sd_detect_add_sh_filename="sd-detect-add.sh"
sd_detect_remove_sh_filename="sd-detect-remove.sh"
sp_go_c_filename="sp_go.c"
sp_go_c_patch_filename="sp_go.c.patch"
sp_ocotp_c_filename="sp-ocotp.c"
sp_ocotp_c_patch_filename="sp-ocotp.c.patch"
sp7021_ltpp3g2revD_dtsi_filename="sp7021-ltpp3g2revD.dtsi"
sp7021_ltpp3g2revD_dtsi_patch_filename="sp7021-ltpp3g2revD.dtsi.patch"
sp7021_common_dtsi_filename="sp7021-common.dtsi"
sp7021_common_dtsi_patch_filename="sp7021-common.dtsi.patch"
sppctl_gpio_c_filename="sppctl_gpio.c"
sppctl_gpio_c_patch_filename="sppctl_gpio.c.patch"
sppctl_gpio_ops_c_filename="sppctl_gpio_ops.c"
sppctl_gpio_ops_c_patch_filename="sppctl_gpio_ops.c.patch"
sppctl_gpio_ops_h_filename="sppctl_gpio_ops.h"
sppctl_gpio_ops_h_patch_filename="sppctl_gpio_ops.h.patch"
sunplus_icm_c_filename="sunplus_icm.c"
sunplus_icm_c_patch_filename="sunplus_icm.c.patch"
sunplus_uart_c_filename="sunplus-uart.c"
sunplus_uart_c_patch_filename="sunplus-uart.c.patch"
usb_mount_rules_filename="usb-mount.rules"
usb_mount_service_filename="usb-mount@.service"
usb_mount_sh_filename="usb-mount.sh"



home_dir=~	#this is the /root directory
bin_dir=/bin
# daisychain_dir=/sys/devices/platform/soc\@B/9c108000.l2sw
etc_dir=/etc
tmp_dir=/tmp
usr_bin_dir=/usr/bin
home_downloads_dir=${home_dir}/Downloads
home_downloads_disk_dir=${home_downloads_dir}/${disk_foldername}
home_downloads_disk_lib_dir=${home_downloads_dir}/disk/lib

scripts_dir=/${scripts_foldername}
home_lttp3rootfs_dir=${home_dir}/LTPP3_ROOTFS
home_lttp3rootfs_boot_configs_dir=${home_lttp3rootfs_dir}/boot/configs
home_lttp3rootfs_boot_drivers_dir=${home_lttp3rootfs_dir}/boot/drivers
home_lttp3rootfs_build_drivers_dir=${home_lttp3rootfs_dir}/build/drivers
home_lttp3rootfs_docker_version_dir=${home_lttp3rootfs_dir}/docker/version
home_lttp3rootfs_motd_update_motd_d_dir=${home_lttp3rootfs_dir}/motd/update-motd.d
home_lttp3rootfs_rootfs_initramfs_dir=${home_lttp3rootfs_dir}/rootfs/initramfs
home_lttp3rootfs_rootfs_initramfs_disk_etc_dir=${home_lttp3rootfs_rootfs_initramfs_dir}/disk/etc
home_lttp3rootfs_services_automount_dir=${home_lttp3rootfs_dir}/services/automount
home_lttp3rootfs_services_oobe_oneshot_dir=${home_lttp3rootfs_dir}/services/oobe/oneshot
home_lttp3rootfs_services_network_dir=${home_lttp3rootfs_dir}/services/network
home_lttp3rootfs_services_pwm_dir=${home_lttp3rootfs_dir}/services/pwm
home_lttp3rootfs_services_ufw_dir=${home_lttp3rootfs_dir}/services/ufw
home_lttp3rootfs_services_permissions_dir=${home_lttp3rootfs_dir}/services/permissions
home_lttp3rootfs_services_sync_dir=${home_lttp3rootfs_dir}/services/sync
home_lttp3rootfs_services_sudo_dir=${home_lttp3rootfs_dir}/services/sudo
home_lttp3rootfs_kernel_dir=${home_lttp3rootfs_dir}/kernel
home_lttp3rootfs_kernel_drivers_dir=${home_lttp3rootfs_kernel_dir}/drivers
home_lttp3rootfs_kernel_drivers_tpd_dir=${home_lttp3rootfs_kernel_drivers_dir}/${tpd_foldername}
home_lttp3rootfs_kernel_makeconfig_dir=${home_lttp3rootfs_kernel_dir}/makeconfig
# home_lttp3rootfs_kernel_drivers_clk_dir=${home_lttp3rootfs_kernel_dir}/drivers/clk
home_lttp3rootfs_kernel_drivers_usb_host_dir=${home_lttp3rootfs_kernel_dir}/drivers/usb/host
home_lttp3rootfs_kernel_drivers_irqchip_dir=${home_lttp3rootfs_kernel_dir}/drivers/irqchip
home_lttp3rootfs_kernel_drivers_misc_dir=${home_lttp3rootfs_kernel_dir}/drivers/misc
home_lttp3rootfs_kernel_drivers_nvnmem_dir=${home_lttp3rootfs_kernel_dir}/drivers/nvmem
home_lttp3rootfs_kernel_drivers_pinctrl_sunplus_dir=${home_lttp3rootfs_kernel_dir}/drivers/pinctrl/sunplus
home_lttp3rootfs_kernel_drivers_serial_dir=${home_lttp3rootfs_kernel_dir}/drivers/serial
home_lttp3rootfs_kernel_drivers_wifi_dir=${home_lttp3rootfs_kernel_dir}/drivers/wifi
home_lttp3rootfs_kernel_dts_dir=${home_lttp3rootfs_kernel_dir}/dts
home_lttp3rootfs_kernel_modules_load_d_dir=${home_lttp3rootfs_kernel_dir}/modules-load.d
home_lttp3rootfs_usr_bin_dir=${home_lttp3rootfs_dir}/usr/bin
SP7xxx_dir=${home_dir}/SP7021
SP7xxx_boot_uboot_include_configs_dir=${SP7xxx_dir}/boot/uboot/include/configs
SP7xxx_boot_uboot_board_sunplus_pentagram_board_dir=${SP7xxx_dir}/boot/uboot/board/sunplus/pentagram_board
SP7xxx_build_tools_isp_dir=${SP7xxx_dir}/build/tools/isp
SP7xxx_linux_kernel_dir=${SP7xxx_dir}/linux/kernel
SP7xxx_linux_kernel_arch_arm_boot_dts_dir=${SP7xxx_linux_kernel_dir}/arch/arm/boot/dts
# SP7xxx_linux_kernel_drivers_clk_dir=${SP7xxx_linux_kernel_dir}/drivers/clk
SP7xxx_linux_kernel_drivers_dir=${SP7xxx_linux_kernel_dir}/drivers
SP7xxx_linux_kernel_drivers_tpd_dir=${SP7xxx_linux_kernel_drivers_dir}/${tpd_foldername}
SP7xxx_linux_kernel_drivers_usb_host_dir=${SP7xxx_linux_kernel_dir}/drivers/usb/host
SP7xxx_linux_kernel_drivers_irqchip_dir=${SP7xxx_linux_kernel_dir}/drivers/irqchip
SP7xxx_linux_kernel_drivers_misc_dir=${SP7xxx_linux_kernel_dir}/drivers/misc
SP7xxx_linux_kernel_drivers_net_wireless_dir=${SP7xxx_linux_kernel_dir}/drivers/net/wireless
SP7xxx_linux_kernel_drivers_net_wireless_bcmdhd_dir=${SP7xxx_linux_kernel_drivers_net_wireless_dir}/${bcmdhd_foldername}
SP7xxx_linux_kernel_drivers_nvmem_dir=${SP7xxx_linux_kernel_dir}/drivers/nvmem
SP7xxx_linux_kernel_drivers_pinctrl_sunplus_dir=${SP7xxx_linux_kernel_dir}/drivers/pinctrl/sunplus
SP7xxx_linux_kernel_drivers_tty_serial_dir=${SP7xxx_linux_kernel_dir}/drivers/tty/serial
SP7xxx_linux_rootfs_initramfs_dir=${SP7xxx_dir}/linux/rootfs/initramfs
SP7xxx_linux_rootfs_initramfs_disk_dir=${SP7xxx_linux_rootfs_initramfs_dir}/${disk_foldername}
SP7xxx_linux_rootfs_initramfs_disk_etc_dir=${SP7xxx_linux_rootfs_initramfs_disk_dir}/etc
SP7xxx_linux_rootfs_initramfs_disk_lib_dir=${SP7xxx_linux_rootfs_initramfs_disk_dir}/lib
SP7xxx_linux_rootfs_initramfs_disk_etc_update_motd_d_dir=${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}/update-motd.d
SP7xxx_linux_rootfs_initramfs_disk_usr_bin_dir=${SP7xxx_linux_rootfs_initramfs_disk_dir}/usr/bin
SP7xxx_linux_rootfs_initramfs_disk_var_backups_gpio_dir=${SP7xxx_linux_rootfs_initramfs_disk_dir}/var/backups/gpio
SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir=${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}/systemd/system
SP7xxx_linux_rootfs_initramfs_disk_etc_tibbo_version_dir=${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}/tibbo/version
SP7xxx_linux_rootfs_initramfs_disk_etc_tibbo_sudo_dir=${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}/tibbo/sudo
SP7xxx_linux_rootfs_initramfs_disk_etc_udev_rulesd_dir=${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}/udev/rules.d
SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir=${SP7xxx_linux_rootfs_initramfs_disk_dir}/usr/local/bin
SP7xxx_linux_rootfs_initramfs_disk_scripts_dir=${SP7xxx_linux_rootfs_initramfs_disk_dir}/scripts
SP7xxx_linux_rootfs_initramfs_extra_dir=${SP7xxx_linux_rootfs_initramfs_dir}/extra
SP7xxx_linux_rootfs_initramfs_extra_etc_dir=${SP7xxx_linux_rootfs_initramfs_extra_dir}${etc_dir}

armhf_fpath=${home_downloads_dir}/${armhf_filename}
bin_systemctl_fpath=${bin_dir}/systemctl
build_disk_fpath=${SP7xxx_linux_rootfs_initramfs_dir}/${build_disk_filename}
build_disk_bck_fpath=${SP7xxx_linux_rootfs_initramfs_dir}/${build_disk_bck_filename} 
build_disk_mod_fpath=${home_lttp3rootfs_rootfs_initramfs_dir}/${build_disk_mod_filename} 
disk_etc_profile_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}/${profile_filename}
src_resolve_fpath=${etc_dir}/${resolve_filename}

src_brcm_patchram_plus_fpath=${home_lttp3rootfs_usr_bin_dir}/${brcm_patchram_plus_filename}
dst_brcm_patchram_plus_fpath=${SP7xxx_linux_rootfs_initramfs_disk_usr_bin_dir}/${brcm_patchram_plus_filename}

src_brcmhd_targz_fpath=${home_lttp3rootfs_kernel_drivers_wifi_dir}/${bcmdhd_targz_filename}
dst_brcmhd_targz_fpath=${SP7xxx_linux_kernel_drivers_net_wireless_dir}/${bcmdhd_targz_filename}

#src_clkspq628c_fpath=${home_lttp3rootfs_kernel_drivers_clk_dir}/${clkspq628c_filename}
#dst_clkspq628c_fpath=${SP7xxx_linux_kernel_drivers_clk_dir}/${clkspq628c_filename}

src_create_chown_pwm_service_fpath=${home_lttp3rootfs_services_pwm_dir}/${create_chown_pwm_service_filename}
dst_create_chown_pwm_service_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}/${create_chown_pwm_service_filename}

src_create_chown_pwm_sh_fpath=${home_lttp3rootfs_services_pwm_dir}/${create_chown_pwm_sh_filename}
dst_create_chown_pwm_sh_fpath=${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}/${create_chown_pwm_sh_filename}

src_daisychain_state_service_fpath=${home_lttp3rootfs_services_network_dir}/${daisychain_state_service_filename}
dst_daisychain_state_service_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}/${daisychain_state_service_filename}

src_daisychain_state_sh_fpath=${home_lttp3rootfs_services_network_dir}/${daisychain_state_sh_filename}
dst_daisychain_state_sh_fpath=${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}/${daisychain_state_sh_filename}

src_enable_eth1_before_login_service_fpath=${home_lttp3rootfs_services_network_dir}/${enable_eth1_before_login_service_filename}
dst_enable_eth1_before_login_service_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}/${enable_eth1_before_login_service_filename}

src_enable_eth1_before_login_sh_fpath=${home_lttp3rootfs_services_network_dir}/${enable_eth1_before_login_sh_filename}
dst_enable_eth1_before_login_sh_fpath=${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}/${enable_eth1_before_login_sh_filename}

src_enable_ufw_before_login_service_fpath=${home_lttp3rootfs_services_ufw_dir}/${enable_ufw_before_login_service_filename}
dst_enable_ufw_before_login_service_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}/${enable_ufw_before_login_service_filename}

src_enable_ufw_before_login_sh_fpath=${home_lttp3rootfs_services_ufw_dir}/${enable_ufw_before_login_sh_filename}
dst_enable_ufw_before_login_sh_fpath=${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}/${enable_ufw_before_login_sh_filename}

src_firmware_fpath=${home_lttp3rootfs_rootfs_initramfs_disk_etc_dir}/${firmware_foldername}
dst_firmware_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}/${firmware_foldername}

src_gpio_set_group_rules_fpath=${home_lttp3rootfs_services_permissions_dir}/${gpio_gpio_set_group_rules_filename}
dst_gpio_set_group_rules_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_udev_rulesd_dir}/${gpio_gpio_set_group_rules_filename}

src_hostname_fpath=${home_lttp3rootfs_rootfs_initramfs_disk_etc_dir}/${hostname_filename}
dst_hostname_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}/${hostname_filename}

src_hosts_fpath=${home_lttp3rootfs_rootfs_initramfs_disk_etc_dir}/${hosts_filename}
dst_hosts_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}/${hosts_filename}

src_ispboootbin_version_txt_fpath=${home_lttp3rootfs_docker_version_dir}/${ispboootbin_version_txt_filename}
dst_ispboootbin_version_txt_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_tibbo_version_dir}/${ispboootbin_version_txt_filename}

src_make_menuconfig_fpath=${home_lttp3rootfs_kernel_makeconfig_dir}/${make_menuconfig_filename}
dst_make_menuconfig_fpath=${SP7xxx_linux_kernel_dir}/${make_menuconfig_default_filename}

src_media_sync_sh_fpath=${home_lttp3rootfs_services_sync_dir}/${media_sync_sh_filename}
dst_media_sync_sh_fpath=${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}/${media_sync_sh_filename}

src_media_sync_service_fpath=${home_lttp3rootfs_services_sync_dir}/${media_sync_service_filename}
dst_media_sync_service_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}/${media_sync_service_filename}

src_media_sync_timer_fpath=${home_lttp3rootfs_services_sync_dir}/${media_sync_timer_filename}
dst_media_sync_timer_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}/${media_sync_timer_filename}

src_modules_fpath=${home_lttp3rootfs_kernel_modules_load_d_dir}/${modules_filename}
dst_modules_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}/${modules_filename}

src_ninetynine_wlan_notice_fpath=${home_lttp3rootfs_motd_update_motd_d_dir}/${ninetynine_wlan_notice_filename}
dst_ninetynine_wlan_notice_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_update_motd_d_dir}/${ninetynine_wlan_notice_filename}

src_ntios_su_add_sh_fpath=${home_lttp3rootfs_services_sudo_dir}/${ntios_su_add_sh_filename}
dst_ntios_su_add_sh_fpath=${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}/${ntios_su_add_sh_filename}

src_ntios_su_addasperand_service_fpath=${home_lttp3rootfs_services_sudo_dir}/${ntios_su_addasperand_service_filename}
dst_ntios_su_addasperand_service_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}/${ntios_su_addasperand_service_filename}

src_ntios_su_add_monitor_service_fpath=${home_lttp3rootfs_services_sudo_dir}/${ntios_su_add_monitor_service_filename}
dst_ntios_su_add_monitor_service_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}/${ntios_su_add_monitor_service_filename}

src_ntios_su_add_monitor_sh_fpath=${home_lttp3rootfs_services_sudo_dir}/${ntios_su_add_monitor_sh_filename}
dst_ntios_su_add_monitor_sh_fpath=${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}/${ntios_su_add_monitor_sh_filename}

src_ntios_su_add_monitor_timer_fpath=${home_lttp3rootfs_services_sudo_dir}/${ntios_su_add_monitor_timer_filename}
dst_ntios_su_add_monitor_timer_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}/${ntios_su_add_monitor_timer_filename}

src_one_time_exec_sh_fpath=${home_lttp3rootfs_services_oobe_oneshot_dir}/${one_time_exec_sh_filename}
dst_one_time_exec_sh_fpath=${SP7xxx_linux_rootfs_initramfs_disk_scripts_dir}/${one_time_exec_sh_filename}

src_one_time_exec_before_login_sh_fpath=${home_lttp3rootfs_services_oobe_oneshot_dir}/${one_time_exec_before_login_sh_filename}
dst_one_time_exec_before_login_sh_fpath=${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}/${one_time_exec_before_login_sh_filename}

src_one_time_exec_before_login_service_fpath=${home_lttp3rootfs_services_oobe_oneshot_dir}/${one_time_exec_before_login_service_filename}
dst_one_time_exec_before_login_service_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}/${one_time_exec_before_login_service_filename}

src_sd_detect_add_sh_fpath=${home_lttp3rootfs_services_automount_dir}/${sd_detect_add_sh_filename}
dst_sd_detect_add_sh_fpath=${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}/${sd_detect_add_sh_filename}

src_sd_detect_remove_sh_fpath=${home_lttp3rootfs_services_automount_dir}/${sd_detect_remove_sh_filename}
dst_sd_detect_remove_sh_fpath=${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}/${sd_detect_remove_sh_filename}

src_sd_detect_rules_fpath=${home_lttp3rootfs_services_automount_dir}/${sd_detect_rules_filename}
dst_sd_detect_rules_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_udev_rulesd_dir}/${sd_detect_rules_filename}

src_sd_detect_service_fpath=${home_lttp3rootfs_services_automount_dir}/${sd_detect_service_filename}
dst_sd_detect_service_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}/${sd_detect_service_filename}

src_usb_mount_service_fpath=${home_lttp3rootfs_services_automount_dir}/${usb_mount_service_filename}
dst_usb_mount_service_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}/${usb_mount_service_filename}

src_usb_mount_sh_fpath=${home_lttp3rootfs_services_automount_dir}/${usb_mount_sh_filename}
dst_usb_mount_sh_fpath=${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}/${usb_mount_sh_filename}

src_usb_mount_rules_fpath=${home_lttp3rootfs_services_automount_dir}/${usb_mount_rules_filename}
dst_usb_mount_rules_fpath=${SP7xxx_linux_rootfs_initramfs_disk_etc_udev_rulesd_dir}/${usb_mount_rules_filename}

src_tpd_dir=${home_lttp3rootfs_kernel_drivers_tpd_dir}
dst_tpd_dir=${SP7xxx_linux_kernel_drivers_tpd_dir}

old_ehci_sched_c_fpath=${SP7xxx_linux_kernel_drivers_usb_host_dir}/${ehci_sched_c_filename}
new_ehci_sched_c_fpath=${home_lttp3rootfs_kernel_drivers_usb_host_dir}/${ehci_sched_c_filename}
ehci_sched_c_patch_fpath=${home_lttp3rootfs_kernel_drivers_usb_host_dir}/${ehci_sched_c_patch_filename}

old_irq_sp7021_intc_c_fpath=${SP7xxx_linux_kernel_drivers_irqchip_dir}/${irq_sp7021_intc_c_filename}
new_irq_sp7021_intc_c_fpath=${home_lttp3rootfs_kernel_drivers_irqchip_dir}/${irq_sp7021_intc_c_filename}
irq_sp7021_intc_c_patch_fpath=${home_lttp3rootfs_kernel_drivers_irqchip_dir}/${irq_sp7021_intc_c_patch_filename}

old_isp_c_fpath=${SP7xxx_build_tools_isp_dir}/${isp_c_filename}
new_isp_c_fpath=${home_lttp3rootfs_build_drivers_dir}/${isp_c_filename}
isp_c_patch_fpath=${home_lttp3rootfs_build_drivers_dir}/${isp_c_patch_filename}

old_makefile_fpath=${SP7xxx_linux_kernel_drivers_dir}/${makefile_filename}
new_makefile_fpath=${home_lttp3rootfs_kernel_drivers_dir}/${makefile_filename}
makefile_patch_fpath=${home_lttp3rootfs_kernel_drivers_dir}/${makefile_patch_filename}

old_kconfig_fpath=${SP7xxx_linux_kernel_dir}/${Kconfig_filename}
new_kconfig_fpath=${home_lttp3rootfs_kernel_dir}/${Kconfig_filename}
kconfig_patch_fpath=${home_lttp3rootfs_kernel_dir}/${Kconfig_patch_filename}

old_pentagram_common_h_fpath=${SP7xxx_boot_uboot_include_configs_dir}/${pentagram_common_h_filename}
new_pentagram_common_h_fpath=${home_lttp3rootfs_boot_configs_dir}/${pentagram_common_h_filename}
pentagram_common_h_patch_fpath=${home_lttp3rootfs_boot_configs_dir}/${pentagram_common_h_patch_filename}

old_sp_go_c_fpath=${SP7xxx_boot_uboot_board_sunplus_pentagram_board_dir}/${sp_go_c_filename}
new_sp_go_c_fpath=${home_lttp3rootfs_boot_drivers_dir}/${sp_go_c_filename}
sp_go_c_patch_fpath=${home_lttp3rootfs_boot_drivers_dir}/${sp_go_c_patch_filename}

old_sp_ocotp_c_fpath=${SP7xxx_linux_kernel_drivers_nvmem_dir}/${sp_ocotp_c_filename}
new_sp_ocotp_c_fpath=${home_lttp3rootfs_kernel_drivers_nvnmem_dir}/${sp_ocotp_c_filename}
sp_ocotp_c_patch_fpath=${home_lttp3rootfs_kernel_drivers_nvnmem_dir}/${sp_ocotp_c_patch_filename}

old_sppctl_gpio_c_fpath=${SP7xxx_linux_kernel_drivers_pinctrl_sunplus_dir}/${sppctl_gpio_c_filename}
new_sppctl_gpio_c_fpath=${home_lttp3rootfs_kernel_drivers_pinctrl_sunplus_dir}/${sppctl_gpio_c_filename}
sppctl_gpio_c_patch_fpath=${home_lttp3rootfs_kernel_drivers_pinctrl_sunplus_dir}/${sppctl_gpio_c_patch_filename}

old_sppctl_gpio_ops_c_fpath=${SP7xxx_linux_kernel_drivers_pinctrl_sunplus_dir}/${sppctl_gpio_ops_c_filename}
new_sppctl_gpio_ops_c_fpath=${home_lttp3rootfs_kernel_drivers_pinctrl_sunplus_dir}/${sppctl_gpio_ops_c_filename}
sppctl_gpio_ops_c_patch_fpath=${home_lttp3rootfs_kernel_drivers_pinctrl_sunplus_dir}/${sppctl_gpio_ops_c_patch_filename}

old_sppctl_gpio_ops_h_fpath=${SP7xxx_linux_kernel_drivers_pinctrl_sunplus_dir}/${sppctl_gpio_ops_h_filename}
new_sppctl_gpio_ops_h_fpath=${home_lttp3rootfs_kernel_drivers_pinctrl_sunplus_dir}/${sppctl_gpio_ops_h_filename}
sppctl_gpio_ops_h_patch_fpath=${home_lttp3rootfs_kernel_drivers_pinctrl_sunplus_dir}/${sppctl_gpio_ops_h_patch_filename}

old_sunplus_icm_c_fpath=${SP7xxx_linux_kernel_drivers_misc_dir}/${sunplus_icm_c_filename}
new_sunplus_icm_c_fpath=${home_lttp3rootfs_kernel_drivers_misc_dir}/${sunplus_icm_c_filename}
sunplus_icm_c_patch_fpath=${home_lttp3rootfs_kernel_drivers_misc_dir}/${sunplus_icm_c_patch_filename}

old_sunplus_uart_c_fpath=${SP7xxx_linux_kernel_drivers_tty_serial_dir}/${sunplus_uart_c_filename}
new_sunplus_uart_c_fpath=${home_lttp3rootfs_kernel_drivers_serial_dir}/${sunplus_uart_c_filename}
sunplus_uart_c_patch_fpath=${home_lttp3rootfs_kernel_drivers_serial_dir}/${sunplus_uart_c_patch_filename}

old_sp7021_common_dtsi_fpath=${SP7xxx_linux_kernel_arch_arm_boot_dts_dir}/${sp7021_common_dtsi_filename}
new_sp7021_common_dtsi_fpath=${home_lttp3rootfs_kernel_dts_dir}/${sp7021_common_dtsi_filename}
sp7021_common_dtsi_patch_fpath=${home_lttp3rootfs_kernel_dts_dir}/${sp7021_common_dtsi_patch_filename}

old_sp7021_ltpp3g2revD_dtsi_fpath=${SP7xxx_linux_kernel_arch_arm_boot_dts_dir}/${sp7021_ltpp3g2revD_dtsi_filename}
new_sp7021_ltpp3g2revD_dtsi_fpath=${home_lttp3rootfs_kernel_dts_dir}/${sp7021_ltpp3g2revD_dtsi_filename}
sp7021_ltpp3g2revD_dtsi_patch_fpath=${home_lttp3rootfs_kernel_dts_dir}/${sp7021_ltpp3g2revD_dtsi_patch_filename}
echo -e "---:TIBBO:ENV: FINISHED"



echo -e "\r"
echo -e "---------------------------------------------------------------"
echo -e "\tPRE-PREPARATION of DISK for CHROOT"
echo -e "---------------------------------------------------------------"

press_any_key__func
#---Create directories (if needed)
if [[ ! -d ${home_downloads_dir} ]]; then
	echo -e "\r"
	echo -e ">Create ${home_downloads_dir}"
	mkdir -p ${home_downloads_dir}
fi
if [[ ! -d ${SP7xxx_linux_kernel_drivers_tpd_dir} ]]; then
	echo -e "\r"
	echo -e ">Create ${SP7xxx_linux_kernel_drivers_tpd_dir}"
	mkdir -p ${SP7xxx_linux_kernel_drivers_tpd_dir}
fi
if [[ ! -d ${SP7xxx_linux_rootfs_initramfs_disk_etc_tibbo_version_dir} ]]; then
	echo -e "\r"
	echo -e ">Create ${SP7xxx_linux_rootfs_initramfs_disk_etc_tibbo_version_dir}"
	mkdir -p ${SP7xxx_linux_rootfs_initramfs_disk_etc_tibbo_version_dir}
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
echo -e ">Moving folder: ${disk_foldername}"
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



#---AUTOMOUNT USB & SD
press_any_key__func
echo -e "\r"
echo -e "---AUTO-MOUNT USB & SD---"
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



#---RULES
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



#SERVICES
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
echo -e ">Copying: ${enable_ufw_before_login_service_filename}"
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



echo -e "\r"
echo -e ">Copying: ${media_sync_service_filename}>"
echo -e ">from: ${home_lttp3rootfs_services_sync_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}"
	cp ${src_media_sync_service_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${media_sync_service_filename}"
	chown root:root ${dst_media_sync_service_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rw-r--r--> for file: ${media_sync_service_filename}"
	chmod 644 ${dst_media_sync_service_fpath}

echo -e "\r"
echo -e ">Copying: ${media_sync_sh_filename}"
echo -e ">from: ${home_lttp3rootfs_services_sync_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}"
	cp ${src_media_sync_sh_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${media_sync_sh_filename}"
	chown root:root ${dst_media_sync_sh_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rwxr-xr-x> for file: ${media_sync_sh_filename}"
	chmod 755 ${dst_media_sync_sh_fpath}

echo -e "\r"
echo -e ">Copying: ${media_sync_timer_filename}>"
echo -e ">from: ${home_lttp3rootfs_services_sync_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}"
	cp ${src_media_sync_timer_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${media_sync_timer_filename}"
	chown root:root ${dst_media_sync_timer_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rw-r--r--> for file: ${media_sync_timer_filename}"
	chmod 644 ${dst_media_sync_timer_fpath}


echo -e "\r"
echo -e ">Copying: ${modules_filename}>"
echo -e ">from: ${home_lttp3rootfs_kernel_modules_load_d_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}"
	cp ${src_modules_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_etc_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${modules_filename}"
	chown root:root ${dst_modules_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rw-r--r--> for file: ${modules_filename}"
	chmod 644 ${dst_modules_fpath}


echo -e "\r"
echo -e ">Copying: ${ntios_su_addasperand_service_filename}>"
echo -e ">from: ${home_lttp3rootfs_services_sudo_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}"
	cp ${src_ntios_su_addasperand_service_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${ntios_su_addasperand_service_filename}"
	chown root:root ${dst_ntios_su_addasperand_service_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rw-r--r--> for file: ${ntios_su_addasperand_service_filename}"
	chmod 644 ${dst_ntios_su_addasperand_service_fpath}

echo -e "\r"
echo -e ">Copying: ${ntios_su_add_sh_filename}"
echo -e ">from: ${home_lttp3rootfs_services_sudo_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}"
	cp ${src_ntios_su_add_sh_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${ntios_su_add_sh_filename}"
	chown root:root ${dst_ntios_su_add_sh_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rwxr-xr-x> for file: ${ntios_su_add_sh_filename}"
	chmod 755 ${dst_ntios_su_add_sh_fpath}



echo -e "\r"
echo -e ">Copying: ${ntios_su_add_monitor_service_filename}>"
echo -e ">from: ${home_lttp3rootfs_services_sudo_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}"
	cp ${src_ntios_su_add_monitor_service_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${ntios_su_add_monitor_service_filename}"
	chown root:root ${dst_ntios_su_add_monitor_service_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rw-r--r--> for file: ${ntios_su_add_monitor_service_filename}"
	chmod 644 ${dst_ntios_su_add_monitor_service_fpath}

echo -e "\r"
echo -e ">Copying: ${ntios_su_add_monitor_sh_filename}"
echo -e ">from: ${home_lttp3rootfs_services_sudo_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}"
	cp ${src_ntios_su_add_monitor_sh_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_usr_local_bin_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${ntios_su_add_monitor_sh_filename}"
	chown root:root ${dst_ntios_su_add_monitor_sh_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rwxr-xr-x> for file: ${ntios_su_add_monitor_sh_filename}"
	chmod 755 ${dst_ntios_su_add_monitor_sh_fpath}

echo -e "\r"
echo -e ">Copying: ${ntios_su_add_monitor_timer_filename}>"
echo -e ">from: ${home_lttp3rootfs_services_sudo_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}"
	cp ${src_ntios_su_add_monitor_timer_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_etc_systemd_system_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${ntios_su_add_monitor_timer_filename}"
	chown root:root ${dst_ntios_su_add_monitor_timer_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rw-r--r--> for file: ${ntios_su_add_monitor_timer_filename}"
	chmod 644 ${dst_ntios_su_add_monitor_timer_fpath}



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



#---DOCKER
echo -e "\r"
echo -e ">Copying: ${ispboootbin_version_txt_filename}>"
echo -e ">from: ${home_lttp3rootfs_docker_version_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_etc_tibbo_version_dir}"
	cp ${src_ispboootbin_version_txt_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_etc_tibbo_version_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for file: ${ispboootbin_version_txt_filename}"
	chown root:root ${dst_ispboootbin_version_txt_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rwxr-xr-x> for file: ${ispboootbin_version_txt_filename}"
	chmod 644 ${dst_ispboootbin_version_txt_fpath}



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
#press_any_key__func
#echo -e "\r"
#echo -e ">Copying: ${clkspq628c_filename}"
#echo -e ">from: ${home_lttp3rootfs_kernel_drivers_clk_dir}"
#echo -e ">to: ${SP7xxx_linux_kernel_drivers_clk_dir}"
#	cp ${src_clkspq628c_fpath} ${SP7xxx_linux_kernel_drivers_clk_dir}

# echo -e "\r"
# echo -e ">>>Change ownership to <root> for file: ${clkspq628c_filename}"
# 	chown root:root ${dst_clkspq628c_fpath}

# echo -e "\r"
# echo -e ">>>Change permission to <-rwxr-xr-x> for file: ${clkspq628c_filename}"
# 	chmod 755 ${dst_clkspq628c_fpath}



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



#---KERNEL
press_any_key__func
echo -e "\r"
echo -e ">Copy contents of folder: ${tpd_foldername}"
echo -e ">from: ${home_lttp3rootfs_kernel_scripts_tpd_dir}"
echo -e ">to: ${dst_tpd_dir}"
	cp ${src_tpd_dir}/* ${dst_tpd_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for this folder and its contents: ${tpd_foldername}"
	chown root:root -R ${dst_tpd_dir}

echo -e "\r"
echo -e "---Kernel Configuration File"
echo -e ">Copying: ${make_menuconfig_filename}"
echo -e ">from: ${home_lttp3rootfs_kernel_makeconfig_dir}"
echo -e ">to: ${SP7xxx_linux_kernel_dir}"
echo -e ">as: ${make_menuconfig_default_filename}"
echo -e "\r"
echo -e "\r"
	cp ${src_make_menuconfig_fpath} ${dst_make_menuconfig_fpath}

# press_any_key__func
# echo -e "\r"
# echo -e ">>>Navigate to ${SP7xxx_linux_kernel_dir}"
# 	cd ${SP7xxx_linux_kernel_dir}

#press_any_key__func
#echo -e "\r"
#echo -e ">>>>>Importing Kernel config-file: ${make_menuconfig_default_filename}"
#echo -e ">from: ${SP7xxx_linux_kernel_dir}"
#	make olddefconfig
#echo -e "\r"
#echo -e "\r"



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



#UPDATE-MOTD-D
press_any_key__func
echo -e "\r"
echo -e ">Copying: ${ninetynine_wlan_notice_filename}"
echo -e ">from: ${home_lttp3rootfs_motd_update_motd_d_dir}"
echo -e ">to: ${SP7xxx_linux_rootfs_initramfs_disk_etc_update_motd_d_dir}"
	cp -rf ${src_ninetynine_wlan_notice_fpath} ${SP7xxx_linux_rootfs_initramfs_disk_etc_update_motd_d_dir}

echo -e "\r"
echo -e ">>>Change ownership to <root> for folder: ${ninetynine_wlan_notice_filename}"
	chown -R root:root ${dst_ninetynine_wlan_notice_fpath}

echo -e "\r"
echo -e ">>>Change permission to <-rw-r-xr-x> for folder: ${ninetynine_wlan_notice_filename}"
	chmod -R 755 ${dst_ninetynine_wlan_notice_fpath}



###APPLYIBG PATCHES###
press_any_key__func
ehci_sched_c_diff=$(diff ${old_ehci_sched_c_fpath} ${new_ehci_sched_c_fpath})
if [[ -n "${ehci_sched_c_diff}" ]]; then
	echo -e "\r"
	echo -e ">Patching file"
	echo -e ">from: ${old_ehci_sched_c_fpath}"
	echo -e ">with: ${ehci_sched_c_patch_fpath}"
	patch "${old_ehci_sched_c_fpath}" < "${ehci_sched_c_patch_fpath}"
else
	echo -e "\r"
	echo -e ">Patch already applied to: ${old_ehci_sched_c_fpath}"
fi

irq_sp7021_intc_c_diff=$(diff ${old_irq_sp7021_intc_c_fpath} ${new_irq_sp7021_intc_c_fpath})
if [[ -n "${irq_sp7021_intc_c_diff}" ]]; then
	echo -e "\r"
	echo -e ">Patching file"
	echo -e ">from: ${old_irq_sp7021_intc_c_fpath}"
	echo -e ">with: ${irq_sp7021_intc_c_patch_fpath}"
	patch "${old_irq_sp7021_intc_c_fpath}" < "${irq_sp7021_intc_c_patch_fpath}"
else
	echo -e "\r"
	echo -e ">Patch already applied to: ${old_irq_sp7021_intc_c_fpath}"
fi

isp_c_diff=$(diff ${old_isp_c_fpath} ${new_isp_c_fpath})
if [[ -n "${isp_c_diff}" ]]; then
	echo -e "\r"
	echo -e ">Patching file"
	echo -e ">from: ${old_isp_c_fpath}"
	echo -e ">with: ${isp_c_patch_fpath}"
	patch "${old_isp_c_fpath}" < "${isp_c_patch_fpath}"
else
	echo -e "\r"
	echo -e ">Patch already applied to: ${old_isp_c_fpath}"
fi

makefile_diff=$(diff ${old_makefile_fpath} ${new_makefile_fpath})
if [[ -n "${makefile_diff}" ]]; then
	echo -e "\r"
	echo -e ">Patching file"
	echo -e ">from: ${old_makefile_fpath}"
	echo -e ">with: ${makefile_patch_fpath}"
	patch "${old_makefile_fpath}" < "${makefile_patch_fpath}"
else
	echo -e "\r"
	echo -e ">Patch already applied to: ${old_makefile_fpath}"
fi

kconfig_diff=$(diff ${old_kconfig_fpath} ${new_kconfig_fpath})
if [[ -n "${kconfig_diff}" ]]; then
	echo -e "\r"
	echo -e ">Patching file"
	echo -e ">from: ${old_kconfig_fpath}"
	echo -e ">with: ${kconfig_patch_fpath}"
	patch "${old_kconfig_fpath}" < "${kconfig_patch_fpath}"
else
	echo -e "\r"
	echo -e ">Patch already applied to: ${old_kconfig_fpath}"
fi

pentagram_common_h_diff=$(diff ${old_pentagram_common_h_fpath} ${new_pentagram_common_h_fpath})
if [[ -n "${pentagram_common_h_diff}" ]]; then
	echo -e "\r"
	echo -e ">Patching file"
	echo -e ">from: ${old_pentagram_common_h_fpath}"
	echo -e ">with: ${pentagram_common_h_patch_fpath}"
	patch "${old_pentagram_common_h_fpath}" < "${pentagram_common_h_patch_fpath}"
else
	echo -e "\r"
	echo -e ">Patch already applied to: ${old_pentagram_common_h_fpath}"
fi

sp_go_c_diff=$(diff ${old_sp_go_c_fpath} ${new_sp_go_c_fpath})
if [[ -n "${sp_go_c_diff}" ]]; then
	echo -e "\r"
	echo -e ">Patching file"
	echo -e ">from: ${old_sp_go_c_fpath}"
	echo -e ">with: ${sp_go_c_patch_fpath}"
	patch "${old_sp_go_c_fpath}" < "${sp_go_c_patch_fpath}"
else
	echo -e "\r"
	echo -e ">Patch already applied to: ${old_sp_go_c_fpath}"
fi

sp_ocotp_c_diff=$(diff ${old_sp_ocotp_c_fpath} ${new_sp_ocotp_c_fpath})
if [[ -n "${sp_ocotp_c_diff}" ]]; then
	echo -e "\r"
	echo -e ">Patching file"
	echo -e ">from: ${old_sp_ocotp_c_fpath}"
	echo -e ">with: ${sp_ocotp_c_patch_fpath}"
	patch "${old_sp_ocotp_c_fpath}" < "${sp_ocotp_c_patch_fpath}"
else
	echo -e "\r"
	echo -e ">Patch already applied to: ${old_sp_ocotp_c_fpath}"
fi

sp7021_common_dtsi_diff=$(diff ${old_sp7021_common_dtsi_fpath} ${new_sp7021_common_dtsi_fpath})
if [[ -n "${sp7021_common_dtsi_diff}" ]]; then
	echo -e "\r"
	echo -e ">Patching file"
	echo -e ">from: ${old_sp7021_common_dtsi_fpath}"
	echo -e ">with: ${sp7021_common_dtsi_patch_fpath}"
	patch "${old_sp7021_common_dtsi_fpath}" < "${sp7021_common_dtsi_patch_fpath}"
else
	echo -e "\r"
	echo -e ">Patch already applied to: ${old_sp7021_common_dtsi_fpath}"
fi

sp7021_ltpp3g2revD_dtsi_diff=$(diff ${old_sp7021_ltpp3g2revD_dtsi_fpath} ${new_sp7021_ltpp3g2revD_dtsi_fpath})
if [[ -n "${sp7021_ltpp3g2revD_dtsi_diff}" ]]; then
	echo -e "\r"
	echo -e ">Patching file"
	echo -e ">from: ${old_sp7021_ltpp3g2revD_dtsi_fpath}"
	echo -e ">with: ${sp7021_ltpp3g2revD_dtsi_patch_fpath}"
	patch "${old_sp7021_ltpp3g2revD_dtsi_fpath}" < "${sp7021_ltpp3g2revD_dtsi_patch_fpath}"
else
	echo -e "\r"
	echo -e ">Patch already applied to: ${old_sp7021_ltpp3g2revD_dtsi_fpath}"
fi

sppctl_gpio_c_diff=$(diff ${old_sppctl_gpio_c_fpath} ${new_sppctl_gpio_c_fpath})
if [[ -n "${sppctl_gpio_c_diff}" ]]; then
	echo -e "\r"
	echo -e ">Patching file"
	echo -e ">from: ${old_sppctl_gpio_c_fpath}"
	echo -e ">with: ${sppctl_gpio_c_patch_fpath}"
	patch "${old_sppctl_gpio_c_fpath}" < "${sppctl_gpio_c_patch_fpath}"
else
	echo -e "\r"
	echo -e ">Patch already applied to: ${old_sppctl_gpio_c_fpath}"
fi

sppctl_gpio_ops_c_diff=$(diff ${old_sppctl_gpio_ops_c_fpath} ${new_sppctl_gpio_ops_c_fpath})
if [[ -n "${sppctl_gpio_ops_c_diff}" ]]; then
	echo -e "\r"
	echo -e ">Patching file"
	echo -e ">from: ${old_sppctl_gpio_ops_c_fpath}"
	echo -e ">with: ${sppctl_gpio_ops_c_patch_fpath}"
	patch "${old_sppctl_gpio_ops_c_fpath}" < "${sppctl_gpio_ops_c_patch_fpath}"
else
	echo -e "\r"
	echo -e ">Patch already applied to: ${old_sppctl_gpio_ops_c_fpath}"
fi

sppctl_gpio_ops_h_diff=$(diff ${old_sppctl_gpio_ops_h_fpath} ${new_sppctl_gpio_ops_h_fpath})
if [[ -n "${sppctl_gpio_ops_h_diff}" ]]; then
	echo -e "\r"
	echo -e ">Patching file"
	echo -e ">from: ${old_sppctl_gpio_ops_h_fpath}"
	echo -e ">with: ${sppctl_gpio_ops_h_patch_fpath}"
	patch "${old_sppctl_gpio_ops_h_fpath}" < "${sppctl_gpio_ops_h_patch_fpath}"
else
	echo -e "\r"
	echo -e ">Patch already applied to: ${old_sppctl_gpio_ops_h_fpath}"
fi

sunplus_icm_c_diff=$(diff ${old_sunplus_icm_c_fpath} ${new_sunplus_icm_c_fpath})
if [[ -n "${sunplus_icm_c_diff}" ]]; then
	echo -e "\r"
	echo -e ">Patching file"
	echo -e ">from: ${old_sunplus_icm_c_fpath}"
	echo -e ">with: ${sunplus_icm_c_patch_fpath}"
	patch "${old_sunplus_icm_c_fpath}" < "${sunplus_icm_c_patch_fpath}"
else
	echo -e "\r"
	echo -e ">Patch already applied to: ${old_sunplus_icm_c_fpath}"
fi

sunplus_uart_c_diff=$(diff ${old_sunplus_uart_c_fpath} ${new_sunplus_uart_c_fpath})
if [[ -n "${sunplus_uart_c_diff}" ]]; then
	echo -e "\r"
	echo -e ">Patching file"
	echo -e ">from: ${old_sunplus_uart_c_fpath}"
	echo -e ">with: ${sunplus_uart_c_patch_fpath}"
	patch "${old_sunplus_uart_c_fpath}" < "${sunplus_uart_c_patch_fpath}"
else
	echo -e "\r"
	echo -e ">Patch already applied to: ${old_sunplus_uart_c_fpath}"
fi



#PATCH: 'BCMDHD'
press_any_key__func
if [[ -d "${SP7xxx_linux_kernel_drivers_net_wireless_bcmdhd_dir}" ]]; then
	echo -e "\r"
	echo -e ">Remove folder ${bcmdhd_foldername}"
	echo -e ">from: ${SP7xxx_linux_kernel_drivers_net_wireless_dir}"
	rm -rf ${SP7xxx_linux_kernel_drivers_net_wireless_bcmdhd_dir}
fi

echo -e "\r"
echo -e ">Extract ${bcmdhd_targz_filename}"
echo -e ">from: ${home_lttp3rootfs_kernel_drivers_wifi_dir}"
echo -e ">to: ${SP7xxx_linux_kernel_drivers_net_wireless_dir}"
tar xzvf ${src_brcmhd_targz_fpath} --directory ${SP7xxx_linux_kernel_drivers_net_wireless_dir}
