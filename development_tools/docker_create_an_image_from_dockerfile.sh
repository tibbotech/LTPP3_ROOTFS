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
    # local docker_ps_a_cmd="docker ps -a"
    local docker__images_cmd="docker images"
    local exported_env_var1=${DOCKER__EMPTYSTRING}
    local exported_env_var2=${DOCKER__EMPTYSTRING}

    #Get REPOSITORY:TAG from dockerfile
    local dockerfile_repository_tag=`egrep -w "${GREP_PATTERN}" ${dockerfile_fpath} | cut -d"\"" -f2`

    #Check if 'dockerfile_repository_tag' is an EMPTY STRING
    if [[ -z ${dockerfile_repository_tag} ]]; then  #is an Empty String
        #Set a value for 'dockerfile_repository_tag'
        dockerfile_repository_tag="${dockerfile}:${DOCKER__LATEST}"
    else    #is Not an Empty String
        #Retrieve to-be-exported Environment variables
        exported_env_var1=`retrieve_sunplus_gitLink_from_file__func "${dockerfile_fpath}" "${docker__exported_env_var_fpath}"`
        exported_env_var2=`retrieve_sunplus_gitCheckout_from_file__func "${dockerfile_fpath}" "${docker__exported_env_var_fpath}"`
    fi

    #Print
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${statusMsg}"
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    # docker build --tag ${dockerfile_repository_tag} - < ${dockerfile_fpath} #with REPOSITORY:TAG
    
    #Remark:
    #   DOCKER_ARG1: argument defined in the dockerfile(s) (e.g. sunplus_inst.sh)
    #   HOST_EXPORTED_ARG1: exported variable in defined in the HOST device (e.g. sunplus git clone link)
    docker build --build-arg DOCKER_ARG1=${exported_env_var1} --build-arg DOCKER_ARG2=${exported_env_var2} --tag ${dockerfile_repository_tag} - < ${dockerfile_fpath} #with REPOSITORY:TAG

    #Validate executed command
    validate_exitCode__func

    #Print docker image list
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    show_cmdOutput_w_menuTitle__func "${MENUTITLE_UPDATED_CONTAINER_LIST}" "${docker__images_cmd}"
    
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
}

function repo_exists__func() {
	#Input args
	local repoName__input=${1}
	local tag__input=${2}

    #Read Docker image-info to Array
    local tmp_arr=()
    readarray -t tmp_arr < <(docker images)

    #Loop through Array
    local tmp_arrItem=${DOCKER__EMPTYSTRING}
    local tmp_arrItem_repoName=${DOCKER__EMPTYSTRING}
    local tmp_arrItem_tag=${DOCKER__EMPTYSTRING}
    for tmp_arrItem in "${tmp_arr[@]}"
    do
        tmp_arrItem_repoName=`echo "${tmp_arrItem}" | awk '{print $1}'`
        tmp_arrItem_tag=`echo "${tmp_arrItem}" | awk '{print $3}'`

        if [[ "${repoName__input}" == "${tmp_arrItem_repoName}" ]]; then
            if [[ "${tag__input}" == "${tmp_arrItem_tag}" ]]; then
                echo "true"

                return
            fi            
        fi
    done

    #No match
    echo "false"
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
    docker__LTPP3_ROOTFS_docker_dockerfiles__dir=${docker__my_LTPP3_ROOTFS_docker_dir}/dockerfiles

    docker__development_tools_folder="development_tools"
    if [[ ${docker__current_folder} != ${docker__development_tools_folder} ]]; then
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}/${docker__development_tools_folder}
    else
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}
    fi

    docker__global_filename="docker_global.sh"
    docker__global__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global_filename}
}

docker__load_source_files__sub() {
    source ${docker__global__fpath}
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
    local errMsg2="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}${docker__LTPP3_ROOTFS_docker_dockerfiles__dir}${DOCKER__NOCOLOR}"
    local errMsg3="***${DOCKER__FG_PURPLERED}MANDATORY${DOCKER__NOCOLOR}: All ${DOCKER__FG_YELLOW}dockerfile${DOCKER__NOCOLOR} files should be put in this directory"
    local locationMsg_dockerfiles="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR}: ${docker__LTPP3_ROOTFS_docker_dockerfiles__dir}"

    #Define local read-input variables
    local readInput_msg="Choose a file: "


    #Get all files at the specified location
    listOf_dockerFileFpaths_string=`find ${docker__LTPP3_ROOTFS_docker_dockerfiles__dir} -maxdepth 1 -type f | sort`
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
    echo -e "${DOCKER__FOURSPACES_Q_QUIT}"
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
        local tag=`cat ${docker__dockerFile_fpath} | awk '{print $2}'| grep "${DOCKER__PATTERN1}" | cut -d"\"" -f2 | cut -d":" -f2`
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
