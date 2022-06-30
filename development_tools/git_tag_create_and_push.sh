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
    DOCKER__MENUTITLE="Git Create & Push Tag"

    DOCKER__CHOOSEBRANCH_MENUOPTIONS="${DOCKER__FOURSPACES_Q_QUIT}"
    DOCKER__CHOOSEBRANCH_MATCHPATTERNS="${DOCKER__QUIT}"
    DOCKER__CHOOSEBRANCH_READDIALOG="Choose branch: "

    DOCKER__INPUTCHOOSETAG_MEUTITLE="List of existing tags"
    DOCKER__INPUTCHOOSETAG="Input/choose tag: "

    DOCKER__SHOWBRANCHES_MENUTITLE="Branches linked to "
    DOCKER__SHOWBRANCHES_MENUOPTIONS="${DOCKER__FOURSPACES_Y_YES}\n"
    DOCKER__SHOWBRANCHES_MENUOPTIONS+="${DOCKER__FOURSPACES_N_NO}"
    DOCKER__SHOWBRANCHES_MATCHPATTERNS="${DOCKER__YES}"
    DOCKER__SHOWBRANCHES_MATCHPATTERNS+="${DOCKER__ONESPACE}"
    DOCKER__SHOWBRANCHES_MATCHPATTERNS+="${DOCKER__NO}"

    DOCKER__ADD_TAG="add tag"
}

docker__init_variables__sub() {
    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_0}

    docker__localBranches_arr=()

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

    docker__branch_chosen=${DOCKER__EMPTYSTRING}
    docker__branch_chosen_tag=${DOCKER__EMPTYSTRING} #tag which is linked to 'docker__branch_chosen'
    docker__branch_chosen_tmp=${DOCKER__EMPTYSTRING}
    docker__stdErr=${DOCKER__EMPTYSTRING}

    docker__onEnter_breakLoop=false
    docker__showTable=true

    docker__exitCode=0
}

docker__rename_tag_handler__sub() {
    #Define constants
    local PRINTF_CHECKOUT_CHOSEN_BRANCH="checkout chosen branch"
    local readDialog=${DOCKER__EMPTYSTRING}

    #Define variables
    local answer=${DOCKER__EMPTYSTRING}

    local printf_msg=${DOCKER__EMPTYSTRING}
    local printf_subjectMsg=${DOCKER__EMPTYSTRING}

    local menuOptions=${DOCKER__EMPTYSTRING}
    local readDialog=${DOCKER__EMPTYSTRING}
    local showBranches_menutitle=${DOCKER__EMPTYSTRING}

    local git_cmd=${DOCKER__EMPTYSTRING}
    local git_linkedTo_branch=${DOCKER__EMPTYSTRING}
    local git_parentBranch=${DOCKER__EMPTYSTRING}
    local git_tag_chosen=${DOCKER__EMPTYSTRING}
    local git_parentTag_bck=${DOCKER__EMPTYSTRING}
    local git_tag_tmp=${DOCKER__EMPTYSTRING}

    local timeStamp=${DOCKER__EMPTYSTRING}

    local numOfLines=0

    local flag_tag_isNew=false
    local flag_tags_areFlipped=false
    local branch_isCheckedOut=false


#Goto phase: START
goto__func START



@START:
    #Set variable
    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

    #Goto next-phase
    goto__func PRECHECK



@PRECHECK:
    #Check if the current directory is a git-repository
    docker__stdErr=`${GIT__CMD_GIT_BRANCH} 2>&1 > /dev/null`
    if [[ ! -z ${docker__stdErr} ]]; then   #not a git-repository
        goto__func EXIT_PRECHECK_FAILED  #goto next-phase
    else    #is a git-repository
        goto__func GET_BRANCHES
    fi


@GET_BRANCHES:
    #Remove files
    if [[ -f ${git__git_tag_create_and_push_out__fpath} ]]; then
        rm ${git__git_tag_create_and_push_out__fpath}
    fi

    #Get local tags
    readarray -t docker__localBranches_arr < <(${GIT__CMD_GIT_BRANCH} | sed 's/ //g')       

    #Write array to file
    write_array_to_file__func "${git__git_tag_create_and_push_out__fpath}" "${docker__localBranches_arr[@]}"

    #Goto next-phase
    goto__func SHOW_AND_CHOOSE_BRANCH



@SHOW_AND_CHOOSE_BRANCH:
    #Show file-content
    show_pathContent_w_selection__func "${git__git_tag_create_and_push_out__fpath}" \
                    "${DOCKER__EMPTYSTRING}" \
                    "${DOCKER__MENUTITLE}" \
                    "${DOCKER__EMPTYSTRING}" \
                    "${DOCKER__EMPTYSTRING}" \
                    "${DOCKER__CHOOSEBRANCH_MENUOPTIONS}" \
                    "${DOCKER__CHOOSEBRANCH_MATCHPATTERNS}" \
                    "${DOCKER__ECHOMSG_NORESULTS_FOUND}" \
                    "${DOCKER__CHOOSEBRANCH_READDIALOG}" \
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
            docker__branch_chosen_tmp="${docker__result_from_output}"

            #Remove asterisk (*) if present
            docker__branch_chosen=`subst_char_with_another_char__func \
                    "${docker__branch_chosen_tmp}" \
                    "${DOCKER__ASTERISK}" \
                    "${DOCKER__EMPTYSTRING}"`
                    
            goto__func PRECHECK_IS_BRANCH_ALREADY_TAGGED
            ;;
    esac



@PRECHECK_IS_BRANCH_ALREADY_TAGGED:
    docker__branch_chosen_tag=`git__get_tag_for_specified_branchName__func "${docker__branch_chosen}" "${DOCKER__FALSE}"`
    if [[ ! -z "${docker__branch_chosen_tag}" ]]; then    #is Not an Empty String
        #Print Tibbo-title
        load_tibbo_title__func "${docker__tibboHeader_prepend_numOfLines}"

        #Print horizontal line
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Print menu-title
        show_header__func "${DOCKER__MENUTITLE}" \
                            "${DOCKER__TABLEWIDTH}" \
                            "${DOCKER__NOCOLOR}" \
                            "${DOCKER__NUMOFLINES_0}" \
                            "${DOCKER__NUMOFLINES_0}"

        #Print horizontal line
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Update message
        printf_msg="---:${DOCKER__CHECK}: branch ${DOCKER__FG_LIGHTBLUE}${docker__branch_chosen}${DOCKER__NOCOLOR} "
        printf_msg+="is already tagged as ${DOCKER__FG_LIGHTBLUE}${docker__branch_chosen_tag}${DOCKER__NOCOLOR}"
        #Show message
        show_msg_only__func "${printf_msg}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_0}"

        #Update message
        printf_msg="---:${DOCKER__INFO}: to ${DOCKER__FG_LIGHTGREY}rename${DOCKER__NOCOLOR} tag, "
        printf_msg+="please choose option ${DOCKER__FG_LIGHTGREY}2${DOCKER__NOCOLOR}"
        #Show message
        show_msg_only__func "${printf_msg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        #Goto next-phase
        goto__func EXIT_SUCCESSFUL
    else    #is Not tagged
        # #Update message
        # printf_msg="---:${DOCKER__CHECK}: branch ${DOCKER__FG_LIGHTBLUE}${docker__branch_chosen}${DOCKER__NOCOLOR} "
        # printf_msg+="is not tagged yet"
        # #Show message
        # show_msg_only__func "${printf_msg}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_0}"

        #Goto next-phase
        goto__func PRECHECK_IS_BRANCH_ALREADY_CHECKED_OUT
    fi



@PRECHECK_IS_BRANCH_ALREADY_CHECKED_OUT:
    #Check if asterisk is present
    branch_isCheckedOut=`git__checkIf_branch_isCheckedOut__func "${docker__branch_chosen}"`
    if [[ ${branch_isCheckedOut} == ${DOCKER__FALSE} ]]; then  #asterisk is NOT found
        #Goto next-phase
        goto__func CHECKOUT_BRANCH
    else    #asterisk is found
        #Goto next-phase
        goto__func SHOW_AND_INPUT_TAG
    fi



@CHECKOUT_BRANCH:
    #Update message
    printf_subjectMsg="---:${DOCKER__START}: ${PRINTF_CHECKOUT_CHOSEN_BRANCH}"
    #Show message
    show_msg_only__func "${printf_subjectMsg}" "${DOCKER__NUMOFLINES_2}" "${DOCKER__NUMOFLINES_0}"

    #Update cmd
    git_cmd="${GIT__CMD_GIT_CHECKOUT} ${docker__branch_chosen}"
    #Execute cmd
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
    printf_subjectMsg="---:${DOCKER__COMPLETED}: ${PRINTF_CHECKOUT_CHOSEN_BRANCH}"
    #Show message
    show_msg_only__func "${printf_subjectMsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
    
    #Goto next-phase
    if [[ ${exitCode} -eq 0 ]]; then
        goto__func SHOW_AND_INPUT_TAG
    else
        goto__func GET_BRANCHES
    fi



@SHOW_AND_INPUT_TAG:
    #Update 'menuOptions'
    menuOptions+="${DOCKER__FOURSPACES}${DOCKER__FG_LIGHTGREY}Up/Down Arrow${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}to cycle thru existing values${DOCKER__NOCOLOR}\n"
    menuOptions+="${DOCKER__FOURSPACES}${DOCKER__FG_LIGHTGREY}TAB${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}auto-complete${DOCKER__NOCOLOR}\n"
    menuOptions+="${DOCKER__FOURSPACES}${DOCKER__FG_LIGHTGREY};c${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}clear${DOCKER__NOCOLOR}\n"
    menuOptions+="$(duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}")\n"
    menuOptions+="${DOCKER__FOURSPACES_QUIT_CTRL_C}"

    #Show file-content
    ${git__git_readInput_w_autocomplete__fpath} "${DOCKER__INPUTCHOOSETAG_MEUTITLE}" \
            "${menuOptions}" \
            "${DOCKER__INPUTCHOOSETAG}" \
            "${DOCKER__ECHOMSG_NORESULTS_FOUND}" \
            "${GIT__CMD_GIT_TAG}" \
            "${docker__showTable}" \
            "${docker__onEnter_breakLoop}" \
            "${docker__tibboHeader_prepend_numOfLines}"

    #Get the exit-code just in case:
    #   1. Ctrl-C was pressed in script 'git__git_readInput_w_autocomplete__fpath'.
    #   2. An error occured in script 'git__git_readInput_w_autocomplete__fpath',...
    #      ...and exit-code = 99 came from function...
    #      ...'show_msg_w_menuTitle_w_pressAnyKey_w_ctrlC_func' (in script: docker__global.sh).
    docker__exitCode=$?
    if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
        goto__func EXIT_SUCCESSFUL
    else
        #Get the result
        git_tag_chosen=`get_output_from_file__func \
                        "${git__git_readInput_w_autocomplete_out__fpath}" \
                        "${DOCKER__LINENUM_1}"`

        #Got to next-phase
        goto__func GET_COMMIT_HASH
    fi



@GET_COMMIT_HASH:
    #Retrieve 'full commit-hash' for given 'git_tag_chosen'
    docker__full_commitHash=`git__get_full_commitHash_for_specified_tag__func \
                        "${git_tag_chosen}" \
                        "${GIT__LOCATION_LOCAL}"`

    goto__func GET_LIST_OF_BRANCHNAMES

    

@GET_LIST_OF_BRANCHNAMES:
    #Retrieve all branch names which are linked to 'docker__full_commitHash' and read to array
    readarray -t docker__branchNames_arr < <(git__get_branches_for_specified_commitHash__func \
                        "${docker__full_commitHash}" \
                        "${GIT__LOCATION_LOCAL}")

    #Write array to file
    write_array_to_file__func "${git__git_tag_create_and_push_out__fpath}" "${docker__branchNames_arr[@]}"

    #Count number of lines in file (excluding empty lines)
    numOfLines=`get_numOfLines_wo_emptyLines_in_file__func "${git__git_tag_create_and_push_out__fpath}"`
    if [[ ${numOfLines} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
        flag_tag_isNew=false
    else
        flag_tag_isNew=true
    fi

    goto__func SHOW_BRANCHNAMES_AND_CONFIRMATION



@SHOW_BRANCHNAMES_AND_CONFIRMATION:
    #Move-up and clean
    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    #Update read-dialog constant
    readDialog="Tag branch ${DOCKER__FG_LIGHTBLUE}${docker__branch_chosen}${DOCKER__NOCOLOR} "
    readDialog+="as ${DOCKER__FG_LIGHTBLUE}${git_tag_chosen}${DOCKER__NOCOLOR} (${DOCKER__Y_SLASH_N})? "

    #Update 'showBranches_menutitle'
    showBranches_menutitle="${DOCKER__SHOWBRANCHES_MENUTITLE}${DOCKER__FG_PINK}${git_tag_chosen}${DOCKER__NOCOLOR}"

    #Show file content
    show_fileContent_wo_select__func "${git__git_tag_create_and_push_out__fpath}" \
                    "${showBranches_menutitle}" \
                    "${DOCKER__EMPTYSTRING}" \
                    "${DOCKER__EMPTYSTRING}" \
                    "${DOCKER__SHOWBRANCHES_MENUOPTIONS}" \
                    "${DOCKER__ECHOMSG_NORESULTS_FOUND}" \
                    "${readDialog}" \
                    "${DOCKER__REGEX_YN}" \
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
        ${DOCKER__YES})    #back
            goto__func ADD_TAG__PRINT_START
            ;;
        ${DOCKER__NO})    #back
            goto__func EXIT_SUCCESSFUL
            ;;
    esac



@ADD_TAG__PRINT_START:
    #Update message
    printf_subjectMsg="---:${DOCKER__START}: ${DOCKER__ADD_TAG}"
    #Show message
    show_msg_only__func "${printf_subjectMsg}" "${DOCKER__NUMOFLINES_2}" "${DOCKER__NUMOFLINES_0}"

    #Goto next-phase
    if [[ ${flag_tag_isNew} == false ]]; then
        goto__func TAG_EXISTS__GENERATE_TEMPORARY_TAG
    else
        goto__func TAG_NEW__EXEC_CMD_PHASE0
    fi



@TAG_NEW__EXEC_CMD_PHASE0:
    #1. Define command
    git_cmd="${GIT__CMD_GIT_TAG} ${git_tag_chosen}"
    #2. Execute command
    eval ${git_cmd}

    #3. Set 'nextPhase'
    nextPhase="TAG_NEW__EXEC_CMD_PHASE1"

    #4. Go to next-phase
    goto__func VALIDATE_EXITCODE 



@TAG_NEW__EXEC_CMD_PHASE1:
    #Send new tag (git_tag_tmp) to remote
    #1. Define command
    git_cmd="${GIT__CMD_GIT_PUSH} origin ${git_tag_chosen}"
    #2. Execute command
    eval ${git_cmd}

    #3. Set 'nextPhase'
    nextPhase="GET_UNIQ_TAGS"

    #4. Go to next-phase
    goto__func VALIDATE_EXITCODE



@TAG_EXISTS__GENERATE_TEMPORARY_TAG:
    #Get timeStamp
    timeStamp=$(date +%s)

    #Generate temporary tag
    git_tag_tmp="${git_tag_chosen}_${timeStamp}"

    #4. Go to next-phase
    goto__func TAG_EXISTS__EXEC_CMD_PHASE0 



@TAG_EXISTS__EXEC_CMD_PHASE0:
    #create 'git_tag_tmp'
    #Remark:
    #   This is necessary because 'git_tag_chosen' is only present at Remote...
    #   ...and linked to a branch
    #1. Define command
    git_cmd="${GIT__CMD_GIT_TAG} ${git_tag_tmp}"
    #2. Execute command
    eval ${git_cmd}

    #3. Set 'nextPhase'
    nextPhase="TAG_EXISTS__EXEC_CMD_PHASE1"

    #4. Go to next-phase
    goto__func VALIDATE_EXITCODE 



@TAG_EXISTS__EXEC_CMD_PHASE1:
    #Create new tag (git_tag_tmp) from old tag (git_tag_chosen)
    #1. Define command
    git_cmd="${GIT__CMD_GIT_TAG} ${git_tag_tmp} ${git_tag_chosen}"
    #2. Execute command
    eval ${git_cmd}

    #3. Set 'nextPhase'
    nextPhase="TAG_EXISTS__EXEC_CMD_PHASE2"

    #4. Go to next-phase
    goto__func VALIDATE_EXITCODE



@TAG_EXISTS__EXEC_CMD_PHASE2:
    #Delete old tag (git_tag_chosen)
    #1. Define command
    git_cmd="${GIT__CMD_GIT_TAG} -d ${git_tag_chosen}"
    #2. Execute command
    eval ${git_cmd}

    #3. Set 'nextPhase'
    nextPhase="TAG_EXISTS__EXEC_CMD_PHASE3"

    #4. Go to next-phase
    goto__func VALIDATE_EXITCODE



@TAG_EXISTS__EXEC_CMD_PHASE3:
    #Sync changes of old tag (git_tag_chosen) to remote
    #1. Define command
    git_cmd="${GIT__CMD_GIT_PUSH} origin :refs/tags/${git_tag_chosen}"
    #2. Execute command
    eval ${git_cmd}

    #3. Set 'nextPhase'
    nextPhase="TAG_EXISTS__EXEC_CMD_PHASE4"

    #4. Go to next-phase
    goto__func VALIDATE_EXITCODE



@TAG_EXISTS__EXEC_CMD_PHASE4:
    #Send new tag (git_tag_tmp) to remote
    #1. Define command
    git_cmd="${GIT__CMD_GIT_PUSH} origin ${git_tag_tmp}"
    #2. Execute command
    eval ${git_cmd}

    #3. Set 'nextPhase'
    if [[ ${flag_tags_areFlipped} == false ]]; then
        nextPhase="TAG_EXISTS__EXEC_CMD_PHASE5"
    else
        #set 'nextPhase'
        nextPhase="GET_UNIQ_TAGS"
    fi

    #4. Go to next-phase
    goto__func VALIDATE_EXITCODE



@TAG_EXISTS__EXEC_CMD_PHASE5:
    #Flip tags
    #Remark:
    #   The reason why we do this is because...
    #   ...we want to tag the current (and the parent) branch...
    #   ...with the original tag 'git_tag_chosen'
    #1. backup 'git_tag_chosen'
    git_parentTag_bck=${git_tag_chosen}

    #2. set 'git_tag_chosen' is 'git_tag_tmp'
    git_tag_chosen=${git_tag_tmp}

    #3. set 'git_tag_tmp' is 'git_parentTag_bck'
    git_tag_tmp=${git_parentTag_bck}

    #(IMPORTANT) Set flag to 'true'
    flag_tags_areFlipped=true

    #go back to phase 'TAG_EXISTS__EXEC_CMD_PHASE0'
    goto__func TAG_EXISTS__EXEC_CMD_PHASE0



@VALIDATE_EXITCODE:
    #Check exit-code
    exitCode=$?
    if [[ ${exitCode} -eq 0 ]]; then
        #Update message
        printf_msg="------:${DOCKER__EXECUTED}: ${git_cmd} (${DOCKER__STATUS_DONE})"
        #Show message
        show_msg_only__func "${printf_msg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
    else
        #Update message
        printf_msg="------:${DOCKER__EXECUTED}: ${git_cmd} (${DOCKER__STATUS_FAILED})"
        #Show message
        show_msg_only__func "${printf_msg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        #Update 'nextPhase'
        nextPhase="GET_UNIQ_TAGS"
    fi 

    #Go to next-phase
    if [[ ${nextPhase} == "GET_UNIQ_TAGS" ]]; then
        if [[ ${exitCode} -eq 0 ]]; then
            #Update message
            printf_subjectMsg="---:${DOCKER__COMPLETED}: ${DOCKER__ADD_TAG}"
            #Show message
            show_msg_only__func "${printf_subjectMsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
        else
            printf_subjectMsg="---:${DOCKER__STOPPED}: ${DOCKER__ADD_TAG}"
            #Show message
            show_msg_only__func "${printf_subjectMsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
        fi 

        #Move-down and clean
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        #Update 'nextPhase'
        nextPhase="EXIT_SUCCESSFUL"
    fi

    goto__func ${nextPhase}



@EXIT_PRECHECK_FAILED:
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
    echo -e "${DOCKER__ERROR}: ${docker__stdErr}"
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_0}"
    
    goto__func EXIT_SUCCESSFUL



@EXIT_SUCCESSFUL:
    exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_1}"
}



#---MAIN SUBROUTINE
main_sub() {
    docker__environmental_variables__sub

    docker__load_source_files__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__rename_tag_handler__sub
}



#---EXECUTE
main_sub