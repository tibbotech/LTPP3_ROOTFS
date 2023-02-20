#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts

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
docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

docker__init_variables__sub() {
    docker__myImageId=""
    docker__myImageId_input=""
    docker__myImageId_subst=""
    docker__myImageId_arr=()
    docker__myImageId_item=""
    docker__myImageId_isFound=""
    docker__myAnswer=""
    docker__repo_chosen=""
    docker__tag_chosen=""

    docker__totNumOfLines=0

    docker__exitCode=0

    # docker__images_cmd="docker image ls"
    # docker__images_IDColNo=3

    docker__showTable=false
    docker__onEnter_breakLoop=true
}

docker__get_and_check_repoTag__sub() {
    #Input args
    local imageID__input=${1}

    #Define message constants
    local ERRMSG_NO_REPO_FOUND="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: "
    ERRMSG_NO_REPO_FOUND+="No matching ${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR} "
    ERRMSG_NO_REPO_FOUND+="found for ${DOCKER__FG_BORDEAUX}ID${DOCKER__NOCOLOR} "
    ERRMSG_NO_REPO_FOUND+=="'${DOCKER__FG_LIGHTGREY}${imageID__input}${DOCKER__NOCOLOR}'"

    local ERRMSG_NO_TAG_FOUND="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: "
    ERRMSG_NO_TAG_FOUND+="No matching ${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} "
    ERRMSG_NO_TAG_FOUND+="found for ${DOCKER__FG_BORDEAUX}ID${DOCKER__NOCOLOR} "
    ERRMSG_NO_TAG_FOUND+="'${DOCKER__FG_LIGHTGREY}${imageID__input}${DOCKER__NOCOLOR}'"

    local ERRMSG_NO_REPO_TAG_FOUND="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: "
    ERRMSG_NO_REPO_TAG_FOUND+="No matching ${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR} "
    ERRMSG_NO_REPO_TAG_FOUND+="and ${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} "
    ERRMSG_NO_REPO_TAG_FOUND+="found for ${DOCKER__FG_BORDEAUX}ID${DOCKER__NOCOLOR} "
    ERRMSG_NO_REPO_TAG_FOUND+="'${DOCKER__FG_LIGHTGREY}${imageID__input}${DOCKER__NOCOLOR}'"

    #Get repository
    docker__repo_chosen=`${docker__images_cmd} | grep -w ${imageID__input} | awk -vcolNo=${docker__images_repoColNo} '{print $colNo}'`

    #Get tag
    docker__tag_chosen=`${docker__images_cmd} | grep -w ${imageID__input} | awk -vcolNo=${docker__images_tagColNo} '{print $colNo}'`

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

docker__remove_specified_images__sub() {
    #Define message constants
    local READMSG_DO_YOU_REALLY_WISH_TO_CONTINUE="***Do you REALLY wish to continue (${DOCKER__Y_SLASH_N_SLASH_B_SLASH_Q})? "

    #Define local message variables
    local errMsg=${DOCKER__EMPTYSTRING}
    local printMsg=${DOCKER__EMPTYSTRING}
    local numOfLines=${DOCKER__NUMOFLINES_0}

    #Set flag to true
    docker__showTable=true

    #Start loop    
    while true
    do
        #Provide iamge-IDs to be removed
        #Output:
        #1. docker__myImageId
        #2. docker__exitCode:
        #   - default: docker__exitCode = 0
        #   - in case ctrl+C is pressed: docker__exitCode = 99
        docker_imageId_input__sub

        #Check previously (in subroutine 'docker_imageId_input__sub') ctrl+C was pressed.
        if [[ ${docker__exitCode} -eq 99 ]]; then
            break
        else
            #Only clean lines if 'docker__myImageId' is an Empty String
            if [[ -z ${docker__myImageId} ]]; then
                moveUp_and_cleanLines__func "${docker__totNumOfLines}"
            fi
        fi

        #Check if 'docker__myImageId' contains data.
        if [[ ! -z ${docker__myImageId} ]]; then
            #Substitute COMMA with SPACE
            docker__myImageId_subst=`echo ${docker__myImageId} | sed 's/,/\ /g'`

            #Convert to Array
            eval "docker__myImageId_arr=(${docker__myImageId_subst})"

            #Question
            while true
            do
                #Show question
                read -N1 -p "${READMSG_DO_YOU_REALLY_WISH_TO_CONTINUE}" docker__myAnswer

                #Take action based on 'docker__myAnswer' value
                if [[ ! -z ${docker__myAnswer} ]]; then
                    case "${docker__myAnswer}" in
                        "y")
                            if [[ ${docker__myImageId} == ${DOCKER__REMOVE_ALL} ]]; then    #remove-all image-IDs
                                #Remove image-IDs
                                docker rmi $(docker images -q)

                                #Set number of lines
                                # numOfLines=${DOCKER__NUMOFLINES_2}
                            else    #Handle each image-ID at the time
                                #Print Empty Lines
                                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

                                for docker__myImageId_item in "${docker__myImageId_arr[@]}"
                                do 
                                    #Check if 'docker__myImageId_item' is present
                                    docker__myImageId_isFound=`checkForMatch_dockerCmd_result__func "${docker__myImageId_item}" \
                                            "${docker__images_cmd}" \
                                            "${docker__images_IDColNo}"`
                                    if [[ ${docker__myImageId_isFound} == true ]]; then
                                        #Remove selected image-IDs
                                        docker image rmi -f ${docker__myImageId_item}

                                        #Check if 'docker__myImageId_item' has been removed successfully
                                        docker__myImageId_isFound=`checkForMatch_dockerCmd_result__func "${docker__myImageId_item}" \
                                                "${docker__images_cmd}" \
                                                "${docker__images_IDColNo}"`
                                        if [[ ${docker__myImageId_isFound} == false ]]; then
                                            docker__prune_handler__sub "${docker__myImageId_item}" "${DOCKER__NUMOFLINES_1}"
                                        else
                                            #Get the (docker__repo_chosen) and (docker__tag_chosen) for a given (docker__myImageId_item)
                                            docker__get_and_check_repoTag__sub "${docker__myImageId_item}"

                                            #Update message
                                            printMsg="...${DOCKER__BLINK}Attempting${DOCKER__NOCOLOR} to remove "
                                            printMsg+="${DOCKER__FG_PURPLE}Repository${DOCKER__NOCOLOR}:${DOCKER__FG_PINK}Tag${DOCKER__NOCOLOR} "
                                            printMsg+="(${docker__repo_chosen}:${docker__tag_chosen}) instead"

                                            #Print message
                                            show_msg_only__func "${printMsg}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_0}"

                                            #Remove reposity:tag (instead of image)
                                            #Remark:
                                            #   It could be the case that this image (docker__myImageId_item) can NOT be removed,...
                                            #   ...because another image was created which is based on this image (docker__myImageId_item).
                                            #   In other words, this image (docker__myImageId_item) is the PARENT IMAGE.

                                            docker rmi "${docker__repo_chosen}:${docker__tag_chosen}"

                                            #Check again if 'docker__myImageId_item' has been removed successfully
                                            docker__myImageId_isFound=`checkForMatch_dockerCmd_result__func "${docker__myImageId_item}" \
                                                    "${docker__images_cmd}" \
                                                    "${docker__images_IDColNo}"`
                                            if [[ ${docker__myImageId_isFound} == false ]]; then
                                                docker__prune_handler__sub "${docker__myImageId_item}" "${DOCKER__NUMOFLINES_1}"
                                            else                                     
                                                errMsg="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Could *NOT* remove image-ID: ${DOCKER__FG_BORDEAUX}${docker__myImageId_item}${DOCKER__NOCOLOR}"
                                                
                                                show_msg_only__func "${errMsg}" "${DOCKER__NUMOFLINES_1}"
                                            fi
                                        fi
                                    else
                                        #Update error-message
                                        errMsg="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Invalid image-ID '${DOCKER__FG_BORDEAUX}${docker__myImageId_item}${DOCKER__NOCOLOR}'"

                                        show_msg_only__func "${errMsg}" "${DOCKER__NUMOFLINES_1}"
                                    fi
                                done

                                #Set number of lines
                                # numOfLines=${DOCKER__NUMOFLINES_2}
                            fi

                            #Print an Empty Line
                            # moveDown_and_cleanLines__func "${numOfLines}"

                            #Set flag back to true
                            docker__showTable=true

                            #Exit while-loop
                            break
                            ;;
                        "n")
                            moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_5}"

                            break
                            ;;
                        "q")
                            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

                            exit
                            ;;
                        "b")
                            moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_5}"

                            break
                            ;;
                        *)
                            if [[ ${docker__myAnswer} != ${DOCKER__ENTER} ]]; then
                                moveDown_oneLine_then_moveUp_and_clean__func "${DOCKER__NUMOFLINES_1}"
                            else
                                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                            fi
                            ;;
                    esac                                                                                                                                             
                fi
            done
        fi
    done
}
docker_imageId_input__sub() {
    #Define message constants
    local MENUTITLE="Remove ${DOCKER__FG_BORDEAUX}image${DOCKER__NOCOLOR}/${DOCKER__FG_PURPLE}repository${DOCKER__NOCOLOR}"
    local READMSG_PASTE_YOUR_INPUT="Paste your input (here): "

    #Define variables
    local readmsg_remarks="${DOCKER__BG_ORANGE}Remarks:${DOCKER__NOCOLOR}\n"
    readmsg_remarks+="${DOCKER__DASH} Remove ALL image-IDs by typing: ${DOCKER__FG_LIGHTGREY}${DOCKER__REMOVE_ALL}${DOCKER__NOCOLOR}\n"
    readmsg_remarks+="${DOCKER__DASH} Multiple image-IDs can be removed\n"
    readmsg_remarks+="${DOCKER__DASH} Comma-separator will be appended automatically\n"
    readmsg_remarks+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}Up/Down Arrow${DOCKER__NOCOLOR}: to cycle thru existing values\n"
    readmsg_remarks+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}TAB${DOCKER__NOCOLOR}: auto-complete\n"
    readmsg_remarks+="${DOCKER__DASH} ${DOCKER__FG_YELLOW};c${DOCKER__NOCOLOR}: clear\n"
    readmsg_remarks+="${DOCKER__DASH} [On an Empty Field] press ENTER to confirm deletion"

    #Reset variable based on the chosen answer (e.g., n, b)
    if [[ "${docker__myAnswer}" != "${DOCKER__BACK}" ]]; then   #only reset if no 'back' was pressed
        docker__myImageId=${DOCKER__EMPTYSTRING}
    else
        if [[ ${docker__myImageId} == ${DOCKER__REMOVE_ALL} ]]; then
            docker__myImageId=${DOCKER__EMPTYSTRING}
        fi
    fi

    #Initialization
    local isFound=false
    local readmsg_update=${DOCKER__EMPTYSTRING}
    local readMsg_numOfLines=0
    local remarks_numOfLines=0
    local update_numOfLines=0

    #Calculate number of lines to be cleaned
    if [[ ! -z ${READMSG_PASTE_YOUR_INPUT} ]]; then    #this condition is important
        readMsg_numOfLines=`echo -e ${READMSG_PASTE_YOUR_INPUT} | wc -l`      
    fi
    if [[ ! -z ${readmsg_remarks} ]]; then    #this condition is important
        remarks_numOfLines=`echo -e ${readmsg_remarks} | wc -l`      
    fi

    while true
    do
        #Define 'readmsg_update'
        readmsg_update="${DOCKER__BG_BORDEAUX}Remove the following ${DOCKER__FG_WHITE}image-IDs${DOCKER__NOCOLOR}:"
        readmsg_update+="${DOCKER__BG_BORDEAUX}${DOCKER__FG_WHITE}${docker__myImageId}${DOCKER__NOCOLOR}"

        #Get the length of 'readmsg_update'
        if [[ ! -z ${readmsg_update} ]]; then    #this condition is important
            update_numOfLines=`echo -e ${readmsg_update} | wc -l`      
        fi

        #Update total number of lines to be cleaned 'docker__totNumOfLines'
        docker__totNumOfLines=$((readMsg_numOfLines + update_numOfLines + DOCKER__NUMOFLINES_1))

        #Only show the read-input message, but do not show the image-list table.
        ${docker__readInput_w_autocomplete__fpath} "${MENUTITLE}" \
                            "${READMSG_PASTE_YOUR_INPUT}" \
                            "${readmsg_update}" \
                            "${readmsg_remarks}" \
                            "${DOCKER__ERRMSG_NO_IMAGES_FOUND}" \
                            "${DOCKER__ERRMSG_CHOSEN_IMAGEID_DOESNOT_EXISTS}" \
                            "${docker__images_cmd}" \
                            "${docker__images_IDColNo}" \
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
        if [[ ${docker__exitCode} -eq 99 ]]; then
            docker__myImageId_input=${DOCKER__EMPTYSTRING}
        else
            #Get the result
            docker__myImageId_input=`get_output_from_file__func "${docker__readInput_w_autocomplete_out__fpath}" "1"`
        fi  

        #This boolean will make sure that the image-list table is only displayed once.
        if [[ ${docker__showTable} == true ]]; then
            docker__showTable=false
        fi

        case "${docker__myImageId_input}" in
		    ${DOCKER__EMPTYSTRING})
                break
                ;;
            ${DOCKER__REMOVE_ALL})
                docker__myImageId="${docker__myImageId_input}"

                break
                ;;
            *)
                #Append 'docker__myImageId_input' to 'docker__myImageId'
                if [[ -z ${docker__myImageId} ]]; then  #'docker__myImageId' is an Empty String (this is the start)
                    docker__myImageId="${docker__myImageId_input}"
                else    #'docker__myImageId' contains data
                    #Check if 'docker__myImageId_input' was already added
                    isFound=`checkForMatch_of_pattern_within_string__func "${docker__myImageId_input}" "${docker__myImageId}"`

                    #If false, then add 'docker__myImageId_input' to 'docker__myImageId'
                    if [[ ${isFound} == false ]]; then
                        docker__myImageId="${docker__myImageId},${docker__myImageId_input}"
                    fi
                fi

                moveUp_and_cleanLines__func "${docker__totNumOfLines}"
                ;;
		esac
	done
}

docker__prune_handler__sub()  {
    #Input args
    local imageId__input=${1}
    local prepend_numOfLines__input=${2}

    #Prune and print messages
    moveUp_and_cleanLines__func "${prepend_numOfLines__input}"

    echo -e "Successfully Removed image-ID: ${DOCKER__FG_BORDEAUX}${imageId__input}${DOCKER__NOCOLOR}"
    echo -e "\r"
    echo -e "Removing ALL unlinked images"
    echo -e "y\n" | docker image prune
    echo -e "Removing ALL stopped containers"
    echo -e "y\n" | docker container prune
}

# docker__show_infoTable__sub() {
#     #Input args
#     local menuTitle__input=${1}
#     local dockerCmd__input=${2}
#     local errorMsg__input=${3}
#     local nunOfEmptyLines_toAdd__input=${4}

#     #Move-down a specified number of lines
#     local counter=1
#     while [[ ${counter} -le ${nunOfEmptyLines_toAdd__input} ]];
#     do
#         moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

#         counter=$((counter+1))
#     done

#     #Get number of containers
#     local numOf_items=`${dockerCmd__input} | head -n -1 | wc -l`

#     #Show Table
#     if [[ ${numOf_items} -eq 0 ]]; then
#         show_msg_w_menuTitle_w_pressAnyKey_w_ctrlC_func "${menuTitle__input}" \
#                         "${errorMsg__input}"  \
#                         "${DOCKER__EXITCODE_99}"
#     else
#         show_repoList_or_containerList_w_menuTitle__func "${menuTitle__input}" "${dockerCmd__input}"
#     fi
# }



#---MAIN SUBROUTINE
main_sub() {
    docker__get_source_fullpath__sub

    docker__load_source_files__sub

    docker__init_variables__sub

    docker__remove_specified_images__sub
}



#---EXECUTE MAIN
main_sub
