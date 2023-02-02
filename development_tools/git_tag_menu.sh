#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts

#---SUBROUTINES
docker__load_environment_variables__sub() {
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
    source ${docker__global__fpath} "${docker__parentDir_of_LTPP3_ROOTFS__dir}" \
                        "${docker__LTPP3_ROOTFS__dir}" \
                        "${docker__LTPP3_ROOTFS_development_tools__dir}"
}

docker__load_constants__sub() {
    DOCKER__MENUTITLE="${DOCKER__FG_LIGHTBLUE}GIT: CREATE/RENAME/REMOVE TAG${DOCKER__NOCOLOR}"
}

docker__init_variables__sub() {
    docker__myChoice=${DOCKER__EMPTYSTRING}
    
    docker__tibboHeader_prepend_numOfLines=0

    docker__regEx="[1-4q]"

    docker__exitCode=0
}

docker__menu__sub() {
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

        #Print horizontal line
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Print menut-title
        show_leadingAndTrailingStrings_separatedBySpaces__func "${DOCKER__MENUTITLE}" \
                        "${docker_git_current_info_msg}" \
                        "${DOCKER__TABLEWIDTH}"

        #Print horizontal line
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Print menu-options
        echo -e "${DOCKER__FOURSPACES}1. Create & push tag"
        echo -e "${DOCKER__FOURSPACES}2. Rename tag"
        echo -e "${DOCKER__FOURSPACES}3. Remove ${DOCKER__FG_BROWN94}local${DOCKER__NOCOLOR} tag"
        echo -e "${DOCKER__FOURSPACES}4. Remove ${DOCKER__FG_BROWN137}remote${DOCKER__NOCOLOR} tag"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}q. $DOCKER__QUIT_CTRL_C"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        #Show read-dialog
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
                ${git__git_tag_create_and_push__fpath}

                docker__restore_branch_checkedOut__sub
                ;;
            2)
                ${git__git_tag_rename__fpath}
                ;;
            3)
                ${git__git_tag_remove__fpath} "${GIT__LOCATION_LOCAL}"
                ;;
            4)
                ${git__git_tag_remove__fpath} "${GIT__LOCATION_REMOTE}"
                ;;
            q)
                exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_1}"
                ;;
        esac
    done
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

docker__restore_branch_checkedOut__sub() {
    #Define constants
    local PRINTF_RESTORE_CHECKOUT_BRANCH="restore checked-out branch"

    #Define variables
    local git_cmd=${DOCKER__EMPTYSTRING}
    local printf_msg=${DOCKER__EMPTYSTRING}
    local printf_subjectMsg=${DOCKER__EMPTYSTRING}

    #Get currently checked out branch
    local current_branch_checkedOut=`git__get_current_branchName__func`

    #Check if 'current_branch_checkedOut' is the same as 'docker__git_current_branchName'
    if [[ ${current_branch_checkedOut} != ${docker__git_current_branchName} ]]; then  #not the same
        #Update message
        printf_subjectMsg="---:${DOCKER__START}: ${PRINTF_RESTORE_CHECKOUT_BRANCH}"
        #Show message
        show_msg_only__func "${printf_subjectMsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        #Update cmd
        git_cmd="${GIT__CMD_GIT_CHECKOUT} ${docker__git_current_branchName}"
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
        printf_subjectMsg="---:${DOCKER__COMPLETED}: ${PRINTF_RESTORE_CHECKOUT_BRANCH}"
        #Show message
        show_msg_only__func "${printf_subjectMsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_1}"
    fi
}



#---MAIN SUBROUTINE
main__sub() {
    docker__load_environment_variables__sub

    docker__load_source_files__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__menu__sub
}



#---EXECUTE
main__sub