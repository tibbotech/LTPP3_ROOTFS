#---INPUT ARGS
containerID__input=${1}
ltpp3g2_username=${2}
ltpp3g2_ipAddr=${3}



#---SUBROUTINES
docker__get_source_fullpath__sub() {
    #Define constants
    local DOCKER__PHASE_CHECK_CACHE=1
    local DOCKER__PHASE_FIND_PATH=10
    local DOCKER__PHASE_EXIT=100

    #Define variables
    local docker__phase=""

    local docker__current_dir=
    local docker__tmp__dir=""

    local docker__development_tools__foldername=""
    local docker__LTPP3_ROOTFS__foldername=""
    local docker__global__filename=""
    local docker__parentDir_of_LTPP3_ROOTFS__dir=""

    local docker__mainmenu_path_cache__filename=""
    local docker__mainmenu_path_cache__fpath=""

    local docker__find_dir_result_arr=()
    local docker__find_dir_result_arritem=""
    local docker__find_dir_result_arrlen=0
    local docker__find_dir_result_arrlinectr=0
    local docker__find_dir_result_arrprogressperc=0

    local docker__path_of_development_tools_found=""
    local docker__parentpath_of_development_tools=""

    local docker__isfound=""

    #Set variables
    docker__phase="${DOCKER__PHASE_CHECK_CACHE}"
    docker__current_dir=$(dirname $(readlink -f $0))
    docker__tmp__dir=/tmp
    docker__development_tools__foldername="development_tools"
    docker__global__filename="docker_global.sh"
    docker__LTPP3_ROOTFS__foldername="LTPP3_ROOTFS"

    docker__mainmenu_path_cache__filename="docker__mainmenu_path.cache"
    docker__mainmenu_path_cache__fpath="${docker__tmp__dir}/${docker__mainmenu_path_cache__filename}"

    docker_result=false

    #Start loop
    while true
    do
        case "${docker__phase}" in
            "${DOCKER__PHASE_CHECK_CACHE}")
                if [[ -f "${docker__mainmenu_path_cache__fpath}" ]]; then
                    #Get the directory stored in cache-file
                    docker__LTPP3_ROOTFS_development_tools__dir=$(awk 'NR==1' "${docker__mainmenu_path_cache__fpath}")

                    #Move one directory up
                    docker__parentpath_of_development_tools=$(dirname "${docker__LTPP3_ROOTFS_development_tools__dir}")

                    #Check if 'development_tools' is in the 'LTPP3_ROOTFS' folder
                    docker__isfound=$(docker__checkif_paths_are_related "${docker__current_dir}" \
                            "${docker__parentpath_of_development_tools}" "${docker__LTPP3_ROOTFS__foldername}")
                    if [[ ${docker__isfound} == false ]]; then
                        docker__phase="${DOCKER__PHASE_FIND_PATH}"
                    else
                        docker_result=true

                        docker__phase="${DOCKER__PHASE_EXIT}"
                    fi
                else
                    docker__phase="${DOCKER__PHASE_FIND_PATH}"
                fi
                ;;
            "${DOCKER__PHASE_FIND_PATH}")   
                #Print
                echo -e "---:\e[30;38;5;215mSTART\e[0;0m: find path of folder \e[30;38;5;246m'${docker__development_tools__foldername}\e[0;0m : \e[1;33mDONE\e[0;0m"

                #Reset variable
                docker__LTPP3_ROOTFS_development_tools__dir=""

                #Start loop
                while true
                do
                    #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
                    #... and read to array 'find_result_arr'
                    readarray -t docker__find_dir_result_arr < <(find  / -type d -iname "${docker__LTPP3_ROOTFS__foldername}" 2> /dev/null)

                    #Get array-length
                    docker__find_dir_result_arrlen=${#docker__find_dir_result_arr[@]}

                    #Iterate thru each array-item
                    for docker__find_dir_result_arritem in "${docker__find_dir_result_arr[@]}"
                    do
                        docker__isfound=$(docker__checkif_paths_are_related "${docker__current_dir}" \
                                "${docker__find_dir_result_arritem}"  "${docker__LTPP3_ROOTFS__foldername}")
                        if [[ ${docker__isfound} == true ]]; then
                            #Update variable 'docker__path_of_development_tools_found'
                            docker__path_of_development_tools_found="${docker__find_dir_result_arritem}/${docker__development_tools__foldername}"

                            # #Increment counter
                            docker__find_dir_result_arrlinectr=$((docker__find_dir_result_arrlinectr+1))

                            #Calculate the progress percentage value
                            docker__find_dir_result_arrprogressperc=$(( docker__find_dir_result_arrlinectr*100/docker__find_dir_result_arrlen ))

                            #Moveup and clean
                            if [[ ${docker__find_dir_result_arrlinectr} -gt 1 ]]; then
                                tput cuu1
                                tput el
                            fi

                            #Print
                            #Note: do not print the '100%'
                            if [[ ${docker__find_dir_result_arrlinectr} -lt ${docker__find_dir_result_arrlen} ]]; then
                                echo -e "------:PROGRESS: ${docker__find_dir_result_arrprogressperc}%"
                            fi

                            #Check if 'directory' exist
                            if [[ -d "${docker__path_of_development_tools_found}" ]]; then    #directory exists
                                #Update variable
                                #Remark:
                                #   'docker__LTPP3_ROOTFS_development_tools__dir' is a global variable.
                                #   This variable will be passed 'globally' to script 'docker_global.sh'.
                                docker__LTPP3_ROOTFS_development_tools__dir="${docker__path_of_development_tools_found}"

                                #Print
                                #Note: print the '100%' here
                                echo -e "------:PROGRESS: 100%"

                                break
                            fi
                        fi
                    done

                    #Check if 'docker__LTPP3_ROOTFS_development_tools__dir' contains any data
                    if [[ -z "${docker__LTPP3_ROOTFS_development_tools__dir}" ]]; then  #contains no data
                        echo -e "\r"
                        echo -e "***\e[1;31mERROR\e[0;0m: folder \e[30;38;5;246m${docker__development_tools__foldername}\e[0;0m: \e[30;38;5;131mNot Found\e[0;0m"
                        echo -e "\r"

                         #Update variable
                        docker_result=false
                    else    #contains data
                        #Print
                        echo -e "---:\e[30;38;5;215mCOMPLETED\e[0;0m: find path of folder \e[30;38;5;246m'${docker__development_tools__foldername}\e[0;0m : \e[1;33mDONE\e[0;0m"


                        #Write to file
                        echo "${docker__LTPP3_ROOTFS_development_tools__dir}" | tee "${docker__mainmenu_path_cache__fpath}" >/dev/null

                        #Print
                        echo -e "---:\e[30;38;5;215mSTATUS\e[0;0m: write path to temporary cache-file: \e[1;33mDONE\e[0;0m"

                        #Update variable
                        docker_result=true
                    fi

                    #set phase
                    docker__phase="${DOCKER__PHASE_EXIT}"

                    #Exit loop
                    break
                done
                ;;    
            "${DOCKER__PHASE_EXIT}")
                break
                ;;
        esac
    done

    #Exit if 'docker_result = false'
    if [[ ${docker_result} == false ]]; then
        exit 99
    fi

    #Retrieve directories
    #Remark:
    #   'docker__LTPP3_ROOTFS__dir' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/
    docker__parentDir_of_LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS__dir%/*}    #move two directories up. This directory is the one-level higher than LTPP3_ROOTFS/

    #Get full-path
    #Remark:
    #   'docker__global__fpath' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__global__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__global__filename}
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

docker__init_variables__sub() {
    docker__cachedInput_arr=()
    docker__cachedInput_arrLen=0
    docker__cachedInput_arrIndex=-1 #must be set to (-1)
    docker__cachedInput_arrIndex_max=0

    docker__cmd=${DOCKER__EMPTYSTRING}
    docker__cmd_clean=${DOCKER__EMPTYSTRING}
    docker__keyInput=${DOCKER__EMPTYSTRING}
    docker__keyInput_add=${DOCKER__EMPTYSTRING}

    # docker__myAnswer=${DOCKER__EMPTYSTRING}

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

    DOCKER__ENTER_CMD_LOCATIONINFO="${DOCKER__FOURSPACES}${DOCKER__FG_ORANGE223}Location${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}${docker__enter_cmdline_mode_out__fpath}${DOCKER__NOCOLOR}"
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

    #Update 'menuTitle'
    local menuTitle="${DOCKER__FG_ORANGE208}Output of command ${DOCKER__NOCOLOR} "
    menuTitle+="<${DOCKER__FG_ORANGE203}${cmd__input}${DOCKER__NOCOLOR}>"

    #Execute function
    show_fileContent_wo_select__func "${docker__enter_cmdline_mode_out__fpath}" \
                    "${menuTitle}" \
                    "${DOCKER__EMPTYSTRING}" \
                    "${DOCKER__ENTER_CMD_LOCATIONINFO}" \
                    "${DOCKER__ENTER_CMD_MENUOPTIONS}" \
                    "${DOCKER__ENTER_CMD_ERRORMSG}" \
                    "${DOCKER__EMPTYSTRING}" \
                    "${DOCKER__EMPTYSTRING}" \
                    "${docker__show_fileContent_wo_select_func_out__fpath}" \
                    "${DOCKER__TABLEROWS_20}" \
                    "${DOCKER__FOURSPACES}" \
                    "${DOCKER__TRUE}" \
                    "${docker__tibboHeader_prepend_numOfLines}" \
                    "${DOCKER__TRUE}"

    #Get result from file.
    get_output_from_file__func \
                        "${docker__show_fileContent_wo_select_func_out__fpath}" \
                        "${DOCKER__LINENUM_1}"

    #In function 'show_fileContent_wo_select__func',...
    #...after press-any-key, the cursor moves down 1 line.
    #To fix this, the cursor has to be moved up 1 line.
    moveUp_and_cleanLines__func "${DOCKER__LINENUM_1}"
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
                docker__exec_cmd_and_write_output_toFile__sub "${docker__cmd}" "${ltpp3g2_username}" "${ltpp3g2_ipAddr}"

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
    local usr__input="${2}"
    local ip__input="${3}"

    #Defube variables
    local top_isfound="${DOCKER__EMPTYSTRING}"

    #Check if 'cmd__wo_leadingSpaces' is found in the exclusion array-list 'DOCKER__EXCL_CMD_ARR'
    docker__isExcluded=`checkFor_leading_partialMatch_of_pattern_within_array__func "${cmd__input}" \
                        "${DOCKER__EXCL_CMD_ARR[@]}"`

    if [[ ${docker__isExcluded} == true ]]; then  #match was found
        #Execute command WIRHOUT writing to array and file
        ${cmd__input}
    else    
        #Check if pattern 'top' is found in 'cmd__input'
        top_isfound=$(echo "${cmd__input}" | grep -o "${DOCKER__PATTERN_TOP}")
        if [[ -n "${top_isfound}" ]]; then
            #Append string ( -n1) to 'top'
            #Remark:
            #   Since we are using a shell to call the 'top' command
            #   ...it is important to append ( -n1), forces 'top' to show
            #   ...only 1 result, after which 'top' MUST terminate.
            cmd__input+=" -n1"
        fi

        #Execute command and write output to a file
        if [[ -z "${usr__input}" ]] && [[ -z "${ip__input}" ]]; then
            #Note: in order to be able to execute commands with SPACES, 'eval' must be used.
            eval ${cmd__input} > ${docker__enter_cmdline_mode_out__fpath}
        else
            #Execute command via SSH
            ssh -tt ${ltpp3g2_username}@${ltpp3g2_ipAddr} "${cmd__input}" > "${docker__enter_cmdline_mode_out__fpath}"
        fi

        #If command 'top' was execited, then:
        #1. At the 1st line: remove characters ([?1h=[?25l[H[2J(B[m) BEFORE the pattern 'top'.
        #Note: The escaped characters ([?1h=[?25l[H[2J(B[m) forces
        #      ...the table to be shown on TOP of the Terminal Window.
        if [[ -n "${top_isfound}" ]]; then
            sed -i "1s/^.*${DOCKER__PATTERN_TOP}/${DOCKER__PATTERN_TOP}/" "${docker__enter_cmdline_mode_out__fpath}"
        fi

        #2. Replace all '[63;1H' with '[0;0m'
        #Note: The escaped character ([63;1H) forces empty lines to be drawn...
        #      ...below the table to fill up the empty space of the Terminal Window.
        sed -i "s/${SED_LBRACKET_63_SEMICOLON_1H}/${SED_LEFBRACKET_0_SEMICOLON_0M}/g" "${docker__enter_cmdline_mode_out__fpath}"
    fi

    #Write input to 'docker__cachedInput_arr' and 'docker__enter_cmdline_mode_cache__fpath'
    docker__write_cmdinput_to_cache_file_and_update_array__sub
}
docker__write_cmdinput_to_cache_file_and_update_array__sub() {
    #Get the exit-code of the previously executed command.
    docker__exitCode=$?

    #Validate docker__exitCode
    if [[ ${docker__exitCode} -eq 0 ]]; then    #no errors found
        #Check if 'cmd__input' is already added to file 'docker__enter_cmdline_mode_cache__fpath'
        local lineNum_found=`retrieve_lineNum_from_file__func "${cmd__input}" \
                        "${docker__enter_cmdline_mode_cache__fpath}"`

        if [[ ${lineNum_found} -gt ${DOCKER__LINENUM_1} ]]; then
            #Delete line specified by 'lineNum_found'
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
                    "${compgen__query_w_autocomplete_out__fpath}" \
                    "${docker__tibboHeader_prepend_numOfLines}"


    #Get the exitcode just in case a Ctrl-C was pressed in script 'compgen__query_w_autocomplete__fpath'.
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
    docker__get_source_fullpath__sub

    docker__load_global_fpath_paths__sub

    docker__init_variables__sub

    docker__load_constants__sub

    docker__calculate_tot_numOfLines__sub

    docker__delete_files__sub

    docker__update_cache_array__sub

    docker__cmd_readinput_handler__sub
}



#---EXECUTE
main__sub
