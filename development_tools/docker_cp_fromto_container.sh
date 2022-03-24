#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---SUBROUTINES
docker__environmental_variables__sub() {
	#---Define PATHS
	docker__ispbooot_bin_filename="ISPBOOOT.BIN"

	docker__bin_bash_dir=/bin/bash
	docker__root_sp7xxx_out_dir=/root/SP7021/out

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

    DOCKER__DIRLIST_REMARKS="${DOCKER__BG_ORANGE}Remarks:${DOCKER__NOCOLOR}\n"
    DOCKER__DIRLIST_REMARKS+="${DOCKER__DASH} append ${DOCKER__FG_YELLOW}/${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}to list directory${DOCKER__NOCOLOR} (e.g. ${DOCKER__FG_LIGHTGREY}/etc${DOCKER__NOCOLOR}${DOCKER__FG_YELLOW}/${DOCKER__NOCOLOR})\n"
	DOCKER__DIRLIST_REMARKS+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}ENTER${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}to confirm${DOCKER__NOCOLOR}\n"
    DOCKER__DIRLIST_REMARKS+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}TAB${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}auto-complete${DOCKER__NOCOLOR}\n"
    DOCKER__DIRLIST_REMARKS+="${DOCKER__DASH} ${DOCKER__FG_YELLOW};b${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}back${DOCKER__NOCOLOR}\n"
    DOCKER__DIRLIST_REMARKS+="${DOCKER__DASH} ${DOCKER__FG_YELLOW};c${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}clear${DOCKER__NOCOLOR}\n"
    DOCKER__DIRLIST_REMARKS+="${DOCKER__DASH} ${DOCKER__FG_YELLOW};h${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}home${DOCKER__NOCOLOR}"

	DOCKER__ECHOMSG_PLEASE_SELECT_A_SOURCEPATH_WHICH_CONTAINS_DATA="Please select valid source folder/file..."
	DOCKER__ECHOMSG_PLEASE_SELECT_A_VALID_DESTINATIONPATH="Please select a valid destination folder..."



	#---NUMERIC CONSTANTS
	DOCKER__LISTVIEW_NUMOFROWS=20
	DOCKER__LISTVIEW_NUMOFCOLS=0
}

docker__init_variables__sub() {
	#Variables for 'docker__readInput_w_autocomplete__fpath'
	docker__ps_a_containerIdColno=1
	docker__onEnter_breakLoop=false
	docker__showTable=true

	#Case-selection variables
	docker__case_option=${DOCKER__CASE_SRC_PATH}

	#Message variables
	docker__summary_msg=${DOCKER__EMPTYSTRING}
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
}

docker__choose_containerid__sub() {
	#Define local message constants
	local MENUTITLE_CURRENT_REPOSITORY_LIST="Current ${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}-list"
    local ERRMSG_NO_CONTAINERS_FOUND="=:${DOCKER__FG_LIGHTRED}NO CONTAINERS FOUND${DOCKER__NOCOLOR}:="
	local ERRMSG_CHOSEN_CONTAINERID_DOESNOT_EXISTS="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Invalid input value "

	#Show read-input
	${docker__readInput_w_autocomplete__fpath} "${MENUTITLE_CURRENT_REPOSITORY_LIST}" \
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

	#Get the exitcode just in case a Ctrl-C was pressed in script 'docker__readInput_w_autocomplete__fpath'.
	docker__exitCode=$?
	if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
		docker__exitFunc "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
	else
		#Retrieve the selected container-ID from file
		docker__containerID_chosen=`get_output_from_file__func \
						"${docker__readInput_w_autocomplete_out__fpath}" \
						"${DOCKER__LINENUM_1}"`
	fi  

	if [[ ${docker__containerID_chosen} == ${DOCKER__SEMICOLON_BACK} ]]; then
		moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

		#remove the last 2 char
		docker__containerID_chosen=${DOCKER__EMPTYSTRING}

		#Set next-phase
		GOTO__func CHOOSE_COPY_DIRECTION
	fi
}

docker__dirlist_show_dirContent_handler__sub() {
	#---------------------------------------------------------------------	
	#This subroutine is copied from the script 'dirlist_readInput_w_autocomplete.sh'
	#---------------------------------------------------------------------
	#Input args
	local containerID__input=${1}
	local dir__input=${2}

    #Move down one line
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    #Show directory content
	if [[ -z ${containerID__input} ]]; then	#LOCAL machine (aka HOST)
		${dclcau_lh_ls__fpath} "${dir__input}" \
						"${DOCKER__LISTVIEW_NUMOFROWS}" \
						"${DOCKER__LISTVIEW_NUMOFCOLS}" \
						"${DOCKER__EMPTYSTRING}" \
						"${DOCKER__EMPTYSTRING}"
	else	#REMOTE machine (aka Container)
		${dclcau_dc_ls__fpath} \
						"${containerID__input}" \
						"${dir__input}" \
						"${DOCKER__LISTVIEW_NUMOFROWS}" \
						"${DOCKER__LISTVIEW_NUMOFCOLS}" \
						"${DOCKER__EMPTYSTRING}" \
						"${DOCKER__EMPTYSTRING}"
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
						"${DOCKER__DIRLIST_REMARKS}" \
                        "${dirlist__src_ls_1aA_output__fpath}" \
                        "${dirlist__src_ls_1aA_tmp__fpath}"

	#Get the exitcode just in case a Ctrl-C was pressed in script 'docker__readInput_w_autocomplete__fpath'.
	docker__exitCode=$?
	if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
		docker__exitFunc "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
	else
		#Retrieve the selected container-ID from file
		docker__path_output=`get_output_from_file__func "${dirlist__readInput_w_autocomplete_out__fpath}" "${DOCKER__LINENUM_1}"`
		docker__numOfMatches_output=`get_output_from_file__func "${dirlist__readInput_w_autocomplete_out__fpath}" "${DOCKER__LINENUM_2}"`
	fi

	#Check if 'docker__path_output' is an Empty String
	if [[ -z ${docker__path_output} ]]; then
		#Set case-selection
		docker__case_option=${DOCKER__CASE_SRC_PATH}

		#Print
		show_msg_only__func "${DOCKER__ECHOMSG_PLEASE_SELECT_A_SOURCEPATH_WHICH_CONTAINS_DATA}" "${DOCKER__NUMOFLINES_2}"

		return
	fi

	#Check if 'docker__numOfMatches_output' is '0' (that means no results found)
	if [[ ${docker__numOfMatches_output} -eq 0 ]]; then
		#Set case-selection
		docker__case_option=${DOCKER__CASE_SRC_PATH}

		#Print
		show_msg_only__func "${DOCKER__ECHOMSG_PLEASE_SELECT_A_SOURCEPATH_WHICH_CONTAINS_DATA}" "${DOCKER__NUMOFLINES_2}"

		return
	fi

	#Handle 'Back' and 'Home'
	if [[ ${docker__path_output} == ${DOCKER__SEMICOLON_HOME} ]]; then
		GOTO__func PHASE_CHOOSE_COPY_DIRECTION
	elif [[ ${docker__path_output} == ${DOCKER__SEMICOLON_BACK} ]]; then
		GOTO__func PHASE_CHOOSE_CONTAINERID
	fi

	#Update 'docker__src_dir' and 'docker__src_file'
	#Check if 'docker__path_output' contains an 'asterisk'
	asterisk_isFound=`checkForMatch_keyWord_within_string__func "${DOCKER__ASTERISK}" "${docker__path_output}"`
	if [[ ${asterisk_isFound} == true ]]; then	#asterisk was found
		docker__src_dir=`get_dirname_from_specified_path__func "${docker__path_output}"`

		#Set 'docker__src_file' to 'asterisk'
		#Remark:
		#	This means that 'dirlist__src_ls_1aA_output__fpath', which contains the files & folders
		#		of directory 'docker__src_dir', will be used as reference when copying from source to destination.
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
				show_msg_only__func "${DOCKER__ECHOMSG_PLEASE_SELECT_A_SOURCEPATH_WHICH_CONTAINS_DATA}" "${DOCKER__NUMOFLINES_2}"

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
	local asterisk_isFound=false
	local fileExists=false

	#Show and select path
	${dirlist__readInput_w_autocomplete__fpath} "${containerID__input}" \
						"${DOCKER__EMPTYSTRING}" \
						"${DOCKER__READINPUT_HOST_DST}" \
						"${DOCKER__DIRLIST_REMARKS}" \
                        "${dirlist__dst_ls_1aA_output__fpath}" \
                        "${dirlist__dst_ls_1aA_tmp__fpath}"

	#Get the exitcode just in case a Ctrl-C was pressed in script 'docker__readInput_w_autocomplete__fpath'.
	docker__exitCode=$?
	if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
		docker__exitFunc "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_2}"
	else
		#Retrieve the selected container-ID from file
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
		GOTO__func PHASE_CHOOSE_COPY_DIRECTION
	elif [[ ${docker__path_output} == ${DOCKER__SEMICOLON_BACK} ]]; then
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
		docker__dirlist_show_dirContent_handler__sub "${containerID__input}" \
				"${docker__path_output}"

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
	#Compose 'docker__summary_msg'
	if [[ ${docker__mycopychoice} == ${DOCKER__CONTAINER_TO_HOST} ]]; then
		docker__summary_msg="Direction:\t${DOCKER__FG_LIGHTGREY}${DOCKER__DIRECTION_CONTAINER_TO_LOCAL}${DOCKER__NOCOLOR}\n"
	else
		docker__summary_msg="Direction:\t${DOCKER__FG_LIGHTGREY}${DOCKER__DIRECTION_LOCAL_TO_CONTAINER}${DOCKER__NOCOLOR}\n"
	fi
	docker__summary_msg+="Source:\t\t${DOCKER__FG_LIGHTGREY}${docker__src_dir_print}${DOCKER__NOCOLOR}\n"
	docker__summary_msg+="Destination:\t${DOCKER__FG_LIGHTGREY}${docker__dst_dir_print}${DOCKER__NOCOLOR}"
	
	#Show summary
	show_msg_w_menuTitle_only_func "${DOCKER__SUMMARY_TITLE}" \
						"${docker__summary_msg}" \
						"${DOCKER__NUMOFLINES_2}" \
						"${DOCKER__NUMOFLINES_0}"
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
				moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

				case "${docker__myanswer}" in
					y)
						GOTO__func PHASE_COPY_FROM_SRC_TO_DST
						;;
					n)
						GOTO__func PHASE_EXIT
						;;
					p)
						docker__case_option=${DOCKER__CASE_SRC_PATH}

						GOTO__func PHASE_GET_SRC_DST_FPATH
						;;
					i)
						GOTO__func PHASE_CHOOSE_CONTAINERID
						;;
					h)
						GOTO__func PHASE_CHOOSE_COPY_DIRECTION
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

	#Set message
	docker__copy_msg="Container-ID: ${DOCKER__FG_LIGHTGREY}${docker__containerID_chosen}${DOCKER__NOCOLOR}\n"
	docker__copy_msg+="Source: ${DOCKER__FG_LIGHTGREY}${docker__src_dir}${DOCKER__NOCOLOR}\n"
	docker__copy_msg+="Destination: ${DOCKER__FG_LIGHTGREY}${docker__dst_dir}${DOCKER__NOCOLOR}"

	#Check if 'asterisk' is found
	asterisk_isFound=`checkForMatch_keyWord_within_string__func "${DOCKER__ASTERISK}" "${docker__src_file}"`

	if [[ ${docker__mycopychoice} -eq ${DOCKER__CONTAINER_TO_HOST} ]]; then	#Container to Local Host
		#Show Title
		show_msg_w_menuTitle_only_func "${DOCKER__DIRECTION_CONTAINER_TO_LOCAL}" \
							"${docker__copy_msg}" \
							"${DOCKER__NUMOFLINES_2}" \
							"${DOCKER__NUMOFLINES_0}"

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
							"${DOCKER__NUMOFLINES_2}" \
							"${DOCKER__NUMOFLINES_0}"

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
	docker__exitFunc "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_2}"
}



#---MAIN SUBROUTINE
main__sub() {
	#Disable EXPANSION
	#Remark:
	#	This is necessary, because otherwise an asterisk '*' won't be treated as a character.
	set -f

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

	#Set case-selection
	docker__case_option=${DOCKER__CASE_SRC_PATH}

	#Goto Next-Phase
	GOTO__func PHASE_GET_SRC_DST_FPATH



@PHASE_GET_SRC_DST_FPATH:
	docker__path_selection_handler__sub
	
	#Goto Next-Phase
	GOTO__func PHASE_SHOW_SUMMARY



@PHASE_SHOW_SUMMARY:
	docker__show_summary__sub

	#Goto Next-Phase
	GOTO__func PHASE_CONFIRMATION



@PHASE_CONFIRMATION:
	docker__confirmation__sub



@PHASE_COPY_FROM_SRC_TO_DST:
	#Remark: the Next-Phase is determined in this function.
	docker__copy_from_src_to_dst__sub

	#Goto Next-Phase
	GOTO__func PHASE_EXIT



@PHASE_EXIT:
	#Enable Expansion
	set +f

	docker__exit__sub

}



#---EXECUTE MAIN
main__sub
