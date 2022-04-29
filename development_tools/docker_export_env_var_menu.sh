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

    docker__global__filename="docker_global.sh"
    docker__global__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global__filename}
}

docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

docker__load_header__sub() {
    #Input args
    local prepend_numOfLines__input=${1}

    #Print
    show_header__func "${DOCKER__TITLE}" "${DOCKER__TABLEWIDTH}" "${DOCKER__BG_ORANGE}" "${prepend_numOfLines__input}" "${DOCKER__NUMOFLINES_0}"
}

docker__load_constants__sub() {
    DOCKER__DIRLIST_MENUTITLE="Choose ${DOCKER__FG_DARKBLUE}docker-file${DOCKER__NOCOLOR}"
    DOCKER__DIRLIST_LOCATION_INFO="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR}: ${docker__LTPP3_ROOTFS_docker_dockerfiles__dir}"
    DOCKER__DIRLIST_REMARK="${DOCKER__FOURSPACES}${DOCKER__FG_LIGHTGREY}NOTE: only files containing pattern '${DOCKER__CONTAINER_ENV1}'...\n"
    DOCKER__DIRLIST_REMARK+="${DOCKER__TENSPACES}...and '${DOCKER__CONTAINER_ENV2}' are shown${DOCKER__NOCOLOR}"
	DOCKER__DIRLIST_READ_DIALOG="Choose a file: "
    DOCKER__DIRLIST_ERRMSG="${DOCKER__FOURSPACES}-:${DOCKER__FG_LIGHTRED}directory is Empty${DOCKER__NOCOLOR}:-"

    DOCKER__MENU_CHOOSE_DOCKERFILE="Choose ${DOCKER__FG_DARKBLUE}docker-file${DOCKER__NOCOLOR}"

    DOCKER__MENU_CHOOSE_ADD_DEL_ENV_VAR_LINK="Choose${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}"
    DOCKER__MENU_CHOOSE_ADD_DEL_ENV_VAR_LINK+="Add${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}Del "
    DOCKER__MENU_CHOOSE_ADD_DEL_ENV_VAR_LINK+="${DOCKER__FG_GREEN41}Link${DOCKER__NOCOLOR}"

    DOCKER__MENU_CHOOSE_ADD_DEL_ENV_VAR_CHECKOUT="Choose${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}"
    DOCKER__MENU_CHOOSE_ADD_DEL_ENV_VAR_CHECKOUT+="Add${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}Del "
    DOCKER__MENU_CHOOSE_ADD_DEL_ENV_VAR_CHECKOUT+="${DOCKER__FG_GREEN119}Checkout${DOCKER__NOCOLOR}"

    DOCKER__MENU_CHOOSE_ADD_DEL_LINKCHECKOUT_PROFILE="Choose${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}"
    DOCKER__MENU_CHOOSE_ADD_DEL_LINKCHECKOUT_PROFILE+="Add${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}Del "
    DOCKER__MENU_CHOOSE_ADD_DEL_LINKCHECKOUT_PROFILE+="${DOCKER__FG_GREEN41}link${DOCKER__NOCOLOR}-${DOCKER__FG_GREEN119}checkout${DOCKER__NOCOLOR} "
    DOCKER__MENU_CHOOSE_ADD_DEL_LINKCHECKOUT_PROFILE+="${DOCKER__FG_GREEN}Profile${DOCKER__NOCOLOR}"
}

docker__init_variables__sub() {
    docker__dockerFile_fpath=${DOCKER__EMPTYSTRING}
    docker__dockerFile_filename=${DOCKER__EMPTYSTRING}
    docker__dockerFile_filename_maxLen=0
    docker__dockerFile_filename_print=${DOCKER__EMPTYSTRING}

    docker__env_var_link=${DOCKER__EMPTYSTRING}
    docker__env_var_link_maxLen=0
    docker__env_var_link_print=${DOCKER__EMPTYSTRING}

    docker__env_var_checkout=${DOCKER__EMPTYSTRING}
    docker__env_var_checkout_maxLen=0
    docker__env_var_checkout_print=${DOCKER__EMPTYSTRING}

    docker__myChoice=${DOCKER__EMPTYSTRING}

    docker__linkCacheFpath=${DOCKER__EMPTYSTRING}
    docker__checkoutCacheFpath=${DOCKER__EMPTYSTRING}
    docker__linkCheckoutProfileCacheFpath=${DOCKER__EMPTYSTRING}

    docker__writeToFile_name=${DOCKER__EMPTYSTRING}

    docker__regEx=${DOCKER__EMPTYSTRING}
    
    docker__dockerFile_filename_print_maxLen=0
    docker__dockerFile_filename_print_maxLen=0
    docker__dockerFile_filename_print_maxLen=0

    docker__prepend_numOfLines=0
}

docker__retrieve_data_from_configFile__sub() {
    #Check if file exist and contains data
    if [[ ! -s ${docker__export_env_var_menu_cfg__fpath} ]]; then
        return
    fi

    #Retrieve data
    docker__dockerFile_fpath=`retrieve__data_specified_by_col_within_file__func "${DOCKER__CONFIGNAME____DOCKER__DOCKERFILE_FPATH}" \
                    "${DOCKER__COLNUM_2}" \
                    "${docker__export_env_var_menu_cfg__fpath}"`
}

docker__retrieve_link_and_checkout_from_file__sub() {
    #----------------------------------------------------------------
    #IMPORTANT:
    #   this subroutine MUST be executed AFTER 'docker__retrieve_data_from_configFile__sub'
    #----------------------------------------------------------------

    #Check if 'docker__dockerFile_fpath' or 'docker__exported_env_var_fpath' does exist?
    if [[ ! -f ${docker__dockerFile_fpath} ]] || [[ ! -f ${docker__exported_env_var_fpath} ]]; then  #true
        return
    fi

    #Get 'docker__env_var_link' from 'docker__exported_env_var_fpath'
    docker__env_var_link=`retrieve_env_var_link_from_file__func "${docker__dockerFile_fpath}" "${docker__exported_env_var_fpath}"`

    #Get 'docker__env_var_checkout' from 'docker__exported_env_var_fpath'
    docker__env_var_checkout=`retrieve_env_var_checkout_from_file__func "${docker__dockerFile_fpath}" "${docker__exported_env_var_fpath}"`
}

docker__calc_const_string_lengths__sub() {
    #Accumulate the lenght of all fixed objects (e.g. SPACE, BRACKETS, DOT, INDEX-NUMBERS, etc...)
    #For Example:
    #
    #    1. Choose docker-file (dockerfile_ltps_sunplus_env_test)
    #^^^^^^^                  ^^                                ^
    #|||||||                  ||                                |
    #+++++++------------------++--------------------------------+
    #             num of fixed objects = 10
    #
    #Define variables
    local fixed_numOfChars=${DOCKER__NUMOFCHARS_10}
    local leading_length=0

    #1. docker__dockerFile_filename
    #Get leading length
    leading_length=`get_stringlen_wo_regEx__func "${DOCKER__MENU_CHOOSE_DOCKERFILE}"`

    #Get trailing length
    docker__dockerFile_filename_maxLen=$((DOCKER__TABLEWIDTH - fixed_numOfChars - leading_length))

    #2. docker__env_var_link
    #Get leading length
    leading_length=`get_stringlen_wo_regEx__func "${DOCKER__MENU_CHOOSE_ADD_DEL_ENV_VAR_LINK}"`

    #Get trailing length
    docker__env_var_link_maxLen=$((DOCKER__TABLEWIDTH - fixed_numOfChars - leading_length))  

    #3. docker__env_var_checkout
    #Get leading length
    leading_length=`get_stringlen_wo_regEx__func "${DOCKER__MENU_CHOOSE_ADD_DEL_ENV_VAR_CHECKOUT}"`

    #Get trailing length
    docker__env_var_checkout_maxLen=$((DOCKER__TABLEWIDTH - fixed_numOfChars - leading_length))  
}

docker__trim_strings_toFit_within_specified_tableSize__sub() {
    #1. Trim 'docker__dockerFile_fpath'
    if [[ ! -z ${docker__dockerFile_fpath} ]]; then
        docker__dockerFile_filename=$(basename ${docker__dockerFile_fpath})

        docker__dockerFile_filename_print=`trim_string_toFit_specified_windowSize__func "${docker__dockerFile_filename}" \
                        "${docker__dockerFile_filename_maxLen}"  \
                        "${DOCKER__FALSE}"`
    else
        docker__dockerFile_filename_print="${DOCKER__DASH}"
    fi

    #Change foreground color to 'DOCKER__FG_LIGHTGREY'
    docker__dockerFile_filename_print="${DOCKER__FG_LIGHTGREY}${docker__dockerFile_filename_print}${DOCKER__NOCOLOR}"



    #2. Trim 'docker__env_var_link'
    if [[ ! -z ${docker__env_var_link} ]]; then
        docker__env_var_link_print=`trim_string_toFit_specified_windowSize__func "${docker__env_var_link}" \
                        "${docker__env_var_link_maxLen}"  \
                        "${DOCKER__FALSE}"`
    else
        docker__env_var_link_print="${DOCKER__DASH}"
    fi

    #Change foreground color to 'DOCKER__FG_LIGHTGREY'
    docker__env_var_link_print="${DOCKER__FG_LIGHTGREY}${docker__env_var_link_print}${DOCKER__NOCOLOR}"



    #3. Trim 'docker__env_var_checkout'
    if [[ ! -z ${docker__env_var_checkout} ]]; then
        docker__env_var_checkout_print=`trim_string_toFit_specified_windowSize__func "${docker__env_var_checkout}" \
                        "${docker__env_var_checkout_maxLen}"  \
                        "${DOCKER__FALSE}"`
    else
        docker__env_var_checkout_print="${DOCKER__DASH}"
    fi

    #Change foreground color to 'DOCKER__FG_LIGHTGREY'
    docker__env_var_checkout_print="${DOCKER__FG_LIGHTGREY}${docker__env_var_checkout_print}${DOCKER__NOCOLOR}"

}

docker__export_env_var_menu__sub() {
    #Initialization
    docker__prepend_numOfLines=${DOCKER__NUMOFLINES_2}

    while true
    do
        #Retrieve & prep variables
        docker__retrieve_and_prep_variables__sub

        #Print header
        docker__load_header__sub "${docker__prepend_numOfLines}"

        #Draw horizontal lines
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Show menu-title
        show_leadingAndTrailingStrings_separatedBySpaces__func "${DOCKER__EXPORT_ENVIRONMENT_VARIABLES_MENUTITLE}" \
                        "${DOCKER__VERSION}" \
                        "${DOCKER__TABLEWIDTH}"

        #Draw horizontal lines
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Show menu-options
        echo -e "${DOCKER__FOURSPACES}1. ${DOCKER__MENU_CHOOSE_DOCKERFILE} (${docker__dockerFile_filename_print})"

        #Only show the following options if 'docker__dockerFile_fpath' is Not an Empty String
        if [[ ! -z ${docker__dockerFile_fpath} ]]; then
            echo -e "${DOCKER__FOURSPACES}2. ${DOCKER__MENU_CHOOSE_ADD_DEL_ENV_VAR_LINK} (${docker__env_var_link_print})"
            echo -e "${DOCKER__FOURSPACES}3. ${DOCKER__MENU_CHOOSE_ADD_DEL_ENV_VAR_CHECKOUT} (${docker__env_var_checkout_print})"
            echo -e "${DOCKER__FOURSPACES}4. ${DOCKER__MENU_CHOOSE_ADD_DEL_LINKCHECKOUT_PROFILE}"

            docker__regEx=${DOCKER__REGEX_1_TO_4q}
        else
            docker__regEx=${DOCKER__REGEX_1q}
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
                if [[ ${docker__myChoice} =~ ${docker__regEx} ]]; then
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
                ${docker__select_dockerfile__fpath} "${docker__LTPP3_ROOTFS_docker_dockerfiles__dir}" \
                        "${DOCKER__CFG_NAME1}" \
                        "${docker__export_env_var_menu_cfg__fpath}"
                ;;
            2)
                ${docker__repo_link_checkout_menu_select__fpath} "${docker__dockerFile_fpath}" \
                        "${DOCKER__LINK}" \
                        "${DOCKER__MENU_CHOOSE_ADD_DEL_ENV_VAR_LINK}" \
                        "${DOCKER__MENU_CHOOSE_ADD_DEL_ENV_VAR_CHECKOUT}" \
                        "${DOCKER__MENU_CHOOSE_ADD_DEL_LINKCHECKOUT_PROFILE}"
                ;;
            3)
                ${docker__repo_link_checkout_menu_select__fpath} "${docker__dockerFile_fpath}" \
                        "${DOCKER__CHECKOUT}" \
                        "${DOCKER__MENU_CHOOSE_ADD_DEL_ENV_VAR_LINK}" \
                        "${DOCKER__MENU_CHOOSE_ADD_DEL_ENV_VAR_CHECKOUT}" \
                        "${DOCKER__MENU_CHOOSE_ADD_DEL_LINKCHECKOUT_PROFILE}"
                ;;
            4)
                ${docker__repo_link_checkout_menu_select__fpath} "${docker__dockerFile_fpath}" \
                        "${DOCKER__LINKCHECKOUT_PROFILE}" \
                        "${DOCKER__MENU_CHOOSE_ADD_DEL_ENV_VAR_LINK}" \
                        "${DOCKER__MENU_CHOOSE_ADD_DEL_ENV_VAR_CHECKOUT}" \
                        "${DOCKER__MENU_CHOOSE_ADD_DEL_LINKCHECKOUT_PROFILE}"
                ;;
            q)
                exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_2}"
                ;;
        esac

        #Set 'docker__prepend_numOfLines'
        docker__prepend_numOfLines=${DOCKER__NUMOFLINES_0}
    done
}
docker__retrieve_and_prep_variables__sub() {
    #Retrieve data from 'docker__export_env_var_menu_cfg__fpath'
    docker__retrieve_data_from_configFile__sub

    #Retrieve the 'link' and 'checkout' values from 'docker__exported_env_var_fpath'
    docker__retrieve_link_and_checkout_from_file__sub

    #Calculate the string lengths
    docker__calc_const_string_lengths__sub

    #Trim strings to fit within table-size
    docker__trim_strings_toFit_within_specified_tableSize__sub
}


#---MAIN SUBROUTINE
main__sub() {
    docker__load_environment_variables__sub

    docker__load_source_files__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__calc_const_string_lengths__sub

    docker__export_env_var_menu__sub
}



#---EXECUTE
main__sub
