#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---SUBROUTINES
docker__environmental_variables__sub() {
    #Check the number of input args
    if [[ -z ${docker__global__fpath} ]]; then   #must be equal to 3 input args
        #---Defin FOLDER
        docker__LTPP3_ROOTFS__foldername="LTPP3_ROOTFS"
        docker__development_tools__foldername="development_tools"

        #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
        #... and read to array 'find_result_arr'
        #Remark:
        #   By using '2> /dev/null', the errors are not shown.
        readarray -t find_dir_result_arr < <(find  / -type d -iname "${docker__LTPP3_ROOTFS__foldername}" 2> /dev/null)

        #Define variable
        local find_path_of_LTPP3_ROOTFS=${DOCKER__EMPTYSTRING}

        #Loop thru array-elements
        for find_dir_result_arrItem in "${find_dir_result_arr[@]}"
        do
            #Update variable 'find_path_of_LTPP3_ROOTFS'
            find_path_of_LTPP3_ROOTFS="${find_dir_result_arrItem}/${docker__development_tools__foldername}"
            #Check if 'directory' exist
            if [[ -d "${find_path_of_LTPP3_ROOTFS}" ]]; then    #directory exists
                #Update variable
                docker__LTPP3_ROOTFS_development_tools__dir="${find_path_of_LTPP3_ROOTFS}"

                break
            fi
        done

        docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/
        docker__parentDir_of_LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS__dir%/*}    #move two directories up. This directory is the one-level higher than LTPP3_ROOTFS/

        docker__global__filename="docker_global.sh"
        docker__global__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__global__filename}
    fi

    docker__dockerfile_auto_filename="dockerfile_auto"
    docker__dockerfile_autogen_fpath=${DOCKER__EMPTYSTRING}
}

docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

docker__load_constants__sub() {
	#---CASE SELECTION CONSTANTS
	DOCKER__CASE_SRC_PATH=0
	DOCKER__CASE_DST_PATH=1
	DOCKER__CASE_DONE=2



	#---ENUM CONSTANTS
	DOCKER__CONTAINER_TO_HOST=1
	DOCKER__HOST_TO_CONTAINER=2



	#---MESSAGE CONSTANTS
	DOCKER__SOURCE="SRC"
	DOCKER__DESTINATION="DST"

	DOCKER__MENUTITLE="Copy {${DOCKER__FG_LIGHTGREY}from${DOCKER__NOCOLOR}|${DOCKER__FG_LIGHTGREY}to${DOCKER__NOCOLOR}} ${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}"
	DOCKER__SUMMARY_TITLE="${DOCKER__FG_REDORANGE}Summary${DOCKER__NOCOLOR}"

	# DOCKER__READINPUT_H_OPTION="${DOCKER__FG_YELLOW}${DOCKER__SEMICOLON_HOME}${DOCKER__NOCOLOR}ome"
	DOCKER__READINPUT_B_OPTION="${DOCKER__FG_YELLOW}${DOCKER__SEMICOLON_BACK}${DOCKER__NOCOLOR}ack"
	DOCKER__READINPUT_C_OPTION="${DOCKER__FG_YELLOW}${DOCKER__SEMICOLON_CLEAR}${DOCKER__NOCOLOR}lear"
	DOCKER__READINPUT_B_C_OPTIONS="(${DOCKER__READINPUT_B_OPTION} ${DOCKER__READINPUT_C_OPTION})"
	# DOCKER__READINPUT_H_B_C_OPTIONS="(${DOCKER__READINPUT_H_OPTION} ${DOCKER__READINPUT_B_OPTION} ${DOCKER__READINPUT_C_OPTION})"
	DOCKER__READINPUT_CONFIRM_OPTIONS="(${DOCKER__FG_YELLOW}y${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}"
	DOCKER__READINPUT_CONFIRM_OPTIONS+="${DOCKER__FG_YELLOW}n${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}"
	DOCKER__READINPUT_CONFIRM_OPTIONS+="${DOCKER__FG_YELLOW}p${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}"
	DOCKER__READINPUT_CONFIRM_OPTIONS+="${DOCKER__FG_YELLOW}i${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}"
	DOCKER__READINPUT_CONFIRM_OPTIONS+="${DOCKER__FG_YELLOW}h${DOCKER__NOCOLOR})"

	DOCKER__READINPUT_CONTAINERID="${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}:-:${DOCKER__NOCOLOR}${DOCKER__BG_BRIGHTPRUPLE}ID${DOCKER__NOCOLOR} ${DOCKER__READINPUT_B_C_OPTIONS}: "
	DOCKER__READINPUT_CONTAINER_SRC="${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}:-:${DOCKER__NOCOLOR}${DOCKER__BG_BRIGHTPRUPLE}Src${DOCKER__NOCOLOR}: "
	DOCKER__READINPUT_DO_YOU_WISH_TO_CONTINUE="Do you wish to continue ${DOCKER__READINPUT_CONFIRM_OPTIONS}?"
	DOCKER__READINPUT_HOST_DST="${DOCKER__FG_GREEN85}Local${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}:-:${DOCKER__NOCOLOR}${DOCKER__BG_GREEN85}Dst${DOCKER__NOCOLOR}: "
	DOCKER__READINPUT_HOST_SRC="${DOCKER__FG_GREEN85}Local${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}:-:${DOCKER__NOCOLOR}${DOCKER__BG_GREEN85}Src${DOCKER__NOCOLOR}: "
	DOCKER__READINPUT_CONTAINER_DST="${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}:-:${DOCKER__NOCOLOR}${DOCKER__BG_BRIGHTPRUPLE}Dst${DOCKER__NOCOLOR}: "

	DOCKER__DIRECTION_CONTAINER_TO_LOCAL="${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR} ${DOCKER__FG_LIGHTGREY}>${DOCKER__NOCOLOR} ${DOCKER__FG_GREEN85}Local${DOCKER__NOCOLOR}"
	DOCKER__DIRECTION_LOCAL_TO_CONTAINER="${DOCKER__FG_GREEN85}Local${DOCKER__NOCOLOR} ${DOCKER__FG_LIGHTGREY}>${DOCKER__NOCOLOR} ${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}"

	DOCKER__CONFIRMATION_REMARKS="${DOCKER__BG_ORANGE}Remarks:${DOCKER__NOCOLOR}\n"
	DOCKER__CONFIRMATION_REMARKS+="${DOCKER__FG_YELLOW}y${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}Yes${DOCKER__NOCOLOR}\n"
	DOCKER__CONFIRMATION_REMARKS+="${DOCKER__FG_YELLOW}n${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}No${DOCKER__NOCOLOR}\n"
	DOCKER__CONFIRMATION_REMARKS+="${DOCKER__FG_YELLOW}p${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}Reselect Path${DOCKER__NOCOLOR}\n"
	DOCKER__CONFIRMATION_REMARKS+="${DOCKER__FG_YELLOW}i${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}Reselect containerID${DOCKER__NOCOLOR}\n"
	DOCKER__CONFIRMATION_REMARKS+="${DOCKER__FG_YELLOW}h${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}Home${DOCKER__NOCOLOR}"

	DOCKER__COPY_DIRECTION_REMARKS="Choose copy direction:\n"
	DOCKER__COPY_DIRECTION_REMARKS+="${DOCKER__FOURSPACES}1. ${DOCKER__DIRECTION_CONTAINER_TO_LOCAL}\n"
	DOCKER__COPY_DIRECTION_REMARKS+="${DOCKER__FOURSPACES}2. ${DOCKER__DIRECTION_LOCAL_TO_CONTAINER}"

	DOCKER__PLEASE_SELECT_A_NON_EMPTY_SOURCE_FOLDER_FILE="Please select a non-empty source folder/file..."
	DOCKER__ECHOMSG_PLEASE_SELECT_A_VALID_DESTINATIONPATH="Please select a valid destination folder..."
}

docker__init_variables__sub() {
	docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

	#Variables for 'docker__readInput_w_autocomplete__fpath'
	# docker__ps_a_containerIdColno=1
	docker__onEnter_breakLoop=false
	docker__showTable=true

	#Case-selection variables
	docker__case_option=${DOCKER__CASE_SRC_PATH}

	#Message variables
	docker__summaryMsg=${DOCKER__EMPTYSTRING}
	docker__copy_msg=${DOCKER__EMPTYSTRING}

	#Misc variables
	docker__containerID_chosen=${DOCKER__EMPTYSTRING}
	docker__path_output=${DOCKER__EMPTYSTRING}

	docker__dst_dir=${DOCKER__EMPTYSTRING}
	docker__src_dir=${DOCKER__EMPTYSTRING}
	docker__src_file=${DOCKER__EMPTYSTRING}

	docker__dst_dir_print=${DOCKER__EMPTYSTRING}
	docker__src_dir_print=${DOCKER__EMPTYSTRING}

	docker__numOfMatches_output=0
	docker__exitCode=0
}

docker__choose_copy_direction__sub() {
	#Load constants
	docker__load_constants__sub

	#MANDATORY: Initialize global variables
	docker__init_variables__sub

	#Define local read variables
	local readMsg="Your Choice: "

    #Show menu-title
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${DOCKER__MENUTITLE}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

	#Show menu-items
	echo -e "${DOCKER__COPY_DIRECTION_REMARKS}"

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

				moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

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
}

docker__choose_containerid__sub() {
	#Show read-input
	${docker__readInput_w_autocomplete__fpath} "${DOCKER__MENUTITLE_CONTAINERLIST}" \
						"${DOCKER__READINPUT_CONTAINERID}" \
						"${DOCKER__EMPTYSTRING}" \
						"${DOCKER__EMPTYSTRING}" \
						"${DOCKER__ERRMSG_NO_CONTAINERS_FOUND}" \
						"${DOCKER__ERRMSG_CHOSEN_CONTAINERID_DOESNOT_EXISTS}" \
						"${docker__ps_a_cmd}" \
						"${docker__ps_a_containerIdColno}" \
						"${DOCKER__EMPTYSTRING}" \
						"${docker__showTable}" \
						"${docker__onEnter_breakLoop}" \
						"${docker__tibboHeader_prepend_numOfLines}"



    #Get the exit-code just in case:
    #   1. Ctrl-C was pressed in script 'docker__readInput_w_autocomplete__fpath'.
    #   2. An error occured in script 'docker__readInput_w_autocomplete__fpath',...
    #      ...and exit-code = 99 came from function...
    #      ...'show_msg_w_menuTitle_w_pressAnyKey_w_ctrlC_func' (in script: docker__global.sh).
	docker__exitCode=$?
	if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
		exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_0}"
	else
		#Get the result
		docker__containerID_chosen=`get_output_from_file__func \
						"${docker__readInput_w_autocomplete_out__fpath}" \
						"${DOCKER__LINENUM_1}"`
	fi  

	if [[ ${docker__containerID_chosen} == ${DOCKER__SEMICOLON_BACK} ]]; then
		moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

		#remove the last 2 char
		docker__containerID_chosen=${DOCKER__EMPTYSTRING}

		#Set next-phase
		goto__func CHOOSE_COPY_DIRECTION
	fi

	#Move-up and clean (corrective action)
	moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
}

docker__dirlist_show_dirContent_handler__sub() {
	#---------------------------------------------------------------------	
	#This subroutine is copied from the script 'dirlist_readInput_w_autocomplete.sh'
	#---------------------------------------------------------------------
	#Input args
	local containerID__input=${1}
	local dir__input=${2}

    #Move down one line
    # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    #Show directory content
	if [[ -z ${containerID__input} ]]; then	#LOCAL machine (aka HOST)
		${dclcau_lh_ls__fpath} "${dir__input}" \
						"${DOCKER__TABLEROWS_20}" \
						"${DOCKER__TABLECOLS_0}" \
						"${DOCKER__EMPTYSTRING}" \
						"${DOCKER__EMPTYSTRING}" \
						"${DOCKER__NUMOFLINES_2}"
	else	#REMOTE machine (aka Container)
		${dclcau_dc_ls__fpath} \
						"${containerID__input}" \
						"${dir__input}" \
						"${DOCKER__TABLEROWS_20}" \
						"${DOCKER__TABLECOLS_0}" \
						"${DOCKER__EMPTYSTRING}" \
						"${DOCKER__EMPTYSTRING}" \
						"${DOCKER__NUMOFLINES_2}"
	fi
}

docker__path_selection_handler__sub() {
	#Define local variables
	local srcFullpath_print=${DOCKER__EMPTYSTRING}
	local dstFullpath_print=${DOCKER__EMPTYSTRING}

	case "${docker__mycopychoice}" in
		${DOCKER__CONTAINER_TO_HOST})
			while true
			do
				case "${docker__case_option}" in
					${DOCKER__CASE_SRC_PATH})
						#---SOURCE: Provide the Location of the file which you want to copy (located  at the Container!)
						docker__src_path_selection__sub "${docker__containerID_chosen}"
						;;

					${DOCKER__CASE_DST_PATH})
						#---DESTINATION: Provide the location where you want to copy to (located at the HOST!)
						docker__dst_path_selection__sub "${DOCKER__EMPTYSTRING}"
						;;

					${DOCKER__CASE_DONE})
						break
						;;
				esac
			done
			;;
		${DOCKER__HOST_TO_CONTAINER})
			while true
			do
				case "${docker__case_option}" in
					${DOCKER__CASE_SRC_PATH})
						#---SOURCE: Provide the location where you want to copy to (located at the HOST!)
						docker__src_path_selection__sub "${DOCKER__EMPTYSTRING}"
						;;

					${DOCKER__CASE_DST_PATH})
						#---DESTINATION: Provide the Location of the file which you want to copy (located  at the Container!)
						docker__dst_path_selection__sub "${docker__containerID_chosen}"
						;;

					${DOCKER__CASE_DONE})
						break
						;;
						
				esac
			done
			;;
	esac
}

docker__src_path_selection__sub() {
	#Input args
	local containerID__input=${1}

	#Define variables
	local asterisk_isFound=false
	local fileExists=false

	#Show and select path
	${dirlist__readInput_w_autocomplete__fpath} "${containerID__input}" \
						"${DOCKER__EMPTYSTRING}" \
						"${DOCKER__READINPUT_CONTAINER_SRC}" \
						"${DOCKER__DIRLIST_REMARKS_EXTENDED}" \
                        "${dirlist__src_ls_1aA_output__fpath}" \
                        "${dirlist__src_ls_1aA_tmp__fpath}" \
						"${DOCKER__EMPTYSTRING}" \
						"${DOCKER__NUMOFLINES_2}"

	#Get the exitcode just in case a Ctrl-C was pressed in script 'dirlist__readInput_w_autocomplete__fpath'.
	docker__exitCode=$?
	if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
		exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_0}"
	else
		#Get the result
		docker__path_output=`get_output_from_file__func "${dirlist__readInput_w_autocomplete_out__fpath}" "${DOCKER__LINENUM_1}"`
		docker__numOfMatches_output=`get_output_from_file__func "${dirlist__readInput_w_autocomplete_out__fpath}" "${DOCKER__LINENUM_2}"`
	fi

	#Check if 'docker__path_output' is an Empty String
	if [[ -z ${docker__path_output} ]]; then
		#Set case-selection
		docker__case_option=${DOCKER__CASE_SRC_PATH}

		#Print
		show_msg_only__func "${DOCKER__PLEASE_SELECT_A_NON_EMPTY_SOURCE_FOLDER_FILE}" "${DOCKER__NUMOFLINES_2}"

		return
	fi

	#Check if 'docker__numOfMatches_output' is '0' (that means no results found)
	if [[ ${docker__numOfMatches_output} -eq 0 ]]; then
		#Set case-selection
		docker__case_option=${DOCKER__CASE_SRC_PATH}

		#Print
		show_msg_only__func "${DOCKER__PLEASE_SELECT_A_NON_EMPTY_SOURCE_FOLDER_FILE}" "${DOCKER__NUMOFLINES_2}"

		return
	fi

	#Handle 'Back' and 'Home'
	if [[ ${docker__path_output} == ${DOCKER__SEMICOLON_HOME} ]]; then
		moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

		goto__func PHASE_CHOOSE_COPY_DIRECTION
	elif [[ ${docker__path_output} == ${DOCKER__SEMICOLON_BACK} ]]; then
		moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

		goto__func PHASE_CHOOSE_CONTAINERID
	fi

	#Update 'docker__src_dir' and 'docker__src_file'
	#Check if 'docker__path_output' contains an 'asterisk'
	asterisk_isFound=`checkForMatch_of_pattern_within_string__func "${DOCKER__ASTERISK}" "${docker__path_output}"`
	if [[ ${asterisk_isFound} == true ]]; then	#asterisk was found
		docker__src_dir=`get_dirname_from_specified_path__func "${docker__path_output}"`

		#Set 'docker__src_file' to 'asterisk'
		#Remark:
		#	Output file 'dirlist__src_ls_1aA_output__fpath', which holds the contents of
		#	...of directory 'docker__src_dir', will be used as reference when...
		#	...copying from source to destination.
		docker__src_file=`get_basename_from_specified_path__func "${docker__path_output}"`
	else	#no asterisk found
		#Check if 'docker__path_output' is a file
		fileExists=`checkIf_file_exists__func "${containerID__input}" "${docker__path_output}"`
		if [[ ${fileExists} == true ]]; then	#file exists
			docker__src_dir=`get_dirname_from_specified_path__func "${docker__path_output}"`
			docker__src_file=`get_basename_from_specified_path__func "${docker__path_output}"`
		else	#file does not exist or not a file
			#Check if 'docker__path_output' is a directory
			dirExists=`checkIf_dir_exists__func "${containerID__input}" "${docker__path_output}"`
			if [[ ${dirExists} == true ]]; then	#is a directory
				docker__src_dir=${docker__path_output}

				#Set 'docker__src_file' to 'asterisk'
				#Remark:
				#	This means that 'dirlist__src_ls_1aA_output__fpath', which contains the files & folders
				#		of directory 'docker__src_dir', will be used as reference when copying from source to destination.
				docker__src_file=${DOCKER__ASTERISK}
			else	#is NOT a directory
				#Move-up cursor to correct position
				moveUp__func "${DOCKER__NUMOFLINES_2}"

				#Show directory contents
				docker__dirlist_show_dirContent_handler__sub "${containerID__input}" \
						"${docker__path_output}"

				#Print
				show_msg_only__func "${DOCKER__PLEASE_SELECT_A_NON_EMPTY_SOURCE_FOLDER_FILE}" "${DOCKER__NUMOFLINES_2}"

				#Reset variables
				docker__src_dir=${DOCKER__EMPTYSTRING}
				docker__src_file=${DOCKER__EMPTYSTRING}

				#Set case-selection
				docker__case_option=${DOCKER__CASE_SRC_PATH}

				return
			fi
		fi
	fi
	
#---Update variable
	docker__src_dir_print=${docker__src_dir}${docker__src_file}

	#Set case-selection
	docker__case_option=${DOCKER__CASE_DST_PATH}
}

docker__dst_path_selection__sub() {
	#Input args
	local containerID__input=${1}

	#Define variables
	# local asterisk_isFound=false
	# local fileExists=false

	#Show and select path
	${dirlist__readInput_w_autocomplete__fpath} "${containerID__input}" \
						"${DOCKER__EMPTYSTRING}" \
						"${DOCKER__READINPUT_HOST_DST}" \
						"${DOCKER__DIRLIST_REMARKS_EXTENDED}" \
                        "${dirlist__dst_ls_1aA_output__fpath}" \
                        "${dirlist__dst_ls_1aA_tmp__fpath}" \
						"${DOCKER__EMPTYSTRING}" \
						"${DOCKER__NUMOFLINES_2}"


	#Get the exitcode just in case a Ctrl-C was pressed in script 'dirlist__readInput_w_autocomplete__fpath'.
	docker__exitCode=$?
	if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
		exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_2}"
	else
		#Get the result
		docker__path_output=`get_output_from_file__func "${dirlist__readInput_w_autocomplete_out__fpath}" "${DOCKER__LINENUM_1}"`
		docker__numOfMatches_output=`get_output_from_file__func "${dirlist__readInput_w_autocomplete_out__fpath}" "${DOCKER__LINENUM_2}"`
	fi

	#Check if 'docker__path_output' is an Empty String
	if [[ -z ${docker__path_output} ]]; then
		#Set case-selection
		docker__case_option=${DOCKER__CASE_DST_PATH}

		#Print
		show_msg_only__func "${DOCKER__ECHOMSG_PLEASE_SELECT_A_VALID_DESTINATIONPATH}" "${DOCKER__NUMOFLINES_2}"

		return
	fi

	#Handle 'Back' and 'Home'
	if [[ ${docker__path_output} == ${DOCKER__SEMICOLON_HOME} ]]; then
		moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_3}"

		goto__func PHASE_CHOOSE_COPY_DIRECTION
	elif [[ ${docker__path_output} == ${DOCKER__SEMICOLON_BACK} ]]; then
		moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

		docker__case_option=${DOCKER__CASE_SRC_PATH}

		return
	fi

	#Check if 'docker__path_output' is a directory
	dirExists=`checkIf_dir_exists__func "${containerID__input}" "${docker__path_output}"`
	if [[ ${dirExists} == true ]]; then	#is a directory
		docker__dst_dir=${docker__path_output}
	else	#is NOT a directory
		#Move-up cursor to correct position
		moveUp__func "${DOCKER__NUMOFLINES_2}"

		#Show directory contents
		docker__dirlist_show_dirContent_handler__sub "${containerID__input}" "${docker__path_output}"

		#Print
		show_msg_only__func "${DOCKER__ECHOMSG_PLEASE_SELECT_A_VALID_DESTINATIONPATH}" "${DOCKER__NUMOFLINES}"

		#Reset variables
		docker__dst_dir=${DOCKER__EMPTYSTRING}

		#Set case-selection
		docker__case_option=${DOCKER__CASE_DST_PATH}

		return
	fi

#---Update variable
	docker__dst_dir_print=${docker__dst_dir}

	#Set case-selection
	docker__case_option=${DOCKER__CASE_DONE}
}


docker__show_summary__sub() {
	#Compose 'docker__summaryMsg'
	if [[ ${docker__mycopychoice} == ${DOCKER__CONTAINER_TO_HOST} ]]; then
		docker__summaryMsg="Direction:\t${DOCKER__FG_LIGHTGREY}${DOCKER__DIRECTION_CONTAINER_TO_LOCAL}${DOCKER__NOCOLOR}\n"
	else
		docker__summaryMsg="Direction:\t${DOCKER__FG_LIGHTGREY}${DOCKER__DIRECTION_LOCAL_TO_CONTAINER}${DOCKER__NOCOLOR}\n"
	fi
	docker__summaryMsg+="Source:\t\t${DOCKER__FG_LIGHTGREY}${docker__src_dir_print}${DOCKER__NOCOLOR}\n"
	docker__summaryMsg+="Destination:\t${DOCKER__FG_LIGHTGREY}${docker__dst_dir_print}${DOCKER__NOCOLOR}"

	#Show summary
	show_msg_w_menuTitle_only_func "${DOCKER__SUMMARY_TITLE}" \
						"${docker__summaryMsg}" \
						"${DOCKER__ZEROSPACE}" \
						"${DOCKER__NUMOFLINES_0}" \
						"${DOCKER__NUMOFLINES_0}" \
						"${DOCKER__NUMOFLINES_0}" \
						"${DOCKER__NUMOFLINES_2}"
}

docker__confirmation__sub() {
	#Show remarks
	show_msg_only__func "${DOCKER__CONFIRMATION_REMARKS}" "${DOCKER__NUMOFLINES_0}"

	while true
	do
		read -N1 -p "${DOCKER__READINPUT_DO_YOU_WISH_TO_CONTINUE}" docker__myanswer

		if [[ ! -z ${docker__myanswer} ]]; then	#contains data
			if [[ ${docker__myanswer} =~ [ynpih] ]]; then
				#Move-down cursor
				# moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

				case "${docker__myanswer}" in
					y)
						moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

						goto__func PHASE_COPY_FROM_SRC_TO_DST
						;;
					n)
						docker__exit_numOfLines=${DOCKER__NUMOFLINES_2}

						goto__func PHASE_EXIT
						;;
					p)
						moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
	
						docker__case_option=${DOCKER__CASE_SRC_PATH}

						goto__func PHASE_GET_SRC_DST_FPATH
						;;
					i)
						moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

						goto__func PHASE_CHOOSE_CONTAINERID
						;;
					h)
						moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

						goto__func PHASE_CHOOSE_COPY_DIRECTION
						;;
				esac
			else
				if [[ ${docker__myanswer} == ${DOCKER__ENTER} ]]; then	#ENTER was pressed
					moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
				else	#any other keys were pressed
					moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"
				fi
			fi
		else 	#contains no data
			moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
		fi
	done
}

docker__copy_from_src_to_dst__sub() {
	#Define variables
	local asterisk_isFound=false
	local line=${DOCKER__EMPTYSTRING}
	local src_path=${DOCKER__EMPTYSTRING}
	local dst_path=${DOCKER__EMPTYSTRING}

	#Compose 'docker__copy_msg'
	docker__copy_msg="Container-ID: ${DOCKER__FG_LIGHTGREY}${docker__containerID_chosen}${DOCKER__NOCOLOR}\n"
	docker__copy_msg+="Source: ${DOCKER__FG_LIGHTGREY}${docker__src_dir}${DOCKER__NOCOLOR}\n"
	docker__copy_msg+="Destination: ${DOCKER__FG_LIGHTGREY}${docker__dst_dir}${DOCKER__NOCOLOR}"

	#Check if 'asterisk' is found (MUST BE DONE HERE!)
	asterisk_isFound=`checkForMatch_of_pattern_within_string__func "${DOCKER__ASTERISK}" "${docker__src_file}"`

	if [[ ${docker__mycopychoice} -eq ${DOCKER__CONTAINER_TO_HOST} ]]; then	#Container to Local Host
		#Show Title
		show_msg_w_menuTitle_only_func "${DOCKER__DIRECTION_CONTAINER_TO_LOCAL}" \
							"${docker__copy_msg}" \
							"${DOCKER__ZEROSPACE}" \
							"${DOCKER__NUMOFLINES_0}" \
							"${DOCKER__NUMOFLINES_0}" \
							"${DOCKER__NUMOFLINES_0}" \
							"${DOCKER__NUMOFLINES_2}"

		if [[ ${asterisk_isFound} == true ]]; then	#asterisk is found
			while read -r line
			do
				src_path="${docker__src_dir}/${line}"

				docker cp ${docker__containerID_chosen}:${src_path} ${docker__dst_dir}

				echo "...copied ${DOCKER__FG_LIGHTGREY}${line}${DOCKER__NOCOLOR}"
			done < ${dirlist__src_ls_1aA_output__fpath}
		else	#asterisk is NOT found
			src_path="${docker__src_dir}/${docker__src_file}"

			docker cp ${docker__containerID_chosen}:${src_path} ${docker__dst_dir}

			echo "...copied ${DOCKER__FG_LIGHTGREY}${docker__src_file}${DOCKER__NOCOLOR}"
		fi	
	else	#Local Host to Container
		#Show Title
		show_msg_w_menuTitle_only_func "${DOCKER__DIRECTION_LOCAL_TO_CONTAINER}" \
							"${docker__copy_msg}" \
							"${DOCKER__ZEROSPACE}" \
							"${DOCKER__NUMOFLINES_0}" \
							"${DOCKER__NUMOFLINES_0}" \
							"${DOCKER__NUMOFLINES_0}" \
							"${DOCKER__NUMOFLINES_2}"

		if [[ ${asterisk_isFound} == true ]]; then	#asterisk is found
			while read -r line
			do
				src_path="${docker__src_dir}/${line}"

				docker cp ${src_path} ${docker__containerID_chosen}:${docker__dst_dir}

				echo "...copied ${DOCKER__FG_LIGHTGREY}${line}${DOCKER__NOCOLOR}"
			done < ${dirlist__src_ls_1aA_output__fpath}
		else	#asterisk is NOT found
			src_path="${docker__src_dir}/${docker__src_file}"

			docker cp ${src_path} ${docker__containerID_chosen}:${docker__dst_dir}

			echo "...copied ${DOCKER__FG_LIGHTGREY}${docker__src_file}${DOCKER__NOCOLOR}"
		fi	
	fi
}


docker__exit__sub() {
	exit__func "${DOCKER__EXITCODE_0}" "${docker__exit_numOfLines}"
}



#---MAIN SUBROUTINE
main__sub() {
	#Then the source file(s) must be loaded.
	docker__load_source_files__sub

	#Disable EXPANSION
	#Remark:
	#	This is necessary, because otherwise an asterisk '*' won't be treated as a character.
	disable_expansion__func

	#Environmental variables must be defined and set first.
	docker__environmental_variables__sub

	#Goto FIRST-Phase
	goto__func PHASE_START



@PHASE_START:
	docker__tibboHeader_prepend_numOfLines="${DOCKER__NUMOFLINES_2}"

	#Goto Next-Phase
	goto__func PHASE_CHOOSE_COPY_DIRECTION



@PHASE_CHOOSE_COPY_DIRECTION:
	load_tibbo_title__func "${docker__tibboHeader_prepend_numOfLines}"

	docker__choose_copy_direction__sub

	#Goto Next-Phase
	goto__func PHASE_CHOOSE_CONTAINERID



@PHASE_CHOOSE_CONTAINERID:
	docker__choose_containerid__sub

	#Set case-selection
	docker__case_option=${DOCKER__CASE_SRC_PATH}

	#Goto Next-Phase
	goto__func PHASE_GET_SRC_DST_FPATH



@PHASE_GET_SRC_DST_FPATH:
	docker__path_selection_handler__sub
	
	#Goto Next-Phase
	goto__func PHASE_SHOW_SUMMARY



@PHASE_SHOW_SUMMARY:
	docker__show_summary__sub

	#Goto Next-Phase
	goto__func PHASE_CONFIRMATION



@PHASE_CONFIRMATION:
	docker__confirmation__sub



@PHASE_COPY_FROM_SRC_TO_DST:
	#Remark: the Next-Phase is determined in this function.
	docker__copy_from_src_to_dst__sub

	#Set 'docker__exit_numOfLines'
	docker__exit_numOfLines=${DOCKER__NUMOFLINES_1}

	#Goto Next-Phase
	goto__func PHASE_EXIT



@PHASE_EXIT:
	#Remark:
	#	'enable_expansion__func' is already done in exit__func)

	docker__exit__sub

}



#---EXECUTE MAIN
main__sub
