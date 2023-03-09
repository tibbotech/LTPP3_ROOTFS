#!/bin/bash
#---FUNCTIONS
function checkif_software_isinstalled__func() {
    #Input args
    local package_input=${1}

    #Define constants
    local PATTERN_PACKAGESTATUS_INSTALLED="ii"

    #Define variables
    dpkg_l_cmd="dpkg -l"

    #Define local 
    local packageStatus=`${dpkg_l_cmd} | grep -w "${package_input}" | awk '{print $1}'`

    #If 'stdOutput' is an EMPTY STRING, then software is NOT installed yet
    if [[ ${packageStatus} == ${PATTERN_PACKAGESTATUS_INSTALLED} ]]; then #contains NO data
        echo true
    else
        echo false
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
                                ;;
                        esac
                    else    #contains data
                        #Print
                        echo -e "---:\e[30;38;5;215mCOMPLETED\e[0;0m: find path of folder \e[30;38;5;246m'${development_tools_foldername}\e[0;0m"


                        #Write to file
                        echo "${docker__LTPP3_ROOTFS_development_tools__dir}" | tee "${mainmenu_path_cache_fpath}" >/dev/null

                        #Print
                        echo -e "---:\e[30;38;5;215mSTATUS\e[0;0m: write path to temporary cache-file: \e[1;33mDONE\e[0;0m"

                        #Update variable
                        result=true
                    fi

                    #set phase
                    phase="${PHASE_EXIT}"

                    #Exit loop
                    break
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
    #---Define PATHS
    docker__home_dir=~
    docker__sp7021_dir=${docker__home_dir}/SP7021
    docker__usr_bin_dir=/usr/bin
    docker__ltpp3rootfs_dir=${docker__home_dir}/LTPP3_ROOTFS
    docker__ltpp3rootfs_development_tools_dir=${docker__ltpp3rootfs_dir}/development_tools

    docker__docker__build_ispboootbin_fpath=${docker__ltpp3rootfs_development_tools_dir}/docker_build_ispboootbin.sh
    docker__bash_fpath=${docker__usr_bin_dir}/bash
}



docker__load_constants__sub() {
    DOCKER__MENUTITLE="Build ${DOCKER__FG_LIGHTGREY}ISPBOOOT.BIN${DOCKER__NOCOLOR}"

    DOCKER__SUBJECT_MANDATORY_SOFTWARE_AND_FILES="---:${DOCKER__PRECHECK}: MANDATORY SOFTWARE & FILES"
    DOCKER__SUBJECT_OVERLAY_RELATED_FILES="---:${DOCKER__PRECHECK}: OVERLAY RELATED FILES"
    DOCKER__SUBJECT_DOCKER_FS_PARTITION_CONF_FILECONTENT="---:${DOCKER__PRECHECK}: DOCKER_FS_PARTITION.CONF FILE-CONTENT"
    DOCKER__SUBJECT_DOCKER_FS_PARTITION_DISKPARTSIZE_DAT_FILECONTENT="---:${DOCKER__PRECHECK}: DOCKER_FS_PARTITION_DISKPARTSIZE.DAT FILE-CONTENT"
    DOCKER__SUBJECT_START_COPY_FILES="---:${DOCKER__START}: COPY FILES"
    DOCKER__SUBJECT_COMPLETED_COPY_FILES="---:${DOCKER__COMPLETED}: COPY FILES"
    DOCKER__SUBJECT_START_PATCH_OVERLAY_TEMPFILES="---:${DOCKER__START}: PATCH OVERLAY TEMPORARY FILES"
    DOCKER__SUBJECT_COMPLETED_PATCH_OVERLAY_TEMPFILES="---:${DOCKER__COMPLETED}: PATCH OVERLAY TEMPORARY FILES"

    DOCKER__INFOMSG_OVERLAYFS_SETTING_IS_DISABLED="-----------:${DOCKER__INFO}: ${DOCKER__FG_LIGHTGREY}overlay${DOCKER__NOCOLOR} setting is disabled...\n"
    DOCKER__INFOMSG_OVERLAYFS_SETTING_IS_DISABLED+="-----------:${DOCKER__INFO}: ignoring overlay..."
    DOCKER__INFOMSG_OVERLAYFS_PARTITION_IS_NOT_PRESENT+="-----------:${DOCKER__INFO}: partition ${DOCKER__FG_LIGHTGREY}overlay${DOCKER__NOCOLOR} is not present...\n"
    DOCKER__INFOMSG_OVERLAYFS_PARTITION_IS_NOT_PRESENT+="-----------:${DOCKER__INFO}: ignoring overlay..."

    DOCKER__ERRMSG_NO_IF_CONDITIONS_FOUND="${DOCKER__ERROR}: no if conditions found!"
    DOCKER__ERRMSG_ONE_OR_MORE_CHECKITEMS_FAILED="${DOCKER__ERROR}: one or more precheck items failed to pass!"
    DOCKER__ERRMSG_ONE_OR_MORE_ENTRIES_ARE_INVALID="${DOCKER__ERROR}: one or more entries are invalid!"
    DOCKER__ERRMSG_ONE_OR_MORE_FILES_COULD_NOT_BE_COPIED="${DOCKER__ERROR}: one or more files could NOT be copied!"
    DOCKER__ERRMSG_PATTERN_EMMC_NOT_FOUND="${DOCKER__ERROR}: pattern ${DOCKER__FG_LIGHTGREY}EMMC${DOCKER__NOCOLOR} not found!"
    DOCKER__ERRMSG_PATTERN_ROOTFS_EX1E0000000_IS_OUT_OF_BOUND="${DOCKER__ERROR}: pattern ${DOCKER__FG_LIGHTGREY}rootfs 0x1e0000000${DOCKER__NOCOLOR} is out of bound!"
    DOCKER__ERRMSG_FILECONTENT_IS_NOT_CONSISTENT_OR_CORRUPT="${DOCKER__ERROR}: file-content is NOT consistent or corrupt!"
}

docker__init_variables__sub() {
    docker__disksize_set=0
    docker__exitCode=0
    docker__isRunning_inside_container=false
    docker__isp_c_overlaybck_isfound=true
    docker__isp_partition_array=()
    docker__isp_partition_arrayitem="${DOCKER__EMPTYSTRING}"
    docker__isp_partition_arraylen=0
    docker__myContainerId="${DOCKER__EMPTYSTRING}"
    docker__numOf_errors_found=0
    docker__overlay_isfound=false
    docker__overlaymode_set="${DOCKER__OVERLAYMODE_PERSISTENT}"
    docker__overlaysetting_set="${DOCKER__OVERLAYFS_DISABLED}"
    docker__showTable=true
}

docker__checkIf_isRunning_inside_container__sub() {
    #Define contants
    local PATTERN_DOCKER="docker"

    #Define variables
    local proc_1_cgroup_dir=/proc/1/cgroup

    #Check if you are currently inside a docker container
    local isDocker=`cat "${proc_1_cgroup_dir}" | grep "${PATTERN_DOCKER}"`
    if [[ ! -z ${isDocker} ]]; then
        docker__isRunning_inside_container=true
    else
        docker__isRunning_inside_container=false
    fi
}

docker__choose_containerID__sub() {
    #Define local message constants
    local READMSG_CHOOSE_A_CONTAINERID="Choose a ${DOCKER__FG_BRIGHTPRUPLE}Container-ID${DOCKER__NOCOLOR} (e.g. dfc5e2f3f7ee): "
    local ERRMSG_INVALID_INPUT_VALUE="${DOCKER__ERROR}: Invalid input value "


    #Check if running inside Docker Container
    #If true, then exit subroutine right away.
    if [[ ${docker__isRunning_inside_container} == true ]]; then   #running in docker container
        return  #exit function
    fi

    #Get container-ID (if running outside a container)
    ${docker__readInput_w_autocomplete__fpath} "${DOCKER__MENUTITLE}" \
                        "${READMSG_CHOOSE_A_CONTAINERID}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${DOCKER__ERRMSG_NO_CONTAINERS_FOUND}" \
                        "${ERRMSG_INVALID_INPUT_VALUE}" \
                        "${docker__ps_a_cmd}" \
                        "${docker__ps_a_containerIdColno}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${docker__showTable}" \
                        "${docker__onEnter_breakLoop}" \
                        "${DOCKER__NUMOFLINES_2}"


    #Get the exit-code just in case:
    #   1. Ctrl-C was pressed in script 'docker__readInput_w_autocomplete__fpath'.
    #   2. An error occured in script 'docker__readInput_w_autocomplete__fpath',...
    #      ...and exit-code = 99 came from function...
    #      ...'show_msg_w_menuTitle_w_pressAnyKey_w_ctrlC_func' (in script: docker__global.sh).
    docker__exitCode=$?
    if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
        docker__myContainerId=${DOCKER__EMPTYSTRING}
    else
        #Get the result
        docker__myContainerId=`get_output_from_file__func "${docker__readInput_w_autocomplete_out__fpath}" "1"`
    fi
}

docker__preCheck__sub() {
    #Define variables
    local printmsg="${DOCKER__EMPTYSTRING}"

    #Reset variables
    docker__numOf_errors_found=0

    #Print Tibbo-title
    load_tibbo_title__func "${DOCKER__NUMOFLINES_2}"

    #Print
    show_msg_only__func "${DOCKER__SUBJECT_MANDATORY_SOFTWARE_AND_FILES}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_0}"

    #Check if running inside docker container
    if [[ ${docker__isRunning_inside_container} == true ]]; then   #running in docker container
        printmsg="-------:${DOCKER__STATUS}: (${DOCKER__FG_LIGHTGREY}${DOCKER__LOCATION_LLOCAL}${DOCKER__NOCOLOR}) Inside Container: true"

        docker__numOf_errors_found=0
    else    #NOT running in docker container
        printmsg="-------:${DOCKER__STATUS}: (${DOCKER__FG_LIGHTGREY}${DOCKER__LOCATION_LLOCAL}${DOCKER__NOCOLOR}) Inside Container: false"

        #Check if docker.io is installed
        #Output: docker__numOf_errors_found
        docker__preCheck_app_isInstalled__sub "${DOCKER__PATTERN_DOCKER_IO}"

        #Check if '/usr/bin/bash' is present
        #Output: docker__numOf_errors_found
        docker__preCheck_app_isPresent__sub "${docker__myContainerId}" "${docker__bash_fpath}"

        #Check if '~/SP7021/linux/rootfs/initramfs/disk' is present
        #Output: docker__numOf_errors_found
        docker__preCheck_app_isPresent__sub "${docker__myContainerId}" "${docker__sp7021_dir}"

        #Check if '~/LTPP3_ROOTFS/development_tools/docker_build_ispboootbin.sh' is present
        #Output: docker__numOf_errors_found
        docker__preCheck_app_isPresent__sub "${docker__myContainerId}" "${docker__docker__build_ispboootbin_fpath}"
    fi

    #Print
    show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

    #In case one or more failed check-items were found
    if [[ ${docker__numOf_errors_found} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
        show_errMsg_wo_menuTitle_and_exit_func "${DOCKER__ERRMSG_ONE_OR_MORE_CHECKITEMS_FAILED}" \
                        ${DOCKER__NUMOFLINES_1} \
                        ${DOCKER__NUMOFLINES_0}
    fi
}
docker__preCheck_app_isInstalled__sub() {
    #Input args
    local appName__input=${1}

    #Define variables
    local printmsg="${DOCKER__EMPTYSTRING}"

    #Check
    local docker_isInstalled=`checkif_software_isinstalled__func "${appName__input}"`
    if [[ ${docker_isInstalled} == true ]]; then
        printmsg="-------:${DOCKER__STATUS}: ${appName__input}: ${DOCKER__STATUS_LINSTALLED}"
    else    #NOT running in docker container
        printmsg="-------:${DOCKER__STATUS}: ${appName__input}: ${DOCKER__STATUS_LNOTINSTALLED}"

        ((docker__numOf_errors_found++))
    fi

    #Print
    show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
}
docker__preCheck_app_isPresent__sub() {
    #Input args
    local containerid__input=${1}
    local path__input=${2}

    #Define variables
    local isFound=false
    local printmsg="${DOCKER__EMPTYSTRING}"

    #Perform preCheck
    #First check if it's a directory
    isFound=`checkIf_dir_exists__func "${containerid__input}" "${path__input}"`
    if [[ ${isFound} == true ]]; then
        printmsg="-------:${DOCKER__STATUS}: ${path__input}: ${DOCKER__STATUS_LPRESENT}"
    else
        #Second: if not a directory, then check if it's a file
        isFound=`checkIf_file_exists__func "${containerid__input}" "${path__input}"`
        if [[ ${isFound} == true ]]; then
            printmsg="-------:${DOCKER__STATUS}: ${path__input}: ${DOCKER__STATUS_LPRESENT}"
        else
            printmsg="-------:${DOCKER__STATUS}: ${path__input}: ${DOCKER__STATUS_LNOTPRESENT}"

            ((docker__numOf_errors_found++))
        fi
    fi

    #Print
    show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
}

docker__overlay__sub() {
    #Define constants
    local PHASE_OVERLAY_FILES_CHECK=1
    local PHASE_OVERLAY_DOCKER_FS_PARTITION_CONF_CHECK=10
    local PHASE_OVERLAY_DOCKER_FS_PARTITION_DISKPARTSIZE_CHECK_AND_CONVERT=20
    local PHASE_OVERLAY_COPY_FILES_FROM_SRC_TO_TMP=30
    local PHASE_OVERLAY_TMPFILES_PATCH=40
    local PHASE_OVERLAY_COPY_FILES_FROM_TMP_TO_DST=50
    local PHASE_OVERLAY_DST_FILES_CHANGE_MOD=60
    local PHASE_OVERLAY_EXIT=100

    #Define variables
    local phase="${PHASE_OVERLAY_FILES_CHECK}"
    local printmsg="${DOCKER__EMPTYSTRING}"

    #Go thru phases
    while true
    do
        case "${phase}" in
            "${PHASE_OVERLAY_FILES_CHECK}")
                docker__overlay_files_check_handler__sub

                phase="${PHASE_OVERLAY_DOCKER_FS_PARTITION_CONF_CHECK}"
                ;;
            "${PHASE_OVERLAY_DOCKER_FS_PARTITION_CONF_CHECK}")
                #Remark:
                #   'docker__overlaysetting_set' is retrieved in this subroutine
                docker__overlay_docker_fs_partition_conf_check_handler__sub

                if [[ "${docker__overlaysetting_set}" == "${DOCKER__OVERLAYFS_DISABLED}" ]]; then
                    phase="${PHASE_OVERLAY_EXIT}"
                else
                    phase="${PHASE_OVERLAY_DOCKER_FS_PARTITION_DISKPARTSIZE_CHECK_AND_CONVERT}"
                fi
                ;;
            "${PHASE_OVERLAY_DOCKER_FS_PARTITION_DISKPARTSIZE_CHECK_AND_CONVERT}")
                #Remark:
                #   'docker__overlay_isfound' is set in this subroutine
                docker__overlay_docker_fs_partition_diskpartsize_check_and_convert_handler__sub

                if [[ ${docker__overlay_isfound} == false ]]; then
                    phase="${PHASE_OVERLAY_EXIT}"
                else
                    phase="${PHASE_OVERLAY_COPY_FILES_FROM_SRC_TO_TMP}"
                fi
                ;;
            "${PHASE_OVERLAY_COPY_FILES_FROM_SRC_TO_TMP}")
                docker__overlay_copy_files_from_src_to_tmp_handler__sub

                phase="${PHASE_OVERLAY_TMPFILES_PATCH}"
                ;;
            "${PHASE_OVERLAY_TMPFILES_PATCH}")
                docker__overlay_tempfiles_patch_handler__sub

                phase="${PHASE_OVERLAY_COPY_FILES_FROM_TMP_TO_DST}"
                ;;
            "${PHASE_OVERLAY_COPY_FILES_FROM_TMP_TO_DST}")
                exit
                ;;
            "${PHASE_OVERLAY_DST_FILES_CHANGE_MOD}")
                exit
                ;;
            "${PHASE_OVERLAY_EXIT}")
                echo -e "${printmsg}"

echo "EXIT"
                exit
                ;;
        esac
    done
}

docker__overlay_files_check_handler__sub() {
    #Reset variables
    docker__numOf_errors_found=0

    #Print
    show_msg_only__func "${DOCKER__SUBJECT_OVERLAY_RELATED_FILES}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_0}"

    #Initialize variables
    docker__numOf_errors_found=0
    docker__isp_c_overlaybck_isfound=true

    #Check fullpath and print status
    docker__overlay_checkif_file_ispresent__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__docker_fs_partition_diskpartsize_dat__fpath}" "false"
    docker__overlay_checkif_file_ispresent__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__docker_fs_partition_conf__fpath}" "false"
    docker__overlay_checkif_file_ispresent__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__LTPP3_ROOTFS_build_scripts_isp_sh__fpath}" "false"
    docker__overlay_checkif_file_ispresent__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__LTPP3_ROOTFS_boot_configs_pentagram_common_h__fpath}" "false"
    docker__overlay_checkif_file_ispresent__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__LTPP3_ROOTFS_linux_scripts_tb_init_sh__fpath}" "false"
    docker__overlay_checkif_file_ispresent__sub "${docker__myContainerId}" \
            "${docker__SP7021_build_tools_isp_isp_c_overlaybck_fpath}" "true"

    #Incase file '~/SP7021/build/tools/isp/isp.c.overlaybck' was NOT found in the container
    if [[ ${docker__isp_c_overlaybck_isfound} == false ]]; then
        #Make a copy of file '~/SP7021/build/tools/isp/isp.c' and copy it as '~/SP7021/build/tools/isp/isp.c.overlaybck' (same location in the container)
        docker__overlay_renew_files__sub "${docker__myContainerId}" \
                "${docker__SP7021_build_tools_isp_isp_c__fpath}" \
                "${docker__myContainerId}" \
                "${docker__SP7021_build_tools_isp_isp_c_overlaybck_fpath}"
                
        docker__overlay_checkif_file_ispresent__sub "${docker__myContainerId}" \
                "${docker__SP7021_build_tools_isp_isp_c_overlaybck_fpath}" "false"
    fi

    #Show error message and exit (if applicable)
    if [[ ${docker__numOf_errors_found} -gt 0 ]]; then
        show_errMsg_wo_menuTitle_and_exit_func "${DOCKER__ERRMSG_ONE_OR_MORE_CHECKITEMS_FAILED}" \
                ${DOCKER__NUMOFLINES_1} \
                ${DOCKER__NUMOFLINES_0}
    fi
}
docker__overlay_checkif_file_ispresent__sub() {
    #Remark:
    #   This subroutine implicitely outputs the variables:
    #       docker__isp_c_overlaybck_isfound (bool)
    #       docker__numOf_errors_found (integer)
    #Input args
    local containerid__input=${1}
    local path__input=${2}

    #Update 'printmsg'
    local printmsg="${DOCKER__EMPTYSTRING}"
    if [[ -z "${containerid__input}" ]]; then
        printmsg="-------:${DOCKER__STATUS}: (${DOCKER__FG_LIGHTGREY}${DOCKER__LOCATION_LLOCAL}${DOCKER__NOCOLOR})"
    else
        printmsg="-------:${DOCKER__STATUS}: (${DOCKER__FG_LIGHTGREY}${containerid__input}${DOCKER__NOCOLOR})"
    fi

    #Check if 'path__input' exists and update 'printmsg'
    if [[ $(checkIf_file_exists__func "${containerid__input}" \
            "${path__input}") == true ]]; then  #file is exists
        printmsg+=" ${path__input}: ${DOCKER__STATUS_LPRESENT}"
    else    #file does not exist
        #Check if 'path__input = '~/SP7021/build/tools/isp/isp.c.overlaybck'
        if [[ "${path__input}" == "${docker__SP7021_build_tools_isp_isp_c_overlaybck_fpath}" ]]; then   #true
            docker__isp_c_overlaybck_isfound=false

            printmsg+=" ${path__input}: ${DOCKER__STATUS_LNOTPRESENT_IGNORE}"
        else    #false
            printmsg+=" ${path__input}: ${DOCKER__STATUS_LNOTPRESENT}"

            ((docker__numOf_errors_found++))
        fi
    fi

    #Print
    show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
}

docker__overlay_docker_fs_partition_conf_check_handler__sub() {
    #Reset variables
    docker__numOf_errors_found=0

    #Print
    show_msg_only__func "${DOCKER__SUBJECT_DOCKER_FS_PARTITION_CONF_FILECONTENT}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_0}"

    #Validate the content of 'docker_fs_partition.conf'
    docker_overlay_disksizeset_check__sub
    docker_overlay_overlaymode_check__sub
    docker_overlay_overlayfs_check__sub

    #Show error message and exit (if applicable)
    if [[ ${docker__numOf_errors_found} -gt 0 ]]; then
        show_errMsg_wo_menuTitle_and_exit_func "${DOCKER__ERRMSG_ONE_OR_MORE_ENTRIES_ARE_INVALID}" \
                ${DOCKER__NUMOFLINES_1} \
                ${DOCKER__NUMOFLINES_0}
    fi
}
docker_overlay_disksizeset_check__sub() {
    #Define variables
    local printmsg="${DOCKER__EMPTYSTRING}"

    #Initialize variables
    docker__disksize_set=0

    #Get data from file
    docker__disksize_set=$(retrieve_data_from_file_based_on_specified_pattern_colnum_delimiterchar__func \
            "${docker__docker_fs_partition_conf__fpath}" \
            "${DOCKER__DISKSIZESETTING}" \
            "${DOCKER__COLNUM_2}" \
            "${DOCKER__ONESPACE}")

    #Update 'printmsg'
    printmsg="-------:${DOCKER__STATUS}: ${DOCKER__DISKSIZESETTING}: ${DOCKER__FG_LIGHTGREY}${docker__disksize_set}${DOCKER__NOCOLOR} " 
    if [[ $(isNumeric__func "${docker__disksize_set}") == false ]]; then  #is not numeric
        printmsg+="(${DOCKER__STATUS_LINVALID})"

        ((docker__numOf_errors_found++))
    else    #is numeric
        if [[ ${docker__disksize_set} -le 0 ]]; then  #less or equal to 0
            printmsg+="(${DOCKER__STATUS_LINVALID})"

            ((docker__numOf_errors_found++))
        else    #greater than 0
            printmsg+="(${DOCKER__STATUS_LVALID})"
        fi
    fi

    #Print
    show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
}
docker_overlay_overlaymode_check__sub() {
    #Define variables
    local printmsg="${DOCKER__EMPTYSTRING}"

    #Initialize variables
    docker__overlaymode_set="${DOCKER__OVERLAYMODE_PERSISTENT}"

    #Get data from file
    docker__overlaymode_set=$(retrieve_data_from_file_based_on_specified_pattern_colnum_delimiterchar__func \
            "${docker__docker_fs_partition_conf__fpath}" \
            "${DOCKER__OVERLAYMODE}" \
            "${DOCKER__COLNUM_2}" \
            "${DOCKER__ONESPACE}")

    #Update 'printmsg'
    printmsg="-------:${DOCKER__STATUS}: ${DOCKER__OVERLAYMODE}: ${DOCKER__FG_LIGHTGREY}${docker__overlaymode_set}${DOCKER__NOCOLOR} " 
    if [[ "${docker__overlaymode_set}" != "${DOCKER__OVERLAYMODE_PERSISTENT}" ]] && \
            [[ "${docker__overlaymode_set}" != "${DOCKER__OVERLAYMODE_NONPERSISTENT}" ]]; then
        printmsg+="(${DOCKER__STATUS_LINVALID})"

        ((docker__numOf_errors_found++))
    else
        printmsg+="(${DOCKER__STATUS_LVALID})"
    fi

    #Print
    show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
}
docker_overlay_overlayfs_check__sub() {
    #Define variables
    local printmsg="${DOCKER__EMPTYSTRING}"

    #Initialize variables
    docker__overlaysetting_set="${DOCKER__OVERLAYMODE_PERSISTENT}"

    #Get data from file
    docker__overlaysetting_set=$(retrieve_data_from_file_based_on_specified_pattern_colnum_delimiterchar__func \
            "${docker__docker_fs_partition_conf__fpath}" \
            "${DOCKER__OVERLAYSETTING}" \
            "${DOCKER__COLNUM_2}" \
            "${DOCKER__ONESPACE}")

    #Update 'printmsg'
    printmsg="-------:${DOCKER__STATUS}: ${DOCKER__OVERLAYSETTING}: ${DOCKER__FG_LIGHTGREY}${docker__overlaysetting_set}${DOCKER__NOCOLOR} " 
    if [[ "${docker__overlaysetting_set}" != "${DOCKER__OVERLAYFS_ENABLED}" ]] && \
            [[ "${docker__overlaysetting_set}" != "${DOCKER__OVERLAYFS_DISABLED}" ]]; then
        printmsg+="(${DOCKER__STATUS_LINVALID})"

        ((docker__numOf_errors_found++))
    else
        printmsg+="(${DOCKER__STATUS_LVALID})"
    fi

    #Print
    show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

    #In case 'docker__overlaysetting_set = disabled', show message and exit this subroutine
    if [[ "${docker__overlaysetting_set}" == "${DOCKER__OVERLAYFS_DISABLED}" ]]; then
        show_msg_only__func "${DOCKER__INFOMSG_OVERLAYFS_SETTING_IS_DISABLED}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
    fi
}

docker__overlay_docker_fs_partition_diskpartsize_check_and_convert_handler__sub() {
    #Reset variables
    docker__numOf_errors_found=0

    #Print
    show_msg_only__func "${DOCKER__SUBJECT_DOCKER_FS_PARTITION_DISKPARTSIZE_DAT_FILECONTENT}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_0}"

    #Validate the content of 'docker_fs_partition_diskpartsize.dat'
    docker__overlay_diskpartsize_check_and_convert__sub

    #Show error message and exit (if applicable)
    if [[ ${docker__numOf_errors_found} -gt 0 ]]; then
        show_errMsg_wo_menuTitle_and_exit_func "${DOCKER__ERRMSG_ONE_OR_MORE_ENTRIES_ARE_INVALID}" \
                ${DOCKER__NUMOFLINES_1} \
                ${DOCKER__NUMOFLINES_0}
    fi
}
docker__overlay_diskpartsize_check_and_convert__sub() {
    #Define variables
    local diskpartname="${DOCKER__EMPTYSTRING}"
    local diskpartname_last="${DOCKER__EMPTYSTRING}"
    local diskpartsize_M=0  #Megabyte
    local diskpartsize_B=0  #Byte
    local dispartsize_H="${DOCKER__EMPTYSTRING}"    #Hex
    local printmsg="${DOCKER__EMPTYSTRING}"
    local remaining_diskpartsize_M=0
    local remaining_isfound=false
    local tb_reserve_isfound=false
    local rootfs_isfound=false
    local i=0

    #Initialize variables
    docker__overlay_isfound=false

    #Iterate thru file-content
    while read -r line
    do
        #Get 'diskpartname' and 'diskpartsize_M'
        diskpartname=$(echo "${line}" | awk '{print $1}')
        diskpartsize_M=$(echo "${line}" | awk '{print $2}')

        #Update 'printmsg'
        printmsg="-------:${DOCKER__STATUS}: ${diskpartname}: ${DOCKER__FG_LIGHTGREY}${diskpartsize_M}${DOCKER__NOCOLOR} " 

        #Check if 'rootfs' is found
        if [[ "${diskpartname}" == "${DOCKER__DISKPARTNAME_ROOTFS}" ]]; then
            rootfs_isfound=true 
        fi

        #Check if 'tb_reserve' is found
        if [[ "${diskpartname}" == "${DOCKER__DISKPARTNAME_TB_RESERVE}" ]]; then
            tb_reserve_isfound=true 
        fi

        #Check if 'overlay' is found
        if [[ "${diskpartname}" == "${DOCKER__DISKPARTNAME_OVERLAY}" ]]; then
            docker__overlay_isfound=true
        fi

        #Check if 'tb_reserve' is found
        if [[ "${diskpartname}" == "${DOCKER__DISKPARTNAME_REMAINING}" ]]; then
            remaining_isfound=true 
        fi

        #Check if 'dispartsize_M' is numeric
        if [[ $(isNumeric__func "${diskpartsize_M}") == false ]]; then  #is not numeric
            printmsg+="(${DOCKER__STATUS_LINVALID})"

            ((docker__numOf_errors_found++))
        else    #is numeric
            if [[ ${diskpartsize_M} -le 0 ]] && [[ "${diskpartname}" != "${DOCKER__DISKPARTNAME_REMAINING}" ]]; then  #less or equal to 0
                printmsg+="(${DOCKER__STATUS_LINVALID})"

                ((docker__numOf_errors_found++))
            else    #greater than 0
                if [[ "${diskpartname}" != "${DOCKER__DISKPARTNAME_REMAINING}" ]]; then
                    #Update index 'i' only if array 'docker__isp_partition_array' contains data
                    if [[ ${#docker__isp_partition_array[@]} -gt 0 ]]; then
                        ((i++))
                    fi

                    #Convert Megabyte to Byte
                    diskpartsize_B=$((diskpartsize_M * DOCKER__DISKSIZE_1K_IN_BYTES * DOCKER__DISKSIZE_1K_IN_BYTES))
                    #Convert Byte to Hex
                    dispartsize_H=$(printf "0x%x" $diskpartsize_B)

                    #Add 'diskpartname' and 'dispartsize_H' to array
                    docker__isp_partition_array[i]="${diskpartname} ${dispartsize_H}"
                else    #diskpartname = remaining
                    #Note: 'diskpartname = remaining' is not added to array 'docker__isp_partition_array'
                    remaining_diskpartsize_M=${diskpartsize_M}
                fi

                #Append string to 'printmsg'
                printmsg+="(${DOCKER__STATUS_LVALID})"
            fi
        fi

        #Print
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
    done < "${docker__docker_fs_partition_diskpartsize_dat__fpath}"

    #Check if 'remaining_diskpartsize_M = 0'.
    #If true, then for the LAST 'diskpartname' set 'dispartsize_H = 0x1e0000000'.
    if [[ ${remaining_diskpartsize_M} -eq 0 ]]; then
        diskpartname_last=$(echo ${docker__isp_partition_array[i]} | cut -d"${DOCKER__ONESPACE}" -f1)

        docker__isp_partition_array[i]="${diskpartname_last} ${DOCKER__DISKSIZE_0X1E0000000}"
    fi


    #Check if 'overlay' is configured
    #Remark:
    #   If 'overlay' partition is NOT present, then exit this subroutine immediately.
    #   This is equivalent to 'docker__overlaysetting_set = disabled'
    if [[ ${docker__overlay_isfound} == false ]]; then
        #Reset array related variables
        docker__isp_partition_array=()
        docker__isp_partition_arrayitem="${DOCKER__EMPTYSTRING}"
        docker__isp_partition_arraylen=0

        #Update 'printmsg'
        printmsg="-------:${DOCKER__STATUS}: ${DOCKER__DISKPARTNAME_OVERLAY}: ${DOCKER__FG_LIGHTGREY}${DOCKER__DASH}${DOCKER__NOCOLOR} "
        printmsg+="(${DOCKER__STATUS_LINVALID})"
        #Print
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        #Print
        show_msg_only__func "${DOCKER__INFOMSG_OVERLAYFS_PARTITION_IS_NOT_PRESENT}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        return 0;
    fi

    #Check if 'rootfs' partition is configured
    if [[ ${rootfs_isfound} == false ]]; then
        printmsg="-------:${DOCKER__STATUS}: (${DOCKER__FG_LIGHTGREY}${DOCKER__LOCATION_LLOCAL}${DOCKER__NOCOLOR}) " 
        printmsg+="${DOCKER__FG_LIGHTGREY}...${DOCKER__NOCOLOR}/${docker__docker_fs_partition_conf__filename} "
        printmsg+="(${DOCKER__FG_YELLOW}${DOCKER__DISKPARTNAME_ROOTFS}${DOCKER__NOCOLOR} "
        printmsg+="${DOCKER__FG_LIGHTRED}not${DOCKER__NOCOLOR} present)"

        #Print
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        ((docker__numOf_errors_found++))
    fi

    #Check if 'tb_reserve' partition is configured
    if [[ ${tb_reserve_isfound} == false ]]; then
        printmsg="-------:${DOCKER__STATUS}: (${DOCKER__FG_LIGHTGREY}${DOCKER__LOCATION_LLOCAL}${DOCKER__NOCOLOR}) " 
        printmsg+="${DOCKER__FG_LIGHTGREY}...${DOCKER__NOCOLOR}/${docker__docker_fs_partition_conf__filename} "
        printmsg+="(${DOCKER__FG_YELLOW}${DOCKER__DISKPARTNAME_TB_RESERVE}${DOCKER__NOCOLOR} "
        printmsg+="${DOCKER__FG_LIGHTRED}not${DOCKER__NOCOLOR} present)"

        #Print
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        ((docker__numOf_errors_found++))
    fi

    #Check if 'tb_reserve' partition is configured
    if [[ ${remaining_isfound} == false ]]; then
        printmsg="-------:${DOCKER__STATUS}: (${DOCKER__FG_LIGHTGREY}${DOCKER__LOCATION_LLOCAL}${DOCKER__NOCOLOR}) " 
        printmsg+="${DOCKER__FG_LIGHTGREY}...${DOCKER__NOCOLOR}/${docker__docker_fs_partition_conf__filename} "
        printmsg+="(${DOCKER__FG_YELLOW}${DOCKER__DISKPARTNAME_REMAINING}${DOCKER__NOCOLOR} "
        printmsg+="${DOCKER__FG_LIGHTRED}not${DOCKER__NOCOLOR} present)"

        #Print
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        ((docker__numOf_errors_found++))
    fi
}

docker__overlay_copy_files_from_src_to_tmp_handler__sub() {
    #Reset variables
    docker__numOf_errors_found=0

    #Print
    show_msg_only__func "${DOCKER__SUBJECT_START_COPY_FILES}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_0}"

    #Copy files
    docker__overlay_renew_files__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__LTPP3_ROOTFS_build_scripts_isp_sh__fpath}" \
            "${DOCKER__EMPTYSTRING}" \
            "${docker__docker_overlayfs_isp_sh__fpath}"

    docker__overlay_renew_files__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__LTPP3_ROOTFS_boot_configs_pentagram_common_h__fpath}" \
            "${DOCKER__EMPTYSTRING}" \
            "${docker__docker_overlayfs_pentagram_common_h__fpath}"

    docker__overlay_renew_files__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__LTPP3_ROOTFS_linux_scripts_tb_init_sh__fpath}" \
            "${DOCKER__EMPTYSTRING}" \
            "${docker__docker_overlayfs_tb_init_sh__fpath}"

    docker__overlay_renew_files__sub "${docker__myContainerId}" \
            "${docker__SP7021_build_tools_isp_isp_c_overlaybck_fpath}" \
            "${DOCKER__EMPTYSTRING}" \
            "${docker__docker_overlayfs_isp_c__fpath}"

    #Show error message and exit (if applicable)
    if [[ ${docker__numOf_errors_found} -gt 0 ]]; then
        show_errMsg_wo_menuTitle_and_exit_func "${DOCKER__ERRMSG_ONE_OR_MORE_CHECKITEMS_FAILED}" \
                ${DOCKER__NUMOFLINES_1} \
                ${DOCKER__NUMOFLINES_0}
    fi

    #Print
    show_msg_only__func "${DOCKER__SUBJECT_COMPLETED_COPY_FILES}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
}
docker__overlay_renew_files__sub() {
    #Remark:
    #   This subroutine implicitely outputs the variable:
    #       docker__numOf_errors_found (integer)
    #Input args
    local src_cid__input=${1}
    local srcfpath__input=${2}
    local dst_cid__input=${3}
    local dstfpath__input=${4}

    #Define variables
    local exitcode=0
    local srcfilename=$(basename ${srcfpath__input})
    local srcdir=$(dirname ${srcfpath__input})
    local srcfpath_tmp=${docker__tmp__dir}/${srcfilename}
    local dstdir=$(dirname ${dstfpath__input})
    local printmsg="${DOCKER__EMPTYSTRING}"

    #Remove file
    remove_file__func "${dstfpath__input}" "-------:"

    #Copy file
    if [[ -z "${src_cid__input}" ]] && [[ -z ${dst_cid__input} ]]; then
        cp "${srcfpath__input}" "${dstfpath__input}"; exitcode=$?
    elif [[ -z "${src_cid__input}" ]] && [[ -n ${dst_cid__input} ]]; then
        docker cp ${srcfpath__input} ${dst_cid__input}:${dstfpath__input}; exitcode=$?
    elif [[ -n "${src_cid__input}" ]] && [[ -z ${dst_cid__input} ]]; then
        docker cp ${src_cid__input}:${srcfpath__input} ${dstfpath__input}; exitcode=$?
    else    #src_cid__input != Empty String && dst_cid__input != Empty String
        #IMPORTANT TO KNOW:
        #   Copying between containers is NOT supported.
        #   In order to be able to make this work, the following workaround will be applied:
        #   1. copy from container to local (/tmp)
        docker cp ${src_cid__input}:${srcfpath__input} ${srcfpath_tmp}; exitcode=$?
        #   2. copy from local (/tmp) to container
        docker cp ${srcfpath_tmp} ${dst_cid__input}:${dstfpath__input}; exitcode=$?
    fi

    #Check 'exitcode' and update 'printmsg'
    printmsg="-------:${DOCKER__STATUS}: copy file ${DOCKER__FG_LIGHTGREY}${srcfilename}${DOCKER__NOCOLOR}: "
    if [[ ${exitcode} -eq 0 ]]; then
        printmsg+="${DOCKER__STATUS_SUCCESSFUL}\n"
    else
        printmsg="${DOCKER__STATUS_FAILED}\n"

        ((docker__numOf_errors_found++))
    fi

    #Update 'printmsg' with 'from'
    printmsg+="-----------:${DOCKER__LOCATION}: "
    if [[ -z "${src_cid__input}" ]]; then
        printmsg+="(${DOCKER__FG_LIGHTGREY}${DOCKER__LOCATION_LLOCAL}${DOCKER__NOCOLOR})"
    else
        printmsg+="(${DOCKER__FG_LIGHTGREY}${src_cid__input}${DOCKER__NOCOLOR})"
    fi
    printmsg+=" from: ${DOCKER__FG_LIGHTGREY}${srcdir}${DOCKER__NOCOLOR}\n"

    #Update 'printmsg' with 'to'
    printmsg+="-----------:${DOCKER__LOCATION}: "
    if [[ -z "${dst_cid__input}" ]]; then
        printmsg+="(${DOCKER__FG_LIGHTGREY}${DOCKER__LOCATION_LLOCAL}${DOCKER__NOCOLOR})"
    else
        printmsg+="(${DOCKER__FG_LIGHTGREY}${dst_cid__input}${DOCKER__NOCOLOR})"
    fi
    printmsg+=" to: ${DOCKER__FG_LIGHTGREY}${dstdir}${DOCKER__NOCOLOR}"

    #Print
    show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
}

docker__overlay_tempfiles_patch_handler__sub() {
    #Reset variables
    docker__numOf_errors_found=0

    #Print
    show_msg_only__func "${DOCKER__SUBJECT_START_PATCH_OVERLAY_TEMPFILES}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_0}"

    #Prepare the temporary files
    docker__overlay_tempfile_isp_sh_patch__sub
    docker__overlay_tempfile_isp_c_patch__sub


    #Show error message and exit (if applicable)
    if [[ ${docker__numOf_errors_found} -gt 0 ]]; then
        show_errMsg_wo_menuTitle_and_exit_func "${DOCKER__ERRMSG_FILECONTENT_IS_NOT_CONSISTENT_OR_CORRUPT}" \
                ${DOCKER__NUMOFLINES_1} \
                ${DOCKER__NUMOFLINES_0}
    fi

    #Print
    show_msg_only__func "${DOCKER__SUBJECT_COMPLETED_PATCH_OVERLAY_TEMPFILES}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
}
docker__overlay_tempfile_isp_sh_patch__sub() {
    #Define variables
    local emmc_linenum=0
    local emmc_linenumstart=0
    local emmc_linenumend=0
    local if_linenum_arr=()
    local if_linenum_arritem="${DOCKER__EMPTYSTRING}"
    local if_linenum_arritem_next="${DOCKER__EMPTYSTRING}"
    local if_linenum_arrlen=0
    local line_containing_rootfs_0x1e0000000="${DOCKER__EMPTYSTRING}"
    local linenum_containing_rootfs_0x1e0000000="${DOCKER__EMPTYSTRING}"
    local partitions_for_isp="${DOCKER__EMPTYSTRING}"
    local printmsg="${DOCKER__EMPTYSTRING}"

    local i=0


    #Start generating 'printmsg'
    printmsg="-------:${DOCKER__STATUS}: patch ${DOCKER__FG_LIGHTGREY}${docker__docker_overlayfs_isp_sh__fpath}: " 

    #Get the 'linenum' of each 'if' and 'elif' condition
    #   if [[ ... ]]; then      <--+    linenum_1
    #                              |
    #   elif [[ ... ]]; then    <--+    linenum_2
    #                              |
    #   elif [[ ... ]]; then    <--+    linenum_3
    #   ..
    #   etc.
    readarray -t if_linenum_arr < <(grep -nF "${DOCKER__PATTERN_IF}" "${docker__docker_overlayfs_isp_sh__fpath}" | cut -d"${DOCKER__COLON}" -f1)

    #Calculate array-length
    if_linenum_arrlen=${#if_linenum_arr[@]}
    #Check if 'if_linenum_arrlen = 0'
    if [[ ${if_linenum_arrlen} -eq 0 ]]; then
        #Increment index
        ((docker__numOf_errors_found++))

        #Update 'printmsg'
        printmsg+="${DOCKER__STATUS_FAILED}\n"
        printmsg+="\n${DOCKER__ERRMSG_NO_IF_CONDITIONS_FOUND}"
        
        #Print
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        #Move-up 1 line to compensate for when 'show_errMsg_wo_menuTitle_and_exit_func' is executed
        moveUp__func "${DOCKER__NUMOFLINES_1}"

        return 0;
    fi


    #Find the pattern 'EMMC'
    emmc_linenum=$(grep -nF "${DOCKER__PATTERN_EMMC}" "${docker__docker_overlayfs_isp_sh__fpath}" | cut -d"${DOCKER__COLON}" -f1)
    #Check if 'emmc_linenum = 0'
    if [[ ${emmc_linenum} -eq 0 ]]; then
        #Increment index
        ((docker__numOf_errors_found++))

        #Update 'printmsg'
        printmsg+="${DOCKER__STATUS_FAILED}\n"
        printmsg+="\n${DOCKER__ERRMSG_PATTERN_EMMC_NOT_FOUND}"
        
        #Print
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        #Move-up 1 line to compensate for when 'show_errMsg_wo_menuTitle_and_exit_func' is executed
        moveUp__func "${DOCKER__NUMOFLINES_1}"

        return 0;
    fi

    #Update 'emmc_linenumstart'
    emmc_linenumstart="${emmc_linenum}"
    #Determine 'emmc_linenumend'
    for (( i=0; i<${if_linenum_arrlen}; i++))
    do
        if_linenum_arritem="${if_linenum_arr[i]}"

        if [[ ${if_linenum_arritem} -eq ${emmc_linenumstart} ]]; then
            if_linenum_arritem_next="${if_linenum_arr[i+1]}"
            emmc_linenumend=$((if_linenum_arritem_next - 1))
        fi
    done

    if [[ ${emmc_linenumend} -eq 0 ]]; then
        #Increment index
        ((docker__numOf_errors_found++))

        #Update 'printmsg'
        printmsg+="${DOCKER__STATUS_FAILED}"
        
        #Print
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        return 0;
    fi

    #Find and get line containing pattern 'rootfs 0x1e0000000'
    linenum_containing_rootfs_0x1e0000000=$(grep -nF "${DOCKER__PATTERN_ROOTFS_0X1E0000000}"  "${docker__docker_overlayfs_isp_sh__fpath}" | cut -d"${DOCKER__COLON}" -f1)
    #Check if 'linenum_containing_rootfs_0x1e0000000 is within the boundary'
    if [[ ${linenum_containing_rootfs_0x1e0000000} -lt ${emmc_linenumstart} ]] || \
            [[ ${linenum_containing_rootfs_0x1e0000000} -gt ${emmc_linenumend} ]]; then
        #Increment index
        ((docker__numOf_errors_found++))

        #Update 'printmsg'
        printmsg+="${DOCKER__STATUS_FAILED}\n"
        printmsg+="\n${DOCKER__ERRMSG_PATTERN_ROOTFS_EX1E0000000_IS_OUT_OF_BOUND}"
        
        #Print
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        #Move-up 1 line to compensate for when 'show_errMsg_wo_menuTitle_and_exit_func' is executed
        moveUp__func "${DOCKER__NUMOFLINES_1}"

        return 0;
    fi


    #Get array-length
    docker__isp_partition_arraylen=${#docker__isp_partition_array[@]}

    #Convert 'array' to 'string'
    #Start by adding the 'rootfs' partition and suze
    #Remark:
    #   Notice the index=1
    #   Make sure to indent with double TABs.
    partitions_for_isp="\t\t${docker__isp_partition_array[1]} \\\\\n"
    #Then add the 'tb_reserve' partition and size
    #Remark:
    #   Notice the index=0
    #   Make sure to indent with double TABs.
    partitions_for_isp+="\t\t${docker__isp_partition_array[0]} \\\\\n"

    #Lastly, add the rest of the partitions and sizes
    #Remark:
    #   Only execute this part if the 'array-length > 2'
    if [[ ${docker__isp_partition_arraylen} -gt 2 ]]; then
        for (( i=2; i<${docker__isp_partition_arraylen}; i++ ));
        do
            #Add the additional partition and size
            partitions_for_isp+="\t\t${docker__isp_partition_array[i]} "

            #Remark
            #   Only add a backslash (\\\\) and new-line (\n),
            #   ...the current array-element is NOT the LAST element.
            if [[ ${i} -lt $((docker__isp_partition_arraylen-1)) ]]; then
                partitions_for_isp+="\\\\\n"
            fi
        done
    fi

    #Patch the temporary file '.../docker/overlayfs/isp.sh'
    replace_or_append_string_in_file__func "${partitions_for_isp}" \
            "${DOCKER__PATTERN_ROOTFS_0X1E0000000}" \
            "${docker__docker_overlayfs_isp_sh__fpath}"
    if [[ "$?" -ne 0 ]]; then
        #Increment index
        ((docker__numOf_errors_found++))

        #Update 'printmsg'
        printmsg+="${DOCKER__STATUS_FAILED}"
    else
        printmsg+="${DOCKER__STATUS_SUCCESSFUL}"
    fi
    
    #Print
    show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
}

docker__overlay_tempfile_isp_c_patch__sub() {
    echo "docker__overlay_tempfile_isp_c_patch__sub: in progress"
}


docker__run_script__sub() {
    #Define variables
    local docker_exec_cmd="docker exec -it ${docker__myContainerId} ${docker__bash_fpath} -c"
    local cmd_outside_container="eval \"${docker__docker__build_ispboootbin_fpath}\""
    local cmd_inside_container="eval \"${docker__docker__build_ispboootbin_fpath}\""
    local printmsg="${DOCKER__EMPTYSTRING}"

    #Execute script 'docker__build_ispboootbin_fpath'
    if [[ ${docker__isRunning_inside_container} == true ]]; then   #currently in a container
        ${cmd_outside_container}
    else    #currently outside of a container
        ${docker_exec_cmd} "${cmd_inside_container}"
    fi

    #Check if there are any errors
    docker__exitCode=$?
    if [[ ${docker__exitCode} -ne 0 ]]; then #no errors found
        printmsg="-------:${DOCKER__STATUS}: build ${DOCKER__FG_LIGHTGREY}ISPBOOOT.BIN${DOCKER__NOCOLOR}: ${DOCKER__STATUS_FAILED}"
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_0}"

        exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_1}"
    else
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    fi
}

docker__main__sub(){
    docker__get_source_fullpath__sub

    docker__load_global_fpath_paths__sub

    docker__environmental_variables__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__checkIf_isRunning_inside_container__sub

    docker__choose_containerID__sub

    #Note:
    #   This pre-check has run AFTER 'docker__choose_containerID__sub',
    #   ...because the 'container-ID' may be needed.
    docker__preCheck__sub

    docker__overlay__sub

    docker__run_script__sub
}


#Run main subroutine
docker__main__sub
