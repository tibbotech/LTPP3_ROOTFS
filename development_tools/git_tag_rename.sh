#!/bin/bash -m
#Remark: by using '-m' the INTERRUPT executed here will NOT propagate to the UPPERLAYER scripts

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

docker__load_constants__sub() {
    DOCKER__MARK_AS_LOCAL="(${DOCKER__FG_LIGHTGREY}l${DOCKER__NOCOLOR})"
    DOCKER__MARK_AS_REMOTE="(${DOCKER__FG_LIGHTGREY}r${DOCKER__NOCOLOR})"
    DOCKER__MARK_AS_BOTH="(${DOCKER__FG_LIGHTGREY}b${DOCKER__NOCOLOR})"

    DOCKER__MENUTITLE="Git Rename ${DOCKER__FG_BROWN94}Local${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}/${DOCKER__NOCOLOR}${DOCKER__FG_BROWN137}Remote${DOCKER__NOCOLOR} Tag"
    DOCKER__CHOOSETAG_REMARKS="${DOCKER__FOURSPACES}${DOCKER__FG_LIGHTGREY}l${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}local tag${DOCKER__NOCOLOR}\n"
    DOCKER__CHOOSETAG_REMARKS+="${DOCKER__FOURSPACES}${DOCKER__FG_LIGHTGREY}r${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}remote tag${DOCKER__NOCOLOR}\n"
    DOCKER__CHOOSETAG_REMARKS+="${DOCKER__FOURSPACES}${DOCKER__FG_LIGHTGREY}b${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}local & remote tag${DOCKER__NOCOLOR}"
    DOCKER__CHOOSETAG_MENUOPTIONS="${DOCKER__FOURSPACES_Q_QUIT}"
    DOCKER__CHOOSETAG__MATCHPATTERN="${DOCKER__QUIT}"
    DOCKER__CHOOSETAG__READDIALOG="Choose tag: "

    DOCKER__SUMMARY_TITLE="${DOCKER__FG_ORANGE203}Summary${DOCKER__NOCOLOR}"

    DOCKER__CONFIRMATION_READDIALOG="Do you wish to continue (${DOCKER__Y_SLASH_N_SLASH_B_SLASH_Q})? "

    DOCKER__RENAME_TAG="rename tag"
}

docker__init_variables__sub() {
    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_0}

    docker__localTag_arr=()
    docker__remoteTag_arr=()
    docker__totalTag_arr=()
    docker__diffLocalTag_arr=()
    docker__diffRemoteTag_arr=()
    docker__uniqtotalTag_arr=()
    docker__markedtotalTag_arr=()

    docker__markedtotalTag_arrIndex=0

    docker__uniqTotalTag_string=${DOCKER__EMPTYSTRING}
    docker__uniqtotalTag_arrItem=${DOCKER__EMPTYSTRING}

    #Remark:
    #   The 'docker__result_from_output' could be a key-input or selected table-item.
    docker__result_from_output=${DOCKER__EMPTYSTRING}
    #Remark:
    #   'tot_numOfLines' retrieved from 'docker__result_from_output' representing the
    #       total number of lines of the table drawn within 
    #        'show_pathContent_w_selection__func'.
    #   Note: this value may be needed in case the above mentioned table
    #       needs to be cleared.
    docker__totNumOfLines_from_output=0

    docker__full_commitHash=${DOCKER__EMPTYSTRING}
    docker__marker_chosen=${DOCKER__EMPTYSTRING}
    docker__tag_w_marker_chosen=${DOCKER__EMPTYSTRING}
    docker__tag_chosen=${DOCKER__EMPTYSTRING}
    docker__tag_new=${DOCKER__EMPTYSTRING}
    docker__tag_new_bck=${DOCKER__EMPTYSTRING}

    docker__errMsg=${DOCKER__EMPTYSTRING}
    docker__stdErr=${DOCKER__EMPTYSTRING}
    docker__summaryMsg=${DOCKER__EMPTYSTRING}
    docker__summaryTitle=${DOCKER__EMPTYSTRING}

    docker__exitCode=0
}

docker__rename_tag_handler__sub() {
    #Define variables
    local answer=${DOCKER__EMPTYSTRING}
    local confirmation_warning=${DOCKER__EMPTYSTRING}

    local printf_msg=${DOCKER__EMPTYSTRING}
    local printf_subjectMsg=${DOCKER__EMPTYSTRING}

    local git_cmd=${DOCKER__EMPTYSTRING}

    local newTag_isAlready_inUse=false
    local tag_isLocal=false
    local tag_isRemote=false

    local nextPhase=${DOCKER__EMPTYSTRING}



#Goto phase: START
goto__func START



@START:
    docker__tibboHeader_prepend_numOfLines=${DOCKER__NUMOFLINES_2}

    goto__func PRECHECK



@PRECHECK:
    #Check if the current directory is a git-repository
    docker__stdErr=`${GIT__CMD_GIT_BRANCH} 2>&1 > /dev/null`
    if [[ ! -z ${docker__stdErr} ]]; then   #not a git-repository
        goto__func EXIT_PRECHECK_FAILED  #goto next-phase
    else    #is a git-repository
        goto__func GET_UNIQ_TAGS
    fi


@GET_UNIQ_TAGS:
    #Remove files
    if [[ -f ${git__git_tag_rename_out__fpath} ]]; then
        rm ${git__git_tag_rename_out__fpath}
    fi

    #Get local tags
    readarray -t docker__localTag_arr < <(git__get_tags__func "${GIT__LOCATION_LOCAL}")

    #Get remote tags
    readarray -t docker__remoteTag_arr < <(git__get_tags__func "${GIT__LOCATION_REMOTE}")

    #Combine 'docker__localTag_arr' and 'docker__remoteTag_arr'
    docker__totalTag_arr=("${docker__localTag_arr[@]}" "${docker__remoteTag_arr[@]}")

    #Remove duplicates and write to string 
    docker__uniqTotalTag_string=`printf "%s\n" "${docker__totalTag_arr[@]}" | sort | uniq | sed 's/\n//g'`

    #Convert string to array
    docker__uniqtotalTag_arr=(`echo ${docker__uniqTotalTag_string[@]}`)

    #Go to next-phase
    goto__func MARK_ARRAY_ELEMENTS_AND_WRITE_TO_FILE



@MARK_ARRAY_ELEMENTS_AND_WRITE_TO_FILE:
    #Mark the array-elements as local (l), remote (r), or both (b)
    #Remark:
    #   There is always a match
    docker__markedtotalTag_arrIndex=0
    for docker__uniqtotalTag_arrItem in "${docker__uniqtotalTag_arr[@]}"
    do
        tag_isLocal=`checkForMatch_of_pattern_within_1darray__func "${docker__uniqtotalTag_arrItem}" \
                        "${docker__localTag_arr[@]}"`

        tag_isRemote=`checkForMatch_of_pattern_within_1darray__func "${docker__uniqtotalTag_arrItem}" \
                        "${docker__remoteTag_arr[@]}"`
        if [[ ${tag_isLocal} = true ]] && [[ ${tag_isRemote} = false ]]; then
            docker__markedtotalTag_arr[docker__markedtotalTag_arrIndex]="${docker__uniqtotalTag_arrItem} ${DOCKER__MARK_AS_LOCAL}"
        elif [[ ${tag_isLocal} = false ]] && [[ ${tag_isRemote} = true ]]; then
            docker__markedtotalTag_arr[docker__markedtotalTag_arrIndex]="${docker__uniqtotalTag_arrItem} ${DOCKER__MARK_AS_REMOTE}"
        else    #tag_isLocal = true &&  tag_isRemote = tru
            docker__markedtotalTag_arr[docker__markedtotalTag_arrIndex]="${docker__uniqtotalTag_arrItem} ${DOCKER__MARK_AS_BOTH}"
        fi

        docker__markedtotalTag_arrIndex=$((docker__markedtotalTag_arrIndex + 1))
    done

    #Write to file
    printf '%s\n' "${docker__markedtotalTag_arr[@]}" > ${git__git_tag_rename_out__fpath}

    #Go to next-phase
    goto__func SHOW_AND_CHOOSE_TAG



@SHOW_AND_CHOOSE_TAG:
    #Show file-content
    show_pathContent_w_selection__func "${git__git_tag_rename_out__fpath}" \
                    "${DOCKER__EMPTYSTRING}" \
                    "${DOCKER__MENUTITLE}" \
                    "${DOCKER__CHOOSETAG_REMARKS}" \
                    "${DOCKER__EMPTYSTRING}" \
                    "${DOCKER__CHOOSETAG_MENUOPTIONS}" \
                    "${DOCKER__CHOOSETAG__MATCHPATTERN}" \
                    "${DOCKER__ECHOMSG_NORESULTS_FOUND}" \
                    "${DOCKER__CHOOSETAG__READDIALOG}" \
                    "${DOCKER__EMPTYSTRING}" \
                    "${DOCKER__EMPTYSTRING}" \
                    "${DOCKER__TABLEROWS_10}" \
                    "${DOCKER__FALSE}" \
                    "${docker__show_pathContent_w_selection_func_out__fpath}" \
                    "${docker__tibboHeader_prepend_numOfLines}" \
                    "${DOCKER__TRUE}"

    #Get the exitcode just in case a Ctrl-C was pressed in function 'show_pathContent_w_selection__func'
    docker__exitCode=$?
    if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
        exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
    fi

    #Get docker__result_from_output
    docker__result_from_output=`retrieve_line_from_file__func "${DOCKER__LINENUM_1}" \
                    "${docker__show_pathContent_w_selection_func_out__fpath}"`
    docker__totNumOfLines_from_output=`retrieve_line_from_file__func "${DOCKER__LINENUM_2}" \
                    "${docker__show_pathContent_w_selection_func_out__fpath}"`

    #Move-down and clean
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    #Handle 'docker__result_from_output'
    case "${docker__result_from_output}" in
        ${DOCKER__QUIT})    #abort
            goto__func EXIT_SUCCESSFUL
            ;;
        *)
            docker__tag_w_marker_chosen="${docker__result_from_output}"

            docker__tag_chosen=`echo "${docker__tag_w_marker_chosen}" | awk '{print $1}'`
            docker__marker_chosen=`echo "${docker__tag_w_marker_chosen}" | awk '{print $2}'`

            goto__func SHOW_RENAMETO_READDIALOG

            break
            ;;
    esac



@SHOW_RENAMETO_READDIALOG:
    #Initialize variables
    docker__semiColonVal=${DOCKER__EMPTYSTRING}

    #Update read-dialog
    docker__renameTo_readDialog="---:${DOCKER__INPUT}: Rename "
    docker__renameTo_readDialog+="${DOCKER__FG_LIGHTGREY}${docker__tag_chosen}${DOCKER__NOCOLOR} "
    docker__renameTo_readDialog+="to "
    docker__renameTo_readDialog+="($DOCKER__SEMICOLON_BACK_CLEAR_COLORED): "

    #Start loop
    while true
    do
        #Show read-dialog
        readDialog_w_Output__func "${docker__renameTo_readDialog}" \
                        "${docker__tag_new}" \
                        "${docker__readDialog_w_Output__func_out__fpath}" \
                        "${DOCKER__NUMOFLINES_1}" \
                        "${DOCKER__NUMOFLINES_0}"

        #Get the exitcode just in case a Ctrl-C was pressed in function 'readDialog_w_Output__func'
        docker__exitCode=$?
        if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
            exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
        fi

        #Get docker__result_from_output
        docker__tag_new=`retrieve_line_from_file__func "${DOCKER__LINENUM_1}" \
                        "${docker__readDialog_w_Output__func_out__fpath}"`
        docker__semiColonVal=`retrieve_line_from_file__func "${DOCKER__LINENUM_2}" \
                        "${docker__readDialog_w_Output__func_out__fpath}"`
        #Handle 'docker__tag_new'
        case "${docker__semiColonVal}" in
            ${DOCKER__SEMICOLON_BACK})  #go back
                goto__func SHOW_AND_CHOOSE_TAG

                break
                ;;
            *)  #all other cases
                if [[ ! -z ${docker__tag_new} ]]; then  #is Not an Empty String
                    #Check if 'docker__tag_new' is already in-use
                    newTag_isAlready_inUse=`checkForMatch_of_pattern_within_1darray__func \
                        "${docker__tag_new}" \
                        "${docker__uniqtotalTag_arr[@]}"`
                    if [[ ${newTag_isAlready_inUse} == false ]]; then   #is Not in-use
                        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                        goto__func CONFIRMATION_TO_PROCEED

                        break
                    else    #is already in-use
                        #Update error-message
                        docker__errMsg="${DOCKER__ERROR}: tag "
                        docker__errMsg+="${DOCKER__FG_LIGHTGREY}${docker__tag_new}${DOCKER__NOCOLOR} "
                        docker__errMsg+="is already in-use"
                        
                        #Show error-message
                        show_msg_wo_menuTitle_w_PressAnyKey__func "${docker__errMsg}" \
                                "${DOCKER__NUMOFLINES_1}" \
                                "${DOCKER__TIMEOUT_10}" \
                                "${DOCKER__NUMOFLINES_1}" \
                                "${DOCKER__NUMOFLINES_0}"

                        #Move-up and clean
                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_5}"
                    fi
                else    #is an Empty String
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                fi
                ;;
        esac
    done

    goto__func CONFIRMATION_TO_PROCEED



@CONFIRMATION_TO_PROCEED:
    #Update warning-message
    if [[ "${docker__marker_chosen}" == "${DOCKER__MARK_AS_LOCAL}" ]]; then
        docker__summaryTitle="Rename ${DOCKER__FG_BROWN94}local${DOCKER__NOCOLOR} tag"
    elif [[ "${docker__marker_chosen}" == "${DOCKER__MARK_AS_REMOTE}" ]]; then
        docker__summaryTitle="Rename ${DOCKER__FG_BROWN137}remote${DOCKER__NOCOLOR} tag"
    else    #docker__marker_chosen = DOCKER__MARK_AS_BOTH
        docker__summaryTitle="Rename ${DOCKER__FG_BROWN94}local${DOCKER__NOCOLOR} and ${DOCKER__FG_BROWN137}remote${DOCKER__NOCOLOR} tag"
    fi

	#Compose 'docker__summaryMsg'
	docker__summaryMsg="${DOCKER__FOURSPACES}From:${DOCKER__ONESPACE}${DOCKER__FG_LIGHTGREY}${docker__tag_chosen}${DOCKER__NOCOLOR}\n"
	docker__summaryMsg+="${DOCKER__FOURSPACES}To:${DOCKER__THREESPACES}${DOCKER__FG_LIGHTGREY}${docker__tag_new}${DOCKER__NOCOLOR}\n"


	#Show summary
	show_msg_w_menuTitle_only_func "${docker__summaryTitle}" \
						"${docker__summaryMsg}" \
						"${DOCKER__ZEROSPACE}" \
						"${DOCKER__NUMOFLINES_0}" \
						"${DOCKER__NUMOFLINES_0}" \
						"${DOCKER__NUMOFLINES_0}" \
						"${DOCKER__NUMOFLINES_1}"

    #Show question
    while true
    do
        #Show question
        read -N1 -p "${DOCKER__CONFIRMATION_READDIALOG}" answer

        #Check if 'answer' is Not an Empty String
        if [[ ! -z ${answer} ]]; then   #not an Empty String
            if [[ ${answer} =~ ${DOCKER__REGEX_YNBQ} ]]; then    #match was found
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                #Handle 'answer'
                case "${answer}" in
                    ${DOCKER__QUIT})    #abort
                        goto__func EXIT_SUCCESSFUL
                        ;;
                    ${DOCKER__BACK})    #abort
                        goto__func SHOW_RENAMETO_READDIALOG
                        ;;
                    ${DOCKER__YES})    #back
                        goto__func RENAME_TAG__PRINT_START
                        ;;
                    ${DOCKER__NO})    #back
                        goto__func SHOW_AND_CHOOSE_TAG
                        ;;
                esac

                break
            else    #no match was found
                if [[ ${answer} != "${DOCKER__ENTER}" ]]; then
                    moveToBeginning_and_cleanLine__func
                else
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                fi
            fi
        fi
    done



@RENAME_TAG__PRINT_START:
    #Update message
    printf_subjectMsg="---:${DOCKER__START}: ${DOCKER__RENAME_TAG}"
    #Show message
    show_msg_only__func "${printf_subjectMsg}" "${DOCKER__NUMOFLINES_2}" "${DOCKER__NUMOFLINES_0}"

    #Choose next-phase
    if [[ "${docker__marker_chosen}" == "${DOCKER__MARK_AS_REMOTE}" ]]; then
        goto__func RENAME_TAG__EXEC_CMD_PHASE0
    else
        goto__func RENAME_TAG__EXEC_CMD_PHASE1
    fi



@RENAME_TAG__EXEC_CMD_PHASE0:
    #create old tag (docker__tag_chosen)
    #Remark:
    #   This is necessary because 'docker__tag_chosen' is only present at Remote and Not at Local.
    #1. Define command
    git_cmd="${GIT__CMD_GIT_TAG} ${docker__tag_chosen}"
    #2. Execute command
    eval ${git_cmd}

    #3. Set 'nextPhase'
    nextPhase="RENAME_TAG__EXEC_CMD_PHASE1"

    #4. Go to next-phase
    goto__func VALIDATE_EXITCODE



@RENAME_TAG__EXEC_CMD_PHASE1:
    #Create new tag (docker__tag_new) from old tag (docker__tag_chosen)
    #1. Define command
    git_cmd="${GIT__CMD_GIT_TAG} ${docker__tag_new} ${docker__tag_chosen}"
    #2. Execute command
    eval ${git_cmd}

    #3. Set 'nextPhase'
    nextPhase="RENAME_TAG__EXEC_CMD_PHASE2"

    #4. Go to next-phase
    goto__func VALIDATE_EXITCODE



@RENAME_TAG__EXEC_CMD_PHASE2:
    #Delete old tag (docker__tag_chosen)
    #1. Define command
    git_cmd="${GIT__CMD_GIT_TAG} -d ${docker__tag_chosen}"
    #2. Execute command
    eval ${git_cmd}

    #3. Set 'nextPhase'
    if [[ "${docker__marker_chosen}" == "${DOCKER__MARK_AS_LOCAL}" ]]; then
        nextPhase="GET_UNIQ_TAGS"
    else
        nextPhase="RENAME_TAG__EXEC_CMD_PHASE3"
    fi

    #4. Go to next-phase
    goto__func VALIDATE_EXITCODE



@RENAME_TAG__EXEC_CMD_PHASE3:
    #Sync changes of old tag (docker__tag_chosen) to remote
    #1. Define command
    git_cmd="${GIT__CMD_GIT_PUSH} origin :refs/tags/${docker__tag_chosen}"
    #2. Execute command
    eval ${git_cmd}

    #3. Set 'nextPhase'
    nextPhase="RENAME_TAG__EXEC_CMD_PHASE4"

    #4. Go to next-phase
    goto__func VALIDATE_EXITCODE



@RENAME_TAG__EXEC_CMD_PHASE4:
    #Send new tag (docker__tag_new) to remote
    #1. Define command
    git_cmd="${GIT__CMD_GIT_PUSH} origin ${docker__tag_new}"
    #2. Execute command
    eval ${git_cmd}

    #3. Set 'nextPhase'
    if [[ "${docker__marker_chosen}" == "${DOCKER__MARK_AS_BOTH}" ]]; then
        nextPhase="GET_UNIQ_TAGS"
    else
        nextPhase="RENAME_TAG__EXEC_CMD_PHASE5"
    fi

    #4. Go to next-phase
    goto__func VALIDATE_EXITCODE



@RENAME_TAG__EXEC_CMD_PHASE5:
    #Delete old tag (docker__tag_chosen)
    #1. Define command
    git_cmd="${GIT__CMD_GIT_TAG} -d ${docker__tag_new}"
    #2. Execute command
    eval ${git_cmd}

    #3. Set 'nextPhase'
    nextPhase="GET_UNIQ_TAGS"

    #4. Go to next-phase
    goto__func VALIDATE_EXITCODE



@VALIDATE_EXITCODE:
    #Check exit-code
    exitCode=$?
    if [[ ${exitCode} -eq 0 ]]; then
        #Update message
        printf_msg="------:${DOCKER__EXECUTED}: ${git_cmd} (${DOCKER__STATUS_LDONE})"
        #Show message
        show_msg_only__func "${printf_msg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
    else
        #Update message
        printf_msg="------:${DOCKER__EXECUTED}: ${git_cmd} (${DOCKER__STATUS_LFAILED})"
        #Show message
        show_msg_only__func "${printf_msg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"

        #Update 'nextPhase'
        nextPhase="GET_UNIQ_TAGS"
    fi 

    #Go to next-phase
    if [[ ${nextPhase} == "GET_UNIQ_TAGS" ]]; then
        if [[ ${exitCode} -eq 0 ]]; then
            #Update message
            printf_subjectMsg="---:${DOCKER__COMPLETED}: ${DOCKER__RENAME_TAG}"
            #Show message
            show_msg_only__func "${printf_subjectMsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
        else
            printf_subjectMsg="---:${DOCKER__STOPPED}: ${DOCKER__RENAME_TAG}"
            #Show message
            show_msg_only__func "${printf_subjectMsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
        fi 

        #Reset variable
        docker__tag_new=${DOCKER__EMPTYSTRING}
    fi

    goto__func ${nextPhase}



@EXIT_PRECHECK_FAILED:
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
    echo -e "${DOCKER__ERROR}: ${docker__stdErr}"
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_0}"
    
    exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_2}"



@EXIT_SUCCESSFUL:
    exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_2}"
}



#---MAIN SUBROUTINE
main_sub() {
    docker__get_source_fullpath__sub

    docker__load_global_fpath_paths__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__rename_tag_handler__sub
}



#---EXECUTE
main_sub
