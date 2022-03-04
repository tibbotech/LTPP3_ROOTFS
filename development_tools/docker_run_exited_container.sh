#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---PATTERN CONSTANTS
DOCKER__PATTERN1="Exited"


#---SUBROUTINES
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
}

docker__load_source_files__sub() {
    source ${docker__global_functions_fpath}
}

docker__load_header__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${DOCKER__BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__BG_ORANGE}                                ${DOCKER__NOCOLOR}"
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
    local MENUTITLE="${DOCKER__FG_YELLOW}Start${DOCKER__NOCOLOR} an ${DOCKER__FG_LIGHTGREY}Exited${DOCKER__NOCOLOR} ${DOCKER__FG_BRIGHTPRUPLE}Container-ID${DOCKER__NOCOLOR}"

    local READMSG_CHOOSE_A_CONTAINERID="Choose a ${DOCKER__FG_BRIGHTPRUPLE}Container-ID${DOCKER__NOCOLOR} (e.g. dfc5e2f3f7ee): "

    local ERRMSG_CHOSEN_CONTAINERID_DOESNOT_EXISTS="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: chosen ${DOCKER__FG_BRIGHTPRUPLE}Container-ID${DOCKER__NOCOLOR} does NOT exist"
    local ERRMSG_NO_EXITED_CONTAINERS_FOUND="=:${DOCKER__FG_LIGHTRED}NO *EXITED* CONTAINERS FOUND${DOCKER__NOCOLOR}:="

    #Define variables
    local errMsg=${DOCKER__EMPTYSTRING}
    local phase=${DOCKER__EMPTYSTRING}
    local readmsg_remarks=${DOCKER__EMPTYSTRING}

    #Set 'readmsg_remarks'
    readmsg_remarks="${DOCKER__BG_ORANGE}Remarks:${DOCKER__NOCOLOR}\n"
    readmsg_remarks+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}Up/Down Arrow${DOCKER__NOCOLOR}: to cycle thru existing values\n"
    readmsg_remarks+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}TAB${DOCKER__NOCOLOR}: auto-complete\n"
    readmsg_remarks+="${DOCKER__DASH} ${DOCKER__FG_YELLOW};c${DOCKER__NOCOLOR}: clear"

    #Set initial 'phase'
    phase=${CONTAINERID_SELECT_PHASE}
    while true
    do
        case "${phase}" in
            ${CONTAINERID_SELECT_PHASE})
                #Run script
                ${docker__readInput_w_autocomplete_fpath} "${MENUTITLE}" \
                        "${READMSG_CHOOSE_A_CONTAINERID}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${readmsg_remarks}" \
                        "${ERRMSG_NO_EXITED_CONTAINERS_FOUND}" \
                        "${ERRMSG_CHOSEN_CONTAINERID_DOESNOT_EXISTS}" \
                        "${docker__ps_a_cmd}" \
                        "${docker__ps_a_containerIdColno}" \
                        "${DOCKER__PATTERN1}" \
                        "${docker__showTable}" \
                        "${docker__onEnter_breakLoop}"

                #Retrieve the selected container-ID from file
                docker__containerID_chosen=`get_output_from_file__func "${docker__readInput_w_autocomplete_out_fpath}"`

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
    local MENUTITLE_UPDATED_CONTAINER_LIST="Updated ${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}-list"

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