#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---INPUT ARGS
containerID__input=${1}
readMsg__input=${2}
readMsgRemarks__input=${3}



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

    #Check if 'fpath__input' is an Empty String
    if [[ -z ${fpath__input} ]]; then
        echo ${DOCKER__SLASH}

        return
    fi

    #Split directory from file/folder
    local dir=`get_dirname_from_specified_path__func "${fpath__input}"`
    local keyWord=`get_basename_from_specified_path__func "${fpath__input}"`
    
    #Check if 'keyWord' is an Empty String
    if [[ -z ${keyWord} ]]; then
        echo ${fpath__input}

        return
    fi

    #Define and update keyWord
    local keyword_output=${DOCKER__EMPTYSTRING}
    local dataArr_1stItem_len=0
    local keyWord_bck=${DOCKER__EMPTYSTRING}
    local keyWord_len=0
    local numOfMatch=0
    local numOfMatch_init=0
    local ret=${DOCKER__EMPTYSTRING}

    local dir_exists=false

    #initialization
    dataArr_1stItem_len=${#dataArr__input[0]}
    numOfMatch_init=`printf '%s\n' "${dataArr__input[@]}" | grep "^${keyWord}" | wc -l` #the initial number of matches for a specified 'keyWord'
    numOfMatch=${numOfMatch_init}   #the number of matches that is being recalculated each time theh 'keyWord' changes

    #Find the closest match
    while true
    do
        if [[ ${numOfMatch_init} -eq 0 ]]; then  #no match
            #Exit loop
            break
        elif [[ ${numOfMatch_init} -eq 1 ]]; then  #only 1 match
            #Update variable
            keyword_output=`printf '%s\n' "${dataArr__input[@]}" | grep "^${keyWord}"`

            #Check if direcotry
            ret=${dir}${keyword_output}
            dir_exists=`checkIf_dir_exists__func "${containerID__input}" "${ret}"`
            if [[ ${dir_exists} == true ]]; then
                ret=${ret}${DOCKER__SLASH}
            fi

            #Output
            echo ${ret}

            #Exit loop
            return;
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
            if [[ ${keyWord_bck_len} -eq ${dataArr_1stItem_len} ]]; then
                keyword_output=${keyWord_bck}

                break
            fi

            #Get the new number of matches
            numOfMatch=`printf '%s\n' "${dataArr__input[@]}" | grep "^${keyWord}" | wc -l`

            #Compare the new 'numOfMatch' with the initial 'numOfMatch_init'
            #Remark:
            #   The idea is that the newly calculated 'numOfMatch' should be the
            if [[ ${numOfMatch} -ne ${numOfMatch_init} ]]; then
                keyword_output=${keyWord_bck}

                break
            fi
        fi
    done

    #Compoase full-path
    ret=${dir}${keyword_output}

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

function load_dirlist_into_array__func() {
    #Input args
    local containerID__input=${1}
    local fpath__input=${2}

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
    #1. remove backup file 'dirlist_ls_raw_bck_tmp_fpath'
    #2. backup file 'dirlist_ls_raw_tmp_fpath'
    #3. remove file 'dirlist_ls_raw_tmp_fpath'
    #4. write array contents to file 'dirlist_ls_raw_tmp_fpath'
    if [[ -f ${dirlist_ls_raw_tmp_fpath} ]]; then
        #step 1:
        if [[ -f ${dirlist_ls_raw_bck_tmp_fpath} ]]; then
            rm ${dirlist_ls_raw_bck_tmp_fpath}
        fi

        #step 2:
        cp ${dirlist_ls_raw_tmp_fpath} ${dirlist_ls_raw_bck_tmp_fpath}

        #step 3:
        rm ${dirlist_ls_raw_tmp_fpath}
    fi

    ##step 4:
    if [[ ${cachedInput__ArrLen} -gt 0 ]]; then
        printf "%s\n" "${cachedInput_Arr[@]}" > ${dirlist_ls_raw_tmp_fpath}
    else
        touch ${dirlist_ls_raw_tmp_fpath}
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
    if [[ -f ${dirlist_ls_raw_tmp_fpath} ]]; then
        rm ${dirlist_ls_raw_tmp_fpath}
    fi
    if [[ -f ${dirlist_ls_raw_bck_tmp_fpath} ]]; then
        rm ${dirlist_ls_raw_bck_tmp_fpath}
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
            show_errMsg_without_menuTitle__func "${ERRMSG_CONTAINERID_IS_NOT_FOUND}" "${DOCKER__NUMOFLINES_1}"

            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            exit
        elif [[ ${docker__containerid_state} == ${DOCKER__STATE_EXITED} ]]; then
            show_errMsg_without_menuTitle__func "${ERRMSG_CONTAINERID_IS_EXITED}" "${DOCKER__NUMOFLINES_1}"

            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            exit
        fi
    fi
}

dirlist__readInput_w_autocomplete__sub() {
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
    local keyInput=${DOCKER__EMPTYSTRING}
    local keyInput_addit=${DOCKER__EMPTYSTRING}
    local ret=${DOCKER__SLASH}
    local ret_bck=${ret}

    local remarks_are_shown=true
    local files_are_different=false

    #Show directory content
    dirlist__show_dirContent_handler__sub "${containerID__input}" "${DOCKER__SLASH}" "${DOCKER__EMPTYSTRING}"

    while true
    do
        if [[ ${remarks_are_shown} == true ]]; then
            if [[ ! -z ${readMsgRemarks__input} ]]; then
                echo -e "${readMsgRemarks__input}"
            fi
        fi
        echo -e "${readMsg__input}${ret}"

        #Move cursor up
        moveUp_oneLine_then_moveRight__func "${readMsg__input}" "${ret}"

        #Read-input
        read -N1 -rs -p "" keyInput

        #Select case based on 'keyInput'
        case "${keyInput}" in
            ${DOCKER__ENTER})
                #Check if there were any ';b', ';c', ';h' issued.
                #In other words, whether 'ret' contains any of the above semi-colon chars.
                #If that's the case then function 'get_endResult_ofString_with_semiColonChar__func'
                #   will handle and return a modified 'ret'.
                ret_bck=${ret}  #set value
                ret=`get_endResult_ofString_with_semiColonChar__func ${ret_bck}`

                if [[ ! -z ${ret} ]]; then    #'ret' contains data
                    break
                else    #'ret' is an Empty String
                    #Reset variable
                    ret=${DOCKER__SLASH}

                    #Set flag to 'false'
                    remarks_are_shown=false
                    
                    #First Move-down, then Move-up, after that clean line
                    moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"
                fi
                ;;
            ${DOCKER__BACKSPACE})
                #Update variable
                ret=`backspace_handler__func "${ret}"`

                #Set flag to 'false'
                remarks_are_shown=false

                #First Move-down, then Move-up, after that clean line
                moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"
                ;;
            ${DOCKER__ESCAPEKEY})
                #Handle Arrowkey-press
                arrowKeys_upDown_handler__func

                #Set flag to 'false'
                remarks_are_shown=false

                #First Move-down, then Move-up, after that clean line
                moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"
                ;;
            ${DOCKER__TAB})
                #Check if 'ret' and 'ret_bck' are the same
                #Remark:
                #   This means that TAB was pressed without inputting any character
                if [[ ${ret} != ${ret_bck} ]]; then
                    #Backup 'ret'
                    ret_bck=${ret}

                    #Load directory content into array
                    load_dirlist_into_array__func "${containerID__input}" "${ret}"

                    #This subroutine will also update 'ret'
                    ret=`autocomplete__func "${ret}" "${cachedInput_Arr[@]}"`

                    #Reload directory content into array if necessary
                    dirlist__reload_dirlist_into_array__sub "${ret}" "${ret_bck}"

                    if [[ ! -f ${dirlist_ls_raw_tmp_fpath} ]] || [[ ! -f ${dirlist_ls_raw_bck_tmp_fpath} ]]; then   #at least one of the files do NOT exist
                        dirlist__show_dirContent_handler__sub "${containerID__input}" "${ret}" "${dirlist_ls_raw_tmp_fpath}"

                            #Set flag to 'true'
                        remarks_are_shown=true
                    else    #both files exists
                        files_are_different=`checkIf_files_are_different__func ${dirlist_ls_raw_tmp_fpath} ${dirlist_ls_raw_bck_tmp_fpath}`
                        if [[ ${files_are_different} == true ]]; then
                            dirlist__show_dirContent_handler__sub "${containerID__input}" "${ret}" "${dirlist_ls_raw_tmp_fpath}"

                            #Set flag to 'true'
                            remarks_are_shown=true
                        else
                            #Set flag to 'false'
                            remarks_are_shown=false

                            #First Move-down, then Move-up, after that clean line
                            moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"
                        fi
                    fi
                else
                    #Set flag to 'false'
                    remarks_are_shown=false
                    
                    #First Move-down, then Move-up, after that clean line
                    moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"                
                fi
                ;;
            *)
                #wait for another 0.5 seconds to capture additional characters.
                #Remark:
                #   This part has been implemented just in case long text has been copied/pasted.
                read -rs -t0.01 keyInput_addit

                #Append 'keyInput_addit' to 'keyInput'
                keyInput="${keyInput}${keyInput_addit}"
                
                #Append 'keyInput' to 'ret'
                if [[ ! -z ${keyInput} ]]; then
                    ret="${ret}${keyInput}"
                fi

                #Set flag to 'false'
                remarks_are_shown=false

                #First Move-down, then Move-up, after that clean line
                moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"
                ;;
        esac
    done

    #Write to file
    echo ${ret} > ${dirlist__readInput_w_autocomplete_out__fpath}
}

dirlist__reload_dirlist_into_array__sub() {
    #Input args
    local fpath_new__input=${1}
    local fpath_bck__input=${2}

    #Check if both paths are the same
    local dirs_are_same=`checkIf__dirname_of_two_paths_are_the_same__func "${fpath_new__input}" "${fpath_bck__input}"`
    if [[ ${dirs_are_same} == false ]]; then
        #RELoad directory content into array
        load_dirlist_into_array__func "${containerID__input}" "${fpath_new__input}"
    fi
}

dirlist__readInput_handler__sub() {
    #Get read-input value
    dirlist__readInput_w_autocomplete__sub "${containerID__input}" "${readMsg__input}" "${readMsgRemarks__input}"

    #Print empty lines
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
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
		${dclcau_lh_ls_fpath} "${dir}" "${DOCKER__LISTVIEW_NUMOFROWS}" "${DOCKER__LISTVIEW_NUMOFCOLS}" "${keyWord}" "${dirlist_content_fpath}"
	else	#REMOTE machine (aka Container)
		${dclcau_dc_ls_fpath} "${containerID__input}" "${dir}" "${DOCKER__LISTVIEW_NUMOFROWS}" "${DOCKER__LISTVIEW_NUMOFCOLS}" "${keyWord}" "${dirlist_content_fpath}"
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
