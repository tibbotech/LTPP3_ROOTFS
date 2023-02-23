#!/bin/bash -m
#Remark: by using '-m' the INTERRUPT executed here will NOT propagate to the UPPERLAYER scripts
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
docker__get_source_fullpath__sub() {
    #Define constants
    local DOCKER__PHASE_CHECK_CACHE=1
    local DOCKER__PHASE_FIND_PATH=10
    local DOCKER__PHASE_EXIT=100

    #Define variables
    local docker__phase=""

    local docker__current_dir=
    local docker__tmp_dir=""

    local docker__development_tools__foldername=""
    local docker__LTPP3_ROOTFS__foldername=""
    local docker__global__filename=""
    local docker__parentDir_of_LTPP3_ROOTFS__dir=""

    local docker__mainmenu_path_cache__filename=""
    local docker__mainmenu_path_cache__fpath=""

    local docker__find_dir_result_arr=()
    local docker__find_dir_result_arritem=""
    local docker__find_dir_result_arrlen=0
    local docker__find_dir_result_arrlinectr=0
    local docker__find_dir_result_arrprogressperc=0

    local docker__path_of_development_tools_found=""
    local docker__parentpath_of_development_tools=""

    local docker__isfound=""

    #Set variables
    docker__phase="${DOCKER__PHASE_CHECK_CACHE}"
    docker__current_dir=$(dirname $(readlink -f $0))
    docker__tmp_dir=/tmp
    docker__development_tools__foldername="development_tools"
    docker__global__filename="docker_global.sh"
    docker__LTPP3_ROOTFS__foldername="LTPP3_ROOTFS"

    docker__mainmenu_path_cache__filename="docker__mainmenu_path.cache"
    docker__mainmenu_path_cache__fpath="${docker__tmp_dir}/${docker__mainmenu_path_cache__filename}"

    docker_result=false

    #Start loop
    while true
    do
        case "${docker__phase}" in
            "${DOCKER__PHASE_CHECK_CACHE}")
                if [[ -f "${docker__mainmenu_path_cache__fpath}" ]]; then
                    #Get the directory stored in cache-file
                    docker__LTPP3_ROOTFS_development_tools__dir=$(awk 'NR==1' "${docker__mainmenu_path_cache__fpath}")

                    #Move one directory up
                    docker__parentpath_of_development_tools=$(dirname "${docker__LTPP3_ROOTFS_development_tools__dir}")

                    #Check if 'development_tools' is in the 'LTPP3_ROOTFS' folder
                    docker__isfound=$(docker__checkif_paths_are_related "${docker__current_dir}" \
                            "${docker__parentpath_of_development_tools}" "${docker__LTPP3_ROOTFS__foldername}")
                    if [[ ${docker__isfound} == false ]]; then
                        docker__phase="${DOCKER__PHASE_FIND_PATH}"
                    else
                        docker_result=true

                        docker__phase="${DOCKER__PHASE_EXIT}"
                    fi
                else
                    docker__phase="${DOCKER__PHASE_FIND_PATH}"
                fi
                ;;
            "${DOCKER__PHASE_FIND_PATH}")   
                #Print
                echo -e "---:\e[30;38;5;215mSTART\e[0;0m: find path of folder \e[30;38;5;246m'${docker__development_tools__foldername}\e[0;0m : \e[1;33mDONE\e[0;0m"

                #Reset variable
                docker__LTPP3_ROOTFS_development_tools__dir=""

                #Start loop
                while true
                do
                    #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
                    #... and read to array 'find_result_arr'
                    readarray -t docker__find_dir_result_arr < <(find  / -type d -iname "${docker__LTPP3_ROOTFS__foldername}" 2> /dev/null)

                    #Get array-length
                    docker__find_dir_result_arrlen=${#docker__find_dir_result_arr[@]}

                    #Iterate thru each array-item
                    for docker__find_dir_result_arritem in "${docker__find_dir_result_arr[@]}"
                    do
                        docker__isfound=$(docker__checkif_paths_are_related "${docker__current_dir}" \
                                "${docker__find_dir_result_arritem}"  "${docker__LTPP3_ROOTFS__foldername}")
                        if [[ ${docker__isfound} == true ]]; then
                            #Update variable 'docker__path_of_development_tools_found'
                            docker__path_of_development_tools_found="${docker__find_dir_result_arritem}/${docker__development_tools__foldername}"

                            # #Increment counter
                            docker__find_dir_result_arrlinectr=$((docker__find_dir_result_arrlinectr+1))

                            #Calculate the progress percentage value
                            docker__find_dir_result_arrprogressperc=$(( docker__find_dir_result_arrlinectr*100/docker__find_dir_result_arrlen ))

                            #Moveup and clean
                            if [[ ${docker__find_dir_result_arrlinectr} -gt 1 ]]; then
                                tput cuu1
                                tput el
                            fi

                            #Print
                            #Note: do not print the '100%'
                            if [[ ${docker__find_dir_result_arrlinectr} -lt ${docker__find_dir_result_arrlen} ]]; then
                                echo -e "------:PROGRESS: ${docker__find_dir_result_arrprogressperc}%"
                            fi

                            #Check if 'directory' exist
                            if [[ -d "${docker__path_of_development_tools_found}" ]]; then    #directory exists
                                #Update variable
                                #Remark:
                                #   'docker__LTPP3_ROOTFS_development_tools__dir' is a global variable.
                                #   This variable will be passed 'globally' to script 'docker_global.sh'.
                                docker__LTPP3_ROOTFS_development_tools__dir="${docker__path_of_development_tools_found}"

                                #Print
                                #Note: print the '100%' here
                                echo -e "------:PROGRESS: 100%"

                                break
                            fi
                        fi
                    done

                    #Check if 'docker__LTPP3_ROOTFS_development_tools__dir' contains any data
                    if [[ -z "${docker__LTPP3_ROOTFS_development_tools__dir}" ]]; then  #contains no data
                        echo -e "\r"
                        echo -e "***\e[1;31mERROR\e[0;0m: folder \e[30;38;5;246m${docker__development_tools__foldername}\e[0;0m: \e[30;38;5;131mNot Found\e[0;0m"
                        echo -e "\r"

                         #Update variable
                        docker_result=false
                    else    #contains data
                        #Print
                        echo -e "---:\e[30;38;5;215mCOMPLETED\e[0;0m: find path of folder \e[30;38;5;246m'${docker__development_tools__foldername}\e[0;0m : \e[1;33mDONE\e[0;0m"


                        #Write to file
                        echo "${docker__LTPP3_ROOTFS_development_tools__dir}" | tee "${docker__mainmenu_path_cache__fpath}" >/dev/null

                        #Print
                        echo -e "---:\e[30;38;5;215mSTATUS\e[0;0m: write path to temporary cache-file: \e[1;33mDONE\e[0;0m"

                        #Update variable
                        docker_result=true
                    fi

                    #set phase
                    docker__phase="${DOCKER__PHASE_EXIT}"

                    #Exit loop
                    break
                done
                ;;    
            "${DOCKER__PHASE_EXIT}")
                break
                ;;
        esac
    done

    #Exit if 'docker_result = false'
    if [[ ${docker_result} == false ]]; then
        exit 99
    fi

    #Retrieve directories
    #Remark:
    #   'docker__LTPP3_ROOTFS__dir' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/
    docker__parentDir_of_LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS__dir%/*}    #move two directories up. This directory is the one-level higher than LTPP3_ROOTFS/

    #Get full-path
    #Remark:
    #   'docker__global__fpath' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__global__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__global__filename}
}
docker__checkif_paths_are_related() {
    #Input args
    local scriptdir__input=${1}
    local finddir__input=${2}
    local pattern__input=${3}

    #Define constants
    local PHASE_PATTERN_CHECK1=1
    local PHASE_PATTERN_CHECK2=10
    local PHASE_PATH_COMPARISON=20
    local PHASE_EXIT=100

    #Define variables
    local phase="${PHASE_PATTERN_CHECK1}"
    local isfound1=""
    local isfound2=""
    local isfound3=""
    local ret=false

    while true
    do
        case "${phase}" in
            "${PHASE_PATTERN_CHECK1}")
                #Check if 'pattern__input' is found in 'scriptdir__input'
                isfound1=$(echo "${scriptdir__input}" | \
                        grep -o "${pattern__input}.*" | \
                        cut -d"/" -f1 | grep -w "^${pattern__input}$")
                if [[ -z "${isfound1}" ]]; then
                    ret=false

                    phase="${PHASE_EXIT}"
                else
                    phase="${PHASE_PATTERN_CHECK2}"
                fi                
                ;;
            "${PHASE_PATTERN_CHECK2}")
                #Check if 'pattern__input' is found in 'finddir__input'
                isfound2=$(echo "${finddir__input}" | \
                        grep -o "${pattern__input}.*" | \
                        cut -d"/" -f1 | grep -w "^${pattern__input}$")
                if [[ -z "${isfound2}" ]]; then
                    ret=false

                    phase="${PHASE_EXIT}"
                else
                    phase="${PHASE_PATH_COMPARISON}"
                fi                
                ;;
            "${PHASE_PATH_COMPARISON}")
                #Check if 'development_tools' is under the folder 'LTPP3_ROOTFS'
                isfound3=$(echo "${scriptdir__input}" | \
                        grep -w "${finddir__input}.*")
                if [[ -z "${isfound3}" ]]; then
                    ret=false
                else
                    ret=true
                fi

                phase="${PHASE_EXIT}"
                ;;
            "${PHASE_EXIT}")
                break
                ;;
        esac
    done

    #Output
    echo "${ret}"

    return 0
}
docker__load_global_fpath_paths__sub() {
    source ${docker__global__fpath}
}

docker__init_variables__sub() {
    docker__containerID_chosen=${DOCKER__EMPTYSTRING}
    docker__myAnswer=${DOCKER__NO}
    docker__repo_new=${DOCKER__EMPTYSTRING}
    docker__tag_new=${DOCKER__EMPTYSTRING}

    # docker__images_cmd="docker images"
    # docker__ps_a_cmd="docker ps -a"

    # docker__ps_a_containerIdColno=1
    # docker__images_repoColNo=1
    # docker__images_tagColNo=2

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

    local READMSG_CHOOSE_A_CONTAINERID="Choose a ${DOCKER__FG_BRIGHTPRUPLE}Container-ID${DOCKER__NOCOLOR} (e.g. dfc5e2f3f7ee): "
    local READMSG_NEW_REPOSITORY_NAME="${DOCKER__FG_YELLOW}New${DOCKER__NOCOLOR} ${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR}'s name (e.g. ubuntu_buildbin_NEW): "
    local READMSG_NEW_REPOSITORY_TAG="${DOCKER__FG_YELLOW}New${DOCKER__NOCOLOR} ${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} (e.g. test): "

    local ERRMSG_CHOSEN_REPO_PAIR_ALREADY_EXISTS="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: chosen ${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR}:${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} pair already exists"
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
                        "${DOCKER__ERRMSG_NO_CONTAINERS_FOUND}" \
                        "${ERRMSG_NONEXISTING_VALUE}" \
                        "${docker__ps_a_cmd}" \
                        "${docker__ps_a_containerIdColno}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${docker__showTable}" \
                        "${docker__onEnter_breakLoop}" \
                        "${DOCKER__NUMOFLINES_2}"

                #Get the exit-code just in case:
                #   1. Ctrl-C was pressed in script 'docker__readInput_w_autocomplete__fpath'.
                #   2. An error occured in script 'docker__readInput_w_autocomplete__fpath',...
                #      ...and exit-code = 99 came from function...
                #      ...'show_msg_w_menuTitle_w_pressAnyKey_w_ctrlC_func' (in script: docker__global.sh).
                docker__exitCode=$?
                if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
                    exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_0}"
                else
                    #Get the result
                    docker__containerID_chosen=`get_output_from_file__func \
                                    "${docker__readInput_w_autocomplete_out__fpath}" \
                                    "${DOCKER__LINENUM_1}"`
                fi  

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
                        "${DOCKER__ERRMSG_NO_IMAGES_FOUND}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${docker__images_cmd}" \
                        "${docker__images_repoColNo}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${docker__showTable}" \
                        "${docker__onEnter_breakLoop}" \
                        "${DOCKER__NUMOFLINES_1}"

                #Get the exit-code just in case:
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
                #Run script
                ${docker__readInput_w_autocomplete__fpath} "${MENUTITLE_CURRENT_IMAGE_LIST}" \
                        "${READMSG_NEW_REPOSITORY_TAG}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${readmsg_remarks}" \
                        "${DOCKER__ERRMSG_NO_IMAGES_FOUND}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${docker__images_cmd}" \
                        "${docker__images_tagColNo}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${docker__showTable}" \
                        "${docker__onEnter_breakLoop}" \
                        "${DOCKER__NUMOFLINES_1}"

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
                docker__create_image_exec__sub "${docker__containerID_chosen}" "${docker__repo_new}" "${docker__tag_new}"
                if [[ ${docker__myAnswer} == ${DOCKER__REDO} ]]; then
                    docker__myAnswer=${DOCKER__EMPTYSTRING}

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

    #Create image
    while true
    do
        #Show read-input message
        read -N1 -p "${DOCKER__READDIALOG_DO_YOU_WISH_TO_CONTINUE_YNR}" docker__myAnswer
        
        #Validate read-input answer
        if [[ ${docker__myAnswer} == ${DOCKER__ENTER} ]]; then
             moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        elif [[ ${docker__myAnswer} == ${DOCKER__YES} ]]; then
            #Print empty line
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_3}"

            #Show start
            echo "---${DOCKER__FG_ORANGE}START${DOCKER__NOCOLOR}: ${ECHOMSG_CREATING_IMAGE}"

            #Create Docker Image based on chosen Container-ID                
            docker commit ${docker__containerID_chosen} ${docker__repo_new}:${docker__tag_new}

            #Remove command-output (which containing 'sha256...')
            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            #Show completed
            echo "---${DOCKER__FG_ORANGE}COMPLETED${DOCKER__NOCOLOR}: ${ECHOMSG_CREATING_IMAGE}"

            # #Print empty line
            # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

            # #Show Docker Image List
            # show_repoList_or_containerList_w_menuTitle__func "${DOCKER__MENUTITLE_UPDATED_REPOSITORYLIST}" "${docker__images_cmd}"

            #Show repo-list
            show_repoList_or_containerList_w_menuTitle_w_confirmation__func "${DOCKER__MENUTITLE_UPDATED_REPOSITORYLIST}" \
                                "${DOCKER__ERRMSG_NO_IMAGES_FOUND}" \
                                "${docker__images_cmd}" \
                                "${DOCKER__NUMOFLINES_0}" \
                                "${DOCKER__TIMEOUT_10}" \
                                "${DOCKER__NUMOFLINES_0}" \
                                "${DOCKER__NUMOFLINES_0}" \
                                "${DOCKER__NUMOFLINES_2}"
                                            
            #Exit this script
            exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_0}"
        elif [[ ${docker__myAnswer} == ${DOCKER__NO} ]]; then
            exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_2}"
        elif [[ ${docker__myAnswer} == ${DOCKER__REDO} ]]; then
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            break
        else
            moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"                                                                                               
        fi
    done
}



#---MAIN SUBROUTINE
main_sub() {
    docker__get_source_fullpath__sub

    docker__load_global_fpath_paths__sub

    docker__init_variables__sub

    docker__create_image_handler__sub
}



#---EXECUTE
main_sub
