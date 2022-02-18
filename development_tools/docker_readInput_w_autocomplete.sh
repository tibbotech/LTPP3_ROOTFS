#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---INPUT ARGS
menuTitle__input=${1}
readMsg__input=${2}
readMsgRemarks__input=${3}
errorMsg__input=${4}
errorMsg2__input=${5}
dockerCmd__input=${6}
colNo__input=${7}
flagCleanLines__input=${8}



#---COLOR CONSTANTS
DOCKER__NOCOLOR=$'\e[0;0m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
# DOCKER__FG_PURPLERED=$'\e[30;38;5;198m'
# DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
# DOCKER__IMAGEID_FG_BORDEAUX=$'\e[30;38;5;198m'
# DOCKER__REPOSITORY_FG_PURPLE=$'\e[30;38;5;93m'
# DOCKER__NEW_REPOSITORY_FG_BRIGHTLIGHTPURPLE=$'\e[30;38;5;147m'
# DOCKER__CONTAINER_FG_BRIGHTPRUPLE=$'\e[30;38;5;141m'
DOCKER__INSIDE_FG_LIGHTGREY=$'\e[30;38;5;246m'

#---CHARACTER CHONSTANTS
DOCKER__DASH="-"
DOCKER__EMPTYSTRING=""

DOCKER__BACKSPACE=$'\b'
DOCKER__DEL=$'\x7e'
DOCKER__ENTER=$'\x0a'
DOCKER__ESCAPEKEY=$'\x1b'   #note: this escape key is ^[
DOCKER__TAB=$'\t'

DOCKER__ONESPACE=" "

#---NUMERIC CONSTANTS
DOCKER__NINE=9
DOCKER__TABLEWIDTH=70

DOCKER__NUMOFLINES_1=1
DOCKER__NUMOFLINES_2=2
DOCKER__NUMOFLINES_3=3
DOCKER__NUMOFLINES_4=4
DOCKER__NUMOFLINES_5=5
DOCKER__NUMOFLINES_6=6
DOCKER__NUMOFLINES_7=7
DOCKER__NUMOFLINES_8=8
DOCKER__NUMOFLINES_9=9



#---MENU CONSTANTS
DOCKER__ARROWUP="arrowUp"
DOCKER__ARROWDOWN="arrowDown"
DOCKER__CTRL_C_QUIT="${DOCKER__FOURSPACES}Quit (Ctrl+C)"



#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C__sub INT



#---FUNCTIONS
function press_any_key__func() {
	#Define constants
	local ANYKEY_TIMEOUT=10

	#Initialize variables
	local keypressed=""
	local tcounter=0

	#Show Press Any Key message with count-down
	echo -e "\r"
	while [[ ${tcounter} -le ${ANYKEY_TIMEOUT} ]];
	do
		delta_tcounter=$(( ${ANYKEY_TIMEOUT} - ${tcounter} ))

		echo -e "\rPress (a)bort or any key to continue... (${delta_tcounter}) \c"
		read -N 1 -t 1 -s -r keypressed

		if [[ ! -z "${keypressed}" ]]; then
			if [[ "${keypressed}" == "a" ]] || [[ "${keypressed}" == "A" ]]; then
				exit
			else
				break
			fi
		fi
		
		tcounter=$((tcounter+1))
	done
	echo -e "\r"
}

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
    #Input args
    #Remark:
    #1. non-array parameter(s) precede(s) array-parameter
    #2. For each non-array parameter, the 'shift' operator has to be added an array-parameter
    local keyWord=${1}
    shift
    local dataArr=("$@")


    #Define and update keyWord
    local dataArr_1stItem_len=0
    local keyWord_bck=${DOCKER__EMPTYSTRING}
    local keyWord_len=0
    local numOfMatch=0
    local numOfMatch_init=0
    local ret=${DOCKER__EMPTYSTRING}

    #initialization
    dataArr_1stItem_len=${#dataArr[0]}
    numOfMatch_init=`printf '%s\n' "${dataArr[@]}" | grep "^${keyWord}" | wc -l`
    numOfMatch=${numOfMatch_init}

    #Find the closest match
    while true
    do
        if [[ ${numOfMatch_init} -eq 0 ]]; then  #no match
            #Exit loop
            break
        elif [[ ${numOfMatch_init} -eq 1 ]]; then  #only 1 match
            #Update variable
            ret=`printf '%s\n' "${dataArr[@]}" | grep "^${keyWord}"`

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
            keyWord=${dataArr[0]:0:keyWord_len}

            #Check if the total length of the 1st array-element has been reached
            if [[ ${keyWord_bck_len} -eq ${dataArr_1stItem_len} ]]; then
                ret=${keyWord_bck}

                break
            fi

            #Get the new number of matches
            numOfMatch=`printf '%s\n' "${dataArr[@]}" | grep "^${keyWord}" | wc -l`

            #Compare the new 'numOfMatch' with the initial 'numOfMatch_init'
            if [[ ${numOfMatch} -ne ${numOfMatch_init} ]]; then
                ret=${keyWord_bck}

                break
            fi
        fi
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

function duplicate_char__func()
{
    #Input args
    local char_input=${1}
    local numOf_times=${2}

    #Duplicate 'char_input'
    local char_duplicated=`printf '%*s' "${numOf_times}" | tr ' ' "${char_input}"`

    #Print text including Leading Empty Spaces
    echo -e "${char_duplicated}"
}

function load_containerID_into_array__func() {
    #Input args
    local dockerCmd__input=${1}
    local colNo__input=${2}

    #Define local variables
    local cachedInputArr_string=${DOCKER__EMPTYSTRING}
    local cachedInputArr_raw_string=${DOCKER__EMPTYSTRING}

    #These are global variables
    cachedInput_Arr=()
    cachedInput_ArrLen=0
    cachedInput_ArrIndex=0
    cachedInput_ArrIndex_max=0

    #Get all values stored under the specified column 'colNo__input' (excluding header)
    cachedInputArr_raw_string=`${dockerCmd__input} | awk -vcolNo=${colNo__input} '{print $colNo}' | tail -n+2`

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

function moveUp_and_cleanLines__func() {
    #Input args
    local numOfLines=${1}

    #Clear lines
    local count=1
    while [[ ${count} -le ${numOfLines} ]]
    do
        tput cuu1	#move UP with 1 line
        tput el		#clear until the END of line

        count=$((count+1))  #increment by 1
    done
}

function moveDown_then_moveUp_and_clean__func() {
    #Input args
    local numOfLines=${1}

    #Move-down 1 line
    tput cud1

    #Move-up and clean a specified number of times
    moveUp_and_cleanLines__func "${numOfLines}"
}

function moveUp_then_moveRight__func() {
    #Input args
    local mainMsg=${1}
    local keyInput=${2}

    #Get lengths
    local mainMsg_wo_regEx=$(echo -e "$mainMsg" | sed "s/$(echo -e "\e")[^m]*m//g")
    local mainMsg_wo_regEx_len=${#mainMsg_wo_regEx}
    local keyInput_wo_regEx=$(echo -e "$keyInput" | sed "s/$(echo -e "\e")[^m]*m//g")
    local keyInput_wo_regEx_len=${#keyInput_wo_regEx}
    local total_len=$((mainMsg_wo_regEx_len + keyInput_wo_regEx_len + 1))

    #Move cursor up by 1 line
    tput cuu1
    #Move cursor to right
    tput cuf ${total_len}
}


function show_errMsg_with_menuTitle__func() {
    #Input args
    local menuTitle=${1}
    local errMsg=${2}

    #Show error-message
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${menuTitle}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    
    echo -e "\r"
    show_centered_string__func "${errMsg}" "${DOCKER__TABLEWIDTH}"
    echo -e "\r"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "\r"

    press_any_key__func

    CTRL_C__sub
}

function show_errMsg_without_menuTitle__func() {
    #Input args
    local errMsg=${1}

    echo -e "\r"
    echo -e "\r"
    echo -e "${errMsg}"

    press_any_key__func
}

function show_list_with_menuTitle__func() {
    #Input args
    local menuTitle=${1}
    local dockerCmd=${2}

    #Show list
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${menuTitle}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    
    if [[ ${dockerCmd} == ${docker__ps_a_cmd} ]]; then
        ${docker__containerlist_tableinfo_fpath}
    else
        ${docker__repolist_tableinfo_fpath}
    fi

    echo -e "\r"

    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${DOCKER__CTRL_C_QUIT}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
}

function show_centered_string__func()
{
    #Input args
    local str_input=${1}
    local maxStrLen_input=${2}

    #Get string 'without visiable' color characters
    local strInput_wo_colorChars=`echo "${str_input}" | sed "s,\x1B\[[0-9;]*m,,g"`

    #Get string length
    local strInput_wo_colorChars_len=${#strInput_wo_colorChars}

    #Calculated the number of spaces to-be-added
    local numOf_spaces=$(( (maxStrLen_input-strInput_wo_colorChars_len)/2 ))

    #Create a string containing only EMPTY SPACES
    local emptySpaces_string=`duplicate_char__func "${DOCKER__ONESPACE}" "${numOf_spaces}" `

    #Print text including Leading Empty Spaces
    echo -e "${emptySpaces_string}${str_input}"
}

function readInput_w_autocomplete__func() {
    #Input args
    local menuTitle__input=${1}
    local readMsg__input=${2}
    local readMsgRemarks__input=${3}
    local errorMsg__input=${4}
    local errorMsg2__input=${5}
    local dockerCmd__input=${6}
    local colNo__input=${7}
    local flagCleanLines__input=${8}

    #Define variables
    local keyInput=${DOCKER__EMPTYSTRING}
    local ret=${DOCKER__EMPTYSTRING}
    local stdOutput=${DOCKER__EMPTYSTRING}

    #Define messages
    local errMsg=${DOCKER__EMPTYSTRING}
 
    #Remove file
    if [[ -f ${docker__readInput_w_autocomplete_out__fpath} ]]; then
        rm ${docker__readInput_w_autocomplete_out__fpath}
    fi

#---Load ContainerIDs into Array 'cachedInput_Arr'
    load_containerID_into_array__func "${dockerCmd__input}" "${colNo__input}"

#---Show Docker Container's List
    #Calculate number of lines to be cleaned
    local remarks_numOfLines=`echo -e ${readMsgRemarks__input} | wc -l`

    local numOfLines1=$((DOCKER__NUMOFLINES_1 + remarks_numOfLines))
    local numOfLines2=$((DOCKER__NUMOFLINES_5 + remarks_numOfLines))
    local numOfLines3=$((DOCKER__NUMOFLINES_6 + remarks_numOfLines))

    #Get number of containers
    if [[ ${flagCleanLines__input} == false ]]; then
        local numOf_containers=`${dockerCmd__input} | head -n -1 | wc -l`
        if [[ ${numOf_containers} -eq 0 ]]; then
            show_errMsg_with_menuTitle__func "${menuTitle__input}" "${errorMsg__input}"
        else
            show_list_with_menuTitle__func "${menuTitle__input}" "${dockerCmd__input}"
        fi
    else
        moveDown_then_moveUp_and_clean__func "${numOfLines3}"
    fi

    while true
    do
        #Check if there is only 1 containerID.
        #Remark:
        #   If that is the case, then set 'ret' to that value.
        if [[ ${numOf_containers} -eq 1 ]]; then
            ret=${cachedInput_Arr[0]}
        fi

        #Show current input
        echo -e "${readMsgRemarks__input}"
        echo -e "${readMsg__input} ${ret}"
        #Move cursor up
        moveUp_then_moveRight__func "${readMsg__input}" "${ret}"
        #Execute read-input
        read -N1 -rs -p "" keyInput

        if [[ ${keyInput} == ${DOCKER__ENTER} ]]; then
            if [[ ! -z ${ret} ]]; then    #input is NOT an EMPTY STRING
                #Only do the following check if 'errorMsg2__input is NOT an Empty String'
                if [[ ! -z ${errorMsg2__input} ]]; then
                    #Check if 'ret' is found in whether the image's or container's list
                    stdOutput=`${dockerCmd__input} | awk -vcolNo=${colNo__input} '{print $colNo}' | grep -w ${ret}`
                    if [[ ! -z ${stdOutput} ]]; then    #match was found
                        break
                    else    #NO match was found
                        #Update error messagae
                        errMsg="${errorMsg2__input}'${DOCKER__INSIDE_FG_LIGHTGREY}${ret}${DOCKER__NOCOLOR}'"

                        #Show error message
                        show_errMsg_without_menuTitle__func "${errMsg}"

                        #Reset return value
                        ret=${DOCKER__EMPTYSTRING}

                        #Move Up and Clean
                        moveUp_and_cleanLines__func "${numOfLines2}"
                    fi
                else
                    break
                fi
            else
                #Reset variable
                ret=${DOCKER__EMPTYSTRING}

                #First Move-down, then Move-up, after that clean line
                moveDown_then_moveUp_and_clean__func "${numOfLines1}"
            fi
        elif [[ ${keyInput} == ${DOCKER__BACKSPACE} ]]; then
            #Update variable
            ret=`backspace_handler__func "${ret}"`

            #First Move-down, then Move-up, after that clean line
            moveDown_then_moveUp_and_clean__func "${numOfLines1}"
        elif [[ ${keyInput} == ${DOCKER__ESCAPEKEY} ]]; then
            #Handle Arrowkey-press
            arrowKeys_upDown_handler__func

            #Update variable
            ret=${cachedInput_Arr[cachedInput_ArrIndex]}

            #First Move-down, then Move-up, after that clean line
            moveDown_then_moveUp_and_clean__func "${numOfLines1}"
        elif [[ ${keyInput} == ${DOCKER__ONESPACE} ]]; then
            #First Move-down, then Move-up, after that clean line
            moveDown_then_moveUp_and_clean__func "${numOfLines1}"
        elif [[ ${keyInput} == ${DOCKER__TAB} ]]; then
            #This subroutine will also update 'ret'
            ret=`autocomplete__func "${ret}" "${cachedInput_Arr[@]}"`

            #First Move-down, then Move-up, after that clean line
            moveDown_then_moveUp_and_clean__func "${numOfLines1}"
        else
            if [[ ! -z ${keyInput} ]]; then
                ret="${ret}${keyInput}"
            fi

            #First Move-down, then Move-up, after that clean line
            moveDown_then_moveUp_and_clean__func "${numOfLines1}"
        fi
    done

    #Write to file
    echo ${ret} > ${docker__readInput_w_autocomplete_out__fpath}
}



#---SUBROUTINES
CTRL_C__sub() {
    echo -e "\r"
    echo -e "\r"
    # echo -e "Exiting now..."
    # echo -e "\r"
    # echo -e "\r"
    
    exit
}

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

    docker__containerlist_tableinfo_filename="docker_containerlist_tableinfo.sh"
    docker__containerlist_tableinfo_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__containerlist_tableinfo_filename}
	docker__repolist_tableinfo_filename="docker_repolist_tableinfo.sh"
	docker__repolist_tableinfo_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__repolist_tableinfo_filename}

    docker__tmp_dir=/tmp
    docker__readInput_w_autocomplete_out__filename="docker__readInput_w_autocomplete.out"
    docker__readInput_w_autocomplete_out__fpath=${docker__tmp_dir}/${docker__readInput_w_autocomplete_out__filename}
}

docker__load_variables__sub() {
    docker__image_ls_cmd="docker image ls"
    docker__ps_a_cmd="docker ps -a"
    docker__1stTimeUse=true
}

docker__readInput_handler__sub() {
    #Get read-input value
    readInput_w_autocomplete__func "${menuTitle__input}" \
                        "${readMsg__input}" \
                        "${readMsgRemarks__input}" \
                        "${errorMsg__input}" \
                        "${errorMsg2__input}" \
                        "${dockerCmd__input}" \
                        "${colNo__input}" \
                        "${flagCleanLines__input}"

    #Print empty lines
    echo -e "\r"
    echo -e "\r"
}



#---MAIN SUBROUTINE
main_sub() {
    docker__environmental_variables__sub

    docker__load_variables__sub

    docker__readInput_handler__sub
}



#---EXECUTE
main_sub

