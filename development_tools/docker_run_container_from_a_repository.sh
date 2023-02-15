#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---NUMERIC CONSTANTS
DOCKER__SSH_LOCALPORT=10022
DOCKER__SSH_PORT=22



#---FUNCTIONS
function checkIf_repoTag_isUniq__func() {
    #Input args
    local repoName__input=${1}
    local tag__input=${2}

    #Define variables
    local dataArr=()
    local dataArr_item=${DOCKER__EMPTYSTRING}
    local stdOutput1=${DOCKER__EMPTYSTRING}
    local stdOutput2=${DOCKER__EMPTYSTRING}

    #Write 'docker images' command output to array
    readarray dataArr <<< $(docker images)

    #Check if repository:tag is unique
    local ret=true

    for dataArr_item in "${dataArr[@]}"
    do                                                      
        stdOutput1=`echo ${dataArr_item} | awk '{print $1}' | grep -w "${repoName__input}"`
        if [[ ! -z ${stdOutput1} ]]; then
            stdOutput2=`echo ${dataArr_item} | awk '{print $2}' | grep -w "${tag__input}"`
            if [[ ! -z ${stdOutput2} ]]; then
                ret=false

                break
            fi
        fi                                             
    done

    #Output
    echo "${ret}"
}

function cmd_was_executed_successfully__func() {
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
        echo failed
    fi
}

function get_available_localport__func() {
    local ssh_localport=${DOCKER__SSH_LOCALPORT}    #initial value
    local pattern=${DOCKER__EMPTYSTRING}
    local localport_isUnique=${DOCKER__EMPTYSTRING}

    while true
    do
        #Define search pattern (e.g. 10022->22)
        search_pattern="${ssh_localport}->22"
        
        #Check if 'search_pattern' can be found in 'docker image ls'
        localport_isUnique=`docker container ls | grep ${search_pattern}`
        if [[ -z ${localport_isUnique} ]]; then #match was NOT found
            docker__ssh_localport=${ssh_localport}   #set value for 'docker__ssh_localport'

            break   #exit loop
        else    #match was found
            ssh_localport=$((ssh_localport+1))  #define a new value for 'ssh_localport'
        fi
    done
}

function get_assigned_ipv4_addresses__func() {
    #Define local constants
    local ERRMSG_NO_IP_ADDRESS_FOUND="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: no ip-address found"

    #Define local variabes
    local iproute_line=${DOCKER__EMPTYSTRING}
    local dev_colno=0
    local src_colno=0
    local nic_name=${DOCKER__EMPTYSTRING}
    local ipv4addr=${DOCKER__EMPTYSTRING}
    local ipv4addr_isPresent=${DOCKER__EMPTYSTRING}
    local nic_belongs_toDocker=${DOCKER__EMPTYSTRING}
    local numOf_iproute_results=0
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
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "${ERRMSG_NO_IP_ADDRESS_FOUND}"    
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
    fi
}



#---SUBROUTINES
docker__get_source_fullpath__sub() {
    #Check the number of input args
    if [[ -z ${docker__global__fpath} ]]; then   #must be equal to 3 input args
        #---Defin FOLDER
        docker__LTPP3_ROOTFS__foldername="LTPP3_ROOTFS"
        docker__development_tools__foldername="development_tools"

        #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
        #... and read to array 'find_result_arr'
        #Remark:
        #   By using '2> /dev/null', the errors are not shown.
        readarray -t find_dir_result_arr < <(find  / -type d -iname "${docker__LTPP3_ROOTFS__foldername}" 2> /dev/null)

        #Define variable
        local find_path_of_LTPP3_ROOTFS=${DOCKER__EMPTYSTRING}

        #Loop thru array-elements
        for find_dir_result_arrItem in "${find_dir_result_arr[@]}"
        do
            #Update variable 'find_path_of_LTPP3_ROOTFS'
            find_path_of_LTPP3_ROOTFS="${find_dir_result_arrItem}/${docker__development_tools__foldername}"
            #Check if 'directory' exist
            if [[ -d "${find_path_of_LTPP3_ROOTFS}" ]]; then    #directory exists
                #Update variable
                docker__LTPP3_ROOTFS_development_tools__dir="${find_path_of_LTPP3_ROOTFS}"

                break
            fi
        done

        docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/
        docker__parentDir_of_LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS__dir%/*}    #move two directories up. This directory is the one-level higher than LTPP3_ROOTFS/

        docker__global__filename="docker_global.sh"
        docker__global__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__global__filename}
    fi
}

docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

docker__init_variables__sub() {
    docker__exitCode=0
    docker__ipv4_addr=${DOCKER__EMPTYSTRING}
    docker__ipv4_addr_summarize_str=${DOCKER__EMPTYSTRING}
    docker__ipv4_addr_summarize_arr=()
    docker__ssh_localport=${DOCKER__SSH_LOCALPORT}


    #Newly Added (not in use yet)
    docker__imageID_chosen=${DOCKER__EMPTYSTRING}
    docker__repo_chosen=${DOCKER__EMPTYSTRING}
    docker__tag_chosen=${DOCKER__EMPTYSTRING}
    docker__repoTag_chosen=${DOCKER__EMPTYSTRING}

    # docker__images_cmd="docker images"
    # docker__ps_a_cmd="docker ps -a"

    # docker__images_repoColNo=1
    # docker__images_tagColNo=2
    # docker__images_IDColNo=3

    docker__onEnter_breakLoop=false
    docker__showTable=true
}

docker__run_container_handler__sub() {
    #Define phase constants
    local IMAGEID_SELECT_PHASE=0
    local REPOTAG_RETRIEVE_PHASE=1
    local RUN_CONTAINER_PHASE=2

    #Define message constants
    local MENUTITLE="Run ${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR} from specfied ${DOCKER__FG_PURPLE}Repository${DOCKER__NOCOLOR}"

    #Define variables
    local containerName=${DOCKER__EMPTYSTRING}
    local errMsg=${DOCKER__EMPTYSTRING}
    local phase=${DOCKER__EMPTYSTRING}
    local readmsg_remarks=${DOCKER__EMPTYSTRING}



    #Set 'readmsg_remarks'
    readmsg_remarks="${DOCKER__BG_ORANGE}Remarks:${DOCKER__NOCOLOR}\n"
    readmsg_remarks+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}Up/Down Arrow${DOCKER__NOCOLOR}: to cycle thru existing values\n"
    readmsg_remarks+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}TAB${DOCKER__NOCOLOR}: auto-complete\n"
    readmsg_remarks+="${DOCKER__DASH} ${DOCKER__FG_YELLOW};c${DOCKER__NOCOLOR}: clear"

    #Set initial 'phase'
    phase=${IMAGEID_SELECT_PHASE}
    while true
    do
        case "${phase}" in
            ${IMAGEID_SELECT_PHASE})
                ${docker__readInput_w_autocomplete__fpath} "${MENUTITLE}" \
                                    "${DOCKER__READINPUTDIALOG_CHOOSE_IMAGEID_FROM_LIST}" \
                                    "${DOCKER__EMPTYSTRING}" \
                                    "${readmsg_remarks}" \
                                    "${DOCKER__ERRMSG_NO_IMAGES_FOUND}" \
                                    "${DOCKER__ERRMSG_CHOSEN_IMAGEID_DOESNOT_EXISTS}" \
                                    "${docker__images_cmd}" \
                                    "${docker__images_IDColNo}" \
                                    "${DOCKER__EMPTYSTRING}" \
                                    "${docker__showTable}" \
                                    "${docker__onEnter_breakLoop}" \
                                    "${DOCKER__NUMOFLINES_2}"

                #Get the exit-code just in case:
                #   1. Ctrl-C was pressed in script 'docker__readInput_w_autocomplete__fpath'.
                #   2. An error occured in script 'docker__readInput_w_autocomplete__fpath',...
                #      ...and exit-code = 99 came from function...
                #      ...'show_msg_w_menuTitle_w_pressAnyKey_w_ctrlC_func' (in script: docker__global.sh).
                docker__exitCode=$?
                if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
                    exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_0}"
                else
                    #Retrieve the 'new tag' from file
                    docker__imageID_chosen=`get_output_from_file__func \
                                "${docker__readInput_w_autocomplete_out__fpath}" \
                                "${DOCKER__LINENUM_1}"`
                fi

                #Check if output is an Empty String
                if [[ -z ${docker__imageID_chosen} ]]; then
                    return
                else
                    phase=${REPOTAG_RETRIEVE_PHASE}
                fi
                ;;
            ${REPOTAG_RETRIEVE_PHASE})
                #This subroutine outputs:
                #   1. docker__repo_chosen
                #   2. docker__tag_chosen
                #Remark:
                #   If variable 'docker__repo_chosen' or 'docker__tag_chosen' is an Empty String, then exit this function.
                docker__get_and_check_repoTag__sub
                if [[ -z ${docker__repo_chosen} ]] || \
                            [[ -z ${docker__tag_chosen} ]]; then
                    return
                elif [[ ${docker__repo_chosen} == ${DOCKER__NONE} ]] || \
                            [[ ${docker__tag_chosen} == ${DOCKER__NONE} ]]; then
                    errMsg="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Incomplete image '${docker__imageID_chosen}'"
                    show_msg_wo_menuTitle_w_PressAnyKey__func "${errMsg}" \
                                "${DOCKER__NUMOFLINES_0}" \
                                "${DOCKER__TIMEOUT_10}" \
                                "${DOCKER__NUMOFLINES_1}" \
                                "${DOCKER__NUMOFLINES_3}"
                    return
                else
                    phase=${RUN_CONTAINER_PHASE}
                fi
                
                ;;
            ${RUN_CONTAINER_PHASE})
                docker__run_container__sub
                
                return
                ;;
        esac
    done

}

docker__run_container__sub() {
    #Get an unused value for the 'docker__ssh_localport'
    #Note: 
    #   function 'get_available_localport__func' does NOT have an output, instead...
    #   ....'docker__ssh_localport' is set in this function
    get_available_localport__func

    #Define Container Name
    local container_label="containerOf__${docker__imageID_chosen}_p${docker__ssh_localport}"

    #Combine 'myRepository' and 'myTag', but separated by a colon ':'
    docker__repoTag_chosen="${docker__repo_chosen}:${docker__tag_chosen}"

    #Run Container of the specified Image-ID
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    docker run -d -p ${docker__ssh_localport}:${DOCKER__SSH_PORT} --name ${container_label} ${docker__repoTag_chosen} > /dev/null

    #Check if docker__exitCode=0
    docker__exitCode=$? #get docker__exitCode
    if [[ ${docker__exitCode} -eq 0 ]]; then    #docker__exitCode=0, which means that command was executed successfully
        #Define message constants
        local MENUTITLE_UPDATED_CONTAINER_LIST="Updated ${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}-list"

        #Show Container's list
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        show_repoList_or_containerList_w_menuTitle__func "${MENUTITLE_UPDATED_CONTAINER_LIST}" "${docker__ps_a_cmd}"

        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        local echomsg1="Summary:\n"
        echomsg1+="\tChosen Repository:\t\t\t${DOCKER__FG_PURPLE}${myRepository}${DOCKER__NOCOLOR}\n"
        echomsg1+="\tCreated Container-ID:\t\t\t${DOCKER__FG_BRIGHTPRUPLE}${containerName}${DOCKER__NOCOLOR}\n"
        echomsg1+="\tTCP-port to-used-for SSH:\t\t${DOCKER__FG_LIGHTBLUE}${docker__ssh_localport}${DOCKER__NOCOLOR}\n"
        echo -e "${echomsg1}"

        get_assigned_ipv4_addresses__func
        
        local echomsg2="\tAvailable ip-address(es) for SSH:"
        echo -e "${echomsg2}"
        for ipv4 in "${docker__ipv4_addr_summarize_arr[@]}"; do 
            echo -e "\t\t\t\t\t\t${DOCKER__FG_LIGHTCYAN}${ipv4}${DOCKER__NOCOLOR}"
        done
        
        # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"


        #Show EXAMPLE OF HOW TO SSH FROM a REMOTE PC
        docker__ipv4_addr=$(cut -d" " -f1 <<< ${docker__ipv4_addr_summarize_str})
        local echomsg3="How to SSH from a remote PC?\n"
        echomsg3="\tDefault login/pass: ${DOCKER__FG_YELLOW}root/root${DOCKER__NOCOLOR}\n"
        echomsg3+="\tSample:\n"
        echomsg3+="\t\tssh ${DOCKER__FG_YELLOW}root${DOCKER__NOCOLOR}@${DOCKER__FG_LIGHTCYAN}${docker__ipv4_addr}${DOCKER__NOCOLOR} -p ${DOCKER__FG_LIGHTBLUE}${docker__ssh_localport}${DOCKER__NOCOLOR}\n"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e ${echomsg3}
        # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        
        exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_0}"
    # else
    #     break
    fi
}

docker__get_and_check_repoTag__sub() {
    #Define message constants
    local ERRMSG_NO_REPO_FOUND="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: No matching ${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR} found for ${DOCKER__FG_BORDEAUX}ID${DOCKER__NOCOLOR} '${DOCKER__FG_LIGHTGREY}${docker__imageID_chosen}${DOCKER__NOCOLOR}'"
    local ERRMSG_NO_TAG_FOUND="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: No matching ${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} found for ${DOCKER__FG_BORDEAUX}ID${DOCKER__NOCOLOR} '${DOCKER__FG_LIGHTGREY}${docker__imageID_chosen}${DOCKER__NOCOLOR}'"
    local ERRMSG_NO_REPO_TAG_FOUND="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: No matching ${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR} and ${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} found for ${DOCKER__FG_BORDEAUX}ID${DOCKER__NOCOLOR} '${DOCKER__FG_LIGHTGREY}${docker__imageID_chosen}${DOCKER__NOCOLOR}'"

    #Get repository
    docker__repo_chosen=`${docker__images_cmd} | grep -w ${docker__imageID_chosen} | awk -vcolNo=${docker__images_repoColNo} '{print $colNo}'`

    #Get tag
    docker__tag_chosen=`${docker__images_cmd} | grep -w ${docker__imageID_chosen} | awk -vcolNo=${docker__images_tagColNo} '{print $colNo}'`

    #Check if any of the value is an Empty String
    if [[ -z ${docker__repo_chosen} ]] && [[ -z ${docker__tag_chosen} ]]; then
        show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_NO_REPO_TAG_FOUND}" "${DOCKER__NUMOFLINES_2}"
    else
        if [[ -z ${docker__repo_chosen} ]]; then
            show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_NO_REPO_FOUND}" "${DOCKER__NUMOFLINES_2}"
        fi

        if [[ -z ${docker__tag_chosen} ]]; then
            show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_NO_TAG_FOUND}" "${DOCKER__NUMOFLINES_2}"
        fi
    fi
}



#---MAIN SUBROUTINE
main_sub() {
    docker__get_source_fullpath__sub

    docker__load_source_files__sub

    docker__init_variables__sub

    docker__run_container_handler__sub
}



#---EXECUTE
main_sub
