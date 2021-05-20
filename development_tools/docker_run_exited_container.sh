#!/bin/bash
#---COLOR CONSTANTS
DOCKER__NOCOLOR=$'\e[0;0m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__CONTAINER_FG_BRIGHTPRUPLE=$'\e[30;38;5;141m'
DOCKER__OUTSIDE_FG_WHITE=$'\e[30;38;5;231m'

DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'
DOCKER__TITLE_BG_LIGHTBLUE=$'\e[30;48;5;45m'
DOCKER__REMARK_BG_ORANGE=$'\e[30;48;5;208m'
DOCKER__CONTAINER_BG_BRIGHTPRUPLE=$'\e[30;48;5;141m'

#---CONSTANTS
DOCKER__TITLE="TIBBO"

#---CHARACTER CHONSTANTS
DOCKER__DASH="-"
DOCKER__EMPTYSTRING=""


#---NUMERIC CONSTANTS
DOCKER__TABLEWIDTH=70

DOCKER__NUMOFLINES_1=1
DOCKER__NUMOFLINES_2=2
DOCKER__NUMOFLINES_3=3
DOCKER__NUMOFLINES_4=4
DOCKER__NUMOFLINES_5=5
DOCKER__NUMOFLINES_6=6



#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C_func INT



#---FUNCTIONS
function CTRL_C_func() {
    echo -e "\r"
    echo -e "\r"
    # echo -e "Exiting now..."
    # echo -e "\r"
    # echo -e "\r"

    exit
}

function press_any_key__func() {
	#Define constants
	local cTIMEOUT_ANYKEY=10

	#Initialize variables
	local keypressed=""
	local tcounter=0

	#Show Press Any Key message with count-down
	echo -e "\r"
	while [[ ${tcounter} -le ${cTIMEOUT_ANYKEY} ]];
	do
		delta_tcounter=$(( ${cTIMEOUT_ANYKEY} - ${tcounter} ))

		echo -e "\rPress (a)bort or any key to continue... (${delta_tcounter}) \c"
		read -N 1 -t 1 -s -r keypressed

		if [[ ! -z "${keypressed}" ]]; then
			if [[ "${keypressed}" == "a" ]] || [[ "${keypressed}" == "A" ]]; then
				exit
			else
				break
			fi
		fi
		
		tcounter=$((tcounter+1))
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



#---SUBROUTINES
docker__load_header__sub() {
    echo -e "\r"
    echo -e "${DOCKER__TITLE_BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__TITLE_BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__init_variables__sub() {
    docker__myContainerId=""
    docker__myContainerId_isFound=""
}

docker_run_specified_exited_container__sub() {
    #Define local constants
    local MENUTITLE="${DOCKER__GENERAL_FG_YELLOW}RUN${DOCKER__NOCOLOR} EXITED ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER${DOCKER__NOCOLOR}"
    local SUBMENUTITLE="Updated ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER${DOCKER__NOCOLOR}-list"

    #Define local message variables
    local readMsg="Choose a ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER-ID${DOCKER__NOCOLOR} (e.g. dfc5e2f3f7ee): "

    local errMsg=${DOCKER__EMPTYSTRING}

    #Show menu-title
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${MENUTITLE}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Get number of containers
    local numof_containers=`docker ps -a | head -n -1 | wc -l`
    if [[ ${numof_containers} -eq 0 ]]; then
        errMsg="=:${DOCKER__ERROR_FG_LIGHTRED}NO *EXITED* CONTAINERS FOUND${DOCKER__NOCOLOR}:="

        echo -e "\r"
        show_centered_string__func "${errMsg}" "${DOCKER__TABLEWIDTH}"
        echo -e "\r"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "\r"

        press_any_key__func

        exit
    else
            docker ps -a
        echo -e "\r"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    fi

    #Show read-input
    while true
    do
        read -p "${readMsg}" docker__myContainerId

        if [[ ! -z ${docker__myContainerId} ]]; then
            docker__myContainerId_isFound=`docker ps -a | awk '{print $1}' | grep -w ${docker__myContainerId} 2>&1`
            if [[ ! -z ${docker__myContainerId_isFound} ]]; then    #match was found
                #Execute command
                docker start ${docker__myContainerId}

                #Show Container's list
                echo -e "\r"
                echo -e "${DOCKER__HORIZONTALLINE}"
                show_centered_string__func "${SUBMENUTITLE}" "${DOCKER__TABLEWIDTH}"
                echo -e "${DOCKER__HORIZONTALLINE}" 
                
                docker ps -a
                
                echo -e "\r"

                exit
            else
                #Update error-message
                errMsg="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: non-existing CONTAINER ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}${docker__myContainerId}${DOCKER__NOCOLOR}"

                #Show error-message
                echo -e "\r"
                echo -e "${errMsg}"

                press_any_key__func

                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_5}"
            fi
        else
            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        fi
    done
}



#MAIN SUBROUTINE
main_sub() {
    docker__load_header__sub

    docker__init_variables__sub

    docker_run_specified_exited_container__sub
}



#Execute main subroutine
main_sub