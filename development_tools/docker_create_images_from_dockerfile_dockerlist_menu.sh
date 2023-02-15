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
    source ${docker__global__fpath} "${docker__parentDir_of_LTPP3_ROOTFS__dir}" \
                        "${docker__LTPP3_ROOTFS__dir}" \
                        "${docker__LTPP3_ROOTFS_development_tools__dir}"
}

docker__load_constants__sub() {
    DOCKER__MENUTITLE="${DOCKER__FG_LIGHTBLUE}DOCKER: "
    DOCKER__MENUTITLE+="${DOCKER__FG_DARKBLUE}CREATE IMAGE${DOCKER__NOCOLOR}"
    DOCKER__MENUTITLE+="(${DOCKER__FG_DARKBLUE}S${DOCKER__NOCOLOR}) "
    DOCKER__MENUTITLE+="${DOCKER__FG_DARKBLUE}USING DOCKER-FILE${DOCKER__NOCOLOR}/"
    DOCKER__MENUTITLE+="${DOCKER__FG_DARKBLUE}LIST${DOCKER__NOCOLOR}"
}

docker__init_variables__sub() {
    docker__myChoice=${DOCKER__EMPTYSTRING}

    docker__tibboHeader_prepend_numOfLines=0
}

docker__run_mandatory_commands__sub() {
    git config --global --add safe.directory ${docker__LTPP3_ROOTFS__dir}
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

        ##Print horizontal line
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Print menut-title
        show_leadingAndTrailingStrings_separatedBySpaces__func "${DOCKER__MENUTITLE}" "${docker_git_current_info_msg}" "${DOCKER__TABLEWIDTH}"

        #Print horizontal line
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Print menu-options
        echo -e "${DOCKER__FOURSPACES}1. Create image using ${DOCKER__FG_DARKBLUE}docker-file${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}2. Create image(s) using ${DOCKER__FG_LIGHTBLUE}docker-list${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}3. ${DOCKER__MENU} Export environment variables"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}r. ${DOCKER__FG_PURPLE}Repository${DOCKER__NOCOLOR}-list"
        echo -e "${DOCKER__FOURSPACES}c. ${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}-list"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}s. ${DOCKER__FG_YELLOW}SSH${DOCKER__NOCOLOR} to ${DOCKER__FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}"
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
                if [[ ${docker__myChoice} =~ [1-3rcsiegq] ]]; then
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
                ${docker__create_an_image_from_dockerfile__fpath}
                ;;

            2)
                ${docker__create_images_from_dockerlist__fpath}
                ;;

            3)
                ${docker__export_env_var_menu__fpath}
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

    docker__run_mandatory_commands__sub

    docker__menu__sub
}



#---EXECUTE
main__sub