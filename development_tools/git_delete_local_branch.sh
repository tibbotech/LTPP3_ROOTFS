#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---COLOR CONSTANTS
DOCKER__NOCOLOR=$'\e[0m'
DOCKER__FG_LIGHTRED=$'\e[1;31m'
DOCKER__CHROOT_FG_GREEN=$'\e[30;38;5;82m'
DOCKER__FG_SOFTLIGHTBLUE=$'\e[30;38;5;80m'
DOCKER__FG_LIGHTBLUE=$'\e[30;38;5;51m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__INSIDE_FG_LIGHTGREY=$'\e[30;38;5;246m'
DOCKER__FILES_FG_ORANGE=$'\e[30;38;5;215m'
DOCKER__IMAGEID_FG_BORDEAUX=$'\e[30;38;5;198m'

DOCKER__FG_SOFTLIGHTRED=$'\e[30;38;5;131m'
DOCKER__FG_LIGHTGREEN=$'\e[30;38;5;71m'
DOCKER__FG_LIGHTSOFTYELLOW=$'\e[30;38;5;229m'

DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'

#---CONSTANTS
DOCKER__TITLE="TIBBO"

DOCKER__CTRL_C_QUIT="Quit (Ctrl+C)"

#---CHARACTER CONSTANTS
DOCKER__ASTERISK="*"
DOCKER__DASH="-"
DOCKER__EMPTYSTRING=""

DOCKER__ENTER=$'\x0a'

DOCKER__ONESPACE=" "
DOCKER__TWOSPACES=${DOCKER__ONESPACE}${DOCKER__ONESPACE}
DOCKER__FOURSPACES=${DOCKER__TWOSPACES}${DOCKER__TWOSPACES}

#---BOOLEAN CONSTANTS
TRUE=true
FALSE=false

#---NUMERIC CONSTANTS
DOCKER__TABLEWIDTH=70

DOCKER__NUMOFLINES_0=0
DOCKER__NUMOFLINES_1=1
DOCKER__NUMOFLINES_2=2
DOCKER__NUMOFLINES_3=3
DOCKER__NUMOFLINES_4=4
DOCKER__NUMOFLINES_5=5
DOCKER__NUMOFLINES_6=6
DOCKER__NUMOFLINES_7=7
DOCKER__NUMOFLINES_8=8
DOCKER__NUMOFLINES_9=9



#---VARIABLES
git__gitBranchList_arr=()
git__branchName_isNew=${FALSE}


#---FUNCTIONS
#---FUNCTIONS
trap CTRL_C__func INT

function CTRL_C__func() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

    exit
}

function press_any_key__func() {
	#Define constants
	local ANYKEY_TIMEOUT=10

	#Initialize variables
	local keypressed=""
	local tcounter=0

	#Show Press Any Key message with count-down
	moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
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
	moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
}

function GOTO__func
{
	#Input args
    LABEL=$1
	
	#Define Command line
    cmd_line=$(sed -n "/$LABEL:/{:a;n;p;ba;};" $0 | grep -v ':$')
	
	#Execute Command line
    eval "${cmd_line}"
	
	#Exit Function
    exit
}

function checkForMatch_subString_in_string__func() {
    #Input args
    local str_input=${1}
    local subStr_input=${2}

    #Check if 'subStr_input' is found in 'str_input'
    local stdOutput=`echo "${str_input}" | grep "${subStr_input}"`
    if [[ ! -z ${stdOutput} ]]; then
        echo ${TRUE}
    else
        echo ${FALSE}
    fi
}

function checkIf_branch_alreadyExists__func() {
    #Input args
    local branchName_input=${1}

    #Check if 'branchName_input' already exists
    local stdOutput=`git branch | grep -w "${branchName_input}" 2>&1`
    if [[ ! -z ${stdOutput} ]]; then #contains data
        echo ${TRUE}
    else    #contains no data
        echo ${FALSE}
    fi
}

function checkIf_branch_isCheckedOut__func() {
    #Input args
    local branchName_input=${1}

    #Check if 'branchName_input' already exists
    local stdOutput=`git branch | grep -w "${branchName_input}" | grep "${DOCKER__ASTERISK}" 2>&1`
    if [[ ! -z ${stdOutput} ]]; then #contains data
        echo ${TRUE}
    else    #contains no data
        echo ${FALSE}
    fi
}

function duplicate_char__func() {
    #Input args
    local char_input=${1}
    local numOf_times=${2}

    #Duplicate 'char_input'
    local char_duplicated=`printf '%*s' "${numOf_times}" | tr ' ' "${char_input}"`

    #Print text including Leading Empty Spaces
    echo -e "${char_duplicated}"
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

function show_centered_string__func() {
    #Input args
    local str_input=${1}
    local maxStrLen_input=${2}

    #Define one-space constant
    local ONESPACE=" "

    #Get string 'without visiable' color characters
    local strInput_wo_colorChars=`echo "${str_input}" | sed "s,\x1B\[[0-9;]*m,,g"`

    #Get string length
    local strInput_wo_colorChars_len=${#strInput_wo_colorChars}

    #Calculated the number of spaces to-be-added
    local numOf_spaces=$(( (maxStrLen_input-strInput_wo_colorChars_len)/2 ))

    #Create a string containing only EMPTY SPACES
    local emptySpaces_string=`duplicate_char__func "${ONESPACE}" "${numOf_spaces}" `

    #Print text including Leading Empty Spaces
    echo -e "${emptySpaces_string}${str_input}"
}

function show_git_branchList__func() {
    #Define local constants
    local CHECKED_OUT="checked out"

    #Define local variables
    local gitBranchList_arrItem=${DOCKER__EMPTYSTRING}
    local gitBranchList_arrItem_wo_asterisk=${DOCKER__EMPTYSTRING} 
    local asterisk_isFound=${FALSE}

    #Print Status Message
    echo -e "---:${DOCKER__FILES_FG_ORANGE}${PRINTF_LIST_LOCAL}${DOCKER__NOCOLOR}: git branch"

    #Show Array items
    for gitBranchList_arrItem in "${git__gitBranchList_arr[@]}"
    do 
        #Check if asterisk is present
        asterisk_isFound=`checkForMatch_subString_in_string__func "${gitBranchList_arrItem}" "${DOCKER__ASTERISK}"`
        if [[ ${asterisk_isFound} == ${TRUE} ]]; then
            gitBranchList_arrItem_wo_asterisk=`echo ${gitBranchList_arrItem} | cut -d"${DOCKER__ASTERISK}" -f2`

            echo -e "${DOCKER__FOURSPACES}${DOCKER__ASTERISK} ${DOCKER__CHROOT_FG_GREEN}${gitBranchList_arrItem_wo_asterisk}${DOCKER__NOCOLOR} (${CHECKED_OUT})"
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

    docker__global_functions_filename="docker_global_functions.sh"
    docker__global_functions_fpath=${git__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global_functions_filename}
}

git__load_source_files__sub() {
    source ${docker__global_functions_fpath}
}

git__load_header__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${DOCKER__TITLE_BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__TITLE_BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

git__git_pull__sub() {
    #Define local constants
    local MENUTITLE="Git ${DOCKER__FG_SOFTLIGHTRED}Delete${DOCKER__NOCOLOR} ${DOCKER__INSIDE_FG_LIGHTGREY}Local${DOCKER__NOCOLOR} Branch"

    #Define local message constants
    local PRINTF_COMPLETED="${DOCKER__FILES_FG_ORANGE}COMPLETED${DOCKER__NOCOLOR}"
    local PRINTF_LIST_LOCAL="${DOCKER__FILES_FG_ORANGE}LIST${DOCKER__NOCOLOR} (${DOCKER__FILES_FG_ORANGE}LOCAL${DOCKER__NOCOLOR})"
    local PRINTF_INPUT="${DOCKER__FILES_FG_ORANGE}INPUT${DOCKER__NOCOLOR}"
    local PRINTF_START="${DOCKER__FILES_FG_ORANGE}START${DOCKER__NOCOLOR}"
    local PRINTF_STATUS="${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}"
    local PRINTF_WARNING="${DOCKER__IMAGEID_FG_BORDEAUX}WARNING${DOCKER__NOCOLOR}"

    local PRINTF_BRANCH_TOBE_DELETED="Branch ${DOCKER__INSIDE_FG_LIGHTGREY}to-be-deleted${DOCKER__NOCOLOR}"
    local PRINTF_ERROR="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}"

    #Define local question constants
    local QUESTION_PROCEED="Proceed (y/n/q)? "

    #Define local read-input constants
    local READ_YOURINPUT="${DOCKER__FG_LIGHTBLUE}Your input${DOCKER__NOCOLOR}: "

    local READERR_CURRENTLY_CHECKEDOUT_NOTALLOWED="${DOCKER__FG_LIGHTRED}currently checked out${DOCKER__NOCOLOR}; ${DOCKER__FG_LIGHTRED}not allowed${DOCKER__NOCOLOR}"
    local READERR_NOT_FOUND="${DOCKER__FG_LIGHTRED}not found${DOCKER__NOCOLOR}"

    #Define local variables
    local isCheckedOut=${FALSE}
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
    echo -e "${DOCKER__FOURSPACES}${DOCKER__CTRL_C_QUIT}"
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
            if [[ ${myBranchName_isFound} == ${TRUE} ]]; then
                #Check if asterisk is present
                isCheckedOut=`checkIf_branch_isCheckedOut__func "${myBranchName}"`
                if [[ ${isCheckedOut} == ${FALSE} ]]; then  #asterisk is NOT found
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
    printf_msg="About to Delete (local) branch '${DOCKER__INSIDE_FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR}'"

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
    echo -e "---:${PRINTF_START}: git branch -d ${DOCKER__INSIDE_FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR}"

    #Execute
    git branch -d ${myBranchName}

    #Check exit-code
    exitCode=$?
    if [[ ${exitCode} -eq 0 ]]; then
        echo -e "---:${PRINTF_COMPLETED}: git branch -d ${DOCKER__INSIDE_FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR}"
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
    echo -e "${PRINTF_ERROR}: git branch -d ${DOCKER__INSIDE_FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR}"
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
