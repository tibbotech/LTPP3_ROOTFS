#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---NUMERIC CONSTANTS
DOCKER__NUMOF_FILES_TOBE_KEPT_MAX=100


docker__LTPP3_ROOTFS__dir=/home/imcase/repo/LTPP3_ROOTFS
docker__parentDir_of_LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS__dir%/*}
docker__LTPP3_ROOTFS_development_tools__dir=${docker__LTPP3_ROOTFS__dir}/development_tools
docker__global__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/docker_global.sh

#***IMPORTANT: EXPORT PATHS
export docker__LTPP3_ROOTFS__dir
export docker__parentDir_of_LTPP3_ROOTFS__dir
export docker__LTPP3_ROOTFS_development_tools__dir
export docker__global__fpath



#---FUNCTIONS
function get_numOfLines_to_clean() {
    #Input args
    local msg__input=${1}
    local fixed_numOfLines__input=${2}

    #Number of lines of 'msg__input'
    msg_numOfLines=`get_numOfLines_for_specified_string_or_file__func "${msg__input}"`

    #Total number of lines
    ret=$((fixed_numOfLines__input + msg_numOfLines))
    
    #Output
    echo "${ret}"
}

function rename_repoTag_w_imageId__func() {
    #Input args
    local imageId__input=${1}
    local repoNew__input=${2}
    local tagNew__input=${3}

    #Rename
    docker image tag "${imageId__input}" "${repoNew__input}:${tagNew__input}"
}

function rename_repoTag_wo_imageId__func() {
    #Input args
    local repoOld__input=${1}
    local tagOld__input=${2}
    local repoNew__input=${3}
    local tagNew__input=${4}

    #Rename
    docker tag "${repoOld__input}:${tagOld__input}" "${repoNew__input}:${tagNew__input}"
}


function remove_repoTag__func() {
    #Input args
    local repo__input=${1}
    local tag__input=${2}

    #Rename
    docker rmi "${repo__input}:${tag__input}"
}



#---SUBROUTINES
docker__load_environment_variables__sub() {
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

docker__init_variables__sub() {
    docker__imageID_chosen=${DOCKER__EMPTYSTRING}
    docker__repo_chosen=${DOCKER__EMPTYSTRING}
    docker__tag_chosen=${DOCKER__EMPTYSTRING}
    docker__repo_new=${DOCKER__EMPTYSTRING}
    docker__tag_new=${DOCKER__EMPTYSTRING}
    docker__repo_existing=${DOCKER__EMPTYSTRING}
    docker__tag_existing=${DOCKER__EMPTYSTRING}
    docker__repo_renamed=${DOCKER__EMPTYSTRING}
    docker__tag_renamed=${DOCKER__EMPTYSTRING}

    docker__renameMsg_fromTo=${DOCKER__EMPTYSTRING}

    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

    docker__onEnter_breakLoop=false
    docker__showTable=true
}

docker__rename_image_handler__sub() {
    #Define phase constants
    local IMAGEID_SELECT_PHASE=1
    local REPOTAG_RETRIEVE_PHASE=2
    local NEW_REPO_INPUT_PHASE=3
    local NEW_REPOTAG_CHECK1_PHASE=4
    local NEW_REPOTAG_CHECK2_PHASE=5
    local SUMMARY_PHASE=6
    local RENAME_REPOTAG_PHASE=7
    local EXIT_PHASE=8

    local ACTION_RENAME_REPOTAG=1
    local ACTION_RENAME_REPOTAG_W_OVERWRITE=2
    local ACTION_RENAME_REPOTAG_WO_OVERWRITE=3


    #Define message constants
    local MENUTITLE="Rename ${DOCKER__FG_PURPLE}Repository${DOCKER__NOCOLOR}:${DOCKER__FG_PINK}Tag${DOCKER__NOCOLOR}"

    local SUMMARYTITLE="${DOCKER__FG_REDORANGE}Summary${DOCKER__NOCOLOR}: "
    SUMMARYTITLE+="rename ${DOCKER__FG_PURPLE}Repository${DOCKER__NOCOLOR}:${DOCKER__FG_PINK}Tag${DOCKER__NOCOLOR}"

    local READMSG_NEW_REPOSITORY_NAME="${DOCKER__FG_YELLOW}New${DOCKER__NOCOLOR} "
    READMSG_NEW_REPOSITORY_NAME+="${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR}'s name "
    READMSG_NEW_REPOSITORY_NAME+="(e.g. ubuntu_buildbin_NEW): "

    local READMSG_NEW_REPOSITORY_TAG="${DOCKER__FG_YELLOW}New${DOCKER__NOCOLOR} "
    READMSG_NEW_REPOSITORY_TAG+="${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} (e.g. test): "

    local ERRMSG_NEW_AND_CHOSEN_REPOTAG_PAIR_ARE_IDENTICAL="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: "
    ERRMSG_NEW_AND_CHOSEN_REPOTAG_PAIR_ARE_IDENTICAL+="New and chosen ${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR}:"
    ERRMSG_NEW_AND_CHOSEN_REPOTAG_PAIR_ARE_IDENTICAL+="${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} pairs are identical"

    local WARNINGMSG_NEW_REPOTAG_PAIR_ALREADY_EXISTS="${DOCKER__FG_BORDEAUX}WARNING${DOCKER__NOCOLOR}: "
    WARNINGMSG_NEW_REPOTAG_PAIR_ALREADY_EXISTS+="New ${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR}:"
    WARNINGMSG_NEW_REPOTAG_PAIR_ALREADY_EXISTS+="${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} pair already exists"

    #Define variables
    local answer=${DOCKER__NO}
    local phase=${DOCKER__EMPTYSTRING}
    local readmsg_remarks_w_clear=${DOCKER__EMPTYSTRING}
    local readmsg_remarks_w_back_home_clear=${DOCKER__EMPTYSTRING}

    local warning_numOfLines=0
    local fixed_numOfLines=0
    local tot_numOfLines_toClean=0
    local tot_numOfLines_toMoveDown=0

    local repoTag_isUniq=false


    #Set 'readmsg_remarks_w_back_home_clear'
    readmsg_remarks_w_clear="${DOCKER__BG_ORANGE}Remarks:${DOCKER__NOCOLOR}\n"
    readmsg_remarks_w_clear+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}Up/Down Arrow${DOCKER__NOCOLOR}: to cycle thru existing values\n"
    readmsg_remarks_w_clear+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}TAB${DOCKER__NOCOLOR}: auto-complete\n"
    readmsg_remarks_w_clear+="${DOCKER__DASH} ${DOCKER__FG_YELLOW};c${DOCKER__NOCOLOR}: clear"


    #Set 'readmsg_remarks_w_back_home_clear'
    readmsg_remarks_w_back_home_clear="${DOCKER__BG_ORANGE}Remarks:${DOCKER__NOCOLOR}\n"
    readmsg_remarks_w_back_home_clear+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}Up/Down Arrow${DOCKER__NOCOLOR}: to cycle thru existing values\n"
    readmsg_remarks_w_back_home_clear+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}TAB${DOCKER__NOCOLOR}: auto-complete\n"
    readmsg_remarks_w_back_home_clear+="${DOCKER__DASH} ${DOCKER__FG_YELLOW};b${DOCKER__NOCOLOR}: back\n"
    readmsg_remarks_w_back_home_clear+="${DOCKER__DASH} ${DOCKER__FG_YELLOW};h${DOCKER__NOCOLOR}: home\n"
    readmsg_remarks_w_back_home_clear+="${DOCKER__DASH} ${DOCKER__FG_YELLOW};c${DOCKER__NOCOLOR}: clear"



    #Initialization
    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}
    phase=${IMAGEID_SELECT_PHASE}
    while true
    do
        case "${phase}" in
            ${IMAGEID_SELECT_PHASE})
                docker__load_header__sub "${docker__tibboHeader_prepend_numOfLines}"

                ${docker__readInput_w_autocomplete__fpath} "${MENUTITLE}" \
                            "${DOCKER__READINPUTDIALOG_CHOOSE_IMAGEID_FROM_LIST}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${readmsg_remarks_w_clear}" \
                            "${DOCKER__ERRMSG_NO_IMAGES_FOUND}" \
                            "${DOCKER__ERRMSG_CHOSEN_IMAGEID_DOESNOT_EXISTS}" \
                            "${docker__images_cmd}" \
                            "${docker__images_IDColNo}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${docker__showTable}" \
                            "${docker__onEnter_breakLoop}"

                #Get the exitcode just in case:
                #   1. Ctrl-C was pressed in script 'docker__readInput_w_autocomplete__fpath'.
                #   2. An error occured in script 'docker__readInput_w_autocomplete__fpath',...
                #      ...and exit-code = 99 came from function...
                #      ...'show_msg_w_menuTitle_w_pressAnyKey_w_ctrlC_func' (in script: docker__global.sh).
                docker__exitCode=$?
                if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
                    exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
                else
                    #Retrieve the selected container-ID from file
                    docker__imageID_chosen=`get_output_from_file__func \
                                    "${docker__readInput_w_autocomplete_out__fpath}" \
                                    "${DOCKER__LINENUM_1}"`
                fi  

                #Take action based on 'docker__imageID_chosen'
                if [[ -z ${docker__imageID_chosen} ]]; then
                    phase=${EXIT_PHASE}
                else
                    phase=${REPOTAG_RETRIEVE_PHASE}
                fi
                ;;
            ${REPOTAG_RETRIEVE_PHASE})
                #This subroutine outputs:
                #   1. docker__repo_chosen
                #   2. docker__tag_chosen
                #Remark:
                #   If variable 'docker__repo_chosen' or 'docker__tag_chosen' is an Empty String, then exit this function.
                docker__get_and_check_repoTag__sub
                if [[ -z ${docker__repo_chosen} ]] || [[ -z ${docker__tag_chosen} ]]; then
                    phase=${EXIT_PHASE}
                else
                    tot_numOfLines_toMoveDown=${DOCKER__NUMOFLINES_1}

                    phase=${NEW_REPO_INPUT_PHASE}
                fi
                ;;
            ${NEW_REPO_INPUT_PHASE})
                ${docker__readInput_w_autocomplete__fpath} "${MENUTITLE}" \
                            "${READMSG_NEW_REPOSITORY_NAME}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${readmsg_remarks_w_back_home_clear}" \
                            "${DOCKER__ERRMSG_NO_IMAGES_FOUND}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${docker__images_cmd}" \
                            "${docker__images_repoColNo}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${docker__showTable}" \
                            "${docker__onEnter_breakLoop}"

                #Get the exitcode just in case:
                #   1. Ctrl-C was pressed in script 'docker__readInput_w_autocomplete__fpath'.
                #   2. An error occured in script 'docker__readInput_w_autocomplete__fpath',...
                #      ...and exit-code = 99 came from function...
                #      ...'show_msg_w_menuTitle_w_pressAnyKey_w_ctrlC_func' (in script: docker__global.sh).
                docker__exitCode=$?
                if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
                    exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
                else
                    #Retrieve the 'new repository' from file
                    docker__repo_new=`get_output_from_file__func \
                            "${docker__readInput_w_autocomplete_out__fpath}" \
                            "${DOCKER__LINENUM_1}"`
                fi

                #Take action based on 'docker__imageID_chosen'
                case "${docker__repo_new}" in
                    ${DOCKER__SEMICOLON_HOME})
                        docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_1}

                        phase=${IMAGEID_SELECT_PHASE}
                        ;;
                    ${DOCKER__SEMICOLON_BACK})
                        docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_1}

                        phase=${IMAGEID_SELECT_PHASE}
                        ;;
                    *)
                        #Check if output is an Empty String
                        if [[ -z ${docker__repo_new} ]]; then
                            phase=${EXIT_PHASE}
                        else
                            tot_numOfLines_toMoveDown=${DOCKER__NUMOFLINES_1}

                            phase=${NEW_TAG_INPUT_PHASE}
                        fi
                        ;;
                esac
                ;;
            ${NEW_TAG_INPUT_PHASE})
                ${docker__readInput_w_autocomplete__fpath} "${MENUTITLE}" \
                            "${READMSG_NEW_REPOSITORY_TAG}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${readmsg_remarks_w_back_home_clear}" \
                            "${DOCKER__ERRMSG_NO_IMAGES_FOUND}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${docker__images_cmd}" \
                            "${docker__images_tagColNo}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${docker__showTable}" \
                            "${docker__onEnter_breakLoop}"
            
                #Get the exitcode just in case:
                #   1. Ctrl-C was pressed in script 'docker__readInput_w_autocomplete__fpath'.
                #   2. An error occured in script 'docker__readInput_w_autocomplete__fpath',...
                #      ...and exit-code = 99 came from function...
                #      ...'show_msg_w_menuTitle_w_pressAnyKey_w_ctrlC_func' (in script: docker__global.sh).
                docker__exitCode=$?
                if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
                    exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
                else
                    #Retrieve the 'new tag' from file
                    docker__tag_new=`get_output_from_file__func \
                                "${docker__readInput_w_autocomplete_out__fpath}" \
                                "${DOCKER__LINENUM_1}"`
                fi

                #Take action based on 'docker__imageID_chosen'
                case "${docker__tag_new}" in
                    ${DOCKER__SEMICOLON_HOME})
                        docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_1}

                        phase=${IMAGEID_SELECT_PHASE}
                        ;;
                    ${DOCKER__SEMICOLON_BACK})
                        tot_numOfLines_toMoveDown=${DOCKER__NUMOFLINES_1}

                        phase=${NEW_REPO_INPUT_PHASE}
                        ;;
                    *)
                        #Check if output is an Empty String
                        if [[ -z ${docker__tag_new} ]]; then
                            phase=${EXIT_PHASE}
                        else
                            phase=${NEW_REPOTAG_CHECK1_PHASE}
                        fi
                        ;;
                esac
                ;;
            ${NEW_REPOTAG_CHECK1_PHASE})
                #This phase checks whether the 'new' and 'chosen' repository:tag are the same
                if [[ "${docker__repo_new}" == "${docker__repo_chosen}" ]] && \
                        [[ "${docker__tag_new}" == "${docker__tag_chosen}" ]]; then
                    show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_NEW_AND_CHOSEN_REPOTAG_PAIR_ARE_IDENTICAL}" \
                            "${DOCKER__NUMOFLINES_0}" \
                            "${DOCKER__TIMEOUT_30}" \
                            "${DOCKER__NUMOFLINES_1}" \
                            "${DOCKER__NUMOFLINES_0}"

                    #Total number of lines
                    tot_numOfLines_toClean=`get_numOfLines_to_clean "${ERRMSG_NEW_AND_CHOSEN_REPOTAG_PAIR_ARE_IDENTICAL}" \
                            "${DOCKER__NUMOFLINES_2}"`

                    #Move-up and clean the ERROR message
                    moveUp_and_cleanLines__func "${tot_numOfLines_toClean}"

                    #Set 'tot_numOfLines_toMoveDown'
                    tot_numOfLines_toMoveDown=${DOCKER__NUMOFLINES_2}

                    #Go back to the beginning
                    phase=${NEW_REPO_INPUT_PHASE}
                else
                    phase=${NEW_REPOTAG_CHECK2_PHASE}
                fi
                ;;
            ${NEW_REPOTAG_CHECK2_PHASE})
                #This phase checks whether the 'new' and 'other' repository:tag are the same
                repoTag_isUniq=`checkIf_repoTag_isUniq__func "${docker__repo_new}" "${docker__tag_new}"`
                if [[ ${repoTag_isUniq} == false ]]; then
                    show_msg_wo_menuTitle_w_confirmation__func "${WARNINGMSG_NEW_REPOTAG_PAIR_ALREADY_EXISTS}" \
                            "${DOCKER__Y_SLASH_N_SLASH_O_SLASH_B_SLASH_H}" \
                            "${DOCKER__REGEX_YNOBH}" \
                            "${DOCKER__NUMOFLINES_0}" \
                            "${DOCKER__TIMEOUT_30}" \
                            "${DOCKER__NUMOFLINES_1}" \
                            "${DOCKER__NUMOFLINES_0}"

                    #Get answer
                    answer=${extern__ret}

                    #Unset extern variable
                    unset extern__ret

                    #Total number of lines
                    tot_numOfLines_toClean=`get_numOfLines_to_clean "${WARNINGMSG_NEW_REPOTAG_PAIR_ALREADY_EXISTS}" \
                            "${DOCKER__NUMOFLINES_2}"`

                    #Move-up and clean the WARNING message
                    moveUp_and_cleanLines__func "${tot_numOfLines_toClean}"

                    #Take action based on 'answer'
                    case "${answer}" in
                        ${DOCKER__YES})
                            #Update varariables
                            #Remark:
                            #   Since the 'docker__repo_new' and 'docker__tag_new' is...
                            #   ...already in use by an existing image, the repository and tag
                            #   ...of this existing image will have to be renamed.
                            docker__repo_existing="${docker__repo_new}"
                            docker__tag_existing="${docker__tag_new}"
                            docker__repo_renamed="${docker__repo_existing}"
                            docker__tag_renamed=$(date +%s)

                            tot_numOfLines_toMoveDown=${DOCKER__NUMOFLINES_1}

                            action=${ACTION_RENAME_REPOTAG_WO_OVERWRITE}

                            phase=${SUMMARY_PHASE}
                            ;;
                        ${DOCKER__NO})
                            docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

                            phase=${IMAGEID_SELECT_PHASE}
                            ;;
                        ${DOCKER__OVERWRITE})
                            tot_numOfLines_toMoveDown=${DOCKER__NUMOFLINES_1}

                            action=${ACTION_RENAME_REPOTAG_W_OVERWRITE}

                            phase=${SUMMARY_PHASE}
                            ;;
                        ${DOCKER__HOME})
                            docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

                            phase=${IMAGEID_SELECT_PHASE}
                            ;;
                        ${DOCKER__BACK})
                            tot_numOfLines_toMoveDown=${DOCKER__NUMOFLINES_2}

                            phase=${NEW_TAG_INPUT_PHASE}
                            ;;
                    esac
                else
                    #  tot_numOfLines_toMoveDown=${DOCKER__NUMOFLINES_1}
                    action=${ACTION_RENAME_REPOTAG}

                    phase=${SUMMARY_PHASE}
                fi
                ;;
            ${SUMMARY_PHASE})
                #Update 'From' message
                docker__renameMsg_fromTo="${DOCKER__FOURSPACES}From:"
                docker__renameMsg_fromTo+="${DOCKER__ONESPACE}${DOCKER__FG_LIGHTGREY}${docker__repo_chosen}${DOCKER__NOCOLOR}:"
                docker__renameMsg_fromTo+="${DOCKER__FG_LIGHTGREY}${docker__tag_chosen}${DOCKER__NOCOLOR}\n"
                
                #Update 'To' message
                if [[ "${action}" == "${ACTION_RENAME_REPOTAG}" ]]; then
                    docker__renameMsg_fromTo+="${DOCKER__FOURSPACES}To:"
                    docker__renameMsg_fromTo+="${DOCKER__THREESPACES}${DOCKER__FG_LIGHTGREY}${docker__repo_new}${DOCKER__NOCOLOR}:"
                    docker__renameMsg_fromTo+="${DOCKER__FG_LIGHTGREY}${docker__tag_new}${DOCKER__NOCOLOR}"

                    docker__summaryTitle="${SUMMARYTITLE}"
                elif [[ "${action}" == "${ACTION_RENAME_REPOTAG_WO_OVERWRITE}" ]]; then
                    docker__renameMsg_fromTo+="${DOCKER__FOURSPACES}To:"
                    docker__renameMsg_fromTo+="${DOCKER__THREESPACES}${DOCKER__FG_LIGHTGREY}${docker__repo_new}${DOCKER__NOCOLOR}:"
                    docker__renameMsg_fromTo+="${DOCKER__FG_LIGHTGREY}${docker__tag_new}${DOCKER__NOCOLOR}\n"
                    docker__renameMsg_fromTo+="\n"
                    docker__renameMsg_fromTo+="${DOCKER__FOURSPACES}WARNING: existing image will be renamed:\n"
                    docker__renameMsg_fromTo+="${DOCKER__FOURSPACES}From:"
                    docker__renameMsg_fromTo+="${DOCKER__ONESPACE}${DOCKER__FG_LIGHTGREY}${docker__repo_new}${DOCKER__NOCOLOR}:"
                    docker__renameMsg_fromTo+="${DOCKER__FG_LIGHTGREY}${docker__tag_new}${DOCKER__NOCOLOR}\n"
                    docker__renameMsg_fromTo+="${DOCKER__FOURSPACES}To:"
                    docker__renameMsg_fromTo+="${DOCKER__THREESPACES}${DOCKER__FG_LIGHTGREY}${docker__repo_renamed}${DOCKER__NOCOLOR}:"
                    docker__renameMsg_fromTo+="${DOCKER__FG_LIGHTGREY}${docker__tag_renamed}${DOCKER__NOCOLOR}"

                    docker__summaryTitle="${SUMMARYTITLE} w/o overwrite"
                else    #action = ACTION_RENAME_REPOTAG_W_OVERWRITE
                    docker__renameMsg_fromTo+="${DOCKER__FOURSPACES}To:"
                    docker__renameMsg_fromTo+="${DOCKER__THREESPACES}${DOCKER__FG_LIGHTGREY}${docker__repo_new}${DOCKER__NOCOLOR}:"
                    docker__renameMsg_fromTo+="${DOCKER__FG_LIGHTGREY}${docker__tag_new}${DOCKER__NOCOLOR}\n"
                    docker__renameMsg_fromTo+="\n"
                    docker__renameMsg_fromTo+="${DOCKER__FOURSPACES}***${DOCKER__FG_LIGHTRED}WARNING${DOCKER__NOCOLOR}***: "
                    docker__renameMsg_fromTo+="existing image (${DOCKER__FG_PURPLE}${docker__repo_new}${DOCKER__NOCOLOR}:"
                    docker__renameMsg_fromTo+="${DOCKER__FG_PINK}${docker__tag_new}${DOCKER__NOCOLOR}) be LOST!"

                    docker__summaryTitle="${SUMMARYTITLE} w/ overwrite"
                fi


                #Show summary
                show_msg_w_menuTitle_only_func "${docker__summaryTitle}" \
                                    "${docker__renameMsg_fromTo}" \
                                    "${DOCKER__NUMOFLINES_1}" \
                                    "${DOCKER__NUMOFLINES_0}"
                
                #Go to next phase
                phase=${RENAME_REPOTAG_PHASE}
                ;;
            ${RENAME_REPOTAG_PHASE})
                #Show question
                show_msg_wo_menuTitle_w_confirmation__func "${DOCKER__EMPTYSTRING}" \
                        "${DOCKER__Y_SLASH_N_SLASH_H}" \
                        "${DOCKER__REGEX_YNH}" \
                        "${DOCKER__NUMOFLINES_0}" \
                        "${DOCKER__TIMEOUT_30}" \
                        "${DOCKER__NUMOFLINES_0}" \
                        "${DOCKER__NUMOFLINES_0}"            

                #Get answer
                answer=${extern__ret}

                #Unset extern variable
                unset extern__ret

                #Take action based on 'answer'
                case "${answer}" in
                    ${DOCKER__YES})
                        case "${action}" in
                            ${ACTION_RENAME_REPOTAG})
                                docker__rename_repoTag__sub                             
                                ;;
                            ${ACTION_RENAME_REPOTAG_W_OVERWRITE})
                                docker__rename_repoTag_w_overwrite__sub
                                ;;
                            ${ACTION_RENAME_REPOTAG_WO_OVERWRITE})
                                docker__rename_repoTag_wo_overwrite__sub
                                ;;                                
                        esac

                        docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

                        phase=${IMAGEID_SELECT_PHASE}      
                        ;;
                    ${DOCKER__NO})
                        docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

                        phase=${IMAGEID_SELECT_PHASE}
                        ;;
                    ${DOCKER__HOME})
                        docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_3}

                        phase=${IMAGEID_SELECT_PHASE}
                        ;;
                    
                esac
                ;;
            ${EXIT_PHASE})
                exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_2}"
                ;;
        esac

        #Move-down and clean
        moveDown_and_cleanLines__func "${tot_numOfLines_toMoveDown}"

        #Reset variable
        tot_numOfLines_toMoveDown=${DOCKER__NUMOFLINES_0}
    done
}

docker__get_and_check_repoTag__sub() {
    #Define message constants
    local ERRMSG_NO_REPO_FOUND="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: "
    ERRMSG_NO_REPO_FOUND+="No matching ${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR} "
    ERRMSG_NO_REPO_FOUND+="found for ${DOCKER__FG_BORDEAUX}ID${DOCKER__NOCOLOR} "
    ERRMSG_NO_REPO_FOUND+=="'${DOCKER__FG_LIGHTGREY}${docker__imageID_chosen}${DOCKER__NOCOLOR}'"

    local ERRMSG_NO_TAG_FOUND="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: "
    ERRMSG_NO_TAG_FOUND+="No matching ${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} "
    ERRMSG_NO_TAG_FOUND+="found for ${DOCKER__FG_BORDEAUX}ID${DOCKER__NOCOLOR} "
    ERRMSG_NO_TAG_FOUND+="'${DOCKER__FG_LIGHTGREY}${docker__imageID_chosen}${DOCKER__NOCOLOR}'"

    local ERRMSG_NO_REPO_TAG_FOUND="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: "
    ERRMSG_NO_REPO_TAG_FOUND+="No matching ${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR} "
    ERRMSG_NO_REPO_TAG_FOUND+="and ${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} "
    ERRMSG_NO_REPO_TAG_FOUND+="found for ${DOCKER__FG_BORDEAUX}ID${DOCKER__NOCOLOR} "
    ERRMSG_NO_REPO_TAG_FOUND+="'${DOCKER__FG_LIGHTGREY}${docker__imageID_chosen}${DOCKER__NOCOLOR}'"

    #Get repository
    docker__repo_chosen=`${docker__images_cmd} | grep -w ${docker__imageID_chosen} | awk -vcolNo=${docker__images_repoColNo} '{print $colNo}'`

    #Get tag
    docker__tag_chosen=`${docker__images_cmd} | grep -w ${docker__imageID_chosen} | awk -vcolNo=${docker__images_tagColNo} '{print $colNo}'`

    #Check if any of the value is an Empty String
    if [[ -z ${docker__repo_chosen} ]] && [[ -z ${docker__tag_chosen} ]]; then
        show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_NO_REPO_TAG_FOUND}" "${DOCKER__NUMOFLINES_2}"
    else
        if [[ -z ${docker__repo_chosen} ]]; then
            show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_NO_REPO_FOUND}" "${DOCKER__NUMOFLINES_2}"
        fi

        if [[ -z ${docker__tag_chosen} ]]; then
            show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_NO_TAG_FOUND}" "${DOCKER__NUMOFLINES_2}"
        fi
    fi
}

docker__rename_repoTag__sub() {
    #Move-down and clean
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_3}"

    #Update 'startMsg'
    local startMsg=":-->${DOCKER__FG_ORANGE}START${DOCKER__NOCOLOR}: rename "
    startMsg+="${DOCKER__FG_PURPLE}${docker__repo_chosen}${DOCKER__NOCOLOR}:"
    startMsg+="${DOCKER__FG_PINK}${docker__tag_chosen}${DOCKER__NOCOLOR}"

    #Update 'completedMsg'
    local completedMsg=":-->${DOCKER__FG_ORANGE}COMPLETED${DOCKER__NOCOLOR}: rename "
    completedMsg+="${DOCKER__FG_PURPLE}${docker__repo_chosen}${DOCKER__NOCOLOR}:"
    completedMsg+="${DOCKER__FG_PINK}${docker__tag_chosen}${DOCKER__NOCOLOR}"

    #Update 'renamingMsg'
    local renamingMsg="...renaming to new: ${DOCKER__FG_LIGHTGREY}docker image tag${DOCKER__NOCOLOR} "
    renamingMsg+="${DOCKER__FG_BORDEAUX}${docker__imageID_chosen}${DOCKER__NOCOLOR} "
    renamingMsg+="${DOCKER__FG_BRIGHTLIGHTPURPLE}${docker__repo_new}${DOCKER__NOCOLOR}:"
    renamingMsg+="${DOCKER__FG_LIGHTPINK}${docker__tag_new}${DOCKER__NOCOLOR}"

    #Update 'removingMsg'
    local removingMsg="...removing existing: ${DOCKER__FG_LIGHTGREY}docker rmi${DOCKER__NOCOLOR} "
    removingMsg+="${DOCKER__FG_PURPLE}${docker__repo_chosen}${DOCKER__NOCOLOR}:"
    removingMsg+="${DOCKER__FG_PINK}${docker__tag_chosen}${DOCKER__NOCOLOR}"

    #Show 'startMsg'
    echo -e "${startMsg}"

    #Show 'renamingMsg'
    echo -e "${renamingMsg}"
    rename_repoTag_w_imageId__func "${docker__imageID_chosen}" "${docker__repo_new}" "${docker__tag_new}"

    #Show 'removingMsg'
    echo -e "${removingMsg}"
    remove_repoTag__func "${docker__repo_chosen}" "${docker__tag_chosen}"

    #Show 'completedMsg'
    echo -e "${completedMsg}"
}

docker__rename_repoTag_w_overwrite__sub() {
    #Move-down and clean
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_3}"

    #Update 'startMsg'
    local startMsg=":-->${DOCKER__FG_ORANGE}START${DOCKER__NOCOLOR}: rename "
    startMsg+="${DOCKER__FG_PURPLE}${docker__repo_chosen}${DOCKER__NOCOLOR}:"
    startMsg+="${DOCKER__FG_PINK}${docker__tag_chosen}${DOCKER__NOCOLOR} "
    startMsg+="w/ OVERWRITE"

    #Update 'completedMsg'
    local completedMsg=":-->${DOCKER__FG_ORANGE}COMPLETED${DOCKER__NOCOLOR}: rename "
    completedMsg+="${DOCKER__FG_PURPLE}${docker__repo_chosen}${DOCKER__NOCOLOR}:"
    completedMsg+="${DOCKER__FG_PINK}${docker__tag_chosen}${DOCKER__NOCOLOR} "
    completedMsg+="w/ OVERWRITE"

    #Update 'removingMsg1'
    local removingMsg1="...removing existing: ${DOCKER__FG_LIGHTGREY}docker rmi${DOCKER__NOCOLOR} "
    removingMsg1+="${DOCKER__FG_PURPLE}${docker__repo_new}${DOCKER__NOCOLOR}:"
    removingMsg1+="${DOCKER__FG_PINK}${docker__tag_new}${DOCKER__NOCOLOR}"

    #Update 'renamingMsg'
    local renamingMsg="...renaming to new: ${DOCKER__FG_LIGHTGREY}docker image tag${DOCKER__NOCOLOR} "
    renamingMsg+="${DOCKER__FG_BORDEAUX}${docker__imageID_chosen}${DOCKER__NOCOLOR} "
    renamingMsg+="${DOCKER__FG_BRIGHTLIGHTPURPLE}${docker__repo_new}${DOCKER__NOCOLOR}:"
    renamingMsg+="${DOCKER__FG_LIGHTPINK}${docker__tag_new}${DOCKER__NOCOLOR}"

    #Update 'removingMsg2'
    local removingMsg2="...removing chosen: ${DOCKER__FG_LIGHTGREY}docker rmi${DOCKER__NOCOLOR} "
    removingMsg2+="${DOCKER__FG_PURPLE}${docker__repo_chosen}${DOCKER__NOCOLOR}:"
    removingMsg2+="${DOCKER__FG_PINK}${docker__tag_chosen}${DOCKER__NOCOLOR}"

    #Show 'startMsg'
    echo -e "${startMsg}"

    #Show 'removingMsg1'
    echo -e "${removingMsg1}"
    remove_repoTag__func "${docker__repo_new}" "${docker__tag_new}"

    #Show 'renamingMsg'
    echo -e "${renamingMsg}"
    rename_repoTag_w_imageId__func "${docker__imageID_chosen}" "${docker__repo_new}" "${docker__tag_new}"

    #Show 'removingMsg2'
    echo -e "${removingMsg2}"
    remove_repoTag__func "${docker__repo_chosen}" "${docker__tag_chosen}"

    #Show 'completedMsg'
    echo -e "${completedMsg}"
}

docker__rename_repoTag_wo_overwrite__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_3}"

    #Update 'startMsg'
    local startMsg=":-->${DOCKER__FG_ORANGE}START${DOCKER__NOCOLOR}: rename "
    startMsg+="${DOCKER__FG_PURPLE}${docker__repo_chosen}${DOCKER__NOCOLOR}:"
    startMsg+="${DOCKER__FG_PINK}${docker__tag_chosen}${DOCKER__NOCOLOR} "
    startMsg+="w/o OVERWRITE"

    #Update 'completedMsg'
    local completedMsg=":-->${DOCKER__FG_ORANGE}COMPLETED${DOCKER__NOCOLOR}: rename "
    completedMsg+="${DOCKER__FG_PURPLE}${docker__repo_chosen}${DOCKER__NOCOLOR}:"
    completedMsg+="${DOCKER__FG_PINK}${docker__tag_chosen}${DOCKER__NOCOLOR} "
    completedMsg+="w/o OVERWRITE"

    #Update 'renamingMsg1'
    local renamingMsg1="...renaming existing: ${DOCKER__FG_LIGHTGREY}docker tag${DOCKER__NOCOLOR} "
    renamingMsg1+="${DOCKER__FG_PURPLE}${docker__repo_existing}${DOCKER__NOCOLOR}:"
    renamingMsg1+="${DOCKER__FG_PINK}${docker__tag_existing}${DOCKER__NOCOLOR} "
    renamingMsg1+="${DOCKER__FG_BRIGHTLIGHTPURPLE}${docker__repo_renamed}${DOCKER__NOCOLOR}:"
    renamingMsg1+="${DOCKER__FG_LIGHTPINK}${docker__tag_renamed}${DOCKER__NOCOLOR}"

    #Update 'removingMsg1'
    local removingMsg1="...removing existing: ${DOCKER__FG_LIGHTGREY}docker rmi${DOCKER__NOCOLOR} "
    removingMsg1+="${DOCKER__FG_PURPLE}${docker__repo_existing}${DOCKER__NOCOLOR}:"
    removingMsg1+="${DOCKER__FG_PINK}${docker__tag_existing}${DOCKER__NOCOLOR}"

    #Update 'renamingMsg2'
    local renamingMsg2="...renaming to new: ${DOCKER__FG_LIGHTGREY}docker image tag${DOCKER__NOCOLOR} "
    renamingMsg2+="${DOCKER__FG_BORDEAUX}${docker__imageID_chosen}${DOCKER__NOCOLOR} "
    renamingMsg2+="${DOCKER__FG_BRIGHTLIGHTPURPLE}${docker__repo_new}${DOCKER__NOCOLOR}:"
    renamingMsg2+="${DOCKER__FG_LIGHTPINK}${docker__tag_new}${DOCKER__NOCOLOR}"

    #Update 'removingMsg2'
    local removingMsg2="...removing chosen: ${DOCKER__FG_LIGHTGREY}docker rmi${DOCKER__NOCOLOR} "
    removingMsg2+="${DOCKER__FG_PURPLE}${docker__repo_chosen}${DOCKER__NOCOLOR}:"
    removingMsg2+="${DOCKER__FG_PINK}${docker__tag_chosen}${DOCKER__NOCOLOR}"

    #Show 'startMsg'
    echo -e "${startMsg}"

    #Show 'renamingMsg1'
    echo -e "${renamingMsg1}"
    rename_repoTag_wo_imageId__func "${docker__repo_existing}" "${docker__tag_existing}" "${docker__repo_renamed}" "${docker__tag_renamed}"

    #Show 'removingMsg1'
    echo -e "${removingMsg1}"
    remove_repoTag__func "${docker__repo_existing}" "${docker__tag_existing}"

    #Show 'renamingMsg2'
    echo -e "${renamingMsg2}"
    rename_repoTag_w_imageId__func "${docker__imageID_chosen}" "${docker__repo_new}" "${docker__tag_new}"

    #Show 'removingMsg2'
    echo -e "${removingMsg2}"
    remove_repoTag__func "${docker__repo_chosen}" "${docker__tag_chosen}"

    #Show 'completedMsg'
    echo -e "${completedMsg}"
}



#---MAIN SUBROUTINE
main_sub() {
    docker__load_environment_variables__sub

    docker__load_source_files__sub

    # docker__load_header__sub

    docker__init_variables__sub

    docker__rename_image_handler__sub
}



#---EXECUTE
main_sub

