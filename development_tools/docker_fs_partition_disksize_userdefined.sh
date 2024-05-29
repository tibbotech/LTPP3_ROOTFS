#!/bin/bash -m
#Remark: by using '-m' the INTERRUPT executed here will NOT propagate to the UPPERLAYER scripts
#---INPUT ARGS
global_fpath__input=${1}



#---SUBROUTINES
#Check if 'docker_global.sh' is already loaded.
#Note: this can be simply done by trying to read the constant 'DOCKER__THISFILE_ISREACHABLE'
docker__check_inputarg__sub() {
    if [[ -z "${global_fpath__input}" ]]; then
        docker__tmp__dir=/tmp
        docker__development_tools__foldername="development_tools"
        docker__global__filename="docker_global.sh"
        docker__mainmenu_path_cache__filename="docker__mainmenu_path.cache"
        docker__mainmenu_path_cache__fpath="${docker__tmp__dir}/${docker__mainmenu_path_cache__filename}"

        if [[ ! -f "${docker__mainmenu_path_cache__fpath}" ]]; then
            echo -e "\r"
            echo -e "***\e[1;31mERROR\e[0;0m: \e[30;38;5;246mInput argument\e[0;0m: \e[30;38;5;131mNOT provided\e[0;0m"
            echo -e "\r"

            exit 99
        else
            #Get the directory stored in cache-file
            docker__LTPP3_ROOTFS_development_tools__dir=$(awk 'NR==1' "${docker__mainmenu_path_cache__fpath}")

            #Get fullpath of 'docker_global.sh'
            global_fpath__input="${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__global__filename}"
        fi
    fi
}

docker__load_global_fpath_paths__sub() {
    source ${global_fpath__input}
}

docker__load_constants__sub() {
    DOCKER__MENUTITLE="${DOCKER__FG_LIGHTBLUE}DOCKER: "
    DOCKER__MENUTITLE+="${DOCKER__FG_DARKBLUE}CHOOSE "
    DOCKER__MENUTITLE+="${DOCKER__FG_RED125}DISK${DOCKER__NOCOLOR}-${DOCKER__FG_RED125}SIZE${DOCKER__NOCOLOR}: "
    DOCKER__MENUTITLE+="USER-DEFINED (${DOCKER__FG_DARKBLUE}MB${DOCKER__NOCOLOR})"

    DOCKER__READINPUT_DIALOG="disk-size (${DOCKER__FG_YELLOW}>=${DOCKER__FG_LIGHTGREY}${DOCKER_DISKSIZE_MIN}${DOCKER__NOCOLOR}, "
    DOCKER__READINPUT_DIALOG+="${DOCKER__FG_LIGHTGREY}${DOCKER__CTRL_C_COLON_QUIT}${DOCKER__NOCOLOR}): "
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

docker__menu__sub() {
    #Define variables
    local mydisksize="${DOCKER__EMPTYSTRING}"
    local regex="[1-90]"

    #Write initial 'ret' value to file.
    #Note: this is done in case ctrl+c is pressed.
    write_data_to_file__func "${mydisksize}" "${docker__fs_partition_disksize_userdefined_output__fpath}"

    #Get Git-information
    #Output:
    #   docker_git_current_info_msg
    docker__get_git_info__sub

    #Show menu
    #Load header
    load_tibbo_title__func "${DOCKER__NUMOFLINES_2}"

    #Print horizontal line
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Print menut-title
    show_leadingAndTrailingStrings_separatedBySpaces__func "${DOCKER__MENUTITLE}" "${docker_git_current_info_msg}" "${DOCKER__TABLEWIDTH}"

    #Print horizontal line
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Show read-dialog
    while true
    do
        #Select an option
        read -e -p "${DOCKER__READINPUT_DIALOG}" -i ${DOCKER_DISKSIZE_MIN} mydisksize
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        #Only continue if a valid option is selected
        if [[ ! -z ${mydisksize} ]]; then
            if [[ $(isNumeric__func "${mydisksize}") == true ]]; then
                if [[ ${mydisksize} -ge ${DOCKER_DISKSIZE_MIN} ]]; then
                    break
                else
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

                    echo -e "${DOCKER__READINPUT_DIALOG}${mydisksize} (${DOCKER__STATUS_LINVALID})"
                fi
            else
                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
            fi
        else
            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
        fi
    done

    #Write to file
    write_data_to_file__func "${mydisksize}" "${docker__fs_partition_disksize_userdefined_output__fpath}"
}



#---MAIN SUBROUTINE
main__sub() {
    docker__check_inputarg__sub

    docker__load_global_fpath_paths__sub

    docker__load_constants__sub

    docker__menu__sub
}



#---EXECUTE
main__sub
