#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---VARIABLES
docker__branchName_isNew=${DOCKER__FALSE}
docker__gitBranchList_arr=()
docker__stdErr=${DOCKER__EMPTYSTRING}


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

    docker__global_functions_filename="docker_global_functions.sh"
    docker__global_functions_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global_functions_filename}
}

docker__load_source_files__sub() {
    source ${docker__global_functions_fpath}
}

docker__load_header__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${DOCKER__BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__git_pull__sub() {
    #Define local constants
    local MENUTITLE="Git ${DOCKER__FG_LIGHTGREEN}Create${DOCKER__NOCOLOR} and/or ${DOCKER__FG_LIGHTSOFTYELLOW}Checkout${DOCKER__NOCOLOR} ${DOCKER__FG_LIGHTGREY}Local${DOCKER__NOCOLOR} Branch"

    #Define local message constants
    local PRINTF_COMPLETED="${DOCKER__FG_ORANGE}COMPLETED${DOCKER__NOCOLOR}"
    local PRINTF_LIST_LOCAL="${DOCKER__FG_ORANGE}LIST${DOCKER__NOCOLOR} (${DOCKER__FG_ORANGE}LOCAL${DOCKER__NOCOLOR})"
    local PRINTF_INPUT="${DOCKER__FG_ORANGE}INPUT${DOCKER__NOCOLOR}"
    local PRINTF_START="${DOCKER__FG_ORANGE}START${DOCKER__NOCOLOR}"
    local PRINTF_STATUS="${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}"
    
    local PRINTF_BRANCHNAME_NEW_EXISTING="Branch (${DOCKER__FG_LIGHTGREY}new${DOCKER__NOCOLOR}/${DOCKER__FG_LIGHTGREY}existing${DOCKER__NOCOLOR})"
    local PRINTF_ERROR="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}"
    local PRINTF_NO_ACTION_REQUIRED="No Action Required."

    #Define local Question constants
    local QUESTION_CHECKOUT_BRANCH="Check out this Branch (y/n/q)? "
    local QUESTION_CREATE_AND_CHECKOUT_BRANCH="Create & Check out this Branch (y/n/q)? "

    #Define local read-input constants
    local READ_YOURINPUT="${DOCKER__FG_LIGHTBLUE}Your input${DOCKER__NOCOLOR}: "

    #Define local variables
    local isCheckedOut=${DOCKER__FALSE}
    local myAnswer=${DOCKER__EMPTYSTRING}

    #Define local message variables
    local printf_msg=${DOCKER__EMPTYSTRING}
    local question_msg=${DOCKER__EMPTYSTRING}

    #Define local read-input variables
    local myBranchName=${DOCKER__EMPTYSTRING}
    local myBranchName_isFound=${DOCKER__FALSE}



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
    docker__stdErr=`git branch 2>&1 > /dev/null`
    if [[ ! -z ${docker__stdErr} ]]; then   #not a git-repository
        GOTO__func EXIT_PRECHECK_FAILED  #goto next-phase
    else    #is a git-repository
        GOTO__func BRANCH_LIST    #goto next-phase
    fi



@BRANCH_LIST:
    #Get Branch List
    docker__get_git_branchList__func

    #Show Branch List
    docker__show_git_branchList__func

    GOTO__func BRANCH_INPUT    #goto next-phase



@BRANCH_INPUT:
    #Input Branch name
    echo -e "---:${PRINTF_INPUT}: ${PRINTF_BRANCHNAME_NEW_EXISTING}"
    
    while true
    do
        read -e -p "${DOCKER__FOURSPACES}${READ_YOURINPUT}" myBranchName
        if [[ ! -z ${myBranchName} ]]; then #contains data
            break
        else
            tput cuu1   #move-up without cleaning
        fi
    done

    #Check if 'myBranchName' already exists
    myBranchName_isFound=`docker__checkIf_branch_alreadyExists__func "${myBranchName}"`
    if [[ ${myBranchName_isFound} == ${DOCKER__TRUE} ]]; then
        #Check if asterisk is present
        isCheckedOut=`docker__checkIf_branch_isCheckedOut__func "${myBranchName}"`
        if [[ ${isCheckedOut} == ${DOCKER__FALSE} ]]; then  #asterisk is NOT found
            #Update message
            printf_msg="Branch '${DOCKER__FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR}' already Exist..."

            #Update variable
            question_msg=${QUESTION_CHECKOUT_BRANCH}
        else    #asterisk is found
            #Add an empty-line
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
            
            #Update message
            printf_msg="Branch '${DOCKER__FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR}' already Exist and Checked Out"

            #Print message
            echo -e "---:${PRINTF_STATUS}: ${printf_msg}"

            #Print message
            echo -e "---:${PRINTF_STATUS}: ${PRINTF_NO_ACTION_REQUIRED}"

            #Goto next-phase
            GOTO__func EXIT_SUCCESSFUL
        fi
    else
        #Update message
        printf_msg="Branch '${DOCKER__FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR}' is New..."

        #Update variable
        question_msg=${QUESTION_CREATE_AND_CHECKOUT_BRANCH}
    fi

    #Add an empty-line
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    #Show question
    while true
    do
        echo -e "---:${PRINTF_STATUS}: ${printf_msg}"
        read -N1 -p "${DOCKER__FOURSPACES}${question_msg}" myAnswer

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

                    if [[ ${myBranchName_isFound} == ${DOCKER__TRUE} ]]; then
                        GOTO__func CHECKOUT_BRANCH    #goto next-phase
                    else
                        GOTO__func CREATE_AND_CHECKOUT_BRANCH    #goto next-phase
                    fi
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



@CHECKOUT_BRANCH:
    echo -e "---:${PRINTF_START}: git checkout ${DOCKER__FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR}"

    #Execute
    git checkout ${myBranchName}

    #Check exit-code
    exitCode=$?
    if [[ ${exitCode} -eq 0 ]]; then
        echo -e "---:${PRINTF_COMPLETED}: git checkout ${DOCKER__FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR}"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        
        #Goto next-phase
        GOTO__func GET_AND_SHOW_BRANCH_LIST
    else
        #Goto next-phase
        GOTO__func EXIT_FAILED
    fi



@CREATE_AND_CHECKOUT_BRANCH:
    echo -e "---:${PRINTF_START}: git checkout -b ${DOCKER__FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR}"

    #Execute
    git checkout -b ${myBranchName}

    #Check exit-code
    exitCode=$?
    if [[ ${exitCode} -eq 0 ]]; then
        echo -e "---:${PRINTF_COMPLETED}: git checkout -b ${DOCKER__FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR}"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        
        #Goto next-phase
        GOTO__func GET_AND_SHOW_BRANCH_LIST
    else
        #Goto next-phase
        GOTO__func EXIT_FAILED
    fi



@GET_AND_SHOW_BRANCH_LIST:
    #Get Branch List
    docker__get_git_branchList__func

    #Show Branch List
    docker__show_git_branchList__func

    #Goto next-phase
    GOTO__func EXIT_SUCCESSFUL



@EXIT_SUCCESSFUL:
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    exit 0

@EXIT_PRECHECK_FAILED:
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${PRINTF_ERROR}: ${docker__stdErr}"
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    
    exit 99

@EXIT_FAILED:
    if [[ ${myBranchName_isFound} == ${DOCKER__TRUE} ]]; then 
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "${PRINTF_ERROR}: git checkout ${DOCKER__FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR} (${DOCKER__FG_LIGHTRED}failed${DOCKER__NOCOLOR})"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        
        exit 99
    else
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "${PRINTF_ERROR}: git checkout -b ${DOCKER__FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR} (${DOCKER__FG_LIGHTRED}failed${DOCKER__NOCOLOR})"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        
        exit 99
    fi
}

function docker__get_git_branchList__func() {
    #Disable File-expansion
    #REMARK: this is a MUST because otherwise an Asterisk would be treated as a NON-string
    set -f

    #Get Git Branch-list and write directly to an array
    readarray -t docker__gitBranchList_arr <<< "$(git branch | tr -d ' ')"

    #Enable File-expansion
    set +f
}

function docker__show_git_branchList__func() {
    #Define local constants
    local CHECKED_OUT="checked out"

    #Define local variables
    local gitBranchList_arrItem=${DOCKER__EMPTYSTRING}
    local gitBranchList_arrItem_wo_asterisk=${DOCKER__EMPTYSTRING} 
    local asterisk_isFound=${DOCKER__FALSE}

    #Print Status Message
    echo -e "---:${DOCKER__FG_ORANGE}${PRINTF_LIST_LOCAL}${DOCKER__NOCOLOR}: git branch"

    #Show Array items
    for gitBranchList_arrItem in "${docker__gitBranchList_arr[@]}"
    do 
        #Check if asterisk is present
        asterisk_isFound=`checkForMatch_subString_in_string__func "${gitBranchList_arrItem}" "${DOCKER__ASTERISK}"`
        if [[ ${asterisk_isFound} == ${DOCKER__TRUE} ]]; then
            gitBranchList_arrItem_wo_asterisk=`echo ${gitBranchList_arrItem} | cut -d"${DOCKER__ASTERISK}" -f2`

            echo -e "${DOCKER__FOURSPACES}${DOCKER__ASTERISK} ${DOCKER__FG_GREEN}${gitBranchList_arrItem_wo_asterisk}${DOCKER__NOCOLOR} (${CHECKED_OUT})"
        else
            echo -e "${DOCKER__FOURSPACES}${gitBranchList_arrItem}"
        fi
    done


    #Move-down and clean line
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
}

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
    local stdOutput=`git branch | grep -w "${branchName_input}" | grep "${DOCKER__ASTERISK}" 2>&1`
    if [[ ! -z ${stdOutput} ]]; then #contains data
        echo ${DOCKER__TRUE}
    else    #contains no data
        echo ${DOCKER__FALSE}
    fi
}



#---MAIN SUBROUTINE
main_sub() {
    docker__environmental_variables__sub

    docker__load_source_files__sub

    docker__load_header__sub

    docker__git_pull__sub
}



#---EXECUTE
main_sub
