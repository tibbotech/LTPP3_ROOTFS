#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---PATTERN CONSTANTS
DOCKER__GIT_MAIN="main"
DOCKER__PATTERN1="repository:tag"
DOCKER__PATTERN2="On branch"
SED__PATTERN_SSH_FORMAT="git\@github.com:"
SED__PATTERN_HTTPS_FORMAT="https:\/\/github.com\/"



#---FUNCTIONS
function create_image__func() {
    #Input args
    local dockerfile_fpath=${1}

    #Define local constants
    local GREP_PATTERN="LABEL repository:tag"

    #Define local message variables
    local statusMsg="---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Creating image..."

    #Define local command variables
    local docker_image_ls_cmd="docker image ls"
    local exported_env_var1=${DOCKER__EMPTYSTRING}  #sunplus git-link
    local exported_env_var2=${DOCKER__EMPTYSTRING}  #sunplus checkout-number
    local exported_env_var3=${DOCKER__EMPTYSTRING}  #tibbo git-link (e.g. LTPP3_ROOTFS.git)

    #Get REPOSITORY:TAG from dockerfile
    local dockerfile_repository_tag=`egrep -w "${GREP_PATTERN}" ${dockerfile_fpath} | cut -d"\"" -f2`

    #Check if 'dockerfile_repository_tag' is an EMPTY STRING
    if [[ -z ${dockerfile_repository_tag} ]]; then  #is an Empty String
        #Set a value for 'dockerfile_repository_tag'
        dockerfile_repository_tag="${dockerfile}:${DOCKER__LATEST}"
    else    #is Not an Empty String
        #Retrieve to-be-exported Environment variables
        exported_env_var1=`retrieve_env_var_link_from_file__func "${dockerfile_fpath}" "${docker__exported_env_var_fpath}"`
        exported_env_var2=`retrieve_env_var_checkout_from_file__func "${dockerfile_fpath}" "${docker__exported_env_var_fpath}"`
        exported_env_var3=`git config --get remote.origin.url`

        #For now, lets assume that the git-repo was cloned via HTTPS.
        #Remark:
        #   Cloning via SSH would require to set the SSH-key of the HOST on GIT-HUB.
        #   This is not do-able, because everytime when a new image is created the SSH-KEY...
        #   ...would change as well. 
        git_https_link_isFound=`echo "${exported_env_var3}" | grep "https"`
        if [[ -z ${git_https_link_isFound} ]]; then #no match was found
            #Substitute 'SED__PATTERN_SSH_FORMAT' with 'SED__PATTERN_HTTPS_FORMAT'
            #In other words:
            #   git@github.com:tibbotech/LTPP3_ROOTFS.git
            #   to
            #   https://github.com/tibbotech/LTPP3_ROOTFS.git
            exported_env_var3=`echo "${exported_env_var3}" | sed "s/${SED__PATTERN_SSH_FORMAT}/${SED__PATTERN_HTTPS_FORMAT}/g"`
        fi

        #Get the 'branch' from which the repo was cloned (e.g. main, fixonetimexec, etc.)
        git_branch=`git status -uno | grep "${DOCKER__PATTERN2}" | rev | cut -d" " -f1 | rev`

        #Update 'exported_env_var3' by including 'git_branch' 
        #Remark:
        #   Do this only if 'git_branch != main'
        if [[ "${git_branch}" != "${DOCKER__GIT_MAIN}" ]]; then
            exported_env_var3="--branch ${git_branch} ${exported_env_var3}"
        fi
    fi

    #Print
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${statusMsg}"
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    # docker build --tag ${dockerfile_repository_tag} - < ${dockerfile_fpath} #with REPOSITORY:TAG
    #Remark:
    #   DOCKER_ARG1: argument defined in the dockerfile(s) (e.g. sunplus_inst.sh)
    #   HOST_EXPORTED_ARG1: exported variable in defined in the HOST device (e.g. sunplus git clone link)
    docker build --build-arg DOCKER_ARG1="${exported_env_var1}" --build-arg DOCKER_ARG2="${exported_env_var2}" --build-arg DOCKER_ARG3="${exported_env_var3}" --tag ${dockerfile_repository_tag} - < ${dockerfile_fpath} #with REPOSITORY:TAG

    #Validate executed command
    validate_exitCode__func

    #Print docker image list
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    show_cmdOutput_w_menuTitle__func "${DOCKER__MENUTITLE_UPDATED_REPOSITORYLIST}" "${docker__images_cmd}"
    
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
    #Check the number of input args
    if [[ -z ${docker__global__fpath} ]]; then   #must be equal to 3 input args
        #---Defin FOLDER
        docker__LTPP3_ROOTFS__foldername="LTPP3_ROOTFS"
        docker__development_tools__foldername="development_tools"

        #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
        #... and read to array 'find_result_arr'
        #Remark:
        #   By using '2> /dev/null', the errors are not shown.
        readarray -t find_dir_result_arr < <(find  / -type d -iname "${docker__LTPP3_ROOTFS__foldername}" 2> /dev/null)

        #Define variable
        local find_path_of_LTPP3_ROOTFS=${DOCKER__EMPTYSTRING}

        #Loop thru array-elements
        for find_dir_result_arrItem in "${find_dir_result_arr[@]}"
        do
            #Update variable 'find_path_of_LTPP3_ROOTFS'
            find_path_of_LTPP3_ROOTFS="${find_dir_result_arrItem}/${docker__development_tools__foldername}"
            #Check if 'directory' exist
            if [[ -d "${find_path_of_LTPP3_ROOTFS}" ]]; then    #directory exists
                #Update variable
                docker__LTPP3_ROOTFS_development_tools__dir="${find_path_of_LTPP3_ROOTFS}"

                break
            fi
        done

        docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/
        docker__parentDir_of_LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS__dir%/*}    #move two directories up. This directory is the one-level higher than LTPP3_ROOTFS/

        docker__global__filename="docker_global.sh"
        docker__global__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__global__filename}
    fi
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
    DOCKER__FILE_REMARKS=${DOCKER__EMPTYSTRING}
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
        show_fileContent_wo_select__func "${docker__dockerList_fpath}" \
                        "${DOCKER__FILE_MENUTITLE}" \
                        "${DOCKER__FILE_REMARKS}" \
                        "${docker__file_locationInfo}" \
                        "${DOCKER__FILE_MENUOPTIONS}" \
                        "${DOCKER__FILE_ERRMSG}" \
                        "${DOCKER__FILE_READDIALOG}" \
                        "${docker__show_fileContent_wo_select_func_out__fpath}" \
                        "${DOCKER__TABLEROWS_10}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${DOCKER__FALSE}"

        #Get the exitcode just in case a Ctrl-C was pressed in function 'show_fileContent_wo_select__func' (in script 'docker_global.sh')
        docker__exitCode=$?
        if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
            exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
        fi

        #Get result from file.
        docker__myAnswer=`get_output_from_file__func \
                            "${docker__show_fileContent_wo_select_func_out__fpath}" \
                            "${DOCKER__LINENUM_1}"`

        #Check if 'docker__myAnswer' is a numeric value
        case "${docker__myAnswer}" in
            ${DOCKER__ENUM_FUNC_F12})
                exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_2}"

                ;;
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
    show_pathContent_w_selection__func "${docker__LTPP3_ROOTFS_docker_list__dir}" \
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
                        "${DOCKER__TABLEROWS_10}" \
                        "${docker__show_pathContent_w_selection_func_out__fpath}"

    #Get the exitcode just in case a Ctrl-C was pressed in function 'show_fileContent_wo_select__func' (in script 'docker_global.sh')
    docker__exitCode=$?
    if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
        exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
    fi

    #Get result from file.
    docker__dockerList_fpath=`get_output_from_file__func \
                        "${docker__show_pathContent_w_selection_func_out__fpath}" \
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
            dockerfile_fpath=${docker__LTPP3_ROOTFS_docker_dockerfiles__dir}/${file_line}

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
