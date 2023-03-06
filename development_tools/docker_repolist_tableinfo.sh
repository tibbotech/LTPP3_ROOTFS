#!/bin/bash
#---ENVIRONMENT VARIABLES
docker__tmp__dir="/tmp"
docker__docker_repoList_tmp__filename="docker__docker_repoList.tmp"
docker__docker_repoList_tmp__fpath=${docker__tmp__dir}/${docker__docker_repoList_tmp__filename}
docker__docker_repoList_print__filename="docker__docker_repoList.prn"
docker__docker_repoList_print__fpath=${docker__tmp__dir}/${docker__docker_repoList_print__filename}



#---FUNCTIONS
function containerIsActive__func() {
	#Input args
	local repoName__input=${1}
	local tag__input=${2}

	#Define variables
	local repo_tag="${repoName__input}:${tag__input}"

	#Check if imageID is found in container's list
	local stdOutput=`docker ps -a | grep "${repo_tag}"`
	if [[ ! -z ${stdOutput} ]]; then
		echo "true"
	else
		echo "false"
	fi
}



#---SUBROUTINES
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
			containerIsActive=`containerIsActive__func "${repoName}" "${tag}"`

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
    get_docker_repoList__sub
}



#---EXECUTE MAIN
main__sub
