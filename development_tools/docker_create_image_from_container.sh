#!/bin/bash
#---COLOR CONSTANTS
DOCKER__NOCOLOR=$'\e[0;0m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__FG_PURPLERED=$'\e[30;38;5;198m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__IMAGEID_FG_BORDEAUX=$'\e[30;38;5;198m'
DOCKER__REPOSITORY_FG_PURPLE=$'\e[30;38;5;93m'
DOCKER__NEW_REPOSITORY_FG_BRIGHTLIGHTPURPLE=$'\e[30;38;5;147m'
DOCKER__CONTAINER_FG_BRIGHTPRUPLE=$'\e[30;38;5;141m'
DOCKER__TAG_FG_LIGHTPINK=$'\e[30;38;5;218m'

DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'
DOCKER__TITLE_BG_LIGHTBLUE=$'\e[30;48;5;45m'

#---CONSTANTS
DOCKER__TITLE="TIBBO"

DOCKER__LATEST="latest"
DOCKER__EXITING_NOW="Exiting now..."

#---CHARACTER CHONSTANTS
DOCKER__DASH="-"
DOCKER__EMPTYSTRING=""
DOCKER__ENTER=$'\x0a'

DOCKER__ONESPACE=" "
DOCKER__TWOSPACES=${DOCKER__ONESPACE}${DOCKER__ONESPACE}
DOCKER__FOURSPACES=${DOCKER__TWOSPACES}${DOCKER__TWOSPACES}

#---NUMERIC CONSTANTS
DOCKER__NINE=9
DOCKER__TABLEWIDTH=70

DOCKER__NUMOFLINES_1=1
DOCKER__NUMOFLINES_2=2
DOCKER__NUMOFLINES_3=3
DOCKER__NUMOFLINES_4=4
DOCKER__NUMOFLINES_5=5
DOCKER__NUMOFLINES_6=6

#---READ-INPUT CONSTANTS
DOCKER__YES="y"
DOCKER__NO="n"
DOCKER__QUIT="q"
DOCKER__BACK="b"

#---MENU CONSTANTS
DOCKER__A_ABORT="${DOCKER__FOURSPACES}b. Back"
DOCKER__CTRL_C_QUIT="${DOCKER__FOURSPACES}Quit (Ctrl+C)"

DOCKER_NOT_FOUND="(${DOCKER__ERROR_FG_LIGHTRED}not found${DOCKER__NOCOLOR})"

#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C__sub INT



#---FUNCTIONS
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

docker__create_image_of_specified_container__sub() {
    #Define local constants
    local MENUTITLE="${DOCKER__GENERAL_FG_YELLOW}Create${DOCKER__NOCOLOR} Docker ${DOCKER__IMAGEID_FG_BORDEAUX}IMAGE${DOCKER__NOCOLOR} from ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER${DOCKER__NOCOLOR}"
    local SUBMENUTITLE="Current ${DOCKER__IMAGEID_FG_BORDEAUX}IMAGE${DOCKER__NOCOLOR}-list"
    local SUBSUBMENUTITLE="Updated ${DOCKER__IMAGEID_FG_BORDEAUX}IMAGE${DOCKER__NOCOLOR}-list"

    local READMSG_CHOOSE_A_CONTAINERID="Choose a ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER-ID${DOCKER__NOCOLOR} (e.g. dfc5e2f3f7ee): "
    local READMSG_NEW_REPOSITORY_NAME="${DOCKER__GENERAL_FG_YELLOW}NEW${DOCKER__NOCOLOR} ${DOCKER__NEW_REPOSITORY_FG_BRIGHTLIGHTPURPLE}REPOSITORY${DOCKER__NOCOLOR}'s name (e.g. ubuntu_buildbin_NEW): "
    local READMSG_NEW_REPOSITORY_TAG="${DOCKER__GENERAL_FG_YELLOW}NEW${DOCKER__NOCOLOR} ${DOCKER__TAG_FG_LIGHTPINK}TAG${DOCKER__NOCOLOR} (e.g. test) for this ${DOCKER__GENERAL_FG_YELLOW}NEW${DOCKER__NOCOLOR} ${DOCKER__IMAGEID_FG_BORDEAUX}IMAGE${DOCKER__NOCOLOR}: "

    #Define local variables
    local errMsg=${EMPTYSTRING}
 

#---Show Docker Image List
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${MENUTITLE}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Get number of containers
    local numof_containers=`docker ps -a | head -n -1 | wc -l`
    if [[ ${numof_containers} -eq 0 ]]; then
        errMsg="=:${DOCKER__ERROR_FG_LIGHTRED}NO CONTAINERS FOUND${DOCKER__NOCOLOR}:="

        echo -e "\r"
        show_centered_string__func "${errMsg}" "${DOCKER__TABLEWIDTH}"
        echo -e "\r"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        press_any_key__func

        CTRL_C__sub
    else
        docker ps -a
        
        echo -e "\r"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__CTRL_C_QUIT}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    fi

    #Add empty line
    # echo -e "\r"

    while true
    do
        #Provide a CONTAINER-ID from which you want to create an Image
        read -p "${READMSG_CHOOSE_A_CONTAINERID}" mycontainerid
        if [[ ! -z ${mycontainerid} ]]; then    #input is NOT an EMPTY STRING

            #Check if 'mycontainerid' is found in ' docker ps -a'
            mycontainerid_isFound=`docker ps -a | awk '{print $1}' | grep -w ${mycontainerid}`
            if [[ ! -z ${mycontainerid_isFound} ]]; then    #match was found
                #Get number of images
                local numof_images=$((docker_image_ls_lines-1))

                #Show Docker Image List
                echo -e "\r"
                duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
                show_centered_string__func "${SUBMENUTITLE}" "${DOCKER__TABLEWIDTH}"
                duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

                if [[ ${numof_images} -eq 0 ]]; then
                    errMsg="=:${DOCKER__ERROR_FG_LIGHTRED}NO CONTAINERS FOUND${DOCKER__NOCOLOR}:="

                    echo -e "\r"
                    show_centered_string__func "${errMsg}" "${DOCKER__TABLEWIDTH}"
                    echo -e "\r"
                    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
                    echo -e "\r"

                    exit
                else
                        docker image ls
                    echo -e "\r"
                    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
                fi  

                while true
                do
                    #Provide a REPOSITORY for this new image
                    read -p "${READMSG_NEW_REPOSITORY_NAME}" myrepository_input
                    if [[ ! -z ${myrepository_input} ]]; then   #input was NOT an Empty String
                        
                        while true
                        do
                            #Provide a TAG for this new image
                            read -p "${READMSG_NEW_REPOSITORY_TAG}" mytag_input
                            if [[ ! -z ${mytag_input} ]]; then   #input is NOT an Empty String

                                myrepository_with_this_tag_isUnique=`docker image ls | grep -w "${myrepository_input}" | grep -w "${mytag_input}"`    #check if 'myrepository_input' AND 'mytag_input' is found in 'docker image ls'

                                if [[ -z ${myrepository_with_this_tag_isUnique} ]]; then    #match was NOT found
                                    #Create Docker Image based on chosen Container-ID                
                                    docker commit ${mycontainerid} ${myrepository_input}:${mytag_input} 2>&1 > /dev/null

                                    #Show Docker Image List
                                    echo -e "\r"
                                    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
                                    show_centered_string__func "${SUBSUBMENUTITLE}" "${DOCKER__TABLEWIDTH}"
                                    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"        
                                    
                                    docker image ls
                                    
                                    echo -e "\r"

                                    exit
                                else
                                    errMsg="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: chosen ${DOCKER__NEW_REPOSITORY_FG_BRIGHTLIGHTPURPLE}REPOSITORY${DOCKER__NOCOLOR}:${DOCKER__TAG_FG_LIGHTPINK}TAG${DOCKER__NOCOLOR} pair already exist"
                                    echo -e "\r"
                                    echo -e "${errMsg}"

                                    press_any_key__func

                                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_6}"

                                    break
                                fi
                            else
                                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                            fi
                        done     
                    else    #input was an Empty String
                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                    fi
                done
            else    #NO match was found
                echo -e "\r"
                echo -e "${READMSG_CHOOSE_A_CONTAINERID} ${DOCKER_NOT_FOUND}"

                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_5}"               
            fi
        else
            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        fi
    done
}



#---MAIN SUBROUTINE
main_sub() {
    docker__load_header__sub

    docker__create_image_of_specified_container__sub
}



#---EXECUTE
main_sub
