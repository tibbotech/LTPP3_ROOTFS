#---INPUT ARGS
containerID__input=${1}


#---SUBROUTINES
docker__environmental_variables__sub() {
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

    docker__global_filename="docker_global.sh"
    docker__global__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global_filename}
}

docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

docker__load_header__sub() {
    #Input args
    local prepend_numOfLines__input=${1}

    #Print
    show_header__func "${DOCKER__TITLE}" "${DOCKER__TABLEWIDTH}" "${DOCKER__BG_ORANGE}" "${prepend_numOfLines__input}" "${DOCKER__NUMOFLINES_0}"
}

docker__init_variables__sub() {
    docker__cachedInput_arr=()
    docker__cachedInput_arrLen=0
    docker__cachedInput_arrIndex=-1 #must be set to (-1)
    docker__cachedInput_arrIndex_max=0

    docker__output_arr=()

    docker__cmd=${DOCKER__EMPTYSTRING}
    docker__cmd_clean=${DOCKER__EMPTYSTRING}
    docker__keyInput=${DOCKER__EMPTYSTRING}
    docker__keyInput_add=${DOCKER__EMPTYSTRING}

    docker__myAnswer=${DOCKER__EMPTYSTRING}

    docker__currDir=${DOCKER__EMPTYSTRING}
    docker__currDir_colored=${DOCKER__EMPTYSTRING}

    docker__echoMsg=${DOCKER__EMPTYSTRING}

    docker__menuTitle_indent=${DOCKER__FOURSPACES}

	docker__exitCode=0

    docker__fixed_numOfLines=0
    docker__remarks_numOfLines=0
    docker__tot_numOfLines=0

    docker__isExcluded=false
    docker__parentWhileLoop_isExit=false
    docker__refresh_readInput_only=false
}

docker__load_constants__sub() {
    # DOCKER__ENTER_CMD_REMARKS="${DOCKER__BG_ORANGE}Remarks:${DOCKER__NOCOLOR}\n"
    DOCKER__ENTER_CMD_REMARKS="${DOCKER__FOURSPACES}${DOCKER__FG_YELLOW}\\${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}prepend backslash in-front-of special chars (${DOCKER__NOCOLOR}"
    DOCKER__ENTER_CMD_REMARKS+="${DOCKER__FG_YELLOW}\\${DOCKER__NOCOLOR}\\${DOCKER__FG_LIGHTGREY},"
    DOCKER__ENTER_CMD_REMARKS+="${DOCKER__FG_YELLOW}\\${DOCKER__NOCOLOR}@${DOCKER__FG_LIGHTGREY},"
    DOCKER__ENTER_CMD_REMARKS+="${DOCKER__FG_YELLOW}\\${DOCKER__NOCOLOR}\$${DOCKER__FG_LIGHTGREY},etc.)${DOCKER__NOCOLOR}\n"
    DOCKER__ENTER_CMD_REMARKS+="${DOCKER__SEVENSPACES}${DOCKER__FG_LIGHTGREY}excluding: dot(${DOCKER__NOCOLOR}.${DOCKER__FG_LIGHTGREY}),slash(${DOCKER__NOCOLOR}/${DOCKER__FG_LIGHTGREY})${DOCKER__NOCOLOR}\n"
	DOCKER__ENTER_CMD_REMARKS+="${DOCKER__FOURSPACES}${DOCKER__FG_YELLOW}ENTER${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}to execute${DOCKER__NOCOLOR}\n"
    DOCKER__ENTER_CMD_REMARKS+="${DOCKER__FOURSPACES}${DOCKER__FG_YELLOW}TAB${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}auto-complete${DOCKER__NOCOLOR}\n"
    DOCKER__ENTER_CMD_REMARKS+="${DOCKER__FOURSPACES}${DOCKER__FG_YELLOW};c${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}clear${DOCKER__NOCOLOR}"

    DOCKER__ENTER_CMD_LOCATIONINFO="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR}: ${docker__enter_cmdline_mode_out__fpath}"
    DOCKER__ENTER_CMD_MENUOPTIONS="${DOCKER__FOURSPACES}${DOCKER__FG_YELLOW}Press-any-key${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}go back to cmd-input${DOCKER__NOCOLOR}"
    DOCKER__ENTER_CMD_ERRORMSG="-:${DOCKER__FG_LIGHTRED}No results${DOCKER__NOCOLOR}:-" #this message will be centered within the function
}

docker__calculate_tot_numOfLines__sub() {
    docker__fixed_numOfLines=${DOCKER__NUMOFLINES_1}    #due to a fixed number of horizontal lines
    docker__remarks_numOfLines=`get_numOfLines_for_specified_string_or_file__func "${DOCKER__ENTER_CMD_REMARKS}"`
    docker__echoMsg_numOfLines=${DOCKER__NUMOFLINES_1}
    docker__fixed_and_echoMsg_numOfLines=$((docker__fixed_numOfLines + docker__echoMsg_numOfLines))
    docker__tot_numOfLines=$((docker__fixed_numOfLines + docker__remarks_numOfLines + docker__echoMsg_numOfLines))
}

docker__delete_files__sub() {
    if [[ -f ${docker__enter_cmdline_mode_out__fpath} ]]; then
        rm ${docker__enter_cmdline_mode_out__fpath}
    fi
}

docker__show_fileContent_handler__sub() {
    #Input args
    local cmd__input=${1}

    #Print header
    docker__load_header__sub "${docker__tibboHeader_prepend_numOfLines}"

    #Update 'menuTitle'
    local menuTitle="${DOCKER__FG_DEEPORANGE}Output of command ${DOCKER__NOCOLOR} "
    menuTitle+="<${DOCKER__FG_REDORANGE}${cmd__input}${DOCKER__NOCOLOR}>"

    #Execute function
    show_fileContent_wo_select__func "${docker__enter_cmdline_mode_out__fpath}" \
                    "${menuTitle}" \
                    "${DOCKER__EMPTYSTRING}" \
                    "${DOCKER__ENTER_CMD_LOCATIONINFO}" \
                    "${DOCKER__ENTER_CMD_MENUOPTIONS}" \
                    "${DOCKER__ENTER_CMD_ERRORMSG}" \
                    "${DOCKER__EMPTYSTRING}" \
                    "${docker__show_fileContent_wo_select_func_out__fpath}" \
                    "${DOCKER__TABLEROWS_20}" \
                    "${DOCKER__FOURSPACES}" \
                    "${DOCKER__TRUE}"

    #Get result from file.
    docker__myAnswer=`get_output_from_file__func \
                        "${docker__show_fileContent_wo_select_func_out__fpath}" \
                        "${DOCKER__LINENUM_1}"`
}

docker__cmd_readinput_handler__sub() {
    #Define local variables
    local arrow_direction=${DOCKER__EMPTYSTRING}
    local echoMsg=${EMPTYSTRING}

    #Disable stty interrupt
    #Note: this is necesary in order to capture Ctrl+C without executing Ctrl+C
    disable_stty_intr__func

    #Initialization
    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

    #Show file content (including Tibbo header)
    docker__show_fileContent_handler__sub "${DOCKER__DASH}"

    #Start read-input
    #Arrow-up/down is used to cycle through the 'cached' input
    while true 
    do
        #Reset arrow-direction
        arrow_direction=${DOCKER__EMPTYSTRING}

        #Get current directory
        docker__currDir=$(pwd)

        #Print remarks:
        if [[ ${docker__refresh_readInput_only} == false ]]; then
            echo -e "${DOCKER__ENTER_CMD_REMARKS}"
        else
            #Reset flag
            docker__refresh_readInput_only=false
        fi

        #Print horizontal line
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        
        #Color 'docker__currDir'
        #   Output: docker__echoMsg
        docker__echoMsg_handler__sub

        #Show read-input message (using echo)
        echo "${docker__echoMsg}${docker__cmd}"

        #Move right
        moveUp_oneLine_then_moveRight__func "${docker__echoMsg}" "${docker__cmd}"

        #Input your key
        read -N1 -rs docker__keyInput

        #Move-down
        moveDown__func "${DOCKER__NUMOFLINES_1}"

        case "${docker__keyInput}" in
            ${DOCKER__ESCAPEKEY})
                docker__escapekey_handler__sub
                ;;
            ${DOCKER__CTRL_C})
                docker__exit_handler__sub
                ;;
            *)
                case "${docker__keyInput}" in
                    ${DOCKER__ENTER})
                        docker__enter_handler__sub
                        ;;
                    ${DOCKER__BACKSPACE})
                        docker__backspace_handler__sub
                        ;;
                    ${DOCKER__TAB})
                        docker__tab_handler__sub
                        ;;
                    *)
                        docker__append_keyInput_handler__sub
                        ;;
                esac
                ;;
        esac

        #Check if flag is given to break loop
        if [[ ${docker__parentWhileLoop_isExit} == true ]]; then
            break
        fi
    done
}

docker__append_keyInput_handler__sub() {
    #wait for another 0.5 seconds to capture additional characters.
    #Remark:
    #   This part has been implemented just in case long text has been copied/pasted.
    read -rs -t0.01 docker__keyInput_add

    #Append 'docker__keyInput_add' to 'docker__keyInput'
    docker__keyInput="${docker__keyInput}${docker__keyInput_add}"
    
    #Append 'docker__keyInput' to 'str'
    if [[ ! -z ${docker__keyInput} ]]; then
        docker__cmd="${docker__cmd}${docker__keyInput}"
    fi

    #Set flag to true
    docker__refresh_readInput_only=true
    
    #Move-up and clean
    moveUp_and_cleanLines__func "${docker__fixed_and_echoMsg_numOfLines}"
}

docker__backspace_handler__sub() {
    #Define variables
    local cmd_len=0

    #Get string length
    cmd_len=${#docker__cmd}

    #Check if the length is greater than 0
    #REMARK:
    #	If FALSE, then do not execute this part, otherwise...
    #	...the following ERROR would occur:
    #	" cmd_len: substring expression < 0"
    if [[ ${cmd_len} -gt 0 ]]; then	#length MUST be greater than 0
        #Substract by 1
        cmd_len=$((cmd_len-1))				

        #Substract 1 TRAILING character
        docker__cmd=${docker__cmd:0:cmd_len}
    else
        docker__cmd=${EMPTYSTRING}
    fi

    #Set flag to true
    docker__refresh_readInput_only=true

    #Move-up and clean
    moveUp_and_cleanLines__func "${docker__fixed_and_echoMsg_numOfLines}"
}

docker__echoMsg_handler__sub() {
    #Define variables
    local objStr=${DOCKER__EMPTYSTRING}
    local occurrence_index=1

    #Reset variable
    docker__currDir_colored=${DOCKER__EMPTYSTRING}
    
    #Color 'docker__currDir'
    #   slash -> DOCKER__FG_LIGHTGREY
    #   all other chars -> DOCKER__FG_LIGHTBLUE
    while true
    do
        #Incremente cut-index
        occurrence_index=$((occurrence_index + 1))

        #Get substring which follows directly after a slash
        #Meaning of:
        #   occurrence_index: nth-occurrence of slash '/'
        #   -d"/": find slash '/'
        #   -f"occurrence_index": fetch the substring, which is directly found on the left
        #                         side of the slash at the specified occurrence_index.
        #Remark:
        #   the first substring that can be fetched starts at the 2nd occurrence, thus 'occurrence_index = 2'
        objStr=`echo "${docker__currDir}" | cut -d"${DOCKER__SLASH}" -f${occurrence_index}`

        #Check if 'objStr' is a value
        if [[ ! -z ${objStr} ]]; then   #is a value
            docker__currDir_colored="${docker__currDir_colored}"
            docker__currDir_colored+="${DOCKER__NOCOLOR}${DOCKER__SLASH}"
            docker__currDir_colored+="${DOCKER__FG_LIGHTBLUE}${objStr}${DOCKER__NOCOLOR}"
        else    #is an Empty String
            break
        fi
    done

    #Prepare message 'docker__echoMsg' 
    docker__echoMsg="${docker__currDir_colored} (${DOCKER__FG_LIGHTGREY}${DOCKER__CTRL_C_COLON_QUIT}${DOCKER__NOCOLOR})${DOCKER__FG_LIGHTBLUE}>${DOCKER__NOCOLOR}"
}

docker__enter_handler__sub() {
    #Check if there were any ';c' issued.
    #In other words, whether 'docker__cmd' contains any of the above semi-colon chars.
    #If that's the case then function 'get_endResult_ofString_with_semiColonChar__func'
    #   will handle and return the result 'ret'.
    docker__cmd_clean=`get_endResult_ofString_with_semiColonChar__func "${docker__cmd}"`

    #Remove leading spaces
    docker__cmd_clean=`echo "${docker__cmd_clean}" | sed 's/^ *//g'`

    case "${docker__cmd_clean}" in
        ${DOCKER__EMPTYSTRING})
            #Reset variable
            docker__cmd=${DOCKER__EMPTYSTRING}

            #Set flag to true
            docker__refresh_readInput_only=true
            
            #Move-up and clean
            moveUp_and_cleanLines__func "${docker__fixed_and_echoMsg_numOfLines}"
                        
            # #First Move-down, then Move-up, after that clean line
            # moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_8}"
            ;;
        ${DOCKER__EXIT})
            docker__exit_handler__sub
            ;;
        *)
            if [[ ! -z ${docker__cmd} ]]; then  #command provided
                #Execute command and write result to file
                #Output: docker__isExcluded
                docker__exec_cmd_and_write_output_toFile__sub "${docker__cmd}"

                if [[ ${docker__isExcluded} == false ]]; then
                    #Show file content (including Tibbo header)
                    docker__show_fileContent_handler__sub "${docker__cmd}"
                else
                    #***IMPORTANT: Reset flag
                    docker__isExcluded=false
                    
                    #Check if 'docker__exitCode = 0'
                    #Remarks:
                    #   1. 'docker__exitCode' is retrieved in 'docker__exec_cmd_and_write_output_toFile__sub'.
                    #   2. command 'cd' is excluded. This means that after executing this command...
                    #      ...and if the execution was successful (docker__exitCode = 0), then...
                    #      ...only the 'docker__echoMsg' has to be updated (excluding the 'DOCKER__ENTER_CMD_REMARKS').
                    if [[ ${docker__exitCode} -eq ${DOCKER__NUMOFMATCH_0} ]]; then  #execution was successful
                        #Set flag to true
                        docker__refresh_readInput_only=true
                        
                        #Move-up and clean
                        moveUp_and_cleanLines__func "${docker__fixed_and_echoMsg_numOfLines}"
                    else    #execution was unsuccessful
                        #Show file content (including Tibbo header)
                        docker__show_fileContent_handler__sub "${docker__cmd}"
                    fi
                fi

                #Reset variables
                docker__cmd=${DOCKER__EMTPYSTRING}
            else    #no command provided
                #Set flag to true
                docker__refresh_readInput_only=true
                
                #Move-up and clean
                moveUp_and_cleanLines__func "${docker__fixed_and_echoMsg_numOfLines}"
            fi
            ;;
    esac
}
docker__exit_handler__sub() {
    #Set flag to true
    docker__parentWhileLoop_isExit=true

    #Enable ssty interrupt
    enable_stty_intr__func

    #Move-down and clean 1 line
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
}
docker__exec_cmd_and_write_output_toFile__sub() {
    #Input args
    local cmd__input="${1}"

    #Reset array
    docker__output_arr=()

    #Check if 'cmd__wo_leadingSpaces' is found in the exclusion array-list 'DOCKER__EXCL_CMD_ARR'
    docker__isExcluded=`checkFor_leading_partialMatch_of_pattern_within_array__func "${cmd__input}" \
                        "${DOCKER__EXCL_CMD_ARR[@]}"`

    if [[ ${docker__isExcluded} == true ]]; then  #match was found
        #Execute command WIRHOUT writing to array and file
        ${cmd__input}
    else    
        #Execute command WITH writing to array and file
        #Remark:
        #   In order to be able to execute commands with SPACES, 'eval' must be used
        readarray -t docker__output_arr < <(eval ${cmd__input})
    fi

    #Write input to 'docker__cachedInput_arr' and 'docker__enter_cmdline_mode_cache__fpath'
    docker__write_input_to_cache_file_and_update_array__sub

    #Write 'docker__output_arr' to file 'docker__enter_cmdline_mode_out__fpath'
    #Remark:
    #   Do NOT use 'echo' because...
    #   ...all array-elements will be written to the file as ONE line...
    #   ...instead of multiple lines.
    printf "%s\n" "${docker__output_arr[@]}" > ${docker__enter_cmdline_mode_out__fpath}
}
docker__write_input_to_cache_file_and_update_array__sub() {
    #Get the exit-code of the previously executed command.
    docker__exitCode=$?

    #Validate docker__exitCode
    if [[ ${docker__exitCode} -eq 0 ]]; then    #no errors found
        #Check if 'cmd__input' is already added to file ''
        local lineNum_found=`retrieve_lineNum_from_file__func "${cmd__input}" \
                        "${docker__enter_cmdline_mode_cache__fpath}"`

        if [[ ${lineNum_found} -gt ${DOCKER__LINENUM_1} ]]; then
            #Deliete line specified by 'lineNum_found'
            delete_lineNum_from_file__func "${lineNum_found}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${docker__enter_cmdline_mode_cache__fpath}"
        fi

        #Add 'cmd__input' to cache-file 'docker__enter_cmdline_mode_cache__fpath'
        insert_string_into_file_at_specified_lineNum__func "${cmd__input}" \
                        "${DOCKER__LINENUM_1}" \
                        "${docker__enter_cmdline_mode_cache__fpath}" \
                        "${DOCKER__TRUE}"

        #Only keep a maximum of specified lines
        remove_all_lines_from_file_after_a_specified_lineNum__func \
                        "${docker__enter_cmdline_mode_cache__fpath}" \
                        "${docker__enter_cmdline_mode_tmp__fpath}" \
                        "${DOCKER__ENTER_CMDLINE_MODE_CACHE_MAX}"

        #Update array
        docker__update_cache_array__sub
    fi
}
docker__update_cache_array__sub() {
    #Check if cache-file contains data
    if [[ ! -s ${docker__enter_cmdline_mode_cache__fpath} ]]; then  #contains no data
        return
    fi

    #Reset array
    docker__cachedInput_arr=()

    #Read from file to array
    readarray -t docker__cachedInput_arr < ${docker__enter_cmdline_mode_cache__fpath}

    #Update array-length
    docker__cachedInput_arrLen=${#docker__cachedInput_arr[@]}

    # #Index starts with 0, therefore deduct array-length by 1
    docker__cachedInput_arrIndex_max=$((docker__cachedInput_arrLen-1))

    # #Update current array-index
    # docker__cachedInput_arrIndex=${docker__cachedInput_arrIndex_max}
}

docker__escapekey_handler__sub() {
    # Flush "stdin" with 0.1  sec timeout.
    read -rsn1 -t 0.1 tmp
    if [[ "$tmp" == "[" ]]; then
        # Flush "stdin" with 0.1  sec timeout.
        read -rsn1 -t 0.1 tmp

        case "$tmp" in
            "A")
                arrow_direction=${DOCKER__ARROWUP}
                ;;
            "B")
                arrow_direction=${DOCKER__ARROWDOWN}
                ;;
        esac
    fi

    #Flush "stdin" with 0.1  sec timeout.
    read -rsn5 -t 0.1

    #*********************************************************
    #This part MUST be executed after the 'Arrow-key handling'
    #*********************************************************
    if [[ ${docker__cachedInput_arrIndex} -eq ${DOCKER__MINUS_ONE} ]]; then  #initial start of this script
        #Set 'docker__cachedInput_arrIndex = 0'
        #Note: this would make sure that the 1st array-element is always shown
        docker__cachedInput_arrIndex=0
    else    #after the initial start
        if [[ ${arrow_direction} == ${DOCKER__ARROWUP} ]]; then
            if [[ ${docker__cachedInput_arrIndex} -eq 0 ]]; then    #index is already leveled to 0
                docker__cachedInput_arrIndex=${docker__cachedInput_arrIndex_max}    #set index to the max. value
            else    #for all other indexes
                docker__cachedInput_arrIndex=$((docker__cachedInput_arrIndex-1))
            fi
        else    #arrow_direction = DOCKER__ARROWDOWN
            if [[ ${docker__cachedInput_arrIndex} -eq ${docker__cachedInput_arrIndex_max} ]]; then  #index is already maxed out
                docker__cachedInput_arrIndex=0
            else    #for all other indexes
                docker__cachedInput_arrIndex=$((docker__cachedInput_arrIndex+1))
            fi
        fi
    fi

    #Update variable
    docker__cmd=${docker__cachedInput_arr[docker__cachedInput_arrIndex]}

    #Set flag to true
    docker__refresh_readInput_only=true

    #Move-up and clean
    moveUp_and_cleanLines__func "${docker__fixed_and_echoMsg_numOfLines}"
}

docker__tab_handler__sub() {
    #Get the length of 'docker__cmd'
    local strLen=${#docker__cmd}

    #Check if 'docker__cmd' iS an Empty String
    if [[ ${strLen} -eq ${DOCKER__NUMOFMATCH_0} ]]; then
        moveUp_and_cleanLines__func "${docker__tot_numOfLines}"
        
        return
    fi

    #Print header
    docker__load_header__sub "${docker__tibboHeader_prepend_numOfLines}"

    #Get the closest match
    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    # IMPORTANT:
    #   make sure to call the script with 'source'
    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    source ${compgen__query_w_autocomplete__fpath} "${containerID__input}" \
                    "${docker__cmd}" \
                    "${DOCKER__TABLEROWS_20}" \
                    "${DOCKER__TABLECOLS_0}" \
                    "${docker__menuTitle_indent}" \
                    "${compgen__query_w_autocomplete_out__fpath}"


    #Get the exitcode just in case a Ctrl-C was pressed in script 'docker__readInput_w_autocomplete__fpath'.
    docker__exitCode=$?
    if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
        exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
    else
        #Get result from file.
        docker__cmd=`get_output_from_file__func \
                        "${compgen__query_w_autocomplete_out__fpath}" \
                        "${DOCKER__LINENUM_1}"`
    fi  
}




#---MAIN SUBROUTINE
main__sub() {

    docker__environmental_variables__sub

    docker__load_source_files__sub

    docker__init_variables__sub

    docker__load_constants__sub

    docker__calculate_tot_numOfLines__sub

    docker__delete_files__sub

    docker__update_cache_array__sub

    docker__cmd_readinput_handler__sub
}



#---EXECUTE
main__sub
