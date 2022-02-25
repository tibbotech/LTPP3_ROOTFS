#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---VARIABLES
cachedInput_Arr=()
cachedInput_ArrLen=0
cachedInput_ArrIndex=0
cachedInput_ArrIndex_max=0



#---SUBROUTINES
docker__environmental_variables__sub() {
	# docker__current_dir=`pwd`
	docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})	#/repo/LTPP3_ROOTFS/development_tools
	docker__parent_dir=${docker__current_dir%/*}    #gets one directory up (/repo/LTPP3_ROOTFS)
    if [[ -z ${docker__parent_dir} ]]; then
        docker__parent_dir="${DOCKER__SLASH}"
    fi
	docker__current_folder=`basename ${docker__current_dir}`

    docker__development_tools_folder="development_tools"
    if [[ ${docker__current_folder} != ${docker__development_tools_folder} ]]; then
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}/${docker__development_tools_folder}
    else
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}
    fi

    docker__global_functions_filename="docker_global_functions.sh"
    docker__global_functions_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__global_functions_filename}
}

docker__load_source_files__sub() {
    source ${docker__global_functions_fpath}
}

docker__enter_command__sub() {
    #Define local constants
    local READ_INPUT_MSG="${DOCKER__FG_LIGHTBLUE}Command${DOCKER__NOCOLOR} (${DOCKER__CTRL_C_COLON_QUIT}): "

    #Define local variables
    local cmd=${DOCKER__EMPTYSTRING}
    local cmd_cached=${DOCKER__EMPTYSTRING}
    local cmd_len=0
    local echoMsg=${DOCKER__EMPTYSTRING}
    local echoMsg_wo_color=${DOCKER__EMPTYSTRING}
    local echoMsg_wo_color_len=${DOCKER__EMPTYSTRING}
    local arrow_direction=${DOCKER__EMPTYSTRING}

    #Start read-input
    #Arrow-up/down is used to cycle through the 'cached' input
    while true 
    do
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        read -e -p "${READ_INPUT_MSG}" cmd

        if [[ ! -z ${cmd} ]]; then
            ${cmd}
        else
            tput cuu1
            tput el
            tput cuu1
            tput el
        fi
    done

    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
}



#---MAIN SUBROUTINE
main__sub() {
    docker__environmental_variables__sub

    docker__load_source_files__sub

    docker__enter_command__sub
}



#---EXECUTE
main__sub
