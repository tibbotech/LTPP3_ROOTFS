#!/bin/bash -m
#---INPUT ARGS
branchName__input=${1}



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
    DOCKER__MENUTITLE="Git Push"
    DOCKER__TABLETITLE_EXISTING_UNPUSHED_COMMITS="Existing Unpushed Commits"

    DOCKER__MENUOPTIONS="${DOCKER__FOURSPACES_Y_YES}\n"
    DOCKER__MENUOPTIONS+="${DOCKER__FOURSPACES_N_NO}\n"
    DOCKER__MENUOPTIONS+="${DOCKER__FOURSPACES_Q_QUIT}"

    DOCKER__READDIALOG="Push ${DOCKER__FG_LIGHTGREY}pending${DOCKER__NOCOLOR} commits? "
    DOCKER__READDIALOG_YNRQ="Push ${DOCKER__FG_LIGHTGREY}new${DOCKER__NOCOLOR} commits (${DOCKER__Y_SLASH_N_SLASH_R_SLASH_Q})? "

    DOCKER__SUBJECT_GIT_PUSH="git push"
}

docker__init_variables__sub() {
    docker__commitSubj=${DOCKER__EMPTYSTRING}
    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

    docker__abbrevCommitHash_arr=()
    docker__commitSubj_arr=()

    docker__numOf_pendingCommits=0
}

docker__reset_variables__sub() {
    docker__abbrevCommitHash_arr=()
    docker__commitSubj_arr=()
}

docker__add_comment_push__sub() {
    #Define constants
    local TIBBOHEADER_PHASE=1
    local MENUTITLE_PHASE=2
    local PRINT_START_MESSAGE=3
    local GIT_ADD_PHASE=4
    local GIT_COMMIT_PHASE=5
    local GIT_CONFIRM_EXISTING_COMMIT_PHASE=6
    local GIT_CONFIRM_NEW_COMMIT_PHASE=7
    local GIT_PUSH_PHASE=8
    local PRINT_COMPLETED_MESSAGE=9
    local EXIT_PHASE=10

    local PRINTF_STAGE1="${DOCKER__FG_ORANGE}STAGE-I${DOCKER__NOCOLOR}"
    local PRINTF_STAGE2="${DOCKER__FG_ORANGE}STAGE-II${DOCKER__NOCOLOR}"
    local PRINTF_STAGE2A="${DOCKER__FG_ORANGE}STAGE-IIA${DOCKER__NOCOLOR}"
    local PRINTF_STAGE3="${DOCKER__FG_ORANGE}STAGE-III${DOCKER__NOCOLOR}"

    local PRINTF_GIT_COMMIT_CMD="${GIT__CMD_GIT_COMMIT_DASH_M} <your subject>"
    local PRINTF_GIT_RESET_SOFT_HEAD_CMD="${GIT__CMD_GIT_RESET} --soft HEAD~"

    #Define variables
    local answer=${DOCKER__NO}
    local phase=${TIBBOHEADER_PHASE}

    local printf_msg=${DOCKER__EMPTYSTRING}
    local printf_subjectMsg=${DOCKER__EMPTYSTRING}
    local readDialog=${DOCKER__EMPTYSTRING}

    local git_current_branch_numOf_commits=0
    local git_diff_numOf_commits=0
    local git_master_numOf_commits=0


    #Handle 'phase'
    while true
    do
        case "${phase}" in
            ${TIBBOHEADER_PHASE})
                #Show Tibbo-title
                load_tibbo_title__func "${docker__tibboHeader_prepend_numOfLines}"

                #Goto next-phase
                phase="${MENUTITLE_PHASE}"
                ;;
            ${MENUTITLE_PHASE})
                #Show menu-title
                show_menuTitle_w_adjustable_indent__func "${DOCKER__MENUTITLE}" "${DOCKER__EMPTYSTRING}"

                #Goto next-phase
                phase="${PRINT_START_MESSAGE}"
                ;;
            ${PRINT_START_MESSAGE})
                #Update message
                printf_subjectMsg="---:${DOCKER__START}: ${DOCKER__SUBJECT_GIT_PUSH}"
                #Show message
                show_msg_only__func "${printf_subjectMsg}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_0}"

                #Goto next-phase
                phase="${GIT_ADD_PHASE}"
                ;;
            ${GIT_ADD_PHASE})
                #Update cmd
                git_cmd="${GIT__CMD_GIT_ADD_DOT}"
                #Execute cmd
                eval ${git_cmd}

                #Check exit-code
                docker__exitCode=$?
                if [[ ${docker__exitCode} -eq 0 ]]; then
                    #Update message
                    printf_msg="------:${DOCKER__EXECUTED}: ${git_cmd} (${DOCKER__STATUS_LDONE})"
                    #Show message
                    show_msg_only__func "${printf_msg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

                    #Goto next-phase
                    phase="${GIT_COMMIT_PHASE}"
                else
                    #Update message
                    printf_msg="------:${DOCKER__EXECUTED}: ${git_cmd} (${DOCKER__STATUS_LFAILED})"
                    #Show message
                    show_msg_only__func "${printf_msg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

                    #Goto next-phase
                    phase="${PRINT_COMPLETED_MESSAGE}"
                fi
                ;;
            ${GIT_COMMIT_PHASE})
                #Update 'readDialog'
                readDialog="------:${DOCKER__INPUT}: provide a subject: "

                #Start loop
                while true
                do
                    #Show read-dialog
                    read -e -p "${readDialog}" docker__commitSubj

                    #Handle 'docker__commitSubj'
                    if [[ ! -z ${docker__commitSubj} ]]; then   #is Not an Empty String
                        break
                    else    #is an Empty String
                        if [[ ${docker__commitSubj} != "${DOCKER__ENTER}" ]]; then    #no ENTER was pressed
                            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                        fi
                    fi
                done

                #Update cmd
                git_cmd="${GIT__CMD_GIT_COMMIT_DASH_M} \"${docker__commitSubj}\""
                #Execute cmd
                eval ${git_cmd}

                #Check exit-code
                docker__exitCode=$?
                if [[ ${docker__exitCode} -eq 0 ]]; then
                    #Update message
                    printf_msg="------:${DOCKER__EXECUTED}: ${git_cmd} (${DOCKER__STATUS_LDONE})"
                    #Show message
                    show_msg_only__func "${printf_msg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

                    #Go to next-phase
                    phase="${GIT_CONFIRM_NEW_COMMIT_PHASE}"
                else
                    #Get the unpushed commits
                    #Remark:
                    #   If no 'branchName__input' is given, then NO results will be found
                    readarray -t docker__abbrevCommitHash_arr < <(git__log_for_unpushed_local_commits__func \
                            "${branchName__input}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${GIT__PLACEHOLDER_ABBREV_COMMIT_HASH}")
                    readarray -t docker__commitSubj_arr < <(git__log_for_unpushed_local_commits__func \
                            "${branchName__input}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${GIT__PLACEHOLDER_SUBJECT}")

                    #Get the number of unpush commits
                    docker__numOf_pendingCommits=`array_count_numOf_elements__func "${docker__abbrevCommitHash_arr[@]}"`

                    #Check if 'docker__numOf_pendingCommits > 0'
                    if [[ ${docker__numOf_pendingCommits} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
                        phase="${GIT_CONFIRM_EXISTING_COMMIT_PHASE}"
                    else
                        #Update message
                        printf_msg="------:${DOCKER__EXECUTED}: ${git_cmd} (${DOCKER__STATUS_LFAILED})"
                        #Show message
                        show_msg_only__func "${printf_msg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

                        #Go to next-phase
                        phase="${PRINT_COMPLETED_MESSAGE}"
                    fi
                fi
                ;;
            ${GIT_CONFIRM_EXISTING_COMMIT_PHASE})
                #Combine the two arrays 'docker__abbrevCommitHash_arr' and 'docker__commitSubj_arr'...
                #...and write the output to a specified file (e.g. git__git_push_out__fpath).
                #Remark:
                #   Also fore-color the values with 'DOCKER__FG_LIGHTGREY'
                combine_two_arrays_of_same_length_and_writeTo_file__func  "${DOCKER__COLON}" \
                        "${DOCKER__BG_LIGHTGREY}" \
                        "${git__git_push_out__fpath}" \
                        "${DOCKER__FALSE}" \
                        "${docker__abbrevCommitHash_arr[@]}" \
                        "${docker__commitSubj_arr[@]}"

                #Show file content
                show_fileContent_wo_select__func "${git__git_push_out__fpath}" \
                                "${DOCKER__TABLETITLE_EXISTING_UNPUSHED_COMMITS}" \
                                "${DOCKER__EMPTYSTRING}" \
                                "${DOCKER__EMPTYSTRING}" \
                                "${DOCKER__MENUOPTIONS}" \
                                "${DOCKER__ECHOMSG_NORESULTS_FOUND}" \
                                "${DOCKER__READDIALOG}" \
                                "${DOCKER__REGEX_YNQ}" \
                                "${docker__show_fileContent_wo_select_func_out__fpath}" \
                                "${DOCKER__TABLEROWS_10}" \
                                "${DOCKER__EMPTYSTRING}" \
                                "${DOCKER__FALSE}" \
                                "${DOCKER__NUMOFLINES_2}" \
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

                #Check if 'answer' is a numeric value
                case "${answer}" in
                    ${DOCKER__QUIT})
                        phase="${EXIT_PHASE}"
                        ;;
                    ${DOCKER__YES})
                        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                        phase="${GIT_PUSH_PHASE}"
                        ;;
                    ${DOCKER__NO})
                        # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                        phase="${EXIT_PHASE}"
                        ;;
                    *)
                        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                        ;;
                esac
                ;;
            ${GIT_CONFIRM_NEW_COMMIT_PHASE})
                #Update 'readDialog'
                readDialog="------:${DOCKER__QUESTION}: ${DOCKER__READDIALOG_YNRQ} "

                while true
                do
                    read -N1 -r -p "${readDialog}" answer

                    case "${answer}" in
                        ${DOCKER__QUIT})
                            # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                            ${GIT__CMD_GIT_RESET} --soft HEAD~

                            phase="${EXIT_PHASE}"

                            break
                            ;;
                        ${DOCKER__YES})
                            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                            phase="${GIT_PUSH_PHASE}"

                            break
                            ;;
                        ${DOCKER__NO})
                            ${GIT__CMD_GIT_RESET} --soft HEAD~

                            Goto next-phase
                            phase="${EXIT_PHASE}"

                            break
                            ;;
                        ${DOCKER__REDO})
                            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

                            echo -e "---:${PRINTF_STAGE2A}: ${PRINTF_GIT_RESET_SOFT_HEAD_CMD}"

                            ${GIT__CMD_GIT_RESET} --soft HEAD~

                            docker__reset_variables__sub

                            phase="${GIT_COMMIT_PHASE}"

                            break
                            ;;
                        ${DOCKER__ENTER})
                            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                            ;;
                        *)
                            moveToBeginning_and_cleanLine__func
                            ;;
                    esac
                done
                ;;
            ${GIT_PUSH_PHASE})
                #Get the number of commits
                #1. master:
                git_master_numOf_commits=`git rev-list --count --no-merges ${GIT__REMOTES_ORIGIN_MAIN}`
                #2. current 'branchName__input':
                git_current_branch_numOf_commits=`git rev-list --count --no-merges ${GIT__REMOTES_ORIGIN}/${branchName__input}`
                #3. difference
                git_diff_numOf_commits=$((git_current_branch_numOf_commits - git_master_numOf_commits))

                #4. Update cmd
                #Remark: 
                #   If 'git_diff_numOf_commits = 1' then it means that 'branchName__input' just did it FIRST commit.
                if [[ ${git_diff_numOf_commits} -eq ${DOCKER__NUMOFMATCH_1} ]]; then
                    git_cmd="${GIT__CMD_GIT_PUSH} -u origin ${branchName__input}"   #first commit
                else
                    git_cmd="${GIT__CMD_GIT_PUSH}"
                fi

                #Execute cmd
                eval ${git_cmd}

                #Check exit-code
                docker__exitCode=$?
                if [[ ${docker__exitCode} -eq 0 ]]; then
                    #Update message
                    printf_msg="------:${DOCKER__EXECUTED}: ${git_cmd} (${DOCKER__STATUS_LDONE})"
                else
                    #Update message
                    printf_msg="------:${DOCKER__EXECUTED}: ${git_cmd} (${DOCKER__STATUS_LFAILED})"
                fi

                #Show message
                show_msg_only__func "${printf_msg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
                
                #Goto next-phase
                phase="${PRINT_COMPLETED_MESSAGE}"
                ;;
            ${PRINT_COMPLETED_MESSAGE})
                #Update message
                printf_subjectMsg="---:${DOCKER__COMPLETED}: ${DOCKER__SUBJECT_GIT_PUSH}"
                #Show message
                show_msg_only__func "${printf_subjectMsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

                #Goto next-phase
                goto__func EXIT_PHASE
                ;;
            ${EXIT_PHASE})
                exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_1}"

                break
                ;;
        esac
    done
}



#---MAIN SUBROUTINE
main_sub() {
    docker__get_source_fullpath__sub

    docker__load_global_fpath_paths__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__add_comment_push__sub
}



#---EXECUTE
main_sub
