#!/bin/bash
#---INPUT ARGS
flag_docker_container_build_ispboootbin_sh_executed_this_script__argv1=${1}  #{true|false}

if [[ "${flag_docker_container_build_ispboootbin_sh_executed_this_script__argv1}" == false ]] || \
        [[ -z "${flag_docker_container_build_ispboootbin_sh_executed_this_script__argv1}" ]]; then
    flag_docker_container_build_ispboootbin_sh_executed_this_script__argv1=false
fi

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

docker__build_ispboootbin__sub() {
    #Generate file-content
    local filecontent="echo -e \"\\r\"\n"
    filecontent+="echo -e \"\\r\"\n"
    filecontent+="echo -e \"---:${DOCKER__UPDATE}: navigate to ${DOCKER__FG_LIGHTGREY}${docker__SP7021__dir}${DOCKER__NOCOLOR}\"\n"
    filecontent+="cd ${docker__SP7021__dir}\n"
    filecontent+="\n"
    filecontent+="echo -e \"---:${DOCKER__UPDATE}: add to ${DOCKER__FG_LIGHTGREY}${docker__SP7021_boot_uboot_tools__dir}${DOCKER__NOCOLOR} to ${DOCKER__FG_LIGHTGREY}PATH${DOCKER__NOCOLOR}\"\n"
    filecontent+="export PATH=\$PATH:${docker__SP7021_boot_uboot_tools__dir}\n"
    filecontent+="\n"
    filecontent+="checkif_matchisFound=\$(cat ${docker__home_dotbashrc__fpath} | grep \"${docker__SP7021_boot_uboot_tools__dir}\")\n"
    filecontent+="if [[ -z \"\${checkif_matchisFound}\" ]]; then\n"
    filecontent+="    echo -e \"export PATH=\$PATH:${docker__SP7021_boot_uboot_tools__dir}\" | tee -a ${docker__home_dotbashrc__fpath}\n"
    filecontent+="fi\n"
    filecontent+="\n"
    filecontent+="echo -e \"---:${DOCKER__UPDATE}: excecute ${DOCKER__FG_LIGHTGREY}source ${docker__home_dotbashrc__fpath}${DOCKER__NOCOLOR}\"\n"
    filecontent+="source ${docker__home_dotbashrc__fpath}\n"
    filecontent+="\n"
    filecontent+="echo -e \"---:${DOCKER__UPDATE}: excecute ${DOCKER__FG_LIGHTGREY}env \"PATH=\$PATH\" make all${DOCKER__NOCOLOR}\"\n"
    filecontent+="env \"PATH=\$PATH\" make all"

    #Remove file
    if [[ -f "${docker_build_ispboootbin_tmp_sh_fpath}" ]]; then
        rm "${docker_build_ispboootbin_tmp_sh_fpath}"
    fi

    #Write to file
    echo -e "${filecontent}" | tee "${docker_build_ispboootbin_tmp_sh_fpath}" >/dev/null

    #Make file executable
    chmod +x "${docker_build_ispboootbin_tmp_sh_fpath}"
}

docker__execute_scripts__sub() {
    eval "${docker_build_ispboootbin_tmp_sh_fpath}"
}


docker__ispboootbin_version__sub() {
    #***NOTE: if 'flag_docker_container_build_ispboootbin_sh_executed_this_script__argv1 = false', then it mean that this script
    #       is initiated from a 'docker_container_build_ispboootbin_sh'. 
    #***NOTE 2: it is important to use this flag, because otherwise if initiated from a 'docker_container_build_ispboootbin_sh'
    #       this part should NEVER be executed. The 'CONTAINER_ENV4' value would NOT be correct!!!
    if [[ "${flag_docker_container_build_ispboootbin_sh_executed_this_script__argv1}" == false ]]; then
        #Retrieve CONTAINER_ENV4 value
        echo "${CONTAINER_ENV4}" > "${docker__SP7021_linux_rootfs_initramfs_disk_etc_tibbo_version_ispboootbin_version__fpath}"
        echo "---:TIBBO:-:UPDATE: wrote ISPBOOOT.BIN version ${CONTAINER_ENV4} to file ${docker__SP7021_linux_rootfs_initramfs_disk_etc_tibbo_version_ispboootbin_version__fpath}"

        chown root:root ${docker__SP7021_linux_rootfs_initramfs_disk_etc_tibbo_version_ispboootbin_version__fpath}
        echo "---:TIBBO:-:UPDATE: chown root:root ${docker__SP7021_linux_rootfs_initramfs_disk_etc_tibbo_version_ispboootbin_version__fpath}"

        chmod 644 ${docker__SP7021_linux_rootfs_initramfs_disk_etc_tibbo_version_ispboootbin_version__fpath}
        echo "---:TIBBO:-:UPDATE: chmod 644 ${docker__SP7021_linux_rootfs_initramfs_disk_etc_tibbo_version_ispboootbin_version__fpath}"
    fi
}

docker__swapfile__sub() {
    #***NOTE: if 'flag_docker_container_build_ispboootbin_sh_executed_this_script__argv1 = false', then it mean that this script
    #       is initiated from a 'docker_container_build_ispboootbin_sh'. 
    #***NOTE 2: it is important to use this flag, because otherwise if initiated from a 'docker_container_build_ispboootbin_sh'
    #       this part should NEVER be executed. The 'CONTAINER_ENV5' value would NOT be correct!!!
    if [[ "${flag_docker_container_build_ispboootbin_sh_executed_this_script__argv1}" == false ]]; then
        sed -i "/${DOCKER__SED_PATTERN_SWAPFILESIZE_IS}/c\\${DOCKER__SED_PATTERN_SWAPFILESIZE_IS}${CONTAINER_ENV5}" "${docker__SP7021_linux_rootfs_initramfs_disk_scripts_one_time_exec__fpath}"
        echo "---:TIBBO:-:UPDATE: updated 'swapfilesize' in file ${docker__SP7021_linux_rootfs_initramfs_disk_scripts_one_time_exec__fpath}"

        if [[ ${CONTAINER_ENV5} -gt 0 ]]; then
            local entry_isfound=$(grep -F "${DOCKER__FSTAB_TB_RESERVE_DIR_ENTRY}" "${docker__SP7021_linux_rootfs_initramfs_disk_etc_fstab__fpath}")
            if [[ -z "${entry_isfound}" ]]; then
                echo "${DOCKER__FSTAB_TB_RESERVE_DIR_ENTRY}" | tee -a "${docker__SP7021_linux_rootfs_initramfs_disk_etc_fstab__fpath}"
                echo "---:TIBBO:-:UPDATE: added entry '${DOCKER__FSTAB_TB_RESERVE_DIR_ENTRY}' to ${docker__SP7021_linux_rootfs_initramfs_disk_etc_fstab__fpath}"
            fi
        else
            sed -i "/${DOCKER__SED_FSTAB_TB_RESERVE_WO_LEADING_SLASH_ENTRY}/d" "${docker__SP7021_linux_rootfs_initramfs_disk_etc_fstab__fpath}"
            echo "---:TIBBO:-:UPDATE: removed entry '${DOCKER__FSTAB_TB_RESERVE_DIR_ENTRY}' from ${docker__SP7021_linux_rootfs_initramfs_disk_etc_fstab__fpath}"
        fi
    fi
}


#---MAIN SUBROUTINE
docker__main__sub() {
    docker__get_source_fullpath__sub
    docker__load_global_fpath_paths__sub

    docker__ispboootbin_version__sub
    docker__swapfile__sub

    docker__build_ispboootbin__sub
    docker__execute_scripts__sub
}



#---MAIN EXECUTE
docker__main__sub
