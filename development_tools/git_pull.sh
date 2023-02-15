#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---SUBROUTINES
docker__get_source_fullpath__sub() {
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
    DOCKER__MENUTITLE="Git Pull"

    DOCKER__READDIALOG_YN="Pull from remote (${DOCKER__Y_SLASH_N})?"

    DOCKER__SUBJECT_GIT_PULL="git pull"
}

docker__init_variables__sub() {
    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

    docker__exitCode=0
}

docker__git_pull__sub() {
    #Define constants
    local TIBBOHEADER_PHASE=1
    local MENUTITLE_PHASE=2
    local PRINT_START_MESSAGE=3
    local GIT_CONFIRM_PULL_PHASE=4
    local GIT_PULL_PHASE=5
    local PRINT_COMPLETED_MESSAGE=6
    local EXIT_PHASE=7


    #Define variables
    local answer=${DOCKER__NO}
    local phase=${TIBBOHEADER_PHASE}

    local printf_msg=${DOCKER__EMPTYSTRING}
    local printf_subjectMsg=${DOCKER__EMPTYSTRING}
    local readDialog=${DOCKER__EMPTYSTRING}


    #Handle 'phase'
    while true
    do
        case "${phase}" in
            ${TIBBOHEADER_PHASE})
                load_tibbo_title__func "${docker__tibboHeader_prepend_numOfLines}"

                phase="${MENUTITLE_PHASE}"
                ;;
            ${MENUTITLE_PHASE})
                show_menuTitle_w_adjustable_indent__func "${DOCKER__MENUTITLE}" "${DOCKER__EMPTYSTRING}"

                phase="${PRINT_START_MESSAGE}"
                ;;
            ${PRINT_START_MESSAGE})
                #Update message
                printf_subjectMsg="---:${DOCKER__START}: ${DOCKER__SUBJECT_GIT_PULL}"
                #Show message
                show_msg_only__func "${printf_subjectMsg}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_0}"

                #Goto next-phase
                phase="${GIT_CONFIRM_PULL_PHASE}"
                ;;
            ${GIT_CONFIRM_PULL_PHASE})
                #Update 'readDialog'
                readDialog="------:${DOCKER__QUESTION}:${DOCKER__READDIALOG_YN}"
                
                while true
                do
                    read -N1 -r -p "${readDialog}" answer

                    case "${answer}" in
                        ${DOCKER__YES})
                            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                            phase="${GIT_PULL_PHASE}"

                            break
                            ;;
                        ${DOCKER__NO})
                            # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                            phase="${EXIT_PHASE}"

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
            ${GIT_PULL_PHASE})
                #Update command
                git_cmd="${GIT__CMD_GIT_PULL}"
                #Execute command
                eval ${git_cmd}

                #Check exit-code
                docker__exitCode=$?
                if [[ ${docker__exitCode} -eq 0 ]]; then
                    #Update message
                    printf_msg="------:${DOCKER__EXECUTED}: ${git_cmd} (${DOCKER__STATUS_DONE})"
                else
                    #Update message
                    printf_msg="------:${DOCKER__EXECUTED}: ${git_cmd} (${DOCKER__STATUS_FAILED})"
                fi

                #Show message
                show_msg_only__func "${printf_msg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

                #Goto next-phase
                phase="${PRINT_COMPLETED_MESSAGE}"
                ;;
            ${PRINT_COMPLETED_MESSAGE})
                #Update message
                printf_subjectMsg="---:${DOCKER__COMPLETED}: ${DOCKER__SUBJECT_GIT_PULL}"
                #Show message
                show_msg_only__func "${printf_subjectMsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_1}"

                #Goto next-phase
                goto__func EXIT_PHASE
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
    docker__get_source_fullpath__sub

    docker__load_source_files__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__git_pull__sub
}



#---EXECUTE
main_sub
