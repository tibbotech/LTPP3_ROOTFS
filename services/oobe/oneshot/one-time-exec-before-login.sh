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
scripts_dir=/scripts
one_time_exec_filename="one-time-exec.sh"
one_time_exec_fpath=${scripts_dir}/${one_time_exec_filename}

target_resize_dir=/dev/mmcblk0p8



#---SUBROUTINES
usage_sub() 
{
	echo -e "\r"
    echo -e ":-->${FG_LIGHTRED}USAGE${NOCOLOR}: $0 {${FG_LIGHTGREEN}${ENABLE}${NOCOLOR}|${FG_SOFLIGHTRED}${DISABLE}${NOCOLOR}}"
	echo -e "\r"
	
    exit 99
}

do_enable_sub() {
	if [[ -f "${one_time_exec_fpath}" ]]; then
		echo -e "\r"
		echo -e ":-->${FG_ORANGE}START${NOCOLOR}: EXECUTING '${FG_LIGHTGREY}${one_time_exec_fpath}${NOCOLOR}'"
			sudo sh -c "${one_time_exec_fpath}"
		echo -e ":-->${FG_ORANGE}COMPLETED${NOCOLOR}: EXECUTING '${FG_LIGHTGREY}${one_time_exec_fpath}${NOCOLOR}'"

		echo -e "\r"
			sudo sh -c "rm ${one_time_exec_fpath}"
		echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: REMOVED '${FG_LIGHTGREY}${one_time_exec_fpath}${NOCOLOR}'"
	fi
}

#---Check input args
if [[ $# -ne 1 ]]; then	#input args is not equal to 2 
    usage_sub
else
	if [[ ${1} != ${ENABLE} ]]; then
		usage_sub
	fi
fi


#---Select case
case "${ACTION}" in
    ${ENABLE})
        do_enable_sub
        ;;
    *)
        usage_sub
        ;;
esac
