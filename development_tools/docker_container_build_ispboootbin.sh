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

function create_dir_in_container__func() {
    #Input args
    containerid__input=${1}
    dir__input=${2}

    #In container, check if directory exists
    if [[ -n ${containerid__input} ]]; then  #not inside container
        #Check if directory exist.
        ${DOCKER__EXEC} ${containerid__input} [ ! -d "${dir__input}" ] && exitcode=1

        #If false, exitcode > 0.
        if [[ ${exitcode} -ne 0 ]]; then    #directory does NOT exist
            #Send a command from OUTSIDE to INSIDE container to execute the directory creation.
            ${DOCKER__EXEC} ${containerid__input} mkdir -p "${dir__input}"
        fi
    else    #inside a container, that's why containerid__input = Empty String
        #Check if directory exist.
        if [[ ! -d "${dir__input}" ]]; then   #directory does NOT exist
            #Create directory
            mkdir -p "${dir__input}"
        fi
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
    DOCKER__SUBJECT_START_COPY_FILES_FROM_SRC_TO_TMP_LOCATION="---:${DOCKER__START}: COPY FILES FROM SOURCE TO TEMP LOCATION"
    DOCKER__SUBJECT_COMPLETED_COPY_FILES="---:${DOCKER__COMPLETED}: COPY FILES"
    DOCKER__SUBJECT_START_PATCH_OVERLAY_TEMPFILES="---:${DOCKER__START}: PATCH OVERLAY TEMPORARY FILES"
    DOCKER__SUBJECT_COMPLETED_PATCH_OVERLAY_TEMPFILES="---:${DOCKER__COMPLETED}: PATCH OVERLAY TEMPORARY FILES"
    DOCKER__SUBJECT_START_COPY_FILES_FROM_TMP_TO_DST_LOCATION="---:${DOCKER__START}: COPY FILES FROM TEMP TO DESTINATION LOCATION"
    DOCKER__SUBJECT_START_DST_EXECFILES_CHANGE_PERMISSION_TO_RWXRXRX="---:${DOCKER__START}: DESTINATION EXEC-FILES > CHANGE PERMISSION TO RWXR-XR-X"
    DOCKER__SUBJECT_COMPLETED_DST_EXECFILES_CHANGE_PERMISSION_TO_RWXRXRX="---:${DOCKER__COMPLETED}: DESTINATION EXEC-FILES > CHANGE PERMISSION TO RWXR-XR-X"
    DOCKER__SUBJECT_START_TB_INIT_SH_CREATE_SOFTLINK="---:${DOCKER__START}: TB_INIT.SH > CREATE SOFT-LINK"
    DOCKER__SUBJECT_COMPLETED_TB_INIT_SH_CREATE_SOFTLINK="---:${DOCKER__COMPLETED}: TB_INIT.SH > CREATE SOFT-LINK"

    DOCKER__INFOMSG_OVERLAYFS_SETTING_IS_DISABLED="${DOCKER__NINEDASHES_COLON}${DOCKER__INFO}: ${DOCKER__FG_LIGHTGREY}overlay${DOCKER__NOCOLOR} setting is disabled...\n"
    DOCKER__INFOMSG_OVERLAYFS_SETTING_IS_DISABLED+="${DOCKER__NINEDASHES_COLON}${DOCKER__INFO}: ignoring overlay..."
    DOCKER__INFOMSG_OVERLAYFS_PARTITION_IS_NOT_PRESENT="${DOCKER__NINEDASHES_COLON}${DOCKER__INFO}: partition ${DOCKER__FG_LIGHTGREY}overlay${DOCKER__NOCOLOR} is not present...\n"
    DOCKER__INFOMSG_OVERLAYFS_PARTITION_IS_NOT_PRESENT+="${DOCKER__NINEDASHES_COLON}${DOCKER__INFO}: ignoring overlay..."
    DOCKER__INFOMSG_PATTERN_ISP_C_1_MISSING="${DOCKER__NINEDASHES_COLON}${DOCKER__INFO}: pattern ${DOCKER__FG_LIGHTGREY}${DOCKER__PATTERN_ISP_C_1}${DOCKER__NOCOLOR}: ${DOCKER__STATUS_MISSING}"
    DOCKER__INFOMSG_PATTERN_ISP_C_2_MISSING="${DOCKER__NINEDASHES_COLON}${DOCKER__INFO}: pattern ${DOCKER__FG_LIGHTGREY}${DOCKER__PATTERN_ISP_C_2}${DOCKER__NOCOLOR}: ${DOCKER__STATUS_MISSING}"
    DOCKER__INFOMSG_PATTERN_ISP_C_3_MISSING="${DOCKER__NINEDASHES_COLON}${DOCKER__INFO}: pattern ${DOCKER__FG_LIGHTGREY}${DOCKER__PATTERN_ISP_C_3}${DOCKER__NOCOLOR}: ${DOCKER__STATUS_MISSING}"
    DOCKER__INFOMSG_PATTERN_ISP_C_2_OUTOFBOUND="${DOCKER__NINEDASHES_COLON}${DOCKER__INFO}: pattern ${DOCKER__FG_LIGHTGREY}${DOCKER__PATTERN_ISP_C_2}${DOCKER__NOCOLOR}: ${DOCKER__STATUS_OUTOFBOUND}"
    DOCKER__INFOMSG_PATTERN_PENTAGRAM_COMMON_H_MISSING="--${DOCKER__NINEDASHES_COLON}${DOCKER__INFO}: pattern ${DOCKER__FG_LIGHTGREY}${DOCKER__PATTERN_PENTAGRAM_COMMON_H}${DOCKER__NOCOLOR}: ${DOCKER__STATUS_MISSING}"

    DOCKER__ERRMSG_NO_IF_CONDITIONS_FOUND="${DOCKER__ERROR}: no if conditions found!"
    DOCKER__ERRMSG_ONE_OR_MORE_CHECKITEMS_FAILED="${DOCKER__ERROR}: one or more precheck items failed to pass!"
    DOCKER__ERRMSG_IGNORE_THESE_ERRORS_AND_BUILD_WITHOUT_OVERLAY="${DOCKER__ERROR}: *ignore* error -> build without overlay"
    DOCKER__ERRMSG_ONE_OR_MORE_ENTRIES_ARE_INVALID="${DOCKER__ERROR}: one or more entries are invalid!"
    DOCKER__ERRMSG_ONE_OR_MORE_FILES_COULD_NOT_BE_COPIED="${DOCKER__ERROR}: one or more files could NOT be copied!"
    DOCKER__ERRMSG_PATTERN_EMMC_NOT_FOUND="${DOCKER__ERROR}: pattern ${DOCKER__FG_LIGHTGREY}EMMC${DOCKER__NOCOLOR} not found!"
    DOCKER__ERRMSG_LINENUMEND_OF_EMMC_IS_ZERO="${DOCKER__ERROR}: ${DOCKER__FG_LIGHTGREY}linenumend${DOCKER__NOCOLOR} of ${DOCKER__FG_LIGHTGREY}EMMC${DOCKER__NOCOLOR} is zero (0)!"
    DOCKER__ERRMSG_PATTERN_ROOTFS_EX1E0000000_IS_OUT_OF_BOUND="${DOCKER__ERROR}: pattern ${DOCKER__FG_LIGHTGREY}rootfs 0x1e0000000${DOCKER__NOCOLOR} is out of bound!"
    DOCKER__ERRMSG_FILECONTENT_IS_NOT_CONSISTENT_OR_CORRUPT="${DOCKER__ERROR}: file-content is NOT consistent or corrupt!\n"
    DOCKER__ERRMSG_FILECONTENT_IS_NOT_CONSISTENT_OR_CORRUPT+="${DOCKER__ERROR}: please make sure the search pattern matches exactly as specified.\n"
    DOCKER__ERRMSG_FILECONTENT_IS_NOT_CONSISTENT_OR_CORRUPT+="${DOCKER__ERROR}: in other words, no extra spaces, strings, special characters."
    DOCKER__ERRMSG_COULD_NOT_CHANGE_FILE_PERMISSION_TO_RWXRXRX="${DOCKER__ERROR}: could NOT change file permission to rwxr-xr-x!"
    DOCKER__ERRMSG_COULD_NOT_CREATE_SOFTLINK="${DOCKER__ERROR}: could NOT create soft-link"

    # DOCKER__SIXDASHES_COLON="------:"

    DOCKER__EXEC="docker exec"
    DOCKER__EXEC_IT="docker exec -it"
}

docker__init_variables__sub() {
    docker__disksize_set=0
    docker__exitcode=0
    docker__fstab_output="${DOCKER__EMPTYSTRING}"
    docker__isRunning_inside_container=false
    docker__isp_c_overlaybck_isfound=true
    docker__isp_sh_overlaybck_isfound=true
    docker__pentagram_common_h_overlaybck_isfound=true
    docker__isp_partition_array=()
    docker__isp_partition_arraylen=0
    docker__isp_partition_name_last="${DOCKER__EMPTYSTRING}"
    docker__containerid="${DOCKER__EMPTYSTRING}"
    docker__numof_errors_found_ctr=0
    docker__overlay_isfound=false
    docker__overlaymode_set="${DOCKER__OVERLAYMODE_PERSISTENT}"
    docker__overlaysetting_set="${DOCKER__OVERLAYFS_DISABLED}"
    docker__showTable=true
    docker__swapfilesize=0
}

docker__checkif_isrunning_in_container__sub() {
    #Check if running inside a container
    docker__isRunning_inside_container=$(checkIf_isRunning_inside_container__func)
}

docker__choose_containerID__sub() {
    #Define local message constants
    local READMSG_CHOOSE_A_CONTAINERID="Choose a ${DOCKER__FG_BRIGHTPRUPLE}Container-ID${DOCKER__NOCOLOR} (e.g. dfc5e2f3f7ee): "
    local ERRMSG_INVALID_INPUT_VALUE="${DOCKER__ERROR}: Invalid input value "

    #Check if running inside Docker Container
    #If true, then exit subroutine right away.
    if [[ ${docker__isRunning_inside_container} == true ]]; then   #currently inside container
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
    docker__exitcode=$?
    if [[ ${docker__exitcode} -eq ${DOCKER__EXITCODE_99} ]]; then
        docker__containerid=${DOCKER__EMPTYSTRING}
    else
        #Get the result
        docker__containerid=`get_output_from_file__func "${docker__readInput_w_autocomplete_out__fpath}" "1"`
    fi
}

docker__preCheck__sub() {
    #Define variables
    local printmsg="${DOCKER__EMPTYSTRING}"

    #Reset variables
    docker__numof_errors_found_ctr=0

    #Print Tibbo-title
    load_tibbo_title__func "${DOCKER__NUMOFLINES_2}"

    #Print
    show_msg_only__func "${DOCKER__SUBJECT_MANDATORY_SOFTWARE_AND_FILES}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_0}"

    #Check if running inside docker container
    if [[ ${docker__isRunning_inside_container} == true ]]; then   #currently inside container
        printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: (${DOCKER__FG_LIGHTGREY}${DOCKER__LOCATION_LLOCAL}${DOCKER__NOCOLOR}) Inside Container: true"

        docker__numof_errors_found_ctr=0
    else    ##currently outside containerner
        printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: (${DOCKER__FG_LIGHTGREY}${DOCKER__LOCATION_LLOCAL}${DOCKER__NOCOLOR}) Inside Container: false"

        #Check if docker.io is installed
        #Output: docker__numof_errors_found_ctr
        docker__preCheck_app_isInstalled__sub "${DOCKER__PATTERN_DOCKER_IO}"

        #Check if '/usr/bin/bash' is present
        #Output: docker__numof_errors_found_ctr
        docker__preCheck_app_isPresent__sub "${docker__containerid}" "${docker__bash_fpath}"

        #Check if '~/SP7021/linux/rootfs/initramfs/disk' is present
        #Output: docker__numof_errors_found_ctr
        docker__preCheck_app_isPresent__sub "${docker__containerid}" "${docker__sp7021_dir}"

        #Check if '~/LTPP3_ROOTFS/development_tools/docker_build_ispboootbin.sh' is present
        #Output: docker__numof_errors_found_ctr
        docker__preCheck_app_isPresent__sub "${docker__containerid}" "${docker__docker__build_ispboootbin_fpath}"
    fi

    #Print
    show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

    #In case one or more failed check-items were found
    if [[ ${docker__numof_errors_found_ctr} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
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
        printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: ${appName__input}: ${DOCKER__STATUS_LINSTALLED}"
    else    #NOT running in docker container
        printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: ${appName__input}: ${DOCKER__STATUS_LNOTINSTALLED}"

        ((docker__numof_errors_found_ctr++))
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
        printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: ${path__input}: ${DOCKER__STATUS_LPRESENT}"
    else
        #Second: if not a directory, then check if it's a file
        isFound=`checkIf_file_exists__func "${containerid__input}" "${path__input}"`
        if [[ ${isFound} == true ]]; then
            printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: ${path__input}: ${DOCKER__STATUS_LPRESENT}"
        else
            printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: ${path__input}: ${DOCKER__STATUS_LNOTPRESENT}"

            ((docker__numof_errors_found_ctr++))
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
    local PHASE_OVERLAY_DST_EXEC_FILES_CHANGE_PERMISSION=60
    local PHASE_OVERLAY_TB_INIT_SOFTLINK_CREATE=70
    local PHASE_OVERLAY_RESTORE_ORG_FILES=80
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

                #Choose 'phase' based on 'docker__numof_errors_found_ctr'
                #Remarks:
                #   In case one or more files were not found, then:
                #   1. exit this subroutine
                #   2. build normally WITHOUT overlay
                if [[ ${docker__numof_errors_found_ctr} -gt 0 ]]; then  #errors were found
                    phase="${PHASE_OVERLAY_EXIT}"
                else    #NO errors found
                    phase="${PHASE_OVERLAY_DOCKER_FS_PARTITION_CONF_CHECK}"
                fi
                ;;
            "${PHASE_OVERLAY_DOCKER_FS_PARTITION_CONF_CHECK}")
                #Remark:
                #   'docker__overlaysetting_set' is retrieved in this subroutine
                docker__overlay_docker_fs_partition_conf_check_handler__sub

                #Check if 'docker__overlaysetting_set = DOCKER__OVERLAYFS_DISABLED'
                if [[ "${docker__overlaysetting_set}" == "${DOCKER__OVERLAYFS_DISABLED}" ]]; then   #is disabled
                    phase="${PHASE_OVERLAY_RESTORE_ORG_FILES}"
                else    #is NOT disabled
                    phase="${PHASE_OVERLAY_DOCKER_FS_PARTITION_DISKPARTSIZE_CHECK_AND_CONVERT}"
                fi
                ;;
            "${PHASE_OVERLAY_DOCKER_FS_PARTITION_DISKPARTSIZE_CHECK_AND_CONVERT}")
                #Remark:
                #   'docker__overlay_isfound' is set in this subroutine
                docker__overlay_docker_fs_partition_diskpartsize_check_and_convert_handler__sub

                if [[ ${docker__overlay_isfound} == false ]]; then
                    phase="${PHASE_OVERLAY_RESTORE_ORG_FILES}"
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
                docker__overlay_copy_files_from_tmp_to_dst_handler__sub

                phase="${PHASE_OVERLAY_DST_EXEC_FILES_CHANGE_PERMISSION}"
                ;;
            "${PHASE_OVERLAY_DST_EXEC_FILES_CHANGE_PERMISSION}")
                docker__overlay_dst_exec_files_change_permission_handler__sub

                phase="${PHASE_OVERLAY_TB_INIT_SOFTLINK_CREATE}"
                ;;
            "${PHASE_OVERLAY_TB_INIT_SOFTLINK_CREATE}")
                docker__overlay_tb_init_softlink_handler__sub

                phase="${PHASE_OVERLAY_EXIT}"
                ;;
            "${PHASE_OVERLAY_RESTORE_ORG_FILES}")
                docker__overlay_restore_original_state__sub

                phase="${PHASE_OVERLAY_EXIT}"
                ;;   
            "${PHASE_OVERLAY_EXIT}")
                break
                ;;
        esac
    done
}

docker__overlay_files_check_handler__sub() {
    #Print
    show_msg_only__func "${DOCKER__SUBJECT_OVERLAY_RELATED_FILES}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_0}"

    #Initialize variables
    docker__numof_errors_found_ctr=0
    docker__fstab_isfound=true
    docker__isp_c_overlaybck_isfound=true
    docker__isp_sh_overlaybck_isfound=true
    docker__pentagram_common_h_overlaybck_isfound=true

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
    docker__overlay_checkif_file_ispresent__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__LTPP3_ROOTFS_linux_scripts_tb_init_bootmenu__fpath}" "false"
    docker__overlay_checkif_file_ispresent__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__LTPP3_ROOTFS_motd_update_motd_96_overlayboot_notice__fpath}" "false"
    docker__overlay_checkif_file_ispresent__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__LTPP3_ROOTFS_motd_update_motd_98_normalboot_notice__fpath}" "false"

    docker__overlay_checkif_file_ispresent__sub "${docker__containerid}" \
            "${docker__SP7021_linux_rootfs_initramfs_disk_etc_fstab_overlaybck__fpath}" "true"
    docker__overlay_checkif_file_ispresent__sub "${docker__containerid}" \
            "${docker__SP7021_build_tools_isp_isp_c_overlaybck__fpath}" "true"
    docker__overlay_checkif_file_ispresent__sub "${docker__containerid}" \
            "${docker__SP7021_build_isp_sh_overlaybck__fpath}" "true"
    docker__overlay_checkif_file_ispresent__sub "${docker__containerid}" \
            "${docker__SP7021_boot_uboot_include_configs_pentagram_common_h_overlaybck__fpath}" "true"

    #Incase file '~/SP7021/linux/rootfs/initramfs/disk/etc/fstab.overlaybck' was NOT found in the container
    if [[ ${docker__fstab_isfound} == false ]]; then
        #Make a copy of file '~/SP7021/linux/rootfs/initramfs/disk/etc/fstab' and copy it as '~/SP7021/linux/rootfs/initramfs/disk/etc/fstab.overlaybck.overlaybck' (same location in the container)
        docker__overlay_copy_file__sub "${docker__containerid}" \
                "${docker__SP7021_linux_rootfs_initramfs_disk_etc_fstab__fpath}" \
                "${docker__containerid}" \
                "${docker__SP7021_linux_rootfs_initramfs_disk_etc_fstab_overlaybck__fpath}"
                
        docker__overlay_checkif_file_ispresent__sub "${docker__containerid}" \
                "${docker__SP7021_linux_rootfs_initramfs_disk_etc_fstab_overlaybck__fpath}" "false"
    fi

    #Incase file '~/SP7021/build/tools/isp/isp.c.overlaybck' was NOT found in the container
    if [[ ${docker__isp_c_overlaybck_isfound} == false ]]; then
        #Make a copy of file '~/SP7021/build/tools/isp/isp.c' and copy it as '~/SP7021/build/tools/isp/isp.c.overlaybck' (same location in the container)
        docker__overlay_copy_file__sub "${docker__containerid}" \
                "${docker__SP7021_build_tools_isp_isp_c__fpath}" \
                "${docker__containerid}" \
                "${docker__SP7021_build_tools_isp_isp_c_overlaybck__fpath}"
                
        docker__overlay_checkif_file_ispresent__sub "${docker__containerid}" \
                "${docker__SP7021_build_tools_isp_isp_c_overlaybck__fpath}" "false"
    fi

    #Incase file '~/SP7021/build/tools/isp/isp.c.overlaybck' was NOT found in the container
    if [[ ${docker__isp_sh_overlaybck_isfound} == false ]]; then
        #Make a copy of file '~/SP7021/build/tools/isp/isp.c' and copy it as '~/SP7021/build/tools/isp/isp.c.overlaybck' (same location in the container)
        docker__overlay_copy_file__sub "${docker__containerid}" \
                "${docker__SP7021_build_isp_sh__fpath}" \
                "${docker__containerid}" \
                "${docker__SP7021_build_isp_sh_overlaybck__fpath}"
                
        docker__overlay_checkif_file_ispresent__sub "${docker__containerid}" \
                "${docker__SP7021_build_isp_sh_overlaybck__fpath}" "false"
    fi

    #Incase file '~/SP7021/build/tools/isp/isp.c.overlaybck' was NOT found in the container
    if [[ ${docker__pentagram_common_h_overlaybck_isfound} == false ]]; then
        #Make a copy of file '~/SP7021/build/tools/isp/isp.c' and copy it as '~/SP7021/build/tools/isp/isp.c.overlaybck' (same location in the container)
        docker__overlay_copy_file__sub "${docker__containerid}" \
                "${docker__SP7021_boot_uboot_include_configs_pentagram_common_h__fpath}" \
                "${docker__containerid}" \
                "${docker__SP7021_boot_uboot_include_configs_pentagram_common_h_overlaybck__fpath}"
                
        docker__overlay_checkif_file_ispresent__sub "${docker__containerid}" \
                "${docker__SP7021_build_tools_isp_isp_c_overlaybck__fpath}" "false"
    fi

    #Show error message and exit (if applicable)
    if [[ ${docker__numof_errors_found_ctr} -gt 0 ]]; then
        # show_errMsg_wo_menuTitle_and_exit_func "${DOCKER__ERRMSG_ONE_OR_MORE_CHECKITEMS_FAILED}" \
        #         ${DOCKER__NUMOFLINES_1} \
        #         ${DOCKER__NUMOFLINES_0}
        show_msg_only__func "${DOCKER__ERRMSG_ONE_OR_MORE_CHECKITEMS_FAILED}" \
                        ${DOCKER__NUMOFLINES_1} \
                        ${DOCKER__NUMOFLINES_0}
        show_msg_only__func "${DOCKER__ERRMSG_IGNORE_THESE_ERRORS_AND_BUILD_WITHOUT_OVERLAY}" \
                        ${DOCKER__NUMOFLINES_0} \
                        ${DOCKER__NUMOFLINES_0}
    fi
}
docker__overlay_checkif_file_ispresent__sub() {
    #Remark:
    # This subroutine passes the result(s) to the following global variable(s):
    #       docker__isp_c_overlaybck_isfound (bool)
    #       docker__numof_errors_found_ctr (integer)
    #Input args
    local containerid__input=${1}
    local path__input=${2}

    #Update 'printmsg'
    local printmsg="${DOCKER__EMPTYSTRING}"
    if [[ -z "${containerid__input}" ]]; then
        printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: (${DOCKER__FG_LIGHTGREY}${DOCKER__LOCATION_LLOCAL}${DOCKER__NOCOLOR})"
    else
        printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: (${DOCKER__FG_LIGHTGREY}${containerid__input}${DOCKER__NOCOLOR})"
    fi

    #Check if 'path__input' exists and update 'printmsg'
    if [[ $(checkIf_file_exists__func "${containerid__input}" \
            "${path__input}") == true ]]; then  #file is exists
        printmsg+=" ${path__input}: ${DOCKER__STATUS_LPRESENT}"
    else    #file does not exist
        #Check if 'path__input = '~/SP7021/build/tools/isp/isp.c.overlaybck'
        case "${path__input}" in
            "${docker__SP7021_linux_rootfs_initramfs_disk_etc_fstab_overlaybck__fpath}")
                docker__fstab_isfound=false

                printmsg+=" ${path__input}: ${DOCKER__STATUS_LNOTPRESENT_IGNORE}"
                ;;
            "${docker__SP7021_build_tools_isp_isp_c_overlaybck__fpath}")
                docker__isp_c_overlaybck_isfound=false

                printmsg+=" ${path__input}: ${DOCKER__STATUS_LNOTPRESENT_IGNORE}"
                ;;
            "${docker__SP7021_build_isp_sh_overlaybck__fpath}")
                docker__isp_sh_overlaybck_isfound=false

                printmsg+=" ${path__input}: ${DOCKER__STATUS_LNOTPRESENT_IGNORE}"
                ;;
            "${docker__SP7021_boot_uboot_include_configs_pentagram_common_h_overlaybck__fpath}")
                docker__pentagram_common_h_overlaybck_isfound=false

                printmsg+=" ${path__input}: ${DOCKER__STATUS_LNOTPRESENT_IGNORE}"
                ;;
            *)
                printmsg+=" ${path__input}: ${DOCKER__STATUS_LNOTPRESENT}"

                ((docker__numof_errors_found_ctr++))
                ;;       
        esac
    fi

    #Print
    show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
}

docker__overlay_docker_fs_partition_conf_check_handler__sub() {
    #Remark:
    # This subroutine passes the result(s) to the following global variable(s):
    #       docker__numof_errors_found_ctr (integer)

    #Reset variables
    docker__numof_errors_found_ctr=0

    #Print
    show_msg_only__func "${DOCKER__SUBJECT_DOCKER_FS_PARTITION_CONF_FILECONTENT}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_0}"

    #Validate the content of 'docker_fs_partition.conf'
    #1. 'docker__disksize_set' is set or retrieved in subroutine 'docker__overlay_disksizeset_check__sub'
    docker__overlay_disksizeset_check__sub
    
    #2. 'docker__overlaymode_set' is set or retrieved in subroutine 'docker__overlay_overlaymode_check__sub'
    docker__overlay_overlaymode_check__sub
    
    #3. 'docker__overlaysetting_set' is set or retrieved in subroutine 'docker__overlay_overlaysetting_check__sub'
    docker__overlay_overlaysetting_check__sub

    #Before showing any errors and exit...
    #FIRST of ALL, check if 'docker__overlaysetting_set = DISABLED'.
    #If true, then exit this subroutine.
    if [[ "${docker__overlaysetting_set}" == "${DOCKER__OVERLAYFS_DISABLED}" ]]; then
        return 0;
    fi

    #docker__overlaysetting_set = DOCKER__OVERLAYFS_ENABLED.
    #Check if 'docker__numof_errors_found_ctr > 0'. 
    #If true, then errors were found previously in one or all of the 3 subroutines:
    #   docker__overlay_disksizeset_check__sub
    #   docker__overlay_overlaymode_check__sub
    #   docker__overlay_overlaysetting_check__sub
    #In this case, show error-message and exit script.
    if [[ ${docker__numof_errors_found_ctr} -gt 0 ]]; then
        show_errMsg_wo_menuTitle_and_exit_func "${DOCKER__ERRMSG_ONE_OR_MORE_ENTRIES_ARE_INVALID}" \
                ${DOCKER__NUMOFLINES_1} \
                ${DOCKER__NUMOFLINES_0}
    fi
}
docker__overlay_disksizeset_check__sub() {
    #Remark:
    # This subroutine passes the result(s) to the following global variable(s):
    #       docker__numof_errors_found_ctr (integer)

    #Define variables
    local printmsg="${DOCKER__EMPTYSTRING}"

    #Initialize variables
    docker__disksize_set=0

    #Get data from file
    docker__disksize_set=$(retrieve_string_based_on_specified_pattern_colnum_delimiterchar_from_file__func \
            "${docker__docker_fs_partition_conf__fpath}" \
            "${DOCKER__DISKSIZESETTING}" \
            "${DOCKER__COLNUM_2}" \
            "${DOCKER__ONESPACE}")

    #Update 'printmsg'
    printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: ${DOCKER__DISKSIZESETTING}: ${DOCKER__FG_LIGHTGREY}${docker__disksize_set}${DOCKER__NOCOLOR} " 
    if [[ $(isNumeric__func "${docker__disksize_set}") == false ]]; then  #is not numeric
        printmsg+="(${DOCKER__STATUS_LINVALID})"

        ((docker__numof_errors_found_ctr++))
    else    #is numeric
        if [[ ${docker__disksize_set} -le 0 ]]; then  #less or equal to 0
            printmsg+="(${DOCKER__STATUS_LINVALID})"

            ((docker__numof_errors_found_ctr++))
        else    #greater than 0
            printmsg+="(${DOCKER__STATUS_LVALID})"
        fi
    fi

    #Print
    show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
}
docker__overlay_overlaymode_check__sub() {
    #Remark:
    # This subroutine passes the result(s) to the following global variable(s):
    #       docker__numof_errors_found_ctr (integer)

    #Define variables
    local printmsg="${DOCKER__EMPTYSTRING}"

    #Initialize variables
    docker__overlaymode_set="${DOCKER__OVERLAYMODE_PERSISTENT}"

    #Get data from file
    docker__overlaymode_set=$(retrieve_string_based_on_specified_pattern_colnum_delimiterchar_from_file__func \
            "${docker__docker_fs_partition_conf__fpath}" \
            "${DOCKER__OVERLAYMODE}" \
            "${DOCKER__COLNUM_2}" \
            "${DOCKER__ONESPACE}")

    #Update 'printmsg'
    printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: ${DOCKER__OVERLAYMODE}: ${DOCKER__FG_LIGHTGREY}${docker__overlaymode_set}${DOCKER__NOCOLOR} " 
    if [[ "${docker__overlaymode_set}" != "${DOCKER__OVERLAYMODE_PERSISTENT}" ]] && \
            [[ "${docker__overlaymode_set}" != "${DOCKER__OVERLAYMODE_NONPERSISTENT}" ]]; then
        printmsg+="(${DOCKER__STATUS_LINVALID})"

        ((docker__numof_errors_found_ctr++))
    else
        printmsg+="(${DOCKER__STATUS_LVALID})"
    fi

    #Print
    show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
}
docker__overlay_overlaysetting_check__sub() {
    #Remark:
    # This subroutine passes the result(s) to the following global variable(s):
    #       docker__numof_errors_found_ctr (integer)

    #Define variables
    local printmsg="${DOCKER__EMPTYSTRING}"

    #Initialize variables
    docker__overlaysetting_set="${DOCKER__OVERLAYFS_DISABLED}"

    #Get data from file
    docker__overlaysetting_set=$(retrieve_string_based_on_specified_pattern_colnum_delimiterchar_from_file__func \
            "${docker__docker_fs_partition_conf__fpath}" \
            "${DOCKER__OVERLAYSETTING}" \
            "${DOCKER__COLNUM_2}" \
            "${DOCKER__ONESPACE}")

    #Update 'printmsg'
    printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: ${DOCKER__OVERLAYSETTING}: ${DOCKER__FG_LIGHTGREY}${docker__overlaysetting_set}${DOCKER__NOCOLOR} " 
    if [[ "${docker__overlaysetting_set}" != "${DOCKER__OVERLAYFS_ENABLED}" ]] && \
            [[ "${docker__overlaysetting_set}" != "${DOCKER__OVERLAYFS_DISABLED}" ]]; then
        printmsg+="(${DOCKER__STATUS_LINVALID})"

        ((docker__numof_errors_found_ctr++))
    else
        printmsg+="(${DOCKER__STATUS_LVALID})"
    fi

    #Print
    show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

    #In case 'docker__overlaysetting_set = disabled', show message and exit this subroutine
    #Remark:
    #   Counter 'docker__numof_errors_found_ctr' is NOT incremented here, because
    #       even if 'docker__overlaysetting_set = DOCKER__OVERLAYFS_DISABLED', we
    #       still should be able to build w/o overlay.
    if [[ "${docker__overlaysetting_set}" == "${DOCKER__OVERLAYFS_DISABLED}" ]]; then
        show_msg_only__func "${DOCKER__INFOMSG_OVERLAYFS_SETTING_IS_DISABLED}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
    fi
}

docker__overlay_docker_fs_partition_diskpartsize_check_and_convert_handler__sub() {
    #Reset variables
    docker__numof_errors_found_ctr=0

    #Print
    show_msg_only__func "${DOCKER__SUBJECT_DOCKER_FS_PARTITION_DISKPARTSIZE_DAT_FILECONTENT}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_0}"

    #Validate the content of 'docker_fs_partition_diskpartsize.dat'
    docker__overlay_diskpartsize_check_and_convert__sub

    #Show error message and exit (if applicable)
    if [[ ${docker__numof_errors_found_ctr} -gt 0 ]]; then
        show_errMsg_wo_menuTitle_and_exit_func "${DOCKER__ERRMSG_ONE_OR_MORE_ENTRIES_ARE_INVALID}" \
                ${DOCKER__NUMOFLINES_1} \
                ${DOCKER__NUMOFLINES_0}
    fi
}
docker__overlay_diskpartsize_check_and_convert__sub() {
    #Define variables
    local diskpartname="${DOCKER__EMPTYSTRING}"
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
        printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: ${diskpartname}: ${DOCKER__FG_LIGHTGREY}${diskpartsize_M}${DOCKER__NOCOLOR} " 

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

            ((docker__numof_errors_found_ctr++))
        else    #is numeric
            if [[ ${diskpartsize_M} -le 0 ]] && [[ "${diskpartname}" != "${DOCKER__DISKPARTNAME_REMAINING}" ]]; then  #less or equal to 0
                printmsg+="(${DOCKER__STATUS_LINVALID})"

                ((docker__numof_errors_found_ctr++))
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

    #Get the last partition name
    docker__isp_partition_name_last=$(echo ${docker__isp_partition_array[i]} | cut -d"${DOCKER__ONESPACE}" -f1)

    #Check if 'remaining_diskpartsize_M = 0'.
    #If true, then for the LAST 'diskpartname' set 'dispartsize_H = 0x1e0000000'.
    if [[ ${remaining_diskpartsize_M} -eq 0 ]]; then
        docker__isp_partition_array[i]="${docker__isp_partition_name_last} ${DOCKER__DISKSIZE_0X1E0000000}"
    fi


    #Check if 'overlay' is configured
    #Remark:
    #   If 'overlay' partition is NOT present, then exit this subroutine immediately.
    #   This is equivalent to 'docker__overlaysetting_set = disabled'
    if [[ ${docker__overlay_isfound} == false ]]; then
        #Reset array related variables
        docker__isp_partition_array=()
        docker__isp_partition_arraylen=0

        #Update 'printmsg'
        printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: ${DOCKER__DISKPARTNAME_OVERLAY}: ${DOCKER__FG_LIGHTGREY}${DOCKER__DASH}${DOCKER__NOCOLOR} "
        printmsg+="(${DOCKER__STATUS_LINVALID})"
        #Print
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        #Print
        show_msg_only__func "${DOCKER__INFOMSG_OVERLAYFS_PARTITION_IS_NOT_PRESENT}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        return 0;
    fi

    #Check if 'rootfs' partition is configured
    if [[ ${rootfs_isfound} == false ]]; then
        printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: (${DOCKER__FG_LIGHTGREY}${DOCKER__LOCATION_LLOCAL}${DOCKER__NOCOLOR}) " 
        printmsg+="${DOCKER__FG_LIGHTGREY}...${DOCKER__NOCOLOR}/${docker__docker_fs_partition_conf__filename} "
        printmsg+="(${DOCKER__FG_YELLOW}${DOCKER__DISKPARTNAME_ROOTFS}${DOCKER__NOCOLOR} "
        printmsg+="${DOCKER__FG_LIGHTRED}not${DOCKER__NOCOLOR} present)"

        #Print
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        ((docker__numof_errors_found_ctr++))
    fi

    #Check if 'tb_reserve' partition is configured
    if [[ ${tb_reserve_isfound} == false ]]; then
        printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: (${DOCKER__FG_LIGHTGREY}${DOCKER__LOCATION_LLOCAL}${DOCKER__NOCOLOR}) " 
        printmsg+="${DOCKER__FG_LIGHTGREY}...${DOCKER__NOCOLOR}/${docker__docker_fs_partition_conf__filename} "
        printmsg+="(${DOCKER__FG_YELLOW}${DOCKER__DISKPARTNAME_TB_RESERVE}${DOCKER__NOCOLOR} "
        printmsg+="${DOCKER__FG_LIGHTRED}not${DOCKER__NOCOLOR} present)"

        #Print
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        ((docker__numof_errors_found_ctr++))
    fi

    #Check if 'tb_reserve' partition is configured
    if [[ ${remaining_isfound} == false ]]; then
        printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: (${DOCKER__FG_LIGHTGREY}${DOCKER__LOCATION_LLOCAL}${DOCKER__NOCOLOR}) " 
        printmsg+="${DOCKER__FG_LIGHTGREY}...${DOCKER__NOCOLOR}/${docker__docker_fs_partition_conf__filename} "
        printmsg+="(${DOCKER__FG_YELLOW}${DOCKER__DISKPARTNAME_REMAINING}${DOCKER__NOCOLOR} "
        printmsg+="${DOCKER__FG_LIGHTRED}not${DOCKER__NOCOLOR} present)"

        #Print
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        ((docker__numof_errors_found_ctr++))
    fi
}

docker__overlay_copy_files_from_src_to_tmp_handler__sub() {
    #Reset variables
    docker__numof_errors_found_ctr=0

    #Print
    show_msg_only__func "${DOCKER__SUBJECT_START_COPY_FILES_FROM_SRC_TO_TMP_LOCATION}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_0}"

    #Copy files
    docker__overlay_copy_file__sub "${docker__containerid}" \
            "${docker__SP7021_linux_rootfs_initramfs_disk_etc_fstab_overlaybck__fpath}" \
            "${DOCKER__EMPTYSTRING}" \
            "${docker__docker_overlayfs_fstab__fpath}"

    docker__overlay_copy_file__sub "${docker__containerid}" \
            "${docker__SP7021_build_tools_isp_isp_c_overlaybck__fpath}" \
            "${DOCKER__EMPTYSTRING}" \
            "${docker__docker_overlayfs_isp_c__fpath}"

    docker__overlay_copy_file__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__LTPP3_ROOTFS_build_scripts_isp_sh__fpath}" \
            "${DOCKER__EMPTYSTRING}" \
            "${docker__docker_overlayfs_isp_sh__fpath}"

    docker__overlay_copy_file__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__LTPP3_ROOTFS_boot_configs_pentagram_common_h__fpath}" \
            "${DOCKER__EMPTYSTRING}" \
            "${docker__docker_overlayfs_pentagram_common_h__fpath}"

    docker__overlay_copy_file__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__LTPP3_ROOTFS_linux_scripts_tb_init_sh__fpath}" \
            "${DOCKER__EMPTYSTRING}" \
            "${docker__docker_overlayfs_tb_init_sh__fpath}"

    docker__overlay_copy_file__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__LTPP3_ROOTFS_linux_scripts_tb_init_bootmenu__fpath}" \
            "${DOCKER__EMPTYSTRING}" \
            "${docker__docker_overlayfs_tb_init_bootmenu__fpath}"

    docker__overlay_copy_file__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__LTPP3_ROOTFS_motd_update_motd_96_overlayboot_notice__fpath}" \
            "${DOCKER__EMPTYSTRING}" \
            "${docker__docker_overlayfs_96_overlayboot_notice__fpath}"
    docker__overlay_copy_file__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__LTPP3_ROOTFS_motd_update_motd_98_normalboot_notice__fpath}" \
            "${DOCKER__EMPTYSTRING}" \
            "${docker__docker_overlayfs_98_normalboot_notice__fpath}"

    #Show error message and exit (if applicable)
    if [[ ${docker__numof_errors_found_ctr} -gt 0 ]]; then
        show_errMsg_wo_menuTitle_and_exit_func "${DOCKER__ERRMSG_ONE_OR_MORE_CHECKITEMS_FAILED}" \
                ${DOCKER__NUMOFLINES_1} \
                ${DOCKER__NUMOFLINES_0}
    fi

    #Print
    show_msg_only__func "${DOCKER__SUBJECT_COMPLETED_COPY_FILES}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
}
docker__overlay_copy_file__sub() {
    #Remark:
    #   This subroutine implicitely outputs the variable:
    #       docker__numof_errors_found_ctr (integer)
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
    local dstfilename=$(basename ${dstfpath__input})
    local dstdir=$(dirname ${dstfpath__input})
    local printmsg="${DOCKER__EMPTYSTRING}"

    #Remove destination file
    remove_file__func "${dst_cid__input}" "${dstfpath__input}" "${DOCKER__SIXDASHES_COLON}"

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
    printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: copy file ${DOCKER__FG_LIGHTGREY}${srcfilename}${DOCKER__NOCOLOR}: "
    if [[ ${exitcode} -eq 0 ]]; then
        printmsg+="${DOCKER__STATUS_SUCCESSFUL}\n"
    else
        printmsg="${DOCKER__STATUS_FAILED}\n"

        ((docker__numof_errors_found_ctr++))
    fi

    #Update 'printmsg' with 'as'
    printmsg+="${DOCKER__SIXDASHES_COLON}${DOCKER__AS}: "
    printmsg+="${DOCKER__FG_LIGHTGREY}${dstfilename}${DOCKER__NOCOLOR}\n"

    #Update 'printmsg' with 'from'
    printmsg+="${DOCKER__SIXDASHES_COLON}${DOCKER__FROM} "
    if [[ -z "${src_cid__input}" ]]; then
        printmsg+="(${DOCKER__FG_LIGHTGREY}${DOCKER__LOCATION_LLOCAL}${DOCKER__NOCOLOR}): "
    else
        printmsg+="(${DOCKER__FG_LIGHTGREY}${src_cid__input}${DOCKER__NOCOLOR}): "
    fi
    printmsg+="${DOCKER__FG_LIGHTGREY}${srcdir}${DOCKER__NOCOLOR}\n"

    #Update 'printmsg' with 'to'
    printmsg+="${DOCKER__SIXDASHES_COLON}${DOCKER__TO} "
    if [[ -z "${dst_cid__input}" ]]; then
        printmsg+="(${DOCKER__FG_LIGHTGREY}${DOCKER__LOCATION_LLOCAL}${DOCKER__NOCOLOR}): "
    else
        printmsg+="(${DOCKER__FG_LIGHTGREY}${dst_cid__input}${DOCKER__NOCOLOR}): "
    fi
    printmsg+="${DOCKER__FG_LIGHTGREY}${dstdir}${DOCKER__NOCOLOR}"

    #Print
    show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
}

docker__overlay_tempfiles_patch_handler__sub() {
    #Reset variables
    docker__numof_errors_found_ctr=0

    #Print
    show_msg_only__func "${DOCKER__SUBJECT_START_PATCH_OVERLAY_TEMPFILES}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_0}"

    #Prepare the temporary files
    docker__overlay_tempfile_isp_sh_patch__sub
    docker__overlay_tempfile_isp_c_patch__sub
    docker__overlay_tempfile_pentagram_common_h_patch__sub
    docker__overlay_tempfile_tb_init_sh_and_fstab_patch__sub

    #Show error message and exit (if applicable)
    if [[ ${docker__numof_errors_found_ctr} -gt 0 ]]; then
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
    printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: patch ${DOCKER__FG_LIGHTGREY}${docker__docker_overlayfs_isp_sh__fpath}: " 

    #Get the 'linenum' of each 'if' and 'elif' condition
    #   if [[ ... ]]; then      <--+    linenum_1
    #                              |
    #   elif [[ ... ]]; then    <--+    linenum_2
    #                              |
    #   elif [[ ... ]]; then    <--+    linenum_3
    #   ..
    #   etc.
    readarray -t if_linenum_arr < <(retrieve_linenum_based_on_specified_pattern_colnum_delimiterchar_from_file__func \
            "${docker__docker_overlayfs_isp_sh__fpath}" \
            "${DOCKER__PATTERN_IF}" \
            "${DOCKER__COLNUM_1}" \
            "${DOCKER__COLON}")

    #Calculate array-length
    if_linenum_arrlen=${#if_linenum_arr[@]}
    #Check if 'if_linenum_arrlen = 0'
    if [[ ${if_linenum_arrlen} -eq 0 ]]; then
        #Increment index
        ((docker__numof_errors_found_ctr++))

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
    emmc_linenum=$(retrieve_linenum_based_on_specified_pattern_colnum_delimiterchar_from_file__func \
            "${docker__docker_overlayfs_isp_sh__fpath}" \
            "${DOCKER__PATTERN_EMMC}" \
            "${DOCKER__COLNUM_1}" \
            "${DOCKER__COLON}")

    #Check if 'emmc_linenum = 0'
    if [[ ${emmc_linenum} -eq 0 ]]; then
        #Increment index
        ((docker__numof_errors_found_ctr++))

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
        ((docker__numof_errors_found_ctr++))

        #Update 'printmsg'
        printmsg+="${DOCKER__STATUS_FAILED}\n"
        printmsg+="\n${DOCKER__ERRMSG_LINENUMEND_OF_EMMC_IS_ZERO}"
        
        #Print
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        #Move-up 1 line to compensate for when 'show_errMsg_wo_menuTitle_and_exit_func' is executed
        moveUp__func "${DOCKER__NUMOFLINES_1}"

        return 0;
    fi

    #Find and get line containing pattern 'rootfs 0x1e0000000'
    linenum_containing_rootfs_0x1e0000000=$(retrieve_linenum_based_on_specified_pattern_colnum_delimiterchar_from_file__func \
            "${docker__docker_overlayfs_isp_sh__fpath}" \
            "${DOCKER__PATTERN_ROOTFS_0X1E0000000}" \
            "${DOCKER__COLNUM_1}" \
            "${DOCKER__COLON}")

    #Check if 'linenum_containing_rootfs_0x1e0000000 is within the boundary'
    if [[ ${linenum_containing_rootfs_0x1e0000000} -lt ${emmc_linenumstart} ]] || \
            [[ ${linenum_containing_rootfs_0x1e0000000} -gt ${emmc_linenumend} ]]; then
        #Increment index
        ((docker__numof_errors_found_ctr++))

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
    replace_or_append_string_based_on_pattern_in_file__func "${partitions_for_isp}" \
            "${DOCKER__PATTERN_ROOTFS_0X1E0000000}" \
            "${docker__docker_overlayfs_isp_sh__fpath}" \
            "${DOCKER__FALSE}"
    
    #Check exit-code
    docker__exitcode=$?
    if [[ ${docker__exitcode} -ne 0 ]]; then #error found
        #Increment index
        ((docker__numof_errors_found_ctr++))

        #Update 'printmsg'
        printmsg+="${DOCKER__STATUS_FAILED}"
    else
        printmsg+="${DOCKER__STATUS_SUCCESSFUL}"
    fi
    
    #Print
    show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
}
docker__overlay_tempfile_isp_c_patch__sub() {
    #Define variables
    local linenum_pattern1=0
    local linenum_pattern2=0
    local linenum_pattern3=0
    local sed_oldstring="${DOCKER__EMPTYSTRING}"
    local sed_newstring="${DOCKER__EMPTYSTRING}"

    #Start generating 'printmsg'
    printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: patch ${DOCKER__FG_LIGHTGREY}${docker__docker_overlayfs_isp_c__fpath}: " 

    #Find and get linenum of pattern-parameter 'DOCKER__PATTERN_ISP_C_1'
    linenum_pattern1=$(retrieve_linenum_based_on_specified_pattern_colnum_delimiterchar_from_file__func \
            "${docker__docker_overlayfs_isp_c__fpath}" \
            "${DOCKER__PATTERN_ISP_C_1}" \
            "${DOCKER__COLNUM_1}" \
            "${DOCKER__COLON}")
    if [[ ${linenum_pattern1} -eq 0 ]]; then
        #Increment index
        ((docker__numof_errors_found_ctr++))

        #Update 'printmsg'
        printmsg+="${DOCKER__STATUS_FAILED}\n"
        printmsg+="${DOCKER__INFOMSG_PATTERN_ISP_C_1_MISSING}"

        #Print
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        return 0;
    fi

    #Find and get linenum of pattern-parameter 'DOCKER__PATTERN_ISP_C_2'
    linenum_pattern2=$(retrieve_linenum_based_on_specified_pattern_colnum_delimiterchar_from_file__func \
            "${docker__docker_overlayfs_isp_c__fpath}" \
            "${DOCKER__PATTERN_ISP_C_2}" "${DOCKER__COLNUM_1}" "${DOCKER__COLON}")
    if [[ ${linenum_pattern2} -eq 0 ]]; then
        #Increment index
        ((docker__numof_errors_found_ctr++))

        #Update 'printmsg'
        printmsg+="${DOCKER__STATUS_FAILED}\n"
        printmsg+="${DOCKER__INFOMSG_PATTERN_ISP_C_2_MISSING}"

        #Print
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        return 0;
    fi

    #Find and get linenum of pattern-parameter 'DOCKER__PATTERN_ISP_C_3'
    linenum_pattern3=$(retrieve_linenum_based_on_specified_pattern_colnum_delimiterchar_from_file__func \
            "${docker__docker_overlayfs_isp_c__fpath}" \
            "${DOCKER__PATTERN_ISP_C_3}" "${DOCKER__COLNUM_1}" "${DOCKER__COLON}")
    if [[ ${linenum_pattern3} -eq 0 ]]; then
        #Increment index
        ((docker__numof_errors_found_ctr++))

        #Update 'printmsg'
        printmsg+="${DOCKER__STATUS_FAILED}\n"
        printmsg+="${DOCKER__INFOMSG_PATTERN_ISP_C_3_MISSING}"

        #Print
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        return 0;
    fi

    #CHeck if 'linenum_pattern2 < linenum_pattern1 OR  linenum_pattern2 > linenum_pattern3
    if [[ ${linenum_pattern2} -lt ${linenum_pattern1} ]] || \
            [[ ${linenum_pattern2} -gt ${linenum_pattern3} ]]; then
        #Increment index
        ((docker__numof_errors_found_ctr++))

        #Update 'printmsg'
        printmsg+="${DOCKER__STATUS_FAILED}\n"
        printmsg+="${DOCKER__INFOMSG_PATTERN_ISP_C_2_OUTOFBOUND}"

        #Print
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        return 0;
    fi

    #Update 'sed_oldstring'
    sed_oldstring="${DOCKER__SED_PATTERN_ISP_C_2_W_ROOTFS}"

    #Update 'sed_newstring'
    sed_newstring="${DOCKER__SED_PATTERN_ISP_C_2_WO_ROOTFS},\\\"${docker__isp_partition_name_last}\\\""

    #Patch 'docker__docker_overlayfs_isp_c__fpath'
    replace_string_with_another_string_in_file__func "${sed_oldstring}" \
            "${sed_newstring}" \
            "${docker__docker_overlayfs_isp_c__fpath}"

    #Check exit-code ($?)
    if [[ "$?" -ne 0 ]]; then
        #Increment index
        ((docker__numof_errors_found_ctr++))

        #Update 'printmsg'
        printmsg+="${DOCKER__STATUS_FAILED}"
    else
        printmsg+="${DOCKER__STATUS_SUCCESSFUL}"
    fi
    
    #Print
    show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
}
docker__overlay_tempfile_pentagram_common_h_patch__sub() {
    #Define variables
    local linenum_pattern=0
    local printmsg="${DOCKER__EMPTYSTRING}"
    local sed_oldstring="${DOCKER__EMPTYSTRING}"
    local sed_newstring="${DOCKER__EMPTYSTRING}"

    #Start generating 'printmsg'
    printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: patch ${DOCKER__FG_LIGHTGREY}${docker__docker_overlayfs_pentagram_common_h__fpath}: " 

    #Find and get linenum of pattern-parameter 'DOCKER__PATTERN_ISP_C_3'
    linenum_pattern=$(retrieve_linenum_based_on_specified_pattern_colnum_delimiterchar_from_file__func \
            "${docker__docker_overlayfs_pentagram_common_h__fpath}" \
            "${DOCKER__PATTERN_PENTAGRAM_COMMON_H}" "${DOCKER__COLNUM_1}" "${DOCKER__COLON}")

    if [[ ${linenum_pattern} -eq 0 ]]; then
        #Increment index
        ((docker__numof_errors_found_ctr++))

        #Update 'printmsg'
        printmsg+="${DOCKER__STATUS_FAILED}\n"
        printmsg+="${DOCKER__INFOMSG_PATTERN_PENTAGRAM_COMMON_H_MISSING}"

        #Print
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        return 0;
    fi

    #Update 'sed_oldstring'
    sed_oldstring="${DOCKER__SED_PATTERN_PENTAGRAM_COMMON_H_W_BACKSLASH0}"

    #Update 'sed_newstring' by appending 'tb_overlay' (this is a MUST!!!)
    sed_newstring="${DOCKER__SED_PATTERN_PENTAGRAM_COMMON_H_WO_BACKSLASH0} ${DOCKER__SED_TB_OVERLAY_DEV_MMCBLK0P10}"

    #Update 'sed_newstring' by appending 'tb_rootfs_ro' (only if 'docker__overlaymode_set = non-persistent')
    if [[ "${docker__overlaymode_set}" == "${DOCKER__OVERLAYMODE_NONPERSISTENT}" ]]; then
        sed_newstring+=" ${DOCKER__PENTAGRAM_TB_ROOTFS_RO_TRUE}"
    fi
    sed_newstring+="\\\0\\\""

    #Patch 'docker__docker_overlayfs_pentagram_common_h__fpath'
    replace_string_with_another_string_in_file__func "${sed_oldstring}" \
            "${sed_newstring}" \
            "${docker__docker_overlayfs_pentagram_common_h__fpath}"

    #Check exit-code
    docker__exitcode=$?
    if [[ ${docker__exitcode} -ne 0 ]]; then #error found
        #Increment index
        ((docker__numof_errors_found_ctr++))

        #Update 'printmsg'
        printmsg+="${DOCKER__STATUS_FAILED}"
    else
        #Compose 'proc_cmdline_content' by retrieving data from '..docker/overlayfs/pentagram_common.h'
        #   and write to '..docker/overlayfs/cmdline'
        docker__overlay_tmpfile_cmdline__sub

        #Print
        printmsg+="${DOCKER__STATUS_SUCCESSFUL}"
    fi
    
    #Print
    show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
}
docker__overlay_tmpfile_cmdline__sub() {
        #Retrieve 'b_c' part
        proc_cmdline_content_lpart=$(grep -o "${DOCKER__PATTERN_B_C_IS_CONSOLE}.*" \
                "${docker__docker_overlayfs_pentagram_common_h__fpath}" | \
                cut -d"=" -f2- | cut -d"\\" -f1)
        #Retrieve 'emmc_root' part
        proc_cmdline_content_rpart=$(grep -o "${DOCKER__PATTERN_EMMC_ROOT_IS_ROOT}.*" \
                "${docker__docker_overlayfs_pentagram_common_h__fpath}" | \
                cut -d"=" -f2- | cut -d"\\" -f1)
        
        #Combine 'proc_cmdline_content_lpart' and 'proc_cmdline_content_lpart'
        proc_cmdline_content="${proc_cmdline_content_lpart} ${proc_cmdline_content_rpart}"
    
        #Write to file
        echo "${proc_cmdline_content}" | tee ${docker__docker_overlayfs_cmdline__fpath} >/dev/null
}

docker__overlay_tempfile_tb_init_sh_and_fstab_patch__sub() {
    #Define constants
    local OVERLAy_PARTITION_NUM=10
    local ADDITIONAL_PARTITION_NUM_START=$((OVERLAy_PARTITION_NUM + 1))
    #array-index = 0: rootfs (/): mmcblk0p8
    #array-index = 1: tb_reserve: mmcblk0p9
    #array-index = 2: overlay: mmcblk0p10
    local ADDITIONAL_PARTITION_ARRAY_INDEX_START=3

    #Define variables
    local dev_mmcblk0pp="${DOCKER__EMPTYSTRING}"
    local fstab_filecontent="${DOCKER__EMPTYSTRING}"
    local isp_partition_arrayitem="${DOCKER__EMPTYSTRING}"
    local isp_partition_name="${DOCKER__EMPTYSTRING}"
    local isp_partition_dir="${DOCKER__EMPTYSTRING}"
    local printmsg="${DOCKER__EMPTYSTRING}"
    local sed_isp_partition_dir="${DOCKER__EMPTYSTRING}"
    local sed_dev_mmcblk0pp="${DOCKER__EMPTYSTRING}"
    local tb_init_filecontent="${DOCKER__EMPTYSTRING}"

    local tb_init_linenum_match=0
    local tb_init_linenum_insert=0

    local i=0
    local i_last=0
    local p=0


    #MANDATORY: generate 'tb_init_filecontent' and 'fstab_filecontent'
    fstab_filecontent="${DOCKER__FSTAB_DEV_MMCBLK09} ${DOCKER__FSTAB_TB_RESERVE_DIR} ${DOCKER__FSTAB_EXT4}\n"

    #Remark:
    #   Should there be any ADDITIONAL partitions (excluding 'overlay')
    #       then this subroutine will add extra command lines to 'tb_init.sh'
    #       directly under the field '#---ADDITIONAL PARTITIONS'.
    #       which will make sure that those additional partitions will be
    #       mounted automatically at boot.
    #   
    #   'docker__isp_partition_arraylen' is calculated in 'docker__overlay_tempfile_isp_sh_patch__sub'
    if [[ ${docker__isp_partition_arraylen} -gt 3 ]]; then
        i_last=$((docker__isp_partition_arraylen - 1))
        p=${ADDITIONAL_PARTITION_NUM_START}

        #Note: 'i' is array-index, which starts with '0'
        for (( i=${ADDITIONAL_PARTITION_ARRAY_INDEX_START}; i<${docker__isp_partition_arraylen}; i++ ));
        do
            #Get array-item
            isp_partition_arrayitem="${docker__isp_partition_array[i]}"
  
            #Retrieve partition name
            isp_partition_name=$(echo "${isp_partition_arrayitem}" | cut -d" " -f1)

            #Update 'sed_isp_partition_dir'
            sed_isp_partition_dir="\\/${isp_partition_name}"

            #Update 'sed_isp_partition_dir'
            isp_partition_dir=/${isp_partition_name}

            #Calculate the partition-number for the current additional partition
            sed_dev_mmcblk0pp="${DOCKER__SED_TB_INIT_DEV_MMCBLK0P}${p}"
            dev_mmcblk0pp="${DOCKER__FSTAB_DEV_MMCBLK0P}${p}"

            #Update 'tb_init_filecontent' with new values
            tb_init_filecontent+="if [[ ! -d ${sed_isp_partition_dir} ]]; then\n"
            tb_init_filecontent+="  if [[ \${flag_root_is_remounted} == false ]]; then\n"
            tb_init_filecontent+="    echo \"---:STATUS: remounting /\"\n"
            tb_init_filecontent+="    mount -o remount,rw ${DOCKER__SED_TB_INIT_MAIN_DIR} #remounting root in emmc as writeable\n"
            tb_init_filecontent+="  fi\n"
            tb_init_filecontent+="\n"
            tb_init_filecontent+="  echo \"---:STATUS: create directory ${sed_isp_partition_dir}\"\n"
            tb_init_filecontent+="  mkdir ${sed_isp_partition_dir}\n"
            tb_init_filecontent+="\n"
            tb_init_filecontent+="  echo \"---:STATUS: creating ${sed_dev_mmcblk0pp}\"\n"
            tb_init_filecontent+="  \${usr_sbin_mkfsext4} ${sed_dev_mmcblk0pp}\n"
            tb_init_filecontent+="fi\n"

            #Only append empty line if current array-index (i) is not the last array-index (i_last)
            if [[ ${i} -lt ${i_last} ]]; then
                tb_init_filecontent+="\n"
            fi


            #Update 'fstab_filecontent' with new values
            fstab_filecontent+="${dev_mmcblk0pp} ${isp_partition_dir} ${DOCKER__FSTAB_EXT4}"

            #Only append empty line if current array-index (i) is not the last array-index (i_last)
            if [[ ${i} -lt ${i_last} ]]; then
                fstab_filecontent+="\n"
            fi

            #Increment index
            ((p++))
        done


        #Start generating 'printmsg'
        printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: patch ${DOCKER__FG_LIGHTGREY}${docker__docker_overlayfs_tb_init_sh__fpath}: " 

        #Insert 'tb_init_filecontent' into 'tb_init.sh' after line '#---ADDITIONAL PARTITIONS'
        tb_init_linenum_match=$(grep -nF "${DOCKER__PATTERN_TB_INIT_ADDITIONAL_PARTITIONS}" \
                "${docker__docker_overlayfs_tb_init_sh__fpath}" | cut -d":" -f1)
        
        #Calculate the linenum which will be used to insert 'tb_init_filecontent'
        tb_init_linenum_insert=$((tb_init_linenum_match + 1))

        #Insert 'tb_init_filecontent' in tb_init.sh at linenum 'tb_init_linenum_insert'
        sed -i "${tb_init_linenum_insert}i${tb_init_filecontent}" "${docker__docker_overlayfs_tb_init_sh__fpath}"

        #Check exit-code
        docker__exitcode=$?
        if [[ ${docker__exitcode} -ne 0 ]]; then #error found
            #Increment index
            ((docker__numof_errors_found_ctr++))

            #Update 'printmsg'
            printmsg+="${DOCKER__STATUS_FAILED}\n"
        else
            printmsg+="${DOCKER__STATUS_SUCCESSFUL}\n"
        fi

        #Check exit-code
        docker__exitcode=$?
        if [[ ${docker__exitcode} -ne 0 ]]; then #error found
            #Increment index
            ((docker__numof_errors_found_ctr++))

            #Update 'printmsg'
            printmsg+="${DOCKER__STATUS_FAILED}"
        else
            printmsg+="${DOCKER__STATUS_SUCCESSFUL}"
        fi

        #Print
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
    fi


    #Start generating 'printmsg'
    printmsg+="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: patch ${DOCKER__FG_LIGHTGREY}${docker__docker_overlayfs_fstab__fpath}: " 

    #Add 'fstab_filecontent' to file 'docker__docker_overlayfs_fstab__fpath'
    echo -e "${fstab_filecontent}" | tee -a ${docker__docker_overlayfs_fstab__fpath} >/dev/null
}

docker__overlay_copy_files_from_tmp_to_dst_handler__sub() {
    #Reset variables
    docker__numof_errors_found_ctr=0

    #Print
    show_msg_only__func "${DOCKER__SUBJECT_START_COPY_FILES_FROM_TMP_TO_DST_LOCATION}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_0}"

    #Copy files
    docker__overlay_copy_file__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__docker_overlayfs_fstab__fpath}" \
            "${docker__containerid}" \
            "${docker__SP7021_linux_rootfs_initramfs_disk_etc_fstab__fpath}"

    docker__overlay_copy_file__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__docker_overlayfs_isp_c__fpath}" \
            "${docker__containerid}" \
            "${docker__SP7021_build_tools_isp_isp_c__fpath}"

    docker__overlay_copy_file__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__docker_overlayfs_isp_sh__fpath}" \
            "${docker__containerid}" \
            "${docker__SP7021_build_isp_sh__fpath}"

    docker__overlay_copy_file__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__docker_overlayfs_pentagram_common_h__fpath}" \
            "${docker__containerid}" \
            "${docker__SP7021_boot_uboot_include_configs_pentagram_common_h__fpath}"

    docker__overlay_copy_file__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__docker_overlayfs_tb_init_sh__fpath}" \
            "${docker__containerid}" \
            "${docker__SP7021_linux_rootfs_initramfs_disk_sbin_tb_init_sh__fpath}"

    docker__overlay_copy_file__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__docker_overlayfs_tb_init_bootmenu__fpath}" \
            "${docker__containerid}" \
            "${docker__SP7021_linux_rootfs_initramfs_disk_sbin_tb_init_bootmenu__fpath}"

    docker__overlay_copy_file__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__docker_overlayfs_96_overlayboot_notice__fpath}" \
            "${docker__containerid}" \
            "${docker__SP7021_linux_rootfs_initramfs_disk_etc_update_motd_d_96_overlayboot_notice__fpath}"
    docker__overlay_copy_file__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__docker_overlayfs_98_normalboot_notice__fpath}" \
            "${docker__containerid}" \
            "${docker__SP7021_linux_rootfs_initramfs_disk_etc_update_motd_d_98_normalboot_notice__fpath}"

    #This is a special subroutine for 'cmdline'
    docker__overlay_create_dir_and_copy_cmdline__sub

    #Show error message and exit (if applicable)
    if [[ ${docker__numof_errors_found_ctr} -gt 0 ]]; then
        show_errMsg_wo_menuTitle_and_exit_func "${DOCKER__ERRMSG_ONE_OR_MORE_CHECKITEMS_FAILED}" \
                ${DOCKER__NUMOFLINES_1} \
                ${DOCKER__NUMOFLINES_0}
    fi

    #Print
    show_msg_only__func "${DOCKER__SUBJECT_COMPLETED_COPY_FILES}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
}
docker__overlay_create_dir_and_copy_cmdline__sub() {
    create_dir_in_container__func "${docker__containerid}" \
            "${docker__SP7021_linux_rootfs_initramfs_disk_etc_tibbo_proc__dir}"

    docker__overlay_copy_file__sub "${DOCKER__EMPTYSTRING}" \
            "${docker__docker_overlayfs_cmdline__fpath}" \
            "${docker__containerid}" \
            "${docker__SP7021_linux_rootfs_initramfs_disk_etc_tibbo_proc_cmdline__fpath}"
}

docker__overlay_dst_exec_files_change_permission_handler__sub() {
    #Reset variables
    docker__numof_errors_found_ctr=0

    #Print
    show_msg_only__func "${DOCKER__SUBJECT_START_DST_EXECFILES_CHANGE_PERMISSION_TO_RWXRXRX}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_0}"

    #Change permission
    docker__overlay_dst_exec_file_change_permission__sub "${docker__SP7021_build_isp_sh__fpath}"
    docker__overlay_dst_exec_file_change_permission__sub "${docker__SP7021_linux_rootfs_initramfs_disk_sbin_tb_init_sh__fpath}"
    docker__overlay_dst_exec_file_change_permission__sub "${docker__SP7021_linux_rootfs_initramfs_disk_sbin_tb_init_bootmenu__fpath}"
    docker__overlay_dst_exec_file_change_permission__sub "${docker__SP7021_linux_rootfs_initramfs_disk_etc_update_motd_d_96_overlayboot_notice__fpath}"
    #Note: do NOT change the permission for 'docker__SP7021_linux_rootfs_initramfs_disk_etc_update_motd_d_98_normalboot_notice__fpath'

    #Show error message and exit (if applicable)
    if [[ ${docker__numof_errors_found_ctr} -gt 0 ]]; then
        show_errMsg_wo_menuTitle_and_exit_func "${DOCKER__ERRMSG_COULD_NOT_CHANGE_FILE_PERMISSION_TO_RWXRXRX}" \
                ${DOCKER__NUMOFLINES_1} \
                ${DOCKER__NUMOFLINES_0}
    fi

    #Print
    show_msg_only__func "${DOCKER__SUBJECT_COMPLETED_DST_EXECFILES_CHANGE_PERMISSION_TO_RWXRXRX}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
}
docker__overlay_dst_exec_file_change_permission__sub() {
    #Input args
    local targetfpath__input=${1}

    #Set 'printmsg'
    local printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: chmod ${DOCKER__CHMOD_755}${DOCKER__FG_LIGHTGREY}${targetfpath__input}: " 

    #Update variables
    local cmd="chmod 755 ${targetfpath__input}"

    #Check whether INSIDE or OUTSIDE container and set 'containerid'
    local containerid="${DOCKER__EMPTYSTRING}"
    if [[ ${docker__isRunning_inside_container} == false ]]; then   #currently inside container
        containerid=${docker__containerid}
    fi

    #Execute command 'cmd'
    docker_exec_cmd__func "${containerid}" "${cmd}"

    #Check exit-code
    docker__exitcode=$?
    if [[ ${docker__exitcode} -ne 0 ]]; then #error found
        #Increment index
        ((docker__numof_errors_found_ctr++))

        #Update 'printmsg'
        printmsg+="${DOCKER__STATUS_FAILED}"
    else
        printmsg+="${DOCKER__STATUS_SUCCESSFUL}"
    fi

    #Print
    show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
}

docker__overlay_tb_init_softlink_handler__sub() {
    #Reset variables
    docker__numof_errors_found_ctr=0

    #Print
    show_msg_only__func "${DOCKER__SUBJECT_START_TB_INIT_SH_CREATE_SOFTLINK}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_0}"

    #Change permission
    docker__overlay_tb_init_softlink_create__sub

    #Show error message and exit (if applicable)
    if [[ ${docker__numof_errors_found_ctr} -gt 0 ]]; then
        show_errMsg_wo_menuTitle_and_exit_func "${DOCKER__ERRMSG_COULD_NOT_CREATE_SOFTLINK}" \
                ${DOCKER__NUMOFLINES_1} \
                ${DOCKER__NUMOFLINES_0}
    fi

    #Print
    show_msg_only__func "${DOCKER__SUBJECT_COMPLETED_TB_INIT_SH_CREATE_SOFTLINK}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
}
docker__overlay_tb_init_softlink_create__sub() {
    #Set 'printmsg'
    local printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: create soft-link of ${DOCKER__FG_LIGHTGREY}${docker__tb_init_sh__filename}${DOCKER__NOCOLOR}: "

    #Remove soft-link 'init'
    remove_file__func "${docker__containerid}" \
            "${docker__SP7021_linux_rootfs_initramfs_disk_sbin_init__fpath}" \
            "${DOCKER__SIXDASHES_COLON}"

    #Define command
    #***IMPORTANT: make sure to use the REAL PATH '/sbin/tb_init.sh' and 
    #   not '/root/SP7021/linux/rootfs/initramfs/disk/usr/sbin/tb_init.sh'
    local cmd="ln -sfn \"${docker__sbin_tb_init_sh__fpath}\" \
            \"${docker__SP7021_linux_rootfs_initramfs_disk_sbin_init__fpath}\""

    #Check whether INSIDE or OUTSIDE container and set 'containerid'
    local containerid="${DOCKER__EMPTYSTRING}"
    if [[ ${docker__isRunning_inside_container} == false ]]; then   #currently inside container
        containerid=${docker__containerid}
    fi

    #Execute command 'cmd'
    docker_exec_cmd__func "${containerid}" "${cmd}"

    #Check exit-code
    docker__exitcode=$?
    if [[ ${docker__exitcode} -ne 0 ]]; then #error found
        #Increment index
        ((docker__numof_errors_found_ctr++))

        #Update 'printmsg'
        printmsg+="${DOCKER__STATUS_FAILED}"
    else
        printmsg+="${DOCKER__STATUS_SUCCESSFUL}"
    fi

    #Print
    show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
}

docker__overlay_restore_original_state__sub() {
    #Restore the original files
    docker__overlay_copy_file__sub "${docker__containerid}" \
            "${docker__SP7021_linux_rootfs_initramfs_disk_etc_fstab_overlaybck__fpath}" \
            "${docker__containerid}" \
            "${docker__SP7021_linux_rootfs_initramfs_disk_etc_fstab__fpath}"

    docker__overlay_copy_file__sub "${docker__containerid}" \
            "${docker__SP7021_build_tools_isp_isp_c_overlaybck__fpath}" \
            "${docker__containerid}" \
            "${docker__SP7021_build_tools_isp_isp_c__fpath}"

    docker__overlay_copy_file__sub "${docker__containerid}" \
            "${docker__SP7021_build_isp_sh_overlaybck__fpath}" \
            "${docker__containerid}" \
            "${docker__SP7021_build_isp_sh__fpath}"

    docker__overlay_copy_file__sub "${docker__containerid}" \
            "${docker__SP7021_boot_uboot_include_configs_pentagram_common_h_overlaybck__fpath}" \
            "${docker__containerid}" \
            "${docker__SP7021_boot_uboot_include_configs_pentagram_common_h__fpath}"

    remove_file__func "${docker__containerid}" \
            "${docker__SP7021_linux_rootfs_initramfs_disk_sbin_tb_init_sh__fpath}" \
            "${DOCKER__SIXDASHES_COLON}"

    remove_file__func "${docker__containerid}" \
            "${docker__SP7021_linux_rootfs_initramfs_disk_sbin_tb_init_bootmenu__fpath}" \
            "${DOCKER__SIXDASHES_COLON}"

    remove_file__func "${docker__containerid}" \
            "${docker__SP7021_linux_rootfs_initramfs_disk_etc_update_motd_d_96_overlayboot_notice__fpath}" \
            "${DOCKER__SIXDASHES_COLON}"
    remove_file__func "${docker__containerid}" \
            "${docker__SP7021_linux_rootfs_initramfs_disk_etc_update_motd_d_98_normalboot_notice__fpath}" \
            "${DOCKER__SIXDASHES_COLON}"
}

docker__one_time_exec_update__sub () {
    #Initialize variable
    local printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: update "
    printmsg+="${DOCKER__FG_LIGHTGREY}${docker__one_time_exec_sh__filename}${DOCKER__NOCOLOR}: "

    #Retrieve 'tb_reserve_size'
    local tb_reserve_size=$(grep -F "${DOCKER__DISKPARTNAME_TB_RESERVE}" "${docker__docker_fs_partition_diskpartsize_dat__fpath}" | awk '{print $2}')
    #Calculate 'docker__swapfilesize'
    docker__swapfilesize=$((tb_reserve_size - DOCKER__RESERVED_SIZE_DEFAULT))

    #Define command
    local cmd="sed -i \"/${DOCKER__SED_PATTERN_SWAPFILESIZE_IS}/c\\${DOCKER__SED_PATTERN_SWAPFILESIZE_IS}${docker__swapfilesize}\" "
    cmd+="\"${docker__SP7021_linux_rootfs_initramfs_disk_scripts_one_time_exec_fpath}\""

    #Check whether INSIDE or OUTSIDE container and set 'containerid'
    local containerid="${DOCKER__EMPTYSTRING}"
    if [[ ${docker__isRunning_inside_container} == false ]]; then   #currently inside container
        containerid=${docker__containerid}
    fi

    #Execute command 'cmd'
    docker_exec_cmd__func "${containerid}" "${cmd}"

    #Check exit-code
    docker__exitcode=$?
    if [[ ${docker__exitcode} -ne 0 ]]; then #error found
        printmsg+="${DOCKER__STATUS_FAILED}"
    else
        printmsg+="${DOCKER__STATUS_SUCCESSFUL}"
    fi

    #Print
    show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
}


docker__fstab_handler__sub() {
    #---------------------------------------------------------------------
    # PHASE 1: Check if entry '/tb_reserve none swap sw 0 0' is found in 'fstab'
    #---------------------------------------------------------------------
    docker__fstab_checkif_tb_reserve_entry_ispresent_sub

    #---------------------------------------------------------------------
    # PHASE 2: Remove entry '/tb_reserve none swap sw 0 0' from 'fstab'
    #---------------------------------------------------------------------
    docker__fstab_remove_tb_reserve_entry__sub

    #---------------------------------------------------------------------
    # PHASE 3: Add entry '/tb_reserve none swap sw 0 0' to 'fstab'
    #---------------------------------------------------------------------
    docker__fstab_add_tb_reserve_entry__sub
}

docker__fstab_checkif_tb_reserve_entry_ispresent_sub() {
    #Define printmsg
    local printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: check if entry "
    printmsg+="${DOCKER__FG_LIGHTGREY}${DOCKER__FSTAB_TB_RESERVE_DIR_ENTRY}${DOCKER__NOCOLOR} "
    printmsg+="is found in ${DOCKER__FG_LIGHTGREY}${docker__fstab__filename}${DOCKER__NOCOLOR}: "

    #Define command to check if entry '/tb_reserve none swap sw 0 0' is found in 'fstab'
    local cmd="grep -F \"${DOCKER__FSTAB_TB_RESERVE_DIR_ENTRY}\" "
    cmd+="\"${docker__SP7021_linux_rootfs_initramfs_disk_etc_fstab__fpath}\""

    #Define output-file which will be used to store the output of 'cmd'
    docker__fstab_output="${docker__tmp__dir}/fstab_output.out"

    #Check whether INSIDE or OUTSIDE container and set 'containerid'
    local containerid="${DOCKER__EMPTYSTRING}"
    if [[ ${docker__isRunning_inside_container} == false ]]; then   #currently inside container
        containerid=${docker__containerid}
    fi

    #Execute command 'cmd'
    docker_exec_cmd_and_receive_output__func "${containerid}" "${cmd}" "${docker__fstab_output}"
    #Check exit-code
    docker__exitcode=$?
    if [[ ${docker__exitcode} -ne 0 ]]; then #error found
        printmsg+="${DOCKER__STATUS_FAILED}"
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        exit 99
    fi

    #Retrieve the output
    docker__fstab_output=$(cat "${docker__fstab_output}")
    if [[ -n "${docker__fstab_output}" ]]; then  #Yes, contains data
        #Update 'printmsg'
        printmsg+="${DOCKER__STATUS_PRESENT}"
    else
        printmsg+="${DOCKER__STATUS_NOTPRESENT}"
    fi

    show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
}

docker__fstab_remove_tb_reserve_entry__sub() {
    #Check if 'docker__fstab_output' contains data
    if [[ -n "${docker__fstab_output}" ]]; then  #Yes, contains data
        #Define 'printmsg'
        local printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: remove entry "
        printmsg+="${DOCKER__FG_LIGHTGREY}${DOCKER__FSTAB_TB_RESERVE_DIR_ENTRY}${DOCKER__NOCOLOR} "
        printmsg+="from ${DOCKER__FG_LIGHTGREY}${docker__fstab__filename}${DOCKER__NOCOLOR}: "

        #Remove entry '/tb_reserve none swap sw 0 0' from 'fstab'
        local cmd="sed -i \"/${DOCKER__SED_FSTAB_TB_RESERVE_DIR_ENTRY}/d\" \"${docker__SP7021_linux_rootfs_initramfs_disk_etc_fstab__fpath}\""

        #Check whether INSIDE or OUTSIDE container and set 'containerid'
        local containerid="${DOCKER__EMPTYSTRING}"
        if [[ ${docker__isRunning_inside_container} == false ]]; then   #currently inside container
            containerid=${docker__containerid}
        fi

        #Execute command 'cmd'
        docker_exec_cmd__func "${containerid}" "${cmd}"

        #Check exit-code
        docker__exitcode=$?
        if [[ ${docker__exitcode} -ne 0 ]]; then #error found
            printmsg+="${DOCKER__STATUS_FAILED}"
            show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

            exit 99
        else    #No error found
            printmsg+="${DOCKER__STATUS_SUCCESSFUL}"
            show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
        fi
    fi
}

docker__fstab_add_tb_reserve_entry__sub() {
    #Check if 'docker__swapfilesize > 0', which means swapfile is ENABLED
    if [[ ${docker__swapfilesize} -gt 0 ]]; then
        #Define 'printmsg'
        local printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: add entry "
        printmsg+="${DOCKER__FG_LIGHTGREY}${DOCKER__FSTAB_TB_RESERVE_DIR_ENTRY}${DOCKER__NOCOLOR} "
        printmsg+="to ${DOCKER__FG_LIGHTGREY}${docker__fstab__filename}${DOCKER__NOCOLOR}: "

        #Remove entry '/tb_reserve none swap sw 0 0' from 'fstab'
        local cmd="echo \"${DOCKER__FSTAB_TB_RESERVE_DIR_ENTRY}\" | tee -a \"${docker__SP7021_linux_rootfs_initramfs_disk_etc_fstab__fpath}\""

        #Check whether INSIDE or OUTSIDE container and set 'containerid'
        local containerid="${DOCKER__EMPTYSTRING}"
        if [[ ${docker__isRunning_inside_container} == false ]]; then   #currently inside container
            containerid=${docker__containerid}
        fi

        #Execute command 'cmd'
        docker_exec_cmd__func "${containerid}" "${cmd}"

        #Check exit-code
        docker__exitcode=$?
        if [[ ${docker__exitcode} -ne 0 ]]; then #error found
            printmsg+="${DOCKER__STATUS_FAILED}"
            show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

            exit 99
        else    #No error found
            printmsg+="${DOCKER__STATUS_SUCCESSFUL}"
            show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
        fi
    fi
}



docker__run_script__sub() {
    #Initialize variable
    local printmsg="${DOCKER__EMPTYSTRING}"

    #Define command
    local cmd="eval \"${docker__docker__build_ispboootbin_fpath}\""

    #Check whether INSIDE or OUTSIDE container and set 'containerid'
    local containerid="${DOCKER__EMPTYSTRING}"
    if [[ ${docker__isRunning_inside_container} == false ]]; then   #currently inside container
        containerid=${docker__containerid}
    fi

    #Execute command 'cmd'
    docker_exec_cmd__func "${containerid}" "${cmd}"

    #Check if there are any errors
    docker__exitcode=$?
    if [[ ${docker__exitcode} -ne 0 ]]; then #error found
        #Update print message
        printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: build ${DOCKER__FG_LIGHTGREY}ISPBOOOT.BIN${DOCKER__NOCOLOR}: ${DOCKER__STATUS_FAILED}"

        # exit__func "${docker__exitcode}" "${DOCKER__NUMOFLINES_1}"
    else
        #Update print message
        printmsg="${DOCKER__SIXDASHES_COLON}${DOCKER__STATUS}: build ${DOCKER__FG_LIGHTGREY}ISPBOOOT.BIN${DOCKER__NOCOLOR}: ${DOCKER__STATUS_SUCCESSFUL}"

        #Print the following message in case 'docker__overlaysetting_set = DOCKER__OVERLAYFS_ENABLED'
        if [[ "${docker__overlaysetting_set}" == "${DOCKER__OVERLAYFS_ENABLED}" ]]; then
            printmsg+="\n"
            printmsg+="${DOCKER__NINEDASHES_COLON}${DOCKER__NOTICE}: After reimaging the LTPS with this new ${DOCKER__FG_LIGHTGREY}ISPBOOOT.BIN${DOCKER__NOCOLOR} image...\n"
            printmsg+="${DOCKER__NINEDASHES_COLON}${DOCKER__NOTICE}: ...executable ${DOCKER__FG_LIGHTGREY}tb_init_bootmenu${DOCKER__NOCOLOR} will be available.\n"
            printmsg+="${DOCKER__NINEDASHES_COLON}${DOCKER__NOTICE}: With this tool, overlay ${DOCKER__FG_LIGHTGREY}mode/options${DOCKER__NOCOLOR} "
            printmsg+="can be configured ${DOCKER__FG_LIGHTGREY}within${DOCKER__NOCOLOR} Linux."
        fi
    fi

    #Print message
    show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_1}" "${DOCKER__NUMOFLINES_0}"
}



docker__main__sub(){
    docker__get_source_fullpath__sub

    docker__load_global_fpath_paths__sub

    docker__environmental_variables__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__checkif_isrunning_in_container__sub

    docker__choose_containerID__sub

    #Note:
    #   This pre-check has run AFTER 'docker__choose_containerID__sub',
    #   ...because the 'container-ID' may be needed.
    docker__preCheck__sub

    docker__overlay__sub

    docker__one_time_exec_update__sub

    docker__fstab_handler__sub

    docker__run_script__sub
}


#Run main subroutine
docker__main__sub
