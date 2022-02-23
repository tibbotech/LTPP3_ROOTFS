#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---COLOR CONSTANTS
DOCKER__NOCOLOR=$'\e[0m'
DOCKER__CONTAINER_FG_BRIGHTPRUPLE=$'\e[30;38;5;141m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__FG_ORANGE=$'\e[30;38;5;215m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__IP_FG_LIGHTCYAN=$'\e[1;36m'
DOCKER__PORTS_FG_LIGHTBLUE=$'\e[1;34m'
DOCKER__REPOSITORY_FG_PURPLE=$'\e[30;38;5;93m'
DOCKER__SUCCESS_FG_LIGHTGREEN=$'\e[1;32m'
DOCKER__TAG_FG_LIGHTPINK=$'\e[30;38;5;218m'

DOCKER__REMARK_BG_ORANGE=$'\e[30;48;5;208m'
DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'
DOCKER__TITLE_BG_LIGHTBLUE=$'\e[30;48;5;45m'

#---CONSTANTS
DOCKER__TITLE="TIBBO"

DOCKER__SSH_LOCALPORT=10022
DOCKER__SSH_PORT=22

#---CHARACTER CHONSTANTS
DOCKER__DASH="-"
DOCKER__EMPTYSTRING=""

DOCKER__ONESPACE=" "
DOCKER__TWOSPACES=${DOCKER__ONESPACE}${DOCKER__ONESPACE}
DOCKER__FOURSPACES=${DOCKER__TWOSPACES}${DOCKER__TWOSPACES}

#---NUMERIC CONSTANTS
DOCKER__TABLEWIDTH=70

DOCKER__NUMOFLINES_1=1
DOCKER__NUMOFLINES_2=2
DOCKER__NUMOFLINES_3=3
DOCKER__NUMOFLINES_4=4
DOCKER__NUMOFLINES_5=5
DOCKER__NUMOFLINES_6=6

#---MENU CONSTANTS
DOCKER__CTRL_C_QUIT="${DOCKER__FOURSPACES}Quit (Ctrl+C)"



#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C_func INT



#---FUNCTIONS
function CTRL_C_func() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
    
    exit
}

function press_any_key__func() {
	#Define constants
	local ANYKEY_TIMEOUT=10

	#Initialize variables
	local keypressed=""
	local tcounter=0

	#Show Press Any Key message with count-down
	moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
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
	moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
}

function exit__func() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

    exit
}

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
    local ERRMSG_NO_IP_ADDRESS_FOUND="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: no ip-address found"

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

function get_output_from_file__func() {
    #Read from file
    if [[ -f ${docker__readInput_w_autocomplete_out__fpath} ]]; then
        ret=`cat ${docker__readInput_w_autocomplete_out__fpath} | head -n1 | xargs`
    else
        ret=${DOCKER__EMPTYSTRING}
    fi

    #Output
    echo ${ret}
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

function show_errMsg_without_menuTitle__func() {
    #Input args
    local errMsg=${1}

    # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${errMsg}"

    press_any_key__func
}

function show_list_with_menuTitle__func() {
    #Input args
    local menuTitle=${1}
    local dockerCmd=${2}

    #Show list
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${menuTitle}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    
    if [[ ${dockerCmd} == ${docker__ps_a_cmd} ]]; then
        ${docker__containerlist_tableinfo_fpath}
    else
        ${docker__repolist_tableinfo_fpath}
    fi

    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${DOCKER__CTRL_C_QUIT}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
}



#---SUBROUTINES
docker__load_environment_variables__sub() {
    #---Define PATHS
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

    docker__global_functions_filename="docker_global_functions.sh"
    docker__global_functions_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global_functions_filename}

    docker__containerlist_tableinfo_filename="docker_containerlist_tableinfo.sh"
    docker__containerlist_tableinfo_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__containerlist_tableinfo_filename}
	docker__repolist_tableinfo_filename="docker_repolist_tableinfo.sh"
	docker__repolist_tableinfo_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__repolist_tableinfo_filename}

    docker_readInput_w_autocomplete_filename="docker_readInput_w_autocomplete.sh"
    docker_readInput_w_autocomplete_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker_readInput_w_autocomplete_filename}

    docker__tmp_dir=/tmp
    docker__readInput_w_autocomplete_out__filename="docker__readInput_w_autocomplete.out"
    docker__readInput_w_autocomplete_out__fpath=${docker__tmp_dir}/${docker__readInput_w_autocomplete_out__filename}
}

docker__load_source_files__sub() {
    source ${docker__global_functions_fpath}
}

docker__load_header__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${DOCKER__TITLE_BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__TITLE_BG_ORANGE}                                ${DOCKER__NOCOLOR}"
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

    docker__images_cmd="docker images"
    docker__ps_a_cmd="docker ps -a"

    docker__images_repoColNo=1
    docker__images_tagColNo=2
    docker__images_IDColNo=3

    docker__onEnter_breakLoop=false
    docker__showTable=true
}

docker__run_container_handler__sub() {
    #Define phase constants
    local IMAGEID_SELECT_PHASE=0
    local REPOTAG_RETRIEVE_PHASE=1
    local RUN_CONTAINER_PHASE=2

    #Define message constants
    local MENUTITLE="Run ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR} from specfied ${DOCKER__REPOSITORY_FG_PURPLE}Repository${DOCKER__NOCOLOR}"

    local READMSG_CHOOSE_IMAGEID_FROM_LIST="Choose an ${DOCKER__IMAGEID_FG_BORDEAUX}Image-ID${DOCKER__NOCOLOR} from list (e.g. 0f7478cf7cab): "

    local ERRMSG_NO_IMAGES_FOUND="=:${DOCKER__ERROR_FG_LIGHTRED}NO IMAGES FOUND${DOCKER__NOCOLOR}:="
    local ERRMSG_CHOSEN_IMAGEID_DOESNOT_EXISTS="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: chosen ${DOCKER__IMAGEID_FG_BORDEAUX}Image-ID${DOCKER__NOCOLOR} does NOT exist"

    #Define variables
    local containerName=${DOCKER__EMPTYSTRING}
    local errMsg=${DOCKER__EMPTYSTRING}
    local phase=${DOCKER__EMPTYSTRING}
    local readmsg_remarks=${DOCKER__EMPTYSTRING}



    #Set 'readmsg_remarks'
    readmsg_remarks="${DOCKER__REMARK_BG_ORANGE}Remarks:${DOCKER__NOCOLOR}\n"
    readmsg_remarks+="${DOCKER__DASH} Up/Down arrow: to cycle thru existing values\n"
    readmsg_remarks+="${DOCKER__DASH} TAB: auto-complete"

    #Set initial 'phase'
    phase=${IMAGEID_SELECT_PHASE}
    while true
    do
        case "${phase}" in
            ${IMAGEID_SELECT_PHASE})
                ${docker_readInput_w_autocomplete_fpath} "${MENUTITLE}" \
                                    "${READMSG_CHOOSE_IMAGEID_FROM_LIST}" \
                                    "${readmsg_remarks}" \
                                    "${DOCKER__EMPTYSTRING}" \
                                    "${ERRMSG_NO_IMAGES_FOUND}" \
                                    "${ERRMSG_CHOSEN_IMAGEID_DOESNOT_EXISTS}" \
                                    "${docker__images_cmd}" \
                                    "${docker__images_IDColNo}" \
                                    "${DOCKER__EMPTYSTRING}" \
                                    "${docker__showTable}" \
                                    "${docker__onEnter_breakLoop}"

                #Retrieve the selected container-ID from file
                docker__imageID_chosen=`get_output_from_file__func` 

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
                if [[ -z ${docker__repo_chosen} ]] || [[ -z ${docker__tag_chosen} ]]; then
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
        local MENUTITLE_UPDATED_CONTAINER_LIST="Updated ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}-list"

        #Show Container's list
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        show_list_with_menuTitle__func "${MENUTITLE_UPDATED_CONTAINER_LIST}" "${docker__ps_a_cmd}"

        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        local echomsg1="Summary:\n"
        echomsg1+="\tChosen Repository:\t\t\t${DOCKER__REPOSITORY_FG_PURPLE}${myRepository}${DOCKER__NOCOLOR}\n"
        echomsg1+="\tCreated Container-ID:\t\t\t${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}${containerName}${DOCKER__NOCOLOR}\n"
        echomsg1+="\tTCP-port to-used-for SSH:\t\t${DOCKER__PORTS_FG_LIGHTBLUE}${docker__ssh_localport}${DOCKER__NOCOLOR}\n"
        echo -e "${echomsg1}"

        get_assigned_ipv4_addresses__func
        
        local echomsg2="\tAvailable ip-address(es) for SSH:"
        echo -e "${echomsg2}"
        for ipv4 in "${docker__ipv4_addr_summarize_arr[@]}"; do 
            echo -e "\t\t\t\t\t\t${DOCKER__IP_FG_LIGHTCYAN}${ipv4}${DOCKER__NOCOLOR}"
        done
        
        # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"


        #Show EXAMPLE OF HOW TO SSH FROM a REMOTE PC
        docker__ipv4_addr=$(cut -d" " -f1 <<< ${docker__ipv4_addr_summarize_str})
        local echomsg3="How to SSH from a remote PC?\n"
        echomsg3="\tDefault login/pass: ${DOCKER__GENERAL_FG_YELLOW}root/root${DOCKER__NOCOLOR}\n"
        echomsg3+="\tSample:\n"
        echomsg3+="\t\tssh ${DOCKER__GENERAL_FG_YELLOW}root${DOCKER__NOCOLOR}@${DOCKER__IP_FG_LIGHTCYAN}${docker__ipv4_addr}${DOCKER__NOCOLOR} -p ${DOCKER__PORTS_FG_LIGHTBLUE}${docker__ssh_localport}${DOCKER__NOCOLOR}\n"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e ${echomsg3}
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        
        exit
    else
        break
    fi
}

docker__get_and_check_repoTag__sub() {
    #Define message constants
    local ERRMSG_NO_REPO_FOUND="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: No matching ${DOCKER__NEW_REPOSITORY_FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR} found for ${DOCKER__IMAGEID_FG_BORDEAUX}ID${DOCKER__NOCOLOR} '${DOCKER__FG_LIGHTGREY}${docker__imageID_chosen}${DOCKER__NOCOLOR}'"
    local ERRMSG_NO_TAG_FOUND="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: No matching ${DOCKER__TAG_FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} found for ${DOCKER__IMAGEID_FG_BORDEAUX}ID${DOCKER__NOCOLOR} '${DOCKER__FG_LIGHTGREY}${docker__imageID_chosen}${DOCKER__NOCOLOR}'"
    local ERRMSG_NO_REPO_TAG_FOUND="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: No matching ${DOCKER__NEW_REPOSITORY_FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR} and ${DOCKER__TAG_FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} found for ${DOCKER__IMAGEID_FG_BORDEAUX}ID${DOCKER__NOCOLOR} '${DOCKER__FG_LIGHTGREY}${docker__imageID_chosen}${DOCKER__NOCOLOR}'"

    #Get repository
    docker__repo_chosen=`${docker__images_cmd} | grep -w ${docker__imageID_chosen} | awk -vcolNo=${docker__images_repoColNo} '{print $colNo}'`

    #Get tag
    docker__tag_chosen=`${docker__images_cmd} | grep -w ${docker__imageID_chosen} | awk -vcolNo=${docker__images_tagColNo} '{print $colNo}'`

    #Check if any of the value is an Empty String
    if [[ -z ${docker__repo_chosen} ]] && [[ -z ${docker__tag_chosen} ]]; then
        show_errMsg_without_menuTitle__func "${ERRMSG_NO_REPO_TAG_FOUND}"
    else
        if [[ -z ${docker__repo_chosen} ]]; then
            show_errMsg_without_menuTitle__func "${ERRMSG_NO_REPO_FOUND}"
        fi

        if [[ -z ${docker__tag_chosen} ]]; then
            show_errMsg_without_menuTitle__func "${ERRMSG_NO_TAG_FOUND}"
        fi
    fi
}



#---MAIN SUBROUTINE
main_sub() {
    docker__load_environment_variables__sub

    docker__load_source_files__sub

    docker__load_header__sub

    docker__init_variables__sub

    docker__run_container_handler__sub
}



#---EXECUTE
main_sub
