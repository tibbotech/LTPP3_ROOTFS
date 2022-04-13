#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---VARIABLES
git__gitBranchList_arr=()
git__branchName_isNew=${DOCKER__FALSE}


#---FUNCTIONS
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

function checkIf_branch_alreadyExists__func() {
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

function checkIf_branch_isCheckedOut__func() {
    #Input args
    local branchName_input=${1}

    #Check if 'branchName_input' already exists
    local stdOutput=`git branch | grep -w "${branchName_input}" | grep "${DOCKER__BACKSLASH_ASTERISK}" 2>&1`
    if [[ ! -z ${stdOutput} ]]; then #contains data
        echo ${DOCKER__TRUE}
    else    #contains no data
        echo ${DOCKER__FALSE}
    fi
}

function get_git_branchList__func() {
    #Disable File-expansion
    #REMARK: this is a MUST because otherwise an Asterisk would be treated as a NON-string
    set -f

    #Get Git Branch-list and write directly to an array
    readarray -t git__gitBranchList_arr <<< "$(git branch | tr -d ' ')"

    #Enable File-expansion
    set +f
}

function show_git_branchList__func() {
    #Define local constants
    local CHECKED_OUT="checked out"

    #Define local variables
    local gitBranchList_arrItem=${DOCKER__EMPTYSTRING}
    local gitBranchList_arrItem_wo_asterisk=${DOCKER__EMPTYSTRING} 
    local asterisk_isFound=${DOCKER__FALSE}

    #Print Status Message
    echo -e "---:${DOCKER__FG_ORANGE}${PRINTF_LIST_LOCAL}${DOCKER__NOCOLOR}: git branch"

    #Show Array items
    for gitBranchList_arrItem in "${git__gitBranchList_arr[@]}"
    do 
        #Check if asterisk is present
        asterisk_isFound=`checkForMatch_subString_in_string__func "${gitBranchList_arrItem}" "${DOCKER__BACKSLASH_ASTERISK}"`
        if [[ ${asterisk_isFound} == ${DOCKER__TRUE} ]]; then
            gitBranchList_arrItem_wo_asterisk=`echo ${gitBranchList_arrItem} | cut -d"${DOCKER__BACKSLASH_ASTERISK}" -f2`

            echo -e "${DOCKER__FOURSPACES}${DOCKER__BACKSLASH_ASTERISK} ${DOCKER__FG_GREEN}${gitBranchList_arrItem_wo_asterisk}${DOCKER__NOCOLOR} (${CHECKED_OUT})"
        else
            echo -e "${DOCKER__FOURSPACES}${gitBranchList_arrItem}"
        fi
    done


    #Move-down and clean line
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
}



#---SUBROUTINES
git__environmental_variables__sub() {
	# git__current_dir=`pwd`
	git__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    git__current_dir=$(dirname ${git__current_script_fpath})	#/repo/LTPP3_ROOTFS/development_tools
	git__parent_dir=${git__current_dir%/*}    #gets one directory up (/repo/LTPP3_ROOTFS)
    if [[ -z ${git__parent_dir} ]]; then
        git__parent_dir="${DOCKER__SLASH}"
    fi
	git__current_folder=`basename ${git__current_dir}`

    git__development_tools_folder="development_tools"
    if [[ ${git__current_folder} != ${git__development_tools_folder} ]]; then
        git__my_LTPP3_ROOTFS_development_tools_dir=${git__current_dir}/${git__development_tools_folder}
    else
        git__my_LTPP3_ROOTFS_development_tools_dir=${git__current_dir}
    fi

    docker__global__filename="docker_global.sh"
    docker__global__fpath=${git__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global__filename}
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
    local MENUTITLE="Git ${DOCKER__FG_SOFTLIGHTRED}Delete${DOCKER__NOCOLOR} ${DOCKER__FG_LIGHTGREY}Local${DOCKER__NOCOLOR} Branch"

    #Define local message constants
    local PRINTF_COMPLETED="${DOCKER__FG_ORANGE}COMPLETED${DOCKER__NOCOLOR}"
    local PRINTF_LIST_LOCAL="${DOCKER__FG_ORANGE}LIST${DOCKER__NOCOLOR} (${DOCKER__FG_ORANGE}LOCAL${DOCKER__NOCOLOR})"
    local PRINTF_INPUT="${DOCKER__FG_ORANGE}INPUT${DOCKER__NOCOLOR}"
    local PRINTF_START="${DOCKER__FG_ORANGE}START${DOCKER__NOCOLOR}"
    local PRINTF_STATUS="${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}"
    local PRINTF_WARNING="${DOCKER__FG_BORDEAUX}WARNING${DOCKER__NOCOLOR}"

    local PRINTF_BRANCH_TOBE_DELETED="Branch ${DOCKER__FG_LIGHTGREY}to-be-deleted${DOCKER__NOCOLOR}"
    local PRINTF_ERROR="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}"

    #Define local question constants
    local QUESTION_PROCEED="Proceed (y/n/q)? "

    #Define local read-input constants
    local READ_YOURINPUT="${DOCKER__FG_LIGHTBLUE}Your input${DOCKER__NOCOLOR}: "

    local READERR_CURRENTLY_CHECKEDOUT_NOTALLOWED="${DOCKER__FG_LIGHTRED}currently checked out${DOCKER__NOCOLOR}; ${DOCKER__FG_LIGHTRED}not allowed${DOCKER__NOCOLOR}"
    local READERR_NOT_FOUND="${DOCKER__FG_LIGHTRED}not found${DOCKER__NOCOLOR}"

    #Define local variables
    local isCheckedOut=${DOCKER__FALSE}
    local myAnswer=${DOCKER__EMPTYSTRING}

    #Define local message variables
    local printf_msg=${DOCKER__EMPTYSTRING}



#Goto phase: START
GOTO__func START



@START:
    #Show menu-title
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${MENUTITLE}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${DOCKER__FOURSPACES}${DOCKER__QUIT_CTRL_C}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    GOTO__func PRECHECK    #goto next-phase



@PRECHECK:
    #Check if the current directory is a git-repository
    git__stdErr=`git branch 2>&1 > /dev/null`
    if [[ ! -z ${git__stdErr} ]]; then   #not a git-repository
        GOTO__func EXIT_PRECHECK_FAILED  #goto next-phase
    else    #is a git-repository
        GOTO__func BRANCH_LIST    #goto next-phase
    fi



@BRANCH_LIST:
    #Get Branch List
    get_git_branchList__func

    #Show Branch List
    show_git_branchList__func

    GOTO__func BRANCH_INPUT    #goto next-phase



@BRANCH_INPUT:
    #Input Branch name
    echo -e "---:${PRINTF_INPUT}: ${PRINTF_BRANCH_TOBE_DELETED}"
    
    while true
    do
        read -e -p "${DOCKER__FOURSPACES}${READ_YOURINPUT}" myBranchName
        if [[ ! -z ${myBranchName} ]]; then #contains data
            #Check if 'myBranchName' already exists
            myBranchName_isFound=`checkIf_branch_alreadyExists__func "${myBranchName}"`
            if [[ ${myBranchName_isFound} == ${DOCKER__TRUE} ]]; then
                #Check if asterisk is present
                isCheckedOut=`checkIf_branch_isCheckedOut__func "${myBranchName}"`
                if [[ ${isCheckedOut} == ${DOCKER__FALSE} ]]; then  #asterisk is NOT found
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                    break
                else    #asterisk is found
                    #Move-up 1 line
                    tput cuu1

                    #Show message with error
                    echo -e "${DOCKER__FOURSPACES}${READ_YOURINPUT}${myBranchName} (${READERR_CURRENTLY_CHECKEDOUT_NOTALLOWED})"
                fi
            else
                #Move-up 1 line
                tput cuu1

                #Show message with error
                echo -e "${DOCKER__FOURSPACES}${READ_YOURINPUT}${myBranchName} (${READERR_NOT_FOUND})"
            fi
        else
            tput cuu1   #move-up without cleaning
        fi
    done


    #Update message
    printf_msg="About to Delete (local) branch '${DOCKER__FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR}'"

    #Show question
    while true
    do
        echo -e "---:${PRINTF_WARNING}: ${printf_msg}"
        read -N1 -p "${DOCKER__FOURSPACES}${QUESTION_PROCEED}" myAnswer

        if [[ ! -z ${myAnswer} ]]; then #contains data
            #Handle 'myAnswer'
            if [[ ${myAnswer} =~ [y,n,q] ]]; then
                if [[ ${myAnswer} == "q" ]]; then
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                    GOTO__func EXIT_SUCCESSFUL  #goto next-phase
                elif [[ ${myAnswer} == "n" ]]; then
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

                    GOTO__func BRANCH_LIST    #goto next-phase
                else
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

                    GOTO__func DELETE_BRANCH    #goto next-phase
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
    echo -e "---:${PRINTF_START}: git branch -d ${DOCKER__FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR}"

    #Execute
    git branch -d ${myBranchName}

    #Check exit-code
    exitCode=$?
    if [[ ${exitCode} -eq 0 ]]; then
        echo -e "---:${PRINTF_COMPLETED}: git branch -d ${DOCKER__FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR}"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        
        #Goto next-phase
        GOTO__func GET_AND_SHOW_BRANCH_LIST
    else
        #Goto next-phase
        GOTO__func EXIT_FAILED
    fi



@GET_AND_SHOW_BRANCH_LIST:
    #Get Branch List
    get_git_branchList__func

    #Show Branch List
    show_git_branchList__func

    #Goto next-phase
    GOTO__func EXIT_SUCCESSFUL



@EXIT_SUCCESSFUL:
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    exit 0

@EXIT_PRECHECK_FAILED:
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${PRINTF_ERROR}: ${git__stdErr}"
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    
    exit 99

@EXIT_FAILED:
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${PRINTF_ERROR}: git branch -d ${DOCKER__FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR}"
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    exit 99
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
