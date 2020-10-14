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
    echo "Usage: $0 {enable|disable}"
	echo -e "\r"
	
    exit 1
}

do_enable_sub() {
	if [[ -f "/sys/devices/platform/soc@B/9c108000.l2sw/mode" ]]; then
		if [[ -z `cat "/sys/devices/platform/soc@B/9c108000.l2sw/mode" | grep "1"` ]]; then
			echo -e "\r"
			echo ">Enable Network Interface Eth1"
			echo ">Changing <mode> to \"1\""
				echo "1" > /sys/devices/platform/soc@B/9c108000.l2sw/mode
				
				netplan apply
		fi
	fi
}

do_disable_sub() {
	if [[ -f "/sys/devices/platform/soc@B/9c108000.l2sw/mode" ]]; then
		echo -e "\r"
		echo ">Disabling eth1"
			ifconfig eth1 down
		
		echo -e "\r"
		echo ">Disable Network Interface Eth1"
		echo ">>>Changing <mode> to \"0\""
			echo "0" > /sys/devices/platform/soc@B/9c108000.l2sw/mode
	fi
}

#---Check input args
if [[ $# -ne 1 ]]; then	#input args is not equal to 2 
    usage_sub
else
	if [[ ${1} != ${cENABLE} ]] && [[ ${1} != ${cDISABLE} ]]; then
		usage_sub
	fi
fi


#---Select case
case "${ACTION}" in
    ${cENABLE})
        do_enable_sub
        ;;
    ${cDISABLE})
        do_disable_sub
        ;;
    *)
        usage_sub
        ;;
esac