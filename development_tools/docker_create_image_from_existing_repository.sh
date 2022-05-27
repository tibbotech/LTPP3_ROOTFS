#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---NUMERIC CONSTANTS
DOCKER__NUMOF_FILES_TOBE_KEPT_MAX=100



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
    show_header__func "${DOCKER__TITLE}" "${DOCKER__TABLEWIDTH}" "${DOCKER__BG_ORANGE}" "${DOCKER__NUMOFLINES_2}" "${DOCKER__NUMOFLINES_0}"
}

docker__init_variables__sub() {
    docker__imageID_chosen=${DOCKER__EMPTYSTRING}
    docker__repo_chosen=${DOCKER__EMPTYSTRING}
    docker__tag_chosen=${DOCKER__EMPTYSTRING}
    docker__repo_new=${DOCKER__EMPTYSTRING}

    # docker__images_cmd="docker images"

    # docker__images_repoColNo=1
    # docker__images_tagColNo=2
    # docker__images_IDColNo=3

    docker__onEnter_breakLoop=false
    docker__showTable=true
}

docker__cleanup_dockerfiles__sub() {
    #Get number of files in directory: <home>/repo/docker/dockerfiles
    local numOf_files=`ls -1ltr ${docker__docker_dockerfiles__dir} | grep "^-" | wc -l`

    #MESSAGE CONSTANTS
    local ECHOMSG_MAX_NUMOF_FILES_EXCEEDED="Maximum number of files exceeded (${DOCKER__FG_LIGHTGREY}${numOf_files}${DOCKER__NOCOLOR} out-of ${DOCKER__FG_LIGHTGREY}${DOCKER__NUMOF_FILES_TOBE_KEPT_MAX}${DOCKER__NOCOLOR})"
    local ECHOMSG_DELETING_FILES="Deleting files..."


    #Check if 'numOf_files' has exceeded 'DOCKER__NUMOF_FILES_TOBE_KEPT_MAX'
    if [[ ${numOf_files} -gt ${DOCKER__NUMOF_FILES_TOBE_KEPT_MAX} ]]; then
        #Print warning
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "---${DOCKER__FG_LIGHTRED}WARNING${DOCKER__NOCOLOR}: ${ECHOMSG_MAX_NUMOF_FILES_EXCEEDED}"
        echo -e "---${DOCKER__FG_LIGHTSOFTYELLOW}LOCATION${DOCKER__NOCOLOR}: ${docker__docker_dockerfiles__dir}"
        echo -e "---${DOCKER__FG_ORANGE}START${DOCKER__NOCOLOR}: ${ECHOMSG_DELETING_FILES}"

        #Number of files exceeding
        local numOf_files_exceeded=$((numOf_files-DOCKER__NUMOF_FILES_TOBE_KEPT_MAX))

        #Put all files in array 'filesArr'
        local filesArr=()
        readarray filesArr <<< $(ls -1ltr ${docker__docker_dockerfiles__dir} | grep "^-" | awk '{print $9}')

        #Initialization
        local numof_files_deleted=0
        
        #Start deleting files (oldest first)
        local filesArr_item=${DOCKER__EMPTYSTRING}
        local dockerfile_fpath=${DOCKER__EMPTYSTRING}
        for filesArr_item in "${filesArr[@]}"
        do                         
            #Update variable
            dockerfile_fpath=${docker__docker_dockerfiles__dir}/${filesArr_item}  

            #Remove file(s)
            rm ${dockerfile_fpath}

            #Print
            echo -e "${DOCKER__FOURSPACES}${filesArr_item}"

            #Move-up one line
            #Remark:
            #   Somehow after printing the above message
            #       An empty line is printed is as well automatically.
            #   Therefore, we'll need to move the cursor up one line.
            tput cuu1

            #Increment counter
            numof_files_deleted=$((numof_files_deleted + 1))

            #Check if the number of allowed to-be-deleted files has been reached
            if [[ ${numof_files_deleted} -eq ${numOf_files_exceeded} ]]; then
                break
            fi                                             
        done

        echo -e "---${DOCKER__FG_ORANGE}COMPLETED${DOCKER__NOCOLOR}: ${ECHOMSG_DELETING_FILES}"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    fi
}

docker__create_dockerfile__sub() {
    #Create directory if not present
    if [[ ! -d ${docker__docker_dockerfiles__dir} ]]; then
        mkdir -p ${docker__docker_dockerfiles__dir}
    fi

    #Generate timestamp
    local dockerfile_autogen_filename=${docker__dockerfile_auto_filename}_${docker__repo_new}

    #Define filename
    docker__dockerfile_autogen_fpath=${docker__docker_dockerfiles__dir}/${dockerfile_autogen_filename}

    #Check if file exist
    #If DOCKER__TRUE, then remove file
    if [[ -f ${docker__dockerfile_autogen_fpath} ]]; then
        rm ${docker__dockerfile_autogen_fpath}
    fi

    #Define dockerfile content
    DOCKERFILE_CONTENT_ARR=(\
        "#---Continue from Repository:TAG=${docker__repo_chosen}:${docker__tag_chosen}"\
        "FROM ${docker__repo_chosen}:${docker__tag_chosen}"\
        ""\
        "#---LABEL about the custom image"\
        "LABEL maintainer=\"hien@tibbo.com\""\
        "LABEL version=\"0.1\""\
        "LABEL description=\"Continue from image '${docker__repo_chosen}:${docker__tag_chosen}', and run 'build_BOOOT_BIN.sh'\""\
        "LABEL NEW repository:tag=\"${docker__repo_new}:${docker__tag_chosen}\""\
        ""\
        "#---Disable Prompt During Packages Installation"\
        "ARG DEBIAN_FRONTEND=noninteractive"\
        ""\
        "#---Update local Git repository"\
        "#RUN cd ~/LTPP3_ROOTFS && git pull"\
        ""\
        "#---Run Prepreparation of Disk (before Chroot)"\
        "#RUN cd ~ && ~/LTPP3_ROOTFS/build_BOOOT_BIN.sh"\
    )


    #Cycle thru array and write each row to Global variable 'docker__dockerfile_autogen_fpath'
	for ((i=0; i<${#DOCKERFILE_CONTENT_ARR[@]}; i++))
	do
        echo -e "${DOCKERFILE_CONTENT_ARR[$i]}" >> ${docker__dockerfile_autogen_fpath}
	done
}

docker__create_image_handler__sub() {
    #Define phase constants
    local IMAGEID_SELECT_PHASE=0
    local REPOTAG_RETRIEVE_PHASE=1
    local NEW_REPO_INPUT_PHASE=2
    local NEW_TAG_INPUT_PHASE=3
    local NEW_REPOTAG_CHECK_PHASE=4
    local CREATE_IMAGE_PHASE=5

    #Define message constants
    local MENUTITLE="Create an ${DOCKER__FG_BORDEAUX}Image${DOCKER__NOCOLOR} from a "
    MENUTITLE+="${DOCKER__FG_PURPLE}Repository${DOCKER__NOCOLOR}"

    local READMSG_NEW_REPOSITORY_NAME="${DOCKER__FG_YELLOW}New${DOCKER__NOCOLOR} "
    READMSG_NEW_REPOSITORY_NAME+="${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR}'s name "
    READMSG_NEW_REPOSITORY_NAME+="(e.g. ubuntu_buildbin_NEW): "

    local READMSG_NEW_REPOSITORY_TAG="${DOCKER__FG_YELLOW}New${DOCKER__NOCOLOR} "
    READMSG_NEW_REPOSITORY_TAG+="${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} (e.g. test): "

    local ERRMSG_CHOSEN_REPO_PAIR_ALREADY_EXISTS="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: "
    ERRMSG_CHOSEN_REPO_PAIR_ALREADY_EXISTS+="chosen ${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR}:"
    ERRMSG_CHOSEN_REPO_PAIR_ALREADY_EXISTS+="${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} pair already exists"


    #Define variables
    local phase=${DOCKER__EMPTYSTRING}
    local readmsg_remarks=${DOCKER__EMPTYSTRING}

    local repoTag_isUniq=false



    #Set 'readmsg_remarks'
    readmsg_remarks="${DOCKER__BG_ORANGE}Remarks:${DOCKER__NOCOLOR}\n"
    readmsg_remarks+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}Up/Down Arrow${DOCKER__NOCOLOR}: to cycle thru existing values\n"
    readmsg_remarks+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}TAB${DOCKER__NOCOLOR}: auto-complete\n"
    readmsg_remarks+="${DOCKER__DASH} ${DOCKER__FG_YELLOW};c${DOCKER__NOCOLOR}: clear"



    #Set initial 'phase'
    phase=${IMAGEID_SELECT_PHASE}
    while true
    do
        case "${phase}" in
            ${IMAGEID_SELECT_PHASE})
                ${docker__readInput_w_autocomplete__fpath} "${MENUTITLE}" \
                            "${DOCKER__READINPUTDIALOG_CHOOSE_IMAGEID_FROM_LIST}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${readmsg_remarks}" \
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

                #Check if output is an Empty String
                if [[ -z ${docker__imageID_chosen} ]]; then
                    return
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
                    return
                else
                    phase=${NEW_REPO_INPUT_PHASE}
                fi
                
                ;;
            ${NEW_REPO_INPUT_PHASE})
                ${docker__readInput_w_autocomplete__fpath} "${MENUTITLE}" \
                            "${READMSG_NEW_REPOSITORY_NAME}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${readmsg_remarks}" \
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

                #Check if output is an Empty String
                if [[ -z ${docker__repo_new} ]]; then
                    return
                else
                    phase=${NEW_TAG_INPUT_PHASE}
                fi
                ;;
            ${NEW_TAG_INPUT_PHASE})
                ${docker__readInput_w_autocomplete__fpath} "${MENUTITLE}" \
                            "${READMSG_NEW_REPOSITORY_TAG}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${readmsg_remarks}" \
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

                #Check if output is an Empty String
                if [[ -z ${docker__tag_new} ]]; then
                    return
                else
                    phase=${NEW_REPOTAG_CHECK_PHASE}
                fi
                ;;            
            ${NEW_REPOTAG_CHECK_PHASE})
                #Check if Repository:Tag pair is Unique
                repoTag_isUniq=`checkIf_repoTag_isUniq__func "${docker__repo_new}" "${docker__tag_new}"`
                if [[ ${repoTag_isUniq} == false ]]; then
                    show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_CHOSEN_REPO_PAIR_ALREADY_EXISTS}" \
                            "${DOCKER__NUMOFLINES_1}" \
                            "${DOCKER__TIMEOUT_10}" \
                            "${DOCKER__NUMOFLINES_1}" \
                            "${DOCKER__NUMOFLINES_2}"

                    phase=${NEW_TAG_INPUT_PHASE}
                else
                    phase=${CREATE_IMAGE_PHASE}
                fi
                ;;
            ${CREATE_IMAGE_PHASE})
                #In this subroutine variable 'docker__myAnswer' will be updated.
                #Possible output:
                #   - yes
                #   - no
                #   - redo
                docker__create_image_exec__sub
                if [[ ${docker__myAnswer} == ${DOCKER__REDO} ]]; then
                    docker__myAnswer=${DOCKER__EMPTYSTRING}

                    phase=${IMAGEID_SELECT_PHASE}
                else
                    break
                fi
                ;;
        esac
    done
}

docker__create_image_exec__sub() {
    #Define constants
    local ECHOMSG_CREATING_IMAGE="Creating image..."
    local ECHOMSG_LOCATION_DOCKERFILE="${DOCKER__FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR} docker-file: "

    #Define variables
    local echomsg="${ECHOMSG_LOCATION_DOCKERFILE}${docker__docker_dockerfiles__dir}"

    #Create image
    while true
    do
        #Show read-input message
        read -N1 -p "${DOCKER__READDIALOG_DO_YOU_WISH_TO_CONTINUE_YNR}" docker__myAnswer
        
        #Validate read-input answer
        if [[ ${docker__myAnswer} == ${DOCKER__ENTER} ]]; then
             moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        elif [[ ${docker__myAnswer} == ${DOCKER__YES} ]]; then
            #Create directory if NOT exist yet
            if [[ ! -d ${docker__docker_dockerfiles__dir} ]]; then
                mkdir -p ${docker__docker_dockerfiles__dir}
            fi
            
            #Print empty line
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_3}"

            #Show start
            echo "---${DOCKER__FG_ORANGE}START${DOCKER__NOCOLOR}: ${ECHOMSG_CREATING_IMAGE}"

            #Generate a 'dockerfile' with content
            #OUTPUT: docker__dockerfile_autogen_fpath
            docker__create_dockerfile__sub "${docker__dockerfile_auto_filename}" ${docker__repo_new} "${docker__docker_dockerfiles__dir}"

            #Execute command
            docker build --tag ${docker__repo_new}:${docker__tag_new} - < ${docker__dockerfile_autogen_fpath}
            
            #Remove command-output (which containing 'sha256...')
            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            #Show completed
            echo "---${DOCKER__FG_ORANGE}COMPLETED${DOCKER__NOCOLOR}: ${ECHOMSG_CREATING_IMAGE}"

            # #Print empty line
            # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            # #Show Docker Image List
            # show_repoList_or_containerList_w_menuTitle__func "${DOCKER__MENUTITLE_UPDATED_REPOSITORYLIST}" "${docker__images_cmd}"

            #Show repo-list
            show_repoList_or_containerList_w_menuTitle_w_confirmation__func "${DOCKER__MENUTITLE_UPDATED_REPOSITORYLIST}" \
                                "${DOCKER__ERRMSG_NO_IMAGES_FOUND}" \
                                "${docker__images_cmd}" \
                                "${DOCKER__NUMOFLINES_2}" \
                                "${DOCKER__TIMEOUT_10}" \
                                "${DOCKER__NUMOFLINES_0}" \
                                "${DOCKER__NUMOFLINES_0}"
                                            
            #Exit this script
            exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_1}"
        elif [[ ${docker__myAnswer} == ${DOCKER__NO} ]]; then
            exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_2}"
        elif [[ ${docker__myAnswer} == ${DOCKER__REDO} ]]; then
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_3}"

            break
        else
            moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"    
                                                                                                                           
        fi
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



#---MAIN SUBROUTINE
main_sub() {
    docker__load_environment_variables__sub

    docker__load_source_files__sub

    docker__load_header__sub

    docker__init_variables__sub

    docker__cleanup_dockerfiles__sub

    docker__create_image_handler__sub
}



#---EXECUTE
main_sub

