#!/bin/bash
#---COLOR CONSTANTS
DOCKER__NOCOLOR=$'\e[0m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__FG_PURPLERED=$'\e[30;38;5;198m'
DOCKER__SUCCESS_FG_LIGHTGREEN=$'\e[1;32m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__TITLE_FG_LIGHTBLUE=$'\e[30;38;5;45m'
DOCKER__FG_DARKBLUE=$'\e[30;38;5;33m'
DOCKER__IMAGEID_FG_BORDEAUX=$'\e[30;38;5;198m'

DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'
DOCKER__FILES_FG_ORANGE=$'\e[30;38;5;215m'
DOCKER__DIRS_FG_VERYLIGHTORANGE=$'\e[30;38;5;223m'
DOCKER__TITLE_BG_LIGHTBLUE=$'\e[30;48;5;45m'



#---CONSTANTS
DOCKER__TITLE="TIBBO"

DOCKER__EXITING_NOW="Exiting now..."

DOCKER__LATEST="latest"
DOCKER__STATUS="STATUS"

#---CHAR CONSTANTS
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

#---READ-INPUT CONSTANTS
DOCKER__YES="y"
DOCKER__NO="n"
DOCKER__QUIT="q"
DOCKER__BACK="b"

#---MENU CONSTANTS
DOCKER__CTRL_C_QUIT="${DOCKER__FOURSPACES}Quit (Ctrl+C)"
DOCKER__Q_QUIT="${DOCKER__FOURSPACES}q. Quit (Ctrl+C)"



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
    # echo -e "${DOCKER__EXITING_NOW}"
    # echo -e "\r"
    # echo -e "\r"

    exit
}

docker__load_environment_variables__sub() {
    docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})
    docker__parent_dir=${docker__current_dir%/*}    #gets one directory up
    if [[ -z ${docker__parent_dir} ]]; then
        docker__parent_dir="${DOCKER__SLASH_CHAR}"
    fi
    #Define local variables
    docker_current_script_filename=`basename $0`

    docker__my_LTPP3_ROOTFS_docker_dir=${docker__parent_dir}/docker
    docker__my_LTPP3_ROOTFS_docker_dockerfiles_dir=${docker__my_LTPP3_ROOTFS_docker_dir}/dockerfiles
}

docker__init_variables__sub() {
    docker__dockerFile_fpath=""
    docker__dockerFile_filename=""
}

docker__show_dockerList_files__sub() {
    #Define local constants
    local MENUTITLE="${DOCKER__GENERAL_FG_YELLOW}Create${DOCKER__NOCOLOR} an ${DOCKER__IMAGEID_FG_BORDEAUX}Image${DOCKER__NOCOLOR} using a ${DOCKER__FG_DARKBLUE}docker-file${DOCKER__NOCOLOR}"

    #Define local variables
    local listOf_dockerFileFpaths_string=""
    local listOf_dockerFileFpaths_arr=()
    local listOf_dockerFileFpaths_arrItem=""
    local extract_filename=""
    local seqnum=0

    #Define local message variables
    local errMsg1="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: No files found at location:"
    local errMsg2="${DOCKER__FOURSPACES}${DOCKER__DIRS_FG_VERYLIGHTORANGE}${docker__my_LTPP3_ROOTFS_docker_dockerfiles_dir}${DOCKER__NOCOLOR}"
    local errMsg3="***${DOCKER__FG_PURPLERED}MANDATORY${DOCKER__NOCOLOR}: All ${DOCKER__GENERAL_FG_YELLOW}dockerfile-list${DOCKER__NOCOLOR} files should be put in this directory"
    local locationMsg_dockerfiles="${DOCKER__FOURSPACES}${DOCKER__DIRS_FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR}: ${docker__my_LTPP3_ROOTFS_docker_dockerfiles_dir}"

    #Define local read-input variables
    local readInput_msg="Choose a file: "


    #Get all files at the specified location
    listOf_dockerFileFpaths_string=`find ${docker__my_LTPP3_ROOTFS_docker_dockerfiles_dir} -maxdepth 1 -type f | sort`
    if [[ -z ${listOf_dockerFileFpaths_string} ]]; then
        echo -e "\r"
        echo -e "${errMsg1}"
        echo -e "${errMsg2}"
        echo -e "\r"
        echo -e "${errMsg3}"
        echo -e "\r"

        exit 99
    fi

    #Convert string to array (with space delimiter)
    listOf_dockerFileFpaths_arr=(${listOf_dockerFileFpaths_string})


    #Show menu-title
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${MENUTITLE}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    for listOf_dockerFileFpaths_arrItem in "${listOf_dockerFileFpaths_arr[@]}"
    do
        #increment sequence-number
        seqnum=$((seqnum+1))

        #Get filename only
        extract_filename=`basename ${listOf_dockerFileFpaths_arrItem}`  
    
        #Show filename
        echo -e "${DOCKER__FOURSPACES}${seqnum}. ${extract_filename}"
    done

    echo -e "\r"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${locationMsg_dockerfiles}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${DOCKER__Q_QUIT}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Read-input handler
    while true
    do
        #Show read-input
        if [[ ${seqnum} -le ${DOCKER__NINE} ]]; then    #seqnum <= 9
            read -N1 -p "${readInput_msg} " mychoice
        else    #seqnum > 9
            read -p "${readInput_msg} " mychoice
        fi

        #Check if 'mychoice' is a numeric value
        if [[ ${mychoice} =~ [1-90q] ]]; then
            #check if 'mychoice' is one of the numbers shown in the overview...
            #... AND 'mychoice' is NOT '0'
            if [[ ${mychoice} == ${DOCKER__QUIT} ]]; then
                exit__func
            elif [[ ${mychoice} -le ${seqnum} ]] && [[ ${mychoice} -ne 0 ]]; then
                echo -e "\r"    #print an empty line

                break   #exit loop
            else
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"    
            fi
        else
            if [[ ${mychoice} != "${DOCKER__ENTER}" ]]; then
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"   
            else
                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"             
            fi
        fi
    done

    #Since arrays start with index=0, deduct 'mychoice' value by '1'
    index=$((mychoice-1))

    #Extract the chosen file from array and assign to the GLOBAL variable 'docker__dockerFile_fpath'
    docker__dockerFile_fpath=${listOf_dockerFileFpaths_arr[index]}
}

docker__create_image_handler__sub() {
    if [[ -f ${docker__dockerFile_fpath} ]]; then
        docker__create_image__func ${docker__dockerFile_fpath}
    else
        echo -e "\r"
        echo -e "***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: File '${DOCKER__FG_DARKBLUE}${docker__dockerFile_fpath}${DOCKER__NOCOLOR}' does ${DOCKER__ERROR_FG_LIGHTRED}Not${DOCKER__NOCOLOR} exist"
        echo -e "\r"       
    fi
}
function docker__create_image__func() {
    #Input args
    local dockerfile_fpath=${1}

    #Define local constants
    local MENUTITLE_UPDATED_CONTAINER_LIST="Updated ${DOCKER__IMAGEID_FG_BORDEAUX}Image${DOCKER__NOCOLOR}-list"
    local GREP_PATTERN="LABEL repository:tag"

    #Define local message variables
    local statusMsg="---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Creating image..."

    #Define local command variables
    local docker_ps_a_cmd="docker ps -a"
    


    #Get REPOSITORY:TAG from dockerfile
    local dockerfile_repository_tag=`egrep -w "${GREP_PATTERN}" ${dockerfile_fpath} | cut -d"\"" -f2`

    #Check if 'dockerfile_repository_tag' is an EMPTY STRING
    if [[ -z ${dockerfile_repository_tag} ]]; then
        dockerfile_repository_tag="${dockerfile}:${DOCKER__LATEST}"
    fi

    #Execute Docker command
    echo -e "\r"
    echo -e "${statusMsg}"
    echo -e "\r"

    docker build --tag ${dockerfile_repository_tag} - < ${dockerfile_fpath} #with REPOSITORY:TAG
    
    #Validate executed command
    docker__validate_exitCode__func

    #Print docker image list
    echo -e "\r"

    docker__show_list_with_menuTitle__func "${MENUTITLE_UPDATED_CONTAINER_LIST}" "${docker_ps_a_cmd}"
    
    echo -e "\r"
    echo -e "\r"
}
function docker__validate_exitCode__func() {
    #Define local message variables
    local successMsg="---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Image was created ${DOCKER__SUCCESS_FG_LIGHTGREEN}successfully${DOCKER__NOCOLOR}..."
    local errMsg="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Unable to create Image"

    #Get exit-code of the latest executed command
    exit_code=$?
    if [[ ${exit_code} -eq 0 ]]; then
        echo -e "\r"
        echo -e "${successMsg}"
        echo -e "\r"

    else
        echo -e "\r"
        echo -e "${errMsg}"
        echo -e "\r"

        # echo -e "${DOCKER__EXITING_NOW}"
        # echo -e "\r"
        # echo -e "\r"

        exit
    fi
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



#---MAIN SUBROUTINE
main_sub() {
    docker__load_environment_variables__sub

    docker__init_variables__sub

    docker__show_dockerList_files__sub

    docker__create_image_handler__sub
}



#---EXECUTE
main_sub
