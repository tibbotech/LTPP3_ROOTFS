#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---INPUT ARGS
dockerfiles_dir__input=${1}
export_env_var_menu_cfg_tag__input=${2}
export_env_var_menu_cfg_fpath__input=${3}



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

    local docker__find_path_of_development_tools=""

    local docker__isfound=""

    #Set variables
    docker__phase="${DOCKER__PHASE_CHECK_CACHE}"
    docker__current_dir=$(pwd)
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

                    #Check if 'development_tools' is in the 'LTPP3_ROOTFS' folder
                    docker__isfound=$(docker__checkif_parentdir_isfound_in_path "${docker__current_dir}" \
                            "${docker__LTPP3_ROOTFS_development_tools__dir}" "${docker__LTPP3_ROOTFS__foldername}")
                    if [[ ${docker__isfound} == false ]]; then
                        docker__phase="${DOCKER__PHASE_FIND_PATH}"
                    else
                        docker_result=true

                        docker__phase="${DOCKER__PHASE_EXIT}"

                        echo -e "---:\e[30;38;5;215mSTATUS\e[0;0m: retrieve path from cache: \e[1;33mDONE\e[0;0m"
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
                        docker__isfound=$(docker__checkif_parentdir_isfound_in_path "${docker__current_dir}" \
                                "${docker__find_dir_result_arritem}"  "${docker__LTPP3_ROOTFS__foldername}")
                        if [[ ${docker__isfound} == true ]]; then
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

                        #set phase
                        docker__phase="${DOCKER__PHASE_EXIT}"

                        break
                    fi
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
docker__checkif_parentdir_isfound_in_path() {
    #Input args
    local parentdir__input=${1}
    local path__input=${2}
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
                #Check if 'pattern__input' is found in 'parentdir__input'
                isfound1=$(echo "${parentdir__input}" | \
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
                #Check if 'pattern__input' is found in 'path__input'
                isfound2=$(echo "${path__input}" | \
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
                isfound3=$(echo "${path__input}" | \
                        grep -w "${parentdir__input}.*")
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
docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

docker__load_constants__sub() {
    DOCKER__DIRLIST_MENUTITLE="${DOCKER__FG_DARKBLUE}Docker-file${DOCKER__NOCOLOR} selection"
    DOCKER__DIRLIST_LOCATION_INFO="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR}: ${docker__LTPP3_ROOTFS_docker_dockerfiles__dir}"
    DOCKER__DIRLIST_REMARKS="${DOCKER__FOURSPACES}NOTE: only files containing patterns ${DOCKER__FG_LIGHTGREY}${DOCKER__CONTAINER_ENV1}${DOCKER__NOCOLOR} "
    DOCKER__DIRLIST_REMARKS+="and ${DOCKER__FG_LIGHTGREY}${DOCKER__CONTAINER_ENV2}${DOCKER__NOCOLOR} are shown"
    DOCKER__DIRLIST_MENUOPTIONS="${DOCKER__FOURSPACES_F12_QUIT}"
    DOCKER__DIRLIST_MATCHPATTERNS="${DOCKER__ENUM_FUNC_F12}"
	DOCKER__DIRLIST_READDIALOG="Choose file: "
    DOCKER__DIRLIST_ERRMSG="${DOCKER__FOURSPACES}-:${DOCKER__FG_LIGHTRED}directory is Empty${DOCKER__NOCOLOR}:-"
}

docker__init_variables__sub() {
    docker__dockerFile_fpath=${DOCKER__EMPTYSTRING}
}

docker__select_dockerfile__sub() {
    #Show directory content
    show_pathContent_w_selection__func "${dockerfiles_dir__input}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${DOCKER__DIRLIST_MENUTITLE}" \
                        "${DOCKER__DIRLIST_REMARKS}" \
                        "${DOCKER__DIRLIST_LOCATION_INFO}" \
                        "${DOCKER__DIRLIST_MENUOPTIONS}" \
                        "${DOCKER__DIRLIST_MATCHPATTERNS}" \
                        "${DOCKER__DIRLIST_ERRMSG}" \
                        "${DOCKER__DIRLIST_READDIALOG}" \
                        "${DOCKER__CONTAINER_ENV1}" \
                        "${DOCKER__CONTAINER_ENV2}" \
                        "${DOCKER__TABLEROWS_10}" \
                        "${DOCKER__FALSE}" \
                        "${docker__show_pathContent_w_selection_func_out__fpath}" \
                        "${DOCKER__NUMOFLINES_2}" \
                        "${DOCKER__TRUE}"

    #Get the exitcode just in case a Ctrl-C was pressed in function 'DOCKER__FOURSPACES_F4_ABORT' (in script 'docker_global.sh')
    docker__exitCode=$?
    if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
        exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
    fi

    #Get result from file.
    docker__dockerFile_fpath=`get_output_from_file__func \
                        "${docker__show_pathContent_w_selection_func_out__fpath}" \
                        "${DOCKER__LINENUM_1}"`

    #if 'docker__dockerFile_fpath = F12', then exit this subroutine
    if [[ ${docker__dockerFile_fpath} == ${DOCKER__ENUM_FUNC_F12} ]]; then
        exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_1}"
    else
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_3}"
    fi

    #Write to configuration file
    echo "${export_env_var_menu_cfg_tag__input}${DOCKER__ONESPACE}${docker__dockerFile_fpath}" > ${export_env_var_menu_cfg_fpath__input}
}



#---MAIN SUBROUTINE
main__sub() {
    docker__get_source_fullpath__sub

    docker__load_source_files__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__select_dockerfile__sub
}



#---EXECUTE
main__sub
