#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---INPUT ARGS
menuTitle__input=${1}
Info__input=${2}
readMsg1__input=${3}
readMsg2__input=${4}
readMsg3__input=${5}
dataFpath__input=${6}



#---SUBROUTINES
docker__load_environment_variables__sub() {
    #Define paths
    docker__LTPP3_ROOTFS_development_tools__fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__LTPP3_ROOTFS_development_tools__dir=$(dirname ${docker__LTPP3_ROOTFS_development_tools__fpath})
    docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/

    docker__global_functions__filename="docker_global_functions.sh"
    docker__global_functions__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__global_functions__filename}
}

docker__load_source_files__sub() {
    source ${docker__global_functions__fpath}
}

docker__init_variables__sub() {
    docker__cachedInput_arr=()
    docker__cachedInput_arrLen=0
    docker__cachedInput_arrIndex=0
    docker__cachedInput_arrIndex_max=0

    docker__keyInput=${DOCKER__EMPTYSTRING}
    docker__keyInput_add=${DOCKER__EMPTYSTRING}
    docker__totInput=${DOCKER__EMPTYSTRING}

    docker__whatToDo_flag=${DOCKER__EMPTYSTRING}
    docker__seqNum_min=0
    docker__seqNum_min_bck=0
    docker__seqNum_max=0
    docker__turnPage=${DOCKER__EMPTYSTRING}
    docker__turnPage_isActive=false
}

docker__prev_next_var_set__sub() {
    docker__prev_only_print="${DOCKER__ONESPACE_PREV}"

    docker__oneSpacePrev_len=`get_stringlen_wo_regEx__func "${DOCKER__ONESPACE_PREV}"`
    docker__oneSpaceNext_len=`get_stringlen_wo_regEx__func "${DOCKER__ONESPACE_NEXT}"`
    docker__space_between_prev_and_next_len=$(( DOCKER__TABLEWIDTH - (docker__oneSpacePrev_len + docker__oneSpaceNext_len) - 1 ))
    docker__space_between_prev_and_next=`duplicate_char__func "${DOCKER__ONESPACE}" "${docker__space_between_prev_and_next_len}"`
    docker__prev_spaces_next_print="${DOCKER__ONESPACE_PREV}${docker__space_between_prev_and_next}${DOCKER__ONESPACE_NEXT}"

    docker_space_between_leftBoundary_and_next_len=$(( DOCKER__TABLEWIDTH - docker__oneSpacePrev_len - 1 ))
    docker_space_between_leftBoundary_and_next=`duplicate_char__func "${DOCKER__ONESPACE}" "${docker_space_between_leftBoundary_and_next_len}"`
    docker__next_only_print="${docker_space_between_leftBoundary_and_next}${DOCKER__ONESPACE_NEXT}"
}

docker_show_mainMenu_handler__sub() {
    #Initialization
    docker__seqNum_min=0
    docker__turnPage=${DOCKER__NEXT}
    docker__whatToDo_flag=${DOCKER__HASH}

    #Update sequence-related values
    #1. docker__seqNum_min_bck
    #2. docker__seqNum_min
    #3. docker__seqNum_max
    #4. docker__turnPage_isActive
    docker__seqNum_handler__sub "${docker__seqNum_min}" "${DOCKER__TABLEROWS}" "${docker__turnPage}"

    while true
    do
        #Check if 'docker__seqNum_min' has changed by comparing the current value with the backup'ed value.
        if [[ ${docker__turnPage_isActive} == true ]]; then
            #Print a horizontal line
            echo -e "${DOCKER__HORIZONTALLINE}"
            #Show menu-title
            show_centered_string__func "${menuTitle__input}" "${DOCKER__TABLEWIDTH}"
            #Print a horizontal line
            echo -e "${DOCKER__HORIZONTALLINE}"

            #Show file-cotent
            docker__show_fileContent__sub

            #Move-down and clean line
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            #Show prev-next line
            docker__show_prev_next_handler__sub "${dataFpath__input}"

            #Print a horizontal line
            echo -e "${DOCKER__FG_LIGHTGREY}${DOCKER__HORIZONTALLINE}${DOCKER__NOCOLOR}"
            #show location of the cache-file
            echo -e "${Info__input}"
            #Print a horizontal line
            echo -e "${DOCKER__FG_LIGHTGREY}${DOCKER__HORIZONTALLINE}${DOCKER__NOCOLOR}"

            #Print menu-options
            if [[ ${docker__whatToDo_flag} != ${DOCKER__HASH} ]]; then
                echo -e "${DOCKER__FOURSPACES_HASH_CHOOSE}"
            fi
            if [[ ${docker__whatToDo_flag} != ${DOCKER__PLUS} ]]; then
                echo -e "${DOCKER__FOURSPACES_PLUS_ADD}"
            fi
            if [[ ${docker__whatToDo_flag} != ${DOCKER__MINUS} ]]; then
                echo -e "${DOCKER__FOURSPACES_MINUS_DEL}"
            fi
            echo -e "${DOCKER__FOURSPACES_CARET_QUIT}"
            
            #Print a horizontal line
            echo -e "${DOCKER__FG_LIGHTGREY}${DOCKER__HORIZONTALLINE}${DOCKER__NOCOLOR}"
        fi
        
        #Show choose dialog
        docker__choose_handler__sub
    done
}
docker__show_prev_next_handler__sub() {
    #Number of Lines of file 'dataFpath__input'
    local fPath_numOfLines=`cat ${dataFpath__input} | wc -l`

    #Check if the specified file contains less than 10 lines
    if [[ ${fPath_numOfLines} -lt ${DOCKER__NUMOFMATCH_10} ]]; then #less than 10 lines
        echo -e "${EMPTYSTRING}"
    else    #10 or more lines
        if [[ ${docker__seqNum_min} -eq ${DOCKER__NUMOFMATCH_1} ]]; then
            echo -e "${docker__next_only_print}"
        else
            if [[ ${docker__seqNum_max} -eq ${fPath_numOfLines} ]]; then
                echo -e "${docker__prev_only_print}"
            else
                echo -e "${docker__prev_spaces_next_print}"
            fi
        fi
    fi
}
docker__seqNum_handler__sub() {
    #This subroutine will update the 'global' variables:
    #1. docker__seqNum_min_bck
    #2. docker__seqNum_min
    #3. docker__seqNum_max
    #4. docker__turnPage_isActive

    #Input args
    local seqNum_min__input=${1}   #current minimum value
    local seqNum_range__input=${2} #max number of items allowed to be shown in table
    local turnPage__input=${3}

    #Number of Lines of file 'dataFpath__input'
    local fPath_numOfLines=`cat ${dataFpath__input} | wc -l`

    #Backup current 'docker__seqNum_min'
    docker__seqNum_min_bck=${seqNum_min__input}

    #Get the minimum value
    if [[ ${seqNum_min__input} -eq ${DOCKER__NUMOFMATCH_0} ]]; then
        docker__seqNum_min=${DOCKER__NUMOFMATCH_1}
    else
        if [[ ${turnPage__input} == ${DOCKER__PREV} ]]; then
            docker__seqNum_min=$((seqNum_min__input - seqNum_range__input))

            #Check if 'docker__seqNum_min' is less than 'DOCKER__NUMOFMATCH_1'.
            if [[ ${docker__seqNum_min} -lt ${DOCKER__NUMOFMATCH_1} ]]; then
                #Set 'docker__seqNum_min' equal to the input value 'DOCKER__NUMOFMATCH_1'
                docker__seqNum_min=${DOCKER__NUMOFMATCH_1}
            fi
        else    #turnPage__input = DOCKER__NEXT
            #Set the minimum value
            docker__seqNum_min=$((seqNum_min__input + seqNum_range__input))

            #Check if 'docker__seqNum_mi > fPath_numOfLines'.
            if [[ ${docker__seqNum_min} -gt ${fPath_numOfLines} ]]; then
                #Set 'docker__seqNum_min' equal to the input value 'seqNum_min__input'
                docker__seqNum_min=${seqNum_min__input}
            fi
        fi
    fi

    #Get the maximum value
    docker__seqNum_max=$((docker__seqNum_min + seqNum_range__input - 1))
    
    #Check if 'docker__seqNum_max > fPath_numOfLines'
    if [[ ${docker__seqNum_max} -gt ${fPath_numOfLines} ]]; then
        #Set 'docker__seqNum_max' equal to 'fPath_numOfLines'
        docker__seqNum_max=${fPath_numOfLines}
    fi

    #Set 'docker__turnPage_isActive'
    #Remark:
    #   Compare 'docker__seqNum_min' with 'docker__seqNum_min_bck'. 
    #   1. Both values are not equal, then set 'docker__turnPage_isActive = true'.
    #   2. Both values are the same, then set 'docker__turnPage_isActive = false'.
    if [[ ${docker__seqNum_min} -ne ${docker__seqNum_min_bck} ]]; then
        docker__turnPage_isActive=true
    else
        docker__turnPage_isActive=false
    fi
}
docker__show_fileContent__sub() {
    #Initialization
    docker__seqNum=0
    docker__numOfItems_shown=0

    #List file-content
    while read -ra line
    do
        #increment sequence-number
        docker__seqNum=$((docker__seqNum + 1))

        #Show filename
        if [[ ${docker__seqNum} -ge ${docker__seqNum_min} ]]; then
            echo "${DOCKER__FOURSPACES}${docker__seqNum}. ${DOCKER__STX}${line}"

            #increment 'docker__numOfItems_shown' by 1
            docker__numOfItems_shown=$((docker__numOfItems_shown + 1))
        fi

        #Break loop once the maximum allowed sequence number has been reached
        if [[ ${docker__seqNum} -eq ${docker__seqNum_max} ]]; then
            break
        fi
    done < ${dataFpath__input}
}

docker__add_handler__sub() {
    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_5}"

    echo "docker__add_handler__sub::: IN PROGRESS..."
}

docker__any_handler__sub() {
    #Number of Lines of file 'dataFpath__input'
    local fPath_numOfLines=`cat ${dataFpath__input} | wc -l`
    if [[ ${fPath_numOfLines} -eq ${DOCKER__NUMOFMATCH_0} ]]; then    #contains no data
        moveToBeginning_and_cleanLine__func

        return
    fi

    #Check if 'docker__keyInput' is a number
    local isNumeric=`isNumeric__func ${docker__keyInput}`
    if [[ ${isNumeric} == false ]]; then #is a number
        moveToBeginning_and_cleanLine__func
        
        return
    fi

    if [[ ${docker__seqNum} -lt ${DOCKER__NUMOFMATCH_10} ]]; then
        docker__process_selected_item__sub "${docker__keyInput}"
    else    #docker__seqNum >= 10
echo ">>>>>> NEED TO CHECK WHETHER 'docker__totInput' has exceeded 'fPath_numOfLines' "
        docker__totInput=${docker__totInput}${docker__keyInput}
    fi

    #Clean and Move to the beginning of line
    moveToBeginning_and_cleanLine__func
}
docker__process_selected_item__sub() {
    #Input args
    local lineNum__input=${1}

    #Retrieve 'string' from file based on the specified 'lineNum__input'
    local line=`sed "${lineNum__input}q;d" ${dataFpath__input}`

    #Remove file if present
    if [[ -f ${docker__show_choose_add_del_from_cache_out__fpath} ]]; then
        rm ${docker__show_choose_add_del_from_cache_out__fpath}
    fi

    #Write to file
    echo "${line}" > ${docker__show_choose_add_del_from_cache_out__fpath}
    
    #Exit
    docker__exit_handler__sub
}

docker__choose_handler__sub() {
    while true
    do
        #Show echo-message
        echo "${readMsg1__input}${docker__totInput}" 

        moveUp_oneLine_then_moveRight__func "${readMsg1__input}" "${docker__totInput}"

        #Show read-input dialog
        read -N1 -rs docker__keyInput

        #Handle docker__keyInput
        case "${docker__keyInput}" in
            ${DOCKER__BACKSPACE})
                docker__backspace_handler__sub
                ;;
            ${DOCKER__ENTER})
                if [[ ${docker__seqNum} -ge ${DOCKER__NUMOFMATCH_10} ]]; then
                    echo "docker__choose_handler__sub:::DO SOMETHING2"                      
                fi

                moveToBeginning_and_cleanLine__func
                ;;
            ${DOCKER__ESCAPEKEY})
                docker__escapekey_flush_handler__sub
                ;;
            ${DOCKER__TAB})
                moveToBeginning_and_cleanLine__func    
                ;;
            ${DOCKER__PLUS})  
                docker__add_handler__sub
                ;;
            ${DOCKER__MINUS})  
                docker__del_handler__sub
                ;;
            ${DOCKER__ESCAPE_HOOKLEFT})  
                docker__prev_handler__sub

                break
                ;;
            ${DOCKER__ESCAPE_HOOKRIGHT})  
                docker__next_handler__sub

                break
                ;;
            ${DOCKER__CARET})  
                docker__exit_handler__sub
                ;;
            *)
                docker__any_handler__sub
                ;;
        esac
    done
}
docker__del_handler__sub() {
    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_5}"
    
    echo "docker__del_handler__sub::: IN PROGRESS..."
}

docker__backspace_handler__sub() {
    #Define variables
    local totInput_len=0

    #Get string length
    totInput_len=${#docker__totInput}

    #Check if the length is greater than 0
    #REMARK:
    #	If FALSE, then do not execute this part, otherwise...
    #	...the following ERROR would occur:
    #	" totInput_len: substring expression < 0"
    if [[ ${totInput_len} -gt 0 ]]; then	#length MUST be greater than 0
        #Substract by 1
        totInput_len=$((totInput_len-1))				

        #Substract 1 TRAILING character
        docker__totInput=${docker__totInput:0:totInput_len}
    else
        docker__totInput=${EMPTYSTRING}
    fi

    #Move-up and clean
    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_0}"
}

docker__enter_handler__sub() {
    #Define local variables
    local totInput_tmp=${DOCKER__EMPTYSTRING}

    #Check if there were any ';c' issued.
    #In other words, whether 'docker__totInput' contains any of the above semi-colon chars.
    #If that's the case then function 'get_endResult_ofString_with_semiColonChar__func'
    #   will handle and return the result 'ret'.
    totInput_tmp=`get_endResult_ofString_with_semiColonChar__func ${docker__totInput}`

    case "${totInput_tmp}" in
        ${DOCKER__EMPTYSTRING})
            #Reset variable
            docker__totInput=${DOCKER__EMPTYSTRING}
            
            #Clean and Move to the beginning of line
            moveToBeginning_and_cleanLine__func
            ;;
        *)
            if [[ ! -z ${docker__totInput} ]]; then  #command provided
                echo ">>>>DO SOMETHING HERE"

                #Reset variable
                docker__totInput=${DOCKER__EMTPYSTRING}

                #Move-down
                # moveDown__func "${DOCKER__NUMOFLINES_1}"
            else    #no input provided
                #Clean and Move to the beginning of line
                moveToBeginning_and_cleanLine__func
            fi
            ;;
    esac
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
    docker__totInput=${docker__cachedInput_arr[docker__cachedInput_arrIndex]}

    #Move-up and clean
    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_0}"
}

docker__escapekey_flush_handler__sub() {
    #Clean and Move to the beginning of line
    moveToBeginning_and_cleanLine__func      

    # Flush "stdin" with 0.1  sec timeout.
    read -rsn1 -t 0.1 tmp
    # Flush "stdin" with 0.1  sec timeout.
    read -rsn1 -t 0.1 tmp
}

docker__exit_handler__sub() {
    #Clean and Move to the beginning of line
    moveToBeginning_and_cleanLine__func   

    #Show last key-input
    echo "${readMsg1__input}${docker__keyInput}" 

    #Exit this file
    docker__exitFunc "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_2}"
}

docker__next_handler__sub() {
    docker__turnPage=${DOCKER__NEXT}

    docker__seqNum_handler__sub "${docker__seqNum_min}" "${DOCKER__TABLEROWS}" "${docker__turnPage}"

    #Move-down and clean line
    if [[ ${docker__turnPage_isActive} == true ]]; then
        #Remark:
        #   'DOCKER__NUMOFLINES_12' is the number of lines of all the other printed text of the table.
        local numOfLines_toMoveUp=$((DOCKER__NUMOFLINES_12 + docker__numOfItems_shown))

        moveUp_and_cleanLines__func "${numOfLines_toMoveUp}"
    else
        moveToBeginning_and_cleanLine__func   
    fi
}

docker__prev_handler__sub() {
    docker__turnPage=${DOCKER__PREV}

    docker__seqNum_handler__sub "${docker__seqNum_min}" "${DOCKER__TABLEROWS}" "${docker__turnPage}"

    #Move-down and clean line
    if [[ ${docker__turnPage_isActive} == true ]]; then
        #Remark:
        #   'DOCKER__NUMOFLINES_12' is the number of lines of all the other printed text of the table.
        local numOfLines_toMoveUp=$((DOCKER__NUMOFLINES_12 + docker__numOfItems_shown))

        moveUp_and_cleanLines__func "${numOfLines_toMoveUp}"
    else
        moveToBeginning_and_cleanLine__func   
    fi
}



docker__append_keyInput_handler__sub() {
    #wait for another 0.5 seconds to capture additional characters.
    #Remark:
    #   This part has been implemented just in case long text has been copied/pasted.
    read -rs -t0.01 docker__keyInput_add

    #Append 'docker__keyInput_add' to 'docker__keyInput'
    docker__keyInput="${docker__keyInput}${docker__keyInput_add}"

    #Append key-input
    docker__totInput="${docker__totInput}${docker__keyInput}"

    #Clean and Move to the beginning of line
    moveToBeginning_and_cleanLine__func
}



#---MAIN SUBROUTINE
main_sub() {
    docker__load_environment_variables__sub

    docker__load_source_files__sub

    docker__init_variables__sub

    docker__prev_next_var_set__sub

    docker_show_mainMenu_handler__sub
}



#---EXECUTE
main_sub
