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

docker__load_header__sub() {
    #Input args
    local prepend_numOfLines__input=${1}

    #Print
    show_header__func "${DOCKER__TITLE}" "${DOCKER__TABLEWIDTH}" "${DOCKER__BG_ORANGE}" "${prepend_numOfLines__input}" "${DOCKER__NUMOFLINES_0}"
}

docker__load_constants__sub() {
    DOCKER__MENUTITLE="Git Undo Last Pending Commit"

    DOCKER__REMARKS="${DOCKER__FG_ORANGE}Remarks${DOCKER__NOCOLOR}:\n"
    DOCKER__REMARKS+="${DOCKER__FOURSPACES}1. The ${DOCKER__FG_LIGHTGREY}last${DOCKER__NOCOLOR} "
    DOCKER__REMARKS+="pending commit coincide with the ${DOCKER__FG_LIGHTGREY}top${DOCKER__NOCOLOR} "
    DOCKER__REMARKS+="item in the table\n"
    DOCKER__REMARKS+="${DOCKER__FOURSPACES}2. Only the ${DOCKER__FG_LIGHTGREY}last${DOCKER__NOCOLOR} "
    DOCKER__REMARKS+="pending commit can be undo'ed"
    DOCKER__READDIALOG_YN="Undo *last* pending commit (${DOCKER__Y_SLASH_N})?"
}

docker__init_variables__sub() {
    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

    docker__abbrevCommitHash_arr=()
    docker__commitSubj_arr=()
    docker__combined_arr=()
    docker__combined_string=${DOCKER__EMPTYSTRING}

    docker__numOf_pendingCommits=0
    docker__tableRows_max=${DOCKER__TABLEROWS_10}
}

docker__undo_last_unpushed_commit_handler__sub() {
    #Define constants
    local TIBBOHEADER_PHASE=1
    local GIT_RETRIEVE_PENDING_COMMITS_PHASE=2
    local GIT_COMBINE_ARRAYS_AND_WRITE_TO_FILE_PHASE=3
    local GIT_SHOW_AND_CONFIRM_PHASE=4
    local GIT_UNDO_COMMIT_PHASE=5
    local EXIT_PHASE=6

    local PRINTF_EXECUTING="${DOCKER__FG_YELLOW}EXECUTING${DOCKER__NOCOLOR}"


    #Define variables
    local answer=${DOCKER__NO}
    local phase=${TIBBOHEADER_PHASE}


    #Handle 'phase'
    while true
    do
        case "${phase}" in
            ${TIBBOHEADER_PHASE})
                docker__load_header__sub "${docker__tibboHeader_prepend_numOfLines}"

                phase="${GIT_RETRIEVE_PENDING_COMMITS_PHASE}"
                ;;
            ${GIT_RETRIEVE_PENDING_COMMITS_PHASE})
                #Get the unpushed commits
                #Remark:
                #   If no 'branchName__input' is given, then NO results will be found
                readarray -t docker__abbrevCommitHash_arr < <(git_log_for_unpushed_local_commits__func "${branchName__input}" "${DOCKER__EMPTYSTRING}" "${GIT__PLACEHOLDER_ABBREV_COMMIT_HASH}")
                readarray -t docker__commitSubj_arr < <(git_log_for_unpushed_local_commits__func "${branchName__input}" "${DOCKER__EMPTYSTRING}" "${GIT__PLACEHOLDER_SUBJECT}")

                #Get the number of unpush commits
                docker__numOf_pendingCommits=${#docker__abbrevCommitHash_arr[@]}

                phase="${GIT_COMBINE_ARRAYS_AND_WRITE_TO_FILE_PHASE}"
                ;;
            ${GIT_COMBINE_ARRAYS_AND_WRITE_TO_FILE_PHASE})
                #Combine the two arrays 'docker__abbrevCommitHash_arr' and 'docker__commitSubj_arr'
                #Remark:
                #   Also fore-color the values with 'DOCKER__FG_LIGHTGREY'
                docker__combined_string=`combine_two_arrays_of_same_length__func  "${DOCKER__COLON}" \
                        "${DOCKER__BG_LIGHTGREY}" \
                        "${docker__abbrevCommitHash_arr[@]}" \
                        "${docker__commitSubj_arr[@]}"`
                #Convert string to array
                docker__combined_arr=(`echo ${docker__combined_string}`)

                #Write array to file
                write_array_to_file__func "${git__git_push_out__fpath}" "${docker__combined_arr[@]}"

                phase="${GIT_SHOW_AND_CONFIRM_PHASE}"
                ;;
            ${GIT_SHOW_AND_CONFIRM_PHASE})
                #Show file content
                show_fileContent_wo_select__func "${git__git_push_out__fpath}" \
                                "${DOCKER__MENUTITLE}" \
                                "${DOCKER__REMARKS}" \
                                "${DOCKER__EMPTYSTRING}" \
                                "${DOCKER__MENUOPTIONS}" \
                                "${DOCKER__ECHOMSG_NORESULTS_FOUND}" \
                                "${DOCKER__READDIALOG_YN}" \
                                "${DOCKER__REGEX_YN}" \
                                "${docker__show_fileContent_wo_select_func_out__fpath}" \
                                "${docker__tableRows_max}" \
                                "${DOCKER__EMPTYSTRING}" \
                                "${DOCKER__FALSE}"

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
                    ${DOCKER__YES})
                        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                        phase="${GIT_UNDO_COMMIT_PHASE}"
                        ;;
                    ${DOCKER__NO})
                        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                        phase="${EXIT_PHASE}"
                        ;;
                    *)
                        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                        ;;
                esac
                ;;
            ${GIT_UNDO_COMMIT_PHASE})
                docker__undo_last_unpushed_commit__sub

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
    #Define constants
    local PRINTF_COMPLETED="${DOCKER__FG_ORANGE}COMPLETED${DOCKER__NOCOLOR}"
    local PRINTF_START="${DOCKER__FG_ORANGE}START${DOCKER__NOCOLOR}"

    #Define command
    local git_cmd="git reset --soft HEAD~"

    #Define messages
    local startMsg="---:${PRINTF_START}: undo last pending commit"
    local executingMsg="\n"
    executingMsg+="---:${PRINTF_EXECUTING}: ${DOCKER__FG_LIGHTGREY}${git_cmd}${DOCKER__NOCOLOR}\n"
    executingMsg+=""
    local completedMsg="---:${PRINTF_COMPLETED}: undo last pending commit"

    #Move-down and clean
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

    #Show start message
    echo -e "${startMsg}"

    #Show executing message
    echo -e "${executingMsg}"

    #Execute undo commit
    ${git_cmd}

    #Show 'completedMsg'
    echo -e "${completedMsg}"

    #Exit
    # exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_2}"
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
