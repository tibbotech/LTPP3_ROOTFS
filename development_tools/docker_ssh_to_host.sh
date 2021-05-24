#!/bin/bash
#---Define colors
DOCKER__NOCOLOR=$'\e[0m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__CONTAINER_FG_BRIGHTPRUPLE=$'\e[30;38;5;141m'
DOCKER__FILES_FG_ORANGE=$'\e[30;38;5;215m'
DOCKER__PORTS_FG_LIGHTBLUE=$'\e[1;34m'
DOCKER__IP_FG_LIGHTCYAN=$'\e[1;36m'

DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'
DOCKER__TITLE_BG_LIGHTBLUE=$'\e[30;48;5;45m'

#---CONSTANTS
DOCKER__TITLE="TIBBO"
DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'

DOCKER__ONESPACE=" "
DOCKER__TWOSPACES=${DOCKER__ONESPACE}${DOCKER__ONESPACE}
DOCKER__FOURSPACES=${DOCKER__TWOSPACES}${DOCKER__TWOSPACES}

#---BOOLEAN CONSTANTS
TRUE=true
FALSE=false

#---CHARACTER CONSTANTS
DOCKER__DASH="-"
DOCKER__COMMA_CHAR=","
DOCKER__EMPTYSTRING=""

DOCKER__ONESPACE=" "
DOCKER__TWOSPACES=${DOCKER__ONESPACE}${DOCKER__ONESPACE}
DOCKER__FOURSPACES=${DOCKER__TWOSPACES}${DOCKER__TWOSPACES}


#---NUMERIC CONSTANTS
DOCKER__TABLEWIDTH=70

DOCKER__NUMOFLINES_0=0
DOCKER__NUMOFLINES_1=1
DOCKER__NUMOFLINES_2=2
DOCKER__NUMOFLINES_3=3
DOCKER__NUMOFLINES_4=4
DOCKER__NUMOFLINES_5=5
DOCKER__NUMOFLINES_6=6
DOCKER__NUMOFLINES_7=7
DOCKER__NUMOFLINES_8=8
DOCKER__NUMOFLINES_9=9



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
	local keypressed=${DOCKER__EMPTYSTRING}
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

function isNumeric__func()
{
    #Input args
    local inputVar=${1}

    #Define local variables
    local regEx="^\-?[0-9]*\.?[0-9]+$"
    local stdOutput=${DOCKER__EMPTYSTRING}

    #Check if numeric
    #If TRUE, then 'stdOutput' is NOT EMPTY STRING
    stdOutput=`echo "${inputVar}" | grep -E "${regEx}"`

    if [[ ! -z ${stdOutput} ]]; then    #contains data
        echo ${TRUE}
    else    #contains NO data
        echo ${FALSE}
    fi
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

function moveUp_and_cleanLines__func() {
    #Input args
    local numOf_lines_toBeCleared=${1}

    #Clear lines
    local numOf_lines_cleared=1
    while [[ ${numOf_lines_cleared} -le ${numOf_lines_toBeCleared} ]]
    do
        tput cuu1	#move UP with 1 line
        tput el		#clear until the END of line

        numOf_lines_cleared=$((numOf_lines_cleared+1))  #increment by 1
    done
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
    docker__ipv4List_string=${DOCKER__EMPTYSTRING}
    docker__ipv4List_arr=()
}

get_assigned_ipv4_addresses__func() {
    #Define local variabes
    local iproute_line=${DOCKER__EMPTYSTRING}
    local dev_colNo=0
    local src_colNo=0
    local nic_name=${DOCKER__EMPTYSTRING}
    local ipv4Addr=${DOCKER__EMPTYSTRING}
    local nic_belongs_toDocker=${DOCKER__EMPTYSTRING}
    local container_ip_isValid=${FALSE}
    local ipv4Addr_isPresent=${DOCKER__EMPTYSTRING}
    local i=0



    #Initialize variables
    docker__ipv4List_string=${DOCKER__EMPTYSTRING}
    docker__ipv4List_arr=()

    #Get Network-adapter vs. IP-address
    local numOf_iproute_results=`ip route | wc -l`
    if [[ $numOf_iproute_results -ne 0 ]]; then
        for ((i = 1 ; i <= ${numOf_iproute_results} ; i++)); do
            iproute_line=`ip route | head -"$i" | tail -1`	#get ip route result for line i
            
            dev_colNo=`echo ${iproute_line} | awk '{ for (k=1; k<=NF; ++k) { if ($k ~ "dev") print k } }'`	#get column number of "dev"
            if [[ ${dev_colNo} -ne 0 ]]; then
                src_colNo=`echo ${iproute_line} | awk '{ for (k=1; k<=NF; ++k) { if ($k ~ "src") print k } }'`	#get column number of "src"
                if [[ ${src_colNo} -ne 0 ]]; then
                    dev_colNo=$((dev_colNo+1))	#get nic column number
                    src_colNo=$((src_colNo+1))	#get ip address column number
                    nic_name=`echo ${iproute_line} | awk -v c=${dev_colNo} '{ print $c }'`	#get result on right-side of "dev"
                    ipv4Addr=`echo ${iproute_line} | awk -v c=${src_colNo} '{ print $c }'`	#get result on right-side of "src"
                    
                    #Check if 'nic_name' value is found in the 'docker network inspect bridge' result
                    nic_belongs_toDocker=$(docker network inspect bridge | grep '${nic_name}') 
                    if [[ -z ${nic_belongs_toDocker} ]]; then   #'nic_name' does not belong to 'docker'

                        container_ip_isValid=`ipv4_checkIf_address_isValid__func "${ipv4Addr}"`
                        if [[ ${container_ip_isValid} == ${TRUE} ]]; then  #'ip4addr' is valid
                            
                            #Check if 'ipv4Addr' is already added to 'docker__ipv4List_string'
                            ipv4Addr_isPresent=$(echo ${docker__ipv4List_string} | grep ${ipv4Addr})  
                            if [[ -z ${ipv4Addr_isPresent} ]]; then #'ipv4Addr' is unique
                                if [[ -z ${docker__ipv4List_string} ]]; then
                                    docker__ipv4List_string="${ipv4Addr}"
                                else
                                    docker__ipv4List_string="${docker__ipv4List_string} ${ipv4Addr}"
                                fi
                            fi
                        fi
                    fi		
                fi
            fi
        done

        #Convert to Array
        eval "docker__ipv4List_arr=(${docker__ipv4List_string})"
    fi
}

docker__ssh_handler__sub() {
    #Define local constants
    local SSH_PORT=10022

    #Define local menu constants
    local MENUTITLE="${DOCKER__GENERAL_FG_YELLOW}SSH${DOCKER__NOCOLOR} to a ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}"

    #Define local message constants
    local ERRMSG_INVALID_IPV4_FORMAT="${DOCKER__ERROR_FG_LIGHTRED}invalid ipv4-format${DOCKER__NOCOLOR}"
    local ERRMSG_NO_IP_ADDRESS_FOUND="=:${DOCKER__ERROR_FG_LIGHTRED}NO IP-ADDRESS FOUND${DOCKER__NOCOLOR}:="
    local ERRMSG_NOT_NUMERIC="${DOCKER__ERROR_FG_LIGHTRED}not numeric${DOCKER__NOCOLOR}"

    #Define local read-input message
    local READMSG_CONTAINER_IP="${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}-IP (e.g. 172.31.1.51): "
    local READMSG_CONTAINER_PORT="${DOCKER__PORTS_FG_LIGHTBLUE}Port${DOCKER__NOCOLOR} (e.g. 10022): "

    #Define local variables
    local container_ip=${DOCKER__EMPTYSTRING}
    local container_ip_isValid=${FALSE}
    local container_port=-1
    local container_port_isValid=${FALSE}
    local ipv4Addr=${DOCKER__EMPTYSTRING}


    #Show menu-title
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${MENUTITLE}"  "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Get Local IP-addresses
    #This function will output 2 global variables:
    #   docker__ipv4List_string
    #   docker__ipv4List_arr
    get_assigned_ipv4_addresses__func

    #Show list of ip-addreses
    if [[ ! -z ${docker__ipv4List_string} ]]; then  #ip-address found
        echo -e "List of Local IP-addresses:"
        for docker__ipv4List_arrItem in "${docker__ipv4List_arr[@]}"; do 
            echo -e "${DOCKER__FOURSPACES}${DOCKER__IP_FG_LIGHTCYAN}${docker__ipv4List_arrItem}${DOCKER__NOCOLOR}"
        done
        echo -e "\r"
    else    #no ip-address found
        echo -e "\r"
        show_centered_string__func "${ERRMSG_NO_IP_ADDRESS_FOUND}"  "${DOCKER__TABLEWIDTH}"
        echo -e "\r"
    fi

    #Input IP-address    
    while true
    do
        #Choose read-input command based on the 'docker__ipv4List_string' value
        if [[ ! -z ${docker__ipv4List_string} ]]; then
            read -e -p "${READMSG_CONTAINER_IP}" -i "${docker__ipv4List_arr[0]}" container_ip
        else
            read -e -p "${READMSG_CONTAINER_IP}" container_ip
        fi
        
        #Check if 'container_ip' is NOT an EMPTY STRING
        if [[ ! -z ${container_ip} ]]; then    #contains data
            container_ip_isValid=`ipv4_checkIf_address_isValid__func "${container_ip}"`
            if [[ ${container_ip_isValid} == ${TRUE} ]]; then  #ip-address is valid
                break
            else    #ip-address is valid
                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                echo -e "${READMSG_CONTAINER_IP}${container_ip} (${ERRMSG_INVALID_IPV4_FORMAT})"
            fi
        else    #contains no data
            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        fi
    done

    #Input Port-number
    while true
    do
        read -e -p "${READMSG_CONTAINER_PORT}" -i "${SSH_PORT}" container_port
        if [[ ! -z ${container_port} ]]; then    #contains data
            container_port_isValid=`isNumeric__func "${container_port}"`
            if [[ ${container_port_isValid} == ${TRUE} ]]; then  #ip-address is valid
                break
            else    #ip-address is valid
                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                echo -e "${READMSG_CONTAINER_PORT}${container_port} (${ERRMSG_NOT_NUMERIC})"
            fi
        else    #contains no data
            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        fi
    done


    #Print
    echo -e "\r"
    echo -e "---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Trying to establish an SSH-connection"
    echo -e "---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Please wait..."
    echo -e "\r"

    #Execute ssh-command
    #REMARK: 
    #   -o AddKeysToAgent=yes: this switch is used to bypass the error message:
    #   'The authenticity of host '[172.17.0.1]:10022 ([172.17.0.1]:10022)' can't be established...etc'
    ssh -o AddKeysToAgent=yes root@${container_ip} -p ${container_port}

    #Print an empty-line
    echo -e "\r"
}
function ipv4_checkIf_address_isValid__func()
{
    #Input args
    local ipv4Addr=${1}

    #Define local variables
    local ipv4Addr_array=()
    local ipv4Addr_arrayItem=${DOCKER__EMPTYSTRING}
    local ipv4Addr_subst=${DOCKER__EMPTYSTRING}
    local regEx=${DOCKER__EMPTYSTRING}
    local isValid=${FALSE}

    #Regular expression
    regEx="^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$"

    #'ipv4Addr' could contain multiple ip-addresses,...
    #...where each ip-address are separated from each other by a comma,...
    #In order to convert 'string' to 'array',...
    #...substitute 'comma' with 'space'
    ipv4Addr_subst=`ipv46_subst_comma_with_space__func "${ipv4Addr}"`

    #Convert from String to Array
    eval "ipv4Addr_array=(${ipv4Addr_subst})"

    #Check if ip-address is valid
    for ipv4Addr_arrayItem in "${ipv4Addr_array[@]}"
    do
        if [[ "${ipv4Addr_arrayItem}" =~ ${regEx} ]]; then  #ip-address is valid
            isValid=${TRUE}
        else    #ip-address is NOT valid
            isValid=${FALSE}

            break  #as soon as an Invalid ip-address input is found, exit loop
        fi
    done

    #Output
    echo ${isValid}
}
function ipv46_subst_comma_with_space__func()
{
    #Input args
    local address=${1}

    #Subsitute MULTIPLE SPACES with ONE SPACE
    local address_subst=`echo ${address} | sed "s/${DOCKER__COMMA_CHAR}/${DOCKER__ONESPACE}/g"`

    #Output
    echo ${address_subst}    
}



#---MAIN SUBROUTINE
main_sub() {
    docker__load_header__sub

    docker__init_variables__sub

    docker__ssh_handler__sub
}



#EXECUTE
main_sub
