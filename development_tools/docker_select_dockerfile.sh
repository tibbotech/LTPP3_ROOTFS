#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---INPUT ARGS
dockerfiles_dir__input=${1}
export_env_var_menu_cfg_tag__input=${2}
export_env_var_menu_cfg_fpath__input=${3}



#---SUBROUTINES
docker__load_environment_variables__sub() {
    #Define paths
    docker__LTPP3_ROOTFS_development_tools__fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__LTPP3_ROOTFS_development_tools__dir=$(dirname ${docker__LTPP3_ROOTFS_development_tools__fpath})
    docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/

    docker__global_filename="docker_global.sh"
    docker__global__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__global_filename}
}

docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

docker__load_header__sub() {
    show_header__func "${DOCKER__TITLE}" "${DOCKER__TABLEWIDTH}" "${DOCKER__BG_ORANGE}" "${DOCKER__NUMOFLINES_2}" "${DOCKER__NUMOFLINES_0}"
}

docker__load_constants__sub() {
    DOCKER__DIRLIST_MENUTITLE="Choose ${DOCKER__FG_DARKBLUE}docker-file${DOCKER__NOCOLOR}"
    DOCKER__DIRLIST_LOCATION_INFO="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR}: ${docker__LTPP3_ROOTFS_docker_dockerfiles__dir}"
    DOCKER__DIRLIST_REMARK="${DOCKER__FOURSPACES}${DOCKER__FG_LIGHTGREY}NOTE: only files containing pattern '${DOCKER__CONTAINER_ENV1}'...\n"
    DOCKER__DIRLIST_REMARK+="${DOCKER__TENSPACES}...and '${DOCKER__CONTAINER_ENV2}' are shown${DOCKER__NOCOLOR}"
	DOCKER__DIRLIST_READ_DIALOG="Choose a file: "
    DOCKER__DIRLIST_ERRMSG="${DOCKER__FOURSPACES}-:${DOCKER__FG_LIGHTRED}directory is Empty${DOCKER__NOCOLOR}:-"
}

docker__init_variables__sub() {
    docker__dockerFile_fpath=${DOCKER__EMPTYSTRING}
}

docker__select_dockerfile__sub() {
    #Show directory content
    show_pathContent_w_keyInput__func "${dockerfiles_dir__input}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${DOCKER__DIRLIST_MENUTITLE}" \
                        "${DOCKER__DIRLIST_REMARK}" \
                        "${DOCKER__DIRLIST_LOCATION_INFO}" \
                        "${DOCKER__FOURSPACES_F12_QUIT}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${DOCKER__DIRLIST_ERRMSG}" \
                        "${DOCKER__DIRLIST_READ_DIALOG}" \
                        "${DOCKER__CONTAINER_ENV1}" \
                        "${DOCKER__CONTAINER_ENV2}" \
                        "${DOCKER__TABLEROWS_10}" \
                        "${docker__select_dockerfile_out__fpath}"

    #Get the exitcode just in case a Ctrl-C was pressed in function 'DOCKER__FOURSPACES_F4_ABORT' (in script 'docker_global.sh')
    docker__exitCode=$?
    if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
        exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
    fi

    #Get result from file.
    docker__dockerFile_fpath=`get_output_from_file__func \
                        "${docker__select_dockerfile_out__fpath}" \
                        "${DOCKER__LINENUM_1}"`

    #if 'docker__dockerFile_fpath = F12', then exit this subroutine
    if [[ ${docker__dockerFile_fpath} == ${DOCKER__ENUM_FUNC_F12} ]]; then
        exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_2}"
    else
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_3}"
    fi

    #Write to configuration file
    echo "${export_env_var_menu_cfg_tag__input}${DOCKER__ONESPACE}${docker__dockerFile_fpath}" > ${export_env_var_menu_cfg_fpath__input}
}



#---MAIN SUBROUTINE
main__sub() {
    docker__load_environment_variables__sub

    docker__load_source_files__sub

    docker__load_header__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__select_dockerfile__sub
}



#---EXECUTE
main__sub
