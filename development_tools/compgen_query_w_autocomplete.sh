#!/bin/bash
#Input args
containerID__input=${1}
query__input=${2}
table_numOfRows__input=${3}
table_numOfCols__input=${4}
output_fPath__input=${5}



#---CHAR CONSTANTS
DASH="-"
DOT="."
DOTSLASH="./"
PIPE="|"
SLASH="/"



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
COMPGEN_F="compgen -f"  #find files and folders
COMPGEN_C_F="compgen -c -f" #find files, folders, and executable commands



#---ENUM CONSTANTS
CHECKFORMATCH_ANY=0
CHECKFORMATCH_STARTWITH=1
CHECKFORMATCH_ENDWITH=2
CHECKFORMATCH_EXACT=3



#---MESSAGE CONSTANTS
PRINT_NORESULTS_FOUND="${FOUR_SPACES}-:${FG_YELLOW}No results found${NOCOLOR}:-"



#---NUMERIC CONSTANTS
NUMOFMATCH_0=0
NUMOFMATCH_1=1

POS_1=1
POS_2=2



#---SPACE CONSTANTS
EMPTYSTRING=""
ONE_SPACE=" "



#---STRING CONSTANTS
HORIZONTALLINE="${FG_LIGHTGREY}---------------------------------------------------------------------${NOCOLOR}"



#---FUNCTIONS
function autocomplete__func() {
    #Input args
    #Remark:
    #1. non-array parameter(s) precede(s) array-parameter
    #2. For each non-array parameter, the 'shift' operator has to be added an array-parameter
    local keyWord=${1}
    shift
    local dataArr=("$@")


    #Define and update keyWord
    local dataArr_1stItem_len=0
    local keyWord_bck=${DOCKER__EMPTYSTRING}
    local keyWord_ends_with_slash=${DOCKER__EMPTYSTRING}
    local keyWord_len=0
    local numOfMatch_init=0
    local numOfMatch=0
    local ret=${DOCKER__EMPTYSTRING}

    #Let's use the 1st array-element as reference (it does not really matter which element is used).
    dataArr_1stItem_len=${#dataArr[0]}

    #Get the number of matches specified by 'keyWord'.
    local trailingSlash_isPresent=`checkForMatch_keyWord_within_string__func "${keyWord}" "${SLASH}" "${CHECKFORMATCH_ENDWITH}"`
    if [[ ${trailingSlash_isPresent} == false ]]; then  #trailing slash not found
        numOfMatch_init=`printf '%s\n' "${dataArr[@]}" | grep "^${keyWord}" | wc -l`
    else    #trailing slash found
        numOfMatch_init=`printf '%s\n' "${dataArr[@]}" | grep "^${keyWord}$" | wc -l`
    fi

    #Find the closest match
    while true
    do
        if [[ ${numOfMatch_init} -eq ${NUMOFMATCH_0} ]]; then  #no match
            #Exit loop
            break
        elif [[ ${numOfMatch_init} -eq ${NUMOFMATCH_1} ]]; then  #only 1 match
            #Update variable
            ret=`printf '%s\n' "${dataArr[@]}" | grep "^${keyWord}"`

            #Exit loop
            break
        else    #multiple matches
            #Backup keyWord
            keyWord_bck=${keyWord}

            #Get keyWord length
            keyWord_bck_len=${#keyWord_bck}

            #Increment keyWord length by 1
            keyWord_len=$((keyWord_bck_len + 1))

            #Get the next keyWord (by using the 1st array-element as base)
            keyWord=${dataArr[0]:0:keyWord_len}

            #Check if the total length of the 1st array-element has been reached
            if [[ ${keyWord_bck_len} -eq ${dataArr_1stItem_len} ]]; then
                ret=${keyWord_bck}

                break
            fi

            #Get the new number of matches
            numOfMatch=`printf '%s\n' "${dataArr[@]}" | grep "^${keyWord}" | wc -l`

            #Compare the new 'numOfMatch' with the initial 'numOfMatch_init'
            if [[ ${numOfMatch} -ne ${numOfMatch_init} ]]; then
                ret=${keyWord_bck}

                break
            fi
        fi
    done

    #Output:
    #   1. the closest match 'ret'
    #   2. the number of matches 'numOfMatch_init'
    #Remark:
    #   The above mentioned parameter values are separated by a pipe '|'
    echo -e "${ret}${PIPE}${numOfMatch_init}"
}

function checkForMatch_keyWord_within_string__func() {
    #Turn-off Expansion
    set -f

    #Input Args
    local string__input=${1}
    local keyWord__input=${2}
    local matchType__input=${3}

    #Find match
    local stdOutput=${EMPTYSTRING}
    case "${matchType__input}" in
        ${CHECKFORMATCH_ANY})
            stdOutput=`echo ${string__input} | grep "${keyWord__input}"`
            ;;
        ${CHECKFORMATCH_STARTWITH})
            stdOutput=`echo ${string__input} | grep "^${keyWord__input}"`
            ;;
        ${CHECKFORMATCH_ENDWITH})
            stdOutput=`echo ${string__input} | grep "${keyWord__input}$"`
            ;;
        ${CHECKFORMATCH_EXACT})
            stdOutput=`echo ${string__input} | grep "^${keyWord__input}$"`
            ;;
    esac

    #Output
    if [[ -z ${stdOutput} ]]; then  #no match
        echo "false"
    else    #match
        echo "true"
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

function compgen_get_numOfMatches_forGiven_keyword__func() {
	#Input args
    local cntnrID__input=${1}
	local keyWord__input=${2}
	
	#Get number of matches
	local ret=${EMPTYSTRING}

    #Define command
    local cmd="${COMPGEN_C} "${keyWord__input}" | sort | uniq | grep "^${keyWord__input}$" | wc -l"

    if [[ -z ${cntnrID__input} ]]; then
        ret=`${cmd}`
    else
        ret=`${docker_exec_cmd} "${cmd}" | tr -d $'\r'`
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

function prepend_backSlash_inFrontOf_specialChars__func() {
	#Input args
	local string__input=${1}

	#Define excluding chars
	local excludes="${DOT}${SLASH}"

	#Prepend a backslash '\' in front of any special chars execpt for chars specified by 'excludes'
	local ret=`printf "${string__input}\n" | sed "s/[^[:alnum:]${excludes}]/\\\\\\&/g"`

	#Output
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
    echo -e "${emptySpaces_string}${string__input}" >> ${writeToThisFile__input}
}

function remove_leading_spaces__func() {
    #Input args
    local string__input=${1}

    #Remove leading spaces
    local ret=`printf "${string__input}" | sed 's/^ *//g'`

    #Output
    echo "${ret}"
}

function retrieve_switches_within_string__func() {
    #Input args
    local string__input=${1}

    #Define variables
    local ret=${EMPTSTRING}
    local word=${EMPTSTRING}

    #Retrieve the switches from string (if any)
    for word in ${string__input}
    do
        leading_dash_isFound=`checkForMatch_keyWord_within_string__func "${word}" "${DASH}" "${CHECKFORMATCH_STARTWITH}"`
        if [[ ${leading_dash_isFound} == true ]]; then
            if [[ -z ${ret} ]]; then
                ret="${word}"
            else
                ret="${ret}${ONE_SPACE}${word}"
            fi
        fi
    done

    #Output
    echo -e "${ret}"
}

function retrieve_string_following_after_switches__func() {
    #Input args
    local string__input=${1}

    #Define variables
    local ret=`printf "%s" "${string__input}" | rev | cut -d"-" -f1 | rev | cut -d" " -f2-`
    
    #Output
    echo -e "${ret}"
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
#     source ${docker__global_functions_fpath}
# }

compgen__init_variables__sub() {
    cached_Arr=()
    cached_ArrLen=0
    # cached_string=${EMPTYSTRING}

    dirContent_numOfItems_max=0
    dirContent_numOfItems_shown=0
    numOfCol_max_allowed=7
    table_width=70

    bin_bash_dir=/bin/bash
    compgen_cmd=${EMPTYSTRING}
    docker_exec_cmd="docker exec -t ${containerID__input} ${bin_bash_dir} -c"

    printf_numOfContents_shown=${EMPTYSTRING}

    compgen_in=${EMPTYSTRING}   #this is the string which on the right=side of the space (if any)
    compgen_out=${EMPTYSTRING}  #this is the result after executing 'autocomplete__func'
    leadingStr=${EMPTYSTRING}   #this is the string which is on the left-side of the space (if any)
    ret=${EMPTYSTRING} #this is in general the combination of 'leadString' and 'compgen_out' (however exceptions may apply)

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
    #Check if 'query__input' is an Empty String
    if [[ -z ${query__input} ]]; then
        echo ${query__input} > ${output_fPath__input}

        exit 0   
    fi

    #Get the 1st char from 'query__input'
    local firstChar=`get_char_at_specified_position__func "${query__input}" "${POS_1}"`

    case "${firstChar}" in
        ${DOT})
            #Get length of 'query__input'
            local query__input_len=${#query__input}
         
            #In case 'query__input_len = 1' 
            if [[ ${query__input_len} -eq ${NUMOFMATCH_1} ]]; then
                #Write to file
                echo -e "${DOTSLASH}" > ${output_fPath__input}

                exit 0
            fi

            #Split 'leading' and 'trainling' string from 'query__input'
            leadingStr=${EMPTYSTRING}
            compgen_in="${query__input}"

            #Select compgen command-type
            compgen_cmd="${COMPGEN_F}"
            ;;
        ${SLASH})
            #Split 'leading' and 'trainling' string from 'query__input'
            leadingStr=${EMPTYSTRING}
            compgen_in="${query__input}"

            #Select compgen command-type
            compgen_cmd="${COMPGEN_F}"
            ;;

        ${ONE_SPACE})
            #Split 'leading' and 'trainling' string from 'query__input'
            leadingStr=${EMPTYSTRING}
            compgen_in="${query__input}"

            #Select compgen command-type
            compgen_cmd="${COMPGEN_F}"
            ;;

        *)
            #--------------------------------------------------------------------
            #In this case it is assumed that the 1st char is NONE-OF-THE-ABOVE
            #--------------------------------------------------------------------
            #Check if string 'query__input' contains any spaces
            local stdOutput=`printf "${query__input}" | grep "${ONE_SPACE}"`
            if [[ ! -z ${stdOutput} ]]; then    #space found
                #Initialization
                local left_str=${EMPTYSTRING}
                local switches=${EMPTYSTRING}
                local cut_index=1
                local numOfMatch=0

                #Check if 'leadingStr' is an executable command (e.g., cd, ls, source, etc.)
                while true
                do
                    #Get the ALL the strings on the LEFT-side of the space
                    left_str=`printf "${query__input}" | cut -d"${ONE_SPACE}" -f-${cut_index}`

                    #Check for exact match.
                    #Remark:
                    #   This can be achieved by using 'grep "^${left_str}$"'.
                    #   ^: starting with
                    #   $: ending with
                    numOfMatch=`compgen_get_numOfMatches_forGiven_keyword__func "${containerID__input}" "${left_str}"`
                    case "${numOfMatch}" in
                        ${NUMOFMATCH_0})
                            #Reset leading string
                            leadingStr=${EMPTYSTRING}
                            #Set trailing string
                            compgen_in="${query__input}"

                            break                            
                            ;;
                        ${NUMOFMATCH_1})
                            #Get the switches which belong to the executable command (if any)
                            switches=`retrieve_switches_within_string__func "${query__input}"`

                            #Define the 'leadingStr'
                            if [[ -z ${switches} ]]; then
                                leadingStr=${left_str}
                            else
                                leadingStr=${left_str}${ONE_SPACE}${switches} 
                            fi

                            #Get the rest of the string on the RIGHT-side of the space
                            #Remark:
                            #   In this case 'cut_index + 1' has to be used.
                            compgen_in=`retrieve_string_following_after_switches__func "${query__input}"`

                            break                            
                            ;;
                        *)  #Multiple matches were found (which is not likely)
                            if [[ "${left_str}" != "${query__input}" ]]; then   #strings are not the same
                                cut_index=$((cut_index + 1))    #increment index by 1
                            else    #strings are the same (which means that 'leadingStr = leadingStr_bck = query__input')
                                #Reset leading string
                                leadingStr=${EMPTYSTRING}
                                #Set trailing string
                                compgen_in="${query__input}"

                                break                        
                            fi
                            ;;
                    esac
                done

                #Select compgen command-type
                compgen_cmd="${COMPGEN_F}"
            else    #no space found
                leadingStr=${EMPTYSTRING}
                compgen_in="${query__input}"

                #Select compgen command-type
                compgen_cmd="${COMPGEN_C_F}"
            fi
            ;;
    esac

    #Check if 'compgen_in' ends with a slash '/'.
    #If true, then remove the slash.
    trailingSlash_isFound=`checkForMatch_keyWord_within_string__func "${compgen_in}" "${SLASH}" "${CHECKFORMATCH_ENDWITH}"`
    if [[ ${trailingSlash_isFound} == true ]]; then
        compgen_in=`printf "%s" "${compgen_in}" | rev | cut -d"${SLASH}" -f2- | rev`
    fi
}

compgen__get_results__sub() {
    #Define commands
    #Remark:
    #   In order to be able to execute commands with SPACES, 'eval' must be used.
    local cmd1="eval ${compgen_cmd} "${compgen_in}" | sort | uniq"
    local cmd2="eval ${compgen_cmd} "${compgen_in}" | sort | uniq | grep "^${compgen_in}$""

    #Choose the command to-be-executed based on the specified 'trailingSlash_isFound'
    if [[ ${trailingSlash_isFound} == false ]]; then
        cmd_chosen=${cmd1}
    else
        cmd_chosen=${cmd2}
    fi

    #Execute command
    if [[ -z ${containerID__input} ]]; then
        readarray -t cached_Arr < <(${cmd_chosen})
    else
        readarray -t cachedInput_Arr < <(${docker__exec_cmd} "${cmd_chosen}" | tr -d $'\r')
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
    #Define variables
    local dirExists=false
    local numOfMatch=0
    local results=${EMPTYSTRING}

    #Get closest match
    if [[ ${cached_ArrLen} -gt ${NUMOFMATCH_0} ]]; then
        results=`autocomplete__func "${compgen_in}" "${cached_Arr[@]}"`

        #Get results delimited by a pipe '|'
        compgen_out=`printf "${results}" | cut -d"${PIPE}" -f1`
        numOfMatch=`printf "${results}" | cut -d"${PIPE}" -f2`

        #Append slash (if 'compgen_out' is a directory)
        if [[ ${numOfMatch} -eq ${NUMOFMATCH_1} ]]; then   #exactly 1 match
            dirExists=`checkIf_dir_exists__func "${containerID__input}" "${compgen_out}"`
            if [[ ${dirExists} == true ]]; then
                compgen_out="${compgen_out}${SLASH}"
            fi
        fi

        #Prepend backslash infront of special chars except for: slash, underscore
        compgen_out=`prepend_backSlash_inFrontOf_specialChars__func "${compgen_out}"` 
    fi

    #Check if 'compgen_out' is an Empty String
    #Remark:
    #   If true, then set 'ret = query__input'
    #   If false, then set 'ret = leadingStr + compgen_out'
    if [[ -z ${compgen_out} ]]; then    #is an Empty String
        ret=${query__input}
    else    #is Not an Empty String
        if [[ -z ${leadingStr} ]]; then #is an Empty String
            ret="${compgen_out}"
        else    #is Not an Empty String
            ret="${leadingStr}${ONE_SPACE}${compgen_out}"
        fi
    fi

    #Write to file
    printf "%s\n" "${ret}" > ${output_fPath__input}
}

compgen__show_handler__sub() {

    #Write results to file
    compgen__prep_body_print__sub

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
compgen__prep_body_print__sub() {
    case "${cached_ArrLen}" in
        ${NUMOFMATCH_0})
            compgen__prep_header_print__sub

#-----------Check if there are any results
            #Write empty line to file
            printf '%b%s\n' "${EMPTYSTRING}" >> ${compgen__tablized_tmp__fpath}
        
            print_centered_string__func "${PRINT_NORESULTS_FOUND}" "${table_width}" "${compgen__tablized_tmp__fpath}"

            #Write empty line to file
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
