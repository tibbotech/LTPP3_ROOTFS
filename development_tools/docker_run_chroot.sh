#!/bin/bash
#---COLOR CONSTANTS
DOCKER__NOCOLOR=$'\e[0m'
DOCKER__CHROOT_FG_GREEN=$'\e[30;38;5;82m'
DOCKER__CONTAINER_FG_BRIGHTPRUPLE=$'\e[30;38;5;141m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__FG_PURPLERED=$'\e[30;38;5;198m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__FILES_FG_ORANGE=$'\e[30;38;5;215m'
DOCKER__FG_LIGHTGREY=$'\e[30;38;5;246m'

DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'
DOCKER__TITLE_BG_LIGHTBLUE='\e[30;48;5;45m'

#---CONSTANTS
DOCKER__TITLE="TIBBO"

#---CHARACTER CHONSTANTS
DOCKER__DASH="-"
DOCKER__EMPTYSTRING=""
DOCKER__ENTER=$'\x0a'

DOCKER__ONESPACE=" "
DOCKER__TWOSPACES=${DOCKER__ONESPACE}${DOCKER__ONESPACE}
DOCKER__FOURSPACES=${DOCKER__TWOSPACES}${DOCKER__TWOSPACES}

#---NUMERIC CONSTANTS
DOCKER__NINE=9
DOCKER__TABLEWIDTH=70

#---BOOLEAN CONSTANTS
TRUE=true
FALSE=false

#---PATTERN CONSTANTS
DOCKER__PATTERN_DOCKER_IO="docker.io"

#---NUMERIC CONSTANTS
DOCKER__NUMOFLINES_1=1
DOCKER__NUMOFLINES_2=2
DOCKER__NUMOFLINES_3=3
DOCKER__NUMOFLINES_4=4
DOCKER__NUMOFLINES_5=5
DOCKER__NUMOFLINES_6=6

#---MENU CONSTANTS
DOCKER__CTRL_C_QUIT="${DOCKER__FOURSPACES}Quit (Ctrl+C)"

#---VARIABLES
docker__containerID=${DOCKER__EMPTYSTRING}
docker__exitCode=0
docker__isRunning_inside_container=${FALSE}
docker__numOf_errors_found=0


#---FUNCTIONS
#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C__sub INT

function CTRL_C__sub() {
    echo -e "\r"
    echo -e "\r"

    exit
}

function press_any_key__func() {
	#Define constants
	local ANYKEY_TIMEOUT=3

	#Initialize variables
	local keypressed=${DOCKER__EMPTYSTRING}
	local tcounter=0

	#Show Press Any Key message with count-down
	echo -e "\r"
	while [[ ${tcounter} -le ${ANYKEY_TIMEOUT} ]];
	do
		delta_tcounter=$(( ${ANYKEY_TIMEOUT} - ${tcounter} ))

		echo -e "\rPress (a)bort or any key to continue... (${delta_tcounter}) \c"
		read -N 1 -t 1 -s -r keypressed

		if [[ ! -z "${keypressed}" ]]; then
			if [[ "${keypressed}" == "a" ]] || [[ "${keypressed}" == "A" ]]; then
                echo -e "\r"
                echo -e "\r"
				exit
			else
				break
			fi
		fi
		
		tcounter=$((tcounter+1))
	done
	echo -e "\r"
}

function press_any_key_to_quit_func() {
	#Define constants
	local ANYKEY_TIMEOUT=3

	#Initialize variables
	local keypressed=${DOCKER__EMPTYSTRING}
	local tcounter=0

	#Show Press Any Key message with count-down
	echo -e "\r"
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

    echo -e "\r"
    echo -e "\r"
    echo -e "EXITING NOW..."
    echo -e "\r"
    echo -e "\r"

    exit    #exit script
}

function show_centered_string__func()
{
    #Input args
    local str_input=${1}
    local maxStrLen_input=${2}

    #Define one-space constant
    local ONESPACE=" "

    #Get string 'without visiable' color characters
    local strInput_wo_colorChars=`echo "${str_input}" | sed "s,\x1B\[[0-9;]*m,,g"`

    #Get string length
    local strInput_wo_colorChars_len=${#strInput_wo_colorChars}

    #Calculated the number of spaces to-be-added
    local numOf_spaces=$(( (maxStrLen_input-strInput_wo_colorChars_len)/2 ))

    #Create a string containing only EMPTY SPACES
    local emptySpaces_string=`duplicate_char__func "${ONESPACE}" "${numOf_spaces}" `

    #Print text including Leading Empty Spaces
    echo -e "${emptySpaces_string}${str_input}"
}

function duplicate_char__func()
{
    #Input args
    local char_input=${1}
    local numOf_times=${2}

    #Duplicate 'char_input'
    local char_duplicated=`printf '%*s' "${numOf_times}" | tr ' ' "${char_input}"`

    #Print text including Leading Empty Spaces
    echo -e "${char_duplicated}"
}

function moveUp_and_cleanLines__func() {
    #Input args
    local numOf_lines_toBeCleared=${1}

    #Clear lines
    local numOf_lines_cleared=1
    while [[ ${numOf_lines_cleared} -le ${numOf_lines_toBeCleared} ]]
    do
        tput cuu1	#move UP with 1 line
        tput el		#clear until the END of line

        numOf_lines_cleared=$((numOf_lines_cleared+1))  #increment by 1
    done
}

function moveDown_and_cleanLines__func() {
    #Input args
    local numOf_lines_toBeCleared=${1}

    #Clear lines
    local numOf_lines_cleared=1
    while [[ ${numOf_lines_cleared} -le ${numOf_lines_toBeCleared} ]]
    do
        tput cud1	#move UP with 1 line
        tput el1	#clear until the END of line

        numOf_lines_cleared=$((numOf_lines_cleared+1))  #increment by 1
    done
}

function checkIf_isRunning_inside_container__func() {
   local PATTERN_DOCKER="docker"

   isDocker=`cat /proc/1/cgroup | grep "${PATTERN_DOCKER}"`
   if [[ ! -z ${isDocker} ]]; then
      echo ${TRUE}
   else
      echo ${FALSE}
   fi
}

function checkIf_software_isInstalled__func()
{
    #Input args
    local package_input=${1}

    #Define local constants
    local pattern_packageStatus_installed="ii"

    #Define local 
    local packageStatus=`dpkg -l | grep -w "${package_input}" | awk '{print $1}'`

    #If 'stdOutput' is an EMPTY STRING, then software is NOT installed yet
    if [[ ${packageStatus} == ${pattern_packageStatus_installed} ]]; then #contains NO data
        echo ${TRUE}
    else
        echo ${FALSE}
    fi
}

function docker__show_list_with_menuTitle__func() {
    #Input args
    local menuTitle=${1}
    local dockerCmd=${2}

    #Show list
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${menuTitle}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    
    ${dockerCmd}

    echo -e "\r"

    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${DOCKER__CTRL_C_QUIT}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
}

function docker__show_errMsg_with_menuTitle__func() {
    #Input args
    local menuTitle=${1}
    local errMsg=${2}

    #Show error-message
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${menuTitle}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    
    echo -e "\r"
    show_centered_string__func "${errMsg}" "${DOCKER__TABLEWIDTH}"
    echo -e "\r"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "\r"

    press_any_key__func

    CTRL_C__sub
}

function docker__show_errMsg_without_menuTitle_noExit_func() {
    #Input args
    local errMsg=${1}

    echo -e "\r"
    echo -e "${errMsg}"

    press_any_key__func
}

function docker__show_errMsg_without_menuTitle_exit_func() {
    #Input args
    local errMsg=${1}

    echo -e "\r"
    echo -e "${errMsg}"
    echo -e "\r"
    echo -e "\r"

    exit 99
}

function moveUp_and_cleanLines__func() {
    #Input args
    local numOf_lines_toBeCleared=${1}

    #Clear lines
    local numOf_lines_cleared=1
    while [[ ${numOf_lines_cleared} -le ${numOf_lines_toBeCleared} ]]
    do
        tput cuu1	#move UP with 1 line
        tput el		#clear until the END of line

        numOf_lines_cleared=$((numOf_lines_cleared+1))  #increment by 1
    done
}

function moveDown_and_cleanLines__func() {
    #Input args
    local numOf_lines_toBeCleared=${1}

    #Clear lines
    local numOf_lines_cleared=1
    while [[ ${numOf_lines_cleared} -le ${numOf_lines_toBeCleared} ]]
    do
        tput cud1	#move UP with 1 line
        tput el1	#clear until the END of line

        numOf_lines_cleared=$((numOf_lines_cleared+1))  #increment by 1
    done
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
}


#SHOW DOCKER BANNER
docker__load_header__sub() {
    echo -e "\r"
    echo -e "${DOCKER__TITLE_BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__TITLE_BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__choose_containerID__sub() {
    #Define local message constants
    # local MENUTITLE="Current ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}-list"
    local MENUTITLE="Run ${DOCKER__CHROOT_FG_GREEN}Chroot${DOCKER__NOCOLOR} from *within* a ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}"
    local READMSG_CHOOSE_A_CONTAINERID="Choose a ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Container-ID${DOCKER__NOCOLOR} (e.g. dfc5e2f3f7ee): "

    local ERRMSG_NO_CONTAINERS_FOUND="=:${DOCKER__ERROR_FG_LIGHTRED}NO CONTAINERS FOUND${DOCKER__NOCOLOR}:="
    local ERRMSG_CHOSEN_REPO_PAIR_ALREADY_EXISTS="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: chosen ${DOCKER__NEW_REPOSITORY_FG_BRIGHTLIGHTPURPLE}Repository${DOCKER__NOCOLOR}:${DOCKER__TAG_FG_LIGHTPINK}Tag${DOCKER__NOCOLOR} pair already exist"

    #Define local command variables
    local docker_ps_a_cmd="docker ps -a"
 
    #Define local variables
    local errMsg=${DOCKER__EMPTYSTRING}
    local myRepository_isFound=${DOCKER__EMPTYSTRING}
    local myTag_isFound=${DOCKER__EMPTYSTRING}


#---Check if running inside Docker Container
    if [[ `checkIf_isRunning_inside_container__func` == ${TRUE} ]]; then   #running in docker container
        docker__isRunning_inside_container=${TRUE}

        return  #exit function
    else    #NOT running in docker container
        docker__isRunning_inside_container=${FALSE}
    fi

#---Show Docker Container's List
    #Get number of containers
    local numof_containers=`docker ps -a | head -n -1 | wc -l`
    if [[ ${numof_containers} -eq 0 ]]; then
        docker__show_errMsg_with_menuTitle__func "${MENUTITLE}" "${ERRMSG_NO_CONTAINERS_FOUND}"
    else
        docker__show_list_with_menuTitle__func "${MENUTITLE}" "${docker_ps_a_cmd}"
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
                errMsg="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Container-ID '${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}${docker__containerID}${DOCKER__NOCOLOR}' Not Found"

                docker__show_errMsg_without_menuTitle_noExit_func "${errMsg}"

                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_5}"         
            fi
        else
            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        fi
    done
}

docker__preCheck__sub() {
    #Define local message constants
    local ERRMSG_ONE_OR_MORE_CHECKITEMS_FAILED="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: One or More Check-items failed to Pass!"

    #Print
    echo -e "\r"
    echo -e "---:${DOCKER__FG_PURPLERED}PRE${NOCOLOR}${FG_ORANGE}-CHECK:${DOCKER__NOCOLOR}: MANDATORY SOFTWARE & FILES"

    #Check if running inside docker container
    if [[ ${docker__isRunning_inside_container} == ${TRUE} ]]; then   #running in docker container
        echo -e "---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Inside Container: ${TRUE}"
    else    #NOT running in docker container
        echo -e "---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Inside Container: ${FALSE}"
    fi

    #Check if docker.io is installed
    docker__preCheck_app_isInstalled__func "${DOCKER__PATTERN_DOCKER_IO}"

    #Check if '/usr/bin/bash' is present
    docker__preCheck_app_isPresent__func "${docker__bash_fpath}" "${docker__isRunning_inside_container}"

    #Check if '/usr/bin/qemu-arm-static' is present
    docker__preCheck_app_isPresent__func "${docker__qemu_fpath}" "${docker__isRunning_inside_container}"

    #Check if '~/SP7021/linux/rootfs/initramfs/disk' is present
    docker__preCheck_app_isPresent__func "${docker__SP7xxx_linux_rootfs_initramfs_disk_dir}" "${docker__isRunning_inside_container}"

    #In case one or more failed check-items were found
    if [[ ${docker__numOf_errors_found} -gt 0 ]]; then
        docker__show_errMsg_without_menuTitle_exit_func "${ERRMSG_ONE_OR_MORE_CHECKITEMS_FAILED}"
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
    if [[ ${docker_isInstalled} == ${TRUE} ]]; then
        echo -e "---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: ${appName_input}: ${DOCKER__CHROOT_FG_GREEN}${INSTALLED}${DOCKER__NOCOLOR}"
    else    #NOT running in docker container
        echo -e "---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: ${appName_input}: ${DOCKER__ERROR_FG_LIGHTRED}${NOTINSTALLED}${DOCKER__NOCOLOR}"

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
    if [[ ${isRunning_inside_container_input} == ${TRUE} ]]; then   #running in docker container
        if [[ -f ${appName_input} ]]; then #file found
            echo -e "---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: ${appName_input}: ${DOCKER__CHROOT_FG_GREEN}present${DOCKER__NOCOLOR}"
        else    #file not found
            echo -e "---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: ${appName_input}: ${DOCKER__ERROR_FG_LIGHTRED}not-present${DOCKER__NOCOLOR}"

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
            echo -e "---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: ${appName_input}: ${DOCKER__CHROOT_FG_GREEN}present${DOCKER__NOCOLOR}"
        else    #file not found
            echo -e "---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: ${appName_input}: ${DOCKER__ERROR_FG_LIGHTRED}not-present${DOCKER__NOCOLOR}"

            docker__numOf_errors_found=$((docker__numOf_errors_found+1))
        fi
    fi
}


docker__run_script__sub() {
    #Define local message constants
    # local MENUTITLE="Run ${DOCKER__CHROOT_FG_GREEN}Chroot${DOCKER__NOCOLOR} from *within* a ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}"

    #Define local command variables
    local docker_exec_cmd="docker exec -it ${docker__containerID} ${docker__bash_fpath} -c"

    #Define local variables
    local exitCode=-1
    local stdErr=${DOCKER__EMPTYSTRING}
    


    #Show menu-title
    echo -e "\r"
    # echo -e "\r"
    # duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    # show_centered_string__func "${MENUTITLE}" "${DOCKER__TABLEWIDTH}"
    # duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "---:${DOCKER__FILES_FG_ORANGE}NOTICE${DOCKER__NOCOLOR}: ..."
    echo -e "---:${DOCKER__FILES_FG_ORANGE}NOTICE${DOCKER__NOCOLOR}: Before we continue..."
    echo -e "---:${DOCKER__FILES_FG_ORANGE}NOTICE${DOCKER__NOCOLOR}: Please make sure that ${DOCKER__FILES_FG_ORANGE}${docker__qemu_user_static_filename}${DOCKER__NOCOLOR} is ${DOCKER__GENERAL_FG_YELLOW}manually${DOCKER__NOCOLOR} installed..." 
    echo -e "---:${DOCKER__FILES_FG_ORANGE}NOTICE${DOCKER__NOCOLOR}: ... because using the already ${DOCKER__GENERAL_FG_YELLOW}built-in${DOCKER__NOCOLOR} ${DOCKER__FILES_FG_ORANGE}${docker__qemu_user_static_filename}${DOCKER__NOCOLOR}..."
    echo -e "---:${DOCKER__FILES_FG_ORANGE}NOTICE${DOCKER__NOCOLOR}: ... may result in ${DOCKER__ERROR_FG_LIGHTRED}unwanted${DOCKER__NOCOLOR} errors."

    press_any_key__func

    echo -e "\r"
    echo -e "---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Entering ${DOCKER__CHROOT_FG_GREEN}Chroot${DOCKER__NOCOLOR} environment..."
    echo -e "---:${DOCKER__FILES_FG_ORANGE}INFO${DOCKER__NOCOLOR}: Type ${DOCKER__GENERAL_FG_YELLOW}exit${DOCKER__NOCOLOR} to Exit ${DOCKER__CHROOT_FG_GREEN}Chroot${DOCKER__NOCOLOR}"
    echo -e "\r"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "\r"
    echo -e "\r"

    #Run chroot command
    #REMARK: make a choice based on whether currently running in 'local-host' or 'container'
    if [[ ${docker__isRunning_inside_container} == ${TRUE} ]]; then   #running in docker container
        chroot ${docker__SP7xxx_linux_rootfs_initramfs_disk_dir} ${docker__qemu_fpath} ${docker__bash_fpath}
    else    #NOT running in docker container
        ${docker_exec_cmd} "chroot ${docker__SP7xxx_linux_rootfs_initramfs_disk_dir} ${docker__qemu_fpath} ${docker__bash_fpath}"
    fi

    #Check if there are any errors
    exitCode=$?
    if [[ ${exitCode} -ne 0 ]]; then #no errors found
        echo -e "---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: *Unable* to enter ${DOCKER__CHROOT_FG_GREEN}Chroot${DOCKER__NOCOLOR} environment..."
    fi
    echo -e "\r"
}

docker__main__sub(){
    docker__load_header__sub

    docker__environmental_variables__sub

    docker__choose_containerID__sub

    docker__preCheck__sub

    docker__run_script__sub
}


#Run main subroutine
docker__main__sub


#  docker exec -it 9c08c7dde301 /bin/bash -c "chroot /root/SP7021/linux/rootfs/initramfs/disk /usr/bin/qemu-arm-static /usr/bin/bash"