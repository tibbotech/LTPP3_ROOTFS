#!/bin/bash -m
#Remark: by using '-m' the INTERRUPT executed here will NOT propagate to the UPPERLAYER scripts
#---INPUT ARGS
menuTitle__input=${1}
Info__input=${2}
readMsg1__input=${3}
readMsg2__input=${4}
readMsg3__input=${5}
dataFPath__input=${6}



#---SUBROUTINES
docker__get_source_fullpath__sub() {
    #Define constants
    local PHASE_CHECK_CACHE=1
    local PHASE_FIND_PATH=10
    local PHASE_EXIT=100

    #Define variables
    local phase=""

    local current_dir=""
    local parent_dir=""
    local search_dir=""
    local tmp_dir=""

    local development_tools_foldername=""
    local lTPP3_ROOTFS_foldername=""
    local global_filename=""
    local parentDir_of_LTPP3_ROOTFS_dir=""

    local mainmenu_path_cache_filename=""
    local mainmenu_path_cache_fpath=""

    local find_dir_result_arr=()
    local find_dir_result_arritem=""

    local path_of_development_tools_found=""
    local parentpath_of_development_tools=""

    local isfound=""

    local retry_ctr=0

    #Set variables
    phase="${PHASE_CHECK_CACHE}"
    current_dir=$(dirname $(readlink -f $0))
    parent_dir="$(dirname "${current_dir}")"
    tmp_dir=/tmp
    development_tools_foldername="development_tools"
    global_filename="docker_global.sh"
    lTPP3_ROOTFS_foldername="LTPP3_ROOTFS"

    mainmenu_path_cache_filename="docker__mainmenu_path.cache"
    mainmenu_path_cache_fpath="${tmp_dir}/${mainmenu_path_cache_filename}"

    result=false

    #Start loop
    while true
    do
        case "${phase}" in
            "${PHASE_CHECK_CACHE}")
                if [[ -f "${mainmenu_path_cache_fpath}" ]]; then
                    #Get the directory stored in cache-file
                    docker__LTPP3_ROOTFS_development_tools__dir=$(awk 'NR==1' "${mainmenu_path_cache_fpath}")

                    #Move one directory up
                    parentpath_of_development_tools=$(dirname "${docker__LTPP3_ROOTFS_development_tools__dir}")

                    #Check if 'development_tools' is in the 'LTPP3_ROOTFS' folder
                    isfound=$(docker__checkif_paths_are_related "${current_dir}" \
                            "${parentpath_of_development_tools}" "${lTPP3_ROOTFS_foldername}")
                    if [[ ${isfound} == false ]]; then
                        phase="${PHASE_FIND_PATH}"
                    else
                        result=true

                        phase="${PHASE_EXIT}"
                    fi
                else
                    phase="${PHASE_FIND_PATH}"
                fi
                ;;
            "${PHASE_FIND_PATH}")   
                #Print
                echo -e "---:\e[30;38;5;215mSTART\e[0;0m: find path of folder \e[30;38;5;246m'${development_tools_foldername}\e[0;0m"

                #Initialize variables
                docker__LTPP3_ROOTFS_development_tools__dir=""
                search_dir="${current_dir}"   #start with search in the current dir

                #Start loop
                while true
                do
                    #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
                    #... and read to array 'find_result_arr'
                    readarray -t find_dir_result_arr < <(find  "${search_dir}" -type d -iname "${lTPP3_ROOTFS_foldername}" 2> /dev/null)

                    #Iterate thru each array-item
                    for find_dir_result_arritem in "${find_dir_result_arr[@]}"
                    do
                        echo -e "---:\e[30;38;5;215mCHECKING\e[0;0m: ${find_dir_result_arritem}"

                        #Find path
                        isfound=$(docker__checkif_paths_are_related "${current_dir}" \
                                "${find_dir_result_arritem}"  "${lTPP3_ROOTFS_foldername}")
                        if [[ ${isfound} == true ]]; then
                            #Update variable 'path_of_development_tools_found'
                            path_of_development_tools_found="${find_dir_result_arritem}/${development_tools_foldername}"

                            #Check if 'directory' exist
                            if [[ -d "${path_of_development_tools_found}" ]]; then    #directory exists
                                #Update variable
                                #Remark:
                                #   'docker__LTPP3_ROOTFS_development_tools__dir' is a global variable.
                                #   This variable will be passed 'globally' to script 'docker_global.sh'.
                                docker__LTPP3_ROOTFS_development_tools__dir="${path_of_development_tools_found}"

                                break
                            fi
                        fi
                    done

                    #Check if 'docker__LTPP3_ROOTFS_development_tools__dir' contains any data
                    if [[ -z "${docker__LTPP3_ROOTFS_development_tools__dir}" ]]; then  #contains no data
                        case "${retry_ctr}" in
                            0)
                                search_dir="${parent_dir}"    #next search in the 'parent' directory
                                ;;
                            1)
                                search_dir="/" #finally search in the 'main' directory (the search may take longer)
                                ;;
                            *)
                                echo -e "\r"
                                echo -e "***\e[1;31mERROR\e[0;0m: folder \e[30;38;5;246m${development_tools_foldername}\e[0;0m: \e[30;38;5;131mNot Found\e[0;0m"
                                echo -e "\r"

                                #Update variable
                                result=false

                                #set phase
                                phase="${PHASE_EXIT}"

                                break
                                ;;
                        esac

                        ((retry_ctr++))
                    else    #contains data
                        #Print
                        echo -e "---:\e[30;38;5;215mCOMPLETED\e[0;0m: find path of folder \e[30;38;5;246m'${development_tools_foldername}\e[0;0m"


                        #Write to file
                        echo "${docker__LTPP3_ROOTFS_development_tools__dir}" | tee "${mainmenu_path_cache_fpath}" >/dev/null

                        #Print
                        echo -e "---:\e[30;38;5;215mSTATUS\e[0;0m: write path to temporary cache-file: \e[1;33mDONE\e[0;0m"

                        #Update variable
                        result=true

                        #set phase
                        phase="${PHASE_EXIT}"

                        break
                    fi
                done
                ;;    
            "${PHASE_EXIT}")
                break
                ;;
        esac
    done

    #Exit if 'result = false'
    if [[ ${result} == false ]]; then
        exit 99
    fi

    #Retrieve directories
    #Remark:
    #   'docker__LTPP3_ROOTFS__dir' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/
    parentDir_of_LTPP3_ROOTFS_dir=${docker__LTPP3_ROOTFS__dir%/*}    #move two directories up. This directory is the one-level higher than LTPP3_ROOTFS/

    #Get full-path
    #Remark:
    #   'docker__global__fpath' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__global__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${global_filename}
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

    docker__load_global_fpath_paths__sub

    docker__init_variables__sub

    docker__show_and_input_handler__sub
}



#---EXECUTE
main_sub
