#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---SUBROUTINES
docker__environmental_variables__sub() {
    #---Define PATHS
    docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})
    docker__parent_dir=${docker__current_dir%/*}    #gets one directory up
    if [[ -z ${docker__parent_dir} ]]; then
        docker__parent_dir="${DOCKER__SLASH_CHAR}"
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
    show_header__func "${DOCKER__TITLE}" "${DOCKER__TABLEWIDTH}" "${DOCKER__BG_ORANGE}" "${DOCKER__NUMOFLINES_2}" "${DOCKER__NUMOFLINES_0}"
}

docker__init_variables__sub() {
    docker__myContainerId=${DOCKER__EMPTYSTRING}
    docker__myContainerId_input=${DOCKER__EMPTYSTRING}
    docker__myContainerId_subst=${DOCKER__EMPTYSTRING}
    docker__myContainerId_arr=()
    docker__myContainerId_item=${DOCKER__EMPTYSTRING}
    docker__myContainerId_isFound=${DOCKER__EMPTYSTRING}
    docker__myAnswer=${DOCKER__EMPTYSTRING}

    docker__exitCode=0

    docker__ps_a_cmd="docker ps -a"
    docker__ps_a_containerIdColno=1

    docker__showTable=false
    docker__onEnter_breakLoop=true
}

docker_remove_specified_containers__sub() {
    #Define local constants
    local READMSG_DO_YOU_REALLY_WISH_TO_CONTINUE="***Do you REALLY wish to continue (y/n/q/b)? "

    #Define local variables
    local errMsg=${DOCKER__EMPTYSTRING}
    local numOfLines=${DOCKER__NUMOFLINES_0}

    #Set flag to true
    docker__showTable=true

    #Start loop
    while true
    do
        #Provide container-IDs to be removed
        #Output:
        #1. docker__myContainerId
        #2. docker__exitCode:
        #   - default: docker__exitCode = 0
        #   - in case ctrl+C is pressed: docker__exitCode = 99
        docker_containerId_input__sub

        #Check previously (in subroutine 'docker_containerId_input__sub') ctrl+C was pressed.
        if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            break
        fi

        #Check if 'docker__myContainerId' contains data.
        if [[ ! -z ${docker__myContainerId} ]]; then
            #Substitute COMMA with SPACE
            docker__myContainerId_subst=`echo ${docker__myContainerId} | sed 's/,/\ /g'`

            #Convert to Array
            eval "docker__myContainerId_arr=(${docker__myContainerId_subst})"

            #Go thru each array-item
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            while true
            do
                read -N1 -p "${READMSG_DO_YOU_REALLY_WISH_TO_CONTINUE}" docker__myAnswer
    
                if [[ ! -z ${docker__myAnswer} ]]; then          
                    case "${docker__myAnswer}" in
                        "y")
                            if [[ ${docker__myContainerId} == ${DOCKER__REMOVE_ALL} ]]; then
                                 #Kill all running container-IDs
                                docker kill $(docker ps -q)

                                #Delete all stopped container-IDs
                                docker rm $(docker ps -a -q)

                                #Set number of lines
                                numOfLines=${DOCKER__NUMOFLINES_2}
                            else
                                #Print Empty Lines
                                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

                                for docker__myContainerId_item in "${docker__myContainerId_arr[@]}"
                                do 
                                    #Check if 'docker__myContainerId_isFound' is present
                                    docker__myContainerId_isFound=`checkForMatch_dockerCmd_result__func "${docker__myContainerId_item}" \
                                            "${docker__ps_a_cmd}" \
                                            "${docker__ps_a_containerIdColno}"`
                                    if [[ ${docker__myContainerId_isFound} == true ]]; then
                                        #Remove selected image-IDs
                                        docker container rm -f ${docker__myContainerId_item}

                                        ##Check if 'docker__myImageId_item' has been removed successfully
                                        docker__myContainerId_isFound=`checkForMatch_dockerCmd_result__func "${docker__myContainerId_item}" \
                                                "${docker__ps_a_cmd}" \
                                                "${docker__ps_a_containerIdColno}"`
                                        if [[ ${docker__myContainerId_isFound} == false ]]; then
                                            docker__prune_handler__sub "${docker__myContainerId_item}"
                                        else  
                                            errMsg="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Could *NOT* remove container-ID: ${DOCKER__FG_BORDEAUX}${docker__myContainerId_item}${DOCKER__NOCOLOR}"
                                            
                                            show_msg_only__func "${errMsg}" "${DOCKER__NUMOFLINES_0}"
                                        fi
                                    else
                                        #Update error-message
                                        errMsg="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Invalid container-ID '${DOCKER__FG_BORDEAUX}${docker__myContainerId_item}${DOCKER__NOCOLOR}'"

                                        show_msg_only__func "${errMsg}" "${DOCKER__NUMOFLINES_0}"
                                    fi
                                done

                                #Set number of lines
                                numOfLines=${DOCKER__NUMOFLINES_1}
                            fi

                            #Print an Empty Line
                            moveDown_and_cleanLines__func "${numOfLines}"

                            #Set flag back to true
                            docker__showTable=true

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

docker_containerId_input__sub() {
    #Define message constants
    local READMSG_PASTE_YOUR_INPUT="Paste your input (here): "
    local MENUTITLE="Remove ${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}"
    local ERRMSG_INVALID_INPUT_VALUE="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Invalid input value "

    #Define variables
    local readmsg_remarks="${DOCKER__BG_ORANGE}Remarks:${DOCKER__NOCOLOR}\n"
    readmsg_remarks+="${DOCKER__DASH} Remove ALL container-IDs by typing: ${DOCKER__FG_LIGHTGREY}${DOCKER__REMOVE_ALL}${DOCKER__NOCOLOR}\n"
    readmsg_remarks+="${DOCKER__DASH} Multiple container-IDs can be removed\n"
    readmsg_remarks+="${DOCKER__DASH} Comma-separator will be appended automatically\n"
    readmsg_remarks+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}Up/Down Arrow${DOCKER__NOCOLOR}: to cycle thru existing values\n"
    readmsg_remarks+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}TAB${DOCKER__NOCOLOR}: auto-complete\n"
    readmsg_remarks+="${DOCKER__DASH} ${DOCKER__FG_YELLOW};c${DOCKER__NOCOLOR}: clear\n"
    readmsg_remarks+="${DOCKER__DASH} [On an Empty Field] press ENTER to confirm deletion"

    #Reset variable based on the chosen answer (e.g., n, b)
    if [[ ${docker__myAnswer} != "b" ]]; then
        docker__myContainerId=${DOCKER__EMPTYSTRING}
    else
        if [[ ${docker__myContainerId} == ${DOCKER__REMOVE_ALL} ]]; then
            docker__myContainerId=${DOCKER__EMPTYSTRING}
        fi
    fi

    #Initialization
    local isFound=false
    local readmsg_update=${DOCKER__EMPTYSTRING}
    local readMsg_numOfLines=0
    local remarks_numOfLines=0
    local update_numOfLines=0
    local numOfLines_tot=0

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
        readmsg_update="${DOCKER__BG_BORDEAUX}Remove the following ${DOCKER__FG_WHITE}container-IDs${DOCKER__NOCOLOR}:"
        readmsg_update+="${DOCKER__BG_BORDEAUX}${DOCKER__FG_WHITE}${docker__myContainerId}${DOCKER__NOCOLOR}"

        #Get the length of 'readmsg_update'
        if [[ ! -z ${readmsg_update} ]]; then    #this condition is important
            update_numOfLines=`echo -e ${readmsg_update} | wc -l`      
        fi

        #Update total number of lines to be cleaned 'numOfLines_tot'
        numOfLines_tot=$((readMsg_numOfLines + update_numOfLines + DOCKER__NUMOFLINES_1))

        ${docker__readInput_w_autocomplete__fpath} "${MENUTITLE}" \
                            "${READMSG_PASTE_YOUR_INPUT}" \
                            "${readmsg_update}" \
                            "${readmsg_remarks}" \
                            "${DOCKER__ERRMSG_NO_CONTAINERS_FOUND}" \
                            "${ERRMSG_INVALID_INPUT_VALUE}" \
                            "${docker__ps_a_cmd}" \
                            "${docker__ps_a_containerIdColno}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${docker__showTable}" \
                            "${docker__onEnter_breakLoop}"

        #Get the exitcode just in case a Ctrl-C was pressed in script 'docker__readInput_w_autocomplete__fpath'.
        docker__exitCode=$?
        if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
            docker__myContainerId_input=${DOCKER__EMPTYSTRING}
        else
            #Retrieve the selected container-ID from file
            docker__myContainerId_input=`get_output_from_file__func "${docker__readInput_w_autocomplete_out__fpath}" "1"`
        fi  

        #This boolean will make sure that the image-list table is only displayed once.
        if [[ ${docker__showTable} == true ]]; then
            docker__showTable=false
        fi

        case "${docker__myContainerId_input}" in
		    ${DOCKER__EMPTYSTRING})
                #Only clean lines if 'docker__myContainerId' is an Empty String
                if [[ -z ${docker__myContainerId} ]]; then
                    moveUp_and_cleanLines__func "${numOfLines_tot}"
                fi

                break
                ;;
            ${DOCKER__REMOVE_ALL})
                docker__myContainerId="${docker__myContainerId_input}"

                break
                ;;
            *)
                #Append 'docker__myContainerId_input' to 'docker__myContainerId'
                if [[ -z ${docker__myContainerId} ]]; then  #'docker__myContainerId' is an Empty String (this is the start)
                    docker__myContainerId="${docker__myContainerId_input}"
                else    #'docker__myContainerId' contains data
                    Check if 'docker__myContainerId_input' was already added
                    isFound=`checkForMatch_keyWord_within_string__func "${docker__myContainerId_input}" "${docker__myContainerId}"`

                    #If false, then add 'docker__myContainerId_input' to 'docker__myContainerId'
                    if [[ ${isFound} == false ]]; then
                        docker__myContainerId="${docker__myContainerId},${docker__myContainerId_input}"
                    fi
                fi

                moveUp_and_cleanLines__func "${numOfLines_tot}"
                ;;
		esac
	done
}

docker__prune_handler__sub()  {
    #Input args
    local imageId__input=${1}

    #Prune and print messages
    echo -e "Successfully Removed Image-ID: ${DOCKER__FG_BORDEAUX}${imageId__input}${DOCKER__NOCOLOR}"
    echo -e "\r"
    echo -e "Removing ALL unlinked images"
    echo -e "y\n" | docker image prune
    echo -e "Removing ALL stopped containers"
    echo -e "y\n" | docker container prune
}



#---MAIN SUBROUTINE
main_sub() {
    docker__environmental_variables__sub

    docker__load_source_files__sub

    docker__load_header__sub

    docker__init_variables__sub

    docker_remove_specified_containers__sub
}



#---EXECUTE
main_sub
