#!/bin/bash
#---SUBROUTINES
docker__get_source_fullpath__sub() {
    #Define variables
    local docker__tmp_dir="${EMPTYSTRING}"

    local docker__development_tools__foldername="${EMPTYSTRING}"
    local docker__LTPP3_ROOTFS__foldername="${EMPTYSTRING}"
    local docker__global__filename="${EMPTYSTRING}"
    local docker__parentDir_of_LTPP3_ROOTFS__dir="${EMPTYSTRING}"

    local docker__mainmenu_path_cache__filename="${EMPTYSTRING}"
    local docker__mainmenu_path_cache__fpath="${EMPTYSTRING}"

    local docker__find_dir_result_arr=()
    local docker__find_dir_result_arritem="${EMPTYSTRING}"
    local docker__find_dir_result_arrlen=0
    local docker__find_dir_result_arrlinectr=0
    local docker__find_dir_result_arrprogressperc=0

    local docker__find_path_of_development_tools="${EMPTYSTRING}"

    #Set variables
    docker__tmp_dir=/tmp
    docker__development_tools__foldername="development_tools"
    docker__global__filename="docker_global.sh"
    docker__LTPP3_ROOTFS__foldername="LTPP3_ROOTFS"

    docker__mainmenu_path_cache__filename="docker__mainmenu_path.cache"
    docker__mainmenu_path_cache__fpath="${docker__tmp_dir}/${docker__mainmenu_path_cache__filename}"

    #Check if file exists
    if [[ -f "${docker__mainmenu_path_cache__fpath}" ]]; then
        #Get the line of file
        docker__LTPP3_ROOTFS_development_tools__dir=$(awk 'NR==1' "${docker__mainmenu_path_cache__fpath}")
    else
        #Start loop
        while true
        do
            #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
            #... and read to array 'find_result_arr'
            readarray -t docker__find_dir_result_arr < <(find  / -type d -iname "${docker__LTPP3_ROOTFS__foldername}" 2> /dev/null)

            #Iterate thru each array-item
            for docker__find_dir_result_arritem in "${docker__find_dir_result_arr[@]}"
            do
                #Update variable 'docker__find_path_of_development_tools'
                docker__find_path_of_development_tools="${docker__find_dir_result_arritem}/${docker__development_tools__foldername}"

                #Check if 'directory' exist
                if [[ -d "${docker__find_path_of_development_tools}" ]]; then    #directory exists
                    #Update variable
                    #Remark:
                    #   'docker__LTPP3_ROOTFS_development_tools__dir' is a global variable.
                    #   This variable will be passed 'globally' to script 'docker_global.sh'.
                    docker__LTPP3_ROOTFS_development_tools__dir="${docker__find_path_of_development_tools}"

                    break
                fi
            done

            #Check if 'docker__LTPP3_ROOTFS_development_tools__dir' contains any data
            if [[ -z "${docker__LTPP3_ROOTFS_development_tools__dir}" ]]; then  #contains no data
                echo -e "\r"

                echo -e "***\e[1;31mERROR\e[0;0m: folder \e[30;38;5;246m${docker__development_tools__foldername}\e[0;0m: \e[30;38;5;131mNot Found\e[0;0m"

                echo -e "\r"

                exit 99
            else    #contains data
                break
            fi
        done

        #Write to file
        echo "${docker__LTPP3_ROOTFS_development_tools__dir}" | tee "${docker__mainmenu_path_cache__fpath}" >/dev/null
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

docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

docker__environmental_variables__sub() {
    docker__tmp_dir="/tmp"
    docker__docker_containerList_tmp__filename="docker__docker_containerList.tmp"
    docker__docker_containerList_tmp__fpath=${docker__tmp_dir}/${docker__docker_containerList_tmp__filename}
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

    docker__environmental_variables__sub

    docker__get_docker_containerList__sub
}



#---EXECUTE MAIN
main__sub
