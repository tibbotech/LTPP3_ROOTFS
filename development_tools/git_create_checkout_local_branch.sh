#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts

#---SUBROUTINES
docker__get_source_fullpath__sub() {
    #Define variables
    local docker__tmp_dir="${EMPTYSTRING}"

    local docker__development_tools__foldername="${EMPTYSTRING}"
    local docker__LTPP3_ROOTFS__foldername="${EMPTYSTRING}"
    local docker__global__filename="${EMPTYSTRING}"
    local docker__parentDir_of_LTPP3_ROOTFS__dir="${EMPTYSTRING}"

    local docker__mainmenu_path_cache__filename="${EMPTYSTRING}"
    local docker__mainmenu_path_cache__fpath="${EMPTYSTRING}"

    local docker__find_dir_result_arr=()
    local docker__find_dir_result_arritem="${EMPTYSTRING}"
    local docker__find_dir_result_arrlen=0
    local docker__find_dir_result_arrlinectr=0
    local docker__find_dir_result_arrprogressperc=0

    local docker__find_path_of_development_tools="${EMPTYSTRING}"

    #Set variables
    docker__tmp_dir=/tmp
    docker__development_tools__foldername="development_tools"
    docker__global__filename="docker_global.sh"
    docker__LTPP3_ROOTFS__foldername="LTPP3_ROOTFS"

    docker__mainmenu_path_cache__filename="docker__mainmenu_path.cache"
    docker__mainmenu_path_cache__fpath="${docker__tmp_dir}/${docker__mainmenu_path_cache__filename}"

    #Check if file exists
    if [[ -f "${docker__mainmenu_path_cache__fpath}" ]]; then
        #Get the line of file
        docker__LTPP3_ROOTFS_development_tools__dir=$(awk 'NR==1' "${docker__mainmenu_path_cache__fpath}")
    else
        #Start loop
        while true
        do
            #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
            #... and read to array 'find_result_arr'
            readarray -t docker__find_dir_result_arr < <(find  / -type d -iname "${docker__LTPP3_ROOTFS__foldername}" 2> /dev/null)

            #Iterate thru each array-item
            for docker__find_dir_result_arritem in "${docker__find_dir_result_arr[@]}"
            do
                #Update variable 'docker__find_path_of_development_tools'
                docker__find_path_of_development_tools="${docker__find_dir_result_arritem}/${docker__development_tools__foldername}"

                #Check if 'directory' exist
                if [[ -d "${docker__find_path_of_development_tools}" ]]; then    #directory exists
                    #Update variable
                    #Remark:
                    #   'docker__LTPP3_ROOTFS_development_tools__dir' is a global variable.
                    #   This variable will be passed 'globally' to script 'docker_global.sh'.
                    docker__LTPP3_ROOTFS_development_tools__dir="${docker__find_path_of_development_tools}"

                    break
                fi
            done

            #Check if 'docker__LTPP3_ROOTFS_development_tools__dir' contains any data
            if [[ -z "${docker__LTPP3_ROOTFS_development_tools__dir}" ]]; then  #contains no data
                echo -e "\r"

                echo -e "***\e[1;31mERROR\e[0;0m: folder \e[30;38;5;246m${docker__development_tools__foldername}\e[0;0m: \e[30;38;5;131mNot Found\e[0;0m"

                echo -e "\r"

                exit 99
            else    #contains data
                break
            fi
        done

        #Write to file
        echo "${docker__LTPP3_ROOTFS_development_tools__dir}" | tee "${docker__mainmenu_path_cache__fpath}" >/dev/null
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

docker__load_source_files__sub() {
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
        printf_msg="------:${DOCKER__EXECUTED}: ${git_cmd} (${DOCKER__STATUS_DONE})"
    else
        #Update message
        printf_msg="------:${DOCKER__EXECUTED}: ${git_cmd} (${DOCKER__STATUS_FAILED})"
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
        printf_msg="------:${DOCKER__EXECUTED}: ${git_cmd} (${DOCKER__STATUS_DONE})"
    else
        #Update message
        printf_msg="------:${DOCKER__EXECUTED}: ${git_cmd} (${DOCKER__STATUS_FAILED})"
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

    docker__load_source_files__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__create_checkout_local_branch_handler__sub
}



#---EXECUTE
main_sub
