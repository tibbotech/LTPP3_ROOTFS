#!/bin/bash
#---Define colors
DOCKER__NOCOLOR=$'\e[0m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__CONTAINER_FG_BRIGHTPRUPLE=$'\e[30;38;5;141m'
DOCKER__PORTS_FG_LIGHTBLUE=$'\e[1;34m'
DOCKER__IP_FG_LIGHTCYAN=$'\e[1;36m'

DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'
DOCKER__TITLE_BG_LIGHTBLUE=$'\e[30;48;5;45m'

#---CONSTANTS
DOCKER__TITLE="TIBBO"
DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'
DOCKER__SSH_LOCALPORT=10022

DOCKER__ONESPACE=" "
DOCKER__TWOSPACES=${DOCKER__ONESPACE}${DOCKER__ONESPACE}
DOCKER__FOURSPACES=${DOCKER__TWOSPACES}${DOCKER__TWOSPACES}

#---CHARACTER CHONSTANTS
DOCKER__DASH="-"

DOCKER__ONESPACE=" "
DOCKER__TWOSPACES=${DOCKER__ONESPACE}${DOCKER__ONESPACE}
DOCKER__FOURSPACES=${DOCKER__TWOSPACES}${DOCKER__TWOSPACES}

#---NUMERIC CONSTANTS
DOCKER__TABLEWIDTH=70



#---FUNCTIONS
#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C_func INT

function CTRL_C_func() {
    echo -e "\r"
    echo -e "\r"
    echo -e "Exiting now..."
    echo -e "\r"
    echo -e "\r"
    
    exit
}

function press_any_key__func() {
	#Define constants
	local ANYKEY_TIMEOUT=10

	#Initialize variables
	local keypressed=""
	local tcounter=0

	#Show Press Any Key message with count-down
	echo -e "\r"
	while [[ ${tcounter} -le ${ANYKEY_TIMEOUT} ]];
	do
		delta_tcounter=$(( ${ANYKEY_TIMEOUT} - ${tcounter} ))

		echo -e "\rPress (a)bort or any key to continue... (${delta_tcounter}) \c"
		read -N 1 -t 1 -s -r keypressed

		if [[ ! -z "${keypressed}" ]]; then
			if [[ "${keypressed}" == "a" ]] || [[ "${keypressed}" == "A" ]]; then
				exit
			else
				break
			fi
		fi
		
		tcounter=$((tcounter+1))
	done
	echo -e "\r"
}

function show_centered_string__func()
{
    #Input args
    local str_input=${1}
    local maxStrLen_input=${2}

    #Define one-space constant
    local ONESPACE=" "

    #Get string 'without visiable' color characters
    local strInput_wo_colorChars=`echo "${str_input}" | sed "s,\x1B\[[0-9;]*m,,g"`

    #Get string length
    local strInput_wo_colorChars_len=${#strInput_wo_colorChars}

    #Calculated the number of spaces to-be-added
    local numOf_spaces=$(( (maxStrLen_input-strInput_wo_colorChars_len)/2 ))

    #Create a string containing only EMPTY SPACES
    local emptySpaces_string=`duplicate_char__func "${ONESPACE}" "${numOf_spaces}" `

    #Print text including Leading Empty Spaces
    echo -e "${emptySpaces_string}${str_input}"
}

function duplicate_char__func()
{
    #Input args
    local char_input=${1}
    local numOf_times=${2}

    #Duplicate 'char_input'
    local char_duplicated=`printf '%*s' "${numOf_times}" | tr ' ' "${char_input}"`

    #Print text including Leading Empty Spaces
    echo -e "${char_duplicated}"
}



#---SUBROUTINES

docker__environmental_variables__sub() {
    docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})
    if [[ ${docker__current_dir} == ${DOCKER__DOT} ]]; then
        docker__current_dir=$(pwd)
    fi
}

docker__load_header__sub() {
    echo -e "\r"
    echo -e "${DOCKER__TITLE_BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__TITLE_BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__init_variables__sub() {
    docker__ipv4_addr_summarize_str=""
    docker__ipv4_addr_summarize_arr=()
    docker__ssh_localport=${DOCKER__SSH_LOCALPORT}
}

get_assigned_ipv4_addresses__func() {
    #Define variabes
    local iproute_line=""
    local dev_colno=0
    local src_colno=0
    local nic_name=""
    local ipv4addr=""
    local nic_belongs_toDocker=""
    local ipv4addr_isPresent=""
    local i=0

    #Get Network-adapter vs. IP-address
    local numOf_iproute_results=`ip route | wc -l`
    if [[ $numOf_iproute_results -ne 0 ]]; then
        for ((i = 1 ; i <= ${numOf_iproute_results} ; i++)); do
            iproute_line=`ip route | head -"$i" | tail -1`	#get ip route result for line i
            
            dev_colno=`echo ${iproute_line} | awk '{ for (k=1; k<=NF; ++k) { if ($k ~ "dev") print k } }'`	#get column number of "dev"
            if [[ ${dev_colno} -ne 0 ]]; then
                src_colno=`echo ${iproute_line} | awk '{ for (k=1; k<=NF; ++k) { if ($k ~ "src") print k } }'`	#get column number of "src"
                if [[ ${src_colno} -ne 0 ]]; then
                    dev_colno=$((dev_colno+1))	#get nic column number
                    src_colno=$((src_colno+1))	#get ip address column number
                    nic_name=`echo ${iproute_line} | awk -v c=${dev_colno} '{ print $c }'`	#get result on right-side of "dev"
                    ipv4addr=`echo ${iproute_line} | awk -v c=${src_colno} '{ print $c }'`	#get result on right-side of "src"
                    
                    #Check if 'nic_name' value is found in the 'docker network inspect bridge' result
                    nic_belongs_toDocker=$(docker network inspect bridge | grep '${nic_name}') 
                    if [[ -z ${nic_belongs_toDocker} ]]; then   #'nic_name' does not belong to 'docker'
                        if [[ ${ipv4addr} =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then  #'ip4addr' is valid
                            
                            #Check if 'ipv4addr' is already added to 'docker__ipv4_addr_summarize_str'
                            ipv4addr_isPresent=$(echo ${docker__ipv4_addr_summarize_str} | grep ${ipv4addr})  
                            if [[ -z ${ipv4addr_isPresent} ]]; then #'ipv4addr' is unique
                                if [[ -z ${docker__ipv4_addr_summarize_str} ]]; then
                                    docker__ipv4_addr_summarize_str="${ipv4addr}"
                                else
                                    docker__ipv4_addr_summarize_str="${docker__ipv4_addr_summarize_str} ${ipv4addr}"
                                fi
                            fi
                        fi
                    fi		
                fi
            fi
        done

        eval "docker__ipv4_addr_summarize_arr=(${docker__ipv4_addr_summarize_str})"
    else
        echo -e "\r"
        echo -e "***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: No ip-address found"    
        echo -e "\r"
        echo -e "\r"
    fi
}

docker__ssh_handler__sub() {
    #Define local menu constants
    local MENUTITLE="${DOCKER__GENERAL_FG_YELLOW}SSH${DOCKER__NOCOLOR} to a ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}"

    #Show menu-title
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${MENUTITLE}"  "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Get Local IP-addresses
    get_assigned_ipv4_addresses__func

    #Show list of ip-addreses
    echo -e "List of Local IP-addresses:"
    for ipv4 in "${docker__ipv4_addr_summarize_arr[@]}"; do 
        echo -e "${DOCKER__FOURSPACES}${DOCKER__IP_FG_LIGHTCYAN}${ipv4}${DOCKER__NOCOLOR}"
    done
    echo -e "\r"

    #Input IP-address
    while true
    do
        read -e -p "${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}-IP (e.g. 172.31.1.51): " -i ${docker__ipv4_addr_summarize_arr[0]} myhost
        if [[ ! -z ${myhost} ]]; then    #input was NOT an EMPTY STRING
            break
        fi
    done

    #Input Port-number
    while true
    do
        read -e -p "${DOCKER__PORTS_FG_LIGHTBLUE}Port${DOCKER__NOCOLOR} (e.g. 10022): " -i "${docker__ssh_localport}" myport
        if [[ ! -z ${myport} ]]; then    #input was NOT an EMPTY STRING
            break
        fi
    done

    #Execute ssh-command
    #REMARK: 
    #   -o AddKeysToAgent=yes: this switch is used to bypass the error message:
    #   'The authenticity of host '[172.17.0.1]:10022 ([172.17.0.1]:10022)' can't be established...etc'
    ssh -o AddKeysToAgent=yes root@${myhost} -p ${myport}
}

main_sub() {
    docker__load_header__sub

    docker__init_variables__sub

    docker__ssh_handler__sub
}

#Execute main subroutine
main_sub
