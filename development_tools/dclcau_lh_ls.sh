#!/bin/bash
#%%%N%H%T%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Directory Content List Auto-Complete %
# Version: 21.03.24-0.0.3
#%%%N%H%T%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#---INPUT ARGS
dir__input=${1}
listView_numOfRows__input=${2}
listView_numOfCols__input=${3}
keyWord__input=${4}
dircontentlist_fpath__input=${5}



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



#---CHAR CONSTANTS
SLASH="/"



#---PATTERN CONSTANTS
PATTERN_PAGE="Page"



#---PRINTF CONSTANTS
PRINTF_NO_RESULTS="${FOUR_SPACES}-:${FG_YELLOW}directory is Empty${NOCOLOR}:-"
PRINTF_UNKNOWN_DIRECTORY="${FOUR_SPACES}-:${FG_LIGHTRED}Unknown directory${NOCOLOR}:-"
PRINTF_PLEASE_NARROW_SEARCH="<${FG_DEEPORANGE}PLEASE NARROW DOWN SEARCH${NOCOLOR}...>"



#---SPACE CONSTANTS
EMPTYSTRING=""
ONE_SPACE=" "
FOUR_SPACES="    "



#---STRING CONSTANTS
HORIZONTALLINE="${FG_LIGHTGREY}---------------------------------------------------------------------${NOCOLOR}"



#---VARIABLES



#---FUNCTIONS
function append_trailing_emptySpaces_to_string__func() {
    #Input args
    local str__input=${1}
    local maxStrWidth__input=${2}

    #Calculate the required empty spaces
    local str__input_len=${#str__input}
    local numOf_emptySpaces=$((maxStrWidth__input-str__input_len))
    local empySpaces_string=`printf '%*s' ${numOf_emptySpaces}`

    #Output
    local str_output="${str__input}${empySpaces_string}"
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



#---SUBROUTINES
load_environmental_variables__sub() {
    tmp_dir=/tmp
    dclcau_ls_raw_headed_tmp_filename="dclcau_ls_raw_headed.tmp"
    dclcau_ls_raw_headed_tmp_fpath=${tmp_dir}/${dclcau_ls_raw_headed_tmp_filename}
    dclcau_ls_raw_all_tmp_filename="dclcau_ls_raw_all.tmp"
    dclcau_ls_raw_all_tmp_fpath=${tmp_dir}/${dclcau_ls_raw_all_tmp_filename}
    dclcau_ls_tablized_tmp_filename="dclcau_ls_tablized.tmp"
    dclcau_ls_tablized_tmp_fpath=${tmp_dir}/${dclcau_ls_tablized_tmp_filename}
    dclcau_ls_color_tmp_filename="dclcau_ls_color.tmp"
    dclcau_ls_color_tmp_fpath=${tmp_dir}/${dclcau_ls_color_tmp_filename}    
}

initialize_variables__sub() {
    dirContent_numOfItems_max=0
    dirContent_numOfItems_shown=0

    printf_numOfContents_shown=${EMPTYSTRING}
}

create_dirs__sub() {
    if [[ ! -d ${tmp_dir} ]]; then
        mkdir -p ${tmp_dir}
    fi
}

delete_files__sub() {
    if [[ -f ${dclcau_ls_raw_headed_tmp_fpath} ]]; then
        rm ${dclcau_ls_raw_headed_tmp_fpath}
    fi
    if [[ -f ${dclcau_ls_raw_all_tmp_fpath} ]]; then
        rm ${dclcau_ls_raw_all_tmp_fpath}
    fi
    if [[ -f ${dclcau_ls_tablized_tmp_fpath} ]]; then
        rm ${dclcau_ls_tablized_tmp_fpath}
    fi
    if [[ -f ${dclcau_ls_color_tmp_fpath} ]]; then
        rm ${dclcau_ls_color_tmp_fpath}
    fi
}

dirContent_main__sub() {
    #Check if directory exists
    if [[ ! -d "${dir__input}" ]]; then  #directory does NOT exist
        #Show header
        dirContent_show_header__sub

        #Print error message
        printf '%b%s\n' "${PRINTF_UNKNOWN_DIRECTORY}"
        printf '%b%s\n' "${EMPTYSTRING}"
        printf '%b%s\n' "${HORIZONTALLINE}"
        # printf '%b%s\n' "${EMPTYSTRING}"
        # printf '%b%s\n' "${EMPTYSTRING}"

        exit
    fi

    #Get directory content and write to file
    dirContent_get__sub

    #No error occurred
    #Get Number of Files/folders
    dirContent_numOfItems_max=`cat ${dclcau_ls_raw_all_tmp_fpath} | wc -l`

    #Directory is Empty
    if [[ ${dirContent_numOfItems_max} -eq 0 ]]; then
        #Show header
        dirContent_show_header__sub

        #Print error message
        printf '%b%s\n' "${PRINTF_NO_RESULTS}"
        printf '%b%s\n' "${EMPTYSTRING}"
        printf '%b%s\n' "${HORIZONTALLINE}"
        # printf '%b%s\n' "${EMPTYSTRING}"
        # printf '%b%s\n' "${EMPTYSTRING}"

        exit
    fi

    #List directory contents
    dirContent_show__sub
}

dirContent_get__sub() {
    #Check if 'dircontentlist_fpath__input' is NOT an Empty String
    if [[ ! -z ${dircontentlist_fpath__input} ]]; then
        #Remark:
        #   If true, then make a copy of 'dircontentlist_fpath__input' to destination file 'dclcau_ls_raw_headed_tmp_fpath' and exit function.
        #   This automatically means that it is NOT needed to retrieve the directory content anymore.
        cp ${dircontentlist_fpath__input} ${dclcau_ls_raw_all_tmp_fpath}
    else
        #Get directory content
        #Explanation: 
        #   The order in which the switches (A,C,x) are applied MATTERS!!!
        #   1: List all in 1 column
        #   a: List hidden files/folders as well
        #   A: List all entries including those starting with a dot '.', except for '.' and '..' (implied)
        #   --group-directories-first: show directories first
        #   head -${listView_numOfRows__input}": show a specified number of rows
        #   tr -d $'\r': (IMPORTANT) trim all carriage returns which is caused by executing 'docker exec -t <containerID> /bin/bash -c'
        #REMARK: For more info see: ls manual
        if [[ -z ${keyWord__input} ]]; then
            ls -1aA ${dir__input} > ${dclcau_ls_raw_all_tmp_fpath}
        else
            ls -1aA ${dir__input} | grep "^${keyWord__input}" > ${dclcau_ls_raw_all_tmp_fpath}
        fi
    fi
    
    if [[ ${listView_numOfRows__input} -eq 0 ]]; then
        cp ${dclcau_ls_raw_all_tmp_fpath} ${dclcau_ls_raw_headed_tmp_fpath}
    else
        cat ${dclcau_ls_raw_all_tmp_fpath} | head -n${listView_numOfRows__input} > ${dclcau_ls_raw_headed_tmp_fpath}
    fi
}

dirContent_show_header__sub() {
    printf_numOfContents_shown="(${FG_DEEPORANGE}${dirContent_numOfItems_shown}${NOCOLOR} out-of ${FG_REDORANGE}${dirContent_numOfItems_max}${NOCOLOR})"

    #Print message showing which directory's content is being shown
    printf '%b%s\n' "${EMPTYSTRING}"
    printf '%b%s\n' "${HORIZONTALLINE}"
    printf '%b%s\n' "${FG_DEEPORANGE}List of${NOCOLOR} <${FG_REDORANGE}${dir__input}${NOCOLOR}> ${printf_numOfContents_shown}"
    printf '%b%s\n' "${HORIZONTALLINE}"
    # printf '%b%s\n' "${EMPTYSTRING}"
}
dirContent_show__sub() {
#---Determine the 'word_length_max' and 'dirContent_numOfItems_shown'
    #word_length_max: maximum word-length found
    #dirContent_numOfItems_shown: number of words found in the file 'dclcau_ls_raw.tmp'
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
    done < ${dclcau_ls_raw_headed_tmp_fpath}

#---Get 'word_length_max_corr'
    #REMARK:
    #   This means that the space between the columns are 4 characters wide
    local word_length_max_corr=$((word_length_max+4))

#---Get 'listView_numOfCols__input'
    #Calculate maximum allowed number of columns
    local table_width=70
    local numOfCol_max_allowed=7
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

#---Distingish directory from files by:
    #1. showing directories with the color deep-orange.
    #   appending a slash.
    local fpath=${EMPTYSTRING}
    local line_colored=${EMPTYSTRING}
    local isDirectory=false

    while read -r line
    do
        #Define fullpath
        fpath=${dir__input}${line}

        #Check if 'fpath' is a directory
        isDirectory=`lh_checkIf_dir_exists__func "${fpath}"`
        if [[ ${isDirectory} == true ]]; then #is directory
            line_colored="${FG_DEEPORANGE}${line}${NOCOLOR}${SLASH}"

        else    #is file
            line_colored="${line}"
        fi

        #Write to file
        echo "${line_colored}" >> ${dclcau_ls_color_tmp_fpath}
    done < ${dclcau_ls_raw_headed_tmp_fpath}

#---Add spaces between each column
    local line_print=${EMPTYSTRING}
    local line_print_woColor=${EMPTYSTRING}

    local word_counter=0
    local line_print_woColor_length=0
    local fileLineNum=0
    local fileLineNum_max=`cat ${dclcau_ls_color_tmp_fpath} | wc -l`

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
                #Retrieve the string excluding the color commands
                line_print_woColor=$(echo -e "${word}}" | sed "s/$(echo -e "\e")[^m]*m//g");
                #Get the length of 'line_print_woColor'
                line_print_woColor_length=`echo ${#line_print_woColor}`
                #Calculate the gap-length
                gap_length=$((word_length_max_corr - line_print_woColor_length))
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
                echo "${line_print}" >> ${dclcau_ls_tablized_tmp_fpath}

                #Reset word_counter
                word_counter=0   

                #Reset string
                line_print=${EMPTYSTRING}
            fi
        done
    done < ${dclcau_ls_color_tmp_fpath}

#---PRINT
    #Print message showing which directory's content is being shown
    dirContent_show_header__sub

    #Show directory contents
    cat ${dclcau_ls_tablized_tmp_fpath}

    #Print an Empty Lines
    printf '%b%s\n' "${EMPTYSTRING}"
    printf '%b%s\n' "${HORIZONTALLINE}"
    # printf '%b%s\n' "${EMPTYSTRING}"   
    # printf '%b%s\n' "${EMPTYSTRING}"
}



#---MAIN SUBROUTINE
main__sub() {
    load_environmental_variables__sub

    initialize_variables__sub

    create_dirs__sub

    delete_files__sub
    
    dirContent_main__sub  
}

#---EXECUTE
main__sub

