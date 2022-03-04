#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---SUBROUTINES
docker__load_environment_variables__sub() {
    #Define paths
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

    docker__global_functions_filename="docker_global_functions.sh"
    docker__global_functions_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global_functions_filename}
}

docker__load_source_files__sub() {
    source ${docker__global_functions_fpath}
}

docker__load_header__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${DOCKER__BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__init_variables__sub() {
    docker__myImageId=""
    docker__myImageId_input=""
    docker__myImageId_subst=""
    docker__myImageId_arr=()
    docker__myImageId_item=""
    docker__myImageId_isFound=""
    docker__myAnswer=""

    docker__exitCode=0

    docker__images_cmd="docker image ls"
    docker__images_IDColNo=3

    docker__showTable=false
    docker__onEnter_breakLoop=true
}

docker__remove_specified_images__sub() {
    #Define message constants
    local READMSG_DO_YOU_REALLY_WISH_TO_CONTINUE="***Do you REALLY wish to continue (y/n/q/b)? "

    #Define local message variables
    local errMsg=${DOCKER__EMPTYSTRING}
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
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            break
        fi

        #Check if 'docker__myImageId' contains data.
        if [[ ! -z ${docker__myImageId} ]]; then
            #Substitute COMMA with SPACE
            docker__myImageId_subst=`echo ${docker__myImageId} | sed 's/,/\ /g'`

            #Convert to Array
            eval "docker__myImageId_arr=(${docker__myImageId_subst})"

            #Print an Empty Line
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

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
                                numOfLines=${DOCKER__NUMOFLINES_2}
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

                                        ##Check if 'docker__myImageId_item' has been removed successfully
                                        docker__myImageId_isFound=`checkForMatch_dockerCmd_result__func "${docker__myImageId_item}" \
                                                "${docker__images_cmd}" \
                                                "${docker__images_IDColNo}"`
                                        if [[ ${docker__myImageId_isFound} == false ]]; then
                                            docker__prune_handler__sub "${docker__myImageId_item}"
                                        else  
                                            errMsg="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Could *NOT* remove image-ID: ${DOCKER__FG_BORDEAUX}${docker__myImageId_item}${DOCKER__NOCOLOR}"
                                            
                                            show_errMsg_plainVersion__func "${errMsg}"
                                        fi
                                    else
                                        #Update error-message
                                        errMsg="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Invalid image-ID '${DOCKER__FG_BORDEAUX}${docker__myImageId_item}${DOCKER__NOCOLOR}'"

                                        show_errMsg_plainVersion__func "${errMsg}"
                                    fi
                                done

                                #Set number of lines
                                numOfLines=${DOCKER__NUMOFLINES_1}
                            fi

                            #Print an Empty Line
                            moveDown_and_cleanLines__func "${numOfLines}"

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
    local READMSG_PASTE_YOUR_INPUT="Paste your input (here): "
    local MENUTITLE="Remove ${DOCKER__FG_BORDEAUX}image${DOCKER__NOCOLOR}/${DOCKER__FG_PURPLE}repository${DOCKER__NOCOLOR}"
    local ERRMSG_NO_IMAGES_FOUND="=:${DOCKER__FG_LIGHTRED}NO IMAGES FOUND${DOCKER__NOCOLOR}:="
    local ERRMSG_CHOSEN_IMAGEID_DOESNOT_EXISTS="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Invalid input value "

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
    if [[ ${docker__myAnswer} != "b" ]]; then
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
        readmsg_update="${DOCKER__BG_BORDEAUX}Remove the following ${DOCKER__FG_WHITE}image-IDs${DOCKER__NOCOLOR}:"
        readmsg_update+="${DOCKER__BG_BORDEAUX}${DOCKER__FG_WHITE}${docker__myImageId}${DOCKER__NOCOLOR}"

        #Get the length of 'readmsg_update'
        if [[ ! -z ${readmsg_update} ]]; then    #this condition is important
            update_numOfLines=`echo -e ${readmsg_update} | wc -l`      
        fi

        #Update total number of lines to be cleaned 'numOfLines_tot'
        numOfLines_tot=$((readMsg_numOfLines + update_numOfLines + DOCKER__NUMOFLINES_1))

        #Only show the read-input message, but do not show the image-list table.
        ${docker__readInput_w_autocomplete_fpath} "${MENUTITLE}" \
                            "${READMSG_PASTE_YOUR_INPUT}" \
                            "${readmsg_update}" \
                            "${readmsg_remarks}" \
                            "${ERRMSG_NO_IMAGES_FOUND}" \
                            "${ERRMSG_CHOSEN_IMAGEID_DOESNOT_EXISTS}" \
                            "${docker__images_cmd}" \
                            "${docker__images_IDColNo}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${docker__showTable}" \
                            "${docker__onEnter_breakLoop}"

        #Get the exitcode just in case a Ctrl-C was pressed in script 'docker__readInput_w_autocomplete_fpath'.
        docker__exitCode=$?
        if [[ ${docker__exitCode} -eq 99 ]]; then
            docker__myImageId_input=${DOCKER__EMPTYSTRING}
        else
            #Retrieve the selected container-ID from file
            docker__myImageId_input=`get_output_from_file__func "${docker__readInput_w_autocomplete_out_fpath}"`
        fi  

        #This boolean will make sure that the image-list table is only displayed once.
        if [[ ${docker__showTable} == true ]]; then
            docker__showTable=false
        fi

        case "${docker__myImageId_input}" in
		    ${DOCKER__EMPTYSTRING})
                #Only clean lines if 'docker__myImageId' is an Empty String
                if [[ -z ${docker__myImageId} ]]; then
                    moveUp_and_cleanLines__func "${numOfLines_tot}"
                fi

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
                    isFound=`checkForMatch_keyWord_within_string__func "${docker__myImageId_input}" "${docker__myImageId}"`

                    #If false, then add 'docker__myImageId_input' to 'docker__myImageId'
                    if [[ ${isFound} == false ]]; then
                        docker__myImageId="${docker__myImageId},${docker__myImageId_input}"
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
    echo -e "Successfully Removed image-ID: ${DOCKER__FG_BORDEAUX}${imageId__input}${DOCKER__NOCOLOR}"
    echo -e "\r"
    echo -e "Removing ALL unlinked images"
    echo -e "y\n" | docker image prune
    echo -e "Removing ALL stopped containers"
    echo -e "y\n" | docker container prune
}

docker__show_infoTable__sub() {
    #Input args
    local menuTitle__input=${1}
    local dockerCmd__input=${2}
    local errorMsg__input=${3}
    local nunOfEmptyLines_toAdd__input=${4}

    #Move-down a specified number of lines
    local counter=1
    while [[ ${counter} -le ${nunOfEmptyLines_toAdd__input} ]];
    do
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        counter=$((counter+1))
    done

    #Get number of containers
    local numOf_items=`${dockerCmd__input} | head -n -1 | wc -l`

    #Show Table
    if [[ ${numOf_items} -eq 0 ]]; then
        show_errMsg_with_menuTitle__func "${menuTitle__input}" "${errorMsg__input}"
    else
        show_list_with_menuTitle__func "${menuTitle__input}" "${dockerCmd__input}"
    fi
}



#---MAIN SUBROUTINE
main_sub() {
    docker__load_environment_variables__sub

    docker__load_source_files__sub

    docker__load_header__sub

    docker__init_variables__sub

    docker__remove_specified_images__sub
}



#---EXECUTE MAIN
main_sub
