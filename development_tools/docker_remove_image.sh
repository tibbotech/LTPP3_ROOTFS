#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---COLOR CONSTANTS
DOCKER__NOCOLOR=$'\e[0;0m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__IMAGEID_FG_BORDEAUX=$'\e[30;38;5;198m'
DOCKER__REPOSITORY_FG_PURPLE=$'\e[30;38;5;93m'
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

DOCKER__ENTER=$'\x0a'

DOCKER__ONESPACE=" "
DOCKER__TWOSPACES=${DOCKER__ONESPACE}${DOCKER__ONESPACE}
DOCKER__FOURSPACES=${DOCKER__TWOSPACES}${DOCKER__TWOSPACES}

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

#---MENU CONSTANTS
DOCKER__CTRL_C_QUIT="${DOCKER__FOURSPACES}Quit (Ctrl+C)"



#---FUNCTIONS
#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C__func INT

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

function moveDown_and_cleanLines__func() {
    #Input args
    local numOf_lines_toBeCleared=${1}

    #Clear lines
    local numOf_lines_cleared=1
    while [[ ${numOf_lines_cleared} -le ${numOf_lines_toBeCleared} ]]
    do
        tput cud1	#move UP with 1 line
        tput el1	#clear until the END of line

        numOf_lines_cleared=$((numOf_lines_cleared+1))  #increment by 1
    done
}


#---SUBROUTINES
CTRL_C__sub() {
    echo -e "\r"
    echo -e "\r"
    # echo -e "Exiting now..."
    # echo -e "\r"
    # echo -e "\r"
    
    exit
}

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
    #Define local message constants
    local MENUTITLE="Remove ${DOCKER__IMAGEID_FG_BORDEAUX}Image${DOCKER__NOCOLOR}/${DOCKER__REPOSITORY_FG_PURPLE}Repository${DOCKER__NOCOLOR}"
    local MENUTITLE_UPDATED_IMAGE_LIST="Updated ${DOCKER__IMAGEID_FG_BORDEAUX}Image${DOCKER__NOCOLOR}-list"
    local READMSG_DO_YOU_REALLY_WISH_TO_CONTINUE="***Do you REALLY wish to continue (y/n/q/b)? "
    local ERRMSG_NO_IMAGES_FOUND="=:${DOCKER__ERROR_FG_LIGHTRED}NO IMAGES FOUND${DOCKER__NOCOLOR}:="

    #Define local message variables
    local errMsg=${DOCKER__EMPTYSTRING}
    local numof_images=0

    #Define local command variables
    local docker_image_ls_cmd="docker image ls"



    #Show Docker Image List
    #Get number of images
    local numof_images=`docker image ls | head -n -1 | wc -l`
    if [[ ${numof_images} -eq 0 ]]; then
        docker__show_errMsg_with_menuTitle__func "${MENUTITLE}" "${ERRMSG_NO_IMAGES_FOUND}"
    else
        docker__show_list_with_menuTitle__func "${MENUTITLE}" "${docker_image_ls_cmd}"
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
                read -N1 -p "${READMSG_DO_YOU_REALLY_WISH_TO_CONTINUE}" docker__myAnswer
                if [[ ! -z ${docker__myAnswer} ]]; then          
                    if [[ ${docker__myAnswer} == "y" ]]; then
                        if [[ ${docker__myImageId} == ${DOCKER__REMOVE_ALL} ]]; then
                            docker rmi $(docker images -q)
                        else
                            for docker__myImageId_item in "${docker__myImageId_arr[@]}"
                            do 
                                docker__myImageId_isFound=`docker image ls | awk '{print $3}' | grep -w ${docker__myImageId_item}`
                                if [[ ! -z ${docker__myImageId_isFound} ]]; then
                                    docker image rmi -f ${docker__myImageId_item}

                                    #Check if removing the image was successful
                                    docker__myImageId_isFound=`docker image ls | awk '{print $3}' | grep -w ${docker__myImageId_item}`
                                    if [[ -z ${docker__myImageId_isFound} ]]; then
                                        echo -e "\r"
                                        echo -e "Successfully Removed Image-ID: ${DOCKER__IMAGEID_FG_BORDEAUX}${docker__myImageId_item}${DOCKER__NOCOLOR}"
                                        echo -e "\r"
                                        echo -e "Removing ALL unlinked images"
                                        echo -e "y\n" | docker image prune
                                        echo -e "Removing ALL stopped containers"
                                        echo -e "y\n" | docker container prune
                                    else
                                        echo -e "\r"
                                        echo -e "Could *NOT* remove Image-ID: ${DOCKER__IMAGEID_FG_BORDEAUX}${docker__myImageId_item}${DOCKER__NOCOLOR}"
                                        echo -e "\r"
                                    fi
                                else
                                    #Update error-message
                                    errMsg="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Invalid Image-ID '${DOCKER__IMAGEID_FG_BORDEAUX}${docker__myImageId_item}${DOCKER__NOCOLOR}'"

                                    #Show error-message
                                    echo -e "\r"

                                    docker__show_errMsg_without_menuTitle__func "${errMsg}"

                                fi

                                echo -e "\r"
                            done
                        fi

                        #Show Updated Docker Image-list
                        local numof_images=`docker image ls | head -n -1 | wc -l`
                        if [[ ${numof_images} -eq 0 ]]; then
                            docker__show_errMsg_with_menuTitle__func "${MENUTITLE_UPDATED_IMAGE_LIST}" "${ERRMSG_NO_IMAGES_FOUND}"
                        
                            exit
                        else
                            docker__show_list_with_menuTitle__func "${MENUTITLE_UPDATED_IMAGE_LIST}" "${docker_image_ls_cmd}"
                        
                            break
                        fi 
                    elif [[ ${docker__myAnswer} == "n" ]]; then
                        echo -e "\r"    #mandatory to add this empty-line

                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_8}"

                        break
                    elif [[ ${docker__myAnswer} == "q" ]]; then
                        echo -e "\r"

                        exit
                    elif [[ ${docker__myAnswer} == "b" ]]; then
                        echo -e "\r"    #mandatory to add this empty-line

                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_8}"

                        break
                    else
                        if [[ ${docker__myAnswer} != "${DOCKER__ENTER}" ]]; then
                            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                        else
                            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                        fi
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
		echo -e "- [On an Empty Field] press ENTER to confirm to-be-deleted entries"
		echo -e "${DOCKER__IMAGEID_BG_BORDEAUX}Remove the following ${DOCKER__OUTSIDE_FG_WHITE}image-IDs${DOCKER__NOCOLOR}:${DOCKER__IMAGEID_BG_BORDEAUX}${DOCKER__OUTSIDE_FG_WHITE}${docker__myImageId}${DOCKER__NOCOLOR}"
		read -e -p "Paste your input (here): " docker__myImageId_input

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

function docker__show_errMsg_with_menuTitle__func() {
    #Input args
    local menuTitle=${1}
    local errMsg=${2}

    #Show error-message
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${menuTitle}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    
    echo -e "\r"
    show_centered_string__func "${errMsg}" "${DOCKER__TABLEWIDTH}"
    echo -e "\r"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "\r"

    press_any_key__func

    CTRL_C__sub
}

function docker__show_errMsg_without_menuTitle__func() {
    #Input args
    local errMsg=${1}

    echo -e "\r"
    echo -e "${errMsg}"

    press_any_key__func
}



main_sub() {
    docker__load_header__sub

    docker__init_variables__sub

    docker__remove_specified_images__sub
}


#Execute main subroutine
main_sub
