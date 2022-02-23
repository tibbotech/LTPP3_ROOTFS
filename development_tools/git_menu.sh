#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---COLOR CONSTANTS
GIT__NOCOLOR=$'\e[0m'
GIT__TITLE_FG_LIGHTBLUE=$'\e[30;38;5;45m'
GIT__INSIDE_FG_LIGHTGREY=$'\e[30;38;5;246m'
GIT__OUTSIDE_FG_WHITE=$'\e[30;38;5;231m'

GIT__FG_SOFTLIGHTRED=$'\e[30;38;5;131m'
GIT__FG_LIGHTGREEN=$'\e[30;38;5;71m'
GIT__FG_LIGHTSOFTYELLOW=$'\e[30;38;5;229m'

GIT__TITLE_BG_ORANGE=$'\e[30;48;5;215m'
GIT__INSIDE_BG_WHITE=$'\e[30;48;5;15m'
GIT__OUTSIDE_BG_LIGHTGREY=$'\e[30;48;5;246m'



#---CONSTANTS
GIT__TITLE="TIBBO"

GIT__MENUTITLE="${GIT__TITLE_FG_LIGHTBLUE}GIT MENU${GIT__NOCOLOR}"
GIT__VERSION="v21.03.17-0.0.1"

GIT__QUIT_CTRL_C="Quit (Ctrl+C)"

#---CHAR CONSTANTS
GIT__DOT="."
GIT__DASH="-"
GIT__ENTER=$'\x0a'

#---NUMERIC CONSTANTS
GIT__TABLEWIDTH=70

GIT__ONESPACE=" "
GIT__TWOSPACES=${GIT__ONESPACE}${GIT__ONESPACE}
GIT__FOURSPACES=${GIT__TWOSPACES}${GIT__TWOSPACES}

GIT__NUMOFLINES_1=1
GIT__NUMOFLINES_2=2



#---VARIABLES



#---FUNCTIONS
trap CTRL_C__func INT

function CTRL_C__func() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

    exit
}

function show_leadingAndTrailingStrings_separatedBySpaces__func()
{
    #Input args
    local leadStr_input=${1}
    local trailStr_input=${2}
    local maxStrLen_input=${3}

    #Define local variables
    local ONESPACE=" "

    #Get string 'without visiable' color characters
    local leadStr_input_wo_colorChars=`echo "${leadStr_input}" | sed "s,\x1B\[[0-9;]*m,,g"`
    local trailStr_input_wo_colorChars=`echo "${trailStr_input}" | sed "s,\x1B\[[0-9;]*m,,g"`

    #Get string length
    local leadStr_input_wo_colorChars_len=${#leadStr_input_wo_colorChars}
    local trailStr_input_wo_colorChars_len=${#trailStr_input_wo_colorChars}

    #Calculated the number of spaces to-be-added
    local numOf_spaces=$(( maxStrLen_input-(leadStr_input_wo_colorChars_len+trailStr_input_wo_colorChars_len) ))

    #Create a string containing only EMPTY SPACES
    local emptySpaces_string=`printf '%*s' "${numOf_spaces}" | tr ' ' "${ONESPACE}"`

    #Print text including Leading Empty Spaces
    echo -e "${leadStr_input}${emptySpaces_string}${trailStr_input}"
}

function cmd_exec__func()
{
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

function show_centered_string__func()
{
    #Input args
    local str_input=${1}
    local maxStrLen_input=${2}

    #Define one-space constant
    local ONESPACE=" "

    #Get string 'without visiable' color characters
    local strInput_wo_colorChars=`echo "${str_input}" | sed "s,\x1B\[[0-9;]*m,,g"`

    #Get string length
    local strInput_wo_colorChars_len=${#strInput_wo_colorChars}

    #Calculated the number of spaces to-be-added
    local numOf_spaces=$(( (maxStrLen_input-strInput_wo_colorChars_len)/2 ))

    #Create a string containing only EMPTY SPACES
    local emptySpaces_string=`duplicate_char__func "${ONESPACE}" "${numOf_spaces}" `

    #Print text including Leading Empty Spaces
    echo -e "${emptySpaces_string}${str_input}"
}

function duplicate_char__func() {
    #Input args
    local char_input=${1}
    local numOf_times=${2}

    #Duplicate 'char_input'
    local char_duplicated=`printf '%*s' "${numOf_times}" | tr ' ' "${char_input}"`

    #Print text including Leading Empty Spaces
    echo -e "${char_duplicated}"
}



#---SUBROUTINES
git__environmental_variables__sub() {
    git__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    git__current_dir=$(dirname ${git__current_script_fpath})
    if [[ ${git__current_dir} == ${GIT__DOT} ]]; then
        git__current_dir=$(pwd)
    fi
    git__current_folder=`basename ${git__current_dir}`

    git__development_tools_folder="development_tools"
    if [[ ${git__current_folder} != ${git__development_tools_folder} ]]; then
        git__my_LTPP3_ROOTFS_development_tools_dir=${git__current_dir}/${git__development_tools_folder}
    else
        git__my_LTPP3_ROOTFS_development_tools_dir=${git__current_dir}
    fi

    docker__my_LTPP3_ROOTFS_development_tools_dir=${git__current_dir}/development_tools
    docker__global_functions_filename="docker_global_functions.sh"
    docker__global_functions_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global_functions_filename}

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
    source ${docker__global_functions_fpath}
}

git__load_header__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${GIT__TITLE_BG_ORANGE}                                 ${GIT__TITLE}${GIT__TITLE_BG_ORANGE}                                ${GIT__NOCOLOR}"
}

git__init_variables__sub() {
    git__myChoice=""
}

git__menu_sub() {
    while true
    do
        #Get current CHECKOUT BRANCH
        local git_current_checkout_branch=`git branch | grep "*" | cut -d"*" -f2 | xargs`

        duplicate_char__func "${GIT__DASH}" "${GIT__TABLEWIDTH}"
        show_leadingAndTrailingStrings_separatedBySpaces__func "${GIT__MENUTITLE}" "${GIT__VERSION}" "${GIT__TABLEWIDTH}"
        duplicate_char__func "${GIT__DASH}" "${GIT__TABLEWIDTH}"
        echo -e "${GIT__FOURSPACES}Current Checkout Branch: ${GIT__FG_LIGHTSOFTYELLOW}${git_current_checkout_branch}${GIT__NOCOLOR}"
        duplicate_char__func "${GIT__DASH}" "${GIT__TABLEWIDTH}"
        echo -e "${GIT__FOURSPACES}1. Git ${GIT__OUTSIDE_BG_LIGHTGREY}${GIT__OUTSIDE_FG_WHITE}Push${GIT__NOCOLOR}"
        echo -e "${GIT__FOURSPACES}2. Git ${GIT__INSIDE_BG_WHITE}${GIT__INSIDE_FG_LIGHTGREY}Pull${GIT__NOCOLOR}"
        echo -e "${GIT__FOURSPACES}3. Git ${GIT__INSIDE_BG_WHITE}${GIT__INSIDE_FG_LIGHTGREY}Pull${GIT__NOCOLOR} origin other-branch"
        echo -e "${GIT__FOURSPACES}4. Git ${GIT__FG_LIGHTGREEN}create${GIT__NOCOLOR}/${GIT__FG_LIGHTSOFTYELLOW}checkout${GIT__NOCOLOR} ${GIT__INSIDE_FG_LIGHTGREY}local${GIT__NOCOLOR} branch"
        echo -e "${GIT__FOURSPACES}5. Git ${GIT__FG_SOFTLIGHTRED}delete${GIT__NOCOLOR} ${GIT__INSIDE_FG_LIGHTGREY}local${GIT__NOCOLOR} branch"
        duplicate_char__func "${GIT__DASH}" "${GIT__TABLEWIDTH}"
        echo -e "${GIT__FOURSPACES}q. $GIT__QUIT_CTRL_C"
        duplicate_char__func "${GIT__DASH}" "${GIT__TABLEWIDTH}"
        # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        while true
        do
            #Select an option
            read -N1 -r -p "Please choose an option: " git__myChoice
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            #Only continue if a valid option is selected
            if [[ ! -z ${git__myChoice} ]]; then
                if [[ ${git__myChoice} =~ [1-5hq] ]]; then
                    break
                else
                    if [[ ${git__myChoice} == ${GIT__ENTER} ]]; then
                        moveUp_and_cleanLines__func "${GIT__NUMOFLINES_1}"
                    else
                        moveDown_oneLine_then_moveUp_and_clean__func "${GIT__NUMOFLINES_1}"
                    fi
                fi
            else
                moveDown_oneLine_then_moveUp_and_clean__func "${GIT__NUMOFLINES_1}"
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
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

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