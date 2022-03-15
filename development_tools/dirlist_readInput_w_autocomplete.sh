#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---INPUT ARGS
containerID__input=${1}
readMsg__input=${2}
readMsgRemarks__input=${3}
output_fPath__input=${4}
tmp_fPath__input=${5}



#---FUNCTIONS
function arrowKeys_upDown_handler__func() {
    # Flush "stdin" with 0.1  sec timeout.
    read -rsn1 -t 0.1 tmp
    if [[ "$tmp" == "[" ]]; then
        # Flush "stdin" with 0.1  sec timeout.
        read -rsn1 -t 0.1 tmp
    fi

    #Flush "stdin" with 0.1  sec timeout.
    read -rsn5 -t 0.1
}

function autocomplete__func() {
    #Input args
    #Remark:
    #1. non-array parameter(s) precede(s) array-parameter
    #2. For each non-array parameter, the 'shift' operator has to be added an array-parameter
    local fpath__input=${1}
    shift
    local dataArr__input=("$@")

    #Define constants
    local PHASE_AUTO=0
    local PHASE_EXIT=1

    #Define and initialize variables
    local col1=${DOCKER__EMPTYSTRING}
    local col2=${DOCKER__EMPTYSTRING}
    local col3=${DOCKER__EMPTYSTRING}
    local dir=${DOCKER__EMPTYSTRING}
    local fpath=${DOCKER__EMPTYSTRING}
    local keyWord=${DOCKER__EMPTYSTRING}
    local keyword_output=${DOCKER__EMPTYSTRING}
    local keyWord_bck=${DOCKER__EMPTYSTRING}
    local phase=${PHASE_AUTO}
    local ret=${DOCKER__EMPTYSTRING}

    local dataArr_1stItem_len=0
    local keyWord_len=0
    local numOfMatch=0
    local numOfMatch_init=0

    local isDirectory=false
    local slash_isFound=false



    #Check if 'fpath__input' is an Empty String
    if [[ -z ${fpath__input} ]]; then
        keyword_output=${DOCKER__SLASH}

        phase=${PHASE_EXIT}
    fi

    #Split directory from file/folder
    dir=`get_dirname_from_specified_path__func "${fpath__input}"`
    keyWord=`get_basename_from_specified_path__func "${fpath__input}"`
    
    #Check if 'keyWord' is an Empty String
    #Remark:
    #   dir is Not an Empty String
    if [[ -z ${keyWord} ]]; then
        keyword_output=${keyWord}

        #Set the following parameters to '1'
        #Remark:
        #   There is No Match for the specified 'keyWord' because it is an Empty String
        #   However, there is a match for the current directory 'dir' itself
        numOfMatch_init=1
        numOfMatch=1

        phase=${PHASE_EXIT}
    fi

    #Select case
    while true
    do
        case "${phase}" in
            ${PHASE_AUTO})
                #Substitute all backslash's '\' with double-backslash's '\\' (if any)
                #Remark:
                #   This is necessary because otherwise 'grep' will not recognize the backslash '\' as a string.
                keyWord=`echo "${keyWord}" | sed "s/${SED__BACKSLASH}/${SED__DOUBLE_BACKSLASH}/g"`       

                #Substitute all dot's '.' with backslash-dot's '\.' (if any)
                #Remark:
                #   This is necessary because otherwise 'grep' will not recognize the dot '.' as a string.
                keyWord=`echo "${keyWord}" | sed "s/${SED__DOT}/${SED__BACKSLASH_DOT}/g"`         

                #initialization
                dataArr_1stItem_len=${#dataArr__input[0]}
                numOfMatch_init=`printf '%s\n' "${dataArr__input[@]}" | grep "^${keyWord}" | wc -l` #the initial number of matches for a specified 'keyWord'
                numOfMatch=${numOfMatch_init}   #the number of matches that is being recalculated each time theh 'keyWord' changes

                #Find the closest match
                while true
                do
                    if [[ ${numOfMatch_init} -eq 0 ]]; then  #no match
                        #Set value to 'keyWord' (which is the input value)
                        keyword_output=${keyWord}

                        #Set number of matches to 0
                        numOfMatch=0

                        #Exit loop
                        break
                    elif [[ ${numOfMatch_init} -eq 1 ]]; then  #only 1 match
                        #Fetch value from array
                        keyword_output=`printf '%s\n' "${dataArr__input[@]}" | grep "^${keyWord}"`

                        #Set number of matches to 0
                        numOfMatch=1

                        #Exit loop
                        break;
                    else    #multiple matches
                        #Backup keyWord.
                        #Remark:
                        #   This backup will be used as output the moment that 'numOfMatch != numOfMatch_init'
                        keyWord_bck=${keyWord}

                        #Get keyWord length
                        keyWord_bck_len=${#keyWord_bck}

                        #Increment keyWord length by 1
                        keyWord_len=$((keyWord_bck_len + 1))

                        #Get the next keyWord by:
                        # 1. using the 1st array-element as base-word
                        # 2. and...incrementing 'keyWord' with 1 character every loop cycle
                        keyWord=${dataArr__input[0]:0:keyWord_len}

                        #Check if the total length of the 1st array-element has been reached
                        #If true, then it means that there is only 1 match.
                        if [[ ${keyWord_bck_len} -eq ${dataArr_1stItem_len} ]]; then
                            #Set 'keyword_output' to the last backup value 'keyWord_bck'
                            keyword_output=${keyWord_bck}

                            break
                        fi

                        #Get the new number of matches
                        numOfMatch=`printf '%s\n' "${dataArr__input[@]}" | grep "^${keyWord}" | wc -l`

                        #Compare the new 'numOfMatch' with the initial 'numOfMatch_init'
                        if [[ ${numOfMatch} -ne ${numOfMatch_init} ]]; then
                            #Set 'keyword_output' to the last backup value 'keyWord_bck'
                            keyword_output=${keyWord_bck}

                            #Set 'numOfMatch' to the initial value 'numOfMatch_init'
                            numOfMatch=${numOfMatch_init}

                            break
                        fi
                    fi
                done

                #Goto next-phase
                phase=${PHASE_EXIT}
                
                ;;
            ${PHASE_EXIT})
                #Compoase full-path
                fpath=${dir}${keyword_output}

                #Substitute all BackSlash-Dot's '\.' with Dot's '.' (if any)
                fpath=`echo "${fpath}" | sed "s/${SED__BACKSLASH_DOT}/${SED__DOT}/g"`

                #Substitute all backslash's '\' with double-backslash's '\\' (if any)
                fpath=`echo "${fpath}" | sed "s/${SED__BACKSLASH}/${SED__DOUBLE_BACKSLASH}/g"`       

                #Only handle this condition if 'numOfMatch = 1'
                if [[ ${numOfMatch} -eq ${DOCKER__NUMOFMATCH_1} ]]; then
                    #Check if 'fpath' is a directory
                    isDirectory=`checkIf_dir_exists__func "${containerID__input}" "${fpath}"`
                    if [[ ${isDirectory} == true ]]; then   #is directory
                        #Check if slash is found
                        slash_isFound=`checkIf_dir_has_trailing_slash "${fpath}"`
                        if [[ ${slash_isFound} == false ]]; then    #slash is NOT found
                            fpath=${fpath}${DOCKER__SLASH}  #append slash
                        fi
                    fi
                fi

                #Compose return string
                #Remark:
                #   This string consists of 3 columns delimited by a comma
                #   - col1: fpath
                #   - col2: numOfMatch_init
                #   - col3: numOfMatch
                #
                col1=${fpath}
                col2=${numOfMatch_init}
                col3=${numOfMatch}

                ret="${col1},${col2},${col3}"

                #Exit while-loop
                break
                ;;        
        esac
    done

    #Output
    echo ${ret}
}

function backspace_handler__func() {
    #Input args
    str_input=${1}

    #CHeck if 'str_input' is an EMPTYSTRING
    if [[ -z ${str_input} ]]; then
        return
    fi

    #Constants
    OFFSET=0

    #Lengths
    str_input_len=${#str_input}
    str_output_len=$((str_input_len-1))

    #Get result
    str_output=${str_input:${OFFSET}:${str_output_len}}

    #Output
    echo "${str_output}"
}

function remove_asterisk_from_string() {
    #Input args
    local str__input=${1}

    #Define variables
    local ret=${DOCKER__EMPTYSTRING}
    local str_len=0
    local str_wo_asterisk_len=0
    local asterisk_isFound=false

    #Check if asterisk is present in 'str__input'
    asterisk_isFound=`checkForMatch_keyWord_within_string__func "${DOCKER__ASTERISK}" "${str__input}"`
    if [[ ${asterisk_isFound} == true ]]; then  #match found
        str_len=${#str__input}  #get length

        str_wo_asterisk_len=$((ret_len - 1))    #get length of stirng without asterisk

        ret=${str__input:0:str_wo_asterisk_len} #get return string without asterisk
    else
        ret=${str__input}   #set return string to input string
    fi

    #Output
    echo "${ret}"
}

function process_str_basedOn_numOf_results__func() {
    #Input args
    local str_autocompleted__input=${1}
    local str_bck__input=${2}
    local autocomplete_numOfMatches__input=${3}

    #Define variables
    local ret=${DOCKER__EMPTYSTRING}
    local asterisk_isFound=false

    #Check the number of matches
    if [[ ${autocomplete_numOfMatches__input} -eq ${DOCKER__NUMOFMATCH_1} ]]; then  #autocomplete only found 1 match
        ret=${str_autocompleted__input}
    else    #autocomplete found multiple matches
        #Check if asterisk is present in 'str__input'
        asterisk_isFound=`checkForMatch_keyWord_within_string__func "${DOCKER__ASTERISK}" "${str_bck__input}"`
        if [[ ${asterisk_isFound} == true ]]; then  #asterisk was found
            ret=${str_bck__input}
        else    #no asterisk found
            ret=${str_autocompleted__input}
        fi
    fi

    #Remove any double slashes
    ret=`echo ${ret} | sed "s/${SED__SLASH}${SED__SLASH}${SED__ASTERISK}/${SED__SLASH}/g"`

    #Output
    echo "${ret}"
}

function load_dirlist_into_array__func() {
    #Input args
    local containerID__input=${1}
    local fpath__input=${2}
    local backupIsEnabled=${3}

    #Split directory from file/folder
    local dir=`get_dirname_from_specified_path__func "${fpath__input}"`
    local keyWord=`get_basename_from_specified_path__func "${fpath__input}"`

    #Define local variables
    local cachedInputArr_string=${DOCKER__EMPTYSTRING}
    local cachedInputArr_raw_string=${DOCKER__EMPTYSTRING}

    #These are global variables
    cachedInput_Arr=()
    cachedInput_ArrLen=0
    cachedInput_ArrIndex=0
    cachedInput_ArrIndex_max=0

    #Check if 'dir' is an Empty String
    if [[ -z ${dir} ]]; then
        dir=${DOCKER__SLASH}
    fi

    #Get directory content
    #Explanation: 
    #   The order in which the switches (A,C,x) are applied MATTERS!!!
    #   1: List all in 1 column
    #   a: List hidden files/folders as well
    #   A: List all entries including those starting with a dot '.', except for '.' and '..' (implied)
    #   --group-directories-first: show directories first
    #   head -${listView_numOfRows_input}": show a specified number of rows
    #   tr -d $'\r': (IMPORTANT) trim all carriage returns which is caused by executing 'docker exec -t <containerID> /bin/bash -c'
    #REMARK: For more info see: ls manual
    if [[ -z ${keyWord} ]]; then
        if [[ -z ${containerID__input} ]]; then
            cachedInputArr_raw_string=`ls -1aA ${dir}`
        else
            cachedInputArr_raw_string=`${docker__exec_cmd} "ls -1aA ${dir}" | tr -d $'\r'`
        fi
    else
        if [[ -z ${containerID__input} ]]; then
            cachedInputArr_raw_string=`ls -1aA ${dir} | grep "^${keyWord}"`
        else
            cachedInputArr_raw_string=`${docker__exec_cmd} "ls -1aA ${dir} | grep "^${keyWord}"" | tr -d $'\r'`
        fi
    fi

    #Get only UNIQUE values
    cachedInputArr_string=`echo ${cachedInputArr_raw_string} | tr ' ' '\n' | awk '!a[$0]++'`

    #Convert string to array
    cachedInput_Arr=(`echo ${cachedInputArr_string}`)

    #Update array-length
    cachedInput__ArrLen=${#cachedInput_Arr[@]}

    #Index starts with 0, therefore deduct array-length by 1
    cachedInput_ArrIndex_max=$((cachedInput_ArrLen-1))

    #Update current array-index
    cachedInput_ArrIndex=${cachedInput_ArrIndex_max}

    #Check if file exist, then:
    #1. remove backup file 'tmp_fPath__input'
    #2. backup file 'output_fPath__input'
    #3. remove file 'output_fPath__input'
    #4. write array contents to file 'output_fPath__input'
    if [[ -f ${output_fPath__input} ]]; then
        if [[ ${backupIsEnabled} == true ]]; then
            #step 1:
            if [[ -f ${tmp_fPath__input} ]]; then
                rm ${tmp_fPath__input}
            fi

            #step 2:
            cp ${output_fPath__input} ${tmp_fPath__input}
        fi

        #step 3:
        rm ${output_fPath__input}
    fi

    ##step 4:
    if [[ ${cachedInput__ArrLen} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
        printf "%s\n" "${cachedInput_Arr[@]}" > ${output_fPath__input}

    else
        touch ${output_fPath__input}
    fi
}



#---SUBROUTINES
dirlist__environmental_variables__sub() {
    bin_bash_dir=/bin/bash

	# docker__current_dir=`pwd`
	docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})	#/repo/LTPP3_ROOTFS/development_tools
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

dirlist__load_source_files__sub() {
    source ${docker__global_functions_fpath}
}

dirlist__initial_file_cleanup__sub() {
    if [[ -f ${output_fPath__input} ]]; then
        rm ${output_fPath__input}
    fi
    if [[ -f ${tmp_fPath__input} ]]; then
        rm ${tmp_fPath__input}
    fi
}

dirlist__initialize_variables__sub() {
    docker__exec_cmd="docker exec -t ${containerID__input} ${bin_bash_dir} -c"
    docker__containerid_state=false
}

dirlist__preCheck_if_containerID_isRunning__sub() {
    #Define constants
    local ERRMSG_CONTAINERID_IS_NOT_FOUND="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: ${DOCKER__FG_BRIGHTPRUPLE}Container-ID${DOCKER__NOCOLOR} '${containerID__input}' is NOT Found"
    local ERRMSG_CONTAINERID_IS_EXITED="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: ${DOCKER__FG_BRIGHTPRUPLE}Container-ID${DOCKER__NOCOLOR} '${containerID__input}' is Exited"

    #Check if 'containerID__input' (if provided) is running
    if [[ ${containerID__input} != ${DOCKER__EMPTYSTRING} ]]; then
        docker__containerid_state=`check_containerID_state__func "${containerID__input}"`
        if [[ ${docker__containerid_state} == ${DOCKER__STATE_NOTFOUND} ]]; then
            show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_CONTAINERID_IS_NOT_FOUND}" "${DOCKER__NUMOFLINES_1}"

            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            exit
        elif [[ ${docker__containerid_state} == ${DOCKER__STATE_EXITED} ]]; then
            show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_CONTAINERID_IS_EXITED}" "${DOCKER__NUMOFLINES_1}"

            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            exit
        fi
    fi
}

dirlist__readInput_w_autocomplete__sub() {
    #Disable EXPANSION
    #Remark:
    #   This allows variables to contains special characters like asterisk '*' which can be matched via 'grep'.
    set -f

    #Input args
    local containerID__input=${1}
    local readMsg__input=${2}
    local readMsgRemarks__input=${3}

    #Remove file
    if [[ -f ${dirlist__readInput_w_autocomplete_out__fpath} ]]; then
        rm ${dirlist__readInput_w_autocomplete_out__fpath}
    fi

    #Calculate number of lines to be cleaned
    local readMsg_numOfLines=0
    if [[ ! -z ${readMsg__input} ]]; then    #this condition is important
        readMsg_numOfLines=`echo -e ${readMsg__input} | wc -l`      
    fi
    local remarks_numOfLines=0
    if [[ ! -z ${readMsgRemarks__input} ]]; then    #this condition is important
        remarks_numOfLines=`echo -e ${readMsgRemarks__input} | wc -l`      
    fi
    local numOfLines_noError_tot=$((readMsg_numOfLines + remarks_numOfLines))

    #Initialization
    local autocomplete_output=${DOCKER__EMPTYSTRING}
    local keyInput=${DOCKER__EMPTYSTRING}
    local keyInput_add=${DOCKER__EMPTYSTRING}
    local phase=${DOCKER__EMPTYSTRING}
    local str=${DOCKER__EMPTYSTRING}
    local str_autocompleted=${DOCKER__EMPTYSTRING}
    local str_prev=${DOCKER__EMPTYSTRING}
    local str_shown=${DOCKER__EMPTYSTRING}
    local str_wo_asterisk=${DOCKER__EMPTYSTRING}
    local ret=${DOCKER__EMPTYSTRING}
    local ret_tmp=${DOCKER__EMPTYSTRING}

    local autocomplete_numOfMatches=0
    local autocomplete_numOfMatches_init=0

    local files_areDifferent=false
    local fpaths_areSame=false
    local onEnterPressed=false
    local onExit_moveDown_isEnabled=false



    #Start phase
    keyInput=${DOCKER__TAB}
    phase=${PHASE_SHOW_KEYINPUT_HANDLER}
    str=${DOCKER__SLASH}

    while true
    do
        case "${phase}" in
            ${PHASE_SHOW_REMARKS})
                #Show remarks if 'readMsgRemarks__input' is NOT an Empty String
                if [[ ! -z ${readMsgRemarks__input} ]]; then
                    echo -e "${readMsgRemarks__input}"
                fi

                phase=${PHASE_SHOW_READINPUT}
            ;;
            ${PHASE_SHOW_READINPUT})
                #Show read-input message
                echo -e "${readMsg__input}${str}"

                #Move cursor up
                moveUp_oneLine_then_moveRight__func "${readMsg__input}" "${str}"

                #Read-input
                read -N1 -rs -p "" keyInput

                phase=${PHASE_SHOW_KEYINPUT_HANDLER}
            ;;
            ${PHASE_SHOW_KEYINPUT_HANDLER})
                #Select case based on 'keyInput'
                case "${keyInput}" in
                    ${DOCKER__ENTER})
                        #Check if there were any ';b', ';c', ';h' issued.
                        #In other words, whether 'str' contains any of the above semi-colon chars.
                        #If that's the case then function 'get_endResult_ofString_with_semiColonChar__func'
                        #   will handle and return the result 'ret'.
                        ret_tmp=`get_endResult_ofString_with_semiColonChar__func ${str}`

                        case "${ret_tmp}" in
                            ${DOCKER__SEMICOLON_BACK})
                                ret=${ret_tmp}

                                break
                                ;;
                            ${DOCKER__SEMICOLON_HOME})
                                ret=${ret_tmp}

                                break
                                ;;
                            ${DOCKER__EMPTYSTRING})
                                #Reset variable
                                str=${DOCKER__SLASH}

                                #Goto next-phase
                                phase=${PHASE_SHOW_READINPUT}
                                
                                #First Move-down, then Move-up, after that clean line
                                moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"
                                ;;
                            *)
                                #Set flag to 'true'
                                onEnterPressed=true

                                #Goto next-phase
                                phase=${PHASE_SHOW_KEYINPUT_HANDLER}

                                #Check if new read-input value 'str' is different from the previous value 'str_prev'. 
                                #Remark:
                                #   If true, then it means that 'str' has not been processed yet right before ENTER was pressed.
                                #   Therefore 'str' has to be processed by: 
                                #   1. goto 'DOCKER__TAB' and process 'str'.
                                #   2. after that, exit the loop
                                #   3. output 'ret'
                                if [[ ${str} != ${str_prev} ]]; then
                                    #Goto 'keyInput = DOCKER__TAB'.
                                    #Remark:
                                    #   skip read-input dialog.
                                    keyInput=${DOCKER__TAB}
                                else    #the new read-input value 'str' is the same as the previous value 'str_prev'.
                                    ret=${ret_tmp}

                                    #This flag is required for corrective move-down cursor 
                                    onExit_moveDown_isEnabled=true

                                    #Goto 'keyInput = DOCKER__EXIT'.
                                    #Remark:
                                    #   skip read-input dialog.
                                    keyInput=${DOCKER__EXIT}
                                fi
                                ;;
                        esac
                        ;;
                    ${DOCKER__BACKSPACE})
                        #Update variable
                        str=`backspace_handler__func "${str}"`

                        #Goto next-phase
                        phase=${PHASE_SHOW_READINPUT}

                        #First Move-down, then Move-up, after that clean line
                        moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"
                        ;;
                    ${DOCKER__ESCAPEKEY})
                        #Handle Arrowkey-press
                        arrowKeys_upDown_handler__func

                        #Goto next-phase
                        phase=${PHASE_SHOW_READINPUT}

                        #First Move-down, then Move-up, after that clean line
                        moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"
                        ;;
                    ${DOCKER__TAB})
                        #Check if 'str' and 'str_prev' are the same
                        #Remark:
                        #   This means that TAB was pressed without inputting any character
                        if [[ "${str}" != "${str_prev}" ]]; then  
                            #Remove 'asterisk' from 'str' (if any)
                            str_wo_asterisk=`remove_asterisk_from_string "${str}"`

#---------------------------Load directory content into array
                            #This function directly outputs the following files:
                            #1. output_fPath__input
                            #2. tmp_fPath__input
                            #Remark:
                            #   Make sure to set 'backupIsEnabled' to 'true'
                            load_dirlist_into_array__func "${containerID__input}" \
                                    "${str_wo_asterisk}" \
                                    "true"

#---------------------------AUTOCOMPLETE: Find the closest match
                            #Output contains the following values delimited by a comma:
                            #   col1: str_autocompleted
                            #   col2: autocomplete_numOfMatches_init
                            #   col3: autocomplete_numOfMatches
                            autocomplete_output=`autocomplete__func "${str_wo_asterisk}" "${cachedInput_Arr[@]}"`

                            #Separate each output element:
                            str_autocompleted=`echo "${autocomplete_output}" | cut -d"," -f1`
                            autocomplete_numOfMatches_init=`echo "${autocomplete_output}" | cut -d"," -f2`
                            autocomplete_numOfMatches=`echo "${autocomplete_output}" | cut -d"," -f3`

#---------------------------Reload directory content into array if necessary
                            #This function indirectly outputs the following file ONLY:
                            #   output_fPath__input
                            #Remark:
                            #   Make sure to set 'backupIsEnabled' to 'false'
                            dirlist__reload_dirlist_into_array__sub "${str_autocompleted}" \
                                    "${str}" \
                                    "${autocomplete_numOfMatches_init}" \
                                    "${autocomplete_numOfMatches}" \
                                    "false"

#---------------------------Show directory content based on the specified 'containerID__input, str_autocompleted, output_fPath__input'
                            #Only handle this condition if 'autocomplete_numOfMatches > 0'
                            if [[ ${autocomplete_numOfMatches} -ne ${DOCKER__NUMOFMATCH_0} ]]; then
                                #Check if the file contents are different
                                files_areDifferent=`checkIf_files_are_different__func ${output_fPath__input} ${tmp_fPath__input}`
                                if [[ ${files_areDifferent} == true ]]; then   #file contents are different
                                    dirlist__show_dirContent_handler__sub "${containerID__input}" \
                                            "${str_autocompleted}" \
                                            "${output_fPath__input}"

                                    #Update 'str_shown'
                                    str_shown=${str_autocompleted}

                                    #Goto next-phase
                                    phase=${PHASE_SHOW_REMARKS}
                                else    #file contents are the same
                                    #Check whether 'str_autocompleted != str_shown'
                                    fpaths_areSame=`checkIf_fpaths_are_the_same__func "${str_autocompleted}" "${str_shown}"`
                                    if [[ ${fpaths_areSame} == false ]]; then #fullpaths are not the same
                                        dirlist__show_dirContent_handler__sub "${containerID__input}" \
                                                "${str_autocompleted}" \
                                                "${output_fPath__input}"

                                        #Update 'str_shown'
                                        str_shown=${str_autocompleted}
                                        
                                        #Goto next-phase
                                        phase=${PHASE_SHOW_REMARKS}
                                    else
                                        #Goto next-phase
                                        phase=${PHASE_SHOW_READINPUT}

                                        #First Move-down, then Move-up, after that clean line
                                        moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"
                                    fi
                                fi
                            fi

#---------------------------If 'asterisk_isFound = true' then restore 'str'
                            str=`process_str_basedOn_numOf_results__func "${str_autocompleted}" \
                                    "${str}" \
                                    "${autocomplete_numOfMatches}"`

#---------------------------Backup 'str'
                            str_prev=${str}

#---------------------------Check if 'onEnterPressed = true'
                            if [[ ${onEnterPressed} == true ]]; then
                                #Update 'ret'
                                ret=${str}

                                #Goto next-phase
                                phase=${PHASE_SHOW_KEYINPUT_HANDLER}
                            
                                #Goto 'keyInput = DOCKER__EXIT'
                                keyInput=${DOCKER__EXIT}
                            fi
                        else    #str = str_prev (enter was pressed without key-input)
                            #Goto next-phase
                            phase=${PHASE_SHOW_READINPUT}
                            
                            #First Move-down, then Move-up, after that clean line
                            moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"                
                        fi
                        ;;
                    ${DOCKER__EXIT})
                        #Check if at least one match is found
                        if [[ ${autocomplete_numOfMatches} -ne ${DOCKER__NUMOFMATCH_0} ]]; then #at least one match is found
                            if [[ ${autocomplete_numOfMatches} -gt ${DOCKER__NUMOFMATCH_1} ]]; then #at least one match is found
                                #Check if an asterisk is already present
                                asterisk_isFound=`checkForMatch_keyWord_within_string__func "${DOCKER__ASTERISK}" "${ret}"`
                                if [[ ${asterisk_isFound} == false ]]; then  #asterisk was NOT found
                                    ret=${ret}${DOCKER__ASTERISK} #append asterisk
                                fi
                            fi

                            if [[ ${onExit_moveDown_isEnabled} == true ]]; then
                                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                            fi

                            break
                        else    #no match was found
                            #Set flags to 'false'
                            onEnterPressed=false

                            #Goto next-phase
                            phase=${PHASE_SHOW_READINPUT}

                            #First Move-down, then Move-up, after that clean line
                            moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"   
                        fi
                        ;;
                    *)
                        #wait for another 0.5 seconds to capture additional characters.
                        #Remark:
                        #   This part has been implemented just in case long text has been copied/pasted.
                        read -rs -t0.01 keyInput_add

                        #Append 'keyInput_add' to 'keyInput'
                        keyInput="${keyInput}${keyInput_add}"
                        
                        #Append 'keyInput' to 'str'
                        if [[ ! -z ${keyInput} ]]; then
                            str="${str}${keyInput}"
                        fi

                        #Goto next-phase
                        phase=${PHASE_SHOW_READINPUT}

                        #First Move-down, then Move-up, after that clean line
                        moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"
                        ;;
                esac
                ;;
        esac
    done

    #Write chosen path to file (line 0)
    echo ${ret} > ${dirlist__readInput_w_autocomplete_out__fpath}

    #Write number of matches to file (line 1)
    echo ${cachedInput__ArrLen} >> ${dirlist__readInput_w_autocomplete_out__fpath}

    #Enable EXPANSION
    set +f
}

dirlist__reload_dirlist_into_array__sub() {
    #Input args
    local fpath_new__input=${1}
    local fpath_bck__input=${2}
    local numOfMatches_init__input=${3}
    local numOfMatches_new__input=${4}
    local backupIsEnabled=${5}

    #Determine if it is required to run 'load_dirlist_into_array__func'.
    if [[ "${numOfMatches_new__input}" -ne "${numOfMatches_init__input}" ]]; then #fullpaths are not the same
        #RELoad directory content into array
        load_dirlist_into_array__func "${containerID__input}" "${fpath_new__input}" "${backupIsEnabled}"

        #Exit subroutine
        return
    fi

    #In case 'numOfMatches_init__input = numOfMatches_new__input'...
    #...check whether 'fpath_new__input != fpath_bck__input'
    if [[ "${fpath_new__input}" != "${fpath_bck__input}" ]]; then #fullpaths are not the same
        #RELoad directory content into array
        load_dirlist_into_array__func "${containerID__input}" "${fpath_new__input}" "${backupIsEnabled}"
    fi
}

dirlist__readInput_handler__sub() {
    #Get read-input value
    dirlist__readInput_w_autocomplete__sub "${containerID__input}" "${readMsg__input}" "${readMsgRemarks__input}"

    #Print empty lines
    # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
}

dirlist__show_dirContent_handler__sub() {
	#Input args
	local containerID__input=${1}
	local fpath__input=${2}
    local dirlist_content_fpath=${3}

    #Split directory from file/folder
    local dir=`get_dirname_from_specified_path__func "${fpath__input}"`
    local keyWord=`get_basename_from_specified_path__func "${fpath__input}"`

    #Move down one line
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    #Show directory content
	if [[ -z ${containerID__input} ]]; then	#LOCAL machine (aka HOST)
		${dclcau_lh_ls__fpath} "${dir}" "${DOCKER__LISTVIEW_NUMOFROWS}" "${DOCKER__LISTVIEW_NUMOFCOLS}" "${keyWord}" "${dirlist_content_fpath}"
	else	#REMOTE machine (aka Container)
		${dclcau_dc_ls__fpath} "${containerID__input}" "${dir}" "${DOCKER__LISTVIEW_NUMOFROWS}" "${DOCKER__LISTVIEW_NUMOFCOLS}" "${keyWord}" "${dirlist_content_fpath}"
	fi
}



#---MAIN SUBROUTINE
main__sub() {
    dirlist__environmental_variables__sub

    dirlist__load_source_files__sub

    dirlist__initial_file_cleanup__sub

    dirlist__initialize_variables__sub

    dirlist__preCheck_if_containerID_isRunning__sub

    dirlist__readInput_handler__sub
}



#---EXECUTE
main__sub
