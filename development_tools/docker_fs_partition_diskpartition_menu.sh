#!/bin/bash -m
#Remark: by using '-m' the INTERRUPT executed here will NOT propagate to the UPPERLAYER scripts
#---INPUT ARGS
disksize__input=${1}
global_fpath__input=${2}



#---SUBROUTINES
#Check if 'docker_global.sh' is already loaded.
#Note: this can be simply done by trying to read the constant 'DOCKER__THISFILE_ISREACHABLE'
docker__check_inputarg__sub() {
    if [[ -z "${global_fpath__input}" ]]; then
        docker__tmp_dir=/tmp
        docker__development_tools__foldername="development_tools"
        docker__global__filename="docker_global.sh"
        docker__mainmenu_path_cache__filename="docker__mainmenu_path.cache"
        docker__mainmenu_path_cache__fpath="${docker__tmp_dir}/${docker__mainmenu_path_cache__filename}"

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
    DOCKER__MENUTITLE="${DOCKER__FG_LIGHTBLUE}DOCKER:${DOCKER__NOCOLOR}"
    DOCKER__SUBMENUTITLE_CHOOSE_DISKSIZE="${DOCKER__MENUTITLE}: ${DOCKER__FG_DARKBLUE}CONFIGURE "
    DOCKER__SUBMENUTITLE_CHOOSE_DISKSIZE+="${DOCKER__FG_RED9}DISK${DOCKER__NOCOLOR}-${DOCKER__FG_RED9}PARTITION${DOCKER__NOCOLOR}"
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
    local partitiondisk="${DOCKER__EMPTYSTRING}"
    local partitiondisk_status=false
    local overlaymode="${DOCKER__EMPTYSTRING}"
    local overlaymode_status=false
    local applychange_status="${DOCKER__EMPTYSTRING}"
    local mychoice="${DOCKER__EMPTYSTRING}"
    local regex="[1-3q]"
    local exitcode=0
    local ret=0

    #Write initial 'ret' value to file.
    #Note: this is done in case ctrl+c is pressed.
    write_data_to_file__func "${ret}" "${docker__fs_partition_disksize_menu_output__fpath}"

    #Show menu
    while true
    do
        #IMPORTANT: reset exitcode
        exitcode=0

        #Get Git-information
        #Output:
        #   docker_git_current_info_msg
        docker__get_git_info__sub

        #Load header
        load_tibbo_title__func "${DOCKER__NUMOFLINES_2}"

        #Print horizontal line
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Print menut-title
        show_leadingAndTrailingStrings_separatedBySpaces__func "${DOCKER__SUBMENUTITLE_CHOOSE_DISKSIZE}" "${docker_git_current_info_msg}" "${DOCKER__TABLEWIDTH}"

        #Print horizontal line
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}1. Partition disk"
        #overlay-modes:
        #   default (do NOT change the pentagram_common.h)
        #   rw (insert string 'tb_overlay' in pentagram_common.h)
        #   ro (insert string 'tb_rootfs_ro' in pentagram_common.h)
        echo -e "${DOCKER__FOURSPACES}2. Set overlay-mode"
        echo -e "${DOCKER__FOURSPACES}3. Apply change" 
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}q. $DOCKER__QUIT_CTRL_C"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        while true
        do
            #Select an option
            read -N1 -r -p "Please choose an option: " mychoice
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            #Only continue if a valid option is selected
            if [[ ! -z ${mychoice} ]]; then
                if [[ ${mychoice} =~ ${regex} ]]; then
                    break
                else
                    if [[ ${mychoice} == ${DOCKER__ENTER} ]]; then
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
        case ${mychoice} in
            1)
                ret=${DOCKER__DISKSIZE_4G_IN_MBYTES}
                ;;
            2)
                ret=${DOCKER__DISKSIZE_8G_IN_MBYTES}
                ;;
            3)
                ${docker__fs_partition_disksize_userdefined__fpath}
                exitcode=$?
        
                #Read from file
                if [[ ${exitcode} -eq 0 ]]; then
                    ret=$(read_1stline_from_file "${docker__fs_partition_disksize_userdefined_output__fpath}")
                fi

                remove_file__func "${docker__fs_partition_disksize_userdefined_output__fpath}"
                ;;
            4)
                ret=${DOCKER__0K_IN_BYTES}
                ;;
            q)
                exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_1}"
                ;;
        esac

        if [[ ${exitcode} -eq 0 ]]; then
            break
        fi
    done

    #Write to file
    write_data_to_file__func "${ret}" "${docker__fs_partition_disksize_menu_output__fpath}"
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
