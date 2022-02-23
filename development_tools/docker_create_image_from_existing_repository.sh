#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---COLOR CONSTANTS
DOCKER__NOCOLOR=$'\e[0;0m'
DOCKER__DIRS_FG_VERYLIGHTORANGE=$'\e[30;38;5;223m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__FG_LIGHTGREY=$'\e[30;38;5;246m'
DOCKER__FG_LIGHTSOFTYELLOW=$'\e[30;38;5;229m'
DOCKER__FG_ORANGE=$'\e[30;38;5;215m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__IMAGEID_FG_BORDEAUX=$'\e[30;38;5;198m'
DOCKER__NEW_REPOSITORY_FG_BRIGHTLIGHTPURPLE=$'\e[30;38;5;147m'
DOCKER__REPOSITORY_FG_PURPLE=$'\e[30;38;5;93m'
DOCKER__TAG_FG_LIGHTPINK=$'\e[30;38;5;218m'

DOCKER__DIRS_BG_VERYLIGHTORANGE=$'\e[30;48;5;223m'
DOCKER__REMARK_BG_ORANGE=$'\e[30;48;5;208m'
DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'
DOCKER__TITLE_BG_LIGHTBLUE='\e[30;48;5;45m'



#---CONSTANTS
DOCKER__TITLE="TIBBO"

DOCKER__EXITING_NOW="Exiting now..."

#---CHAR CONSTANTS
DOCKER__DASH="-"
DOCKER__EMPTYSTRING=""
DOCKER__SLASH_CHAR="/"

DOCKER__ENTER=$'\x0a'

DOCKER__ONESPACE=" "
DOCKER__TWOSPACES=${DOCKER__ONESPACE}${DOCKER__ONESPACE}
DOCKER__FOURSPACES=${DOCKER__TWOSPACES}${DOCKER__TWOSPACES}

#---NUMERIC CONSTANTS
DOCKER__NUMOF_FILES_TOBE_KEPT_MAX=100
DOCKER__NINE=9
DOCKER__TABLEWIDTH=70

DOCKER__NUMOFLINES_1=1
DOCKER__NUMOFLINES_2=2
DOCKER__NUMOFLINES_3=3
DOCKER__NUMOFLINES_4=4
DOCKER__NUMOFLINES_5=5


#---READ-INPUT CONSTANTS
DOCKER__YES="y"
DOCKER__NO="n"
DOCKER__REDO="r"


#---MENU CONSTANTS
DOCKER__CTRL_C_QUIT="${DOCKER__FOURSPACES}Quit (Ctrl+C)"
DOCKER__HORIZONTALLINE="---------------------------------------------------------------------"


#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C__sub INT



#---FUNCTIONS
function press_any_key__func() {
	#Define constants
	local ANYKEY_TIMEOUT=10

	#Initialize variables
	local keypressed=${DOCKER__EMPTYSTRING}
	local tcounter=0

	#Show Press Any Key message with count-down
	moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
	while [[ ${tcounter} -le ${ANYKEY_TIMEOUT} ]];
	do
		delta_tcounter=$(( ${ANYKEY_TIMEOUT} - ${tcounter} ))

		echo -e "\rPress (a)bort or any key to continue... (${delta_tcounter}) \c"
		read -N 1 -t 1 -s -r keypressed

		if [[ ! -z "${keypressed}" ]]; then
			if [[ "${keypressed}" == "a" ]] || [[ "${keypressed}" == "A" ]]; then
				exit
			else
				break
			fi
		fi
		
		tcounter=$((tcounter+1))
	done
	moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
}

function exit__func() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

    exit
}

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

function duplicate_char__func()
{
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

function show_centered_string__func()
{
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

function show_errMsg_without_menuTitle__func() {
    #Input args
    local errMsg=${1}

    # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${errMsg}"

    press_any_key__func
}

function show_list_with_menuTitle__func() {
    #Input args
    local menuTitle=${1}
    local dockerCmd=${2}

    #Show list
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${menuTitle}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    
    if [[ ${dockerCmd} == ${docker__ps_a_cmd} ]]; then
        ${docker__containerlist_tableinfo_fpath}
    else
        ${docker__repolist_tableinfo_fpath}
    fi

    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${DOCKER__CTRL_C_QUIT}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
}



#---SUBROUTINES
CTRL_C__sub() {
    exit__func
}

docker__load_environment_variables__sub() {
    #Define paths
    docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})
    docker__parent_dir=${docker__current_dir%/*}    #go one directory up (e.g. <home-dir>/repo/LTPP3_ROOTFS)
    if [[ -z ${docker__parent_dir} ]]; then
        docker__parent_dir="${DOCKER__SLASH_CHAR}"
    fi
    docker__current_folder=`basename ${docker__current_dir}`

    docker__xxx_repo_dir=${docker__parent_dir%/*}    #go one directory up (e.g. <home-dir>/repo)
    docker__xxx_docker_dockerfiles_dir=${docker__xxx_repo_dir}/docker/dockerfiles
    docker__dockerfile_auto_filename="dockerfile_auto"
    docker__dockerfile_autogen_fpath=${DOCKER__EMPTYSTRING}

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
        echo -e "---${DOCKER__ERROR_FG_LIGHTRED}WARNING${DOCKER__NOCOLOR}: ${ECHOMSG_MAX_NUMOF_FILES_EXCEEDED}"
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
    #If TRUE, then remove file
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
    local MENUTITLE="Create an ${DOCKER__IMAGEID_FG_BORDEAUX}Image${DOCKER__NOCOLOR} from a ${DOCKER__REPOSITORY_FG_PURPLE}Repository${DOCKER__NOCOLOR}"
    local MENUTITLE_UPDATED_IMAGE_LIST="Updated ${DOCKER__IMAGEID_FG_BORDEAUX}Image${DOCKER__NOCOLOR}-list"

    local READMSG_CHOOSE_IMAGEID_FROM_LIST="Choose an ${DOCKER__IMAGEID_FG_BORDEAUX}Image-ID${DOCKER__NOCOLOR} from list (e.g. 0f7478cf7cab): "
    local READMSG_NEW_REPOSITORY_NAME="${DOCKER__GENERAL_FG_YELLOW}New${DOCKER__NOCOLOR} ${DOCKER__NEW_REPOSITORY_FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR}'s name (e.g. ubuntu_buildbin_NEW): "
    local READMSG_NEW_REPOSITORY_TAG="${DOCKER__GENERAL_FG_YELLOW}New${DOCKER__NOCOLOR} ${DOCKER__TAG_FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} (e.g. test): "

    local ERRMSG_CHOSEN_IMAGEID_DOESNOT_EXISTS="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: chosen ${DOCKER__IMAGEID_FG_BORDEAUX}Image-ID${DOCKER__NOCOLOR} does NOT exist"
    local ERRMSG_CHOSEN_REPO_PAIR_ALREADY_EXISTS="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: chosen ${DOCKER__NEW_REPOSITORY_FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR}:${DOCKER__TAG_FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} pair already exists"
    local ERRMSG_NO_IMAGES_FOUND="=:${DOCKER__ERROR_FG_LIGHTRED}NO IMAGES FOUND${DOCKER__NOCOLOR}:="
    local ERRMSG_NONUNIQUE_INPUT_VALUE="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: non-unique input value "

    #Define variables
    local errMsg=${DOCKER__EMPTYSTRING}
    local phase=${DOCKER__EMPTYSTRING}
    local readmsg_remarks=${DOCKER__EMPTYSTRING}

    local repoTag_isUniq=false



    #Set 'readmsg_remarks'
    readmsg_remarks="${DOCKER__REMARK_BG_ORANGE}Remarks:${DOCKER__NOCOLOR}\n"
    readmsg_remarks+="${DOCKER__DASH} Up/Down arrow: to cycle thru existing values\n"
    readmsg_remarks+="${DOCKER__DASH} TAB: auto-complete"

    #Set initial 'phase'
    phase=${IMAGEID_SELECT_PHASE}
    while true
    do
        case "${phase}" in
            ${IMAGEID_SELECT_PHASE})
                ${docker_readInput_w_autocomplete_fpath} "${MENUTITLE}" \
                                    "${READMSG_CHOOSE_IMAGEID_FROM_LIST}" \
                                    "${readmsg_remarks}" \
                                    "${DOCKER__EMPTYSTRING}" \
                                    "${ERRMSG_NO_IMAGES_FOUND}" \
                                    "${ERRMSG_CHOSEN_IMAGEID_DOESNOT_EXISTS}" \
                                    "${docker__images_cmd}" \
                                    "${docker__images_IDColNo}" \
                                    "${DOCKER__EMPTYSTRING}" \
                                    "${docker__showTable}" \
                                    "${docker__onEnter_breakLoop}"

                #Retrieve the selected container-ID from file
                docker__imageID_chosen=`get_output_from_file__func` 

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
                ${docker_readInput_w_autocomplete_fpath} "${MENUTITLE}" \
                                    "${READMSG_NEW_REPOSITORY_NAME}" \
                                    "${readmsg_remarks}" \
                                    "${DOCKER__EMPTYSTRING}" \
                                    "${ERRMSG_NO_IMAGES_FOUND}" \
                                    "${DOCKER__EMPTYSTRING}" \
                                    "${docker__images_cmd}" \
                                    "${docker__images_repoColNo}" \
                                    "${DOCKER__EMPTYSTRING}" \
                                    "${docker__showTable}" \
                                    "${docker__onEnter_breakLoop}"

                #Retrieve the selected container-ID from file
                docker__repo_new=`get_output_from_file__func` 

                #Check if output is an Empty String
                if [[ -z ${docker__repo_new} ]]; then
                    return
                else
                    phase=${NEW_TAG_INPUT_PHASE}
                fi
                ;;
            ${NEW_TAG_INPUT_PHASE})
                ${docker_readInput_w_autocomplete_fpath} "${MENUTITLE}" \
                                    "${READMSG_NEW_REPOSITORY_TAG}" \
                                    "${readmsg_remarks}" \
                                    "${DOCKER__EMPTYSTRING}" \
                                    "${ERRMSG_NO_IMAGES_FOUND}" \
                                    "${DOCKER__EMPTYSTRING}" \
                                    "${docker__images_cmd}" \
                                    "${docker__images_tagColNo}" \
                                    "${DOCKER__EMPTYSTRING}" \
                                    "${docker__showTable}" \
                                    "${docker__onEnter_breakLoop}"
            
                #Retrieve the selected container-ID from file
                docker__tag_new=`get_output_from_file__func` 

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
                    show_errMsg_without_menuTitle__func "${ERRMSG_CHOSEN_REPO_PAIR_ALREADY_EXISTS}"

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
    local ECHOMSG_LOCATION_DOCKERFILE="${DOCKER__DIRS_FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR} docker-file: "
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
            show_list_with_menuTitle__func "${MENUTITLE_UPDATED_IMAGE_LIST}" "${docker__images_cmd}"
            
            #Exit this script
            exit__func
        elif [[ ${docker__myAnswer} == ${DOCKER__NO} ]]; then
            exit__func
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
    local ERRMSG_NO_REPO_FOUND="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: No matching ${DOCKER__NEW_REPOSITORY_FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR} found for ${DOCKER__IMAGEID_FG_BORDEAUX}ID${DOCKER__NOCOLOR} '${DOCKER__FG_LIGHTGREY}${docker__imageID_chosen}${DOCKER__NOCOLOR}'"
    local ERRMSG_NO_TAG_FOUND="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: No matching ${DOCKER__TAG_FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} found for ${DOCKER__IMAGEID_FG_BORDEAUX}ID${DOCKER__NOCOLOR} '${DOCKER__FG_LIGHTGREY}${docker__imageID_chosen}${DOCKER__NOCOLOR}'"
    local ERRMSG_NO_REPO_TAG_FOUND="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: No matching ${DOCKER__NEW_REPOSITORY_FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR} and ${DOCKER__TAG_FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} found for ${DOCKER__IMAGEID_FG_BORDEAUX}ID${DOCKER__NOCOLOR} '${DOCKER__FG_LIGHTGREY}${docker__imageID_chosen}${DOCKER__NOCOLOR}'"

    #Get repository
    docker__repo_chosen=`${docker__images_cmd} | grep -w ${docker__imageID_chosen} | awk -vcolNo=${docker__images_repoColNo} '{print $colNo}'`

    #Get tag
    docker__tag_chosen=`${docker__images_cmd} | grep -w ${docker__imageID_chosen} | awk -vcolNo=${docker__images_tagColNo} '{print $colNo}'`

    #Check if any of the value is an Empty String
    if [[ -z ${docker__repo_chosen} ]] && [[ -z ${docker__tag_chosen} ]]; then
        show_errMsg_without_menuTitle__func "${ERRMSG_NO_REPO_TAG_FOUND}"
    else
        if [[ -z ${docker__repo_chosen} ]]; then
            show_errMsg_without_menuTitle__func "${ERRMSG_NO_REPO_FOUND}"
        fi

        if [[ -z ${docker__tag_chosen} ]]; then
            show_errMsg_without_menuTitle__func "${ERRMSG_NO_TAG_FOUND}"
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

