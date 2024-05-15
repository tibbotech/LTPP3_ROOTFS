#!/bin/bash -m
#Remark: by using '-m' the INTERRUPT executed here will NOT propagate to the UPPERLAYER scripts
#---PATTERN CONSTANTS
DOCKER__GIT_MAIN="main"
DOCKER__PATTERN1="repository:tag"
DOCKER__PATTERN2="On branch"
DOCKER__PATTERN3="origin"
DOCKER__PATTERN_CONTAINER_ENV1="CONTAINER_ENV1"
DOCKER__PATTERN_CONTAINER_ENV2="CONTAINER_ENV2"
DOCKER__PATTERN_DOCKERFILE_ENV1="DOCKERFILE_ENV1"
DOCKER__PATTERN_CONTAINER_ENV4="CONTAINER_ENV4"
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
    local errorMsg1="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: No branch name found...abort"
    local errorMsg2="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Oops...it appears that \"${DOCKER__PATTERN_CONTAINER_ENV1}\" and "
            errorMsg2+="\"${DOCKER__PATTERN_CONTAINER_ENV1}\" are not set yet...\n"
          errorMsg2+="***${DOCKER__FG_LIGHTBLUE}RECOMMEND${DOCKER__NOCOLOR}: Please choose 'option 3: Export environment variables' first!"
    local errorMsg4="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Oops...it appears that \"${DOCKER__PATTERN_CONTAINER_ENV4}\""
            errorMsg4+="is not set yet...\n"
          errorMsg4+="***${DOCKER__FG_LIGHTBLUE}RECOMMEND${DOCKER__NOCOLOR}: Please choose '1. Create image using docker-file' again!"


    #Define local  variables
    # local docker__images_cmd="docker images"
    local exported_env_var1=${DOCKER__EMPTYSTRING}  #sunplus git-link
    local exported_env_var2=${DOCKER__EMPTYSTRING}  #sunplus checkout-number
    local exported_env_var3=${DOCKER__EMPTYSTRING}  #tibbo git-link (e.g. LTPP3_ROOTFS.git)
    local exported_env_var4=${DOCKER__EMPTYSTRING}  #disk_preprep.sh ispboootbin_version

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
        #Find the following patterns in 'dockerfile_fpath': 'DOCKER__PATTERN_CONTAINER_ENV1', 'DOCKER__PATTERN_CONTAINER_ENV2', and 'DOCKER__PATTERN_DOCKERFILE_ENV1'
        container_env1_isfound=$(grep -F "${DOCKER__PATTERN_CONTAINER_ENV1}" "${dockerfile_fpath}")
        container_env2_isfound=$(grep -F "${DOCKER__PATTERN_CONTAINER_ENV2}" "${dockerfile_fpath}")
        container_env3_isfound=$(grep -F "${DOCKER__PATTERN_DOCKERFILE_ENV1}" "${dockerfile_fpath}")
        container_env4_isfound=$(grep -F "${DOCKER__PATTERN_CONTAINER_ENV4}" "${dockerfile_fpath}")
    
        #Check if 'dockerfile_fpath' contains 'DOCKER__PATTERN_CONTAINER_ENV1', 'DOCKER__PATTERN_CONTAINER_ENV2', and 'DOCKER__PATTERN_DOCKERFILE_ENV1' are present in file 'dockerfile_fpath'?
        if [[ -n "${container_env1_isfound}" ]] && [[ -n "${container_env2_isfound}" ]] && [[ -n "${container_env3_isfound}" ]]; then   #Yes, patterns are present
            #Retrieve to-be-exported Environment variables
            exported_env_var1=`retrieve_env_var_link_from_file__func "${dockerfile_fpath}" "${docker__exported_env_var__fpath}"`
            exported_env_var2=`retrieve_env_var_checkout_from_file__func "${dockerfile_fpath}" "${docker__exported_env_var__fpath}"`
            exported_env_var3=`git config --get remote.origin.url`

            if [[ -z "${exported_env_var1}" ]] || [[ -z "${exported_env_var2}" ]]; then
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                echo -e "${errorMsg2}"
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                exit 99
            fi

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
                    echo -e "${errorMsg1}"
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                    exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_2}"
                fi

                exported_env_var3="--branch ${git_branch} ${exported_env_var3}"
            fi
        elif [[ -n "${container_env4_isfound}" ]]; then
            #Retrieve ISPBOOOT.BIN version from file
            exported_env_var4=$(cat "${docker__ispboootbin_version_txt__fpath}")

            #Check if 'exported_env_var4' is an Empty String
            if [[ -z "${exported_env_var4}" ]]; then
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                echo -e "${errorMsg4}"
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                exit 99
            fi
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
    docker build --build-arg DOCKER_ARG1="${exported_env_var1}" \
            --build-arg DOCKER_ARG2="${exported_env_var2}" \
            --build-arg DOCKER_ARG3="${exported_env_var3}" \
            --build-arg DOCKER_ARG4="${exported_env_var4}" \
            --tag ${dockerfile_repository_tag} - < ${dockerfile_fpath} #with REPOSITORY:TAG

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
    local PHASE_CHECK_CACHE=1
    local PHASE_FIND_PATH=10
    local PHASE_EXIT=100

    #Define variables
    local phase=""

    local current_dir=""
    local parent_dir=""
    local search_dir=""
    local tmp_dir=""

    local development_tools_foldername=""
    local lTPP3_ROOTFS_foldername=""
    local global_filename=""
    local parentDir_of_LTPP3_ROOTFS_dir=""

    local mainmenu_path_cache_filename=""
    local mainmenu_path_cache_fpath=""

    local find_dir_result_arr=()
    local find_dir_result_arritem=""

    local path_of_development_tools_found=""
    local parentpath_of_development_tools=""

    local isfound=""

    local retry_ctr=0

    #Set variables
    phase="${PHASE_CHECK_CACHE}"
    current_dir=$(dirname $(readlink -f $0))
    parent_dir="$(dirname "${current_dir}")"
    tmp_dir=/tmp
    development_tools_foldername="development_tools"
    global_filename="docker_global.sh"
    lTPP3_ROOTFS_foldername="LTPP3_ROOTFS"

    mainmenu_path_cache_filename="docker__mainmenu_path.cache"
    mainmenu_path_cache_fpath="${tmp_dir}/${mainmenu_path_cache_filename}"

    result=false

    #Start loop
    while true
    do
        case "${phase}" in
            "${PHASE_CHECK_CACHE}")
                if [[ -f "${mainmenu_path_cache_fpath}" ]]; then
                    #Get the directory stored in cache-file
                    docker__LTPP3_ROOTFS_development_tools__dir=$(awk 'NR==1' "${mainmenu_path_cache_fpath}")

                    #Move one directory up
                    parentpath_of_development_tools=$(dirname "${docker__LTPP3_ROOTFS_development_tools__dir}")

                    #Check if 'development_tools' is in the 'LTPP3_ROOTFS' folder
                    isfound=$(docker__checkif_paths_are_related "${current_dir}" \
                            "${parentpath_of_development_tools}" "${lTPP3_ROOTFS_foldername}")
                    if [[ ${isfound} == false ]]; then
                        phase="${PHASE_FIND_PATH}"
                    else
                        result=true

                        phase="${PHASE_EXIT}"
                    fi
                else
                    phase="${PHASE_FIND_PATH}"
                fi
                ;;
            "${PHASE_FIND_PATH}")   
                #Print
                echo -e "---:\e[30;38;5;215mSTART\e[0;0m: find path of folder \e[30;38;5;246m'${development_tools_foldername}\e[0;0m"

                #Initialize variables
                docker__LTPP3_ROOTFS_development_tools__dir=""
                search_dir="${current_dir}"   #start with search in the current dir

                #Start loop
                while true
                do
                    #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
                    #... and read to array 'find_result_arr'
                    readarray -t find_dir_result_arr < <(find  "${search_dir}" -type d -iname "${lTPP3_ROOTFS_foldername}" 2> /dev/null)

                    #Iterate thru each array-item
                    for find_dir_result_arritem in "${find_dir_result_arr[@]}"
                    do
                        echo -e "---:\e[30;38;5;215mCHECKING\e[0;0m: ${find_dir_result_arritem}"

                        #Find path
                        isfound=$(docker__checkif_paths_are_related "${current_dir}" \
                                "${find_dir_result_arritem}"  "${lTPP3_ROOTFS_foldername}")
                        if [[ ${isfound} == true ]]; then
                            #Update variable 'path_of_development_tools_found'
                            path_of_development_tools_found="${find_dir_result_arritem}/${development_tools_foldername}"

                            #Check if 'directory' exist
                            if [[ -d "${path_of_development_tools_found}" ]]; then    #directory exists
                                #Update variable
                                #Remark:
                                #   'docker__LTPP3_ROOTFS_development_tools__dir' is a global variable.
                                #   This variable will be passed 'globally' to script 'docker_global.sh'.
                                docker__LTPP3_ROOTFS_development_tools__dir="${path_of_development_tools_found}"

                                break
                            fi
                        fi
                    done

                    #Check if 'docker__LTPP3_ROOTFS_development_tools__dir' contains any data
                    if [[ -z "${docker__LTPP3_ROOTFS_development_tools__dir}" ]]; then  #contains no data
                        case "${retry_ctr}" in
                            0)
                                search_dir="${parent_dir}"    #next search in the 'parent' directory
                                ;;
                            1)
                                search_dir="/" #finally search in the 'main' directory (the search may take longer)
                                ;;
                            *)
                                echo -e "\r"
                                echo -e "***\e[1;31mERROR\e[0;0m: folder \e[30;38;5;246m${development_tools_foldername}\e[0;0m: \e[30;38;5;131mNot Found\e[0;0m"
                                echo -e "\r"

                                #Update variable
                                result=false

                                #set phase
                                phase="${PHASE_EXIT}"

                                break
                                ;;
                        esac

                        ((retry_ctr++))
                    else    #contains data
                        #Print
                        echo -e "---:\e[30;38;5;215mCOMPLETED\e[0;0m: find path of folder \e[30;38;5;246m'${development_tools_foldername}\e[0;0m"


                        #Write to file
                        echo "${docker__LTPP3_ROOTFS_development_tools__dir}" | tee "${mainmenu_path_cache_fpath}" >/dev/null

                        #Print
                        echo -e "---:\e[30;38;5;215mSTATUS\e[0;0m: write path to temporary cache-file: \e[1;33mDONE\e[0;0m"

                        #Update variable
                        result=true

                        #set phase
                        phase="${PHASE_EXIT}"

                        break
                    fi
                done
                ;;    
            "${PHASE_EXIT}")
                break
                ;;
        esac
    done

    #Exit if 'result = false'
    if [[ ${result} == false ]]; then
        exit 99
    fi

    #Retrieve directories
    #Remark:
    #   'docker__LTPP3_ROOTFS__dir' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/
    parentDir_of_LTPP3_ROOTFS_dir=${docker__LTPP3_ROOTFS__dir%/*}    #move two directories up. This directory is the one-level higher than LTPP3_ROOTFS/

    #Get full-path
    #Remark:
    #   'docker__global__fpath' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__global__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${global_filename}
}
docker__checkif_paths_are_related() {
    #Input args
    local scriptdir__input=${1}
    local finddir__input=${2}
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
                #Check if 'pattern__input' is found in 'scriptdir__input'
                isfound1=$(echo "${scriptdir__input}" | \
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
                #Check if 'pattern__input' is found in 'finddir__input'
                isfound2=$(echo "${finddir__input}" | \
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
                isfound3=$(echo "${scriptdir__input}" | \
                        grep -w "${finddir__input}.*")
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
docker__load_global_fpath_paths__sub() {
    source ${docker__global__fpath}
}

docker__load_constants__sub() {
    DOCKER__MENUTITLE="${DOCKER__FG_YELLOW}Create${DOCKER__NOCOLOR} an ${DOCKER__FG_BORDEAUX}Image${DOCKER__NOCOLOR} using a ${DOCKER__FG_DARKBLUE}docker-file${DOCKER__NOCOLOR}"
    DOCKER__REMARK=${DOCKER__EMPTYSTRING}
    DOCKER__LOCATIONINFO="${DOCKER__FOURSPACES}${DOCKER__FG_ORANGE223}Location${DOCKER__NOCOLOR}: ${docker__LTPP3_ROOTFS_docker_dockerfiles__dir}"
    DOCKER__MENUOPTIONS="${DOCKER__FOURSPACES_Q_QUIT}"
    DOCKER__MATCHPATTERNS="${DOCKER__QUIT}"
    DOCKER__ERRMSG="${DOCKER__FOURSPACES}-:${DOCKER__FG_LIGHTRED}directory is Empty${DOCKER__NOCOLOR}:-"
    DOCKER__READ_DIALOG="Choose a file: "

    DOCKER__MATCHPATTERN_ROOTFS="rootfs"
    DOCKER__MATCHPATTERN_LABEL_REPOSITORY_COLON_TAG_IS="LABEL repository:tag="
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

    #Get the exitCode just in case a Ctrl-C was pressed in function 'DOCKER__FOURSPACES_F4_ABORT' (in script 'docker_global.sh')
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

docker__ispboootbin_version_input__sub() {
    #define local variables
    local exitCode=0
    local label_repositorytag=${DOCKER__EMPTYSTRING}

    #1. Find match pattern 'DOCKER__MATCHPATTERN_LABEL_REPOSITORY_COLON_TAG_IS'
    #2. Retrieve the string on the right-side of the equal (=) sign
    #3. Remove the double quotes (")
    label_repositorytag=$(cat "${docker__dockerFile_fpath}" | \
            grep -o "${DOCKER__MATCHPATTERN_LABEL_REPOSITORY_COLON_TAG_IS}.*" | \
            cut -d"=" -f2 | \
            sed 's/\"//g')

    #Check if pattern 'DOCKER__MATCHPATTERN_ROOTFS' is NOT found in 'label_repositorytag'
    if [[ ! "${label_repositorytag}" =~ "${DOCKER__MATCHPATTERN_ROOTFS}" ]]; then
        return 0;
    fi

    #Run script and capture exit code
    eval "${docker__ispboootbin_version_input__fpath}" || exitCode=$?

    #Check if exitCode is '99'
    #NOTE 1: this probably means that an interrupt, thus Ctrl+C was pressed.
    #NOTE 2: the interrupt is caught by an Global function 'docker__ctrl_c__sub'
    # which is defined in 'docker_global.sh'.
    if ((exitCode == DOCKER__EXITCODE_99)); then
        exit 99
    else
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    fi
}


#---MAIN SUBROUTINE
main_sub() {
    docker__get_source_fullpath__sub

    docker__load_global_fpath_paths__sub

    docker__load_constants__sub

    docker__init_variables__sub

    while true
    do
        docker__show_dockerList_files__sub

        docker__ispboootbin_version_input__sub

        docker__create_image_handler__sub

        if [[ ${docker__flagExitLoop} == true ]]; then
            break
        fi
    done
}



#---EXECUTE
main_sub
