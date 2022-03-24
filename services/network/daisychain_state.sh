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

#---BOOLEAN CONSTANTS
ENABLE="enable"
DISABLE="disable"



#---ENVIRONMENT VARIABLES
mode_fpath=/sys/devices/platform/soc@B/9c108000.l2sw/mode



#---SUBROUTINES
do_disable_sub() {
	if [[ -f "${mode_fpath}" ]]; then
		echo -e "\r"
		if [[ -z `cat "${mode_fpath}" | grep "1"` ]]; then
			echo "1" > ${mode_fpath}
			netplan apply
			echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: ${FG_LIGHTGREY}daisy-chain${NOCOLOR} is ${FG_SOFLIGHTRED}DISABLED${NOCOLOR}"

			ifconfig eth1 up
			echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: ${FG_LIGHTGREY}eth1${NOCOLOR} is ${FG_LIGHTGREEN}ENABLED${NOCOLOR}"
		else
			echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: ${FG_LIGHTGREY}daisy-chain${NOCOLOR} is already ${FG_SOFLIGHTRED}DISABLED${NOCOLOR}"
		fi
		echo -e "\r"
	fi
}

do_enable_sub() {
	if [[ -f "${mode_fpath}" ]]; then
		echo -e "\r"
		if [[ -z `cat "${mode_fpath}" | grep "0"` ]]; then
			ifconfig eth1 down
			echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: ${FG_LIGHTGREY}eth1${NOCOLOR} is ${FG_SOFLIGHTRED}DISABLED${NOCOLOR}" 
		
			echo "0" > ${mode_fpath}
			netplan apply
			echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: ${FG_LIGHTGREY}daisy-chain${NOCOLOR} is ${FG_LIGHTGREEN}ENABLED${NOCOLOR}"
		else
			echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: ${FG_LIGHTGREY}daisy-chain${NOCOLOR} is already ${FG_LIGHTGREEN}ENABLED${NOCOLOR}"
		fi
		echo -e "\r"
	fi
}

#---Check input args
if [[ $# -ne 1 ]]; then	#input args is not equal to 2 
    usage_sub
else
	if [[ ${1} != ${ENABLE} ]] && [[ ${1} != ${DISABLE} ]]; then
		usage_sub
	fi
fi


#---Select case
case "${ACTION}" in
    ${ENABLE})
        do_enable_sub
        ;;
    ${DISABLE})
        do_disable_sub
        ;;
    *)
        usage_sub
        ;;
esac
