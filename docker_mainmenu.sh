#!/bin/bash
#--------------------------------------------------------------------
#REMARK:
#   The command 'source' requires '#!/bin/bash' to be defined.
#--------------------------------------------------------------------
docker__get_source_fullpath__sub() {
    #Define variables
    local docker__current_dir="${EMPTYSTRING}"
    local docker__home_dir=~

    local docker__development_tools__foldername="${EMPTYSTRING}"
    local docker__LTPP3_ROOTFS__foldername="${EMPTYSTRING}"
    local docker__global__filename="${EMPTYSTRING}"
    local docker__parentDir_of_LTPP3_ROOTFS__dir="${EMPTYSTRING}"

    local docker__find_dir_result_arr=()
    local docker__find_dir_result_arritem="${EMPTYSTRING}"
    local docker__find_path_of_LTPP3_ROOTFS="${EMPTYSTRING}"

    local docker__repo_of_LTPP3_ROOTFS="${EMPTYSTRING}"



    #Set variables
    current_dir=$(pwd)
    docker__development_tools__foldername="development_tools"
    docker__global__filename="docker_global.sh"
    docker__LTPP3_ROOTFS__foldername="LTPP3_ROOTFS"
    docker__repo_of_LTPP3_ROOTFS="git@github.com:tibbotech/${docker__LTPP3_ROOTFS__foldername}.git"



    #Start loop
    while true
    do
        #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
        #... and read to array 'find_result_arr'
        readarray -t docker__find_dir_result_arr < <(find  / -type d -iname "${docker__LTPP3_ROOTFS__foldername}" 2> /dev/null)

        for docker__find_dir_result_arritem in "${docker__find_dir_result_arr[@]}"
        do
            #Update variable 'docker__find_path_of_LTPP3_ROOTFS'
            docker__find_path_of_LTPP3_ROOTFS="${docker__find_dir_result_arritem}/${docker__development_tools__foldername}"
            #Check if 'directory' exist
            if [[ -d "${docker__find_path_of_LTPP3_ROOTFS}" ]]; then    #directory exists
                #Update variable
                #Remark:
                #   'docker__LTPP3_ROOTFS_development_tools__dir' is a global variable.
                #   This variable will be passed 'globally' to script 'docker_global.sh'.
                docker__LTPP3_ROOTFS_development_tools__dir="${docker__find_path_of_LTPP3_ROOTFS}"

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



    #***IMPORTANT: EXPORT PATHS
    export docker__LTPP3_ROOTFS__dir
    export docker__parentDir_of_LTPP3_ROOTFS__dir
    export docker__LTPP3_ROOTFS_development_tools__dir
    export docker__global__fpath
}

docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

docker__load_constants__sub() {
    DOCKER__MENUTITLE="${DOCKER__FG_LIGHTBLUE}DOCKER MAIN-MENU${DOCKER__NOCOLOR}"
}

docker__checkIf_user_is_root__sub()
{
    #Define local variable
    currUser=$(whoami)

    #Exec command
    if [[ ${currUser} != "root" ]]; then
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: current user is not ${DOCKER__FG_LIGHTGREY}root${DOCKER__NOCOLOR}"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        exit 99
    fi
}

docker__init_variables__sub() {
    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

    docker__regEx="[1-3890rcseipgq]"
    docker__myChoice=""

    docker__git_current_branchName=${DOCKER__EMPTYSTRING}
    docker__git_current_abbrevCommitHash=${DOCKER__EMPTYSTRING}
	docker__git_current_unpushed_abbrevCommitHash=${DOCKER__EMPTYSTRING}
	docker__git_current_push_status=${DOCKER__EMPTYSTRING}
    docker__git_current_tag=${DOCKER__EMPTYSTRING}
}

docker__enable_objects__sub() {
    cursor_show__func
    enable_expansion__func
    enable_keyboard_input__func
    enable_ctrl_c__func
    enable_stty_intr__func
}

docker__mainmenu__sub() {
    #Initialization
    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

    while true
    do
        #Get Git-information
        #Output:
        #   docker_git_current_info_msg
        docker__get_git_info__sub

        #Print Tibbo-title
        load_tibbo_title__func "${docker__tibboHeader_prepend_numOfLines}"

        #Set 'docker__tibboHeader_prepend_numOfLines'
        docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_1}

        #Print horizontal line
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Print menut-title
        show_leadingAndTrailingStrings_separatedBySpaces__func "${DOCKER__MENUTITLE}" "${docker_git_current_info_msg}" "${DOCKER__TABLEWIDTH}"

        #Print horizontal line
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Print menu-options
        echo -e "${DOCKER__FOURSPACES}1. ${DOCKER__MENU} create ${DOCKER__FG_BORDEAUX}image${DOCKER__NOCOLOR}(s) using docker-file/list"
        echo -e "${DOCKER__FOURSPACES}2. ${DOCKER__MENU} create${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}remove${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}rename ${DOCKER__FG_BORDEAUX}image${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}3. ${DOCKER__MENU} run${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}remove ${DOCKER__FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}8. Copy file from${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}to ${DOCKER__FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}9. Chroot from inside${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}outside ${DOCKER__FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}" 
        echo -e "${DOCKER__FOURSPACES}0. Enter Command Prompt"

        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}r. ${DOCKER__FG_PURPLE}Repository${DOCKER__NOCOLOR}-list"
        echo -e "${DOCKER__FOURSPACES}c. ${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}-list"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}s. ${DOCKER__FG_YELLOW}SSH${DOCKER__NOCOLOR} to ${DOCKER__FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}i. Load from ${DOCKER__FG_BORDEAUX}image${DOCKER__NOCOLOR} file"
        echo -e "${DOCKER__FOURSPACES}e. Save to ${DOCKER__FG_BORDEAUX}image${DOCKER__NOCOLOR} file"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}g. ${DOCKER__MENU} Git"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}q. ${DOCKER__QUIT_CTRL_C}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        while true
        do
            #Select an option
            read -N1 -r -p "Please choose an option: " docker__myChoice
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            #Only continue if a valid option is selected
            if [[ ! -z ${docker__myChoice} ]]; then
                if [[ ${docker__myChoice} =~ ${docker__regEx} ]]; then
                    # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

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
                ${docker_create_images_from_dockerfile_dockerlist_menu__fpath}
                ;;

            2)
                ${docker_image_create_remove_rename_menu__fpath}
                ;;

            3)
                ${docker__container_run_remove_menu__fpath}
                ;;

            8)
                ${docker__cp_fromto_container__fpath}
                ;;

            9)
                ${docker__run_chroot__fpath}
                ;;

            0)
                ${docker__enter_cmdline_mode__fpath} "${DOCKER__EMPTYSTRING}" "${DOCKER__EMPTYSTRING}" "${DOCKER__EMPTYSTRING}"
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

            i)
                ${docker__load__fpath}
                ;;

            e)
                ${docker__save__fpath}
                ;;

            g)  
                ${docker__git_menu__fpath}
                ;;

            q)
                exit
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

    docker__checkIf_user_is_root__sub

    docker__init_variables__sub

    docker__enable_objects__sub

    docker__mainmenu__sub
}

#Execute main subroutine
main__sub
