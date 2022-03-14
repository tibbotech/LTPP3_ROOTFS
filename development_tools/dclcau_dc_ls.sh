#!/bin/bash
#%%%N%H%T%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Directory Content List Auto-Complete %
# Version: 21.03.24-0.0.3
#%%%N%H%T%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#---INPUT ARGS
containerID__input=${1}
dir__input=${2}
listView_numOfRows__input=${3}
listView_numOfCols__input=${4}      #0: auto-set-column, 1: 1-column, 2: 2-columns, 3: 3-columns (MAX)
keyWord__input=${5}
dircontentlist_fpath__input=${6}



#---BOOLEAN CONSTANTS
TRUE=true
FALSE=false



#---CHAR CONSTANTS
SLASH="/"



#---COLOR CONSTANTS
NOCOLOR=$'\e[0;0m'
FG_DEEPORANGE=$'\e[30;38;5;208m'
FG_LIGHTGREY=$'\e[30;38;5;246m'
FG_LIGHTRED=$'\e[1;31m'
FG_ORANGE=$'\e[30;38;5;215m'
FG_REDORANGE=$'\e[30;38;5;203m'
FG_YELLOW=$'\e[1;33m'



#---PATTERN CONSTANTS
PATTERN_PAGE="Page"



#---PRINTF CONSTANTS
PRINTF_DIR_IS_EMPTY="${FOUR_SPACES}-:${FG_YELLOW}directory is Empty${NOCOLOR}:-"
PRINTF_UNKNOWN_DIRECTORY="${FOUR_SPACES}-:${FG_LIGHTRED}Unknown directory${NOCOLOR}:-"
PRINTF_PLEASE_NARROW_SEARCH="<${FG_DEEPORANGE}PLEASE NARROW DOWN SEARCH${NOCOLOR}...>"



#---SPACE CONSTANTS
EMPTYSTRING=""
FOUR_SPACES="    "



#---STRING CONSTANTS
HORIZONTALLINE="${FG_LIGHTGREY}---------------------------------------------------------------------${NOCOLOR}"



#---VARIABLES



#---FUNCTIONS
function checkIf_dir_exists_func() {
	#Input args
	local str__input=${1}

	#Get result
    local stdOutput_raw=`${docker_exec_cmd} "[ -d "${str__input}" ] && echo ${TRUE} || echo ${FALSE}"`

    #Remove carriage returns '\r' caused by '/bin/bash -c'
    local stdOutput=`echo "${stdOutput_raw}" | tr -d $'\r'`

    #Output
    echo ${stdOutput}
}



#---SUBROUTINES
load_environmental_variables__sub() {
    bin_bash_dir=/bin/bash

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
    listView_numOfRows_accurate=0
    listView_numOfRows_accurate_wHeader=0
    listView_numOfRows_accurate_wHeader_raw=0

    printf_numOfContents_shown=${EMPTYSTRING}

    docker_exec_cmd="docker exec -t ${containerID__input} ${bin_bash_dir} -c"
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
    #Check if 'fpath' is a directory
    local isDirectory=`checkIf_dir_exists_func "${dir__input}"`
    if [[ ${isDirectory} == ${FALSE} ]]; then
        dirContent_show_header__sub

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
    #Get Number of Files
    dirContent_numOfItems_max=`cat ${dclcau_ls_raw_all_tmp_fpath} | wc -l`

    #Directory is Empty
    if [[ ${dirContent_numOfItems_max} -eq 0 ]]; then
        #Show header
        dirContent_show_header__sub

        #Print error message
        printf '%b%s\n' "${PRINTF_DIR_IS_EMPTY}"
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
        #   tr -d $'\r': (IMPORTANT) trim all carriage returns which is caused by executing 'docker exec -t <containerID__input> /bin/bash -c'
        #REMARK: For more info see: ls manual
        if [[ -z ${keyWord__input} ]]; then
            ${docker_exec_cmd} "ls -1aA ${dir__input}" | tr -d $'\r' > ${dclcau_ls_raw_all_tmp_fpath}
        else
            ${docker_exec_cmd} "ls -1aA ${dir__input} | grep "^${keyWord__input}"" | tr -d $'\r' > ${dclcau_ls_raw_all_tmp_fpath}
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
    local fpath=${EMPTYSTRING}
    local line=${EMPTYSTRING}
    local line_print=${EMPTYSTRING}
    local word=${EMPTYSTRING}
    local word_print=${EMPTYSTRING}
    local word_tmp=${EMPTYSTRING}

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


    #Correction of 'word_length_max'
    #REMARK:
    #   This means that the space between the columns are 4 characters wide
    local word_maxLen_corr=$((word_length_max+4))

    #Calculate maximum allowed number of columns
    local col_maxWidth=70
    local numOfCol_max_allowed=7
    local numOfCols_max_calculated=$((col_maxWidth/word_length_max))

    #Check if the number of 'numOfCols_max_calculated > numOfCol_max_allowed'
    if [[ ${numOfCols_max_calculated} -gt ${numOfCol_max_allowed} ]]; then
        numOfCols_max_calculated=${numOfCol_max_allowed}    #set value to 'numOfCol_max_allowed'
    fi

    #Check if 'listView_numOfCols__input > numOfCols_max_calculated
    #Or 'listView_numOfCols__input = 0 (auto)'
    if [[ ${listView_numOfCols__input} -gt ${numOfCols_max_calculated} ]] || \
            [[ ${listView_numOfCols__input} -eq 0 ]]; then
        listView_numOfCols__input=${numOfCols_max_calculated}
    fi

#---Place the files/folders in Table-form
    #Counter which keep track of the number of words used
    #REMARK: 
    #   This counter will be resetted once it is equal to 'listView_numOfCols__input'
    local counter=0
    local lastLineOfFile=`cat ${dclcau_ls_raw_all_tmp_fpath} | tail -1`

    while read -ra line
    do
        #Go thru each 'word' of the current 'line'
        for word in "${line[@]}"
        do
            #Steps:
            #1. Define the fullpath
            fpath=${dir__input}/${word}

            #2. Check if 'fpath' is a directory
            #-  If NOT a directory, then use a gap of '4'
            #-  If a directory, then use a gap of '3'
            local isDirectory=`checkIf_dir_exists_func "${fpath}"`
            if [[ ${isDirectory} == ${FALSE} ]]; then
                word_tmp=${word}
            else
                word_tmp=${word}${SLASH}
            fi

            #Append empty spaces to 'word' by using the print-format '%-xs'
            word_print=`printf "%-${word_maxLen_corr}s" "${word_tmp}"`

            #Compose 'line_print' which could contain mulitple 'word_print'
            line_print="${line_print}${word_print}"

            #Increment counter
            counter=$((counter+1))

            #1. Write to file
            #2. Reset variables
            if [[ ${counter} -eq ${listView_numOfCols__input} ]] || \
                    [[ "${line}" == "${lastLineOfFile}" ]]; then
                #Print the result of 'echo' (which means that any special characters will NOT be treated as a string)
                echo "${line_print}" >> ${dclcau_ls_tablized_tmp_fpath}

                #Initialize variables
                counter=0
                word_tmp=${EMPTYSTRING}
                word_print=${EMPTYSTRING}
                line_print=${EMPTYSTRING}
            fi
        done
    done < ${dclcau_ls_raw_headed_tmp_fpath}



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

