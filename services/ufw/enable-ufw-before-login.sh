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
	if [[ ! -z `ufw status | grep "inactive"` ]]; then
		echo -e "\r"
		echo "Enabling UFW"
			ufw enable
	fi
}

do_disable_sub() {
	if [[ -z `ufw status | grep "inactive"` ]]; then
		echo -e "\r"
		echo "Disabling UFW"
			ufw disable
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