#!/bin/bash -m
#Remark: by using '-m' the INTERRUPT executed here will NOT propagate to the UPPERLAYER scripts
#---INPUT ARGS
global_fpath__input=${1}

if [[ -z "${global_fpath__input}" ]]; then
    echo -e "\r"
    echo -e "***\e[1;31mERROR\e[0;0m: \e[30;38;5;246mInput argument\e[0;0m: \e[30;38;5;131mNOT provided\e[0;0m"
    echo -e "\r"

    exit 99
fi



#---SUBROUTINES
docker__load_source_files__sub() {
    source ${global_fpath__input}
}

docker__load_constants__sub() {
    DOCKER__MENUTITLE="${DOCKER__FG_LIGHTBLUE}DOCKER: "
    DOCKER__MENUTITLE+="${DOCKER__FG_DARKBLUE}CONFIGURE${DOCKER__NOCOLOR} ${DOCKER__FG_RED9}OVERLAY${DOCKER__NOCOLOR}"

    DOCKER__SUBMENUTITLE_CHOOSE_DISKSIZE="${DOCKER__MENUTITLE}: CHOOSE ${DOCKER__FG_RED125}DISK${DOCKER__NOCOLOR}-SIZE"
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
    local mychoice="${DOCKER__EMPTYSTRING}"
    local regex1234q="[1-4q]"
    local ret=0

    #Write initial 'ret' value to file.
    #Note: this is done in case ctrl+c is pressed.
    write_data_to_file__func "${ret}" "${docker__configure_overlayfs_disksize_menu_output__fpath}"

    #Show menu
    while true
    do
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
        echo -e "${DOCKER__FOURSPACES}1. 4GB (ltpp3-g2-02)"
        echo -e "${DOCKER__FOURSPACES}2. 8GB (ltpp3-g2-03)"
        echo -e "${DOCKER__FOURSPACES}3. user-defined"
        echo -e "${DOCKER__FOURSPACES}4. no overlay"
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
                if [[ ${mychoice} =~ ${regex1234q} ]]; then
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
                echo "$0: docker__configure_overlayfs_disksize_userdefined__fpath: in progress"
                ${docker__configure_overlayfs_disksize_userdefined__fpath}
                ;;
            4)
                ret=${DOCKER__0K_IN_BYTES}
                ;;
            q)
                exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_1}"
                ;;
        esac

        break
    done

    #Write to file
    write_data_to_file__func "${ret}" "${docker__configure_overlayfs_disksize_menu_output__fpath}"
}



#---MAIN SUBROUTINE
main__sub() {
    docker__load_source_files__sub

    docker__load_constants__sub

    docker__menu__sub
}



#---EXECUTE
main__sub
