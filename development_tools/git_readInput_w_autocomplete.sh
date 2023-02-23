#!/bin/bash -m
#Remark: by using '-m' the INTERRUPT executed here will NOT propagate to the UPPERLAYER scripts
#---INPUT ARGS
menuTitle__input=${1}
menuOptions__input=${2}
readDialog__input=${3}
errorMsg__input=${4}
cmd__input=${5}
showTable__input=${6}
onEnter_breakLoop__input=${7}
tibboHeader_prepend_numOfLines__input=${8}



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

    #Check if 'docker__cachedInput_ArrLen > 0'
    #Remark:
    #   If false, then exit this function right away.
    if [[ ${docker__cachedInput_ArrLen} -eq 0 ]]; then
        return
    fi

    #*********************************************************
    #This part MUST be executed after the 'Arrow-key handling'
    #*********************************************************
    if [[ ${arrow_direction} == ${DOCKER__ARROWUP} ]]; then
        if [[ ${docker__1stTimeUse} == true ]]; then
            docker__cachedInput_ArrIndex=0

            docker__1stTimeUse=false
        else
            if [[ ${docker__cachedInput_ArrIndex} -eq 0 ]]; then    #index is already leveled to 0
                docker__cachedInput_ArrIndex=${docker__cachedInput_ArrIndex_max}    #set index to the max. value
            else    #for all other indexes
                docker__cachedInput_ArrIndex=$((docker__cachedInput_ArrIndex-1))
            fi
        fi
    elif [[ ${arrow_direction} == ${DOCKER__ARROWDOWN} ]]; then
        if [[ ${docker__1stTimeUse} == true ]]; then
            docker__cachedInput_ArrIndex=0

            docker__1stTimeUse=false
        else
            if [[ ${docker__cachedInput_ArrIndex} -eq ${docker__cachedInput_ArrIndex_max} ]]; then  #index is already maxed out
                docker__cachedInput_ArrIndex=0
            else    #for all other indexes
                docker__cachedInput_ArrIndex=$((docker__cachedInput_ArrIndex+1))
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
    local keyWord__input=${1}
    shift
    local dataArr__input=("$@")

    #Define and update keyWord__input
    local dataArr_filtered_1stElement_len=0
    local keyWord_bck=${DOCKER__EMPTYSTRING}
    local keyWord_incr=${DOCKER__EMPTYSTRING}
    local keyWord_len=0
    local numOfMatch=0
    local numOfMatch_init=0
    local ret=${DOCKER__EMPTYSTRING}

    #Remove asterisks (*) from 'keyWord__input'
    local keyWord_clean=`echo "${keyWord__input}" | sed 's/*//g'`

    #Remove asterisks (*) from 'dataArr__input'
    #Explanation:
    #   printf '%s\n' "${dataArr__input[@]}": print each array-element separated by a (\n)
    #   sed 's/*//g': substitute asterisk (*) with 'Empty String'
    #   sed 's/\n/ /g': substitute (\n) with space ( )
    local dataArr_clean_string=`printf '%s\n' "${dataArr__input[@]}" | sed 's/*//g' | sed 's/\n/ /g'`
    local dataArr_clean=(`echo "${dataArr_clean_string}"`)

    #Get only array-elements containing 'keyWord_clean'
    #Explanation:
    #   printf '%s\n' "${dataArr_clean[@]}": print each array-element separated by a (\n)
    #   grep "^${keyWord_clean}": get only array-elements matching 'keyWord_clean'
    #   sed 's/\n/ /g': substitute (\n) with space ( )
    local dataArr_filtered_string=`printf '%s\n' "${dataArr_clean[@]}" | grep "^${keyWord_clean}" | sed 's/\n/ /g'`
    local dataArr_filtered=(`echo "${dataArr_filtered_string}"`)

    #initialization
    dataArr_filtered_1stElement_len=${#dataArr_filtered[0]}
    keyWord_incr=${keyWord_clean}
    numOfMatch_init=${#dataArr_filtered[@]}
    numOfMatch=${numOfMatch_init}

    #Find the closest match
    while true
    do
        if [[ ${numOfMatch_init} -eq 0 ]]; then  #no match
            #Exit loop
            break
        elif [[ ${numOfMatch_init} -eq 1 ]]; then  #only 1 match
            #Update variable
            ret=`printf '%s\n' "${dataArr_filtered[@]}" | grep "^${keyWord_incr}"`

            #Exit loop
            break
        else    #multiple matches
            #Backup 'keyWord_incr'
            keyWord_bck=${keyWord_incr}

            #Get 'keyWord_bck' length
            keyWord_bck_len=${#keyWord_bck}

            #Increment 'keyWord_len' length by 1
            keyWord_len=$((keyWord_bck_len + 1))

            #Get the next 'keyWord_incr' (by using the 1st array-element as base)
            keyWord_incr=${dataArr_filtered[0]:0:keyWord_len}

            #Check if the total length of the 1st array-element has been reached
            if [[ ${keyWord_bck_len} -eq ${dataArr_filtered_1stElement_len} ]]; then
                ret=${keyWord_bck}

                break
            fi

            #Get the new number of matches
            numOfMatch=`printf '%s\n' "${dataArr_filtered[@]}" | grep "^${keyWord_incr}" | wc -l`

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
docker__load_global_fpath_paths__sub() {
    source ${docker__global__fpath}
}

docker__init_variables__sub() {
    docker__1stTimeUse=true 
}

docker__readInput_handler__sub() {
    #Get read-input value
    docker__readInput_w_autocomplete__sub "${menuTitle__input}" \
                        "${menuOptions__input}" \
                        "${readDialog__input}" \
                        "${errorMsg__input}" \
                        "${cmd__input}" \
                        "${showTable__input}" \
                        "${onEnter_breakLoop__input}" \
                        "${tibboHeader_prepend_numOfLines__input}"

    #Print empty lines
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
}

docker__readInput_w_autocomplete__sub() {
    #Input args
    local menuTitle__input=${1}
    local menuOptions__input=${2}
    local readDialog__input=${3}
    local errorMsg__input=${4}
    local cmd__input=${5}
    local showTable__input=${6}
    local onEnter_breakLoop__input=${7}
    local tibboHeader_prepend_numOfLines__input=${8}

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
    if [[ -f ${git__git_readInput_w_autocomplete_out__fpath} ]]; then
        rm ${git__git_readInput_w_autocomplete_out__fpath}
    fi



#---Run command and read output into 'docker__cachedInput_Arr'
    docker__run_cmd_and_read_output_into_array__sub "${cmd__input}"



#---Update table-input variables
    local dataArr_pageNum=${DOCKER__LINENUM_1}

    local dataArr_pageLines=${DOCKER__TABLEROWS_20}
    if [[ ${docker__cachedInput_ArrLen} -eq 0 ]]; then
        dataArr_pageLines=${DOCKER__NUMOFLINES_1}
    else 
        if [[ ${docker__cachedInput_ArrLen} -le ${DOCKER__TABLEROWS_20} ]]; then
            dataArr_pageLines=${docker__cachedInput_ArrLen}
        fi
    fi

    local dataArr_pageNumMax=$((docker__cachedInput_ArrLen/dataArr_pageLines))
    local mod_remainder=$((docker__cachedInput_ArrLen%dataArr_pageLines))
    if [[ ${mod_remainder} -ne ${DOCKER__NUMOFMATCH_0} ]]; then #there are leftovers after division
        dataArr_pageNumMax=$((dataArr_pageNumMax + 1))
    fi



#---Calculate number of lines to be cleaned
    local empty_NumOfLines=${DOCKER__NUMOFLINES_1}  #empty line
    local horiz_numOfLines=${DOCKER__NUMOFLINES_4}  #horizontal lines
    local prev_next_numOfLines=${DOCKER__NUMOFLINES_1}  #prev and next line
    local menuOptions_numOfLines=0  
    if [[ ! -z ${menuOptions__input} ]]; then
        menuOptions_numOfLines=`echo -e ${menuOptions__input} | wc -l`  #menu-options lines  
    fi
    local readMsg_numOfLines=0 
    if [[ ! -z ${readDialog__input} ]]; then
        readMsg_numOfLines=`echo -e ${readDialog__input} | wc -l`  #read-dialog lines
    fi
    #Total number of lines to be cleaned
    local tot_numOfLines_toClean=$((empty_NumOfLines + horiz_numOfLines + menuOptions_numOfLines + prev_next_numOfLines + readMsg_numOfLines + dataArr_pageLines))
    


#---Show array-elements
    if [[ ${showTable__input} == true ]]; then
        #Check if 'tibboHeader_prepend_numOfLines__input' is an Empty String
        if [[ -z ${tibboHeader_prepend_numOfLines__input} ]]; then
            tibboHeader_prepend_numOfLines__input=${DOCKER__NUMOFLINES_2}
        fi

        #Print Tibbo-title
        load_tibbo_title__func "${tibboHeader_prepend_numOfLines__input}"

        #Show array-elements
        docker__show_infoTable__sub "${menuTitle__input}" \
                        "${menuOptions__input}" \
                        "${errorMsg__input}" \
                        "${dataArr_pageNum}" \
                        "${dataArr_pageLines}" \
                        "${docker__cachedInput_Arr[@]}"
    fi

    #Start automcomplete
    while true
    do
        #Check if there is only 1 array-element.
        #Remark:
        #   If that is the case, then set 'ret' to that value.
        # if [[ ${onBackSpacePressed} == false ]]; then  #no backspace pressed
            # if [[ ${docker__cachedInput_ArrLen} -eq 1 ]]; then  #only 1 result found
            #     ret=${docker__cachedInput_Arr[0]}
            # fi
        # else    #backspace was pressed
        if [[ ${onBackSpacePressed} == true ]]; then  #no backspace pressed
            onBackSpacePressed=false    #set flag back to false
        fi

        echo -e "${readDialog__input}${ret}"

        #Move cursor up
        moveUp_oneLine_then_moveRight__func "${readDialog__input}" "${ret}"
        
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
                    #Check if 'ret' has a leading asterisk (*)
                    local asterisk_isFound=`checkIf_string_contains_a_leading_specified_chars__func "${ret}" "${DOCKER__NUMOFMATCH_1}" "${DOCKER__ASTERISK}"`
                    if [[ ${asterisk_isFound} == true  ]]; then
                        #Remove asterisk (*)
                        ret=`echo "${ret}" | sed 's/*//g'`
                    fi

                    break
                else    #'ret' is an Empty String
                    #Reset variable
                    ret=${DOCKER__EMPTYSTRING}

                    #If boolean is set to true, then exit while-loop.
                    if [[ ${onEnter_breakLoop__input} == true ]]; then
                        break
                    fi

                    #First Move-down, then Move-up, after that clean line
                    moveDown_oneLine_then_moveUp_and_clean__func "${readMsg_numOfLines}"
                fi
                ;;
            ${DOCKER__BACKSPACE})
                #Update variable
                ret=`backspace_handler__func "${ret}"`

                #Set flag to 'true'
                onBackSpacePressed=true

                #First Move-down, then Move-up, after that clean line
                moveDown_oneLine_then_moveUp_and_clean__func "${readMsg_numOfLines}"
                ;;
            ${DOCKER__ESCAPED_HOOKLEFT})
                if [[ ${dataArr_pageNum} -gt ${DOCKER__NUMOFMATCH_2} ]]; then
                    #Update variable
                    dataArr_pageNum=$((dataArr_pageNum - 1))

                    #Move-up and clean
                    moveUp_and_cleanLines__func "${tot_numOfLines_toClean}"

                    #Show array-elements
                    docker__show_infoTable__sub "${menuTitle__input}" \
                            "${menuOptions__input}" \
                            "${errorMsg__input}" \
                            "${dataArr_pageNum}" \
                            "${dataArr_pageLines}" \
                            "${docker__cachedInput_Arr[@]}"
                fi

                #Move-to-beginning of line and clean
                moveToBeginning_and_cleanLine__func

                ;;
            ${DOCKER__ESCAPED_HOOKRIGHT})
                if [[ ${dataArr_pageNum} -lt ${dataArr_pageNumMax} ]]; then
                    #Update variable
                    dataArr_pageNum=$((dataArr_pageNum + 1))

                    #Move-up and clean
                    moveUp_and_cleanLines__func "${tot_numOfLines_toClean}"

                    #Show array-elements
                    docker__show_infoTable__sub "${menuTitle__input}" \
                            "${menuOptions__input}" \
                            "${errorMsg__input}" \
                            "${dataArr_pageNum}" \
                            "${dataArr_pageLines}" \
                            "${docker__cachedInput_Arr[@]}"
                fi

                #Move-to-beginning of line and clean
                moveToBeginning_and_cleanLine__func
                ;;
            ${DOCKER__ESCAPEKEY})
                #Handle Arrowkey-press
                arrowKeys_upDown_handler__func

                #Update variable
                if [[ ${docker__cachedInput_ArrLen} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
                    ret=${docker__cachedInput_Arr[docker__cachedInput_ArrIndex]}

                    #Check if 'ret' has a leading asterisk (*)
                    local asterisk_isFound=`checkIf_string_contains_a_leading_specified_chars__func "${ret}" "${DOCKER__NUMOFMATCH_1}" "${DOCKER__ASTERISK}"`
                    if [[ ${asterisk_isFound} == true  ]]; then
                        #Remove asterisk (*)
                        ret=`echo "${ret}" | sed 's/*//g'`
                    fi
                else
                    ret=${DOCKER__EMPTYSTRING}
                fi

                #First Move-down, then Move-up, after that clean line
                moveDown_oneLine_then_moveUp_and_clean__func "${readMsg_numOfLines}"
                ;;
            ${DOCKER__ONESPACE})
                #First Move-down, then Move-up, after that clean line
                moveDown_oneLine_then_moveUp_and_clean__func "${readMsg_numOfLines}"
                ;;
            ${DOCKER__TAB})
                #This subroutine will also update 'ret'
                ret=`autocomplete__func "${ret}" "${docker__cachedInput_Arr[@]}"`

                #First Move-down, then Move-up, after that clean line
                moveDown_oneLine_then_moveUp_and_clean__func "${readMsg_numOfLines}"
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
                moveDown_oneLine_then_moveUp_and_clean__func "${readMsg_numOfLines}"
                ;;
        esac
    done

    #Write to file
    echo -e "${ret}" > ${git__git_readInput_w_autocomplete_out__fpath}
}

docker__run_cmd_and_read_output_into_array__sub() {
    #Input args
    local cmd__input=${1}

    #These are global variables
    docker__cachedInput_Arr=()
    docker__cachedInput_ArrLen=0
    docker__cachedInput_ArrIndex=0
    docker__cachedInput_ArrIndex_max=0

    #Run command and read into Array
    readarray -t docker__cachedInput_Arr < <(${cmd__input} | tr -d "[:blank:]")

    #Update array-length
    docker__cachedInput_ArrLen=${#docker__cachedInput_Arr[@]}

    #Index starts with 0, therefore deduct array-length by 1
    docker__cachedInput_ArrIndex_max=$((docker__cachedInput_ArrLen-1))

    #Update current array-index
    docker__cachedInput_ArrIndex=${docker__cachedInput_ArrIndex_max}
}

docker__show_infoTable__sub() {
    #Input args
    local menuTitle__input=${1}
    local menuOptions__input=${2}
    local errorMsg__input=${3}
    local dataArr_pageNum__input=${4}    #page-number
    local dataArr_pageLines__input=${5}  #number of lines to be shown
    shift
    shift
    shift
    shift
    shift
    local dataArr__input=("$@")

    #Show Table
    if [[ ${docker__cachedInput_ArrLen} -eq 0 ]]; then
        show_msg_w_menuTitle_only_func "${menuTitle__input}" \
                        "${errorMsg__input}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${DOCKER__NUMOFLINES_0}" \
                        "${DOCKER__NUMOFLINES_4}" \
                        "${DOCKER__NUMOFLINES_0}" \
                        "${DOCKER__EMPTYSTRING}"


        #IMPORTANT: this will make sure that this script is exited upon error
        docker__exitCode=$?
        if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
            exit__func "${exitCode__input}" "${DOCKER__NUMOFLINES_0}"
        fi
    else
        show_array_elements_w_menuTitle__func "${menuTitle__input}" \
                        "${menuOptions__input}" \
                        "${dataArr_pageNum__input}" \
                        "${dataArr_pageLines__input}" \
                        "${dataArr__input[@]}"
    fi
}



#---MAIN SUBROUTINE
main__sub() {
    docker__get_source_fullpath__sub

    docker__load_global_fpath_paths__sub

    docker__init_variables__sub

    docker__readInput_handler__sub
}



#---EXECUTE
main__sub
