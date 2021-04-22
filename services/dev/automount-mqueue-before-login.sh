#!/bin/bash
#---version:21.03.23-0.0.1
#---Input args
ACTION=${1}



#---COLORS CONSTANTS
NOCOLOR=$'\e[0m'
FG_LIGHTRED=$'\e[1;31m'
FG_ORANGE=$'\e[30;38;5;209m'
FG_LIGHTGREY=$'\e[30;38;5;246m'
FG_LIGHTGREEN=$'\e[30;38;5;71m'
FG_SOFLIGHTRED=$'\e[30;38;5;131m'



#---CONSTANTS
MOUNTPOINT_NONE="none"



#---BOOLEAN CONSTANTS
ENABLE="enable"
DISABLE="disable"



#---ENVIRONMENT VARIABLES
dev_dir=/dev
mqueue_fs="mqueue"
dev_mqueue_dir=${dev_dir}/${mqueue_fs}

usr_local_bin=/usr/local/bin
automount_mqueue_before_login_sh_fpath=${usr_local_bin}/automount-mqueue-before-login.sh



#---SUBROUTINES
usage_sub() 
{
	echo -e "\r"
    echo -e ":-->${FG_LIGHTRED}USAGE${NOCOLOR}: $0 {${FG_LIGHTGREEN}${ENABLE}${NOCOLOR}|${FG_SOFLIGHTRED}${DISABLE}${NOCOLOR}}"
	echo -e "\r"
	
    exit 99
}

do_enable_sub() {
	if [[ -f "${automount_mqueue_before_login_sh_fpath}" ]]; then
		automount_mqueue_func
	else
		echo -e "\r"
		echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: FILE NOT FOUND '${FG_LIGHTGREY}${automount_mqueue_before_login_sh_fpath}${NOCOLOR}'"
		echo -e "\r"	
	fi
}
function automount_mqueue_func() {
	#---POSIX MESSAGE QUEUE
	if [[ ! -d ${dev_mqueue_dir} ]]; then
		mkdir ${dev_mqueue_dir}

		echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: CREATED DIRECTORY ${FG_LIGHTGREY}${dev_mqueue_dir}${NOCOLOR}"
	fi

	currMountPoint=`mount | grep ${dev_mqueue_dir} | awk '{print $1}'`
	if [[ ! -z ${currMountPoint} ]]; then
		if [[ ${currMountPoint} != ${MOUNTPOINT_NONE} ]]; then #/dev/mqueue is already mounted
			umount ${currMountPoint}    #unmount /dev/mqueue
			echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: REMOVED MOUNT DIRECTORY ${FG_LIGHTGREY}${dev_mqueue_dir}${NOCOLOR}"
		fi
	fi

	mount -t ${mqueue_fs} ${MOUNTPOINT_NONE} ${dev_mqueue_dir}
	echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: MOUNTED ${FG_LIGHTGREY}${dev_mqueue_dir}${NOCOLOR}"
}




#---CHECK INPUT ARGS
if [[ $# -ne 1 ]]; then	#input args is not equal to 2 
    usage_sub
else
	if [[ ${1} != ${ENABLE} ]]; then
		usage_sub
	fi
fi


#---SELECT CASE
case "${ACTION}" in
    ${ENABLE})
        do_enable_sub
        ;;
    *)
        usage_sub
        ;;
esac
