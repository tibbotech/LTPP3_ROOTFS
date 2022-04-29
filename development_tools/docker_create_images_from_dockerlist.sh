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
    local exported_env_var1=${DOCKER__EMPTYSTRING}
    local exported_env_var2=${DOCKER__EMPTYSTRING}

    #Get REPOSITORY:TAG from dockerfile
    local dockerfile_repository_tag=`egrep -w "${GREP_PATTERN}" ${dockerfile_fpath} | cut -d"\"" -f2`

    #Check if 'dockerfile_repository_tag' is an EMPTY STRING
    if [[ -z ${dockerfile_repository_tag} ]]; then
        dockerfile_repository_tag="${dockerfile}:${DOCKER__LATEST}"
    fi

    #Check if 'dockerfile_repository_tag' is an EMPTY STRING
    if [[ -z ${dockerfile_repository_tag} ]]; then  #is an Empty String
        #Set a value for 'dockerfile_repository_tag'
        dockerfile_repository_tag="${dockerfile}:${DOCKER__LATEST}"
    else    #is Not an Empty String
        #Retrieve to-be-exported Environment variables
        exported_env_var1=`cat ${docker__exported_env_var_fpath} | grep -w "${dockerfile_repository_tag}" | awk '{print $2}'`
        exported_env_var2=`cat ${docker__exported_env_var_fpath} | grep -w "${dockerfile_repository_tag}" | awk '{print $3}'`
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

    show_cmdOutput_w_menuTitle__func "${MENUTITLE_UPDATED_IMAGE_LIST}" "${docker__images_cmd}"
    
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

    docker__global_filename="docker_global.sh"
    docker__global__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global_filename}
}

docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

docker__load_header__sub() {
    show_header__func "${DOCKER__TITLE}" "${DOCKER__TABLEWIDTH}" "${DOCKER__BG_ORANGE}" "${DOCKER__NUMOFLINES_2}" "${DOCKER__NUMOFLINES_0}"
}

docker__load_constants__sub() {
    DOCKER__DIR_MENUTITLE="${DOCKER__FG_YELLOW}Create${DOCKER__NOCOLOR} multiple ${DOCKER__FG_BORDEAUX}IMAGES${DOCKER__NOCOLOR} using a ${DOCKER__FG_LIGHTBLUE}docker-list${DOCKER__NOCOLOR}"
    DOCKER__DIR_REMARK=${DOCKER__EMPTYSTRING}
    DOCKER__DIR_LOCATIONINFO="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR}: ${docker__LTPP3_ROOTFS_docker_dockerfiles__dir}"
    DOCKER__DIR_ERRMSG="${DOCKER__FOURSPACES}-:${DOCKER__FG_LIGHTRED}Directory is Empty${DOCKER__NOCOLOR}:-"
    DOCKER__DIR_READDIALOG="Choose a file: "

    DOCKER__FILE_MENUTITLE="Show ${DOCKER__FG_VERYLIGHTORANGE}file${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}-${DOCKER__NOCOLOR}content"
    DOCKER__FILE_READDIALOG="Do you wish to continue (y/n/b): "
    DOCKER__FILE_REMARK=${DOCKER__EMPTYSTRING}
    DOCKER__FILE_MENUOPTIONS="${DOCKER__FOURSPACES_Y_YES}\n"
    DOCKER__FILE_MENUOPTIONS+="${DOCKER__FOURSPACES_N_NO}\n"
    DOCKER__FILE_MENUOPTIONS+="${DOCKER__FOURSPACES_B_BACK}\n"
    DOCKER__FILE_MENUOPTIONS+="${DOCKER__FOURSPACES_F12_QUIT}"
    DOCKER__FILE_ERRMSG="${DOCKER__FOURSPACES}-:${DOCKER__FG_LIGHTRED}File is Empty${DOCKER__NOCOLOR}:-"
}

docker__init_variables__sub() {
    docker__dockerList_fpath=${DOCKER__EMPTYSTRING}
    docker__dockerList_filename=${DOCKER__EMPTYSTRING}
    docker__file_locationInfo=${DOCKER__EMPTYSTRING}
    docker__myAnswer=${DOCKER__NO}
    docker__submenuTitle=${DOCKER__EMPTYSTRING}
    docker__flagExitLoop=false
}

docker__show_dockerList_files_handler__sub() {
    #Start loop
    while true
    do
        #Show Tibbo-header
        docker__load_header__sub

        #Show dockerList files
        docker__show_dockerList_files__sub

        #Get filename 'docker__dockerList_filename' from fullpath 'docker__dockerList_fpath'
        docker__dockerList_filename=`basename ${docker__dockerList_fpath}`

        #Update variables
        docker__file_locationInfo="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}File${DOCKER__NOCOLOR}: ${docker__dockerList_filename}"



        #Move-down and clean lines
        # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"



        #Show Tibbo-header
        docker__load_header__sub

        #Show file content
        show_fileContent_wo_keyInput__func "${docker__dockerList_fpath}" \
                        "${DOCKER__FILE_MENUTITLE}" \
                        "${DOCKER__FILE_REMARK}" \
                        "${docker__file_locationInfo}" \
                        "${DOCKER__FILE_MENUOPTIONS}" \
                        "${DOCKER__FILE_ERRMSG}" \
                        "${DOCKER__FILE_READDIALOG}" \
                        "${docker__create_images_from_dockerlist_out__fpath}" \
                        "${DOCKER__TABLEROWS}"

        #Get the exitcode just in case a Ctrl-C was pressed in function 'show_fileContent_wo_keyInput__func' (in script 'docker_global.sh')
        docker__exitCode=$?
        if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
            exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
        fi

        #Get result from file.
        docker__myAnswer=`get_output_from_file__func \
                            "${docker__create_images_from_dockerlist_out__fpath}" \
                            "${DOCKER__LINENUM_1}"`

        #Check if 'docker__myAnswer' is a numeric value
        case "${docker__myAnswer}" in
            ${DOCKER__YES})
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

                return
                ;;
            ${DOCKER__NO})
                exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_2}"
                ;;
            *)
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                ;;
        esac
    done
}
docker__show_dockerList_files__sub() {
    #Show directory content
    show_pathContent_w_keyInput__func "${docker__my_LTPP3_ROOTFS_docker_list_dir}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${DOCKER__DIR_MENUTITLE}" \
                        "${DOCKER__DIR_REMARK}" \
                        "${DOCKER__DIR_LOCATIONINFO}" \
                        "${DOCKER__FOURSPACES_F12_QUIT}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${DOCKER__DIR_ERRMSG}" \
                        "${DOCKER__DIR_READDIALOG}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${DOCKER__TABLEROWS}" \
                        "${docker__create_images_from_dockerlist_out__fpath}"

    #Get the exitcode just in case a Ctrl-C was pressed in function 'show_fileContent_wo_keyInput__func' (in script 'docker_global.sh')
    docker__exitCode=$?
    if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
        exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
    fi

    #Get result from file.
    docker__dockerList_fpath=`get_output_from_file__func \
                        "${docker__create_images_from_dockerlist_out__fpath}" \
                        "${DOCKER__LINENUM_1}"`

    #Double-check if 'docker__dockerFile_fpath = F12'
    if [[ ${docker__dockerList_fpath} == ${DOCKER__ENUM_FUNC_F12} ]]; then
        exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_2}"
    else
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    fi
}

docker__create_image_handler__sub() {
    #---Read contents of the file
    #Each line of the file represents a 'dockerfile' containing the instructions to-be-executed
    
    #Define local variables
    local linenum=1
    local dockerfile_fpath=${DOCKER__EMPTYSTRING}

    #Initialization
    docker__flagExitLoop=true

    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_0}"

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
                local tag=`cat ${dockerfile_fpath} | awk '{print $2}'| grep "${DOCKER__PATTERN1}" | cut -d"\"" -f2 | cut -d":" -f2`
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

    # docker__load_header__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__mandatory_apps_check__sub

    while true
    do
        docker__show_dockerList_files_handler__sub

        docker__create_image_handler__sub

        if [[ ${docker__flagExitLoop} == true ]]; then
            break
        fi
    done
}



#---EXECUTE
main_sub
