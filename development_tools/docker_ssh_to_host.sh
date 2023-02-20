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
    #Define constants
    local DOCKER__PHASE_CHECK_CACHE=1
    local DOCKER__PHASE_FIND_PATH=10
    local DOCKER__PHASE_EXIT=100

    #Define variables
    local docker__phase=""

    local docker__current_dir=
    local docker__tmp_dir=""

    local docker__development_tools__foldername=""
    local docker__LTPP3_ROOTFS__foldername=""
    local docker__global__filename=""
    local docker__parentDir_of_LTPP3_ROOTFS__dir=""

    local docker__mainmenu_path_cache__filename=""
    local docker__mainmenu_path_cache__fpath=""

    local docker__find_dir_result_arr=()
    local docker__find_dir_result_arritem=""
    local docker__find_dir_result_arrlen=0
    local docker__find_dir_result_arrlinectr=0
    local docker__find_dir_result_arrprogressperc=0

    local docker__path_of_development_tools_found=""
    local docker__parentpath_of_development_tools=""

    local docker__isfound=""

    #Set variables
    docker__phase="${DOCKER__PHASE_CHECK_CACHE}"
    docker__current_dir=$(dirname $(readlink -f $0))
    docker__tmp_dir=/tmp
    docker__development_tools__foldername="development_tools"
    docker__global__filename="docker_global.sh"
    docker__LTPP3_ROOTFS__foldername="LTPP3_ROOTFS"

    docker__mainmenu_path_cache__filename="docker__mainmenu_path.cache"
    docker__mainmenu_path_cache__fpath="${docker__tmp_dir}/${docker__mainmenu_path_cache__filename}"

    docker_result=false

    #Start loop
    while true
    do
        case "${docker__phase}" in
            "${DOCKER__PHASE_CHECK_CACHE}")
                if [[ -f "${docker__mainmenu_path_cache__fpath}" ]]; then
                    #Get the directory stored in cache-file
                    docker__LTPP3_ROOTFS_development_tools__dir=$(awk 'NR==1' "${docker__mainmenu_path_cache__fpath}")

                    #Move one directory up
                    docker__parentpath_of_development_tools=$(dirname "${docker__LTPP3_ROOTFS_development_tools__dir}")

                    #Check if 'development_tools' is in the 'LTPP3_ROOTFS' folder
                    docker__isfound=$(docker__checkif_paths_are_related "${docker__current_dir}" \
                            "${docker__parentpath_of_development_tools}" "${docker__LTPP3_ROOTFS__foldername}")
                    if [[ ${docker__isfound} == false ]]; then
                        docker__phase="${DOCKER__PHASE_FIND_PATH}"
                    else
                        docker_result=true

                        docker__phase="${DOCKER__PHASE_EXIT}"
                    fi
                else
                    docker__phase="${DOCKER__PHASE_FIND_PATH}"
                fi
                ;;
            "${DOCKER__PHASE_FIND_PATH}")   
                #Print
                echo -e "---:\e[30;38;5;215mSTART\e[0;0m: find path of folder \e[30;38;5;246m'${docker__development_tools__foldername}\e[0;0m : \e[1;33mDONE\e[0;0m"

                #Reset variable
                docker__LTPP3_ROOTFS_development_tools__dir=""

                #Start loop
                while true
                do
                    #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
                    #... and read to array 'find_result_arr'
                    readarray -t docker__find_dir_result_arr < <(find  / -type d -iname "${docker__LTPP3_ROOTFS__foldername}" 2> /dev/null)

                    #Get array-length
                    docker__find_dir_result_arrlen=${#docker__find_dir_result_arr[@]}

                    #Iterate thru each array-item
                    for docker__find_dir_result_arritem in "${docker__find_dir_result_arr[@]}"
                    do
                        docker__isfound=$(docker__checkif_paths_are_related "${docker__current_dir}" \
                                "${docker__find_dir_result_arritem}"  "${docker__LTPP3_ROOTFS__foldername}")
                        if [[ ${docker__isfound} == true ]]; then
                            #Update variable 'docker__path_of_development_tools_found'
                            docker__path_of_development_tools_found="${docker__find_dir_result_arritem}/${docker__development_tools__foldername}"

                            # #Increment counter
                            docker__find_dir_result_arrlinectr=$((docker__find_dir_result_arrlinectr+1))

                            #Calculate the progress percentage value
                            docker__find_dir_result_arrprogressperc=$(( docker__find_dir_result_arrlinectr*100/docker__find_dir_result_arrlen ))

                            #Moveup and clean
                            if [[ ${docker__find_dir_result_arrlinectr} -gt 1 ]]; then
                                tput cuu1
                                tput el
                            fi

                            #Print
                            #Note: do not print the '100%'
                            if [[ ${docker__find_dir_result_arrlinectr} -lt ${docker__find_dir_result_arrlen} ]]; then
                                echo -e "------:PROGRESS: ${docker__find_dir_result_arrprogressperc}%"
                            fi

                            #Check if 'directory' exist
                            if [[ -d "${docker__path_of_development_tools_found}" ]]; then    #directory exists
                                #Update variable
                                #Remark:
                                #   'docker__LTPP3_ROOTFS_development_tools__dir' is a global variable.
                                #   This variable will be passed 'globally' to script 'docker_global.sh'.
                                docker__LTPP3_ROOTFS_development_tools__dir="${docker__path_of_development_tools_found}"

                                #Print
                                #Note: print the '100%' here
                                echo -e "------:PROGRESS: 100%"

                                break
                            fi
                        fi
                    done

                    #Check if 'docker__LTPP3_ROOTFS_development_tools__dir' contains any data
                    if [[ -z "${docker__LTPP3_ROOTFS_development_tools__dir}" ]]; then  #contains no data
                        echo -e "\r"
                        echo -e "***\e[1;31mERROR\e[0;0m: folder \e[30;38;5;246m${docker__development_tools__foldername}\e[0;0m: \e[30;38;5;131mNot Found\e[0;0m"
                        echo -e "\r"

                         #Update variable
                        docker_result=false
                    else    #contains data
                        #Print
                        echo -e "---:\e[30;38;5;215mCOMPLETED\e[0;0m: find path of folder \e[30;38;5;246m'${docker__development_tools__foldername}\e[0;0m : \e[1;33mDONE\e[0;0m"


                        #Write to file
                        echo "${docker__LTPP3_ROOTFS_development_tools__dir}" | tee "${docker__mainmenu_path_cache__fpath}" >/dev/null

                        #Print
                        echo -e "---:\e[30;38;5;215mSTATUS\e[0;0m: write path to temporary cache-file: \e[1;33mDONE\e[0;0m"

                        #Update variable
                        docker_result=true
                    fi

                    #set phase
                    docker__phase="${DOCKER__PHASE_EXIT}"

                    #Exit loop
                    break
                done
                ;;    
            "${DOCKER__PHASE_EXIT}")
                break
                ;;
        esac
    done

    #Exit if 'docker_result = false'
    if [[ ${docker_result} == false ]]; then
        exit 99
    fi

    #Retrieve directories
    #Remark:
    #   'docker__LTPP3_ROOTFS__dir' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/
    docker__parentDir_of_LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS__dir%/*}    #move two directories up. This directory is the one-level higher than LTPP3_ROOTFS/

    #Get full-path
    #Remark:
    #   'docker__global__fpath' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__global__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__global__filename}
}
docker__checkif_paths_are_related() {
    #Input args
    local scriptdir__input=${1}
    local finddir__input=${2}
    local pattern__input=${3}

    #Define constants
    local PHASE_PATTERN_CHECK1=1
    local PHASE_PATTERN_CHECK2=10
    local PHASE_PATH_COMPARISON=20
    local PHASE_EXIT=100

    #Define variables
    local phase="${PHASE_PATTERN_CHECK1}"
    local isfound1=""
    local isfound2=""
    local isfound3=""
    local ret=false

    while true
    do
        case "${phase}" in
            "${PHASE_PATTERN_CHECK1}")
                #Check if 'pattern__input' is found in 'scriptdir__input'
                isfound1=$(echo "${scriptdir__input}" | \
                        grep -o "${pattern__input}.*" | \
                        cut -d"/" -f1 | grep -w "^${pattern__input}$")
                if [[ -z "${isfound1}" ]]; then
                    ret=false

                    phase="${PHASE_EXIT}"
                else
                    phase="${PHASE_PATTERN_CHECK2}"
                fi                
                ;;
            "${PHASE_PATTERN_CHECK2}")
                #Check if 'pattern__input' is found in 'finddir__input'
                isfound2=$(echo "${finddir__input}" | \
                        grep -o "${pattern__input}.*" | \
                        cut -d"/" -f1 | grep -w "^${pattern__input}$")
                if [[ -z "${isfound2}" ]]; then
                    ret=false

                    phase="${PHASE_EXIT}"
                else
                    phase="${PHASE_PATH_COMPARISON}"
                fi                
                ;;
            "${PHASE_PATH_COMPARISON}")
                #Check if 'development_tools' is under the folder 'LTPP3_ROOTFS'
                isfound3=$(echo "${scriptdir__input}" | \
                        grep -w "${finddir__input}.*")
                if [[ -z "${isfound3}" ]]; then
                    ret=false
                else
                    ret=true
                fi

                phase="${PHASE_EXIT}"
                ;;
            "${PHASE_EXIT}")
                break
                ;;
        esac
    done

    #Output
    echo "${ret}"

    return 0
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
