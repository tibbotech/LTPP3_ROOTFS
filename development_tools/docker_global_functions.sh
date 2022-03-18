#!/bin/bash
#---BOOLEAN CONSTANTS
DOCKER__TRUE=true
DOCKER__FALSE=false



#---CHARACTER CHONSTANTS
DOCKER__BACKSLASH_ASTERISK="\*"
DOCKER__ASTERISK="*"
DOCKER__BACKSLASH="\\"
DOCKER__COMMA=","
DOCKER__DASH="-"
DOCKER__DOT="."
DOCKER__ESCAPE_SLASH="\/"
DOCKER__SEMICOLON=";"
DOCKER__SLASH="/"

DOCKER__EMPTYSTRING=""

DOCKER__BACKSPACE=$'\b'
DOCKER__DEL=$'\x7e'
DOCKER__ENTER=$'\x0a'
DOCKER__ESCAPEKEY=$'\x1b'   #note: this escape key is ^[
DOCKER__TAB=$'\t'

DOCKER__EXIT="exit"



#---COLOR CONSTANTS
DOCKER__NOCOLOR=$'\e[0;0m'

DOCKER__FG_BORDEAUX=$'\e[30;38;5;198m'
DOCKER__FG_BRIGHTPRUPLE=$'\e[30;38;5;141m'
DOCKER__FG_BRIGHTLIGHTPURPLE=$'\e[30;38;5;147m'
DOCKER__FG_DARKBLUE=$'\e[30;38;5;33m'
DOCKER__FG_REDORANGE=$'\e[30;38;5;203m'
DOCKER__FG_GREEN=$'\e[30;38;5;82m'
DOCKER__FG_GREEN85=$'\e[30;38;5;85m'
DOCKER__FG_LIGHTBLUE=$'\e[30;38;5;45m'
DOCKER__FG_LIGHTGREEN=$'\e[1;32m'
DOCKER__FG_LIGHTGREEN_71=$'\e[30;38;5;71m'
DOCKER__FG_LIGHTGREY=$'\e[30;38;5;246m'
DOCKER__FG_LIGHTPINK=$'\e[30;38;5;218m'
DOCKER__FG_LIGHTRED=$'\e[1;31m'
DOCKER__FG_LIGHTSOFTYELLOW=$'\e[30;38;5;229m'
DOCKER__FG_ORANGE=$'\e[30;38;5;215m'
DOCKER__FG_PURPLE=$'\e[30;38;5;93m'
DOCKER__FG_PURPLERED=$'\e[30;38;5;198m'
DOCKER__FG_SOFTDARKBLUE=$'\e[30;38;5;38m'
DOCKER__FG_SOFTLIGHTRED=$'\e[30;38;5;131m'
DOCKER__FG_VERYLIGHTORANGE=$'\e[30;38;5;223m'
DOCKER__FG_WHITE=$'\e[30;38;5;231m'
DOCKER__FG_YELLOW=$'\e[1;33m'

DOCKER__BG_BRIGHTPRUPLE=$'\e[30;48;5;141m'
DOCKER__BG_BORDEAUX=$'\e[30;48;5;198m'
DOCKER__BG_GREEN85=$'\e[30;48;5;85m'
DOCKER__BG_ORANGE=$'\e[30;48;5;215m'
DOCKER__BG_LIGHTBLUE=$'\e[30;48;5;45m'
DOCKER__BG_LIGHTGREY=$'\e[30;48;5;246m'
DOCKER__BG_WHITE=$'\e[30;48;5;15m'



#---DIMENSION CONSTANTS
DOCKER__NINE=9
DOCKER__TABLEWIDTH=70



#---DOCKER RELATED CONSTANTS
DOCKER__GREPPATTERN_EXITED="Exited"

DOCKER__STATE_RUNNING="Running"
DOCKER__STATE_EXITED="Exited"
DOCKER__STATE_NOTFOUND="NotFound"



#---EXIT-CODE CONSTANTS
DOCKER__EXITCODE_0=0
DOCKER__EXITCODE_99=99



#---MENU CONSTANTS
DOCKER__TITLE="TIBBO"
DOCKER__A_ABORT="${DOCKER__FOURSPACES}b. Back"
DOCKER__ARROWUP="arrowUp"
DOCKER__ARROWDOWN="arrowDown"
DOCKER__QUIT_CTR_C="${DOCKER__FOURSPACES}Quit (Ctrl+C)"
DOCKER__CTRL_C_COLON_QUIT="Ctrl+C: Quit"
DOCKER__EXITING_NOW="Exiting now..."
DOCKER__HORIZONTALLINE="---------------------------------------------------------------------"
DOCKER__LATEST="latest"
DOCKER__Q_QUIT="${DOCKER__FOURSPACES}q. Quit (Ctrl+C)"
DOCKER__QUIT_CTRL_C="Quit (Ctrl+C)"



#---NUMERIC CONSTANTS
DOCKER__LINENUM_1=1
DOCKER__LINENUM_2=2

DOCKER__LISTVIEW_NUMOFROWS=20
DOCKER__LISTVIEW_NUMOFCOLS=0

DOCKER__NUMOFCHARS_1=1

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
DOCKER__NUMOFLINES_10=10

DOCKER__NUMOFMATCH_0=0
DOCKER__NUMOFMATCH_1=1



#---PATTERN CONSTANTS
DOCKER__PATTERN_DOCKER_IO="docker.io"



#---PHASE CONSTANTS
PHASE_SHOW_REMARKS=0
PHASE_SHOW_READINPUT=1
PHASE_SHOW_KEYINPUT_HANDLER=2



#---READ-INPUT CONSTANTS
DOCKER__BACK="b"
DOCKER__CLEAR="c"
DOCKER__HOME="h"
DOCKER__NO="n"
DOCKER__QUIT="q"
DOCKER__REDO="r"
DOCKER__YES="y"

DOCKER__SEMICOLON_BACK=";b"
DOCKER__SEMICOLON_CLEAR=";c"
DOCKER__SEMICOLON_HOME=";h"



#---SED CONSTANTS
SED__ASTERISK="*"
SED__BACKSLASH="\\\\"
SED__DOT="\\."
SED__SLASH="\\/"

SED__DOUBLE_BACKSLASH=${SED__BACKSLASH}${SED__BACKSLASH}
SED__BACKSLASH_DOT="${SED__BACKSLASH}${SED__DOT}"



#---SET CONSTANTS
DOCKER__REMOVE_ALL="REMOVE-ALL"



#---SPACE CONSTANTS
DOCKER__ONESPACE=" "
DOCKER__TWOSPACES=${DOCKER__ONESPACE}${DOCKER__ONESPACE}
DOCKER__FOURSPACES=${DOCKER__TWOSPACES}${DOCKER__TWOSPACES}
DOCKER__FIVE_SPACES=${DOCKER__FOURSPACES}${DOCKER__ONESPACE}



#---VARIABLES
docker__images_cmd="docker images"
docker__ps_a_cmd="docker ps -a"



#---SPECIFAL FUNCTIONS
function docker__exitFunc() {
    #Input args
    exitCode__input=${1}
    numOfLines__input=${2}

    #Move-down cursor
    moveDown_and_cleanLines__func "${numOfLines__input}"

    #Exit with code
    exit ${exitCode__input}
}

function GOTO__func() {
	#Input args
    LABEL=$1
	
	#Define Command line
    cmd=$(sed -n "/$LABEL:/{:a;n;p;ba;};" $0 | grep -v ':$')
	
	#Execute Command line
    eval "${cmd}"
	
	#Exit Function
    exit
}

function press_any_key__func() {
	#Define constants
	local ANYKEY_TIMEOUT=10

	#Initialize variables
	local keyPressed=""
	local tCounter=0

	#Show Press Any Key message with count-down
	moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
	while [[ ${tCounter} -le ${ANYKEY_TIMEOUT} ]];
	do
		delta_tcounter=$(( ${ANYKEY_TIMEOUT} - ${tCounter} ))

		echo -e "\rPress (a)bort or any key to continue... (${delta_tcounter}) \c"
		read -N 1 -t 1 -s -r keyPressed

		if [[ ! -z "${keyPressed}" ]]; then
			if [[ "${keyPressed}" == "a" ]] || [[ "${keyPressed}" == "A" ]]; then
				exit
			else
				break
			fi
		fi
		
		tCounter=$((tCounter+1))
	done
	moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
}



#---DOCKER RELATED FUNCTIONS
function check_containerID_state__func() {
    #Input args
    local containerID__input=${1}

    #Check if 'containterID__input' is running
    local stdOutput=`${docker__ps_a_cmd} --format "table {{.ID}}|{{.Status}}" | grep -w "${containerID__input}"`
    if [[ -z ${stdOutput} ]]; then  #contains NO data
        echo "${DOCKER__STATE_NOTFOUND}"
    else    #contains data
        local stdOutput2=`echo ${stdOutput} | grep -w "${DOCKER__GREPPATTERN_EXITED}"`
        if [[ ! -z ${stdOutput2} ]]; then   #contains data
            echo "${DOCKER__STATE_EXITED}"
        else    #contains NO data
            echo "${DOCKER__STATE_RUNNING}"
        fi
    fi
}



#---FILE RELATED FUNCTIONS
function checkIf_dir_exists__func() {
    #Input args
    local containerID__input=${1}
    local dir__input=${2}

    #Check if dir exists
    local ret=false
    if [[ ! -z ${dir__input} ]]; then #contains data
        if [[ ${dir__input} == ${DOCKER__SLASH} ]]; then
            ret=true
        else
            if [[ -z ${containerID__input} ]]; then #no container-ID provided
                ret=`lh_checkIf_dir_exists__func "${dir__input}"`
            else    #container-ID provided
                ret=`container_checkIf_dir_exists__func "${containerID__input}" "${dir__input}"`
            fi
        fi
    else
        ret=${dir__input}
    fi

    #Output
    echo "${ret}"
}
function container_checkIf_dir_exists__func() {
	#Input args
    local containerID__input=${1}
	local dir__input=${2}

	#Define variables
    local bin_bash_dir=/bin/bash
    local docker_exec_cmd="docker exec -t ${containerID__input} ${bin_bash_dir} -c"

    #Check if directory exists
    local ret_raw=`${docker_exec_cmd} "[ -d "${dir__input}" ] && echo true || echo false"`

    #Remove carriage returns '\r' caused by '/bin/bash -c'
    local ret=`echo "${ret_raw}" | tr -d $'\r'`

    #Output
    echo ${ret}
}
function lh_checkIf_dir_exists__func() {
	#Input args
	local dir__input=${1}

    #Check if directory exists
    if [[ -d ${dir__input} ]]; then
        echo true
    else
        echo false
    fi
}

function checkIf_file_exists__func() {
    #Input args
    local containerID__input=${1}
    local fpath__input=${2}

    #Check if dir exists
    local ret=false
    if [[ ! -z ${fpath__input} ]]; then #contains data
        if [[ ${fpath__input} != ${DOCKER__SLASH} ]]; then  #input is not a slash
            if [[ -z ${containerID__input} ]]; then #no container-ID provided
                ret=`lh_checkIf_file_exists__func "${fpath__input}"`
            else    #container-ID provided
                ret=`container_checkIf_file_exists__func "${containerID__input}" "${fpath__input}"`
            fi
        fi
    fi

    #Output
    echo "${ret}"
}
function container_checkIf_file_exists__func() {
	#Input args
    local containerID__input=${1}
	local fpath__input=${2}

	#Define variables
    local bin_bash_dir=/bin/bash
    local docker_exec_cmd="docker exec -t ${containerID__input} ${bin_bash_dir} -c"

    #Check if directory exists
    local ret_raw=`${docker_exec_cmd} "[ -f "${fpath__input}" ] && echo true || echo false"`

    #Remove carriage returns '\r' caused by '/bin/bash -c'
    local ret=`echo "${ret_raw}" | tr -d $'\r'`

    #Output
    echo ${ret}
}
function lh_checkIf_file_exists__func() {
	#Input args
	local fpath__input=${1}

     #Check if directory exists
     if [[ -f ${fpath__input} ]]; then
        echo true
     else
        echo false
     fi
}

function checkIf_dir_has_trailing_slash() {
	#Input args
	local dir__input=${1}

    #Check if 'dir__input' already has a trailing slash
    local dir_len=${#dir__input}
    local lastChar_pos=$((dir_len - 1))

    #Get the first character
    local lastChar=${dir__input:lastChar_pos:dir_len}

    #Check if 'firstChar' is a slash '/'
    if [[ ${lastChar} == ${DOCKER__SLASH} ]]; then
        echo "true"
    else
        echo "false"
    fi
}

function checkIf_dirnames_are_the_same__func() {
    #Input args
    local fpath_new__input=${1}
    local fpath_bck__input=${2}

    #Retrieve dirname from 'fpath1__input' and 'fpath2__input'
    local dir1=`get_dirname_from_specified_path__func "${fpath_new__input}"`
    local dir2=`get_dirname_from_specified_path__func "${fpath_bck__input}"`

    #Check if both paths are the same
    if [[ ${dir1} == ${dir2} ]]; then
        echo "true"
    else
        echo "false"
    fi
}

function checkIf_files_are_different__func() {
    #Input args
    local file1__input=${1}
    local file2__input=${2}

    #Check if the files exist
    if [[ ! -f ${file1__input} ]]; then
        echo "true"

        return  #exit function
    fi

    if [[ ! -f ${file2__input} ]]; then
        echo "true"

        return  #exit function
    fi

    #Compare both files
    local stdOutput=`diff ${file1__input} ${file2__input}`
    if [[ -z ${stdOutput} ]]; then
        echo "false"
    else
        echo "true"
    fi
}

function checkIf_fpaths_are_the_same__func() {
    #---------------------------------------------------------------------
    # Two full-paths are compared with each other to see if they are the
    # same. Should the input values end with a slash, then that slash will
    # be removed.
    #---------------------------------------------------------------------
    #Input args
    local fpath1__input=${1}
    local fpath2__input=${2}

    #Define and initialize variables
    local fpath1_rev=${fpath1__input}
    local fpath2_rev=${fpath2__input}
    local fpath1_lastChar=${DOCKER__EMPTYSTRING}
    local fpath2_lastChar=${DOCKER__EMPTYSTRING}

    local fpath1_len=${#fpath1__input}
    local fpath2_len=${#fpath2__input}

    #Get the last character
    fpath1_lastChar=`get_theLast_xChars_ofString__func "${fpath1__input}" "${DOCKER__NUMOFCHARS_1}"`
    if [[ ${fpath1_lastChar} == ${DOCKER__SLASH} ]]; then
        fpath1_rev=${fpath1__input:0:(fpath1_len-1)}
    fi
    fpath2_lastChar=`get_theLast_xChars_ofString__func "${fpath2__input}" "${DOCKER__NUMOFCHARS_1}"`
    if [[ ${fpath2_lastChar} == ${DOCKER__SLASH} ]]; then
        fpath2_rev=${fpath2__input:0:(fpath2_len-1)}
    fi

    #Check if both paths are the same
    if [[ ${fpath1_rev} == ${fpath2_rev} ]]; then
        echo "true"
    else
        echo "false"
    fi
}

function get_basename_from_specified_path__func() {
    #Input arg
    local fpath__input=${1}

    #Get basename (which is a file or folder)
    local ret=`echo ${fpath__input} | rev | cut -d"${DOCKER__SLASH}" -f1 | rev`

    #Output
    echo ${ret}
}

function get_dirname_from_specified_path__func() {
    #Input arg
    local fpath__input=${1}

    #Get dirname
    local dir=`echo ${fpath__input} | rev | cut -d"${DOCKER__SLASH}" -f2- | rev`
    if [[ ${dir} == ${DOCKER__EMPTYSTRING} ]]; then
        ret=${DOCKER__SLASH}
    else
        ret=${dir}${DOCKER__SLASH}
    fi

    #Output
    echo ${ret}
}

function get_output_from_file__func() {
    #Input args
    outputFpath__input=${1}
    lineNum__input=${2}

    #Read from file
    if [[ -f ${outputFpath__input} ]]; then
        ret=`cat ${outputFpath__input} | head -n${lineNum__input} | tail -n+${lineNum__input}`
    else
        ret=${DOCKER__EMPTYSTRING}
    fi

    #Output
    echo ${ret}
}



#---MOVE FUNCTIONS
function moveUp__func() {
    #Input args
    local numOfLines__input=${1}

    #Clear lines
    local tCounter=1
    while [[ ${tCounter} -le ${numOfLines__input} ]]
    do
        tput cuu1	#move UP with 1 line

        tCounter=$((tCounter+1))  #increment by 1
    done
}

function moveUp_and_cleanLines__func() {
    #Input args
    local numOfLines__input=${1}

    #Clear lines
    local xPos_curr=0

    if [[ ${numOfLines__input} != 0 ]]; then
        local tCounter=1
        while [[ ${tCounter} -le ${numOfLines__input} ]]
        do
            #clean current line, Move-up 1 line and clean
            tput el1
            tput cuu1
            tput el

            #Increment tCounter by 1
            tCounter=$((tCounter+1))
        done
    else    #
        tput el1
    fi

    #Get current x-position of cursor
    xPos_curr=`tput cols`

    #Move to the beginning of line
    tput cub ${xPos_curr}
}

function moveDown__func() {
    #Input args
    local numOfLines__input=${1}

    #Clear lines
    local tCounter=1
    while [[ ${tCounter} -le ${numOfLines__input} ]]
    do
        #Move-down 1 line
        tput cud1

        #Increment tCounter by 1
        tCounter=$((tCounter+1))
    done
}

function moveDown_and_cleanLines__func() {
    #Input args
    local numOfLines__input=${1}

    #Clear lines
    local tCounter=1
    while [[ ${tCounter} -le ${numOfLines__input} ]]
    do
        #Move-down 1 line and clean
        tput cud1
        tput el1

        #Increment tCounter by 1
        tCounter=$((tCounter+1))
    done
}

function moveDown_oneLine_then_moveUp_and_clean__func() {
    #Input args
    local numOfLines__input=${1}

    #Move-down 1 line
    tput cud1

    #Move-up and clean a specified number of times
    moveUp_and_cleanLines__func "${numOfLines__input}"
}

function moveUp_oneLine_then_moveRight__func() {
    #Input args
    local mainMsg=${1}
    local keyInput=${2}

    #Get lengths
    local mainMsg_wo_regEx=$(echo -e "$mainMsg" | sed "s/$(echo -e "\e")[^m]*m//g")
    local mainMsg_wo_regEx_len=${#mainMsg_wo_regEx}
    local keyInput_wo_regEx=$(echo -e "$keyInput" | sed "s/$(echo -e "\e")[^m]*m//g")
    local keyInput_wo_regEx_len=${#keyInput_wo_regEx}
    local total_len=$((mainMsg_wo_regEx_len + keyInput_wo_regEx_len))

    #Move cursor up by 1 line
    tput cuu1
    #Move cursor to right
    tput cuf ${total_len}
}



#---SHOW FUNCTIONS
function show_centered_string__func() {
    #Input args
    local string__input=${1}
    local maxStrLen__input=${2}

    #Define one-space constant
    local ONE_SPACE=" "

    #Get string 'without visiable' color characters
    local strInput_wo_colorChars=`echo "${string__input}" | sed "s,\x1B\[[0-9;]*m,,g"`

    #Get string length
    local strInput_wo_colorChars_len=${#strInput_wo_colorChars}

    #Calculated the number of spaces to-be-added
    local numOf_spaces=$(( (maxStrLen__input-strInput_wo_colorChars_len)/2 ))

    #Create a string containing only EMPTY SPACES
    local emptySpaces_string=`duplicate_char__func "${ONE_SPACE}" "${numOf_spaces}" `

    #Print text including Leading Empty Spaces
    echo -e "${emptySpaces_string}${string__input}"
}

function show_leadingAndTrailingStrings_separatedBySpaces__func() {
    #Input args
    local leadStr__input=${1}
    local trailStr__input=${2}
    local maxStrLen__input=${3}

    #Define local variables
    local ONE_SPACE=" "

    #Get string 'without visiable' color characters
    local leadStr_input_wo_colorChars=`echo "${leadStr__input}" | sed "s,\x1B\[[0-9;]*m,,g"`
    local trailStr_input_wo_colorChars=`echo "${trailStr__input}" | sed "s,\x1B\[[0-9;]*m,,g"`

    #Get string length
    local leadStr_input_wo_colorChars_len=${#leadStr_input_wo_colorChars}
    local trailStr_input_wo_colorChars_len=${#trailStr_input_wo_colorChars}

    #Calculated the number of spaces to-be-added
    local numOf_spaces=$(( maxStrLen__input-(leadStr_input_wo_colorChars_len+trailStr_input_wo_colorChars_len) ))

    #Create a string containing only EMPTY SPACES
    local emptySpaces_string=`printf '%*s' "${numOf_spaces}" | tr ' ' "${ONE_SPACE}"`

    #Print text including Leading Empty Spaces
    echo -e "${leadStr__input}${emptySpaces_string}${trailStr__input}"
}

function show_list_w_menuTitle__func() {
    #Input args
    local menuTitle__input=${1}
    local dockerCmd__input=${2}

    #Show list
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${menuTitle__input}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    
    if [[ ${dockerCmd__input} == ${docker__ps_a_cmd} ]]; then
        ${docker__containerlist_tableinfo__fpath}
    else
        ${docker__repolist_tableinfo__fpath}
    fi

    #Move-down cursor
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    #Print
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${DOCKER__QUIT_CTR_C}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
}

function show_msg_w_menuTitle_w_pressAnyKey_w_ctrlC_func() {
    #Input args
    local menuTitle__input=${1}
    local msg__input=${2}

    #Show error-message
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${menuTitle__input}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    show_centered_string__func "${msg__input}" "${DOCKER__TABLEWIDTH}"
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    press_any_key__func

    CTRL_C__sub
}

function show_msg_w_menuTitle_only_func() {
    #Input args
    local menuTitle__input=${1}
    local msg__input=${2}
    local prepend__numOfLines=${3}
    local append__numOfLines=${4}

    #Prepend empty lines
    moveDown_and_cleanLines__func "${prepend__numOfLines}"

    #Horizontal line
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Print 'menuTitle__input'
    show_centered_string__func "${menuTitle__input}" "${DOCKER__TABLEWIDTH}"

    #Horizontal line
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    
    #Only handle the following condition if 'msg__input' is NOT an Empty String
    if [[ ! -z ${msg__input} ]]; then
        #Print 'msg__input'
        echo -e "${msg__input}"
        
        #Append 1 emoty line
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        #Horizontal line
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    fi

    #Append empty lines
    moveDown_and_cleanLines__func "${append__numOfLines}"
}

function show_msg_only__func() {
    #Input args
    local msg__input=${1}
    local numOfLines__input=${2}

    #Move-down cursor
    moveDown_and_cleanLines__func "${numOfLines__input}"

    #Print
    echo -e "${msg__input}" #error message
}

function show_msg_wo_menuTitle_w_PressAnyKey__func() {
    #Input args
    local msg__input=${1}
    local numOfLines__input=${2}

    #Move-down cursor
    moveDown_and_cleanLines__func "${numOfLines__input}"

    #Print
    echo -e "${msg__input}"

    #Show press-any-key dialog
    press_any_key__func
}

function show_errMsg_without_menuTitle_exit_func() {
    #Input args
    local msg__input=${1}
    local prepend__numOfLines=${2}
    local append__numOfLines=${3}

    #Move down and clean
    moveDown_and_cleanLines__func "${prepend__numOfLines}"
    
    #Print
    echo -e "${msg__input}"

    #Move down and clean
    moveDown_and_cleanLines__func "${append__numOfLines}"

    #Exit
    docker__exitFunc "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_0}"
}



#---STRING FUNCTIONS
function checkForMatch_keyWord_within_string__func() {
    #Turn-off Expansion
    set -f

    #Input Args
    local keyWord__input=${1}
    local string__input=${2}

    #Find any match (not exact)
    local stdOutput=`echo ${string__input} | grep "${keyWord__input}"`
    if [[ -z ${stdOutput} ]]; then  #no match
        echo "false"
    else    #match
        echo "true"
    fi

    #Turn-on Expansion
    set +f
}

function checkForMatch_dockerCmd_result__func() {
    #Input Args
    local keyWord__input=${1}
    local dockerCmd__input=${2}
    local dockerTableColno__input=${3}

    #Find any match (not exact)
    local stdOutput=`${dockerCmd__input} | awk -vcolNo=${dockerTableColno__input} '{print $colNo}' | grep -w ${keyWord__input}`
    if [[ -z ${stdOutput} ]]; then  #no match
        echo "false"
    else    #match
        echo "true"
    fi
}

function duplicate_char__func() {
    #Input args
    local char__input=${1}
    local numOfTimes__input=${2}

    #Duplicate 'char__input'
    local ret=`printf '%*s' "${numOfTimes__input}" | tr ' ' "${char__input}"`

    #Print text including Leading Empty Spaces
    echo -e "${ret}"
}

function get_char_at_specified_position__func() {
    #Input Args
    local string__input=${1}
    local pos__input=${2}

    #Calculate the 'index'
    #Remark:
    #   The 'index' starts with '0'.
    local index=0
    if [[ ${pos__input} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
        index=$((pos__input - 1))
    fi

    #Get the first character
    local ret=${string__input:index:1}    

    #Output
    echo "${ret}"
}

function get_endResult_ofString_with_semiColonChar__func() {
    #Input args
    local string__input=${1}

    #Define variables
    local adjacentChar=${DOCKER__EMPTYSTRING}
    local leftPart=${DOCKER__EMPTYSTRING}
    local rightPart=${DOCKER__EMPTYSTRING}
    local ret=${DOCKER__EMPTYSTRING}

    local backIsFound=false
    local clearIsFound=false
    local homeIsFound=false

    local rightPart_len=0

    #Check if ';h' is found
    #If TRUE, then return with the original 'DOCKER__SEMICOLON_HOME'
    homeIsFound=`checkForMatch_keyWord_within_string__func "${DOCKER__SEMICOLON_HOME}" "${string__input}"`
    if [[ ${homeIsFound} == true ]]; then
        ret=${DOCKER__SEMICOLON_HOME}

        echo ${ret}
        
        return
    fi

    #Check if ';b' is found
    #If TRUE, then return with the original 'DOCKER__SEMICOLON_BACK'
    backIsFound=`checkForMatch_keyWord_within_string__func "${DOCKER__SEMICOLON_BACK}" "${string__input}"`
    if [[ ${backIsFound} == true ]]; then
        ret=${DOCKER__SEMICOLON_BACK}

        echo ${ret}

        return
    fi

    #Check if ';c' is found.
    #If FALSE, then return with the original 'string__input'.
    clearIsFound=`checkForMatch_keyWord_within_string__func "${DOCKER__SEMICOLON_CLEAR}" "${string__input}"`
    if [[ ${clearIsFound} == false ]]; then
        ret=${string__input}

        echo ${ret}
        
        return
    fi

    #If ';c' was found previously then, retrieve the substring which is on the right-side of the semi-colon ';'.
    #Remark:
    #   In case there were multiple ';c' issued and thus residing in 'string__input',...
    #   ...then just make sure to get the substring at the last semi-colon ';'.
    rightPart=`echo "${string__input}" | rev | cut -d";" -f1 | rev`

    rightPart_len=${#rightPart}

    #Get string without semicolon.
    #Remark:
    #   Please not that if result 'ret' contains any leading and trailing spaces,...
    #   ...then these spaces will be automatically omitted from the end result.
    ret=${rightPart:1:rightPart_len}

    #Output
    echo ${ret}
}

function get_theLast_xChars_ofString__func() {
    #Input args
    local string__input=${1}
    local numOfLastChars__input=${2}

    #Define local variable
    local ret=`echo ${string__input: -numOfLastChars__input}`

    #Output
    echo ${ret}
}

function remove_trailing_char__func() {
    #Input args
    local string__input=${1}
	local char__input=${2}

    #Get string without trailing specified char
	#REMARK:
	#	char__input: character to be removed
	#	REMARK: 
	#		Make sure to prepend escape-char '\' if needed
	#		For example: slash '/' prepended with escape-char becomes '\/')
	#	*: all of specified 'char__input' value
	#	$: start from the end
	local ret=`echo "${string__input}" | sed s"/${char__input}*$//g"`

    #Output
    echo ${ret}
}

function remove_whiteSpaces__func() {
    #Input args
    local orgString__input=${1}
    
    #Remove white spaces
    local ret=`echo -e "${orgString__input}" | tr -d "[:blank:]"`

    #OUTPUT
    echo ${ret}
}




#---SUBROUTINES
trap CTRL_C__sub INT

CTRL_C__sub() {
    docker__exitFunc "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_2}"
}



docker__environmental_variables__sub() {
    #---Define PATHS
    docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})
    docker__parent_dir=${docker__current_dir%/*}    #gets one directory up
    if [[ -z ${docker__parent_dir} ]]; then
        docker__parent_dir="${DOCKER__SLASH_CHAR}"
    fi
    docker__current_folder=`basename ${docker__current_dir}`

    docker__development_tools_folder="development_tools"
    if [[ ${docker__current_folder} != ${docker__development_tools_folder} ]]; then
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}/${docker__development_tools_folder}
    else
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}
    fi

    docker__containerlist_tableinfo__filename="docker_containerlist_tableinfo.sh"
    docker__containerlist_tableinfo__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__containerlist_tableinfo__filename}

	docker__repolist_tableinfo__filename="docker_repolist_tableinfo.sh"
	docker__repolist_tableinfo__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__repolist_tableinfo__filename}

    compgen__query_w_autocomplete__filename="compgen_query_w_autocomplete.sh"
    compgen__query_w_autocomplete__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${compgen__query_w_autocomplete__filename}

    docker__readInput_w_autocomplete__filename="docker_readInput_w_autocomplete.sh"
    docker__readInput_w_autocomplete__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__readInput_w_autocomplete__filename}

    dirlist__readInput_w_autocomplete__filename="dirlist_readInput_w_autocomplete.sh"
    dirlist__readInput_w_autocomplete__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${dirlist__readInput_w_autocomplete__filename}

    docker__tmp_dir=/tmp
    compgen__query_w_autocomplete_out__filename="compgen_query_w_autocomplete.out"
    compgen__query_w_autocomplete_out__fpath=${docker__tmp_dir}/${compgen__query_w_autocomplete_out__filename}

    docker__readInput_w_autocomplete_out__filename="docker_readInput_w_autocomplete.out"
    docker__readInput_w_autocomplete_out__fpath=${docker__tmp_dir}/${docker__readInput_w_autocomplete_out__filename}

    dirlist__readInput_w_autocomplete_out__filename="dirlist_readInput_w_autocomplete.out"
    dirlist__readInput_w_autocomplete_out__fpath=${docker__tmp_dir}/${dirlist__readInput_w_autocomplete_out__filename}
    
    dirlist__src_ls_1aA_output__filename="dirlist_src_ls_1aA.output"
    dirlist__src_ls_1aA_output__fpath=${docker__tmp_dir}/${dirlist__src_ls_1aA_output__filename}
    dirlist__src_ls_1aA_tmp__filename="dirlist_src_ls_1aA.tmp"
    dirlist__src_ls_1aA_tmp__fpath=${docker__tmp_dir}/${dirlist__src_ls_1aA_tmp__filename}
    dirlist__dst_ls_1aA_output__filename="dirlist_dst_ls_1aA.output"
    dirlist__dst_ls_1aA_output__fpath=${docker__tmp_dir}/${dirlist__dst_ls_1aA_output__filename}
    dirlist__dst_ls_1aA_tmp__filename="dirlist_dst_ls_1aA.tmp"
    dirlist__dst_ls_1aA_tmp__fpath=${docker__tmp_dir}/${dirlist__dst_ls_1aA_tmp__filename}

    dclcau_lh_ls__filename="dclcau_lh_ls.sh"
    dclcau_lh_ls__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${dclcau_lh_ls__filename}
    dclcau_dc_ls__filename="dclcau_dc_ls.sh"
    dclcau_dc_ls__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${dclcau_dc_ls__filename}

    #OLD VERSION (is temporarily present for backwards compaitibility)
	docker__dockercontainer_dirlist__filename="dockercontainer_dirlist.sh"
	docker__dockercontainer_dirlist__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__dockercontainer_dirlist__filename}
	docker__localhost_dirlist__filename="localhost_dirlist.sh"
	docker__localhost_dirlist__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__localhost_dirlist__filename}
}



#---MAIN SUBROUTINE
main__sub() {
    docker__environmental_variables__sub
}



#---EXECUTE MAIN
main__sub
