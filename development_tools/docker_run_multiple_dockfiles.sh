#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---FUNCTIONS
press_any_key__func() {
	#Define constants
	local ANYKEY_TIMEOUT=10

	#Initialize variables
	local keypressed=""
	local tcounter=0

	#Show Press Any Key message with count-down
	moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
	while [[ ${tcounter} -le ${ANYKEY_TIMEOUT} ]];
	do
		delta_tcounter=$(( ${ANYKEY_TIMEOUT} - ${tcounter} ))

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
	moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
}

docker__get_source_fullpath__sub() {
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

docker__init_variables__sub() {
    docker__LICENSE_filename="LICENSE"
    docker__README_md_filename="README.md"
    docker__LTPP3_ROOTFS_foldername="LTPP3_ROOTFS"

    docker__dockerfile_list_fpath=""
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
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "${DOCKER__FIVE_SPACES}PLEASE INSTALL the missing software."
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        
        press_any_key__func
    fi
}

docker__get_this_running_script_dir__sub() {
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
}

docker__show_dockerfile_list_files__sub() {
    #Clear terminal screen
    # tput clear

    #Define variables
    local arr_line=""
    local dockerfile_list_filename=""

    #Get all files at the specified location
    local dockerfile_list_fpath_string=`find ${docker__my_LTPP3_ROOTFS_docker_list_dir} -maxdepth 1 -type f | sort`
    local arr_line=""

    #Check if '' is an EMPTY STRING
    if [[ -z ${dockerfile_list_fpath_string} ]]; then
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "----------------------------------------------------------------------"
        echo -e "***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: no files found in directory:"
        echo -e "${DOCKER__FIVE_SPACES}${docker__my_LTPP3_ROOTFS_docker_list_dir}"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "Please put all ${DOCKER__FG_YELLOW}dockerfile-list${DOCKER__NOCOLOR} files in this directory"

        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

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
        echo -e "----------------------------------------------------------------------"
        echo -e "\t${DOCKER__FG_YELLOW}Create${DOCKER__NOCOLOR} multiple ${DOCKER__FG_BORDEAUX}IMAGES${DOCKER__NOCOLOR} with ${DOCKER__FG_LIGHTBLUE}DOCKER-FILES${DOCKER__NOCOLOR}"
        echo -e "----------------------------------------------------------------------"
        for arr_line in "${dockerfile_list_fpath_arr[@]}"
        do
            #Get filename only
            dockerfile_list_filename=`basename ${arr_line}`  
        
            #Show filename
            echo -e "${DOCKER__FIVE_SPACES}${seqnum}. ${dockerfile_list_filename}"

            #increment sequence-number
            seqnum=$((seqnum+1))
        done
        echo -e "----------------------------------------------------------------------"

        #Read-input handler
        while true
        do
            #Show read-input
            read -e -p "Choose a file (ctrl+c: quit): " mychoice

            #Check if 'mychoice' is a numeric value
            if [[ ${mychoice} =~ [1-9,0] ]]; then
                #check if 'mychoice' is one of the numbers shown in the overview...
                #... AND 'mychoice' is NOT '0'
                if [[ ${mychoice} -lt ${seqnum} ]] && [[ ${mychoice} -ne 0 ]]; then
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"    #print an empty line

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
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "----------------------------------------------------------------------"
        echo -e "Contents of File ${DOCKER__FG_ORANGE}${dockerfile_list_filename}${DOCKER__NOCOLOR}"
        echo -e "----------------------------------------------------------------------"
        while read file_line
        do
            echo -e "${DOCKER__FIVE_SPACES}${file_line}"

        done < ${docker__dockerfile_list_fpath}
        echo -e "----------------------------------------------------------------------"

        #Read-input handler
        while true
        do
            #Show read-input
            read -N1 -p "Do you wish to continue (y/n): " mychoice

            #Check if 'mychoice' is a numeric value
            if [[ ${mychoice} =~ [y,n] ]]; then
                #print 2 empty lines
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

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
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "script was executed ${DOCKER__FG_LIGHTGREEN}successfully${DOCKER__NOCOLOR}..."
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    else
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: script was stopped due to an error occurred..."
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "Please resolve the issue..."
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        echo -e "${DOCKER__EXITING_NOW}"
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"

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
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    echo -e "Running: ${DOCKER__FG_ORANGE}${dockerfile_fpath}${DOCKER__NOCOLOR}"
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    sudo sh -c "${dockercmd}" #execute cmd

    docker__checkif_cmd_exec_was_successful__sub   #check if cmd ran successfully

    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        ${docker__repolist_tableinfo__fpath}
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
}

docker__handle_chosen_dockerfile_list__sub() {
    #---Read contents of the file
    #Each line of the file represents a 'dockerfile' containing the instructions to-be-executed
    
    #Define variables
    local linenum=1
    local dockerfile_fpath=""

    while IFS='' read file_line
    do
        if [[ ${linenum} -gt 1 ]]; then #skip the header
            #Get the fullpath
            dockerfile_fpath=${docker__my_LTPP3_ROOTFS_docker_dockerfiles_dir}/${file_line}

            #Check if file exists
            if [[ -f ${dockerfile_fpath} ]]; then
                docker__run_dockercmd_with_error_check__sub ${dockerfile_fpath}
            else
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                echo -e "***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: non-existing file: ${dockerfile_fpath}"
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
            fi
        fi

        linenum=$((linenum+1))  #increment index by 1
    done < ${docker__dockerfile_list_fpath}
}


main_sub() {
    docker__get_source_fullpath__sub

    docker__load_source_files__sub

    load_tibbo_title__func "${DOCKER__NUMOFLINES_2}"

    docker__init_variables__sub

    docker__get_this_running_script_dir__sub

    docker__mandatory_apps_check__sub

    docker__show_dockerfile_list_files__sub

    docker__handle_chosen_dockerfile_list__sub
}


#Execute main subroutine
main_sub
