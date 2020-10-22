#!/bin/bash
#---Define colors
DOCKER_ORANGE='\033[0;33m'
DOCKER_LIGHTRED='\033[1;31m'
DOCKER_LIGHTGREEN='\033[1;32m'
DOCKER_YELLOW='\033[1;33m'
DOCKER_LIGHTBLUE='\033[1;34m'
DOCKER_NOCOLOR='\033[0m'

#---Define variables
docker_multiple_input_files_filename="docker_multiple_input_files.txt"

docker_work_dir=`dirname "$(realpath "${0}")"`
docker_repo_LTPP3_ROOTFS_dir=/repo/LTPP3_ROOTFS

docker_multiple_input_files_fpath=${docker_work_dir}/${docker_multiple_input_files_filename}

#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C__func INT

function CTRL_C__func() {
    echo -e "\r"
    echo -e "\r"
    echo -e "Exiting now..."
    echo -e "\r"
    echo -e "\r"

    exit
}


#---Local functions
verify_if_file_exists__func() {
    #Input args
    local dockerfile_fpath=${1}

    #Execute Docker command
    if [[ ! -f ${dockerfile_fpath} ]]; then
        echo -e "\r"
        echo -e "\r"
        echo -e "***${DOCKER_LIGHTRED}ERROR${DOCKER_NOCOLOR}: docker file ${DOCKER_ORANGE}${dockerfile_fpath}${DOCKER_NOCOLOR} not found..."
        echo -e "\r"
        echo -e "Verify the location of the file."
        echo -e "\r"
        echo -e "Exiting now..."
        echo -e "\r"
        echo -e "\r"

        exit
    fi    
}
checkif_cmd_exec_was_successful__func() {
    exit_code=$?
    
    if [[ ${exit_code} -eq 0 ]]; then
        echo -e "\r"
        echo -e "\r"
        echo -e "script was executed ${DOCKER_LIGHTGREEN}successfully${DOCKER_NOCOLOR}..."
        echo -e "\r"
        echo -e "\r"
    else
        echo -e "\r"
        echo -e "\r"
        echo -e "***${DOCKER_LIGHTRED}ERROR${DOCKER_NOCOLOR}: script was stopped due to an error occurred..."
        echo -e "\r"
        echo -e "Please resolve the issue..."
        echo -e "\r"
        echo -e "Exiting now..."
        echo -e "\r"
        echo -e "\r"

        exit
    fi
}
run_dockercmd_with_error_check__func() {
    #Input args
    local dockerfile=${1}

    #Define constants
    GREP_PATTERN="LABEL repository:tag"

    #Define variables
    local dockerfile_fpath=${docker_repo_LTPP3_ROOTFS_dir}/${dockerfile}

    #Get REPOSITORY:TAG from dockerfile
    local dockerfile_repository_tag=`grep -w "${GREP_PATTERN}" ${dockerfile_fpath} | cut -d"\"" -f2`

    #Define Docker command
    local dockercmd="docker build - < ${dockerfile_fpath}"  #without REPOSITORY:TAG

    if [[ ! -z ${dockerfile_repository_tag} ]]; then
        dockercmd="docker build --tag ${dockerfile_repository_tag} - < ${dockerfile_fpath}" #with REPOSITORY:TAG
    fi


    #Verify if 'dockerfile_fpath' exist
    #If not exist, then Exit
    verify_if_file_exists__func "${dockerfile_fpath}"


    #Execute Docker command
    echo -e "\r"
    echo -e "Running: ${DOCKER_ORANGE}${dockerfile_fpath}${DOCKER_NOCOLOR}"
    echo -e "\r"

    sudo sh -c "${dockercmd}" #execute cmd

    checkif_cmd_exec_was_successful__func   #check if cmd ran successfully

    echo -e "\r"
    sudo sh -c "docker image ls"    #show Docker IMAGE list
    echo -e "\r"
}


#---Check if 'docker_multiple_input_files_fpath' is present
verify_if_file_exists__func "${docker_multiple_input_files_fpath}"

#---Read contents of the file
#Each LINE of the file represents a 'dockerfile' containing the instructions to-be-executed
sed 1d ${docker_multiple_input_files_fpath} | while read LINE  #skip header
do
    run_dockercmd_with_error_check__func ${LINE}
done
