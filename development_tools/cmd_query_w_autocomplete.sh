#!/bin/bash
#Input args
query_input=${1}
listView_numOfRows__input=${2}
listView_numOfCols__input=${3}
output_fPath__input=${4}



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



#---MESSAGE CONSTANTS
PRINT_NORESULTS_FOUND="${FOUR_SPACES}-:${FG_YELLOW}No results found${NOCOLOR}:-"



#---NUMERIC CONSTANTS
NUMOFMATCH_0=0



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


#---SUBROUTINES
cmd_query__environmental_variables__sub() {
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

    tmp_dir=/tmp
    cmd_query__raw_headed_tmp__filename="cmd_query_raw_headed.tmp"
    cmd_query__raw_headed_tmp__fpath=${tmp_dir}/${cmd_query__raw_headed_tmp__filename}
    cmd_query__raw_all_tmp__filename="cmd_query_raw_all.tmp"
    cmd_query__raw_all_tmp__fpath=${tmp_dir}/${cmd_query__raw_all_tmp__filename}
    cmd_query__tablized_tmp__filename="cmd_query_tablized.tmp"
    cmd_query__tablized_tmp__fpath=${tmp_dir}/${cmd_query__tablized_tmp__filename}  
}

cmd_query__load_source_files__sub() {
    source ${docker__global_functions_fpath}
}

cmd_query__init_variables__sub() {
    cached_Arr=()
    cached_ArrLen=0
    cached_string=${EMPTYSTRING}

    printf_numOfContents_shown=${EMPTYSTRING}

    dirContent_numOfItems_max=0
    dirContent_numOfItems_shown=0
    numOfCol_max_allowed=7
    table_width=70
}

cmd_query__create_dirs__sub() {
    if [[ ! -d ${tmp_dir} ]]; then
        mkdir -p ${tmp_dir}
    fi
}

cmd_query__delete_files__sub() {
    if [[ -f ${cmd_query__raw_all_tmp__fpath} ]]; then
        rm ${cmd_query__raw_all_tmp__fpath}
    fi
    if [[ -f ${cmd_query__raw_headed_tmp__fpath} ]]; then
        rm ${cmd_query__raw_headed_tmp__fpath}
    fi
    if [[ -f ${cmd_query__tablized_tmp__fpath} ]]; then
        rm ${cmd_query__tablized_tmp__fpath}
    fi
}

cmd_query__get_results__sub() {
    #Retrieve the queried results
    cached_string=`compgen -c | sort | uniq | grep "^${query_input}"`

    #Convert string to array
    cached_Arr=(`echo ${cached_string}`)

    #Update array-length
    cached_ArrLen=${#cached_Arr[@]}

    if [[ ${cached_ArrLen} -gt ${NUMOFMATCH_0} ]]; then
        printf "%s\n" "${cached_Arr[@]}" > ${cmd_query__raw_all_tmp__fpath}

    else
        touch ${cmd_query__raw_all_tmp__fpath}
    fi
}

cmd_query__get_closest_match__sub() {
    #Get closest match
    local ret=`autocomplete__func "${query_input}" "${cached_Arr[@]}"`

    #Write to file
    echo ${ret} > ${output_fPath__input}
}

cmd_query__show_handler__sub() {
    #Write header content to file
    cmd_query__prep_header_print__sub

    #Write results to file
    cmd_query__prep_body_print__sub

    #Show directory contents
    cat ${cmd_query__tablized_tmp__fpath}
}
cmd_query__prep_header_print__sub() {
    #Update variable
    printf_numOfContents_shown="(${FG_DEEPORANGE}${dirContent_numOfItems_shown}${NOCOLOR} out-of ${FG_REDORANGE}${dirContent_numOfItems_max}${NOCOLOR})"

    #Print message showing which directory's content is being shown
    printf '%s\n' "${EMPTYSTRING}" > ${cmd_query__tablized_tmp__fpath}
    printf '%s\n' "${HORIZONTALLINE}" >> ${cmd_query__tablized_tmp__fpath}
    printf '%s\n' "${FG_DEEPORANGE}List of keyword ${NOCOLOR} <${FG_REDORANGE}${query_input}${NOCOLOR}> ${printf_numOfContents_shown}" >> ${cmd_query__tablized_tmp__fpath}
    printf '%s\n' "${HORIZONTALLINE}" >> ${cmd_query__tablized_tmp__fpath}
}
cmd_query__prep_body_print__sub() {
#---Check if there are any results
    if [[ ${cached_ArrLen} -eq ${NUMOFMATCH_0} ]]; then
        #Write empty line to file
        printf '%b%s\n' "${EMPTYSTRING}" >> ${cmd_query__tablized_tmp__fpath}
    
        print_centered_string__func "${PRINT_NORESULTS_FOUND}" "${table_width}" "${cmd_query__tablized_tmp__fpath}"

        #Write empty line to file
        printf '%b%s\n' "${EMPTYSTRING}" >> ${cmd_query__tablized_tmp__fpath}
        #Write horizontal line to file
        printf '%b%s\n' "${HORIZONTALLINE}" >> ${cmd_query__tablized_tmp__fpath}
        #Write empty line to file
        printf '%b%s\n' "${EMPTYSTRING}" >> ${cmd_query__tablized_tmp__fpath}

        return
    fi


#---Copy from 'cmd_query__raw_all_tmp__fpath' to 'cmd_query__raw_headed_tmp__fpath' based on the specified 'listView_numOfRows__input'
    if [[ ${listView_numOfRows__input} -eq 0 ]]; then
        cp ${cmd_query__raw_all_tmp__fpath} ${cmd_query__raw_headed_tmp__fpath}
    else
        cat ${cmd_query__raw_all_tmp__fpath} | head -n${listView_numOfRows__input} > ${cmd_query__raw_headed_tmp__fpath}
    fi

#---Determine the 'word_length_max' and 'dirContent_numOfItems_shown'
    #word_length_max: maximum word-length found
    #dirContent_numOfItems_shown: number of words found in the file 'cmd_query_raw.tmp'
    local line=${EMPTYSTRING}
    local word=${EMPTYSTRING}
    local word_length=0
    local word_length_max=0

    while read -ra line
    do
        #Go thru each 'word' of the current 'line'
        for word in "${line[@]}"
        do
            #Get length of 'word'
            word_length=${#word}

            #Update max 'word' length
            if [[ ${word_length_max} -lt ${word_length} ]]; then
                word_length_max=${word_length}
            fi

            #Count the number of words in this file, which is equivalent to 'dirContent_numOfItems_shown'
            dirContent_numOfItems_shown=$((dirContent_numOfItems_shown+1))
        done
    done < ${cmd_query__raw_headed_tmp__fpath}

#---Get 'word_length_max_corr'
    #REMARK:
    #   This means that the space between the columns are 4 characters wide
    local word_length_max_corr=$((word_length_max+4))

#---Get 'listView_numOfCols__input'
    #Calculate maximum allowed number of columns
    local numOfCols_calc_max=$((table_width/word_length_max_corr))
    line_length_max_try=$((word_length_max_corr*numOfCols_calc_max + word_length_max))
    #Finally check if it is possible to add another word with max. length is 'word_length_max'
    if [[ ${line_length_max_try} -le ${table_width} ]]; then #line_length_max_try
        numOfCols_calc_max=$((numOfCols_calc_max + 1))
    fi

    #Check if the number of 'numOfCols_calc_max > numOfCol_max_allowed'
    if [[ ${numOfCols_calc_max} -gt ${numOfCol_max_allowed} ]]; then
        numOfCols_calc_max=${numOfCol_max_allowed}    #set value to 'numOfCol_max_allowed'
    fi

#---Get 'listView_numOfCols__input'
    #Or 'listView_numOfCols__input = 0 (auto)'
    if [[ ${listView_numOfCols__input} -gt ${numOfCols_calc_max} ]] || \
            [[ ${listView_numOfCols__input} -eq 0 ]]; then
        listView_numOfCols__input=${numOfCols_calc_max}
    fi

#---Add spaces between each column
    local line_print=${EMPTYSTRING}

    local word_counter=0
    local fileLineNum=0
    local fileLineNum_max=`cat ${cmd_query__raw_headed_tmp__fpath} | wc -l`

    while read -ra line
    do
        #Go thru each 'word' of the current 'line'
        for word in "${line[@]}"
        do
            #Increment by 1
            fileLineNum=$((fileLineNum + 1))
            word_counter=$((word_counter + 1))

            #Set 'word' to be printed
            if [[ ${word_counter} -eq 1 ]]; then
                line_print="${word}"
            else
                line_print="${line_print}${word}" 
            fi

            #Calculate the gap to be appended.
            #Remark:
            #   This is the gap between each column.
            if [[ ${fileLineNum} -lt ${fileLineNum_max} ]]; then
                #Get the length of 'word'
                word_length=`echo ${#word}`
                #Calculate the gap-length
                gap_length=$((word_length_max_corr - word_length))
                #Generate the spaces based on the specified 'gap_length'
                gap_string=`duplicate_char__func "${ONE_SPACE}" "${gap_length}" `

                #Append the 'gap_string' to 'line_print'
                line_print=${line_print}${gap_string}
            fi

            #Write to file
            #Remarks:
            #   Only do this when:
            #   1. word_counter = listView_numOfCols__input
            #   OR
            #   2. fileLineNum = fileLineNum_max
            if [[ ${word_counter} -eq ${listView_numOfCols__input} ]] || [[ ${fileLineNum} -eq ${fileLineNum_max} ]]; then
                #write to file
                echo "${line_print}" >> ${cmd_query__tablized_tmp__fpath}

                #Reset word_counter
                word_counter=0   

                #Reset string
                line_print=${EMPTYSTRING}
            fi
        done
    done < ${cmd_query__raw_headed_tmp__fpath}


    #Write empty line to file
    printf '%b%s\n' "${EMPTYSTRING}" >> ${cmd_query__tablized_tmp__fpath}
    #Write horizontal line to file
    printf '%b%s\n' "${HORIZONTALLINE}" >> ${cmd_query__tablized_tmp__fpath}
    #Write empty line to file
    printf '%b%s\n' "${EMPTYSTRING}" >> ${cmd_query__tablized_tmp__fpath}
}



#---MAIN SUBROUTINE
main__sub() {
    cmd_query__environmental_variables__sub

    cmd_query__load_source_files__sub

    cmd_query__init_variables__sub

    cmd_query__create_dirs__sub

    cmd_query__delete_files__sub

    cmd_query__get_results__sub

    cmd_query__get_closest_match__sub

    cmd_query__show_handler__sub
}



#---EXECUTE MAIN
main__sub
