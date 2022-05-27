#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---INPUT ARGS
menuTitle__input=${1}
readMsg__input=${2}
errorMsg__input=${3}
cmd__input=${4}
showTable__input=${5}
onEnter_breakLoop__input=${6}


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

function run_cmd_and_read_output_into_array__func() {
    #Input args
    local cmd__input=${1}

    #Define local variables
    local cachedInputArr_string=${DOCKER__EMPTYSTRING}
    local cachedInputArr_raw_string=${DOCKER__EMPTYSTRING}

    #These are global variables
    cachedInput_Arr=()
    cachedInput_ArrLen=0
    cachedInput_ArrIndex=0
    cachedInput_ArrIndex_max=0

    #Run command and read into Array
    readarray -t cachedInput_Arr < <(${cmd__input} | tr -d "[:blank:]")

    #Update array-length
    cachedInput_ArrLen=${#cachedInput_Arr[@]}

    #Index starts with 0, therefore deduct array-length by 1
    cachedInput_ArrIndex_max=$((cachedInput_ArrLen-1))

    #Update current array-index
    cachedInput_ArrIndex=${cachedInput_ArrIndex_max}
}



#---SUBROUTINES
docker__environmental_variables__sub() {
	# docker__current_dir=`pwd`
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

    docker__global__filename="docker_global.sh"
    docker__global__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global__filename}
}

docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

docker__init_variables__sub() {
    docker__1stTimeUse=true

    #***ASSUMPTION:
    #   
    docker__isDockerCmd=true
}

docker__readInput_handler__sub() {
    #Get read-input value
    docker__readInput_w_autocomplete__sub "${menuTitle__input}" \
                        "${readMsg__input}" \
                        "${errorMsg__input}" \
                        "${cmd__input}" \
                        "${showTable__input}" \
                        "${onEnter_breakLoop__input}"

    #Print empty lines
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
}

docker__readInput_w_autocomplete__sub() {
    #Input args
    local menuTitle__input=${1}
    local readMsg__input=${2}
    local errorMsg__input=${3}
    local cmd__input=${4}
    local showTable__input=${5}
    local onEnter_breakLoop__input=${6}

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

#---Run command and read output into 'cachedInput_Arr'
    run_cmd_and_read_output_into_array__func "${cmd__input}"

#---Show Docker Container's List
    #Calculate number of lines to be cleaned
    local readMsg_numOfLines=0
    if [[ ! -z ${readMsg__input} ]]; then    #this condition is important
        readMsg_numOfLines=`echo -e ${readMsg__input} | wc -l`      
    fi
    local update_numOfLines=0

    local numOfLines_noError_tot=$((readMsg_numOfLines + update_numOfLines))
    local numOfLines_wError_tot=$((DOCKER__NUMOFLINES_5 +  update_numOfLines))

    #Only execute this condition if 'menuTitle__input' is not an Empty String
    #Remark:
    #   This way we can control whether to show the Image-list Table or not.
    if [[ ${showTable__input} == true ]]; then
        docker__show_infoTable__sub "${menuTitle__input}" \
                        "${errorMsg__input}" \
                        "${cachedInput_Arr[@]}"
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
                ret=`get_endResult_ofString_with_semiColonChar__func ${ret_bck}` 
                
                if [[ ! -z ${ret} ]]; then    #'ret' contains data
                    #Remove asterisks (*) from 'ret'
                    ret=`echo "${ret}" | sed 's/*//g'`

                    break
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
    echo -e "${ret}" > ${git__git_readInput_w_autocomplete_out__fpath}
}

docker__show_infoTable__sub() {
    #Input args
    local menuTitle__input=${1}
    local errorMsg__input=${2}
    shift
    shift
    local dataArr__input=("$@")

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
        show_array_elements_w_menuTitle__func "${menuTitle__input}" "${dataArr__input[@]}"
    fi
}



#---MAIN SUBROUTINE
main__sub() {
    docker__environmental_variables__sub

    docker__load_source_files__sub

    docker__init_variables__sub

    docker__readInput_handler__sub
}



#---EXECUTE
main__sub
