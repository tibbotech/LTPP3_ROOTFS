#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---COLOR CONSTANTS
DOCKER__NOCOLOR=$'\e[0;0m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__IMAGEID_FG_BORDEAUX=$'\e[30;38;5;198m'
DOCKER__REPOSITORY_FG_PURPLE=$'\e[30;38;5;93m'
DOCKER__NEW_REPOSITORY_FG_BRIGHTLIGHTPURPLE=$'\e[30;38;5;147m'
DOCKER__TAG_FG_LIGHTPINK=$'\e[30;38;5;218m'
DOCKER__DIRS_FG_VERYLIGHTORANGE=$'\e[30;38;5;223m'

DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'
DOCKER__TITLE_BG_LIGHTBLUE='\e[30;48;5;45m'
DOCKER__DIRS_BG_VERYLIGHTORANGE=$'\e[30;48;5;223m'



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
DOCKER__QUIT="q"
DOCKER__REDO="r"


#---MENU CONSTANTS
DOCKER__R_REDO="${DOCKER__FOURSPACES}r. Redo"
DOCKER__Q_QUIT="${DOCKER__FOURSPACES}q. Quit (Ctrl+C)"
DOCKER__CTRL_C_QUIT="${DOCKER__FOURSPACES}Quit (Ctrl+C)"



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
	echo -e "\r"
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
	echo -e "\r"
}

function exit__func() {
    echo -e "\r"
    echo -e "\r"
    # echo -e ${DOCKER__EXITING_NOW}
    # echo -e "\r"
    # echo -e "\r"

    exit
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

function moveUp_and_cleanLines__func() {
    #Input args
    local numOf_lines_toBeCleared=${1}

    #Clear lines
    local numOf_lines_cleared=1
    while [[ ${numOf_lines_cleared} -le ${numOf_lines_toBeCleared} ]]
    do
        tput cuu1
        tput el

        numOf_lines_cleared=$((numOf_lines_cleared+1))  #increment by 1
    done
}

function moveDown_and_cleanLines__func() {
    #Input args
    local numOf_lines_toBeCleared=${1}

    #Clear lines
    local numOf_lines_cleared=1
    while [[ ${numOf_lines_cleared} -le ${numOf_lines_toBeCleared} ]]
    do
        tput cud1	#move UP with 1 line
        tput el1	#clear until the END of line

        numOf_lines_cleared=$((numOf_lines_cleared+1))  #increment by 1
    done
}



#---SUBROUTINES
CTRL_C__sub() {
    exit__func
}

docker__load_header__sub() {
    echo -e "\r"
    echo -e "${DOCKER__TITLE_BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__TITLE_BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__load_environment_variables__sub() {
    #Define paths
    docker__dockerfile_filename="dockerfile_auto"
    docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})
    docker__parent_dir=${docker__current_dir%/*}    #gets one directory up
    if [[ -z ${docker__parent_dir} ]]; then
        docker__parent_dir="${DOCKER__SLASH_CHAR}"
    fi
    docker__current_folder=`basename ${docker__current_dir}`

    docker__first_dir=${docker__parent_dir%/*}    #gets one directory up
    dockerfile_dir=${docker__first_dir}/docker/dockerfiles
    docker__dockerfile_fpath=${DOCKER__EMPTYSTRING}
    docker__mydockerfile_location=${DOCKER__EMPTYSTRING}

    docker__development_tools_folder="development_tools"
    if [[ ${docker__current_folder} != ${docker__development_tools_folder} ]]; then
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}/${docker__development_tools_folder}
    else
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}
    fi

	docker_repolist_tableinfo_filename="docker_repolist_tableinfo.sh"
	docker_repolist_tableinfo_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker_repolist_tableinfo_filename}
}

docker__init_variables__sub() {
    docker__myRepository=${DOCKER__EMPTYSTRING}
    docker__myRepository_new=${DOCKER__EMPTYSTRING}
    docker__myRepository_tags_detected=${DOCKER__EMPTYSTRING}
    docker__myRepository_firstTag_detected=${DOCKER__EMPTYSTRING}
    docker__myRepository_tag=${DOCKER__EMPTYSTRING}
    docker__myRepository_isFound=${DOCKER__EMPTYSTRING}
    docker__myRepository_new_isFound=${DOCKER__EMPTYSTRING}
    docker__myTag_isFound=${DOCKER__EMPTYSTRING}
}

docker__create_dirs__sub() {
    #Create directory if not present
    if [[ ! -d ${dockerfile_dir} ]]; then
        mkdir -p ${dockerfile_dir}
    fi
}

create_dockerfile__sub() {
    #Input args
    local dockerfile_input=${1}
    local repository_input=${2}
    local directory_input=${3}

    #Generate timestamp
    # local filename_w_timestamp=${dockerfile_input}_${repository_input}_${dockerfile_timestamp}
    local dockerfile_autogenerated=${dockerfile_input}_${repository_input}

    #Define filename
    docker__dockerfile_fpath=${directory_input}/${dockerfile_autogenerated}

    #Check if file exist
    #If TRUE, then remove file
    if [[ -f ${docker__dockerfile_fpath} ]]; then
        rm ${docker__dockerfile_fpath}
    fi

    #Define dockerfile content
    DOCKERFILE_CONTENT_ARR=(\
        "#---Continue from Repository:TAG=${docker__myRepository}:${docker__myRepository_tag}"\
        "FROM ${docker__myRepository}:${docker__myRepository_tag}"\
        ""\
        "#---LABEL about the custom image"\
        "LABEL maintainer=\"hien@tibbo.com\""\
        "LABEL version=\"0.1\""\
        "LABEL description=\"Continue from image '${docker__myRepository}:${docker__myRepository_tag}', and run 'build_BOOOT_BIN.sh'\""\
        "LABEL NEW repository:tag=\"${docker__myRepository_new}:${docker__myRepository_tag}\""\
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


    #Cycle thru array and write each row to Global variable 'docker__dockerfile_fpath'
	for ((i=0; i<${#DOCKERFILE_CONTENT_ARR[@]}; i++))
	do
        echo -e "${DOCKERFILE_CONTENT_ARR[$i]}" >> ${docker__dockerfile_fpath}
	done
}

docker__build_image_from_specified_repository__sub() {
    #Define local constants
    local MENUTITLE="Create an ${DOCKER__IMAGEID_FG_BORDEAUX}Image${DOCKER__NOCOLOR} from a ${DOCKER__REPOSITORY_FG_PURPLE}Repository${DOCKER__NOCOLOR}"
    local MENUTITLE_UPDATED_IMAGE_LIST="Updated ${DOCKER__IMAGEID_FG_BORDEAUX}Image${DOCKER__NOCOLOR}-list"
    
    #Define local message constants
    local ERRMSG_NO_IMAGES_FOUND="=:${DOCKER__ERROR_FG_LIGHTRED}NO IMAGES FOUND${DOCKER__NOCOLOR}:="

    #Define local read-input constants
    local READMSG_CHOOSE_A_REPOSITORY_FROM_LIST="Choose a ${DOCKER__REPOSITORY_FG_PURPLE}Repository${DOCKER__NOCOLOR} from list (e.g. ubuntu_buildbin): "
    local READMSG_DO_YOU_WISH_TO_CONTINUE="Do you wish to continue (y/n/r)? "
    local READMSG_PROVIDE_ITS_CORRESPONDING_TAG="Provide its matching ${DOCKER__TAG_FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} (e.g. latest): "
    local READMSG_NEW_REPOSITORY_NAME="${DOCKER__GENERAL_FG_YELLOW}New${DOCKER__NOCOLOR} ${DOCKER__NEW_REPOSITORY_FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR}'s name (e.g. ubuntu_buildbin_NEW): "

    #Define Local message variables
    local echoMsg="${DOCKER__DIRS_FG_VERYLIGHTORANGE}SAVE-TO${DOCKER__NOCOLOR}: ${dockerfile_dir}"
    local errMsg=${DOCKER__EMPTYSTRING}

    #Define local command variables
    local docker_image_ls_cmd="docker image ls"


    #Show Docker Image List
    #Get number of images
    local numof_images=`docker image ls | head -n -1 | wc -l`
    if [[ ${numof_images} -eq 0 ]]; then
        docker__show_errMsg_with_menuTitle__func "${MENUTITLE}" "${ERRMSG_NO_IMAGES_FOUND}"
    else
        docker__show_list_with_menuTitle__func "${MENUTITLE}" "${docker_image_ls_cmd}"
    fi 


    #Create timestamp
    # dockerfile_timestamp=$(date +%y%m%d%H%M%S)

    while true
    do
        #Provide a CONTAINER-ID from which you want to create an Image
        read -e -p "${READMSG_CHOOSE_A_REPOSITORY_FROM_LIST}" docker__myRepository
        if [[ ! -z ${docker__myRepository} ]]; then    #input is NOT an EMPTY STRING

            #Check if 'docker__myRepository' is found in ' docker container ls'
            docker__myRepository_isFound=`docker image ls | awk '{print $1}' | grep -w "${docker__myRepository}"`
            if [[ ! -z ${docker__myRepository_isFound} ]]; then    #match was found
                while true
                do
                    #Find tag belonging to 'docker__myRepository' (Exact Match)
                    docker__myRepository_tags_detected=$(docker image ls | grep -w "${docker__myRepository}" | awk '{print $2}')
                    docker__myRepository_firstTag_detected=`echo -e ${docker__myRepository_tags_detected} | cut -d" " -f1`
                    
                    #Provide a TAG for this new image
                    read -e -p "${READMSG_PROVIDE_ITS_CORRESPONDING_TAG}" -i ${docker__myRepository_firstTag_detected} docker__myRepository_tag
                    if [[ ! -z ${docker__myRepository_tag} ]]; then   #input is NOT an Empty String        

                        docker__myTag_isFound=`docker image ls | grep -w "${docker__myRepository}" | grep -w "${docker__myRepository_tag}"`    #check if 'docker__myRepository' AND 'docker__myRepository_tag' is found in 'docker image ls'
                        if [[ ! -z ${docker__myTag_isFound} ]]; then    #match was found

                            while true
                            do
                                #Provide a NEW Repository for the NEW image
                                read -e -p "${READMSG_NEW_REPOSITORY_NAME}" docker__myRepository_new
                                if [[ ! -z ${docker__myRepository_new} ]]; then #not an EMPTY STRING

                                    #Check if 'docker__myRepository' is UNIQUE
                                    docker__myRepository_new_isFound=`docker image ls | awk '{print $1}' | grep -w "${docker__myRepository_new}"`
                                    if  [[ -z ${docker__myRepository_new_isFound} ]]; then    #match was NOT found

                                        while true
                                        do
                                            #Provide a location where you want to create a *NEW DOCKERFILE*
                                            echo -e "${echoMsg}"

                                            #Confirm if user wants to continue
                                            while true
                                            do
                                                #Add an empty-line
                                                echo -e "\r"
                                                
                                                #Show read-input message
                                                read -N1 -p "${READMSG_DO_YOU_WISH_TO_CONTINUE}" docker__myanswer
                                                
                                                #Validate read-input answer
                                                if [[ ${docker__myanswer} == ${DOCKER__YES} ]]; then
                                                    #Create directory if NOT exist yet
                                                    if [[ ! -d ${dockerfile_dir} ]]; then
                                                        mkdir -p ${dockerfile_dir}
                                                    fi

                                                    #Generate a 'dockerfile' with content
                                                    #OUTPUT: docker__dockerfile_fpath
                                                    create_dockerfile__sub "${docker__dockerfile_filename}" ${docker__myRepository_new} "${dockerfile_dir}"

                                                    #Execute command
                                                    docker build --tag ${docker__myRepository_new}:${docker__myRepository_tag} - < ${docker__dockerfile_fpath}
                                                    
                                                    #Show Updated Image-list
                                                    echo -e "\r"

                                                    docker__show_list_with_menuTitle__func "${MENUTITLE_UPDATED_IMAGE_LIST}" "${docker_image_ls_cmd}"

                                                    echo -e "\r"
                                                    echo -e "\r"

                                                    exit

                                                elif [[ ${docker__myanswer} == ${DOCKER__NO} ]]; then
                                                    exit__func
                                                elif [[ ${docker__myanswer} == ${DOCKER__REDO} ]]; then
                                                    break
                                                elif [[ ${docker__myanswer} == ${DOCKER__QUIT} ]]; then
                                                    exit__func   
                                                else
                                                    if [[ ${docker__myanswer} != "${DOCKER__ENTER}" ]]; then
                                                        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                                                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"    
                                                    else
                                                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"              
                                                    fi                                                                                                                             
                                                fi
                                            done

                                            #Answer 'r' was given in the LAST while-loop
                                            if [[ ${docker__myanswer} == ${DOCKER__REDO} ]]; then
                                                break
                                            fi
                                        done
                                    else
                                        errMsg="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Repository '${DOCKER__REPOSITORY_FG_PURPLE}${docker__myRepository_new}${DOCKER__NOCOLOR}' already Exist!!!"
                                        
                                        docker__show_errMsg_without_menuTitle__func "${errMsg}"

                                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_5}"
                                    fi
                                else
                                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                                fi

                                #Answer 'r' was given in the LAST while-loop
                                if [[ ${docker__myanswer} == ${DOCKER__REDO} ]]; then
                                    break
                                fi
                            done
                        else    #input was an Empty String
                            errMsg="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Un-matched pair ${DOCKER__REPOSITORY_FG_PURPLE}Repository${DOCKER__NOCOLOR} <-> ${DOCKER__TAG_FG_LIGHTPINK}Tag${DOCKER__NOCOLOR}"
                            
                            docker__show_errMsg_without_menuTitle__func "${errMsg}"

                            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_5}"
                        fi
                    else
                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                    fi

                    #Answer 'n' was given in the LAST while-loop
                    if [[ ${docker__myanswer} == ${DOCKER__REDO} ]]; then
                        echo -e "\r"
                        echo -e "\r"
                        
                        docker__show_list_with_menuTitle__func "${MENUTITLE}" "${docker_image_ls_cmd}"

                        break
                    fi
                done
            else    #NO match was found
                errMsg="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Repository-ID '${DOCKER__REPOSITORY_FG_PURPLE}${docker__myRepository}${DOCKER__NOCOLOR}' Not Found"

                docker__show_errMsg_without_menuTitle__func "${errMsg}"

                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_5}"               
            fi
        else
            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        fi
    done
}

function docker__show_list_with_menuTitle__func() {
    #Input args
    local menuTitle=${1}
    local dockerCmd=${2}

    #Show list
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${menuTitle}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    
    ${docker_repolist_tableinfo_fpath}

    echo -e "\r"

    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${DOCKER__CTRL_C_QUIT}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
}

function docker__show_errMsg_with_menuTitle__func() {
    #Input args
    local menuTitle=${1}
    local errMsg=${2}

    #Show error-message
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${menuTitle}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    
    echo -e "\r"
    show_centered_string__func "${errMsg}" "${DOCKER__TABLEWIDTH}"
    echo -e "\r"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "\r"

    press_any_key__func

    CTRL_C__sub
}

function docker__show_errMsg_without_menuTitle__func() {
    #Input args
    local errMsg=${1}

    echo -e "\r"
    echo -e "${errMsg}"

    press_any_key__func
}



#---MAIN SUBROUTINE
main_sub() {
    docker__load_header__sub

    docker__load_environment_variables__sub

    docker__init_variables__sub

    docker__create_dirs__sub

    docker__build_image_from_specified_repository__sub
}



#---EXECUTE
main_sub

