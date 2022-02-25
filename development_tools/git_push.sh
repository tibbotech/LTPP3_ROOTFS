#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---SUBROUTINES
git__environmental_variables__sub() {
	# git__current_dir=`pwd`
	git__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    git__current_dir=$(dirname ${git__current_script_fpath})	#/repo/LTPP3_ROOTFS/development_tools
	git__parent_dir=${git__current_dir%/*}    #gets one directory up (/repo/LTPP3_ROOTFS)
    if [[ -z ${git__parent_dir} ]]; then
        git__parent_dir="${DOCKER__SLASH}"
    fi
	git__current_folder=`basename ${git__current_dir}`

    git__development_tools_folder="development_tools"
    if [[ ${git__current_folder} != ${git__development_tools_folder} ]]; then
        git__my_LTPP3_ROOTFS_development_tools_dir=${git__current_dir}/${git__development_tools_folder}
    else
        git__my_LTPP3_ROOTFS_development_tools_dir=${git__current_dir}
    fi

    docker__global_functions_filename="docker_global_functions.sh"
    docker__global_functions_fpath=${git__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global_functions_filename}
}

git__load_source_files__sub() {
    source ${docker__global_functions_fpath}
}

git__load_header__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${DOCKER__BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}


git__add_comment_push__sub() {
    #Define local constants
    local MENUTITLE="Git ${DOCKER__BG_LIGHTGREY}${DOCKER__FG_WHITE}Push${DOCKER__NOCOLOR}"

    #Define local variables
    local username=${DOCKER__EMPTYSTRING}
    local password=${DOCKER__EMPTYSTRING}
    local commit_description=${DOCKER__EMPTYSTRING}
    local ts_current=${DOCKER__EMPTYSTRING}

    #Define local message variables
    local errMsg=${DOCKER__EMPTYSTRING}

    #Show menu-title
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${MENUTITLE}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

#---Git Add
    #Execute command
    git add .

    #Check exit-code
    exitCode=$?
    if [[ ${exitCode} -eq 0 ]]; then
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: git add. (${DOCKER__FG_GREEN}done${DOCKER__NOCOLOR})"
    else
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: git add. (${DOCKER__FG_LIGHTRED}failed${DOCKER__NOCOLOR})"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        exit 99
    fi

#---Git Commit
    #Provide a commit description
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    while true
    do
        read -e -p "Provide a description for this commit: " commit_description

        if [[ ! -z ${commit_description} ]]; then
            break
        else
            if [[ ${commit_description} != "${DOCKER__ENTER}" ]]; then    #no ENTER was pressed
                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
            fi
        fi
    done

    #Execute command
    git commit -m "${commit_description}"

    #Check exit-code
    exitCode=$?
    if [[ ${exitCode} -eq 0 ]]; then
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: git commit -m <your description> (${DOCKER__FG_GREEN}done${DOCKER__NOCOLOR})"
    else
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}:  git commit -m <your description> (${DOCKER__FG_LIGHTRED}failed${DOCKER__NOCOLOR})"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        exit 99
    fi


#---Git Push
    #Execute command
    git push

    #Check exit-code
    exitCode=$?
    if [[ ${exitCode} -eq 0 ]]; then
        echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: git push (${DOCKER__FG_GREEN}done${DOCKER__NOCOLOR})"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        exit 0
    else
        echo -e "***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: git push (${DOCKER__FG_LIGHTRED}failed${DOCKER__NOCOLOR})"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        exit 99
    fi
}



#---MAIN SUBROUTINE
main_sub() {
    git__environmental_variables__sub

    git__load_source_files__sub

    git__load_header__sub

    git__environmental_variables__sub

    git__add_comment_push__sub
}



#---EXECUTE
main_sub
