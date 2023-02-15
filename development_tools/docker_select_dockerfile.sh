#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---INPUT ARGS
dockerfiles_dir__input=${1}
export_env_var_menu_cfg_tag__input=${2}
export_env_var_menu_cfg_fpath__input=${3}



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

docker__load_constants__sub() {
    DOCKER__DIRLIST_MENUTITLE="${DOCKER__FG_DARKBLUE}Docker-file${DOCKER__NOCOLOR} selection"
    DOCKER__DIRLIST_LOCATION_INFO="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR}: ${docker__LTPP3_ROOTFS_docker_dockerfiles__dir}"
    DOCKER__DIRLIST_REMARKS="${DOCKER__FOURSPACES}NOTE: only files containing patterns ${DOCKER__FG_LIGHTGREY}${DOCKER__CONTAINER_ENV1}${DOCKER__NOCOLOR} "
    DOCKER__DIRLIST_REMARKS+="and ${DOCKER__FG_LIGHTGREY}${DOCKER__CONTAINER_ENV2}${DOCKER__NOCOLOR} are shown"
    DOCKER__DIRLIST_MENUOPTIONS="${DOCKER__FOURSPACES_F12_QUIT}"
    DOCKER__DIRLIST_MATCHPATTERNS="${DOCKER__ENUM_FUNC_F12}"
	DOCKER__DIRLIST_READDIALOG="Choose file: "
    DOCKER__DIRLIST_ERRMSG="${DOCKER__FOURSPACES}-:${DOCKER__FG_LIGHTRED}directory is Empty${DOCKER__NOCOLOR}:-"
}

docker__init_variables__sub() {
    docker__dockerFile_fpath=${DOCKER__EMPTYSTRING}
}

docker__select_dockerfile__sub() {
    #Show directory content
    show_pathContent_w_selection__func "${dockerfiles_dir__input}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${DOCKER__DIRLIST_MENUTITLE}" \
                        "${DOCKER__DIRLIST_REMARKS}" \
                        "${DOCKER__DIRLIST_LOCATION_INFO}" \
                        "${DOCKER__DIRLIST_MENUOPTIONS}" \
                        "${DOCKER__DIRLIST_MATCHPATTERNS}" \
                        "${DOCKER__DIRLIST_ERRMSG}" \
                        "${DOCKER__DIRLIST_READDIALOG}" \
                        "${DOCKER__CONTAINER_ENV1}" \
                        "${DOCKER__CONTAINER_ENV2}" \
                        "${DOCKER__TABLEROWS_10}" \
                        "${DOCKER__FALSE}" \
                        "${docker__show_pathContent_w_selection_func_out__fpath}" \
                        "${DOCKER__NUMOFLINES_2}" \
                        "${DOCKER__TRUE}"

    #Get the exitcode just in case a Ctrl-C was pressed in function 'DOCKER__FOURSPACES_F4_ABORT' (in script 'docker_global.sh')
    docker__exitCode=$?
    if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
        exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
    fi

    #Get result from file.
    docker__dockerFile_fpath=`get_output_from_file__func \
                        "${docker__show_pathContent_w_selection_func_out__fpath}" \
                        "${DOCKER__LINENUM_1}"`

    #if 'docker__dockerFile_fpath = F12', then exit this subroutine
    if [[ ${docker__dockerFile_fpath} == ${DOCKER__ENUM_FUNC_F12} ]]; then
        exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_1}"
    else
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_3}"
    fi

    #Write to configuration file
    echo "${export_env_var_menu_cfg_tag__input}${DOCKER__ONESPACE}${docker__dockerFile_fpath}" > ${export_env_var_menu_cfg_fpath__input}
}



#---MAIN SUBROUTINE
main__sub() {
    docker__get_source_fullpath__sub

    docker__load_source_files__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__select_dockerfile__sub
}



#---EXECUTE
main__sub
