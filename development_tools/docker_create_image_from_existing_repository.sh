#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---NUMERIC CONSTANTS
DOCKER__NUMOF_FILES_TOBE_KEPT_MAX=100



#---FUNCTIONS
function checkIf_repoTag_isUniq__func() {
    #Input args
    local repoName__input=${1}
    local tag__input=${2}

    #Define variables
    local dataArr=()
    local dataArr_item=${DOCKER__EMPTYSTRING}
    local stdOutput1=${DOCKER__EMPTYSTRING}
    local stdOutput2=${DOCKER__EMPTYSTRING}

    #Write 'docker images' command output to array
    readarray dataArr <<< $(docker images)

    #Check if repository:tag is unique
    local ret=true

    for dataArr_item in "${dataArr[@]}"
    do                                                      
        stdOutput1=`echo ${dataArr_item} | awk '{print $1}' | grep -w "${repoName__input}"`
        if [[ ! -z ${stdOutput1} ]]; then
            stdOutput2=`echo ${dataArr_item} | awk '{print $2}' | grep -w "${tag__input}"`
            if [[ ! -z ${stdOutput2} ]]; then
                ret=false

                break
            fi
        fi                                             
    done

    #Output
    echo "${ret}"
}



#---SUBROUTINES
docker__load_environment_variables__sub() {
    #Define paths
    docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})
    docker__parent_dir=${docker__current_dir%/*}    #go one directory up (LTPP3_ROOTFS/)
    if [[ -z ${docker__parent_dir} ]]; then
        docker__parent_dir="${DOCKER__SLASH_CHAR}"
    fi
    docker__current_folder=`basename ${docker__current_dir}`

    docker__xxx_repo_dir=${docker__parent_dir%/*}    #go one directory up (e.g. repo/)
    docker__xxx_docker_dockerfiles_dir=${docker__xxx_repo_dir}/docker/dockerfiles
    docker__dockerfile_auto_filename="dockerfile_auto"
    docker__dockerfile_autogen_fpath=${DOCKER__EMPTYSTRING}

    docker__development_tools_folder="development_tools"
    if [[ ${docker__current_folder} != ${docker__development_tools_folder} ]]; then
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}/${docker__development_tools_folder}
    else
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}
    fi

    docker__global__filename="docker_global.sh"
    docker__global__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global__filename}
}

docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

docker__load_header__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${DOCKER__BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__init_variables__sub() {
    docker__imageID_chosen=${DOCKER__EMPTYSTRING}
    docker__repo_chosen=${DOCKER__EMPTYSTRING}
    docker__tag_chosen=${DOCKER__EMPTYSTRING}
    docker__repo_new=${DOCKER__EMPTYSTRING}

    docker__images_cmd="docker images"

    docker__images_repoColNo=1
    docker__images_tagColNo=2
    docker__images_IDColNo=3

    docker__onEnter_breakLoop=false
    docker__showTable=true
}

docker__cleanup_dockerfiles__sub() {
    #Get number of files in directory: <home>/repo/docker/dockerfiles
    local numOf_files=`ls -1ltr ${docker__xxx_docker_dockerfiles_dir} | grep "^-" | wc -l`

    #MESSAGE CONSTANTS
    local ECHOMSG_MAX_NUMOF_FILES_EXCEEDED="Maximum number of files exceeded (${DOCKER__FG_LIGHTGREY}${numOf_files}${DOCKER__NOCOLOR} out-of ${DOCKER__FG_LIGHTGREY}${DOCKER__NUMOF_FILES_TOBE_KEPT_MAX}${DOCKER__NOCOLOR})"
    local ECHOMSG_DELETING_FILES="Deleting files..."


    #Check if 'numOf_files' has exceeded 'DOCKER__NUMOF_FILES_TOBE_KEPT_MAX'
    if [[ ${numOf_files} -gt ${DOCKER__NUMOF_FILES_TOBE_KEPT_MAX} ]]; then
        #Print warning
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "---${DOCKER__FG_LIGHTRED}WARNING${DOCKER__NOCOLOR}: ${ECHOMSG_MAX_NUMOF_FILES_EXCEEDED}"
        echo -e "---${DOCKER__FG_LIGHTSOFTYELLOW}LOCATION${DOCKER__NOCOLOR}: ${docker__xxx_docker_dockerfiles_dir}"
        echo -e "---${DOCKER__FG_ORANGE}START${DOCKER__NOCOLOR}: ${ECHOMSG_DELETING_FILES}"

        #Number of files exceeding
        local numOf_files_exceeded=$((numOf_files-DOCKER__NUMOF_FILES_TOBE_KEPT_MAX))

        #Put all files in array 'filesArr'
        local filesArr=()
        readarray filesArr <<< $(ls -1ltr ${docker__xxx_docker_dockerfiles_dir} | grep "^-" | awk '{print $9}')

        #Initialization
        local numof_files_deleted=0
        
        #Start deleting files (oldest first)
        local filesArr_item=${DOCKER__EMPTYSTRING}
        local dockerfile_fpath=${DOCKER__EMPTYSTRING}
        for filesArr_item in "${filesArr[@]}"
        do                         
            #Update variable
            dockerfile_fpath=${docker__xxx_docker_dockerfiles_dir}/${filesArr_item}  

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
    if [[ ! -d ${docker__xxx_docker_dockerfiles_dir} ]]; then
        mkdir -p ${docker__xxx_docker_dockerfiles_dir}
    fi

    #Generate timestamp
    local dockerfile_autogen_filename=${docker__dockerfile_auto_filename}_${docker__repo_new}

    #Define filename
    docker__dockerfile_autogen_fpath=${docker__xxx_docker_dockerfiles_dir}/${dockerfile_autogen_filename}

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
    local NEW_REPOTAG_CHECK_PHASE=3
    local CREATE_IMAGE_PHASE=4

    #Define message constants
    local MENUTITLE="Create an ${DOCKER__FG_BORDEAUX}Image${DOCKER__NOCOLOR} from a ${DOCKER__FG_PURPLE}Repository${DOCKER__NOCOLOR}"
    local MENUTITLE_UPDATED_IMAGE_LIST="Updated ${DOCKER__FG_BORDEAUX}Image${DOCKER__NOCOLOR}-list"

    local READMSG_CHOOSE_IMAGEID_FROM_LIST="Choose an ${DOCKER__FG_BORDEAUX}Image-ID${DOCKER__NOCOLOR} from list (e.g. 0f7478cf7cab): "
    local READMSG_NEW_REPOSITORY_NAME="${DOCKER__FG_YELLOW}New${DOCKER__NOCOLOR} ${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR}'s name (e.g. ubuntu_buildbin_NEW): "
    local READMSG_NEW_REPOSITORY_TAG="${DOCKER__FG_YELLOW}New${DOCKER__NOCOLOR} ${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} (e.g. test): "

    local ERRMSG_CHOSEN_IMAGEID_DOESNOT_EXISTS="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: chosen ${DOCKER__FG_BORDEAUX}Image-ID${DOCKER__NOCOLOR} does NOT exist"
    local ERRMSG_CHOSEN_REPO_PAIR_ALREADY_EXISTS="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: chosen ${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR}:${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} pair already exists"
    local ERRMSG_NO_IMAGES_FOUND="=:${DOCKER__FG_LIGHTRED}NO IMAGES FOUND${DOCKER__NOCOLOR}:="
    local ERRMSG_NONUNIQUE_INPUT_VALUE="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: non-unique input value "

    #Define variables
    local errMsg=${DOCKER__EMPTYSTRING}
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
                            "${READMSG_CHOOSE_IMAGEID_FROM_LIST}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${readmsg_remarks}" \
                            "${ERRMSG_NO_IMAGES_FOUND}" \
                            "${ERRMSG_CHOSEN_IMAGEID_DOESNOT_EXISTS}" \
                            "${docker__images_cmd}" \
                            "${docker__images_IDColNo}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${docker__showTable}" \
                            "${docker__onEnter_breakLoop}"

                #Retrieve the selected container-ID from file
                docker__imageID_chosen=`get_output_from_file__func "${docker__readInput_w_autocomplete_out__fpath}" "1"`

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
                            "${ERRMSG_NO_IMAGES_FOUND}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${docker__images_cmd}" \
                            "${docker__images_repoColNo}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${docker__showTable}" \
                            "${docker__onEnter_breakLoop}"

                #Retrieve the selected container-ID from file
                docker__repo_new=`get_output_from_file__func "${docker__readInput_w_autocomplete_out__fpath}" "1"`

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
                            "${ERRMSG_NO_IMAGES_FOUND}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${docker__images_cmd}" \
                            "${docker__images_tagColNo}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${docker__showTable}" \
                            "${docker__onEnter_breakLoop}"
            
                #Retrieve the selected container-ID from file
                docker__tag_new=`get_output_from_file__func "${docker__readInput_w_autocomplete_out__fpath}" "1"`

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
                    show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_CHOSEN_REPO_PAIR_ALREADY_EXISTS}" "${DOCKER__NUMOFLINES_2}"

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
    local READMSG_DO_YOU_WISH_TO_CONTINUE="Do you wish to continue (y/n/r)? "

    #Define variables
    local echomsg="${ECHOMSG_LOCATION_DOCKERFILE}${docker__xxx_docker_dockerfiles_dir}"

    #Create image
    while true
    do
        #Show read-input message
        read -N1 -p "${READMSG_DO_YOU_WISH_TO_CONTINUE}" docker__myAnswer
        
        #Validate read-input answer
        if [[ ${docker__myAnswer} == ${DOCKER__ENTER} ]]; then
             moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        elif [[ ${docker__myAnswer} == ${DOCKER__YES} ]]; then
            #Create directory if NOT exist yet
            if [[ ! -d ${docker__xxx_docker_dockerfiles_dir} ]]; then
                mkdir -p ${docker__xxx_docker_dockerfiles_dir}
            fi
            
            #Print empty line
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            #Show start
            echo "---${DOCKER__FG_ORANGE}START${DOCKER__NOCOLOR}: ${ECHOMSG_CREATING_IMAGE}"

            #Generate a 'dockerfile' with content
            #OUTPUT: docker__dockerfile_autogen_fpath
            docker__create_dockerfile__sub "${docker__dockerfile_auto_filename}" ${docker__repo_new} "${docker__xxx_docker_dockerfiles_dir}"

            #Execute command
            docker build --tag ${docker__repo_new}:${docker__tag_new} - < ${docker__dockerfile_autogen_fpath}
            
            #Remove command-output (which containing 'sha256...')
            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            #Show completed
            echo "---${DOCKER__FG_ORANGE}COMPLETED${DOCKER__NOCOLOR}: ${ECHOMSG_CREATING_IMAGE}"

            #Print empty line
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            #Show Docker Image List
            show_cmdOutput_w_menuTitle__func "${MENUTITLE_UPDATED_IMAGE_LIST}" "${docker__images_cmd}"
            
            #Exit this script
            exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_0}"
        elif [[ ${docker__myAnswer} == ${DOCKER__NO} ]]; then
            exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_0}"
        elif [[ ${docker__myAnswer} == ${DOCKER__REDO} ]]; then
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

            break
        else
            moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"    
                                                                                                                           
        fi
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
    docker__load_environment_variables__sub

    docker__load_source_files__sub

    docker__load_header__sub

    docker__init_variables__sub

    docker__cleanup_dockerfiles__sub

    docker__create_image_handler__sub
}



#---EXECUTE
main_sub

