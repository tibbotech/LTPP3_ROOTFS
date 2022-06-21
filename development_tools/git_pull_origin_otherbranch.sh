#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---VARIABLES
git__local_branchList_arr=()
git__stdErr=${DOCKER__EMPTYSTRING}


#---FUNCTIONS
function checkIf_remoteBranch_exists__func() {
    #Input args
    local branchName_input=${1}

    #Check if 'branchName_input' already exists
    local stdOutput=`${GIT__CMD_GIT_BRANCH} -r | grep -w "${branchName_input}" 2>&1`
    if [[ ! -z ${stdOutput} ]]; then #contains data
        echo ${DOCKER__TRUE}
    else    #contains no data
        echo ${DOCKER__FALSE}
    fi
}

function checkForMatch_subString_in_string__func() {
    #Input args
    local str_input=${1}
    local subStr_input=${2}

    #Check if 'subStr_input' is found in 'str_input'
    local stdOutput=`echo "${str_input}" | grep "${subStr_input}"`
    if [[ ! -z ${stdOutput} ]]; then
        echo ${DOCKER__TRUE}
    else
        echo ${DOCKER__FALSE}
    fi
}

function get_git_branchList__func() {
    #Disable File-expansion
    #REMARK: this is a MUST because otherwise an Asterisk would be treated as a NON-string
    set -f

    #Get Git Local Branch-list and write directly to an array
    # readarray -t git__local_branchList_arr <<< "$(${GIT__CMD_GIT_BRANCH} | tr -d ' ')"

    #Get Git Remote Branch-list and write directly to an array
    readarray -t git__remote_branchList_arr <<< "$(${GIT__CMD_GIT_BRANCH} -r | tr -d ' ')"

    #Enable File-expansion
    set +f
}

function show_git_branchList__func() {
    #Define local message contants
    local PRINTF_LIST_LOCAL="${DOCKER__FG_ORANGE}LIST${DOCKER__NOCOLOR} (LOCAL)"
    local PRINTF_LIST_REMOTE="${DOCKER__FG_ORANGE}LIST${DOCKER__NOCOLOR} (${DOCKER__FG_BORDEAUX}REMOTE${DOCKER__NOCOLOR})"

    #Define local constants
    local CHECKED_OUT="checked out"
    local SED_OLD_PATTERN="origin\/"
    local SED_NEW_PATTERN="(origin) "

    #Define local variables
    local gitBranchList_arrItem=${DOCKER__EMPTYSTRING}
    local gitBranchList_arrItem_wo_asterisk=${DOCKER__EMPTYSTRING} 
    local asterisk_isFound=${DOCKER__FALSE}

    # #Print Status Message
    # echo -e "---:${DOCKER__FG_ORANGE}${PRINTF_LIST_LOCAL}${DOCKER__NOCOLOR}: ${GIT__CMD_GIT_BRANCH}"

    # #Show Array items
    # for gitBranchList_arrItem in "${git__local_branchList_arr[@]}"
    # do 
    #     #Check if asterisk is present
    #     asterisk_isFound=`checkForMatch_subString_in_string__func "${gitBranchList_arrItem}" "${DOCKER__ESCAPED_ASTERISK}"`
    #     if [[ ${asterisk_isFound} == ${DOCKER__TRUE} ]]; then
    #         gitBranchList_arrItem_wo_asterisk=`echo ${gitBranchList_arrItem} | cut -d"${DOCKER__ESCAPED_ASTERISK}" -f2`

    #         echo -e "${DOCKER__FOURSPACES}${DOCKER__ESCAPED_ASTERISK} ${DOCKER__FG_GREEN}${gitBranchList_arrItem_wo_asterisk}${DOCKER__NOCOLOR} (${CHECKED_OUT})"
    #     else
    #         echo -e "${DOCKER__FOURSPACES}${gitBranchList_arrItem}"
    #     fi
    # done


    # #Move-down and clean line
    # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"


    #Re-using variable 'gitBranchList_arrItem'
    #Print Status Message
    echo -e "---:${DOCKER__FG_ORANGE}${PRINTF_LIST_REMOTE}${DOCKER__NOCOLOR}: ${GIT__CMD_GIT_BRANCH}"

    #Show Array items
    for gitBranchList_arrItem in "${git__remote_branchList_arr[@]}"
    do 
        echo -e "${DOCKER__FOURSPACES}${gitBranchList_arrItem}" | sed "s/${SED_OLD_PATTERN}/${SED_NEW_PATTERN}/g"
    done


    #Move-down and clean line
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
}



#---SUBROUTINES
git__environmental_variables__sub() {
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

git__load_source_files__sub() {
    source ${docker__global__fpath}
}

git__load_header__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${DOCKER__BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

git__git_pull__sub() {
    #Define local constants
    local MENUTITLE="Git ${DOCKER__BG_WHITE}${DOCKER__FG_LIGHTGREY}Pull${DOCKER__NOCOLOR} Origin Other-Branch"

    local PRINTF_PULL_FROM_WHICH_BRANCH="Pull from which branch?"

    #Define local Question constants
    local QUESTION_CHECKOUT_BRANCH="Check out this Branch (${DOCKER__Y_SLASH_N_SLASH_Q})? "
    local QUESTION_CREATE_AND_CHECKOUT_BRANCH="Create & Check out this Branch (${DOCKER__Y_SLASH_N_SLASH_Q})? "

    #Define local read-input constants
    local READ_YOURINPUT="${DOCKER__FG_LIGHTBLUE}Your choice${DOCKER__NOCOLOR}: "

    #Define local variables
    local isCheckedOut=${DOCKER__FALSE}
    local myAnswer=${DOCKER__EMPTYSTRING}

    #Define local message variables
    local printf_msg=${DOCKER__EMPTYSTRING}
    local question_msg=${DOCKER__EMPTYSTRING}

    #Define local read-input variables
    local myChosen_remoteBranch=${DOCKER__EMPTYSTRING}
    local myChosen_remoteBranch_isFound=${DOCKER__FALSE}



#Goto phase: START
goto__func START



@START:
    #Show menu-title
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${MENUTITLE}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${DOCKER__FOURSPACES}${DOCKER__QUIT_CTRL_C}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    goto__func PRECHECK    #goto next-phase



@PRECHECK:
    #Check if the current directory is a git-repository
    git__stdErr=`${GIT__CMD_GIT_BRANCH} 2>&1 > /dev/null`
    if [[ ! -z ${git__stdErr} ]]; then   #not a git-repository
        goto__func EXIT_PRECHECK_FAILED  #goto next-phase
    else    #is a git-repository
        goto__func BRANCH_LIST    #goto next-phase
    fi



@BRANCH_LIST:
    #Get Branch List
    get_git_branchList__func

    #Show Branch List
    show_git_branchList__func

    #Goto next-phase
    goto__func BRANCH_INPUT    



@BRANCH_INPUT:
    #Input Branch name
    echo -e "---:${DOCKER__QUESTION}: ${PRINTF_PULL_FROM_WHICH_BRANCH}"
    
    while true
    do
        read -e -p "${DOCKER__FOURSPACES}${READ_YOURINPUT}" myChosen_remoteBranch
        if [[ ! -z ${myChosen_remoteBranch} ]]; then #contains data
            #Check if 'myChosen_remoteBranch' already exists
            myChosen_remoteBranch_isFound=`checkIf_remoteBranch_exists__func "${myChosen_remoteBranch}"`
            if [[ ${myChosen_remoteBranch_isFound} == ${DOCKER__TRUE} ]]; then
                break
            else
                #Move-up twice and move-down once
                tput cuu1
                tput cuu1
                tput cud1

                #Show error message (but do NOT exit)
                echo -e "${DOCKER__FOURSPACES}${READ_YOURINPUT}${myChosen_remoteBranch} (${DOCKER__FG_LIGHTRED}not found${DOCKER__NOCOLOR})"
            fi
        else
            tput cuu1   #move-up without cleaning
        fi
    done

    #Goto next-phase
    goto__func CONFIRMATION_TO_CONTINUE



@CONFIRMATION_TO_CONTINUE:
    #Add an empty-line
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    #Show question
    while true
    do
        read -N1 -p "${DOCKER__FOURSPACES}${DOCKER__READDIALOG_DO_YOU_WISH_TO_CONTINUE_YN}" myAnswer

        if [[ ! -z ${myAnswer} ]]; then #contains data
            #Handle 'myAnswer'
            if [[ ${myAnswer} =~ [y,n,q] ]]; then
                if [[ ${myAnswer} == "q" ]]; then
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                    goto__func EXIT  #goto next-phase
                elif [[ ${myAnswer} == "n" ]]; then
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

                    goto__func BRANCH_LIST    #goto next-phase
                else
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

                    goto__func GIT_PULL
                fi

                break
            else
                if [[ ${myAnswer} != "${DOCKER__ENTER}" ]]; then
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
                else
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
                fi
            fi
        fi
    done



@GIT_PULL:
    echo -e "---:${DOCKER__START}: git pull origin ${DOCKER__FG_LIGHTGREY}${myChosen_remoteBranch}${DOCKER__NOCOLOR}"

    # #Git fetch
    # git fetch origin ${myChosen_remoteBranch}

    # #Git Merge
    # git merge ${myChosen_remoteBranch}

    git pull origin ${myChosen_remoteBranch}

    echo -e "---:${DOCKER__COMPLETED}: git pull origin ${DOCKER__FG_LIGHTGREY}${myChosen_remoteBranch}${DOCKER__NOCOLOR}"

    #Print empty line
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    #Goto next-phase
    goto__func GET_AND_SHOW_BRANCH_LIST



@GET_AND_SHOW_BRANCH_LIST:
    #Get Branch List
    get_git_branchList__func

    #Show Branch List
    show_git_branchList__func

    #Goto next-phase
    goto__func EXIT



@EXIT:
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    exit 0

@EXIT_PRECHECK_FAILED:
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
    echo -e "${DOCKER__ERROR}: ${git__stdErr}"
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    
    exit 99

@EXIT_FAILED:
    if [[ ${myChosen_remoteBranch_isFound} == ${DOCKER__TRUE} ]]; then 
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "${DOCKER__ERROR}: git checkout ${DOCKER__FG_LIGHTGREY}${myChosen_remoteBranch}${DOCKER__NOCOLOR} (${DOCKER__STATUS_FAILED})"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        
        exit 99
    else
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "${DOCKER__ERROR}: git checkout -b ${DOCKER__FG_LIGHTGREY}${myChosen_remoteBranch}${DOCKER__NOCOLOR} (${DOCKER__STATUS_FAILED})"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        
        exit 99
    fi
}



#---MAIN SUBROUTINE
main_sub() {
    git__environmental_variables__sub

    git__load_source_files__sub

    git__load_header__sub

    git__git_pull__sub
}



#---EXECUTE
main_sub
