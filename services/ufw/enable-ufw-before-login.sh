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



#---SUBROUTINES
usage__sub() 
{
	echo -e "\r"
    echo -e ":-->${FG_LIGHTRED}USAGE${NOCOLOR}: $0 {${FG_LIGHTGREEN}${ENABLE}${NOCOLOR}|${FG_SOFLIGHTRED}${DISABLE}${NOCOLOR}}"
	echo -e "\r"
	
    exit 99
}

do_enable__sub() {
	if [[ ! -z `ufw status | grep "inactive"` ]]; then
		echo -e "\r"
			ufw ${ENABLE}
		echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: ${FG_LIGHTGREEN}ENABLED${NOCOLOR} ${FG_LIGHTGREY}ufw${NOCOLOR}"
	fi
}

do_disable__sub() {
	if [[ -z `ufw status | grep "inactive"` ]]; then
		echo -e "\r"
			ufw ${DISABLE}
		echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: ${FG_SOFLIGHTRED}DISABLED${NOCOLOR} ${FG_LIGHTGREY}ufw${NOCOLOR}"
	fi
}

#---CHECK INPUT ARGS
if [[ $# -ne 1 ]]; then	#input args is not equal to 2 
    usage__sub
else
	if [[ ${1} != ${ENABLE} ]] && [[ ${1} != ${DISABLE} ]]; then
		usage__sub
	fi
fi


#---SELECT CASE
case "${ACTION}" in
    ${ENABLE})
        do_enable__sub
        ;;
    ${DISABLE})
        do_disable__sub
        ;;
    *)
        usage__sub
        ;;
esac
