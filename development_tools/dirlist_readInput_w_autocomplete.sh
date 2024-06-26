#!/bin/bash -m
#Remark: by using '-m' the INTERRUPT executed here will NOT propagate to the UPPERLAYER scripts
#---INPUT ARGS
containerID__argv=${1}
dir__argv=${2}
readMsg__argv=${3}
readMsgRemarks__argv=${4}
output_fPath__argv=${5}
tmp_fPath__argv=${6}   #the temporary backup fullpath of 'output_fPath__argv'
dir_menuTitle__argv=${7}
tibboHeader_prepend_numOfLines__argv=${8}



#---FUNCTIONS
function arrowKeys_upDown_handler__func() {
    # Flush "stdin" with 0.1  sec timeout.
    read -rsn1 -t 0.1 tmp
    if [[ "$tmp" == "[" ]]; then
        # Flush "stdin" with 0.1  sec timeout.
        read -rsn1 -t 0.1 tmp
    fi

    #Flush "stdin" with 0.1  sec timeout.
    read -rsn5 -t 0.1
}

function autocomplete__func() {
    #Input args
    #Remark:
    #1. non-array parameter(s) precede(s) array-parameter
    #2. For each non-array parameter, the 'shift' operator has to be added an array-parameter
    local fpath__input=${1}
    shift
    local dataArr__input=("$@")

    #Define constants
    local PHASE_AUTO=0
    local PHASE_EXIT=1

    #Define and initialize variables
    local col1=${DOCKER__EMPTYSTRING}
    local col2=${DOCKER__EMPTYSTRING}
    local col3=${DOCKER__EMPTYSTRING}
    local dir=${DOCKER__EMPTYSTRING}
    local fpath=${DOCKER__EMPTYSTRING}
    local keyWord=${DOCKER__EMPTYSTRING}
    local keyword_output=${DOCKER__EMPTYSTRING}
    local keyWord_bck=${DOCKER__EMPTYSTRING}
    local phase=${PHASE_AUTO}
    local ret=${DOCKER__EMPTYSTRING}

    local dataArr_1stItem_len=0
    local keyWord_len=0
    local numOfMatch=0
    local numOfMatch_init=0

    local isDirectory=false
    local slash_isFound=false



    #Check if 'fpath__input' is an Empty String
    if [[ -z ${fpath__input} ]]; then
        keyword_output=${DOCKER__SLASH}

        phase=${PHASE_EXIT}
    fi

    #Split directory from file/folder
    dir=`get_dirname_from_specified_path__func "${fpath__input}"`
    keyWord=`get_basename_rev1__func "${fpath__input}"`
    
    #Check if 'keyWord' is an Empty String
    #Remark:
    #   dir is Not an Empty String
    if [[ -z ${keyWord} ]]; then
        keyword_output=${keyWord}

        #Set the following parameters to '1'
        #Remark:
        #   There is No Match for the specified 'keyWord' because it is an Empty String
        #   However, there is a match for the current directory 'dir' itself
        numOfMatch_init=1
        numOfMatch=1

        phase=${PHASE_EXIT}
    fi

    #Select case
    while true
    do
        case "${phase}" in
            ${PHASE_AUTO})
                #Substitute all backslash's '\' with double-backslash's '\\' (if any)
                #Remark:
                #   This is necessary because otherwise 'grep' will not recognize the backslash '\' as a string.
                keyWord=`echo "${keyWord}" | sed "s/${SED__BACKSLASH}/${SED__DOUBLE_BACKSLASH}/g"`

                #Substitute all dot's '.' with backslash-dot's '\.' (if any)
                #Remark:
                #   This is necessary because otherwise 'grep' will not recognize the dot '.' as a string.
                keyWord=`echo "${keyWord}" | sed "s/${SED__DOT}/${SED__BACKSLASH_DOT}/g"`         

                #initialization
                dataArr_1stItem_len=${#dataArr__input[0]}
                numOfMatch_init=`printf '%s\n' "${dataArr__input[@]}" | grep "^${keyWord}" | wc -l` #the initial number of matches for a specified 'keyWord'
                numOfMatch=${numOfMatch_init}   #the number of matches that is being recalculated each time theh 'keyWord' changes

                #Find the closest match
                while true
                do
                    if [[ ${numOfMatch_init} -eq 0 ]]; then  #no match
                        #Set value to 'keyWord' (which is the input value)
                        keyword_output=${keyWord}

                        #Set number of matches to 0
                        numOfMatch=0

                        #Exit loop
                        break
                    elif [[ ${numOfMatch_init} -eq 1 ]]; then  #only 1 match
                        #Fetch value from array
                        keyword_output=`printf '%s\n' "${dataArr__input[@]}" | grep "^${keyWord}"`

                        #Set number of matches to 0
                        numOfMatch=1

                        #Exit loop
                        break;
                    else    #multiple matches
                        #Backup keyWord.
                        #Remark:
                        #   This backup will be used as output the moment that 'numOfMatch != numOfMatch_init'
                        keyWord_bck=${keyWord}

                        #Get keyWord length
                        keyWord_bck_len=${#keyWord_bck}

                        #Increment keyWord length by 1
                        keyWord_len=$((keyWord_bck_len + 1))

                        #Get the next keyWord by:
                        # 1. using the 1st array-element as base-word
                        # 2. and...incrementing 'keyWord' with 1 character every loop cycle
                        keyWord=${dataArr__input[0]:0:keyWord_len}

                        #Check if the total length of the 1st array-element has been reached
                        #If true, then it means that there is only 1 match.
                        if [[ ${keyWord_bck_len} -eq ${dataArr_1stItem_len} ]]; then
                            #Set 'keyword_output' to the last backup value 'keyWord_bck'
                            keyword_output=${keyWord_bck}

                            break
                        fi

                        #Get the new number of matches
                        numOfMatch=`printf '%s\n' "${dataArr__input[@]}" | grep "^${keyWord}" | wc -l`

                        #Compare the new 'numOfMatch' with the initial 'numOfMatch_init'
                        if [[ ${numOfMatch} -ne ${numOfMatch_init} ]]; then
                            #Set 'keyword_output' to the last backup value 'keyWord_bck'
                            keyword_output=${keyWord_bck}

                            #Set 'numOfMatch' to the initial value 'numOfMatch_init'
                            numOfMatch=${numOfMatch_init}

                            break
                        fi
                    fi
                done

                #Goto next-phase
                phase=${PHASE_EXIT}
                
                ;;
            ${PHASE_EXIT})
                #Compoase full-path
                fpath=${dir}${keyword_output}

                #Substitute all BackSlash-Dot's '\.' with Dot's '.' (if any)
                fpath=`echo "${fpath}" | sed "s/${SED__BACKSLASH_DOT}/${SED__DOT}/g"`

                #Substitute all backslash's '\' with double-backslash's '\\' (if any)
                fpath=`echo "${fpath}" | sed "s/${SED__BACKSLASH}/${SED__DOUBLE_BACKSLASH}/g"`       

                #Only handle this condition if 'numOfMatch = 1'
                if [[ ${numOfMatch} -eq ${DOCKER__NUMOFMATCH_1} ]]; then
                    #Check if 'fpath' is a directory
                    isDirectory=`checkIf_dir_exists__func "${containerID__argv}" "${fpath}"`
                    if [[ ${isDirectory} == true ]]; then   #is directory
                        #Check if slash is found
                        slash_isFound=`checkIf_string_contains_a_trailing_specified_chars__func \
                                "${fpath}" \
                                "${DOCKER__NUMOFCHARS_1}" \
                                "${DOCKER__SLASH}"`
                        if [[ ${slash_isFound} == false ]]; then    #slash is NOT found
                            fpath=${fpath}${DOCKER__SLASH}  #append slash
                        fi
                    fi
                fi

                #Compose return string
                #Remark:
                #   This string consists of 3 columns delimited by a comma
                #   - col1: fpath
                #   - col2: numOfMatch_init
                #   - col3: numOfMatch
                #
                col1=${fpath}
                col2=${numOfMatch_init}
                col3=${numOfMatch}

                ret="${col1}${DOCKER__STX}${col2}${DOCKER__STX}${col3}"

                #Exit while-loop
                break
                ;;        
        esac
    done

    #Output
    echo -e "${ret}"
}

function backspace_handler__func() {
    #Input args
    str_input=${1}

    #CHeck if 'str_input' is an EMPTYSTRING
    if [[ -z ${str_input} ]]; then
        return
    fi

    #Constants
    OFFSET=0

    #Lengths
    str_input_len=${#str_input}
    str_output_len=$((str_input_len-1))

    #Get result
    str_output=${str_input:${OFFSET}:${str_output_len}}

    #Output
    echo "${str_output}"
}

function remove_asterisk_from_string() {
    #Input args
    local str__input=${1}

    #Define variables
    local ret=${DOCKER__EMPTYSTRING}
    local str_len=0
    local str_wo_asterisk_len=0
    local asterisk_isFound=false
    local isFile=false

    #Check if asterisk is present in 'str__input'
    asterisk_isFound=$(checkif_asterisk_isvalid "${str__input}")
    if [[ ${asterisk_isFound} == true ]]; then  #match found
        str_len=${#str__input}  #get length

        str_wo_asterisk_len=$((ret_len - 1))    #get length of stirng without asterisk

        ret=${str__input:0:str_wo_asterisk_len} #get return string without asterisk
    else
        ret=${str__input}   #set return string to input string
    fi

    #Output
    echo "${ret}"
}

function process_str_basedOn_numOf_results__func() {
    #Input args
    local str_autocompleted__input="${1}"
    local str__input="${2}"
    local autocomplete_numOfMatches__input="${3}"
    local asterisk_isfound__input="${4}"
    local rangeNotation_isFound__input="${5}"

    #Define variables
    local ret="${DOCKER__EMPTYSTRING}"

    #Check the number of matches
    if [[ ${rangeNotation_isFound__input} == true ]]; then   #asterisk or range-notation found
        ret="${str__input}"
    else
        if [[ ${autocomplete_numOfMatches__input} -eq ${DOCKER__NUMOFMATCH_1} ]]; then  #autocomplete only found 1 match
            ret="${str_autocompleted__input}"
        else    #autocomplete found multiple matches
            if [[ ${asterisk_isfound__input} == true ]]; then   #asterisk or range-notation found
                ret="${str__input}"
            else    #no asterisk or range-notation is present
                ret="${str_autocompleted__input}"
            fi
        fi
    fi

    #Remove any double slashes
    ret=$(echo "${ret}" | sed "s/${SED__SLASH}${SED__SLASH}${SED__ASTERISK}/${SED__SLASH}/g")

    #Output
    echo "${ret}"
}

function phaseOne_retrieve_all_files_and_folders_matching_basename_of_str_trimmed__sub() {
    #Input args
    local containerID__argv=${1}
    local fpath__input=${2}
    local backupIsEnabled__input=${3}

    #Split directory from file/folder
    local dir=`get_dirname_from_specified_path__func "${fpath__input}"`
    local keyWord=`get_basename_rev1__func "${fpath__input}"`

    #Define local variables
    local cachedInputArr_string=${DOCKER__EMPTYSTRING}
    local cachedInputArr_raw_string=${DOCKER__EMPTYSTRING}

    #These are global variables
    cachedInput_Arr=()
    cachedInput_ArrLen=0
    cachedInput_ArrIndex=0
    cachedInput_ArrIndex_max=0

    #Check if 'dir' is an Empty String
    if [[ -z ${dir} ]]; then
        dir=${DOCKER__SLASH}
    fi

    #Get result and put in array
    if [[ -z ${keyWord} ]]; then
        if [[ -z ${containerID__argv} ]]; then
            readarray -t cachedInput_Arr < <(eval ls -1aA ${dir} | awk '!a[$0]++')
        else
            readarray -t cachedInput_Arr < <(${docker__exec_cmd} "eval ls -1aA ${dir}" | tr -d $'\r' | awk '!a[$0]++')
        fi
    else
        if [[ -z ${containerID__argv} ]]; then
            readarray -t cachedInput_Arr < <(eval ls -1aA ${dir} | grep "^${keyWord}" | awk '!a[$0]++')
        else
            readarray -t cachedInput_Arr < <(${docker__exec_cmd} "eval ls -1aA ${dir} | grep "^${keyWord}"" | tr -d $'\r' | awk '!a[$0]++')
        fi
    fi

    #Update array-length
    cachedInput__ArrLen=${#cachedInput_Arr[@]}

    #Index starts with 0, therefore deduct array-length by 1
    cachedInput_ArrIndex_max=$((cachedInput_ArrLen-1))

    #Update current array-index
    cachedInput_ArrIndex=${cachedInput_ArrIndex_max}

    #Check if file exist, then:
    #1. remove backup file 'tmp_fPath__argv'
    #2. backup file 'output_fPath__argv'
    #3. remove file 'output_fPath__argv'
    #4. write array contents to file 'output_fPath__argv'
    if [[ -f ${output_fPath__argv} ]]; then
        if [[ ${backupIsEnabled__input} == true ]]; then
            #step 1:
            if [[ -f ${tmp_fPath__argv} ]]; then
                rm ${tmp_fPath__argv}
            fi

            #step 2:
            cp ${output_fPath__argv} ${tmp_fPath__argv}
        fi

        #step 3:
        rm ${output_fPath__argv}
    fi

    ##step 4:
    if [[ ${cachedInput__ArrLen} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
        printf "%s\n" "${cachedInput_Arr[@]}" > ${output_fPath__argv}

    else
        touch ${output_fPath__argv}
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

dirlist__initial_file_cleanup__sub() {
    if [[ -f ${output_fPath__argv} ]]; then
        rm ${output_fPath__argv}
    fi
    if [[ -f ${tmp_fPath__argv} ]]; then
        rm ${tmp_fPath__argv}
    fi
}

dirlist__initialize_variables__sub() {
    docker__exec_cmd="docker exec -t ${containerID__argv} ${docker__bin_bash__dir} -c"
    docker__containerid_state=false
}

dirlist__preCheck_if_containerID_isRunning__sub() {
    #Define constants
    local ERRMSG_CONTAINERID_IS_NOT_FOUND="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: ${DOCKER__FG_BRIGHTPRUPLE}Container-ID${DOCKER__NOCOLOR} '${containerID__argv}' is NOT Found"
    local ERRMSG_CONTAINERID_IS_EXITED="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: ${DOCKER__FG_BRIGHTPRUPLE}Container-ID${DOCKER__NOCOLOR} '${containerID__argv}' is Exited"

    #Check if 'containerID__argv' (if provided) is running
    if [[ ${containerID__argv} != ${DOCKER__EMPTYSTRING} ]]; then
        docker__containerid_state=`check_containerID_state__func "${containerID__argv}"`
        if [[ ${docker__containerid_state} == ${DOCKER__STATE_NOTFOUND} ]]; then
            show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_CONTAINERID_IS_NOT_FOUND}" "${DOCKER__NUMOFLINES_1}"

            # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_1}"
        elif [[ ${docker__containerid_state} == ${DOCKER__STATE_EXITED} ]]; then
            show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_CONTAINERID_IS_EXITED}" "${DOCKER__NUMOFLINES_1}"

            # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_1}"
        fi
    fi
}

dirlist__readInput_w_autocomplete__sub() {
    #Disable EXPANSION
    #Remark:
    #   This allows variables to contains special characters like asterisk '*' which can be matched via 'grep'.
    set -f

    #Input args
    local containerID__argv=${1}
    local readMsg__argv=${2}
    local readMsgRemarks__argv=${3}

    #Remove file
    if [[ -f ${dirlist__readInput_w_autocomplete_out__fpath} ]]; then
        rm ${dirlist__readInput_w_autocomplete_out__fpath}
    fi

    #Calculate number of lines to be cleaned
    local readMsg_numOfLines=0
    if [[ ! -z ${readMsg__argv} ]]; then    #this condition is important
        readMsg_numOfLines=`echo -e ${readMsg__argv} | wc -l`      
    fi
    local remarks_numOfLines=0
    if [[ ! -z ${readMsgRemarks__argv} ]]; then    #this condition is important
        remarks_numOfLines=`echo -e ${readMsgRemarks__argv} | wc -l`      
    fi
    local numOfLines_noError_tot=$((readMsg_numOfLines + remarks_numOfLines))

    #Initialization
    local autocomplete_output=${DOCKER__EMPTYSTRING}
    local keyInput=${DOCKER__EMPTYSTRING}
    local keyInput_add=${DOCKER__EMPTYSTRING}
    local phase=${DOCKER__EMPTYSTRING}
    local str=${DOCKER__EMPTYSTRING}
    local str_autocompleted=${DOCKER__EMPTYSTRING}
    local str_prev=${DOCKER__EMPTYSTRING}
    local str_shown=${DOCKER__EMPTYSTRING}
    local ret=${DOCKER__EMPTYSTRING}
    local ret_tmp=${DOCKER__EMPTYSTRING}

    local autocomplete_numOfMatches=0
    local autocomplete_numOfMatches_init=0

    local backupIsEnabled=false
    local files_areDifferent=false
    local fpaths_areSame=false
    local invalidKeyInputIsFound=false
    local noMatchIsFound=false
    local onEnterPressed=false
    local onExit_moveDown_isEnabled=false
    local onExit_show_readInput_message=false



    #Start phase
    if [[ ! -z ${dir__argv} ]]; then
        str=${dir__argv}
    else
        str=${DOCKER__SLASH}
    fi
    keyInput=${DOCKER__TAB}
    phase=${PHASE_KEYINPUT_HANDLER}

    while true
    do
        case "${phase}" in
            ${PHASE_SHOW_REMARKS})
                #Show remarks if 'readMsgRemarks__argv' is NOT an Empty String
                if [[ ! -z ${readMsgRemarks__argv} ]]; then
                    echo -e "${readMsgRemarks__argv}"

                    #Append horizontal line
                    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
                fi

                phase=${PHASE_SHOW_READINPUT}
            ;;
            ${PHASE_SHOW_READINPUT})
                #***IMPORTANT: reset 'onEnterPressed'
                onEnterPressed=false

                #Show read-input message with error
                if [[ ${noMatchIsFound} == true ]]; then
                    #Show error message
                    echo -e "${readMsg__argv}${str} (${DOCKER__STATUS_LNOMATCHFOUND})" 

                    #Wait for 2 seconds
                    sleep 1

                    #Move-up and clean line
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                    #Reset flag
                    noMatchIsFound=false
                fi

                if [[ ${invalidKeyInputIsFound} == true ]]; then
                    #Show error message
                    echo -e "${readMsg__argv}${str} (${DOCKER__STATUS_LINVALID_KEYINPUT_COMBO})" 

                    #Wait for 2 seconds
                    sleep 1

                    #Move-up and clean line
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                    #Reset flag
                    invalidKeyInputIsFound=false
                fi

                #Show read-input message
                echo -e "${readMsg__argv}${str}"

                #Move cursor up
                moveUp_oneLine_then_moveRight__func "${readMsg__argv}" "${str}"

                #Read-input
                read -N1 -rs -p "" keyInput

                phase=${PHASE_KEYINPUT_HANDLER}
            ;;
            ${PHASE_KEYINPUT_HANDLER})
                #Select case based on 'keyInput'
                case "${keyInput}" in
                    ${DOCKER__ENTER})
                        #Check if there were any ';b', ';c', ';h' issued.
                        #In other words, whether 'str' contains any of the above semi-colon chars.
                        #If that's the case then function 'get_endResult_ofString_with_semiColonChar__func'
                        #   will handle and return the result 'ret'.
                        ret_tmp=`get_endResult_ofString_with_semiColonChar__func "${str}"`

                        case "${ret_tmp}" in
                            ${DOCKER__SEMICOLON_BACK})
                                ret=${ret_tmp}

                                break
                                ;;
                            ${DOCKER__SEMICOLON_HOME})
                                ret=${ret_tmp}

                                break
                                ;;
                            ${DOCKER__EMPTYSTRING})
                                #Reset variable
                                str=${DOCKER__SLASH}

                                #Goto next-phase
                                phase=${PHASE_SHOW_READINPUT}
                                
                                #First Move-down, then Move-up, after that clean line
                                moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"
                                ;;
                            *)
                                #Set flag to 'true'
                                onEnterPressed=true

                                #Goto next-phase
                                phase=${PHASE_KEYINPUT_HANDLER}

                                #Check if new read-input value 'str' is different from the previous value 'str_prev'. 
                                #Remark:
                                #   If true, then it means that 'str' has not been processed yet right before ENTER was pressed.
                                #   Therefore 'str' has to be processed by: 
                                #   1. goto 'DOCKER__TAB' and process 'str'.
                                #   2. after that, exit the loop
                                #   3. output 'ret'
                                if [[ ${str} != ${str_prev} ]]; then
                                    # str="${str}"

                                    #Goto 'keyInput = DOCKER__TAB'.
                                    #Remark:
                                    #   skip read-input dialog.
                                    keyInput=${DOCKER__TAB}

                                    #Set flag to 'true'
                                    #***NOTE: this is a CORRECTIVE ACTION to show the read-input message, because
                                    #       without this corrective action, NO read-input message is shown AFTER
                                    #       the 'DOCKER__TAB' is processed
                                    onExit_show_readInput_message=true

                                else    #the new read-input value 'str' is the same as the previous value 'str_prev'.
                                    ret=${ret_tmp}

                                    #Set flag to 'true'
                                    #***NOTE: this is a CORRECTIVE ACTION to move-down cursor.
                                    onExit_moveDown_isEnabled=true

                                    #Goto 'keyInput = DOCKER__EXIT'.
                                    #Remark:
                                    #   skip read-input dialog.
                                    keyInput=${DOCKER__EXIT}
                                fi
                                ;;
                        esac
                        ;;
                    ${DOCKER__BACKSPACE})
                        #Update variable
                        str=`backspace_handler__func "${str}"`

                        #Goto next-phase
                        phase=${PHASE_SHOW_READINPUT}

                        #First Move-down, then Move-up, after that clean line
                        moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"
                        ;;
                    ${DOCKER__ESCAPEKEY})
                        #Handle Arrowkey-press
                        arrowKeys_upDown_handler__func

                        #Goto next-phase
                        phase=${PHASE_SHOW_READINPUT}

                        #First Move-down, then Move-up, after that clean line
                        moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"
                        ;;
                    ${DOCKER__TAB})
                        #Check if 'str' and 'str_prev' are DIFFERENT?
                        #***NOTE: this check is done to avoid processing the same task again.
                        if [[ "${str}" != "${str_prev}" ]]; then  #Yes, they are different
                            #Define constants
                            local SUBPHASE_CHECKIF_ASTERISK_AND_RANGENOTATION_ARE_PRESENT="1"
                            local SUBPHASE_CHECKIF_ASTERISK_IS_PRESENT="2"
                            local SUBPPHASE_CHECKIF_RANGENOTATION_IS_PRESENT="3"
                            local SUBPHASE_AUTOCOMPLETE="4"
                            local SUBPHASE_FINALIZE="5"
                            local SUBPHASE_EXIT="100"

                            #Define and set subphase
                            local subphase="${SUBPHASE_CHECKIF_ASTERISK_AND_RANGENOTATION_ARE_PRESENT}"

                            #Define variables
                            local str_trimmed=${DOCKER__EMPTYSTRING}

                            #Define flags
                            local atTab_asterisk_isFound=false
                            local atTab_rangeNotation_isFound=false

                            #Start loop
                            while [[ true ]]
                            do
                                case ${subphase} in
                                    "${SUBPHASE_CHECKIF_ASTERISK_AND_RANGENOTATION_ARE_PRESENT}")
                                        if [[ $(CheckIf_Both_Asterisk_And_RangeNotation_ArePresent "${str}") == true ]]; then
                                            invalidKeyInputIsFound=true

                                            subphase="${SUBPHASE_EXIT}"

                                            phase="${PHASE_SHOW_READINPUT}"

                                            #First Move-down, then Move-up, after that clean line
                                            moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"   
                                        else
                                            subphase="${SUBPHASE_CHECKIF_ASTERISK_IS_PRESENT}"
                                        fi
                                        ;;

                                    "${SUBPHASE_CHECKIF_ASTERISK_IS_PRESENT}")
                                        if [[ $(checkif_asterisk_isvalid "${str}") == true ]]; then
                                            atTab_asterisk_isFound=true

                                            str_trimmed=$(remove_trailing_chars_from_path "${str}" "${DOCKER__NUMOFCHARS_1}")

                                            subphase="${SUBPHASE_AUTOCOMPLETE}"
                                        else
                                            atTab_asterisk_isFound=false

                                            subphase="${SUBPPHASE_CHECKIF_RANGENOTATION_IS_PRESENT}"
                                        fi
                                        ;;
                                    "${SUBPPHASE_CHECKIF_RANGENOTATION_IS_PRESENT}")
                                        if [[ $(CheckIf_RangeNotation_IsValid "${str}") == true ]]; then
                                            str_trimmed=$(remove_trailing_chars_from_path "${str}" "${DOCKER__NUMOFCHARS_5}")

                                            atTab_rangeNotation_isFound=true
                                        else
                                            str_trimmed="${str}"

                                            atTab_rangeNotation_isFound=false
                                        fi

                                        subphase="${SUBPHASE_AUTOCOMPLETE}"
                                        ;;                                        
                                    "${SUBPHASE_AUTOCOMPLETE}")
#---------------------------------------Retrieve all files & folders which match the 'basename' of 'str_trimmed'
                                        #***IMPORTANT: set boolean to 'true'
                                        backupIsEnabled=true

                                        #This function DIRECTLY updates the following files:
                                        #   1. output_fPath__argv
                                        #   2. tmp_fPath__argv
                                        phaseOne_retrieve_all_files_and_folders_matching_basename_of_str_trimmed__sub "${containerID__argv}" \
                                                "${str_trimmed}" \
                                                "${backupIsEnabled}"

#---------------------------------------AUTOCOMPLETE: Find the closest match
                                        #Output contains the following values delimited by a comma:
                                        #   col1: str_autocompleted
                                        #   col2: autocomplete_numOfMatches_init
                                        #   col3: autocomplete_numOfMatches
                                        autocomplete_output=`autocomplete__func "${str_trimmed}" "${cachedInput_Arr[@]}"`

                                        #Separate each output element:
                                        str_autocompleted=`echo "${autocomplete_output}" | cut -d"${DOCKER__STX}" -f1`
                                        autocomplete_numOfMatches_init=`echo "${autocomplete_output}" | cut -d"${DOCKER__STX}" -f2`
                                        autocomplete_numOfMatches=`echo "${autocomplete_output}" | cut -d"${DOCKER__STX}" -f3`

#---------------------------------------Retrieve all files & folders of the specified 'str_autocompleted'
                                        #***IMPORTANT: set boolean to 'false'
                                        backupIsEnabled=false

                                        #This function INDIRECTLY updates ONLY output_fPath__argv
                                        #***NOTE: 'tmp_fPath__argv' MUST NOT be UPDATED, because next in fucntion 'checkIf_files_are_different__func'
                                        #   file 'output_fPath__argv' is compared with compared with 'tmp_fPath__argv' to see if there are any changes.
                                        phaseTwo_retrieve_files_and_folders_of_specified_str_autocompleted__sub "${str_autocompleted}" \
                                                "${str}" \
                                                "${autocomplete_numOfMatches_init}" \
                                                "${autocomplete_numOfMatches}" \
                                                "${backupIsEnabled}"

#---------------------------------------Show directory content based on the specified 'containerID__argv, str_autocompleted, output_fPath__argv'
                                        #Only handle this condition if 'autocomplete_numOfMatches > 0'
                                        if [[ ${autocomplete_numOfMatches} -ne ${DOCKER__NUMOFMATCH_0} ]]; then
                                            #Check if the file contents are different
                                            files_areDifferent=`checkIf_files_are_different__func ${output_fPath__argv} ${tmp_fPath__argv}`
                                            if [[ "${files_areDifferent}" == true ]]; then   #file contents are different
                                                dirlist__show_dirContent_handler__sub "${containerID__argv}" \
                                                        "${str_autocompleted}" \
                                                        "${output_fPath__argv}" \
                                                        "${dir_menuTitle__argv}" \
                                                        "${tibboHeader_prepend_numOfLines__argv}"

                                                #Update 'str_shown'
                                                str_shown=${str_autocompleted}

                                                #Goto next-phase
                                                phase=${PHASE_SHOW_REMARKS}
                                            else    #file contents are the same
                                                #Check whether 'str_autocompleted != str_shown'
                                                fpaths_areSame=`checkIf_fpaths_are_the_same__func "${str_autocompleted}" "${str_shown}"`
                                                if [[ ${fpaths_areSame} == false ]]; then #fullpaths are not the same
                                                    dirlist__show_dirContent_handler__sub "${containerID__argv}" \
                                                            "${str_autocompleted}" \
                                                            "${output_fPath__argv}" \
                                                            "${dir_menuTitle__argv}" \
                                                            "${tibboHeader_prepend_numOfLines__argv}"

                                                    #Update 'str_shown'
                                                    str_shown=${str_autocompleted}
                                                    
                                                    #Goto next-phase
                                                    phase=${PHASE_SHOW_REMARKS}
                                                else
                                                    #Goto next-phase
                                                    phase=${PHASE_SHOW_READINPUT}

                                                    #First Move-down, then Move-up, after that clean line
                                                    moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"
                                                fi
                                            fi
                                        fi

                                        subphase="${SUBPHASE_FINALIZE}"

#---------------------------------------Set 'tibboHeader_prepend_numOfLines__argv' (MUST BE SET AT THIS POSITION!!!)
                                        if [[ ! -z ${tibboHeader_prepend_numOfLines__argv} ]]; then
                                            tibboHeader_prepend_numOfLines__argv=${DOCKER__NUMOFLINES_3}
                                        fi
                                        ;;
                                    "${SUBPHASE_FINALIZE}")
#---------------------------------------Restore 'str'
                                        str=$(process_str_basedOn_numOf_results__func "${str_autocompleted}" \
                                                "${str}" \
                                                "${autocomplete_numOfMatches}" \
                                                "${atTab_asterisk_isFound}" \
                                                "${atTab_rangeNotation_isFound}")

#---------------------------------------Backup 'str'
                                        str_prev=${str}

#---------------------------------------Check if 'onEnterPressed = true'
                                        if [[ ${onEnterPressed} == true ]]; then
                                            #Update 'ret'
                                            ret="${str}"

                                            #Goto next-phase
                                            phase=${PHASE_KEYINPUT_HANDLER}
                                        
                                            #Goto 'keyInput = DOCKER__EXIT'
                                            keyInput=${DOCKER__EXIT}
                                        fi

                                        subphase="${SUBPHASE_EXIT}"
                                        ;;
                                    "${SUBPHASE_EXIT}")
                                        break
                                        ;;
                                esac
                            done
                        else    #No, they are the same
                            #Goto next-phase
                            phase=${PHASE_SHOW_READINPUT}
                            
                            #First Move-down, then Move-up, after that clean line
                            moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"                
                        fi
                        ;;
                    ${DOCKER__EXIT})
                        #Check if at least one match is found
                        if [[ ${autocomplete_numOfMatches} -ne ${DOCKER__NUMOFMATCH_0} ]]; then #at least one match is found
                            #Check if 'ret' is ends with a range-notation {.-.}
                            local atExit_rangeNotation_isFound=$(CheckIf_RangeNotation_IsValid "${ret}")
                            
                            if [[ ${atExit_rangeNotation_isFound} == false ]]; then  #Yes, range-notiation is present
                                if [[ ${autocomplete_numOfMatches} -gt ${DOCKER__NUMOFMATCH_1} ]]; then #at least two matches were found
                                    #Check if 'ret' is ends with an asterisk (*)
                                    local atExit_asterisk_isFound=$(checkif_asterisk_isvalid "${ret}")

                                    #***NOTE: if asterisk (*) is found then do NOTHING.
                                    if [[ ${atExit_asterisk_isFound} == false ]]; then  #asterisk was NOT found
                                        #Check if 'ret' is a file
                                        isFile=$(checkIf_file_exists__func "${containerID__argv}" "${ret}")
                                        #NOTE:
                                        #   a. if True, then DO NOTHING. It means that a file is really present with that name.
                                        #   ***NOTE: should you want to not copy only this file, but a number of files from which
                                        #       the 'keyword' is the SAME as this file, then append an asterisk(*) at the end.
                                        #   b. if False, then proceed and process the commands within the if-condition.
                                        if [[ ${isFile} == false ]]; then    #No, is NOT a file
                                            ret="${ret}${DOCKER__ASTERISK}" #append asterisk
                                        fi
                                    fi
                                fi
                            fi

                            if [[ ${onExit_show_readInput_message} == true ]]; then
                                echo -e "${readMsg__argv}${ret}"
                            fi

                            if [[ ${onExit_moveDown_isEnabled} == true ]]; then
                                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                            fi

                            break
                        else    #no match was found
                            #Set flag to 'false'
                            #***NOTE: this prevents us from exiting this function.
                            onEnterPressed=false

                            #Set flag to 'true'
                            noMatchIsFound=true

                            #Goto next-phase
                            phase=${PHASE_SHOW_READINPUT}

                            #First Move-down, then Move-up, after that clean line
                            moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"   
                        fi
                        ;;
                    *)
                        #wait for another 0.5 seconds to capture additional characters.
                        #Remark:
                        #   This part has been implemented just in case long text has been copied/pasted.
                        read -rs -t0.01 keyInput_add

                        #Append 'keyInput_add' to 'keyInput'
                        keyInput="${keyInput}${keyInput_add}"
                        
                        #Append 'keyInput' to 'str'
                        if [[ ! -z ${keyInput} ]]; then
                            str="${str}${keyInput}"
                        fi

                        #Goto next-phase
                        phase=${PHASE_SHOW_READINPUT}

                        #First Move-down, then Move-up, after that clean line
                        moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"
                        ;;
                esac
                ;;
        esac
    done

    #Write chosen path to file (line 0)
    echo "${ret}" > "${dirlist__readInput_w_autocomplete_out__fpath}"

    #Write number of matches to file (line 1)
    echo ${cachedInput__ArrLen} >> ${dirlist__readInput_w_autocomplete_out__fpath}

    #Enable EXPANSION
    set +f
}

phaseTwo_retrieve_files_and_folders_of_specified_str_autocompleted__sub() {
    #Input args
    local fpath_new__input=${1}
    local fpath_bck__input=${2}
    local numOfMatches_init__input=${3}
    local numOfMatches_new__input=${4}
    local backupIsEnabled__input=${5}

    #Determine if it is required to run 'phaseOne_retrieve_all_files_and_folders_matching_basename_of_str_trimmed__sub'.
    if [[ "${numOfMatches_new__input}" -ne "${numOfMatches_init__input}" ]]; then #fullpaths are not the same
        #RELoad directory content into array
        phaseOne_retrieve_all_files_and_folders_matching_basename_of_str_trimmed__sub "${containerID__argv}" "${fpath_new__input}" "${backupIsEnabled__input}"

        #Exit subroutine
        return
    fi

    #In case 'numOfMatches_init__input = numOfMatches_new__input'...
    #...check whether 'fpath_new__input != fpath_bck__input'
    if [[ "${fpath_new__input}" != "${fpath_bck__input}" ]]; then #fullpaths are not the same
        #RELoad directory content into array
        phaseOne_retrieve_all_files_and_folders_matching_basename_of_str_trimmed__sub "${containerID__argv}" "${fpath_new__input}" "${backupIsEnabled__input}"
    fi
}

dirlist__readInput_handler__sub() {
    #Get read-input value
    dirlist__readInput_w_autocomplete__sub "${containerID__argv}" "${readMsg__argv}" "${readMsgRemarks__argv}"

    #Print empty lines
    # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
}

dirlist__show_dirContent_handler__sub() {
	#Input args
	local containerID__argv=${1}
	local fpath__input=${2}
    local dirlistContentFpath__input=${3}
    local menuTitle__input=${4}
    local tibboHeader_prepend_numOfLines__argv=${5}

    #Split directory from file/folder
    local dir=`get_dirname_from_specified_path__func "${fpath__input}"`
    local keyWord=`get_basename_rev1__func "${fpath__input}"`

    #Move down one line
    if [[ ! -z ${menuTitle__input} ]]; then
        show_menuTitle_w_adjustable_indent__func "${menuTitle__input}" "${DOCKER__EMPTYSTRING}"
    # else
    #     moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    fi

    #Show directory content
	if [[ -z ${containerID__argv} ]]; then	#LOCAL machine (aka HOST)
		${dclcau_lh_ls__fpath} "${dir}" \
                    "${DOCKER__TABLEROWS_20}" \
                    "${DOCKER__TABLECOLS_0}" \
                    "${keyWord}" \
                    "${dirlistContentFpath__input}" \
                    "${tibboHeader_prepend_numOfLines__argv}"

	else	#REMOTE machine (aka Container)
		${dclcau_dc_ls__fpath} "${containerID__argv}" \
                    "${dir}" \
                    "${DOCKER__TABLEROWS_20}" \
                    "${DOCKER__TABLECOLS_0}" \
                    "${keyWord}" \
                    "${dirlistContentFpath__input}" \
                    "${tibboHeader_prepend_numOfLines__argv}"
	fi
}



#---MAIN SUBROUTINE
main__sub() {
    docker__get_source_fullpath__sub

    docker__load_global_fpath_paths__sub

    dirlist__initial_file_cleanup__sub

    dirlist__initialize_variables__sub

    dirlist__preCheck_if_containerID_isRunning__sub

    dirlist__readInput_handler__sub
}



#---EXECUTE
main__sub
