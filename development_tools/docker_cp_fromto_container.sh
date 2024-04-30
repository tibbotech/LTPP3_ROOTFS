#!/bin/bash -m
#Remark: by using '-m' the INTERRUPT executed here will NOT propagate to the UPPERLAYER scripts
#---SUBROUTINES
docker__get_source_fullpath__sub() {
    #Define constants
    local PHASE_CHECK_CACHE=1
    local PHASE_FIND_PATH=10
    local PHASE_EXIT=100

    #Define variables
    local phase=""

    local current_dir=""
    local parent_dir=""
    local search_dir=""
    local tmp_dir=""

    local development_tools_foldername=""
    local lTPP3_ROOTFS_foldername=""
    local global_filename=""
    local parentDir_of_LTPP3_ROOTFS_dir=""

    local mainmenu_path_cache_filename=""
    local mainmenu_path_cache_fpath=""

    local find_dir_result_arr=()
    local find_dir_result_arritem=""

    local path_of_development_tools_found=""
    local parentpath_of_development_tools=""

    local isfound=""

    local retry_ctr=0

    #Set variables
    phase="${PHASE_CHECK_CACHE}"
    current_dir=$(dirname $(readlink -f $0))
    parent_dir="$(dirname "${current_dir}")"
    tmp_dir=/tmp
    development_tools_foldername="development_tools"
    global_filename="docker_global.sh"
    lTPP3_ROOTFS_foldername="LTPP3_ROOTFS"

    mainmenu_path_cache_filename="docker__mainmenu_path.cache"
    mainmenu_path_cache_fpath="${tmp_dir}/${mainmenu_path_cache_filename}"

    result=false

    #Start loop
    while true
    do
        case "${phase}" in
            "${PHASE_CHECK_CACHE}")
                if [[ -f "${mainmenu_path_cache_fpath}" ]]; then
                    #Get the directory stored in cache-file
                    docker__LTPP3_ROOTFS_development_tools__dir=$(awk 'NR==1' "${mainmenu_path_cache_fpath}")

                    #Move one directory up
                    parentpath_of_development_tools=$(dirname "${docker__LTPP3_ROOTFS_development_tools__dir}")

                    #Check if 'development_tools' is in the 'LTPP3_ROOTFS' folder
                    isfound=$(docker__checkif_paths_are_related "${current_dir}" \
                            "${parentpath_of_development_tools}" "${lTPP3_ROOTFS_foldername}")
                    if [[ ${isfound} == false ]]; then
                        phase="${PHASE_FIND_PATH}"
                    else
                        result=true

                        phase="${PHASE_EXIT}"
                    fi
                else
                    phase="${PHASE_FIND_PATH}"
                fi
                ;;
            "${PHASE_FIND_PATH}")   
                #Print
                echo -e "---:\e[30;38;5;215mSTART\e[0;0m: find path of folder \e[30;38;5;246m'${development_tools_foldername}\e[0;0m"

                #Initialize variables
                docker__LTPP3_ROOTFS_development_tools__dir=""
                search_dir="${current_dir}"   #start with search in the current dir

                #Start loop
                while true
                do
                    #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
                    #... and read to array 'find_result_arr'
                    readarray -t find_dir_result_arr < <(find  "${search_dir}" -type d -iname "${lTPP3_ROOTFS_foldername}" 2> /dev/null)

                    #Iterate thru each array-item
                    for find_dir_result_arritem in "${find_dir_result_arr[@]}"
                    do
                        echo -e "---:\e[30;38;5;215mCHECKING\e[0;0m: ${find_dir_result_arritem}"

                        #Find path
                        isfound=$(docker__checkif_paths_are_related "${current_dir}" \
                                "${find_dir_result_arritem}"  "${lTPP3_ROOTFS_foldername}")
                        if [[ ${isfound} == true ]]; then
                            #Update variable 'path_of_development_tools_found'
                            path_of_development_tools_found="${find_dir_result_arritem}/${development_tools_foldername}"

                            #Check if 'directory' exist
                            if [[ -d "${path_of_development_tools_found}" ]]; then    #directory exists
                                #Update variable
                                #Remark:
                                #   'docker__LTPP3_ROOTFS_development_tools__dir' is a global variable.
                                #   This variable will be passed 'globally' to script 'docker_global.sh'.
                                docker__LTPP3_ROOTFS_development_tools__dir="${path_of_development_tools_found}"

                                break
                            fi
                        fi
                    done

                    #Check if 'docker__LTPP3_ROOTFS_development_tools__dir' contains any data
                    if [[ -z "${docker__LTPP3_ROOTFS_development_tools__dir}" ]]; then  #contains no data
                        case "${retry_ctr}" in
                            0)
                                search_dir="${parent_dir}"    #next search in the 'parent' directory
                                ;;
                            1)
                                search_dir="/" #finally search in the 'main' directory (the search may take longer)
                                ;;
                            *)
                                echo -e "\r"
                                echo -e "***\e[1;31mERROR\e[0;0m: folder \e[30;38;5;246m${development_tools_foldername}\e[0;0m: \e[30;38;5;131mNot Found\e[0;0m"
                                echo -e "\r"

                                #Update variable
                                result=false

                                #set phase
                                phase="${PHASE_EXIT}"

                                break
                                ;;
                        esac

                        ((retry_ctr++))
                    else    #contains data
                        #Print
                        echo -e "---:\e[30;38;5;215mCOMPLETED\e[0;0m: find path of folder \e[30;38;5;246m'${development_tools_foldername}\e[0;0m"


                        #Write to file
                        echo "${docker__LTPP3_ROOTFS_development_tools__dir}" | tee "${mainmenu_path_cache_fpath}" >/dev/null

                        #Print
                        echo -e "---:\e[30;38;5;215mSTATUS\e[0;0m: write path to temporary cache-file: \e[1;33mDONE\e[0;0m"

                        #Update variable
                        result=true

                        #set phase
                        phase="${PHASE_EXIT}"

                        break
                    fi
                done
                ;;    
            "${PHASE_EXIT}")
                break
                ;;
        esac
    done

    #Exit if 'result = false'
    if [[ ${result} == false ]]; then
        exit 99
    fi

    #Retrieve directories
    #Remark:
    #   'docker__LTPP3_ROOTFS__dir' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/
    parentDir_of_LTPP3_ROOTFS_dir=${docker__LTPP3_ROOTFS__dir%/*}    #move two directories up. This directory is the one-level higher than LTPP3_ROOTFS/

    #Get full-path
    #Remark:
    #   'docker__global__fpath' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__global__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${global_filename}
}
docker__checkif_paths_are_related() {
    #Input args
    local scriptdir__input=${1}
    local finddir__input=${2}
    local pattern__input=${3}

    #Define constants
    local PHASE_PATTERN_CHECK1=1
    local PHASE_PATTERN_CHECK2=10
    local PHASE_PATH_COMPARISON=20
    local PHASE_EXIT=100

    #Define variables
    local phase="${PHASE_PATTERN_CHECK1}"
    local isfound1=""
    local isfound2=""
    local isfound3=""
    local ret=false

    while true
    do
        case "${phase}" in
            "${PHASE_PATTERN_CHECK1}")
                #Check if 'pattern__input' is found in 'scriptdir__input'
                isfound1=$(echo "${scriptdir__input}" | \
                        grep -o "${pattern__input}.*" | \
                        cut -d"/" -f1 | grep -w "^${pattern__input}$")
                if [[ -z "${isfound1}" ]]; then
                    ret=false

                    phase="${PHASE_EXIT}"
                else
                    phase="${PHASE_PATTERN_CHECK2}"
                fi                
                ;;
            "${PHASE_PATTERN_CHECK2}")
                #Check if 'pattern__input' is found in 'finddir__input'
                isfound2=$(echo "${finddir__input}" | \
                        grep -o "${pattern__input}.*" | \
                        cut -d"/" -f1 | grep -w "^${pattern__input}$")
                if [[ -z "${isfound2}" ]]; then
                    ret=false

                    phase="${PHASE_EXIT}"
                else
                    phase="${PHASE_PATH_COMPARISON}"
                fi                
                ;;
            "${PHASE_PATH_COMPARISON}")
                #Check if 'development_tools' is under the folder 'LTPP3_ROOTFS'
                isfound3=$(echo "${scriptdir__input}" | \
                        grep -w "${finddir__input}.*")
                if [[ -z "${isfound3}" ]]; then
                    ret=false
                else
                    ret=true
                fi

                phase="${PHASE_EXIT}"
                ;;
            "${PHASE_EXIT}")
                break
                ;;
        esac
    done

    #Output
    echo "${ret}"

    return 0
}
docker__load_global_fpath_paths__sub() {
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
	DOCKER__SUMMARY_TITLE="${DOCKER__FG_ORANGE203}Summary${DOCKER__NOCOLOR}"

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
	asterisk_isFound=`checkForMatch_of_a_pattern_within_string__func "${DOCKER__ASTERISK}" "${docker__path_output}"`
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
	local src_copypath=${DOCKER__EMPTYSTRING}
	local dst_copypath=${DOCKER__EMPTYSTRING}


	#---------------------------------------------------------------------
	# PHASE 1: COPY
	#---------------------------------------------------------------------
	#Compose 'docker__copy_msg'
	docker__copy_msg="Container-ID: ${DOCKER__FG_LIGHTGREY}${docker__containerID_chosen}${DOCKER__NOCOLOR}\n"
	docker__copy_msg+="Source: ${DOCKER__FG_LIGHTGREY}${docker__src_dir}${DOCKER__NOCOLOR}\n"
	docker__copy_msg+="Destination: ${DOCKER__FG_LIGHTGREY}${docker__dst_dir}${DOCKER__NOCOLOR}"

	#Check if 'asterisk' is found (MUST BE DONE HERE!)
	asterisk_isFound=`checkForMatch_of_a_pattern_within_string__func "${DOCKER__ASTERISK}" "${docker__src_file}"`

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
				src_copypath="${docker__src_dir}/${line}"
				dst_copypath="${docker__dst_dir}"

				docker cp ${docker__containerID_chosen}:${src_copypath} ${dst_copypath}

				echo "...copied ${DOCKER__FG_LIGHTGREY}${line}${DOCKER__NOCOLOR}"

				$(docker__src_and_dst_count_contents "${docker__containerID_chosen}" "${DOCKER__EMPTYSTRING}" "${src_copypath}" "${dst_copypath}/${line}") 
			done < ${dirlist__src_ls_1aA_output__fpath}

			docker__src_and_dst_count_contents "${docker__containerID_chosen}" "${DOCKER__EMPTYSTRING}" "${docker__src_dir}" "${docker__dst_dir}"
		else	#asterisk is NOT found
			src_copypath="${docker__src_dir}/${docker__src_file}"
			dst_copypath="${docker__dst_dir}"

			docker cp ${docker__containerID_chosen}:${src_copypath} ${dst_copypath}

			echo "...copied ${DOCKER__FG_LIGHTGREY}${docker__src_file}${DOCKER__NOCOLOR}"

			docker__src_and_dst_count_contents "${docker__containerID_chosen}" "${DOCKER__EMPTYSTRING}" "${src_copypath}" "${dst_copypath}/${docker__src_file}"
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
				src_copypath="${docker__src_dir}/${line}"
				dst_copypath="${docker__dst_dir}"

				docker cp ${src_copypath} ${docker__containerID_chosen}:${dst_copypath}

				echo "...copied ${DOCKER__FG_LIGHTGREY}${line}${DOCKER__NOCOLOR}"

				docker__src_and_dst_count_contents "${DOCKER__EMPTYSTRING}" "${docker__containerID_chosen}" "${src_copypath}" "${dst_copypath}/${line}"
			done < ${dirlist__src_ls_1aA_output__fpath}

			docker__src_and_dst_count_contents "${DOCKER__EMPTYSTRING}" "${docker__containerID_chosen}" "${docker__src_dir}" "${docker__dst_dir}"
		else	#asterisk is NOT found
			src_copypath="${docker__src_dir}/${docker__src_file}"
			dst_copypath="${docker__dst_dir}"

			docker cp ${src_copypath} ${docker__containerID_chosen}:${dst_copypath}

			echo "...copied ${DOCKER__FG_LIGHTGREY}${docker__src_file}${DOCKER__NOCOLOR}"

			docker__src_and_dst_count_contents "${DOCKER__EMPTYSTRING}" "${docker__containerID_chosen}" "${src_copypath}" "${dst_copypath}/${docker__src_file}"
		fi	
	fi
}

docker__src_and_dst_count_contents() {
	#Input args
	src_containerid__input="${1}"
	dst_containerid__input="${2}"
	src_path__input="${3}"
	dst_path__input="${4}"

	#Define command lines
	#EXPLANATION:
	#	ls -1aR /root/LTPP3_ROOTFS: 
	#		List all files and directories (including hidden ones) recursively in /root/LTPP3_ROOTFS
	#	grep -vE ':$':
	#		Exclude lines ending with :
	#	grep -vE '^$':
	#		Exclude empty lines
	#	grep -vE '^\.+$':
	#		Exclude lines containing only .
	#	wc -l:
	#		Count the remaining lines
	local src_cmd="ls -1aR  \"${src_path__input}\" | grep -vE ':$' | grep -vE '^$' | grep -vE '^\.+$' |  wc -l"
	local dst_cmd="ls -1aR  \"${dst_path__input}\" | grep -vE ':$' | grep -vE '^$' | grep -vE '^\.+$' |  wc -l"

	#Execute commands
	container_exec_cmd_and_receive_output__func "${src_containerid__input}" "${src_cmd}" "${docker__container_exec_cmd_and_receive_output_out__fpath}"
	local src_output=$(cat "${docker__container_exec_cmd_and_receive_output_out__fpath}")

	container_exec_cmd_and_receive_output__func "${dst_containerid__input}" "${dst_cmd}" "${docker__container_exec_cmd_and_receive_output_out__fpath}"
	local dst_output=$(cat "${docker__container_exec_cmd_and_receive_output_out__fpath}")

	#Compare 'src_output' with 'dst_output'
	if [[ ${src_output} -eq ${dst_output} ]]; then
		echo "src : dst = ${src_output} : ${dst_output} (${DOCKER__FG_GREEN}OK${DOCKER__NOCOLOR})"
	else
		echo "src : dst = ${src_output} : ${dst_output} (${DOCKER__FG_GREEN}FAIL${DOCKER__NOCOLOR})"
	fi
}

docker__exit__sub() {
	exit__func "${DOCKER__EXITCODE_0}" "${docker__exit_numOfLines}"
}



#---MAIN SUBROUTINE
main__sub() {
	#Environmental variables must be defined and set first.
	docker__get_source_fullpath__sub

	#Then the source file(s) must be loaded.
	docker__load_global_fpath_paths__sub

	#Disable EXPANSION
	#Remark:
	#	This is necessary, because otherwise an asterisk '*' won't be treated as a character.
	disable_expansion__func

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
