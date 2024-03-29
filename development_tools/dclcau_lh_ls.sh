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
tibboHeader_prepend_numOfLines__input=${6}



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



#---SPACE CONSTANTS
EMPTYSTRING=""
ONE_SPACE=" "
FOUR_SPACES="${ONE_SPACE}${ONE_SPACE}${ONE_SPACE}${ONE_SPACE}"



#---PRINTF CONSTANTS
PRINTF_DIR_IS_EMPTY="${FOUR_SPACES}-:${FG_YELLOW}directory is Empty${NOCOLOR}:-"
PRINTF_UNKNOWN_DIRECTORY="${FOUR_SPACES}-:${FG_LIGHTRED}Unknown directory${NOCOLOR}:-"



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
docker__get_source_fullpath__sub() {
    #Define constants
    local PHASE_CHECK_CACHE=1
    local PHASE_FIND_PATH=10
    local PHASE_EXIT=100

    #Define variables
    local phase=""

    local current_dir=""
    local parent_dir=""
    local search_dir=""
    local tmp_dir=""

    local development_tools_foldername=""
    local lTPP3_ROOTFS_foldername=""
    local global_filename=""
    local parentDir_of_LTPP3_ROOTFS_dir=""

    local mainmenu_path_cache_filename=""
    local mainmenu_path_cache_fpath=""

    local find_dir_result_arr=()
    local find_dir_result_arritem=""

    local path_of_development_tools_found=""
    local parentpath_of_development_tools=""

    local isfound=""

    local retry_ctr=0

    #Set variables
    phase="${PHASE_CHECK_CACHE}"
    current_dir=$(dirname $(readlink -f $0))
    parent_dir="$(dirname "${current_dir}")"
    tmp_dir=/tmp
    development_tools_foldername="development_tools"
    global_filename="docker_global.sh"
    lTPP3_ROOTFS_foldername="LTPP3_ROOTFS"

    mainmenu_path_cache_filename="docker__mainmenu_path.cache"
    mainmenu_path_cache_fpath="${tmp_dir}/${mainmenu_path_cache_filename}"

    result=false

    #Start loop
    while true
    do
        case "${phase}" in
            "${PHASE_CHECK_CACHE}")
                if [[ -f "${mainmenu_path_cache_fpath}" ]]; then
                    #Get the directory stored in cache-file
                    docker__LTPP3_ROOTFS_development_tools__dir=$(awk 'NR==1' "${mainmenu_path_cache_fpath}")

                    #Move one directory up
                    parentpath_of_development_tools=$(dirname "${docker__LTPP3_ROOTFS_development_tools__dir}")

                    #Check if 'development_tools' is in the 'LTPP3_ROOTFS' folder
                    isfound=$(docker__checkif_paths_are_related "${current_dir}" \
                            "${parentpath_of_development_tools}" "${lTPP3_ROOTFS_foldername}")
                    if [[ ${isfound} == false ]]; then
                        phase="${PHASE_FIND_PATH}"
                    else
                        result=true

                        phase="${PHASE_EXIT}"
                    fi
                else
                    phase="${PHASE_FIND_PATH}"
                fi
                ;;
            "${PHASE_FIND_PATH}")   
                #Print
                echo -e "---:\e[30;38;5;215mSTART\e[0;0m: find path of folder \e[30;38;5;246m'${development_tools_foldername}\e[0;0m"

                #Initialize variables
                docker__LTPP3_ROOTFS_development_tools__dir=""
                search_dir="${current_dir}"   #start with search in the current dir

                #Start loop
                while true
                do
                    #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
                    #... and read to array 'find_result_arr'
                    readarray -t find_dir_result_arr < <(find  "${search_dir}" -type d -iname "${lTPP3_ROOTFS_foldername}" 2> /dev/null)

                    #Iterate thru each array-item
                    for find_dir_result_arritem in "${find_dir_result_arr[@]}"
                    do
                        echo -e "---:\e[30;38;5;215mCHECKING\e[0;0m: ${find_dir_result_arritem}"

                        #Find path
                        isfound=$(docker__checkif_paths_are_related "${current_dir}" \
                                "${find_dir_result_arritem}"  "${lTPP3_ROOTFS_foldername}")
                        if [[ ${isfound} == true ]]; then
                            #Update variable 'path_of_development_tools_found'
                            path_of_development_tools_found="${find_dir_result_arritem}/${development_tools_foldername}"

                            #Check if 'directory' exist
                            if [[ -d "${path_of_development_tools_found}" ]]; then    #directory exists
                                #Update variable
                                #Remark:
                                #   'docker__LTPP3_ROOTFS_development_tools__dir' is a global variable.
                                #   This variable will be passed 'globally' to script 'docker_global.sh'.
                                docker__LTPP3_ROOTFS_development_tools__dir="${path_of_development_tools_found}"

                                break
                            fi
                        fi
                    done

                    #Check if 'docker__LTPP3_ROOTFS_development_tools__dir' contains any data
                    if [[ -z "${docker__LTPP3_ROOTFS_development_tools__dir}" ]]; then  #contains no data
                        case "${retry_ctr}" in
                            0)
                                search_dir="${parent_dir}"    #next search in the 'parent' directory
                                ;;
                            1)
                                search_dir="/" #finally search in the 'main' directory (the search may take longer)
                                ;;
                            *)
                                echo -e "\r"
                                echo -e "***\e[1;31mERROR\e[0;0m: folder \e[30;38;5;246m${development_tools_foldername}\e[0;0m: \e[30;38;5;131mNot Found\e[0;0m"
                                echo -e "\r"

                                #Update variable
                                result=false

                                #set phase
                                phase="${PHASE_EXIT}"

                                break
                                ;;
                        esac

                        ((retry_ctr++))
                    else    #contains data
                        #Print
                        echo -e "---:\e[30;38;5;215mCOMPLETED\e[0;0m: find path of folder \e[30;38;5;246m'${development_tools_foldername}\e[0;0m"


                        #Write to file
                        echo "${docker__LTPP3_ROOTFS_development_tools__dir}" | tee "${mainmenu_path_cache_fpath}" >/dev/null

                        #Print
                        echo -e "---:\e[30;38;5;215mSTATUS\e[0;0m: write path to temporary cache-file: \e[1;33mDONE\e[0;0m"

                        #Update variable
                        result=true

                        #set phase
                        phase="${PHASE_EXIT}"

                        break
                    fi
                done
                ;;    
            "${PHASE_EXIT}")
                break
                ;;
        esac
    done

    #Exit if 'result = false'
    if [[ ${result} == false ]]; then
        exit 99
    fi

    #Retrieve directories
    #Remark:
    #   'docker__LTPP3_ROOTFS__dir' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/
    parentDir_of_LTPP3_ROOTFS_dir=${docker__LTPP3_ROOTFS__dir%/*}    #move two directories up. This directory is the one-level higher than LTPP3_ROOTFS/

    #Get full-path
    #Remark:
    #   'docker__global__fpath' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__global__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${global_filename}
}
docker__checkif_paths_are_related() {
    #Input args
    local scriptdir__input=${1}
    local finddir__input=${2}
    local pattern__input=${3}

    #Define constants
    local PHASE_PATTERN_CHECK1=1
    local PHASE_PATTERN_CHECK2=10
    local PHASE_PATH_COMPARISON=20
    local PHASE_EXIT=100

    #Define variables
    local phase="${PHASE_PATTERN_CHECK1}"
    local isfound1=""
    local isfound2=""
    local isfound3=""
    local ret=false

    while true
    do
        case "${phase}" in
            "${PHASE_PATTERN_CHECK1}")
                #Check if 'pattern__input' is found in 'scriptdir__input'
                isfound1=$(echo "${scriptdir__input}" | \
                        grep -o "${pattern__input}.*" | \
                        cut -d"/" -f1 | grep -w "^${pattern__input}$")
                if [[ -z "${isfound1}" ]]; then
                    ret=false

                    phase="${PHASE_EXIT}"
                else
                    phase="${PHASE_PATTERN_CHECK2}"
                fi                
                ;;
            "${PHASE_PATTERN_CHECK2}")
                #Check if 'pattern__input' is found in 'finddir__input'
                isfound2=$(echo "${finddir__input}" | \
                        grep -o "${pattern__input}.*" | \
                        cut -d"/" -f1 | grep -w "^${pattern__input}$")
                if [[ -z "${isfound2}" ]]; then
                    ret=false

                    phase="${PHASE_EXIT}"
                else
                    phase="${PHASE_PATH_COMPARISON}"
                fi                
                ;;
            "${PHASE_PATH_COMPARISON}")
                #Check if 'development_tools' is under the folder 'LTPP3_ROOTFS'
                isfound3=$(echo "${scriptdir__input}" | \
                        grep -w "${finddir__input}.*")
                if [[ -z "${isfound3}" ]]; then
                    ret=false
                else
                    ret=true
                fi

                phase="${PHASE_EXIT}"
                ;;
            "${PHASE_EXIT}")
                break
                ;;
        esac
    done

    #Output
    echo "${ret}"

    return 0
}
docker__load_global_fpath_paths__sub() {
    source ${docker__global__fpath}
}

local__load_environmental_variables__sub() {
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
    #Check if 'tibboHeader_prepend_numOfLines__input' is an Empty String
    if [[ -z ${tibboHeader_prepend_numOfLines__input} ]]; then
        tibboHeader_prepend_numOfLines__input=${DOCKER__NUMOFLINES_2}
    fi

    #Print Tibbo-title
    load_tibbo_title__func "${tibboHeader_prepend_numOfLines__input}"

    #Check if directory exists
    if [[ ! -d "${dir__input}" ]]; then  #directory does NOT exist
        #Show header
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
    #Get Number of Files/folders
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
    local printf_numOfContents_shown="(${FG_DEEPORANGE}${dirContent_numOfItems_shown}${NOCOLOR} out-of ${FG_REDORANGE}${dirContent_numOfItems_max}${NOCOLOR})"
    local printf_header="${FG_DEEPORANGE}List of${NOCOLOR} <${FG_REDORANGE}${dir__input}${NOCOLOR}> ${printf_numOfContents_shown}"

    #Print message showing which directory's content is being shown
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
    local numOfCol_max_allowed=7
    local numOfCols_calc_max=$((DOCKER__TABLEWIDTH/word_length_max_corr))
    line_length_max_try=$((word_length_max_corr*numOfCols_calc_max + word_length_max))
    #Finally check if it is possible to add another word with max. length is 'word_length_max'
    if [[ ${line_length_max_try} -le ${DOCKER__TABLEWIDTH} ]]; then #line_length_max_try
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
    docker__get_source_fullpath__sub

    docker__load_global_fpath_paths__sub

    local__load_environmental_variables__sub

    initialize_variables__sub

    create_dirs__sub

    delete_files__sub
    
    dirContent_main__sub  
}



#---EXECUTE
main__sub

