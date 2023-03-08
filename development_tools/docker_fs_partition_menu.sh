#!/bin/bash -m
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

docker__load_constants__sub() {
    DOCKER__MENUTITLE="${DOCKER__FG_LIGHTBLUE}DOCKER: "
    DOCKER__MENUTITLE+="${DOCKER__FG_DARKBLUE}Overlay${DOCKER__NOCOLOR} & ${DOCKER__FG_DARKBLUE}ISPBOOOT.BIN${DOCKER__NOCOLOR}"
}

docker__init_variables__sub() {
    docker__mychoice1="${DOCKER__EMPTYSTRING}"
    docker__myinput="${DOCKER__EMPTYSTRING}"
    docker__diskpart="${DOCKER__EMPTYSTRING}"
    docker__diskpartstatus_print="${DOCKER__DASH}"
    docker__diskpartstatus_header_print="${DOCKER__EMPTYSTRING}"
    docker__disksize_set=0
    docker__disksizestatus_print="${DOCKER__DASH}"
    docker__disksizestatus_header_print="${DOCKER__EMPTYSTRING}"
    docker__disksizestatus=false
    docker__regEx="${DOCKER__EMPTYSTRING}"
    docker__regex1bq="[1bq]"
    docker__regex12bq="[1-2bq]"

    docker__overlaymode_set="${DOCKER__OVERLAYMODE_PERSISTENT}"
    docker__overlayfs_set="${DOCKER__OVERLAYFS_DISABLED}"
}

docker__get_git_info__sub() {
    #Get information
    docker__git_current_branchName=`git__get_current_branchName__func`

    docker__git_current_abbrevCommitHash=`git__log_for_pushed_and_unpushed_commits__func "${DOCKER__EMPTYSTRING}" \
                        "${GIT__LAST_COMMIT}" \
                        "${GIT__PLACEHOLDER_ABBREV_COMMIT_HASH}"`
      
    docker__git_push_status=`git__checkIf_branch_isPushed__func "${docker__git_current_branchName}"`

    docker__git_current_tag=`git__get_tag_for_specified_branchName__func "${docker__git_current_branchName}" "${DOCKER__FALSE}"`
    if [[ -z "${docker__git_current_tag}" ]]; then
        docker__git_current_tag="${GIT__NOT_TAGGED}"
    fi

    #Generate message to be shown
    docker_git_current_info_msg="${DOCKER__FG_LIGHTBLUE}${docker__git_current_branchName}${DOCKER__NOCOLOR}:"
    docker_git_current_info_msg+="${DOCKER__FG_DARKBLUE}${docker__git_current_abbrevCommitHash}${DOCKER__NOCOLOR}"
    docker_git_current_info_msg+="(${DOCKER__FG_DARKBLUE}${docker__git_push_status}${DOCKER__NOCOLOR}):"
    docker_git_current_info_msg+="${DOCKER__FG_LIGHTBLUE}${docker__git_current_tag}${DOCKER__NOCOLOR}"
}

docker__menu__sub() {
    #Initialize variables
    docker__diskpart="${DOCKER__EMPTYSTRING}"
    docker__diskpartstatus_print="${DOCKER__DASH}"
    docker__diskpartstatus_header_print="${DOCKER__EMPTYSTRING}"
    docker__disksize_set=0
    docker__disksizestatus_print="${DOCKER__DASH}"
    docker__disksizestatus_header_print="${DOCKER__EMPTYSTRING}"
    docker__disksizestatus=false
    docker__regEx="${docker__regex1bq}"

    #Show menu
    while true
    do    
        #Get Git-information
        #Output:
        #   docker_git_current_info_msg
        docker__get_git_info__sub

        #Load header
        load_tibbo_title__func "${DOCKER__NUMOFLINES_2}"

        #Print horizontal line
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Print menut-title
        show_leadingAndTrailingStrings_separatedBySpaces__func "${DOCKER__MENUTITLE}" "${docker_git_current_info_msg}" "${DOCKER__TABLEWIDTH}"

        #Print horizontal line
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Print menu-options
        #Remark:
        #   This subroutine will implicitely update the varaiables:
        #   1. docker__disksizestatus
        #   2. docker__disksizestatus_print
        docker__menu_update_disksizestatus_boolean_and_print_values__sub
        echo -e "${docker__disksizestatus_header_print} (${DOCKER__FG_LIGHTGREY}${docker__disksizestatus_print}${DOCKER__NOCOLOR})"
        
        #Remark:
        #   This subroutine will implicitely update the varaiables:
        #   1. docker__regEx
        #   2. docker__diskpartstatus_header_print    
        #   3. docker__diskpartstatus_print
        docker__menu_update_regex_and_diskpartstatus_print_values__sub
        echo -e "${docker__diskpartstatus_header_print} (${docker__diskpartstatus_print})"

        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}b. ${DOCKER__MENU} build ${DOCKER__BG_LIGHTGREY}ISPBOOOT.BIN${DOCKER__NOCOLOR}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}q. $DOCKER__QUIT_CTRL_C"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Show read-dialog
        while true
        do
            #Select an option
            read -N1 -r -p "Please choose an option: " docker__mychoice1
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            #Only continue if a valid option is selected
            if [[ ! -z ${docker__mychoice1} ]]; then
                if [[ ${docker__mychoice1} =~ ${docker__regEx} ]]; then
                    break
                else
                    if [[ ${docker__mychoice1} == ${DOCKER__ENTER} ]]; then
                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
                    else
                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                    fi
                fi
            else
                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
            fi
        done
            
        #Goto the selected option
        case ${docker__mychoice1} in
            1)
                ${docker__fs_partition_disksize_menu__fpath} "${docker__global__fpath}"
                ;;
            2)
                ${docker__fs_partition_diskpartition_menu_fpath} "${docker__disksize_set}" "${docker__global__fpath}"
                ;;
            b)
                ${docker__container_build_ispboootbin_fpath}
                ;;
            q)
                exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_1}"
                ;;
        esac
    done
}
docker__menu_update_disksizestatus_boolean_and_print_values__sub() {
    #Generate 'docker__disksizestatus_header_print'
    docker__disksizestatus_header_print="${DOCKER__FOURSPACES}1. ${DOCKER__MENU} Choose ${DOCKER__FG_RED125}disk${DOCKER__NOCOLOR}-${DOCKER__FG_RED125}size${DOCKER__NOCOLOR}"

    #Initialize variables
    docker__disksize_set=0
    docker__disksizestatus=false
    docker__disksizestatus_print="${DOCKER__FG_LIGHTGREY}${DOCKER__DASH}${DOCKER__NOCOLOR}"

    #Get 'docker__disksize_set' from file
    if [[ -f "${docker__docker_fs_partition_conf__fpath}" ]]; then
        docker__disksize_set=$(retrieve__data_specified_by_col_within_file__func "${DOCKER__DISKSIZESETTING}" \
                "${DOCKER__COLNUM_2}" \
                "${docker__docker_fs_partition_conf__fpath}")
    fi


    #1. Set 'docker__disksizestatus'
    #2. Generate 'docker__disksizestatus_print'
    if [[ ${docker__disksize_set} -ne 0 ]]; then
        docker__disksizestatus=true

        docker__disksizestatus_print="${DOCKER__FG_LIGHTGREY}${docker__disksize_set}${DOCKER__NOCOLOR}"
    fi
}


docker__menu_update_regex_and_diskpartstatus_print_values__sub () {
    #1. Generate 'docker__diskpartstatus_header_print'
    #2. Select 'docker__regEx'
    if [[ ${docker__disksizestatus} == true ]]; then
        docker__regEx="${docker__regex12bq}"

        docker__diskpartstatus_header_print="${DOCKER__FOURSPACES}2. ${DOCKER__MENU} Configure "
    else
        docker__regEx="${docker__regex1bq}"

        docker__diskpartstatus_header_print="${DOCKER__FG_LIGHTGREY}${DOCKER__FOURSPACES}2. ${DOCKER__MENU} ${DOCKER__NOCOLOR}Configure "
    fi
    docker__diskpartstatus_header_print+="${DOCKER__FG_RED9}disk${DOCKER__NOCOLOR}-${DOCKER__FG_RED9}partition${DOCKER__NOCOLOR}"


    #Initialize variables
    docker__overlaymode_set=${DOCKER__EMPTYSTRING}
    docker__overlayfs_set=${DOCKER__EMPTYSTRING}

    #Get 'docker__overlaymode_set' from file
    if [[ -f "${docker__docker_fs_partition_conf__fpath}" ]]; then
        docker__overlaymode_set=$(retrieve__data_specified_by_col_within_file__func "${DOCKER__OVERLAYMODE}" \
                "${DOCKER__COLNUM_2}" \
                "${docker__docker_fs_partition_conf__fpath}")

        docker__overlayfs_set=$(retrieve__data_specified_by_col_within_file__func "${DOCKER__OVERLAYSETTING}" \
                "${DOCKER__COLNUM_2}" \
                "${docker__docker_fs_partition_conf__fpath}")
    fi

    #Generate 'docker__disksizestatus_print'
    if [[ -n "${docker__overlaymode_set}" ]]; then
        if [[ "${docker__overlaymode_set}" == "${DOCKER__OVERLAYMODE_PERSISTENT}" ]]; then
            docker__diskpartstatus_print="${DOCKER__FG_GREEN158}${docker__overlaymode_set}${DOCKER__NOCOLOR}"
        else
            docker__diskpartstatus_print="${DOCKER__FG_RED187}${docker__overlaymode_set}${DOCKER__NOCOLOR}"
        fi
    else
        docker__diskpartstatus_print="${DOCKER__FG_LIGHTGREY}${DOCKER__DASH}${DOCKER__NOCOLOR}"
    fi

    docker__diskpartstatus_print+="/"

    if [[ -n "${docker__overlayfs_set}" ]]; then
        if [[ "${docker__overlayfs_set}" == "${DOCKER__OVERLAYFS_ENABLED}" ]]; then
            docker__diskpartstatus_print+="${DOCKER__FG_GREEN158}${docker__overlayfs_set}${DOCKER__NOCOLOR}"
        else
            docker__diskpartstatus_print+="${DOCKER__FG_RED187}${docker__overlayfs_set}${DOCKER__NOCOLOR}"
        fi
    else
        docker__diskpartstatus_print+="${DOCKER__FG_LIGHTGREY}${DOCKER__DASH}${DOCKER__NOCOLOR}"
    fi
}

#---MAIN SUBROUTINE
main__sub() {
echo ">"
    docker__get_source_fullpath__sub

    docker__load_global_fpath_paths__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__menu__sub
}



#---EXECUTE
main__sub