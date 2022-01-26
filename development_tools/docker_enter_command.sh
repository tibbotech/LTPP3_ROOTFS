#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---COLOR CONSTANTS
NOCOLOR=$'\e[0m'
FG_LIGHTRED=$'\e[1;31m'
CHROOT_FG_GREEN=$'\e[30;38;5;82m'
FG_SOFTLIGHTBLUE=$'\e[30;38;5;80m'
FG_LIGHTBLUE=$'\e[30;38;5;51m'
GENERAL_FG_YELLOW=$'\e[1;33m'
INSIDE_FG_LIGHTGREY=$'\e[30;38;5;246m'
FILES_FG_ORANGE=$'\e[30;38;5;215m'

FG_LIGHTGREEN=$'\e[30;38;5;71m'
FG_LIGHTSOFTYELLOW=$'\e[30;38;5;229m'

TITLE_BG_ORANGE=$'\e[30;48;5;215m'



#---CONSTANTS
TITLE="TIBBO"

CTRL_C_QUIT="Ctrl+C: Quit"

EMPTYSTRING=""
ARROWUP="arrowUp"
ARROWDOWN="arrowDown"



#---CHARACTER CONSTANTS
BACKSPACE=$'\177'
ENTER=$'\x0a'
ESC=$'\x1b'
TAB=$'\t'



#---BOOLEAN CONSTANTS



#---NUMERIC CONSTANTS



#---VARIABLES
cachedInput_Arr=()
cachedInput_ArrLen=0
cachedInput_ArrIndex=0
cachedInput_ArrIndex_max=0


#---FUNCTIONS
trap CTRL_C__func INT

function CTRL_C__func() {
    echo -e "\r"
    echo -e "\r"

    exit
}



#---SUBROUTINES
git_enter_command__sub() {
    #Define local constants
    local READ_INPUT_MSG="${FG_LIGHTBLUE}Command${NOCOLOR} (${CTRL_C_QUIT}): "

    #Define local variables
    local cmd=${EMPTYSTRING}
    local cmd_cached=${EMPTYSTRING}
    local cmd_len=0
    local echoMsg=${EMPTYSTRING}
    local echoMsg_wo_color=${EMPTYSTRING}
    local echoMsg_wo_color_len=${EMPTYSTRING}
    local arrow_direction=${EMPTYSTRING}

    #Start read-input
    #Arrow-up/down is used to cycle through the 'cached' input
    while true 
    do
        echo -e "\r"
        read -e -p "${READ_INPUT_MSG}" cmd

        if [[ ! -z ${cmd} ]]; then
            ${cmd}
        else
            tput cuu1
            tput el
            tput cuu1
            tput el
        fi
    done

    echo -e "\r"
}



#---MAIN SUBROUTINE
main__sub() {
    git_enter_command__sub
}



#---EXECUTE
main__sub
