#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---PATTERN CONSTANTS
DOCKER__PATTERN1="repository:tag"



#---FUNCTIONS
function create_image__func() {
    #Input args
    local dockerfile_fpath=${1}

    #Define local constants
    local GREP_PATTERN="LABEL repository:tag"
    local MENUTITLE_UPDATED_IMAGE_LIST="Updated ${DOCKER__FG_BORDEAUX}IMAGE${DOCKER__NOCOLOR}-list"

    #Define local message variables
    local statusMsg="---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Creating image..."

    #Define local command variables
    local docker_image_ls_cmd="docker image ls"

    #Get REPOSITORY:TAG from dockerfile
    local dockerfile_repository_tag=`egrep -w "${GREP_PATTERN}" ${dockerfile_fpath} | cut -d"\"" -f2`

    #Check if 'dockerfile_repository_tag' is an EMPTY STRING
    if [[ -z ${dockerfile_repository_tag} ]]; then
        dockerfile_repository_tag="${dockerfile}:${DOCKER__LATEST}"
    fi

    #Execute Docker command
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${statusMsg}"
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    docker build --tag ${dockerfile_repository_tag} - < ${dockerfile_fpath}

    #Validate executed command
    validate_exitCode__func

    #Print docker image list
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    show_list_with_menuTitle__func "${MENUTITLE_UPDATED_IMAGE_LIST}" "${docker__images_cmd}"
    
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
docker__mandatory_apps_check__sub() {
    #Define local constants
    local DOCKER_IO="docker.io"
    local QEMU_USER_STATIC="qemu-user-static"

    local docker_io_isInstalled=`dpkg -l | grep "${DOCKER_IO}"`
    local qemu_user_static_isInstalled=`dpkg -l | grep "${QEMU_USER_STATIC}"`

    if [[ -z ${docker_io_isInstalled} ]] || [[ -z ${qemu_user_static_isInstalled} ]]; then
        echo -e "${DOCKER__FOURSPACES}The following mandatory software is/are not installed:"
        if [[ -z ${docker_io_isInstalled} ]]; then
            echo -e "${DOCKER__FOURSPACES}- docker.io"
        fi
        if [[ -z ${qemu_user_static_isInstalled} ]]; then
            echo -e "${DOCKER__FOURSPACES}- qemu-user-static"
        fi
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "${DOCKER__FOURSPACES}PLEASE INSTALL the missing software."
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        
        press_any_key__func
    fi
}

docker__load_environment_variables__sub() {
    docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})
    docker__parent_dir=${docker__current_dir%/*}    #gets one directory up
    if [[ -z ${docker__parent_dir} ]]; then
        docker__parent_dir="${DOCKER__SLASH_CHAR}"
    fi
    #Define local variables
    docker_current_script_filename=`basename $0`

    docker__my_LTPP3_ROOTFS_docker_dir=${docker__parent_dir}/docker
    docker__my_LTPP3_ROOTFS_docker_list_dir=${docker__my_LTPP3_ROOTFS_docker_dir}/list
    docker__my_LTPP3_ROOTFS_docker_dockerfiles_dir=${docker__my_LTPP3_ROOTFS_docker_dir}/dockerfiles

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
}

docker__load_source_files__sub() {
    source ${docker__global_functions_fpath}
}

docker__load_header__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${DOCKER__BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__init_variables__sub() {
    docker__dockerList_fpath=""
    docker__dockerList_filename=""
    docker__flagExitLoop=false

    docker__images_cmd="docker images"
}

docker__show_dockerList_files__sub() {
    #Define local constants
    local MENUTITLE="${DOCKER__FG_YELLOW}Create${DOCKER__NOCOLOR} multiple ${DOCKER__FG_BORDEAUX}IMAGES${DOCKER__NOCOLOR} using a ${DOCKER__FG_LIGHTBLUE}docker-list${DOCKER__NOCOLOR}"

    #Define local variables
    local dockerlist_filename=""
    local listOf_dockerListFpaths_string=""
    local listOf_dockerListFpaths_arr=()
    local listOf_dockerListFpaths_arrItem=""

    #Define local message variables
    local errMsg1="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: No files found in directory:"
    local errMsg2="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}${docker__my_LTPP3_ROOTFS_docker_list_dir}${DOCKER__NOCOLOR}"
    local errMsg3="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Please put all ${DOCKER__FG_YELLOW}dockerfile-list${DOCKER__NOCOLOR} files in this directory"

    local locationMsg_dockerList="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR}: ${docker__my_LTPP3_ROOTFS_docker_list_dir}"
    local locationMsg_dockerfiles="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR}: ${docker__my_LTPP3_ROOTFS_docker_dockerfiles_dir}"

    #Define local read-input variables
    local readInput_msg1="Choose a file: "
    local readInput_msg2="Do you wish to continue (y/n): "

    #Get all files at the specified location
    listOf_dockerListFpaths_string=`find ${docker__my_LTPP3_ROOTFS_docker_list_dir} -maxdepth 1 -type f | LC_ALL=C sort`
    if [[ -z ${listOf_dockerListFpaths_string} ]]; then
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "${errMsg1}"
        echo -e "${errMsg2}"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "${errMsg3}"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        exit 99
    fi


    #Convert string to array (with space delimiter)
    listOf_dockerListFpaths_arr=(${listOf_dockerListFpaths_string})

    #Start loop
    while true
    do
        #Initial sequence number
        local seqnum=0

        #Show all 'dockerfile-list' files
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        show_centered_string__func "${MENUTITLE}" "${DOCKER__TABLEWIDTH}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        for listOf_dockerListFpaths_arrItem in "${listOf_dockerListFpaths_arr[@]}"
        do
            #increment sequence-number
            seqnum=$((seqnum+1))

            #Get filename only
            dockerlist_filename=`basename ${listOf_dockerListFpaths_arrItem}`  
        
            #Show filename
            echo -e "${DOCKER__FOURSPACES}${seqnum}. ${dockerlist_filename}"
        done

        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${locationMsg_dockerList}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__Q_QUIT}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Read-input handler
        while true
        do
            #Show read-input
            if [[ ${seqnum} -le ${DOCKER__NINE} ]]; then    #seqnum <= 9
                read -N1 -p "${readInput_msg1}" mychoice
            else    #seqnum > 9
                read -p "${readInput_msg1}" mychoice
            fi

            #Check if 'mychoice' is a numeric value
            if [[ ${mychoice} =~ [1-90q] ]]; then
                #check if 'mychoice' is one of the numbers shown in the overview...
                #... AND 'mychoice' is NOT '0'
                if [[ ${mychoice} -le ${seqnum} ]] && [[ ${mychoice} -ne 0 ]]; then
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"    #print an empty line

                    break   #exit loop
                elif [[ ${mychoice} == ${DOCKER__QUIT} ]]; then
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

                    exit
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

        #Extract the chosen file from array and assign to the GLOBAL variable 'docker__dockerList_fpath'
        docker__dockerList_fpath=${listOf_dockerListFpaths_arr[index]}
        docker__dockerList_filename=`basename ${docker__dockerList_fpath}`

        #Show chosen file contents
        local subMenuTitle="Contents of File ${DOCKER__FG_ORANGE}${docker__dockerList_filename}${DOCKER__NOCOLOR}"

        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        show_centered_string__func "${subMenuTitle}" "${DOCKER__TABLEWIDTH}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        while read file_line
        do
            echo -e "${DOCKER__FOURSPACES}${file_line}"

        done < ${docker__dockerList_fpath}
        
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${locationMsg_dockerfiles}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__A_ABORT}"
        echo -e "${DOCKER__Q_QUIT}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Read-input handler
        while true
        do
            #Show read-input
            read -N1 -p "${readInput_msg2}" mychoice

            #Check if 'mychoice' is a numeric value
            if [[ ${mychoice} =~ [ynbq] ]]; then
                #print 2 empty lines
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

                if [[ ${mychoice} == ${DOCKER__YES} ]]; then
                    return  #exit function
                elif [[ ${mychoice} == ${DOCKER__NO} ]] || [[ ${mychoice} == ${DOCKER__QUIT} ]]; then
                    CTRL_C__sub #same as Ctrl+C
                elif [[ ${mychoice} == ${DOCKER__BACK} ]]; then
                    break
                else
                    break   #exit THIS loop
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
    done   
}

docker__create_image_handler__sub() {
    #---Read contents of the file
    #Each line of the file represents a 'dockerfile' containing the instructions to-be-executed
    
    #Define local variables
    local linenum=1
    local dockerfile_fpath=""

    #Initialization
    docker__flagExitLoop=true

    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    while IFS='' read file_line
    do
        if [[ ${linenum} -gt 1 ]]; then #skip the header
            #Get the fullpath
            dockerfile_fpath=${docker__my_LTPP3_ROOTFS_docker_dockerfiles_dir}/${file_line}

            #Check if file exists
            if [[ -f ${dockerfile_fpath} ]]; then
                #Get repository-name
                local repoName=`cat ${dockerfile_fpath} | awk '{print $2}'| grep "${DOCKER__PATTERN1}" | cut -d"\"" -f2 | cut -d":" -f1`
                #Get tag belonging to the previously retrieved repository-name
                local tag=`cat ${dockerfile_fpath} | awk '{print $3}'| grep "${DOCKER__PATTERN1}" | cut -d"\"" -f2 | cut -d":" -f2`
                #Check if the repository-name & tag pair is already created
                local isFound=`repo_exists__func "${repoName}" "${tag}"`
                if [[ ${isFound} == true ]]; then
                    local statusMsg="---:${DOCKER__FG_ORANGE}UPDATE${DOCKER__NOCOLOR}: '${file_line}' already executed..."
                    echo -e "${statusMsg}"

                    docker__flagExitLoop=false
                else
                    create_image__func ${dockerfile_fpath}
                fi
            else
                local errMsg="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: non-existing file: ${dockerfile_fpath}"

                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                echo -e "${errMsg}"
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"       
            fi
        fi

        linenum=$((linenum+1))  #increment index by 1
    done < ${docker__dockerList_fpath}

    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
}



#---MAIN SUBROUTINE
main_sub() {
    docker__load_environment_variables__sub

    docker__load_source_files__sub

    docker__load_header__sub

    docker__init_variables__sub

    docker__mandatory_apps_check__sub

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
