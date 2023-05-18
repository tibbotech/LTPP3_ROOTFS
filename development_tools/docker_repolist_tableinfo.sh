#!/bin/bash
#---FUNCTIONS
function containerIsActive__func() {
	#Input args
	local repoName__input=${1}
	local tag__input=${2}

	#Define variables
	local repo_tag="${repoName__input}:${tag__input}"

	#Check if imageID is found in container's list
	#Remarks:
	#	{{.Image}}: get the 'repository:tag'
	#	{{.Status}}: get the 'status'
	local result=$(docker ps -a --format "table {{.Image}} {{.Status}}" | grep "${repo_tag}")
	if [[ -n "${result}" ]]; then
		#Remarks:
		#	sed 's/ /_/g': replace SPACE with UNDERSCORE
		#	sed 's/(.*.)//g': replace ANYTHING that is BETWEEN BRACKETS (including the brackets) with EMPTY STRING
		#	sed 's/__/_/g'): replace DOUBLE UNDERSCORE with UNDERSCORE
		local isExited=$(grep -o "${PATTERN_EXITED}.*" <<< "${result}" | sed 's/ /_/g' | sed 's/(.*.)//g' | sed 's/__/_/g')
		if [[ -n "${isExited}" ]]; then
			echo "${isExited}"
		else
			echo "true"
		fi
	else
		echo "false"
	fi
}



#---SUBROUTINES
docker__get_source_fullpath__sub() {
    #Define constants
    local PHASE_CHECK_CACHE=1
    local PHASE_FIND_PATH=10
    local PHASE_EXIT=100

    #Define variables
    local phase=""

    local current_dir=""
    local parent_dir=""
    local search_dir=""
    local tmp_dir=""

    local development_tools_foldername=""
    local lTPP3_ROOTFS_foldername=""
    local global_filename=""
    local parentDir_of_LTPP3_ROOTFS_dir=""

    local mainmenu_path_cache_filename=""
    local mainmenu_path_cache_fpath=""

    local find_dir_result_arr=()
    local find_dir_result_arritem=""

    local path_of_development_tools_found=""
    local parentpath_of_development_tools=""

    local isfound=""

    local retry_ctr=0

    #Set variables
    phase="${PHASE_CHECK_CACHE}"
    current_dir=$(dirname $(readlink -f $0))
    parent_dir="$(dirname "${current_dir}")"
    tmp_dir=/tmp
    development_tools_foldername="development_tools"
    global_filename="docker_global.sh"
    lTPP3_ROOTFS_foldername="LTPP3_ROOTFS"

    mainmenu_path_cache_filename="docker__mainmenu_path.cache"
    mainmenu_path_cache_fpath="${tmp_dir}/${mainmenu_path_cache_filename}"

    result=false

    #Start loop
    while true
    do
        case "${phase}" in
            "${PHASE_CHECK_CACHE}")
                if [[ -f "${mainmenu_path_cache_fpath}" ]]; then
                    #Get the directory stored in cache-file
                    docker__LTPP3_ROOTFS_development_tools__dir=$(awk 'NR==1' "${mainmenu_path_cache_fpath}")

                    #Move one directory up
                    parentpath_of_development_tools=$(dirname "${docker__LTPP3_ROOTFS_development_tools__dir}")

                    #Check if 'development_tools' is in the 'LTPP3_ROOTFS' folder
                    isfound=$(docker__checkif_paths_are_related "${current_dir}" \
                            "${parentpath_of_development_tools}" "${lTPP3_ROOTFS_foldername}")
                    if [[ ${isfound} == false ]]; then
                        phase="${PHASE_FIND_PATH}"
                    else
                        result=true

                        phase="${PHASE_EXIT}"
                    fi
                else
                    phase="${PHASE_FIND_PATH}"
                fi
                ;;
            "${PHASE_FIND_PATH}")   
                #Print
                echo -e "---:\e[30;38;5;215mSTART\e[0;0m: find path of folder \e[30;38;5;246m'${development_tools_foldername}\e[0;0m"

                #Initialize variables
                docker__LTPP3_ROOTFS_development_tools__dir=""
                search_dir="${current_dir}"   #start with search in the current dir

                #Start loop
                while true
                do
                    #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
                    #... and read to array 'find_result_arr'
                    readarray -t find_dir_result_arr < <(find  "${search_dir}" -type d -iname "${lTPP3_ROOTFS_foldername}" 2> /dev/null)

                    #Iterate thru each array-item
                    for find_dir_result_arritem in "${find_dir_result_arr[@]}"
                    do
                        echo -e "---:\e[30;38;5;215mCHECKING\e[0;0m: ${find_dir_result_arritem}"

                        #Find path
                        isfound=$(docker__checkif_paths_are_related "${current_dir}" \
                                "${find_dir_result_arritem}"  "${lTPP3_ROOTFS_foldername}")
                        if [[ ${isfound} == true ]]; then
                            #Update variable 'path_of_development_tools_found'
                            path_of_development_tools_found="${find_dir_result_arritem}/${development_tools_foldername}"

                            #Check if 'directory' exist
                            if [[ -d "${path_of_development_tools_found}" ]]; then    #directory exists
                                #Update variable
                                #Remark:
                                #   'docker__LTPP3_ROOTFS_development_tools__dir' is a global variable.
                                #   This variable will be passed 'globally' to script 'docker_global.sh'.
                                docker__LTPP3_ROOTFS_development_tools__dir="${path_of_development_tools_found}"

                                break
                            fi
                        fi
                    done

                    #Check if 'docker__LTPP3_ROOTFS_development_tools__dir' contains any data
                    if [[ -z "${docker__LTPP3_ROOTFS_development_tools__dir}" ]]; then  #contains no data
                        case "${retry_ctr}" in
                            0)
                                search_dir="${parent_dir}"    #next search in the 'parent' directory
                                ;;
                            1)
                                search_dir="/" #finally search in the 'main' directory (the search may take longer)
                                ;;
                            *)
                                echo -e "\r"
                                echo -e "***\e[1;31mERROR\e[0;0m: folder \e[30;38;5;246m${development_tools_foldername}\e[0;0m: \e[30;38;5;131mNot Found\e[0;0m"
                                echo -e "\r"

                                #Update variable
                                result=false

                                #set phase
                                phase="${PHASE_EXIT}"

                                break
                                ;;
                        esac

                        ((retry_ctr++))
                    else    #contains data
                        #Print
                        echo -e "---:\e[30;38;5;215mCOMPLETED\e[0;0m: find path of folder \e[30;38;5;246m'${development_tools_foldername}\e[0;0m"


                        #Write to file
                        echo "${docker__LTPP3_ROOTFS_development_tools__dir}" | tee "${mainmenu_path_cache_fpath}" >/dev/null

                        #Print
                        echo -e "---:\e[30;38;5;215mSTATUS\e[0;0m: write path to temporary cache-file: \e[1;33mDONE\e[0;0m"

                        #Update variable
                        result=true

                        #set phase
                        phase="${PHASE_EXIT}"

                        break
                    fi
                done
                ;;    
            "${PHASE_EXIT}")
                break
                ;;
        esac
    done

    #Exit if 'result = false'
    if [[ ${result} == false ]]; then
        exit 99
    fi

    #Retrieve directories
    #Remark:
    #   'docker__LTPP3_ROOTFS__dir' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/
    parentDir_of_LTPP3_ROOTFS_dir=${docker__LTPP3_ROOTFS__dir%/*}    #move two directories up. This directory is the one-level higher than LTPP3_ROOTFS/

    #Get full-path
    #Remark:
    #   'docker__global__fpath' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__global__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${global_filename}
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
	docker__tmp__dir="/tmp"
	docker__docker_repoList_tmp__filename="docker__docker_repoList.tmp"
	docker__docker_repoList_tmp__fpath=${docker__tmp__dir}/${docker__docker_repoList_tmp__filename}
	docker__docker_repoList_print__filename="docker__docker_repoList.prn"
	docker__docker_repoList_print__fpath=${docker__tmp__dir}/${docker__docker_repoList_print__filename}
}

docker__load_constants__sub() {
	PATTERN_EXITED="Exited"
}

get_docker_repoList__sub() {
    #Define constants
    local IMAGE_ID="IMAGE-ID"
    local REPO_NAME="REPOSITORY"
    local TAG="TAG"
    local CREATED="CREATED"
    local SIZE="SIZE"
	local CONTAINER_ACTIVE="CONTAINER-ACTIVE"
    local GAPS_BETWEEN_COL=2

	#Define variables
	local containerIsActive=false
	local createdFor=${DOCKER__EMPTYSTRING}
	local imageID=${DOCKER__EMPTYSTRING}
	local imageSize=${DOCKER__EMPTYSTRING}
	local line_tmp=${DOCKER__EMPTYSTRING}
	local line_final=${DOCKER__EMPTYSTRING}
	local repoName=${DOCKER__EMPTYSTRING}
	local tag=${DOCKER__EMPTYSTRING}

	local containerIsActive_width=0
	local containerIsActive_width_tmp=0
	local createdFor_width=0
	local createdFor_width_tmp=0
	local imageID_width=0
	local imageID_width_tmp=0
	local imageSize_width=0
	local imageSize_width_tmp=0
    local lineNum=0
	local numOf_images=0
	local repoName_width=0
	local repoName_width_tmp=0
	local tag_width=0
	local tag_width_tmp=0

	local printf_format=${DOCKER__EMPTYSTRING}

    #Remove existing files
    if [[ -f ${docker__docker_repoList_tmp__fpath} ]]; then
        rm ${docker__docker_repoList_tmp__fpath}
    fi
    if [[ -f ${docker__docker_repoList_print__fpath} ]]; then
        rm ${docker__docker_repoList_print__fpath}
    fi

	#Get current Repository's List.
	#Remark:
	#	Also replace ONLY multiple-spaces to pipe.
	#	It is important to do it here.
	docker image ls | sed 's/   */|/g' > ${docker__docker_repoList_tmp__fpath}

    #Get number of containers
	numOf_images=`docker images | head -n -1 | wc -l`

	#Go thru file content
	while read line
	do
        #Increment LineNum
        lineNum=$((lineNum+1))

        if [[ ${lineNum} -eq 1 ]]; then
			#Write header to file
			echo -e "${IMAGE_ID} ${REPO_NAME} ${TAG} ${CREATED} ${SIZE} ${CONTAINER_ACTIVE}" > ${docker__docker_repoList_print__fpath}
        else
			#Replace exactly one-space only.
			line_tmp=`echo ${line} | sed 's/  */_/g'`
			#Replace pipe with one-space.
			line_final=`echo ${line_tmp} | sed 's/|/ /g'`

			#Get data
			imageID=`echo ${line_final} | awk '{print $3}'`
			repoName=`echo ${line_final} | awk '{print $1}'`
			tag=`echo ${line_final} | awk '{print $2}'`
			createdFor=`echo ${line_final} | awk '{print $4}'`
			imageSize=`echo ${line_final} | awk '{print $5}'`

			#Check if a container is active for given 'imageID'
			containerIsActive=$(containerIsActive__func "${repoName}" "${tag}")
			if [[ -n $(grep -o "${PATTERN_EXITED}.*" <<< "${containerIsActive}") ]]; then
				containerIsActive="${DOCKER__FG_YELLOW}${containerIsActive}${DOCKER__NOCOLOR}"
			fi

			#For each object value (e.g., imageID, repoName, tag, createdFor, imageSize, containerIsActive) calculate the longest length
			#Remark:
			#   This longest length will be used as reference for the column-widths
			imageID_width_tmp=${#imageID}
			if [[ ${imageID_width_tmp} -gt ${imageID_width} ]]; then
				imageID_width=${imageID_width_tmp}
			fi

			repoName_width_tmp=${#repoName}
			if [[ ${repoName_width_tmp} -gt ${repoName_width} ]]; then
				repoName_width=${repoName_width_tmp}
			fi

			tag_width_tmp=${#tag}
			if [[ ${tag_width_tmp} -gt ${tag_width} ]]; then
				tag_width=${tag_width_tmp}
			fi

			createdFor_width_tmp=${#createdFor}
			if [[ ${createdFor_width_tmp} -gt ${createdFor_width} ]]; then
				createdFor_width=${createdFor_width_tmp}
			fi

			imageSize_width_tmp=${#imageSize}
			if [[ ${imageSize_width_tmp} -gt ${imageSize_width} ]]; then
				imageSize_width=${imageSize_width_tmp}
			fi

			containerIsActive_width_tmp=${#containerIsActive}
			if [[ ${containerIsActive_width_tmp} -gt ${containerIsActive_width} ]]; then
				containerIsActive_width=${containerIsActive_width_tmp}
			fi

			#Write data to file
			echo -e "${imageID} ${repoName} ${tag} ${createdFor} ${imageSize} ${containerIsActive}" >> ${docker__docker_repoList_print__fpath}
		fi

        if [[ ${lineNum} -gt ${numOf_images} ]]; then
            break
        fi
	done < ${docker__docker_repoList_tmp__fpath}

    #Add additional spaces
    #Remark:
    #   This would ensure that there are gaps between the columns
    imageID_width=$((imageID_width+GAPS_BETWEEN_COL))
    repoName_width=$((repoName_width+GAPS_BETWEEN_COL))
    tag_width=$((tag_width+GAPS_BETWEEN_COL))
    createdFor_width=$((createdFor_width+GAPS_BETWEEN_COL))
	imageSize_width=$((imageSize_width+GAPS_BETWEEN_COL))
	containerIsActive_width=$((containerIsActive_width+GAPS_BETWEEN_COL))

	local printf_format="%-${imageID_width}s%-${repoName_width}s%-${tag_width}s%-${createdFor_width}s%-${imageSize_width}s%-${containerIsActive_width}s\n"

    # #Get header
    local printf_header=`printf "${printf_format}" $(<${docker__docker_repoList_print__fpath}) | head -n1`
    #Print header
    echo -e "${DOCKER__FG_LIGHTGREY}${printf_header}${DOCKER__NOCOLOR}"

    #Print body
    printf "${printf_format}" $(<${docker__docker_repoList_print__fpath}) | tail -n+2
}



#---MAIN SUBROUTINES
main__sub() {
	docker__get_source_fullpath__sub

	docker__load_global_fpath_paths__sub

	docker__environmental_variables__sub

	docker__load_constants__sub
	
    get_docker_repoList__sub
}



#---EXECUTE MAIN
main__sub
