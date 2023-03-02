#!/bin/bash -m
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

docker__load_constants__sub() {
    DOCKER__MENUTITLE="${DOCKER__FG_LIGHTBLUE}DOCKER: "
    DOCKER__MENUTITLE+="${DOCKER__FG_DARKBLUE}FS PATITION${DOCKER__NOCOLOR} [${DOCKER__FG_DARKBLUE}MB${DOCKER__NOCOLOR}]"
}

docker__init_variables__sub() {
    docker__mychoice1="${DOCKER__EMPTYSTRING}"
    docker__myinput="${DOCKER__EMPTYSTRING}"
    docker__diskpart="${DOCKER__EMPTYSTRING}"
    docker__diskpartstatus_print="${DOCKER__DASH}"
    docker__diskpartstatus_header_print="${DOCKER__EMPTYSTRING}"
    docker__diskpartstatus=false
    docker__disksize=0
    docker__disksizestatus_print="${DOCKER__DASH}"
    docker__disksizestatus_header_print="${DOCKER__EMPTYSTRING}"
    docker__disksizestatus=false
    docker__regEx="${DOCKER__EMPTYSTRING}"
    docker__regex1bq="[1bq]"
    docker__regex12bq="[1-2bq]"
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
    docker__diskpartstatus=false
    docker__disksize=0
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
        echo -e "${DOCKER__FOURSPACES}b. build ${DOCKER__BG_LIGHTGREY}ISPBOOOT.BIN${DOCKER__NOCOLOR}"
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
                docker__disksize=$(read_1stline_from_file "${docker__fs_partition_disksize_menu_output__fpath}")

                remove_file__func "${docker__fs_partition_disksize_menu_output__fpath}"
                ;;
            2)
                echo "2 in progress"
                ;;
            b)
                echo "in 'docker_build_ispboootbin.sh', a check has to be built in whether to copy the 'isp.sh' and 'pentagram_common.h' from source to destination"
                echo "you could check whether 'docker__docker_overlayfs__dir' contains both files or not. If yes, then copy and build".
                echo "if NOT, then just build without overlay"
                ${docker__container_build_ispboootbin_fpath}
                ;;
            q)
                exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_1}"
                ;;
        esac
    done
}
docker__menu_update_disksizestatus_boolean_and_print_values__sub() {
    docker__disksizestatus_header_print="${DOCKER__FOURSPACES}1. Choose ${DOCKER__FG_RED125}disk${DOCKER__NOCOLOR}-${DOCKER__FG_RED125}size${DOCKER__NOCOLOR}"

    if [[ ${docker__disksize} -ne 0 ]]; then
        docker__disksizestatus=true

        docker__disksizestatus_print="${DOCKER__FG_LIGHTGREY}${docker__disksize}${DOCKER__NOCOLOR}"
    else
        docker__disksizestatus=false

        docker__disksizestatus_print="${DOCKER__STATUS_UNSET}"
    fi
}


docker__menu_update_regex_and_diskpartstatus_print_values__sub () {
docker__disksizestatus=true
    if [[ ${docker__disksizestatus} == true ]]; then
        docker__regEx="${docker__regex12bq}"

        docker__diskpartstatus_header_print="${DOCKER__FOURSPACES}2. Configure ${DOCKER__FG_RED9}disk${DOCKER__NOCOLOR}-${DOCKER__FG_RED9}partition${DOCKER__NOCOLOR}"
docker__diskpartstatus=true
        if [[ ${docker__diskpartstatus} == true ]]; then
            docker__diskpartstatus_print="${DOCKER__STATUS_SET}"
        else
            docker__diskpartstatus_print="${DOCKER__STATUS_UNSET}"
        fi
    else
        docker__regEx="${docker__regex1bq}"

        docker__diskpartstatus_header_print="${DOCKER__FG_LIGHTGREY}${DOCKER__FOURSPACES}2.${DOCKER__NOCOLOR} Configure ${DOCKER__FG_RED9}disk${DOCKER__NOCOLOR}-${DOCKER__FG_RED9}partition${DOCKER__NOCOLOR}"

        docker__diskpartstatus_print="${DOCKER__STATUS_UNSET}"
    fi
}

#---MAIN SUBROUTINE
main__sub() {
    docker__get_source_fullpath__sub

    docker__load_global_fpath_paths__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__menu__sub
}



#---EXECUTE
main__sub