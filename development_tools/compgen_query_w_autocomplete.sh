#!/bin/bash
#Input args
containerID__input=${1}
query__input=${2}
table_numOfRows__input=${3}
table_numOfCols__input=${4}
output_fPath__input=${5}



#---CHAR CONSTANTS
CR="$'\r'"
DASH="-"
DOT="."
DOTSLASH="./"
PIPE="|"
SLASH="/"

ESC_BCKSLASH="\\"
ESC_BCKSLASHDOT="\\."
ESC_BCKSLASH__ESC_DOT="\\\."    #used in grep
ESC_DOTBCKSLASH=".\\"

DOCKER__BACKSPACE=$'\b'
DOCKER__DEL=$'\x7e'
DOCKER__ENTER=$'\x0a'
DOCKER__ESCAPEKEY=$'\x1b'   #note: this escape key is ^[
DOCKER__TAB=$'\t'



#---CASE CONSTANTS
OTHER="OTHER"



#---COLOR CONSTANTS
NOCOLOR=$'\e[0;0m'
FG_DEEPORANGE=$'\e[30;38;5;208m'
FG_LIGHTGREY=$'\e[30;38;5;246m'
FG_LIGHTRED=$'\e[1;31m'
FG_ORANGE=$'\e[30;38;5;215m'
FG_REDORANGE=$'\e[30;38;5;203m'
FG_YELLOW=$'\e[1;33m'

SED_NOCOLOR="\33[0;0m"
SED_FG_ORANGE="\33[30;38;5;215m"



#---COMPGEN CONSTANTS
COMPGEN_C="compgen -c"  #find executable commands
COMPGEN_D="compgen -d"  #find folders
COMPGEN_F="compgen -f"  #find files and folders
COMPGEN_C_D="compgen -c -d" #find folders, and executable commands
COMPGEN_C_F="compgen -c -f" #find files, folders, and executable commands



#---ENUM CONSTANTS
CHECKFORMATCH_ANY=0
CHECKFORMATCH_STARTWITH=1
CHECKFORMATCH_ENDWITH=2
CHECKFORMATCH_EXACT=3



#---HEX CONSTANTS
GS=$'\x1D'
RS=$'\x1E'
STX=$'\x02'
ETX=$'\x03'



#---MESSAGE CONSTANTS
PRINT_NORESULTS_FOUND="${FOUR_SPACES}-:${FG_YELLOW}No results found${NOCOLOR}:-"



#---NUMERIC CONSTANTS
NUMOFMATCH_0=0
NUMOFMATCH_1=1
NUMOFMATCH_2=2

POS_1=1
POS_2=2



#---OUTPUT CONSTANTS
ENDOFLINE="ENDOFLINE"




#---SED CONSTANTS
SED_DOT="."
SED_BACKSLASH_T="\t"
SED_ESCAPED_BACKSLASH="\\"
SED_SLASH_ESCAPED="\/"
SED_ONE_SPACE=" "
SED_SLASH="/"
SED_SUBST_BACKSLASHSPACE="${STX}backslashspace${ETX}"
SED_SUBST_BACKSLASH="${STX}backslash${ETX}"
SED_SUBST_SPACE="${STX}space${ETX}"
SED_SUBST_BACKSLASHT="${STX}backslasht${ETX}"



#---SPACE CONSTANTS
EMPTYSTRING=""
ONE_SPACE=" "
BACKSLASH_ONE_SPACE="\ "



#---TRIM CONSTANTS
TRIM_CR="tr -d ${CR}"



#---STRING CONSTANTS
HORIZONTALLINE="${FG_LIGHTGREY}---------------------------------------------------------------------${NOCOLOR}"



#---FUNCTIONS
function add_leading_spaces__func() {
    #Input args
    local strResult__input=${1}
    local leadingSpaces__input=${2}

    #1. Add LEADING spaces
    local ret=${leadingSpaces__input}${strResult__input}

    #3. Output
    echo "${ret}"
}

function checkForMatch_keyWord_within_string__func() {
    #Turn-off Expansion
    set -f

    #Input Args
    local string__input=${1}
    local keyWord__input=${2}
    local matchType__input=${3}
    shift
    shift
    shift
    local dataArr__input=("$@")

    #MUST: Prepend backslash in front of special characters
    keyWord_escaped=`prepend_backSlash_inFrontOf_specialChars__func "${keyWord__input}" "true"`

    #Find match
    local numOfMatches=`get_numberOfOccurrences_ofKeyWord_within_stringOrArray__func "${string__input}" \
                        "${keyWord__input}" \
                        "${matchType__input}" \
                        "${dataArr__input[@]}"`
    #Output
    if [[ ${numOfMatches} -gt ${NUMOFMATCH_0} ]]; then  #no match
        echo "true"
    else    #match
        echo "false"
    fi

    #Turn-on Expansion
    set +f
}

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

    #Check if directory exists
    local ret_raw=`${docker_exec_cmd} "[ -d "${dir__input}" ] && echo true || echo false"`

    #Remove carriage returns '\r' caused by '/bin/bash -c'
    local ret=`echo "${ret_raw}" |eval ${TRIM_CR}`

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

function checkIf_leadingChar_is_alphanumeric__func() {
    #Turn-off Expansion
    set -f

    #Input Args
    local string__input=${1}

    #Check if 'string__input' is an Empty String
    if [[ -z ${string__input} ]]; then
        echo "false"
    
        return
    fi

    #Check for match
    local stdOutput=`echo "${string__input}" | grep -v "^[a-zA-Z]"`

    #Output
    if [[ -z ${stdOutput} ]]; then  #no match
        echo "true"
    else    #match
        echo "false"
    fi

    #Turn-on Expansion
    set +f
}

function checkIf_string_contains_a_leading_dash__func() {
    #Input args
    local string__input=${1}

    #Check if 'str_astWord' contains a leading dash '-'
    local firstChar=`get_first_nChars_ofString__func "${string__input}" "${NUMOFMATCH_1}"`
    if [[ ${firstChar} == ${DASH} ]]; then
        echo "true"
    else
        echo "false"
    fi
}

function checkIf_string_contains_nonSpace_chars__func() {
    #Turn-off Expansion
    set -f

    #Input Args
    local string__input=${1}

    #Remove all spaces from string
    local str_wo_spaces="${string__input//${ONE_SPACE}}"

    #Check if 'string_input' contains spaces only
    if [[ -z "${str_wo_spaces}" ]]; then
        echo "false"
    else
        echo "true"
    fi

    #Turn-on Expansion
    set +f
}

function compgen_get_numOfMatches_forGiven_keyword__func() {
	#Input args
    local cntnrID__input=${1}
	local keyWord__input=${2}
	
	#Get number of matches
	local ret=${EMPTYSTRING}

    #Define command to check for an exact match of the specified 'keyWord__input'
    #Remark:
    #   This can be achieved by using 'grep "^${cmd_part_str}$"'
    #   ^: starting with
    #   $: ending with
    local cmd="eval ${COMPGEN_C} ${keyWord__input} | sort | uniq | grep \"${keyWord__input}\" | wc -l"

    if [[ -z ${cntnrID__input} ]]; then
        ret=`${cmd}`
    else
        ret=`${docker_exec_cmd} "${cmd}" |eval ${TRIM_CR}`
    fi

	#Output
	echo "${ret}"
}

function convert_escapedChar_to_humanReadable__func() {
    #Input Args
    local string__input=${1}
    local convSpace__input=${2} #true or false

    #SUBSTITUTE:
    #1. '\ ' to |backslashspace|
    local str_subst_backSlashSpace=`echo "${string__input}" | sed "s/${SED_ESCAPED_BACKSLASH}${SED_ESCAPED_BACKSLASH}${SED_ESCAPED_BACKSLASH}${SED_ONE_SPACE}/${SED_SUBST_BACKSLASHSPACE}/g"`

    #2. '\' to |backslash|
    local str_subst_backslash=`echo "${str_subst_backSlashSpace}" | sed "s/${SED_ESCAPED_BACKSLASH}${SED_ESCAPED_BACKSLASH}/${SED_SUBST_BACKSLASH}/g"`

    #3. ' ' to |space|
    local ret=${EMPTYSTRING}
    if [[ ${convSpace__input} == true ]]; then
        ret=`echo "${str_subst_backslash}" | sed "s/${SED_ONE_SPACE}/${SED_SUBST_SPACE}/g"`
    else
        ret=${str_subst_backslash}
    fi
 
    #output
    echo "${ret}"
}
function revert_humanReadable_to_escapedChar__func() {
    #Input args
    local string__input=${1}
    local convSpace__input=${2} #true or false

    #SUBSTITUTE:
    #1. |backslash| to '\'
    local str_subst_backslash_inv=`echo "${string__input}" | sed "s/${SED_SUBST_BACKSLASH}/${SED_ESCAPED_BACKSLASH}${SED_ESCAPED_BACKSLASH}/g"`

    #2. |backslashspace| to '\ '
    local str_subst_backSlashSpace_inv=`echo "${str_subst_backslash_inv}" | sed "s/${SED_SUBST_BACKSLASHSPACE}/${SED_ESCAPED_BACKSLASH}${SED_ESCAPED_BACKSLASH}${SED_ESCAPED_BACKSLASH}${SED_ONE_SPACE}/g"`

    #3. |space| to ' '
    local ret=${EMPTYSTRING}
    if [[ ${convSpace__input} == true ]]; then
        ret=`echo "${str_subst_backSlashSpace_inv}" | sed "s/${SED_SUBST_SPACE}/${SED_ONE_SPACE}/g"`
    else
        ret=${str_subst_backSlashSpace_inv}
    fi

    #output
   echo "${ret}"
}

function duplicate_char__func() {
    #Input args
    local char__input=${1}
    local numOfTimes__input=${2}

    #Duplicate 'char__input'
    local ret=`printf '%*s' "${numOfTimes__input}" | tr ' ' "${char__input}"`

    #Print text including Leading Empty Spaces
    echo "${ret}"
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

function get_numberOfOccurrences_ofKeyWord_within_stringOrArray__func() {
    #Turn-off Expansion
    set -f

    #Input Args
    local string__input=${1}
    local keyWord__input=${2}
    local matchType__input=${3}
    shift
    shift
    shift
    local dataArr__input=("$@")

    #MUST: Prepend backslash in front of special characters
    keyWord_escaped=`prepend_backSlash_inFrontOf_specialChars__func "${keyWord__input}" "true"`

    #Find match
    local ret=0
    case "${matchType__input}" in
        ${CHECKFORMATCH_ANY})
            if [[ ${string__input} != ${EMPTYSTRING} ]]; then
                ret=`echo "${string__input}" |  grep -oE "${keyWord_escaped}" | wc -l`
            else
                ret=`echo "${dataArr__input[@]}" | xargs -n1 | grep -E "${keyWord_escaped}" | wc -l`
            fi
            ;;
        ${CHECKFORMATCH_STARTWITH})
            if [[ ${string__input} != ${EMPTYSTRING} ]]; then
                ret=`echo "${string__input}" |  grep -oE "^${keyWord_escaped}" | wc -l`
            else
                ret=`echo "${dataArr__input[@]}" | xargs -n1 | grep -E "^${keyWord_escaped}" | wc -l`
            fi
            ;;
        ${CHECKFORMATCH_ENDWITH})
            if [[ ${string__input} != ${EMPTYSTRING} ]]; then
                ret=`echo "${string__input}" |  grep -oE "${keyWord_escaped}$" | wc -l`
            else
                ret=`echo "${dataArr__input[@]}" | xargs -n1 | grep -E "${keyWord_escaped}$" | wc -l`
            fi
            ;;
        ${CHECKFORMATCH_EXACT})
            if [[ ${string__input} != ${EMPTYSTRING} ]]; then
                ret=`echo "${string__input}" | grep -oE "(^|[[:blank:]])${keyWord_escaped}($|[[:blank:]])" | wc -l`
            else
                ret=`echo "${dataArr__input[@]}"| xargs -n1 |  grep -E "(^|[[:blank:]])${keyWord_escaped}($|[[:blank:]])" | wc -l`
            fi
            ;;
    esac

    #Output
    echo "${ret}"

    #Turn-on Expansion
    set +f
}

function get_last_nChars_ofString__func() {
    #Input args
    local string__input=${1}
    local numOfChars__input=${2}

    #Define local variable
    local ret=`echo "${string__input: -numOfChars__input}"`

    #Output
    echo -e "${ret}"
}

function get_first_nChars_ofString__func() {
    #Input args
    local string__input=${1}
    local numOfChars__input=${2}

    #Define local variable
    local ret=`echo "${string__input:0:numOfChars__input}"`

    #Output
    echo -e "${ret}"
}

function if_dir_then_append_slash__func() {
    #Input args
    local cntnrID__input=${1}
    local string__input=${2}

    #Define variable
    local ret=${string__input}

    #Append backslash (if 'compgen_out' is a directory) 
    local dirExists=`checkIf_dir_exists__func "${cntnrID__input}" "${string__input}"`
    if [[ ${dirExists} == true ]]; then
        ret="${string__input}${SLASH}"
    fi

    #Output
    echo "${ret}"
}

function prepend_backSlash_inFrontOf_specialChars__func() {
	#Input args
	local string__input=${1}
    local enableExcludes__input=${2}

	#Define excluding chars
	local SED_EXCLUDES="${SED_DOT}${SED_SLASH}"

	#Prepend a backslash '\' in front of any special chars execpt for chars specified by 'SED_EXCLUDES'
    local ret=${EMPTYSTRING}
    if [[ ${enableExcludes__input} == true ]]; then
	    ret=`echo "${string__input}" | sed "s/[^[:alnum:]${SED_EXCLUDES}]/${SED_ESCAPED_BACKSLASH}${SED_ESCAPED_BACKSLASH}&/g"`
    else
        ret=`echo "${string__input}" | sed "s/[^[:alnum:]]/${SED_ESCAPED_BACKSLASH}${SED_ESCAPED_BACKSLASH}&/g"`
    fi

	#Output
	echo "${ret}"
}

function subst_bckSlash_slash_bckSlashT_with_humanReadableText__func() {
    #Input Args
    local string__input=${1}
    local convSpace__input=${2} #true or false

    #SUBSTITUTE:
    #1. '\ ' to \x02backslashspace\x03
    local str_subst_backSlashSpace=`echo "${string__input}" | sed "s/${SED_ESCAPED_BACKSLASH}${SED_ESCAPED_BACKSLASH}${SED_ESCAPED_BACKSLASH}${SED_ONE_SPACE}/${SED_SUBST_BACKSLASHSPACE}/g"`

    #2. '\t' to \x02slasht\x03
    local str_subst_backslashT=`echo "${str_subst_backSlashSpace}" | sed "s/${SED_ESCAPED_BACKSLASH}${SED_ESCAPED_BACKSLASH}${SED_BACKSLASH_T}/${SED_SUBST_BACKSLASHT}/g"`

    #3. '\' to \x02backslash\x03
    local str_subst_backslash=`echo "${str_subst_backslashT}" | sed "s/${SED_ESCAPED_BACKSLASH}${SED_ESCAPED_BACKSLASH}/${SED_SUBST_BACKSLASH}/g"`

    #4. ' ' to \x02space\x03
    local ret=${EMPTYSTRING}
    if [[ ${convSpace__input} == true ]]; then
        ret=`echo "${str_subst_backslash}" | sed "s/${SED_ONE_SPACE}/${SED_SUBST_SPACE}/g"`
    else
        ret=${str_subst_backslash}
    fi
 
    #output
    echo "${ret}"
}
function revert_humanReadText_backTo_bckSlash_slash_bckSlashT__func() {
    #Input args
    local string__input=${1}
    local convSpace__input=${2} #true or false

    #SUBSTITUTE:
    #1. \x02backslash\x03 to '\'
    local str_subst_backslash_inv=`echo "${string__input}" | sed "s/${SED_SUBST_BACKSLASH}/${SED_ESCAPED_BACKSLASH}${SED_ESCAPED_BACKSLASH}/g"`

    #2. \x02backslashspace\x03 to '\ '
    local str_subst_backSlashSpace_inv=`echo "${str_subst_backslash_inv}" | sed "s/${SED_SUBST_BACKSLASHSPACE}/${SED_ESCAPED_BACKSLASH}${SED_ESCAPED_BACKSLASH}${SED_ESCAPED_BACKSLASH}${SED_ONE_SPACE}/g"`

    #3. \x02space\x03 to ' '
    local ret=${EMPTYSTRING}
    if [[ ${convSpace__input} == true ]]; then
        ret=`echo "${str_subst_backSlashSpace_inv}" | sed "s/${SED_SUBST_SPACE}/${SED_ONE_SPACE}/g"`
    else
        ret=${str_subst_backSlashSpace_inv}
    fi

    #output
   echo "${ret}"
}

function print_centered_string__func() {
    #Input args
    local string__input=${1}
    local maxStrLen__input=${2}
    local writeToThisFile__input=${3}

    #Define one-space constant
    local ONESPACE=" "

    #Get string 'without visiable' color characters
    local strInput_wo_colorChars=`echo "${string__input}" | sed "s,\x1B\[[0-9;]*m,,g"`

    #Get string length
    local strInput_wo_colorChars_len=${#strInput_wo_colorChars}

    #Calculated the number of spaces to-be-added
    local numOf_spaces=$(( (maxStrLen__input-strInput_wo_colorChars_len)/2 ))

    #Create a string containing only EMPTY SPACES
    local emptySpaces_string=`duplicate_char__func "${ONESPACE}" "${numOf_spaces}" `

    #Print text including Leading Empty Spaces
    printf "%s" "${emptySpaces_string}${string__input}" >> ${writeToThisFile__input}
}

function remove_trailingSlash__func() {
    #Input args
    local string__input=${1}

    #Define variables
    local ret=${EMPTYSTRING}
    local string_clean_len=0
    local string_clean_wo_trailingChar_len=0

    #Check if trailing slash is present
    local trailingSlash_isPresent=`checkForMatch_keyWord_within_string__func "${string__input}" "${SLASH}" "${CHECKFORMATCH_ENDWITH}" "${EMPTYSTRING}"`
    if [[ ${trailingSlash_isPresent} == false ]]; then  #trailing backslash not found
        ret=${string__input}
    else    #trailing backslash found
        string_clean_len=${#string__input}   #get length
        string_clean_wo_trailingChar_len=$((string_clean_len - 1))  #get length without trailing slash

        ret=${string__input:0:string_clean_wo_trailingChar_len}  #get string without trailing slash
    fi

    #Output
    echo "${ret}"
}

function retrieve_leadingStr__compgen_in__and__cmd____func() {
    #---------------------------------------------------------------------"
    # REMARK:
    #   This function outputs 2 values:
    #   1.  str_leading
    #   2.  str_lastWord
    #   The values are separated by a GS '\x1D'
    #---------------------------------------------------------------------"
    #Input Args
    local string__input=${1}

    #Define variables
    local escapeChar_spaces_isEnabled=false

    #1. Prepend backslash in front of a backslash-space '\ ', backslash-t '\t', and backslash '\'
    local str_conv=`subst_bckSlash_slash_bckSlashT_with_humanReadableText__func "${string__input}" "${escapeChar_spaces_isEnabled}"`

    #2. Get last word and leading string
    #Steps:
    #   1. rev: reverse string
    #   2. sed -e "s/ /${RS} ${RS}/": replace all spaces with <space><RS><space> '\x1E \x1E'
    #   3. cut -d"${RS}" -f1: get results which is on the LEFT side of <RS>
    #   4. #1. rev: reverse string back
    #   5. sed -e "s/${RS}//": remove all <RS>
    #2.1 Get last string
    local str_conv_lastWord=`echo "${str_conv}" | rev | sed -e "s/ /${RS} ${RS}/" | cut -d"${RS}" -f1 | rev | sed -e "s/${RS}//"`

    #2.2 Get leading string
    local str_conv_leading=`echo "${str_conv}" | rev | sed -e "s/ /${RS} ${RS}/" | cut -d"${RS}" -f2- | rev | sed -e "s/${RS}//"`

    #3. Remove the earlier prepended backslash
    local str_lastWord=`revert_humanReadText_backTo_bckSlash_slash_bckSlashT__func "${str_conv_lastWord}" "${escapeChar_spaces_isEnabled}"`
    local str_leading=`revert_humanReadText_backTo_bckSlash_slash_bckSlashT__func "${str_conv_leading}" "${escapeChar_spaces_isEnabled}"`

    #Get length of 'str_lastWord'
    local str_lastWord_len=${#str_lastWord}

    #Check if the retrieved 'str_lastWord' is an Empty String.
    #Remarks:
    #   'str_lastWord' is an Empty String, then:
    #       1. str_leading is an Empty String or contains spaces only
    #       2. str_leading is a non-space string
    #   'str_lastWord' is NOT an Empty String, then:
    #       'string__input' consists of 1 word.
    if [[ -z "${str_lastWord}" ]]; then #is an Empty string
        #Set 'str_lastWord' to an Empty String.
        str_lastWord=${EMPTYSTRING}

        #Check if 'str_conv_leading' contains any characters which are NOT a SPACE.
        #Remarks:
        #   1. This function also checks whether 'str_conv_leading' is an Empty String.
        #   2. 'str_conv_leading' is used here on purpose, because special characters like '\',
        #       which contains a SPACE, are ignored when doing this check.
        local leadingStr_contains_nonSpaceChars=`checkIf_string_contains_nonSpace_chars__func "${str_conv_leading}"`
        if [[ ${leadingStr_contains_nonSpaceChars} == true ]]; then    #contains non-space characters as well
            cmd=${COMPGEN_F}
        else    #contains only spaces
            cmd=${COMPGEN_C}
        fi
    else    #not an Empty String
        cmd=${COMPGEN_C_D}
    fi

    #4. Prep output
    ret="${str_leading}${GS}${str_lastWord}${GS}${cmd}"

    #Output
    echo "${ret}"
}

function remove_escapeChar_from_backslashSpace_and_backSlash() {
    #Input args
    local string__input=${1}
    local convSpace__input=${2} #true or false

    #SUBSTITUTE:
    #1. \x02backslash\x03 to '\'
    local str_subst_backslash_inv=`echo "${string__input}" | sed "s/${SED_SUBST_BACKSLASH}/${SED_ESCAPED_BACKSLASH}${SED_ESCAPED_BACKSLASH}/g"`

    #2. \x02backslashspace\x03 to '\ '
    local str_subst_backSlashSpace_inv=`echo "${str_subst_backslash_inv}" | sed "s/${SED_SUBST_BACKSLASHSPACE}/${SED_ESCAPED_BACKSLASH}${SED_ESCAPED_BACKSLASH}${SED_ESCAPED_BACKSLASH}${SED_ONE_SPACE}/g"`

    #3. \x02space\x03 to ' '
    local ret=${EMPTYSTRING}
    if [[ ${convSpace__input} == true ]]; then
        ret=`echo "${str_subst_backSlashSpace_inv}" | sed "s/${SED_SUBST_SPACE}/${SED_ONE_SPACE}/g"`
    else
        ret=${str_subst_backSlashSpace_inv}
    fi

    #output
   echo "${ret}"
}



#---AUTOCOMPLETE FUNCTION
function autocomplete__func() {
>>>NEED TO BE ADDED
}



#---SUBROUTINES
compgen__environmental_variables__sub() {
    tmp_dir=/tmp
    compgen__raw_headed_tmp__filename="compgen_raw_headed.tmp"
    compgen__raw_headed_tmp__fpath=${tmp_dir}/${compgen__raw_headed_tmp__filename}
    compgen__raw_all_tmp__filename="compgen_raw_all.tmp"
    compgen__raw_all_tmp__fpath=${tmp_dir}/${compgen__raw_all_tmp__filename}
    compgen__tablized_tmp__filename="compgen_tablized.tmp"
    compgen__tablized_tmp__fpath=${tmp_dir}/${compgen__tablized_tmp__filename}  
}

# compgen__load_source_files__sub() {
#     source ${docker__global__fpath}
# }

compgen__init_variables__sub() {
    cached_Arr=()
    cached_ArrLen=0
    # cached_string=${EMPTYSTRING}

    bin_bash_dir=/bin/bash
    compgen_cmd=${EMPTYSTRING}
    docker_exec_cmd="docker exec -t ${containerID__input} ${bin_bash_dir} -c"

    printf_numOfContents_shown=${EMPTYSTRING}

    compgen_in=${EMPTYSTRING}   #this is the string which on the right=side of the space (if any)
    compgen_out=${EMPTYSTRING}  #this is the result after executing 'autocomplete__func'
    leadingSpaces=${EMPTYSTRING}    #this string needs to be prepended before writing to 'output_fPath__input'
    leadingStr=${EMPTYSTRING}   #this is the string which is on the left-side of the space (if any)
    remainingStr=${EMPTYSTRING}
    query_numOfWords=0
    ret=${EMPTYSTRING} #this is in general the combination of 'leadString' and 'compgen_out' (however exceptions may apply)

    dirContent_numOfItems_max=0
    dirContent_numOfItems_shown=0
    numOfCol_max_allowed=7
    remainingStr_len=0
    table_width=70

    spaceInBetweeString_isFound=false
    trailingSlash_isFound=false
}

compgen__create_dirs__sub() {
    if [[ ! -d ${tmp_dir} ]]; then
        mkdir -p ${tmp_dir}
    fi
}

compgen__delete_files__sub() {
    if [[ -f ${compgen__raw_all_tmp__fpath} ]]; then
        rm ${compgen__raw_all_tmp__fpath}
    fi
    if [[ -f ${compgen__raw_headed_tmp__fpath} ]]; then
        rm ${compgen__raw_headed_tmp__fpath}
    fi
    if [[ -f ${compgen__tablized_tmp__fpath} ]]; then
        rm ${compgen__tablized_tmp__fpath}
    fi
    if [[ -f ${output_fPath__input} ]]; then
        rm ${output_fPath__input}
    fi 
}

compgen__prep_param_and_cmd_handler__sub() {
    #Get the LAST word within 'remainingStr'
    local results=`retrieve_leadingStr__compgen_in__and__cmd____func "${query__input}"`

    #Get the results
    #Remark:
    #   This leading string part will have to be prepended to the return value 'ret' in function 'compgen__get_closest_match__sub'
    leadingStr=`echo "${results}" | cut -d"${GS}" -f1`

    #Get the string part which will be injected into 'compgen'
    compgen_in=`echo "${results}" | cut -d"${GS}" -f2`

    #Get compgen command
    compgen_cmd=`echo "${results}" | cut -d"${GS}" -f3`
}

compgen__get_results__sub() {
    #Check 'compgen_in' for special cases
    case "${compgen_in}" in
        "${ESC_BCKSLASHDOT}")
            cached_Arr=()
            cached_ArrLen=0

            leadingStr=${EMPTYSTRING}
            compgen_out="${DOT}"

            return
            ;;
        "${DOT}")
            cached_Arr=()
            cached_ArrLen=0

            leadingStr=${EMPTYSTRING}
            compgen_out="${DOTSLASH}"

            return
            ;;
        "${ESC_DOTBCKSLASH}")
            cached_Arr=()
            cached_ArrLen=0

            leadingStr=${EMPTYSTRING}
            compgen_out="${DOT}"

            return
            ;;
        "${ESC_BCKSLASH}")
            cached_Arr=()
            cached_ArrLen=0

            leadingStr=${EMPTYSTRING}
            compgen_out="${ESC_BCKSLASH}${ESC_BCKSLASH}"

            return
            ;;
        *)
            #Check if 'str_lastWord' contains a leading dash '-'
            local leadingDash_isFound=`checkIf_string_contains_a_leading_dash__func "${compgen_in}"`
            if [[ ${leadingDash_isFound} == true ]]; then
                cached_Arr=()
                cached_ArrLen=0

                leadingStr=${EMPTYSTRING}
                compgen_out="${query__input}"

                return
            fi
            ;;
    esac

    #Substitute DOUBLE slashes with SINGLE slash
    compgen_in=`echo "${compgen_in}" | sed "s/${SED_SLASH_ESCAPED}${SED_SLASH_ESCAPED}*/${SED_SLASH_ESCAPED}/g"`

    #Remove TRAILING SLASH (if present)
    # local str_in=`remove_trailingSlash__func "${compgen_in}"`

    #Define commands
    #Remarks:
    #1. In order to be able to execute commands with SPACES, 'eval' must be used.
    #2. Backslash '\' should be prepended before a quote '"', because otherwise 
    #   the command 'cmd' will not be executed correctly.
    #3. Exclude all results with TRAILING dot '.' and double-dots '..' from the command output by using:
    #   - grep -v \"${ESC_BCKSLASH__ESC_DOT}${ESC_BCKSLASH__ESC_DOT}$\"
    #   - grep -v \"${ESC_BCKSLASH__ESC_DOT}$\"
    local cmd="eval ${compgen_cmd} ${compgen_in} | sort | uniq | grep -v \"${ESC_BCKSLASH__ESC_DOT}$\" | grep -v \"${ESC_BCKSLASH__ESC_DOT}${ESC_BCKSLASH__ESC_DOT}$\""

    #Define Arrays
    local tmp_Arr=()

    #Execute command
    if [[ -z ${containerID__input} ]]; then
        readarray -t tmp_Arr < <(${cmd})
    else
        readarray -t tmp_Arr < <(${docker_exec_cmd} "${cmd}" | eval ${TRIM_CR})
    fi

    #Define 'cached_Arr'
    #If 'compgen_in = DOT', then make sure to also include the DOTSLASH './' in 'cached_Arr'.
    if [[ "${compgen_in}" == "${DOT}" ]]; then  #contains a DOT
        cached_Arr=("${DOTSLASH}" "${tmp_Arr[@]}")
    else    #contains no DOT
        cached_Arr=("${tmp_Arr[@]}")
    fi

    #Update array-length
    cached_ArrLen=${#cached_Arr[@]}

    if [[ ${cached_ArrLen} -gt ${NUMOFMATCH_0} ]]; then
        printf "%s\n" "${cached_Arr[@]}" > ${compgen__raw_all_tmp__fpath}
    else
        touch ${compgen__raw_all_tmp__fpath}
    fi
}

compgen__get_closest_match__sub() {
>>>NEED TO BE ADDED
}

compgen__show_handler__sub() {
    #Write results to file
    compgen__prep_print__sub

    #Show directory contents
    cat ${compgen__tablized_tmp__fpath}
}
compgen__prep_header_print__sub() {
    #Get maximum number of results
    dirContent_numOfItems_max=`cat ${compgen__raw_all_tmp__fpath} | wc -l`

    #Update variable
    printf_numOfContents_shown="(${FG_DEEPORANGE}${dirContent_numOfItems_shown}${NOCOLOR} out-of ${FG_REDORANGE}${dirContent_numOfItems_max}${NOCOLOR})"

    #Print message showing which directory's content is being shown
    printf '%s\n' "${EMPTYSTRING}" > ${compgen__tablized_tmp__fpath}
    printf '%s\n' "${EMPTYSTRING}" >> ${compgen__tablized_tmp__fpath}
    printf '%s\n' "${HORIZONTALLINE}" >> ${compgen__tablized_tmp__fpath}
    printf '%s\n' "${FG_DEEPORANGE}List of keyword ${NOCOLOR} <${FG_REDORANGE}${query__input}${NOCOLOR}> ${printf_numOfContents_shown}" >> ${compgen__tablized_tmp__fpath}
    printf '%s\n' "${HORIZONTALLINE}" >> ${compgen__tablized_tmp__fpath}
}
compgen__prep_print__sub() {
    case "${cached_ArrLen}" in
        ${NUMOFMATCH_0})
            compgen__prep_header_print__sub

#-----------Check if there are any results
            #Write empty line to file
            printf '%b%s\n' "${EMPTYSTRING}" >> ${compgen__tablized_tmp__fpath}
        
            print_centered_string__func "${PRINT_NORESULTS_FOUND}" "${table_width}" "${compgen__tablized_tmp__fpath}"

            #Write empty lines to file
            printf '%b%s\n' "${EMPTYSTRING}" >> ${compgen__tablized_tmp__fpath}
            printf '%b%s\n' "${EMPTYSTRING}" >> ${compgen__tablized_tmp__fpath}
            #Write horizontal line to file
            printf '%b%s\n' "${HORIZONTALLINE}" >> ${compgen__tablized_tmp__fpath}
            # #Write empty line to file
            # printf '%b%s\n' "${EMPTYSTRING}" >> ${compgen__tablized_tmp__fpath}

            return
            ;;
        *)
#-----------Copy from 'compgen__raw_all_tmp__fpath' to 'compgen__raw_headed_tmp__fpath' based on the specified 'table_numOfRows__input'
            if [[ ${table_numOfRows__input} -eq 0 ]]; then
                cp ${compgen__raw_all_tmp__fpath} ${compgen__raw_headed_tmp__fpath}
            else
                cat ${compgen__raw_all_tmp__fpath} | head -n${table_numOfRows__input} > ${compgen__raw_headed_tmp__fpath}
            fi

#-----------Determine the 'word_length_max' and 'dirContent_numOfItems_shown'
            #word_length_max: maximum word-length found
            #dirContent_numOfItems_shown: number of words found in the file 'compgen_raw.tmp'
            local line=${EMPTYSTRING}
            local line_length=0
            local word_length_max=0

            while IFS= read -r line
            do
                #Get length of 'line'
                line_length=${#line}

                #Update max 'word' length
                if [[ ${word_length_max} -lt ${line_length} ]]; then
                    word_length_max=${line_length}
                fi

                #Count the number of words in this file, which is equivalent to 'dirContent_numOfItems_shown'
                dirContent_numOfItems_shown=$((dirContent_numOfItems_shown+1))
            done < ${compgen__raw_headed_tmp__fpath}

#-----------Get 'word_length_max_corr'
            #REMARK:
            #   This means that the space between the columns are 4 characters wide
            local word_length_max_corr=$((word_length_max+4))

#-----------Get 'table_numOfCols__input'
            #Calculate maximum allowed number of columns
            local numOfCols_calc_max=$((table_width/word_length_max_corr))
            local line_length_max_try=$((word_length_max_corr*numOfCols_calc_max + word_length_max))
            #Finally check if it is possible to add another word with max. length is 'word_length_max'
            if [[ ${line_length_max_try} -le ${table_width} ]]; then #line_length_max_try
                numOfCols_calc_max=$((numOfCols_calc_max + 1))
            fi

            #Check if the number of 'numOfCols_calc_max > numOfCol_max_allowed'
            if [[ ${numOfCols_calc_max} -gt ${numOfCol_max_allowed} ]]; then
                numOfCols_calc_max=${numOfCol_max_allowed}    #set value to 'numOfCol_max_allowed'
            fi

#-----------Get 'table_numOfCols__input'
            #Or 'table_numOfCols__input = 0 (auto)'
            if [[ ${table_numOfCols__input} -gt ${numOfCols_calc_max} ]] || \
                    [[ ${table_numOfCols__input} -eq 0 ]]; then
                table_numOfCols__input=${numOfCols_calc_max}
            fi


#-----------Write header to file (must be placed here)
            compgen__prep_header_print__sub


#-----------Add spaces between each column
            local line_print=${EMPTYSTRING}

            local fileLineNum=0
            local fileLineNum_max=`cat ${compgen__raw_headed_tmp__fpath} | wc -l`
            local line_print_numOfWords=0

            while IFS= read -r line
            do
                #Increment by 1
                fileLineNum=$((fileLineNum + 1))
                line_print_numOfWords=$((line_print_numOfWords + 1))

                #Set 'word' to be printed
                if [[ ${line_print_numOfWords} -eq 1 ]]; then
                    line_print="${line}"
                else
                    line_print="${line_print}${line}" 
                fi

                #Calculate the gap to be appended.
                #Remark:
                #   This is the gap between each column.
                if [[ ${fileLineNum} -lt ${fileLineNum_max} ]]; then
                    #Get the length of 'line'
                    line_length=`echo ${#line}`
                    #Calculate the gap-length
                    gap_length=$((word_length_max_corr - line_length))
                    #Generate the spaces based on the specified 'gap_length'
                    gap_string=`duplicate_char__func "${ONE_SPACE}" "${gap_length}" `

                    #Append the 'gap_string' to 'line_print'
                    line_print=${line_print}${gap_string}
                fi

                #Write to file
                #Remarks:
                #   Only do this when:
                #   1. line_print_numOfWords = table_numOfCols__input
                #   OR
                #   2. fileLineNum = fileLineNum_max
                if [[ ${line_print_numOfWords} -eq ${table_numOfCols__input} ]] || [[ ${fileLineNum} -eq ${fileLineNum_max} ]]; then
                    #write to file
                    echo "${line_print}" >> ${compgen__tablized_tmp__fpath}

                    #Reset line_print_numOfWords
                    line_print_numOfWords=0   

                    #Reset string
                    line_print=${EMPTYSTRING}
                fi
            done < ${compgen__raw_headed_tmp__fpath}
            ;;
    esac

    #Write empty line to file
    printf '%b%s\n' "${EMPTYSTRING}" >> ${compgen__tablized_tmp__fpath}
    #Write horizontal line to file
    printf '%b%s\n' "${HORIZONTALLINE}" >> ${compgen__tablized_tmp__fpath}
    # #Write empty line to file
    # printf '%b%s\n' "${EMPTYSTRING}" >> ${compgen__tablized_tmp__fpath}
}



#---MAIN SUBROUTINE
main__sub() {
    compgen__environmental_variables__sub

    # compgen__load_source_files__sub

    compgen__init_variables__sub

    compgen__create_dirs__sub

    compgen__delete_files__sub

    compgen__prep_param_and_cmd_handler__sub

    compgen__get_results__sub

    compgen__get_closest_match__sub

    compgen__show_handler__sub
}



#---EXECUTE MAIN
main__sub
