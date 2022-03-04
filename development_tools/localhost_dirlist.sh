#!/bin/bash
#---Input args
host_dirInput=${1}
listView_numOfRows_input=${2}
listView_numOfCols_input=${3}      #0: auto-set-column, 1: 1-column, 2: 2-columns, 3: 3-columns (MAX)
keyWord_input=${4}



#---Define colors
NOCOLOR=$'\e[0;0m'
ERROR_FG_LIGHTRED=$'\e[1;31m'
FG_YELLOW=$'\e[1;33m'
FG_ORANGE=$'\e[30;38;5;215m'
FG_DEEPORANGE=$'\e[30;38;5;208m'



#---Constants
LISTVIEW_NUMOFCOLS_INPUT_MAX=10
TERMINAL_NUMOFCOLS_MAX=70
ONEHUNDRED_PERCENT=100

EMPTYSTRING=""
FOUR_SPACES="    "

SLASH="/"

PATTERN_PAGE="Page"

ERRMSG_NUMBER_OF_COLUMNS_CAN_NOT_EXCEED_MAX="Number of Colums can NOT exceed '${FG_YELLOW}${LISTVIEW_NUMOFCOLS_INPUT_MAX}${NOCOLOR}'"

PRINTF_DIRECTORY_IS_EMPTY="${FOUR_SPACES}<${FG_YELLOW}Directory is Empty${NOCOLOR}>"
PRINTF_NONEXISTING_DIRECTORY="${FOUR_SPACES}<${ERROR_FG_LIGHTRED}Non-Existing Directory${NOCOLOR}>"
PRINTF_PLEASE_NARROW_SEARCH="<${FG_DEEPORANGE}PLEASE NARROW SEARCH${NOCOLOR}...>"



#---Variables
object_maxLen=0 #length of the file-/folder-name

dirContent_numOfItems_max=0
listView_numOfCols_auto=0
dirContent_numOfItems_shown=0
terminal_numOfCols=0
listView_numOfRows__init_wHeader=0

printf_numOfContents_shown=${EMPTYSTRING}



#---Functions



#---Subroutines
dirContent_main__sub() {
    #Get Terminal Window's number of columns
    terminal_numOfCols=`tput cols`
    if [[ ${terminal_numOfCols} -gt ${TERMINAL_NUMOFCOLS_MAX} ]]; then
        terminal_numOfCols=${TERMINAL_NUMOFCOLS_MAX}
    fi

    if [[ ! -d "${host_dirInput}" ]]; then
        printf '%b%s\n' ""
        printf '%b%s\n' "${PRINTF_NONEXISTING_DIRECTORY}"
        printf '%b%s\n' ""

        exit
    fi

    #No error occurred
    #Get Number of Files
    if [[ -z ${keyWord_input} ]]; then
        dirContent_numOfItems_max=`ls -1 ${host_dirInput} | wc -l`
    else
        dirContent_numOfItems_max=`ls -1 ${host_dirInput} | grep "^${keyWord_input}" | wc -l`
    fi

    if [[ ${dirContent_numOfItems_max} -eq 0 ]]; then
        printf '%b\t\n' ""
        printf '%b\t\n' "${PRINTF_DIRECTORY_IS_EMPTY}"
        printf '%b\t\n' ""

        return
    fi

    #This is a guessed value (because we are in the 'chicken-and-egg' paradox)
    #REMARK:
    #   'object_maxLen' is required in order to calculate 'listView_numOfCols_auto'
    #   But in order to get an accurate 'object_maxLen' the ACTUAL number-of rows is needed (which we don't know yet)
    listView_numOfRows_init=$((LISTVIEW_NUMOFCOLS_INPUT_MAX*listView_numOfRows_input))

    #Get contents of the specified directory 'host_dirInput'
    #EXPLANATION:
    #   ls ${host_dirInput}: get the contents of the specified 'host_dirInput'
    #   grep "^${keyWord_input}": show only the result matching string starting with the specified 'keyWord_input'
    #   head -n ${listView_numOfRows_input}: get the top-N specified by 'listView_numOfRows_input'   
    #Get Number of Files
    if [[ -z ${keyWord_input} ]]; then
        docker_dirContent_list_string=`ls ${host_dirInput} | head -n ${listView_numOfRows_init}`
    else
        docker_dirContent_list_string=`ls ${host_dirInput} | grep "^${keyWord_input}" | head -n ${listView_numOfRows_init}`
    fi

    #Convert String to Array
    docker_dirContent_list_array=(`echo ${docker_dirContent_list_string}`)

    #Get the maximum file-/folder-name length
    for docker_dirContent_list_arrayItem in "${docker_dirContent_list_array[@]}"; do 
        # echo "${docker_dirContent_list_arrayItem}"

        #Get object-length and store it in a temporary variable
        object_maxLen_tmp=${#docker_dirContent_list_arrayItem}

        #Update 'object_maxLen'
        if [[ ${object_maxLen_tmp} -gt ${object_maxLen} ]]; then
            object_maxLen=${object_maxLen_tmp}
        fi
    done

    #Calculate the number of columns which will be used to place the data in
    listView_numOfCols_auto=$((terminal_numOfCols/object_maxLen))

    #Check if the calculated 'listView_numOfCols_auto' has exceeded the maximum allowed 'LISTVIEW_NUMOFCOLS_INPUT_MAX'
    #REMARK:
    #   The calculated 'listView_numOfCols_auto' would exceed 'LISTVIEW_NUMOFCOLS_INPUT_MAX', when...
    #   the 'object_maxLen' is very small (e.g., 1-5).
    #   A SMALL 'object_maxLen' means a LARGE 'listView_numOfCols_auto' value
    if [[ ${listView_numOfCols_auto} -gt ${LISTVIEW_NUMOFCOLS_INPUT_MAX} ]]; then
        listView_numOfCols_auto=${LISTVIEW_NUMOFCOLS_INPUT_MAX} #set value to the maximum allowed 'LISTVIEW_NUMOFCOLS_INPUT_MAX' value
    elif [[ ${listView_numOfCols_auto} -eq 0 ]]; then
        #'listView_numOfCols_auto' can be '0' IF 'object_maxLen > terminal_numOfCols'
        listView_numOfCols_auto=1
    fi

    #Get the "guessed" number-of-rows
    #REMARK:
    #   This value is required to calculate 'listView_numOfRows_accurate'
    listView_numOfRows__init_wHeader=$((listView_numOfRows_input+1))

    #Print an Empty Line
    printf '%b\n' "${EMPTYSTRING}"

    if [[ ${listView_numOfCols_input} -eq 0 ]]; then
        dirContent_get_and_show_list__func "${listView_numOfCols_auto}"

    elif [[ ${listView_numOfCols_input} -le 3 ]]; then
        dirContent_get_and_show_list__func "${listView_numOfCols_input}"

    else
        printf '%b%s\n' "${FOUR_SPACES}***${ERROR_FG_LIGHTRED}ERROR${NOCOLOR}: ${ERRMSG_NUMBER_OF_COLUMNS_CAN_NOT_EXCEED_MAX}" | tee ${docker_container_dirlist_fpath}

        #Print an Empty Line
        printf '%b%s\n' "${EMPTYSTRING}" | tee ${docker_container_dirlist_fpath}

        exit
    fi


    #Print an Empty Line
    printf '%b\n' "${EMPTYSTRING}"

    if [[ ${dirContent_numOfItems_shown} -le ${dirContent_numOfItems_max} ]]; then
        printf_numOfContents_shown=${EMPTYSTRING}"<${FG_DEEPORANGE}number of contents shown${NOCOLOR} (${FG_DEEPORANGE}${dirContent_numOfItems_shown}${NOCOLOR} out-of ${FG_DEEPORANGE}${dirContent_numOfItems_max}${NOCOLOR})>"
        printf '%b\t\n' "${printf_numOfContents_shown}"
        
        printf '%b\t\n' "${PRINTF_PLEASE_NARROW_SEARCH}"
    else
        #Print 'number of contents shown '(dirContent_numOfItems_shown out-of dirContent_numOfItems_max)'
        printf_numOfContents_shown=${EMPTYSTRING}"<${FG_DEEPORANGE}number of contents shown${NOCOLOR} (${FG_DEEPORANGE}${dirContent_numOfItems_max}${NOCOLOR} out-of ${FG_DEEPORANGE}${dirContent_numOfItems_max}${NOCOLOR})>"
        printf '%b\t\n' "${printf_numOfContents_shown}"
    fi

    #Print an Empty Line
    printf '%b\n' "${EMPTYSTRING}"   
}
dirContent_get_and_show_list__func() {
    #Input args
    local lv_numOfCols=${1} #input is whether 'listView_numOfCols_auto' or 'listView_numOfCols_input'

    #Calculate a more accurate value
    #   grep "^${keyWord_input}": show only the result matching string starting with the specified 'keyWord_input'
    #   pr -${lv_numOfCols}: place the results in the specified number of columns 'lv_numOfCols'
    #   sed '/^$/d': remove BLANK lines
    #   head -n ${listView_numOfRows_accurate_wHeader}: get the top-N specified by 'listView_numOfRows_accurate_wHeader' (starts from the top)
    #   wc -l" get the number of rows
    if [[ -z ${keyWord_input} ]]; then
        listView_numOfRows_accurate_wHeader=`ls ${host_dirInput} | pr -${lv_numOfCols} | sed '/^$/d' | head -n ${listView_numOfRows__init_wHeader} | wc -l`
    else
        listView_numOfRows_accurate_wHeader=`ls ${host_dirInput} | grep "^${keyWord_input}" | pr -${lv_numOfCols} | sed '/^$/d' | head -n ${listView_numOfRows__init_wHeader} | wc -l`
    fi

    #Calculate 'listView_numOfRows_accurate' which is the ACTUAL number of rows to be shown in the list-view
    listView_numOfRows_accurate=$((listView_numOfRows_accurate_wHeader-1))  #without header

    #Calculate the number of objects to-be-shown
    dirContent_numOfItems_shown=$((lv_numOfCols*listView_numOfRows_accurate))

    #Get directory contents specified by 'host_dirInput' and keyword 'keyWord_input'
    #   grep "^${keyWord_input}": show only the result matching string starting with the specified 'keyWord_input'
    #   pr -${lv_numOfCols}: place the results in the specified number of columns 'lv_numOfCols'
    #   sed '/^$/d': remove BLANK lines
    #   head -n ${listView_numOfRows_accurate_wHeader}: get the top-N specified by 'listView_numOfRows_accurate_wHeader' (starts from the top)
    #   tail -n ${listView_numOfRows_accurate}`: get the to bottom-N specified by 'listView_numOfRows_accurate' (starts from the bottom)
    if [[ -z ${keyWord_input} ]]; then
        dirContent_list_string=`ls ${host_dirInput} | pr -${lv_numOfCols} | sed '/^$/d' | head -n ${listView_numOfRows_accurate_wHeader} | tail -n ${listView_numOfRows_accurate}`
    else
        dirContent_list_string=`ls ${host_dirInput} | grep "^${keyWord_input}" | pr -${lv_numOfCols} | sed '/^$/d' | head -n ${listView_numOfRows_accurate_wHeader} | tail -n ${listView_numOfRows_accurate}`
    fi

    #Show directory contents specified by 'host_dirInput' and keyword 'keyWord_input'
    printf '%b\t\n' "${FG_ORANGE}${dirContent_list_string}${NOCOLOR}"
}

main__sub() {
  dirContent_main__sub  
}

#---Execute
main__sub

