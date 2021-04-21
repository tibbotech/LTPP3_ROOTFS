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
do_enable_sub() {
	if [[ -f "${mode_fpath}" ]]; then
		if [[ -z `cat "${mode_fpath}" | grep "1"` ]]; then
			echo -e "\r"
				echo "1" > ${mode_fpath}
				
				netplan apply
			echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}:  ${FG_LIGHTGREY}DAISY-CHAIN${NOCOLOR} MODE IS ${FG_SOFLIGHTRED}OFF${NOCOLOR}"

			echo -e "\r"
				ifconfig eth1 up
			echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: ${FG_LIGHTGREEN}ENABLED${NOCOLOR} ${FG_LIGHTGREY}eth1${NOCOLOR}" 
		fi
	fi
}

do_disable_sub() {
	if [[ -f "${mode_fpath}" ]]; then
		echo -e "\r"
			ifconfig eth1 down
		echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: ${FG_SOFLIGHTRED}DISABLED${NOCOLOR} ${FG_LIGHTGREY}eth1${NOCOLOR}" 
		
		echo -e "\r"
			echo "0" > ${mode_fpath}

			netplan apply
		echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: ${FG_LIGHTGREY}DAISY-CHAIN${NOCOLOR} MODE IS ${FG_LIGHTGREEN}ON${NOCOLOR}"
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
