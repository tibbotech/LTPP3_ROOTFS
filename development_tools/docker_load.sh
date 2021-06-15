#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---COLOR CONSTANTS
DOCKER__NOCOLOR=$'\e[0m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__IMAGEID_FG_BORDEAUX=$'\e[30;38;5;198m'
DOCKER__DIRS_FG_VERYLIGHTORANGE=$'\e[30;38;5;223m'
DOCKER__FILES_FG_ORANGE=$'\e[30;38;5;215m'
DOCKER__TAG_FG_LIGHTPINK=$'\e[30;38;5;218m'
DOCKER__FG_LIGHTGREY=$'\e[30;38;5;246m'

DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'

#---CONSTANTS
DOCKER__TITLE="TIBBO"

#---CHARACTER CONSTANTS
DOCKER__DASH="-"
DOCKER__EMPTYSTRING=""
DOCKER__SLASH_CHAR="/"

DOCKER__ENTER=$'\x0a'

DOCKER__ONESPACE=" "
DOCKER__TWOSPACES=${DOCKER__ONESPACE}${DOCKER__ONESPACE}
DOCKER__FOURSPACES=${DOCKER__TWOSPACES}${DOCKER__TWOSPACES}

#---NUMERIC CONSTANTS
DOCKER__NINE=9
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

#---MENU CONSTANTS
DOCKER__CTRL_C_QUIT="${DOCKER__FOURSPACES}Quit (Ctrl+C)"
DOCKER__Q_QUIT="${DOCKER__FOURSPACES}q. Quit (Ctrl+C)"



#---FUNCTIONS
#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C__func INT

function CTRL_C__func() {
    echo -e "\r"
    echo -e "\r"

    exit
}

function press_any_key__func() {
	#Define constants
	local ANYKEY_TIMEOUT=10

	#Initialize variables
	local keyPressed=${DOCKER__EMPTYSTRING}
	local tCounter=0

	#Show Press Any Key message with count-down
	echo -e "\r"
	while [[ ${tCounter} -le ${ANYKEY_TIMEOUT} ]];
	do
		delta_tCounter=$(( ${ANYKEY_TIMEOUT} - ${tCounter} ))

		echo -e "\rPress (a)bort or any key to continue... (${delta_tCounter}) \c"
		read -N 1 -t 1 -s -r keyPressed

		if [[ ! -z "${keyPressed}" ]]; then
			if [[ "${keyPressed}" == "a" ]] || [[ "${keyPressed}" == "A" ]]; then
				exit
			else
				break
			fi
		fi
		
		tCounter=$((tCounter+1))
	done
	echo -e "\r"
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

function moveDown_and_cleanLines__func() {
    #Input args
    local numOf_lines_toBeCleared=${1}

    #Clear lines
    local numOf_lines_cleared=1
    while [[ ${numOf_lines_cleared} -le ${numOf_lines_toBeCleared} ]]
    do
        tput cud1	#move UP with 1 line
        tput el	#clear until the END of line

        numOf_lines_cleared=$((numOf_lines_cleared+1))  #increment by 1
    done
}



#--SUBROUTINES
docker__load_header__sub() {
    echo -e "\r"
    echo -e "${DOCKER__TITLE_BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__TITLE_BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__environmental_variables__sub() {
    #Define paths
    docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})
    docker__parent_dir=${docker__current_dir%/*}    #gets one directory up
    if [[ -z ${docker__parent_dir} ]]; then
        docker__parent_dir="${DOCKER__SLASH_CHAR}"
    fi

    docker__first_dir=${docker__parent_dir%/*}    #gets one directory up
    docker__images_dir=${docker__first_dir}/docker/images
    docker__image_fPath=${DOCKER__EMPTYSTRING}
}


docker__load_handler__sub() {
    #Define local constants
    local MENUTITLE="${DOCKER__GENERAL_FG_YELLOW}Load${DOCKER__NOCOLOR} an ${DOCKER__IMAGEID_FG_BORDEAUX}Image${DOCKER__NOCOLOR} file"
    local MENUTITLE_UPDATED_IMAGE_LIST="Updated ${DOCKER__IMAGEID_FG_BORDEAUX}Image${DOCKER__NOCOLOR}-list"

    #Define local message constants
    local ECHOMSG_IMAGE_LOCATION="${DOCKER__IMAGEID_FG_BORDEAUX}Image${DOCKER__NOCOLOR} Location: "
    local ERRMSG_NO_IMAGES_FILES_FOUND="=:${DOCKER__ERROR_FG_LIGHTRED}NO IMAGES FILES FOUND${DOCKER__NOCOLOR}:="

    #Define local read-input constants
    local READMSG_YOUR_CHOICE="Your choice: "
    local READMSG_DO_YOU_WISH_TO_CONTINUE="Do you wish to continue (y/n)? "    #Define local command variables

    #Define local variables
    local imageList_fPath_arrItem=${DOCKER__EMPTYSTRING}
    local imageList_filename=${DOCKER__EMPTYSTRING}
    local myChoice=${DOCKER__EMPTYSTRING}

    #Define local message variables
    local errMsg=${DOCKER__EMPTYSTRING}
    local locationMsg_dockerFiles="${DOCKER__FOURSPACES}${DOCKER__DIRS_FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR}: ${docker__images_dir}"

    #Define local command variables
    local docker_image_ls_cmd="docker image ls"




    #Show menu-title
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${MENUTITLE}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Get all files at the specified location
    local imageList_fPath_string=`find ${docker__images_dir} -maxdepth 1 -type f`
    local imageList_fPath_arrItem=${DOCKER__EMPTYSTRING}

    #Check if '' is an EMPTY STRING
    if [[ -z ${imageList_fPath_string} ]]; then
        echo -e "\r"

        show_centered_string__func "${ERRMSG_NO_IMAGES_FILES_FOUND}" "${DOCKER__TABLEWIDTH}"
    else
        #Convert string to array (with space delimiter)
        local imageList_fPath_arr=(${imageList_fPath_string})

        #Initial sequence number
        local seqNum=1

        #Show all files
        for imageList_fPath_arrItem in "${imageList_fPath_arr[@]}"
        do
            #Get filename only
            imageList_filename=`basename ${imageList_fPath_arrItem}`  
        
            #Show filename
            echo -e "${DOCKER__FOURSPACES}${seqNum}. ${imageList_filename}"

            #increment sequence-number
            seqNum=$((seqNum+1))
        done
    fi

    echo -e "\r"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${locationMsg_dockerFiles}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${DOCKER__FOURSPACES}m. Manual input"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${DOCKER__Q_QUIT}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"


    #Choose an option
    while true
    do
        while true
        do
            #Show read-input
            if [[ ${seqNum} -le ${DOCKER__NINE} ]]; then    #seqNum <= 9
                read -N1 -p "${READMSG_YOUR_CHOICE} " myChoice
            else    #seqNum > 9
                read -e -p "${READMSG_YOUR_CHOICE} " myChoice
            fi

            #Check if 'myChoice' is a numeric value
            if [[ ${myChoice} =~ [1-90mq] ]]; then
                #check if 'myChoice' is one of the numbers shown in the overview...
                #... AND 'myChoice' is NOT '0'
                if [[ ${myChoice} -lt ${seqNum} ]] && [[ ${myChoice} -ne 0 ]]; then
                    arrNum=$((myChoice-1))
                    myOutput_fPath=${imageList_fPath_arr[${arrNum}]}

                    echo -e "\r"
                    echo -e "\r"
                    echo -e "${ECHOMSG_IMAGE_LOCATION}"

#---This part has been implemented to make sure that the file-location...
#---is not shown on the last terminal line
                    echo -e "\r"
                    echo -e "\r"
                    
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
#---This part has been implemented to make sure that the file-location...
#---is not shown on the last terminal line
                    
                    echo -e "${DOCKER__FG_LIGHTGREY}"
                    read -e -p "${DOCKER__FOURSPACES}" -i "${myOutput_fPath}" myOutput_fPath
                    echo -e "${DOCKER__NOCOLOR}"

                    break

                elif [[ ${myChoice} == "m" ]]; then
                    myOutput_fPath=${imageList_fPath_arr[0]}  #'imageList_fPath_arr' contains the full-path

                    echo -e "\r"
                    echo -e "\r"
                    echo -e "${ECHOMSG_IMAGE_LOCATION}"

#---This part has been implemented to make sure that the file-location...
#---is not shown on the last terminal line
                    echo -e "\r"
                    echo -e "\r"
                    
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
#---This part has been implemented to make sure that the file-location...
#---is not shown on the last terminal line

                    echo -e "${DOCKER__FG_LIGHTGREY}"
                    read -e -p "${DOCKER__FOURSPACES}" -i "${myOutput_fPath}" myOutput_fPath
                    echo -e "${DOCKER__NOCOLOR}"

                    break

                elif [[ ${myChoice} == "q" ]]; then
                    CTRL_C__func

                else
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"   

                fi
            else    #for all other keys
                if [[ ${myChoice} != "${DOCKER__ENTER}" ]]; then    #no ENTER was pressed
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                else    #ENTER was pressed
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                fi
            fi
        done

        #Double-check if chosen image-file still exist
        if [[ -f ${myOutput_fPath} ]]; then
            while true
            do
                read -N1 -p "${READMSG_DO_YOU_WISH_TO_CONTINUE}" myAnswer
                if  [[ ${myAnswer} == "y" ]]; then
                    echo -e "\r"
                    echo -e "\r"
                    echo -e "---:${DOCKER__FILES_FG_ORANGE}START${DOCKER__NOCOLOR}: Loading image '${DOCKER__FG_LIGHTGREY}${myOutput_fPath}${DOCKER__NOCOLOR}'"
                    echo -e "---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Depending on the image size..."
                    echo -e "---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: This may take a while..."
                    echo -e "---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Please wait..."

                        docker image load --input ${myOutput_fPath} > /dev/null

                    echo -e "---:${DOCKER__FILES_FG_ORANGE}COMPLETED${DOCKER__NOCOLOR}: Loading image '${DOCKER__FG_LIGHTGREY}${myOutput_fPath}${DOCKER__NOCOLOR}'"

                    #Show Docker Image List
                    echo -e "\r"

                    docker__show_list_with_menuTitle__func "${MENUTITLE_UPDATED_IMAGE_LIST}" "${docker_image_ls_cmd}"
                    
                    echo -e "\r"
                    echo -e "\r"

                    exit

                elif  [[ ${myAnswer} == "n" ]]; then
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_7}"

                    break
                else    #Empty String
                    if [[ ${myAnswer} != "${DOCKER__ENTER}" ]]; then    #no ENTER was pressed
                        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                    else    #ENTER was pressed
                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                    fi
                fi
            done
        else    #directory does NOT exist
            errMsg="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: File '${DOCKER__FG_LIGHTGREY}${myOutput_fPath}${DOCKER__NOCOLOR}' not found"

            docker__show_errMsg_without_menuTitle__func "${errMsg}" "${DOCKER__NUMOFLINES_0}"

            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_9}"
        fi
    done
}

function docker__show_list_with_menuTitle__func() {
    #Input args
    local menuTitle=${1}
    local dockerCmd=${2}

    #Show list
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${menuTitle}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    
    ${dockerCmd}

    echo -e "\r"

    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${DOCKER__CTRL_C_QUIT}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
}

function docker__show_errMsg_without_menuTitle__func() {
    #Input args
    local errMsg=${1}
    local numOf_lines_toBe_movedDown=${2}

    #Move-Down and Clean Lines
    #REMARK: actually the lines do not need to be cleaned
    moveDown_and_cleanLines__func ${numOf_lines_toBe_movedDown}

    #Show error-message
    echo -e "${errMsg}"

    press_any_key__func
}



#---MAIN SUBROUTINE
main_sub() {
    docker__load_header__sub

    docker__environmental_variables__sub

    docker__load_handler__sub
}



#---EXECUTE
main_sub
