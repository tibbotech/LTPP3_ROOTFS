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
    GIT__MENUTITLE="${DOCKER__FG_LIGHTBLUE}GIT MENU${DOCKER__NOCOLOR}"
}

docker__init_variables__sub() {
    # docker__current_checkOut_branch=${DOCKER__EMPTYSTRING}
    docker__myChoice=""    
    docker__regEx="[01-6hq]"

    docker__tibboHeader_prepend_numOfLines=0

    docker__childWhileLoop_isExit=false
    docker__parentWhileLoop_isExit=false
}

git__menu_sub() {
    #Initialization
    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

    while true
    do
        #Get Git-information
        #Output:
        #   docker_git_current_info_msg
        docker__get_git_info__sub

        #Load header
        load_tibbo_title__func "${docker__tibboHeader_prepend_numOfLines}"

        #Set 'docker__tibboHeader_prepend_numOfLines'
        docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_1}

        # #Get current CHECKOUT BRANCH
        # docker__current_checkOut_branch=`git symbolic-ref --short -q HEAD`

        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        show_leadingAndTrailingStrings_separatedBySpaces__func "${GIT__MENUTITLE}" "${docker_git_current_info_msg}" "${DOCKER__TABLEWIDTH}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        # echo -e "${DOCKER__FOURSPACES}Current Checkout Branch: ${DOCKER__FG_LIGHTSOFTYELLOW}${docker__git_current_branchName}${DOCKER__NOCOLOR}"
        # duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}1. Push"
        echo -e "${DOCKER__FOURSPACES}2. Pull"
        echo -e "${DOCKER__FOURSPACES}3. Undo last unpushed commit"
        echo -e "${DOCKER__FOURSPACES}4. Create${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}checkout ${DOCKER__FG_BROWN94}local${DOCKER__NOCOLOR} branch"
        echo -e "${DOCKER__FOURSPACES}5. Delete ${DOCKER__FG_BROWN94}local${DOCKER__NOCOLOR} branch"
        echo -e "${DOCKER__FOURSPACES}6. ${DOCKER__MENU} create${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}rename${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}remove tag"
        echo -e "${DOCKER__FOURSPACES}0. Enter Command Prompt"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}q. $DOCKER__QUIT_CTRL_C"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        # echo -e "\r"

        while true
        do
            #Select an option
            read -N1 -r -p "Please choose an option: " docker__myChoice
            echo -e "\r"

            #Only continue if a valid option is selected
            case "${docker__myChoice}" in
                ${DOCKER__CTRL_C})
                    docker__exit_handler__sub
                    ;;
                *)
                    if [[ ! -z "${docker__myChoice}" ]]; then
                        if [[ ${docker__myChoice} =~ ${docker__regEx} ]]; then
                            break
                        else
                            if [[ ${docker__myChoice} == ${DOCKER__ENTER} ]]; then
                                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
                            else
                                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                            fi
                        fi
                    else
                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                    fi
                    ;;
            esac

            #Check if flag is given to break loop
            if [[ ${docker__childWhileLoop_isExit} == true ]]; then
                break
            fi
        done
            
        #Goto the selected option
        case ${docker__myChoice} in
            1)  
                ${git__git_push__fpath} "${docker__git_current_branchName}"
                ;;
            2)  
                ${git__git_pull__fpath}
                ;;
            3)
                ${git__git_undo_last_unpushed_commit__fpath} "${docker__git_current_branchName}"
                ;;
            4)
                ${git__git_create_checkout_local_branch__fpath}

                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
                ;;
            5)
                ${git__git_delete_local_branch__fpath}

                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
                ;;
            6)
                ${git__git_tag_menu__fpath} "${docker__git_current_branchName}"
                ;;
            0)
                ${docker__enter_cmdline_mode__fpath} "${DOCKER__EMPTYSTRING}"
                ;;
            q)
                docker__exit_handler__sub
                ;;
        esac

        #Check if flag is given to break loop
        if [[ ${docker__parentWhileLoop_isExit} == true ]]; then
            break
        fi
    done
}

docker__exit_handler__sub() {
    #Set flag to true
    docker__childWhileLoop_isExit=true
    docker__parentWhileLoop_isExit=true

    #Move-down and clean 1 line
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
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



#---MAIN SUBROUTINE
main__sub() {
    docker__get_source_fullpath__sub

    docker__load_source_files__sub

    docker__load_constants__sub

    docker__init_variables__sub

    git__menu_sub
}



#---EXECUTE
main__sub