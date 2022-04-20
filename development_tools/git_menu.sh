#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---CONSTANTS
GIT__MENUTITLE="${DOCKER__FG_LIGHTBLUE}GIT MENU${DOCKER__NOCOLOR}"
GIT__VERSION="v21.03.17-0.0.1"



#---FUNCTIONS
function cmd_exec__func() {
    #Input args
    cmd=${1}

    #Define local variable
    currUser=$(whoami)

    #Exec command
    if [[ ${currUser} != "root" ]]; then
        sudo ${cmd}
    else
        ${cmd}
    fi
}



#---SUBROUTINES
git__environmental_variables__sub() {
    git__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    git__current_dir=$(dirname ${git__current_script_fpath})
    if [[ ${git__current_dir} == ${DOCKER__DOT} ]]; then
        git__current_dir=$(pwd)
    fi
    git__current_folder=`basename ${git__current_dir}`

    git__development_tools_folder="development_tools"
    if [[ ${git__current_folder} != ${git__development_tools_folder} ]]; then
        git__my_LTPP3_ROOTFS_development_tools_dir=${git__current_dir}/${git__development_tools_folder}
    else
        git__my_LTPP3_ROOTFS_development_tools_dir=${git__current_dir}
    fi

    docker__global__filename="docker_global.sh"
    docker__global__fpath=${git__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global__filename}

    git__git_push_filename="git_push.sh"
    git__git_pull_filename="git_pull.sh"
    git__git_pull_origin_otherBranch_filename="git_pull_origin_otherbranch.sh"
    git__git_create_checkout_local_branch_filename="git_create_checkout_local_branch.sh"
    git__git_delete_local_branch_filename="git_delete_local_branch.sh"
    git__git_push_fpath=${git__my_LTPP3_ROOTFS_development_tools_dir}/${git__git_push_filename}
    git__git_pull_fpath=${git__my_LTPP3_ROOTFS_development_tools_dir}/${git__git_pull_filename}
    git__git_pull_origin_otherBranch_fpath=${git__my_LTPP3_ROOTFS_development_tools_dir}/${git__git_pull_origin_otherBranch_filename}
    git__git_create_checkout_local_branch_fpath=${git__my_LTPP3_ROOTFS_development_tools_dir}/${git__git_create_checkout_local_branch_filename}
    git__git_delete_local_branch_fpath=${git__my_LTPP3_ROOTFS_development_tools_dir}/${git__git_delete_local_branch_filename}
}

git__load_source_files__sub() {
    source ${docker__global__fpath}
}

git__load_header__sub() {
    echo -e "\r"
    echo -e "${DOCKER__BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

git__init_variables__sub() {
    git__myChoice=""
}

git__menu_sub() {
    while true
    do
        #Get current CHECKOUT BRANCH
        local git_current_checkout_branch=`git branch | grep "*" | cut -d"*" -f2 | xargs`

        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        show_leadingAndTrailingStrings_separatedBySpaces__func "${GIT__MENUTITLE}" "${GIT__VERSION}" "${DOCKER__TABLEWIDTH}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}Current Checkout Branch: ${DOCKER__FG_LIGHTSOFTYELLOW}${git_current_checkout_branch}${DOCKER__NOCOLOR}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}1. Git ${DOCKER__BG_LIGHTGREY}${DOCKER__FG_WHITE}Push${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}2. Git ${DOCKER__BG_WHITE}${DOCKER__FG_LIGHTGREY}Pull${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}3. Git ${DOCKER__BG_WHITE}${DOCKER__FG_LIGHTGREY}Pull${DOCKER__NOCOLOR} origin other-branch"
        echo -e "${DOCKER__FOURSPACES}4. Git ${DOCKER__FG_GREEN71}create${DOCKER__NOCOLOR}/${DOCKER__FG_LIGHTSOFTYELLOW}checkout${DOCKER__NOCOLOR} ${DOCKER__FG_LIGHTGREY}local${DOCKER__NOCOLOR} branch"
        echo -e "${DOCKER__FOURSPACES}5. Git ${DOCKER__FG_SOFTLIGHTRED}delete${DOCKER__NOCOLOR} ${DOCKER__FG_LIGHTGREY}local${DOCKER__NOCOLOR} branch"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}q. $DOCKER__QUIT_CTRL_C"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        # echo -e "\r"

        while true
        do
            #Select an option
            read -N1 -r -p "Please choose an option: " git__myChoice
            echo -e "\r"

            #Only continue if a valid option is selected
            if [[ ! -z ${git__myChoice} ]]; then
                if [[ ${git__myChoice} =~ [1-5hq] ]]; then
                    break
                else
                    if [[ ${git__myChoice} == ${DOCKER__ENTER} ]]; then
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
        case ${git__myChoice} in
            1)  
                cmd_exec__func "${git__git_push_fpath}"
                ;;

            2)  
                cmd_exec__func "${git__git_pull_fpath}"
                ;;

            3)
                cmd_exec__func "${git__git_pull_origin_otherBranch_fpath}"
                ;;

            4)
                cmd_exec__func "${git__git_create_checkout_local_branch_fpath}"
                ;;

            5)
                cmd_exec__func "${git__git_delete_local_branch_fpath}"
                ;;

            q)
                echo -e "\r"
                echo -e "\r"

                exit 0
                ;;
        esac
    done
}



#---MAIN SUBROUTINE
main__sub() {
    git__environmental_variables__sub

    git__load_source_files__sub

    git__load_header__sub

    git__init_variables__sub

    git__menu_sub
}



#---EXECUTE
main__sub