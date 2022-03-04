#!/bin/bash
#---BOOLEAN CONSTANTS
DOCKER__TRUE=true
DOCKER__FALSE=false



#---CHARACTER CHONSTANTS
DOCKER__ASTERISK="\*"
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


#---COLOR CONSTANTS
DOCKER__NOCOLOR=$'\e[0;0m'

DOCKER__FG_BORDEAUX=$'\e[30;38;5;198m'
DOCKER__FG_BRIGHTPRUPLE=$'\e[30;38;5;141m'
DOCKER__FG_BRIGHTLIGHTPURPLE=$'\e[30;38;5;147m'
DOCKER__FG_DARKBLUE=$'\e[30;38;5;33m'
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
DOCKER__BG_ORANGE=$'\e[30;48;5;215m'
DOCKER__BG_LIGHTBLUE=$'\e[30;48;5;45m'
DOCKER__BG_LIGHTGREY=$'\e[30;48;5;246m'
DOCKER__BG_WHITE=$'\e[30;48;5;15m'



#---DOCKER RELATED CONSTANTS
DOCKER__GREPPATTERN_EXITED="Exited"

DOCKER__STATE_RUNNING="Running"
DOCKER__STATE_EXITED="Exited"
DOCKER__STATE_NOTFOUND="NotFound"



#---MENU CONSTANTS
DOCKER__TITLE="TIBBO"
DOCKER__A_ABORT="${DOCKER__FOURSPACES}b. Back"
DOCKER__ARROWUP="arrowUp"
DOCKER__ARROWDOWN="arrowDown"
DOCKER__CTRL_C_QUIT="${DOCKER__FOURSPACES}Quit (Ctrl+C)"
DOCKER__CTRL_C_COLON_QUIT="Ctrl+C: Quit"
DOCKER__EXITING_NOW="Exiting now..."
DOCKER__HORIZONTALLINE="---------------------------------------------------------------------"
DOCKER__LATEST="latest"
DOCKER__Q_QUIT="${DOCKER__FOURSPACES}q. Quit (Ctrl+C)"
DOCKER__QUIT_CTRL_C="Quit (Ctrl+C)"



#---NUMERIC CONSTANTS
DOCKER__LISTVIEW_NUMOFROWS=20
DOCKER__LISTVIEW_NUMOFCOLS=0

DOCKER__NINE=9
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
DOCKER__NUMOFLINES_10=10



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
function exit__func() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

    exit
}

function GOTO__func() {
	#Input args
    LABEL=$1
	
	#Define Command line
    cmd_line=$(sed -n "/$LABEL:/{:a;n;p;ba;};" $0 | grep -v ':$')
	
	#Execute Command line
    eval "${cmd_line}"
	
	#Exit Function
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
function checkIf_container_dir_exists__func() {
	#Input args
    local containerID__input=${1}
	local dir__input=${2}

	#Define variables
    local bin_bash_dir=/bin/bash
    local docker_exec_cmd="docker exec -t ${containerID__input} ${bin_bash_dir} -c"

    #Check if directory exists
    local ret_raw=`${docker_exec_cmd} "[ -d "${str__input}" ] && echo true || echo false"`

    #Remove carriage returns '\r' caused by '/bin/bash -c'
    local ret=`echo "${ret_raw}" | tr -d $'\r'`

    #Output
    echo ${ret}
}

function checkIf_localhost_dir_exists__func() {
	#Input args
	local dir__input=${1}

     #Check if directory exists
     if [[ -d ${dir__input} ]]; then
        echo true
     else
        echo false
     fi
}

function checkIf_dir_exists__func() {
    #Input args
    local containerID__input=${1}
    local dir__input=${2}

    #Check if dir exists
    local ret=false
    if [[ -z ${containerID__input} ]]; then
        ret=`checkIf_localhost_dir_exists__func "${dir__input}"`
    else
        ret=`checkIf_container_dir_exists__func "${containerID__input}" "${dir__input}"`
    fi

    #Output
    echo "${ret}"
}

function checkIf__dirname_of_two_paths_are_the_same__func() {
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

    #Compare both files
    local stdOutput=`diff ${file1__input} ${file2__input}`
    if [[ -z ${stdOutput} ]]; then
        echo "false"
    else
        echo "true"
    fi
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

function get_basename_from_specified_path__func() {
    #Input arg
    local fpath__input=${1}

    #Get basename (which is a file or folder)
    local ret=`echo ${fpath__input} | rev | cut -d"${DOCKER__SLASH}" -f1 | rev`

    #Output
    echo ${ret}
}

function get_output_from_file__func() {
    #Input args
    outputFpath__input=${1}

    #Read from file
    if [[ -f ${outputFpath__input} ]]; then
        ret=`cat ${outputFpath__input} | head -n1 | xargs`
    else
        ret=${DOCKER__EMPTYSTRING}
    fi

    #Output
    echo ${ret}
}



#---MOVE FUNCTIONS
function moveUp__func() {
    #Input args
    local numOfLines=${1}

    #Clear lines
    local counter=1
    while [[ ${counter} -le ${numOfLines} ]]
    do
        tput cuu1	#move UP with 1 line

        counter=$((counter+1))  #increment by 1
    done
}

function moveUp_and_cleanLines__func() {
    #Input args
    local numOfLines=${1}

    #Clear lines
    local xPos_curr=0

    if [[ ${numOfLines} != 0 ]]; then
        local counter=1
        while [[ ${counter} -le ${numOfLines} ]]
        do
            tput el1    #clear CURRENT line until BEGINNING of line
            tput cuu1	#move-UP 1 line
            tput el		#clear CURRENT line until END of line

            #Increment counter by 1
            counter=$((counter+1))
        done
    else    #
        tput el1
    fi

    #Get current x-position of cursor
    xPos_curr=`tput cols`
    #Move to the beginning of line
    tput cub ${xPos_curr}
}

function moveDown_and_cleanLines__func() {
    #Input args
    local numOfLines=${1}

    #Clear lines
    local counter=1
    while [[ ${counter} -le ${numOfLines} ]]
    do
        tput cud1	#move-DOWN 1 line
        tput el1	 #clear CURRENT line until BEGINNING of line

        #Increment counter by 1
        counter=$((counter+1))
    done
}

function moveDown_oneLine_then_moveUp_and_clean__func() {
    #Input args
    local numOfLines=${1}

    #Move-down 1 line
    tput cud1

    #Move-up and clean a specified number of times
    moveUp_and_cleanLines__func "${numOfLines}"
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

function show_leadingAndTrailingStrings_separatedBySpaces__func() {
    #Input args
    local leadStr_input=${1}
    local trailStr_input=${2}
    local maxStrLen_input=${3}

    #Define local variables
    local ONESPACE=" "

    #Get string 'without visiable' color characters
    local leadStr_input_wo_colorChars=`echo "${leadStr_input}" | sed "s,\x1B\[[0-9;]*m,,g"`
    local trailStr_input_wo_colorChars=`echo "${trailStr_input}" | sed "s,\x1B\[[0-9;]*m,,g"`

    #Get string length
    local leadStr_input_wo_colorChars_len=${#leadStr_input_wo_colorChars}
    local trailStr_input_wo_colorChars_len=${#trailStr_input_wo_colorChars}

    #Calculated the number of spaces to-be-added
    local numOf_spaces=$(( maxStrLen_input-(leadStr_input_wo_colorChars_len+trailStr_input_wo_colorChars_len) ))

    #Create a string containing only EMPTY SPACES
    local emptySpaces_string=`printf '%*s' "${numOf_spaces}" | tr ' ' "${ONESPACE}"`

    #Print text including Leading Empty Spaces
    echo -e "${leadStr_input}${emptySpaces_string}${trailStr_input}"
}

function show_errMsg_plainVersion__func() {
    #Input args
    local errMsg=${1}

    # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

    echo -e "${errMsg}" #error message

    # press_any_key__func
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

    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${DOCKER__CTRL_C_QUIT}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
}

function show_errMsg_with_menuTitle__func() {
    #Input args
    local menuTitle=${1}
    local errMsg=${2}

    #Show error-message
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${menuTitle}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    show_centered_string__func "${errMsg}" "${DOCKER__TABLEWIDTH}"
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    press_any_key__func

    CTRL_C__sub
}

function show_errMsg_without_menuTitle__func() {
    #Input args
    local errMsg=${1}
    local numOfLines=${2}

    moveDown_and_cleanLines__func "${numOfLines}"
    echo -e "${errMsg}"

    press_any_key__func
}



#---STRING FUNCTIONS
function checkForMatch_keyWord_within_string__func() {
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
}

function checkIf_lastChar_ofString_isHash__func() {
    #Input Args
    local string__input=${1}  
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
    local char_input=${1}
    local numOf_times=${2}

    #Duplicate 'char_input'
    local char_duplicated=`printf '%*s' "${numOf_times}" | tr ' ' "${char_input}"`

    #Print text including Leading Empty Spaces
    echo -e "${char_duplicated}"
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

function get_lastTwoChars_of_string__func() {
    #Input args
    local str_input=${1}

    #Define local variable
    local last2Chars=`echo ${str_input: -2}`

    #Output
    echo ${last2Chars}
}

function remove_trailing_char__func() {
    #Input args
    local str_input=${1}
	local char_input=${2}

    #Get string without trailing specified char
	#REMARK:
	#	char_input: character to be removed
	#	REMARK: 
	#		Make sure to prepend escape-char '\' if needed
	#		For example: slash '/' prepended with escape-char becomes '\/')
	#	*: all of specified 'char_input' value
	#	$: start from the end
	local str_output=`echo "${str_input}" | sed s"/${char_input}*$//g"`

    #Output
    echo ${str_output}
}

function remove_whiteSpaces__func() {
    #Input args
    local orgstring=${1}
    
    #Remove white spaces
    local outputstring=`echo -e "${orgstring}" | tr -d "[:blank:]"`

    #OUTPUT
    echo ${outputstring}
}




#---SUBROUTINES
trap CTRL_C__sub INT

CTRL_C__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

    exit 99
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

    docker__containerlist_tableinfo_filename="docker_containerlist_tableinfo.sh"
    docker__containerlist_tableinfo_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__containerlist_tableinfo_filename}

	docker__repolist_tableinfo_filename="docker_repolist_tableinfo.sh"
	docker__repolist_tableinfo_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__repolist_tableinfo_filename}

    docker__readInput_w_autocomplete_filename="docker_readInput_w_autocomplete.sh"
    docker__readInput_w_autocomplete_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__readInput_w_autocomplete_filename}

    docker__tmp_dir=/tmp
    docker__readInput_w_autocomplete_out_filename="docker__readInput_w_autocomplete.out"
    docker__readInput_w_autocomplete_out_fpath=${docker__tmp_dir}/${docker__readInput_w_autocomplete_out_filename}

    dirlist__readInput_w_autocomplete_out__filename="dirlist__readInput_w_autocomplete.out"
    dirlist__readInput_w_autocomplete_out__fpath=${docker__tmp_dir}/${dirlist__readInput_w_autocomplete_out__filename}

    dirlist__readInput_w_autocomplete_filename="dirlist_readInput_w_autocomplete.sh"
    dirlist__readInput_w_autocomplete_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${dirlist__readInput_w_autocomplete_filename}
    
    dirlist_ls_raw_tmp_filename="dirlist_ls_raw.tmp"
    dirlist_ls_raw_tmp_fpath=${docker__tmp_dir}/${dirlist_ls_raw_tmp_filename}
    dirlist_ls_raw_bck_tmp_filename="dirlist_ls_raw_bck.tmp"
    dirlist_ls_raw_bck_tmp_fpath=${docker__tmp_dir}/${dirlist_ls_raw_bck_tmp_filename}

    dclcau_lh_ls_filename="dclcau_lh_ls.sh"
    dclcau_lh_ls_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${dclcau_lh_ls_filename}
    dclcau_dc_ls_filename="dclcau_dc_ls.sh"
    dclcau_dc_ls_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${dclcau_dc_ls_filename}

    #OLD VERSION (is temporarily present for backwards compaitibility)
	docker__dockercontainer_dirlist_filename="dockercontainer_dirlist.sh"
	docker__dockercontainer_dirlist_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__dockercontainer_dirlist_filename}
	docker__localhost_dirlist_filename="localhost_dirlist.sh"
	docker__localhost_dirlist_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__localhost_dirlist_filename}
}



#---MAIN SUBROUTINE
main__sub() {
    docker__environmental_variables__sub
}



#---EXECUTE MAIN
main__sub
