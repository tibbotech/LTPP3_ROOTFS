#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---SUBROUTINES
docker__get_source_fullpath__sub() {
    #Define variables
    local docker__current_dir="${EMPTYSTRING}"
    local docker__home_dir="${EMPTYSTRING}"
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

    local docker__repo_of_LTPP3_ROOTFS="${EMPTYSTRING}"



    #Set variables
    docker__current_dir=$(pwd)
    docker__home_dir=~
    docker__tmp_dir=/tmp
    docker__development_tools__foldername="development_tools"
    docker__global__filename="docker_global.sh"
    docker__LTPP3_ROOTFS__foldername="LTPP3_ROOTFS"
    docker__repo_of_LTPP3_ROOTFS="git@github.com:tibbotech/${docker__LTPP3_ROOTFS__foldername}.git"

    docker__mainmenu_path_cache__filename="docker__mainmenu_path.cache"
    docker__mainmenu_path_cache__fpath="${docker__tmp_dir}/${docker__mainmenu_path_cache__filename}"

    #Check if file exists
    if [[ -f "${docker__mainmenu_path_cache__fpath}" ]]; then
        #Get the line of file
        docker__LTPP3_ROOTFS_development_tools__dir=$(awk 'NR==1' "${docker__mainmenu_path_cache__fpath}")

        #Print
        echo -e "---:\e[30;38;5;215mSTATUS\e[0;0m: retrieve path from cache: \e[1;33mDONE\e[0;0m"
    else
        #Print
        echo -e "---:\e[30;38;5;215mSTART\e[0;0m: find path of folder \e[30;38;5;246m'${docker__development_tools__foldername}\e[0;0m : \e[1;33mDONE\e[0;0m"

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
                #Update variable 'docker__find_path_of_development_tools'
                docker__find_path_of_development_tools="${docker__find_dir_result_arritem}/${docker__development_tools__foldername}"

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
                if [[ -d "${docker__find_path_of_development_tools}" ]]; then    #directory exists
                    #Update variable
                    #Remark:
                    #   'docker__LTPP3_ROOTFS_development_tools__dir' is a global variable.
                    #   This variable will be passed 'globally' to script 'docker_global.sh'.
                    docker__LTPP3_ROOTFS_development_tools__dir="${docker__find_path_of_development_tools}"

                    #Print
                    #Note: print the '100%' here
                    echo -e "------:PROGRESS: 100%"

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

        #Print
        echo -e "---:\e[30;38;5;215mCOMPLETED\e[0;0m: find path of folder \e[30;38;5;246m'${docker__development_tools__foldername}\e[0;0m : \e[1;33mDONE\e[0;0m"


        #Write to file
        echo "${docker__LTPP3_ROOTFS_development_tools__dir}" | tee "${docker__mainmenu_path_cache__fpath}" >/dev/null

        #Print
        echo -e "\r"
        echo -e "---:\e[30;38;5;215mSTATUS\e[0;0m: write path to temporary cache-file: \e[1;33mDONE\e[0;0m"
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
    docker__get_source_fullpath__sub

    docker__load_source_files__sub

    docker__enter_command__sub
}



#---EXECUTE
main__sub
