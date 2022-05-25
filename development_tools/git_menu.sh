#---CONSTANTS
GIT__MENUTITLE="${DOCKER__FG_LIGHTBLUE}GIT MENU${DOCKER__NOCOLOR}"
GIT__VERSION="v21.03.17-0.0.1"



#---SUBROUTINES
docker__environmental_variables__sub() {
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

    git__git_push_filename="git_push.sh"
    git__git_pull_filename="git_pull.sh"
    git__git_pull_origin_otherBranch_filename="git_pull_origin_otherbranch.sh"
    git__git_create_checkout_local_branch_filename="git_create_checkout_local_branch.sh"
    git__git_delete_local_branch_filename="git_delete_local_branch.sh"
    git__git_push_fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${git__git_push_filename}
    git__git_pull_fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${git__git_pull_filename}
    git__git_pull_origin_otherBranch_fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${git__git_pull_origin_otherBranch_filename}
    git__git_create_checkout_local_branch_fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${git__git_create_checkout_local_branch_filename}
    git__git_delete_local_branch_fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${git__git_delete_local_branch_filename}
}

docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

docker__load_header__sub() {
    show_header__func "${DOCKER__TITLE}" "${DOCKER__TABLEWIDTH}" "${DOCKER__BG_ORANGE}" "${DOCKER__NUMOFLINES_2}" "${DOCKER__NUMOFLINES_0}"
}

docker__init_variables__sub() {
    docker__myChoice=""

    docker__childWhileLoop_isExit=false
    docker__parentWhileLoop_isExit=false
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
        echo -e "${DOCKER__FOURSPACES}4. Git ${DOCKER__FG_GREEN41}create${DOCKER__NOCOLOR}/${DOCKER__FG_LIGHTSOFTYELLOW}checkout${DOCKER__NOCOLOR} ${DOCKER__FG_LIGHTGREY}local${DOCKER__NOCOLOR} branch"
        echo -e "${DOCKER__FOURSPACES}5. Git ${DOCKER__FG_SOFTLIGHTRED}delete${DOCKER__NOCOLOR} ${DOCKER__FG_LIGHTGREY}local${DOCKER__NOCOLOR} branch"
        echo -e "${DOCKER__FOURSPACES}0. Enter Command Prompt"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}q. $DOCKER__QUIT_CTRL_C"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        # echo -e "\r"

        while true
        do
            #Select an option
            read -N1 -r -p "Please choose an option: " docker__myChoice
            echo -e "\r"

            #Only continue if a valid option is selected
            case "${docker__myChoice}" in
                ${DOCKER__CTRL_C})
                    docker__exit_handler__sub
                    ;;
                *)
                    if [[ ! -z "${docker__myChoice}" ]]; then
                        if [[ ${docker__myChoice} =~ [01-5hq] ]]; then
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
                    ;;
            esac

            #Check if flag is given to break loop
            if [[ ${docker__childWhileLoop_isExit} == true ]]; then
                break
            fi
        done
            
        #Goto the selected option
        case ${docker__myChoice} in
            1)  
                ${git__git_push_fpath}
                ;;

            2)  
                ${git__git_pull_fpath}
                ;;

            3)
                ${git__git_pull_origin_otherBranch_fpath}
                ;;

            4)
                ${git__git_create_checkout_local_branch_fpath}
                ;;

            5)
                ${git__git_delete_local_branch_fpath}
                ;;
            0)
                ${docker__enter_cmdline_mode__fpath} "${DOCKER__EMPTYSTRING}"
                ;;
            q)
                docker__exit_handler__sub
                ;;
        esac

        #Check if flag is given to break loop
        if [[ ${docker__parentWhileLoop_isExit} == true ]]; then
            break
        fi
    done
}

docker__exit_handler__sub() {
    #Set flag to true
    docker__childWhileLoop_isExit=true
    docker__parentWhileLoop_isExit=true

    #Move-down and clean 1 line
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
}



#---MAIN SUBROUTINE
main__sub() {
    docker__environmental_variables__sub

    docker__load_source_files__sub

    docker__load_header__sub

    docker__init_variables__sub

    git__menu_sub
}



#---EXECUTE
main__sub