#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---CONSTANTS
DOCKER__CACHE_MAX=30



#---FUNCTIONS



#---SUBROUTINES
docker__load_environment_variables__sub() {
    #Define paths
    docker__LTPP3_ROOTFS_development_tools__fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__LTPP3_ROOTFS_development_tools__dir=$(dirname ${docker__LTPP3_ROOTFS_development_tools__fpath})
    docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/

    docker__global_functions__filename="docker_global_functions.sh"
    docker__global_functions__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__global_functions__filename}
}

docker__load_source_files__sub() {
    source ${docker__global_functions__fpath}
}

docker__load_header__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${DOCKER__BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__BG_ORANGE}                               ${DOCKER__NOCOLOR}"
}

docker__init_variables__sub() {
    docker__cachedInput_arr=()
    docker__cachedInput_arrLen=0
    docker__cachedInput_arrIndex=0
    docker__cachedInput_arrIndex_max=0

    docker__keyInput=${DOCKER__EMPTYSTRING}
    docker__keyInput_add=${DOCKER__EMPTYSTRING}
    docker__totInput=${DOCKER__EMPTYSTRING}

    docker__exitCode=0
}

docker__verify_sunplus_gitlink__sub() {
    #Check if directory exist
    #If false, then create directory
    if [[ ! -d ${docker__docker_cache__dir} ]]; then
        mkdir -p ${docker__docker_cache__dir}
    fi

    #Check if file 'docker__gitlink.cache' is exists
    #Renark:
    #   If not present, then:
    #   1. Get the git-link from file 'docker__exported_env_var_fpath'
    #   2. Write the retrieved git-link to cache 'docker__gitlink_cache__fpath'
    if [[ ! -f ${docker__gitlink_cache__fpath} ]]; then
        local sunplus_gitLink=`retrieve_sunplus_gitLink_from_file__func "${docker__dockerfile_ltps_sunplus_fpath}" "${docker__exported_env_var_fpath}"`

        echo ${sunplus_gitLink} > ${docker__gitlink_cache__fpath}
    fi
}

docker__show_input_write_toFile__sub() {
    #Define constants
    MENUTITLE="${DOCKER__FG_YELLOW}Select${DOCKER__NOCOLOR}/${DOCKER__FG_YELLOW}Input${DOCKER__NOCOLOR} Sunplus ${DOCKER__FG_LIGHTBLUE}Git${DOCKER__NOCOLOR} Link"
    LOCATION_INFO_MSG="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}${docker__gitlink_cache__fpath}${DOCKER__NOCOLOR}"
    MENUOPTIONS_MSG="${DOCKER__FOURSPACES_HASH_CHOOSE}\n"
    MENUOPTIONS_MSG+="${DOCKER__FOURSPACES_PLUS_ADD}\n"
    MENUOPTIONS_MSG+="${DOCKER__FOURSPACES_MINUS_DEL}\n"
    MENUOPTIONS_MSG+="${DOCKER__FOURSPACES_CARET_QUIT}"
    READINPUTDIALOG_CHOOSE_GITLINK="Choose link: "
    READINPUTDIALOG_DELETE_LINENUM="Delete link:"
    READINPUTDIALOG_INPUT_GITLINK="Input link (${DOCKER__FG_YELLOW};c${DOCKER__NOCOLOR}lear): "

    ${docker_show_choose_add_del_from_cache__fpath} "${MENUTITLE}" \
                        "${LOCATION_INFO_MSG}" \
                        "${MENUOPTIONS_MSG}" \
                        "${READINPUTDIALOG_CHOOSE_GITLINK}" \
                        "${READINPUTDIALOG_INPUT_GITLINK}" \
                        "${READINPUTDIALOG_DELETE_LINENUM}" \
                        "${docker__exported_env_var_fpath}" \
                        "${docker__gitlink_cache__fpath}" \
                        "${docker__show_choose_add_del_from_cache_out__fpath}"
    #Get the exitcode just in case a Ctrl-C was pressed in script 'docker_show_choose_add_del_from_cache__fpath'.
    docker__exitCode=$?
    if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
        docker__exitFunc "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
    fi
}



#---MAIN SUBROUTINE
main_sub() {
    docker__load_environment_variables__sub

    docker__load_source_files__sub

    docker__load_header__sub

    docker__init_variables__sub

    docker__verify_sunplus_gitlink__sub

    docker__show_input_write_toFile__sub
}



#---EXECUTE
main_sub
