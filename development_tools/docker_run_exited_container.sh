#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---COLOR CONSTANTS
DOCKER__NOCOLOR=$'\e[0;0m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__CONTAINER_FG_BRIGHTPRUPLE=$'\e[30;38;5;141m'
DOCKER__INSIDE_FG_LIGHTGREY=$'\e[30;38;5;246m'

DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'
DOCKER__TITLE_BG_LIGHTBLUE=$'\e[30;48;5;45m'
DOCKER__REMARK_BG_ORANGE=$'\e[30;48;5;208m'
DOCKER__CONTAINER_BG_BRIGHTPRUPLE=$'\e[30;48;5;141m'

#---CONSTANTS
DOCKER__TITLE="TIBBO"

#---CHARACTER CHONSTANTS
DOCKER__DASH="-"
DOCKER__EMPTYSTRING=""

DOCKER__ONESPACE=" "
DOCKER__TWOSPACES=${DOCKER__ONESPACE}${DOCKER__ONESPACE}
DOCKER__FOURSPACES=${DOCKER__TWOSPACES}${DOCKER__TWOSPACES}

#---MENU CONSTANTS
DOCKER__CTRL_C_QUIT="${DOCKER__FOURSPACES}Quit (Ctrl+C)"

#---NUMERIC CONSTANTS
DOCKER__TABLEWIDTH=70

DOCKER__NUMOFLINES_1=1
DOCKER__NUMOFLINES_2=2
DOCKER__NUMOFLINES_3=3
DOCKER__NUMOFLINES_4=4
DOCKER__NUMOFLINES_5=5
DOCKER__NUMOFLINES_6=6

#---PATTERN CONSTANTS
DOCKER__PATTERN1="Exited"



#---FUNCTIONS
#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C__sub INT

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
    # echo -e ${DOCKER__EXITING_NOW}
    # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

    exit
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
CTRL_C__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

    exit
}

docker__environmental_variables__sub() {
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
    docker__containerID_chosen=${DOCKER__EMPTYSTRING}

    docker__ps_a_cmd="docker ps -a"

    docker__ps_a_containerIdColno=1

    docker__onEnter_breakLoop=false
    docker__showTable=true
}

docker__start_exited_container_handler__sub() {
    #Define phase constants
    local CONTAINERID_SELECT_PHASE=0
    local START_EXITED_CONTAINERID=1

    #Define local constants
    local MENUTITLE="${DOCKER__GENERAL_FG_YELLOW}Start${DOCKER__NOCOLOR} an ${DOCKER__INSIDE_FG_LIGHTGREY}Exited${DOCKER__NOCOLOR} ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Container-ID${DOCKER__NOCOLOR}"

    local READMSG_CHOOSE_A_CONTAINERID="Choose a ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Container-ID${DOCKER__NOCOLOR} (e.g. dfc5e2f3f7ee): "

    local ERRMSG_CHOSEN_CONTAINERID_DOESNOT_EXISTS="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: chosen ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Container-ID${DOCKER__NOCOLOR} does NOT exist"
    local ERRMSG_NO_EXITED_CONTAINERS_FOUND="=:${DOCKER__ERROR_FG_LIGHTRED}NO *EXITED* CONTAINERS FOUND${DOCKER__NOCOLOR}:="

    #Define variables
    local errMsg=${DOCKER__EMPTYSTRING}
    local phase=${DOCKER__EMPTYSTRING}
    local readmsg_remarks=${DOCKER__EMPTYSTRING}

    #Set 'readmsg_remarks'
    readmsg_remarks="${DOCKER__REMARK_BG_ORANGE}Remarks:${DOCKER__NOCOLOR}\n"
    readmsg_remarks+="${DOCKER__DASH} Up/Down arrow: to cycle thru existing values\n"
    readmsg_remarks+="${DOCKER__DASH} TAB: auto-complete"

    #Set initial 'phase'
    phase=${CONTAINERID_SELECT_PHASE}
    while true
    do
        case "${phase}" in
            ${CONTAINERID_SELECT_PHASE})
                #Run script
                ${docker_readInput_w_autocomplete_fpath} "${MENUTITLE}" \
                                    "${READMSG_CHOOSE_A_CONTAINERID}" \
                                    "${readmsg_remarks}" \
                                    "${DOCKER__EMPTYSTRING}" \
                                    "${ERRMSG_NO_EXITED_CONTAINERS_FOUND}" \
                                    "${ERRMSG_CHOSEN_CONTAINERID_DOESNOT_EXISTS}" \
                                    "${docker__ps_a_cmd}" \
                                    "${docker__ps_a_containerIdColno}" \
                                    "${DOCKER__PATTERN1}" \
                                    "${docker__showTable}" \
                                    "${docker__onEnter_breakLoop}"

                #Retrieve the selected container-ID from file
                docker__containerID_chosen=`get_output_from_file__func` 

                #Check if output is an Empty String
                if [[ -z ${docker__containerID_chosen} ]]; then
                    return
                else
                    phase=${START_EXITED_CONTAINERID}
                fi
                ;;
            ${START_EXITED_CONTAINERID})
                docker__start_exited_container__sub

                return
                ;;
        esac
    done
}

docker__start_exited_container__sub() {
    #Define message constants
    local MENUTITLE_UPDATED_CONTAINER_LIST="Updated ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}-list"

    #Execute command
    docker start ${docker__containerID_chosen}

    #Show Container's list
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    
    show_list_with_menuTitle__func "${MENUTITLE_UPDATED_CONTAINER_LIST}" "${docker__ps_a_cmd}"
    
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
}



#MAIN SUBROUTINE
main_sub() {
    docker__environmental_variables__sub

    docker__load_source_files__sub

    docker__load_header__sub

    docker__init_variables__sub

    docker__start_exited_container_handler__sub
}



#Execute main subroutine
main_sub