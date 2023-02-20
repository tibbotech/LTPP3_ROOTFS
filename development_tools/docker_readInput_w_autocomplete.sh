#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---INPUT ARGS
menuTitle__input=${1}
readMsg__input=${2}
readMsgUpdate__input=${3}
readMsgRemarks__input=${4}
errorMsg__input=${5}
errorMsg2__input=${6}
dockerCmd__input=${7}
colNo__input=${8}
pattern__input=${9}
showTable__input=${10}
onEnter_breakLoop__input=${11}
tibboHeader_prepend_numOfLines__input=${12}



#---FUNCTIONS
function arrowKeys_upDown_handler__func() {
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
            *)
                arrow_direction=${DOCKER__EMPTYSTRING}
                ;;
        esac
    fi

    #Flush "stdin" with 0.1  sec timeout.
    read -rsn5 -t 0.1

    #Check if 'cachedInput_ArrLen > 0'
    #Remark:
    #   If false, then exit this function right away.
    if [[ ${cachedInput_ArrLen} -eq 0 ]]; then
        return
    fi

    #*********************************************************
    #This part MUST be executed after the 'Arrow-key handling'
    #*********************************************************
    if [[ ${arrow_direction} == ${DOCKER__ARROWUP} ]]; then
        if [[ ${docker__1stTimeUse} == true ]]; then
            cachedInput_ArrIndex=0

            docker__1stTimeUse=false
        else
            if [[ ${cachedInput_ArrIndex} -eq 0 ]]; then    #index is already leveled to 0
                cachedInput_ArrIndex=${cachedInput_ArrIndex_max}    #set index to the max. value
            else    #for all other indexes
                cachedInput_ArrIndex=$((cachedInput_ArrIndex-1))
            fi
        fi
    elif [[ ${arrow_direction} == ${DOCKER__ARROWDOWN} ]]; then
        if [[ ${docker__1stTimeUse} == true ]]; then
            cachedInput_ArrIndex=0

            docker__1stTimeUse=false
        else
            if [[ ${cachedInput_ArrIndex} -eq ${cachedInput_ArrIndex_max} ]]; then  #index is already maxed out
                cachedInput_ArrIndex=0
            else    #for all other indexes
                cachedInput_ArrIndex=$((cachedInput_ArrIndex+1))
            fi
        fi
    fi
}

function autocomplete__func() {
    #Disable expansion
    disable_expansion__func

    #Input args
    #Remark:
    #1. non-array parameter(s) precede(s) array-parameter
    #2. For each non-array parameter, the 'shift' operator has to be added an array-parameter
    local keyWord=${1}
    shift
    local dataArr=("$@")


    #Define and update keyWord
    local dataArr_filtered_1stElement_len=0
    local keyWord_bck=${DOCKER__EMPTYSTRING}
    local keyWord_len=0
    local numOfMatch=0
    local numOfMatch_init=0
    local ret=${DOCKER__EMPTYSTRING}

    #Get only array-elements containing 'keyWord__input'
    #Explanation:
    #   printf '%s\n' "${dataArr[@]}": print each array-element separated by a (\n)
    #   grep "^${keyWord__input}": get only array-elements matching 'keyWord__input'
    #   sed 's/\n/ /g': substitute (\n) with space ( )
    local dataArr_filtered_string=`printf '%s\n' "${dataArr[@]}" | grep "^${keyWord__input}" | sed 's/\n/ /g'`
    local dataArr_filtered=(`echo "${dataArr_filtered_string}"`)

    #initialization
    dataArr_filtered_1stElement_len=${#dataArr_filtered[0]}
    numOfMatch_init=`printf '%s\n' "${dataArr_filtered[@]}" | grep "^${keyWord}" | wc -l`
    numOfMatch=${numOfMatch_init}

    #Find the closest match
    while true
    do
        if [[ ${numOfMatch_init} -eq 0 ]]; then  #no match
            #Exit loop
            break
        elif [[ ${numOfMatch_init} -eq 1 ]]; then  #only 1 match
            #Update variable
            ret=`printf '%s\n' "${dataArr_filtered[@]}" | grep "^${keyWord}"`

            #Exit loop
            break
        else    #multiple matches
            #Backup keyWord
            keyWord_bck=${keyWord}

            #Get keyWord length
            keyWord_bck_len=${#keyWord_bck}

            #Increment keyWord length by 1
            keyWord_len=$((keyWord_bck_len + 1))

            #Get the next keyWord (by using the 1st array-element as base)
            keyWord=${dataArr_filtered[0]:0:keyWord_len}

            #Check if the total length of the 1st array-element has been reached
            if [[ ${keyWord_bck_len} -eq ${dataArr_filtered_1stElement_len} ]]; then
                ret=${keyWord_bck}

                break
            fi

            #Get the new number of matches
            numOfMatch=`printf '%s\n' "${dataArr_filtered[@]}" | grep "^${keyWord}" | wc -l`

            #Compare the new 'numOfMatch' with the initial 'numOfMatch_init'
            #If there is a difference, then set 'ret = keyWord_bck' and exit the loop.
            if [[ ${numOfMatch} -ne ${numOfMatch_init} ]]; then
                ret=${keyWord_bck}

                break
            fi
        fi
    done

    #Output
    echo ${ret}

    #Enable expansion
    enable_expansion__func
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

function run_cmd_and_read_output_into_array__func() {
    #Input args
    local dockerCmd__input=${1}
    local colNo__input=${2}
    local pattern__input=${3}

    #Define local variables
    local cachedInputArr_string=${DOCKER__EMPTYSTRING}
    local cachedInputArr_raw_string=${DOCKER__EMPTYSTRING}

    #These are global variables
    cachedInput_Arr=()
    cachedInput_ArrLen=0
    cachedInput_ArrIndex=0
    cachedInput_ArrIndex_max=0

    #Get all values stored under the specified column 'colNo__input' (excluding header)
    if [[ -z ${pattern__input} ]]; then
        cachedInputArr_raw_string=`${dockerCmd__input} | awk -vcolNo=${colNo__input} '{print $colNo}' | tail -n+2`
    else
        cachedInputArr_raw_string=`${dockerCmd__input} | grep "${pattern__input}" | awk -vcolNo=${colNo__input} '{print $colNo}'`
    fi

    #Get only UNIQUE values
    cachedInputArr_string=`echo ${cachedInputArr_raw_string} | tr ' ' '\n' | awk '!a[$0]++'`

    #Convert string to array
    cachedInput_Arr=(`echo ${cachedInputArr_string}`)

    #Update array-length
    cachedInput_ArrLen=${#cachedInput_Arr[@]}

    #Index starts with 0, therefore deduct array-length by 1
    cachedInput_ArrIndex_max=$((cachedInput_ArrLen-1))

    #Update current array-index
    cachedInput_ArrIndex=${cachedInput_ArrIndex_max}
}



#---SUBROUTINES
docker__get_source_fullpath__sub() {
    #Define constants
    local DOCKER__PHASE_CHECK_CACHE=1
    local DOCKER__PHASE_FIND_PATH=10
    local DOCKER__PHASE_EXIT=100

    #Define variables
    local docker__phase=""

    local docker__current_dir=
    local docker__tmp_dir=""

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
    docker__tmp_dir=/tmp
    docker__development_tools__foldername="development_tools"
    docker__global__filename="docker_global.sh"
    docker__LTPP3_ROOTFS__foldername="LTPP3_ROOTFS"

    docker__mainmenu_path_cache__filename="docker__mainmenu_path.cache"
    docker__mainmenu_path_cache__fpath="${docker__tmp_dir}/${docker__mainmenu_path_cache__filename}"

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
docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

docker__init_variables__sub() {
    docker__1stTimeUse=true
}

docker__readInput_handler__sub() {
    #Get read-input value
    docker__readInput_w_autocomplete__sub "${menuTitle__input}" \
                        "${readMsg__input}" \
                        "${readMsgUpdate__input}" \
                        "${readMsgRemarks__input}" \
                        "${errorMsg__input}" \
                        "${errorMsg2__input}" \
                        "${dockerCmd__input}" \
                        "${colNo__input}" \
                        "${pattern__input}" \
                        "${showTable__input}" \
                        "${onEnter_breakLoop__input}" \
                        "${tibboHeader_prepend_numOfLines__input}"

    #Print empty lines
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
}

docker__readInput_w_autocomplete__sub() {
    #Input args
    local menuTitle__input=${1}
    local readMsg__input=${2}
    local readMsgUpdate__input=${3}
    local readMsgRemarks__input=${4}
    local errorMsg__input=${5}
    local errorMsg2__input=${6}
    local dockerCmd__input=${7}
    local colNo__input=${8}
    local pattern__input=${9}
    local showTable__input=${10}
    local onEnter_breakLoop__input=${11}
    local tibboHeader_prepend_numOfLines__input=${12}

    #Define variables
    local keyInput=${DOCKER__EMPTYSTRING}
    local keyInput_addit=${DOCKER__EMPTYSTRING}
    local ret=${DOCKER__EMPTYSTRING}
    local ret_bck=${DOCKER__EMPTYSTRING}
    local stdOutput=${DOCKER__EMPTYSTRING}

    local onBackSpacePressed=false

    #Define messages
    local errMsg=${DOCKER__EMPTYSTRING}
 
    #Remove file
    if [[ -f ${docker__readInput_w_autocomplete_out__fpath} ]]; then
        rm ${docker__readInput_w_autocomplete_out__fpath}
    fi

#---Load ContainerIDs into Array 'cachedInput_Arr'
    run_cmd_and_read_output_into_array__func "${dockerCmd__input}" "${colNo__input}" "${pattern__input}"

#---Show Docker Container's List
    #Calculate number of lines to be cleaned
    local readMsg_numOfLines=0
    if [[ ! -z ${readMsg__input} ]]; then    #this condition is important
        readMsg_numOfLines=`echo -e ${readMsg__input} | wc -l`      
    fi
    local remarks_numOfLines=0
    if [[ ! -z ${readMsgRemarks__input} ]]; then    #this condition is important
        remarks_numOfLines=`echo -e ${readMsgRemarks__input} | wc -l`      
    fi
    local update_numOfLines=0
    if [[ ! -z ${readMsgUpdate__input} ]]; then    #this condition is important
        update_numOfLines=`echo -e ${readMsgUpdate__input} | wc -l`      
    fi

    local numOfLines_noError_tot=$((readMsg_numOfLines + update_numOfLines))
    local numOfLines_wError_tot=$((DOCKER__NUMOFLINES_5 +  update_numOfLines))

    #Only execute this condition if 'menuTitle__input' is not an Empty String
    #Remark:
    #   This way we can control whether to show the Image-list Table or not.
    if [[ ${showTable__input} == true ]]; then
        #Check if 'tibboHeader_prepend_numOfLines__input' is an Empty String
        if [[ -z ${tibboHeader_prepend_numOfLines__input} ]]; then
            tibboHeader_prepend_numOfLines__input=${DOCKER__NUMOFLINES_2}
        fi

        #Print Tibbo-title
        load_tibbo_title__func "${tibboHeader_prepend_numOfLines__input}"
        
        #Show command-output
        docker__show_infoTable__sub "${menuTitle__input}" \
                        "${dockerCmd__input}" \
                        "${errorMsg__input}" #\
                        # "${DOCKER__NUMOFLINES_0}"

        #Show current input
        if [[ ! -z ${readMsgRemarks__input} ]]; then
            echo -e "${readMsgRemarks__input}"
        fi
    fi

    #Start automcomplete
    while true
    do
        #Check if there is only 1 array-element.
        #Remark:
        #   If that is the case, then set 'ret' to that value.
        # if [[ ${onBackSpacePressed} == false ]]; then  #no backspace pressed
            # if [[ ${cachedInput_ArrLen} -eq 1 ]]; then  #only 1 result found
            #     ret=${cachedInput_Arr[0]}
            # fi
        # else    #backspace was pressed
        if [[ ${onBackSpacePressed} == true ]]; then  #no backspace pressed
            onBackSpacePressed=false    #set flag back to false
        fi

        if [[ ! -z ${readMsgUpdate__input} ]]; then
            echo -e "${readMsgUpdate__input}"
        fi
        echo -e "${readMsg__input}${ret}"

        #Move cursor up
        moveUp_oneLine_then_moveRight__func "${readMsg__input}" "${ret}"
        
        #Execute read-input
        read -N1 -rs -p "" keyInput

        case "${keyInput}" in
            ${DOCKER__ENTER})
                #Check if there were any ';b', ';c', ';h' issued.
                #In other words, whether 'ret' contains any of the above semi-colon chars.
                #If that's the case then function 'get_endResult_ofString_with_semiColonChar__func'
                #   will handle and return a modified 'ret'.
                ret_bck=${ret}  #set value
                ret=`get_endResult_ofString_with_semiColonChar__func "${ret_bck}"` 
                
                if [[ ! -z ${ret} ]]; then    #'ret' contains data
                    #Break immeidiately if ';b' or ';h' was found.
                    if [[ ${ret} == ${DOCKER__SEMICOLON_BACK} ]] || [[ ${ret} == ${DOCKER__SEMICOLON_HOME} ]]; then
                        break
                    fi

                    if [[ ! -z ${errorMsg2__input} ]]; then #not an Empty String
                        #Check if 'ret' is found in the image-/container-list
                        stdOutput=`${dockerCmd__input} | awk -vcolNo=${colNo__input} '{print $colNo}' | grep -w ${ret}`
                        if [[ ! -z ${stdOutput} ]] || [[ ${ret} == ${DOCKER__REMOVE_ALL} ]]; then    #match
                            break
                        else    #no match
                            #Update error message
                            errMsg="${errorMsg2__input}'${DOCKER__FG_LIGHTGREY}${ret}${DOCKER__NOCOLOR}'"

                            #Show error message
                            show_msg_wo_menuTitle_w_PressAnyKey__func "${errMsg}" "${DOCKER__NUMOFLINES_2}"

                            #Reset return value
                            ret=${DOCKER__EMPTYSTRING}

                            #Move Up and Clean
                            moveUp_and_cleanLines__func "${numOfLines_wError_tot}"
                        fi
                    else    #is an Empty String 
                        break
                    fi
                else    #'ret' is an Empty String
                    #Reset variable
                    ret=${DOCKER__EMPTYSTRING}

                    #If boolean is set to true, then exit while-loop.
                    if [[ ${onEnter_breakLoop__input} == true ]]; then
                        break
                    fi

                    #First Move-down, then Move-up, after that clean line
                    moveDown_oneLine_then_moveUp_and_clean__func "${numOfLines_noError_tot}"
                fi
                ;;
            ${DOCKER__BACKSPACE})
                #Update variable
                ret=`backspace_handler__func "${ret}"`

                #Set flag to 'true'
                onBackSpacePressed=true

                #First Move-down, then Move-up, after that clean line
                moveDown_oneLine_then_moveUp_and_clean__func "${numOfLines_noError_tot}"
                ;;
            ${DOCKER__ESCAPEKEY})
                #Handle Arrowkey-press
                arrowKeys_upDown_handler__func

                #Update variable
                if [[ ${cachedInput_ArrLen} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
                    ret=${cachedInput_Arr[cachedInput_ArrIndex]}
                else
                    ret=${DOCKER__EMPTYSTRING}
                fi

                #First Move-down, then Move-up, after that clean line
                moveDown_oneLine_then_moveUp_and_clean__func "${numOfLines_noError_tot}"
                ;;
            ${DOCKER__ONESPACE})
                #First Move-down, then Move-up, after that clean line
                moveDown_oneLine_then_moveUp_and_clean__func "${numOfLines_noError_tot}"
                ;;
            ${DOCKER__TAB})
                #This subroutine will also update 'ret'
                ret=`autocomplete__func "${ret}" "${cachedInput_Arr[@]}"`
                # autocomplete__func "${ret}" "${cachedInput_Arr[@]}"

                #First Move-down, then Move-up, after that clean line
                moveDown_oneLine_then_moveUp_and_clean__func "${numOfLines_noError_tot}"
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

                #First Move-down, then Move-up, after that clean line
                moveDown_oneLine_then_moveUp_and_clean__func "${numOfLines_noError_tot}"
                ;;
        esac
    done

    #Write to file
    echo -e "${ret}" > ${docker__readInput_w_autocomplete_out__fpath}
}

docker__show_infoTable__sub() {
    #Input args
    local menuTitle__input=${1}
    local dockerCmd__input=${2}
    local errorMsg__input=${3}
    # local numOfLines_toMoveDown=${4}

    # #Print empty lines (if applicable)
    # local counter=1
    # while [[ ${counter} -le ${numOfLines_toMoveDown} ]];
    # do
    #     moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    #     counter=$((counter+1))
    # done

    # #Get number of containers
    # local numOf_items=`${dockerCmd__input} | head -n -1 | wc -l`

    #Show Table
    if [[ ${cachedInput_ArrLen} -eq 0 ]]; then
        show_msg_w_menuTitle_w_pressAnyKey_w_ctrlC_func "${menuTitle__input}" \
                        "${errorMsg__input}" \
                        "${DOCKER__EXITCODE_99}"

        #IMPORTANT: this will make sure that this script is exited upon error
        docker__exitCode=$?
        if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
            exit__func "${exitCode__input}" "${DOCKER__NUMOFLINES_0}"
        fi
    else
        show_repoList_or_containerList_w_menuTitle__func "${menuTitle__input}" "${dockerCmd__input}"
    fi
}



#---MAIN SUBROUTINE
main__sub() {
    docker__get_source_fullpath__sub

    docker__load_source_files__sub

    docker__init_variables__sub

    docker__readInput_handler__sub
}



#---EXECUTE
main__sub
