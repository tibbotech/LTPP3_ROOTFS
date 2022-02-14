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
DOCKER__REPOSITORY_FG_PURPLE=$'\e[30;38;5;93m'

DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'



#---CONSTANTS
DOCKER__TITLE="TIBBO"

#---CHARACTER CHONSTANTS
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
trap CTRL_C_func INT

function CTRL_C_func() {
    echo -e "\r"
    echo -e "\r"
    echo -e "${DOCKER__ERROR_FG_LIGHTRED}Exporting${DOCKER__NOCOLOR} Docker Image Interrupted..."
    echo -e "\r"
    echo -e "Exiting now..."
    echo -e "\r"
    echo -e "\r"

    exit
}

function press_any_key__func() {
	#Define constants
	local ANYKEY_TIMEOUT=3

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



#---SUBROUTINES
docker__load_header__sub() {
    echo -e "\r"
    echo -e "${DOCKER__TITLE_BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__TITLE_BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__load_environment_variables__sub() {
    #Define paths
    docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})
    docker__parent_dir=${docker__current_dir%/*}    #gets one directory up
	if [[ -z ${docker__parent_dir} ]]; then
		docker__parent_dir="${AUTOCOMPLETE__SLASH_CHAR}"
	fi

    docker__first_dir=${docker__parent_dir%/*}    #gets one directory up
    docker__images_dir=${docker__first_dir}/docker/images

    docker__current_folder=`basename ${docker__current_dir}`
    docker__development_tools_folder="development_tools"
    if [[ ${docker__current_folder} != ${docker__development_tools_folder} ]]; then
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}/${docker__development_tools_folder}
    else
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}
    fi

	docker_repolist_tableinfo_filename="docker_repolist_tableinfo.sh"
	docker_repolist_tableinfo_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker_repolist_tableinfo_filename}
}

docker__create_dirs__sub() {
    #Create directory if not present
    if [[ ! -d ${docker__images_dir} ]]; then
        mkdir -p ${docker__images_dir}
    fi
}

docker__save_handler__sub() {
    #Define local constants
    local MENUTITLE="Export an ${DOCKER__IMAGEID_FG_BORDEAUX}Image${DOCKER__NOCOLOR} file"

    #Define local message constants
    local ECHOMSG_IMAGE_LOCATION="${DOCKER__IMAGEID_FG_BORDEAUX}Image${DOCKER__NOCOLOR} Location: "

    #Define local read-input constants
    local READMSG_CHOOSE_A_REPOSITORY_FROM_LIST="Choose a ${DOCKER__REPOSITORY_FG_PURPLE}Repository${DOCKER__NOCOLOR} from list (e.g. ubuntu_buildbin): "
    local READMSG_DO_YOU_WISH_TO_CONTINUE="Do you wish to continue (y/n)? "    #Define local command variables
    local READMSG_PROVIDE_ITS_CORRESPONDING_TAG="Provide its matching ${DOCKER__TAG_FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} (e.g. latest): "

    #Define local variables
    local myRepository=${DOCKER__EMPTYSTRING}
    local myTag=${DOCKER__EMPTYSTRING}
    local myImageId=${DOCKER__EMPTYSTRING}

    #Define local command variables
    local docker_image_ls_cmd="docker image ls"



    #Show Image-list
    docker__show_list_with_menuTitle__func "${MENUTITLE}" "${docker_image_ls_cmd}"

    #Loop
    while true
    do
        read -e -p "${READMSG_CHOOSE_A_REPOSITORY_FROM_LIST}" myRepository
        if [[ ! -z ${myRepository} ]]; then

            myRepository_isFound=`docker image ls | awk '{print $1}' | grep -w "${myRepository}"`
            if [[ ! -z ${myRepository_isFound} ]]; then
                while true
                do        
                    #Find tag belonging to 'myRepository' (Exact Match)
                    myTag=$(docker image ls | grep -w "${myRepository}" | awk '{print $2}')

                    #Request for TAG input
                    read -e -p "${READMSG_PROVIDE_ITS_CORRESPONDING_TAG}" -i ${myTag} myTag
                    if [[ ! -z ${myTag} ]]; then    #input was NOT an EMPTY STRING

                        #check if 'myRepository' and 'myTag' are a matching pair
                        myTag_isFound=`docker image ls | grep -w "${myRepository}" | grep -w "${myTag}"`
                        if [[ ! -z ${myTag_isFound} ]]; then    #match was found
                            #Get Image-ID
                            myImageId=`docker image ls | grep -w "${myRepository}" | grep -w "${myTag}" | awk '{print $3}'`

                            #Compose Image full-path
                            docker__image_fpath="${docker__images_dir}/${myRepository}_${myTag}_${myImageId}.tar.gz"
                            
                            while true
                            do
                                echo -e "${ECHOMSG_IMAGE_LOCATION}"
                                
#-------------------------------This part has been implemented to make sure that the file-location...
#-------------------------------is not shown on the last terminal line
                                echo -e "\r"
                                echo -e "\r"
                                
                                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
#-------------------------------This part has been implemented to make sure that the file-location...
#-------------------------------is not shown on the last terminal line
                                                    
                                echo -e "${DOCKER__FG_LIGHTGREY}"
                                read -e -p "${DOCKER__FOURSPACES}" -i "${docker__image_fpath}" myOutput_fPath
                                echo -e "${DOCKER__NOCOLOR}"

                                if [[ ! -z ${myOutput_fPath} ]]; then
                                    
                                    myOutput_dir=`dirname ${myOutput_fPath}`
                                    if [[ -d ${myOutput_dir} ]]; then
                                        while true
                                        do
                                            read -N1 -p "${READMSG_DO_YOU_WISH_TO_CONTINUE}" myAnswer
                                            if  [[ ${myAnswer} == "y" ]]; then
                                                echo -e "\r"
                                                echo -e "\r"
                                                echo -e "---:${DOCKER__FILES_FG_ORANGE}START${DOCKER__NOCOLOR}: Exporting image '${DOCKER__FG_LIGHTGREY}${myOutput_fPath}${DOCKER__NOCOLOR}'"
                                                echo -e "---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Depending on the image size..."
                                                echo -e "---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: This may take a while..."
                                                echo -e "---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Please wait..."
                                                
                                                docker image save --output ${myOutput_fPath} ${myRepository}:${myTag} > /dev/null

                                                echo -e "---:${DOCKER__FILES_FG_ORANGE}COMPLETED${DOCKER__NOCOLOR}: Exporting image '${DOCKER__FG_LIGHTGREY}${myOutput_fPath}${DOCKER__NOCOLOR}'"
                                                
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
                                        errMsg="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Directory '${DOCKER__FG_LIGHTGREY}${myOutput_dir}${DOCKER__NOCOLOR}' not found"

                                        docker__show_errMsg_without_menuTitle__func "${errMsg}" "${DOCKER__NUMOFLINES_0}"

                                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_7}"  
                                    fi
                                else    #Empty String
                                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_4}"  
                                fi

                                #Answer was 'no'
                                if  [[ ${myAnswer} == "n" ]]; then
                                    break
                                fi
                            done
                        else
                            errMsg="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Un-matched pair ${DOCKER__REPOSITORY_FG_PURPLE}Repository${DOCKER__NOCOLOR} <-> ${DOCKER__TAG_FG_LIGHTPINK}Tag${DOCKER__NOCOLOR}"
                            
                            docker__show_errMsg_without_menuTitle__func "${errMsg}" "${DOCKER__NUMOFLINES_1}"

                            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_5}"            
                        fi
                    else
                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                    fi

                    #Answer was 'no'
                    if  [[ ${myAnswer} == "n" ]]; then
                        break
                    fi
                done
            else
                errMsg="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: repository '${DOCKER__FG_LIGHTGREY}${myOutput_fPath}${DOCKER__NOCOLOR}' not found"

                docker__show_errMsg_without_menuTitle__func "${errMsg}" "${DOCKER__NUMOFLINES_1}"

                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_5}"
            fi 
        else
            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
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
    
    ${docker_repolist_tableinfo_fpath}

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
    docker__load_environment_variables__sub

    docker__load_header__sub

    docker__create_dirs__sub

    docker__save_handler__sub

}



#---EXECUTE
main_sub
