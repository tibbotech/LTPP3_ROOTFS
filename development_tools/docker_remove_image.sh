#!/bin/bash
#---COLOR CONSTANTS
DOCKER__NOCOLOR=$'\e[0;0m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__IMAGEID_FG_BORDEAUX=$'\e[30;38;5;198m'
DOCKER__OUTSIDE_FG_WHITE=$'\e[30;38;5;231m'

DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'
DOCKER__TITLE_BG_LIGHTBLUE=$'\e[30;48;5;45m'
DOCKER__IMAGEID_BG_BORDEAUX=$'\e[30;48;5;198m'
DOCKER__REMARK_BG_ORANGE=$'\e[30;48;5;208m'

#---CONSTANTS
DOCKER__TITLE="TIBBO"

DOCKER__REMOVE_ALL="REMOVE-ALL"

#---CHARACTER CONSTANTS
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
DOCKER__NUMOFLINES_7=7
DOCKER__NUMOFLINES_8=8



#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C__func INT



#---FUNCTIONS
function CTRL_C__func() {
    # echo -e "\r"
    # echo -e "\r"
    # echo -e "Exiting now..."
    echo -e "\r"
    echo -e "\r"

    exit
}

function press_any_key__func() {
	#Define constants
	local ANYKEY_TIMEOUT=10

	#Initialize variables
	local keyPressed=""
	local tCounter=0

	#Show Press Any Key message with count-down
	echo -e "\r"
	while [[ ${tCounter} -le ${ANYKEY_TIMEOUT} ]];
	do
		delta_tcounter=$(( ${ANYKEY_TIMEOUT} - ${tCounter} ))

		echo -e "\rPress (a)bort or any key to continue... (${delta_tcounter}) \c"
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



#---SUBROUTINES
docker__load_header__sub() {
    echo -e "\r"
    echo -e "${DOCKER__TITLE_BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__TITLE_BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__init_variables__sub() {
    docker__myImageId=""
    docker__myImageId_input=""
    docker__myImageId_subst=""
    docker__myImageId_arr=()
    docker__myImageId_item=""
    docker__myImageId_isFound=""
    docker__myAnswer=""
}

docker__remove_specified_images__sub() {
    #Define local constants
    local MENUTITLE="${DOCKER__GENERAL_FG_YELLOW}Remove${DOCKER__NOCOLOR} ${DOCKER__IMAGEID_FG_BORDEAUX}IMAGE(s)${DOCKER__NOCOLOR}"
    local MENUTITLE_UPDATE="Updated ${DOCKER__IMAGEID_FG_BORDEAUX}IMAGE${DOCKER__NOCOLOR}-list"
    local READMSG="***Do you REALLY wish to continue (y/n/q/b)? "

    #Define local variables
    local errMsg=${DOCKER__EMPTYSTRING}
    local numof_images=0

    #Show menu-title
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${MENUTITLE}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Get number of images
    numof_images=`docker image ls | head -n -1 | wc -l`
    if [[ ${numof_images} -eq 0 ]]; then
        #Update error-message
        errMsg="=:${DOCKER__ERROR_FG_LIGHTRED}NO IMAGES FOUND${DOCKER__NOCOLOR}:="

        echo -e "\r"
        show_centered_string__func "${errMsg}" "${DOCKER__TABLEWIDTH}"
        echo -e "\r"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        press_any_key__func

        exit
    else
        docker image ls

        echo -e "\r"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    fi      

    #Start loop    
    while true
    do
        #Input CONTAINERID(s) which you want to REMOVE
        #REMARK: subroutine 'docker_imageId_input__func' will output variable 'docker__myImageId'
        docker_imageId_input__func

        if [[ ! -z ${docker__myImageId} ]]; then
            #Substitute COMMA with SPACE
            docker__myImageId_subst=`echo ${docker__myImageId} | sed 's/,/\ /g'`

            #Convert to Array
            eval "docker__myImageId_arr=(${docker__myImageId_subst})"

            #Go thru each array-item
            echo -e "\r"

            while true
            do
                read -p "${READMSG}" docker__myAnswer
                if [[ ! -z ${docker__myAnswer} ]]; then          
                    if [[ ${docker__myAnswer} == "y" ]]; then
                        if [[ ${docker__myImageId} == ${DOCKER__REMOVE_ALL} ]]; then
                            docker rmi $(docker images -q) 2>&1 > /dev/null
                        else
                            for docker__myImageId_item in "${docker__myImageId_arr[@]}"
                            do 
                                docker__myImageId_isFound=`docker image ls | awk '{print $3}' | grep -w ${docker__myImageId_item}`
                                if [[ ! -z ${docker__myImageId_isFound} ]]; then
                                    docker image rmi -f ${docker__myImageId_item} 2>&1 > /dev/null
                                    echo -e "\r"
                                    echo -e "Removed IMAGE-ID: ${DOCKER__IMAGEID_FG_BORDEAUX}${docker__myImageId_item}${DOCKER__NOCOLOR}"
                                    echo -e "\r"
                                    echo -e "Removing ALL unlinked images"
                                    echo -e "y\n" | docker image prune
                                    echo -e "Removing ALL stopped containers"
                                    echo -e "y\n" | docker container prune
                                else
                                    #Update error-message
                                    errMsg="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Invalid IMAGE-ID: ${DOCKER__IMAGEID_FG_BORDEAUX}${docker__myImageId_item}${DOCKER__NOCOLOR}"

                                    #Show error-message
                                    echo -e "\r"
                                    echo -e "${errMsg}"
                                fi

                                echo -e "\r"
                            done
                        fi

                        #Show menu-title
                        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
                        show_centered_string__func "${MENUTITLE_UPDATE}" "${DOCKER__TABLEWIDTH}"
                        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
                        
                        #Get number of containers
                        numof_images=`docker image ls | head -n -1 | wc -l`
                        if [[ ${numof_images} -eq 0 ]]; then
                            errMsg="=:${DOCKER__ERROR_FG_LIGHTRED}NO IMAGES FOUND${DOCKER__NOCOLOR}:="

                            echo -e "\r"
                            show_centered_string__func "${errMsg}" "${DOCKER__TABLEWIDTH}"
                            echo -e "\r"
                            duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

                            press_any_key__func

                            return
                        else
                            docker image ls

                            echo -e "\r"
                            duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

                            break
                        fi
                    elif [[ ${docker__myAnswer} == "n" ]]; then
                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_8}"

                        break
                    elif [[ ${docker__myAnswer} == "q" ]]; then
                        echo -e "\r"

                        exit
                    elif [[ ${docker__myAnswer} == "b" ]]; then
                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_8}"

                        break
                    else
                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                    fi
                else
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                fi
            done
        else
            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_6}"
        fi
    done
}
function docker_imageId_input__func() {
    #RESET VARIABLE (IMPORTANT)
    if [[ ${docker__myAnswer} != "b" ]]; then
        docker__myImageId=${DOCKER__EMPTYSTRING}
    else
        if [[ ${docker__myImageId} == ${DOCKER__REMOVE_ALL} ]]; then
            docker__myImageId=${DOCKER__EMPTYSTRING}
        fi
    fi

	while true
	do
		echo -e "${DOCKER__REMARK_BG_ORANGE}Remarks:${DOCKER__NOCOLOR}" 
        echo -e "- Remove ALL image-IDs by typing: ${DOCKER__REMOVE_ALL}"
		echo -e "- Multiple image-IDs can be removed"
		echo -e "- Comma-separator will be auto-appended (e.g. 0f7478cf7cab,5f1b8726ca97)"
		echo -e "- [On an Empty Field] press ENTER to stop input"
		echo -e "${DOCKER__IMAGEID_BG_BORDEAUX}Remove the following ${DOCKER__OUTSIDE_FG_WHITE}image-IDs${DOCKER__NOCOLOR}:${DOCKER__IMAGEID_BG_BORDEAUX}${DOCKER__OUTSIDE_FG_WHITE}${docker__myImageId}${DOCKER__NOCOLOR}"
		read -p "Paste your input (here): " docker__myImageId_input

		if [[ -z ${docker__myImageId_input} ]]; then
			moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

			break
        elif [[ ${docker__myImageId_input} == ${DOCKER__REMOVE_ALL} ]]; then
            docker__myImageId="${docker__myImageId_input}"

			break
		else
			if [[ -z ${docker__myImageId} ]]; then
				docker__myImageId="${docker__myImageId_input}"
			else
				docker__myImageId="${docker__myImageId},${docker__myImageId_input}"
			fi

			moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_7}"
		fi
	done
}


main_sub() {
    docker__load_header__sub

    docker__init_variables__sub

    docker__remove_specified_images__sub
}


#Execute main subroutine
main_sub
