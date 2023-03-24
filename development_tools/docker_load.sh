#!/bin/bash -m
#Remark: by using '-m' the INTERRUPT executed here will NOT propagate to the UPPERLAYER scripts
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

docker__load_constants__sub() {
    #Define phase constants
    DOCKER__SELECT_SRC_DIR=0
    DOCKER__LOAD_PHASE=1
    DOCKER__SHOW_UPDATED_IMAGE_LIST_PHASE=2

    #Define message constants
    DOCKER__MENUTITLE="${DOCKER__FG_YELLOW}Import${DOCKER__NOCOLOR} an ${DOCKER__FG_BORDEAUX}Image${DOCKER__NOCOLOR} file"
    DOCKER__READDIALOG_CHOOSE_TARGET_DIR="Choose src-fullpath: "

    #Define numeric constants
    #Remark:
    #   (DOCKER__LEADING_ECHOMSG_LEN) is the length of echo-msg '---:COMPLETED: Exporting image ' including: one space ( ), two quotes (')
    DOCKER__LEADING_ECHOMSG_LEN=33
}

docker__init_variables__sub() {
    docker__answer=${DOCKER__EMPTYSTRING}
    docker__image_fpath=${DOCKER__EMPTYSTRING}
    docker__image_fpath_print=${DOCKER__EMPTYSTRING}
    docker__imageID_chosen=${DOCKER__EMPTYSTRING}
    docker__repo_chosen=${DOCKER__EMPTYSTRING}
    docker__tag_chosen=${DOCKER__EMPTYSTRING}

    # docker__images_cmd="docker images"

    # docker__images_repoColNo=1
    # docker__images_tagColNo=2
    # docker__images_IDColNo=3

    docker__onEnter_breakLoop=false
    docker__showTable=true
}

docker__load_handler__sub() {
    #Define variables
    local echomsg=${DOCKER__EMPTYSTRING}
    local phase=${DOCKER__EMPTYSTRING}

    #Set initial 'phase'
    phase=${DOCKER__SELECT_SRC_DIR}
    while true
    do
        case "${phase}" in
            ${DOCKER__SELECT_SRC_DIR})
                #Show and select directory
	            ${dirlist__readInput_w_autocomplete__fpath} "${DOCKER__EMPTYSTRING}" \
						"${docker__docker_images__dir}" \
						"${DOCKER__READDIALOG_CHOOSE_TARGET_DIR}" \
						"${DOCKER__DIRLIST_REMARKS}" \
                        "${dirlist__dst_ls_1aA_output__fpath}" \
                        "${dirlist__dst_ls_1aA_tmp__fpath}" \
						"${DOCKER__EMPTYSTRING}" \
                        "${DOCKER__NUMOFLINES_2}"

                #Get the exit-code just in case:
                #   1. Ctrl-C was pressed in script 'dirlist__readInput_w_autocomplete__fpath'.
                #   2. An error occured in script 'dirlist__readInput_w_autocomplete__fpath',...
                #      ...and exit-code = 99 came from function...
                #      ...'show_msg_w_menuTitle_w_pressAnyKey_w_ctrlC_func' (in script: docker__global.sh).
                docker__exitCode=$?
                if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
                    exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
                else
                    #Get the result
                    docker__path_output=`get_output_from_file__func "${dirlist__readInput_w_autocomplete_out__fpath}" "${DOCKER__LINENUM_1}"`
                    docker__numOfMatches_output=`get_output_from_file__func "${dirlist__readInput_w_autocomplete_out__fpath}" "${DOCKER__LINENUM_2}"`
                fi

                if [[ -f ${docker__path_output} ]]; then    #is a file
                    #Generate 'docker__image_fpath'
                    docker__image_fpath="${docker__path_output}"

                    #Replace multiple slashes with a single slash (/)
                    docker__image_fpath=`subst_multiple_chars_with_single_char__func "${docker__image_fpath}" \
                                    "${DOCKER__ESCAPED_SLASH}" \
                                    "${DOCKER__ESCAPED_SLASH}"`

                    #Set the maximum allowed string-length for 'docker__image_fpath_print'
                    docker__image_fpath_print_maxLen=$((DOCKER__TABLEWIDTH - DOCKER__LEADING_ECHOMSG_LEN))

                    #Resize 'docker__image_fpath' in order to fit into table-size 'DOCKER__TABLEWIDTH'
                    docker__image_fpath_print=`trim_string_toFit_specified_windowSize__func \
                            "${docker__image_fpath}" \
                            "${docker__image_fpath_print_maxLen}" \
                            "${DOCKER__TRUE}"`

                    echomsg="---:${DOCKER__FG_ORANGE}SOURCE${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}${docker__image_fpath_print}${DOCKER__NOCOLOR}"
                    show_msg_only__func "${echomsg}" "${DOCKER__NUMOFLINES_1}"

                    #Goto next-phase
                    phase=${DOCKER__LOAD_PHASE}
                else    #is a directory
                    show_msg_wo_menuTitle_w_PressAnyKey__func "${DOCKER__INVALID_OR_NOT_A_FILE}" \
                                "${DOCKER__NUMOFLINES_1}" \
                                "${DOCKER__TIMEOUT_10}" \
                                "${DOCKER__NUMOFLINES_1}" \
                                "${DOCKER__NUMOFLINES_2}"  
                fi
                ;;
            ${DOCKER__LOAD_PHASE})
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                while true
                do
                    read -N1 -p "${DOCKER__READDIALOG_DO_YOU_WISH_TO_CONTINUE_YN}" docker__answer
                    if  [[ "${docker__answer}" == "${DOCKER__Y}" ]]; then
                        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_3}"

                        echomsg="---:${DOCKER__FG_ORANGE}START${DOCKER__NOCOLOR}: Importing image '${DOCKER__FG_LIGHTGREY}${docker__image_fpath_print}${DOCKER__NOCOLOR}'\n"
                        echomsg+="------:${DOCKER__FG_ORANGE}INFO${DOCKER__NOCOLOR}: Depending on the image size...\n"
                        echomsg+="------:${DOCKER__FG_ORANGE}INFO${DOCKER__NOCOLOR}: This may take a while...\n"
                        echomsg+="------:${DOCKER__FG_ORANGE}INFO${DOCKER__NOCOLOR}: Please wait..."
                        show_msg_only__func "${echomsg}" "${DOCKER__NUMOFLINES_0}"

                        #Save image to 'docker__image_fpath'
                        docker image load --input ${docker__image_fpath} > /dev/null

                        echomsg="---:${DOCKER__FG_ORANGE}COMPLETED${DOCKER__NOCOLOR}: Importing image '${DOCKER__FG_LIGHTGREY}${docker__image_fpath_print}${DOCKER__NOCOLOR}'"
                        show_msg_only__func "${echomsg}" "${DOCKER__NUMOFLINES_0}"

                        #Goto next-phase
                        phase=${DOCKER__SHOW_UPDATED_IMAGE_LIST_PHASE}

                        break
                    elif  [[ "${docker__answer}" == "${DOCKER__N}" ]]; then
                        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                        #Goto next-phase
                        phase=${DOCKER__SELECT_SRC_DIR}

                        break
                    else    #Empty String
                        if [[ "${docker__answer}" != "${DOCKER__ENTER}" ]]; then    #no ENTER was pressed
                            moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"
                        else    #ENTER was pressed
                            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                        fi
                    fi
                done
                ;;
            ${DOCKER__SHOW_UPDATED_IMAGE_LIST_PHASE})
                show_repoList_or_containerList_w_menuTitle_w_confirmation__func "${DOCKER__MENUTITLE_UPDATED_REPOSITORYLIST}" \
                                    "${DOCKER__ERRMSG_NO_IMAGES_FOUND}" \
                                    "${docker__images_cmd}" \
                                    "${DOCKER__NUMOFLINES_0}" \
                                    "${DOCKER__TIMEOUT_10}" \
                                    "${DOCKER__NUMOFLINES_0}" \
                                    "${DOCKER__NUMOFLINES_0}" \
                                    "${DOCKER__NUMOFLINES_2}"

                exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_0}"
                ;;
        esac
    done
}





#---MAIN SUBROUTINE
main_sub() {
    docker__get_source_fullpath__sub

    docker__load_global_fpath_paths__sub

    # load_tibbo_title__func

    docker__load_constants__sub

    docker__init_variables__sub

    docker__load_handler__sub
}



#---EXECUTE
main_sub
