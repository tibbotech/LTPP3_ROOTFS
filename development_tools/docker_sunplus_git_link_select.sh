#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
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
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${DOCKER__BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__BG_ORANGE}                               ${DOCKER__NOCOLOR}"
}

docker__load_constants__sub() {
    DOCKER__DIRLIST_MENUTITLE="Select a ${DOCKER__FG_DARKBLUE}docker-file${DOCKER__NOCOLOR}"
    DOCKER__DIRLIST_LOCATION_INFO="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR}: ${docker__LTPP3_ROOTFS_docker_dockerfiles__dir}"
    DOCKER__DIRLIST_REMARK="${DOCKER__FOURSPACES}NOTE: only files containing '${DOCKER__PATTERN_ARG}' and '${DOCKER__PATTERN_ENV}' are shown"
	DOCKER__DIRLIST_READ_DIALOG="Choose a file: "
    DOCKER__DIRLIST_ERRMSG="${DOCKER__FOURSPACES}-:${DOCKER__FG_LIGHTRED}directory is Empty${DOCKER__NOCOLOR}:-"

    DOCKER__GITLINK_MENUTITLE="${DOCKER__FG_YELLOW}Select${DOCKER__NOCOLOR}/${DOCKER__FG_YELLOW}Input${DOCKER__NOCOLOR} Sunplus ${DOCKER__FG_LIGHTBLUE}Git${DOCKER__NOCOLOR} Link"
    DOCKER__GITLINK_LOCATION_INFO_MSG="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}${docker__sunplus_gitlink_cache__fpath}${DOCKER__NOCOLOR}"
    DOCKER__GITLINK_MENUOPTIONS_MSG="${DOCKER__FOURSPACES_HASH_CHOOSE}\n"
    DOCKER__GITLINK_MENUOPTIONS_MSG+="${DOCKER__FOURSPACES_PLUS_ADD}\n"
    DOCKER__GITLINK_MENUOPTIONS_MSG+="${DOCKER__FOURSPACES_MINUS_DEL}\n"
    DOCKER__GITLINK_MENUOPTIONS_MSG+="${DOCKER__FOURSPACES_CARET_QUIT}"
    DOCKER__GITLINK_CHOOSE_LINK="Choose link: "
    DOCKER__GITLINK_DELETE_LINENUM="Del link:"
    DOCKER__GITLINK_ADD_LINK="Add link (${DOCKER__FG_YELLOW};c${DOCKER__NOCOLOR}lear): "
}

docker__init_variables__sub() {
    docker__keyInput=${DOCKER__EMPTYSTRING}
    docker__keyInput_add=${DOCKER__EMPTYSTRING}
    docker__totInput=${DOCKER__EMPTYSTRING}

    docker__dockerFileFpath=${DOCKER__EMPTYSTRING}

    docker__exitCode=0
}

docker__show_dockerList_files__sub() {
    #Show directory content
    show_dirContent__func "${docker__LTPP3_ROOTFS_docker_dockerfiles__dir}" \
                        "${DOCKER__DIRLIST_MENUTITLE}" \
                        "${DOCKER__DIRLIST_REMARK}" \
                        "${DOCKER__DIRLIST_LOCATION_INFO}" \
                        "${DOCKER__FOURSPACES_Q_QUIT}" \
                        "${DOCKER__DIRLIST_ERRMSG}" \
                        "${DOCKER__DIRLIST_READ_DIALOG}" \
                        "${DOCKER__PATTERN_ARG}" \
                        "${DOCKER__PATTERN_ENV}" \
                        "${docker__sunplus_git_link_select_tmp__fpath}"

    #Get the exitcode just in case a Ctrl-C was pressed in function 'show_dirContent__func' (in script 'docker_global.sh')
    docker__exitCode=$?
    if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
        exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
    fi

    #Get result from file.
    docker__dockerFileFpath=`get_output_from_file__func \
                        "${docker__sunplus_git_link_select_tmp__fpath}" \
                        "${DOCKER__LINENUM_1}"`
}



docker__show_input_write_toFile__sub() {
    #Define variables
    local flag_checkWebLink=true
    local repository_tag=`egrep -w "${DOCKER__PATTERN_REPOSITORY_TAG}" ${docker__dockerfile_ltps_sunplus_fpath} | cut -d"\"" -f2`

    #Execute script show/choose/add/del git-link(s)
    ${docker__show_choose_add_del_from_cache__fpath} "${DOCKER__GITLINK_MENUTITLE}" \
                        "${DOCKER__GITLINK_LOCATION_INFO_MSG}" \
                        "${DOCKER__GITLINK_MENUOPTIONS_MSG}" \
                        "${DOCKER__GITLINK_CHOOSE_LINK}" \
                        "${DOCKER__GITLINK_ADD_LINK}" \
                        "${DOCKER__GITLINK_DELETE_LINENUM}" \
                        "${docker__exported_env_var_fpath}" \
                        "${docker__sunplus_gitlink_cache__fpath}" \
                        "${docker__show_choose_add_del_from_cache_out__fpath}" \
                        "update_exported_env_var__func" \
                        "${docker__dockerFileFpath}" \
                        "${flag_checkWebLink}"

    #Get the exitcode just in case a Ctrl-C was pressed in script 'docker__show_choose_add_del_from_cache__fpath'.
    docker__exitCode=$?
    if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
        exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
    fi
}



#---MAIN SUBROUTINE
main_sub() {
    docker__load_environment_variables__sub

    docker__load_source_files__sub

    docker__load_header__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__show_dockerList_files__sub

    docker__show_input_write_toFile__sub
}



#---EXECUTE
main_sub
