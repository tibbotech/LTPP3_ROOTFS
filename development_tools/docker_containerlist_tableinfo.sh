#!/bin/bash
#---SUBROUTINES
docker__get_source_fullpath__sub() {
    #---Define PATHS
    docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})
    if [[ ${docker__current_dir} == ${DOCKER__DOT} ]]; then
        docker__current_dir=$(pwd)
    fi
    docker__current_folder=`basename ${docker__current_dir}`

    docker__development_tools_folder="development_tools"
    if [[ ${docker__current_folder} != ${docker__development_tools_folder} ]]; then
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}/${docker__development_tools_folder}
    else
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}
    fi

    docker__global__filename="docker_global.sh"
    docker__global__fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global__filename}

    docker__tmp_dir="/tmp"
    docker__docker_containerList_tmp__filename="docker__docker_containerList.tmp"
    docker__docker_containerList_tmp__fpath=${docker__tmp_dir}/${docker__docker_containerList_tmp__filename}
}

docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

docker__get_docker_containerList__sub() {
    #Define constants
    local CONTAINER_ID="CONTAINER-ID"
    local DOCKER_PS_A_CMD="docker ps -a"
    local PORT="SSH-PORT"
    local REPO_TAG="REPO:TAG"
    local STATUS="STATUS"

    local GAPS_BETWEEN_COL=2

    #Define variables
    local containerID_width=0
    local containerID_width_tmp=0
    local lineNum=0
    local pr_numOfCol=4
    local ps_tableWidth=0
    local repoNameTag_width=0
    local repoNameTag_width_tmp=0
    local status_width=0
    local status_width_tmp=0
    local sshPort_width=0
    local sshPort_width_tmp=0

    local containerID=${DOCKER__EMPTYSTRING}
    local repoNameTag=${DOCKER__EMPTYSTRING}
    local status=${DOCKER__EMPTYSTRING}
    local sshPort=${DOCKER__EMPTYSTRING}

    #Remove existing files
    if [[ -f ${docker__docker_containerList_tmp__fpath} ]]; then
        rm ${docker__docker_containerList_tmp__fpath}
    fi

    #Get number of containers
    local numOf_containers=`${DOCKER_PS_A_CMD} -a | head -n -1 | wc -l`

    #Initialization
    while true
    do
        #Increment LineNum
        lineNum=$((lineNum+1))

        if [[ ${lineNum} -eq 1 ]]; then
            echo -e "${CONTAINER_ID} ${REPO_TAG} ${STATUS} ${PORT}" >> ${docker__docker_containerList_tmp__fpath}
        else
            #Get data
            containerID=`${DOCKER_PS_A_CMD} --format "table {{.ID}}" | tail -n+${lineNum} | head -n1`
            repoNameTag=`${DOCKER_PS_A_CMD} --format "table {{.Image}}" | tail -n+${lineNum} | head -n1`
            status=`${DOCKER_PS_A_CMD} --format "table {{.Status}}" | tail -n+${lineNum} | head -n1 | sed 's/ /_/g'`
            sshPort=`${DOCKER_PS_A_CMD} --format "table {{.Ports}}" | tail -n+${lineNum} | head -n1 | cut -d":" -f2 | cut -d"-" -f1`

            #Check if any value is an Empty String
            if [[ -z ${containerID} ]]; then
                containerID=${DOCKER__DASH}
            fi
            if [[ -z ${repoNameTag} ]]; then
                repoNameTag=${DOCKER__DASH}
            fi
            if [[ -z ${status} ]]; then
                status=${DOCKER__DASH}
            fi
            if [[ -z ${sshPort} ]]; then
                sshPort=${DOCKER__DASH}
            fi
            #For each object value (e.g., repoNameTag, containerID, status, sshPort) calculate the longest length
            #Remark:
            #   This longest length will be used as reference for the column-widths
            containerID_width_tmp=${#containerID}
            if [[ ${containerID_width_tmp} -gt ${containerID_width} ]]; then
                containerID_width=${containerID_width_tmp}
            fi

            repoNameTag_width_tmp=${#repoNameTag}
            if [[ ${repoNameTag_width_tmp} -gt ${repoNameTag_width} ]]; then
                repoNameTag_width=${repoNameTag_width_tmp}
            fi

            status_width_tmp=${#status}
            if [[ ${status_width_tmp} -gt ${status_width} ]]; then
                status_width=${status_width_tmp}
            fi

            sshPort_width_tmp=${#sshPort}
            if [[ ${sshPort_width_tmp} -gt ${sshPort_width} ]]; then
                sshPort_width=${sshPort_width_tmp}
            fi

            #Write to file
            echo -e "${containerID} ${repoNameTag} ${status} ${sshPort}" >> ${docker__docker_containerList_tmp__fpath}
        fi

        if [[ ${lineNum} -gt ${numOf_containers} ]]; then
            break
        fi
    done

    #Add additional spaces
    #Remark:
    #   This would ensure that there are gaps between the columns
    containerID_width=$((containerID_width+GAPS_BETWEEN_COL))
    repoNameTag_width=$((repoNameTag_width+GAPS_BETWEEN_COL))
    status_width=$((status_width+GAPS_BETWEEN_COL))
    sshPort_width=$((sshPort_width+GAPS_BETWEEN_COL))

    #Define printf-format
    local printf_format="%-${containerID_width}s%-${repoNameTag_width}s%-${status_width}s%-${sshPort_width}s\n"

    #Get header
    local printf_header=`printf "${printf_format}" $(<${docker__docker_containerList_tmp__fpath}) | head -n1`
    #Print header
    echo -e "${DOCKER__FG_LIGHTGREY}${printf_header}${DOCKER__NOCOLOR}"

    #Print body
    printf "${printf_format}" $(<${docker__docker_containerList_tmp__fpath}) | tail -n+2
}



#---MAIN SUBROUTINES
main__sub() {
    docker__get_source_fullpath__sub

    docker__load_source_files__sub

    docker__get_docker_containerList__sub
}



#---EXECUTE MAIN
main__sub
