#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---NUMERIC CONSTANTS
DOCKER__LISTVIEW_NUMOFROWS=20
DOCKER__LISTVIEW_NUMOFCOLS=0

#---ENUM CONSTANTS
DOCKER__CONTAINER_TO_HOST=1
DOCKER__HOST_TO_CONTAINER=2



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



#---SUBROUTINES
docker__environmental_variables__sub() {
	#---Define PATHS
	docker__ispbooot_bin_filename="ISPBOOOT.BIN"

	docker__bin_bash_dir=/bin/bash
	docker__root_sp7xxx_out_dir=/root/SP7021/out

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

    docker__global_functions_filename="docker_global_functions.sh"
    docker__global_functions_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global_functions_filename}
}

docker__load_source_files__sub() {
    source ${docker__global_functions_fpath}
}

docker__load_header__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${DOCKER__BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__load_constants__sub() {
	#Has to be loaded after 'docker__load_source_files__sub'
	DOCKER__CASE_SOURCE_DIR="SOURCE DIR"
	DOCKER__CASE_SOURCE_FOBJECT="SOURCE FILENAME"
	DOCKER__CASE_DEST_DIR="DEST DIR"
	DOCKER__CASE_DONE="DONE"
	DOCKER__CONTAINER_LIST_DIRECTORY_ERROR="No such file or directory"

	DOCKER__READINPUT_H_OPTION="${DOCKER__FG_YELLOW}${DOCKER__SEMICOLON_HOME}${DOCKER__NOCOLOR}ome"
	DOCKER__READINPUT_B_OPTION="${DOCKER__FG_YELLOW}${DOCKER__SEMICOLON_BACK}${DOCKER__NOCOLOR}ack"
	DOCKER__READINPUT_C_OPTION="${DOCKER__FG_YELLOW}${DOCKER__SEMICOLON_CLEAR}${DOCKER__NOCOLOR}lear"
	DOCKER__READINPUT_B_C_OPTIONS="(${DOCKER__READINPUT_B_OPTION} ${DOCKER__READINPUT_C_OPTION})"
	DOCKER__READINPUT_H_B_C_OPTIONS="(${DOCKER__READINPUT_H_OPTION} ${DOCKER__READINPUT_B_OPTION} ${DOCKER__READINPUT_C_OPTION})"

	DOCKER__READINPUT_CONTAINERID="${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}:-:ID ${DOCKER__READINPUT_B_C_OPTIONS}: "

	DOCKER__READINPUT_CONTAINER_SOURCE_DIR="${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}:-:SOURCE-DIR ${DOCKER__READINPUT_H_B_C_OPTIONS}: "
	DOCKER__READINPUT_CONTAINER_SOURCE_FOBJECT="${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}:-:{FILE|FOLDER} ${DOCKER__READINPUT_H_B_C_OPTIONS}: "
	DOCKER__READINPUT_HOST_DEST_DIR="${DOCKER__FG_GREEN85}HOST${DOCKER__NOCOLOR}:-:DEST-DIR ${DOCKER__READINPUT_H_B_C_OPTIONS}: "

	DOCKER__READINPUT_HOST_SOURCE_DIR="${DOCKER__FG_GREEN85}HOST${DOCKER__NOCOLOR}:-:SOURCE-DIR ${DOCKER__READINPUT_H_B_C_OPTIONS}: "
	DOCKER__READINPUT_HOST_SOURCE_FOBJECT="${DOCKER__FG_GREEN85}HOST${DOCKER__NOCOLOR}:-:{FILE|FOLDER} ${DOCKER__READINPUT_H_B_C_OPTIONS}: "
	DOCKER__READINPUT_CONTAINER_DEST_DIR="${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}:-:DEST-DIR ${DOCKER__READINPUT_H_B_C_OPTIONS}: "
}

docker__init_variables__sub() {
	#Initialize variables for 'docker__readInput_w_autocomplete_fpath'
	docker__containerID_chosen=${DOCKER__EMPTYSTRING}
    
	docker__ps_a_cmd="docker ps -a"
    
	docker__ps_a_containerIdColno=1

	docker__onEnter_breakLoop=false
	docker__showTable=true

	#Initialize variables
	docker__get_initial_myContainerId_dfltVal_isAlreadyDone=${DOCKER__TRUE}

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

	docker__case_option=${DOCKER__EMPTYSTRING}
	docker__lastTwoChar=${DOCKER__EMPTYSTRING}
	docker__myanswer=${DOCKER__EMPTYSTRING}
	docker__mycopychoice=${DOCKER__EMPTYSTRING}

	docker__accept_mySource_dir=${DOCKER__EMPTYSTRING}
	docker__accept_mySource_fObject=${DOCKER__EMPTYSTRING}
	docker__accept_myDest_dir=${DOCKER__EMPTYSTRING}

	docker__prevDir=${DOCKER__EMPTYSTRING}

	#Assign values to specified variables (as mentioned below)
	#REMARK: these variables will be used in function 'get_source_destination_fpath__sub'
	#IMPORTANT: this MUST be done here!
	if [[ ${docker__mycopychoice} -eq ${DOCKER__CONTAINER_TO_HOST} ]]; then
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

docker__choose_copy_direction__sub() {
	#Define local message constants
	local MENUTITLE="Copy a ${DOCKER__FG_ORANGE}File${DOCKER__NOCOLOR} {From${DOCKER__FG_LIGHTGREY}|${DOCKER__NOCOLOR}To} a ${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}"

	#Define local read variables
	local readMsg="Your Choice: "

    #Show menu-title
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${MENUTITLE}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

	#Show menu-items
	echo -e "Choose copy direction:"
	echo -e "${DOCKER__FOURSPACES}1. ${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR} ${DOCKER__FG_LIGHTGREY}>${DOCKER__NOCOLOR} ${DOCKER__FG_GREEN85}HOST${DOCKER__NOCOLOR}"
	echo -e "${DOCKER__FOURSPACES}2. ${DOCKER__FG_GREEN85}HOST${DOCKER__NOCOLOR} ${DOCKER__FG_LIGHTGREY}>${DOCKER__NOCOLOR} ${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}"
	moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

	#Start loop
	while true
	do
		#Show read-input
		read -N1 -r -p "${readMsg}" docker__myanswer

		#Remove (white-)spaces
		docker__myanswer=`remove_whiteSpaces__func "${docker__myanswer}"`
		if [[ ! -z ${docker__myanswer} ]]; then
			if [[ ${docker__myanswer} == [1,2] ]]; then
				if [[ ${docker__myanswer} -eq 1 ]]; then
					docker__mycopychoice=${DOCKER__CONTAINER_TO_HOST}
				else
					docker__mycopychoice=${DOCKER__HOST_TO_CONTAINER}
				fi

				moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

				break
			else
				# Flush "stdin" with 0.1  sec timeout.
				read -rsn1 -t 0.1 tmp
				if [[ "$tmp" == "[" ]]; then
					# Flush "stdin" with 0.1  sec timeout.
					read -rsn1 -t 0.1 tmp
				fi

				#Clean up current line
				moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_0}"
			fi
		else
			moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
		fi
	done

	#Load constants
	docker__load_constants__sub

	#MANDATORY: Initialize global variables
	docker__init_variables__sub
}

docker__choose_containerid__sub() {
	#Define local message constants
	local MENUTITLE_CURRENT_REPOSITORY_LIST="Current ${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}-list"
    local ERRMSG_NO_CONTAINERS_FOUND="=:${DOCKER__FG_LIGHTRED}NO CONTAINERS FOUND${DOCKER__NOCOLOR}:="
	local ERRMSG_CHOSEN_CONTAINERID_DOESNOT_EXISTS="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Invalid input value "

	#Show read-input
		${docker__readInput_w_autocomplete_fpath} "${MENUTITLE_CURRENT_REPOSITORY_LIST}" \
                            "${DOCKER__READINPUT_CONTAINERID}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${ERRMSG_NO_CONTAINERS_FOUND}" \
                            "${ERRMSG_CHOSEN_CONTAINERID_DOESNOT_EXISTS}" \
                            "${docker__ps_a_cmd}" \
                            "${docker__ps_a_containerIdColno}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${docker__showTable}" \
                            "${docker__onEnter_breakLoop}"

	#Get the exitcode just in case a Ctrl-C was pressed in script 'docker__readInput_w_autocomplete_fpath'.
	docker__exitCode=$?
	if [[ ${docker__exitCode} -eq 99 ]]; then
		exit 99
	else
		#Retrieve the selected container-ID from file
		docker__myContainerId_input=`get_output_from_file__func "${docker__readInput_w_autocomplete_out_fpath}"`
	fi  

	#Retrieve the selected container-ID from file
	docker__containerID_chosen=`get_output_from_file__func "${docker__readInput_w_autocomplete_out_fpath}"`
	if [[ ${docker__containerID_chosen} == ${DOCKER__SEMICOLON_BACK} ]]; then
		moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

		#remove the last 2 char
		docker__containerID_chosen=${DOCKER__EMPTYSTRING}

		#Set next-phase
		GOTO__func CHOOSE_COPY_DIRECTION
	fi
}

get_source_destination_fpath__sub() {
	#Define local variables
	local sourceFpath_toBeShown=${DOCKER__EMPTYSTRING}
	local destFpath_toBeShown=${DOCKER__EMPTYSTRING}

	#Initial phase
	docker__case_option=${DOCKER__CASE_SOURCE_DIR}
	if [[ ${docker__mycopychoice} -eq ${DOCKER__CONTAINER_TO_HOST} ]]; then
		while true
		do
			case ${docker__case_option} in
				${DOCKER__CASE_SOURCE_DIR})
					#---SOURCE: Provide the Location of the file which you want to copy (located  at the Container!)
					docker__container2host_get_src_dir__sub
					;;

				${DOCKER__CASE_SOURCE_FOBJECT})
					#---SOURCE: Provide the file/folder which you want to copy (located at the Container!)
					container_get_source_fobject__func
					;;

				${DOCKER__CASE_DEST_DIR})
					#---DESTINATION: Provide the location where you want to copy to (located at the HOST!)
					host_get_dest_dir__func
					;;

				${DOCKER__CASE_DONE})
					break
					;;
			esac
		done


		#Compose Source and Destination Fullpath
		docker__compose_source_dest_fpath__sub

	else	#HOST -to- Container
		while true
		do
			case ${docker__case_option} in
				${DOCKER__CASE_SOURCE_DIR})
					#---SOURCE: Provide the location where you want to copy to (located at the HOST!)
					host_get_source_dir__func
					;;

				${DOCKER__CASE_SOURCE_FOBJECT})			
					#---SOURCE: Provide the file/folder which you want to copy (located  at the Container!)
					host_get_source_fobject__func
					;;

				${DOCKER__CASE_DEST_DIR})
					#---DESTINATION: Provide the Location of the file which you want to copy (located  at the Container!)
					container_get_dest_dir__func
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
	moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
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

	echo "${DOCKER__FG_GREEN85}Source Full-path${DOCKER__NOCOLOR}: ${sourceFpath_toBeShown}"
	echo "${DOCKER__FG_BRIGHTPRUPLE}Destination Full-path${DOCKER__NOCOLOR}: ${docker__accept_myDest_fPath}"

	duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
	moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
}

docker__container2host_get_src_dir__sub() {
	#Define local variables
	local dirExists=${DOCKER__FALSE}
	local numOf_dirContent=0

	#Initial setting
	docker__lastTwoChar=${DOCKER__EMPTYSTRING}

	while true
	do
		#Print an Empty Line
		# moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

		if [[ -z ${docker__mySource_dir} ]]; then	#contains NO data
			read -e -p "${DOCKER__READINPUT_CONTAINER_SOURCE_DIR}" docker__mySource_dir
		else	#contains data
			read -e -p "${DOCKER__READINPUT_CONTAINER_SOURCE_DIR}" -i "${docker__mySource_dir}" docker__mySource_dir
		fi

		docker__lastTwoChar=`get_lastTwoChars_of_string__func "${docker__mySource_dir}"`
		if [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_HOME} ]]; then	#goto HOME
			moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

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
			show_dirContent_handler__func "${docker__myContainerId_accept}" "${docker__mySource_dir}"

			dirExists=`container_file_or_dir_exists__func "${docker__myContainerId_accept}" "${docker__mySource_dir}"`
			if [[ ${dirExists} == ${DOCKER__TRUE} ]]; then

				numOf_dirContent=`calc_numOf_dirContent__func "${docker__myContainerId_accept}" "${docker__mySource_dir}"`
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
function container_get_source_fobject__func() {
	#Define local variables
	local fObjectExists=${DOCKER__FALSE}
	local sourceFpath=${DOCKER__EMPTYSTRING}

	#Initial setting
	docker__lastTwoChar=${DOCKER__EMPTYSTRING}

	while true
	do
		# #Print an Empty Line
		# moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
		
		if [[ -z ${docker__mySource_fObject} ]]; then	#is an Empty String
			read -e -p "${DOCKER__READINPUT_CONTAINER_SOURCE_FOBJECT}" docker__mySource_fObject
		else	#is NOT an Empty String
			read -e -p "${DOCKER__READINPUT_CONTAINER_SOURCE_FOBJECT}" -i "${docker__mySource_fObject}" docker__mySource_fObject
		fi

		docker__lastTwoChar=`get_lastTwoChars_of_string__func "${docker__mySource_fObject}"`
		if [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_HOME} ]]; then	#goto HOME
			moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

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
			fObjectExists=`container_file_or_dir_exists__func "${docker__myContainerId_accept}" "${sourceFpath}"`	
			if [[ ${fObjectExists} == ${DOCKER__TRUE} ]]; then	#full-path does exist
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

function host_get_dest_dir__func() {
	#Define local variables
	local dirExists=${DOCKER__FALSE}

	#Initial setting
	docker__lastTwoChar=${DOCKER__EMPTYSTRING}

	while true
	do
		# #Print an Empty Line
		# moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

		if [[ -z ${docker__myDest_dir} ]]; then	#is an Empty String
			read -e -p "${DOCKER__READINPUT_HOST_DEST_DIR}" docker__myDest_dir
		else	#is NOT an Empty String
			read -e -p "${DOCKER__READINPUT_HOST_DEST_DIR}" -i "${docker__myDest_dir}" docker__myDest_dir
		fi

		docker__lastTwoChar=`get_lastTwoChars_of_string__func "${docker__myDest_dir}"`
		if [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_HOME} ]]; then	#goto HOME
			moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

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
			show_dirContent_handler__func "${DOCKER__EMPTYSTRING}" "${docker__myDest_dir}"

			dirExists=`host_file_or_dir_exists__func "${docker__myDest_dir}"`
			if [[ ${dirExists} == ${DOCKER__TRUE} ]]; then
				docker__accept_myDest_dir=${docker__myDest_dir}

				docker__case_option=${DOCKER__CASE_DONE}

				break
			fi
		else
			moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
		fi
	done
}
function host_get_source_dir__func() {
	#Define local variables
	local dirExists=${DOCKER__FALSE}

	#Initial setting
	docker__lastTwoChar=${DOCKER__EMPTYSTRING}

	while true
	do
		# #Print an Empty Line
		# moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

		if [[ -z ${docker__mySource_dir} ]]; then	#is an Empty String
			read -e -p "${DOCKER__READINPUT_HOST_SOURCE_DIR}" docker__mySource_dir
		else	#is NOT an Empty String
			read -e -p "${DOCKER__READINPUT_HOST_SOURCE_DIR}" -i "${docker__mySource_dir}" docker__mySource_dir
		fi

		docker__lastTwoChar=`get_lastTwoChars_of_string__func "${docker__mySource_dir}"`
		if [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_HOME} ]]; then	#goto HOME
			moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

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
			show_dirContent_handler__func "${DOCKER__EMPTYSTRING}" "${docker__mySource_dir}"

			dirExists=`host_file_or_dir_exists__func "${docker__mySource_dir}"`
			if [[ ${dirExists} == ${DOCKER__TRUE} ]]; then

				numOf_dirContent=`calc_numOf_dirContent__func "${DOCKER__EMPTYSTRING}" "${docker__mySource_dir}"`
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
function host_get_source_fobject__func() {
	#Define local variables
	local fObjectExists=${DOCKER__FALSE}
	local sourceFpath=${DOCKER__EMPTYSTRING}

	#Initial setting
	docker__lastTwoChar=${DOCKER__EMPTYSTRING}

	while true
	do
		# #Print an Empty Line
		# moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

		if [[ -z ${docker__mySource_fObject} ]]; then	#is an Empty String
			read -e -p "${DOCKER__READINPUT_HOST_SOURCE_FOBJECT}" docker__mySource_fObject
		else	#is NOT an Empty String
			read -e -p "${DOCKER__READINPUT_HOST_SOURCE_FOBJECT}" -i "${docker__mySource_fObject}" docker__mySource_fObject
		fi

		docker__lastTwoChar=`get_lastTwoChars_of_string__func "${docker__mySource_fObject}"`
		if [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_HOME} ]]; then	#goto HOME
			moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

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
			fObjectExists=`host_file_or_dir_exists__func "${sourceFpath}"`	
			if [[ ${fObjectExists} == ${DOCKER__TRUE} ]]; then	#full-path does exist
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
function container_get_dest_dir__func() {
	#Define local variables
	local dirExists=${DOCKER__FALSE}

	#Initial setting
	docker__lastTwoChar=${DOCKER__EMPTYSTRING}

	while true
	do
		# #Print an Empty Line
		# moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

		if [[ -z ${docker__myDest_dir} ]]; then	#is an Empty String
			read -e -p "${DOCKER__READINPUT_CONTAINER_DEST_DIR}" docker__myDest_dir
		else	#is NOT an Empty String
			read -e -p "${DOCKER__READINPUT_CONTAINER_DEST_DIR}" -i "${docker__myDest_dir}" docker__myDest_dir
		fi

		docker__lastTwoChar=`get_lastTwoChars_of_string__func "${docker__myDest_dir}"`
		if [[ ${docker__lastTwoChar} == ${DOCKER__SEMICOLON_HOME} ]]; then	#goto HOME
			moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

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
			show_dirContent_handler__func "${docker__myContainerId_accept}" "${docker__myDest_dir}"

			dirExists=`container_file_or_dir_exists__func "${docker__myContainerId_accept}" "${docker__myDest_dir}"`
			if [[ ${dirExists} == ${DOCKER__TRUE} ]]; then
				docker__accept_myDest_dir=${docker__myDest_dir}

				docker__case_option=${DOCKER__CASE_DONE}

				break
			fi
		else
			moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
		fi
	done
}
function show_dirContent_handler__func() {
	#Input args
	local myContainerID=${1}
	local dirInput=${2}

	#Define local variable
	local keyWord=${DOCKER__EMPTYSTRING}	#no key-word (show all data in 'dirInput')

	#Get directory content of 'dirInput'
	if [[ -z ${myContainerID} ]]; then	#LOCAL machine (aka HOST)
		${docker__localhost_dirlist_fpath} "${dirInput}" "${DOCKER__LISTVIEW_NUMOFROWS}" "${DOCKER__LISTVIEW_NUMOFCOLS}" "${keyWord}"
	else	#REMOTE machine (aka Container)
		${docker__dockercontainer_dirlist_fpath} "${myContainerID}" "${dirInput}" "${DOCKER__LISTVIEW_NUMOFROWS}" "${DOCKER__LISTVIEW_NUMOFCOLS}" "${keyWord}"
	fi
}
function host_file_or_dir_exists__func() {
	#Input arg
	local myPath=${1}

	#Check if directory exists
	if [[ ! -d ${myPath} ]]; then	#directory does NOT exist
		#Maybe 'myPath' is a File
		if [[ ! -f ${myPath} ]]; then	#file does NOT exist
			echo ${DOCKER__FALSE}
		else	#file does exist
			echo ${DOCKER__TRUE} 
		fi
	else	# directory does exist
		echo ${DOCKER__TRUE} 
	fi
}
function container_file_or_dir_exists__func() {
	#Input arg
	local myContainerID=${1}
	local myPath=${2}

	#Define local variables
	local error_isFound=`docker exec -it ${myContainerID} ls ${myPath} | grep "${DOCKER__CONTAINER_LIST_DIRECTORY_ERROR}"`
	if [[ ! -z ${error_isFound} ]]; then	#directory does NOT exist
		echo ${DOCKER__FALSE}
	else	#directory does exist
		echo ${DOCKER__TRUE} 
	fi
}
function calc_numOf_dirContent__func() {
	#Input args
	local myContainerID=${1}
	local dirInput=${2}

	#Define local variables
	local dirContent_numOfItems_max_raw=${DOCKER__EMPTYSTRING}
	local dirContent_numOfItems_max=0
	
	local docker_exec_cmd="docker exec -it ${docker__containerID_chosen} ${docker__bin_bash_dir} -c"

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

docker__compose_source_dest_fpath__sub() {
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
		read -N1 -p "Do you wish to continue (${DOCKER__FG_YELLOW}y${DOCKER__NOCOLOR}es/${DOCKER__FG_YELLOW}n${DOCKER__NOCOLOR}o/${DOCKER__FG_YELLOW}r${DOCKER__NOCOLOR}edo/${DOCKER__FG_YELLOW}h${DOCKER__NOCOLOR}ome)?" docker__myanswer

		docker__myanswer=`remove_whiteSpaces__func "${docker__myanswer}"`

		if [[ ! -z ${docker__myanswer} ]]; then
			if [[ ${docker__myanswer} =~ [y,n,r,h] ]]; then
				break
			else
				# moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"	#add empty line (necessary to clean 'read' line)

				moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
				moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
			fi
		else 
			moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
		fi
	done
	moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

	#---Confirm answer and take action
	if [[ ${docker__myanswer} == "y" ]]; then
		moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
		echo -e "---${DOCKER__FG_ORANGE}START${DOCKER__NOCOLOR}: Copying Files/Folders"

		copy_src_to_dst_handler__func
		
		echo -e "---${DOCKER__FG_ORANGE}COMPLETED${DOCKER__NOCOLOR}: Copying Files/Folders"

		moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
	elif [[ ${docker__myanswer} == "r" ]]; then
		moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

		GOTO__func PHASE_GET_SRC_DST_FPATH

	elif [[ ${docker__myanswer} == "h" ]]; then
		moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

		GOTO__func PHASE_CHOOSE_COPY_DIRECTION

	else
		GOTO__func PHASE_EXIT
	fi
}

function copy_src_to_dst_handler__func() {
	#Define local variables
	local dirContent_list_string=${DOCKER__EMPTYSTRING}
	local dirContent_list_array=${DOCKER__EMPTYSTRING}
	local dirContent_list_arrayItem_raw=${DOCKER__EMPTYSTRING}
	local dirContent_list_arrayItem_clean=${DOCKER__EMPTYSTRING}
	local sourceFpath=${DOCKER__EMPTYSTRING}
	local destFpath=${DOCKER__EMPTYSTRING}

	#Define docker exec command which inclues '/bin/bash -c'
	local docker_exec_cmd="docker exec -it ${docker__myContainerId_accept} ${docker__bin_bash_dir} -c"

	if [[ ${docker__mycopychoice} -eq ${DOCKER__CONTAINER_TO_HOST} ]]; then
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

docker__exit__sub() {
	exit 0

	moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
	moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
}



#---MAIN SUBROUTINE
main__sub() {
	#Environmental variables must be defined and set first.
	docker__environmental_variables__sub

	#Then the source file(s) must be loaded.
	docker__load_source_files__sub

	#Goto FIRST-Phase
	GOTO__func PHASE_LOAD_HEADER



@PHASE_LOAD_HEADER:
    docker__load_header__sub

	#Goto Next-Phase
	GOTO__func PHASE_CHOOSE_COPY_DIRECTION



@PHASE_CHOOSE_COPY_DIRECTION:
	docker__choose_copy_direction__sub

	#Goto Next-Phase
	GOTO__func PHASE_CHOOSE_CONTAINERID



@PHASE_CHOOSE_CONTAINERID:
	docker__choose_containerid__sub

	#Goto Next-Phase
	GOTO__func PHASE_GET_SRC_DST_FPATH



@PHASE_GET_SRC_DST_FPATH:
	get_source_destination_fpath__sub
	
	#Goto Next-Phase
	GOTO__func PHASE_COPY_FROM_SRC_TO_DST



@PHASE_COPY_FROM_SRC_TO_DST:
	#Remark: the Next-Phase is determined in this function.
	docker__copy_src_to_dst__sub



@PHASE_EXIT:
	docker__exit__sub

}



#---EXECUTE MAIN
main__sub
