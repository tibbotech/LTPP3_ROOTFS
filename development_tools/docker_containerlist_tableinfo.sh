#!/bin/bash
#---SUBROUTINES
docker__get_source_fullpath__sub() {
    #Define constants
    local DOCKER__PHASE_CHECK_CACHE=1
    local DOCKER__PHASE_FIND_PATH=10
    local DOCKER__PHASE_EXIT=100

    #Define variables
    local docker__phase=""

    local docker__current_dir=
    local docker__tmp_dir=""

    local docker__development_tools__foldername=""
    local docker__LTPP3_ROOTFS__foldername=""
    local docker__global__filename=""
    local docker__parentDir_of_LTPP3_ROOTFS__dir=""

    local docker__mainmenu_path_cache__filename=""
    local docker__mainmenu_path_cache__fpath=""

    local docker__find_dir_result_arr=()
    local docker__find_dir_result_arritem=""
    local docker__find_dir_result_arrlen=0
    local docker__find_dir_result_arrlinectr=0
    local docker__find_dir_result_arrprogressperc=0

    local docker__path_of_development_tools_found=""
    local docker__parentpath_of_development_tools=""

    local docker__isfound=""

    #Set variables
    docker__phase="${DOCKER__PHASE_CHECK_CACHE}"
    docker__current_dir=$(dirname $(readlink -f $0))
    docker__tmp_dir=/tmp
    docker__development_tools__foldername="development_tools"
    docker__global__filename="docker_global.sh"
    docker__LTPP3_ROOTFS__foldername="LTPP3_ROOTFS"

    docker__mainmenu_path_cache__filename="docker__mainmenu_path.cache"
    docker__mainmenu_path_cache__fpath="${docker__tmp_dir}/${docker__mainmenu_path_cache__filename}"

    docker_result=false

    #Start loop
    while true
    do
        case "${docker__phase}" in
            "${DOCKER__PHASE_CHECK_CACHE}")
                if [[ -f "${docker__mainmenu_path_cache__fpath}" ]]; then
                    #Get the directory stored in cache-file
                    docker__LTPP3_ROOTFS_development_tools__dir=$(awk 'NR==1' "${docker__mainmenu_path_cache__fpath}")

                    #Move one directory up
                    docker__parentpath_of_development_tools=$(dirname "${docker__LTPP3_ROOTFS_development_tools__dir}")

                    #Check if 'development_tools' is in the 'LTPP3_ROOTFS' folder
                    docker__isfound=$(docker__checkif_paths_are_related "${docker__current_dir}" \
                            "${docker__parentpath_of_development_tools}" "${docker__LTPP3_ROOTFS__foldername}")
                    if [[ ${docker__isfound} == false ]]; then
                        docker__phase="${DOCKER__PHASE_FIND_PATH}"
                    else
                        docker_result=true

                        docker__phase="${DOCKER__PHASE_EXIT}"
                    fi
                else
                    docker__phase="${DOCKER__PHASE_FIND_PATH}"
                fi
                ;;
            "${DOCKER__PHASE_FIND_PATH}")   
                #Print
                echo -e "---:\e[30;38;5;215mSTART\e[0;0m: find path of folder \e[30;38;5;246m'${docker__development_tools__foldername}\e[0;0m : \e[1;33mDONE\e[0;0m"

                #Reset variable
                docker__LTPP3_ROOTFS_development_tools__dir=""

                #Start loop
                while true
                do
                    #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
                    #... and read to array 'find_result_arr'
                    readarray -t docker__find_dir_result_arr < <(find  / -type d -iname "${docker__LTPP3_ROOTFS__foldername}" 2> /dev/null)

                    #Get array-length
                    docker__find_dir_result_arrlen=${#docker__find_dir_result_arr[@]}

                    #Iterate thru each array-item
                    for docker__find_dir_result_arritem in "${docker__find_dir_result_arr[@]}"
                    do
                        docker__isfound=$(docker__checkif_paths_are_related "${docker__current_dir}" \
                                "${docker__find_dir_result_arritem}"  "${docker__LTPP3_ROOTFS__foldername}")
                        if [[ ${docker__isfound} == true ]]; then
                            #Update variable 'docker__path_of_development_tools_found'
                            docker__path_of_development_tools_found="${docker__find_dir_result_arritem}/${docker__development_tools__foldername}"

                            # #Increment counter
                            docker__find_dir_result_arrlinectr=$((docker__find_dir_result_arrlinectr+1))

                            #Calculate the progress percentage value
                            docker__find_dir_result_arrprogressperc=$(( docker__find_dir_result_arrlinectr*100/docker__find_dir_result_arrlen ))

                            #Moveup and clean
                            if [[ ${docker__find_dir_result_arrlinectr} -gt 1 ]]; then
                                tput cuu1
                                tput el
                            fi

                            #Print
                            #Note: do not print the '100%'
                            if [[ ${docker__find_dir_result_arrlinectr} -lt ${docker__find_dir_result_arrlen} ]]; then
                                echo -e "------:PROGRESS: ${docker__find_dir_result_arrprogressperc}%"
                            fi

                            #Check if 'directory' exist
                            if [[ -d "${docker__path_of_development_tools_found}" ]]; then    #directory exists
                                #Update variable
                                #Remark:
                                #   'docker__LTPP3_ROOTFS_development_tools__dir' is a global variable.
                                #   This variable will be passed 'globally' to script 'docker_global.sh'.
                                docker__LTPP3_ROOTFS_development_tools__dir="${docker__path_of_development_tools_found}"

                                #Print
                                #Note: print the '100%' here
                                echo -e "------:PROGRESS: 100%"

                                break
                            fi
                        fi
                    done

                    #Check if 'docker__LTPP3_ROOTFS_development_tools__dir' contains any data
                    if [[ -z "${docker__LTPP3_ROOTFS_development_tools__dir}" ]]; then  #contains no data
                        echo -e "\r"
                        echo -e "***\e[1;31mERROR\e[0;0m: folder \e[30;38;5;246m${docker__development_tools__foldername}\e[0;0m: \e[30;38;5;131mNot Found\e[0;0m"
                        echo -e "\r"

                         #Update variable
                        docker_result=false
                    else    #contains data
                        #Print
                        echo -e "---:\e[30;38;5;215mCOMPLETED\e[0;0m: find path of folder \e[30;38;5;246m'${docker__development_tools__foldername}\e[0;0m : \e[1;33mDONE\e[0;0m"


                        #Write to file
                        echo "${docker__LTPP3_ROOTFS_development_tools__dir}" | tee "${docker__mainmenu_path_cache__fpath}" >/dev/null

                        #Print
                        echo -e "---:\e[30;38;5;215mSTATUS\e[0;0m: write path to temporary cache-file: \e[1;33mDONE\e[0;0m"

                        #Update variable
                        docker_result=true
                    fi

                    #set phase
                    docker__phase="${DOCKER__PHASE_EXIT}"

                    #Exit loop
                    break
                done
                ;;    
            "${DOCKER__PHASE_EXIT}")
                break
                ;;
        esac
    done

    #Exit if 'docker_result = false'
    if [[ ${docker_result} == false ]]; then
        exit 99
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
docker__checkif_paths_are_related() {
    #Input args
    local scriptdir__input=${1}
    local finddir__input=${2}
    local pattern__input=${3}

    #Define constants
    local PHASE_PATTERN_CHECK1=1
    local PHASE_PATTERN_CHECK2=10
    local PHASE_PATH_COMPARISON=20
    local PHASE_EXIT=100

    #Define variables
    local phase="${PHASE_PATTERN_CHECK1}"
    local isfound1=""
    local isfound2=""
    local isfound3=""
    local ret=false

    while true
    do
        case "${phase}" in
            "${PHASE_PATTERN_CHECK1}")
                #Check if 'pattern__input' is found in 'scriptdir__input'
                isfound1=$(echo "${scriptdir__input}" | \
                        grep -o "${pattern__input}.*" | \
                        cut -d"/" -f1 | grep -w "^${pattern__input}$")
                if [[ -z "${isfound1}" ]]; then
                    ret=false

                    phase="${PHASE_EXIT}"
                else
                    phase="${PHASE_PATTERN_CHECK2}"
                fi                
                ;;
            "${PHASE_PATTERN_CHECK2}")
                #Check if 'pattern__input' is found in 'finddir__input'
                isfound2=$(echo "${finddir__input}" | \
                        grep -o "${pattern__input}.*" | \
                        cut -d"/" -f1 | grep -w "^${pattern__input}$")
                if [[ -z "${isfound2}" ]]; then
                    ret=false

                    phase="${PHASE_EXIT}"
                else
                    phase="${PHASE_PATH_COMPARISON}"
                fi                
                ;;
            "${PHASE_PATH_COMPARISON}")
                #Check if 'development_tools' is under the folder 'LTPP3_ROOTFS'
                isfound3=$(echo "${scriptdir__input}" | \
                        grep -w "${finddir__input}.*")
                if [[ -z "${isfound3}" ]]; then
                    ret=false
                else
                    ret=true
                fi

                phase="${PHASE_EXIT}"
                ;;
            "${PHASE_EXIT}")
                break
                ;;
        esac
    done

    #Output
    echo "${ret}"

    return 0
}
docker__load_global_fpath_paths__sub() {
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

    docker__load_global_fpath_paths__sub

    docker__environmental_variables__sub

    docker__get_docker_containerList__sub
}



#---EXECUTE MAIN
main__sub
