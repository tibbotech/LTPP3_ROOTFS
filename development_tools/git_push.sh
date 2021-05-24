#!/bin/bash
#---COLOR CONSTANTS
DOCKER__NOCOLOR=$'\e[0m'
DOCKER__FG_LIGHTRED=$'\e[1;31m'
DOCKER__CHROOT_FG_GREEN=$'\e[30;38;5;82m'
DOCKER__FG_SOFTLIGHTBLUE=$'\e[30;38;5;80m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__INSIDE_FG_LIGHTGREY=$'\e[30;38;5;246m'
DOCKER__FILES_FG_ORANGE=$'\e[30;38;5;215m'
DOCKER__INSIDE_FG_LIGHTGREY=$'\e[30;38;5;246m'
DOCKER__OUTSIDE_FG_WHITE=$'\e[30;38;5;231m'

DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'
DOCKER__OUTSIDE_BG_LIGHTGREY=$'\e[30;48;5;246m'



#---CONSTANTS
DOCKER__TITLE="TIBBO"

#---CHARACTER CONSTANTS
DOCKER__DASH="-"
DOCKER__EMPTYSTRING=""

DOCKER__ENTER=$'\x0a'

#---NUMERIC CONSTANTS
DOCKER__TABLEWIDTH=70

DOCKER__NUMOFLINES_0=0
DOCKER__NUMOFLINES_1=1
DOCKER__NUMOFLINES_2=2
DOCKER__NUMOFLINES_3=3
DOCKER__NUMOFLINES_4=4
DOCKER__NUMOFLINES_5=5
DOCKER__NUMOFLINES_6=6
DOCKER__NUMOFLINES_7=7
DOCKER__NUMOFLINES_8=8
DOCKER__NUMOFLINES_9=9


#---FUNCTIONS
#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C_func INT

function CTRL_C_func() {
    echo -e "\r"
    echo -e "\r"
    echo -e "Exiting now..."
    echo -e "\r"
    echo -e "\r"

    exit
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

function duplicate_char__func()
{
    #Input args
    local char_input=${1}
    local numOf_times=${2}

    #Duplicate 'char_input'
    local char_duplicated=`printf '%*s' "${numOf_times}" | tr ' ' "${char_input}"`

    #Print text including Leading Empty Spaces
    echo -e "${char_duplicated}"
}



#---SUBROUTINES
docker__environmental_variables__sub() {
    #---Define paths
    docker__home_dir="/home/imcase"
    docker__home_scripts_dir=${docker__home_dir}/scripts
}

docker__load_header__sub() {
    echo -e "\r"
    echo -e "${DOCKER__TITLE_BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__TITLE_BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}


docker__add_comment_push__sub() {
    #Define local constants
    local MENUTITLE="Git ${DOCKER__OUTSIDE_BG_LIGHTGREY}${DOCKER__OUTSIDE_FG_WHITE}Push${DOCKER__NOCOLOR}"

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
        echo -e "\r"
        echo -e "---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: git add. (${DOCKER__CHROOT_FG_GREEN}done${DOCKER__NOCOLOR})"
    else
        echo -e "\r"
        echo -e "***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: git add. (${DOCKER__FG_LIGHTRED}failed${DOCKER__NOCOLOR})"
        echo -e "\r"

        exit 99
    fi

#---Git Commit
    #Provide a commit description
    echo -e "\r"
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
        echo -e "\r"
        echo -e "---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: git commit -m <your description> (${DOCKER__CHROOT_FG_GREEN}done${DOCKER__NOCOLOR})"
    else
        echo -e "\r"
        echo -e "***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}:  git commit -m <your description> (${DOCKER__FG_LIGHTRED}failed${DOCKER__NOCOLOR})"
        echo -e "\r"

        exit 99
    fi


#---Git Push
    #Execute command
    git push

    #Check exit-code
    exitCode=$?
    if [[ ${exitCode} -eq 0 ]]; then
        echo -e "---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: git push (${DOCKER__CHROOT_FG_GREEN}done${DOCKER__NOCOLOR})"
        echo -e "\r"

        exit 0
    else
        echo -e "***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: git push (${DOCKER__FG_LIGHTRED}failed${DOCKER__NOCOLOR})"
        echo -e "\r"

        exit 99
    fi
}

function moveUp_and_cleanLines__func() {
    #Input args
    local numOf_lines_toBeCleared=${1}

    #Clear lines
    local numOf_lines_cleared=1
    while [[ ${numOf_lines_cleared} -le ${numOf_lines_toBeCleared} ]]
    do
        tput cuu1	#move UP with 1 line
        tput el		#clear until the END of line

        numOf_lines_cleared=$((numOf_lines_cleared+1))  #increment by 1
    done
}


#---MAIN SUBROUTINE
main_sub() {
    docker__load_header__sub

    docker__environmental_variables__sub

    docker__add_comment_push__sub
}



#---EXECUTE
main_sub
