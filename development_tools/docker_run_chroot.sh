#!/bin/bash
#---Define colors
DOCKER__NOCOLOR=$'\e[0m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__FILES_FG_ORANGE=$'\e[30;38;5;215m'

DOCKER__TITLE_BG_LIGHTBLUE='\e[30;48;5;45m'

#---Define PATHS
docker__SP7xxx_foldername="SP7021"
docker__disk_foldername="disk"
docker__qemu_user_static_filename="qemu-user-static"

docker__usr_dir=/usr
docker__usr_bin_dir=${docker__usr_dir}/bin

docker__home_dir=~
docker__SP7xxx_dir=${docker__home_dir}/${docker__SP7xxx_foldername}
docker__SP7xxx_linux_rootfs_initramfs_dir=${docker__SP7xxx_dir}/linux/rootfs/initramfs
docker__SP7xxx_linux_rootfs_initramfs_disk_dir=${docker__SP7xxx_linux_rootfs_initramfs_dir}/${docker__disk_foldername}

docker__qemu_fpath=${docker__usr_bin_dir}/qemu-arm-static
docker__bash_fpath=${docker__usr_bin_dir}/bash


#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C__sub INT

function CTRL_C__sub() {
    echo -e "\r"
    echo -e "\r"
    echo -e "${DOCKER__READ_FG_EXITING_NOW}"
    echo -e "\r"
    echo -e "\r"

    exit
}

press_any_key__localfunc() {
	#Define constants
	local cTIMEOUT_ANYKEY=10

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

press_any_key_to_quit_localfunc() {
	#Define constants
	local cTIMEOUT_ANYKEY=3

	#Initialize variables
	local keypressed=""
	local tcounter=0

	#Show Press Any Key message with count-down
	echo -e "\r"
	while [[ ${tcounter} -le ${cTIMEOUT_ANYKEY} ]];
	do
		delta_tcounter=$(( ${cTIMEOUT_ANYKEY} - ${tcounter} ))

		echo -e "\rPress any key to continue... (${delta_tcounter}) \c"
		read -N 1 -t 1 -s -r keypressed

		if [[ ! -z "${keypressed}" ]]; then
			break
		fi
		
		tcounter=$((tcounter+1))
	done

    echo -e "\r"
    echo -e "\r"
    echo -e "EXITING NOW..."
    echo -e "\r"
    echo -e "\r"

    exit    #exit script
}

#SHOW DOCKER BANNER
docker__load_header__sub() {
    echo -e "\r"
    echo -e "${DOCKER__TITLE_BG_LIGHTBLUE}                               DOCKER${DOCKER__TITLE_BG_LIGHTBLUE}                               ${DOCKER__NOCOLOR}"
}

docker__checkif_dir_exist__sub() {
    if [[ ! -d ${docker__SP7xxx_linux_rootfs_initramfs_disk_dir} ]]; then
        echo -e "\r"
        echo -e "***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Please make sure to run chroot from WITHIN a CONTAINER!!!"

        press_any_key_to_quit_localfunc
    fi
}

docker__mandatory_apps_check__sub() {
    echo -e "\r"
    echo -e "Before we continue..."
    echo -e "\r"
    echo -e "Please make sure that to have ${DOCKER__GENERAL_FG_YELLOW}manually${DOCKER__NOCOLOR} installed ${DOCKER__FILES_FG_ORANGE}${docker__qemu_user_static_filename}${DOCKER__NOCOLOR}..."

    press_any_key__localfunc

    echo -e "\r"  
    echo -e "\r"    
    echo -e "Using the already ${DOCKER__GENERAL_FG_YELLOW}built-in${DOCKER__NOCOLOR} ${DOCKER__FILES_FG_ORANGE}${docker__qemu_user_static_filename}${DOCKER__NOCOLOR} may result in ${DOCKER__ERROR_FG_LIGHTRED}ERRORs${DOCKER__NOCOLOR}."

    press_any_key__localfunc
}

docker__run_script__sub() {
    echo -e "\r"
        echo -e "--------------------------------------------------------------------"
    echo -e "GOING INTO <CHROOT>"
        echo -e "--------------------------------------------------------------------"
    echo -e "REMARK:"
    echo -e "\tTo EXIT 'chroot', type 'exit'"
        echo -e "--------------------------------------------------------------------"
    chroot ${docker__SP7xxx_linux_rootfs_initramfs_disk_dir} ${docker__qemu_fpath} ${docker__bash_fpath}
}

docker__main__sub(){
    docker__load_header__sub
    docker__checkif_dir_exist__sub
    docker__mandatory_apps_check__sub
    docker__run_script__sub
}


#Run main subroutine
docker__main__sub