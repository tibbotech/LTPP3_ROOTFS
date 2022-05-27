#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts

#---FUNCTIONS
function docker__checkIf_branch_alreadyExists__func() {
    #Input args
    local branchName_input=${1}

    #Check if 'branchName_input' already exists
    local stdOutput=`git branch | grep -w "${branchName_input}" 2>&1`
    if [[ ! -z ${stdOutput} ]]; then #contains data
        echo ${DOCKER__TRUE}
    else    #contains no data
        echo ${DOCKER__FALSE}
    fi
}

function docker__checkIf_branch_isCheckedOut__func() {
    #Input args
    local branchName_input=${1}

    #Check if 'branchName_input' already exists
    local stdOutput=`git branch | grep -w "${branchName_input}" | grep "${DOCKER__ESCAPED_ASTERISK}" 2>&1`
    if [[ ! -z ${stdOutput} ]]; then #contains data
        echo ${DOCKER__TRUE}
    else    #contains no data
        echo ${DOCKER__FALSE}
    fi
}



#---SUBROUTINES
docker__environmental_variables__sub() {
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
    source ${docker__global__fpath}
}

docker__load_header__sub() {
    #Input args
    local prepend_numOfLines__input=${1}

    #Print
    show_header__func "${DOCKER__TITLE}" "${DOCKER__TABLEWIDTH}" "${DOCKER__BG_ORANGE}" "${prepend_numOfLines__input}" "${DOCKER__NUMOFLINES_0}"
}

docker__load_constants__sub() {
    DOCKER__MENUTITLE="Git ${DOCKER__FG_SOFTLIGHTRED}Delete${DOCKER__NOCOLOR} ${DOCKER__FG_LIGHTGREY}Local${DOCKER__NOCOLOR} Branch"
    DOCKER__READDIALOG="Input: "
}

docker__init_variables__sub() {
    docker__branch_chosen=${DOCKER__EMPTYSTRING}
    docker__git_cmd=${DOCKER__EMPTYSTRING}
    docker__stdErr=${DOCKER__EMPTYSTRING}

    docker__tibboHeader_prepend_numOfLines=0

    docker__branch_chosen_isFound=false
    docker__onEnter_breakLoop=false
    docker__showTable=true
}

docker__delete_local_branch_handler__sub() {
    #Define local message constants
    local PRINTF_COMPLETED="${DOCKER__FG_ORANGE}COMPLETED${DOCKER__NOCOLOR}"
    local PRINTF_LIST_LOCAL="${DOCKER__FG_ORANGE}LIST${DOCKER__NOCOLOR} (${DOCKER__FG_ORANGE}LOCAL${DOCKER__NOCOLOR})"
    local PRINTF_INPUT="${DOCKER__FG_ORANGE}INPUT${DOCKER__NOCOLOR}"
    local PRINTF_START="${DOCKER__FG_ORANGE}START${DOCKER__NOCOLOR}"
    local PRINTF_STATUS="${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}"
    local PRINTF_WARNING="${DOCKER__FG_BORDEAUX}WARNING${DOCKER__NOCOLOR}"

    local PRINTF_BRANCH_TOBE_DELETED="Branch ${DOCKER__FG_LIGHTGREY}to-be-deleted${DOCKER__NOCOLOR}"
    local PRINTF_ERROR="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}"

    local PRINTF_NO_ACTION_TAKEN="No action taken"

    #Define local question constants
    local QUESTION_PROCEED="Delete selected branch (y/n/q)? "

    #Define local read-input constants
    local READ_YOURINPUT="${DOCKER__FG_LIGHTBLUE}Your input${DOCKER__NOCOLOR}: "

    local READERR_CURRENTLY_CHECKEDOUT_NOTALLOWED="${DOCKER__FG_LIGHTRED}currently checked out${DOCKER__NOCOLOR}; ${DOCKER__FG_LIGHTRED}not allowed${DOCKER__NOCOLOR}"
    local READERR_NOT_FOUND="${DOCKER__FG_LIGHTRED}not found${DOCKER__NOCOLOR}"

    #Define local variables
    local isCheckedOut=${DOCKER__FALSE}
    local myAnswer=${DOCKER__EMPTYSTRING}

    #Define local message variables
    local printf_msg=${DOCKER__EMPTYSTRING}
    local question_msg=${DOCKER__EMPTYSTRING}



#Goto phase: START
goto__func START



@START:
    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

    goto__func PRECHECK



@PRECHECK:
    #Check if the current directory is a git-repository
    git__stdErr=`git branch 2>&1 > /dev/null`
    if [[ ! -z ${git__stdErr} ]]; then   #not a git-repository
        goto__func EXIT_PRECHECK_FAILED  #goto next-phase
    else    #is a git-repository
        goto__func BRANCH_SHOW_AND_INPUT
    fi



@BRANCH_SHOW_AND_INPUT:
    #Output: docker__branch_chosen
    docker__show_and_input_git_branch__sub

    #Move-down and clean
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    #Check if 'docker__branch_chosen' already exists
    docker__branch_chosen_isFound=`docker__checkIf_branch_alreadyExists__func "${docker__branch_chosen}"`
    if [[ ${docker__branch_chosen_isFound} == ${DOCKER__TRUE} ]]; then
        #Check if asterisk is present
        isCheckedOut=`docker__checkIf_branch_isCheckedOut__func "${docker__branch_chosen}"`
        if [[ ${isCheckedOut} == ${DOCKER__FALSE} ]]; then  #asterisk is NOT found
            #Update message
            printf_msg="Branch '${DOCKER__FG_LIGHTGREY}${docker__branch_chosen}${DOCKER__NOCOLOR}' exists"

            #Print message
            echo -e "---:${PRINTF_STATUS}: ${printf_msg}"

            #Update variable
            question_msg=${QUESTION_PROCEED}
        else    #asterisk is found            
            #Update message
            printf_msg="Branch '${DOCKER__FG_LIGHTGREY}${docker__branch_chosen}${DOCKER__NOCOLOR}' is checked out"

            #Print message
            echo -e "---:${PRINTF_STATUS}: ${printf_msg}"

            #Print message
            echo -e "---:${PRINTF_STATUS}: ${PRINTF_NO_ACTION_TAKEN}"

            #Add an empty-line
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

            #Goto next-phase
            goto__func BRANCH_SHOW_AND_INPUT
        fi
    else
        #Update message
        printf_msg="Branch '${DOCKER__FG_LIGHTGREY}${docker__branch_chosen}${DOCKER__NOCOLOR}' does NOT exist"

        #Print message
        echo -e "---:${PRINTF_STATUS}: ${printf_msg}"

        #Print message
        echo -e "---:${PRINTF_STATUS}: ${PRINTF_NO_ACTION_TAKEN}"

        #Add an empty-line
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

        #Goto next-phase
        goto__func BRANCH_SHOW_AND_INPUT
    fi

    #Move-down and clean
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    #Show question
    while true
    do
        read -N1 -p "${question_msg}" myAnswer

        if [[ ! -z ${myAnswer} ]]; then #contains data
            #Handle 'myAnswer'
            if [[ ${myAnswer} =~ [y,n,q] ]]; then
                if [[ ${myAnswer} == "q" ]]; then
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                    goto__func EXIT_SUCCESSFUL  #goto next-phase
                elif [[ ${myAnswer} == "n" ]]; then
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_3}"

                    goto__func BRANCH_SHOW_AND_INPUT    #goto next-phase
                else
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

                    goto__func DELETE_BRANCH    #goto next-phase
                fi

                break
            else
                if [[ ${myAnswer} != "${DOCKER__ENTER}" ]]; then
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_3}"
                else
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_3}"
                fi
            fi
        fi
    done




@DELETE_BRANCH:
    echo -e "---:${PRINTF_START}: git branch -d ${DOCKER__FG_LIGHTGREY}${docker__branch_chosen}${DOCKER__NOCOLOR}"

    #Execute
    git branch -d ${docker__branch_chosen}

    #Check exit-code
    exitCode=$?
    if [[ ${exitCode} -eq 0 ]]; then
        echo -e "---:${PRINTF_COMPLETED}: git branch -d ${DOCKER__FG_LIGHTGREY}${docker__branch_chosen}${DOCKER__NOCOLOR}"
        
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

        goto__func BRANCH_SHOW_AND_INPUT
    else
        #Goto next-phase
        goto__func EXIT_FAILED
    fi



@EXIT_SUCCESSFUL:
    exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_2}"



@EXIT_PRECHECK_FAILED:
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${PRINTF_ERROR}: ${git__stdErr}"
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_0}"
    
    exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_2}"



@EXIT_FAILED:
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${PRINTF_ERROR}: git branch -d ${DOCKER__FG_LIGHTGREY}${docker__branch_chosen}${DOCKER__NOCOLOR}"
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

    goto__func BRANCH_SHOW_AND_INPUT
}



docker__show_and_input_git_branch__sub() {
    #Show Tibbo-header
    docker__load_header__sub "${docker__tibboHeader_prepend_numOfLines}"

    #Define command
    docker__git_cmd="git branch"

    #Show file-content
    ${git__git_readInput_w_autocomplete__fpath} "${DOCKER__MENUTITLE}" \
            "${DOCKER__READDIALOG}" \
            "${DOCKER__ECHOMSG_NORESULTS_FOUND}" \
            "${docker__git_cmd}" \
            "${docker__showTable}" \
            "${docker__onEnter_breakLoop}"

    #Get the exitcode just in case:
    #   1. Ctrl-C was pressed in script 'docker__readInput_w_autocomplete__fpath'.
    #   2. An error occured in script 'docker__readInput_w_autocomplete__fpath',...
    #      ...and exit-code = 99 came from function...
    #      ...'show_msg_w_menuTitle_w_pressAnyKey_w_ctrlC_func' (in script: docker__global.sh).
    docker__exitCode=$?
    if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
        exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
    else
        #Retrieve the selected container-ID from file
        docker__branch_chosen=`get_output_from_file__func \
                        "${git__git_readInput_w_autocomplete_out__fpath}" \
                        "${DOCKER__LINENUM_1}"`
    fi

    #Set 'docker__tibboHeader_prepend_numOfLines' to '0'
    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_0}
}



#---MAIN SUBROUTINE
main_sub() {
    docker__environmental_variables__sub

    docker__load_source_files__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__delete_local_branch_handler__sub
}



#---EXECUTE
main_sub
