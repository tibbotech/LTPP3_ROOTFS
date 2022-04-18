#!/bin/bash
#---BOOLEAN CONSTANTS
DOCKER__TRUE=true
DOCKER__FALSE=false

DOCKER__N="n"
DOCKER__Y="y"



#---CHARACTER CHONSTANTS
DOCKER__ASTERISK="*"
DOCKER__CARET="^"
DOCKER__COLON=":"
DOCKER__COMMA=","
DOCKER__DASH="-"
DOCKER__DOT="."
DOCKER__HASH="#"
DOCKER__HOOKLEFT="<"
DOCKER__HOOKRIGHT=">"
DOCKER__MINUS="-"
DOCKER__PLUS="+"
DOCKER__SEMICOLON=";"
DOCKER__SLASH="/"
DOCKER__UNDERSCORE="_"

DOCKER__DOUBLE_UNDERSCORE="${DOCKER__UNDERSCORE}${DOCKER__UNDERSCORE}"

DOCKER__ESCAPE_ASTERISK="\*"
DOCKER__ESCAPE_BACKSLASH="\\"
DOCKER__ESCAPE_HOOKLEFT="\<"
DOCKER__ESCAPE_HOOKRIGHT="\>"
DOCKER__ESCAPE_QUOTE="\""
DOCKER__ESCAPE_SLASH="\/"

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
DOCKER__FG_DEEPORANGE=$'\e[30;38;5;208m'
DOCKER__FG_REDORANGE=$'\e[30;38;5;203m'
DOCKER__FG_GREEN=$'\e[30;38;5;82m'
DOCKER__FG_GREEN85=$'\e[30;38;5;85m'
DOCKER__FG_GREEN114=$'\e[30;38;5;114m'
DOCKER__FG_GREEN155=$'\e[30;38;5;155m'
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
DOCKER__TABLEROWS=10



#---DOCKER RELATED CONSTANTS
DOCKER__PATTERN_EXITED="Exited"

DOCKER__STATE_RUNNING="Running"
DOCKER__STATE_EXITED="Exited"
DOCKER__STATE_NOTFOUND="NotFound"



#---ENV VARIABLES (WHICH ARE USED IN THE DOCKERFILE FILES)
DOCKER__CONTAINER_ENV1="CONTAINER_ENV1"
DOCKER__CONTAINER_ENV2="CONTAINER_ENV2"



#---EXIT CONSTANTS
DOCKER__EXITCODE_0=0    #no error
DOCKER__EXITCODE_99=99  #an error which tells the device to exit



#---FILE-RELATED CONSTANTS
DOCKER__FILE_LINK="link"
DOCKER__FILE_CHECKOUT="checkout"
DOCKER__FILE_LINKCHECKOUT_PROFILE="link_checkout_profile"
DOCKER__FILE_CACHE="cache"



#---FUNCTION-KEY CONSTANTS
DOCKER__ENUM_FUNC_F1="F1"
DOCKER__ENUM_FUNC_F2="F2"
DOCKER__ENUM_FUNC_F3="F3"
DOCKER__ENUM_FUNC_F4="F4"
DOCKER__ENUM_FUNC_F5="F5"
DOCKER__ENUM_FUNC_F6="F6"
DOCKER__ENUM_FUNC_F7="F7"
DOCKER__ENUM_FUNC_F8="F8"
DOCKER__ENUM_FUNC_F9="F9"
DOCKER__ENUM_FUNC_F10="F10"
DOCKER__ENUM_FUNC_F12="F12"
DOCKER__FUNC_O="O"
DOCKER__FUNC_P="P"
DOCKER__FUNC_Q="Q"
DOCKER__FUNC_R="R"
DOCKER__FUNC_S="S"
DOCKER__FUNC_SLB="["    #square-left-bracket (SLB)
DOCKER__FUNC_15="15"
DOCKER__FUNC_17="17"
DOCKER__FUNC_18="18"
DOCKER__FUNC_19="19"
DOCKER__FUNC_20="20"
DOCKER__FUNC_21="21"
DOCKER__FUNC_24="24"



#---GIT CONSTANTS
DOCKER__GIT_CACHE_MAX=50    #maximum number of entries for Git-Link and Git-Checkout



#---NUMERIC CONSTANTS
DOCKER__LINENUM_0=0
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
DOCKER__NUMOFLINES_12=12

DOCKER__NUMOFMATCH_0=0
DOCKER__NUMOFMATCH_1=1
DOCKER__NUMOFMATCH_10=10
DOCKER__NUMOFMATCH_20=20

DOCKER__TIMEOUT_3=3
DOCKER__TIMEOUT_5=5
DOCKER__TIMEOUT_10=10



#---PATTERN CONSTANTS
DOCKER__PATTERN_DOCKER_IO="docker.io"
DOCKER__PATTERN_REPOSITORY_TAG="repository:tag"



#---PHASE CONSTANTS
PHASE_SHOW_REMARKS=0
PHASE_SHOW_READINPUT=1
PHASE_SHOW_KEYINPUT_HANDLER=2



#---PRINT CONSTANTS
DOCKER__PREV="prev"
DOCKER__NEXT="next"



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
DOCKER__SEMICOLON_DELETE=";d"
DOCKER__SEMICOLON_HOME=";h"



#---REGEX CONSTANTS
DOCKER__REGEX_0_TO_9="[1-90]"
DOCKER__REGEX_0_TO_9_COMMA_DASH="[1-90,-]"



#---SED CONSTANTS
SED__ASTERISK="*"
SED__BACKSLASH="\\\\"
SED__DOT="\\."
SED__SLASH="\\/"

SED__RS=$'\x1E'
SED__STX=$'\x02'
SED__ETX=$'\x03'
SED_SUBST_SPACE="${SED__STX}space${SED__ETX}"

SED__DOUBLE_BACKSLASH=${SED__BACKSLASH}${SED__BACKSLASH}
SED__BACKSLASH_DOT="${SED__BACKSLASH}${SED__DOT}"

SED__HTTP="http"
SED__HXXP="hxxp"



#---SET CONSTANTS
DOCKER__REMOVE_ALL="REMOVE-ALL"



#---SPACE CONSTANTS
DOCKER__ONESPACE=" "
DOCKER__TWOSPACES=${DOCKER__ONESPACE}${DOCKER__ONESPACE}
DOCKER__THREESPACES=${DOCKER__TWOSPACES}${DOCKER__ONESPACE}
DOCKER__FOURSPACES=${DOCKER__TWOSPACES}${DOCKER__TWOSPACES}
DOCKER__FIVESPACES=${DOCKER__FOURSPACES}${DOCKER__ONESPACE}
DOCKER__TENSPACES=${DOCKER__FIVESPACES}${DOCKER__FIVESPACES}



#---CONSTANTS THAT MUST BE LOADED HERE!
#---MENU CONSTANTS
DOCKER__TITLE="TIBBO"
DOCKER__ARROWUP="arrowUp"
DOCKER__ARROWDOWN="arrowDown"
DOCKER__CTRL_C_COLON_QUIT="Ctrl+C: Quit"
DOCKER__EXITING_NOW="Exiting now..."
DOCKER__HORIZONTALLINE="---------------------------------------------------------------------"
DOCKER__LATEST="latest"

DOCKER__QUIT_CTRL_C="${DOCKER__FG_LIGHTGREY}Quit${DOCKER__NOCOLOR} (${DOCKER__FG_LIGHTGREY}Ctrl+C${DOCKER__NOCOLOR})"

DOCKER__FOURSPACES_B_BACK="${DOCKER__FOURSPACES}b. ${DOCKER__FG_LIGHTGREY}Back${DOCKER__NOCOLOR}"
DOCKER__FOURSPACES_C_CHOOSE="${DOCKER__FOURSPACES}c. ${DOCKER__FG_LIGHTGREY}Choose${DOCKER__NOCOLOR}"
DOCKER__FOURSPACES_F12_QUIT="${DOCKER__FOURSPACES}${DOCKER__ENUM_FUNC_F12}. ${DOCKER__FG_LIGHTGREY}Quit${DOCKER__NOCOLOR} (${DOCKER__FG_LIGHTGREY}Ctrl+C${DOCKER__NOCOLOR})"
DOCKER__FOURSPACES_Q_QUIT="${DOCKER__FOURSPACES}q. ${DOCKER__FG_LIGHTGREY}Quit${DOCKER__NOCOLOR} (${DOCKER__FG_LIGHTGREY}Ctrl+C${DOCKER__NOCOLOR})"
DOCKER__FOURSPACES_QUIT_CTRL_C="${DOCKER__FOURSPACES}${DOCKER__FG_LIGHTGREY}Quit${DOCKER__NOCOLOR} (${DOCKER__FG_LIGHTGREY}Ctrl+C${DOCKER__NOCOLOR})"

DOCKER__FOURSPACES_F6_CHOOSE="${DOCKER__FOURSPACES}${DOCKER__ENUM_FUNC_F6}: ${DOCKER__FG_LIGHTGREY}Choose${DOCKER__NOCOLOR}"
DOCKER__FOURSPACES_F7_ADD="${DOCKER__FOURSPACES}${DOCKER__ENUM_FUNC_F7}: ${DOCKER__FG_LIGHTGREY}Add${DOCKER__NOCOLOR}"
DOCKER__FOURSPACES_F8_DEL="${DOCKER__FOURSPACES}${DOCKER__ENUM_FUNC_F8}: ${DOCKER__FG_LIGHTGREY}Del${DOCKER__NOCOLOR}"
DOCKER__FOURSPACES_F8_DEL+=" (${DOCKER__FG_LIGHTGREY}e.g.${DOCKER__NOCOLOR}, ${DOCKER__FG_LIGHTGREY}1,3,4${DOCKER__NOCOLOR}, ${DOCKER__FG_LIGHTGREY}2${DOCKER__NOCOLOR}, ${DOCKER__FG_LIGHTGREY}5-0${DOCKER__NOCOLOR})"

DOCKER__ONESPACE_PREV="${DOCKER__ONESPACE}${DOCKER__HOOKLEFT} ${DOCKER__FG_LIGHTGREY}${DOCKER__PREV}${DOCKER__NOCOLOR}"
DOCKER__ONESPACE_NEXT="${DOCKER__FG_LIGHTGREY}${DOCKER__NEXT}${DOCKER__NOCOLOR} ${DOCKER__HOOKRIGHT}${DOCKER__ONESPACE}"

DOCKER__CONFIGURED="(${DOCKER__FG_LIGHTGREY}configured${DOCKER__NOCOLOR})"



#---WEB CONSTANTS
DOCKER__HTTP_200=200



#---VARIABLES
docker__images_cmd="docker images"
docker__ps_a_cmd="docker ps -a"



#---EXTERN VARIABLES
#---------------------------------------------------------------------
#***WARNING***
#   Extern variables can be called from anywhere. 
#   Therefore, use it with caution.
#---------------------------------------------------------------------
extern__ret=${DOCKER__EMPTYSTRING}



#---SPECIFAL FUNCTIONS
function cursor_hide__func() {
    printf '\e[?25l'
}
function cursor_show__func() {
    printf '\e[?25h'
}

function enable_expansion__func() {
    set +f
}
function disable_expansion__func() {
    set -f
}

function enable_keyboard_input__func() {
    stty echo
}
function disable_keyboard_input__func() {
    stty -echo
}

function exit__func() {
    #Input args
    exitCode__input=${1}
    numOfLines__input=${2}

    #Turn-on Expansion
    enable_expansion__func
    
    #Show mouse cursor
    cursor_show__func

    #Enable keyboard-input
    enable_keyboard_input__func

    #Move-down cursor
    moveDown_and_cleanLines__func "${numOfLines__input}"

    #Exit with code
    exit ${exitCode__input}
}

function goto__func() {
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
    #Input args
    local timeout__input=${1}
    local prepend_numOfLines__input=${2}
    local append_numOfLines__input=${3}

	#Initialize variables
	local keyInput=""
	local tCounter=0
    local timeout=${timeout__input}
    if [[ -z ${timeout} ]]; then
        timeout=${DOCKER__TIMEOUT_10}
    fi
    local prepend_numOfLines=${prepend_numOfLines__input}
    if [[ -z ${prepend_numOfLines} ]]; then
        prepend_numOfLines=${DOCKER__NUMOFLINES_1}
    fi
    local append_numOfLines=${append_numOfLines__input}
    if [[ -z ${append_numOfLines} ]]; then
        append_numOfLines=${DOCKER__NUMOFLINES_1}
    fi

	#Show Press Any Key message with count-down
	moveDown_and_cleanLines__func "${prepend_numOfLines}"
	while [[ ${tCounter} -le ${timeout} ]];
	do
		delta_tcounter=$(( ${timeout} - ${tCounter} ))

		echo -e "\rPress (a)bort or any key to continue... (${delta_tcounter}) \c"
		read -N1 -t1 -rs keyInput

		if [[ ! -z "${keyInput}" ]]; then
			if [[ "${keyInput}" == "a" ]] || [[ "${keyInput}" == "A" ]]; then
				exit
			else
				break
			fi
		fi
		
		tCounter=$((tCounter+1))
	done
	moveDown_and_cleanLines__func "${append_numOfLines}"
}

function confirmation_w_timer__func() {
    #Input args
    local timeout__input=${1}
    local prepend_numOfLines__input=${2}
    local append_numOfLines__input=${3}

    #Define constants
    local ECHOMSG_DO_YOU_WISH_TO_CONTINUE="Do you wish to continue"
    local ECHOMSG_Y_SLASH_N="${DOCKER__Y}/${DOCKER__N}"


	#Initialize variables
	local ret=${DOCKER__EMPTYSTRING}
	local tCounter=0
    local timeout=${timeout__input}
    if [[ -z ${timeout} ]]; then
        timeout=${DOCKER__TIMEOUT_10}
    fi
    local prepend_numOfLines=${prepend_numOfLines__input}
    if [[ -z ${prepend_numOfLines} ]]; then
        prepend_numOfLines=${DOCKER__NUMOFLINES_1}
    fi
    local append_numOfLines=${append_numOfLines__input}
    if [[ -z ${append_numOfLines} ]]; then
        append_numOfLines=${DOCKER__NUMOFLINES_1}
    fi
    local after_confirmation_append_numOfLines=$((append_numOfLines - 1))


    #Hide cursor
    cursor_hide__func

	#Show Press Any Key message with count-down
	moveDown_and_cleanLines__func "${prepend_numOfLines}"
	while [[ ${tCounter} -le ${timeout} ]];
	do
		delta_tcounter=$(( ${timeout} - ${tCounter} ))

		read -N1 -t1 -r -p "${ECHOMSG_DO_YOU_WISH_TO_CONTINUE} (${delta_tcounter}) (${ECHOMSG_Y_SLASH_N})? " ret

		if [[ ! -z "${ret}" ]]; then
			if [[ "${ret}" =~ [yn] ]]; then
                moveDown_and_cleanLines__func "${after_confirmation_append_numOfLines}"

				break
			else
                if [[ "${ret}" == "${DOCKER__ENTER}" ]]; then
				    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                else
                    moveToBeginning_and_cleanLine__func
                fi
			fi
        else
            moveToBeginning_and_cleanLine__func
		fi
		
		tCounter=$((tCounter+1))
	done
	moveDown_and_cleanLines__func "${append_numOfLines}"

    #Check if 'ret' is an Empty String.
    #If true, then set 'ret = n'
    if [[ -z ${ret} ]]; then
        ret="${DOCKER__N}"
    fi

    #Hide cursor
    cursor_show__func

    #Update 'extern__ret'
    #Remark:
    #   This extern variable can be called from anywhere. Therefore, use it with caution.
    extern__ret=${ret}
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
        local stdOutput2=`echo ${stdOutput} | grep -w "${DOCKER__PATTERN_EXITED}"`
        if [[ ! -z ${stdOutput2} ]]; then   #contains data
            echo "${DOCKER__STATE_EXITED}"
        else    #contains NO data
            echo "${DOCKER__STATE_RUNNING}"
        fi
    fi
}

function createAndWrite_data_to_cacheFiles_ifNotExist__func() {
    #Input args
    local link_cache_fpath__input=${1}
    local checkout_cache_fpath__input=${2}
    local linkCheckoutProfile_cache_Fpath=${3}
    local dockerfile_fpath__input=${4}
    local exported_env_var_fpath__input=${5}

    #Get the git-link from file 'exported_env_var_fpath__input'
    local git_link=`retrieve_env_var_link_from_file__func "${dockerfile_fpath__input}" "${exported_env_var_fpath__input}"`

    #Get the git-checkout from file 'exported_env_var_fpath__input'
    local git_checkout=`retrieve_env_var_checkout_from_file__func "${dockerfile_fpath__input}" "${exported_env_var_fpath__input}"`

    #Check if file 'link_cache_fpath__input' is exists
    #Renark:
    #   If not present, then:
    #       Write the retrieved git-link to cache 'dockerfile_fpath__input'
    if [[ ! -f ${link_cache_fpath__input} ]]; then
        echo ${git_link} > ${link_cache_fpath__input}
    fi

    #Check if file 'checkout_cache_fpath__input' is exists
    #Renark:
    #   If not present, then:
    #       Write the retrieved git-checkout to cache 'dockerfile_fpath__input'
    if [[ ! -f ${checkout_cache_fpath__input} ]]; then
        echo ${git_checkout} > ${checkout_cache_fpath__input}
    fi

    #Check if file 'checkout_cache_fpath__input' is exists
    #Renark:
    #   If not present, then:
    #       Write the retrieved git-link & checkout to cache 'dockerfile_fpath__input'
    if [[ ! -f ${linkCheckoutProfile_cache_Fpath} ]]; then
        echo "${git_link}${DOCKER__ONESPACE}${git_checkout}" > ${linkCheckoutProfile_cache_Fpath}
    fi
}

function generate_cache_filenames_basedOn_specified_repositoryTag__func() {
    #Input args
    local cache_dir__input=${1}
    local dockerfile_fpath__input=${2}

    #Check if directory exist
    #If false, then create directory
    if [[ ! -d ${cache_dir__input} ]]; then
        mkdir -p ${cache_dir__input}
    fi

    #Get repository:tag from file
    if [[ ! -f ${dockerfile_fpath__input} ]]; then
        return
    fi

    #Get the repository:tag from 'dockerfile_fpath__input'
    local dockerfile_fpath_repositoryTag=`retrieve_repositoryTag_from_dockerfile__func "${dockerfile_fpath__input}"`

    #Replace ':' with '_-_'
    local repositoryTag_subst=`echo "${dockerfile_fpath_repositoryTag}" | sed "s/${DOCKER__COLON}/${DOCKER__DOUBLE_UNDERSCORE}/g"`

    #Create cache-filenames
    local link_cache_filename="${repositoryTag_subst}${DOCKER__DOUBLE_UNDERSCORE}${DOCKER__FILE_LINK}.${DOCKER__FILE_CACHE}"
    local checkout_cache_filename="${repositoryTag_subst}${DOCKER__DOUBLE_UNDERSCORE}${DOCKER__FILE_CHECKOUT}.${DOCKER__FILE_CACHE}"
    local linkCheckoutProfile_cache_filename="${repositoryTag_subst}${DOCKER__DOUBLE_UNDERSCORE}${DOCKER__FILE_LINKCHECKOUT_PROFILE}.${DOCKER__FILE_CACHE}"

    #Create cache-fullpaths
    local link_cache_fpath=${cache_dir__input}/${link_cache_filename}
    local checkout_cache_fpath=${cache_dir__input}/${checkout_cache_filename}
    local linkCheckoutProfile_cache_fpath=${cache_dir__input}/${linkCheckoutProfile_cache_filename}

    #Update 'ret'
    #Remarks:
    #   'ret' contains 2 outputs which are separated by  a 'SED__RS'.
    #   1. 'link_cache_fpath'
    #   2. 'checkout_cache_fpath'
    #   3. 'linkCheckoutProfile_cache_fpath'
    ret="${link_cache_fpath}${SED__RS}${checkout_cache_fpath}${SED__RS}${linkCheckoutProfile_cache_fpath}"

    #Output
    echo "${ret}"
}



#---ESCAPE-KEY RELATED FUNCTIONS
function functionKey_detection__func() {
    #Define variables
    local ret=${DOCKER__EMPTYSTRING}

    # Flush "^[" within 0.1 sec timeout.
    read -rsn1 -t 0.1 key2
    
    #Check if 2nd key is the kapital letter 'O'
    case "${key2}" in
        "${DOCKER__FUNC_O}")
            #Check if the 3rd key is any of the following letters
            read -rsn1 -t 0.1 key3
            case "${key3}" in
                "${DOCKER__FUNC_P}")    #F1
                    ret=${DOCKER__ENUM_FUNC_F1}
                    ;;
                "${DOCKER__FUNC_Q}")    #F2
                    ret=${DOCKER__ENUM_FUNC_F2}
                    ;;
                "${DOCKER__FUNC_R}")    #F3
                    ret=${DOCKER__ENUM_FUNC_F3}
                    ;;
                "${DOCKER__FUNC_S}")    #F4
                    ret=${DOCKER__ENUM_FUNC_F4}
                    ;;
                *)
                    ;;
            esac
            ;;
        "${DOCKER__FUNC_SLB}")
            #Check if the following 2 keys are any of the following 2-digit numbers
            read -rsn2 -t 0.1 key3
            case "${key3}" in
                "${DOCKER__FUNC_15}")    #F5
                    ret=${DOCKER__ENUM_FUNC_F5}
                    ;;
                "${DOCKER__FUNC_17}")    #F6
                    ret=${DOCKER__ENUM_FUNC_F6}
                    ;;
                "${DOCKER__FUNC_18}")    #F7
                    ret=${DOCKER__ENUM_FUNC_F7}
                    ;;
                "${DOCKER__FUNC_19}")    #F8
                    ret=${DOCKER__ENUM_FUNC_F8}
                    ;;
                "${DOCKER__FUNC_20}")    #F9
                    ret=${DOCKER__ENUM_FUNC_F9}
                    ;;
                "${DOCKER__FUNC_21}")    #F10
                    ret=${DOCKER__ENUM_FUNC_F10}
                    ;;
                "${DOCKER__FUNC_24}")    #F12
                    ret=${DOCKER__ENUM_FUNC_F12}
                    ;;
                *)
                    ;;
            esac
    esac

    #Flush "stdin" with 0.1  sec timeout.
    read -rsn5 -t 0.1

    #Output
    echo "${ret}"
}



#---FILE-RELATED FUNCTIONS
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
    echo -e "${ret}"
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
    echo -e "${ret}"
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
    echo -e "${ret}"
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
    echo -e "${ret}"
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
    echo -e "${ret}"
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
    echo -e "${ret}"
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
    echo -e "${ret}"
}

function write_data_to_file__func() {
    #Input args
    string__input=${1}
    targetFpath__input=${2}

    #Write
    echo "${string__input}" > ${targetFpath__input}
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

    if [[ ${numOfLines__input} -ne ${DOCKER__NUMOFMATCH_0} ]]; then
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
    else
        tput el1
    fi

    #Get current x-position of cursor
    xPos_curr=`tput cols`

    #Move to the beginning of line
    tput cub ${xPos_curr}
}

function moveToBeginning_and_cleanLine__func() {
    #Clean to begining of line
    tput el1

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
    local mainMsg_wo_regEx=$(printf "%s" "$mainMsg" | sed "s/$(echo -e "\e")[^m]*m//g")
    local mainMsg_wo_regEx_len=${#mainMsg_wo_regEx}
    local keyInput_wo_regEx=$(printf "%s" "$keyInput" | sed "s/$(echo -e "\e")[^m]*m//g")
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

function show_dirContent__func() {
#---Input args
    local dir__input=${1}
    local menuTitle__input=${2}
    local remark__input=${3}
    local info__input=${4}
    local menuOptions__input=${5}
    local errMsg__input=${6}
    local readDialog__input=${7}
    local pattern1__input=${8}
    local pattern2__input=${9}
    local outputFpath__input=${10}
    local table_index_max__input=${11}



#---Define variables
    local fpath_arr=()
    local fpath_arrIndex=0
    local fpath_arrLen=0
    local fpath_arrItem=${DOCKER__EMPTYSTRING}

    local filteredFiles_arr=()
    local filteredFiles_arrIndex=0
    local filteredFiles_arrIndex_sel=0
    local filteredFiles_arrLen=0
    local filteredFiles_filename=${DOCKER__EMPTYSTRING}

    local filename=${DOCKER__EMPTYSTRING}
    local filename_base=${DOCKER__EMPTYSTRING}
    local keyOutput=${DOCKER__EMPTYSTRING}
    local pattern1_result=${DOCKER__EMPTYSTRING}
    local pattern2_result=${DOCKER__EMPTYSTRING}
    local ret=${DOCKER__EMPTYSTRING}

    local table_index=0
    local table_index_base=0
    local table_index_base_try_next=0
    local table_index_chosen=${DOCKER__EMPTYSTRING}

    local flag_main_whileLoop_setTo_break=false
    local flag_forLoop_setTo_break=false



#---Remove file (if present)
    if [[ -f ${outputFpath__input} ]]; then
        rm ${outputFpath__input}
    fi



#---Calculate num-of-lines of input-args
    #Each input-args
    menuTitle_numOfLines=`echo -e "${menuTitle__input}" | sed '/^\s*$/d' | wc -l`
    remark_numOfLines=`echo -e "${remark__input}" | sed '/^\s*$/d' | wc -l`
    info_numOfLines=`echo -e "${info__input}" | sed '/^\s*$/d' | wc -l`
    menuOptions_numOfLines=`echo -e "${menuOptions__input}" | sed '/^\s*$/d' | wc -l`
    readDialog_numOfLines=`echo -e "${readDialog__input}" | sed '/^\s*$/d' | wc -l`

    #fixed objects
    fixed_numOfLines=${DOCKER__NUMOFLINES_4}    #due to a fixed number of horizontal and empty lines
    if [[ ${remark_numOfLines} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
        fixed_numOfLines=$((fixed_numOfLines + 1))  #due to the preceding horizontal line
    fi
    if [[ ${info_numOfLines} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
        fixed_numOfLines=$((fixed_numOfLines + 1))  #due to the preceding horizontal line
    fi
    if [[ ${menuOptions_numOfLines} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
        fixed_numOfLines=$((fixed_numOfLines + 1))  #due to the preceding horizontal line
    fi

    #total
    tot_numOfLines=$((menuTitle_numOfLines + remark_numOfLines + info_numOfLines + menuOptions_numOfLines + readDialog_numOfLines + fixed_numOfLines + table_index_max__input))



#---Define 'prev' and 'next' variables
    local prev_only_print="${DOCKER__ONESPACE_PREV}"

    local oneSpacePrev_len=`get_stringlen_wo_regEx__func "${DOCKER__ONESPACE_PREV}"`
    local oneSpaceNext_len=`get_stringlen_wo_regEx__func "${DOCKER__ONESPACE_NEXT}"`
    local space_between_prev_and_next_len=$(( DOCKER__TABLEWIDTH - (oneSpacePrev_len + oneSpaceNext_len) - 1 ))
    local space_between_prev_and_next=`duplicate_char__func "${DOCKER__ONESPACE}" "${space_between_prev_and_next_len}"`
    local prev_spaces_next_print="${DOCKER__ONESPACE_PREV}${space_between_prev_and_next}${DOCKER__ONESPACE_NEXT}"

    local docker_space_between_leftBoundary_and_next_len=$(( DOCKER__TABLEWIDTH - oneSpacePrev_len - 1 ))
    local docker_space_between_leftBoundary_and_next=`duplicate_char__func "${DOCKER__ONESPACE}" "${docker_space_between_leftBoundary_and_next_len}"`
    local next_only_print="${docker_space_between_leftBoundary_and_next}${DOCKER__ONESPACE_NEXT}"



#---Store directory content in array'
    #Remark: 
    #   Also make sure to substitute '<space>' with '${STX}space${ETX}'
    readarray -t fpath_arr < <(find ${dir__input} -maxdepth 1 -type f | \
                                sort | \
                                sed "s/${DOCKER__ONESPACE}/${SED_SUBST_SPACE}/g")

    #Get 'fpath_arrLen'
    fpath_arrLen=${#fpath_arr[@]}

#---Show directory content
    while true
    do
#-------Show cursor
        cursor_hide__func

#-------Disable keyboard-input
        disable_keyboard_input__func
        
#-------Show menu-title
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        show_centered_string__func "${menuTitle__input}" "${DOCKER__TABLEWIDTH}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        if [[ ! -z ${fpath_arr[@]} ]]; then
            #Initialization
            flag_forLoop_setTo_break=false
            filteredFiles_arr=()
            filteredFiles_arrIndex=0
            fpath_arrIndex=0
            table_index_chosen=0
            table_index=0

            #Loop thru array
            for fpath_arrItem in "${fpath_arr[@]}"
            do
                #Narrow down the result by implementing 'pattern1__input' and 'pattern2__input'
                #Both patterns must be found within the path 'fpath_arrItem'
                pattern1_result=`cat ${fpath_arrItem} | grep "${pattern1__input}"`
                pattern2_result=`cat ${fpath_arrItem} | grep "${pattern2__input}"`
                if [[ ! -z ${pattern1_result} ]] || [[ ! -z ${pattern2_result} ]]; then
                    #Increment array-index
                    fpath_arrIndex=$((fpath_arrIndex + 1))

                    #Turn
                    if [[ ${fpath_arrIndex} -gt ${table_index_base} ]]; then
                        #increment table-index
                        table_index=$((table_index + 1))

                        #Check if 'table_index = table_index_max__input'
                        #Remark:
                        #   If true, set 'table_index = 0'
                        if [[ ${table_index} -eq ${table_index_max__input} ]]; then
                            table_index=${DOCKER__NUMOFMATCH_0}

                            flag_forLoop_setTo_break=true
                        fi

                        #Get filename without diectory
                        filename_base=`basename ${fpath_arrItem}`  
                    
                        #Convert 'SED_SUBST_SPACE' back to '<space>'
                        filename=`echo "${filename_base}" | sed "s/${SED_SUBST_SPACE}/${OCKER__ONESPACE}/g"`



                        #Add 'filename' to 'filteredFiles_arr'
                        #Remark:
                        #   This array contains only data which matches both patterns...
                        #   ...'pattern1__input' and 'pattern2__input'.
                        if [[ ${table_index} -eq ${DOCKER__NUMOFMATCH_0} ]]; then   #when a turnover has happened
                            filteredFiles_arrIndex=$((table_index_max__input - 1))
                        else    #in normal conditions
                            filteredFiles_arrIndex=$((table_index - 1))
                        fi
                        filteredFiles_arr[${filteredFiles_arrIndex}]=${filename}



                        #Define and set 'line_print'
                        if [[ ${table_index} -ne ${DOCKER__NUMOFMATCH_0} ]]; then
                            line_print="${DOCKER__FOURSPACES}${table_index}. ${filename}"
                        else
                            line_print="${DOCKER__THREESPACES}${DOCKER__FG_LIGHTGREY}${DOCKER__LINENUM_1}${DOCKER__NOCOLOR}${table_index}. ${filename}"
                        fi
                
                        #Show filename
                        echo -e "${line_print}"
                    fi
                fi

                #Prevously 'table_index' was set to '0'.
                #This means that the maximum number of items allowed to-be-shown has been reached.
                #In this case, break the for-loop.
                if [[ ${flag_forLoop_setTo_break} == true ]]; then
                    break
                fi
            done    #end of for
        else
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
            show_centered_string__func "${errMsg__input}" "${DOCKER__TABLEWIDTH}"
        fi



#-------Fill up table with Empty Lines (if needed)
        #Check if 'flag_forLoop_setTo_break = false'
        #Remark:
        #   Remember that if 'flag_forLoop_setTo_break = true', then...
        #   ...the for-loop was broken due to 'table_index = table_index_max__input'.
        if [[ ${flag_forLoop_setTo_break} == false ]]; then
            while [[ ${table_index} -lt ${table_index_max__input} ]]
            do
                #increment line-number
                table_index=$((table_index + 1))

                #Print an Empty Line
                echo "${DOCKER__EMPTYSTRING}"
            done
        fi



#------Show 'prev' and 'next'
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        #Calculate the 'table_index_base_try_next'
        #Remark:
        #   By doing this it can be determined whether the last-page has been reached or not.
        table_index_base_try_next=$((table_index_base + table_index_max__input))

        #Check if the specified file contains less than or equal to 10 lines
        if [[ ${fpath_arrLen} -le ${table_index_max__input} ]]; then #less than 10 lines
            #Don't show anything
            echo -e "${EMPTYSTRING}"
        else    #file contains more than 10 lines
            if [[ ${table_index_base} -eq ${DOCKER__NUMOFMATCH_0} ]]; then   #range 1-10
                echo -e "${next_only_print}"
            else    #all other ranges
                if [[ ${table_index_base_try_next} -ge ${fpath_arrLen} ]]; then  #last range value (e.g. 40-50), assuming 50 is the last-index
                    echo -e "${prev_only_print}"
                else   #range 10-20, 20-30, 30-40, etc.
                    echo -e "${prev_spaces_next_print}"
                fi
            fi
        fi



#-------Show info & menu-options
        # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        if [[ ! -z ${info__input} ]]; then
            duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
            echo -e "${info__input}"
        fi
        if [[ ! -z ${remark__input} ]]; then
            duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
            echo -e "${remark__input}"
        fi
        if [[ ! -z ${menuOptions__input} ]]; then
            duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
            echo -e "${menuOptions__input}"
        fi
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"


#-------Enable keyboard-input
        enable_keyboard_input__func

#-------Show cursor
        cursor_show__func



#-------Get array-length
        filteredFiles_arrLen=${#filteredFiles_arr[@]}



#-------Read-input
        while true
        do
            #Show read-input
            read -N1 -p "${readDialog__input} " table_index_chosen

            #Check if 'table_index_chosen' is a numeric value
            case "${table_index_chosen}" in
                ${DOCKER__ENTER})
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                    ;;
                ${DOCKER__ESCAPE_HOOKLEFT})
                    #Only decrement if 'table_index_base > table_index_max__input'
                    #Remark:
                    #   Notice that 'table_index_base_try_next' is used here and NOT 'table_index_base'
                    if [[ ${table_index_base_try_next} -gt ${table_index_max__input} ]]; then
                        table_index_base=$((table_index_base - table_index_max__input))

                        moveUp_and_cleanLines__func "${tot_numOfLines}"

                        break
                    else
                        moveToBeginning_and_cleanLine__func
                    fi

                    ;;
                ${DOCKER__ESCAPE_HOOKRIGHT})
                    #Only decrement if 'table_index_base_try_next < fpath_arrLen'
                    #Remark:
                    #   Notice that 'table_index_base_try_next' is used here and NOT 'table_index_base'
                    if [[ ${table_index_base_try_next} -lt ${fpath_arrLen} ]]; then
                        table_index_base=$((table_index_base + table_index_max__input))

                        moveUp_and_cleanLines__func "${tot_numOfLines}"

                        break
                    else
                        moveToBeginning_and_cleanLine__func
                    fi
                    ;;
                ${DOCKER__ESCAPEKEY})
                    moveToBeginning_and_cleanLine__func

                    keyOutput=`functionKey_detection__func "${docker__keyInput}"`
                    if [[ ${keyOutput} == ${DOCKER__ENUM_FUNC_F12} ]]; then
                        #Print read-input dialog
                        echo "${readDialog__input}"

                        #Exit
                        exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_2}"
                    fi
                    ;;
                *)
                    if [[ ${table_index_chosen} =~ [1-90] ]]; then
                        #IMPORTANT: If 'table_index_chosen = 0', then set 'table_index_chosen = table_index_max__input'
                        if [[ ${table_index_chosen} -eq ${DOCKER__NUMOFMATCH_0} ]]; then
                            table_index_chosen=${table_index_max__input}
                        fi

                        #Only take action if 'table_index_chosen =< filteredFiles_arrLen'
                        if [[ ${table_index_chosen} -le ${filteredFiles_arrLen} ]]; then
                            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_3}"

                            flag_main_whileLoop_setTo_break=true

                            break
                        else
                            moveToBeginning_and_cleanLine__func
                        fi             
                    else
                        moveToBeginning_and_cleanLine__func
                    fi
                    ;;
            esac
        done    #end of while

        #Check if 'flag_main_whileLoop_setTo_break = true'
        if [[ ${flag_main_whileLoop_setTo_break} == true ]]; then
            break
        fi
    done    #end of main while



#---Output
    #If 'table_index_chosen = 0', then set 'table_index_chosen = table_index_max__input'
    #Remark:
    #   This part is actually not necessary since it has been executed already previously.
    if [[ ${table_index_chosen} -eq ${DOCKER__NUMOFMATCH_0} ]]; then
        table_index_chosen=${table_index_max__input}
    fi

    #Convert to array-index
    #Remark:
    #   -1 is a correction due to array starting with 'index = 0'
    filteredFiles_arrIndex_sel=$(( table_index_chosen - 1 ))

    #Get the selected filename (with '${SED_SUBST_SPACE}')
    filteredFiles_filename="${filteredFiles_arr[filteredFiles_arrIndex_sel]}"

    #Get the fullpath
    ret=${dir__input}/${filteredFiles_filename}

    #Write to file
    echo "${ret}" > ${outputFpath__input}
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

function show_cmdOutput_w_menuTitle__func() {
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
    echo -e "${DOCKER__FOURSPACES_QUIT_CTRL_C}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
}

function show_errMsg_without_menuTitle_exit_func() {
    #Input args
    local msg__input=${1}
    local prepend_numOfLines__input=${2}
    local append_numOfLines__input=${3}

    #Move down and clean
    moveDown_and_cleanLines__func "${prepend_numOfLines__input}"
    
    #Print
    echo -e "${msg__input}"

    #Move down and clean
    moveDown_and_cleanLines__func "${append_numOfLines__input}"

    #Exit
    exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_0}"
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

    docker__ctrl_c__sub
}

function show_msg_w_menuTitle_only_func() {
    #Input args
    local menuTitle__input=${1}
    local msg__input=${2}
    local prepend_numOfLines__input=${3}
    local append_numOfLines__input=${4}

    #Prepend empty lines
    moveDown_and_cleanLines__func "${prepend_numOfLines__input}"

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
    moveDown_and_cleanLines__func "${append_numOfLines__input}"
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
    local prepend_numOfLines__input=${2}
    local confirmation_timeout__input=${3}
    local confirmation_prepend_numOfLines__input=${4}
    local confirmation_append_numOfLines__input=${5}

    #Move-down cursor
    moveDown_and_cleanLines__func "${prepend_numOfLines__input}"

    #Print
    echo -e "${msg__input}"

    #Show press-any-key dialog
    press_any_key__func "${confirmation_timeout__input}" \
                        "${confirmation_prepend_numOfLines__input}" \
                        "${confirmation_append_numOfLines__input}"
}

function show_msg_wo_menuTitle_w_confirmation__func() {
    #Input args
    local msg__input=${1}
    local prepend_numOfLines__input=${2}
    local confirmation_timeout__input=${3}
    local confirmation_prepend_numOfLines__input=${4}
    local confirmation_append_numOfLines__input=${5}

    #Move-down cursor
    moveDown_and_cleanLines__func "${prepend_numOfLines__input}"

    #Print
    echo -e "${msg__input}"

    #Show press-any-key dialog
    confirmation_w_timer__func "${confirmation_timeout__input}" \
                        "${confirmation_prepend_numOfLines__input}" \
                        "${confirmation_append_numOfLines__input}"
}

function show_menuTitle_only__func() {
    #Input args
    local menuTitle__input=${1}

    #Show list
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${menuTitle__input}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
}



#---STRING FUNCTIONS
function checkForMatch_of_pattern_within_string__func() {
    #Turn-off Expansion
    disable_expansion__func

    #Input Args
    local pattern__input=${1}
    local string__input=${2}

    #Find any match (not exact)
    local stdOutput=`echo ${string__input} | grep "${pattern__input}"`
    if [[ -z ${stdOutput} ]]; then  #no match
        echo "false"
    else    #match
        echo "true"
    fi

    #Turn-on Expansion
    enable_expansion__func
}

function checkForMatch_of_patterns_within_file__func() {
    #Turn-off Expansion
    disable_expansion__func

    #Input Args
    local pattern1__input=${1}
    local pattern2__input=${2}
    local dataFpath__input=${3}

    #Compose command line
    local cmd="cat ${dataFpath__input}"
    if [[ ! -z ${pattern1__input} ]]; then
        cmd+=" | grep -w \"${pattern1__input}\""
    fi
    if [[ ! -z ${pattern2__input} ]]; then
        cmd+=" | grep -w \"${pattern2__input}\""
    fi

    #Find match
    local isFound=`eval "${cmd}"`
    if [[ -z ${isFound} ]]; then  #no match
        echo "false"
    else    #match
        echo "true"
    fi

    #Turn-on Expansion
    enable_expansion__func
}

function checkForMatch_dockerCmd_result__func() {
    #Input Args
    local pattern__input=${1}
    local dockerCmd__input=${2}
    local dockerTableColno__input=${3}

    #Find any match (not exact)
    local stdOutput=`${dockerCmd__input} | awk -vcolNo=${dockerTableColno__input} '{print $colNo}' | grep -w ${pattern__input}`
    if [[ -z ${stdOutput} ]]; then  #no match
        echo "false"
    else    #match
        echo "true"
    fi
}

function delete_lineNum_from_file__func() {
    #Input args
    local lineNum__input=${1}
    local excludeVal__input=${2}
    local targetFpath__input=${3}

    #Get the 'line' for 'lineNum__input'
    local line=`retrieve_line_from_file__func "${lineNum__input}" "${targetFpath__input}"`

    #Delete line-number
    if [[ "${line}" != "${excludeVal__input}" ]]; then
        sed -i "${lineNum__input}d" ${targetFpath__input}
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
    echo -e "${ret}"
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
    homeIsFound=`checkForMatch_of_pattern_within_string__func "${DOCKER__SEMICOLON_HOME}" "${string__input}"`
    if [[ ${homeIsFound} == true ]]; then
        ret=${DOCKER__SEMICOLON_HOME}

        echo -e "${ret}"
        
        return
    fi

    #Check if ';b' is found
    #If TRUE, then return with the original 'DOCKER__SEMICOLON_BACK'
    backIsFound=`checkForMatch_of_pattern_within_string__func "${DOCKER__SEMICOLON_BACK}" "${string__input}"`
    if [[ ${backIsFound} == true ]]; then
        ret=${DOCKER__SEMICOLON_BACK}

        echo -e "${ret}"

        return
    fi

    #Check if ';c' is found.
    #If FALSE, then return with the original 'string__input'.
    clearIsFound=`checkForMatch_of_pattern_within_string__func "${DOCKER__SEMICOLON_CLEAR}" "${string__input}"`
    if [[ ${clearIsFound} == false ]]; then
        ret=${string__input}

        echo -e "${ret}"
        
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
    echo -e "${ret}"
}

function get_stringlen_wo_regEx__func() {
    #Input args
    local string__input=${1} 

    #Get string without color regex. 
    local string_wo_regEx=$(printf "%s" "${string__input}" | sed "s/$(echo -e "\e")[^m]*m//g")

    #Get length
    local string_wo_regEx_len=${#string_wo_regEx}

    #Output
    echo "${string_wo_regEx_len}"
}

function get_theLast_xChars_ofString__func() {
    #Input args
    local string__input=${1}
    local numOfLastChars__input=${2}

    #Define local variable
    local ret=`echo ${string__input: -numOfLastChars__input}`

    #Output
    echo -e "${ret}"
}

function insert_string_into_file__func() {
    #Input args
    local string__input=${1}
    local lineNum__input=${2}
    local targetFpath__input=${3}

    #Check if file contains data
    #If true, then insert
    #If false, then just write
    if [[ -s ${targetFpath__input} ]]; then #contains data
        sed -i "${lineNum__input}i${string__input}" ${targetFpath__input}
    else    #contains no data
        echo "${string__input}" > ${targetFpath__input}
    fi
}

function isNumeric__func() {
    #Input args
    local string__input=${1}

    #Define variables
    local re='^[0-9]+$'

    #Check if 'string__input' is numeric
    if [[ $string__input =~ $re ]] ; then
        echo true
    else
        echo false
    fi
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
    echo -e "${ret}"
}

function remove_whiteSpaces__func() {
    #Input args
    local orgString__input=${1}
    
    #Remove white spaces
    local ret=`echo -e "${orgString__input}" | tr -d "[:blank:]"`

    #Output
    echo -e "${ret}"
}

function replace_multiple_chars_with_single_char__func() {
    #Input args
    local string__input=${1}
    local charOld__input=${2}
    local charNew__input=${3}

    #Replace
    local ret=`echo "${string__input}" | sed "s/${charOld__input}${charOld__input}*/${charNew__input}/g"`

	#Output
	echo "${ret}"
}

function retrieve_data_in_col2_from_2Darray__func() {
	#Input args
	local col1str__input=${1}
    shift
    local dataArr__input=("$@")

	#Define variables
	local dataArrItem=${DOCKER__EMPTYSTRING}
	local ret=${DOCKER__EMPTYSTRING}
	local stdOutput=${DOCKER__EMPTYSTRING}

	for dataArrItem in "${dataArr__input[@]}"
	do
		#Check if'col1str__input' is found in 'dataArrItem'
		stdOutput=`echo "${dataArrItem}" | grep "${col1str__input}"`
		if [[ ! -z ${stdOutput} ]]; then	#match was found
			#Get data in the 2nd column
			ret=`echo "${stdOutput}" | awk '{print $2}'`

			break
		fi
	done

	#Output
	echo "${ret}"
}

function retrieve_line_from_file__func() {
    #Input args
    local lineNum__input=${1}
    local targetFpath__input=${2}

    #Retrieve line based on the specified 'lineNum__input'
    local ret=`sed "${lineNum__input}q;d" ${targetFpath__input}`

    #Output
    echo "${ret}"
}

function retrieve_lineNum_from_file__func() {
    #Input args
    local line__input=${1}
    local targetFpath__input=${2}

    #Retrieve line-number based on the specified 'line__input'
    local ret=`cat ${targetFpath__input} | grep -n "^${line__input}$" | cut -d":" -f1`
    
    #Check if 'ret' is an Empty String
    if [[ -z ${ret} ]]; then    #true
        ret=0
    fi

    #Output
    echo "${ret}"    
}

function retrieve_subStrings_delimited_by_trailing_specified_char__func() {
    #----------------------------------------------------------------------
    # Note: 
    #   If 'char__input' is NOT present within the specified 'string__input'
    #   then this function will output an Empty String. 
    #----------------------------------------------------------------------
    #Input args
    local string__input=${1}
    local char__input=${2}

    #Define variables
    local char_isFound=false
    local ret_left=${EMPTYSTRING}
    local ret_right=${EMPTYSTRING}
    local ret=${EMPTYSTRING}

    #Check if 'char__input' is found in 'string__input'
    local char_isFound=`checkForMatch_of_pattern_within_string__func "${char__input}" "${string__input}"`

    #Retrieve the sub-string which is on the left-side of the specified 'char__input'.
    if [[ ${char_isFound} == true ]]; then
        ret_left=`echo "${string__input}" | rev | cut -d"${char__input}" -f2- | rev`
        ret_right=`echo "${string__input}" | rev | cut -d"${char__input}" -f1 | rev`
    fi

    #Output
    #1. ret_left
    #2. ret_right
    #Both results are delimited by 'SED__RS'
    echo "${ret_left}${SED__RS}${ret_right}"
}

function skip_and_correct_unwanted_chars__func() {
    #---------------------------------------------------------------------
    # Remarks:
    #   The allowed chars are specified by the provided regex 
	#		'DOCKER__REGEX_0_TO_9_COMMA_DASH'.
    #   Should there be any unwanted char found within 'string__input', 
    #   	then this unwanted char is skipped.
    #---------------------------------------------------------------------
    #Input args
    local string__input=${1}

    #Define variables
	local char=${DOCKER__EMPTYSTRING}
	local dash_isFound=false
	local index=0
    local ret=${DOCKER__EMPTYSTRING}
    local string_noSpaces=${DOCKER__EMPTYSTRING}
	local string_filtered=${DOCKER__EMPTYSTRING}
	local string_final=${DOCKER__EMPTYSTRING}
	local string_leftOfComma=${DOCKER__EMPTYSTRING}
	local string_remain=${DOCKER__EMPTYSTRING}
	local string_singleComma=${DOCKER__EMPTYSTRING}
	local string_singleDash=${DOCKER__EMPTYSTRING}
	local string_leftOfDash=${DOCKER__EMPTYSTRING}
	local string_rightOfDash=${DOCKER__EMPTYSTRING}

    #Step 1.1: remove all spaces
    string_noSpaces=`echo "${string__input}" | sed 's/ //g'`
    
	#Step 1.2: remove all multiple commas
    string_singleComma=`echo "${string_noSpaces}" | sed "s/${DOCKER__COMMA}${DOCKER__COMMA}*/${DOCKER__COMMA}/g"`

	#Step 1.3: remove all multiple dashes
    string_singleDash=`echo "${string_singleComma}" | sed "s/${DOCKER__DASH}${DOCKER__DASH}*/${DOCKER__DASH}/g"`

    #Step 2: check each 'char' of 'string__input'..
	#...and filter out unwanted chars
    for (( index=1; index<=${#string_singleDash}; index++ ))
    do
		#Get 'char'
		char=${string_singleDash:index-1:1}

		#Check if 'char' is wanted or unwanted
		if [[ ${char} =~ ${DOCKER__REGEX_0_TO_9_COMMA_DASH} ]]; then	#wanted
			string_filtered="${string_filtered}${char}"
		fi
    done	#end of while

	#Step 3: Check each substring delimited by a comma ','
	string_remain=${string_filtered}

    while true
    do
        #Get the index(es) on the left-side of the comma ','
        string_leftOfComma=`echo "${string_remain}" | cut -d"${DOCKER__COMMA}" -f1`
        if [[ ! -z ${string_leftOfComma} ]]; then  #contains data
            #Check if a dash '-' is found in 'string_leftOfComma'
            dash_isFound=`checkForMatch_of_pattern_within_string__func "${DOCKER__DASH}" "${string_leftOfComma}"`
            if [[ ${dash_isFound} == false ]]; then #dash not found
				#Append to 'string_final'
				string_final="${string_final}${DOCKER__COMMA}${string_leftOfComma}"
            else    #dash was found
                #Get the minimum and maximum range values
                string_leftOfDash=`echo "${string_leftOfComma}" | cut -d"${DOCKER__DASH}" -f1`
                string_rightOfDash=`echo "${string_leftOfComma}" | cut -d"${DOCKER__DASH}" -f2`

				#Check if 'string_leftOfDash' OR 'string_rightOfDash' is contains data
				if [[ ! -z ${string_leftOfDash} ]] || [[ ! -z ${string_rightOfDash} ]]; then	#one or the other is true
					#Check if 'string_leftOfDash' is an Empty String
					if [[ -z ${string_leftOfDash} ]]; then	#true
						string_leftOfDash=${string_rightOfDash}
					fi

					#Check if 'string_rightOfDash' is an Empty String
					if [[ -z ${string_rightOfDash} ]]; then	#true
						string_rightOfDash=${string_leftOfDash}
					fi

					#Append to 'string_final' ONLY if 'string_leftOfDash <= string_rightOfDash'
					if [[ ${string_leftOfDash} -le ${string_rightOfDash} ]]; then
						string_final="${string_final}${DOCKER__COMMA}${string_leftOfDash}${DOCKER__DASH}${string_rightOfDash}"
					fi
				fi
            fi
        fi

        #Get the remaining indexes which are on the right-side of the comma ','
        string_remain=`echo "${string_remain}" | cut -d"${DOCKER__COMMA}" -f2-`

        #Exit when 'string_leftOfComma = string_remain'
        #Remark:
        #   This means that there are no comma's left anymore.
        if [[ "${string_remain}" == "${string_leftOfComma}" ]]; then
            break
        fi
    done

	#Remove leading comma
	ret=`echo "${string_final}" | sed "s/^\${DOCKER__COMMA}//g"`

	#remove trailing comma
	ret=`echo "${ret}" | sed "s/${DOCKER__COMMA}$//g"`

    #Output
    echo "${ret}"
}

function xtract_indexes_from_a_rangeAndOrGroup_in_descendingOrder__func() {
    #---------------------------------------------------------------------
    # Remarks:
    #   The allowed chars are specified by the provided regex 
	#		'DOCKER__REGEX_0_TO_9_COMMA_DASH'.
    #   Should there be any unwanted char found within 'string__input', 
    #   	then this unwanted char is skipped.
    #   The following 'string__input' notation are allowed:
    #       1,2,3,etc...
    #       1-10
    #       Combination: 1,2,3,1-10
    #---------------------------------------------------------------------
    #input args
    local string__input=${1}

    #Define variables
    local index_xtracted_arr=()
    local index_xtracted_arrIndex=0

    local dataArrItem=${DOCKER__EMPTYSTRING}
    local string_leftOfComma=${DOCKER__EMPTYSTRING}
    local string_remain=${DOCKER__EMPTYSTRING}
    local ret=${DOCKER__EMPTYSTRING}

    local counter=0
    local index_range_min=0
    local index_range_max=0
    local index_revalidated=0

    local dash_isFound=false

    #Recheck 'string__input' and allow only chars specified by regex 'DOCKER__REGEX_0_TO_9_COMMA_DASH'
    index_revalidated=`skip_and_correct_unwanted_chars__func "${string__input}" "${DOCKER__REGEX_0_TO_9_COMMA_DASH}"`

    #Initialization
    string_remain=${index_revalidated}

    #Extract the indexes from 'index_revalidated'
    while true
    do
        #Get the index(es) on the left-side of the comma ','
        string_leftOfComma=`echo "${string_remain}" | cut -d"${DOCKER__COMMA}" -f1`
        if [[ ! -z ${string_leftOfComma} ]]; then  #contains data
            #Check if a dash '-' is found in 'string_leftOfComma'
            dash_isFound=`checkForMatch_of_pattern_within_string__func "${DOCKER__DASH}" "${string_leftOfComma}"`
            if [[ ${dash_isFound} == false ]]; then #dash not found
                #Add 'string_leftOfComma' to array 'index_xtracted_arr'
                index_xtracted_arr[${index_xtracted_arrIndex}]=${string_leftOfComma}

                #Increment array-index
                index_xtracted_arrIndex=$((index_xtracted_arrIndex + 1))
            else    #dash was found
                #Get the minimum and maximum range values
                index_range_min=`echo "${string_leftOfComma}" | cut -d"${DOCKER__DASH}" -f1`
                index_range_max=`echo "${string_leftOfComma}" | cut -d"${DOCKER__DASH}" -f2`

                #Add indexes to array 'index_xtracted_arr' in the range of 'index_range_min to index_range_max'
                #Note: the values 'index_range_min' and 'index_range_max' included.
                for (( counter=${index_range_min}; counter<=${index_range_max}; counter+=1 )); do
                    #Add 'counter' to array 'index_xtracted_arr'
                    index_xtracted_arr[${index_xtracted_arrIndex}]=${counter}

                    #Increment array-index
                    index_xtracted_arrIndex=$((index_xtracted_arrIndex + 1))
                done
            fi
        fi

        #Get the remaining indexes which are on the right-side of the comma ','
        string_remain=`echo "${string_remain}" | cut -d"${DOCKER__COMMA}" -f2-`

        #Exit when 'string_leftOfComma = string_remain'
        #Remark:
        #   This means that there are no comma's left anymore.
        if [[ "${string_remain}" == "${string_leftOfComma}" ]]; then
            break
        fi
    done

    #Steps:
    #1. Read 'index_xtracted_arr' value: echo "${index_xtracted_arr[@]}"
    #2. Flip result from horizontal to vertical: xargs -n1
    #3. (IMPORTANT) Sort numerical values(n) in descending order(r):  sort -nr
    #4. remove double-entries(u): uniq
    #5. Flip result from vertical back to horizontal: xargs -n1
    ret=`echo "${index_xtracted_arr[@]}" | xargs -n1 | sort -rn | uniq | xargs`
    
    #Output as string
    echo "${ret}"
}



#---SUNPLUS-RELATED
function retrieve_env_var_checkout_from_file__func() {
    #Input args
    local dockerfile_fpath__input=${1}
    local exported_env_var_fpath__input=${2}

    #Get the repository:tag from 'dockerfile_fpath__input'
    local dockerfile_fpath_repositoryTag=`retrieve_repositoryTag_from_dockerfile__func "${dockerfile_fpath__input}"`

    #Get the Sunplus git-checkout from file 'exported_env_var_fpath__input'
    local ret=`cat ${exported_env_var_fpath__input} | grep -w "${dockerfile_fpath_repositoryTag}" | awk '{print $3}'`

    #Output
    echo "${ret}"
}
function retrieve_env_var_link_from_file__func() {
    #Input args
    local dockerfile_fpath__input=${1}
    local exported_env_var_fpath__input=${2}

    #Get the repository:tag from 'dockerfile_fpath__input'
    local dockerfile_fpath_repositoryTag=`retrieve_repositoryTag_from_dockerfile__func "${dockerfile_fpath__input}"`

    #Get the Sunplus git-link from file 'exported_env_var_fpath__input'
    local ret=`cat ${exported_env_var_fpath__input} | grep -w "${dockerfile_fpath_repositoryTag}" | awk '{print $2}'`

    #Output
    echo "${ret}"
}

function subst_string_with_another_string__func() {
    #Input args
    local string__input=${1}
    local oldSubString__input=${2}
    local newSubString__input=${3}

    #Substitute
    local ret=`echo "${string__input}" | sed "s/${oldSubString__input}/${newSubString__input}/g"`

    #Output
    echo "${ret}"
}

function update_exported_env_var__func() {
    #Input args
    local docker_arg1__input=${1}
    local docker_arg2__input=${2}
    local dockerfile_fpath__input=${3}
    local exported_env_var_fpath__input=${4}

    #Define Message Constants
    local ERRMSG_DOCKERFILE_NOT_FOUND="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: File Not Found '${dockerFile__input}'"
    local ERRMSG_EXPORTEDFILE_NOT_FOUND="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: File Not Found '${exported_env_var_fpath__input}'"

    #Get repository:tag from file
    local dockerfile_fpath_repositoryTag=`retrieve_repositoryTag_from_dockerfile__func "${dockerfile_fpath__input}"`

    #Check if file exist
    if [[ -f ${exported_env_var_fpath__input} ]]; then
        #Check if 'dockerfile_fpath_repositoryTag' is already present in file
        repository_tag_lineNum=`cat ${exported_env_var_fpath__input} | grep -nw "${dockerfile_fpath_repositoryTag}" | cut -d"${DOCKER__COLON}" -f1`
        #If present, then remove line containing the 'dockerfile_fpath_repositoryTag'
        if [[ ${repository_tag_lineNum} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
            #Check if 'docker_arg1__input' is an Empty String
            #Note: this means that 'docker_arg2__input' was changed.
            if [[ -z ${docker_arg1__input} ]]; then
                docker_arg1__input=`cat ${exported_env_var_fpath__input} | grep "${dockerfile_fpath_repositoryTag}" | awk '{print $2}'`
            fi

            #Check if 'docker_arg2__input' is an Empty String
            #Note: this means that 'docker_arg1__input' was changed.
            if [[ -z ${docker_arg2__input} ]]; then
                docker_arg2__input=`cat ${exported_env_var_fpath__input} | grep "${dockerfile_fpath_repositoryTag}" | awk '{print $3}'`
            fi

            #Remove current entry in 'exported_env_var.txt'
            sed -i "${repository_tag_lineNum}d" ${exported_env_var_fpath__input}
        fi

        #Add the new data to file 'docker__exported_env_var_fpath' as follows:
        #   dockerfile_fpath_repositoryTag<space>docker_arg1__input<space>DOCKER_ARG2__input
        #Remark:
        #   1. This data will be retrieved in 'docker__create_an_image_from_dockerfile.sh' and 'docker_create_images_from_dockerlist.sh'
        #   2. This means that 'input args' will not be used in those two mentioned files.
        echo "${dockerfile_fpath_repositoryTag} ${docker_arg1__input} ${docker_arg2__input}" >> ${exported_env_var_fpath__input}
    else
        show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_EXPORTEDFILE_NOT_FOUND}" "${DOCKER__NUMOFLINES_1}"
    fi
}

function retrieve_repositoryTag_from_dockerfile__func() {
    #Input args
    local dockerfile_fpath__input=${1}

    #Retrieve repository:tag
    local ret=`egrep -w "${DOCKER__PATTERN_REPOSITORY_TAG}" ${dockerfile_fpath__input} | cut -d"\"" -f2`

    #Output
    echo "${ret}"
}

#---WEB-RELATED
function checkIf_webLink_isAccessible__func() {
    #Input args
    local webLink__input=${1}
    local timeout__input=${2}

    #Check if 'webLink__input' is reachable
    local response=`timeout ${timeout__input} curl --silent --head --location --output /dev/null --write-out '%{http_code}' ${webLink__input}`
    if [[ ${response} -eq ${DOCKER__HTTP_200} ]]; then
        echo "true"
    else
        echo "false"
    fi
}



#---SUBROUTINES
trap docker__ctrl_c__sub INT

docker__ctrl_c__sub() {
    #Turn-on Expansion
    enable_expansion__func
    
    #Show mouse cursor
    cursor_show__func

    #Enable keyboard-input
    enable_keyboard_input__func

    #Exit with exit-code 99
    exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_2}"
}

docker__environmental_variables__sub() {
    #---Define PATHS
    docker__LTPP3_ROOTFS_development_tools__fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__LTPP3_ROOTFS_development_tools__dir=$(dirname ${docker__LTPP3_ROOTFS_development_tools__fpath})
    docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/
    docker__parentDir_of_LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS__dir%/*}    #move two directories up. This directory is the one-level higher than LTPP3_ROOTFS/
    if [[ -z ${docker__parentDir_of_LTPP3_ROOTFS__dir} ]]; then
        docker__parentDir_of_LTPP3_ROOTFS__dir="${DOCKER__SLASH_CHAR}"
    fi
    docker__docker__dir=${docker__parentDir_of_LTPP3_ROOTFS__dir}/docker
    docker__docker_cache__dir=${docker__docker__dir}/cache



    compgen__query_w_autocomplete__filename="compgen_query_w_autocomplete.sh"
    compgen__query_w_autocomplete__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${compgen__query_w_autocomplete__filename}

    dirlist__readInput_w_autocomplete__filename="dirlist_readInput_w_autocomplete.sh"
    dirlist__readInput_w_autocomplete__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${dirlist__readInput_w_autocomplete__filename}

    docker__containerlist_tableinfo__filename="docker_containerlist_tableinfo.sh"
    docker__containerlist_tableinfo__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__containerlist_tableinfo__filename}

    docker__create_an_image_from_dockerfile__filename="docker_create_an_image_from_dockerfile.sh"
    docker__create_an_image_from_dockerfile__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__create_an_image_from_dockerfile__filename}
    docker__create_images_from_dockerlist__filename="docker_create_images_from_dockerlist.sh"
    docker__create_images_from_dockerlist__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__create_images_from_dockerlist__filename}

    docker__git_menu__filename="git_menu.sh"
    docker__git_menu__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__git_menu__filename}

    docker__load__filename="docker_load.sh"
    docker__load__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__load__filename}

    docker__readInput_w_autocomplete__filename="docker_readInput_w_autocomplete.sh"
    docker__readInput_w_autocomplete__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__readInput_w_autocomplete__filename}

    docker__repo_link_checkout_menu_select__filename="docker_repo_link_checkout_menu_select.sh"
    docker__repo_link_checkout_menu_select__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__repo_link_checkout_menu_select__filename}

    docker__repo_linkCheckout_profile_menu_select__filename="docker_repo_linkCheckout_profile_menu_selec.sh"
    docker__repo_linkCheckout_profile_menu_select__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__repo_linkCheckout_profile_menu_select__filename}

	docker__repolist_tableinfo__filename="docker_repolist_tableinfo.sh"
	docker__repolist_tableinfo__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__repolist_tableinfo__filename}

    docker__show_choose_add_del_from_cache__filename="docker_show_choose_add_del_from_cache.sh"
    docker__show_choose_add_del_from_cache__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__show_choose_add_del_from_cache__filename}

    docker__save__filename="docker_save.sh"
    docker__save__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__save__filename}

    docker__ssh_to_host__filename="docker_ssh_to_host.sh"
    docker__ssh_to_host__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__ssh_to_host__filename}



    docker__LTPP3_ROOTFS_docker__dir=${docker__LTPP3_ROOTFS__dir}/docker
    docker__LTPP3_ROOTFS_docker_dockerfiles__dir=${docker__LTPP3_ROOTFS_docker__dir}/dockerfiles
    docker__dockerfile_ltps_sunplus_filename="dockerfile_ltps_sunplus"
    docker__dockerfile_ltps_sunplus_fpath=${docker__LTPP3_ROOTFS_docker_dockerfiles__dir}/${docker__dockerfile_ltps_sunplus_filename}

    docker__LTPP3_ROOTFS_docker_environment_dir=${docker__LTPP3_ROOTFS_docker__dir}/environment
    docker__exported_env_var_filename="exported_env_var.txt"
    docker__exported_env_var_fpath=${docker__LTPP3_ROOTFS_docker_environment_dir}/${docker__exported_env_var_filename}

    docker__LTPP3_ROOTFS_docker_environment_dir=${docker__LTPP3_ROOTFS_docker__dir}/environment
    docker__exported_env_var_default_filename="exported_env_var_default.txt"
    docker__exported_env_var_default_fpath=${docker__LTPP3_ROOTFS_docker_environment_dir}/${docker__exported_env_var_default_filename}



    docker__tmp_dir=/tmp
    compgen__query_w_autocomplete_out__filename="compgen_query_w_autocomplete.out"
    compgen__query_w_autocomplete_out__fpath=${docker__tmp_dir}/${compgen__query_w_autocomplete_out__filename}

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
    dclcau_lh_ls__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${dclcau_lh_ls__filename}
    dclcau_dc_ls__filename="dclcau_dc_ls.sh"
    dclcau_dc_ls__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${dclcau_dc_ls__filename}

    docker__enter_cmdline_out__filename="docker__enter_cmdline.out"
    docker__enter_cmdline_out__fpath=${docker__tmp_dir}/${docker__enter_cmdline_out__filename}

    docker__readInput_w_autocomplete_out__filename="docker_readInput_w_autocomplete.out"
    docker__readInput_w_autocomplete_out__fpath=${docker__tmp_dir}/${docker__readInput_w_autocomplete_out__filename}

    docker__show_choose_add_del_from_cache_out__filename="docker_show_choose_add_del_from_cache.out"
    docker__show_choose_add_del_from_cache_out__fpath=${docker__tmp_dir}/${docker__show_choose_add_del_from_cache_out__filename}

    docker__repo_link_checkout_menu_select_tmp__filname="docker_repo_link_checkout_menu_select.tmp"
    docker__repo_link_checkout_menu_select_tmp__fpath=${docker__tmp_dir}/${docker__repo_link_checkout_menu_select_tmp__filname}



    #OLD VERSION (is temporarily present for backwards compaitibility)
	docker__dockercontainer_dirlist__filename="dockercontainer_dirlist.sh"
	docker__dockercontainer_dirlist__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__dockercontainer_dirlist__filename}
	docker__localhost_dirlist__filename="localhost_dirlist.sh"
	docker__localhost_dirlist__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__localhost_dirlist__filename}
}

docker__create_exported_env_var_file__sub() {
    #Check if 'docker__exported_env_var.txt' is present
    if [[ ! -f ${docker__exported_env_var_fpath} ]]; then
        #Copy from 'docker__exported_env_var_default_fpath' to 'docker__exported_env_var_fpath'
        #Remark:
        #   Both paths are defined in 'docker__global__fpath'
        cp ${docker__exported_env_var_default_fpath} ${docker__exported_env_var_fpath}
    fi
}

# function docker__generate_cache_filename_basedOn_specified_repositoryTag__func() {
#     #Input args
#     local cache_dir__input=${1}
#     local repositoryTag__input=${2}

#     #Check if directory exist
#     #If false, then create directory
#     if [[ ! -d ${cache_dir__input} ]]; then
#         mkdir -p ${cache_dir__input}
#     fi

#     #Replace ':' with '_-_'
#     local cache_filename=`echo "${repositoryTag__input}" | sed "s/${DOCKER__COLON}/${DOCKER__UNDERSCORE_DASH_UNDERSCORE}/g"`

#     # #Check if file 'docker__gitlink.cache' is exists
#     # #Renark:
#     # #   If not present, then:
#     # #   1. Get the git-link from file 'docker__exported_env_var_fpath'
#     # #   2. Write the retrieved git-link to cache 'docker__sunplus_gitlink_cache__fpath'
#     # if [[ ! -f ${docker__sunplus_gitlink_cache__fpath} ]]; then
#     #     local sunplus_gitLink=`retrieve_env_var_link_from_file__func "${docker__dockerfile_ltps_sunplus_fpath}" "${docker__exported_env_var_fpath}"`

#     #     echo ${sunplus_gitLink} > ${docker__sunplus_gitlink_cache__fpath}
#     # fi

#     # #Check if file 'docker__git_checkout.cache' is exists
#     # #Renark:
#     # #   If not present, then:
#     # #   1. Get the git-checkout from file 'docker__exported_env_var_fpath'
#     # #   2. Write the retrieved git-checkout to cache 'docker__sunplus_gitcheckout_cache__fpath'
#     # if [[ ! -f ${docker__sunplus_gitcheckout_cache__fpath} ]]; then
#     #     local sunplus_gitCheckout=`retrieve_env_var_checkout_from_file__func "${docker__dockerfile_ltps_sunplus_fpath}" "${docker__exported_env_var_fpath}"`

#     #     echo ${sunplus_gitCheckout} > ${docker__sunplus_gitcheckout_cache__fpath}
#     # fi
# }



#---MAIN SUBROUTINE
main__sub() {
    docker__environmental_variables__sub

    docker__create_exported_env_var_file__sub
}



#---EXECUTE MAIN
main__sub
