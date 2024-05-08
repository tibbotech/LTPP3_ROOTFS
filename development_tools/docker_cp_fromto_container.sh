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
	DOCKER__READINPUT_CONFIRM_SPECIAL_OPTION="${DOCKER__FG_YELLOW}a${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}"
	DOCKER__READINPUT_CONFIRM_OPTIONS="${DOCKER__FG_YELLOW}y${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}"
	DOCKER__READINPUT_CONFIRM_OPTIONS+="${DOCKER__FG_YELLOW}n${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}"
	DOCKER__READINPUT_CONFIRM_OPTIONS+="${DOCKER__FG_YELLOW}p${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}"
	DOCKER__READINPUT_CONFIRM_OPTIONS+="${DOCKER__FG_YELLOW}i${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}"
	DOCKER__READINPUT_CONFIRM_OPTIONS+="${DOCKER__FG_YELLOW}h${DOCKER__NOCOLOR}"

	DOCKER__READINPUT_CONTAINERID="${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}:-:${DOCKER__NOCOLOR}${DOCKER__BG_BRIGHTPRUPLE}ID${DOCKER__NOCOLOR} ${DOCKER__READINPUT_B_C_OPTIONS}: "
	DOCKER__READINPUT_CONTAINER_SRC="${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}:-:${DOCKER__NOCOLOR}${DOCKER__BG_BRIGHTPRUPLE}Src${DOCKER__NOCOLOR}: "
	DOCKER__READINPUT_CONTAINER_DST="${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}:-:${DOCKER__NOCOLOR}${DOCKER__BG_BRIGHTPRUPLE}Dst${DOCKER__NOCOLOR}: "
	DOCKER__READINPUT_HOST_SRC="${DOCKER__FG_GREEN85}Local${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}:-:${DOCKER__NOCOLOR}${DOCKER__BG_GREEN85}Src${DOCKER__NOCOLOR}: "
	DOCKER__READINPUT_HOST_DST="${DOCKER__FG_GREEN85}Local${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}:-:${DOCKER__NOCOLOR}${DOCKER__BG_GREEN85}Dst${DOCKER__NOCOLOR}: "

	DOCKER__READINPUT_DO_YOU_WISH_TO_CONTINUE="Do you wish to continue"

	DOCKER__DIRECTION_CONTAINER_TO_LOCAL="${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR} ${DOCKER__FG_LIGHTGREY}>${DOCKER__NOCOLOR} ${DOCKER__FG_GREEN85}Local${DOCKER__NOCOLOR}"
	DOCKER__DIRECTION_LOCAL_TO_CONTAINER="${DOCKER__FG_GREEN85}Local${DOCKER__NOCOLOR} ${DOCKER__FG_LIGHTGREY}>${DOCKER__NOCOLOR} ${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}"

	DOCKER__CONFIRMATION_REMARKS="${DOCKER__BG_ORANGE}Remarks:${DOCKER__NOCOLOR}\n"
	DOCKER__CONFIRMATION_REMARKS_SPECIAL_OPTION="${DOCKER__DASH} ${DOCKER__FG_YELLOW}a${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}Yes and create folder${DOCKER__NOCOLOR}\n"
	DOCKER__CONFIRMATION_REMARKS_OPTIONS="${DOCKER__DASH} ${DOCKER__FG_YELLOW}y${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}Yes${DOCKER__NOCOLOR}\n"
	DOCKER__CONFIRMATION_REMARKS_OPTIONS+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}n${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}No${DOCKER__NOCOLOR}\n"
	DOCKER__CONFIRMATION_REMARKS_OPTIONS+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}p${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}Reselect Path${DOCKER__NOCOLOR}\n"
	DOCKER__CONFIRMATION_REMARKS_OPTIONS+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}i${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}Reselect containerID${DOCKER__NOCOLOR}\n"
	DOCKER__CONFIRMATION_REMARKS_OPTIONS+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}h${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}Home${DOCKER__NOCOLOR}"

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

	docker__src_parentfolder=${DOCKER__EMPTYSTRING}
	docker__entire_folder_iscopied=false

	docker__dst_dir_print=${DOCKER__EMPTYSTRING}
	docker__src_dir_print=${DOCKER__EMPTYSTRING}

	docker__numOfMatches_output=0
	docker__exitCode=0

	#---NOTE:
	#	index 0: contains the counter for the source path
	#	index 0: contains the counter for the destination path
	docker__src_and_dst_totalcount_list=(0 0)
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

	#Initialize global variables
	docker__src_parentfolder=${DOCKER__EMPTYSTRING}
	docker__entire_folder_iscopied=false

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
	local keywordRange_isFound=false
	local isFile=false
	local readMsg=${DOCKER__EMPTYSTRING}

	#Depending on the 'containerID__input' value, use the appropriate 'readMsg'
	if [[ -z "${containerID__input}" ]]; then
		readMsg="${DOCKER__READINPUT_HOST_SRC}"
	else
		readMsg="${DOCKER__READINPUT_CONTAINER_SRC}"
	fi

	#Show and select path
	${dirlist__readInput_w_autocomplete__fpath} "${containerID__input}" \
						"${DOCKER__EMPTYSTRING}" \
						"${readMsg}" \
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

	#Check if 'asterisk *' is found
	asterisk_isFound=$(checkif_asterisk_isvalid "${docker__path_output}")
	#Check if 'keywordrange {.,.}' is found
	keywordRange_isFound=$(checkif_keywordrange_isvalid "${docker__path_output}")


	if [[ ${asterisk_isFound} == true ]] || [[ ${keywordRange_isFound} == true ]]; then	#asterisk was found
		docker__src_dir=`get_dirname_from_specified_path__func "${docker__path_output}"`

		#Set 'docker__src_file' to 'asterisk'
		#Remark:
		#	Output file 'dirlist__src_ls_1aA_output__fpath', which holds the contents of
		#	...of directory 'docker__src_dir', will be used as reference when...
		#	...copying from source to destination.
		docker__src_file=`get_basename_rev1__func "${docker__path_output}"`
	else	#no asterisk found
		#Check if 'docker__path_output' is a file
		isFile=`checkIf_file_exists__func "${containerID__input}" "${docker__path_output}"`
		if [[ ${isFile} == true ]]; then	#file exists
			#Extract Directory and Filename
			docker__src_dir=`get_dirname_from_specified_path__func "${docker__path_output}"`
			docker__src_file=`get_basename_rev1__func "${docker__path_output}"`

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
	local readMsg=${DOCKER__EMPTYSTRING}

	#Depending on the 'containerID__input' value, use the appropriate 'readMsg'
	if [[ -z "${containerID__input}" ]]; then
		readMsg="${DOCKER__READINPUT_HOST_DST}"
	else
		readMsg="${DOCKER__READINPUT_CONTAINER_DST}"
	fi

	#Show and select path
	${dirlist__readInput_w_autocomplete__fpath} "${containerID__input}" \
						"${DOCKER__EMPTYSTRING}" \
						"${readMsg}" \
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
		show_msg_only__func "${DOCKER__ECHOMSG_PLEASE_SELECT_A_VALID_DESTINATIONPATH}"

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
	#Check if SOURCE PARENT FOLDER is set to be copied to DESTINATION
	#***NOTE: this function implicitely update the following 2 global variables:
	#	1. docker__src_parentfolder
	#	2. docker__entire_folder_iscopied
	docker__entire_folder_iscopied__sub

	#Compose the REMARK and READINPUT
	local remark="${DOCKER__CONFIRMATION_REMARKS}"
	local readmsg="${DOCKER__READINPUT_DO_YOU_WISH_TO_CONTINUE} "
	if [[ "${docker__entire_folder_iscopied}" == true ]]; then
		remark+="${DOCKER__CONFIRMATION_REMARKS_SPECIAL_OPTION}"
		readmsg+="(${DOCKER__READINPUT_CONFIRM_SPECIAL_OPTION}"
	else
		readmsg+="("
	fi
	remark+="${DOCKER__CONFIRMATION_REMARKS_OPTIONS}"
	readmsg+="${DOCKER__READINPUT_CONFIRM_OPTIONS})? "

	#Show remarks
	show_msg_only__func "${remark}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}" "false" "true"

	while true
	do
		read -N1 -p "${readmsg}" docker__myanswer

		if [[ ! -z ${docker__myanswer} ]]; then	#contains data
			if [[ ${docker__myanswer} =~ [aynpih] ]]; then
				#Move-down cursor
				# moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

				case "${docker__myanswer}" in
					a)
						moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

						goto__func PHASE_CREATE_FOLDER_AT_DST
						;;
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

docker__entire_folder_iscopied__sub() {
	#Check if 'docker__src_file' is an asterisk (*)
	if [[ "${docker__src_file}" == "${DOCKER__ASTERISK}" ]]; then
		#Get SOURCE parent folder
		docker__src_parentfolder=$(get_basename_rev2__func "${docker__src_dir}")

		#Set flag to 'true'
		docker__entire_folder_iscopied=true
	else
		#Reset variable
		docker__src_parentfolder=${DOCKER__EMPTYSTRING}

		#Set flag to 'false'
		docker__entire_folder_iscopied=false
	fi
}

docker__create_folder_at_dst__sub() {
	#Update fullpath
	local new_dst_dir=$(get_fullpath_by_combining_dir_with_fileorfolder "${docker__dst_dir}" "${docker__src_parentfolder}")

	#Create fullpath
	if [[ ${docker__mycopychoice} -eq ${DOCKER__CONTAINER_TO_HOST} ]]; then	#Container to Host Device
		mkdir -p "${new_dst_dir}"
	else	#Host Device to Container
		docker exec ${docker__containerID_chosen} mkdir -p "${new_dst_dir}"
	fi

	#***IMPORTANT: Update 'docker__dst_dir'
	docker__dst_dir="${new_dst_dir}"
}

docker__copy_from_src_to_dst__sub() {
	#---------------------------------------------------------------------
	# PHASE 1: DEFINITION
	#---------------------------------------------------------------------
	#Define variables
	local asterisk_isFound=false
	local keywordRange_isFound=false

	local line=${DOCKER__EMPTYSTRING}
	local src_folder=${DOCKER__EMPTYSTRING}
	local src_copypath=${DOCKER__EMPTYSTRING}
	local dst_copypath=${DOCKER__EMPTYSTRING}

	local range_notation_matchItems_list=()

	#Define paths
	local datetime=$(date +"%Y%b%d_%Hh%Mm%Ss")
	local misscontfilename="missing_contents_list"
	local misscontfilename_w_datetime="${misscontfilename}_${datetime}.out"
	local misscontfpath=$(get_fullpath_by_combining_dir_with_fileorfolder "${docker__tmp__dir}" \
			"${misscontfilename_w_datetime}")

	#Remove 'misscontfpath' (if present)
	if [[ -f "${misscontfpath}" ]]; then
		rm "${misscontfpath}"
	fi


	#---------------------------------------------------------------------
	# PHASE 2: COPY & CHECK
	#---------------------------------------------------------------------
	#Compose 'docker__copy_msg'
	docker__copy_msg="Container-ID: ${DOCKER__FG_LIGHTGREY}${docker__containerID_chosen}${DOCKER__NOCOLOR}\n"
	docker__copy_msg+="Source: ${DOCKER__FG_LIGHTGREY}${docker__src_dir}${DOCKER__NOCOLOR}\n"
	docker__copy_msg+="Destination: ${DOCKER__FG_LIGHTGREY}${docker__dst_dir}${DOCKER__NOCOLOR}"

	#Check if 'asterisk' is found (MUST BE DONE HERE!)
	asterisk_isFound=$(checkif_asterisk_isvalid "${docker__src_file}")

	#Check if 'keywordrange' is found (MUST BE DONE HERE!)
	keywordRange_isFound=$(checkif_keywordrange_isvalid "${docker__src_file}")

	#---------------------------------------------------------------------
	# CONTAINER TO HOST
	#---------------------------------------------------------------------
	if [[ ${docker__mycopychoice} -eq ${DOCKER__CONTAINER_TO_HOST} ]]; then	#Container to Local Host
		#Show Title
		show_msg_w_menuTitle_only_func "${DOCKER__DIRECTION_CONTAINER_TO_LOCAL}" \
							"${docker__copy_msg}" \
							"${DOCKER__ZEROSPACE}" \
							"${DOCKER__NUMOFLINES_0}" \
							"${DOCKER__NUMOFLINES_0}" \
							"${DOCKER__NUMOFLINES_0}" \
							"${DOCKER__NUMOFLINES_2}"

		#---------------------------------------------------------------------
		# ASTERISK
		#---------------------------------------------------------------------
		if [[ ${asterisk_isFound} == true ]]; then	#asterisk is found
			while read -r line
			do
				#Define paths
				src_copypath=$(get_fullpath_by_combining_dir_with_fileorfolder "${docker__src_dir}" "${line}")
				dst_copypath=$(get_fullpath_by_combining_dir_with_fileorfolder "${docker__dst_dir}" "${line}")

				#Copy from source to destination
				docker__copy_tar_from_src_to_dst__sub "${docker__containerID_chosen}" \
						"${DOCKER__EMPTYSTRING}" \
						"${line}" \
						"${docker__src_dir}" \
						"${docker__dst_dir}"

				#Print
				echo -e "...copied ${DOCKER__FG_LIGHTGREY}${line}${DOCKER__NOCOLOR}"

				#Show total counter comparison
				#Show missing contents (if any)
				docker__src_vs_dst_show_counts "${docker__containerID_chosen}" \
						"${DOCKER__EMPTYSTRING}" \
						"${src_copypath}"\
						"${dst_copypath}" \
						"${misscontfpath}" \
						"${asterisk_isFound}"
			done < ${dirlist__src_ls_1aA_output__fpath}

			#Show total missing contents & counts
			docker__src_vs_dst_show_total_counts_and_missing_contents "${docker__containerID_chosen}" \
					"${DOCKER__EMPTYSTRING}" \
					"${docker__src_dir}"\
					"${docker__dst_dir}" \
					"${misscontfpath}" \
					"${asterisk_isFound}" \
					"${docker__src_and_dst_totalcount_list[@]}"

		#---------------------------------------------------------------------
		# RANGE-NOTATION
		#---------------------------------------------------------------------
		elif [[ ${keywordRange_isFound} == true ]]; then	#keywordrange is found
			#1. Get the STRING containing all matching files and folders based on the provided range-notation,
			#	which is stored in variable 'docker__src_file'
			#2. Convert this STRING to ARRAY by using (..) 
			range_notation_matchItems_list=( $(docker__get_range_notation_matchItems_list "${docker__containerID_chosen}" \
					"${docker__src_dir}" \
					"${docker__src_file}") )

			printf '%s\n' "${range_notation_matchItems_list[@]}"
			echo "CONTAINER TO HOST: CONTINUE FROM HERE!!!"

		#---------------------------------------------------------------------
		# ALL OTHER
		#---------------------------------------------------------------------
		else	#anything else
			#Define paths
			src_copypath=$(get_fullpath_by_combining_dir_with_fileorfolder "${docker__src_dir}" "${docker__src_file}")
			dst_copypath=$(get_fullpath_by_combining_dir_with_fileorfolder "${docker__dst_dir}" "${docker__src_file}")

			#Copy from source to destination
			docker__copy_tar_from_src_to_dst__sub "${docker__containerID_chosen}" \
					"${DOCKER__EMPTYSTRING}" \
					"${docker__src_file}" \
					"${docker__src_dir}" \
					"${docker__dst_dir}"

			#Print
			echo -e "...copied ${DOCKER__FG_LIGHTGREY}${docker__src_file}${DOCKER__NOCOLOR}"


			#Show total counter comparison
			#Show missing contents (if any)
			docker__src_vs_dst_show_counts "${docker__containerID_chosen}" \
					"${DOCKER__EMPTYSTRING}" \
					"${src_copypath}" \
					"${dst_copypath}" \
					"${misscontfpath}" \
					"${asterisk_isFound}"
		fi

	#---------------------------------------------------------------------
	# HOST TO CONTAINER
	#---------------------------------------------------------------------
	else
		#Show Title
		show_msg_w_menuTitle_only_func "${DOCKER__DIRECTION_LOCAL_TO_CONTAINER}" \
							"${docker__copy_msg}" \
							"${DOCKER__ZEROSPACE}" \
							"${DOCKER__NUMOFLINES_0}" \
							"${DOCKER__NUMOFLINES_0}" \
							"${DOCKER__NUMOFLINES_0}" \
							"${DOCKER__NUMOFLINES_2}"

		#---------------------------------------------------------------------
		# ASTERISK
		#---------------------------------------------------------------------
		if [[ ${asterisk_isFound} == true ]]; then	#asterisk is found
			while read -r line
			do
				#Define paths
				src_copypath=$(get_fullpath_by_combining_dir_with_fileorfolder "${docker__src_dir}" "${line}")
				dst_copypath=$(get_fullpath_by_combining_dir_with_fileorfolder "${docker__dst_dir}" "${line}")

				#Copy from source to destination
				docker__copy_tar_from_src_to_dst__sub "${DOCKER__EMPTYSTRING}" \
						"${docker__containerID_chosen}" \
						"${line}" \
						"${docker__src_dir}" \
						"${docker__dst_dir}"

				#Print
				echo -e "...copied ${DOCKER__FG_LIGHTGREY}${line}${DOCKER__NOCOLOR}"

				#Show total missing contents & counts
				docker__src_vs_dst_show_counts "${DOCKER__EMPTYSTRING}" \
						"${docker__containerID_chosen}" \
						"${src_copypath}" \
						"${dst_copypath}" \
						"${misscontfpath}" \
						"${asterisk_isFound}"
			done < ${dirlist__src_ls_1aA_output__fpath}


			#Show total missing contents & counts
			docker__src_vs_dst_show_total_counts_and_missing_contents "${DOCKER__EMPTYSTRING}" \
					"${docker__containerID_chosen}" \
					"${docker__src_dir}"\
					"${docker__dst_dir}" \
					"${misscontfpath}" \
					"${asterisk_isFound}" \
					"${docker__src_and_dst_totalcount_list[@]}"

		#---------------------------------------------------------------------
		# RANGE-NOTATION
		#---------------------------------------------------------------------
		elif [[ ${keywordRange_isFound} == true ]]; then	#keywordrange is found
			#1. Get the STRING containing all matching files and folders based on the provided range-notation,
			#	which is stored in variable 'docker__src_file'
			#2. Convert this STRING to ARRAY by using (..) 
			range_notation_matchItems_list=( $(docker__get_range_notation_matchItems_list "${DOCKER__EMPTYSTRING}" \
					"${docker__src_dir}" \
					"${docker__src_file}") )

			printf '%s\n' "${range_notation_matchItems_list[@]}"
			echo "HOST TO CONTAINER: CONTINUE FROM HERE!!!"

		#---------------------------------------------------------------------
		# ALL OTHER
		#---------------------------------------------------------------------
		else	#anything else
			#Define paths
			src_copypath=$(get_fullpath_by_combining_dir_with_fileorfolder "${docker__src_dir}" "${docker__src_file}")
			dst_copypath=$(get_fullpath_by_combining_dir_with_fileorfolder "${docker__dst_dir}" "${docker__src_file}")

			docker__copy_tar_from_src_to_dst__sub "${DOCKER__EMPTYSTRING}" \
					"${docker__containerID_chosen}" \
					"${docker__src_file}" \
					"${docker__src_dir}" \
					"${docker__dst_dir}"

			#print
			echo -e "...copied ${DOCKER__FG_LIGHTGREY}${docker__src_file}${DOCKER__NOCOLOR}"


			#Show total counter comparison
			#Show missing contents (if any)
			docker__src_vs_dst_show_counts "${DOCKER__EMPTYSTRING}" \
					"${docker__containerID_chosen}" \
					"${src_copypath}" \
					"${dst_copypath}" \
					"${misscontfpath}" \
					"${asterisk_isFound}"
		fi	
	fi
}

docker__get_dir_contents() {
	#Input args
	local containerID__input="${1}"
	local dir__input="${2}"

	#Get directory list of contents
	local src_cmd="ls -1av \"${dir__input}\" | grep -Ev '^\.\.?$'"
	local src_outputfpath="${docker__tmp__dir}/src.out"
	
	#Execute command
	#***NOTE: this function pass the result to file 'src_outputfpath'
	docker_exec_cmd_and_receive_output__func "${containerID__input}" "${src_cmd}" "${src_outputfpath}"
	#Retrieve result from file 'src_outputfpath'
	local src_output=$(cat "${src_outputfpath}")

	#OUTPUT
	echo -e "${src_output[@]}"
}

docker__get_range_notation_matchItems_list() {
	local containerID__input="${1}"
	local src_dir__input="${2}"
	local range_notation__input="${3}"

	#1. Get dir contents
	#2. Convert 'string' to 'array'
	local dirlist_ls_1av=( $(docker__get_dir_contents "${containerID__input}" "${src_dir__input}") )

	#Extract LEFT and RIGHT chars
	local leftchar=$(extract_leftchar_from_range_notation "${range_notation__input}")
	local rightchar=$(extract_rightchar_from_range_notation "${range_notation__input}")
	#Convert LEFT and RIGHT chars to decimals
	local leftdec=$(char_to_dec "${leftchar}")
	local rightdec=$(char_to_dec "${rightchar}")

	#SWAP 'leftdec' with 'rightdec' if needed 'leftdec > rightdec'
	local leftdec_tmp=${leftdec}
	if [[ ${leftdec} -gt ${rightdec} ]]; then
		leftdec=${rightdec}
		rightdec=${leftdec_tmp}
	fi 

	#Get the list with all files and folders matching the range-notation
	local char=${DOCKER__EMPTYSTRING}
	local dirlistitem_firstchar=${DOCKER__EMPTYSTRING}
	local ret=()

	#Iterate from decimal 'leftdec' until 'rightdec'
	for (( dec=leftdec; dec<=rightdec; dec++ ))
	do
		#Convert decimal 'd' to char 'c'
		char=$(dec_to_char "${dec}")

		#Iterate thru array 'dirlistitem'
		for dirlistitem in "${dirlist_ls_1av[@]}"; do
			#Get the first character
			dirlistitem_firstchar="${dirlistitem:0:1}"
			#Check if there is match between 'dirlistitem_firstchar' and 'char'
			if [[ "${dirlistitem_firstchar}" == "${char}" ]]; then
				#Add 'dirlistitem' to array
				ret+=("${dirlistitem}")
			fi
		done
	done

	#OUTPUT
	echo "${ret[@]}"
}



docker__copy_tar_from_src_to_dst__sub() {
	#Input args
	local src_containerid__input="${1}"
	local dst_containerid__input="${2}"
	local src_content__input="${3}"	#file or folder
	local src_dir__input="${4}"
	local dst_dir__input="${5}"

	#Define Paths
	tar_filename="${src_content__input}.tar"
	src_tar_fpath=$(get_fullpath_by_combining_dir_with_fileorfolder "${src_dir__input}" "${tar_filename}")
	dst_tar_fpath=$(get_fullpath_by_combining_dir_with_fileorfolder "${dst_dir__input}" "${tar_filename}")

	if [[ -n "${src_containerid__input}" ]]; then
		#---------------------------------------------------------------------
		# CONTAINER TO LOCAL
		#---------------------------------------------------------------------
		#Compress file or folder(s) with 'tar'
		docker exec ${src_containerid__input} tar -cf ${src_tar_fpath} -C ${src_dir__input} ${src_content__input}

		#Copy 'tar' file from source to destination
		docker cp ${src_containerid__input}:${src_tar_fpath} ${dst_tar_fpath}

		#Destination: extract 'tar' file
		tar -xf ${dst_tar_fpath} -C ${dst_dir__input}

		#Source: remove tar file
		docker exec ${src_containerid__input} rm ${src_tar_fpath}

		#Destination: remove tar file
		rm ${dst_tar_fpath}
	else
		#---------------------------------------------------------------------
		# LOCAL TO CONTAINER
		#---------------------------------------------------------------------
		#Compress file or folder(s) with 'tar'
		tar -cf ${src_tar_fpath} -C ${src_dir__input} ${src_content__input}

		#Copy 'tar' file from source to destination
		docker cp ${src_tar_fpath} ${dst_containerid__input}:${dst_tar_fpath}

		#Destination: extract 'tar' file
		docker exec ${dst_containerid__input} tar -xf ${dst_tar_fpath} -C ${dst_dir__input}

		#Source: remove tar file
		rm ${src_tar_fpath}

		#Destination: remove tar file
		docker exec ${dst_containerid__input} rm ${dst_tar_fpath}
	fi
}

docker__src_vs_dst_show_counts() {
	#Input args
	local src_containerid__input="${1}"
	local dst_containerid__input="${2}"
	local src_path__input="${3}"
	local dst_path__input="${4}"
	local misscontfpath__input="${5}"
	local asterisk_isFound__input="${6}"

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
	#NOTE:
	#	if 'src_path__input' and/or 'dst_path__input' is directory, then this directory is NOT INCLUDED in the count!!!
	local src_cmd="find \"${src_path__input}\" -printf \"${src_path__input}/%P\n\" | wc -l"
	local dst_cmd="find \"${dst_path__input}\" -printf \"${dst_path__input}/%P\n\" | wc -l"
	local src_outputfpath="${docker__tmp__dir}/src.out"
	local dst_outputfpath="${docker__tmp__dir}/dst.out"

	#Execute commands
	docker_exec_cmd_and_receive_output__func "${src_containerid__input}" "${src_cmd}" "${src_outputfpath}"
	local src_output=$(cat "${src_outputfpath}")
	if [[ -z "${src_output}" ]]; then
		src_output=0
	fi

	docker_exec_cmd_and_receive_output__func "${dst_containerid__input}" "${dst_cmd}" "${dst_outputfpath}"
	local dst_output=$(cat "${dst_outputfpath}")
	if [[ -z "${dst_output}" ]]; then
		dst_output=0
	fi

	# Add 'src_output' and 'dst_output' to array
	#---NOTE:
	#   index 0: contains the counter for the source path
	#   index 1: contains the counter for the destination path
	docker__src_and_dst_totalcount_list[0]=$((docker__src_and_dst_totalcount_list[0] + src_output))
	docker__src_and_dst_totalcount_list[1]=$((docker__src_and_dst_totalcount_list[1] + dst_output))

	#Compare 'src_output' with 'dst_output'
	if [[ ${src_output} -eq ${dst_output} ]]; then
		echo -e "......src:dst = ${src_output}:${dst_output} (${DOCKER__FG_GREEN}OK${DOCKER__NOCOLOR})"
	else
		docker__src_vs_dst_show_missing_contents "${src_containerid__input}" \
				"${dst_containerid__input}" \
				"${src_path__input}" \
				"${dst_path__input}" \
				"${misscontfpath__input}" \
				"${asterisk_isFound__input}"

		echo -e "......src:dst = ${src_output}:${dst_output} (${DOCKER__FG_RED1}FAIL${DOCKER__NOCOLOR})\n" | tee -a "${misscontfpath__input}"
	fi
}

docker__src_vs_dst_show_missing_contents() {
	#Input args
	src_containerid__input="${1}"
	dst_containerid__input="${2}"
	src_path__input="${3}"
	dst_path__input="${4}"
	misscontfpath__input="${5}"
	asterisk_isFound__input="${6}"

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
	local src_cmd="find \"${src_path__input}\" -printf \"${src_path__input}/%P\n\""
	local dst_cmd="find \"${dst_path__input}\" -printf \"${dst_path__input}/%P\n\""
	local src_outputfpath="${docker__tmp__dir}/src.out"
	local dst_outputfpath="${docker__tmp__dir}/dst.out"

	#Execute commands
	docker_exec_cmd_and_receive_output__func "${src_containerid__input}" "${src_cmd}" "${src_outputfpath}"
	local src_output=$(cat "${src_outputfpath}")

	docker_exec_cmd_and_receive_output__func "${dst_containerid__input}" "${dst_cmd}" "${dst_outputfpath}"
	local dst_output=$(cat "${dst_outputfpath}")

	#1. Find elements in 'src_output' that are not in 'dst_output'
	#2. Write to array
	missing_contents_list=($(comm -23 <(printf "%s\n" "${src_output[@]}" | sort) <(printf "%s\n" "${dst_output[@]}" | sort)))

	#Show missing files and folders
	echo -e "\r"
	echo -e "...List of missing contents (incl. their parent folders):" | tee -a ${misscontfpath__input}
	#Iterate thru elements of array 'missing_contents_list'
	for content in "${missing_contents_list[@]}"
	do
		if [[ ${asterisk_isFound__input} == false ]]; then
			echo -e "${content}" | tee -a ${misscontfpath__input}
		else
			# echo -e "${src_path__input}/${content}" | sed 's#//*#/#g' | tee -a ${misscontfpath__input}
			echo -e "$(get_fullpath_by_combining_dir_with_fileorfolder "${src_path__input}" "${content}")" | tee -a ${misscontfpath__input}
		fi
	done
	echo -e "\r"
}

docker__src_vs_dst_show_total_counts_and_missing_contents() {
	#Input args
	local src_containerid__input="${1}"
	local dst_containerid__input="${2}"
	local src_dir__input="${3}"
	local dst_dir_input="${4}"
	local misscontfpath__input="${5}"
	local asterisk_isFound__input="${6}"
    shift 6                 # Shift to skip the first 6 parameters
    local totalcount_list__input=("$@") 

	#Show total missing contents & counts
	if [[ ${totalcount_list__input[0]} -ne ${totalcount_list__input[1]} ]]; then
		#Show total missing contents
		docker__src_vs_dst_show_missing_contents "${src_containerid__input}" \
				"${dst_containerid__input}" \
				"${src_dir__input}" \
				"${dst_dir_input}" \
				"${misscontfpath__input}" \
				"${asterisk_isFound__input}"

		#Show total missing counts
		echo -e "...Total missing contents count (incl. parent folders):" | tee -a "${misscontfpath__input}"
		echo -e "......src:dst = ${totalcount_list__input[0]}:${totalcount_list__input[1]}" | tee -a "${misscontfpath__input}"
		echo -e "...See file: \"${misscontfpath__input}\"\n"
	else
		#Show total counts
		echo -e "...Total contents count (incl. parent folders):"
		echo -e "......src:dst = ${totalcount_list__input[0]}:${totalcount_list__input[1]}"
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



@PHASE_CREATE_FOLDER_AT_DST:
	docker__create_folder_at_dst__sub

	#Goto Next-Phase
	goto__func PHASE_COPY_FROM_SRC_TO_DST



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
