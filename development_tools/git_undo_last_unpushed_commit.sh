#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---INPUT ARGS
branchName__input=${1}



#---SUBROUTINES
docker__get_source_fullpath__sub() {
    #Define constants
    local DOCKER__PHASE_CHECK_CACHE=1
    local DOCKER__PHASE_FIND_PATH=10
    local DOCKER__PHASE_EXIT=100

    #Define variables
    local docker__phase=""

    local docker__current_dir=
    local docker__tmp_dir=""

    local docker__development_tools__foldername=""
    local docker__LTPP3_ROOTFS__foldername=""
    local docker__global__filename=""
    local docker__parentDir_of_LTPP3_ROOTFS__dir=""

    local docker__mainmenu_path_cache__filename=""
    local docker__mainmenu_path_cache__fpath=""

    local docker__find_dir_result_arr=()
    local docker__find_dir_result_arritem=""
    local docker__find_dir_result_arrlen=0
    local docker__find_dir_result_arrlinectr=0
    local docker__find_dir_result_arrprogressperc=0

    local docker__path_of_development_tools_found=""
    local docker__parentpath_of_development_tools=""

    local docker__isfound=""

    #Set variables
    docker__phase="${DOCKER__PHASE_CHECK_CACHE}"
    docker__current_dir=$(dirname $(readlink -f $0))
    docker__tmp_dir=/tmp
    docker__development_tools__foldername="development_tools"
    docker__global__filename="docker_global.sh"
    docker__LTPP3_ROOTFS__foldername="LTPP3_ROOTFS"

    docker__mainmenu_path_cache__filename="docker__mainmenu_path.cache"
    docker__mainmenu_path_cache__fpath="${docker__tmp_dir}/${docker__mainmenu_path_cache__filename}"

    docker_result=false

    #Start loop
    while true
    do
        case "${docker__phase}" in
            "${DOCKER__PHASE_CHECK_CACHE}")
                if [[ -f "${docker__mainmenu_path_cache__fpath}" ]]; then
                    #Get the directory stored in cache-file
                    docker__LTPP3_ROOTFS_development_tools__dir=$(awk 'NR==1' "${docker__mainmenu_path_cache__fpath}")

                    #Move one directory up
                    docker__parentpath_of_development_tools=$(dirname "${docker__LTPP3_ROOTFS_development_tools__dir}")

                    #Check if 'development_tools' is in the 'LTPP3_ROOTFS' folder
                    docker__isfound=$(docker__checkif_paths_are_related "${docker__current_dir}" \
                            "${docker__parentpath_of_development_tools}" "${docker__LTPP3_ROOTFS__foldername}")
                    if [[ ${docker__isfound} == false ]]; then
                        docker__phase="${DOCKER__PHASE_FIND_PATH}"
                    else
                        docker_result=true

                        docker__phase="${DOCKER__PHASE_EXIT}"
                    fi
                else
                    docker__phase="${DOCKER__PHASE_FIND_PATH}"
                fi
                ;;
            "${DOCKER__PHASE_FIND_PATH}")   
                #Print
                echo -e "---:\e[30;38;5;215mSTART\e[0;0m: find path of folder \e[30;38;5;246m'${docker__development_tools__foldername}\e[0;0m : \e[1;33mDONE\e[0;0m"

                #Reset variable
                docker__LTPP3_ROOTFS_development_tools__dir=""

                #Start loop
                while true
                do
                    #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
                    #... and read to array 'find_result_arr'
                    readarray -t docker__find_dir_result_arr < <(find  / -type d -iname "${docker__LTPP3_ROOTFS__foldername}" 2> /dev/null)

                    #Get array-length
                    docker__find_dir_result_arrlen=${#docker__find_dir_result_arr[@]}

                    #Iterate thru each array-item
                    for docker__find_dir_result_arritem in "${docker__find_dir_result_arr[@]}"
                    do
                        docker__isfound=$(docker__checkif_paths_are_related "${docker__current_dir}" \
                                "${docker__find_dir_result_arritem}"  "${docker__LTPP3_ROOTFS__foldername}")
                        if [[ ${docker__isfound} == true ]]; then
                            #Update variable 'docker__path_of_development_tools_found'
                            docker__path_of_development_tools_found="${docker__find_dir_result_arritem}/${docker__development_tools__foldername}"

                            # #Increment counter
                            docker__find_dir_result_arrlinectr=$((docker__find_dir_result_arrlinectr+1))

                            #Calculate the progress percentage value
                            docker__find_dir_result_arrprogressperc=$(( docker__find_dir_result_arrlinectr*100/docker__find_dir_result_arrlen ))

                            #Moveup and clean
                            if [[ ${docker__find_dir_result_arrlinectr} -gt 1 ]]; then
                                tput cuu1
                                tput el
                            fi

                            #Print
                            #Note: do not print the '100%'
                            if [[ ${docker__find_dir_result_arrlinectr} -lt ${docker__find_dir_result_arrlen} ]]; then
                                echo -e "------:PROGRESS: ${docker__find_dir_result_arrprogressperc}%"
                            fi

                            #Check if 'directory' exist
                            if [[ -d "${docker__path_of_development_tools_found}" ]]; then    #directory exists
                                #Update variable
                                #Remark:
                                #   'docker__LTPP3_ROOTFS_development_tools__dir' is a global variable.
                                #   This variable will be passed 'globally' to script 'docker_global.sh'.
                                docker__LTPP3_ROOTFS_development_tools__dir="${docker__path_of_development_tools_found}"

                                #Print
                                #Note: print the '100%' here
                                echo -e "------:PROGRESS: 100%"

                                break
                            fi
                        fi
                    done

                    #Check if 'docker__LTPP3_ROOTFS_development_tools__dir' contains any data
                    if [[ -z "${docker__LTPP3_ROOTFS_development_tools__dir}" ]]; then  #contains no data
                        echo -e "\r"
                        echo -e "***\e[1;31mERROR\e[0;0m: folder \e[30;38;5;246m${docker__development_tools__foldername}\e[0;0m: \e[30;38;5;131mNot Found\e[0;0m"
                        echo -e "\r"

                         #Update variable
                        docker_result=false
                    else    #contains data
                        #Print
                        echo -e "---:\e[30;38;5;215mCOMPLETED\e[0;0m: find path of folder \e[30;38;5;246m'${docker__development_tools__foldername}\e[0;0m : \e[1;33mDONE\e[0;0m"


                        #Write to file
                        echo "${docker__LTPP3_ROOTFS_development_tools__dir}" | tee "${docker__mainmenu_path_cache__fpath}" >/dev/null

                        #Print
                        echo -e "---:\e[30;38;5;215mSTATUS\e[0;0m: write path to temporary cache-file: \e[1;33mDONE\e[0;0m"

                        #Update variable
                        docker_result=true
                    fi

                    #set phase
                    docker__phase="${DOCKER__PHASE_EXIT}"

                    #Exit loop
                    break
                done
                ;;    
            "${DOCKER__PHASE_EXIT}")
                break
                ;;
        esac
    done

    #Exit if 'docker_result = false'
    if [[ ${docker_result} == false ]]; then
        exit 99
    fi

    #Retrieve directories
    #Remark:
    #   'docker__LTPP3_ROOTFS__dir' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/
    docker__parentDir_of_LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS__dir%/*}    #move two directories up. This directory is the one-level higher than LTPP3_ROOTFS/

    #Get full-path
    #Remark:
    #   'docker__global__fpath' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__global__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__global__filename}
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
docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

docker__load_constants__sub() {
    DOCKER__MENUTITLE="Git Undo Last Unpushed Commit"
    DOCKER__UNDO_LAST_UNPUSHED_COMMIT="undo last unpushed commit"

    DOCKER__REMARKS="${DOCKER__FG_ORANGE}Remark${DOCKER__NOCOLOR}:\n"
    DOCKER__REMARKS+="${DOCKER__FOURSPACES}${DOCKER__FG_LIGHTGREY}last${DOCKER__NOCOLOR} "
    DOCKER__REMARKS+="unpushed commit = ${DOCKER__FG_LIGHTGREY}top${DOCKER__NOCOLOR} table-item"

    DOCKER__MENUOPTIONS="${DOCKER__FOURSPACES_Y_YES}\n"
    DOCKER__MENUOPTIONS+="${DOCKER__FOURSPACES_N_NO}\n"
    DOCKER__MENUOPTIONS+="${DOCKER__FOURSPACES_Q_QUIT}"

    DOCKER__READDIALOG="Undo ${DOCKER__FG_LIGHTGREY}last${DOCKER__NOCOLOR} unpushed commit (${DOCKER__Y_SLASH_N_SLASH_Q})? "
}

docker__init_variables__sub() {
    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

    docker__abbrevCommitHash_arr=()
    docker__commitSubj_arr=()

    docker__combined_arrIndex=0

    docker__numOf_unpushedCommits=0
    docker__tableRows_max=${DOCKER__TABLEROWS_10}
}

docker__reset_variables__sub() {
    docker__abbrevCommitHash_arr=()
    docker__commitSubj_arr=()
}

docker__undo_last_unpushed_commit_handler__sub() {
    #Define constants
    local TIBBOHEADER_PHASE=1
    local GIT_RETRIEVE_PENDING_COMMITS_PHASE=2
    local GIT_COMBINE_ARRAYS_AND_WRITE_TO_FILE_PHASE=3
    local GIT_SHOW_AND_CONFIRM_PHASE=4
    local GIT_UNDO_COMMIT_PHASE=5
    local EXIT_PHASE=6


    #Define variables
    local answer=${DOCKER__NO}
    local phase=${TIBBOHEADER_PHASE}


    #Handle 'phase'
    while true
    do
        case "${phase}" in
            ${TIBBOHEADER_PHASE})
                # load_tibbo_title__func "${docker__tibboHeader_prepend_numOfLines}"

                phase="${GIT_RETRIEVE_PENDING_COMMITS_PHASE}"
                ;;
            ${GIT_RETRIEVE_PENDING_COMMITS_PHASE})
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
                docker__numOf_unpushedCommits=`array_count_numOf_elements__func "${docker__abbrevCommitHash_arr[@]}"`

                #Goto next-phase
                phase="${GIT_COMBINE_ARRAYS_AND_WRITE_TO_FILE_PHASE}"
                ;;
            ${GIT_COMBINE_ARRAYS_AND_WRITE_TO_FILE_PHASE})
                if [[ ${docker__numOf_unpushedCommits} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
                    #Combine the two arrays 'docker__abbrevCommitHash_arr' and 'docker__commitSubj_arr'...
                    #...and write the output to a specified file (e.g. git__git_undo_last_unpushed_commit_out__fpath).
                    #Remark:
                    #   Also fore-color the values with 'DOCKER__FG_LIGHTGREY'
                    combine_two_arrays_of_same_length_and_writeTo_file__func  "${DOCKER__COLON}" \
                            "${DOCKER__BG_LIGHTGREY}" \
                            "${git__git_undo_last_unpushed_commit_out__fpath}" \
                            "${DOCKER__FALSE}" \
                            "${docker__abbrevCommitHash_arr[@]}" \
                            "${docker__commitSubj_arr[@]}"
                else
                    #Remove file (if present)
                    if [[ -f ${git__git_undo_last_unpushed_commit_out__fpath} ]]; then
                        rm ${git__git_undo_last_unpushed_commit_out__fpath}
                    fi

                    #Create an empty file
                    touch ${git__git_undo_last_unpushed_commit_out__fpath}
                fi

                #Goto next-phase
                phase="${GIT_SHOW_AND_CONFIRM_PHASE}"
                ;;
            ${GIT_SHOW_AND_CONFIRM_PHASE})
                #Show file content
                show_fileContent_wo_select__func "${git__git_undo_last_unpushed_commit_out__fpath}" \
                                "${DOCKER__MENUTITLE}" \
                                "${DOCKER__REMARKS}" \
                                "${DOCKER__EMPTYSTRING}" \
                                "${DOCKER__MENUOPTIONS}" \
                                "${DOCKER__ECHOMSG_NORESULTS_FOUND}" \
                                "${DOCKER__READDIALOG}" \
                                "${DOCKER__REGEX_YNQ}" \
                                "${docker__show_fileContent_wo_select_func_out__fpath}" \
                                "${docker__tableRows_max}" \
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

                #Check if 'answer' is a numeric value
                case "${answer}" in
                    ${DOCKER__QUIT})
                        phase="${EXIT_PHASE}"
                        ;;
                    ${DOCKER__YES})
                        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                        phase="${GIT_UNDO_COMMIT_PHASE}"
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
            ${GIT_UNDO_COMMIT_PHASE})
                docker__undo_last_unpushed_commit__sub

                docker__reset_variables__sub

                phase="${TIBBOHEADER_PHASE}"
                ;;
            ${EXIT_PHASE})
                exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_2}"

                break
                ;;
        esac
    done
}

docker__undo_last_unpushed_commit__sub() {
    #Define command
    local git_cmd="${GIT__CMD_GIT_RESET} --soft HEAD~"

    #Define messages
    local printf_msg=${DOCKER__EMPTYSTRING}
    local printf_subjectMsg=${DOCKER__EMPTYSTRING}

    #Update message
    printf_subjectMsg="---:${DOCKER__START}: ${DOCKER__UNDO_LAST_UNPUSHED_COMMIT}"
    #Show message
    show_msg_only__func "${printf_subjectMsg}" "${DOCKER__NUMOFLINES_2}" "${DOCKER__NUMOFLINES_0}"

    #Execute undo commit
    eval ${git_cmd}

    #Check exit-code
    exitCode=$?
    if [[ ${exitCode} -eq 0 ]]; then
        #Update message
        printf_msg="------:${DOCKER__EXECUTED}: ${git_cmd} (${DOCKER__STATUS_DONE})"
    else
        #Update message
        printf_msg="------:${DOCKER__EXECUTED}: ${git_cmd} (${DOCKER__STATUS_FAILED})"
    fi

    #Show message
    show_msg_only__func "${printf_msg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

    #Update message
    printf_subjectMsg="---:${DOCKER__COMPLETED}: ${DOCKER__UNDO_LAST_UNPUSHED_COMMIT}"
    #Show message
    show_msg_only__func "${printf_subjectMsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
}


#---MAIN SUBROUTINE
main_sub() {
    docker__get_source_fullpath__sub

    docker__load_source_files__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__undo_last_unpushed_commit_handler__sub
}



#---EXECUTE
main_sub
