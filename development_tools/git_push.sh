#!/bin/bash -m
#---INPUT ARGS
branchName__input=${1}



#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
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
    DOCKER__MENUTITLE="Git Push"
    DOCKER__TABLETITLE_EXISTING_UNPUSHED_COMMITS="Existing Unpushed Commits"

    DOCKER__MENUOPTIONS="${DOCKER__FOURSPACES_Y_YES}\n"
    DOCKER__MENUOPTIONS+="${DOCKER__FOURSPACES_N_NO}"

    DOCKER__READDIALOG_YN="Push *pending* commits (${DOCKER__Y_SLASH_N})?"
    DOCKER__READDIALOG_YNR="Push *new* commits (${DOCKER__Y_SLASH_N_SLASH_R})?"
}

docker__init_variables__sub() {
    docker__commitSubj=${DOCKER__EMPTYSTRING}
    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

    docker__abbrevCommitHash_arr=()
    docker__commitSubj_arr=()
    docker__combined_arr=()
    docker__combined_string=${DOCKER__EMPTYSTRING}

    docker__numOf_pendingCommits=0
}

docker__load_header__sub() {
    #Input args
    local prepend_numOfLines__input=${1}

    #Print
    show_header__func "${DOCKER__TITLE}" "${DOCKER__TABLEWIDTH}" "${DOCKER__BG_ORANGE}" "${prepend_numOfLines__input}" "${DOCKER__NUMOFLINES_0}"
}

docker__add_comment_push__sub() {
    #Define constants
    local TIBBOHEADER_PHASE=1
    local MENUTITLE_PHASE=2
    local GIT_ADD_PHASE=3
    local GIT_COMMIT_PHASE=4
    local GIT_CONFIRM_EXISTING_COMMIT_PHASE=5
    local GIT_CONFIRM_NEW_COMMIT_PHASE=6
    local GIT_PUSH_PHASE=7
    local EXIT_PHASE=8

    local PRINTF_INPUT="${DOCKER__FG_YELLOW}INPUT${DOCKER__NOCOLOR}"
    local PRINTF_QUESTION="${DOCKER__FG_YELLOW}QUESTION${DOCKER__NOCOLOR}"
    local PRINTF_STAGE1="${DOCKER__FG_ORANGE}STAGE-I${DOCKER__NOCOLOR}"
    local PRINTF_STAGE2="${DOCKER__FG_ORANGE}STAGE-II${DOCKER__NOCOLOR}"
    local PRINTF_STAGE2A="${DOCKER__FG_ORANGE}STAGE-IIA${DOCKER__NOCOLOR}"
    local PRINTF_STAGE3="${DOCKER__FG_ORANGE}STAGE-III${DOCKER__NOCOLOR}"

    local PRINTF_GIT_ADD_CMD="git add ."
    local PRINTF_GIT_COMMIT_CMD="git commit -m <your subject>"
    local PRINTF_GIT_PUSH_CMD="git push"
    local PRINTF_GIT_RESET_SOFT_HEAD_CMD="git reset --soft HEAD~"

    local STATUS_DONE="${DOCKER__FG_GREEN}done${DOCKER__NOCOLOR}"
    local STATUS_FAILED="${DOCKER__FG_LIGHTRED}failed${DOCKER__NOCOLOR}"


    #Define variables
    local answer=${DOCKER__NO}
    local phase=${TIBBOHEADER_PHASE}



    #Handle 'phase'
    while true
    do
        case "${phase}" in
            ${TIBBOHEADER_PHASE})
                docker__load_header__sub "${docker__tibboHeader_prepend_numOfLines}"

                phase="${MENUTITLE_PHASE}"
                ;;
            ${MENUTITLE_PHASE})
                show_menuTitle_w_adjustable_indent__func "${DOCKER__MENUTITLE}" "${DOCKER__EMPTYSTRING}"

                phase="${GIT_ADD_PHASE}"
                ;;
            ${GIT_ADD_PHASE})
                #Move-down and clean
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                #Execute command
                git add .

                #Check exit-code
                exitCode=$?
                if [[ ${exitCode} -eq 0 ]]; then
                    echo -e "---:${PRINTF_STAGE1}: ${PRINTF_GIT_ADD_CMD} (${STATUS_DONE})"

                    phase="${GIT_COMMIT_PHASE}"
                else
                    echo -e "---:${PRINTF_STAGE1}: ${PRINTF_GIT_ADD_CMD} (${STATUS_FAILED})"

                    phase="${EXIT_PHASE}"
                fi
                ;;
            ${GIT_COMMIT_PHASE})
                #Move-down and clean
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                while true
                do
                    read -e -p "---:${PRINTF_INPUT}: subject: " docker__commitSubj

                    if [[ ! -z ${docker__commitSubj} ]]; then
                        break
                    else
                        if [[ ${docker__commitSubj} != "${DOCKER__ENTER}" ]]; then    #no ENTER was pressed
                            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                        fi
                    fi
                done

                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                #Execute command
                git commit -m "${docker__commitSubj}"

                #Check exit-code
                exitCode=$?
                if [[ ${exitCode} -eq 0 ]]; then
                    echo -e "---:${PRINTF_STAGE2}: ${PRINTF_GIT_COMMIT_CMD} (${STATUS_DONE})"

                    phase="${GIT_CONFIRM_NEW_COMMIT_PHASE}"
                else
                    #Get the unpushed commits
                    #Remark:
                    #   If no 'branchName__input' is given, then NO results will be found
                    readarray -t docker__abbrevCommitHash_arr < <(git_log_for_unpushed_local_commits__func "${branchName__input}" "${DOCKER__EMPTYSTRING}" "${GIT__PLACEHOLDER_ABBREV_COMMIT_HASH}")
                    readarray -t docker__commitSubj_arr < <(git_log_for_unpushed_local_commits__func "${branchName__input}" "${DOCKER__EMPTYSTRING}" "${GIT__PLACEHOLDER_SUBJECT}")

                    #Get the number of unpush commits
                    docker__numOf_pendingCommits=${#docker__abbrevCommitHash_arr[@]}

                    #Check if 'docker__numOf_pendingCommits > 0'
                    if [[ ${docker__numOf_pendingCommits} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
                        phase="${GIT_CONFIRM_EXISTING_COMMIT_PHASE}"
                    else
                        echo -e "---:${PRINTF_STAGE2}: ${PRINTF_GIT_COMMIT_CMD} (${STATUS_FAILED})"

                        phase="${EXIT_PHASE}"
                    fi
                fi
                ;;
            ${GIT_CONFIRM_EXISTING_COMMIT_PHASE})
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

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

                #Show file content
                show_fileContent_wo_select__func "${git__git_push_out__fpath}" \
                                "${DOCKER__TABLETITLE_EXISTING_UNPUSHED_COMMITS}" \
                                "${DOCKER__EMPTYSTRING}" \
                                "${DOCKER__EMPTYSTRING}" \
                                "${DOCKER__MENUOPTIONS}" \
                                "${DOCKER__ECHOMSG_NORESULTS_FOUND}" \
                                "${DOCKER__READDIALOG_YN}" \
                                "${DOCKER__REGEX_YN}" \
                                "${docker__show_fileContent_wo_select_func_out__fpath}" \
                                "${DOCKER__TABLEROWS_10}" \
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

                        phase="${GIT_PUSH_PHASE}"
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
            ${GIT_CONFIRM_NEW_COMMIT_PHASE})
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                while true
                do
                    read -N1 -r -p "---:${PRINTF_QUESTION}:${DOCKER__READDIALOG_YNR}" answer

                    case "${answer}" in
                        ${DOCKER__YES})
                            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                            phase="${GIT_PUSH_PHASE}"

                            break
                            ;;
                        ${DOCKER__NO})
                            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                            phase="${EXIT_PHASE}"

                            break
                            ;;
                        ${DOCKER__REDO})
                            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

                            echo -e "---:${PRINTF_STAGE2A}: ${PRINTF_GIT_RESET_SOFT_HEAD_CMD}"

                            git reset --soft HEAD~

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
                #Move-down and clean
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                #Execute command
                git push

                #Check exit-code
                exitCode=$?
                if [[ ${exitCode} -eq 0 ]]; then
                    echo -e "---:${PRINTF_STAGE3}: ${PRINTF_GIT_PUSH_CMD} (${STATUS_DONE})"
                else
                    echo -e "---:${PRINTF_STAGE3}: ${PRINTF_GIT_PUSH_CMD} (${STATUS_FAILED})"
                fi

                phase="${EXIT_PHASE}"
                ;;
            ${EXIT_PHASE})
                exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_2}"

                break
                ;;
        esac
    done
}



#---MAIN SUBROUTINE
main_sub() {
    docker__environmental_variables__sub

    docker__load_source_files__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__add_comment_push__sub
}



#---EXECUTE
main_sub
