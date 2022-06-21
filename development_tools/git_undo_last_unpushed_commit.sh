#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---INPUT ARGS
branchName__input=${1}



#---SUBROUTINES
docker__environmental_variables__sub() {
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
    docker__environmental_variables__sub

    docker__load_source_files__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__undo_last_unpushed_commit_handler__sub
}



#---EXECUTE
main_sub
