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
    #Define phase constants
    DOCKER__IMAGEID_SELECT_PHASE=0
    DOCKER__REPOTAG_RETRIEVE_PHASE=1
    DOCKER__GENERATE_IMAGE_FPATH_PHASE=2
    DOCKER__SAVE_PHASE=3

    #Define message constants
    DOCKER__MENUTITLE="Export an ${DOCKER__FG_BORDEAUX}Image${DOCKER__NOCOLOR} file"
    DOCKER__READDIALOG_CHOOSE_TARGET_DIR="Choose dst-dir: "

    #Define numeric constants
    #Remark:
    #   (DOCKER__LEADING_ECHOMSG_LEN) is the length of echo-msg '---:COMPLETED: Exporting image ' including: one space ( ), two quotes (')
    DOCKER__LEADING_ECHOMSG_LEN=33
}

docker__init_variables__sub() {
    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

    docker__answer=${DOCKER__EMPTYSTRING}
    docker__image_fpath=${DOCKER__EMPTYSTRING}
    docker__image_fpath_print=${DOCKER__EMPTYSTRING}
    docker__imageID_chosen=${DOCKER__EMPTYSTRING}
    docker__repo_chosen=${DOCKER__EMPTYSTRING}
    docker__tag_chosen=${DOCKER__EMPTYSTRING}

    # docker__images_cmd="docker images"

    # docker__images_repoColNo=1
    # docker__images_tagColNo=2
    # docker__images_IDColNo=3

    docker__onEnter_breakLoop=false
    docker__showTable=true
}


docker__save_handler__sub() {
    #Define variables
    local echomsg=${DOCKER__EMPTYSTRING}
    local phase=${DOCKER__EMPTYSTRING}
    local readmsg_remarks=${DOCKER__EMPTYSTRING}


    #Set 'readmsg_remarks'
    readmsg_remarks="${DOCKER__BG_ORANGE}Remarks:${DOCKER__NOCOLOR}\n"
    readmsg_remarks+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}Up/Down Arrow${DOCKER__NOCOLOR}: to cycle thru existing values\n"
    readmsg_remarks+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}TAB${DOCKER__NOCOLOR}: auto-complete\n"
    readmsg_remarks+="${DOCKER__DASH} ${DOCKER__FG_YELLOW};c${DOCKER__NOCOLOR}: clear"



    #Set initial 'phase'
    phase=${DOCKER__IMAGEID_SELECT_PHASE}
    while true
    do
        case "${phase}" in
            ${DOCKER__IMAGEID_SELECT_PHASE})
                ${docker__readInput_w_autocomplete__fpath} "${DOCKER__MENUTITLE}" \
                        "${DOCKER__READINPUTDIALOG_CHOOSE_IMAGEID_FROM_LIST}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${readmsg_remarks}" \
                        "${DOCKER__ERRMSG_NO_IMAGES_FOUND}" \
                        "${DOCKER__ERRMSG_CHOSEN_IMAGEID_DOESNOT_EXISTS}" \
                        "${docker__images_cmd}" \
                        "${docker__images_IDColNo}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${docker__showTable}" \
                        "${docker__onEnter_breakLoop}" \
                        "${docker__tibboHeader_prepend_numOfLines}"

                #Get the exit-code just in case:
                #   1. Ctrl-C was pressed in script 'docker__readInput_w_autocomplete__fpath'.
                #   2. An error occured in script 'docker__readInput_w_autocomplete__fpath',...
                #      ...and exit-code = 99 came from function...
                #      ...'show_msg_w_menuTitle_w_pressAnyKey_w_ctrlC_func' (in script: docker__global.sh).
                docker__exitCode=$?
                if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
                    exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
                else
                    #Retrieve the 'new tag' from file
                    docker__imageID_chosen=`get_output_from_file__func \
                                "${docker__readInput_w_autocomplete_out__fpath}" \
                                "${DOCKER__LINENUM_1}"`
                fi

                #Check if 'docker__imageID_chosen' contains data?
                #Remark:
                #   if 'docker__imageID_chosen = DOCKER__EMPTYSTRING', then it means that...
                #   ...Ctrl+C was pressed in script 'docker__readInput_w_autocomplete__fpath'.
                if [[ -z ${docker__imageID_chosen} ]]; then #false
                    exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_0}"
                else    #true
                    phase=${DOCKER__REPOTAG_RETRIEVE_PHASE}
                fi
                ;;
            ${DOCKER__REPOTAG_RETRIEVE_PHASE})
                #This subroutine outputs:
                #   1. docker__repo_chosen
                #   2. docker__tag_chosen
                docker__get_and_check_repoTag__sub

                #Goto next-phase
                if [[ -z ${docker__repo_chosen} ]] || [[ -z ${docker__tag_chosen} ]]; then
                    phase=${DOCKER__IMAGEID_SELECT_PHASE}
                else
                    phase=${DOCKER__GENERATE_IMAGE_FPATH_PHASE}
                fi
                ;;
            ${DOCKER__GENERATE_IMAGE_FPATH_PHASE})
                #Show and select directory
	            ${dirlist__readInput_w_autocomplete__fpath} "${DOCKER__EMPTYSTRING}" \
						"${docker__docker_images__dir}" \
						"${DOCKER__READDIALOG_CHOOSE_TARGET_DIR}" \
						"${DOCKER__DIRLIST_REMARKS}" \
                        "${dirlist__dst_ls_1aA_output__fpath}" \
                        "${dirlist__dst_ls_1aA_tmp__fpath}" \
						"${DOCKER__EMPTYSTRING}" \
                        "${DOCKER__NUMOFLINES_1}"

                #Get the exitcode just in case a Ctrl-C was pressed in script 'dirlist__readInput_w_autocomplete__fpath'.
                docker__exitCode=$?
                if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
                    exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
                else
                    #Get the result
                    docker__path_output=`get_output_from_file__func "${dirlist__readInput_w_autocomplete_out__fpath}" "${DOCKER__LINENUM_1}"`
                    docker__numOfMatches_output=`get_output_from_file__func "${dirlist__readInput_w_autocomplete_out__fpath}" "${DOCKER__LINENUM_2}"`
                fi
       
                #Check if 'docker__path_output' is a directory?
                if [[ -d ${docker__path_output} ]]; then    #true
                    #Generate 'docker__image_fpath'
                    docker__image_fpath="${docker__path_output}/${docker__repo_chosen}_${docker__tag_chosen}_${docker__imageID_chosen}.tar.gz"

                    #Replace multiple slashes with a single slash (/)
                    docker__image_fpath=`subst_multiple_chars_with_single_char__func "${docker__image_fpath}" \
                                    "${DOCKER__ESCAPED_SLASH}" \
                                    "${DOCKER__ESCAPED_SLASH}"`

                    #Set the maximum allowed string-length for 'docker__image_fpath_print'
                    docker__image_fpath_print_maxLen=$((DOCKER__TABLEWIDTH - DOCKER__LEADING_ECHOMSG_LEN))

                    #Resize 'docker__image_fpath' in order to fit into table-size 'DOCKER__TABLEWIDTH'
                    docker__image_fpath_print=`trim_string_toFit_specified_windowSize__func \
                            "${docker__image_fpath}" \
                            "${docker__image_fpath_print_maxLen}" \
                            "${DOCKER__TRUE}"`

                    echomsg="---:${DOCKER__FG_ORANGE}DESTINATION${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}${docker__image_fpath_print}${DOCKER__NOCOLOR}"
                    show_msg_only__func "${echomsg}" "${DOCKER__NUMOFLINES_1}"

                    #Goto next-phase
                    phase=${DOCKER__SAVE_PHASE}
                else    #false
                    show_msg_wo_menuTitle_w_PressAnyKey__func "${DOCKER__INVALID_OR_NOT_A_DIRECTORY}" \
                                "${DOCKER__NUMOFLINES_1}" \
                                "${DOCKER__TIMEOUT_10}" \
                                "${DOCKER__NUMOFLINES_1}" \
                                "${DOCKER__NUMOFLINES_1}"                    
                fi
                ;;
            ${DOCKER__SAVE_PHASE})
                #Move-down and clean
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                while true
                do
                    read -N1 -p "${DOCKER__READDIALOG_DO_YOU_WISH_TO_CONTINUE_YN}" docker__answer
                    if  [[ "${docker__answer}" == "${DOCKER__Y}" ]]; then
                        #Move-down and clean
                        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_3}"

                        #Compose echo-message
                        echomsg="---:${DOCKER__FG_ORANGE}START${DOCKER__NOCOLOR}: Exporting image '${DOCKER__FG_LIGHTGREY}${docker__image_fpath_print}${DOCKER__NOCOLOR}'\n"
                        echomsg+="------:${DOCKER__FG_ORANGE}INFO${DOCKER__NOCOLOR}: Depending on the image size...\n"
                        echomsg+="------:${DOCKER__FG_ORANGE}INFO${DOCKER__NOCOLOR}: This may take a while...\n"
                        echomsg+="------:${DOCKER__FG_ORANGE}INFO${DOCKER__NOCOLOR}: Please wait..."

                        #Show echo-message
                        show_msg_only__func "${echomsg}" "${DOCKER__NUMOFLINES_0}"

                        #Save image to 'docker__image_fpath'
                        docker image save --output ${docker__image_fpath} ${docker__repo_chosen}:${docker__tag_chosen} > /dev/null

                        #Compose echo-message
                        echomsg="---:${DOCKER__FG_ORANGE}COMPLETED${DOCKER__NOCOLOR}: Exporting image '${DOCKER__FG_LIGHTGREY}${docker__image_fpath_print}${DOCKER__NOCOLOR}'"
                        
                        #Show echo-message
                        show_msg_only__func "${echomsg}" "${DOCKER__NUMOFLINES_0}"

                        #Exit
                        exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_1}"
                    elif  [[ "${docker__answer}" == "${DOCKER__N}" ]]; then
                        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                        #Goto next-phase
                        phase=${DOCKER__IMAGEID_SELECT_PHASE}

                        break
                    else    #Empty String
                        if [[ "${docker__answer}" != "${DOCKER__ENTER}" ]]; then    #no ENTER was pressed
                            moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"
                        else    #ENTER was pressed
                            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                        fi
                    fi
                done
                ;;
        esac
    done
}

docker__get_and_check_repoTag__sub() {
    #Define message constants
    local ERRMSG_NO_REPO_FOUND="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: No matching ${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR} found for ${DOCKER__FG_BORDEAUX}ID${DOCKER__NOCOLOR} '${DOCKER__FG_LIGHTGREY}${docker__imageID_chosen}${DOCKER__NOCOLOR}'"
    local ERRMSG_NO_TAG_FOUND="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: No matching ${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} found for ${DOCKER__FG_BORDEAUX}ID${DOCKER__NOCOLOR} '${DOCKER__FG_LIGHTGREY}${docker__imageID_chosen}${DOCKER__NOCOLOR}'"
    local ERRMSG_NO_REPO_TAG_FOUND="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: No matching ${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR} and ${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} found for ${DOCKER__FG_BORDEAUX}ID${DOCKER__NOCOLOR} '${DOCKER__FG_LIGHTGREY}${docker__imageID_chosen}${DOCKER__NOCOLOR}'"

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



#---MAIN SUBROUTINE
main_sub() {
    docker__get_source_fullpath__sub

    docker__load_source_files__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__save_handler__sub

}



#---EXECUTE
main_sub
