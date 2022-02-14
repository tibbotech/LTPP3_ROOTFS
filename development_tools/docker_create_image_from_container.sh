#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
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
DOCKER__REDO="r"

#---MENU CONSTANTS
DOCKER__A_ABORT="${DOCKER__FOURSPACES}b. Back"
DOCKER__CTRL_C_QUIT="${DOCKER__FOURSPACES}Quit (Ctrl+C)"

DOCKER_NOT_FOUND="(${DOCKER__ERROR_FG_LIGHTRED}not found${DOCKER__NOCOLOR})"

#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C__sub INT



#---FUNCTIONS
function press_any_key__func() {
	#Define constants
	local ANYKEY_TIMEOUT=10

	#Initialize variables
	local keypressed=""
	local tcounter=0

	#Show Press Any Key message with count-down
	echo -e "\r"
	while [[ ${tcounter} -le ${ANYKEY_TIMEOUT} ]];
	do
		delta_tcounter=$(( ${ANYKEY_TIMEOUT} - ${tcounter} ))

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

function exit__func() {
    echo -e "\r"
    echo -e "\r"
    # echo -e ${DOCKER__EXITING_NOW}
    # echo -e "\r"
    # echo -e "\r"

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

docker__environmental_variables__sub() {
	# docker__current_dir=`pwd`
	docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})	#/repo/LTPP3_ROOTFS/development_tools
	docker__parent_dir=${docker__current_dir%/*}    #gets one directory up (/repo/LTPP3_ROOTFS)
    if [[ -z ${docker__parent_dir} ]]; then
        docker__parent_dir="${DOCKER__SLASH}"
    fi
	docker__current_folder=`basename ${docker__current_dir}`

    docker__development_tools_folder="development_tools"
    if [[ ${docker__current_folder} != ${docker__development_tools_folder} ]]; then
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}/${docker__development_tools_folder}
    else
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}
    fi

    docker__containerlist_tableinfo_filename="docker_containerlist_tableinfo.sh"
    docker__containerlist_tableinfo_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__containerlist_tableinfo_filename}
	docker_repolist_tableinfo_filename="docker_repolist_tableinfo.sh"
	docker_repolist_tableinfo_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker_repolist_tableinfo_filename}
}

docker__load_header__sub() {
    echo -e "\r"
    echo -e "${DOCKER__TITLE_BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__TITLE_BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__create_image_of_specified_container__sub() {
    #Define local message constants
    local MENUTITLE="Create an ${DOCKER__IMAGEID_FG_BORDEAUX}Image${DOCKER__NOCOLOR} from a ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}"
    local MENUTITLE_CURRENT_IMAGE_LIST="Current ${DOCKER__IMAGEID_FG_BORDEAUX}Image${DOCKER__NOCOLOR}-list"
    local MENUTITLE_UPDATED_IMAGE_LIST="Updated ${DOCKER__IMAGEID_FG_BORDEAUX}Image${DOCKER__NOCOLOR}-list"
    local READMSG_CHOOSE_A_CONTAINERID="Choose a ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Container-ID${DOCKER__NOCOLOR} (e.g. dfc5e2f3f7ee): "
    local READMSG_DO_YOU_WISH_TO_CONTINUE="Do you wish to continue (y/n/r)? "
    local READMSG_NEW_REPOSITORY_NAME="${DOCKER__GENERAL_FG_YELLOW}New${DOCKER__NOCOLOR} ${DOCKER__NEW_REPOSITORY_FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR}'s name (e.g. ubuntu_buildbin_NEW): "
    local READMSG_NEW_REPOSITORY_TAG="Its ${DOCKER__GENERAL_FG_YELLOW}New${DOCKER__NOCOLOR} corresponding ${DOCKER__TAG_FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} (e.g. test): "

    local ERRMSG_NO_CONTAINERS_FOUND="=:${DOCKER__ERROR_FG_LIGHTRED}NO CONTAINERS FOUND${DOCKER__NOCOLOR}:="
    local ERRMSG_CHOSEN_REPO_PAIR_ALREADY_EXISTS="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: chosen ${DOCKER__NEW_REPOSITORY_FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR}:${DOCKER__TAG_FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} pair already exist"

    #Define local message variables
    local errMsg=${EMPTYSTRING}

    #Define local command variables
    local docker_image_ls_cmd="docker image ls"
    local docker_ps_a_cmd="docker ps -a"
 
    #Define local variables
    local myRepository_isFound=${DOCKER__EMPTYSTRING}
    local myTag_isFound=${DOCKER__EMPTYSTRING}



#---Show Docker Container's List
    #Get number of containers
    local numof_containers=`docker ps -a | head -n -1 | wc -l`
    if [[ ${numof_containers} -eq 0 ]]; then
        docker__show_errMsg_with_menuTitle__func "${MENUTITLE}" "${ERRMSG_NO_CONTAINERS_FOUND}"
    else
        docker__show_list_with_menuTitle__func "${MENUTITLE}" "${docker_ps_a_cmd}"
    fi

    #Add empty line
    # echo -e "\r"

    while true
    do
        #Provide a Container-ID from which you want to create an Image
        read -e -p "${READMSG_CHOOSE_A_CONTAINERID}" mycontainerid
        if [[ ! -z ${mycontainerid} ]]; then    #input is NOT an EMPTY STRING

            #Check if 'mycontainerid' is found in ' docker ps -a'
            mycontainerid_isFound=`docker ps -a | awk '{print $1}' | grep -w ${mycontainerid}`
            if [[ ! -z ${mycontainerid_isFound} ]]; then    #match was found
                #Get number of images
                local numof_images=$((docker_image_ls_lines-1))

                #Show Docker Image List
                echo -e "\r"

                if [[ ${numof_images} -eq 0 ]]; then
                    docker__show_errMsg_with_menuTitle__func "${MENUTITLE_CURRENT_IMAGE_LIST}" "${ERRMSG_NO_CONTAINERS_FOUND}"
                else
                    docker__show_list_with_menuTitle__func "${MENUTITLE_CURRENT_IMAGE_LIST}" "${docker_image_ls_cmd}"
                fi  

                while true
                do
                    #Provide a Repository for this new image
                    read -e -p "${READMSG_NEW_REPOSITORY_NAME}" myrepository_input
                    if [[ ! -z ${myrepository_input} ]]; then   #input was NOT an Empty String
                        
                        while true
                        do
                            #Provide a Tag for this new image
                            read -e -p "${READMSG_NEW_REPOSITORY_TAG}" mytag_input
                            if [[ ! -z ${mytag_input} ]]; then   #input is NOT an Empty String

                                myRepository_isFound=`docker image ls | awk '{print $1}' | grep -w "${myrepository_input}"`
                                myTag_isFound=`docker image ls | awk '{print $2}' | grep -w "${mytag_input}"`

                                if [[ -z ${myRepository_isFound} ]] || [[ -z ${myTag_isFound} ]]; then    #match was NOT found
                                    while true
                                    do
                                        #Add an empty-line
                                        echo -e "\r"

                                        #Show read-input message
                                        read -N1 -p "${READMSG_DO_YOU_WISH_TO_CONTINUE}" docker__myanswer
                                        
                                        #Validate read-input answer
                                        if [[ ${docker__myanswer} == ${DOCKER__YES} ]]; then
                                            #Create Docker Image based on chosen Container-ID                
                                            docker commit ${mycontainerid} ${myrepository_input}:${mytag_input}

                                            #Show Docker Image List
                                            echo -e "\r"

                                            docker__show_list_with_menuTitle__func "${MENUTITLE_UPDATED_IMAGE_LIST}" "${docker_image_ls_cmd}"
                                            
                                            echo -e "\r"
                                            echo -e "\r"

                                            exit

                                        elif [[ ${docker__myanswer} == ${DOCKER__NO} ]]; then
                                            exit__func
                                        elif [[ ${docker__myanswer} == ${DOCKER__REDO} ]]; then
                                            break
                                        elif [[ ${docker__myanswer} == ${DOCKER__QUIT} ]]; then
                                            exit__func   
                                        else
                                            if [[ ${docker__myanswer} != "${DOCKER__ENTER}" ]]; then
                                                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                                                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"    
                                            else
                                                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"              
                                            fi                                                                                                                                    
                                        fi
                                    done
                                else
                                    docker__show_errMsg_without_menuTitle__func "${ERRMSG_CHOSEN_REPO_PAIR_ALREADY_EXISTS}"

                                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_6}"

                                    break
                                fi
                            else
                                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                            fi

                            #Answer 'r' was given in the LAST while-loop
                            if [[ ${docker__myanswer} == ${DOCKER__REDO} ]]; then
                                break
                            fi
                        done     
                    else    #input was an Empty String
                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                    fi

                    #Answer 'r' was given in the LAST while-loop
                    if [[ ${docker__myanswer} == ${DOCKER__REDO} ]]; then
                        docker__show_list_with_menuTitle__func "${MENUTITLE}" "${docker_ps_a_cmd}"
                        
                        break
                    fi
                done
            else    #NO match was found
                errMsg="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Container-ID '${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}${mycontainerid}${DOCKER__NOCOLOR}' Not Found"

                docker__show_errMsg_without_menuTitle__func "${errMsg}"

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
    
    if [[ ${dockerCmd} == ${docker_ps_a_cmd} ]]; then
        ${docker__containerlist_tableinfo_fpath}
    else
        ${docker_repolist_tableinfo_fpath}
    fi

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



#---MAIN SUBROUTINE
main_sub() {
    docker__environmental_variables__sub

    docker__load_header__sub

    docker__create_image_of_specified_container__sub
}



#---EXECUTE
main_sub
