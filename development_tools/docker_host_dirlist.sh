#!/bin/bash
#---Input args
dir_input=${1}
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
LISTVIEW_NUMOFCOLS_INPUT_MAX=3
TERMINAL_NUMOFCOLS_MAX=70
ONEHUNDRED_PERCENT=100

EMPTYSTRING=""
FOUR_SPACES="    "

PATTERN_PAGE="Page"

ERRMSG_NUMBER_OF_COLUMNS_CAN_NOT_EXCEED_THREE="Number of Colums can NOT exceed '${FG_YELLOW}${LISTVIEW_NUMOFCOLS_INPUT_MAX}${NOCOLOR}'"

PRINTF_NO_RESULTS_FOUND="${FOUR_SPACES}***${FG_YELLOW}NO RESULTS FOUND${NOCOLOR}..."
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
dirContent_main__sub() 
{
    #Get Terminal Window's number of columns
    terminal_numOfCols=`tput cols`
    if [[ ${terminal_numOfCols} -gt ${TERMINAL_NUMOFCOLS_MAX} ]]; then
        terminal_numOfCols=${TERMINAL_NUMOFCOLS_MAX}
    fi


    if [[ -d "${dir_input}" ]]; then
        #Get Number of Files
        dirContent_numOfItems_max=`ls ${dir_input} | grep "${keyWord_input}" | wc -l`

        if [[ ${dirContent_numOfItems_max} -eq 0 ]]; then
            printf '%b\t\n' ""
            printf '%b\t\n' "${PRINTF_NO_RESULTS_FOUND}"
            printf '%b\t\n' ""

            return
        fi

        #This is a guessed value (because we are in the 'chicken-and-egg' paradox)
        #REMARK:
        #   'object_maxLen' is required in order to calculate 'listView_numOfCols_auto'
        #   But in order to get an accurate 'object_maxLen' the ACTUAL number-of rows is needed (which we don't know yet)
        listView_numOfRows_init=$((LISTVIEW_NUMOFCOLS_INPUT_MAX*listView_numOfRows_input))

        #Get length of each file-/folder-name
        #EXPLANATION:
        #   ls ${dir_input}: get the contents of the specified 'dir_input'
        #   grep "${keyWord_input}": show only the result matching the specified 'keyWord_input'
        #   head -n ${listView_numOfRows_input}: get the top-N specified by 'listView_numOfRows_input'   
        #   awk '$(NF+1)=length': get the length of each file-/folder-name and put it in the 2nd Column
        #       NOTE: the 1st column shows the file-/folder-name
        #   awk '{print $2}': get only the values of the 2nd column (which is contains the file-/folder-name length)
        #   sort -rn: sort in a DESCENDING ORDER
        #   uniq: only get unique values
        #   head -n 1: only get the TOP value

        object_maxLen=`ls ${dir_input} | grep "${keyWord_input}" | head -n ${listView_numOfRows_init} | awk '$(NF+1)=length' | awk '{print $2}' | sort -rn | uniq | head -n 1`

        #Get printf-column-with-percentage
        listView_numOfCols_auto=$((terminal_numOfCols/object_maxLen))

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
            printf '%b%s\n' "${FOUR_SPACES}***${ERROR_FG_LIGHTRED}ERROR${NOCOLOR}: ${ERRMSG_NUMBER_OF_COLUMNS_CAN_NOT_EXCEED_THREE}" | tee ${docker_container_dirlist_fpath}

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
    fi
}
dirContent_get_and_show_list__func()
{
    #Input args
    local lv_numOfCols=${1} #input is whether 'listView_numOfCols_auto' or 'listView_numOfCols_input'

    #Calculate a more accurate value
    listView_numOfRows_accurate_wHeader=`ls ${dir_input} | grep "${keyWord_input}" | pr -${lv_numOfCols} | sed '/^$/d' | head -n ${listView_numOfRows__init_wHeader} | wc -l`
    listView_numOfRows_accurate=$((listView_numOfRows_accurate_wHeader-1))

    #Calculate the number of objects to-be-shown
    dirContent_numOfItems_shown=$((lv_numOfCols*listView_numOfRows_accurate))

    #Get directory contents specified by 'dir_input' and keyword 'keyWord_input'
    dirContent_list_string=`ls ${dir_input} | grep "${keyWord_input}" | pr -${lv_numOfCols} | sed '/^$/d' | head -n ${listView_numOfRows_accurate_wHeader} | tail -n ${listView_numOfRows_accurate}`

    #Show directory contents specified by 'dir_input' and keyword 'keyWord_input'
    printf '%b\t\n' "${FG_ORANGE}${dirContent_list_string}${NOCOLOR}"
}

main__sub()
{
  dirContent_main__sub  
}

#---Execute
main__sub

