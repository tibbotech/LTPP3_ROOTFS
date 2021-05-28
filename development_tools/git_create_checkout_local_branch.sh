#!/bin/bash
#---COLOR CONSTANTS
DOCKER__NOCOLOR=$'\e[0m'
DOCKER__FG_LIGHTRED=$'\e[1;31m'
DOCKER__CHROOT_FG_GREEN=$'\e[30;38;5;82m'
DOCKER__FG_SOFTLIGHTBLUE=$'\e[30;38;5;80m'
DOCKER__FG_LIGHTBLUE=$'\e[30;38;5;51m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__INSIDE_FG_LIGHTGREY=$'\e[30;38;5;246m'
DOCKER__FILES_FG_ORANGE=$'\e[30;38;5;215m'

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
docker__branchName_isNew=${FALSE}
docker__gitBranchList_arr=()
docker__stdErr=${DOCKER__EMPTYSTRING}


#---FUNCTIONS
trap CTRL_C__func INT

function CTRL_C__func() {
    echo -e "\r"
    echo -e "\r"

    exit
}

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

function show_centered_string__func()
{
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

function moveUp_and_cleanLines__func() {
    #Input args
    local numOf_lines_toBeCleared=${1}

    #Clear lines
    local numOf_lines_cleared=1
    while [[ ${numOf_lines_cleared} -le ${numOf_lines_toBeCleared} ]]
    do
        tput cuu1	#move UP with 1 line
        tput el		#clear until the END of line

        numOf_lines_cleared=$((numOf_lines_cleared+1))  #increment by 1
    done


    echo -e "\r"
}

function moveDown_and_cleanLines__func() {
    #Input args
    local numOf_lines_toBeCleared=${1}

    #Clear lines
    local numOf_lines_cleared=1
    while [[ ${numOf_lines_cleared} -le ${numOf_lines_toBeCleared} ]]
    do
        tput cud1	#move UP with 1 line
        tput el1	#clear until the END of line

        numOf_lines_cleared=$((numOf_lines_cleared+1))  #increment by 1
    done
}



#---SUBROUTINES
docker__load_header__sub() {
    echo -e "\r"
    echo -e "${DOCKER__TITLE_BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__TITLE_BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__git_pull__sub() {
    #Define local constants
    local MENUTITLE="Git ${DOCKER__FG_LIGHTGREEN}Create${DOCKER__NOCOLOR} and/or ${DOCKER__FG_LIGHTSOFTYELLOW}Checkout${DOCKER__NOCOLOR} Branch"

    #Define local message constants
    local PRINTF_COMPLETED="${DOCKER__FILES_FG_ORANGE}COMPLETED${DOCKER__NOCOLOR}"
    local PRINTF_LIST_LOCAL="${DOCKER__FILES_FG_ORANGE}LIST${DOCKER__NOCOLOR} (${DOCKER__FILES_FG_ORANGE}LOCAL${DOCKER__NOCOLOR})"
    local PRINTF_INPUT="${DOCKER__FILES_FG_ORANGE}INPUT${DOCKER__NOCOLOR}"
    local PRINTF_START="${DOCKER__FILES_FG_ORANGE}START${DOCKER__NOCOLOR}"
    local PRINTF_STATUS="${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}"
    
    local PRINTF_BRANCHNAME_NEW_EXISTING="Branch (${DOCKER__INSIDE_FG_LIGHTGREY}new${DOCKER__NOCOLOR}/${DOCKER__INSIDE_FG_LIGHTGREY}existing${DOCKER__NOCOLOR})"
    local PRINTF_ERROR="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}"
    local PRINTF_NO_ACTION_REQUIRED="No Action Required."

    #Define local Question constants
    local QUESTION_CHECKOUT_BRANCH="Check out this Branch (y/n/q)? "
    local QUESTION_CREATE_AND_CHECKOUT_BRANCH="Create & Check out this Branch (y/n/q)? "

    #Define local read-input constants
    local READ_YOURINPUT="${DOCKER__FG_LIGHTBLUE}Your input${DOCKER__NOCOLOR}: "

    #Define local variables
    local isCheckedOut=${FALSE}
    local myAnswer=${DOCKER__EMPTYSTRING}

    #Define local message variables
    local printf_msg=${DOCKER__EMPTYSTRING}
    local question_msg=${DOCKER__EMPTYSTRING}

    #Define local read-input variables
    local myBranchName=${DOCKER__EMPTYSTRING}
    local myBranchName_isFound=${FALSE}



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
    if [[ ${myBranchName_isFound} == ${TRUE} ]]; then
        #Check if asterisk is present
        isCheckedOut=`docker__checkIf_branch_isCheckedOut__func "${myBranchName}"`
        if [[ ${isCheckedOut} == ${FALSE} ]]; then  #asterisk is NOT found
            #Update message
            printf_msg="Branch '${DOCKER__INSIDE_FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR}' already Exist..."

            #Update variable
            question_msg=${QUESTION_CHECKOUT_BRANCH}
        else    #asterisk is found
            #Add an empty-line
            echo -e "\r"
            
            #Update message
            printf_msg="Branch '${DOCKER__INSIDE_FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR}' already Exist and Checked Out"

            #Print message
            echo -e "---:${PRINTF_STATUS}: ${printf_msg}"

            #Print message
            echo -e "---:${PRINTF_STATUS}: ${PRINTF_NO_ACTION_REQUIRED}"

            #Goto next-phase
            GOTO__func EXIT_SUCCESSFUL
        fi
    else
        #Update message
        printf_msg="Branch '${DOCKER__INSIDE_FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR}' is New..."

        #Update variable
        question_msg=${QUESTION_CREATE_AND_CHECKOUT_BRANCH}
    fi

    #Add an empty-line
    echo -e "\r"

    #Show question
    while true
    do
        echo -e "---:${PRINTF_STATUS}: ${printf_msg}"
        read -N1 -p "${DOCKER__FOURSPACES}${question_msg}" myAnswer

        if [[ ! -z ${myAnswer} ]]; then #contains data
            #Handle 'myAnswer'
            if [[ ${myAnswer} =~ [y,n,q] ]]; then
                if [[ ${myAnswer} == "q" ]]; then
                    echo -e "\r"

                    GOTO__func EXIT_SUCCESSFUL  #goto next-phase
                elif [[ ${myAnswer} == "n" ]]; then
                    echo -e "\r"
                    echo -e "\r"

                    GOTO__func BRANCH_LIST    #goto next-phase
                else
                    echo -e "\r"
                    echo -e "\r"

                    if [[ ${myBranchName_isFound} == ${TRUE} ]]; then
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
    echo -e "---:${PRINTF_START}: git checkout ${DOCKER__INSIDE_FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR}"

    #Execute
    git checkout ${myBranchName}

    #Check exit-code
    exitCode=$?
    if [[ ${exitCode} -eq 0 ]]; then
        echo -e "---:${PRINTF_COMPLETED}: git checkout ${DOCKER__INSIDE_FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR}"
        echo -e "\r"
        
        #Goto next-phase
        GOTO__func GET_AND_SHOW_BRANCH_LIST
    else
        #Goto next-phase
        GOTO__func EXIT_FAILED
    fi



@CREATE_AND_CHECKOUT_BRANCH:
    echo -e "---:${PRINTF_START}: git checkout -b ${DOCKER__INSIDE_FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR}"

    #Execute
    git checkout -b ${myBranchName}

    #Check exit-code
    exitCode=$?
    if [[ ${exitCode} -eq 0 ]]; then
        echo -e "---:${PRINTF_COMPLETED}: git checkout -b ${DOCKER__INSIDE_FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR}"
        echo -e "\r"
        
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
    echo -e "\r"

    exit 0

@EXIT_PRECHECK_FAILED:
    echo -e "\r"
    echo -e "${PRINTF_ERROR}: ${docker__stdErr}"
    echo -e "\r"
    
    exit 99

@EXIT_FAILED:
    if [[ ${myBranchName_isFound} == ${TRUE} ]]; then 
        echo -e "\r"
        echo -e "${PRINTF_ERROR}: git checkout ${DOCKER__INSIDE_FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR} (${DOCKER__FG_LIGHTRED}failed${DOCKER__NOCOLOR})"
        echo -e "\r"
        
        exit 99
    else
        echo -e "\r"
        echo -e "${PRINTF_ERROR}: git checkout -b ${DOCKER__INSIDE_FG_LIGHTGREY}${myBranchName}${DOCKER__NOCOLOR} (${DOCKER__FG_LIGHTRED}failed${DOCKER__NOCOLOR})"
        echo -e "\r"
        
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
    local asterisk_isFound=${FALSE}

    #Print Status Message
    echo -e "---:${DOCKER__FILES_FG_ORANGE}${PRINTF_LIST_LOCAL}${DOCKER__NOCOLOR}: git branch"

    #Show Array items
    for gitBranchList_arrItem in "${docker__gitBranchList_arr[@]}"
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

function docker__checkIf_branch_alreadyExists__func() {
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

function docker__checkIf_branch_isCheckedOut__func() {
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



#---MAIN SUBROUTINE
main_sub() {
    docker__load_header__sub

    docker__git_pull__sub
}



#---EXECUTE
main_sub
