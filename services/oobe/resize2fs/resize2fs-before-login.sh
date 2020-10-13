#!/bin/bash
#---Input args
ACTION=${1}


#---Constants
cENABLE="enable"
cDISABLE="disable"


#---Local Functions
usage_sub() 
{
	echo -e "\r"
    echo "Usage: $0 {enable}"
	echo -e "\r"
	
    exit 1
}

do_enable_sub() {
	if [[ -f "/scripts/resize2fs_exec.sh" ]]; then
		echo -e "\r"
		echo ">Rezising </dev/mmcblk0p8>"
			/scripts/resize2fs_exec.sh

		echo -e "\r"
		echo ">Removing </scripts/resize2fs_exec.sh>"
			rm /scripts/resize2fs_exec.sh
	fi
}

#---Check input args
if [[ $# -ne 1 ]]; then	#input args is not equal to 2 
    usage_sub
else
	if [[ ${1} != ${cENABLE} ]]; then
		usage_sub
	fi
fi


#---Select case
case "${ACTION}" in
    ${cENABLE})
        do_enable_sub
        ;;
    *)
        usage_sub
        ;;
esac