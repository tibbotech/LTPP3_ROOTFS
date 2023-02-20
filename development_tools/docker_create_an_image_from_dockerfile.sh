#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---PATTERN CONSTANTS
DOCKER__GIT_MAIN="main"
DOCKER__PATTERN1="repository:tag"
DOCKER__PATTERN2="On branch"
DOCKER__PATTERN3="origin"
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
    local errorMsg="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: No branch name found...abort"

    #Define local  variables
    # local docker__images_cmd="docker images"
    local exported_env_var1=${DOCKER__EMPTYSTRING}  #sunplus git-link
    local exported_env_var2=${DOCKER__EMPTYSTRING}  #sunplus checkout-number
    local exported_env_var3=${DOCKER__EMPTYSTRING}  #tibbo git-link (e.g. LTPP3_ROOTFS.git)

    local git_branch=${DOCKER__EMPTYSTRING}
    local git_https_link_isFound=${DOCKER__EMPTYSTRING}
    local git_status=${DOCKER__EMPTYSTRING}


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

        #Get the 'status' to see if we are in 'main'
        #Remark:
        #   'git status' cannot retrieve the 'branch' if it is DETACHED
        git_status=`git status -uno | grep "${DOCKER__PATTERN2}" | rev | cut -d" " -f1 | rev`

        #Get the 'branch' from which the repo was cloned (e.g. main, fixonetimexec, etc.)
        #Remark:
        #   Using the following command to get the 'branch' will always work (even if the branch is DETACHED)
        git_branch=`git show -s --pretty=%d HEAD | grep -o "${DOCKER__PATTERN3}.*" | cut -d"/" -f2 | cut -d")" -f1`

        #Update 'exported_env_var3' by including 'git_branch' 
        #Remark:
        #   Do this only if 'git_status != main'
        if [[ "${git_status}" != "${DOCKER__GIT_MAIN}" ]]; then
            if [[ -z "${git_branch}" ]]; then
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                echo -e "${errorMsg}"
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_2}"
            fi

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

    show_repoList_or_containerList_w_menuTitle__func "${DOCKER__MENUTITLE_UPDATED_REPOSITORYLIST}" "${docker__images_cmd}"
    
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
docker__get_source_fullpath__sub() {
    #Define constants
    local DOCKER__PHASE_CHECK_CACHE=1
    local DOCKER__PHASE_FIND_PATH=10
    local DOCKER__PHASE_EXIT=100

    #Define variables
    local docker__phase=""

    local docker__current_dir=
    local docker__tmp_dir=""

    local docker__development_tools__foldername=""
    local docker__LTPP3_ROOTFS__foldername=""
    local docker__global__filename=""
    local docker__parentDir_of_LTPP3_ROOTFS__dir=""

    local docker__mainmenu_path_cache__filename=""
    local docker__mainmenu_path_cache__fpath=""

    local docker__find_dir_result_arr=()
    local docker__find_dir_result_arritem=""
    local docker__find_dir_result_arrlen=0
    local docker__find_dir_result_arrlinectr=0
    local docker__find_dir_result_arrprogressperc=0

    local docker__find_path_of_development_tools=""

    local docker__isfound=""

    #Set variables
    docker__phase="${DOCKER__PHASE_CHECK_CACHE}"
    docker__current_dir=$(pwd)
    docker__tmp_dir=/tmp
    docker__development_tools__foldername="development_tools"
    docker__global__filename="docker_global.sh"
    docker__LTPP3_ROOTFS__foldername="LTPP3_ROOTFS"

    docker__mainmenu_path_cache__filename="docker__mainmenu_path.cache"
    docker__mainmenu_path_cache__fpath="${docker__tmp_dir}/${docker__mainmenu_path_cache__filename}"

    docker_result=false

    #Start loop
    while true
    do
        case "${docker__phase}" in
            "${DOCKER__PHASE_CHECK_CACHE}")
                if [[ -f "${docker__mainmenu_path_cache__fpath}" ]]; then
                    #Get the directory stored in cache-file
                    docker__LTPP3_ROOTFS_development_tools__dir=$(awk 'NR==1' "${docker__mainmenu_path_cache__fpath}")

                    #Check if 'development_tools' is in the 'LTPP3_ROOTFS' folder
                    docker__isfound=$(docker__checkif_parentdir_isfound_in_path "${docker__current_dir}" \
                            "${docker__LTPP3_ROOTFS_development_tools__dir}" "${docker__LTPP3_ROOTFS__foldername}")
                    if [[ ${docker__isfound} == false ]]; then
                        docker__phase="${DOCKER__PHASE_FIND_PATH}"
                    else
                        docker_result=true

                        docker__phase="${DOCKER__PHASE_EXIT}"

                        echo -e "---:\e[30;38;5;215mSTATUS\e[0;0m: retrieve path from cache: \e[1;33mDONE\e[0;0m"
                    fi
                else
                    docker__phase="${DOCKER__PHASE_FIND_PATH}"
                fi
                ;;
            "${DOCKER__PHASE_FIND_PATH}")   
                #Print
                echo -e "---:\e[30;38;5;215mSTART\e[0;0m: find path of folder \e[30;38;5;246m'${docker__development_tools__foldername}\e[0;0m : \e[1;33mDONE\e[0;0m"

                #Reset variable
                docker__LTPP3_ROOTFS_development_tools__dir=""

                #Start loop
                while true
                do
                    #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
                    #... and read to array 'find_result_arr'
                    readarray -t docker__find_dir_result_arr < <(find  / -type d -iname "${docker__LTPP3_ROOTFS__foldername}" 2> /dev/null)

                    #Get array-length
                    docker__find_dir_result_arrlen=${#docker__find_dir_result_arr[@]}

                    #Iterate thru each array-item
                    for docker__find_dir_result_arritem in "${docker__find_dir_result_arr[@]}"
                    do
                        docker__isfound=$(docker__checkif_parentdir_isfound_in_path "${docker__current_dir}" \
                                "${docker__find_dir_result_arritem}"  "${docker__LTPP3_ROOTFS__foldername}")
                        if [[ ${docker__isfound} == true ]]; then
                            #Update variable 'docker__find_path_of_development_tools'
                            docker__find_path_of_development_tools="${docker__find_dir_result_arritem}/${docker__development_tools__foldername}"

                            # #Increment counter
                            docker__find_dir_result_arrlinectr=$((docker__find_dir_result_arrlinectr+1))

                            #Calculate the progress percentage value
                            docker__find_dir_result_arrprogressperc=$(( docker__find_dir_result_arrlinectr*100/docker__find_dir_result_arrlen ))

                            #Moveup and clean
                            if [[ ${docker__find_dir_result_arrlinectr} -gt 1 ]]; then
                                tput cuu1
                                tput el
                            fi

                            #Print
                            #Note: do not print the '100%'
                            if [[ ${docker__find_dir_result_arrlinectr} -lt ${docker__find_dir_result_arrlen} ]]; then
                                echo -e "------:PROGRESS: ${docker__find_dir_result_arrprogressperc}%"
                            fi

                            #Check if 'directory' exist
                            if [[ -d "${docker__find_path_of_development_tools}" ]]; then    #directory exists
                                #Update variable
                                #Remark:
                                #   'docker__LTPP3_ROOTFS_development_tools__dir' is a global variable.
                                #   This variable will be passed 'globally' to script 'docker_global.sh'.
                                docker__LTPP3_ROOTFS_development_tools__dir="${docker__find_path_of_development_tools}"

                                #Print
                                #Note: print the '100%' here
                                echo -e "------:PROGRESS: 100%"

                                break
                            fi
                        fi
                    done

                    #Check if 'docker__LTPP3_ROOTFS_development_tools__dir' contains any data
                    if [[ -z "${docker__LTPP3_ROOTFS_development_tools__dir}" ]]; then  #contains no data
                        echo -e "\r"
                        echo -e "***\e[1;31mERROR\e[0;0m: folder \e[30;38;5;246m${docker__development_tools__foldername}\e[0;0m: \e[30;38;5;131mNot Found\e[0;0m"
                        echo -e "\r"

                         #Update variable
                        docker_result=false
                    else    #contains data
                        #Print
                        echo -e "---:\e[30;38;5;215mCOMPLETED\e[0;0m: find path of folder \e[30;38;5;246m'${docker__development_tools__foldername}\e[0;0m : \e[1;33mDONE\e[0;0m"


                        #Write to file
                        echo "${docker__LTPP3_ROOTFS_development_tools__dir}" | tee "${docker__mainmenu_path_cache__fpath}" >/dev/null

                        #Print
                        echo -e "---:\e[30;38;5;215mSTATUS\e[0;0m: write path to temporary cache-file: \e[1;33mDONE\e[0;0m"

                        #Update variable
                        docker_result=true

                        #set phase
                        docker__phase="${DOCKER__PHASE_EXIT}"

                        break
                    fi
                done
                ;;    
            "${DOCKER__PHASE_EXIT}")
                break
                ;;
        esac
    done

    #Exit if 'docker_result = false'
    if [[ ${docker_result} == false ]]; then
        exit 99
    fi

    #Retrieve directories
    #Remark:
    #   'docker__LTPP3_ROOTFS__dir' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/
    docker__parentDir_of_LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS__dir%/*}    #move two directories up. This directory is the one-level higher than LTPP3_ROOTFS/

    #Get full-path
    #Remark:
    #   'docker__global__fpath' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__global__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__global__filename}
}
docker__checkif_parentdir_isfound_in_path() {
    #Input args
    local parentdir__input=${1}
    local path__input=${2}
    local pattern__input=${3}

    #Define constants
    local PHASE_PATTERN_CHECK1=1
    local PHASE_PATTERN_CHECK2=10
    local PHASE_PATH_COMPARISON=20
    local PHASE_EXIT=100

    #Define variables
    local phase="${PHASE_PATTERN_CHECK1}"
    local isfound1=""
    local isfound2=""
    local isfound3=""
    local ret=false

    while true
    do
        case "${phase}" in
            "${PHASE_PATTERN_CHECK1}")
                #Check if 'pattern__input' is found in 'parentdir__input'
                isfound1=$(echo "${parentdir__input}" | \
                        grep -o "${pattern__input}.*" | \
                        cut -d"/" -f1 | grep -w "^${pattern__input}$")
                if [[ -z "${isfound1}" ]]; then
                    ret=false

                    phase="${PHASE_EXIT}"
                else
                    phase="${PHASE_PATTERN_CHECK2}"
                fi                
                ;;
            "${PHASE_PATTERN_CHECK2}")
                #Check if 'pattern__input' is found in 'path__input'
                isfound2=$(echo "${path__input}" | \
                        grep -o "${pattern__input}.*" | \
                        cut -d"/" -f1 | grep -w "^${pattern__input}$")
                if [[ -z "${isfound2}" ]]; then
                    ret=false

                    phase="${PHASE_EXIT}"
                else
                    phase="${PHASE_PATH_COMPARISON}"
                fi                
                ;;
            "${PHASE_PATH_COMPARISON}")
                #Check if 'development_tools' is under the folder 'LTPP3_ROOTFS'
                isfound3=$(echo "${path__input}" | \
                        grep -w "${parentdir__input}.*")
                if [[ -z "${isfound3}" ]]; then
                    ret=false
                else
                    ret=true
                fi

                phase="${PHASE_EXIT}"
                ;;
            "${PHASE_EXIT}")
                break
                ;;
        esac
    done

    #Output
    echo "${ret}"

    return 0
}
docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

docker__load_constants__sub() {
    DOCKER__MENUTITLE="${DOCKER__FG_YELLOW}Create${DOCKER__NOCOLOR} an ${DOCKER__FG_BORDEAUX}Image${DOCKER__NOCOLOR} using a ${DOCKER__FG_DARKBLUE}docker-file${DOCKER__NOCOLOR}"
    DOCKER__REMARK=${DOCKER__EMPTYSTRING}
    DOCKER__LOCATIONINFO="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR}: ${docker__LTPP3_ROOTFS_docker_dockerfiles__dir}"
    DOCKER__MENUOPTIONS="${DOCKER__FOURSPACES_Q_QUIT}"
    DOCKER__MATCHPATTERNS="${DOCKER__QUIT}"
    DOCKER__ERRMSG="${DOCKER__FOURSPACES}-:${DOCKER__FG_LIGHTRED}directory is Empty${DOCKER__NOCOLOR}:-"
    DOCKER__READ_DIALOG="Choose a file: "
}

docker__init_variables__sub() {
    docker__dockerFile_fpath=${DOCKER__EMPTYSTRING}
    docker__dockerFile_filename=${DOCKER__EMPTYSTRING}
    docker__printMsg=${DOCKER__EMPTYSTRING}
    docker__flagExitLoop=false
}

docker__show_dockerList_files__sub() {
    #Show directory content
    show_pathContent_w_selection__func "${docker__LTPP3_ROOTFS_docker_dockerfiles__dir}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${DOCKER__MENUTITLE}" \
                        "${DOCKER__REMARK}" \
                        "${DOCKER__LOCATIONINFO}" \
                        "${DOCKER__MENUOPTIONS}" \
                        "${DOCKER__MATCHPATTERNS}" \
                        "${DOCKER__ERRMSG}" \
                        "${DOCKER__READ_DIALOG}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${DOCKER__TABLEROWS_10}" \
                        "${DOCKER__FALSE}" \
                        "${docker__show_pathContent_w_selection_func_out__fpath}" \
                        "${DOCKER__NUMOFLINES_2}" \
                        "${DOCKER__TRUE}"

    #Get the exitcode just in case a Ctrl-C was pressed in function 'DOCKER__FOURSPACES_F4_ABORT' (in script 'docker_global.sh')
    docker__exitCode=$?
    if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
        exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
    fi

    #Get result from file.
    docker__dockerFile_fpath=`get_output_from_file__func \
                        "${docker__show_pathContent_w_selection_func_out__fpath}" \
                        "${DOCKER__LINENUM_1}"`

    #Double-check if 'docker__dockerFile_fpath = F12'
    if [[ ${docker__dockerFile_fpath} == ${DOCKER__QUIT} ]]; then
        exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_2}"
    else
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    fi
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
        #Update message
        docker__printMsg="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: "
        docker__printMsg+="file ${DOCKER__FG_DARKBLUE}${docker__dockerFile_fpath}${DOCKER__NOCOLOR} "
        docker__printMsg+="does ${DOCKER__FG_LIGHTRED}Not${DOCKER__NOCOLOR} exist"

        #Show message
        show_msg_only__func "${docker__printMsg}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_1}"
    fi
}



#---MAIN SUBROUTINE
main_sub() {
    docker__get_source_fullpath__sub

    docker__load_source_files__sub

    docker__load_constants__sub

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
