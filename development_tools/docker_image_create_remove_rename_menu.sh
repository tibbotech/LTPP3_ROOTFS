#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts

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
    source ${docker__global__fpath} "${docker__parentDir_of_LTPP3_ROOTFS__dir}" \
                        "${docker__LTPP3_ROOTFS__dir}" \
                        "${docker__LTPP3_ROOTFS_development_tools__dir}"
}

docker__load_constants__sub() {
    DOCKER__MENUTITLE="${DOCKER__FG_LIGHTBLUE}DOCKER: "
    DOCKER__MENUTITLE+="${DOCKER__FG_DARKBLUE}CREATE${DOCKER__NOCOLOR}/"
    DOCKER__MENUTITLE+="${DOCKER__FG_DARKBLUE}REMOVE${DOCKER__NOCOLOR}/"
    DOCKER__MENUTITLE+="${DOCKER__FG_DARKBLUE}RENAME ${DOCKER__FG_LIGHTBLUE}IMAGE${DOCKER__NOCOLOR}"
    
}

docker__init_variables__sub() {
    docker__myChoice=${DOCKER__EMPTYSTRING}
    docker__regEx="[1-4rcsiegq]"
    docker__tibboHeader_prepend_numOfLines=0
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

        #Print menu-title
        show_leadingAndTrailingStrings_separatedBySpaces__func "${DOCKER__MENUTITLE}" "${docker_git_current_info_msg}" "${DOCKER__TABLEWIDTH}"
        #Print horizontal line
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Print menu-options
        echo -e "${DOCKER__FOURSPACES}1. Create image from ${DOCKER__FG_PURPLE}Repository${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}2. Create image from ${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}3. Remove image"
        echo -e "${DOCKER__FOURSPACES}4. Rename image ${DOCKER__FG_PURPLE}Repository${DOCKER__NOCOLOR}:${DOCKER__FG_PINK}Tag${DOCKER__NOCOLOR}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}r. ${DOCKER__FG_PURPLE}Repository${DOCKER__NOCOLOR}-list"
        echo -e "${DOCKER__FOURSPACES}c. ${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}-list"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}s. ${DOCKER__FG_YELLOW}SSH${DOCKER__NOCOLOR} to a ${DOCKER__FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}i. Load from File"
        echo -e "${DOCKER__FOURSPACES}e. Save to File"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}g. ${DOCKER__FG_LIGHTGREY}Git${DOCKER__NOCOLOR} Menu"
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
                ${docker__create_image_from_existing_repository__fpath}
                ;;
            2)
                ${docker__create_image_from_container__fpath}
                ;;
            3)
                ${docker__remove_image__fpath}
                ;;
            4)
                ${docker_rename_repotag__fpath}
                ;;
            c)
                docker__show_containerList_handler__sub
                ;;
            r)
                docker__show_repositoryList_handler__sub
                ;;
            s)
                ${docker__ssh_to_host__fpath}
                ;;
            e)
                ${docker__save__fpath}
                ;;
            i)
                ${docker__load__fpath}
                ;;
            g)  
                ${docker__git_menu__fpath}
                ;;
            q)
                exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_1}"
                ;;
        esac
    done
}

docker__show_repositoryList_handler__sub() {
    #Show repo-list
    show_repoList_or_containerList_w_menuTitle_w_confirmation__func "${DOCKER__MENUTITLE_REPOSITORYLIST}" \
                        "${DOCKER__ERRMSG_NO_IMAGES_FOUND}" \
                        "${docker__images_cmd}" \
                        "${DOCKER__NUMOFLINES_0}" \
                        "${DOCKER__TIMEOUT_10}" \
                        "${DOCKER__NUMOFLINES_0}" \
                        "${DOCKER__NUMOFLINES_0}" \
                        "${DOCKER__NUMOFLINES_2}"
}

docker__show_containerList_handler__sub() {
    #Show container-list
    show_repoList_or_containerList_w_menuTitle_w_confirmation__func "${DOCKER__MENUTITLE_CONTAINERLIST}" \
                        "${DOCKER__ERRMSG_NO_CONTAINERS_FOUND}" \
                        "${docker__ps_a_cmd}" \
                        "${DOCKER__NUMOFLINES_0}" \
                        "${DOCKER__TIMEOUT_10}" \
                        "${DOCKER__NUMOFLINES_0}" \
                        "${DOCKER__NUMOFLINES_0}" \
                        "${DOCKER__NUMOFLINES_2}"
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

    docker__load_source_files__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__menu__sub
}



#---EXECUTE
main__sub