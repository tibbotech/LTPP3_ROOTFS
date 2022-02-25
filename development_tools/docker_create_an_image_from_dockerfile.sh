#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---PATTERN CONSTANTS
DOCKER__PATTERN1="repository:tag"



#---FUNCTIONS
function create_image__func() {
    #Input args
    local dockerfile_fpath=${1}

    #Define local constants
    local MENUTITLE_UPDATED_CONTAINER_LIST="Updated ${DOCKER__FG_BORDEAUX}Image${DOCKER__NOCOLOR}-list"
    local GREP_PATTERN="LABEL repository:tag"

    #Define local message variables
    local statusMsg="---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Creating image..."

    #Define local command variables
    local docker_ps_a_cmd="docker ps -a"
    


    #Get REPOSITORY:TAG from dockerfile
    local dockerfile_repository_tag=`egrep -w "${GREP_PATTERN}" ${dockerfile_fpath} | cut -d"\"" -f2`

    #Check if 'dockerfile_repository_tag' is an EMPTY STRING
    if [[ -z ${dockerfile_repository_tag} ]]; then
        dockerfile_repository_tag="${dockerfile}:${DOCKER__LATEST}"
    fi

    #Print
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${statusMsg}"
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    docker build --tag ${dockerfile_repository_tag} - < ${dockerfile_fpath} #with REPOSITORY:TAG
    
    #Validate executed command
    validate_exitCode__func

    #Print docker image list
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    show_list_with_menuTitle__func "${MENUTITLE_UPDATED_CONTAINER_LIST}" "${docker_ps_a_cmd}"
    
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
}

function repo_exists__func() {
	#Input args
	local repoName__input=${1}
	local tag__input=${2}

	#Check if imageID is found in container's list
	local stdOutput=`docker images | grep "${repoName__input}" | grep "${tag__input}"`
	if [[ ! -z ${stdOutput} ]]; then
		echo "true"
	else
		echo "false"
	fi
}

function validate_exitCode__func() {
    #Define local message variables
    local successMsg="---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Image was created ${DOCKER__FG_LIGHTGREEN}successfully${DOCKER__NOCOLOR}..."
    local errMsg="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Unable to create Image"

    #Get exit-code of the latest executed command
    exit_code=$?
    if [[ ${exit_code} -eq 0 ]]; then
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "${successMsg}"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    else
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "${errMsg}"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        # echo -e "${DOCKER__EXITING_NOW}"
        # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

        exit
    fi
}



#---SUBROUTINES
docker__load_environment_variables__sub() {
    docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})
    docker__parent_dir=${docker__current_dir%/*}    #gets one directory up
    if [[ -z ${docker__parent_dir} ]]; then
        docker__parent_dir="${DOCKER__SLASH_CHAR}"
    fi
    docker_current_script_filename=`basename $0`
	docker__current_folder=`basename ${docker__current_dir}`

    docker__my_LTPP3_ROOTFS_docker_dir=${docker__parent_dir}/docker
    docker__my_LTPP3_ROOTFS_docker_dockerfiles_dir=${docker__my_LTPP3_ROOTFS_docker_dir}/dockerfiles

    docker__development_tools_folder="development_tools"
    if [[ ${docker__current_folder} != ${docker__development_tools_folder} ]]; then
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}/${docker__development_tools_folder}
    else
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}
    fi

    docker__global_functions_filename="docker_global_functions.sh"
    docker__global_functions_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global_functions_filename}

    docker__containerlist_tableinfo_filename="docker_containerlist_tableinfo.sh"
    docker__containerlist_tableinfo_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__containerlist_tableinfo_filename}
	docker__repolist_tableinfo_filename="docker_repolist_tableinfo.sh"
	docker__repolist_tableinfo_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__repolist_tableinfo_filename}
}

docker__load_source_files__sub() {
    source ${docker__global_functions_fpath}
}

docker__load_header__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${DOCKER__BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__init_variables__sub() {
    docker__dockerFile_fpath=""
    docker__dockerFile_filename=""
    docker__flagExitLoop=false
}

docker__show_dockerList_files__sub() {
    #Define local constants
    local MENUTITLE="${DOCKER__FG_YELLOW}Create${DOCKER__NOCOLOR} an ${DOCKER__FG_BORDEAUX}Image${DOCKER__NOCOLOR} using a ${DOCKER__FG_DARKBLUE}docker-file${DOCKER__NOCOLOR}"

    #Define local variables
    local listOf_dockerFileFpaths_string=""
    local listOf_dockerFileFpaths_arr=()
    local listOf_dockerFileFpaths_arrItem=""
    local extract_filename=""
    local seqnum=0

    #Define local message variables
    local errMsg1="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: No files found at location:"
    local errMsg2="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}${docker__my_LTPP3_ROOTFS_docker_dockerfiles_dir}${DOCKER__NOCOLOR}"
    local errMsg3="***${DOCKER__FG_PURPLERED}MANDATORY${DOCKER__NOCOLOR}: All ${DOCKER__FG_YELLOW}dockerfile-list${DOCKER__NOCOLOR} files should be put in this directory"
    local locationMsg_dockerfiles="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR}: ${docker__my_LTPP3_ROOTFS_docker_dockerfiles_dir}"

    #Define local read-input variables
    local readInput_msg="Choose a file: "


    #Get all files at the specified location
    listOf_dockerFileFpaths_string=`find ${docker__my_LTPP3_ROOTFS_docker_dockerfiles_dir} -maxdepth 1 -type f | sort`
    if [[ -z ${listOf_dockerFileFpaths_string} ]]; then
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "${errMsg1}"
        echo -e "${errMsg2}"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "${errMsg3}"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        exit 99
    fi

    #Convert string to array (with space delimiter)
    listOf_dockerFileFpaths_arr=(${listOf_dockerFileFpaths_string})


    #Show menu-title
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${MENUTITLE}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    for listOf_dockerFileFpaths_arrItem in "${listOf_dockerFileFpaths_arr[@]}"
    do
        #increment sequence-number
        seqnum=$((seqnum+1))

        #Get filename only
        extract_filename=`basename ${listOf_dockerFileFpaths_arrItem}`  
    
        #Show filename
        echo -e "${DOCKER__FOURSPACES}${seqnum}. ${extract_filename}"
    done

    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${locationMsg_dockerfiles}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${DOCKER__Q_QUIT}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Read-input handler
    while true
    do
        #Show read-input
        if [[ ${seqnum} -le ${DOCKER__NINE} ]]; then    #seqnum <= 9
            read -N1 -p "${readInput_msg} " mychoice
        else    #seqnum > 9
            read -p "${readInput_msg} " mychoice
        fi

        #Check if 'mychoice' is a numeric value
        if [[ ${mychoice} =~ [1-90q] ]]; then
            #check if 'mychoice' is one of the numbers shown in the overview...
            #... AND 'mychoice' is NOT '0'
            if [[ ${mychoice} == ${DOCKER__QUIT} ]]; then
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

                exit 90
            elif [[ ${mychoice} -le ${seqnum} ]] && [[ ${mychoice} -ne 0 ]]; then
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"    #print an empty line

                break   #exit loop
            else
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"    
            fi
        else
            if [[ ${mychoice} != "${DOCKER__ENTER}" ]]; then
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"   
            else
                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"             
            fi
        fi
    done

    #Since arrays start with index=0, deduct 'mychoice' value by '1'
    index=$((mychoice-1))

    #Extract the chosen file from array and assign to the GLOBAL variable 'docker__dockerFile_fpath'
    docker__dockerFile_fpath=${listOf_dockerFileFpaths_arr[index]}
}

docker__create_image_handler__sub() {
    if [[ -f ${docker__dockerFile_fpath} ]]; then
        #Get repository-name
        local repoName=`cat ${docker__dockerFile_fpath} | awk '{print $2}'| grep "${DOCKER__PATTERN1}" | cut -d"\"" -f2 | cut -d":" -f1`
        #Get tag belonging to the previously retrieved repository-name
        local tag=`cat ${docker__dockerFile_fpath} | awk '{print $3}'| grep "${DOCKER__PATTERN1}" | cut -d"\"" -f2 | cut -d":" -f2`
        #Check if the repository-name & tag pair is already created
        local isFound=`repo_exists__func "${repoName}" "${tag}"`
        if [[ ${isFound} == true ]]; then
            local docker_filename=`basename ${docker__dockerFile_fpath}`
            local statusMsg="---:${DOCKER__FG_ORANGE}UPDATE${DOCKER__NOCOLOR}: '${docker_filename}' already executed..."
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
            echo -e "${statusMsg}"
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            docker__flagExitLoop=false
        else
            docker__flagExitLoop=true

            create_image__func ${docker__dockerFile_fpath}
        fi
    else
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: File '${DOCKER__FG_DARKBLUE}${docker__dockerFile_fpath}${DOCKER__NOCOLOR}' does ${DOCKER__FG_LIGHTRED}Not${DOCKER__NOCOLOR} exist"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"       
    fi
}



#---MAIN SUBROUTINE
main_sub() {
    docker__load_environment_variables__sub

    docker__load_source_files__sub

    docker__load_header__sub

    docker__init_variables__sub

    while true
    do
        docker__show_dockerList_files__sub

        docker__create_image_handler__sub

        if [[ ${docker__flagExitLoop} == true ]]; then
            break
        fi
    done
}



#---EXECUTE
main_sub
