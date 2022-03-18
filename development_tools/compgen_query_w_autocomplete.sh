#!/bin/bash
#Input args
containerID__input=${1}
query__input=${2}
table_numOfRows__input=${3}
table_numOfCols__input=${4}
output_fPath__input=${5}



#---CHAR CONSTANTS
DOT="."
DOTSLASH="./"
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
    local keyWord_len=0
    local numOfMatch=0
    local numOfMatch_init=0
    local ret=${DOCKER__EMPTYSTRING}

    #initialization
    dataArr_1stItem_len=${#dataArr[0]}
    numOfMatch_init=`printf '%s\n' "${dataArr[@]}" | grep "^${keyWord}" | wc -l`
    numOfMatch=${numOfMatch_init}

    #Find the closest match
    while true
    do
        if [[ ${numOfMatch_init} -eq 0 ]]; then  #no match
            #Exit loop
            break
        elif [[ ${numOfMatch_init} -eq 1 ]]; then  #only 1 match
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

    #Output
    echo ${ret}
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
	local excludes="${DOT}"

	#Prepend a backslash '\' in front of any special chars execpt for chars specified by 'excludes'
	local ret=`printf "${string__input}\n" | sed "s/[^[:alnum:]${excludes}]/\\\\\&/g"`

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



#---SUBROUTINES
compgen__environmental_variables__sub() {
	# # docker__current_dir=`pwd`
	# docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    # docker__current_dir=$(dirname ${docker__current_script_fpath})	#/repo/LTPP3_ROOTFS/development_tools
	# docker__parent_dir=${docker__current_dir%/*}    #gets one directory up (/repo/LTPP3_ROOTFS)
    # if [[ -z ${docker__parent_dir} ]]; then
    #     docker__parent_dir="${DOCKER__SLASH}"
    # fi
	# docker__current_folder=`basename ${docker__current_dir}`

    # docker__development_tools_folder="development_tools"
    # if [[ ${docker__current_folder} != ${docker__development_tools_folder} ]]; then
    #     docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}/${docker__development_tools_folder}
    # else
    #     docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}
    # fi

    # docker__global_functions_filename="docker_global_functions.sh"
    # docker__global_functions_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global_functions_filename}

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

    printf_numOfContents_shown=${EMPTYSTRING}

    dirContent_numOfItems_max=0
    dirContent_numOfItems_shown=0
    numOfCol_max_allowed=7
    table_width=70

    bin_bash_dir=/bin/bash
    compgen_cmd=${EMPTYSTRING}
    docker_exec_cmd="docker exec -t ${containerID__input} ${bin_bash_dir} -c"

    compgen_in=${EMPTYSTRING}   #this is the string which on the right=side of the space (if any)
    compgen_out=${EMPTYSTRING}  #this is the result after executing 'autocomplete__func'
    leadingStr=${EMPTYSTRING}   #this is the string which is on the left-side of the space (if any)
    ret=${EMPTYSTRING} #this is in general the combination of 'leadString' and 'compgen_out' (however exceptions may apply)
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
            compgen_in=${query__input}

            #Select compgen command-type
            compgen_cmd="${COMPGEN_F}"
            ;;
        ${SLASH})
            #Split 'leading' and 'trainling' string from 'query__input'
            leadingStr=${EMPTYSTRING}
            compgen_in=${query__input}

            #Select compgen command-type
            compgen_cmd="${COMPGEN_F}"
            ;;

        ${ONE_SPACE})
            #Split 'leading' and 'trainling' string from 'query__input'
            leadingStr=${EMPTYSTRING}
            compgen_in=${query__input}

            #Select compgen command-type
            compgen_cmd="${COMPGEN_F}"
            ;;

        *)
            #--------------------------------------------------------------------
            #In this case it is assumed that the 1st char is NONE-OF-THE-ABOVE
            #--------------------------------------------------------------------
            #Find the FIRST space (if any)
            local stdOutput=`printf "${query__input}" | grep "${ONE_SPACE}"`
            if [[ ! -z ${stdOutput} ]]; then    #space found
                #Get the substring on the left-side of the space
                leadingStr=`printf "${query__input}" | cut -d"${ONE_SPACE}" -f1`

                #Check if 'leadingStr' is an executable command
                local numOfMatch=`${COMPGEN_C} "${leadingStr}" | sort | uniq | wc -l`
                if [[ ${numOfMatch} -eq ${NUMOFMATCH_1} ]]; then  #exactly 1 match found
                    #--------------------------------------------------------------------
                    #Since only 1 match was found, it is assumed that 'leadingStr' is 
                    #   an executable command, which can be called globally.
                    #--------------------------------------------------------------------
                    
                    #Get the rest of the substring on the right-side of the space.
                    #Remark:
                    #   It means that we are looking for a file/folder.
                    compgen_in=`printf "${query__input}" | cut -d"${ONE_SPACE}" -f2-`             
                else    #no match or multiple matches were found
                    leadingStr=${EMPTYSTRING}
                    compgen_in=${query__input}                
                fi 

                #Select compgen command-type
                compgen_cmd="${COMPGEN_F}"       
            else    #no space found
                leadingStr=${EMPTYSTRING}
                compgen_in=${query__input}

                #Select compgen command-type
                compgen_cmd="${COMPGEN_C_F}"
            fi
            ;;
    esac
}

compgen__get_results__sub() {
    # #Retrieve the queried results
    # cached_string=`${compgen_cmd} "${compgen_in}" | sort | uniq`

    # #Get the number of matches
    # local numOfMatch=`${compgen_cmd} "${compgen_in}" | sort | uniq | wc -l`
    # if [[ ${numOfMatch} -eq ${NUMOFMATCH_1} ]]; then  #exactly 1 match found
    #     cached_Arr=("${cached_string}")
    # else
    #     cached_Arr=(`echo ${cached_string}`)
    # fi

    #Execute command and read into array
    readarray -t cached_Arr < <(${compgen_cmd} "${compgen_in}" | sort | uniq)

    #Update array-length
    cached_ArrLen=${#cached_Arr[@]}

    if [[ ${cached_ArrLen} -gt ${NUMOFMATCH_0} ]]; then
        printf "%s\n" "${cached_Arr[@]}" > ${compgen__raw_all_tmp__fpath}
    else
        touch ${compgen__raw_all_tmp__fpath}
    fi
}

compgen__get_closest_match__sub() {
    #Get closest match
    if [[ ${cached_ArrLen} -gt ${NUMOFMATCH_0} ]]; then
        compgen_out=`autocomplete__func "${compgen_in}" "${cached_Arr[@]}"`
    fi

    #Check if 'compgen_out' is an Empty String
    #Remark:
    #   If true, then set 'ret = query__input'
    #   If false, then set 'ret = leadingStr + compgen_out'
    if [[ -z ${compgen_out} ]]; then
        ret=${query__input}
    else
        ret="${leadingStr}${compgen_out}"
    fi

    #Prepend backslash infront of special chars
    ret=`prepend_backSlash_inFrontOf_specialChars__func "${ret}"` 

    #Write to file
    echo ${ret} > ${output_fPath__input}
}

compgen__show_handler__sub() {
    #Write header content to file
    compgen__prep_header_print__sub

    #Write results to file
    compgen__prep_body_print__sub

    #Show directory contents
    cat ${compgen__tablized_tmp__fpath}
}
compgen__prep_header_print__sub() {
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

            while read -r line
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

#-----------Add spaces between each column
            local line_print=${EMPTYSTRING}

            local fileLineNum=0
            local fileLineNum_max=`cat ${compgen__raw_headed_tmp__fpath} | wc -l`
            local line_print_numOfWords=0

            while read -r line
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
