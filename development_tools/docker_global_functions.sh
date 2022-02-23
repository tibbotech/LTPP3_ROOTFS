#!/bin/bash

function checkForMatch_keyWord_within_string__func() {
    #Input Args
    local keyWord__input=${1}
    local string__input=${2}

    #Find any match (not exact)
    local stdOutput=`echo ${string__input} | grep "${keyWord__input}"`
    if [[ -z ${stdOutput} ]]; then  #no match
        echo "false"
    else    #match
        echo "true"
    fi
}

function moveUp__func() {
    #Input args
    local numOfLines=${1}

    #Clear lines
    local counter=1
    while [[ ${counter} -le ${numOfLines} ]]
    do
        tput cuu1	#move UP with 1 line

        counter=$((counter+1))  #increment by 1
    done
}

function moveUp_and_cleanLines__func() {
    #Input args
    local numOfLines=${1}

    #Clear lines
    local xPos_curr=0

    if [[ ${numOfLines} != 0 ]]; then
        local counter=1
        while [[ ${counter} -le ${numOfLines} ]]
        do
            tput el1    #clear CURRENT line until BEGINNING of line
            tput cuu1	#move-UP 1 line
            tput el		#clear CURRENT line until END of line

            #Increment counter by 1
            counter=$((counter+1))
        done
    else    #
        tput el1
    fi

    #Get current x-position of cursor
    xPos_curr=`tput cols`
    #Move to the beginning of line
    tput cub ${xPos_curr}
}

function moveDown_and_cleanLines__func() {
    #Input args
    local numOfLines=${1}

    #Clear lines
    local counter=1
    while [[ ${counter} -le ${numOfLines} ]]
    do
        tput cud1	#move-DOWN 1 line
        tput el1	 #clear CURRENT line until BEGINNING of line

        #Increment counter by 1
        counter=$((counter+1))
    done
}

function moveDown_oneLine_then_moveUp_and_clean__func() {
    #Input args
    local numOfLines=${1}

    #Move-down 1 line
    tput cud1

    #Move-up and clean a specified number of times
    moveUp_and_cleanLines__func "${numOfLines}"
}

function moveUp_oneLine_then_moveRight__func() {
    #Input args
    local mainMsg=${1}
    local keyInput=${2}

    #Get lengths
    local mainMsg_wo_regEx=$(echo -e "$mainMsg" | sed "s/$(echo -e "\e")[^m]*m//g")
    local mainMsg_wo_regEx_len=${#mainMsg_wo_regEx}
    local keyInput_wo_regEx=$(echo -e "$keyInput" | sed "s/$(echo -e "\e")[^m]*m//g")
    local keyInput_wo_regEx_len=${#keyInput_wo_regEx}
    local total_len=$((mainMsg_wo_regEx_len + keyInput_wo_regEx_len))

    #Move cursor up by 1 line
    tput cuu1
    #Move cursor to right
    tput cuf ${total_len}
}
