#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---COLOR CONSTANTS
DOCKER__NOCOLOR=$'\e[0;0m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__IMAGEID_FG_BORDEAUX=$'\e[30;38;5;198m'
DOCKER__REPOSITORY_FG_PURPLE=$'\e[30;38;5;93m'
DOCKER__OUTSIDE_FG_WHITE=$'\e[30;38;5;231m'

DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'
DOCKER__TITLE_BG_LIGHTBLUE=$'\e[30;48;5;45m'
DOCKER__IMAGEID_BG_BORDEAUX=$'\e[30;48;5;198m'
DOCKER__REMARK_BG_ORANGE=$'\e[30;48;5;208m'

#---CONSTANTS
DOCKER__TITLE="TIBBO"

DOCKER__REMOVE_ALL="REMOVE-ALL"

#---CHARACTER CONSTANTS
DOCKER__DASH="-"
DOCKER__EMPTYSTRING=""

DOCKER__ENTER=$'\x0a'

DOCKER__ONESPACE=" "
DOCKER__TWOSPACES=${DOCKER__ONESPACE}${DOCKER__ONESPACE}
DOCKER__FOURSPACES=${DOCKER__TWOSPACES}${DOCKER__TWOSPACES}

#---NUMERIC CONSTANTS
DOCKER__TABLEWIDTH=70

DOCKER__NUMOFLINES_1=1
DOCKER__NUMOFLINES_2=2
DOCKER__NUMOFLINES_3=3
DOCKER__NUMOFLINES_4=4
DOCKER__NUMOFLINES_5=5
DOCKER__NUMOFLINES_6=6
DOCKER__NUMOFLINES_7=7
DOCKER__NUMOFLINES_8=8
DOCKER__NUMOFLINES_9=9
DOCKER__NUMOFLINES_10=10

#---MENU CONSTANTS
DOCKER__CTRL_C_QUIT="${DOCKER__FOURSPACES}Quit (Ctrl+C)"



#---FUNCTIONS
#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C__sub INT

function press_any_key__func() {
	#Define constants
	local ANYKEY_TIMEOUT=10

	#Initialize variables
	local keyPressed=""
	local tCounter=0

	#Show Press Any Key message with count-down
	moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
	while [[ ${tCounter} -le ${ANYKEY_TIMEOUT} ]];
	do
		delta_tcounter=$(( ${ANYKEY_TIMEOUT} - ${tCounter} ))

		echo -e "\rPress (a)bort or any key to continue... (${delta_tcounter}) \c"
		read -N 1 -t 1 -s -r keyPressed

		if [[ ! -z "${keyPressed}" ]]; then
			if [[ "${keyPressed}" == "a" ]] || [[ "${keyPressed}" == "A" ]]; then
				exit
			else
				break
			fi
		fi
		
		tCounter=$((tCounter+1))
	done
	moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
}

function duplicate_char__func() {
    #Input args
    local char_input=${1}
    local numOf_times=${2}

    #Duplicate 'char_input'
    local char_duplicated=`printf '%*s' "${numOf_times}" | tr ' ' "${char_input}"`

    #Print text including Leading Empty Spaces
    echo -e "${char_duplicated}"
}

function get_output_from_file__func() {
    #Read from file
    if [[ -f ${docker__readInput_w_autocomplete_out__fpath} ]]; then
        ret=`cat ${docker__readInput_w_autocomplete_out__fpath} | head -n1 | xargs`
    else
        ret=${DOCKER__EMPTYSTRING}
    fi

    #Output
    echo ${ret}
}

function show_centered_string__func() {
    #Input args
    local str_input=${1}
    local maxStrLen_input=${2}

    #Define one-space constant
    local ONESPACE=" "

    #Get string 'without visiable' color characters
    local strInput_wo_colorChars=`echo "${str_input}" | sed "s,\x1B\[[0-9;]*m,,g"`

    #Get string length
    local strInput_wo_colorChars_len=${#strInput_wo_colorChars}

    #Calculated the number of spaces to-be-added
    local numOf_spaces=$(( (maxStrLen_input-strInput_wo_colorChars_len)/2 ))

    #Create a string containing only EMPTY SPACES
    local emptySpaces_string=`duplicate_char__func "${ONESPACE}" "${numOf_spaces}" `

    #Print text including Leading Empty Spaces
    echo -e "${emptySpaces_string}${str_input}"
}

function show_errMsg_with_menuTitle__func() {
    #Input args
    local menuTitle=${1}
    local errMsg=${2}

    #Show error-message
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"  #horizontal line
    show_centered_string__func "${menuTitle}" "${DOCKER__TABLEWIDTH}"   #menu-title
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"  #horizontal line
    
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    show_centered_string__func "${errMsg}" "${DOCKER__TABLEWIDTH}"  #error message
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"  #horizontal line
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    press_any_key__func

    CTRL_C__sub
}

function show_errMsg_without_menuTitle__func() {
    #Input args
    local errMsg=${1}

    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

    echo -e "${errMsg}" #error message

    press_any_key__func
}

function show_errMsg_plainVersion__func() {
    #Input args
    local errMsg=${1}

    # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

    echo -e "${errMsg}" #error message

    # press_any_key__func
}

function show_list_with_menuTitle__func() {
    #Input args
    local menuTitle=${1}
    local dockerCmd=${2}

    #Show list
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"   #horizontal line
    show_centered_string__func "${menuTitle}" "${DOCKER__TABLEWIDTH}"   #menu-title
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"   #horizontal line
    
    if [[ ${dockerCmd} == ${docker__ps_a_cmd} ]]; then
        ${docker__containerlist_tableinfo_fpath}    #show container-list
    else
        ${docker__repolist_tableinfo_fpath} #show image-list
    fi

    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"   #horizontal line
    echo -e "${DOCKER__CTRL_C_QUIT}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"   #horizontal line
}   



#---SUBROUTINES
CTRL_C__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
    
    exit 99
}

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

	docker__repolist_tableinfo_filename="docker_repolist_tableinfo.sh"
	docker__repolist_tableinfo_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__repolist_tableinfo_filename}

    docker_readInput_w_autocomplete_filename="docker_readInput_w_autocomplete.sh"
    docker_readInput_w_autocomplete_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker_readInput_w_autocomplete_filename}

    docker__tmp_dir=/tmp
    docker__readInput_w_autocomplete_out__filename="docker__readInput_w_autocomplete.out"
    docker__readInput_w_autocomplete_out__fpath=${docker__tmp_dir}/${docker__readInput_w_autocomplete_out__filename}
}

docker__load_source_files__sub() {
    source ${docker__global_functions_fpath}
}

docker__load_header__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${DOCKER__TITLE_BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__TITLE_BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__init_variables__sub() {
    docker__myImageId=""
    docker__myImageId_input=""
    docker__myImageId_subst=""
    docker__myImageId_arr=()
    docker__myImageId_item=""
    docker__myImageId_isFound=""
    docker__myAnswer=""

    docker__images_cmd="docker image ls"

    docker__exitCode=0
    docker__images_IDColNo=3

    docker__showTable=false
    docker__onEnter_breakLoop=true
}

docker__remove_specified_images__sub() {
    #Define message constants
    local MENUTITLE="Remove ${DOCKER__IMAGEID_FG_BORDEAUX}Image${DOCKER__NOCOLOR}/${DOCKER__REPOSITORY_FG_PURPLE}Repository${DOCKER__NOCOLOR}"
    local MENUTITLE_UPDATED_IMAGE_LIST="Updated ${DOCKER__IMAGEID_FG_BORDEAUX}Image${DOCKER__NOCOLOR}-list"
    local READMSG_DO_YOU_REALLY_WISH_TO_CONTINUE="***Do you REALLY wish to continue (y/n/q/b)? "
    local ERRMSG_NO_IMAGES_FOUND="=:${DOCKER__ERROR_FG_LIGHTRED}NO IMAGES FOUND${DOCKER__NOCOLOR}:="

    #Define local message variables
    local errMsg=${DOCKER__EMPTYSTRING}
    local numof_images=0

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

        #
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
                                # docker rmi $(docker images -q)

                                #Show image-list table
                                docker__show_infoTable__sub "${MENUTITLE_UPDATED_IMAGE_LIST}" \
                                        "${docker__images_cmd}" \
                                        "${ERRMSG_NO_IMAGES_FOUND}" \
                                        "${DOCKER__NUMOFLINES_2}"

                                #Exit this current loop
                                break
                            else    #Handle each image-ID at the time
                                #Print Empty Lines
                                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

                                for docker__myImageId_item in "${docker__myImageId_arr[@]}"
                                do 
                                    docker__myImageId_isFound=`docker image ls | awk '{print $3}' | grep -w ${docker__myImageId_item}`
                                    if [[ ! -z ${docker__myImageId_isFound} ]]; then
                                        # docker image rmi -f ${docker__myImageId_item}

                                        #Check if removing the image was successful
                                        docker__myImageId_isFound=`docker image ls | awk '{print $3}' | grep -w ${docker__myImageId_item}`
                                        if [[ -z ${docker__myImageId_isFound} ]]; then
                                            docker__prune_handler__sub "${docker__myImageId_item}"
                                        else  
                                            errMsg="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Could *NOT* remove Image-ID: ${DOCKER__IMAGEID_FG_BORDEAUX}${docker__myImageId_item}${DOCKER__NOCOLOR}"
                                            
                                            show_errMsg_plainVersion__func "${errMsg}"
                                        fi
                                    else
                                        #Update error-message
                                        errMsg="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Invalid Image-ID '${DOCKER__IMAGEID_FG_BORDEAUX}${docker__myImageId_item}${DOCKER__NOCOLOR}'"

                                        show_errMsg_plainVersion__func "${errMsg}"
                                    fi
                                done
                            fi

                            #Print an Empty Line
                            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                            #Set flag back to true
                            docker__showTable=true

                            break
                            ;;
                        "n")
                            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_10}"

                            break
                            ;;
                        "q")
                            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

                            exit
                            ;;
                        "b")
                            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_10}"

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
    local MENUTITLE="Remove ${DOCKER__IMAGEID_FG_BORDEAUX}Image${DOCKER__NOCOLOR}/${DOCKER__REPOSITORY_FG_PURPLE}Repository${DOCKER__NOCOLOR}"
    local ERRMSG_NO_IMAGES_FOUND="=:${DOCKER__ERROR_FG_LIGHTRED}NO IMAGES FOUND${DOCKER__NOCOLOR}:="

    local ERRMSG_CHOSEN_IMAGEID_DOESNOT_EXISTS="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Invalid input value "
    local ERRMSG_NO_IMAGES_FOUND="=:${DOCKER__ERROR_FG_LIGHTRED}NO IMAGES FOUND${DOCKER__NOCOLOR}:="

    #Define variables
    local readmsg_remarks1="${DOCKER__REMARK_BG_ORANGE}Remarks:${DOCKER__NOCOLOR}\n"
    readmsg_remarks1+="${DOCKER__DASH} Remove ALL image-IDs by typing: ${DOCKER__REMOVE_ALL}\n"
    readmsg_remarks1+="${DOCKER__DASH} Multiple image-IDs can be removed\n"
    readmsg_remarks1+="${DOCKER__DASH} Comma-separator will be appended automatically\n"
    readmsg_remarks1+="${DOCKER__DASH} Up/Down arrow: to cycle thru existing values\n"
    readmsg_remarks1+="${DOCKER__DASH} TAB: auto-complete\n"
    readmsg_remarks1+="${DOCKER__DASH} [On an Empty Field] press ENTER to confirm deletion"

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
    local readmsg_remarks2=${DOCKER__EMPTYSTRING}
    local readMsg_numOfLines=0
    local remarks_numOfLines=0
    local remarks2_numOfLines=0
    local numOfLines_tot=0

    #Calculate number of lines to be cleaned
    if [[ ! -z ${READMSG_PASTE_YOUR_INPUT} ]]; then    #this condition is important
        readMsg_numOfLines=`echo -e ${READMSG_PASTE_YOUR_INPUT} | wc -l`      
    fi
    if [[ ! -z ${readmsg_remarks1} ]]; then    #this condition is important
        remarks_numOfLines=`echo -e ${readmsg_remarks1} | wc -l`      
    fi

    while true
    do
        #Define 'readmsg_remarks2'
        readmsg_remarks2="${DOCKER__IMAGEID_BG_BORDEAUX}Remove the following ${DOCKER__OUTSIDE_FG_WHITE}image-IDs${DOCKER__NOCOLOR}:"
        readmsg_remarks2+="${DOCKER__IMAGEID_BG_BORDEAUX}${DOCKER__OUTSIDE_FG_WHITE}${docker__myImageId}${DOCKER__NOCOLOR}"

        #Get the length of 'readmsg_remarks2'
        if [[ ! -z ${readmsg_remarks2} ]]; then    #this condition is important
            remarks2_numOfLines=`echo -e ${readmsg_remarks2} | wc -l`      
        fi

        #Update total number of lines to be cleaned 'numOfLines_tot'
        numOfLines_tot=$((readMsg_numOfLines + remarks_numOfLines + remarks2_numOfLines))

        #Only show the read-input message, but do not show the image-list table.
        ${docker_readInput_w_autocomplete_fpath} "${MENUTITLE}" \
                            "${READMSG_PASTE_YOUR_INPUT}" \
                            "${readmsg_remarks1}" \
                            "${readmsg_remarks2}" \
                            "${ERRMSG_NO_IMAGES_FOUND}" \
                            "${ERRMSG_CHOSEN_IMAGEID_DOESNOT_EXISTS}" \
                            "${docker__images_cmd}" \
                            "${docker__images_IDColNo}" \
                            "${DOCKER__EMPTYSTRING}" \
                            "${docker__showTable}" \
                            "${docker__onEnter_breakLoop}"

        #Get the exitcode just in case a Ctrl-C was pressed in script 'docker_readInput_w_autocomplete_fpath'.
        docker__exitCode=$?
        if [[ ${docker__exitCode} -eq 99 ]]; then
            docker__myImageId_input=${DOCKER__EMPTYSTRING}
        else
            #Retrieve the selected container-ID from file
            docker__myImageId_input=`get_output_from_file__func`  
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

docker__show_infoTable__sub() {
    #Input args
    local menuTitle__input=${1}
    local dockerCmd__input=${2}
    local errorMsg__input=${3}
    local numOfLines_toPrint__input=${4}

    #Move-down a specified number of lines
    local counter=1
    while [[ ${counter} -le ${numOfLines_toPrint__input} ]];
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

docker__prune_handler__sub()  {
    #Input args
    local ${imageId__input}=${1}

    #Prune and print messages
    echo -e "Successfully Removed Image-ID: ${DOCKER__IMAGEID_FG_BORDEAUX}${imageId__input}${DOCKER__NOCOLOR}"
    echo -e "\r"
    echo -e "Removing ALL unlinked images"
    echo -e "y\n" | docker image prune
    echo -e "Removing ALL stopped containers"
    echo -e "y\n" | docker container prune
}

main_sub() {
    docker__load_environment_variables__sub

    docker__load_source_files__sub

    docker__load_header__sub

    docker__init_variables__sub

    docker__remove_specified_images__sub
}


#Execute main subroutine
main_sub
