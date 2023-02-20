#!/bin/bash
#---FUNCTIONS
function checkIf_software_isInstalled__func() {
    #Input args
    local package_input=${1}

    #Define constants
    local PATTERN_PACKAGESTATUS_INSTALLED="ii"

    #Define variables
    dpkg_l_cmd="dpkg -l"

    #Define local 
    local packageStatus=`${dpkg_l_cmd} | grep -w "${package_input}" | awk '{print $1}'`

    #If 'stdOutput' is an EMPTY STRING, then software is NOT installed yet
    if [[ ${packageStatus} == ${PATTERN_PACKAGESTATUS_INSTALLED} ]]; then #contains NO data
        echo true
    else
        echo false
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

docker__environmental_variables__sub() {
    #---Define PATHS
    docker__home_dir=~
    docker__sp7021_dir=${docker__home_dir}/SP7021
    docker__usr_bin_dir=/usr/bin
    docker__ltpp3rootfs_dir=${docker__home_dir}/LTPP3_ROOTFS
    docker__ltpp3rootfs_development_tools_dir=${docker__ltpp3rootfs_dir}/development_tools

    docker__docker_build_ispboootbin_fpath=${docker__ltpp3rootfs_development_tools_dir}/docker_build_ispboootbin.sh
    docker__bash_fpath=${docker__usr_bin_dir}/bash
}

docker__init_variables__sub() {
    docker__myContainerId=${DOCKER__EMPTYSTRING}
    docker__numOf_errors_found=0
    docker__exitCode=0

    docker__isRunning_inside_container=false
    docker__showTable=true

}

docker__checkIf_isRunning_inside_container__sub() {
    #Define contants
    local PATTERN_DOCKER="docker"

    #Define variables
    local proc_1_cgroup_dir=/proc/1/cgroup

    #Check if you are currently inside a docker container
    local isDocker=`cat "${proc_1_cgroup_dir}" | grep "${PATTERN_DOCKER}"`
    if [[ ! -z ${isDocker} ]]; then
        docker__isRunning_inside_container=true
    else
        docker__isRunning_inside_container=false
    fi
}

docker__choose_containerID__sub() {
    #Define local message constants
    # local MENUTITLE="Current ${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}-list"
    local MENUTITLE="Build ${DOCKER__FG_LIGHTGREY}ISPBOOOT.BIN${DOCKER__NOCOLOR}"
    local READMSG_CHOOSE_A_CONTAINERID="Choose a ${DOCKER__FG_BRIGHTPRUPLE}Container-ID${DOCKER__NOCOLOR} (e.g. dfc5e2f3f7ee): "
    local ERRMSG_INVALID_INPUT_VALUE="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Invalid input value "


    #Check if running inside Docker Container
    #If true, then exit subroutine right away.
    if [[ ${docker__isRunning_inside_container} == true ]]; then   #running in docker container
        return  #exit function
    fi

    #Get container-ID (if running outside a container)
    ${docker__readInput_w_autocomplete__fpath} "${MENUTITLE}" \
                        "${READMSG_CHOOSE_A_CONTAINERID}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${DOCKER__ERRMSG_NO_CONTAINERS_FOUND}" \
                        "${ERRMSG_INVALID_INPUT_VALUE}" \
                        "${docker__ps_a_cmd}" \
                        "${docker__ps_a_containerIdColno}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${docker__showTable}" \
                        "${docker__onEnter_breakLoop}" \
                        "${DOCKER__NUMOFLINES_2}"


    #Get the exit-code just in case:
    #   1. Ctrl-C was pressed in script 'docker__readInput_w_autocomplete__fpath'.
    #   2. An error occured in script 'docker__readInput_w_autocomplete__fpath',...
    #      ...and exit-code = 99 came from function...
    #      ...'show_msg_w_menuTitle_w_pressAnyKey_w_ctrlC_func' (in script: docker__global.sh).
    docker__exitCode=$?
    if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
        docker__myContainerId=${DOCKER__EMPTYSTRING}
    else
        #Get the result
        docker__myContainerId=`get_output_from_file__func "${docker__readInput_w_autocomplete_out__fpath}" "1"`
    fi
}

docker__preCheck__sub() {
    #Define local message constants
    local ERRMSG_ONE_OR_MORE_CHECKITEMS_FAILED="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: one or more precheck items failed to pass!"

    #Print Tibbo-title
    load_tibbo_title__func "${DOCKER__NUMOFLINES_2}"

    #Print
    echo -e "---:${DOCKER__FG_PURPLERED}PRE${NOCOLOR}${FG_ORANGE}-CHECK:${DOCKER__NOCOLOR}: MANDATORY SOFTWARE & FILES"

    #Check if running inside docker container
    if [[ ${docker__isRunning_inside_container} == true ]]; then   #running in docker container
        echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Inside Container: true"

        docker__numOf_errors_found=0
    else    #NOT running in docker container
        echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Inside Container: false"

        #Check if docker.io is installed
        #Output: docker__numOf_errors_found
        docker__preCheck_app_isInstalled__sub "${DOCKER__PATTERN_DOCKER_IO}"

        #Check if '/usr/bin/bash' is present
        #Output: docker__numOf_errors_found
        docker__preCheck_app_isPresent__sub "${docker__myContainerId}" "${docker__bash_fpath}"

        #Check if '~/SP7021/linux/rootfs/initramfs/disk' is present
        #Output: docker__numOf_errors_found
        docker__preCheck_app_isPresent__sub "${docker__myContainerId}" "${docker__sp7021_dir}"

        #Check if '~/LTPP3_ROOTFS/development_tools/docker_build_ispboootbin.sh' is present
        #Output: docker__numOf_errors_found
        docker__preCheck_app_isPresent__sub "${docker__myContainerId}" "${docker__docker_build_ispboootbin_fpath}"
    fi

    #In case one or more failed check-items were found
    if [[ ${docker__numOf_errors_found} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
        show_errMsg_wo_menuTitle_and_exit_func "${ERRMSG_ONE_OR_MORE_CHECKITEMS_FAILED}" \
                        ${DOCKER__NUMOFLINES_1} \
                        ${DOCKER__NUMOFLINES_1}
    fi
}
docker__preCheck_app_isInstalled__sub() {
    #Input args
    local appName__input=${1}

    #Define local constants
    local INSTALLED="installed"
    local NOTINSTALLED="not-installed"

    #Check
    local docker_isInstalled=`checkIf_software_isInstalled__func "${appName__input}"`
    if [[ ${docker_isInstalled} == true ]]; then
        echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: ${appName__input}: ${DOCKER__FG_GREEN}${INSTALLED}${DOCKER__NOCOLOR}"
    else    #NOT running in docker container
        echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: ${appName__input}: ${DOCKER__FG_LIGHTRED}${NOTINSTALLED}${DOCKER__NOCOLOR}"

        docker__numOf_errors_found=$((docker__numOf_errors_found+1))
    fi
}
docker__preCheck_app_isPresent__sub() {
    #Input args
    local constainerID__input=${1}
    local path__input=${2}

    #Define local variables
    local isFound=false

    #Perform preCheck
    #First check if it's a directory
    isFound=`checkIf_dir_exists__func "${constainerID__input}" "${path__input}"`
    if [[ ${isFound} == true ]]; then
        echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: ${path__input}: ${DOCKER__FG_GREEN}present${DOCKER__NOCOLOR}"
    else
        #Second: if not a directory, then check if it's a file
        isFound=`checkIf_file_exists__func "${constainerID__input}" "${path__input}"`
        if [[ ${isFound} == true ]]; then
            echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: ${path__input}: ${DOCKER__FG_GREEN}present${DOCKER__NOCOLOR}"
        else
            echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: ${path__input}: ${DOCKER__FG_LIGHTRED}not-present${DOCKER__NOCOLOR}"

            #Increment counter
            docker__numOf_errors_found=$((docker__numOf_errors_found+1))
        fi
    fi
}

docker__run_script__sub() {
    #Define variables
    local docker_exec_cmd="docker exec -it ${docker__myContainerId} ${docker__bash_fpath} -c"
    local stdErr=${DOCKER__EMPTYSTRING}
    local cmd_outside_container="eval \"${docker__docker_build_ispboootbin_fpath}\""
    local cmd_inside_container="eval \"${docker__docker_build_ispboootbin_fpath}\""

    #Execute script 'docker_build_ispboootbin_fpath'
    if [[ ${docker__isRunning_inside_container} == true ]]; then   #currently in a container
        ${cmd_outside_container}
    else    #currently outside of a container
        ${docker_exec_cmd} "${cmd_inside_container}"
    fi

    #Check if there are any errors
    docker__exitCode=$?
    if [[ ${docker__exitCode} -ne 0 ]]; then #no errors found
        echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Build ${DOCKER__FG_LIGHTGREY}ISPBOOOT.BIN${DOCKER__NOCOLOR} ${DOCKER__FG_LIGHTRED}FAILED${DOCKER__NOCOLOR}..."

        exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_1}"
    else
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    fi
}

docker__main__sub(){
    docker__get_source_fullpath__sub

    docker__load_source_files__sub

    docker__environmental_variables__sub

    docker__init_variables__sub

    docker__checkIf_isRunning_inside_container__sub

    docker__choose_containerID__sub

    #Note:
    #   This pre-check has run AFTER 'docker__choose_containerID__sub',
    #   ...because the 'container-ID' may be needed.
    docker__preCheck__sub

    docker__run_script__sub
}


#Run main subroutine
docker__main__sub
