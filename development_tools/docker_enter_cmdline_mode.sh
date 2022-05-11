#!/bin/bash -m
#---INPUT ARGS
containerID__input=${1}



#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
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

docker__load_constants__sub() {
    DOCKER__ENTER_CMD_REMARKS="${DOCKER__BG_ORANGE}Remarks:${DOCKER__NOCOLOR}\n"
    DOCKER__ENTER_CMD_REMARKS+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}\\${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}each special character within a command, file, or folder,...\n"
    DOCKER__ENTER_CMD_REMARKS+="     ...MUST to be prepended with backslash.\n"
	DOCKER__ENTER_CMD_REMARKS+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}ENTER${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}to execute${DOCKER__NOCOLOR}\n"
    DOCKER__ENTER_CMD_REMARKS+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}TAB${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}auto-complete${DOCKER__NOCOLOR}\n"
    DOCKER__ENTER_CMD_REMARKS+="${DOCKER__DASH} ${DOCKER__FG_YELLOW};c${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}clear${DOCKER__NOCOLOR}"

    DOCKER__PATTERN_CD="cd"
}

docker__init_variables__sub() {
    docker__cachedInput_arr=()
    docker__cachedInput_arrLen=0
    docker__cachedInput_arrIndex=0
    docker__cachedInput_arrIndex_max=0

    docker__output_arr=()

    docker__cmd=${DOCKER__EMPTYSTRING}
    docker__keyInput=${DOCKER__EMPTYSTRING}
    docker__keyInput_add=${DOCKER__EMPTYSTRING}

    docker__currDir=${DOCKER__EMPTYSTRING}
    docker__currDir_colored=${DOCKER__EMPTYSTRING}
    docker__echoMsg=${DOCKER__EMPTYSTRING}

	docker__exitCode=0
}

docker__delete_files__sub() {
    if [[ -f ${docker__enter_cmdline_out__fpath} ]]; then
        rm ${docker__enter_cmdline_out__fpath}
    fi
}

docker__cmd_readinput_handler__sub() {
    #Define local variables
    local arrow_direction=${DOCKER__EMPTYSTRING}
    local echoMsg=${EMPTYSTRING}

    #Start read-input
    #Arrow-up/down is used to cycle through the 'cached' input
    while true 
    do
        #Reset arrow-direction
        arrow_direction=${DOCKER__EMPTYSTRING}

        #Get current directory
        docker__currDir=$(pwd)

        #Color 'docker__currDir'
        #   Output: docker__currDir_colored
        docker__currDir_color_handler__sub

        #Prepare message 'docker__echoMsg' 
        docker__echoMsg="${docker__currDir_colored} (${DOCKER__FG_LIGHTGREY}${DOCKER__CTRL_C_COLON_QUIT}${DOCKER__NOCOLOR})${DOCKER__FG_LIGHTBLUE}>${DOCKER__NOCOLOR}"

        #Show remarks:
        echo -e "${DOCKER__ENTER_CMD_REMARKS}"
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

    #Move-up and clean
    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_7}"
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

    #Move-up and clean
    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_7}"
}

docker__currDir_color_handler__sub() {
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
}

docker__enter_handler__sub() {
    #Define local variables
    local cmd_tmp=${DOCKER__EMPTYSTRING}

    #Check if there were any ';c' issued.
    #In other words, whether 'docker__cmd' contains any of the above semi-colon chars.
    #If that's the case then function 'get_endResult_ofString_with_semiColonChar__func'
    #   will handle and return the result 'ret'.
    cmd_tmp=`get_endResult_ofString_with_semiColonChar__func ${docker__cmd}`

    case "${cmd_tmp}" in
        ${DOCKER__EMPTYSTRING})
            #Reset variable
            docker__cmd=${DOCKER__EMPTYSTRING}
            
            #First Move-down, then Move-up, after that clean line
            moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_8}"
            ;;
        *)
            if [[ ! -z ${docker__cmd} ]]; then  #command provided
                #Execute command and write result to file
                docker__exec_cmd_and_write_output_toFile__sub

                #Print Command Output
                if [[ -f ${docker__enter_cmdline_out__fpath} ]]; then
                    cat ${docker__enter_cmdline_out__fpath}
                fi

                #Reset variable
                docker__cmd=${DOCKER__EMTPYSTRING}

                #Move-down
                # moveDown__func "${DOCKER__NUMOFLINES_1}"
            else    #no command provided
                #Move-up one line
                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_7}"
            fi
            ;;
    esac
}
docker__exec_cmd_and_write_output_toFile__sub() {
    #Define header to-be-printed
    docker__output_arr="${DOCKER__EMPTYSTRING}\n"
    docker__output_arr+="${DOCKER__EMPTYSTRING}\n"
    docker__output_arr+="${DOCKER__FG_LIGHTGREY}${docker__dup_horizLine}${DOCKER__NOCOLOR}\n"
    docker__output_arr+="${DOCKER__FG_DEEPORANGE}Results of command ${DOCKER__NOCOLOR} <${DOCKER__FG_REDORANGE}${docker__cmd}${DOCKER__NOCOLOR}>\n"
    docker__output_arr+="${DOCKER__FG_LIGHTGREY}${docker__dup_horizLine}${DOCKER__NOCOLOR}\n"

    #Execute command
    #Remark:
    #   In order to be able to execute commands with SPACES, 'eval' must be used.
    docker__output_arr+=$(eval ${docker__cmd})

    #Get the exit-code of the previously executed command.
    exitCode=$?

    #Validate exitCode
    if [[ ${exitCode} -eq 0 ]]; then    #no errors found
        #add command to array
        docker__cachedInput_arr+=("${docker__cmd}")

        #Update array-length
        docker__cachedInput_arrLen=${#docker__cachedInput_arr[@]}

        #Index starts with 0, therefore deduct array-length by 1
        docker__cachedInput_arrIndex_max=$((docker__cachedInput_arrLen-1))

        #Update current array-index
        docker__cachedInput_arrIndex=${docker__cachedInput_arrIndex_max}
    fi

    #Append horizontal line to array
    docker__output_arr+="${DOCKER__EMPTYSTRING}\n"
    docker__output_arr+="${DOCKER__EMPTYSTRING}\n"
    docker__output_arr+="${DOCKER__FG_LIGHTGREY}${docker__dup_horizLine}${DOCKER__NOCOLOR}"
    
    #Write to file
    echo -e "${docker__output_arr[@]}" > ${docker__enter_cmdline_out__fpath}
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

    #Update variable
    docker__cmd=${docker__cachedInput_arr[docker__cachedInput_arrIndex]}

    #Move-up and clean
    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_7}"
}

docker__tab_handler__sub() {
    #Get the length of 'docker__cmd'
    local strLen=${#docker__cmd}

    #Check if 'docker__cmd' iS an Empty String
    if [[ ${strLen} -eq ${DOCKER__NUMOFMATCH_0} ]]; then
        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_7}"
        
        return
    fi

    #Get the closest match
    ${compgen__query_w_autocomplete__fpath} "${containerID__input}" \
                    "${docker__cmd}" \
                    "${DOCKER__TABLEROWS_20}" \
                    "${DOCKER__TABLECOLS_0}" \
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

    docker__load_constants__sub

    docker__init_variables__sub

    docker__delete_files__sub

    docker__cmd_readinput_handler__sub
}



#---EXECUTE
main__sub
