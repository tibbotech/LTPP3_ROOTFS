#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---CONSTANTS
DOCKER__CREATEIMAGE_MENUTITLE="${DOCKER__FG_LIGHTBLUE}DOCKER: CREATE IMAGE(S)${DOCKER__NOCOLOR}"
DOCKER__VERSION="v21.03.17-0.0.1"



#---SUBROUTINES
docker__load_environment_variables__sub() {
    #---Define PATHS
    docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})
    if [[ ${docker__current_dir} == ${DOCKER__DOT} ]]; then
        docker__current_dir=$(pwd)
    fi
    docker__current_folder=`basename ${docker__current_dir}`

    docker__development_tools_folder="development_tools"
    if [[ ${docker__current_folder} != ${docker__development_tools_folder} ]]; then
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}/${docker__development_tools_folder}
    else
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}
    fi

    docker__global__filename="docker_global.sh"
    docker__global__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global__filename}

    docker__create_an_image_from_dockerfile_filename="docker_create_an_image_from_dockerfile.sh"
    docker__create_an_image_from_dockerfile_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__create_an_image_from_dockerfile_filename}
    docker__create_images_from_dockerlist_filename="docker_create_images_from_dockerlist.sh"
    docker__create_images_from_dockerlist_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__create_images_from_dockerlist_filename}
    docker__sunplus_git_link_assignment_filename="docker_sunplus_git_link_assignment.sh"
    docker__sunplus_git_link_assignment_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__sunplus_git_link_assignment_filename}
    docker__sunplus_git_checkout_assignment_filename="docker_sunplus_git_link_assignment.sh"
    docker__sunplus_git_checkout_assignment_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__sunplus_git_checkout_assignment_filename}
    docker__ssh_to_host_filename="docker_ssh_to_host.sh"
    docker__ssh_to_host_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__ssh_to_host_filename}
    docker__save_filename="docker_save.sh"
    docker__save_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__save_filename}
    docker__load_filename="docker_load.sh"
    docker__load_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__load_filename}

    docker__git_menu_filename="git_menu.sh"
    docker__git_menu_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__git_menu_filename}
}

docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

docker__load_header__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${DOCKER__BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__init_variables__sub() {
    docker__myChoice=""
}

docker__create_images_menu__sub() {
    while true
    do
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        show_leadingAndTrailingStrings_separatedBySpaces__func "${DOCKER__CREATEIMAGE_MENUTITLE}" "${DOCKER__VERSION}" "${DOCKER__TABLEWIDTH}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}1. Create an ${DOCKER__FG_BORDEAUX}image${DOCKER__NOCOLOR} using a ${DOCKER__FG_DARKBLUE}docker-file${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}2. Create ${DOCKER__FG_BORDEAUX}images${DOCKER__NOCOLOR} using a ${DOCKER__FG_LIGHTBLUE}docker-list${DOCKER__NOCOLOR}"
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

        while true
        do
            #Select an option
            read -N1 -r -p "Please choose an option: " docker__myChoice
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            #Only continue if a valid option is selected
            if [[ ! -z ${docker__myChoice} ]]; then
                if [[ ${docker__myChoice} =~ [1-2rcsiegq] ]]; then
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
                ${docker__create_an_image_from_dockerfile_fpath}
                ;;

            2)
                ${docker__create_images_from_dockerlist_fpath}
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

            e)
                ${docker__save_fpath}
                ;;

            i)
                ${docker__load_fpath}
                ;;

            g)  
                ${docker__git_menu_fpath}
                ;;

            q)
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

                exit 0
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
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
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



#---MAIN SUBROUTINE
main__sub() {
    docker__load_environment_variables__sub

    docker__load_source_files__sub

    docker__load_header__sub

    docker__init_variables__sub

    docker__create_images_menu__sub
}



#---EXECUTE
main__sub