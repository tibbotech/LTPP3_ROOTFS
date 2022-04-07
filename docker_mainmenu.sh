#!/bin/bash
#---CONSTANTS
DOCKER__MENUTITLE="${DOCKER__FG_LIGHTBLUE}DOCKER MAIN-MENU${DOCKER__NOCOLOR}"
DOCKER__CREATEIMAGE_SUBMENUTITLE="${DOCKER__FG_LIGHTBLUE}DOCKER SUB-MENU: CREATE IMAGE(S)${DOCKER__NOCOLOR}"
DOCKER__GIT_SUBMENUTITLE="${DOCKER__FG_LIGHTBLUE}DOCKER SUB-MENU: GIT${DOCKER__NOCOLOR}"
DOCKER__VERSION="v21.03.17-0.0.1"



#---SUBROUTINES
docker__load_environment_variables__sub() {
    #---Define PATHS
    docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})  #this is the directory: LTPP3_ROOTFS/
    if [[ ${docker__current_dir} == ${DOCKER__DOT} ]]; then
        docker__current_dir=$(pwd)
    fi

    docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}/development_tools

    docker__containerlist_tableinfo__filename="docker_containerlist_tableinfo.sh"
    docker__containerlist_tableinfo__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__containerlist_tableinfo__filename}
    docker__global_functions__filename="docker_global_functions.sh"
    docker__global_functions__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global_functions__filename}
    docker__repolist_tableinfo__filename="docker_repolist_tableinfo.sh"
    docker__repolist_tableinfo__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__repolist_tableinfo__filename}
    docker__create_an_image_from_dockerfile_filename="docker_create_an_image_from_dockerfile.sh"
    docker__create_an_image_from_dockerfile_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__create_an_image_from_dockerfile_filename}
    docker__create_images_from_dockerlist_filename="docker_create_images_from_dockerlist.sh"
    docker__create_images_from_dockerlist_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__create_images_from_dockerlist_filename}
    docker__create_image_from_existing_repository_filename="docker_create_image_from_existing_repository.sh"
    docker__create_image_from_existing_repository_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__create_image_from_existing_repository_filename}
    docker__create_image_from_container_filename="docker_create_image_from_container.sh"
    docker__create_image_from_container_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__create_image_from_container_filename}
    docker__run_container_from_a_repository_filename="docker_run_container_from_a_repository.sh"
    docker__run_container_from_a_repository_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__run_container_from_a_repository_filename}
    docker__run_exited_container_filename="docker_run_exited_container.sh"
    docker__run_exited_container_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__run_exited_container_filename}
    docker__remove_image_filename="docker_remove_image.sh"
    docker__remove_image_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__remove_image_filename}
    docker__remove_container_filename="docker_remove_container.sh"
    docker__remove_container_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__remove_container_filename}
    docker__cp_fromto_container_filename="docker_cp_fromto_container.sh"
    docker__cp_fromto_container_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__cp_fromto_container_filename}
    docker__create_dockerfile_filename="docker_create_dockerfile_filename.sh"
    docker__create_dockerfile_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__create_dockerfile_filename}
    docker__ssh_to_host_filename="docker_ssh_to_host.sh"
    docker__ssh_to_host_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__ssh_to_host_filename}

    docker__save_filename="docker_save.sh"
    docker__save_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__save_filename}
    docker__load_filename="docker_load.sh"
    docker__load_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__load_filename}

    docker__run_chroot_filename="docker_run_chroot.sh"
    docker__run_chroot_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__run_chroot_filename}

    docker__enter_command_filename="docker_enter_command.sh"
    docker__enter_command_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__enter_command_filename}

    docker__create_images_menu_filename="docker_create_images_menu.sh"
    docker__create_images_menu_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__create_images_menu_filename}

    docker__git_menu_filename="git_menu.sh"
    docker__git_menu_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__git_menu_filename}
}

docker__load_source_files__sub() {
    source ${docker__global_functions__fpath}
}

docker__load_header__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    echo -e "${DOCKER__BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__BG_ORANGE}                                ${DOCKER__NOCOLOR}"
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

docker__checkIf_exported_env_var_isPresent__sub() {
    #Check if 'docker__exported_env_var.txt' is present
    if [[ ! -f ${docker__exported_env_var_fpath} ]]; then
        #Copy from 'docker__exported_env_var_default_fpath' to 'docker__exported_env_var_fpath'
        #Remark:
        #   Both paths are defined in 'docker__global_functions__fpath'
        cp ${docker__exported_env_var_default_fpath} ${docker__exported_env_var_fpath}
    fi
}

docker__mainmenu__sub() {
    while true
    do
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
                ${docker__create_images_menu_fpath}

                ;;

            2)
                ${docker__create_image_from_existing_repository_fpath}
                ;;

            3)
                ${docker__create_image_from_container_fpath}
                ;;

            4)
                ${docker__run_container_from_a_repository_fpath}
                ;;

            5)
                ${docker__run_exited_container_fpath}
                ;;

            6)
                ${docker__remove_image_fpath}
                ;;

            7)
                ${docker__remove_container_fpath}
                ;;

            8)
                ${docker__cp_fromto_container_fpath}
                ;;

            9)
                ${docker__run_chroot_fpath}
                ;;

            0)
                ${docker__enter_command_fpath}
                ;;

            c)
                docker__list_container__sub
                ;;

            r)
                docker__list_repository__sub
                ;;

            s)
                ${docker__ssh_to_host_fpath}
                ;;

            i)
                ${docker__load_fpath}
                ;;

            e)
                ${docker__save_fpath}
                ;;

            g)  
                ${docker__git_menu_fpath}
                ;;

            q)
                exit
                ;;
        esac
    done
}


docker__list_repository__sub() {
    #Load header
    docker__load_header__sub

    #Define local constants
    local MENUTITLE_REPOSITORYLIST="${DOCKER__FG_PURPLE}Repository${DOCKER__NOCOLOR}-list"

    local ERRMSG_NO_IMAGES_FOUND="=:${DOCKER__FG_LIGHTRED}NO IMAGES FOUND${DOCKER__NOCOLOR}:="

    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        show_centered_string__func "${MENUTITLE_REPOSITORYLIST}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Get number of containers
    local numOf_repositories=`docker image ls | head -n -1 | wc -l`
    if [[ ${numOf_repositories} -eq 0 ]]; then
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
            show_centered_string__func "${ERRMSG_NO_IMAGES_FOUND}" "${DOCKER__TABLEWIDTH}"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        press_any_key__func
    else
        ${docker__repolist_tableinfo__fpath}

        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
    fi
}

docker__list_container__sub() {
    #Load header
    docker__load_header__sub

    #Define local constants
    local MENUTITLE_CONTAINERLIST="${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}-list"
    
    local ERRMSG_NO_CONTAINERS_FOUND="=:${DOCKER__FG_LIGHTRED}NO CONTAINERS FOUND${DOCKER__NOCOLOR}:="

    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        show_centered_string__func "${MENUTITLE_CONTAINERLIST}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Get number of containers
    local numOf_containers=`docker ps -a | head -n -1 | wc -l`
    if [[ ${numOf_containers} -eq 0 ]]; then
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
            show_centered_string__func "${ERRMSG_NO_CONTAINERS_FOUND}" "${DOCKER__TABLEWIDTH}"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        press_any_key__func
    else
        ${docker__containerlist_tableinfo__fpath}

        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
    fi
}

main_sub() {
    docker__load_environment_variables__sub

    docker__load_source_files__sub

    docker__load_header__sub

    docker__checkIf_user_is_root__sub

    docker__init_variables__sub

    docker__checkIf_exported_env_var_isPresent__sub

    docker__mainmenu__sub
}

#Execute main subroutine
main_sub
