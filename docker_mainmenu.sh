#---CONSTANTS
DOCKER__MENUTITLE="${DOCKER__FG_LIGHTBLUE}DOCKER MAIN-MENU${DOCKER__NOCOLOR}"
DOCKER__CREATEIMAGE_SUBMENUTITLE="${DOCKER__FG_LIGHTBLUE}DOCKER SUB-MENU: CREATE IMAGE(S)${DOCKER__NOCOLOR}"
DOCKER__GIT_SUBMENUTITLE="${DOCKER__FG_LIGHTBLUE}DOCKER SUB-MENU: GIT${DOCKER__NOCOLOR}"
DOCKER__VERSION="v21.03.17-0.0.1"

#---SUBROUTINES
docker__load_environment_variables__sub() {
    # #---Defin FOLDER
    # docker__LTPP3_ROOTFS__foldername="LTPP3_ROOTFS"
    docker__development_tools__foldername="development_tools"

    # #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
    # #... and read to array 'find_result_arr'
    # #Remark:
    # #   By using '2> /dev/null', the errors are not shown.
    # readarray -t find_dir_result_arr < <(find  / -type d -iname "${docker__LTPP3_ROOTFS__foldername}" 2> /dev/null)

    # #Define variable
    # local find_path_of_LTPP3_ROOTFS=${DOCKER__EMPTYSTRING}

    # #Loop thru array-elements
    # for find_dir_result_arrItem in "${find_dir_result_arr[@]}"
    # do
    #     #Update variable 'find_path_of_LTPP3_ROOTFS'
    #     find_path_of_LTPP3_ROOTFS="${find_dir_result_arrItem}/${docker__development_tools__foldername}"
    #     #Check if 'directory' exist
    #     if [[ -d "${find_path_of_LTPP3_ROOTFS}" ]]; then    #directory exists
    #         #Update variable
    #         docker__LTPP3_ROOTFS_development_tools__dir="${find_path_of_LTPP3_ROOTFS}"

    #         break
    #     fi
    # done

    # docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/
    # docker__parentDir_of_LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS__dir%/*}    #move two directories up. This directory is the one-level higher than LTPP3_ROOTFS/

    docker__LTPP3_ROOTFS__dir=`pwd`
    docker__parentDir_of_LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS__dir%/*}    #move two directories up. This directory is the one-level higher than LTPP3_ROOTFS/
    docker__LTPP3_ROOTFS_development_tools__dir="${docker__LTPP3_ROOTFS__dir}/${docker__development_tools__foldername}"

    docker__global__filename="docker_global.sh"
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

docker__load_header__sub() {
    #Input args
    local prepend_numOfLines__input=${1}

    #Print
    show_header__func "${DOCKER__TITLE}" "${DOCKER__TABLEWIDTH}" "${DOCKER__BG_ORANGE}" "${prepend_numOfLines__input}" "${DOCKER__NUMOFLINES_0}"
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
    docker__myChoice=""
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
        #Print header
        docker__load_header__sub "${docker__tibboHeader_prepend_numOfLines}"
    
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        show_leadingAndTrailingStrings_separatedBySpaces__func "${DOCKER__MENUTITLE}" "${DOCKER__VERSION}" "${DOCKER__TABLEWIDTH}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        echo -e "${DOCKER__FOURSPACES}1. Create ${DOCKER__FG_BORDEAUX}images${DOCKER__NOCOLOR} using a ${DOCKER__FG_DARKBLUE}docker-file${DOCKER__NOCOLOR}/${DOCKER__FG_LIGHTBLUE}docker-list${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}2. Create an ${DOCKER__FG_BORDEAUX}image${DOCKER__NOCOLOR} from a ${DOCKER__FG_PURPLE}repository${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}3. Create an ${DOCKER__FG_BORDEAUX}image${DOCKER__NOCOLOR} from a ${DOCKER__FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}4. Run ${DOCKER__FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR} from a ${DOCKER__FG_PURPLE}repository${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}5. Run an *exited* ${DOCKER__FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}6. Remove ${DOCKER__FG_BORDEAUX}image${DOCKER__NOCOLOR}/${DOCKER__FG_PURPLE}repository${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}7. Remove ${DOCKER__FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}8. Copy a ${DOCKER__FG_ORANGE}file${DOCKER__NOCOLOR} from/to a ${DOCKER__FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}9. ${DOCKER__FG_GREEN}Chroot${DOCKER__NOCOLOR} (from in/outside a container)"
        echo -e "${DOCKER__FOURSPACES}0. Enter Command Prompt"

        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}r. ${DOCKER__FG_PURPLE}Repository${DOCKER__NOCOLOR}-list"
        echo -e "${DOCKER__FOURSPACES}c. ${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}-list"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}s. ${DOCKER__FG_YELLOW}SSH${DOCKER__NOCOLOR} to a ${DOCKER__FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}i. Load an ${DOCKER__FG_BORDEAUX}image${DOCKER__NOCOLOR} file"
        echo -e "${DOCKER__FOURSPACES}e. Save an ${DOCKER__FG_BORDEAUX}image${DOCKER__NOCOLOR} file"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}g. ${DOCKER__FG_LIGHTGREY}Git${DOCKER__NOCOLOR} Menu"
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
                if [[ ${docker__myChoice} =~ [1-90rcseipgq] ]]; then
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
                ${docker__create_images_menu__fpath}
                ;;

            2)
                ${docker__create_image_from_existing_repository__fpath}
                ;;

            3)
                ${docker__create_image_from_container__fpath}
                ;;

            4)
                ${docker__run_container_from_a_repository__fpath}
                ;;

            5)
                ${docker__run_exited_container__fpath}
                ;;

            6)
                ${docker__remove_image__fpath}
                ;;

            7)
                ${docker__remove_container__fpath}
                ;;

            8)
                ${docker__cp_fromto_container__fpath}
                ;;

            9)
                ${docker__run_chroot__fpath}
                ;;

            0)
                ${docker__enter_cmdline_mode__fpath} "${DOCKER__EMPTYSTRING}"
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

        #Set 'docker__tibboHeader_prepend_numOfLines'
        docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_1}
    done
}

docker__show_repositoryList_handler__sub() {
    #Load header
    docker__load_header__sub "${DOCKER__NUMOFLINES_2}"

    #Show repo-list
    show_repository_or_container_list__func "${DOCKER__MENUTITLE_REPOSITORYLIST}" \
                        "${DOCKER__ERRMSG_NO_IMAGES_FOUND}" \
                        "${docker__images_cmd}" \
                        "${DOCKER__NUMOFLINES_0}" \
                        "${DOCKER__TIMEOUT_10}" \
                        "${DOCKER__NUMOFLINES_0}" \
                        "${DOCKER__NUMOFLINES_0}"
}

docker__show_containerList_handler__sub() {
    #Load header
    docker__load_header__sub "${DOCKER__NUMOFLINES_2}"

    #Show container-list
    show_repository_or_container_list__func "${DOCKER__MENUTITLE_CONTAINERLIST}" \
                        "${DOCKER__ERRMSG_NO_CONTAINERS_FOUND}" \
                        "${docker__ps_a_cmd}" \
                        "${DOCKER__NUMOFLINES_0}" \
                        "${DOCKER__TIMEOUT_10}" \
                        "${DOCKER__NUMOFLINES_0}" \
                        "${DOCKER__NUMOFLINES_0}"
}



#---MAIN SUBROUTINE
main__sub() {
    docker__load_environment_variables__sub

    docker__load_source_files__sub

    # docker__load_header__sub

    docker__checkIf_user_is_root__sub

    docker__init_variables__sub

    docker__enable_objects__sub

    docker__mainmenu__sub
}

#Execute main subroutine
main__sub
