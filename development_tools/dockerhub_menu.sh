#!/bin/bash -m
#Remark:
#   Line (#!/bin/bash -m) may cause the git-menu and its sub-menus not to respond correctly)
#   Should this be the case then remove line (#!/bin/bash -m)

#---SUBROUTINES
docker__get_source_fullpath__sub() {
    #Define constants
    local PHASE_CHECK_CACHE=1
    local PHASE_FIND_PATH=10
    local PHASE_EXIT=100

    #Define variables
    local phase=""

    local current_dir=""
    local parent_dir=""
    local search_dir=""
    local tmp_dir=""

    local development_tools_foldername=""
    local lTPP3_ROOTFS_foldername=""
    local global_filename=""
    local parentDir_of_LTPP3_ROOTFS_dir=""

    local mainmenu_path_cache_filename=""
    local mainmenu_path_cache_fpath=""

    local find_dir_result_arr=()
    local find_dir_result_arritem=""

    local path_of_development_tools_found=""
    local parentpath_of_development_tools=""

    local isfound=""

    local retry_ctr=0

    #Set variables
    phase="${PHASE_CHECK_CACHE}"
    current_dir=$(dirname $(readlink -f $0))
    parent_dir="$(dirname "${current_dir}")"
    tmp_dir=/tmp
    development_tools_foldername="development_tools"
    global_filename="docker_global.sh"
    lTPP3_ROOTFS_foldername="LTPP3_ROOTFS"

    mainmenu_path_cache_filename="docker__mainmenu_path.cache"
    mainmenu_path_cache_fpath="${tmp_dir}/${mainmenu_path_cache_filename}"

    result=false

    #Start loop
    while true
    do
        case "${phase}" in
            "${PHASE_CHECK_CACHE}")
                if [[ -f "${mainmenu_path_cache_fpath}" ]]; then
                    #Get the directory stored in cache-file
                    docker__LTPP3_ROOTFS_development_tools__dir=$(awk 'NR==1' "${mainmenu_path_cache_fpath}")

                    #Move one directory up
                    parentpath_of_development_tools=$(dirname "${docker__LTPP3_ROOTFS_development_tools__dir}")

                    #Check if 'development_tools' is in the 'LTPP3_ROOTFS' folder
                    isfound=$(docker__checkif_paths_are_related "${current_dir}" \
                            "${parentpath_of_development_tools}" "${lTPP3_ROOTFS_foldername}")
                    if [[ ${isfound} == false ]]; then
                        phase="${PHASE_FIND_PATH}"
                    else
                        result=true

                        phase="${PHASE_EXIT}"
                    fi
                else
                    phase="${PHASE_FIND_PATH}"
                fi
                ;;
            "${PHASE_FIND_PATH}")   
                #Print
                echo -e "---:\e[30;38;5;215mSTART\e[0;0m: find path of folder \e[30;38;5;246m'${development_tools_foldername}\e[0;0m"

                #Initialize variables
                docker__LTPP3_ROOTFS_development_tools__dir=""
                search_dir="${current_dir}"   #start with search in the current dir

                #Start loop
                while true
                do
                    #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
                    #... and read to array 'find_result_arr'
                    readarray -t find_dir_result_arr < <(find  "${search_dir}" -type d -iname "${lTPP3_ROOTFS_foldername}" 2> /dev/null)

                    #Iterate thru each array-item
                    for find_dir_result_arritem in "${find_dir_result_arr[@]}"
                    do
                        echo -e "---:\e[30;38;5;215mCHECKING\e[0;0m: ${find_dir_result_arritem}"

                        #Find path
                        isfound=$(docker__checkif_paths_are_related "${current_dir}" \
                                "${find_dir_result_arritem}"  "${lTPP3_ROOTFS_foldername}")
                        if [[ ${isfound} == true ]]; then
                            #Update variable 'path_of_development_tools_found'
                            path_of_development_tools_found="${find_dir_result_arritem}/${development_tools_foldername}"

                            #Check if 'directory' exist
                            if [[ -d "${path_of_development_tools_found}" ]]; then    #directory exists
                                #Update variable
                                #Remark:
                                #   'docker__LTPP3_ROOTFS_development_tools__dir' is a global variable.
                                #   This variable will be passed 'globally' to script 'docker_global.sh'.
                                docker__LTPP3_ROOTFS_development_tools__dir="${path_of_development_tools_found}"

                                break
                            fi
                        fi
                    done

                    #Check if 'docker__LTPP3_ROOTFS_development_tools__dir' contains any data
                    if [[ -z "${docker__LTPP3_ROOTFS_development_tools__dir}" ]]; then  #contains no data
                        case "${retry_ctr}" in
                            0)
                                search_dir="${parent_dir}"    #next search in the 'parent' directory
                                ;;
                            1)
                                search_dir="/" #finally search in the 'main' directory (the search may take longer)
                                ;;
                            *)
                                echo -e "\r"
                                echo -e "***\e[1;31mERROR\e[0;0m: folder \e[30;38;5;246m${development_tools_foldername}\e[0;0m: \e[30;38;5;131mNot Found\e[0;0m"
                                echo -e "\r"

                                #Update variable
                                result=false

                                #set phase
                                phase="${PHASE_EXIT}"

                                break
                                ;;
                        esac

                        ((retry_ctr++))
                    else    #contains data
                        #Print
                        echo -e "---:\e[30;38;5;215mCOMPLETED\e[0;0m: find path of folder \e[30;38;5;246m'${development_tools_foldername}\e[0;0m"


                        #Write to file
                        echo "${docker__LTPP3_ROOTFS_development_tools__dir}" | tee "${mainmenu_path_cache_fpath}" >/dev/null

                        #Print
                        echo -e "---:\e[30;38;5;215mSTATUS\e[0;0m: write path to temporary cache-file: \e[1;33mDONE\e[0;0m"

                        #Update variable
                        result=true

                        #set phase
                        phase="${PHASE_EXIT}"

                        break
                    fi
                done
                ;;    
            "${PHASE_EXIT}")
                break
                ;;
        esac
    done

    #Exit if 'result = false'
    if [[ ${result} == false ]]; then
        exit 99
    fi

    #Retrieve directories
    #Remark:
    #   'docker__LTPP3_ROOTFS__dir' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/
    parentDir_of_LTPP3_ROOTFS_dir=${docker__LTPP3_ROOTFS__dir%/*}    #move two directories up. This directory is the one-level higher than LTPP3_ROOTFS/

    #Get full-path
    #Remark:
    #   'docker__global__fpath' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__global__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${global_filename}
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
    DOCKERHUB__MENUTITLE="${DOCKER__FG_LIGHTBLUE}DOCKERHUB MENU${DOCKER__NOCOLOR}"

    DOCKER__DOCKERHUB_PRINT="--->${DOCKER__BG_LIGHTBLUE}DOCKER-HUB${DOCKER__NOCOLOR}"
    DOCKER__DOCKERHUB_LOGIN_PRINT="${DOCKER__DOCKERHUB_PRINT}: login"
    DOCKER__DOCKERHUB_READDIALOG_REPO_INPUT="${DOCKER__DOCKERHUB_PRINT}: input ${DOCKER__FG_BRIGHTLIGHTPURPLE}repository${DOCKER__NOCOLOR}: "
    DOCKER__DOCKERHUB_READDIALOG_TAG_INPUT="${DOCKER__DOCKERHUB_PRINT}: input ${DOCKER__FG_LIGHTPINK}tag${DOCKER__NOCOLOR}: "
    DOCKER__DOCKERHUB_PUSH_PRINT="${DOCKER__DOCKERHUB_PRINT}: push"
    DOCKER__DOCKERHUB_REMOVE_CACHE_FILE="${DOCKER__DOCKERHUB_PRINT}: remove cache file"
}

docker__init_variables__sub() {
    # docker__current_checkOut_branch=${DOCKER__EMPTYSTRING}
    docker__exitCode=0
    docker__imageID_chosen=${DOCKER__EMPTYSTRING}
    docker__myChoice=""    
    docker__regEx="[012q]"
    docker__repo_chosen=${DOCKER__EMPTYSTRING}
    docker__repoTag_get=${DOCKER__EMPTYSTRING}
    docker__repo_put=${DOCKER__EMPTYSTRING}
    docker__tag_put=${DOCKER__EMPTYSTRING}
    docker__repoTag_put=${DOCKER__EMPTYSTRING}
    docker__tag_chosen=${DOCKER__EMPTYSTRING}
    docker__tibboHeader_prepend_numOfLines=0

    docker__childWhileLoop_isExit=false
    docker__onEnter_breakLoop=false
    docker__parentWhileLoop_isExit=false
    docker__showTable=true
}

docker__dockerhub_menu__sub() {
    #Initialization
    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

    while true
    do
        #Get Git-information
        #Output:
        #   docker_git_current_info_msg
        docker__get_git_info__sub

        #Load header
        load_tibbo_title__func "${docker__tibboHeader_prepend_numOfLines}"

        #Set 'docker__tibboHeader_prepend_numOfLines'
        docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_1}

        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        show_leadingAndTrailingStrings_separatedBySpaces__func "${DOCKERHUB__MENUTITLE}" "${docker_git_current_info_msg}" "${DOCKER__TABLEWIDTH}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        # echo -e "${DOCKER__FOURSPACES}Current Checkout Branch: ${DOCKER__FG_LIGHTSOFTYELLOW}${docker__git_current_branchName}${DOCKER__NOCOLOR}"
        # duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}1. Push"
        echo -e "${DOCKER__FOURSPACES}2. Pull"
        echo -e "${DOCKER__FOURSPACES}0. Enter Command Prompt"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}q. $DOCKER__QUIT_CTRL_C"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        # echo -e "\r"

        while true
        do
            #Select an option
            read -N1 -r -p "Please choose an option: " docker__myChoice
            echo -e "\r"

            #Only continue if a valid option is selected
            case "${docker__myChoice}" in
                ${DOCKER__CTRL_C})
                    docker__exit_handler__sub
                    ;;
                *)
                    if [[ ! -z "${docker__myChoice}" ]]; then
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
                    ;;
            esac

            #Check if flag is given to break loop
            if [[ ${docker__childWhileLoop_isExit} == true ]]; then
                break
            fi
        done
            
        #Goto the selected option
        case ${docker__myChoice} in
            1)  
                docker__docker_push_handler__sub
                ;;
            2)  
                docker__docker_pull__sub "tibbotech/ltpp3_g2_u"
                ;;
            0)
                ${docker__enter_cmdline_mode__fpath} "${DOCKER__EMPTYSTRING}"
                ;;
            q)
                docker__exit_handler__sub
                ;;
        esac

        #Check if flag is given to break loop
        if [[ ${docker__parentWhileLoop_isExit} == true ]]; then
            break
        fi
    done
}

docker__docker_push_handler__sub() {
    #Define phase constants
    local IMAGEID_SELECT_PHASE=0
    local REPOTAG_RETRIEVE_PHASE=1
    local DOCKER_PUSH_PHASE=2

    #Define message constants
    local MENUTITLE="Docker Push"

    #Define variables
    local containerName=${DOCKER__EMPTYSTRING}
    local errMsg=${DOCKER__EMPTYSTRING}
    local phase=${DOCKER__EMPTYSTRING}
    local readmsg_remarks=${DOCKER__EMPTYSTRING}



    #Set 'readmsg_remarks'
    readmsg_remarks="${DOCKER__BG_ORANGE}Remarks:${DOCKER__NOCOLOR}\n"
    readmsg_remarks+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}Up/Down Arrow${DOCKER__NOCOLOR}: to cycle thru existing values\n"
    readmsg_remarks+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}TAB${DOCKER__NOCOLOR}: auto-complete\n"
    readmsg_remarks+="${DOCKER__DASH} ${DOCKER__FG_YELLOW};c${DOCKER__NOCOLOR}: clear"

    #Set initial 'phase'
    phase=${IMAGEID_SELECT_PHASE}
    while true
    do
        case "${phase}" in
            ${IMAGEID_SELECT_PHASE})
                ${docker__readInput_w_autocomplete__fpath} "${MENUTITLE}" \
                                    "${DOCKER__READINPUTDIALOG_CHOOSE_IMAGEID_FROM_LIST}" \
                                    "${DOCKER__EMPTYSTRING}" \
                                    "${readmsg_remarks}" \
                                    "${DOCKER__ERRMSG_NO_IMAGES_FOUND}" \
                                    "${DOCKER__ERRMSG_CHOSEN_IMAGEID_DOESNOT_EXISTS}" \
                                    "${docker__images_cmd}" \
                                    "${docker__images_IDColNo}" \
                                    "${DOCKER__EMPTYSTRING}" \
                                    "${docker__showTable}" \
                                    "${docker__onEnter_breakLoop}" \
                                    "${DOCKER__NUMOFLINES_2}"

                #Get the exit-code just in case:
                #   1. Ctrl-C was pressed in script 'docker__readInput_w_autocomplete__fpath'.
                #   2. An error occured in script 'docker__readInput_w_autocomplete__fpath',...
                #      ...and exit-code = 99 came from function...
                #      ...'show_msg_w_menuTitle_w_pressAnyKey_w_ctrlC_func' (in script: docker__global.sh).
                docker__exitCode=$?
                if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
                    exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_0}"
                else
                    #Retrieve the 'new tag' from file
                    docker__imageID_chosen=`get_output_from_file__func \
                                "${docker__readInput_w_autocomplete_out__fpath}" \
                                "${DOCKER__LINENUM_1}"`
                fi

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
                if [[ -z ${docker__repo_chosen} ]] || \
                            [[ -z ${docker__tag_chosen} ]]; then
                    return
                elif [[ ${docker__repo_chosen} == ${DOCKER__NONE} ]] || \
                            [[ ${docker__tag_chosen} == ${DOCKER__NONE} ]]; then
                    errMsg="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Incomplete image '${docker__imageID_chosen}'"
                    show_msg_wo_menuTitle_w_PressAnyKey__func "${errMsg}" \
                                "${DOCKER__NUMOFLINES_0}" \
                                "${DOCKER__TIMEOUT_10}" \
                                "${DOCKER__NUMOFLINES_1}" \
                                "${DOCKER__NUMOFLINES_3}"
                    return
                else
                    phase=${DOCKER_PUSH_PHASE}
                fi
                
                ;;
            ${DOCKER_PUSH_PHASE})
                docker__docker_push__sub
                
                return
                ;;
        esac
    done
}
docker__get_and_check_repoTag__sub() {
    #Define message constants
    local ERRMSG_NO_REPO_FOUND="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: No matching ${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR} found for ${DOCKER__FG_BORDEAUX}ID${DOCKER__NOCOLOR} '${DOCKER__FG_LIGHTGREY}${docker__imageID_chosen}${DOCKER__NOCOLOR}'"
    local ERRMSG_NO_TAG_FOUND="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: No matching ${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} found for ${DOCKER__FG_BORDEAUX}ID${DOCKER__NOCOLOR} '${DOCKER__FG_LIGHTGREY}${docker__imageID_chosen}${DOCKER__NOCOLOR}'"
    local ERRMSG_NO_REPO_TAG_FOUND="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: No matching ${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR} and ${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} found for ${DOCKER__FG_BORDEAUX}ID${DOCKER__NOCOLOR} '${DOCKER__FG_LIGHTGREY}${docker__imageID_chosen}${DOCKER__NOCOLOR}'"

    #Get repository
    docker__repo_chosen=`${docker__images_cmd} | grep -w ${docker__imageID_chosen} | awk -vcolNo=${docker__images_repoColNo} '{print $colNo}'`

    #Get tag
    docker__tag_chosen=`${docker__images_cmd} | grep -w ${docker__imageID_chosen} | awk -vcolNo=${docker__images_tagColNo} '{print $colNo}'`

    #Check if any of the value is an Empty String
    if [[ -z ${docker__repo_chosen} ]] && [[ -z ${docker__tag_chosen} ]]; then
        show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_NO_REPO_TAG_FOUND}" "${DOCKER__NUMOFLINES_2}"
    else
        if [[ -z ${docker__repo_chosen} ]]; then
            show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_NO_REPO_FOUND}" "${DOCKER__NUMOFLINES_2}"
        fi

        if [[ -z ${docker__tag_chosen} ]]; then
            show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_NO_TAG_FOUND}" "${DOCKER__NUMOFLINES_2}"
        fi
    fi
}

docker__docker_push__sub() {
    #Define variables
    local printmsg="${DOCKER__EMPTYSTRING}"

    #Initialize variables
    docker__repoTag_get="${DOCKER__EMPTYSTRING}"

    #Combine 'myRepository' and 'myTag', but separated by a colon ':'
    docker__repoTag_get="${docker__repo_chosen}:${docker__tag_chosen}"

    #Run dockerhub login
    printmsg="${DOCKER__DOCKERHUB_LOGIN_PRINT}"
    show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_0}"

    ${docker__docker_login_cmd}; docker__exitCode=$?

    if [[ ${docker__exitCode} -eq 0 ]]; then
        #Docker push repository:tag
        printmsg="${DOCKER__DOCKERHUB_PUSH_PRINT} ${docker__repoTag_get}"
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_2}" "${DOCKER__NUMOFLINES_0}"

        ${docker__docker_push_cmd} ${docker__repoTag_get}

        #Remove docker login cache
        printmsg="${DOCKER__DOCKERHUB_REMOVE_CACHE_FILE} '${docker__config_json__fpath}'"
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_2}" "${DOCKER__NUMOFLINES_0}"

        rm "${docker__config_json__fpath}"
    fi

    #Move-down and clean 1 line
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
}

docker__docker_pull__sub() {
    #Initialize variables
    docker__repo_put="${DOCKER__EMPTYSTRING}"
    docker__tag_put="${DOCKER__EMPTYSTRING}"

    #Show read-dialog for 'repository' input
    readDialog_w_Output__func "${DOCKER__DOCKERHUB_READDIALOG_REPO_INPUT}" \
                    "${DOCKER__EMPTYSTRING}" \
                    "${docker__readDialog_w_Output__func_out__fpath}" \
                    "${DOCKER__NUMOFLINES_2}" \
                    "${DOCKER__NUMOFLINES_0}"

    #Get the exitcode just in case a Ctrl-C was pressed in function 'readDialog_w_Output__func'
    docker__exitCode=$?
    if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
        exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
    fi

    #Get docker__result_from_output
    docker__repo_put=`retrieve_line_from_file__func "${DOCKER__LINENUM_1}" \
                    "${docker__readDialog_w_Output__func_out__fpath}"`

    #Show read-dialog for 'tag' input
    readDialog_w_Output__func "${DOCKER__DOCKERHUB_READDIALOG_TAG_INPUT}" \
                    "${DOCKER__EMPTYSTRING}" \
                    "${docker__readDialog_w_Output__func_out__fpath}" \
                    "${DOCKER__NUMOFLINES_0}" \
                    "${DOCKER__NUMOFLINES_0}"

    #Get the exitcode just in case a Ctrl-C was pressed in function 'readDialog_w_Output__func'
    docker__exitCode=$?
    if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
        exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
    fi

    #Get docker__result_from_output
    docker__tag_put=`retrieve_line_from_file__func "${DOCKER__LINENUM_1}" \
                    "${docker__readDialog_w_Output__func_out__fpath}"`

    #Combine 'docker__repo_put' and 'docker__tag_put'
    docker__repoTag_put="${docker__repo_put}:${docker__tag_put}"

    #Docker pull repository:tag
    ${docker__docker_pull_cmd} ${docker__repoTag_put}

    #Move-down and clean 1 line
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
}

docker__exit_handler__sub() {
    #Set flag to true
    docker__childWhileLoop_isExit=true
    docker__parentWhileLoop_isExit=true

    #Move-down and clean 1 line
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
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

    docker__dockerhub_menu__sub
}



#---EXECUTE
main__sub