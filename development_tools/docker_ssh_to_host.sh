#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---FUNCTIONS
function isNumeric__func()
{
    #Input args
    local inputVar=${1}

    #Define local variables
    local regEx="^\-?[0-9]*\.?[0-9]+$"
    local stdOutput=${DOCKER__EMPTYSTRING}

    #Check if numeric
    #If DOCKER__TRUE, then 'stdOutput' is NOT EMPTY STRING
    stdOutput=`echo "${inputVar}" | grep -E "${regEx}"`

    if [[ ! -z ${stdOutput} ]]; then    #contains data
        echo ${DOCKER__TRUE}
    else    #contains NO data
        echo ${DOCKER__FALSE}
    fi
}



#---SUBROUTINES
docker__get_source_fullpath__sub() {
    docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})
    if [[ ${docker__current_dir} == ${DOCKER__DOT} ]]; then
        docker__current_dir=$(pwd)
    fi
	docker__current_folder=`basename ${docker__current_dir}`

    docker__development_tools_folder="development_tools"
    if [[ ${docker__current_folder} != ${docker__development_tools_folder} ]]; then
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}/${docker__development_tools_folder}
    else
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}
    fi

    docker__global__filename="docker_global.sh"
    docker__global__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global__filename}
}

docker__load_source_files__sub() {
    source ${docker__global__fpath}
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
    local container_ip_isValid=${DOCKER__FALSE}
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
                        if [[ ${container_ip_isValid} == ${DOCKER__TRUE} ]]; then  #'ip4addr' is valid
                            
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
    local MENUTITLE="${DOCKER__FG_YELLOW}SSH${DOCKER__NOCOLOR} to a ${DOCKER__FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}"

    #Define local message constants
    local ERRMSG_INVALID_IPV4_FORMAT="${DOCKER__FG_LIGHTRED}invalid ipv4-format${DOCKER__NOCOLOR}"
    local ERRMSG_NO_IP_ADDRESS_FOUND="=:${DOCKER__FG_LIGHTRED}NO IP-ADDRESS FOUND${DOCKER__NOCOLOR}:="
    local ERRMSG_NOT_NUMERIC="${DOCKER__FG_LIGHTRED}not numeric${DOCKER__NOCOLOR}"

    #Define local read-input message
    local READMSG_CONTAINER_IP="${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}-IP (e.g. 172.31.1.51): "
    local READMSG_CONTAINER_PORT="${DOCKER__FG_LIGHTBLUE}Port${DOCKER__NOCOLOR} (e.g. 10022): "

    #Define local variables
    local container_ip=${DOCKER__EMPTYSTRING}
    local container_ip_isValid=${DOCKER__FALSE}
    local container_port=-1
    local container_port_isValid=${DOCKER__FALSE}
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
            echo -e "${DOCKER__FOURSPACES}${DOCKER__FG_LIGHTCYAN}${docker__ipv4List_arrItem}${DOCKER__NOCOLOR}"
        done
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    else    #no ip-address found
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        show_centered_string__func "${ERRMSG_NO_IP_ADDRESS_FOUND}"  "${DOCKER__TABLEWIDTH}"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
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
            if [[ ${container_ip_isValid} == ${DOCKER__TRUE} ]]; then  #ip-address is valid
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
            if [[ ${container_port_isValid} == ${DOCKER__TRUE} ]]; then  #ip-address is valid
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
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Trying to establish an SSH-connection"
    echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Please wait..."
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    #Execute ssh-command
    #REMARK: 
    #   -o AddKeysToAgent=yes: this switch is used to bypass the error message:
    #   'The authenticity of host '[172.17.0.1]:10022 ([172.17.0.1]:10022)' can't be established...etc'
    ssh -o AddKeysToAgent=yes root@${container_ip} -p ${container_port}

    #Print an empty-line
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
}
function ipv4_checkIf_address_isValid__func() {
    #Input args
    local ipv4Addr=${1}

    #Define local variables
    local ipv4Addr_array=()
    local ipv4Addr_arrayItem=${DOCKER__EMPTYSTRING}
    local ipv4Addr_subst=${DOCKER__EMPTYSTRING}
    local regEx=${DOCKER__EMPTYSTRING}
    local isValid=${DOCKER__FALSE}

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
            isValid=${DOCKER__TRUE}
        else    #ip-address is NOT valid
            isValid=${DOCKER__FALSE}

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
    local address_subst=`echo ${address} | sed "s/${DOCKER__COMMA}/${DOCKER__ONESPACE}/g"`

    #Output
    echo ${address_subst}    
}



#---MAIN SUBROUTINE
main_sub() {
    docker__get_source_fullpath__sub

    docker__load_source_files__sub

    load_tibbo_title__func "${DOCKER__NUMOFLINES_2}"

    docker__init_variables__sub

    docker__ssh_handler__sub
}



#EXECUTE
main_sub
