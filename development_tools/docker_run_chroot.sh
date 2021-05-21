#!/bin/bash
#---COLOR CONSTANTS
DOCKER__NOCOLOR=$'\e[0m'
DOCKER__CHROOT_FG_GREEN=$'\e[30;38;5;82m'
DOCKER__CONTAINER_FG_BRIGHTPRUPLE=$'\e[30;38;5;141m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__FILES_FG_ORANGE=$'\e[30;38;5;215m'

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



#---VARIABLES
docker__exitCode=0



#---FUNCTIONS
#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C__sub INT

function CTRL_C__sub() {
    echo -e "\r"
    echo -e "\r"
    echo -e "${DOCKER__READ_FG_EXITING_NOW}"
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

docker__checkif_dir_exist__sub() {
    if [[ ! -d ${docker__SP7xxx_linux_rootfs_initramfs_disk_dir} ]]; then
        echo -e "\r"
        echo -e "***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Please make sure to run ${DOCKER__CHROOT_FG_GREEN}Chroot${DOCKER__NOCOLOR} from ${DOCKER__ERROR_FG_LIGHTRED}within${DOCKER__NOCOLOR} a ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}!!!"

        press_any_key_to_quit_func
    fi
}

docker__run_script__sub() {
    #Define local message constants
    local MENUTITLE="Run ${DOCKER__CHROOT_FG_GREEN}Chroot${DOCKER__NOCOLOR} from *within* a ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}"

    #Show menu-title
    echo -e "\r"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${MENUTITLE}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "\r"

    echo -e "---:${DOCKER__FILES_FG_ORANGE}NOTICE${DOCKER__NOCOLOR}: Before we continue..."
    echo -e "---:${DOCKER__FILES_FG_ORANGE}NOTICE${DOCKER__NOCOLOR}: Please make sure that ${DOCKER__FILES_FG_ORANGE}${docker__qemu_user_static_filename}${DOCKER__NOCOLOR} is ${DOCKER__GENERAL_FG_YELLOW}manually${DOCKER__NOCOLOR} installed..." 
    echo -e "---:${DOCKER__FILES_FG_ORANGE}NOTICE${DOCKER__NOCOLOR}: ... because using the already ${DOCKER__GENERAL_FG_YELLOW}built-in${DOCKER__NOCOLOR} ${DOCKER__FILES_FG_ORANGE}${docker__qemu_user_static_filename}${DOCKER__NOCOLOR}..."
    echo -e "---:${DOCKER__FILES_FG_ORANGE}NOTICE${DOCKER__NOCOLOR}: ... may result in ${DOCKER__ERROR_FG_LIGHTRED}unwanted${DOCKER__NOCOLOR} errors."

    echo -e "\r"
    echo -e "---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: Entering ${DOCKER__CHROOT_FG_GREEN}Chroot${DOCKER__NOCOLOR} environment..."

    #Check if there are any errors
    local stdErr=`chroot ${docker__SP7xxx_linux_rootfs_initramfs_disk_dir} ${docker__qemu_fpath} ${docker__bash_fpath} 2>&1 > /dev/null`
    if [[ -z ${stdErr} ]]; then #no errors found
        echo -e "---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: *Successfully* entered ${DOCKER__CHROOT_FG_GREEN}Chroot${DOCKER__NOCOLOR} environment..."

        echo -e "---:${DOCKER__FILES_FG_ORANGE}INFO${DOCKER__NOCOLOR}: Type ${DOCKER__GENERAL_FG_YELLOW}exit${DOCKER__NOCOLOR} to Exit ${DOCKER__CHROOT_FG_GREEN}Chroot${DOCKER__NOCOLOR}"
    else    #an error occured
        echo -e "---:${DOCKER__FILES_FG_ORANGE}STATUS${DOCKER__NOCOLOR}: *Unable* to enter ${DOCKER__CHROOT_FG_GREEN}Chroot${DOCKER__NOCOLOR} environment..."
        echo -e "***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: ${stdErr}"

        press_any_key_to_quit_func
    fi
    echo -e "\r"
}

docker__main__sub(){
    docker__load_header__sub

    docker__environmental_variables__sub

    docker__checkif_dir_exist__sub

    docker__run_script__sub
}


#Run main subroutine
docker__main__sub