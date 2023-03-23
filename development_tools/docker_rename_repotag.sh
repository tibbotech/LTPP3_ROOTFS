#!/bin/bash -m
#Remark: by using '-m' the INTERRUPT executed here will NOT propagate to the UPPERLAYER scripts
#---NUMERIC CONSTANTS
DOCKER__NUMOF_FILES_TOBE_KEPT_MAX=100


docker__LTPP3_ROOTFS__dir=/home/imcase/repo/LTPP3_ROOTFS
docker__parentDir_of_LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS__dir%/*}
docker__LTPP3_ROOTFS_development_tools__dir=${docker__LTPP3_ROOTFS__dir}/development_tools
docker__global__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/docker_global.sh

#***IMPORTANT: EXPORT PATHS
export docker__LTPP3_ROOTFS__dir
export docker__parentDir_of_LTPP3_ROOTFS__dir
export docker__LTPP3_ROOTFS_development_tools__dir
export docker__global__fpath



#---FUNCTIONS
function get_numOfLines_to_clean() {
    #Input args
    local msg__input=${1}
    local fixed_numOfLines__input=${2}

    #Number of lines of 'msg__input'
    msg_numOfLines=`get_numOfLines_for_specified_string_or_file__func "${msg__input}"`

    #Total number of lines
    ret=$((fixed_numOfLines__input + msg_numOfLines))
    
    #Output
    echo "${ret}"
}

function rename_repoTag_w_imageId__func() {
    #Input args
    local imageId__input=${1}
    local repoNew__input=${2}
    local tagNew__input=${3}

    #Rename
    docker image tag "${imageId__input}" "${repoNew__input}:${tagNew__input}"
}

function rename_repoTag_wo_imageId__func() {
    #Input args
    local repoOld__input=${1}
    local tagOld__input=${2}
    local repoNew__input=${3}
    local tagNew__input=${4}

    #Rename
    docker tag "${repoOld__input}:${tagOld__input}" "${repoNew__input}:${tagNew__input}"
}


function remove_repoTag__func() {
    #Input args
    local repo__input=${1}
    local tag__input=${2}

    #Rename
    docker rmi "${repo__input}:${tag__input}"
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
                                ;;
                        esac
                    else    #contains data
                        #Print
                        echo -e "---:\e[30;38;5;215mCOMPLETED\e[0;0m: find path of folder \e[30;38;5;246m'${development_tools_foldername}\e[0;0m"


                        #Write to file
                        echo "${docker__LTPP3_ROOTFS_development_tools__dir}" | tee "${mainmenu_path_cache_fpath}" >/dev/null

                        #Print
                        echo -e "---:\e[30;38;5;215mSTATUS\e[0;0m: write path to temporary cache-file: \e[1;33mDONE\e[0;0m"

                        #Update variable
                        result=true
                    fi

                    #set phase
                    phase="${PHASE_EXIT}"

                    #Exit loop
                    break
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

docker__init_variables__sub() {
    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

    docker__imageID_chosen=${DOCKER__EMPTYSTRING}
    docker__repo_chosen=${DOCKER__EMPTYSTRING}
    docker__tag_chosen=${DOCKER__EMPTYSTRING}
    docker__repo_new=${DOCKER__EMPTYSTRING}
    docker__tag_new=${DOCKER__EMPTYSTRING}
    docker__repo_existing=${DOCKER__EMPTYSTRING}
    docker__tag_existing=${DOCKER__EMPTYSTRING}
    docker__repo_renamed=${DOCKER__EMPTYSTRING}
    docker__tag_renamed=${DOCKER__EMPTYSTRING}

    docker__renameMsg_fromTo=${DOCKER__EMPTYSTRING}

    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

    docker__onEnter_breakLoop=false
    docker__showTable=true
}

docker__rename_image_handler__sub() {
    #Define phase constants
    local IMAGEID_SELECT_PHASE=1
    local REPOTAG_RETRIEVE_PHASE=2
    local NEW_REPO_INPUT_PHASE=3
    local NEW_REPOTAG_CHECK1_PHASE=4
    local NEW_REPOTAG_CHECK2_PHASE=5
    local SUMMARY_PHASE=6
    local RENAME_REPOTAG_PHASE=7
    local EXIT_PHASE=8

    local ACTION_RENAME_REPOTAG=1
    local ACTION_RENAME_REPOTAG_W_OVERWRITE=2
    local ACTION_RENAME_REPOTAG_WO_OVERWRITE=3


    #Define message constants
    local MENUTITLE="Rename ${DOCKER__FG_PURPLE}Repository${DOCKER__NOCOLOR}:${DOCKER__FG_PINK}Tag${DOCKER__NOCOLOR}"

    local SUMMARYTITLE="${DOCKER__FG_ORANGE203}Summary${DOCKER__NOCOLOR}: "
    SUMMARYTITLE+="rename ${DOCKER__FG_PURPLE}Repository${DOCKER__NOCOLOR}:${DOCKER__FG_PINK}Tag${DOCKER__NOCOLOR}"

    local READMSG_NEW_REPOSITORY_NAME="${DOCKER__FG_YELLOW}New${DOCKER__NOCOLOR} "
    READMSG_NEW_REPOSITORY_NAME+="${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR}'s name "
    READMSG_NEW_REPOSITORY_NAME+="(e.g. ubuntu_buildbin_NEW): "

    local READMSG_NEW_REPOSITORY_TAG="${DOCKER__FG_YELLOW}New${DOCKER__NOCOLOR} "
    READMSG_NEW_REPOSITORY_TAG+="${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} (e.g. test): "

    local ERRMSG_NEW_AND_CHOSEN_REPOTAG_PAIR_ARE_IDENTICAL="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: "
    ERRMSG_NEW_AND_CHOSEN_REPOTAG_PAIR_ARE_IDENTICAL+="New and chosen ${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR}:"
    ERRMSG_NEW_AND_CHOSEN_REPOTAG_PAIR_ARE_IDENTICAL+="${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} pairs are identical"

    local WARNINGMSG_NEW_REPOTAG_PAIR_ALREADY_EXISTS="${DOCKER__FG_BORDEAUX}WARNING${DOCKER__NOCOLOR}: "
    WARNINGMSG_NEW_REPOTAG_PAIR_ALREADY_EXISTS+="New ${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR}:"
    WARNINGMSG_NEW_REPOTAG_PAIR_ALREADY_EXISTS+="${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} pair already exists"

    #Define variables
    local answer=${DOCKER__NO}
    local phase=${DOCKER__EMPTYSTRING}
    local readmsg_remarks_w_clear=${DOCKER__EMPTYSTRING}
    local readmsg_remarks_w_back_home_clear=${DOCKER__EMPTYSTRING}

    local warning_numOfLines=0
    local fixed_numOfLines=0
    local tot_numOfLines_toClean=0
    local tot_numOfLines_toMoveDown=0

    local repoTag_isUniq=false


    #Set 'readmsg_remarks_w_back_home_clear'
    readmsg_remarks_w_clear="${DOCKER__BG_ORANGE}Remarks:${DOCKER__NOCOLOR}\n"
    readmsg_remarks_w_clear+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}Up/Down Arrow${DOCKER__NOCOLOR}: to cycle thru existing values\n"
    readmsg_remarks_w_clear+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}TAB${DOCKER__NOCOLOR}: auto-complete\n"
    readmsg_remarks_w_clear+="${DOCKER__DASH} ${DOCKER__FG_YELLOW};c${DOCKER__NOCOLOR}: clear"


    #Set 'readmsg_remarks_w_back_home_clear'
    readmsg_remarks_w_back_home_clear="${DOCKER__BG_ORANGE}Remarks:${DOCKER__NOCOLOR}\n"
    readmsg_remarks_w_back_home_clear+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}Up/Down Arrow${DOCKER__NOCOLOR}: to cycle thru existing values\n"
    readmsg_remarks_w_back_home_clear+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}TAB${DOCKER__NOCOLOR}: auto-complete\n"
    readmsg_remarks_w_back_home_clear+="${DOCKER__DASH} ${DOCKER__FG_YELLOW};b${DOCKER__NOCOLOR}: back\n"
    readmsg_remarks_w_back_home_clear+="${DOCKER__DASH} ${DOCKER__FG_YELLOW};h${DOCKER__NOCOLOR}: home\n"
    readmsg_remarks_w_back_home_clear+="${DOCKER__DASH} ${DOCKER__FG_YELLOW};c${DOCKER__NOCOLOR}: clear"



    #Initialization
    phase=${IMAGEID_SELECT_PHASE}
    while true
    do
        case "${phase}" in
            ${IMAGEID_SELECT_PHASE})
                ${docker__readInput_w_autocomplete__fpath} "${MENUTITLE}" \
                            "${DOCKER__READINPUTDIALOG_CHOOSE_IMAGEID_FROM_LIST}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${readmsg_remarks_w_clear}" \
                            "${DOCKER__ERRMSG_NO_IMAGES_FOUND}" \
                            "${DOCKER__ERRMSG_CHOSEN_IMAGEID_DOESNOT_EXISTS}" \
                            "${docker__images_cmd}" \
                            "${docker__images_IDColNo}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${docker__showTable}" \
                            "${docker__onEnter_breakLoop}" \
                            "${docker__tibboHeader_prepend_numOfLines}"

                #Get the exit-code just in case:
                #   1. Ctrl-C was pressed in script 'docker__readInput_w_autocomplete__fpath'.
                #   2. An error occured in script 'docker__readInput_w_autocomplete__fpath',...
                #      ...and exit-code = 99 came from function...
                #      ...'show_msg_w_menuTitle_w_pressAnyKey_w_ctrlC_func' (in script: docker__global.sh).
                docker__exitCode=$?
                if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
                    exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_0}"
                else
                    #Get the result
                    docker__imageID_chosen=`get_output_from_file__func \
                                    "${docker__readInput_w_autocomplete_out__fpath}" \
                                    "${DOCKER__LINENUM_1}"`
                fi  

                #Take action based on 'docker__imageID_chosen'
                if [[ -z ${docker__imageID_chosen} ]]; then
                    phase=${EXIT_PHASE}
                else
                    phase=${REPOTAG_RETRIEVE_PHASE}
                fi
                ;;
            ${REPOTAG_RETRIEVE_PHASE})
                #This subroutine outputs:
                #   1. docker__repo_chosen
                #   2. docker__tag_chosen
                #Remark:
                #   If variable 'docker__repo_chosen' or 'docker__tag_chosen' is an Empty String, then exit this function.
                docker__get_and_check_repoTag__sub
                if [[ -z ${docker__repo_chosen} ]] || [[ -z ${docker__tag_chosen} ]]; then
                    phase=${EXIT_PHASE}
                else
                    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_1}

                    phase=${NEW_REPO_INPUT_PHASE}
                fi
                ;;
            ${NEW_REPO_INPUT_PHASE})
                ${docker__readInput_w_autocomplete__fpath} "${MENUTITLE}" \
                            "${READMSG_NEW_REPOSITORY_NAME}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${readmsg_remarks_w_back_home_clear}" \
                            "${DOCKER__ERRMSG_NO_IMAGES_FOUND}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${docker__images_cmd}" \
                            "${docker__images_repoColNo}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${docker__showTable}" \
                            "${docker__onEnter_breakLoop}" \
                            "${docker__tibboHeader_prepend_numOfLines}"

                #Get the exit-code just in case:
                #   1. Ctrl-C was pressed in script 'docker__readInput_w_autocomplete__fpath'.
                #   2. An error occured in script 'docker__readInput_w_autocomplete__fpath',...
                #      ...and exit-code = 99 came from function...
                #      ...'show_msg_w_menuTitle_w_pressAnyKey_w_ctrlC_func' (in script: docker__global.sh).
                docker__exitCode=$?
                if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
                    exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
                else
                    #Retrieve the 'new repository' from file
                    docker__repo_new=`get_output_from_file__func \
                            "${docker__readInput_w_autocomplete_out__fpath}" \
                            "${DOCKER__LINENUM_1}"`
                fi

                #Take action based on 'docker__imageID_chosen'
                case "${docker__repo_new}" in
                    ${DOCKER__SEMICOLON_HOME})
                        docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_1}

                        phase=${IMAGEID_SELECT_PHASE}
                        ;;
                    ${DOCKER__SEMICOLON_BACK})
                        docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_1}

                        phase=${IMAGEID_SELECT_PHASE}
                        ;;
                    *)
                        #Check if output is an Empty String
                        if [[ -z ${docker__repo_new} ]]; then
                            phase=${EXIT_PHASE}
                        else
                            # tot_numOfLines_toMoveDown=${DOCKER__NUMOFLINES_1}

                            phase=${NEW_TAG_INPUT_PHASE}
                        fi
                        ;;
                esac
                ;;
            ${NEW_TAG_INPUT_PHASE})
                ${docker__readInput_w_autocomplete__fpath} "${MENUTITLE}" \
                            "${READMSG_NEW_REPOSITORY_TAG}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${readmsg_remarks_w_back_home_clear}" \
                            "${DOCKER__ERRMSG_NO_IMAGES_FOUND}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${docker__images_cmd}" \
                            "${docker__images_tagColNo}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${docker__showTable}" \
                            "${docker__onEnter_breakLoop}" \
                            "${docker__tibboHeader_prepend_numOfLines}"
            
                #Get the exit-code just in case:
                #   1. Ctrl-C was pressed in script 'docker__readInput_w_autocomplete__fpath'.
                #   2. An error occured in script 'docker__readInput_w_autocomplete__fpath',...
                #      ...and exit-code = 99 came from function...
                #      ...'show_msg_w_menuTitle_w_pressAnyKey_w_ctrlC_func' (in script: docker__global.sh).
                docker__exitCode=$?
                if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
                    exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
                else
                    #Retrieve the 'new tag' from file
                    docker__tag_new=`get_output_from_file__func \
                                "${docker__readInput_w_autocomplete_out__fpath}" \
                                "${DOCKER__LINENUM_1}"`
                fi

                #Take action based on 'docker__imageID_chosen'
                case "${docker__tag_new}" in
                    ${DOCKER__SEMICOLON_HOME})
                        docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_1}

                        phase=${IMAGEID_SELECT_PHASE}
                        ;;
                    ${DOCKER__SEMICOLON_BACK})
                        # tot_numOfLines_toMoveDown=${DOCKER__NUMOFLINES_1}

                        phase=${NEW_REPO_INPUT_PHASE}
                        ;;
                    *)
                        #Check if output is an Empty String
                        if [[ -z ${docker__tag_new} ]]; then
                            phase=${EXIT_PHASE}
                        else
                            phase=${NEW_REPOTAG_CHECK1_PHASE}
                        fi
                        ;;
                esac
                ;;
            ${NEW_REPOTAG_CHECK1_PHASE})
                #This phase checks whether the 'new' and 'chosen' repository:tag are the same
                if [[ "${docker__repo_new}" == "${docker__repo_chosen}" ]] && \
                        [[ "${docker__tag_new}" == "${docker__tag_chosen}" ]]; then
                    show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_NEW_AND_CHOSEN_REPOTAG_PAIR_ARE_IDENTICAL}" \
                            "${DOCKER__NUMOFLINES_0}" \
                            "${DOCKER__TIMEOUT_30}" \
                            "${DOCKER__NUMOFLINES_1}" \
                            "${DOCKER__NUMOFLINES_0}"

                    #Total number of lines
                    tot_numOfLines_toClean=`get_numOfLines_to_clean "${ERRMSG_NEW_AND_CHOSEN_REPOTAG_PAIR_ARE_IDENTICAL}" \
                            "${DOCKER__NUMOFLINES_2}"`

                    #Move-up and clean the ERROR message
                    moveUp_and_cleanLines__func "${tot_numOfLines_toClean}"

                    #Set 'tot_numOfLines_toMoveDown'
                    # tot_numOfLines_toMoveDown=${DOCKER__NUMOFLINES_2}

                    #Go back to the beginning
                    phase=${NEW_REPO_INPUT_PHASE}
                else
                    phase=${NEW_REPOTAG_CHECK2_PHASE}
                fi
                ;;
            ${NEW_REPOTAG_CHECK2_PHASE})
                #This phase checks whether the 'new' and 'other' repository:tag are the same
                repoTag_isUniq=`checkIf_repoTag_isUniq__func "${docker__repo_new}" "${docker__tag_new}"`
                if [[ ${repoTag_isUniq} == false ]]; then
                    show_msg_wo_menuTitle_w_confirmation__func "${WARNINGMSG_NEW_REPOTAG_PAIR_ALREADY_EXISTS}" \
                            "${DOCKER__Y_SLASH_N_SLASH_O_SLASH_B_SLASH_H}" \
                            "${DOCKER__REGEX_YNOBH}" \
                            "${DOCKER__NUMOFLINES_0}" \
                            "${DOCKER__TIMEOUT_30}" \
                            "${DOCKER__NUMOFLINES_1}" \
                            "${DOCKER__NUMOFLINES_0}"

                    #Get answer
                    answer=${extern__ret}

                    #Unset extern variable
                    unset extern__ret

                    # #Total number of lines
                    # tot_numOfLines_toClean=`get_numOfLines_to_clean "${WARNINGMSG_NEW_REPOTAG_PAIR_ALREADY_EXISTS}" \
                    #         "${DOCKER__NUMOFLINES_2}"`

                    # #Move-up and clean the WARNING message
                    # moveUp_and_cleanLines__func "${tot_numOfLines_toClean}"

                    #Update 'docker__tibboHeader_prepend_numOfLines'
                    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_3}

                    #Take action based on 'answer'
                    case "${answer}" in
                        ${DOCKER__YES})
                            #Update 'docker__tibboHeader_prepend_numOfLines'
                            docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_3}

                            #Update varariables
                            #Remark:
                            #   Since the 'docker__repo_new' and 'docker__tag_new' is...
                            #   ...already in use by an existing image, the repository and tag
                            #   ...of this existing image will have to be renamed.
                            docker__repo_existing="${docker__repo_new}"
                            docker__tag_existing="${docker__tag_new}"
                            docker__repo_renamed="${docker__repo_existing}"
                            docker__tag_renamed=$(date +%s)

                            action=${ACTION_RENAME_REPOTAG_WO_OVERWRITE}

                            phase=${SUMMARY_PHASE}
                            ;;
                        ${DOCKER__NO})
                            phase=${IMAGEID_SELECT_PHASE}
                            ;;
                        ${DOCKER__OVERWRITE})
                            action=${ACTION_RENAME_REPOTAG_W_OVERWRITE}

                            phase=${SUMMARY_PHASE}
                            ;;
                        ${DOCKER__HOME})
                            phase=${IMAGEID_SELECT_PHASE}
                            ;;
                        ${DOCKER__BACK})
                            phase=${NEW_TAG_INPUT_PHASE}
                            ;;
                    esac
                else
                    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_1}

                    action=${ACTION_RENAME_REPOTAG}

                    phase=${SUMMARY_PHASE}
                fi
                ;;
            ${SUMMARY_PHASE})
                #Update 'From' message
                docker__renameMsg_fromTo="${DOCKER__FOURSPACES}From:"
                docker__renameMsg_fromTo+="${DOCKER__ONESPACE}${DOCKER__FG_LIGHTGREY}${docker__repo_chosen}${DOCKER__NOCOLOR}:"
                docker__renameMsg_fromTo+="${DOCKER__FG_LIGHTGREY}${docker__tag_chosen}${DOCKER__NOCOLOR}\n"
                
                #Update 'To' message
                if [[ "${action}" == "${ACTION_RENAME_REPOTAG}" ]]; then
                    docker__renameMsg_fromTo+="${DOCKER__FOURSPACES}To:"
                    docker__renameMsg_fromTo+="${DOCKER__THREESPACES}${DOCKER__FG_LIGHTGREY}${docker__repo_new}${DOCKER__NOCOLOR}:"
                    docker__renameMsg_fromTo+="${DOCKER__FG_LIGHTGREY}${docker__tag_new}${DOCKER__NOCOLOR}"

                    docker__summaryTitle="${SUMMARYTITLE}"
                elif [[ "${action}" == "${ACTION_RENAME_REPOTAG_WO_OVERWRITE}" ]]; then
                    docker__renameMsg_fromTo+="${DOCKER__FOURSPACES}To:"
                    docker__renameMsg_fromTo+="${DOCKER__THREESPACES}${DOCKER__FG_LIGHTGREY}${docker__repo_new}${DOCKER__NOCOLOR}:"
                    docker__renameMsg_fromTo+="${DOCKER__FG_LIGHTGREY}${docker__tag_new}${DOCKER__NOCOLOR}\n"
                    docker__renameMsg_fromTo+="\n"
                    docker__renameMsg_fromTo+="${DOCKER__FOURSPACES}WARNING: existing image will be renamed:\n"
                    docker__renameMsg_fromTo+="${DOCKER__FOURSPACES}From:"
                    docker__renameMsg_fromTo+="${DOCKER__ONESPACE}${DOCKER__FG_LIGHTGREY}${docker__repo_new}${DOCKER__NOCOLOR}:"
                    docker__renameMsg_fromTo+="${DOCKER__FG_LIGHTGREY}${docker__tag_new}${DOCKER__NOCOLOR}\n"
                    docker__renameMsg_fromTo+="${DOCKER__FOURSPACES}To:"
                    docker__renameMsg_fromTo+="${DOCKER__THREESPACES}${DOCKER__FG_LIGHTGREY}${docker__repo_renamed}${DOCKER__NOCOLOR}:"
                    docker__renameMsg_fromTo+="${DOCKER__FG_LIGHTGREY}${docker__tag_renamed}${DOCKER__NOCOLOR}"

                    docker__summaryTitle="${SUMMARYTITLE} w/o overwrite"
                else    #action = ACTION_RENAME_REPOTAG_W_OVERWRITE
                    docker__renameMsg_fromTo+="${DOCKER__FOURSPACES}To:"
                    docker__renameMsg_fromTo+="${DOCKER__THREESPACES}${DOCKER__FG_LIGHTGREY}${docker__repo_new}${DOCKER__NOCOLOR}:"
                    docker__renameMsg_fromTo+="${DOCKER__FG_LIGHTGREY}${docker__tag_new}${DOCKER__NOCOLOR}\n"
                    docker__renameMsg_fromTo+="\n"
                    docker__renameMsg_fromTo+="${DOCKER__FOURSPACES}***${DOCKER__FG_LIGHTRED}WARNING${DOCKER__NOCOLOR}***: "
                    docker__renameMsg_fromTo+="existing image (${DOCKER__FG_PURPLE}${docker__repo_new}${DOCKER__NOCOLOR}:"
                    docker__renameMsg_fromTo+="${DOCKER__FG_PINK}${docker__tag_new}${DOCKER__NOCOLOR}) be LOST!"

                    docker__summaryTitle="${SUMMARYTITLE} w/ overwrite"
                fi

                #Go to next phase
                phase=${RENAME_REPOTAG_PHASE}
                ;;
            ${RENAME_REPOTAG_PHASE})
                #Print Tibbo-title
                load_tibbo_title__func "${docker__tibboHeader_prepend_numOfLines}"
                
                #Show question
                show_msg_w_menuTitle_w_confirmation__func "${docker__summaryTitle}" \
                        "${docker__renameMsg_fromTo}" \
                        "${DOCKER__Y_SLASH_N_SLASH_H}" \
                        "${DOCKER__REGEX_YNH}" \
                        "${DOCKER__NUMOFLINES_0}" \
                        "${DOCKER__TIMEOUT_30}" \
                        "${DOCKER__NUMOFLINES_0}" \
                        "${DOCKER__NUMOFLINES_0}"          

                #Get answer
                answer=${extern__ret}

                #Unset extern variable
                unset extern__ret

                #Take action based on 'answer'
                case "${answer}" in
                    ${DOCKER__YES})
                        case "${action}" in
                            ${ACTION_RENAME_REPOTAG})
                                docker__rename_repoTag__sub                             
                                ;;
                            ${ACTION_RENAME_REPOTAG_W_OVERWRITE})
                                docker__rename_repoTag_w_overwrite__sub
                                ;;
                            ${ACTION_RENAME_REPOTAG_WO_OVERWRITE})
                                docker__rename_repoTag_wo_overwrite__sub
                                ;;                                
                        esac

                        docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

                        phase=${IMAGEID_SELECT_PHASE}      
                        ;;
                    ${DOCKER__NO})
                        docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_3}

                        phase=${IMAGEID_SELECT_PHASE}
                        ;;
                    ${DOCKER__HOME})
                        docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_3}

                        phase=${IMAGEID_SELECT_PHASE}
                        ;;
                    
                esac
                ;;
            ${EXIT_PHASE})
                exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_2}"
                ;;
        esac

        #Move-down and clean
        # moveDown_and_cleanLines__func "${tot_numOfLines_toMoveDown}"

        #Reset variable
        # tot_numOfLines_toMoveDown=${DOCKER__NUMOFLINES_0}
    done
}

docker__get_and_check_repoTag__sub() {
    #Define message constants
    local ERRMSG_NO_REPO_FOUND="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: "
    ERRMSG_NO_REPO_FOUND+="No matching ${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR} "
    ERRMSG_NO_REPO_FOUND+="found for ${DOCKER__FG_BORDEAUX}ID${DOCKER__NOCOLOR} "
    ERRMSG_NO_REPO_FOUND+=="'${DOCKER__FG_LIGHTGREY}${docker__imageID_chosen}${DOCKER__NOCOLOR}'"

    local ERRMSG_NO_TAG_FOUND="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: "
    ERRMSG_NO_TAG_FOUND+="No matching ${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} "
    ERRMSG_NO_TAG_FOUND+="found for ${DOCKER__FG_BORDEAUX}ID${DOCKER__NOCOLOR} "
    ERRMSG_NO_TAG_FOUND+="'${DOCKER__FG_LIGHTGREY}${docker__imageID_chosen}${DOCKER__NOCOLOR}'"

    local ERRMSG_NO_REPO_TAG_FOUND="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: "
    ERRMSG_NO_REPO_TAG_FOUND+="No matching ${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR} "
    ERRMSG_NO_REPO_TAG_FOUND+="and ${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} "
    ERRMSG_NO_REPO_TAG_FOUND+="found for ${DOCKER__FG_BORDEAUX}ID${DOCKER__NOCOLOR} "
    ERRMSG_NO_REPO_TAG_FOUND+="'${DOCKER__FG_LIGHTGREY}${docker__imageID_chosen}${DOCKER__NOCOLOR}'"

    #Get repository
    docker__repo_chosen=`${docker__images_cmd} | grep -w ${docker__imageID_chosen} | awk -vcolNo=${docker__images_repoColNo} '{print $colNo}'`

    #Get tag
    docker__tag_chosen=`${docker__images_cmd} | grep -w ${docker__imageID_chosen} | awk -vcolNo=${docker__images_tagColNo} '{print $colNo}'`

    #Check if any of the value is an Empty String
    if [[ -z ${docker__repo_chosen} ]] && [[ -z ${docker__tag_chosen} ]]; then
        show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_NO_REPO_TAG_FOUND}" "${DOCKER__NUMOFLINES_2}"
    else
        if [[ -z ${docker__repo_chosen} ]]; then
            show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_NO_REPO_FOUND}" "${DOCKER__NUMOFLINES_2}"
        fi

        if [[ -z ${docker__tag_chosen} ]]; then
            show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_NO_TAG_FOUND}" "${DOCKER__NUMOFLINES_2}"
        fi
    fi
}

docker__rename_repoTag__sub() {
    #Move-down and clean
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_3}"

    #Update 'startMsg'
    local startMsg="---:${DOCKER__FG_ORANGE}START${DOCKER__NOCOLOR}: rename "
    startMsg+="${DOCKER__FG_PURPLE}${docker__repo_chosen}${DOCKER__NOCOLOR}:"
    startMsg+="${DOCKER__FG_PINK}${docker__tag_chosen}${DOCKER__NOCOLOR}"

    #Update 'completedMsg'
    local completedMsg="---:${DOCKER__FG_ORANGE}COMPLETED${DOCKER__NOCOLOR}: rename "
    completedMsg+="${DOCKER__FG_PURPLE}${docker__repo_chosen}${DOCKER__NOCOLOR}:"
    completedMsg+="${DOCKER__FG_PINK}${docker__tag_chosen}${DOCKER__NOCOLOR}"

    #Update 'renamingMsg'
    local renamingMsg="...renaming to new: ${DOCKER__FG_LIGHTGREY}docker image tag${DOCKER__NOCOLOR} "
    renamingMsg+="${DOCKER__FG_BORDEAUX}${docker__imageID_chosen}${DOCKER__NOCOLOR} "
    renamingMsg+="${DOCKER__FG_BRIGHTLIGHTPURPLE}${docker__repo_new}${DOCKER__NOCOLOR}:"
    renamingMsg+="${DOCKER__FG_LIGHTPINK}${docker__tag_new}${DOCKER__NOCOLOR}"

    #Update 'removingMsg'
    local removingMsg="...removing existing: ${DOCKER__FG_LIGHTGREY}docker rmi${DOCKER__NOCOLOR} "
    removingMsg+="${DOCKER__FG_PURPLE}${docker__repo_chosen}${DOCKER__NOCOLOR}:"
    removingMsg+="${DOCKER__FG_PINK}${docker__tag_chosen}${DOCKER__NOCOLOR}"

    #Show 'startMsg'
    echo -e "${startMsg}"

    #Show 'renamingMsg'
    echo -e "${renamingMsg}"
    rename_repoTag_w_imageId__func "${docker__imageID_chosen}" "${docker__repo_new}" "${docker__tag_new}"

    #Show 'removingMsg'
    echo -e "${removingMsg}"
    remove_repoTag__func "${docker__repo_chosen}" "${docker__tag_chosen}"

    #Show 'completedMsg'
    echo -e "${completedMsg}"
}

docker__rename_repoTag_w_overwrite__sub() {
    #Move-down and clean
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_3}"

    #Update 'startMsg'
    local startMsg="---:${DOCKER__FG_ORANGE}START${DOCKER__NOCOLOR}: rename "
    startMsg+="${DOCKER__FG_PURPLE}${docker__repo_chosen}${DOCKER__NOCOLOR}:"
    startMsg+="${DOCKER__FG_PINK}${docker__tag_chosen}${DOCKER__NOCOLOR} "
    startMsg+="w/ OVERWRITE"

    #Update 'completedMsg'
    local completedMsg="---:${DOCKER__FG_ORANGE}COMPLETED${DOCKER__NOCOLOR}: rename "
    completedMsg+="${DOCKER__FG_PURPLE}${docker__repo_chosen}${DOCKER__NOCOLOR}:"
    completedMsg+="${DOCKER__FG_PINK}${docker__tag_chosen}${DOCKER__NOCOLOR} "
    completedMsg+="w/ OVERWRITE"

    #Update 'removingMsg1'
    local removingMsg1="...removing existing: ${DOCKER__FG_LIGHTGREY}docker rmi${DOCKER__NOCOLOR} "
    removingMsg1+="${DOCKER__FG_PURPLE}${docker__repo_new}${DOCKER__NOCOLOR}:"
    removingMsg1+="${DOCKER__FG_PINK}${docker__tag_new}${DOCKER__NOCOLOR}"

    #Update 'renamingMsg'
    local renamingMsg="...renaming to new: ${DOCKER__FG_LIGHTGREY}docker image tag${DOCKER__NOCOLOR} "
    renamingMsg+="${DOCKER__FG_BORDEAUX}${docker__imageID_chosen}${DOCKER__NOCOLOR} "
    renamingMsg+="${DOCKER__FG_BRIGHTLIGHTPURPLE}${docker__repo_new}${DOCKER__NOCOLOR}:"
    renamingMsg+="${DOCKER__FG_LIGHTPINK}${docker__tag_new}${DOCKER__NOCOLOR}"

    #Update 'removingMsg2'
    local removingMsg2="...removing chosen: ${DOCKER__FG_LIGHTGREY}docker rmi${DOCKER__NOCOLOR} "
    removingMsg2+="${DOCKER__FG_PURPLE}${docker__repo_chosen}${DOCKER__NOCOLOR}:"
    removingMsg2+="${DOCKER__FG_PINK}${docker__tag_chosen}${DOCKER__NOCOLOR}"

    #Show 'startMsg'
    echo -e "${startMsg}"

    #Show 'removingMsg1'
    echo -e "${removingMsg1}"
    remove_repoTag__func "${docker__repo_new}" "${docker__tag_new}"

    #Show 'renamingMsg'
    echo -e "${renamingMsg}"
    rename_repoTag_w_imageId__func "${docker__imageID_chosen}" "${docker__repo_new}" "${docker__tag_new}"

    #Show 'removingMsg2'
    echo -e "${removingMsg2}"
    remove_repoTag__func "${docker__repo_chosen}" "${docker__tag_chosen}"

    #Show 'completedMsg'
    echo -e "${completedMsg}"
}

docker__rename_repoTag_wo_overwrite__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_3}"

    #Update 'startMsg'
    local startMsg="---:${DOCKER__FG_ORANGE}START${DOCKER__NOCOLOR}: rename "
    startMsg+="${DOCKER__FG_PURPLE}${docker__repo_chosen}${DOCKER__NOCOLOR}:"
    startMsg+="${DOCKER__FG_PINK}${docker__tag_chosen}${DOCKER__NOCOLOR} "
    startMsg+="w/o OVERWRITE"

    #Update 'completedMsg'
    local completedMsg="---:${DOCKER__FG_ORANGE}COMPLETED${DOCKER__NOCOLOR}: rename "
    completedMsg+="${DOCKER__FG_PURPLE}${docker__repo_chosen}${DOCKER__NOCOLOR}:"
    completedMsg+="${DOCKER__FG_PINK}${docker__tag_chosen}${DOCKER__NOCOLOR} "
    completedMsg+="w/o OVERWRITE"

    #Update 'renamingMsg1'
    local renamingMsg1="...renaming existing: ${DOCKER__FG_LIGHTGREY}docker tag${DOCKER__NOCOLOR} "
    renamingMsg1+="${DOCKER__FG_PURPLE}${docker__repo_existing}${DOCKER__NOCOLOR}:"
    renamingMsg1+="${DOCKER__FG_PINK}${docker__tag_existing}${DOCKER__NOCOLOR} "
    renamingMsg1+="${DOCKER__FG_BRIGHTLIGHTPURPLE}${docker__repo_renamed}${DOCKER__NOCOLOR}:"
    renamingMsg1+="${DOCKER__FG_LIGHTPINK}${docker__tag_renamed}${DOCKER__NOCOLOR}"

    #Update 'removingMsg1'
    local removingMsg1="...removing existing: ${DOCKER__FG_LIGHTGREY}docker rmi${DOCKER__NOCOLOR} "
    removingMsg1+="${DOCKER__FG_PURPLE}${docker__repo_existing}${DOCKER__NOCOLOR}:"
    removingMsg1+="${DOCKER__FG_PINK}${docker__tag_existing}${DOCKER__NOCOLOR}"

    #Update 'renamingMsg2'
    local renamingMsg2="...renaming to new: ${DOCKER__FG_LIGHTGREY}docker image tag${DOCKER__NOCOLOR} "
    renamingMsg2+="${DOCKER__FG_BORDEAUX}${docker__imageID_chosen}${DOCKER__NOCOLOR} "
    renamingMsg2+="${DOCKER__FG_BRIGHTLIGHTPURPLE}${docker__repo_new}${DOCKER__NOCOLOR}:"
    renamingMsg2+="${DOCKER__FG_LIGHTPINK}${docker__tag_new}${DOCKER__NOCOLOR}"

    #Update 'removingMsg2'
    local removingMsg2="...removing chosen: ${DOCKER__FG_LIGHTGREY}docker rmi${DOCKER__NOCOLOR} "
    removingMsg2+="${DOCKER__FG_PURPLE}${docker__repo_chosen}${DOCKER__NOCOLOR}:"
    removingMsg2+="${DOCKER__FG_PINK}${docker__tag_chosen}${DOCKER__NOCOLOR}"

    #Show 'startMsg'
    echo -e "${startMsg}"

    #Show 'renamingMsg1'
    echo -e "${renamingMsg1}"
    rename_repoTag_wo_imageId__func "${docker__repo_existing}" "${docker__tag_existing}" "${docker__repo_renamed}" "${docker__tag_renamed}"

    #Show 'removingMsg1'
    echo -e "${removingMsg1}"
    remove_repoTag__func "${docker__repo_existing}" "${docker__tag_existing}"

    #Show 'renamingMsg2'
    echo -e "${renamingMsg2}"
    rename_repoTag_w_imageId__func "${docker__imageID_chosen}" "${docker__repo_new}" "${docker__tag_new}"

    #Show 'removingMsg2'
    echo -e "${removingMsg2}"
    remove_repoTag__func "${docker__repo_chosen}" "${docker__tag_chosen}"

    #Show 'completedMsg'
    echo -e "${completedMsg}"
}



#---MAIN SUBROUTINE
main_sub() {
    docker__get_source_fullpath__sub

    docker__load_global_fpath_paths__sub

    # load_tibbo_title__func

    docker__init_variables__sub

    docker__rename_image_handler__sub
}



#---EXECUTE
main_sub

