#!/bin/bash -m
#Remark: by using '-m' the INTERRUPT executed here will NOT propagate to the UPPERLAYER scripts

#---SUBROUTINES
docker__get_source_fullpath__sub() {
    #Define constants
    local DOCKER__PHASE_CHECK_CACHE=1
    local DOCKER__PHASE_FIND_PATH=10
    local DOCKER__PHASE_EXIT=100

    #Define variables
    local docker__phase=""

    local docker__current_dir=
    local docker__tmp__dir=""

    local docker__development_tools__foldername=""
    local docker__LTPP3_ROOTFS__foldername=""
    local docker__global__filename=""
    local docker__parentDir_of_LTPP3_ROOTFS__dir=""

    local docker__mainmenu_path_cache__filename=""
    local docker__mainmenu_path_cache__fpath=""

    local docker__find_dir_result_arr=()
    local docker__find_dir_result_arritem=""
    local docker__find_dir_result_arrlen=0
    local docker__find_dir_result_arrlinectr=0
    local docker__find_dir_result_arrprogressperc=0

    local docker__path_of_development_tools_found=""
    local docker__parentpath_of_development_tools=""

    local docker__isfound=""

    #Set variables
    docker__phase="${DOCKER__PHASE_CHECK_CACHE}"
    docker__current_dir=$(dirname $(readlink -f $0))
    docker__tmp__dir=/tmp
    docker__development_tools__foldername="development_tools"
    docker__global__filename="docker_global.sh"
    docker__LTPP3_ROOTFS__foldername="LTPP3_ROOTFS"

    docker__mainmenu_path_cache__filename="docker__mainmenu_path.cache"
    docker__mainmenu_path_cache__fpath="${docker__tmp__dir}/${docker__mainmenu_path_cache__filename}"

    docker_result=false

    #Start loop
    while true
    do
        case "${docker__phase}" in
            "${DOCKER__PHASE_CHECK_CACHE}")
                if [[ -f "${docker__mainmenu_path_cache__fpath}" ]]; then
                    #Get the directory stored in cache-file
                    docker__LTPP3_ROOTFS_development_tools__dir=$(awk 'NR==1' "${docker__mainmenu_path_cache__fpath}")

                    #Move one directory up
                    docker__parentpath_of_development_tools=$(dirname "${docker__LTPP3_ROOTFS_development_tools__dir}")

                    #Check if 'development_tools' is in the 'LTPP3_ROOTFS' folder
                    docker__isfound=$(docker__checkif_paths_are_related "${docker__current_dir}" \
                            "${docker__parentpath_of_development_tools}" "${docker__LTPP3_ROOTFS__foldername}")
                    if [[ ${docker__isfound} == false ]]; then
                        docker__phase="${DOCKER__PHASE_FIND_PATH}"
                    else
                        docker_result=true

                        docker__phase="${DOCKER__PHASE_EXIT}"
                    fi
                else
                    docker__phase="${DOCKER__PHASE_FIND_PATH}"
                fi
                ;;
            "${DOCKER__PHASE_FIND_PATH}")   
                #Print
                echo -e "---:\e[30;38;5;215mSTART\e[0;0m: find path of folder \e[30;38;5;246m'${docker__development_tools__foldername}\e[0;0m : \e[1;33mDONE\e[0;0m"

                #Reset variable
                docker__LTPP3_ROOTFS_development_tools__dir=""

                #Start loop
                while true
                do
                    #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
                    #... and read to array 'find_result_arr'
                    readarray -t docker__find_dir_result_arr < <(find  / -type d -iname "${docker__LTPP3_ROOTFS__foldername}" 2> /dev/null)

                    #Get array-length
                    docker__find_dir_result_arrlen=${#docker__find_dir_result_arr[@]}

                    #Iterate thru each array-item
                    for docker__find_dir_result_arritem in "${docker__find_dir_result_arr[@]}"
                    do
                        docker__isfound=$(docker__checkif_paths_are_related "${docker__current_dir}" \
                                "${docker__find_dir_result_arritem}"  "${docker__LTPP3_ROOTFS__foldername}")
                        if [[ ${docker__isfound} == true ]]; then
                            #Update variable 'docker__path_of_development_tools_found'
                            docker__path_of_development_tools_found="${docker__find_dir_result_arritem}/${docker__development_tools__foldername}"

                            # #Increment counter
                            docker__find_dir_result_arrlinectr=$((docker__find_dir_result_arrlinectr+1))

                            #Calculate the progress percentage value
                            docker__find_dir_result_arrprogressperc=$(( docker__find_dir_result_arrlinectr*100/docker__find_dir_result_arrlen ))

                            #Moveup and clean
                            if [[ ${docker__find_dir_result_arrlinectr} -gt 1 ]]; then
                                tput cuu1
                                tput el
                            fi

                            #Print
                            #Note: do not print the '100%'
                            if [[ ${docker__find_dir_result_arrlinectr} -lt ${docker__find_dir_result_arrlen} ]]; then
                                echo -e "------:PROGRESS: ${docker__find_dir_result_arrprogressperc}%"
                            fi

                            #Check if 'directory' exist
                            if [[ -d "${docker__path_of_development_tools_found}" ]]; then    #directory exists
                                #Update variable
                                #Remark:
                                #   'docker__LTPP3_ROOTFS_development_tools__dir' is a global variable.
                                #   This variable will be passed 'globally' to script 'docker_global.sh'.
                                docker__LTPP3_ROOTFS_development_tools__dir="${docker__path_of_development_tools_found}"

                                #Print
                                #Note: print the '100%' here
                                echo -e "------:PROGRESS: 100%"

                                break
                            fi
                        fi
                    done

                    #Check if 'docker__LTPP3_ROOTFS_development_tools__dir' contains any data
                    if [[ -z "${docker__LTPP3_ROOTFS_development_tools__dir}" ]]; then  #contains no data
                        echo -e "\r"
                        echo -e "***\e[1;31mERROR\e[0;0m: folder \e[30;38;5;246m${docker__development_tools__foldername}\e[0;0m: \e[30;38;5;131mNot Found\e[0;0m"
                        echo -e "\r"

                         #Update variable
                        docker_result=false
                    else    #contains data
                        #Print
                        echo -e "---:\e[30;38;5;215mCOMPLETED\e[0;0m: find path of folder \e[30;38;5;246m'${docker__development_tools__foldername}\e[0;0m : \e[1;33mDONE\e[0;0m"


                        #Write to file
                        echo "${docker__LTPP3_ROOTFS_development_tools__dir}" | tee "${docker__mainmenu_path_cache__fpath}" >/dev/null

                        #Print
                        echo -e "---:\e[30;38;5;215mSTATUS\e[0;0m: write path to temporary cache-file: \e[1;33mDONE\e[0;0m"

                        #Update variable
                        docker_result=true
                    fi

                    #set phase
                    docker__phase="${DOCKER__PHASE_EXIT}"

                    #Exit loop
                    break
                done
                ;;    
            "${DOCKER__PHASE_EXIT}")
                break
                ;;
        esac
    done

    #Exit if 'docker_result = false'
    if [[ ${docker_result} == false ]]; then
        exit 99
    fi

    #Retrieve directories
    #Remark:
    #   'docker__LTPP3_ROOTFS__dir' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/
    docker__parentDir_of_LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS__dir%/*}    #move two directories up. This directory is the one-level higher than LTPP3_ROOTFS/

    #Get full-path
    #Remark:
    #   'docker__global__fpath' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__global__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__global__filename}
}
docker__checkif_paths_are_related() {
    #Input args
    local scriptdir__input=${1}
    local finddir__input=${2}
    local pattern__input=${3}

    #Define constants
    local PHASE_PATTERN_CHECK1=1
    local PHASE_PATTERN_CHECK2=10
    local PHASE_PATH_COMPARISON=20
    local PHASE_EXIT=100

    #Define variables
    local phase="${PHASE_PATTERN_CHECK1}"
    local isfound1=""
    local isfound2=""
    local isfound3=""
    local ret=false

    while true
    do
        case "${phase}" in
            "${PHASE_PATTERN_CHECK1}")
                #Check if 'pattern__input' is found in 'scriptdir__input'
                isfound1=$(echo "${scriptdir__input}" | \
                        grep -o "${pattern__input}.*" | \
                        cut -d"/" -f1 | grep -w "^${pattern__input}$")
                if [[ -z "${isfound1}" ]]; then
                    ret=false

                    phase="${PHASE_EXIT}"
                else
                    phase="${PHASE_PATTERN_CHECK2}"
                fi                
                ;;
            "${PHASE_PATTERN_CHECK2}")
                #Check if 'pattern__input' is found in 'finddir__input'
                isfound2=$(echo "${finddir__input}" | \
                        grep -o "${pattern__input}.*" | \
                        cut -d"/" -f1 | grep -w "^${pattern__input}$")
                if [[ -z "${isfound2}" ]]; then
                    ret=false

                    phase="${PHASE_EXIT}"
                else
                    phase="${PHASE_PATH_COMPARISON}"
                fi                
                ;;
            "${PHASE_PATH_COMPARISON}")
                #Check if 'development_tools' is under the folder 'LTPP3_ROOTFS'
                isfound3=$(echo "${scriptdir__input}" | \
                        grep -w "${finddir__input}.*")
                if [[ -z "${isfound3}" ]]; then
                    ret=false
                else
                    ret=true
                fi

                phase="${PHASE_EXIT}"
                ;;
            "${PHASE_EXIT}")
                break
                ;;
        esac
    done

    #Output
    echo "${ret}"

    return 0
}
docker__load_global_fpath_paths__sub() {
    source ${docker__global__fpath}
}

docker__load_constants__sub() {
    DOCKER__EXPORT_ENVIRONMENT_VARIABLES_MENUTITLE="${DOCKER__FG_LIGHTBLUE}DOCKER: EXPORT ENVIRONMENT VARIABLES${DOCKER__NOCOLOR}"

    DOCKER__DIRLIST_MENUTITLE="Choose ${DOCKER__FG_DARKBLUE}docker-file${DOCKER__NOCOLOR}"
    DOCKER__DIRLIST_LOCATION_INFO="${DOCKER__FOURSPACES}${DOCKER__FG_ORANGE223}Location${DOCKER__NOCOLOR}: ${docker__LTPP3_ROOTFS_docker_dockerfiles__dir}"
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
    DOCKER__MENU_CHOOSE_ADD_DEL_LINKCHECKOUT_PROFILE+="profile"
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

    docker__tibboHeader_prepend_numOfLines=0
}

docker__retrieve_data_from_configFile__sub() {
    #Check if file exist and contains data
    if [[ ! -s ${docker__export_env_var_menu_cfg__fpath} ]]; then
        return
    fi

    #Retrieve data
    docker__dockerFile_fpath=`retrieve__data_specified_by_col_within_file__func \
                        "${DOCKER__CONFIGNAME____DOCKER__DOCKERFILE_FPATH}" \
                        "${DOCKER__COLNUM_2}" \
                        "${docker__export_env_var_menu_cfg__fpath}"`

    #Check if 'docker__dockerFile_fpath' exists
    if [[ ! -f ${docker__dockerFile_fpath} ]]; then #does not exist
        #Reset variable
        docker__dockerFile_fpath=${DOCKER__EMPTYSTRING}

        #Remove line containing 'DOCKER__CONFIGNAME____DOCKER__DOCKERFILE_FPATH' value
        find_and_remove_all_lines_from_file_forGiven_keyWord__func "${docker__export_env_var_menu_cfg__fpath}" \
                        "${DOCKER__CONFIGNAME____DOCKER__DOCKERFILE_FPATH}"
    fi
}

docker__retrieve_link_and_checkout_from_file__sub() {
    #----------------------------------------------------------------
    #IMPORTANT:
    #   this subroutine MUST be executed AFTER 'docker__retrieve_data_from_configFile__sub'
    #----------------------------------------------------------------

    #Check if 'docker__dockerFile_fpath' or 'docker__exported_env_var__fpath' does exist?
    if [[ ! -f ${docker__dockerFile_fpath} ]] || [[ ! -f ${docker__exported_env_var__fpath} ]]; then  #true
        return
    fi

    #Get 'docker__env_var_link' from 'docker__exported_env_var__fpath'
    docker__env_var_link=`retrieve_env_var_link_from_file__func "${docker__dockerFile_fpath}" "${docker__exported_env_var__fpath}"`

    #Get 'docker__env_var_checkout' from 'docker__exported_env_var__fpath'
    docker__env_var_checkout=`retrieve_env_var_checkout_from_file__func "${docker__dockerFile_fpath}" "${docker__exported_env_var__fpath}"`
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
    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

    while true
    do
        #Get Git-information
        #Output:
        #   docker_git_current_info_msg
        docker__get_git_info__sub

        #Retrieve & prep variables
        docker__retrieve_and_prep_variables__sub

        #Print header
        load_tibbo_title__func "${docker__tibboHeader_prepend_numOfLines}"

        #Set 'docker__tibboHeader_prepend_numOfLines'
        docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_0}

        #Draw horizontal lines
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Show menu-title
        show_leadingAndTrailingStrings_separatedBySpaces__func "${DOCKER__EXPORT_ENVIRONMENT_VARIABLES_MENUTITLE}" \
                        "${docker_git_current_info_msg}" \
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

                docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_1}
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
                exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_1}"
                ;;
        esac
    done
}

docker__retrieve_and_prep_variables__sub() {
    #Retrieve data from 'docker__export_env_var_menu_cfg__fpath'
    docker__retrieve_data_from_configFile__sub

    #Retrieve the 'link' and 'checkout' values from 'docker__exported_env_var__fpath'
    docker__retrieve_link_and_checkout_from_file__sub

    #Calculate the string lengths
    docker__calc_const_string_lengths__sub

    #Trim strings to fit within table-size
    docker__trim_strings_toFit_within_specified_tableSize__sub
}

docker__get_git_info__sub() {
    #Get information
    docker__git_current_branchName=`git__get_current_branchName__func`

    docker__git_current_abbrevCommitHash=`git__log_for_pushed_and_unpushed_commits__func "${DOCKER__EMPTYSTRING}" \
                        "${GIT__LAST_COMMIT}" \
                        "${GIT__PLACEHOLDER_ABBREV_COMMIT_HASH}"`
      
    docker__git_push_status=`git__checkIf_branch_isPushed__func "${docker__git_current_branchName}"`

    docker__git_current_tag=`git__get_tag_for_specified_branchName__func "${docker__git_current_branchName}" "${DOCKER__FALSE}"`
    if [[ -z "${docker__git_current_tag}" ]]; then
        docker__git_current_tag="${GIT__NOT_TAGGED}"
    fi

    #Generate message to be shown
    docker_git_current_info_msg="${DOCKER__FG_LIGHTBLUE}${docker__git_current_branchName}${DOCKER__NOCOLOR}:"
    docker_git_current_info_msg+="${DOCKER__FG_DARKBLUE}${docker__git_current_abbrevCommitHash}${DOCKER__NOCOLOR}"
    docker_git_current_info_msg+="(${DOCKER__FG_DARKBLUE}${docker__git_push_status}${DOCKER__NOCOLOR}):"
    docker_git_current_info_msg+="${DOCKER__FG_LIGHTBLUE}${docker__git_current_tag}${DOCKER__NOCOLOR}"
}



#---MAIN SUBROUTINE
main__sub() {
    docker__get_source_fullpath__sub

    docker__load_global_fpath_paths__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__calc_const_string_lengths__sub

    docker__export_env_var_menu__sub
}



#---EXECUTE
main__sub
