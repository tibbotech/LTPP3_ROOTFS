#!/bin/bash
#---VARIABLES
docker__containerID=${DOCKER__EMPTYSTRING}
docker__exitCode=0
docker__isRunning_inside_container=${DOCKER__FALSE}
docker__numOf_errors_found=0



#---FUNCTIONS
function press_any_key_to_quit_func() {
	#Define constants
	local ANYKEY_TIMEOUT=3

	#Initialize variables
	local keypressed=${DOCKER__EMPTYSTRING}
	local tcounter=0

	#Show Press Any Key message with count-down
	moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
	while [[ ${tcounter} -le ${ANYKEY_TIMEOUT} ]];
	do
		delta_tcounter=$(( ${ANYKEY_TIMEOUT} - ${tcounter} ))

		echo -e "\rPress any key to continue... (${delta_tcounter}) \c"
		read -N 1 -t 1 -s -r keypressed

		if [[ ! -z "${keypressed}" ]]; then
			break
		fi
		
		tcounter=$((tcounter+1))
	done

    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
    echo -e "EXITING NOW..."
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

    exit    #exit script
}

function checkIf_isRunning_inside_container__func() {
   local PATTERN_DOCKER="docker"

   isDocker=`cat /proc/1/cgroup | grep "${PATTERN_DOCKER}"`
   if [[ ! -z ${isDocker} ]]; then
      echo ${DOCKER__TRUE}
   else
      echo ${DOCKER__FALSE}
   fi
}

function checkIf_software_isInstalled__func() {
    #Input args
    local package_input=${1}

    #Define local constants
    local pattern_packageStatus_installed="ii"

    #Define local 
    local packageStatus=`dpkg -l | grep -w "${package_input}" | awk '{print $1}'`

    #If 'stdOutput' is an EMPTY STRING, then software is NOT installed yet
    if [[ ${packageStatus} == ${pattern_packageStatus_installed} ]]; then #contains NO data
        echo ${DOCKER__TRUE}
    else
        echo ${DOCKER__FALSE}
    fi
}

function show_errMsg_without_menuTitle_noExit_func() {
    #Input args
    local errMsg=${1}

    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${errMsg}"

    press_any_key__func
}

function show_errMsg_without_menuTitle_exit_func() {
    #Input args
    local errMsg=${1}

    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${errMsg}"
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

    exit 99
}



#---SUBROUTINES
docker__environmental_variables__sub() {
    #---Define PATHS
    docker__SP7xxx_foldername="SP7021"
    docker__disk_foldername="disk"
    docker__qemu_user_static_filename="qemu-user-static"

    docker__home_dir=~
    docker__SP7xxx_dir=${docker__home_dir}/${docker__SP7xxx_foldername}
    docker__SP7xxx_linux_rootfs_initramfs_dir=${docker__SP7xxx_dir}/linux/rootfs/initramfs
    docker__SP7xxx_linux_rootfs_initramfs_disk_dir=${docker__SP7xxx_linux_rootfs_initramfs_dir}/${docker__disk_foldername}

    docker__usr_bin_dir=/usr/bin
    docker__qemu_fpath=${docker__usr_bin_dir}/qemu-arm-static
    docker__bash_fpath=${docker__usr_bin_dir}/bash

    docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})
    if [[ ${docker__current_dir} == ${DOCKER__DOT} ]]; then
        docker__current_dir=$(pwd)
    fi
    docker__current_folder=`basename ${docker__current_dir}`
    docker__current_folder=`basename ${docker__current_dir}`

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
}


docker__load_source_files__sub() {
    source ${docker__global_functions_fpath}
}

docker__load_header__sub() {
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "${DOCKER__BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__choose_containerID__sub() {
    #Define local message constants
    # local MENUTITLE="Current ${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}-list"
    local MENUTITLE="Run ${DOCKER__FG_GREEN}Chroot${DOCKER__NOCOLOR} from *within* a ${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}"
    local READMSG_CHOOSE_A_CONTAINERID="Choose a ${DOCKER__FG_BRIGHTPRUPLE}Container-ID${DOCKER__NOCOLOR} (e.g. dfc5e2f3f7ee): "

    local ERRMSG_NO_CONTAINERS_FOUND="=:${DOCKER__FG_LIGHTRED}NO CONTAINERS FOUND${DOCKER__NOCOLOR}:="
    local ERRMSG_CHOSEN_REPO_PAIR_ALREADY_EXISTS="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: chosen ${DOCKER__FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR}:${DOCKER__FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} pair already exist"

    #Define local command variables
    local docker_ps_a_cmd="docker ps -a"
 
    #Define local variables
    local errMsg=${DOCKER__EMPTYSTRING}
    local myRepository_isFound=${DOCKER__EMPTYSTRING}
    local myTag_isFound=${DOCKER__EMPTYSTRING}


#---Check if running inside Docker Container
    if [[ `checkIf_isRunning_inside_container__func` == ${DOCKER__TRUE} ]]; then   #running in docker container
        docker__isRunning_inside_container=${DOCKER__TRUE}

        return  #exit function
    else    #NOT running in docker container
        docker__isRunning_inside_container=${DOCKER__FALSE}
    fi

#---Show Docker Container's List
    #Get number of containers
    local numof_containers=`docker ps -a | head -n -1 | wc -l`
    if [[ ${numof_containers} -eq 0 ]]; then
        show_msg_w_menuTitle_w_pressAnyKey_w_ctrlC_func "${MENUTITLE}" "${ERRMSG_NO_CONTAINERS_FOUND}"
    else
        show_list_w_menuTitle__func "${MENUTITLE}" "${docker_ps_a_cmd}"
    fi

    while true
    do
        #Provide a Container-ID from which you want to create an Image
        read -e -p "${READMSG_CHOOSE_A_CONTAINERID}" docker__containerID
        if [[ ! -z ${docker__containerID} ]]; then    #input is NOT an EMPTY STRING

            #Check if 'docker__containerID' is found in ' docker ps -a'
            mycontainerid_isFound=`docker ps -a | awk '{print $1}' | grep -w ${docker__containerID}`
            if [[ ! -z ${mycontainerid_isFound} ]]; then    #match was found
                break
            else    #NO match was found
                errMsg="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Container-ID '${DOCKER__FG_BRIGHTPRUPLE}${docker__containerID}${DOCKER__NOCOLOR}' Not Found"

                show_errMsg_without_menuTitle_noExit_func "${errMsg}"

                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_5}"         
            fi
        else
            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        fi
    done
}

docker__preCheck__sub() {
    #Define local message constants
    local ERRMSG_ONE_OR_MORE_CHECKITEMS_FAILED="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: One or More Check-items failed to Pass!"

    #Print
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "---:${DOCKER__FG_PURPLERED}PRE${NOCOLOR}${FG_ORANGE}-CHECK:${DOCKER__NOCOLOR}: MANDATORY SOFTWARE & FILES"

    #Check if running inside docker container
    if [[ ${docker__isRunning_inside_container} == ${DOCKER__TRUE} ]]; then   #running in docker container
        echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Inside Container: ${DOCKER__TRUE}"

        docker__numOf_errors_found=0
    else    #NOT running in docker container
        echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Inside Container: ${DOCKER__FALSE}"

        #Check if docker.io is installed
        docker__preCheck_app_isInstalled__func "${DOCKER__PATTERN_DOCKER_IO}"

        #Check if '/usr/bin/bash' is present
        docker__preCheck_app_isPresent__func "${docker__bash_fpath}" "${docker__isRunning_inside_container}"

        #Check if '/usr/bin/qemu-arm-static' is present
        docker__preCheck_app_isPresent__func "${docker__qemu_fpath}" "${docker__isRunning_inside_container}"

        #Check if '~/SP7021/linux/rootfs/initramfs/disk' is present
        docker__preCheck_app_isPresent__func "${docker__SP7xxx_linux_rootfs_initramfs_disk_dir}" "${docker__isRunning_inside_container}"
    fi

    #In case one or more failed check-items were found
    if [[ ${docker__numOf_errors_found} -gt 0 ]]; then
        show_errMsg_without_menuTitle_exit_func "${ERRMSG_ONE_OR_MORE_CHECKITEMS_FAILED}"
    fi
}
function docker__preCheck_app_isInstalled__func() {
    #Input args
    local appName_input=${1}

    #Define local constants
    local INSTALLED="installed"
    local NOTINSTALLED="not-installed"

    #Check
    local docker_isInstalled=`checkIf_software_isInstalled__func "${appName_input}"`
    if [[ ${docker_isInstalled} == ${DOCKER__TRUE} ]]; then
        echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: ${appName_input}: ${DOCKER__FG_GREEN}${INSTALLED}${DOCKER__NOCOLOR}"
    else    #NOT running in docker container
        echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: ${appName_input}: ${DOCKER__FG_LIGHTRED}${NOTINSTALLED}${DOCKER__NOCOLOR}"

        docker__numOf_errors_found=$((docker__numOf_errors_found+1))
    fi
}
function docker__preCheck_app_isPresent__func() {
    #Input args
    local appName_input=${1}
    local isRunning_inside_container_input=${2}

    #Define local command variables
    local docker_exec_cmd="docker exec -it ${docker__containerID} ${docker__bash_fpath} -c"

    #Define local variables
    local numOf_files_found=0
    local numOf_files_found_raw=${DOCKER__EMPTYSTRING}

    #Check
    if [[ ${isRunning_inside_container_input} == ${DOCKER__TRUE} ]]; then   #running in docker container
        if [[ -f ${appName_input} ]]; then #file found
            echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: ${appName_input}: ${DOCKER__FG_GREEN}present${DOCKER__NOCOLOR}"
        else    #file not found
            echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: ${appName_input}: ${DOCKER__FG_LIGHTRED}not-present${DOCKER__NOCOLOR}"

            docker__numOf_errors_found=$((docker__numOf_errors_found+1))
        fi
    else     #NOT running in docker container
        numOf_files_found_raw=`${docker_exec_cmd} "ls -1 ${appName_input} | wc -l"`

        #***IMPORTANT: Remove carriage return '\r'
        #   'dirContent_numOfItems_max_raw' contains a carriage returns '\r'...
        #...due to the execution of '/bin/bash' in the command 'docker exec it'.
        #   To remove the carriage returns the 'listView_numOfRows_accurate_wHeader_raw' is PIPED thru 'tr -d $'\r'
        numOf_files_found=`echo "${numOf_files_found_raw}" | tr -d $'\r'`
        if [[ ${numOf_files_found} -ne 0 ]]; then   #file found
            echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: ${appName_input}: ${DOCKER__FG_GREEN}present${DOCKER__NOCOLOR}"
        else    #file not found
            echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: ${appName_input}: ${DOCKER__FG_LIGHTRED}not-present${DOCKER__NOCOLOR}"

            docker__numOf_errors_found=$((docker__numOf_errors_found+1))
        fi
    fi
}


docker__run_script__sub() {
    #Define local message constants
    # local MENUTITLE="Run ${DOCKER__FG_GREEN}Chroot${DOCKER__NOCOLOR} from *within* a ${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}"

    #Define local command variables
    local docker_exec_cmd="docker exec -it ${docker__containerID} ${docker__bash_fpath} -c"

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
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

    #Run chroot command
    #REMARK: make a choice based on whether currently running in 'local-host' or 'container'
    if [[ ${docker__isRunning_inside_container} == ${DOCKER__TRUE} ]]; then   #running in docker container
        chroot ${docker__SP7xxx_linux_rootfs_initramfs_disk_dir} ${docker__qemu_fpath} ${docker__bash_fpath}
    else    #NOT running in docker container
        ${docker_exec_cmd} "chroot ${docker__SP7xxx_linux_rootfs_initramfs_disk_dir} ${docker__qemu_fpath} ${docker__bash_fpath}"
    fi

    #Check if there are any errors
    exitCode=$?
    if [[ ${exitCode} -ne 0 ]]; then #no errors found
        echo -e "---:${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}: *Unable* to enter ${DOCKER__FG_GREEN}Chroot${DOCKER__NOCOLOR} environment..."
    fi
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
}

docker__main__sub(){
    docker__environmental_variables__sub

    docker__load_source_files__sub

    docker__load_header__sub

    docker__choose_containerID__sub

    docker__preCheck__sub

    docker__run_script__sub
}


#Run main subroutine
docker__main__sub


#  docker exec -it 9c08c7dde301 /bin/bash -c "chroot /root/SP7021/linux/rootfs/initramfs/disk /usr/bin/qemu-arm-static /usr/bin/bash"