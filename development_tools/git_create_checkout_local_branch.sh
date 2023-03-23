#!/bin/bash -m
#Remark: by using '-m' the INTERRUPT executed here will NOT propagate to the UPPERLAYER scripts

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
                                ;;
                        esac
                    else    #contains data
                        #Print
                        echo -e "---:\e[30;38;5;215mCOMPLETED\e[0;0m: find path of folder \e[30;38;5;246m'${development_tools_foldername}\e[0;0m"


                        #Write to file
                        echo "${docker__LTPP3_ROOTFS_development_tools__dir}" | tee "${mainmenu_path_cache_fpath}" >/dev/null

                        #Print
                        echo -e "---:\e[30;38;5;215mSTATUS\e[0;0m: write path to temporary cache-file: \e[1;33mDONE\e[0;0m"

                        #Update variable
                        result=true
                    fi

                    #set phase
                    phase="${PHASE_EXIT}"

                    #Exit loop
                    break
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
    DOCKER__MENUTITLE="Git Create/Checkout "
    DOCKER__MENUTITLE+="${DOCKER__FG_LIGHTGREY}Local${DOCKER__NOCOLOR} Branch"
    DOCKER__READDIALOG="Input: "
}

docker__init_variables__sub() {
    docker__branch_chosen=${DOCKER__EMPTYSTRING}
    docker__stdErr=${DOCKER__EMPTYSTRING}

    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_0}

    docker__branch_chosen_isFound=false
    docker__onEnter_breakLoop=false
    docker__showTable=true
}

docker__create_checkout_local_branch_handler__sub() {
    #Define local constants
    local PRINTF_CHECKOUT_OF_EXISTING_BRANCH="checkout of existing branch"
    local PRINTF_CHECKOUT_OF_NEW_BRANCH="checkout of new branch"

    local QUESTION_CHECKOUT_BRANCH="Check out chosen Branch (${DOCKER__Y_SLASH_N_SLASH_Q})? "
    local QUESTION_CREATE_AND_CHECKOUT_BRANCH="Create & Check out chosen Branch (${DOCKER__Y_SLASH_N_SLASH_Q})? "

    #Define local variables
    local answer=${DOCKER__EMPTYSTRING}

    local printf_msg=${DOCKER__EMPTYSTRING}
    local printf_subjectMsg=${DOCKER__EMPTYSTRING}
    local readDialog=${DOCKER__EMPTYSTRING}

    local isCheckedOut=${DOCKER__FALSE}



#Goto phase: START
goto__func START



@START:
    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

    goto__func PRECHECK



@PRECHECK:
    #Check if the current directory is a git-repository
    docker__stdErr=`${GIT__CMD_GIT_BRANCH} 2>&1 > /dev/null`
    if [[ ! -z ${docker__stdErr} ]]; then   #not a git-repository
        goto__func EXIT_PRECHECK_FAILED  #goto next-phase
    else    #is a git-repository
        goto__func BRANCH_SHOW_AND_INPUT
    fi



@BRANCH_SHOW_AND_INPUT:
    #Output: docker__branch_chosen
    docker__show_and_input_git_branch__sub

    #Check if 'docker__branch_chosen' already exists
    docker__branch_chosen_isFound=`git__checkIf_branch_alreadyExists__func "${docker__branch_chosen}"`
    if [[ ${docker__branch_chosen_isFound} == ${DOCKER__TRUE} ]]; then
        #Check if asterisk is present
        isCheckedOut=`git__checkIf_branch_isCheckedOut__func "${docker__branch_chosen}"`
        if [[ ${isCheckedOut} == ${DOCKER__FALSE} ]]; then  #asterisk is NOT found
            #Update message
            printf_msg="---:${DOCKER__CHECK}: Branch ${DOCKER__FG_LIGHTGREY}${docker__branch_chosen}${DOCKER__NOCOLOR} is present"

            #Update variable
            readDialog="---:${DOCKER__QUESTION}: ${QUESTION_CHECKOUT_BRANCH}"
        else    #asterisk is found
            #Update message
            printf_msg="---:${DOCKER__CHECK}: Branch ${DOCKER__FG_LIGHTGREY}${docker__branch_chosen}${DOCKER__NOCOLOR} is present and already checked out"

            #Show message
            show_msg_only__func "${printf_msg}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_2}"

            #Goto next-phase
            goto__func BRANCH_SHOW_AND_INPUT
        fi
    else
        #Update message
        printf_msg="---:${DOCKER__CHECK}: Branch ${DOCKER__FG_LIGHTGREY}${docker__branch_chosen}${DOCKER__NOCOLOR} is new"

        #Update variable
        readDialog="---:${DOCKER__QUESTION}: ${QUESTION_CREATE_AND_CHECKOUT_BRANCH}"
    fi


    #Show message
    show_msg_only__func "${printf_msg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_1}"

    #Show question
    while true
    do
        #Show read-dialog
        read -N1 -p "${readDialog}" answer

        if [[ ! -z ${answer} ]]; then #contains data
            #Handle 'answer'
            if [[ ${answer} =~ ${DOCKER__REGEX_YNQ} ]]; then
                case "${answer}" in
                    ${DOCKER__QUIT})
                        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

                        goto__func EXIT_SUCCESSFUL  #goto next-phase
                        ;;
                    ${DOCKER__NO})
                        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_3}"

                        goto__func BRANCH_SHOW_AND_INPUT    #goto next-phase
                        ;;
                    *)
                        if [[ ${docker__branch_chosen_isFound} == ${DOCKER__TRUE} ]]; then
                            goto__func CHECKOUT_BRANCH    #goto next-phase
                        else
                            goto__func CREATE_AND_CHECKOUT_BRANCH    #goto next-phase
                        fi
                        ;;
                esac

                break
            else
                case "${answer}" in
                    ${DOCKER__ENTER})
                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                        ;;
                    *)
                        moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"
                        ;;
                esac
            fi
        fi
    done



@CHECKOUT_BRANCH:
    #Update message
    printf_subjectMsg="---:${DOCKER__START}: ${PRINTF_CHECKOUT_OF_EXISTING_BRANCH}"
    #Show message
    show_msg_only__func "${printf_subjectMsg}" "${DOCKER__NUMOFLINES_2}" "${DOCKER__NUMOFLINES_0}"

    #Update cmd
    git_cmd="${GIT__CMD_GIT_CHECKOUT} ${docker__branch_chosen}"
    #Execute cmd
    eval ${git_cmd}

    #Check exit-code
    exitCode=$?
    if [[ ${exitCode} -eq 0 ]]; then
        #Update message
        printf_msg="------:${DOCKER__EXECUTED}: ${git_cmd} (${DOCKER__STATUS_LDONE})"
    else
        #Update message
        printf_msg="------:${DOCKER__EXECUTED}: ${git_cmd} (${DOCKER__STATUS_LFAILED})"
    fi

    #Show message
    show_msg_only__func "${printf_msg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

    #Update message
    printf_subjectMsg="---:${DOCKER__COMPLETED}: ${PRINTF_CHECKOUT_OF_EXISTING_BRANCH}"
    #Show message
    show_msg_only__func "${printf_subjectMsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_1}"
    
    #Goto next-phase
    goto__func EXIT_SUCCESSFUL



@CREATE_AND_CHECKOUT_BRANCH:
    #Update message
    printf_subjectMsg="---:${DOCKER__START}: ${PRINTF_CHECKOUT_OF_NEW_BRANCH}"
    #Show message
    show_msg_only__func "${printf_subjectMsg}" "${DOCKER__NUMOFLINES_2}" "${DOCKER__NUMOFLINES_0}"

    #Update cmd
    git_cmd="${GIT__CMD_GIT_CHECKOUT} -b ${docker__branch_chosen}"
    #Execute cmd
    eval ${git_cmd}

    #Check exit-code
    exitCode=$?
    if [[ ${exitCode} -eq 0 ]]; then
        #Update message
        printf_msg="------:${DOCKER__EXECUTED}: ${git_cmd} (${DOCKER__STATUS_LDONE})"
    else
        #Update message
        printf_msg="------:${DOCKER__EXECUTED}: ${git_cmd} (${DOCKER__STATUS_LFAILED})"
    fi

    #Show message
    show_msg_only__func "${printf_msg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

    #Update message
    printf_subjectMsg="---:${DOCKER__COMPLETED}: ${PRINTF_CHECKOUT_OF_NEW_BRANCH}"
    #Show message
    show_msg_only__func "${printf_subjectMsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_1}"
    
    #Goto next-phase
    goto__func EXIT_SUCCESSFUL



@EXIT_PRECHECK_FAILED:
    #Update message
    printf_msg="${DOCKER__ERROR}: ${docker__stdErr}"
    #Show message
    show_msg_only__func "${printf_msg}" "${DOCKER__NUMOFLINES_2}" "${DOCKER__NUMOFLINES_0}"
    
    #Exit
    exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_2}"



@EXIT_SUCCESSFUL:
    exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_2}"

}

docker__show_and_input_git_branch__sub() {
    #Show file-content
    ${git__git_readInput_w_autocomplete__fpath} "${DOCKER__MENUTITLE}" \
            "${DOCKER__FOURSPACES_QUIT_CTRL_C}" \
            "${DOCKER__READDIALOG}" \
            "${DOCKER__ECHOMSG_NORESULTS_FOUND}" \
            "${GIT__CMD_GIT_BRANCH}" \
            "${docker__showTable}" \
            "${docker__onEnter_breakLoop}" \
            "${docker__tibboHeader_prepend_numOfLines}"

    #Get the exit-code just in case:
    #   1. Ctrl-C was pressed in script 'git__git_readInput_w_autocomplete__fpath'.
    #   2. An error occured in script 'git__git_readInput_w_autocomplete__fpath',...
    #      ...and exit-code = 99 came from function...
    #      ...'show_msg_w_menuTitle_w_pressAnyKey_w_ctrlC_func' (in script: docker__global.sh).
    docker__exitCode=$?
    if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
        exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
    else
        #Get the result
        docker__branch_chosen=`get_output_from_file__func \
                        "${git__git_readInput_w_autocomplete_out__fpath}" \
                        "${DOCKER__LINENUM_1}"`
    fi

    #Set 'docker__tibboHeader_prepend_numOfLines' to '0'
    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_0}
}



#---MAIN SUBROUTINE
main_sub() {
    docker__get_source_fullpath__sub

    docker__load_global_fpath_paths__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__create_checkout_local_branch_handler__sub
}



#---EXECUTE
main_sub
