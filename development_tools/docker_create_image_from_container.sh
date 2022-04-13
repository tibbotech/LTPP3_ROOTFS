#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
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
docker__environmental_variables__sub() {
	# docker__current_dir=`pwd`
	docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})	#/repo/LTPP3_ROOTFS/development_tools
	docker__parent_dir=${docker__current_dir%/*}    #gets one directory up (/repo/LTPP3_ROOTFS)
    if [[ -z ${docker__parent_dir} ]]; then
        docker__parent_dir="${DOCKER__SLASH}"
    fi
	docker__current_folder=`basename ${docker__current_dir}`

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
    docker__containerID_chosen=${DOCKER__EMPTYSTRING}
    docker__myAnswer=${DOCKER__NO}
    docker__repo_new=${DOCKER__EMPTYSTRING}
    docker__tag_new=${DOCKER__EMPTYSTRING}

    docker__images_cmd="docker images"
    docker__ps_a_cmd="docker ps -a"

    docker__ps_a_containerIdColno=1
    docker__images_repoColNo=1
    docker__images_tagColNo=2

    docker__onEnter_breakLoop=false
    docker__showTable=true
}

docker__create_image_handler__sub() {
    #Define phase constants
    local CONTAINERID_SELECT_PHASE=0
    local NEW_REPO_INPUT_PHASE=1
    local NEW_TAG_INPUT_PHASE=2
    local NEW_REPOTAG_CHECK_PHASE=3
    local CREATE_IMAGE_PHASE=4

    #Define message constants
    local HORIZONTAL_LINE="---------------------------------------------------------------------"
    local MENUTITLE="Create an ${DOCKER__FG_BORDEAUX}Image${DOCKER__NOCOLOR} from a ${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}"
    local MENUTITLE_CURRENT_IMAGE_LIST="Current ${DOCKER__FG_BORDEAUX}Image${DOCKER__NOCOLOR}-list"
    local MENUTITLE_UPDATED_IMAGE_LIST="Updated ${DOCKER__FG_BORDEAUX}Image${DOCKER__NOCOLOR}-list"

    local READMSG_CHOOSE_A_CONTAINERID="Choose a ${DOCKER__FG_BRIGHTPRUPLE}Container-ID${DOCKER__NOCOLOR} (e.g. dfc5e2f3f7ee): "
    local READMSG_NEW_REPOSITORY_NAME="${DOCKER__FG_YELLOW}New${DOCKER__NOCOLOR} ${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR}'s name (e.g. ubuntu_buildbin_NEW): "
    local READMSG_NEW_REPOSITORY_TAG="${DOCKER__FG_YELLOW}New${DOCKER__NOCOLOR} ${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} (e.g. test): "

    local ERRMSG_CHOSEN_REPO_PAIR_ALREADY_EXISTS="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: chosen ${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR}:${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} pair already exists"
    local ERRMSG_NO_CONTAINERS_FOUND="=:${DOCKER__FG_LIGHTRED}NO CONTAINERS FOUND${DOCKER__NOCOLOR}:="
    local ERRMSG_NO_IMAGES_FOUND="=:${DOCKER__FG_LIGHTRED}NO IMAGES FOUND${DOCKER__NOCOLOR}:="
    local ERRMSG_NONEXISTING_VALUE="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: non-existing input value "

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
    phase=${CONTAINERID_SELECT_PHASE}
    while true
    do
        case "${phase}" in
            ${CONTAINERID_SELECT_PHASE})
                #Run script
                ${docker__readInput_w_autocomplete__fpath} "${MENUTITLE}" \
                        "${READMSG_CHOOSE_A_CONTAINERID}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${readmsg_remarks}" \
                        "${ERRMSG_NO_CONTAINERS_FOUND}" \
                        "${ERRMSG_NONEXISTING_VALUE}" \
                        "${docker__ps_a_cmd}" \
                        "${docker__ps_a_containerIdColno}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${docker__showTable}" \
                        "${docker__onEnter_breakLoop}"
                                    


                #Retrieve the selected container-ID from file
                docker__containerID_chosen=`get_output_from_file__func "${docker__readInput_w_autocomplete_out__fpath}" "1"`

                #Check if output is an Empty String
                if [[ -z ${docker__containerID_chosen} ]]; then
                    return
                else
                    phase=${NEW_REPO_INPUT_PHASE}
                fi
                ;;
            ${NEW_REPO_INPUT_PHASE})
                #Run script
                ${docker__readInput_w_autocomplete__fpath} "${MENUTITLE_CURRENT_IMAGE_LIST}" \
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
                #Run script
                ${docker__readInput_w_autocomplete__fpath} "${MENUTITLE_CURRENT_IMAGE_LIST}" \
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
                docker__create_image_exec__sub "${docker__containerID_chosen}" "${docker__repo_new}" "${docker__tag_new}"
                if [[ ${docker__myAnswer} == ${DOCKER__REDO} ]]; then
                    phase=${CONTAINERID_SELECT_PHASE}
                else
                    break
                fi
                ;;
        esac
    done
}
docker__create_image_exec__sub() {
    #Input args
    local containerID__input=${1}
    local repoName__input=${2}
    local tag__input=${3}

    #Define constants
    local ECHOMSG_CREATING_IMAGE="Creating image..."
    local READMSG_DO_YOU_WISH_TO_CONTINUE="Do you wish to continue (y/n/r)? "

    #Create image
    while true
    do
        #Show read-input message
        read -N1 -p "${READMSG_DO_YOU_WISH_TO_CONTINUE}" docker__myAnswer
        
        #Validate read-input answer
        if [[ ${docker__myAnswer} == ${DOCKER__ENTER} ]]; then
             moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        elif [[ ${docker__myAnswer} == ${DOCKER__YES} ]]; then
            #Print empty line
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            #Show start
            echo "---${DOCKER__FG_ORANGE}START${DOCKER__NOCOLOR}: ${ECHOMSG_CREATING_IMAGE}"

            #Create Docker Image based on chosen Container-ID                
            docker commit ${docker__containerID_chosen} ${docker__repo_new}:${docker__tag_new}

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



#---MAIN SUBROUTINE
main_sub() {
    docker__environmental_variables__sub

    docker__load_source_files__sub

    docker__load_header__sub

    docker__init_variables__sub

    docker__create_image_handler__sub
}



#---EXECUTE
main_sub
