#!/bin/bash
#---COLOR CONSTANTS
DOCKER__NOCOLOR=$'\e[0;0m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__REPOSITORY_FG_PURPLE=$'\e[30;38;5;93m'
DOCKER__CONTAINER_FG_BRIGHTPRUPLE=$'\e[30;38;5;141m'
DOCKER__HOST_FG_GREEN85=$'\e[30;38;5;85m'
DOCKER__DIRS_FG_VERYLIGHTORANGE=$'\e[30;38;5;223m'
DOCKER__FILES_FG_ORANGE=$'\e[30;38;5;215m'

DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'

#---CONSTANTS
DOCKER__TITLE="TIBBO"

#---CHARACTER CHONSTANTS
DOCKER__ASTERISK="\*"
DOCKER__DASH="-"
DOCKER__SLASH="/"
DOCKER__ESCAPE_SLASH="\/"

DOCKER__EMPTYSTRING=""

DOCKER__ONESPACE=" "
DOCKER__TWOSPACES=${DOCKER__ONESPACE}${DOCKER__ONESPACE}
DOCKER__FOURSPACES=${DOCKER__TWOSPACES}${DOCKER__TWOSPACES}

#---NUMERIC CONSTANTS
DOCKER__LISTVIEW_NUMOFROWS=20
DOCKER__LISTVIEW_NUMOFCOLS=0

DOCKER__TABLEWIDTH=70

DOCKER__NUMOFLINES_1=1
DOCKER__NUMOFLINES_2=2
DOCKER__NUMOFLINES_3=3
DOCKER__NUMOFLINES_4=4
DOCKER__NUMOFLINES_5=5
DOCKER__NUMOFLINES_6=6
DOCKER__NUMOFLINES_7=7
DOCKER__NUMOFLINES_8=8

#---BOOLEAN CONSTANTS
TRUE=true
FALSE=false

#---READ-INPUT CONSTANTS
DOCKER__CASE_SOURCE_DIR="SOURCE DIR"
DOCKER__CASE_SOURCE_FOBJECT="SOURCE FILENAME"
DOCKER__CASE_DEST_DIR="DEST DIR"
DOCKER__CASE_DONE="DONE"
DOCKER__CONTAINER_LIST_DIRECTORY_ERROR="No such file or directory"
DOCKER__SEMICOLON_BACK=";b"
DOCKER__SEMICOLON_CLEAR=";c"
DOCKER__SEMICOLON_HOME=";h"

DOCKER__READINPUT_H_OPTION="${DOCKER__GENERAL_FG_YELLOW};h${DOCKER__NOCOLOR}ome"
DOCKER__READINPUT_B_OPTION="${DOCKER__GENERAL_FG_YELLOW};b${DOCKER__NOCOLOR}ack"
DOCKER__READINPUT_C_OPTION="${DOCKER__GENERAL_FG_YELLOW};c${DOCKER__NOCOLOR}lear"
DOCKER__READINPUT_B_C_OPTIONS="(${DOCKER__READINPUT_B_OPTION}/${DOCKER__READINPUT_C_OPTION})"
DOCKER__READINPUT_H_B_C_OPTIONS="(${DOCKER__READINPUT_H_OPTION}/${DOCKER__READINPUT_B_OPTION}/${DOCKER__READINPUT_C_OPTION})"

DOCKER__READINPUT_CONTAINERID="${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER${DOCKER__NOCOLOR}:-:ID ${DOCKER__READINPUT_B_C_OPTIONS}: "

DOCKER__READINPUT_CONTAINER_SOURCE_DIR="${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER${DOCKER__NOCOLOR}:-:SOURCE-DIR ${DOCKER__READINPUT_H_B_C_OPTIONS}: "
DOCKER__READINPUT_CONTAINER_SOURCE_FOBJECT="${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER${DOCKER__NOCOLOR}:-:{FILE|FOLDER} ${DOCKER__READINPUT_H_B_C_OPTIONS}: "
DOCKER__READINPUT_HOST_DEST_DIR="${DOCKER__HOST_FG_GREEN85}HOST${DOCKER__NOCOLOR}:-:DEST-DIR ${DOCKER__READINPUT_H_B_C_OPTIONS}: "

DOCKER__READINPUT_HOST_SOURCE_DIR="${DOCKER__HOST_FG_GREEN85}HOST${DOCKER__NOCOLOR}:-:SOURCE-DIR ${DOCKER__READINPUT_H_B_C_OPTIONS}: "
DOCKER__READINPUT_HOST_SOURCE_FOBJECT="${DOCKER__HOST_FG_GREEN85}HOST${DOCKER__NOCOLOR}:-:{FILE|FOLDER} ${DOCKER__READINPUT_H_B_C_OPTIONS}: "
DOCKER__READINPUT_CONTAINER_DEST_DIR="${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER${DOCKER__NOCOLOR}:-:DEST-DIR ${DOCKER__READINPUT_H_B_C_OPTIONS}: "



# #---VARIABLES
# docker__myContainerId_accept=${DOCKER__EMPTYSTRING}
# docker__mySource_dir=${DOCKER__EMPTYSTRING}
# docker__mySource_fObject=${DOCKER__EMPTYSTRING}
# docker__mySource_fPath=${DOCKER__EMPTYSTRING}
# docker__myDest_dir=${DOCKER__EMPTYSTRING}

# docker__myDest_fpath=${DOCKER__EMPTYSTRING}
# docker__accept_mySource_dir=${DOCKER__EMPTYSTRING}
# docker__accept_mySource_fObject=${DOCKER__EMPTYSTRING}
# docker__accept_mySource_fPath=${DOCKER__EMPTYSTRING}
# docker__accept_myDest_dir=${DOCKER__EMPTYSTRING}
# docker__accept_myDest_fPath=${DOCKER__EMPTYSTRING}

# docker__myTmpSource_fPath=${DOCKER__EMPTYSTRING}
# docker__myTmpDest_fPath=${DOCKER__EMPTYSTRING}

# docker__myanswer=${DOCKER__EMPTYSTRING}
# docker__lastTwoChar=${DOCKER__EMPTYSTRING}
# docker__case_option=${DOCKER__EMPTYSTRING}




#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C_func INT


#---FUNCTIONS
function CTRL_C_func() {
    # echo -e "\r"
    # echo -e "\r"
    # echo -e "Exiting now..."
    echo -e "\r"
    echo -e "\r"

    exit 0
}

function GOTO__func {
	#Input args
    LABEL=$1
	
	#Define Command line
    cmd_line=$(sed -n "/$LABEL:/{:a;n;p;ba;};" $0 | grep -v ':$')
	
	#Execute Command line
    eval "${cmd_line}"
	
	#Exit Function
    exit
}

function press_any_key__func() {
	#Define constants
	local cTIMEOUT_ANYKEY=10

	#Initialize variables
	local keypressed=${DOCKER__EMPTYSTRING}
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

function get_lastTwoChars_of_string__func()
{
    #Input args
    local str_input=${1}

    #Define local variable
    local last2Chars=`echo ${str_input: -2}`

    #Output
    echo ${last2Chars}
}
function remove_trailing_char__func()
{
    #Input args
    local str_input=${1}
	local char_input=${2}

    #Get string without trailing specified char
	#REMARK:
	#	char_input: character to be removed
	#	REMARK: 
	#		Make sure to prepend escape-char '\' if needed
	#		For example: slash '/' prepended with escape-char becomes '\/')
	#	*: all of specified 'char_input' value
	#	$: start from the end
	local str_output=`echo "${str_input}" | sed s"/${char_input}*$//g"`

    #Output
    echo ${str_output}
}

function cell__remove_whitespaces__func() {
    #Input args
    local orgstring=${1}
    
    #Remove white spaces
    local outputstring=`echo -e "${orgstring}" | tr -d "[:blank:]"`

    #OUTPUT
    echo ${outputstring}
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
docker__init_variables__sub() {
	#Initialize variables
	docker__get_initial_myContainerId_dfltVal_isAlreadyDone=${TRUE}

	docker__myContainerId_defaultVal=${DOCKER__EMPTYSTRING}
	docker__myContainerId_accept=${DOCKER__EMPTYSTRING}
	docker__mySource_dir=${DOCKER__EMPTYSTRING}
	docker__mySource_fObject=${DOCKER__EMPTYSTRING}
	docker__mySource_fPath=${DOCKER__EMPTYSTRING}
	docker__myDest_dir=${DOCKER__EMPTYSTRING}

	docker__myDest_fpath=${DOCKER__EMPTYSTRING}
	docker__accept_mySource_dir=${DOCKER__EMPTYSTRING}
	docker__accept_mySource_fObject=${DOCKER__EMPTYSTRING}
	docker__accept_mySource_fPath=${DOCKER__EMPTYSTRING}
	docker__accept_myDest_dir=${DOCKER__EMPTYSTRING}
	docker__accept_myDest_fPath=${DOCKER__EMPTYSTRING}

	docker__myTmpSource_fPath=${DOCKER__EMPTYSTRING}
	docker__myTmpDest_fPath=${DOCKER__EMPTYSTRING}

	docker__myanswer=${DOCKER__EMPTYSTRING}
	docker__lastTwoChar=${DOCKER__EMPTYSTRING}
	docker__case_option=${DOCKER__EMPTYSTRING}

	docker__accept_mySource_dir=${DOCKER__EMPTYSTRING}
	docker__accept_mySource_fObject=${DOCKER__EMPTYSTRING}
	docker__accept_myDest_dir=${DOCKER__EMPTYSTRING}

	docker__prevDir=${DOCKER__EMPTYSTRING}

	#Assign values to specified variables (as mentioned below)
	#REMARK: these variables will be used in function 'docker__get_source_destination_fpath__sub'
	#IMPORTANT: this MUST be done here!
	if [[ ${docker__mycopychoice} -eq 1 ]]; then
		docker__mySource_dir=${docker__root_sp7xxx_out_dir}
		# if [[ -z ${docker__accept_mySource_dir} ]]; then
		# 	docker__accept_mySource_dir=${docker__mySource_dir}
		# fi

		docker__mySource_fObject=${docker__ispbooot_bin_filename}
		# if [[ -z ${docker__accept_mySource_fObject} ]]; then
		# 	docker__accept_mySource_fObject=${docker__mySource_fObject}
		# fi

		docker__myDest_dir=${docker__parent_dir}
		# if [[ -z ${docker__accept_myDest_dir} ]]; then
		# 	docker__accept_myDest_dir=${docker__myDest_dir}
		# fi

	else
		docker__mySource_dir=${docker__parent_dir}
		# if [[ -z ${docker__accept_mySource_dir} ]]; then
		# 	docker__accept_mySource_dir=${docker__mySource_dir}
		# fi

		docker__mySource_fObject=${DOCKER__EMPTYSTRING}
		# if [[ -z ${docker__accept_mySource_fObject} ]]; then
		# 	docker__accept_mySource_fObject=${DOCKER__EMPTYSTRING}
		# fi

		docker__myDest_dir=${docker__root_sp7xxx_out_dir}
		# if [[ -z ${docker__accept_myDest_dir} ]]; then
		# 	docker__accept_myDest_dir=${docker__myDest_dir}
		# fi
	fi
}

docker__load_header__sub() {
    echo -e "\r"
    echo -e "${DOCKER__TITLE_BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__TITLE_BG_ORANGE}                                ${DOCKER__NOCOLOR}"

	#Goto Next-Phase
	GOTO__func PHASE_ENVIRONMENT_VARIABLES
}

docker__environmental_variables__sub() {
	#---Define PATHS
	docker__ispbooot_bin_filename="ISPBOOOT.BIN"
	docker__dockercontainer_dirlist_filename="dockercontainer_dirlist.sh"
	docker__localhost_dirlist_filename="localhost_dirlist.sh"
	
	# docker__current_dir=`pwd`
	docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})	#/repo/LTPP3_ROOTFS/development_tools
	docker__parent_dir=${docker__current_dir%/*}    #gets one directory up (/repo/LTPP3_ROOTFS)
    if [[ -z ${docker__parent_dir} ]]; then
        docker__parent_dir="${DOCKER__SLASH}"
    fi

	docker__root_sp7xxx_out_dir=/root/SP7021/out

	docker__dockercontainer_dirlist_fpath=${docker__current_dir}/${docker__dockercontainer_dirlist_filename}
	docker__localhost_dirlist_fpath=${docker__current_dir}/${docker__localhost_dirlist_filename}

	docker__bin_bash_dir=/bin/bash

	#Goto Next-Phase
	GOTO__func PHASE_CHOOSE_COPY_DIRECTION
}

docker__choose_copy_direction__sub() {
	#Define local constants
	local MENUTITLE="Copy ${DOCKER__FILES_FG_ORANGE}FILE${DOCKER__NOCOLOR}/${DOCKER__DIRS_FG_VERYLIGHTORANGE}FOLDER${DOCKER__NOCOLOR} From/To ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER${DOCKER__NOCOLOR}"

	#Define local variables
	local readMsg="Your Choice: "

    #Show menu-title
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${MENUTITLE}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

	#Show menu-items
	echo -e "Choose copy direction:"
	echo -e "${DOCKER__FOURSPACES}1. ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER${DOCKER__NOCOLOR} > ${DOCKER__HOST_FG_GREEN85}HOST${DOCKER__NOCOLOR}"
	echo -e "${DOCKER__FOURSPACES}2. ${DOCKER__HOST_FG_GREEN85}HOST${DOCKER__NOCOLOR} > ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER${DOCKER__NOCOLOR}"
	echo -e "\r"

	#Start loop
	while true
	do
		#Show read-input
		read -N1 -r -p "${readMsg}" docker__mycopychoice

		#Remove (white-)spaces
		docker__mycopychoice=`cell__remove_whitespaces__func "${docker__mycopychoice}"`
		if [[ ! -z ${docker__mycopychoice} ]]; then
			if [[ ${docker__mycopychoice} =~ [1,2] ]]; then
				echo -e "\r"
				echo -e "\r"

				break  
			# else
			# 	#Update error-message
			# 	errMsg="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Invalid option '${docker__mycopychoice}'"

			# 	#Show error-message
			# 	echo -e "\r"
			# 	echo -e "${errMsg}"

			# 	press_any_key__func

			# 	moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_4}"
			fi
		else
			moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
		fi
	done

	#MANDATORY: Initialize global variables
	docker__init_variables__sub

	#Goto Next-Phase
	GOTO__func PHASE_CHOOSE_CONTAINERID
}

docker__choose_containerid__sub() {
	#Define local constants
	local MENUTITLE="Show ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER${DOCKER__NOCOLOR}-list"

	#Define local variables
	local myContainerId_chosen=${DOCKER__EMPTYSTRING}

	#Initial setting
	# docker__lastTwoChar=${DOCKER__EMPTYSTRING}

    #Show menu-title
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${MENUTITLE}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Get number of images
    numof_containers=`docker ps -a | head -n -1 | wc -l`
    if [[ ${numof_containers} -eq 0 ]]; then
        #Update error-message
        errMsg="=:${DOCKER__ERROR_FG_LIGHTRED}NO CONTAINERS FOUND${DOCKER__NOCOLOR}:="

        #Show error-message
        echo -e "\r"
        show_centered_string__func "${errMsg}" "${DOCKER__TABLEWIDTH}"
        echo -e "\r"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        press_any_key__func

        exit
    else
        docker ps -a

        echo -e "\r"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    fi

	#Initialize variable
	if [[ -z ${docker__lastTwoChar} ]]; then
		docker__myContainerId_defaultVal=`docker ps -a | awk '{print $1}' | cut -d" " -f1  | head -n 2 | tail -n 1`
	fi

	#Start loop
	while true
	do
		#Choose read-input command (depending on the 'docker__myContainerId_defaultVal' value)
		if [[ -z ${docker__myContainerId_defaultVal} ]]; then	#is an Empty String
			read -e -p "${DOCKER__READINPUT_CONTAINERID}" myContainerId_chosen
		else	#is NOT an Empty String
			read -e -p "${DOCKER__READINPUT_CONTAINERID}" -i ${docker__myContainerId_defaultVal} myContainerId_chosen
		fi

		#Get the last-two-characters
		docker__lastTwoChar=`get_lastTwoChars_of_string__func "${myContainerId_chosen}"`
		if [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_BACK} ]]; then
			echo -e "\r"

			#remove the last 2 char
			myContainerId_chosen=`echo ${myContainerId_chosen} | sed -e "s/${docker__lastTwoChar}$//"`

			#Update 'docker__myContainerId_defaultVal'
			docker__myContainerId_defaultVal=${myContainerId_chosen}

			#Set next-phase
			GOTO__func CHOOSE_COPY_DIRECTION

			break
		elif [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_CLEAR} ]]; then
			#Reset variables
			myContainerId_chosen=${DOCKER__EMPTYSTRING}
			docker__myContainerId_defaultVal=${DOCKER__EMPTYSTRING}
			docker__myContainerId_accept=${DOCKER__EMPTYSTRING}

			moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
			moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
		else
			#Reset variables
			docker__lastTwoChar=${DOCKER__EMPTYSTRING}

			#Update 'docker__myContainerId_defaultVal'
			docker__myContainerId_defaultVal=${myContainerId_chosen}
		fi

		#Only continue if none of the above if-condition is met
		if [[ ! -z ${myContainerId_chosen} ]]; then
			#Remove any white-spaces
			docker__myContainerId_accept=`cell__remove_whitespaces__func "${myContainerId_chosen}"`

			#Check if 'docker__myContainerId_accept' can be found in the 'container's list'
			docker__myContainerId_isFound=`docker ps -a | awk '{print $1}' | grep -w ${docker__myContainerId_accept}`
			if [[ ! -z ${docker__myContainerId_isFound} ]]; then
				break         
			else
				#Update error-message
				errMsg="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Invalid CONTAINER-ID: '${DOCKER__LIGHTRED}${docker__myContainerId_accept}${DOCKER__NOCOLOR}'"
				
				#Show error-message
				echo -e "\r"
				echo -e "${errMsg}"

				#Wait for a max. of 10 seconds
				press_any_key__func

				#Move-up and Clean lines
				moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_5}"

				#Reset variable
				docker__myContainerId_accept=${DOCKER__EMPTYSTRING}
			fi
		else
			moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
		fi
	done

	#Goto Next-Phase
	GOTO__func PHASE_GET_SRC_DST_FPATH
}

docker__get_source_destination_fpath__sub() {
	#Define local variables
	local sourceFpath_toBeShown=${DOCKER__EMPTYSTRING}
	local destFpath_toBeShown=${DOCKER__EMPTYSTRING}

	#Initial phase
	docker__case_option=${DOCKER__CASE_SOURCE_DIR}
	if [[ ${docker__mycopychoice} -eq 1 ]]; then	#CONTAINER -to- HOST (docker__mycopychoice = 1)
		while true
		do
			case ${docker__case_option} in
				${DOCKER__CASE_SOURCE_DIR})
					#---SOURCE: Provide the Location of the file which you want to copy (located  at the CONTAINER!)
					docker__container_get_source_dir__func
					;;

				${DOCKER__CASE_SOURCE_FOBJECT})
					#---SOURCE: Provide the file/folder which you want to copy (located at the CONTAINER!)
					docker__container_get_source_fobject__func
					;;

				${DOCKER__CASE_DEST_DIR})
					#---DESTINATION: Provide the location where you want to copy to (located at the HOST!)
					docker__host_get_dest_dir__func
					;;

				${DOCKER__CASE_DONE})
					break
					;;
			esac
		done


		#Compose Source and Destination Fullpath
		docker__compose_source_dest_fpath__sub

	else	#HOST -to- CONTAINER (docker__mycopychoice = 2)
		while true
		do
			case ${docker__case_option} in
				${DOCKER__CASE_SOURCE_DIR})
					#---SOURCE: Provide the location where you want to copy to (located at the HOST!)
					docker__host_get_source_dir__func
					;;

				${DOCKER__CASE_SOURCE_FOBJECT})			
					#---SOURCE: Provide the file/folder which you want to copy (located  at the CONTAINER!)
					docker__host_get_source_fobject__func
					;;

				${DOCKER__CASE_DEST_DIR})
					#---DESTINATION: Provide the Location of the file which you want to copy (located  at the CONTAINER!)
					docker__container_get_dest_dir__func
					;;

				${DOCKER__CASE_DONE})
					break
					;;
					
			esac
		done

		#Compose Source and Destination Fullpath
		docker__compose_source_dest_fpath__sub

	fi

#---Summary
	echo -e "\r"
	duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
	echo "Overview:"
	duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

	#Update 'sourceFpath_toBeShown'
	if [[ ${docker__accept_mySource_fObject} == ${DOCKER__ASTERISK} ]]; then
		sourceFpath_toBeShown=${docker__accept_mySource_fPath}/*
	else
		sourceFpath_toBeShown=${docker__accept_mySource_fPath}
	fi

	#Update 'destFpath_toBeShown'
	destFpath_toBeShown=${docker__accept_myDest_fPath}

	echo "${DOCKER__HOST_FG_GREEN85}Source Full-path${DOCKER__NOCOLOR}: ${sourceFpath_toBeShown}"
	echo "${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Destination Full-path${DOCKER__NOCOLOR}: ${docker__accept_myDest_fPath}"

	duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
	echo -e "\r"
	
	#Goto Next-Phase
	GOTO__func PHASE_COPY_FROM_SRC_TO_DST
}
docker__container_get_source_dir__func()
{
	#Define local variables
	local dirExists=${FALSE}
	local numOf_dirContent=0

	#Initial setting
	docker__lastTwoChar=${DOCKER__EMPTYSTRING}

	while true
	do
		#Print an Empty Line
		# echo -e "\r"

		if [[ -z ${docker__mySource_dir} ]]; then	#contains NO data
			read -e -p "${DOCKER__READINPUT_CONTAINER_SOURCE_DIR}" docker__mySource_dir
		else	#contains data
			read -e -p "${DOCKER__READINPUT_CONTAINER_SOURCE_DIR}" -i "${docker__mySource_dir}" docker__mySource_dir
		fi

		docker__lastTwoChar=`get_lastTwoChars_of_string__func "${docker__mySource_dir}"`
		if [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_HOME} ]]; then	#goto HOME
			echo -e "\r"

			docker__mySource_dir=`echo ${docker__mySource_dir} | sed -e "s/${docker__lastTwoChar}$//"`	#remove the last 2 char

			GOTO__func PHASE_CHOOSE_COPY_DIRECTION

			break
		elif [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_BACK} ]]; then	#goto Previous-Phase
			docker__mySource_dir=`echo ${docker__mySource_dir} | sed -e "s/${docker__lastTwoChar}$//"`	#remove the last 2 char

			GOTO__func PHASE_CHOOSE_CONTAINERID

			break
		elif [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_CLEAR} ]]; then
			docker__mySource_dir=${DOCKER__EMPTYSTRING}	#reset variable
			docker__accept_mySource_dir=${DOCKER__EMPTYSTRING}	#reset variable (maybe obsolete)

			moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
			moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
		fi

		#None of the above if-condition is met	
		if [[ ! -z ${docker__mySource_dir} ]]; then
			#Get directory contents list based on the specified directory 'docker__mySource_dir'
			docker__show_dirContent_handler__func "${docker__myContainerId_accept}" "${docker__mySource_dir}"

			dirExists=`docker__container_file_or_dir_exists__func "${docker__myContainerId_accept}" "${docker__mySource_dir}"`
			if [[ ${dirExists} == ${TRUE} ]]; then

				numOf_dirContent=`docker__calc_numOf_dirContent__func "${docker__myContainerId_accept}" "${docker__mySource_dir}"`
				if [[ ${numOf_dirContent} -gt 0 ]]; then
					docker__accept_mySource_dir=${docker__mySource_dir}

					docker__case_option=${DOCKER__CASE_SOURCE_FOBJECT}

					break
				fi
			fi
		else
			# moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
			moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
		fi
	done
}
docker__container_get_source_fobject__func()
{
	#Define local variables
	local fObjectExists=${FALSE}
	local sourceFpath=${DOCKER__EMPTYSTRING}

	#Initial setting
	docker__lastTwoChar=${DOCKER__EMPTYSTRING}

	while true
	do
		# #Print an Empty Line
		# echo -e "\r"
		
		if [[ -z ${docker__mySource_fObject} ]]; then	#is an Empty String
			read -e -p "${DOCKER__READINPUT_CONTAINER_SOURCE_FOBJECT}" docker__mySource_fObject
		else	#is NOT an Empty String
			read -e -p "${DOCKER__READINPUT_CONTAINER_SOURCE_FOBJECT}" -i "${docker__mySource_fObject}" docker__mySource_fObject
		fi

		docker__lastTwoChar=`get_lastTwoChars_of_string__func "${docker__mySource_fObject}"`
		if [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_HOME} ]]; then	#goto HOME
			echo -e "\r"

			docker__mySource_fObject=`echo ${docker__mySource_fObject} | sed -e "s/${docker__lastTwoChar}$//"`	#remove the last 2 char

			GOTO__func PHASE_CHOOSE_COPY_DIRECTION

			break
		elif [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_BACK} ]]; then	#goto Previous-Phase
			docker__mySource_fObject=`echo ${docker__mySource_fObject} | sed -e "s/${docker__lastTwoChar}$//"`	#remove the last 2 char

			docker__case_option=${DOCKER__CASE_SOURCE_DIR}

			break
		elif [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_CLEAR} ]]; then
			docker__mySource_fObject=${DOCKER__EMPTYSTRING}	#reset variable
			docker__accept_mySource_fObject=${DOCKER__EMPTYSTRING}	#reset variable (maybe obsolete)

			moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
			moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
		fi

		#Define the full-path
		sourceFpath="${docker__accept_mySource_dir}/${docker__mySource_fObject}"

		#Validate 'sourceFpath'
		if [[ ! -z ${docker__mySource_fObject} ]]; then	#contains data
			#Check if 'docker__mySource_fObject = *'
			if [[ ${docker__mySource_fObject} == ${DOCKER__ASTERISK} ]]; then
				docker__accept_mySource_fObject=${docker__mySource_fObject}

				docker__case_option=${DOCKER__CASE_DEST_DIR}

				break	#exit loop
			fi

			#Check if full-path does exist (assuming that 'docker__mySource_fObject != *')
			fObjectExists=`docker__container_file_or_dir_exists__func "${docker__myContainerId_accept}" "${sourceFpath}"`	
			if [[ ${fObjectExists} == ${TRUE} ]]; then	#full-path does exist
				docker__accept_mySource_fObject=${docker__mySource_fObject}

				docker__case_option=${DOCKER__CASE_DEST_DIR}

				break
			else	#full-path does NOT exist
				#Reset variable
				docker__mySource_fObject=${DOCKER__EMPTYSTRING}

				#Move-up and Clean-up
				moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
			fi
		else	#contains NO data
			moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
		fi
	done
}
docker__host_get_dest_dir__func()
{
	#Define local variables
	local dirExists=${FALSE}

	#Initial setting
	docker__lastTwoChar=${DOCKER__EMPTYSTRING}

	while true
	do
		# #Print an Empty Line
		# echo -e "\r"

		if [[ -z ${docker__myDest_dir} ]]; then	#is an Empty String
			read -e -p "${DOCKER__READINPUT_HOST_DEST_DIR}" docker__myDest_dir
		else	#is NOT an Empty String
			read -e -p "${DOCKER__READINPUT_HOST_DEST_DIR}" -i "${docker__myDest_dir}" docker__myDest_dir
		fi

		docker__lastTwoChar=`get_lastTwoChars_of_string__func "${docker__myDest_dir}"`
		if [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_HOME} ]]; then	#goto HOME
			echo -e "\r"

			docker__myDest_dir=`echo ${docker__myDest_dir} | sed -e "s/${docker__lastTwoChar}$//"`	#remove the last 2 char

			GOTO__func PHASE_CHOOSE_COPY_DIRECTION

			break
		elif [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_BACK} ]]; then	#goto Previous-Phase
			docker__myDest_dir=`echo ${docker__myDest_dir} | sed -e "s/${docker__lastTwoChar}$//"`	#remove the last 2 char

			docker__case_option=${DOCKER__CASE_SOURCE_FOBJECT}

			break
		elif [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_CLEAR} ]]; then
			docker__myDest_dir=${DOCKER__EMPTYSTRING}	#reset variable
			docker__accept_myDest_dir=${docker__myDest_dir}	#reset variable (maybe obsolete)

			moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
			moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
		fi

		#Take action based on whether directory 'docker__myDest_dir' exist or not
		if [[ ! -z ${docker__myDest_dir} ]]; then
			#Get directory contents list based on the specified directory 'docker__mySource_dir'
			docker__show_dirContent_handler__func "${DOCKER__EMPTYSTRING}" "${docker__myDest_dir}"

			dirExists=`docker__host_file_or_dir_exists__func "${docker__myDest_dir}"`
			if [[ ${dirExists} == ${TRUE} ]]; then
				docker__accept_myDest_dir=${docker__myDest_dir}

				docker__case_option=${DOCKER__CASE_DONE}

				break
			fi
		else
			moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
		fi
	done
}
docker__host_get_source_dir__func()
{
	#Define local variables
	local dirExists=${FALSE}

	#Initial setting
	docker__lastTwoChar=${DOCKER__EMPTYSTRING}

	while true
	do
		# #Print an Empty Line
		# echo -e "\r"

		if [[ -z ${docker__mySource_dir} ]]; then	#is an Empty String
			read -e -p "${DOCKER__READINPUT_HOST_SOURCE_DIR}" docker__mySource_dir
		else	#is NOT an Empty String
			read -e -p "${DOCKER__READINPUT_HOST_SOURCE_DIR}" -i "${docker__mySource_dir}" docker__mySource_dir
		fi

		docker__lastTwoChar=`get_lastTwoChars_of_string__func "${docker__mySource_dir}"`
		if [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_HOME} ]]; then	#goto HOME
			echo -e "\r"

			docker__mySource_dir=`echo ${docker__mySource_dir} | sed -e "s/${docker__lastTwoChar}$//"`	#remove the last 2 char

			GOTO__func PHASE_CHOOSE_COPY_DIRECTION

			break
		elif [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_BACK} ]]; then	#goto Previous-Phase
			docker__mySource_dir=`echo ${docker__mySource_dir} | sed -e "s/${docker__lastTwoChar}$//"`	#remove the last 2 char

			GOTO__func PHASE_CHOOSE_CONTAINERID

			break
		elif [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_CLEAR} ]]; then
			docker__mySource_dir=${DOCKER__EMPTYSTRING}	#reset variable
			docker__accept_mySource_fObject=${docker__mySource_fObject}	#reset variable (maybe obsolete)

			moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
			moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
		fi

		#None of the above if-condition is met	
		if [[ ! -z ${docker__mySource_dir} ]]; then
			#Get directory contents list based on the specified directory 'docker__mySource_dir'
			docker__show_dirContent_handler__func "${DOCKER__EMPTYSTRING}" "${docker__mySource_dir}"

			dirExists=`docker__host_file_or_dir_exists__func "${docker__mySource_dir}"`
			if [[ ${dirExists} == ${TRUE} ]]; then

				numOf_dirContent=`docker__calc_numOf_dirContent__func "${DOCKER__EMPTYSTRING}" "${docker__mySource_dir}"`
				if [[ ${numOf_dirContent} -gt 0 ]]; then
					docker__accept_mySource_dir=${docker__mySource_dir}

					docker__case_option=${DOCKER__CASE_SOURCE_FOBJECT}

					break
				fi
			fi
		else
			# moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
			moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
		fi
	done
}
docker__host_get_source_fobject__func()
{
	#Define local variables
	local fObjectExists=${FALSE}
	local sourceFpath=${DOCKER__EMPTYSTRING}

	#Initial setting
	docker__lastTwoChar=${DOCKER__EMPTYSTRING}

	while true
	do
		# #Print an Empty Line
		# echo -e "\r"

		if [[ -z ${docker__mySource_fObject} ]]; then	#is an Empty String
			read -e -p "${DOCKER__READINPUT_HOST_SOURCE_FOBJECT}" docker__mySource_fObject
		else	#is NOT an Empty String
			read -e -p "${DOCKER__READINPUT_HOST_SOURCE_FOBJECT}" -i "${docker__mySource_fObject}" docker__mySource_fObject
		fi

		docker__lastTwoChar=`get_lastTwoChars_of_string__func "${docker__mySource_fObject}"`
		if [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_HOME} ]]; then	#goto HOME
			echo -e "\r"

			docker__mySource_fObject=`echo ${docker__mySource_fObject} | sed -e "s/${docker__lastTwoChar}$//"`	#remove the last 2 char

			GOTO__func PHASE_CHOOSE_COPY_DIRECTION

			break
		elif [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_BACK} ]]; then	#goto Previous-Phase
			docker__mySource_fObject=`echo ${docker__mySource_fObject} | sed -e "s/${docker__lastTwoChar}$//"`	#remove the last 2 char

			docker__case_option=${DOCKER__CASE_SOURCE_DIR}

			break
		elif [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_CLEAR} ]]; then
			docker__mySource_fObject=${DOCKER__EMPTYSTRING}	#reset variable
			docker__accept_mySource_fObject=${docker__mySource_fObject}	#reset variable (maybe obsolete)

			moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
			moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
		fi

		#Define the full-path
		sourceFpath="${docker__accept_mySource_dir}/${docker__mySource_fObject}"

		#Validate 'sourceFpath'
		if [[ ! -z ${docker__mySource_fObject} ]]; then	#contains data
			#Check if 'docker__mySource_fObject = *'
			if [[ ${docker__mySource_fObject} == ${DOCKER__ASTERISK} ]]; then
				docker__accept_mySource_fObject=${docker__mySource_fObject}

				docker__case_option=${DOCKER__CASE_DEST_DIR}

				break	#exit loop
			fi

			#Check if full-path does exist (assuming that 'docker__mySource_fObject != *')
			fObjectExists=`docker__host_file_or_dir_exists__func "${sourceFpath}"`	
			if [[ ${fObjectExists} == ${TRUE} ]]; then	#full-path does exist
				docker__accept_mySource_fObject=${docker__mySource_fObject}

				docker__case_option=${DOCKER__CASE_DEST_DIR}

				break
			else	#full-path does NOT exist
				#Reset variable
				docker__mySource_fObject=${DOCKER__EMPTYSTRING}

				#Move-up and Clean-up
				moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
			fi
		else	#contains NO data
			moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
		fi
	done
}
docker__container_get_dest_dir__func()
{
	#Define local variables
	local dirExists=${FALSE}

	#Initial setting
	docker__lastTwoChar=${DOCKER__EMPTYSTRING}

	while true
	do
		# #Print an Empty Line
		# echo -e "\r"

		if [[ -z ${docker__myDest_dir} ]]; then	#is an Empty String
			read -e -p "${DOCKER__READINPUT_CONTAINER_DEST_DIR}" docker__myDest_dir
		else	#is NOT an Empty String
			read -e -p "${DOCKER__READINPUT_CONTAINER_DEST_DIR}" -i "${docker__myDest_dir}" docker__myDest_dir
		fi

		docker__lastTwoChar=`get_lastTwoChars_of_string__func "${docker__myDest_dir}"`
		if [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_HOME} ]]; then	#goto HOME
			echo -e "\r"

			docker__myDest_dir=`echo ${docker__myDest_dir} | sed -e "s/${docker__lastTwoChar}$//"`	#remove the last 2 char

			GOTO__func PHASE_CHOOSE_COPY_DIRECTION

			break
		elif [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_BACK} ]]; then	#goto Previous-Phase
			docker__myDest_dir=`echo ${docker__myDest_dir} | sed -e "s/${docker__lastTwoChar}$//"`	#remove the last 2 char

			docker__case_option=${DOCKER__CASE_SOURCE_FOBJECT}

			break
		elif [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_CLEAR} ]]; then
			docker__myDest_dir=${DOCKER__EMPTYSTRING}	#reset variable
			docker__accept_myDest_dir=${docker__myDest_dir}	#reset variable

			moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
			moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
		fi

		#Take action based on whether directory 'docker__myDest_dir' exist or not
		if [[ ! -z ${docker__myDest_dir} ]]; then
			#Get directory contents list based on the specified directory 'docker__mySource_dir'
			docker__show_dirContent_handler__func "${docker__myContainerId_accept}" "${docker__myDest_dir}"

			dirExists=`docker__container_file_or_dir_exists__func "${docker__myContainerId_accept}" "${docker__myDest_dir}"`
			if [[ ${dirExists} == ${TRUE} ]]; then
				docker__accept_myDest_dir=${docker__myDest_dir}

				docker__case_option=${DOCKER__CASE_DONE}

				break
			fi
		else
			moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
		fi
	done
}
function docker__show_dirContent_handler__func()
{
	#Input args
	local myContainerID=${1}
	local dirInput=${2}

	#Define local variable
	local keyWord=${DOCKER__EMPTYSTRING}	#no key-word (show all data in 'dirInput')

	#Get directory content of 'dirInput'
	if [[ -z ${myContainerID} ]]; then	#LOCAL machine (aka HOST)
		${docker__localhost_dirlist_fpath} "${dirInput}" "${DOCKER__LISTVIEW_NUMOFROWS}" "${DOCKER__LISTVIEW_NUMOFCOLS}" "${keyWord}"
	else	#REMOTE machine (aka CONTAINER)
		${docker__dockercontainer_dirlist_fpath} "${myContainerID}" "${dirInput}" "${DOCKER__LISTVIEW_NUMOFROWS}" "${DOCKER__LISTVIEW_NUMOFCOLS}" "${keyWord}"
	fi
}
function docker__host_file_or_dir_exists__func()
{
	#Input arg
	local myPath=${1}

	#Check if directory exists
	if [[ ! -d ${myPath} ]]; then	#directory does NOT exist
		#Maybe 'myPath' is a File
		if [[ ! -f ${myPath} ]]; then	#file does NOT exist
			echo ${FALSE}
		else	#file does exist
			echo ${TRUE} 
		fi
	else	# directory does exist
		echo ${TRUE} 
	fi
}
function docker__container_file_or_dir_exists__func()
{
	#Input arg
	local myContainerID=${1}
	local myPath=${2}

	#Define local variables
	local error_isFound=`docker exec -it ${myContainerID} ls ${myPath} | grep "${DOCKER__CONTAINER_LIST_DIRECTORY_ERROR}"`
	if [[ ! -z ${error_isFound} ]]; then	#directory does NOT exist
		echo ${FALSE}
	else	#directory does exist
		echo ${TRUE} 
	fi
}
function docker__calc_numOf_dirContent__func()
{
	#Input args
	local myContainerID=${1}
	local dirInput=${2}

	#Define local variables
	local dirContent_numOfItems_max_raw=${DOCKER__EMPTYSTRING}
	local dirContent_numOfItems_max=0
	
	local docker_exec_cmd="docker exec -it ${myContainerId_chosen} ${docker__bin_bash_dir} -c"

    #Get Number of Files
    if [[ -z ${myContainerID} ]]; then
        dirContent_numOfItems_max=`ls -1 ${dirInput} | wc -l`
    else
		#This result contains carriage return(s)
        dirContent_numOfItems_max_raw=`${docker_exec_cmd} "ls -1 ${dirInput} | wc -l"`

		#Remove the carriage return(s)
		dirContent_numOfItems_max=`echo "${dirContent_numOfItems_max_raw}" | tr -d $'\r'`
    fi

	#Output
	echo ${dirContent_numOfItems_max}
}

docker__compose_source_dest_fpath__sub()
{
	#Remove trailing slashes
	docker__accept_mySource_dir=`remove_trailing_char__func "${docker__accept_mySource_dir}" "${DOCKER__ESCAPE_SLASH}"`
	docker__accept_myDest_dir=`remove_trailing_char__func "${docker__accept_myDest_dir}" "${DOCKER__ESCAPE_SLASH}"`

	if [[ ${docker__accept_mySource_fObject} == ${DOCKER__ASTERISK} ]]; then
		docker__accept_mySource_fPath=${docker__accept_mySource_dir}
		docker__accept_myDest_fPath=${docker__accept_myDest_dir}
	else
		docker__accept_mySource_fPath=${docker__accept_mySource_dir}/${docker__accept_mySource_fObject}
		docker__accept_myDest_fPath=${docker__accept_myDest_dir}/${docker__accept_mySource_fObject}
	fi
}

docker__copy_src_to_dst__sub() {
	while true
	do
		read -N1 -p "Do you wish to continue (${DOCKER__GENERAL_FG_YELLOW}y${DOCKER__NOCOLOR}es/${DOCKER__GENERAL_FG_YELLOW}n${DOCKER__NOCOLOR}o/${DOCKER__GENERAL_FG_YELLOW}r${DOCKER__NOCOLOR}edo/${DOCKER__GENERAL_FG_YELLOW}h${DOCKER__NOCOLOR}ome)?" docker__myanswer

		docker__myanswer=`cell__remove_whitespaces__func "${docker__myanswer}"`

		if [[ ! -z ${docker__myanswer} ]]; then
			if [[ ${docker__myanswer} =~ [y,n,r,h] ]]; then
				break
			else
				# echo -e "\r"	#add empty line (necessary to clean 'read' line)

				moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
				moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
			fi
		else 
			moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
		fi
	done
	echo -e "\r"

	#---Confirm answer and take action
	if [[ ${docker__myanswer} == "y" ]]; then
		echo -e "\r"
		echo -e "---${DOCKER__FILES_FG_ORANGE}START${DOCKER__NOCOLOR}: Copying Files/Folders"

		docker__copy_src_to_dst_handler__func
		
		echo -e "---${DOCKER__FILES_FG_ORANGE}COMPLETED${DOCKER__NOCOLOR}: Copying Files/Folders"

		echo -e "\r"
	elif [[ ${docker__myanswer} == "r" ]]; then
		echo -e "\r"

		GOTO__func PHASE_GET_SRC_DST_FPATH

	elif [[ ${docker__myanswer} == "h" ]]; then
		echo -e "\r"

		GOTO__func PHASE_CHOOSE_COPY_DIRECTION

	else
		GOTO__func PHASE_EXIT
	fi
}

docker__copy_src_to_dst_handler__func()
{
	#Define local variables
	local dirContent_list_string=${DOCKER__EMPTYSTRING}
	local dirContent_list_array=${DOCKER__EMPTYSTRING}
	local dirContent_list_arrayItem_raw=${DOCKER__EMPTYSTRING}
	local dirContent_list_arrayItem_clean=${DOCKER__EMPTYSTRING}
	local sourceFpath=${DOCKER__EMPTYSTRING}
	local destFpath=${DOCKER__EMPTYSTRING}

	#Define docker exec command which inclues '/bin/bash -c'
	local docker_exec_cmd="docker exec -it ${docker__myContainerId_accept} ${docker__bin_bash_dir} -c"

	if [[ ${docker__mycopychoice} -eq 1 ]]; then
		if [[ ${docker__mySource_fObject} = ${DOCKER__ASTERISK} ]]; then	#an asterisk was inputted for file-/folder-name
			#Get directory contents specified by 'docker__accept_mySource_dir'
			dirContent_list_string=`${docker_exec_cmd} "ls -1 ${docker__accept_mySource_dir}"`	

			#Convert string to array
			dirContent_list_array=(`echo ${dirContent_list_string}`)

			#Cycle through array
			for dirContent_list_arrayItem_raw in "${dirContent_list_array[@]}"; do
				#***IMPORTANT***: Remove carriage return (\r)
				#REMARK:
				#   'dirContent_list_arrayItem_raw' contains a carriage returns '\r'...
				#...due to the execution of '/bin/bash' in the command 'docker exec it'.
				#   To remove the carriage returns the 'dirContent_list_arrayItem_raw' is PIPED thru 'tr -d $'\r'
				dirContent_list_arrayItem_clean=`echo ${dirContent_list_arrayItem_raw} | tr -d $'\r'`

				#Print which file/folder will be copied
				echo -e "${DOCKER__FOURSPACES}copying: ${dirContent_list_arrayItem_clean}"

				#Compose Source and Destination Fullpath
				sourceFpath="${docker__accept_mySource_dir}/${dirContent_list_arrayItem_clean}"
				destFpath="${docker__accept_myDest_dir}/${dirContent_list_arrayItem_clean}"

				#Copy file or folder
				docker cp ${docker__myContainerId_accept}:${sourceFpath} ${destFpath}
			done
		else
			#Print which file/folder will be copied
			echo -e "${DOCKER__FOURSPACES}copying: ${docker__accept_mySource_fObject}"

			docker cp ${docker__myContainerId_accept}:${docker__accept_mySource_fPath} ${docker__accept_myDest_fPath}
		fi
	else
		if [[ ${docker__mySource_fObject} = ${DOCKER__ASTERISK} ]]; then	#an asterisk was inputted for file-/folder-name
			#Get directory contents specified by 'docker__accept_mySource_dir'
			dirContent_list_string=`ls -1 ${docker__accept_mySource_dir}`	

			#Convert string to array
			dirContent_list_array=(`echo ${dirContent_list_string}`)

			#Cycle through array
			for dirContent_list_arrayItem_clean in "${dirContent_list_array[@]}"; do
				#Print which file/folder will be copied
				echo -e "${DOCKER__FOURSPACES}copying: ${dirContent_list_arrayItem_clean}"

				#Compose Source and Destination Fullpath
				sourceFpath="${docker__accept_mySource_dir}/${dirContent_list_arrayItem_clean}"
				destFpath="${docker__accept_myDest_dir}/${dirContent_list_arrayItem_clean}"

				#Copy file or folder
				docker cp ${sourceFpath} ${docker__myContainerId_accept}:${destFpath}
			done
		else
			#Print which file/folder will be copied
			echo -e "${DOCKER__FOURSPACES}copying: ${docker__accept_mySource_fObject}"

			docker cp ${docker__accept_mySource_fPath} ${docker__myContainerId_accept}:${docker__accept_myDest_fPath}
		fi
	fi	
}

docker__exit__sub()
{
	# echo -e "\r"
	# echo -e "Exiting now..."
	
	exit 0

	echo -e "\r"
	echo -e "\r"
}

main_sub() {
#Goto FIRST-Phase
GOTO__func PHASE_LOAD_HEADER	#start with this!


@PHASE_LOAD_HEADER:
    docker__load_header__sub

@PHASE_ENVIRONMENT_VARIABLES:
	docker__environmental_variables__sub


@PHASE_CHOOSE_COPY_DIRECTION:
	docker__choose_copy_direction__sub


@PHASE_CHOOSE_CONTAINERID:
	docker__choose_containerid__sub


@PHASE_GET_SRC_DST_FPATH:
	docker__get_source_destination_fpath__sub


@PHASE_COPY_FROM_SRC_TO_DST:
	docker__copy_src_to_dst__sub

@PHASE_EXIT:
	docker__exit__sub

}


#Execute main subroutine
main_sub
