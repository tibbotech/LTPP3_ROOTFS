#!/bin/bash
#---Define colors
DOCKER__NOCOLOR=$'\e[0;0m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__REPOSITORY_FG_PURPLE=$'\e[30;38;5;93m'
DOCKER__CONTAINER_FG_BRIGHTPRUPLE=$'\e[30;38;5;141m'
DOCKER__HOST_FG_GREEN85=$'\e[30;38;5;85m'
DOCKER__DIRS_FG_VERYLIGHTORANGE=$'\e[30;38;5;223m'
DOCKER__FILES_FG_ORANGE=$'\e[30;38;5;215m'

DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'




#---Define constants
DOCKER__TITLE="TIBBO"

DOCKER__ASTERISK_CHAR="\*"
DOCKER__SLASH_CHAR="/"

DOCKER__CASE_SOURCE_DIR="SOURCE DIR"
DOCKER__CASE_SOURCE_FOBJECT="SOURCE FILENAME"
DOCKER__CASE_DEST_DIR="DEST DIR"
DOCKER__CASE_DONE="DONE"
DOCKER__CONTAINER_LIST_DIRECTORY_ERROR="No such file or directory"
DOCKER__SEMICOLON_BACK=";b"
DOCKER__SEMICOLON_CLEAR=";c"
DOCKER__SEMICOLON_HOME=";h"

DOCKER__EMPTYSTRING=""
DOCKER__SPACE=" "
DOCKER__FOUR_SPACES="    "

DOCKER__LISTVIEW_NUMOFROWS=20
DOCKER__LISTVIEW_NUMOFCOLS=0

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



#---Define variables
docker__myContainerId=${DOCKER__EMPTYSTRING}
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




#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C_func INT

function CTRL_C_func() {
    echo -e "\r"
    echo -e "\r"
    echo -e "Exiting now..."
    echo -e "\r"
    echo -e "\r"

    exit 0
}




#---Local functions & subroutines
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

press_any_key__localfunc() {
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
    local inputVal=${1}

    #Define local variable
    local last2Chars=`echo ${inputVal: -2}`

    #Output
    echo ${last2Chars}
}

function cell__remove_whitespaces__func() {
    #Input args
    local orgstring=${1}
    
    #Remove white spaces
    local outputstring=`echo -e "${orgstring}" | tr -d "[:blank:]"`

    #OUTPUT
    echo ${outputstring}
}

docker__init_variables__sub() {
	docker__accept_mySource_dir=${DOCKER__EMPTYSTRING}
	docker__accept_mySource_fObject=${DOCKER__EMPTYSTRING}
	docker__accept_myDest_dir=${DOCKER__EMPTYSTRING}

	#Initialize variables to be used in function 'docker__get_source_destination_fpath__sub'
	#REMARK: this MUST be done here!
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
        docker__parent_dir="${DOCKER__SLASH_CHAR}"
    fi

	docker__root_sp7xxx_out_dir=/root/SP7021/out

	docker__dockercontainer_dirlist_fpath=${docker__current_dir}/${docker__dockercontainer_dirlist_filename}
	docker__localhost_dirlist_fpath=${docker__current_dir}/${docker__localhost_dirlist_filename}

	docker__bin_bash_dir=/bin/bash

	#Goto Next-Phase
	GOTO__func PHASE_CHOOSE_COPY_DIRECTION
}

docker__choose_copy_direction__sub() {
    echo -e "----------------------------------------------------------------------"
    echo -e "Copy ${DOCKER__FILES_FG_ORANGE}FILE${DOCKER__NOCOLOR}/${DOCKER__DIRS_FG_VERYLIGHTORANGE}FOLDER${DOCKER__NOCOLOR} From/To ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER${DOCKER__NOCOLOR}\t\tv21.03.17-0.0.1"
    echo -e "----------------------------------------------------------------------"
	echo -e "Choose copy direction:"
	echo -e "${DOCKER__FOUR_SPACES}1. ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER${DOCKER__NOCOLOR} > ${DOCKER__HOST_FG_GREEN85}HOST${DOCKER__NOCOLOR}"
	echo -e "${DOCKER__FOUR_SPACES}2. ${DOCKER__HOST_FG_GREEN85}HOST${DOCKER__NOCOLOR} > ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER${DOCKER__NOCOLOR}"
	echo -e "\r"

	while true
	do
		read -N1 -p "Choose an option: " docker__mycopychoice

		docker__mycopychoice=`cell__remove_whitespaces__func "${docker__mycopychoice}"`

		if [[ ! -z ${docker__mycopychoice} ]]; then
			if [[ ${docker__mycopychoice} =~ [1,2] ]]; then
				echo -e "\r"

				break  
			else
				echo -e "\r"
				echo -e "***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Invalid option '${docker__mycopychoice}'"

				press_any_key__localfunc

				tput cuu1
				tput el
				tput cuu1
				tput el
				tput cuu1
				tput el
				tput cuu1
				tput el
			fi
		else
			tput cuu1
			tput el
		fi
	done

	#MANDATORY: Initialize global variables
	docker__init_variables__sub


	#Goto Next-Phase
	GOTO__func PHASE_CHOOSE_CONTAINERID
}

docker__choose_containerid__sub() {
	#Initial setting
	docker__lastTwoChar=${DOCKER__EMPTYSTRING}

    #Get number of containers
    local numof_containers=`docker ps -a | head -n -1 | wc -l`

    #---Show Docker Image List
    echo -e "\r"
    echo -e "----------------------------------------------------------------------"
    echo -e "\t${DOCKER__GENERAL_FG_YELLOW}Create${DOCKER__NOCOLOR} Docker ${DOCKER__IMAGEID_FG_BORDEAUX}IMAGE${DOCKER__NOCOLOR} from ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER${DOCKER__NOCOLOR}"
    echo -e "----------------------------------------------------------------------"
        docker ps -a

        if [[ ${numof_containers} -eq 0 ]]; then
            echo -e "\r"
            echo -e "\t\t=:${DOCKER__ERROR_FG_LIGHTRED}NO CONTAINERS FOUND${DOCKER__NOCOLOR}:="
            echo -e "----------------------------------------------------------------------"
            echo -e "\r"

			press_any_key__localfunc

            exit
        else
            echo -e "----------------------------------------------------------------------"
        fi
    echo -e "\r"

	#Get the 'FIRST' Container-ID
	docker__myContainerId=`docker ps -a | awk '{print $1}' | head -n 2 | tail -n 1`

	while true
	do
		#Choose read-input command (depenging on the 'docker__myContainerId' value)
		if [[ -z ${docker__myContainerId} ]]; then	#is an Empty String
			read -e -p "${DOCKER__READINPUT_CONTAINERID}" docker__myContainerId
		else	#is NOT an Empty String
			read -e -p "${DOCKER__READINPUT_CONTAINERID}" -i ${docker__myContainerId} docker__myContainerId
		fi

		#Get the last-two-characters
		docker__lastTwoChar=`get_lastTwoChars_of_string__func "${docker__myContainerId}"`
		if [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_BACK} ]]; then
			echo -e "\r"

			docker__myContainerId=`echo ${docker__myContainerId} | sed -e "s/${docker__lastTwoChar}$//"`	#remove the last 2 char

			GOTO__func CHOOSE_COPY_DIRECTION

			break
		elif [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_CLEAR} ]]; then
			docker__myContainerId=${DOCKER__EMPTYSTRING}	#reset variable

			tput cuu1
			tput el
			tput cud1
			tput el
		fi

		if [[ ! -z ${docker__myContainerId} ]]; then
			#Remove any white-spaces
			docker__myContainerId=`cell__remove_whitespaces__func "${docker__myContainerId}"`
			#Check if 'docker__myContainerId' can be found in the 'container's list'
			docker__myContainerId_isFound=`docker ps -a | awk '{print $1}' | grep -w ${docker__myContainerId}`
			
			if [[ ! -z ${docker__myContainerId_isFound} ]]; then
				break         
			else
				echo -e "\r"
				echo -e "***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Invalid CONTAINER-ID: '${DOCKER__LIGHTRED}${docker__myContainerId}${DOCKER__NOCOLOR}'"

				press_any_key__localfunc

				tput cuu1
				tput el
				tput cuu1
				tput el
				tput cuu1
				tput el
				tput cuu1
				tput el
				tput cuu1
				tput el
			fi
		else
			tput cuu1
			tput el
		fi
	done

	#Goto Next-Phase
	GOTO__func PHASE_GET_SRC_DST_FPATH
}

docker__get_source_destination_fpath__sub() {
	#Initial phase
	docker__case_option=${DOCKER__CASE_SOURCE_DIR}

	#Define local variables
	local dirExists="false"
	local fObjectExists="false"
	local fPath=${DOCKER__EMPTYSTRING}

	if [[ ${docker__mycopychoice} -eq 1 ]]; then
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


		#---Summary
		echo -e "\r"
		echo -e "--------------------------------------------------------------------"
		echo "Overview:"
		echo -e "--------------------------------------------------------------------"
		if [[ ${docker__accept_mySource_fObject} == ${DOCKER__ASTERISK_CHAR} ]]; then
			echo "${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Source Full-path${DOCKER__NOCOLOR}: ${docker__accept_mySource_fPath}/*"
			echo "${DOCKER__HOST_FG_GREEN85}Destination Full-path${DOCKER__NOCOLOR}: ${docker__accept_myDest_fPath}"
		else
			echo "${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Source Full-path${DOCKER__NOCOLOR}: ${docker__accept_mySource_fPath}"
			echo "${DOCKER__HOST_FG_GREEN85}Destination Full-path${DOCKER__NOCOLOR}: ${docker__accept_myDest_fPath}"
		fi
		echo -e "\r"
	else
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

		#---Summary
		echo -e "\r"
		echo -e "--------------------------------------------------------------------"
		echo "Overview:"
		echo -e "--------------------------------------------------------------------"
		if [[ ${docker__accept_mySource_fObject} == ${DOCKER__ASTERISK_CHAR} ]]; then
			echo "${DOCKER__HOST_FG_GREEN85}Source Full-path${DOCKER__NOCOLOR}: ${docker__accept_mySource_fPath}/*"
			echo "${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Destination Full-path${DOCKER__NOCOLOR}: ${docker__accept_myDest_fPath}"
		else
			echo "${DOCKER__HOST_FG_GREEN85}Source Full-path${DOCKER__NOCOLOR}: ${docker__accept_mySource_fPath}"
			echo "${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Destination Full-path${DOCKER__NOCOLOR}: ${docker__accept_myDest_fPath}"
		fi
		echo -e "--------------------------------------------------------------------"
		echo -e "\r"
	fi

	#Goto Next-Phase
	GOTO__func PHASE_COPY_FROM_SRC_TO_DST
}
docker__container_get_source_dir__func()
{
	#Initial setting
	docker__lastTwoChar=${DOCKER__EMPTYSTRING}

	while true
	do
		#Print an Empty Line
		echo -e "\r"

		if [[ -z ${docker__mySource_dir} ]]; then	#is an Empty String
			read -p "${DOCKER__READINPUT_CONTAINER_SOURCE_DIR}" docker__mySource_dir
		else	#is NOT an Empty String
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

			tput cuu1
			tput el
			tput cud1
			tput el
		fi
		
		if [[ ! -z ${docker__mySource_dir} ]]; then
			dirExists=`docker__container_file_or_dir_exists__func "${docker__myContainerId}" "${docker__mySource_dir}"`
			if [[ ${dirExists} == "true" ]]; then
				docker__accept_mySource_dir=${docker__mySource_dir}

				docker__case_option=${DOCKER__CASE_SOURCE_FOBJECT}
				
				break
			else
				#Get directory contents list based on the specified directory 'docker__mySource_dir'
				docker__show_dirContent_handler__func "${docker__myContainerId}" "${docker__mySource_dir}"
			fi
		else
			tput cuu1
			tput el
			tput cud1
			tput el
		fi
	done
}
docker__container_get_source_fobject__func()
{
	#Initial setting
	docker__lastTwoChar=${DOCKER__EMPTYSTRING}

	while true
	do
		#Print an Empty Line
		echo -e "\r"
		
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

			tput cuu1
			tput el
			tput cud1
			tput el
		fi

		if [[ ! -z ${docker__mySource_fObject} ]]; then
			if [[ ${docker__mySource_fObject} == ${DOCKER__ASTERISK_CHAR} ]]; then
				docker__accept_mySource_fObject=${docker__mySource_fObject}

				docker__case_option=${DOCKER__CASE_DEST_DIR}

				break	#exit loop
			fi

			fPath="${docker__accept_mySource_dir}/${docker__mySource_fObject}"
			fObjectExists=`docker__container_file_or_dir_exists__func "${docker__myContainerId}" "${fPath}"`	
			if [[ ${fObjectExists} == "true" ]]; then
				docker__accept_mySource_fObject=${docker__mySource_fObject}

				docker__case_option=${DOCKER__CASE_DEST_DIR}

				break
			else
				#Get directory contents list based on the specified directory 'docker__accept_mySource_dir' and keyword 'docker__mySource_fObject'
				docker__show_dirContent_handler__func "${docker__myContainerId}" "${docker__accept_mySource_dir}/${docker__mySource_fObject}"
			fi
		else
			#Get directory contents list based on the specified directory 'docker__accept_mySource_dir' and keyword 'docker__mySource_fObject'
			docker__show_dirContent_handler__func "${docker__myContainerId}" "${docker__accept_mySource_dir}/${docker__mySource_fObject}"
		fi
	done
}
docker__host_get_dest_dir__func()
{
	#Initial setting
	docker__lastTwoChar=${DOCKER__EMPTYSTRING}

	while true
	do
		#Print an Empty Line
		echo -e "\r"

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

			tput cuu1
			tput el
			tput cud1
			tput el
		fi

		if [[ ! -z ${docker__myDest_dir} ]]; then
			
			dirExists=`docker__host_file_or_dir_exists__func "${docker__myDest_dir}"`
			if [[ ${dirExists} == "true" ]]; then
				docker__accept_myDest_dir=${docker__myDest_dir}

				docker__case_option=${DOCKER__CASE_DONE}

				break
			else
				#Get directory contents list based on the specified directory 'docker__myDest_dir'
				docker__show_dirContent_handler__func "${DOCKER__EMPTYSTRING}" "${docker__myDest_dir}"
			fi
		else
			tput cuu1
			tput el
			tput cud1
			tput el
		fi
	done
}
docker__host_get_source_dir__func()
{
	#Initial setting
	docker__lastTwoChar=${DOCKER__EMPTYSTRING}

	while true
	do
		#Print an Empty Line
		echo -e "\r"

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
			docker__accept_mySource_dir=${docker__mySource_dir}	#reset variable

			tput cuu1
			tput el
			tput cud1
			tput el
		fi
		
		if [[ ! -z ${docker__mySource_dir} ]]; then
			dirExists=`docker__host_file_or_dir_exists__func "${docker__mySource_dir}"`
			if [[ ${dirExists} == "true" ]]; then
				docker__accept_mySource_dir=${docker__mySource_dir}

				docker__case_option=${DOCKER__CASE_SOURCE_FOBJECT}
				
				break
			else
				#Get directory contents list based on the specified directory'docker__mySource_dir'
				docker__show_dirContent_handler__func "${DOCKER__EMPTYSTRING}" "${docker__mySource_dir}"
			fi
		else
			tput cuu1
			tput el
			tput cud1
			tput el
		fi
	done
}
docker__host_get_source_fobject__func()
{
	#Initial setting
	docker__lastTwoChar=${DOCKER__EMPTYSTRING}

	while true
	do
		#Print an Empty Line
		echo -e "\r"

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
			docker__accept_mySource_fObject=${docker__mySource_fObject}	#reset variable

			tput cuu1
			tput el
			tput cud1
			tput el
		fi

		if [[ ! -z ${docker__mySource_fObject} ]]; then
			if [[ ${docker__mySource_fObject} == ${DOCKER__ASTERISK_CHAR} ]]; then
				docker__accept_mySource_fObject=${docker__mySource_fObject}

				docker__case_option=${DOCKER__CASE_DEST_DIR}

				break	#exit loop
			fi

			fPath="${docker__accept_mySource_dir}/${docker__mySource_fObject}"
			fObjectExists=`docker__host_file_or_dir_exists__func "${fPath}"`	
			if [[ ${fObjectExists} == "true" ]]; then
				docker__accept_mySource_fObject=${docker__mySource_fObject}

				docker__case_option=${DOCKER__CASE_DEST_DIR}

				break
			else
				#Get directory contents list based on the specified directory 'docker__accept_mySource_dir' and keyword 'docker__mySource_fObject'
				docker__show_dirContent_handler__func "${DOCKER__EMPTYSTRING}" "${docker__accept_mySource_dir}/${docker__mySource_fObject}"
			fi
		else
			#Get directory contents list based on the specified directory 'docker__accept_mySource_dir' and keyword 'docker__mySource_fObject'
			docker__show_dirContent_handler__func "${DOCKER__EMPTYSTRING}" "${docker__accept_mySource_dir}/${docker__mySource_fObject}"
		fi
	done
}
docker__container_get_dest_dir__func()
{
	#Initial setting
	docker__lastTwoChar=${DOCKER__EMPTYSTRING}

	while true
	do
		#Print an Empty Line
		echo -e "\r"

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

			tput cuu1
			tput el
			tput cud1
			tput el
		fi

		if [[ ! -z ${docker__myDest_dir} ]]; then
			
			dirExists=`docker__container_file_or_dir_exists__func "${docker__myContainerId}" "${docker__myDest_dir}"`
			if [[ ${dirExists} == "true" ]]; then
				docker__accept_myDest_dir=${docker__myDest_dir}

				docker__case_option=${DOCKER__CASE_DONE}

				break
			else
				#Get directory contents list based on the specified directory'docker__mySource_dir'
				docker__show_dirContent_handler__func "${docker__myContainerId}" "${docker__myDest_dir}"
			fi
		else
			tput cuu1
			tput el
			tput cud1
			tput el
		fi
	done
}
docker__show_dirContent_handler__func()
{
	#Input args
	local myContainerId=${1}
	local dirInput=${2}

	#Get Parent directory
	local myParent_dir=${dirInput%/*}

	#Get file-/folder-object
	local myObject=`echo ${dirInput} | rev | cut -d"/" -f1 | rev`

	#Get directory content of 'myParent_dir'
	if [[ -z ${myContainerId} ]]; then
		if [[ -d ${myParent_dir} ]]; then	#directory exists
			${docker__localhost_dirlist_fpath} "${myParent_dir}" "${DOCKER__LISTVIEW_NUMOFROWS}" "${DOCKER__LISTVIEW_NUMOFCOLS}" "${myObject}"
		fi
	else
		#Define docker exec command which inclues '/bin/bash -c'
		local docker_exec_cmd="docker exec -it ${myContainerId} ${docker__bin_bash_dir} -c"
		
		local stdError=`${docker_exec_cmd} "ls -l ${myParent_dir} 2>&1 > /dev/null"`
		if [[ -z "${stdError}" ]]; then	#no error, thus directory exists
			${docker__dockercontainer_dirlist_fpath} "${myContainerId}" "${myParent_dir}" "${DOCKER__LISTVIEW_NUMOFROWS}" "${DOCKER__LISTVIEW_NUMOFCOLS}" "${myObject}"
		fi
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
			echo "false"
		else	#file does exist
			echo "true" 
		fi
	else	# directory does exist
		echo "true" 
	fi
}
function docker__container_file_or_dir_exists__func()
{
	#Input arg
	local myContainerID=${1}
	local myPath=${2}


	#Define local variables
	local error_isFound=`docker exec -it ${myContainerID} ls ${myPath} | grep "${DOCKER__CONTAINER_LIST_DIRECTORY_ERROR}"`

	#Check if directory exists
	if [[ ! -z ${error_isFound} ]]; then	#does NOT exist
		echo "false"
	else	#does exist
		echo "true" 
	fi
}

docker__compose_source_dest_fpath__sub()
{
	if [[ ${docker__accept_mySource_fObject} == ${DOCKER__ASTERISK_CHAR} ]]; then
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
		read -N1 -p "Do you wish to continue (${DOCKER__GENERAL_FG_YELLOW}y${DOCKER__NOCOLOR}/${DOCKER__GENERAL_FG_YELLOW}n${DOCKER__NOCOLOR}/${DOCKER__GENERAL_FG_YELLOW}b${DOCKER__NOCOLOR}/${DOCKER__GENERAL_FG_YELLOW}h${DOCKER__NOCOLOR})?" docker__myanswer

		docker__myanswer=`cell__remove_whitespaces__func "${docker__myanswer}"`

		if [[ ! -z ${docker__myanswer} ]]; then
			if [[ ${docker__myanswer} =~ [y,n,b,h] ]]; then
				break
			else
				echo -e "\r"	#add empty line (necessary to clean 'read' line)

				tput cuu1
				tput el
			fi
		else 
			tput cuu1
			tput el
		fi
	done
	echo -e "\r"

	#---Confirm answer and take action
	if [[ ${docker__myanswer} == "y" ]]; then
		echo -e "\r"
		echo -e "Copy in Progress... Please wait..."

		docker__copy_src_to_dst_handler__func
		
		echo -e "Copy completed..."
		echo -e "\r"
	elif [[ ${docker__myanswer} == "b" ]]; then
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
	local dirContent_list_string=${EMPTYSTRING}
	local dirContent_list_array=${EMPTYSTRING}
	local dirContent_list_arrayItem_raw=${EMPTYSTRING}
	local dirContent_list_arrayItem_clean=${EMPTYSTRING}
	local sourceFpath=${EMPTYSTRING}
	local destFpath=${EMPTYSTRING}

	#Define docker exec command which inclues '/bin/bash -c'
	local docker_exec_cmd="docker exec -it ${docker__myContainerId} ${docker__bin_bash_dir} -c"

	if [[ ${docker__mycopychoice} -eq 1 ]]; then
		if [[ ${docker__mySource_fObject} = ${DOCKER__ASTERISK_CHAR} ]]; then	#an asterisk was inputted for file-/folder-name
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
				echo -e "${DOCKER__FOUR_SPACES}copying: ${dirContent_list_arrayItem_clean}"

				#Compose Source and Destination Fullpath
				sourceFpath="${docker__accept_mySource_dir}/${dirContent_list_arrayItem_clean}"
				destFpath="${docker__accept_myDest_dir}/${dirContent_list_arrayItem_clean}"

				#Copy file or folder
				docker cp ${docker__myContainerId}:${sourceFpath} ${destFpath}
			done
		else
			#Print which file/folder will be copied
			echo -e "${DOCKER__FOUR_SPACES}copying: ${docker__accept_mySource_fObject}"

			docker cp ${docker__myContainerId}:${docker__accept_mySource_fPath} ${docker__accept_myDest_fPath}
		fi
	else
		if [[ ${docker__mySource_fObject} = ${DOCKER__ASTERISK_CHAR} ]]; then	#an asterisk was inputted for file-/folder-name
			#Get directory contents specified by 'docker__accept_mySource_dir'
			dirContent_list_string=`ls -1 ${docker__accept_mySource_dir}`	

			#Convert string to array
			dirContent_list_array=(`echo ${dirContent_list_string}`)

			#Cycle through array
			for dirContent_list_arrayItem_clean in "${dirContent_list_array[@]}"; do
				#Print which file/folder will be copied
				echo -e "${DOCKER__FOUR_SPACES}copying: ${dirContent_list_arrayItem_clean}"

				#Compose Source and Destination Fullpath
				sourceFpath="${docker__accept_mySource_dir}/${dirContent_list_arrayItem_clean}"
				destFpath="${docker__accept_myDest_dir}/${dirContent_list_arrayItem_clean}"

				#Copy file or folder
				docker cp ${sourceFpath} ${docker__myContainerId}:${destFpath}
			done
		else
			#Print which file/folder will be copied
			echo -e "${DOCKER__FOUR_SPACES}copying: ${docker__accept_mySource_fObject}"

			docker cp ${docker__accept_mySource_fPath} ${docker__myContainerId}:${docker__accept_myDest_fPath}
		fi
	fi	
}

docker__exit__sub()
{
	echo -e "\r"
	echo -e "Exiting now..."
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
