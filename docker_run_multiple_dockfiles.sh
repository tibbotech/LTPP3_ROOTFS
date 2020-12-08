#!/bin/bash
#---Define colors
DOCKER__ORANGE='\033[0;33m'
DOCKER__LIGHTRED='\033[1;31m'
DOCKER__LIGHTGREEN='\033[1;32m'
DOCKER__YELLOW='\033[1;33m'
DOCKER__LIGHTBLUE='\033[1;34m'
DOCKER__NOCOLOR='\033[0m'

DOCKER__BG_LIGHTBLUE='\e[30;48;5;45m'


#---Define constants
DOCKER__YES="y"
DOCKER__FIVE_SPACES="     "
DOCKER__LATEST="latest"
DOCKER__EXITING_NOW="Exiting now..."


#---Define PATHS
docker__LICENSE_filename="LICENSE"
docker__README_md_filename="README.md"
docker__LTPP3_ROOTFS_foldername="LTPP3_ROOTFS"

docker__dockerfile_list_fpath=""


#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C__sub INT

function CTRL_C__sub() {
    echo -e "\r"
    echo -e "\r"
    echo -e "${DOCKER__EXITING_NOW}"
    echo -e "\r"
    echo -e "\r"

    exit
}

press_any_key__localfunc() {
	#Define constants
	local cTIMEOUT_ANYKEY=10

	#Initialize variables
	local keypressed=""
	local tcounter=0

	#Show Press Any Key message with count-down
	echo -e "\r"
	while [[ ${tcounter} -le ${cTIMEOUT_ANYKEY} ]];
	do
		delta_tcounter=$(( ${cTIMEOUT_ANYKEY} - ${tcounter} ))

		echo -e "\rPress (a)bort or any key to continue... (${delta_tcounter}) \c"
		read -N 1 -t 1 -s -r keypressed

		if [[ ! -z "${keypressed}" ]]; then
			if [[ "${keypressed}" == "a" ]] || [[ "${keypressed}" == "A" ]]; then
				exit
			else
				break
			fi
		fi
		
		tcounter=$((tcounter+1))
	done
	echo -e "\r"
}

#---Local functions & subroutines
docker__load_header__sub() {
    echo -e "\r"
    echo -e "${DOCKER__BG_LIGHTBLUE}                               DOCKER${DOCKER__BG_LIGHTBLUE}                               ${DOCKER__NOCOLOR}"
}

docker__mandatory_apps_check__sub() {
    #Define local constants
    local DOCKER_IO="docker.io"
    local QEMU_USER_STATIC="qemu-user-static"

    local docker_io_isInstalled=`dpkg -l | grep "${DOCKER_IO}"`
    local qemu_user_static_isInstalled=`dpkg -l | grep "${QEMU_USER_STATIC}"`

    if [[ -z ${docker_io_isInstalled} ]] || [[ -z ${qemu_user_static_isInstalled} ]]; then
        echo -e "${DOCKER__FIVE_SPACES}The following mandatory software is/are not installed:"
        if [[ -z ${docker_io_isInstalled} ]]; then
            echo -e "${DOCKER__FIVE_SPACES}- docker.io"
        fi
        if [[ -z ${qemu_user_static_isInstalled} ]]; then
            echo -e "${DOCKER__FIVE_SPACES}- qemu-user-static"
        fi
        echo -e "\r"
        echo -e "${DOCKER__FIVE_SPACES}PLEASE INSTALL the missing software."
        echo -e "\r"
    fi

    press_any_key__localfunc
}

docker__get_this_running_script_dir__sub() {
    #Define local variables
    local script_basename=`basename $0`

    docker__your_repodir_LTPP3_ROOTFS_dir=`dirname "$0"`
    docker__your_repodir_LTPP3_ROOTFS_docker_dir=${docker__your_repodir_LTPP3_ROOTFS_dir}/docker
    docker__your_repodir_LTPP3_ROOTFS_docker_list_dir=${docker__your_repodir_LTPP3_ROOTFS_docker_dir}/list
    docker__your_repodir_LTPP3_ROOTFS_docker_dockerfiles_dir=${docker__your_repodir_LTPP3_ROOTFS_docker_dir}/dockerfiles

    docker__your_repodir_LTPP3_ROOTFS_LICENSE_fpath=${docker__your_repodir_LTPP3_ROOTFS_dir}/${docker__LICENSE_filename}
    docker__your_repodir_LTPP3_ROOTFS_README_md_fpath=${docker__your_repodir_LTPP3_ROOTFS_dir}/${docker__README_md_filename}

    if [[ ! -f ${docker__your_repodir_LTPP3_ROOTFS_LICENSE_fpath} ]] && [[ ! -f ${docker__your_repodir_LTPP3_ROOTFS_README_md_fpath} ]]; then
        echo -e "***${DOCKER__LIGHTRED}ERROR${DOCKER__NOCOLOR}: script '${DOCKER__ORANGE}${script_basename}${DOCKER__NOCOLOR}' might not be up-to-date."
        echo -e "Please use 'git pull' to update the scripts and then try again..."
        echo -e "\r"
        echo -e "${DOCKER__EXITING_NOW}"
        echo -e "\r"
        echo -e "\r"

        exit
    fi

}

docker__show_dockerfile_list_files__sub() {
    #Clear terminal screen
    # tput clear

    #Define variables
    local arr_line=""
    local dockerfile_list_filename=""

    #Get all files at the specified location
    local dockerfile_list_fpath_string=`find ${docker__your_repodir_LTPP3_ROOTFS_docker_list_dir} -maxdepth 1 -type f`
    local arr_line=""

    #Check if '' is an EMPTY STRING
    if [[ -z ${dockerfile_list_fpath_string} ]]; then
        echo -e "\r"
        echo -e "--------------------------------------------------------------------"
        echo -e "***${DOCKER__LIGHTRED}ERROR${DOCKER__NOCOLOR}: no files found in directory:"
        echo -e "${DOCKER__FIVE_SPACES}${docker__your_repodir_LTPP3_ROOTFS_docker_list_dir}"
        echo -e "\r"
        echo -e "Please put all ${DOCKER__YELLOW}dockerfile-list${DOCKER__NOCOLOR} files in this directory"
        echo -e "--------------------------------------------------------------------"
        echo -e "\r"
        echo -e "\r"

        exit
    fi


    #Convert string to array (with space delimiter)
    local dockerfile_list_fpath_arr=(${dockerfile_list_fpath_string})

    #Start loop
    while true
    do
        #Initial sequence number
        local seqnum=1

        #Show all 'dockerfile-list' files
        echo -e "\r"
        echo -e "--------------------------------------------------------------------"
        echo -e "Overview of all ${DOCKER__YELLOW}dockerfile-list${DOCKER__NOCOLOR} files"
        echo -e "--------------------------------------------------------------------"
        for arr_line in "${dockerfile_list_fpath_arr[@]}"
        do
            #Get filename only
            dockerfile_list_filename=`basename ${arr_line}`  
        
            #Show filename
            echo -e "${DOCKER__FIVE_SPACES}${seqnum}. ${dockerfile_list_filename}"

            #increment sequence-number
            seqnum=$((seqnum+1))
        done
        echo -e "--------------------------------------------------------------------"

        #Read-input handler
        while true
        do
            #Show read-input
            read -p "Choose a file: " mychoice

            #Check if 'mychoice' is a numeric value
            if [[ ${mychoice} =~ [1-9,0] ]]; then
                #check if 'mychoice' is one of the numbers shown in the overview...
                #... AND 'mychoice' is NOT '0'
                if [[ ${mychoice} -lt ${seqnum} ]] && [[ ${mychoice} -ne 0 ]]; then
                    echo -e "\r"    #print an empty line

                    break   #exit loop
                else
                    tput cuu1   #move-UP one line
                    tput el #clean until end of line
                fi
            else
                tput cuu1   #move-UP one line
                tput el #clean until end of line    
            fi
        done

        #Since arrays start with index=0, deduct 'mychoice' value by '1'
        index=$((mychoice-1))

        #Extract the chosen file from array and assign to the GLOBAL variable 'docker__dockerfile_list_fpath'
        docker__dockerfile_list_fpath=${dockerfile_list_fpath_arr[index]}

        local dockerfile_list_filename=`basename ${docker__dockerfile_list_fpath}`

        #Show chosen file contents
        echo -e "\r"
        echo -e "--------------------------------------------------------------------"
        echo -e "Contents of File '${dockerfile_list_filename}'"
        echo -e "--------------------------------------------------------------------"
        while read file_line
        do
            echo -e "${DOCKER__FIVE_SPACES}${file_line}"

        done < ${docker__dockerfile_list_fpath}
        echo -e "--------------------------------------------------------------------"

        #Read-input handler
        while true
        do
            #Show read-input
            read -N1 -p "Do you wish to continue (y/n): " mychoice

            #Check if 'mychoice' is a numeric value
            if [[ ${mychoice} =~ [y,n] ]]; then
                #print 2 empty lines
                echo -e "\r"
                echo -e "\r"

                if [[ ${mychoice} == ${DOCKER__YES} ]]; then
                    return  #exit function
                else
                    break   #exit THIS loop
                fi
            else
                tput cuu1   #move-UP one line
                tput el #clean until end of line    
            fi
        done
    done   
}

docker__checkif_cmd_exec_was_successful__sub() {
    exit_code=$?
    
    if [[ ${exit_code} -eq 0 ]]; then
        echo -e "\r"
        echo -e "script was executed ${DOCKER__LIGHTGREEN}successfully${DOCKER__NOCOLOR}..."
        echo -e "\r"

    else
        echo -e "\r"
        echo -e "***${DOCKER__LIGHTRED}ERROR${DOCKER__NOCOLOR}: script was stopped due to an error occurred..."
        echo -e "\r"
        echo -e "Please resolve the issue..."
        echo -e "\r"
        echo -e "${DOCKER__EXITING_NOW}"
        echo -e "\r"
        echo -e "\r"

        exit
    fi
}
docker__run_dockercmd_with_error_check__sub() {
    #Input args
    local dockerfile_fpath=${1}

    #Define constants
    GREP_PATTERN="LABEL repository:tag"

    #Get REPOSITORY:TAG from dockerfile
    local dockerfile_repository_tag=`egrep -w "${GREP_PATTERN}" ${dockerfile_fpath} | cut -d"\"" -f2`

    #Check if '' is an EMPTY STRING
    if [[ -z ${dockerfile_repository_tag} ]]; then
        dockerfile_repository_tag="${dockerfile}:${DOCKER__LATEST}"
    fi

    #Define Docker command
    dockercmd="docker build --tag ${dockerfile_repository_tag} - < ${dockerfile_fpath}" #with REPOSITORY:TAG

    #Execute Docker command
    echo -e "\r"
    echo -e "Running: ${DOCKER__ORANGE}${dockerfile_fpath}${DOCKER__NOCOLOR}"
    echo -e "\r"

    sudo sh -c "${dockercmd}" #execute cmd

    docker__checkif_cmd_exec_was_successful__sub   #check if cmd ran successfully

    echo -e "\r"
    sudo sh -c "docker image ls"    #show Docker IMAGE list
    echo -e "\r"
    echo -e "\r"
}

docker__handle_chosen_dockerfile_list__sub() {
    #---Read contents of the file
    #Each line of the file represents a 'dockerfile' containing the instructions to-be-executed
    while IFS='' read file_line
    do
        #Check if file exists
        if [[ -f ${file_line} ]]; then
            docker__run_dockercmd_with_error_check__sub ${file_line}
        fi
    done < ${docker__dockerfile_list_fpath} | tail -n +2    #skip header
}


main_sub() {
    docker__load_header__sub

    docker__get_this_running_script_dir__sub

    docker__mandatory_apps_check__sub

    docker__show_dockerfile_list_files__sub

    docker__handle_chosen_dockerfile_list__sub
}


#Execute main subroutine
main_sub
