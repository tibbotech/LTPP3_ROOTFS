#!/bin/bash -m
#Remark: by using '-m' the INTERRUPT executed here will NOT propagate to the UPPERLAYER scripts
#---INPUT ARGS
git_location__input=${1}    #GIT__LOCATION_LOCAL or GIT__LOCATION_REMOTE



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
    DOCKER__INPUT_ARGS_ERR1="${DOCKER__ERROR}: Invalid input-arg value "
    DOCKER__INPUT_ARGS_ERR1+="'${DOCKER__FG_LIGHTGREY}${git_location__input}${DOCKER__NOCOLOR}'"
    DOCKER__INPUT_ARGS_ERR2="${DOCKER__ERROR}: Please input: "
    DOCKER__INPUT_ARGS_ERR2+="${DOCKER__FG_LIGHTGREY}${GIT__LOCATION_LOCAL}${DOCKER__NOCOLOR} or "
    DOCKER__INPUT_ARGS_ERR2+="${DOCKER__FG_LIGHTGREY}${GIT__LOCATION_REMOTE}${DOCKER__NOCOLOR}"

    if [[ ${git_location__input} == ${GIT__LOCATION_LOCAL} ]]; then
        DOCKER__MENUTITLE="Git Remove Local Tag"
    else    #git_location__input = GIT__LOCATION_REMOTE
        DOCKER__MENUTITLE="Git Remove Remote Tag"
    fi
    DOCKER__CHOOSETAG_MENUOPTIONS="${DOCKER__FOURSPACES_Q_QUIT}"
    DOCKER__CHOOSETAG__MATCHPATTERN="${DOCKER__QUIT}"
    DOCKER__CHOOSETAG__READDIALOG="Choose tag: "

    if [[ ${git_location__input} == ${GIT__LOCATION_LOCAL} ]]; then
        DOCKER__SHOWBRANCHES_MENUTITLE="Local branches linked to "
    else    #git_location__input = GIT__LOCATION_REMOTE
        DOCKER__SHOWBRANCHES_MENUTITLE="Remote branches linked to "
    fi
    DOCKER__SHOWBRANCHES_MENUOPTIONS="${DOCKER__FOURSPACES_Y_YES}\n"
    DOCKER__SHOWBRANCHES_MENUOPTIONS+="${DOCKER__FOURSPACES_N_NO}\n"
    DOCKER__SHOWBRANCHES_MENUOPTIONS+="${DOCKER__FOURSPACES_Q_QUIT}"
    DOCKER__SHOWBRANCHES_MATCHPATTERNS="${DOCKER__YES}"
    DOCKER__SHOWBRANCHES_MATCHPATTERNS+="${DOCKER__ONESPACE}"
    DOCKER__SHOWBRANCHES_MATCHPATTERNS+="${DOCKER__NO}"
    DOCKER__SHOWBRANCHES_MATCHPATTERNS+="${DOCKER__ONESPACE}"
    DOCKER__SHOWBRANCHES_MATCHPATTERNS+="${DOCKER__QUIT}"
    DOCKER__SHOWBRANCHES_READDIALOG="Do you wish to continue (${DOCKER__Y_SLASH_N_SLASH_Q})? "

    DOCKER__CONFIRMATION_WARNING="${DOCKER__WARNING}: linked branches will be untagged from "
    DOCKER__CONFIRMATION_READDIALOG="Do you really wish to continue (${DOCKER__Y_SLASH_N_SLASH_Q})? "
}

docker__init_variables__sub() {
    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_0}

    docker__branchNames_arr=()
    docker__tag_arr=()

    #Remark:
    #   The 'docker__result_from_output' could be a key-input or selected table-item.
    docker__result_from_output=${DOCKER__EMPTYSTRING}
    #Remark:
    #   'tot_numOfLines' retrieved from 'docker__result_from_output' representing the
    #       total number of lines of the table drawn within 
    #        'show_pathContent_w_selection__func'.
    #   Note: this value may be needed in case the above mentioned table
    #       needs to be cleared.
    docker__totNumOfLines_from_output=0

    docker__full_commitHash=${DOCKER__EMPTYSTRING}
    docker__tag_chosen=${DOCKER__EMPTYSTRING}

    docker__stdErr=${DOCKER__EMPTYSTRING}
}

docker__check_input_args__sub() {
    #Check if 'git_location__input' is valid
    if [[ "${git_location__input}" != "${GIT__LOCATION_LOCAL}" ]] && \
            [[ "${git_location__input}" != "${GIT__LOCATION_REMOTE}" ]]; then
        show_msg_only__func "${DOCKER__INPUT_ARGS_ERR1}" "${DOCKER__NUMOFLINES_2}" "${DOCKER__NUMOFLINES_0}"
        show_msg_only__func "${DOCKER__INPUT_ARGS_ERR2}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_2}"
    fi
}

docker__remove_tag_handler__sub() {
    #Define constants
    local PRINTF_REMOVE_TAG="remove local tag"
    if [[ "${git_location__input}" == "${GIT__LOCATION_REMOTE}" ]]; then
        PRINTF_REMOVE_TAG="remove remote tag"
    fi

    #Define variables
    local answer=${DOCKER__EMPTYSTRING}

    local confirmation_warning=${DOCKER__EMPTYSTRING}
    local showBranches_menutitle=${DOCKER__EMPTYSTRING}

    local printf_msg=${DOCKER__EMPTYSTRING}


#Goto phase: START
goto__func START



@START:
    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

    goto__func PRECHECK



@PRECHECK:
    #Check if the current directory is a git-repository
    docker__stdErr=`${GIT__CMD_GIT_BRANCH} 2>&1 > /dev/null`
    if [[ ! -z ${docker__stdErr} ]]; then   #not a git-repository
        goto__func EXIT_PRECHECK_FAILED  #goto next-phase
    else    #is a git-repository
        goto__func GET_TAGS
    fi


@GET_TAGS:
    #Remove file
    if [[ -f ${git__git_tag_remove_out__fpath} ]]; then
        rm ${git__git_tag_remove_out__fpath}
    fi

    #Get all tags
    readarray -t docker__tag_arr < <(git__get_tags__func "${git_location__input}")

    #Write array to file
    write_array_to_file__func "${git__git_tag_remove_out__fpath}" "${docker__tag_arr[@]}"

    #Go to next-phase
    goto__func SHOW_AND_CHOOSE_TAG



@SHOW_AND_CHOOSE_TAG:
    #Show file-content
    show_pathContent_w_selection__func "${git__git_tag_remove_out__fpath}" \
                    "${DOCKER__EMPTYSTRING}" \
                    "${DOCKER__MENUTITLE}" \
                    "${DOCKER__EMPTYSTRING}" \
                    "${DOCKER__EMPTYSTRING}" \
                    "${DOCKER__CHOOSETAG_MENUOPTIONS}" \
                    "${DOCKER__CHOOSETAG__MATCHPATTERN}" \
                    "${DOCKER__ECHOMSG_NORESULTS_FOUND}" \
                    "${DOCKER__CHOOSETAG__READDIALOG}" \
                    "${DOCKER__EMPTYSTRING}" \
                    "${DOCKER__EMPTYSTRING}" \
                    "${DOCKER__TABLEROWS_10}" \
                    "${DOCKER__FALSE}" \
                    "${docker__show_pathContent_w_selection_func_out__fpath}" \
                    "${docker__tibboHeader_prepend_numOfLines}" \
                    "${DOCKER__TRUE}"

    #Get docker__result_from_output
    docker__result_from_output=`retrieve_line_from_file__func "${DOCKER__LINENUM_1}" \
                    "${docker__show_pathContent_w_selection_func_out__fpath}"`
    docker__totNumOfLines_from_output=`retrieve_line_from_file__func "${DOCKER__LINENUM_2}" \
                    "${docker__show_pathContent_w_selection_func_out__fpath}"`

    #Move-down and clean
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    #Handle 'docker__result_from_output'
    case "${docker__result_from_output}" in
        ${DOCKER__QUIT})    #abort
            goto__func EXIT_SUCCESSFUL
            ;;
        *)
            docker__tag_chosen="${docker__result_from_output}"

            goto__func GET_COMMIT_HASH

            break
            ;;
    esac    



@GET_COMMIT_HASH:
    #Retrieve 'full commit-hash' for given 'docker__tag_chosen'
    docker__full_commitHash=`git__get_full_commitHash_for_specified_tag__func \
                        "${docker__tag_chosen}" \
                        "${git_location__input}"`

    goto__func GET_LIST_OF_BRANCHNAMES

    

@GET_LIST_OF_BRANCHNAMES:
    #Retrieve all branch names which are linked to 'docker__full_commitHash' and read to array
    readarray -t docker__branchNames_arr < <(git__get_branches_for_specified_commitHash__func \
                        "${docker__full_commitHash}" \
                        "${git_location__input}")

    #Write array to file
    write_array_to_file__func "${git__git_tag_remove_out__fpath}" "${docker__branchNames_arr[@]}"

    goto__func SHOW_BRANCHNAMES_AND_CONFIRMATION



@SHOW_BRANCHNAMES_AND_CONFIRMATION:
    #Update 'showBranches_menutitle'
    showBranches_menutitle="${DOCKER__SHOWBRANCHES_MENUTITLE}${DOCKER__FG_PINK}${docker__tag_chosen}${DOCKER__NOCOLOR}"

    #Show file content
    show_fileContent_wo_select__func "${git__git_tag_remove_out__fpath}" \
                    "${showBranches_menutitle}" \
                    "${DOCKER__EMPTYSTRING}" \
                    "${DOCKER__EMPTYSTRING}" \
                    "${DOCKER__SHOWBRANCHES_MENUOPTIONS}" \
                    "${DOCKER__ECHOMSG_NORESULTS_FOUND}" \
                    "${DOCKER__SHOWBRANCHES_READDIALOG}" \
                    "${DOCKER__REGEX_YNQ}" \
                    "${docker__show_fileContent_wo_select_func_out__fpath}" \
                    "${DOCKER__TABLEROWS_10}" \
                    "${DOCKER__EMPTYSTRING}" \
                    "${DOCKER__FALSE}" \
                    "${docker__tibboHeader_prepend_numOfLines}" \
                    "${DOCKER__TRUE}"

    #Get the exitcode just in case a Ctrl-C was pressed in function 'show_fileContent_wo_select__func' (in script 'docker_global.sh')
    docker__exitCode=$?
    if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
        exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
    fi

    #Get result from file.
    answer=`get_output_from_file__func \
                        "${docker__show_fileContent_wo_select_func_out__fpath}" \
                        "${DOCKER__LINENUM_1}"`

    #Move-down and clean
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    #Handle 'answer'
    case "${answer}" in
        ${DOCKER__QUIT})    #abort
            goto__func EXIT_SUCCESSFUL
            ;;
        ${DOCKER__YES})    #back
            goto__func DOUBLE_CONFIRMATION_TO_PROCEED
            ;;
        ${DOCKER__NO})    #back
            goto__func GET_TAGS
            ;;
    esac



@DOUBLE_CONFIRMATION_TO_PROCEED:
    #Update 'showBranches_menutitle'
    confirmation_warning="${DOCKER__CONFIRMATION_WARNING}${DOCKER__FG_PINK}${docker__tag_chosen}${DOCKER__NOCOLOR}"

    readDialog="---:${DOCKER__QUESTION}: ${DOCKER__CONFIRMATION_READDIALOG}"

    #Show question
    while true
    do
        #Show question
        show_msg_only__func "${confirmation_warning}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_1}"
        read -N1 -p "${readDialog}" answer

        #Check if 'answer' is Not an Empty String
        if [[ ! -z ${answer} ]]; then   #not an Empty String
            if [[ ${answer} =~ ${DOCKER__REGEX_YNQ} ]]; then    #match was found
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                #Handle 'answer'
                case "${answer}" in
                    ${DOCKER__QUIT})    #abort
                        goto__func EXIT_SUCCESSFUL
                        ;;
                    ${DOCKER__YES})    #back
                        goto__func REMOVE_TAG
                        ;;
                    ${DOCKER__NO})    #back
                        goto__func GET_TAGS
                        ;;
                esac

                break
            else    #no match was found
                if [[ ${answer} != "${DOCKER__ENTER}" ]]; then
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_3}"
                else
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_4}"
                fi
            fi
        fi
    done


@REMOVE_TAG:
    #Update message
    printf_cmdMsg="---:${DOCKER__START}: ${PRINTF_REMOVE_TAG}"
    #Show message
    show_msg_only__func "${printf_cmdMsg}" "${DOCKER__NUMOFLINES_2}" "${DOCKER__NUMOFLINES_0}"

    #Remove tag
    #1. Define command
    if [[ ${git_location__input} == ${GIT__LOCATION_LOCAL} ]]; then
        git_cmd="${GIT__CMD_GIT_TAG} -d ${docker__tag_chosen}"
    else    #git_location__input = GIT__LOCATION_REMOTE
        git_cmd="${GIT__CMD_GIT_PUSH} --delete origin ${docker__tag_chosen}"
    fi

    #2. Execute command
    eval ${git_cmd}


    #Check exit-code
    exitCode=$?
    if [[ ${exitCode} -eq 0 ]]; then
        #Update message
        printf_cmdMsg="------:${DOCKER__EXECUTED}: ${git_cmd} (${DOCKER__STATUS_LDONE})"
    else
        #Update message
        printf_cmdMsg="------:${DOCKER__ERROR}: ${git_cmdMsg} (${DOCKER__STATUS_LFAILED})"
    fi

    #Show message
    show_msg_only__func "${printf_cmdMsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

    #Update message
    printf_cmdMsg="---:${DOCKER__COMPLETED}: ${PRINTF_REMOVE_TAG}"
    #Show message
    show_msg_only__func "${printf_cmdMsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

    goto__func GET_TAGS



@EXIT_PRECHECK_FAILED:
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
    echo -e "${DOCKER__ERROR}: ${docker__stdErr}"
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_0}"
    
    exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_2}"



@EXIT_SUCCESSFUL:
    exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_2}"
}



#---MAIN SUBROUTINE
main_sub() {
    docker__get_source_fullpath__sub

    docker__load_global_fpath_paths__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__check_input_args__sub

    docker__remove_tag_handler__sub
}



#---EXECUTE
main_sub
