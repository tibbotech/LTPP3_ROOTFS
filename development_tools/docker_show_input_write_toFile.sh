#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---INPUT ARGS
menuTitle__input=${1}
Info__input=${2}
readMsg1__input=${3}
readMsg2__input=${4}
readMsg3__input=${5}
dataFPath__input=${6}




#---SUBROUTINES
docker__get_source_fullpath__sub() {
    #Check the number of input args
    if [[ -z ${docker__global__fpath} ]]; then   #must be equal to 3 input args
        #---Defin FOLDER
        docker__LTPP3_ROOTFS__foldername="LTPP3_ROOTFS"
        docker__development_tools__foldername="development_tools"

        #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
        #... and read to array 'find_result_arr'
        #Remark:
        #   By using '2> /dev/null', the errors are not shown.
        readarray -t find_dir_result_arr < <(find  / -type d -iname "${docker__LTPP3_ROOTFS__foldername}" 2> /dev/null)

        #Define variable
        local find_path_of_LTPP3_ROOTFS=${DOCKER__EMPTYSTRING}

        #Loop thru array-elements
        for find_dir_result_arrItem in "${find_dir_result_arr[@]}"
        do
            #Update variable 'find_path_of_LTPP3_ROOTFS'
            find_path_of_LTPP3_ROOTFS="${find_dir_result_arrItem}/${docker__development_tools__foldername}"
            #Check if 'directory' exist
            if [[ -d "${find_path_of_LTPP3_ROOTFS}" ]]; then    #directory exists
                #Update variable
                docker__LTPP3_ROOTFS_development_tools__dir="${find_path_of_LTPP3_ROOTFS}"

                break
            fi
        done

        docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/
        docker__parentDir_of_LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS__dir%/*}    #move two directories up. This directory is the one-level higher than LTPP3_ROOTFS/

        docker__global__filename="docker_global.sh"
        docker__global__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__global__filename}
    fi
}

docker__load_source_files__sub() {
    source ${docker__global_functions__fpath}
}

docker__init_variables__sub() {
    docker__cachedInput_arr=()
    docker__cachedInput_arrLen=0
    docker__cachedInput_arrIndex=0
    docker__cachedInput_arrIndex_max=0

    docker__seqNum=0

    docker__keyInput=${DOCKER__EMPTYSTRING}
    docker__keyInput_add=${DOCKER__EMPTYSTRING}
    docker__totInput=${DOCKER__EMPTYSTRING}
}

docker__show_and_input_handler__sub() {
    while true
    do
        #Print a horizontal line
        echo -e "${DOCKER__HORIZONTALLINE}"
        #Show menu-title
        show_centered_string__func "${menuTitle__input}" "${DOCKER__TABLEWIDTH}"
        #Print a horizontal line
        echo -e "${DOCKER__HORIZONTALLINE}"

        #Initialization
        docker__seqNum=0

        #List file-content
        while read -ra line
        do
            #increment sequence-number
            docker__seqNum=$((docker__seqNum+1))

            #Show filename
            echo "${DOCKER__FOURSPACES}${docker__seqNum}. ${DOCKER__STX}${line}"
        done < ${dataFPath__input}

        #Move-down and clean line
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        #Print a horizontal line
        echo -e "${DOCKER__FG_LIGHTGREY}${DOCKER__HORIZONTALLINE}${DOCKER__NOCOLOR}"
        #show location of the cache-file
        echo -e "${Info__input}"

        #Print a horizontal line
        echo -e "${DOCKER__FG_LIGHTGREY}${DOCKER__HORIZONTALLINE}${DOCKER__NOCOLOR}"
        #Print menu-options
        echo -e "${DOCKER__FOURSPACES_I_INPUT}"
        echo -e "${DOCKER__FOURSPACES_D_DELETE}"
        echo -e "${DOCKER__FOURSPACES_Q_QUIT}"
        #Print a horizontal line
        echo -e "${DOCKER__FG_LIGHTGREY}${DOCKER__HORIZONTALLINE}${DOCKER__NOCOLOR}"
        
        #Show choose dialog
        docker__choose_handler__sub
    done

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
            i)  
                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_5}"

                docker__input_handler__sub
                ;;
            d)  
                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_5}"

                docker__delete_handler__sub
                ;;
            q)  
                docker__exit_handler__sub
                ;;
            *)
                if [[ ${docker__seqNum} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
                    if [[ ${docker__seqNum} -lt ${DOCKER__NUMOFMATCH_10} ]]; then
                        echo "docker__choose_handler__sub:::DO SOMETHING1"     
                    else    #docker__seqNum >= 10
                        docker__totInput=${docker__totInput}${docker__keyInput}
                    fi
                fi

                moveToBeginning_and_cleanLine__func
                ;;
        esac
    done
}
docker__input_handler__sub() {
    echo "docker__input_handler__sub::: IN PROGRESS..."
}
docker__delete_handler__sub() {
    echo "docker__delete_handler__sub::: IN PROGRESS..."
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
    totInput_tmp=`get_endResult_ofString_with_semiColonChar__func "${docker__totInput}"`

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
    docker__exitFunc "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_0}"
}



#---MAIN SUBROUTINE
main_sub() {
    docker__get_source_fullpath__sub

    docker__load_source_files__sub

    docker__init_variables__sub

    docker__show_and_input_handler__sub
}



#---EXECUTE
main_sub
