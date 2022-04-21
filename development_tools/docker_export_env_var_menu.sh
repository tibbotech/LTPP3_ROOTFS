#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---CONSTANTS
DOCKER__EXPORT_ENVIRONMENT_VARIABLES_MENUTITLE="${DOCKER__FG_LIGHTBLUE}DOCKER: EXPORT ENVIRONMENT VARIABLES${DOCKER__NOCOLOR}"
DOCKER__VERSION="v22.04.22-0.0.1"



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

    docker__my_LTPP3_ROOTFS_development_tools_dir=/home/imcase/repo/LTPP3_ROOTFS/development_tools

    docker__global__filename="docker_global.sh"
    docker__global__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global__filename}
}

docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

docker__load_header__sub() {
    show_header__func "${DOCKER__TITLE}" "${DOCKER__TABLEWIDTH}" "${DOCKER__BG_ORANGE}" "${DOCKER__NUMOFLINES_2}" "${DOCKER__NUMOFLINES_0}"
}

docker__init_variables__sub() {
    docker__dockerFile_filename_print=${DOCKER__EMPTYSTRING}
    docker__dockerFile_filename_trim=${DOCKER__EMPTYSTRING}
    docker__dockerFile_fpath=${DOCKER__EMPTYSTRING}
    docker__myChoice=${DOCKER__EMPTYSTRING}

    docker__menu_choose_dockerfile_leading_len=0
    docker__menu_choose_dockerfile_trailing_len=0
}


docker__load_constants__sub() {
    DOCKER__DIRLIST_MENUTITLE="Choose ${DOCKER__FG_DARKBLUE}docker-file${DOCKER__NOCOLOR}"
    DOCKER__DIRLIST_LOCATION_INFO="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR}: ${docker__LTPP3_ROOTFS_docker_dockerfiles__dir}"
    DOCKER__DIRLIST_REMARK="${DOCKER__FOURSPACES}${DOCKER__FG_LIGHTGREY}NOTE: only files containing pattern '${DOCKER__CONTAINER_ENV1}'...\n"
    DOCKER__DIRLIST_REMARK+="${DOCKER__TENSPACES}...and '${DOCKER__CONTAINER_ENV2}' are shown${DOCKER__NOCOLOR}"
	DOCKER__DIRLIST_READ_DIALOG="Choose a file: "
    DOCKER__DIRLIST_ERRMSG="${DOCKER__FOURSPACES}-:${DOCKER__FG_LIGHTRED}directory is Empty${DOCKER__NOCOLOR}:-"

    DOCKER__MENU_CHOOSE_DOCKERFILE="${DOCKER__FOURSPACES}1. Choose ${DOCKER__FG_DARKBLUE}docker-file${DOCKER__NOCOLOR} "

    DOCKER__MENU_CHOOSE_ADD_DEL_ENV_VAR_LINK="${DOCKER__FOURSPACES}2. Choose${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}"
    DOCKER__MENU_CHOOSE_ADD_DEL_ENV_VAR_LINK+="Add${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}"
    DOCKER__MENU_CHOOSE_ADD_DEL_ENV_VAR_LINK+="Del env-variable ${DOCKER__FG_GREEN41}Link${DOCKER__NOCOLOR}"

    DOCKER__MENU_CHOOSE_ADD_DEL_ENV_VAR_CHECKOUT="${DOCKER__FOURSPACES}3. Choose${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}"
    DOCKER__MENU_CHOOSE_ADD_DEL_ENV_VAR_CHECKOUT+="Add${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}"
    DOCKER__MENU_CHOOSE_ADD_DEL_ENV_VAR_CHECKOUT+="Del env-variable ${DOCKER__FG_GREEN119}Checkout${DOCKER__NOCOLOR}"

    DOCKER__MENU_CHOOSE_ADD_DEL_LINKCHECKOUT_PROFILE="${DOCKER__FOURSPACES}4. Choose${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}"
    DOCKER__MENU_CHOOSE_ADD_DEL_LINKCHECKOUT_PROFILE+="Add${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}Del "
    DOCKER__MENU_CHOOSE_ADD_DEL_LINKCHECKOUT_PROFILE+="env-variable ${DOCKER__FG_GREEN41}link${DOCKER__FG_GREEN}-${DOCKER__FG_GREEN119}checkout${DOCKER__NOCOLOR} "
    DOCKER__MENU_CHOOSE_ADD_DEL_LINKCHECKOUT_PROFILE+="${DOCKER__FG_GREEN}Profile${DOCKER__NOCOLOR}"
}

docker__calc_const_string_lengths__sub() {
    docker__menu_choose_dockerfile_leading_len=`get_stringlen_wo_regEx__func "${DOCKER__MENU_CHOOSE_DOCKERFILE}"`

    #Note: -2 due to the curve-brackets
    docker__menu_choose_dockerfile_trailing_len=$((DOCKER__TABLEWIDTH - docker__menu_choose_dockerfile_leading_len - 2))
}

docker__trim_msg_toFit_within_specified_windowSize__sub() {
    #Retrieve 'docker__dockerFile_filename_print'
    if [[ ! -z ${docker__dockerFile_fpath} ]]; then
        docker__dockerFile_filename=$(basename ${docker__dockerFile_fpath})

        docker__dockerFile_filename_print=`trim_string_toFit_specified_windowSize__func "${docker__dockerFile_filename}" \
                        "${docker__menu_choose_dockerfile_trailing_len}"  \
                        "${DOCKER__FALSE}"`
    else
        docker__dockerFile_filename_print="${DOCKER__DASH}"
    fi

    #Change foreground color to 'DOCKER__FG_LIGHTGREY'
    docker__dockerFile_filename_print="${DOCKER__FG_LIGHTGREY}${docker__dockerFile_filename_print}${DOCKER__NOCOLOR}"
}

docker__export_env_var_menu__sub() {
    while true
    do

        #Draw horizontal lines
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Show menu-title
        show_leadingAndTrailingStrings_separatedBySpaces__func "${DOCKER__EXPORT_ENVIRONMENT_VARIABLES_MENUTITLE}" \
                        "${DOCKER__VERSION}" \
                        "${DOCKER__TABLEWIDTH}"

        #Draw horizontal lines
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Trim 'docker__dockerFile_fpath' to fit into 'docker__menu_choose_dockerfile_trailing_len'
        docker__trim_msg_toFit_within_specified_windowSize__sub

        #Show menu-options
        echo -e "${DOCKER__MENU_CHOOSE_DOCKERFILE} (${docker__dockerFile_filename_print})"

        #Only show the following options if 'docker__dockerFile_fpath' is Not an Empty String
        if [[ ! -z ${docker__dockerFile_fpath} ]]; then
            echo -e "${DOCKER__MENU_CHOOSE_ADD_DEL_ENV_VAR_LINK}"
            echo -e "${DOCKER__MENU_CHOOSE_ADD_DEL_ENV_VAR_CHECKOUT}"
            echo -e "${DOCKER__MENU_CHOOSE_ADD_DEL_LINKCHECKOUT_PROFILE}"
        fi

        #Draw horizontal lines
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Show menu-additional-options
        echo -e "${DOCKER__FOURSPACES}q. ${DOCKER__QUIT_CTRL_C}"

        #Draw horizontal lines
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Show read-input
        while true
        do
            #Select an option
            read -N1 -r -p "Please choose an option: " docker__myChoice
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            #Only continue if a valid option is selected
            if [[ ! -z ${docker__myChoice} ]]; then
                if [[ ${docker__myChoice} =~ [1-4q] ]]; then
                    break
                else
                    if [[ ${docker__myChoice} == ${DOCKER__ENTER} ]]; then
                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
                    else
                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                    fi
                fi
            else
                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
            fi
        done
            
        #Goto the selected option
        case ${docker__myChoice} in
            1)
                docker__select_dockerfile__sub
                ;;
            2)
                ${docker__repo_link_checkout_menu_select__fpath} "${docker__dockerFile_fpath}" "${DOCKER__LINK}"
                ;;
            3)
                ${docker__repo_link_checkout_menu_select__fpath} "${docker__dockerFile_fpath}" "${DOCKER__CHECKOUT}"
                ;;
            4)
                ${docker__repo_link_checkout_menu_select__fpath} "${docker__dockerFile_fpath}" "${DOCKER__LINKCHECKOUT_PROFILE}"
                ;;
            q)
                exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_2}"
                ;;
        esac
    done
}

docker__select_dockerfile__sub() {
    #Move-down and clean
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

    #Show directory content
    show_dirContent__func "${docker__LTPP3_ROOTFS_docker_dockerfiles__dir}" \
                        "${DOCKER__DIRLIST_MENUTITLE}" \
                        "${DOCKER__DIRLIST_REMARK}" \
                        "${DOCKER__DIRLIST_LOCATION_INFO}" \
                        "${DOCKER__FOURSPACES_F12_QUIT}" \
                        "${DOCKER__DIRLIST_ERRMSG}" \
                        "${DOCKER__DIRLIST_READ_DIALOG}" \
                        "${DOCKER__CONTAINER_ENV1}" \
                        "${DOCKER__CONTAINER_ENV2}" \
                        "${docker__export_env_var_menu_out__fpath}" \
                        "${DOCKER__TABLEROWS}"

    #Get the exitcode just in case a Ctrl-C was pressed in function 'show_dirContent__func' (in script 'docker_global.sh')
    docker__exitCode=$?
    if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
        exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
    fi

    #Get result from file.
    docker__dockerFile_fpath=`get_output_from_file__func \
                        "${docker__export_env_var_menu_out__fpath}" \
                        "${DOCKER__LINENUM_1}"`

                
}



#---MAIN SUBROUTINE
main__sub() {
    docker__load_environment_variables__sub

    docker__load_source_files__sub

    docker__load_header__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__calc_const_string_lengths__sub

    docker__export_env_var_menu__sub
}



#---EXECUTE
main__sub
