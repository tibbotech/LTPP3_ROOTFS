#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---INPUT ARGS
git_location__input=${1}    #GIT__LOCATION_LOCAL or GIT__LOCATION_REMOTE



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
        printf_cmdMsg="------:${DOCKER__EXECUTED}: ${git_cmd} (${DOCKER__STATUS_DONE})"
    else
        #Update message
        printf_cmdMsg="------:${DOCKER__ERROR}: ${git_cmdMsg} (${DOCKER__STATUS_FAILED})"
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

    docker__load_source_files__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__check_input_args__sub

    docker__remove_tag_handler__sub
}



#---EXECUTE
main_sub
