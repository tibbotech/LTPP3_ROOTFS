#!/bin/bash
#---COLOR CONSTANTS
DOCKER__NOCOLOR=$'\e[0;0m'
DOCKER__FG_BRIGHTPRUPLE=$'\e[30;38;5;141m'
DOCKER__FG_GREEN85=$'\e[30;38;5;85m'
DOCKER__FG_LIGHTGREY=$'\e[30;38;5;246m'
DOCKER__FG_LIGHTRED=$'\e[1;31m'
DOCKER__FG_ORANGE=$'\e[30;38;5;215m'
DOCKER__FG_PURPLE=$'\e[30;38;5;93m'
DOCKER__FG_VERYLIGHTORANGE=$'\e[30;38;5;223m'
DOCKER__FG_YELLOW=$'\e[1;33m'
DOCKER__BG_ORANGE=$'\e[30;48;5;215m'



#---CHARACTER CHONSTANTS
DOCKER__EMPTYSTRING=""



#---VARIABLES



#---ENVIRONMENT VARIABLES
docker__tmp_dir="/tmp"
docker__docker_containerList_tmp__filename="docker__docker_containerList.tmp"
docker__docker_containerList_tmp__fpath=${docker__tmp_dir}/${docker__docker_containerList_tmp__filename}



#---SUBROUTINES
get_docker_containerList__sub() {
    #Define constants
    local REPO_TAG="REPO:TAG"
    local CONTAINER_ID="CONTAINER-ID"
    local STATUS="STATUS"
    local PORT="SSH-PORT"
    local GAPS_BETWEEN_COL=4

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
    local numOf_containers=`docker ps -a | head -n -1 | wc -l`

    #Initialization
    while true
    do
        #Increment LineNum
        lineNum=$((lineNum+1))

        if [[ ${lineNum} -eq 1 ]]; then
            echo -e "${CONTAINER_ID} ${REPO_TAG} ${STATUS} ${PORT}" >> ${docker__docker_containerList_tmp__fpath}
        else
            #Get data
            containerID=`docker ps --format "table {{.ID}}" | tail -n+${lineNum} | head -n1`
            repoNameTag=`docker ps --format "table {{.Image}}" | tail -n+${lineNum} | head -n1`
            status=`docker ps --format "table {{.Status}}" | tail -n+${lineNum} | head -n1 | sed 's/ /_/g'`
            sshPort=`docker ps --format "table {{.Ports}}" | tail -n+${lineNum} | head -n1 | cut -d":" -f2 | cut -d"-" -f1`

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
    get_docker_containerList__sub
}



#---EXECUTE MAIN
main__sub
