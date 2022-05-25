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
flag_prepend_emptyLine__input=${7}



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



#---SPACE CONSTANTS
EMPTYSTRING=""
ONE_SPACE=" "
FOUR_SPACES="    "



#---STRING CONSTANTS
HORIZONTALLINE="${FG_LIGHTGREY}---------------------------------------------------------------------${NOCOLOR}"



#---VARIABLES



#---FUNCTIONS
function dc_checkIf_dir_exists__func() {
	#Input args
	local str__input=${1}

	#Get result
    local stdOutput_raw=`${docker_exec_cmd} "[ -d "${str__input}" ] && echo ${TRUE} || echo ${FALSE}"`

    #Remove carriage returns '\r' caused by '/bin/bash -c'
    local stdOutput=`echo "${stdOutput_raw}" | tr -d $'\r'`

    #Output
    echo ${stdOutput}
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



#---SUBROUTINES
docker__load_environment_variables__sub() {
    #Check the number of input args
    if [[ -z ${docker__global__fpath} ]]; then   #must be equal to 3 input args
        #---Defin FOLDER
        docker__LTPP3_ROOTFS__foldername="LTPP3_ROOTFS"
        docker__development_tools__foldername="development_tools"

        #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
        #... and read to array 'find_result_arr'
        #Remark:
        #   By using '2> /dev/null', the errors are not shown.
        readarray -t find_dir_result_arr < <(find  / -type d -iname "${docker__LTPP3_ROOTFS__foldername}" 2> /dev/null)

        #Define variable
        local find_path_of_LTPP3_ROOTFS=${DOCKER__EMPTYSTRING}

        #Loop thru array-elements
        for find_dir_result_arrItem in "${find_dir_result_arr[@]}"
        do
            #Update variable 'find_path_of_LTPP3_ROOTFS'
            find_path_of_LTPP3_ROOTFS="${find_dir_result_arrItem}/${docker__development_tools__foldername}"
            #Check if 'directory' exist
            if [[ -d "${find_path_of_LTPP3_ROOTFS}" ]]; then    #directory exists
                #Update variable
                docker__LTPP3_ROOTFS_development_tools__dir="${find_path_of_LTPP3_ROOTFS}"

                break
            fi
        done

        docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/
        docker__parentDir_of_LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS__dir%/*}    #move two directories up. This directory is the one-level higher than LTPP3_ROOTFS/

        docker__global__filename="docker_global.sh"
        docker__global__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__global__filename}
    fi
}

docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

local__load_environmental_variables__sub() {
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
    local isDirectory=`dc_checkIf_dir_exists__func "${dir__input}"`
    if [[ ${isDirectory} == ${FALSE} ]]; then
        dirContent_show_header__sub

        #Print error message
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        show_centered_string__func "${PRINTF_UNKNOWN_DIRECTORY}" "${DOCKER__TABLEWIDTH}" "${DOCKER__NOCOLOR}"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

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
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        show_centered_string__func "${PRINTF_DIR_IS_EMPTY}" "${DOCKER__TABLEWIDTH}" "${DOCKER__NOCOLOR}"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

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
    local printf_numOfContents_shown="(${FG_DEEPORANGE}${dirContent_numOfItems_shown}${NOCOLOR} out-of ${FG_REDORANGE}${dirContent_numOfItems_max}${NOCOLOR})"
    local printf_header="${FG_DEEPORANGE}List of${NOCOLOR} <${FG_REDORANGE}${dir__input}${NOCOLOR}> ${printf_numOfContents_shown}"

    #Print message showing which directory's content is being shown
    if [[ ${flag_prepend_emptyLine__input} == true ]]; then
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    fi
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    printf '%b%s\n' "${printf_header}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
}
dirContent_show__sub() {
#---Determine the 'word_length_max' and 'dirContent_numOfItems_shown'
    #word_length_max: maximum word-length found
    #dirContent_numOfItems_shown: number of words found in the file 'dclcau_ls_raw.tmp'
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
    done < ${dclcau_ls_raw_headed_tmp_fpath}

#---Get 'word_length_max_corr'
    #REMARK:
    #   This means that the space between the columns are 4 characters wide
    local word_length_max_corr=$((word_length_max+4))

#---Get 'listView_numOfCols__input'
    #Calculate maximum allowed number of columns
    local table_width=${DOCKER__TABLEWIDTH}
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

    while IFS= read -r line
    do
        #Define fullpath
        fpath=${dir__input}${line}

        #Check if 'fpath' is a directory
        isDirectory=`dc_checkIf_dir_exists__func "${fpath}"`
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

    local line_print_numOfWords=0
    local line_print_woColor_length=0
    local fileLineNum=0
    local fileLineNum_max=`cat ${dclcau_ls_color_tmp_fpath} | wc -l`

    while IFS= read -r line
    do
        #Increment by 1
        fileLineNum=$((fileLineNum + 1))
        line_print_numOfWords=$((line_print_numOfWords + 1))

        #Set 'line' to be printed
        if [[ ${line_print_numOfWords} -eq 1 ]]; then
            line_print="${line}"
        else
            line_print="${line_print}${line}" 
        fi

        #Calculate the gap to be appended.
        #Remark:
        #   This is the gap between each column.
        if [[ ${fileLineNum} -lt ${fileLineNum_max} ]]; then
            #Retrieve the string excluding the color commands
            line_print_woColor=$(echo -e "${line}}" | sed "s/$(echo -e "\e")[^m]*m//g");
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
        #   1. line_print_numOfWords = listView_numOfCols__input
        #   OR
        #   2. fileLineNum = fileLineNum_max
        if [[ ${line_print_numOfWords} -eq ${listView_numOfCols__input} ]] || [[ ${fileLineNum} -eq ${fileLineNum_max} ]]; then
            #write to file
            echo "${line_print}" >> ${dclcau_ls_tablized_tmp_fpath}

            #Reset line_print_numOfWords
            line_print_numOfWords=0   

            #Reset string
            line_print=${EMPTYSTRING}
        fi
    done < ${dclcau_ls_color_tmp_fpath}

#---PRINT
    #Print message showing which directory's content is being shown
    dirContent_show_header__sub

    #Show directory contents
    cat ${dclcau_ls_tablized_tmp_fpath}

    #Print an Empty Lines
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    #Print horizontal line
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
}




#---MAIN SUBROUTINE
main__sub() {
    docker__load_environment_variables__sub

    docker__load_source_files__sub

    local__load_environmental_variables__sub

    initialize_variables__sub

    create_dirs__sub

    delete_files__sub

    dirContent_main__sub  
}



#---EXECUTE
main__sub

