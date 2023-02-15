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
    #Check if 'docker__global__fpath' is an 'Empty String'
    #Remark:
    #   'docker__global__fpath' is a global variable.
    #   A parent script, which is calling 'this script', may have updated 'docker__global__fpath' already.
    #   Therefore, this check has been implemented to prevent unnecessary overhead.
    if [[ -z ${docker__global__fpath} ]]; then
        #Define variables
        local docker__current_dir="${EMPTYSTRING}"
        local docker__home_dir=~

        local docker__development_tools__foldername="${EMPTYSTRING}"
        local docker__LTPP3_ROOTFS__foldername="${EMPTYSTRING}"
        local docker__global__filename="${EMPTYSTRING}"
        local docker__parentDir_of_LTPP3_ROOTFS__dir="${EMPTYSTRING}"

        local docker__find_dir_result_arr=()
        local docker__find_dir_result_arritem="${EMPTYSTRING}"
        local docker__find_path_of_LTPP3_ROOTFS="${EMPTYSTRING}"

        local docker__repo_of_LTPP3_ROOTFS="${EMPTYSTRING}"



        #Set variables
        current_dir=$(pwd)
        docker__development_tools__foldername="development_tools"
        docker__global__filename="docker_global.sh"
        docker__LTPP3_ROOTFS__foldername="LTPP3_ROOTFS"
        docker__repo_of_LTPP3_ROOTFS="git@github.com:tibbotech/${docker__LTPP3_ROOTFS__foldername}.git"



        #Start loop
        while true
        do
            #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
            #... and read to array 'find_result_arr'
            readarray -t docker__find_dir_result_arr < <(find  / -type d -iname "${docker__LTPP3_ROOTFS__foldername}" 2> /dev/null)

            for docker__find_dir_result_arritem in "${docker__find_dir_result_arr[@]}"
            do
                #Update variable 'docker__find_path_of_LTPP3_ROOTFS'
                docker__find_path_of_LTPP3_ROOTFS="${docker__find_dir_result_arritem}/${docker__development_tools__foldername}"
                #Check if 'directory' exist
                if [[ -d "${docker__find_path_of_LTPP3_ROOTFS}" ]]; then    #directory exists
                    #Update variable
                    #Remark:
                    #   'docker__LTPP3_ROOTFS_development_tools__dir' is a global variable.
                    #   This variable will be passed 'globally' to script 'docker_global.sh'.
                    docker__LTPP3_ROOTFS_development_tools__dir="${docker__find_path_of_LTPP3_ROOTFS}"

                    break
                fi
            done

            #Check if 'docker__LTPP3_ROOTFS_development_tools__dir' contains any data
            if [[ -z "${docker__LTPP3_ROOTFS_development_tools__dir}" ]]; then  #contains no data
                #Check if repo exists
                git ls-remote --heads "${docker__repo_of_LTPP3_ROOTFS}" >1 /dev/null; exitcode=$?

                #Exit if 'exitcode > 0'
                if [[ ${exitcode} -ne 0 ]]; then
                    exit ${exitcode}
                fi

                #Go to home-dir
                cd "${docker__home_dir}"

                #Clone repo
                git clone "${docker__repo_of_LTPP3_ROOTFS}"

                #Go back to current-dir
                cd "${current_dir}"
            else    #contains data
                breaklinux_rootfs_initramfs_disk_dir
            fi
        done



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
    fi
}

docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

docker__environmental_variables__sub() {
    #---Define PATHS
    docker__SP7xxx_foldername="SP7021"
    docker__disk_foldername="disk"
    docker__qemu_user_static_filename="qemu-user-static"

    docker__home_dir=~
    docker__sp7021_dir=${docker__home_dir}/${docker__SP7xxx_foldername}
    docker__sp7021_linux_rootfs_initramfs_dir=${docker__sp7021_dir}/linux/rootfs/initramfs
    docker__sp7021_linux_rootfs_initramfs_disk_dir=${docker__sp7021_linux_rootfs_initramfs_dir}/${docker__disk_foldername}

    docker__usr_bin_dir=/usr/bin
    docker__qemu_fpath=${docker__usr_bin_dir}/qemu-arm-static
    docker__bash_fpath=${docker__usr_bin_dir}/bash
}

docker__init_variables__sub() {
    docker__myContainerId=${DOCKER__EMPTYSTRING}
    docker__isRunning_inside_container=false
    docker__numOf_errors_found=0

    docker__exitCode=0

    docker__showTable=true
    docker__onEnter_breakLoop=true
}

docker__checkIf_isRunning_inside_container__sub() {
    #Define contants
    local PATTERN_DOCKER="docker"

    #Define variablers
    local proc_1_cgroup_dir=/proc/1/cgroup

    isDocker=`cat "${proc_1_cgroup_dir}" | grep "${PATTERN_DOCKER}"`
    if [[ ! -z ${isDocker} ]]; then
        docker__isRunning_inside_container=true
    else
        docker__isRunning_inside_container=false
    fi
}

docker__choose_containerID__sub() {
    #Define local message constants
    # local MENUTITLE="Current ${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}-list"
    local MENUTITLE="Run ${DOCKER__FG_GREEN}Chroot${DOCKER__NOCOLOR} from *within* a ${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}"
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
    local ERRMSG_ONE_OR_MORE_CHECKITEMS_FAILED="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: One or More Check-items failed to Pass!"

    #Print
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
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

        #Check if '/usr/bin/qemu-arm-static' is present
        #Output: docker__numOf_errors_found
        docker__preCheck_app_isPresent__sub "${docker__myContainerId}" "${docker__qemu_fpath}"

        #Check if '~/SP7021/linux/rootfs/initramfs/disk' is present
        #Output: docker__numOf_errors_found
        docker__preCheck_app_isPresent__sub "${docker__myContainerId}" "${docker__sp7021_linux_rootfs_initramfs_disk_dir}"
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
    #Define local message constants
    # local MENUTITLE="Run ${DOCKER__FG_GREEN}Chroot${DOCKER__NOCOLOR} from *within* a ${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}"

    #Define local command variables
    local docker_exec_cmd="docker exec -it ${docker__myContainerId} ${docker__bash_fpath} -c"

    #Define local variables
    local exitCode=-1
    local stdErr=${DOCKER__EMPTYSTRING}
    


    #Show menu-title
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    # duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    # show_centered_string__func "${MENUTITLE}" "${DOCKER__TABLEWIDTH}"
    # duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "---:${DOCKER__FG_ORANGE}NOTICE${DOCKER__NOCOLOR}: ..."
    echo -e "---:${DOCKER__FG_ORANGE}NOTICE${DOCKER__NOCOLOR}: Before we continue..."
    echo -e "---:${DOCKER__FG_ORANGE}NOTICE${DOCKER__NOCOLOR}: Please make sure that ${DOCKER__FG_ORANGE}${docker__qemu_user_static_filename}${DOCKER__NOCOLOR} is ${DOCKER__FG_YELLOW}manually${DOCKER__NOCOLOR} installed..." 
    echo -e "---:${DOCKER__FG_ORANGE}NOTICE${DOCKER__NOCOLOR}: ... because using the already ${DOCKER__FG_YELLOW}built-in${DOCKER__NOCOLOR} ${DOCKER__FG_ORANGE}${docker__qemu_user_static_filename}${DOCKER__NOCOLOR}..."
    echo -e "---:${DOCKER__FG_ORANGE}NOTICE${DOCKER__NOCOLOR}: ... may result in ${DOCKER__FG_LIGHTRED}unwanted${DOCKER__NOCOLOR} errors."

    press_any_key__func

    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Entering ${DOCKER__FG_GREEN}Chroot${DOCKER__NOCOLOR} environment..."
    echo -e "---:${DOCKER__FG_ORANGE}INFO${DOCKER__NOCOLOR}: Type ${DOCKER__FG_YELLOW}exit${DOCKER__NOCOLOR} to Exit ${DOCKER__FG_GREEN}Chroot${DOCKER__NOCOLOR}"
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    #Run chroot command
    #REMARK: make a choice based on whether currently running in 'local-host' or 'container'
    if [[ ${docker__isRunning_inside_container} == true ]]; then   #running in docker container
        chroot ${docker__sp7021_linux_rootfs_initramfs_disk_dir} ${docker__qemu_fpath} ${docker__bash_fpath}
    else    #NOT running in docker container
        ${docker_exec_cmd} "chroot ${docker__sp7021_linux_rootfs_initramfs_disk_dir} ${docker__qemu_fpath} ${docker__bash_fpath}"
    fi

    #Check if there are any errors
    exitCode=$?
    if [[ ${exitCode} -ne 0 ]]; then #no errors found
        echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: *Unable* to enter ${DOCKER__FG_GREEN}Chroot${DOCKER__NOCOLOR} environment..."

        exit__func "${exitCode}" "${DOCKER__NUMOFLINES_1}"
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

    docker__preCheck__sub

    docker__run_script__sub
}


#Run main subroutine
docker__main__sub


#  docker exec -it 9c08c7dde301 /bin/bash -c "chroot /root/SP7021/linux/rootfs/initramfs/disk /usr/bin/qemu-arm-static /usr/bin/bash"