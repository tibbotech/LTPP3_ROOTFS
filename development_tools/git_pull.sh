#!/bin/bash -m
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
    DOCKER__MENUTITLE="Git Pull"

    DOCKER__READDIALOG_YN="Pull from remote (${DOCKER__Y_SLASH_N})?"
}

docker__init_variables__sub() {
    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}
}

docker__load_header__sub() {
    #Input args
    local prepend_numOfLines__input=${1}

    #Print
    show_header__func "${DOCKER__TITLE}" "${DOCKER__TABLEWIDTH}" "${DOCKER__BG_ORANGE}" "${prepend_numOfLines__input}" "${DOCKER__NUMOFLINES_0}"
}

docker__git_pull__sub() {
    #Define constants
    local TIBBOHEADER_PHASE=1
    local MENUTITLE_PHASE=2
    local GIT_CONFIRM_PULL_PHASE=3
    local GIT_PULL_PHASE=4
    local EXIT_PHASE=5

    local PRINTF_GIT_PULL_CMD="Git pull"    

    local PRINTF_QUESTION="${DOCKER__FG_YELLOW}QUESTION${DOCKER__NOCOLOR}"
    local PRINTF_RESULT="${DOCKER__FG_ORANGE}RESULT${DOCKER__NOCOLOR}"

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

                phase="${GIT_CONFIRM_PULL_PHASE}"
                ;;
            ${GIT_CONFIRM_PULL_PHASE})
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                while true
                do
                    read -N1 -r -p "---:${PRINTF_QUESTION}:${DOCKER__READDIALOG_YN}" answer

                    case "${answer}" in
                        ${DOCKER__YES})
                            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                            phase="${GIT_PULL_PHASE}"

                            break
                            ;;
                        ${DOCKER__NO})
                            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

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
                #Move-down and clean
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                #Execute command
                git pull

                #Check exit-code
                exitCode=$?
                if [[ ${exitCode} -eq 0 ]]; then
                    echo -e "---:${PRINTF_RESULT}: ${PRINTF_GIT_PULL_CMD} (${STATUS_DONE})"
                else
                    echo -e "---:${PRINTF_RESULT}: ${PRINTF_GIT_PULL_CMD} (${STATUS_FAILED})"
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

    docker__git_pull__sub
}



#---EXECUTE
main_sub
