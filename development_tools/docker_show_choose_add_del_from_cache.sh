#!/bin/bash -m
#Remark: by using '-m' the INTERRUPT executed here will NOT propagate to the UPPERLAYER scripts
#---INPUT ARGS
menuTitle__input=${1}
info__input=${2}
menuOptions1__input=${3}
menuOptions2__input=${4}
menuOptions3__input=${5}
matchPattern2__input=${6}
matchPattern3__input=${7}
readInputDialog1__input=${8}    #read dialog for 'Choose'
readInputDialog2__input=${9}    #read dialog for 'Add'
readInputDialog3__input=${10}    #read dialog for 'Del'
exported_env_var_fpath__input=${11}   #e.g. exported_env_var.txt
target_cacheFpath=${12} #e.g., docker__linkCacheFpath, docker__checkoutCacheFpath, OR docker__linkCheckoutProfileCacheFpath
allThreeCacheFpaths__input=${13} #e.g., docker__linkCacheFpath, docker__checkoutCacheFpath, AND docker__linkCheckoutProfileCacheFpath
outFpath__input=${14}    #e.g. docker_show_choose_add_del_from_cache.out
dockerfile_fpath__input=${15}    #e.g. repository:tag
exp_env_var_type__input=${16}
weblink_check_timeOut__input=${17}
tibboHeader_prepend_numOfLines__input=${18}



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

docker__init_variables__sub() {
    docker__linkStatusArr=()
    docker__linkStatus_arrIndex=0
    docker__linkStatus_arrItem=${DOCKER__EMPTYSTRING}
    docker__linkStatus_arrLen=0

    docker__line=${DOCKER__EMPTYSTRING}
    docker__checkoutCacheFpath=${DOCKER__EMPTYSTRING}
    docker__linkCacheFpath=${DOCKER__EMPTYSTRING}
    docker__linkCheckoutProfileCacheFpath=${DOCKER__EMPTYSTRING}

    docker__cacheFpath_lineNum=0
    docker__cacheFpath_lineNum_base=0
    docker__cacheFpath_lineNum_min=0
    docker__cacheFpath_lineNum_min_bck=0
    docker__cacheFpath_lineNum_max=0
    docker__cacheFpath_numOfLines=0

    docker__table_index_abs=0
    docker__table_index_rel=0

    docker__colnum=0

    docker__fixed_numOfLines=0
    docker__info_numOfLines=0
    docker__lineNum_abs=0
    docker__menuOptions_numOfLines=0
    docker__menuTitle_numOfLines=0
    docker__readInputDialog1_numOfLines=0
    docker__readInputDialog2_numOfLines=0
    docker__readInputDialog3_numOfLines=0
    docker__subTot_numOfLines=0
    docker__tot1_numOfLines=0
    docker__tot2_numOfLines=0
    docker__tot3_numOfLines=0
    docker__tot_numOfLines=0

    docker__linkCheckout_profile_menuSel=${DOCKER__EMPTYSTRING}

    docker__env_var_sel=${DOCKER__EMPTYSTRING}
    docker__env_var_checkout=${DOCKER__EMPTYSTRING}
    docker__env_var_link=${DOCKER__EMPTYSTRING}
    docker__env_var_linkColonCheckout=${DOCKER__EMPTYSTRING}
    docker__env_var_linkSpaceCheckout=${DOCKER__EMPTYSTRING}
    docker__env_var_repositoryTag_isFound=false
 
    docker__info=${DOCKER__EMPTYSTRING}

    docker__keyInput=${DOCKER__EMPTYSTRING}
    docker__keyInput_add=${DOCKER__EMPTYSTRING}
    docker__readInputDialog=${DOCKER__EMPTYSTRING}
    docker__subTotInput_leftOfLastComma=${DOCKER__EMPTYSTRING}
    docker__subTotInput_leftOfLastComma_bck=${DOCKER__EMPTYSTRING}
    docker__subTotInput_rightOfLastComma=${DOCKER__EMPTYSTRING}
    docker__totInput=${DOCKER__EMPTYSTRING}

    docker__repositoryTag=${DOCKER__EMPTYSTRING}

    docker__flag_refresh_all=false
    docker__flag_turnPage_isAllowed=false
}

docker__retrieve_all_cacheFpaths__sub() {
    docker__linkCacheFpath=`echo "${allThreeCacheFpaths__input}" | cut -d"${SED__RS}" -f1`
    docker__checkoutCacheFpath=`echo "${allThreeCacheFpaths__input}" | cut -d"${SED__RS}" -f2`
    docker__linkCheckoutProfileCacheFpath=`echo "${allThreeCacheFpaths__input}" | cut -d"${SED__RS}" -f3`
}

docker__remove_files__sub() {
    #Remove file if present
    if [[ -f ${outFpath__input} ]]; then
        rm ${outFpath__input}
    fi
}

docker__remove_allEmptyLines_and_append_caretReturn__sub() {
    remove_allEmptyLines_within_file__func "${exported_env_var_fpath__input}"
    remove_allEmptyLines_within_file__func "${docker__linkCacheFpath}"
    remove_allEmptyLines_within_file__func "${docker__checkoutCacheFpath}"
    remove_allEmptyLines_within_file__func "${docker__linkCheckoutProfileCacheFpath}"
    remove_allEmptyLines_within_file__func "${dockerfile_fpath__input}"

    append_caretReturn_ifNotPresent_within_file__func "${exported_env_var_fpath__input}"
    append_caretReturn_ifNotPresent_within_file__func "${docker__linkCacheFpath}"
    append_caretReturn_ifNotPresent_within_file__func "${docker__checkoutCacheFpath}"
    append_caretReturn_ifNotPresent_within_file__func "${docker__linkCheckoutProfileCacheFpath}"
    append_caretReturn_ifNotPresent_within_file__func "${dockerfile_fpath__input}"
}

docker__reset_variables__sub() {
    docker__env_var_sel=${DOCKER__EMPTYSTRING}
    docker__env_var_checkout=${DOCKER__EMPTYSTRING}
    docker__env_var_link=${DOCKER__EMPTYSTRING}
    docker__env_var_linkColonCheckout=${DOCKER__EMPTYSTRING}
    docker__env_var_linkSpaceCheckout=${DOCKER__EMPTYSTRING}
    docker__env_var_repositoryTag_isFound=false
}

docker__trim_info_toFit_within_specified_windowSize__sub() {
    docker__info=`trim_string_toFit_specified_windowSize__func "${info__input}" "${DOCKER__TABLEWIDTH}" "${DOCKER__TRUE}"`
}

docker__calc_numOfLines_of_inputArgs__sub() {
    #1. MENUTITLE / INFO / MENUOPTIONS / READINPUT DIALOGS / FIXED 
    #Get the number of lines for each object
    docker__menuTitle_numOfLines=`get_numOfLines_for_specified_string_or_file__func "${menuTitle__input}"`
    docker__info_numOfLines=`get_numOfLines_for_specified_string_or_file__func "${docker__info}"`
    docker__menuOptions_numOfLines=`get_numOfLines_for_specified_string_or_file__func "${menuOptions1__input}"`
    docker__readInputDialog1_numOfLines=`get_numOfLines_for_specified_string_or_file__func "${readInputDialog1__input}"`
    docker__readInputDialog2_numOfLines=`get_numOfLines_for_specified_string_or_file__func "${readInputDialog2__input}"`
    docker__readInputDialog3_numOfLines=`get_numOfLines_for_specified_string_or_file__func "${readInputDialog3__input}"`
    docker__fixed_numOfLines=${DOCKER__NUMOFLINES_6}    #allOther means: horizontal lines, empty string lines, prev-next line.

    #Calculate unchanged number of lines
    docker__subTot_numOfLines=$((docker__menuTitle_numOfLines + docker__info_numOfLines + docker__menuOptions_numOfLines + docker__fixed_numOfLines + DOCKER__TABLEROWS_10))

    #Calculate the total number of lines for 3 situations:
    #1. HASH (e.g. Choose)
    docker__tot1_numOfLines=$((docker__subTot_numOfLines + docker__readInputDialog1_numOfLines))
    #2. PLUS (e.g. Add)
    docker__tot2_numOfLines=$((docker__subTot_numOfLines + docker__readInputDialog2_numOfLines))
    #3. MINUS (e.g. Del)
    docker__tot3_numOfLines=$((docker__subTot_numOfLines + docker__readInputDialog3_numOfLines))

    #2. FILE (Initial)
    if [[ -s ${target_cacheFpath} ]]; then
        docker__cacheFpath_numOfLines=`get_numOfLines_for_specified_string_or_file__func "${target_cacheFpath}"`
    else
        docker__cacheFpath_numOfLines=0
    fi
}

docker__prev_next_var_set__sub() {
    docker__prev_only_print="${DOCKER__ONESPACE_PREV}"

    docker__oneSpacePrev_len=`get_stringlen_wo_regEx__func "${DOCKER__ONESPACE_PREV}"`
    docker__oneSpaceNext_len=`get_stringlen_wo_regEx__func "${DOCKER__ONESPACE_NEXT}"`
    docker__space_between_prev_and_next_len=$(( DOCKER__TABLEWIDTH - (docker__oneSpacePrev_len + docker__oneSpaceNext_len) - 1 ))
    docker__space_between_prev_and_next=`duplicate_char__func "${DOCKER__ONESPACE}" "${docker__space_between_prev_and_next_len}"`
    docker__prev_spaces_next_print="${DOCKER__ONESPACE_PREV}${docker__space_between_prev_and_next}${DOCKER__ONESPACE_NEXT}"

    docker__space_between_leftBoundary_and_next_len=$(( DOCKER__TABLEWIDTH - docker__oneSpacePrev_len - 1 ))
    docker__space_between_leftBoundary_and_next=`duplicate_char__func "${DOCKER__ONESPACE}" "${docker__space_between_leftBoundary_and_next_len}"`
    docker__next_only_print="${docker__space_between_leftBoundary_and_next}${DOCKER__ONESPACE_NEXT}"
}

docker__retrieve__exported_env_var__and__flag_repositoryTag_isFound__sub() {
    #Set 'docker__env_var_repositoryTag_isFound = true'
    docker__env_var_repositoryTag_isFound=true

    #Get 'docker__env_var_link' from 'exported_env_var_fpath__input'
    docker__env_var_link=`retrieve_env_var_link_from_file__func "${dockerfile_fpath__input}" "${exported_env_var_fpath__input}"`
    if [[ -z ${docker__env_var_link} ]]; then
        docker__env_var_repositoryTag_isFound=false
    fi


    #Get 'docker__env_var_checkout' from 'exported_env_var_fpath__input'
    docker__env_var_checkout=`retrieve_env_var_checkout_from_file__func "${dockerfile_fpath__input}" "${exported_env_var_fpath__input}"`
    if [[ -z ${docker__env_var_checkout} ]]; then
        docker__env_var_repositoryTag_isFound=false
    fi

    #Define 'docker__env_var_linkColonCheckout'
    docker__env_var_linkColonCheckout="${docker__env_var_link}${DOCKER__COLON}${docker__env_var_checkout}"
}

docker__init_move_link_checkout_or_profile_to_top__sub() {
    #Check 'target_cacheFpath' exists and contains data
    if [[ ! -s ${target_cacheFpath} ]]; then
        return
    fi

    #Check if 'docker__env_var_link' and 'docker__env_var_checkout' are NOT Empty Strings
    if [[ ${docker__env_var_repositoryTag_isFound} == false ]]; then
        return
    fi
 
    case "${exp_env_var_type__input}" in
        ${DOCKER__LINK})
            docker__env_var_sel=${docker__env_var_link}
            ;;
        ${DOCKER__CHECKOUT})
            docker__env_var_sel=${docker__env_var_checkout}
            ;;
        ${DOCKER__LINKCHECKOUT_PROFILE})
            docker__env_var_sel=${docker__env_var_linkColonCheckout}
            ;;
    esac

    #Get the line-number of 'docker__env_var_link' within 'target_cacheFpath'
    docker__lineNum_abs=`retrieve_lineNum_from_file__func "${docker__env_var_sel}" "${target_cacheFpath}"`

    #Check if:
    # docker__lineNum_abs = 0: match not found.
    # OR
    # docker__lineNum_abs > 1: match found, but the matched value is not on line-number = 1.
    if [[ ${docker__lineNum_abs} -eq ${DOCKER__LINENUM_0} ]] || [[ ${docker__lineNum_abs} -gt ${DOCKER__LINENUM_1} ]]; then
        #Delete 'line' specified by 'docker__lineNum_abs'
        delete_lineNum_from_file__func "${docker__lineNum_abs}" "${DOCKER__EMPTYSTRING}" "${target_cacheFpath}"

        #Insert 'line' at the top of the file.
        insert_string_into_file_at_specified_lineNum__func "${docker__env_var_sel}" "${DOCKER__LINENUM_1}" "${target_cacheFpath}" "${DOCKER__TRUE}"
    fi

    #IMPORTANT: double-check if 'docker__env_var_link', 'docker__env_var_checkoutare present...
    #           ...in their respective cache-files (e.g., docker__linkCacheFpath and docker__checkoutCacheFpath).
    #If not present, then insert 'docker__env_var_link' and 'docker__env_var_checkout' into their cache-files.
    #Reason:
    #   It could be the case that in the 'link-checkout profile' cache-file, the 'link' and 'checkout' values are present.
    #   However,  the 'link' and/or 'checkout' cache-files these values are not present.
    #   By double-checking this, these values can be re-added to the 'link' and 'checkout' cache-files.
    #Remark:
    #   REMEMBER, do this only for 'exp_env_var_type__input = DOCKER__LINKCHECKOUT_PROFILE'
    if [[ ${exp_env_var_type__input} ==  ${DOCKER__LINKCHECKOUT_PROFILE} ]]; then
        #link
        local link_lineNum_found=`retrieve_lineNum_from_file__func "${docker__env_var_link}" "${docker__linkCacheFpath}"`
        if [[ ${link_lineNum_found} -eq ${DOCKER__NUMOFMATCH_0} ]]; then
            insert_string_into_file_at_specified_lineNum__func "${docker__env_var_link}" "${DOCKER__LINENUM_1}" "${docker__linkCacheFpath}" "${DOCKER__TRUE}"
        fi

        #Checkout
        local checkout_lineNum_found=`retrieve_lineNum_from_file__func "${docker__env_var_checkout}" "${docker__checkoutCacheFpath}"`
        if [[ ${checkout_lineNum_found} -eq ${DOCKER__NUMOFMATCH_0} ]]; then
            insert_string_into_file_at_specified_lineNum__func "${docker__env_var_checkout}" "${DOCKER__LINENUM_1}" "${docker__checkoutCacheFpath}" "${DOCKER__TRUE}"
        fi
    fi

    #Reset all variables
    # docker__reset_variables__sub
}

docker__show_menu_handler__sub() {
    #Check if 'tibboHeader_prepend_numOfLines__input' is an Empty String
    if [[ -z ${tibboHeader_prepend_numOfLines__input} ]]; then
        tibboHeader_prepend_numOfLines__input=${DOCKER__NUMOFLINES_2}
    fi

    #Print Tibbo-title
    load_tibbo_title__func "${tibboHeader_prepend_numOfLines__input}"

    #Initialization
    docker__readInputDialog=${readInputDialog1__input}
    docker__cacheFpath_lineNum_base=0
    docker__cacheFpath_lineNum_min_bck=0
    docker__cacheFpath_lineNum_min=0
    docker__cacheFpath_lineNum_max=0
    docker__flag_turnPage_isAllowed=false

    #Initialize sequence-related variables
    docker__seqNum_init__sub

    while true
    do
        #Check if 'docker__cacheFpath_lineNum_min' has changed by comparing the current value with the backup'ed value.
        if [[ ${docker__flag_turnPage_isAllowed} == true ]]; then
            #Print a horizontal line
            duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

            #Print menu-title
            show_centered_string__func "${menuTitle__input}" "${DOCKER__TABLEWIDTH}"

            #Print a horizontal line
            duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

            #Show file-cotent
            docker__show_fileContent__sub

            #Move-down and clean line
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            #Show prev-next line
            docker__show_prev_next_handler__sub

            #Show line-number range in between prev and next
            docker__show_lineNumRange_between_prev_and_next__sub

            #Print a horizontal line
            duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

            #show location of the cache-file
            echo -e "${docker__info}"

            #Print a horizontal line
            duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

            #Print menu-options
            echo -e "${menuOptions1__input}"
            
            #Print a horizontal line
            duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        fi
        
        #Show choose dialog
        docker__menuOptions_handler__sub
    done
}
docker__seqNum_init__sub() {
    #Initialization
    docker__cacheFpath_lineNum_base=0
    docker__cacheFpath_lineNum_min=0

    #Update sequence-related values
    #1. docker__cacheFpath_lineNum_base
    #2. docker__cacheFpath_lineNum_min_bck
    #3. docker__cacheFpath_lineNum_min
    #4. docker__cacheFpath_lineNum_max
    #5. docker__flag_turnPage_isAllowed
    docker__seqNum_handler__sub "${docker__cacheFpath_lineNum_base}" \
                        "${docker__cacheFpath_lineNum_min}" \
                        "${DOCKER__TABLEROWS_10}" \
                        "${DOCKER__NEXT}"
}
docker__show_fileContent__sub() {
    #Show cursor
    cursor_hide__func

    #Disable keyboard-input
    disable_keyboard_input__func

    #Define variables
    local line=${DOCKER__EMPTYSTRING}
    local line_subst=${DOCKER__EMPTYSTRING}
    local line_subst2=${DOCKER__EMPTYSTRING}
    local line_subst2_left=${DOCKER__EMPTYSTRING}
    local line_subst2_right=${DOCKER__EMPTYSTRING}
    local line_subst3=${DOCKER__EMPTYSTRING}
    local line_subst3_left=${DOCKER__EMPTYSTRING}
    local line_subst3_right=${DOCKER__EMPTYSTRING}
    local line_subst4=${DOCKER__EMPTYSTRING}
    local line_match=${DOCKER__EMPTYSTRING}
    local line_print=${DOCKER__EMPTYSTRING}
    local linkStatusArr_status=${DOCKER__EMPTYSTRING}

    local line_index=0
    local line_subst3_left_len=0
    local line_subst3_left_max=0
    local line_subst3_right_max=0

    local webLink_isAccessible=false
    local match_isFound=false

    #Initialization
    docker__cacheFpath_lineNum=0
    docker__table_index_abs=${docker__cacheFpath_lineNum_base}
    docker__table_index_rel=0

#---Make sure that all empty lines are removed except for the last empty line of the file
    docker__remove_allEmptyLines_and_append_caretReturn__sub

#---List file-content
    while read -ra line
    do
        #increment line-number
        docker__cacheFpath_lineNum=$((docker__cacheFpath_lineNum + 1))

        #Show filename
        if [[ ${docker__cacheFpath_lineNum} -ge ${docker__cacheFpath_lineNum_min} ]]; then
            if [[ ! -z ${line} ]]; then
                #Increment table index-number
                docker__table_index_abs=$((docker__table_index_abs + 1))
                docker__table_index_rel=$((docker__table_index_rel + 1))

                #Substitute 'http' with 'hxxp'
                #Remark:
                #   This substitution is required in order to eliminate the underlines for hyperlinks
                # line_subst=`subst_string_with_another_string__func "${line}" "${SED__HTTP}" "${SED__HXXP}"`
                line_subst=${line}


                #Define 'line_index'
                if [[ ${docker__readInputDialog} != ${readInputDialog3__input} ]]; then #Choose & Add
                    #Redefine 'docker__table_index_rel' in case its '10'
                    if [[ ${docker__table_index_rel} -eq ${DOCKER__TABLEROWS_10} ]]; then
                        docker__table_index_rel=${DOCKER__NUMOFMATCH_0}
                    fi

                    line_index="${DOCKER__FOURSPACES}${docker__table_index_rel}"
                    # if [[ ${docker__table_index_rel} -ne ${DOCKER__NUMOFMATCH_0} ]]; then
                    #     line_index="${DOCKER__FOURSPACES}${docker__table_index_rel}"
                    # else
                    #     line_index="${DOCKER__THREESPACES}${DOCKER__FG_LIGHTGREY}${DOCKER__LINENUM_1}${DOCKER__NOCOLOR}${docker__table_index_rel}"
                    # fi
                else    #Del
                    if [[ ${docker__table_index_abs} -lt ${DOCKER__NUMOFMATCH_10} ]]; then
                        line_index="${DOCKER__FOURSPACES}${docker__table_index_abs}"
                    else
                        line_index="${DOCKER__THREESPACES}${docker__table_index_abs}"
                    fi
                fi



                #Update 'line_subst2'
                line_subst2="${line_index}.${DOCKER__ONESPACE}${line_subst}"



                #Check if 'exported_env_var.txt' exists
                if [[ -f ${exported_env_var_fpath__input} ]]; then
                    #Get the repository:tag from 'dockerfile_fpath__input'
                    docker__repositoryTag=`retrieve_repositoryTag_from_dockerfile__func "${dockerfile_fpath__input}"`

                    if [[ ${exp_env_var_type__input} != ${DOCKER__LINKCHECKOUT_PROFILE} ]]; then
                        #Choose column number
                        if [[ ${exp_env_var_type__input} == ${DOCKER__LINK} ]]; then
                            docker__colnum=${DOCKER__COLNUM_2}
                        else    #exp_env_var_type__input = DOCKER__CHECKOUT
                            docker__colnum=${DOCKER__COLNUM_3}
                        fi

                        #Check for match
                        #Remark:
                        #   In this case 'line' represents 'docker__env_var_link' or 'docker__env_var_checkout'
                        match_isFound=`checkForMatch_pattern_of_a_column_within_file__func "${line}" \
                                "${docker__repositoryTag}" \
                                "${docker__colnum}" \
                                "${exported_env_var_fpath__input}"`
                    else
                        #Separate 'limk' from 'checkout'
                        docker__env_var_link=`echo "${line}" | rev | cut -d"${DOCKER__COLON}" -f2- | rev`
                        docker__env_var_checkout=`echo "${line}" | rev | cut -d"${DOCKER__COLON}" -f1 | rev`

                        #FIRST MATCH: check if a match can be found for 'docker__env_var_link'
                        match_isFound=`checkForMatch_multi_patterns_under_specified_columns_within_file__func "${docker__env_var_link}" \
                                "${docker__repositoryTag}" \
                                "${DOCKER__COLNUM_2}" \
                                "${docker__env_var_checkout}" \
                                "${docker__repositoryTag}" \
                                "${DOCKER__COLNUM_3}" \
                                "${exported_env_var_fpath__input}"`
                    fi

                    #Check if 'match_isFound = true'?
                    if [[ ${match_isFound} == true ]]; then #true
                        #Append '(cfg)' behind 'line_subst2' value
                        line_subst2="${line_subst2}${DOCKER__ONESPACE}${DOCKER__CONFIGURED}"
                    fi
                fi



                #Fit 'line_print' within the specified 'DOCKER__TABLEWIDTH'
                if [[ ${exp_env_var_type__input} != ${DOCKER__LINKCHECKOUT_PROFILE}  ]]; then
                    line_subst3=`trim_string_toFit_specified_windowSize__func "${line_subst2}" "${DOCKER__TABLEWIDTH}" "${DOCKER__TRUE}"`
                else
                    #Get the substring 'line_subst2_left' which is on the left-side of the last colon ':'
                    line_subst2_left=`echo "${line_subst2}" | rev | cut -d"${DOCKER__COLON}" -f2- | rev`
                    #Get the substring 'line_subst2_right' which is on the right-side of the last colon ':'
                    line_subst2_right=`echo "${line_subst2}" | rev | cut -d"${DOCKER__COLON}" -f1 | rev`

                    #Set the maximum window-size for 'line_subst2_left' and 'line_subst2_right'
                    #Remark:
                    #   This means that 'line_subst3_left_max' is 20 chars longer than 'line_subst3_right_max'
                    line_subst3_left_max=$(( (DOCKER__TABLEWIDTH/2) + DOCKER__TEN ))
                    # line_subst3_right_max=$(( (DOCKER__TABLEWIDTH/2) - DOCKER__TEN ))

                    #Get 'line_subst3_left'
                    line_subst3_left=`trim_string_toFit_specified_windowSize__func "${line_subst2_left}" "${line_subst3_left_max}" "${DOCKER__TRUE}"`

                    #Retrieve the current length of 'line_subst3_left'
                    line_subst3_left_len=`get_stringlen_wo_regEx__func "${line_subst3_left}"`

                    #Calculate 'line_subst3_right_max'
                    line_subst3_right_max=$(( DOCKER__TABLEWIDTH - line_subst3_left_len ))

                    #Get 'line_subst3_right'
                    line_subst3_right=`trim_string_toFit_specified_windowSize__func "${line_subst2_right}" "${line_subst3_right_max}" "${DOCKER__TRUE}"`

                    #Compose 'line_subst3'
                    line_subst3="${line_subst3_left}${DOCKER__BG_LIGHTGREY}${DOCKER__COLON}${DOCKER__NOCOLOR}${line_subst3_right}"
                fi



                #Only do this check if 'exp_env_var_type__input = DOCKER__LINK'
                if [[ ${exp_env_var_type__input} == ${DOCKER__LINK}  ]] && \
                        [[ ${weblink_check_timeOut__input} -ne ${DOCKER__NUMOFMATCH_0} ]]; then
                    #Get the status from 'docker__linkStatusArr' (if present)
                    linkStatusArr_status=`retrieve_data_specified_by_col_within_2Darray__func "${line}" "${DOCKER__COLNUM_2}" "${docker__linkStatusArr[@]}"`
                    if [[ ! -z ${linkStatusArr_status} ]]; then    #status was found in 'docker__linkStatusArr'
                        webLink_isAccessible=${linkStatusArr_status}
                    else    #could not find 'line' in 'docker__linkStatusArr'
                        #Check if web-link is reachable
                        webLink_isAccessible=`checkIf_webLink_isAccessible__func ${line} ${weblink_check_timeOut__input}`

                        #Update array
                        docker__linkStatusArr__add_data__sub "${line}" "${webLink_isAccessible}"
                    fi

                    #Define and set 'line_colored'
                    if [[ ${webLink_isAccessible} == true ]]; then
                        line_subst4=${DOCKER__FG_GREEN85}${DOCKER__STX}${line_subst3}${DOCKER__NOCOLOR}
                    else
                        line_subst4=${line_subst3}
                    fi
                else    #exp_env_var_type__input=DOCKER__CHECKOUT
                    #Do nothing
                    line_subst4=${line_subst3}
                fi



                #Update 'line_print'
                line_print=${line_subst4}



                #Print file-content with table index-number
                echo "${line_print}"
            fi
        fi

        #Break loop once the maximum allowed sequence number has been reached
        if [[ ${docker__cacheFpath_lineNum} -eq ${docker__cacheFpath_lineNum_max} ]]; then
            break
        fi
    done < ${target_cacheFpath}

#---Fill up table with Empty Lines (if needed)
    #This is necessary to fill up the table with 10 lines.
    while [[ ${docker__cacheFpath_lineNum} -lt ${docker__cacheFpath_lineNum_max} ]]
    do
        #increment line-number
        docker__cacheFpath_lineNum=$((docker__cacheFpath_lineNum + 1))

        #Print an Empty Line
        echo "${DOCKER__EMPTYSTRING}"
    done

    #Reset environment variables related parameters
    # docker__reset_variables__sub

    #Enable keyboard-input
    enable_keyboard_input__func

    #Show cursor
    cursor_show__func
}

docker__linkStatusArr__add_data__sub() {
    #Input args
    local link__input=${1}
    local status__input=${2}

    #Define variables
    local link_status="${link__input} ${status__input}"

    #Add to Array
    docker__linkStatusArr[docker__linkStatus_arrIndex]="${link_status}"

    #Increment index
    docker__linkStatus_arrIndex=$((docker__linkStatus_arrIndex + 1))
}

docker__show_prev_next_handler__sub() {
    #Check if the specified file contains less than or equal to 10 lines
    if [[ ${docker__cacheFpath_numOfLines} -le ${DOCKER__TABLEROWS_10} ]]; then #less than 10 lines
        #Don't show anything
        echo -e "${EMPTYSTRING}"
    else    #file contains more than 10 lines
        if [[ ${docker__cacheFpath_lineNum_min} -eq ${DOCKER__NUMOFMATCH_1} ]]; then   #range 1-10
            echo -e "${docker__next_only_print}"
        else    #all other ranges
            if [[ ${docker__cacheFpath_lineNum_max} -gt ${docker__cacheFpath_numOfLines} ]]; then   #last range value (e.g. 40-50)
                echo -e "${docker__prev_only_print}"
            else    #range 10-20, 20-30, 30-40, etc.
                echo -e "${docker__prev_spaces_next_print}"
            fi
        fi
    fi
}
docker__show_lineNumRange_between_prev_and_next__sub() {
    #Define the maximum range line-number
    #Remark:
    #   Whenever 'prev' or 'nexxt' is pressed, the maximum range line-number will also change.
    local lineNum_max=${docker__cacheFpath_lineNum_max}
    
    #Check if 'docker__cacheFpath_lineNum_max > docker__cacheFpath_numOfLines'?
    if [[ ${docker__cacheFpath_lineNum_max} -gt ${docker__cacheFpath_numOfLines} ]]; then   #true
        #Reprep 'lineNum_range_msg', use 'docker__cacheFpath_numOfLines' instead of 'docker__cacheFpath_lineNum_max'
        lineNum_max=${docker__cacheFpath_numOfLines}
    fi

    #Define and set the minimum range line-number
    local lineNum_min=${docker__cacheFpath_lineNum_min}
    
    #Check if 'lineNum_min > lineNum_max'?
    if [[ ${lineNum_min} -gt ${lineNum_max} ]]; then   #true
        lineNum_min=${lineNum_max}
    fi

    #Prepare the line-number range message
    local lineNum_range_msg="${DOCKER__FG_LIGHTGREY}${lineNum_min}${DOCKER__NOCOLOR} "
    lineNum_range_msg+="to ${DOCKER__FG_LIGHTGREY}${lineNum_max}${DOCKER__NOCOLOR} "
    lineNum_range_msg+="(${DOCKER__FG_SOFTLIGHTRED}${docker__cacheFpath_numOfLines}${DOCKER__NOCOLOR})"

    #Caclulate the length of 'lineNum_range_msg' without regEx
    local lineNum_range_msg_wo_regEx_len=`get_stringlen_wo_regEx__func "${lineNum_range_msg}"`

    #Determine the start-position of where to place 'lineNum_range_msg'
    local lineNum_range_msg_startPos=$(( (DOCKER__TABLEWIDTH/2) - (lineNum_range_msg_wo_regEx_len/2) ))

    #Move cursor to start-position 'lineNum_range_msg_startPos'
    tput cuu1 && tput cuf ${lineNum_range_msg_startPos}

    #Print 'lineNum_range_msg'
    echo -e "${lineNum_range_msg}"
}

docker__seqNum_handler__sub() {
    #This subroutine will update the 'global' variables:
    #1. docker__cacheFpath_lineNum_base
    #2. docker__cacheFpath_lineNum_min_bck
    #3. docker__cacheFpath_lineNum_min
    #4. docker__cacheFpath_lineNum_max
    #5. docker__flag_turnPage_isAllowed

    #Input args
    local seqNum_base__input=${1}
    local seqNum_min__input=${2}   #current minimum value
    local seqNum_range__input=${3} #max number of items allowed to be shown in table
    local turnPageDirection__input=${4}

    #Backup current 'docker__cacheFpath_lineNum_min'
    docker__cacheFpath_lineNum_min_bck=${seqNum_min__input}

    #Get the minimum value
    if [[ ${seqNum_min__input} -eq ${DOCKER__NUMOFMATCH_0} ]]; then
        docker__cacheFpath_lineNum_min=${DOCKER__NUMOFMATCH_1}
    else
        case "${turnPageDirection__input}" in
            ${DOCKER__PREV})
                #Increment the base value (e.g. 50, 40, 30, etc.)
                docker__cacheFpath_lineNum_base=$((seqNum_base__input - seqNum_range__input))

                #Decrement the minimum value
                docker__cacheFpath_lineNum_min=$((seqNum_min__input - seqNum_range__input))

                #Check if 'docker__cacheFpath_lineNum_min' is less than 'DOCKER__NUMOFMATCH_1'.
                if [[ ${docker__cacheFpath_lineNum_min} -lt ${DOCKER__NUMOFMATCH_1} ]]; then
                    #Set 'docker__cacheFpath_lineNum_base' equal to 'DOCKER__NUMOFMATCH_0'
                    docker__cacheFpath_lineNum_base=${DOCKER__NUMOFMATCH_0}

                    #Set 'docker__cacheFpath_lineNum_min' equal to 'DOCKER__NUMOFMATCH_1'
                    docker__cacheFpath_lineNum_min=${DOCKER__NUMOFMATCH_1}
                fi
                ;;
            ${DOCKER__NEXT})
                #Increment the base value (e.g. 0, 10, 20, 30, et.)
                docker__cacheFpath_lineNum_base=$((seqNum_base__input + seqNum_range__input))

                #Increment the minimum value
                docker__cacheFpath_lineNum_min=$((seqNum_min__input + seqNum_range__input))

                #Check if 'docker__seqNum_mi > docker__cacheFpath_numOfLines'.
                if [[ ${docker__cacheFpath_lineNum_min} -gt ${docker__cacheFpath_numOfLines} ]]; then
                    #Set 'docker__cacheFpath_lineNum_base' equal to the input value 'seqNum_base__input
                    docker__cacheFpath_lineNum_base=${seqNum_base__input}

                    #Set 'docker__cacheFpath_lineNum_min' equal to the input value 'seqNum_min__input'
                    docker__cacheFpath_lineNum_min=${seqNum_min__input}
                fi
                ;;
        esac
    fi

    #Get the maximum value

    docker__cacheFpath_lineNum_max=$((docker__cacheFpath_lineNum_min + seqNum_range__input - 1))
    
    #Set 'docker__flag_turnPage_isAllowed'
    #Remark:
    #   Compare 'docker__cacheFpath_lineNum_min' with 'docker__cacheFpath_lineNum_min_bck'. 
    #   1. Both values are not equal, then set 'docker__flag_turnPage_isAllowed = true'.
    #   2. Both values are the same, then set 'docker__flag_turnPage_isAllowed = false'.
    if [[ ${docker__cacheFpath_lineNum_min} -ne ${docker__cacheFpath_lineNum_min_bck} ]]; then
        docker__flag_turnPage_isAllowed=true
    else
        docker__flag_turnPage_isAllowed=false
    fi
}

docker__menuOptions_handler__sub() {
    #Make sure that all empty lines are removed except for the last empty line of the file
    docker__remove_allEmptyLines_and_append_caretReturn__sub

    while true
    do
        #Show echo-message
        echo "${docker__readInputDialog}${docker__totInput}" 

        moveUp_oneLine_then_moveRight__func "${docker__readInputDialog}" "${docker__totInput}"

        #Show read-input dialog
        read -N1 -rs docker__keyInput

        #Handle docker__keyInput
        case "${docker__keyInput}" in
            ${DOCKER__BACKSPACE})
                docker__backspace_handler__sub
                ;;
            ${DOCKER__ENTER})
                docker__enter_handler__sub
                ;;
            ${DOCKER__ESCAPEKEY})
                docker__escapeKey_handler__sub
                ;;
            ${DOCKER__TAB})
                docker__tab_handler__Sub    
                ;;
            ${DOCKER__ESCAPED_HOOKLEFT})  
                docker__prev_handler__sub

                break
                ;;
            ${DOCKER__ESCAPED_HOOKRIGHT})  
                docker__next_handler__sub

                break
                ;;
            *)
                docker__any_handler__sub
                ;;
        esac

        #Check if 'docker__flag_refresh_all = true'.
        #If true, then break this loop.
        if [[ ${docker__flag_refresh_all} == true ]]; then
            #Reset flag to 'false'
            docker__flag_refresh_all=false

            #Move down and clean
            # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            #Break this loop
            break
        fi
    done
}

docker__backspace_handler__sub() {
    #Define variables
    local totInput_len=0

    #Get string length
    totInput_len=${#docker__totInput}

    #Check if the length is greater than 0
    #REMARK:
    #	If FALSE, then do not execute this part, otherwise...
    #	...the following ERROR would occur:
    #	" totInput_len: substring expression < 0"
    if [[ ${totInput_len} -gt 0 ]]; then	#length MUST be greater than 0
        #Substract by 1
        totInput_len=$((totInput_len-1))				

        #Substract 1 TRAILING character
        docker__totInput=${docker__totInput:0:totInput_len}
    else
        docker__totInput=${EMPTYSTRING}
    fi

    #Move-up and clean
    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_0}"
}

docker__enter_handler__sub() {
    #Process 'docker__keyInput' based on 'docker__readInputDialog'
    case "${docker__readInputDialog}" in
        ${readInputDialog2__input}) #Add
            docker__enter_add_handler__sub
            ;;
        ${readInputDialog3__input}) #Del
            docker__enter_del_handler__sub
            ;;
    esac

    #Clean and Move to the beginning of line
    moveToBeginning_and_cleanLine__func     
}

docker__enter_add_handler__sub() {
    #Define variables
    local answer=${DOCKER__N}
    local linkStatusArr_status=${DOCKER__EMPTYSTRING}
    local webLink_isAccessible=${DOCKER__EMPTYSTRING}

    #Check if 'docker__totInput' is an Empty String?
    if [[ -z ${docker__totInput} ]]; then   #true
        return
    fi


    #Check if the clear-command ';c' was executed
    local totInput_tmp=`get_endResult_ofString_with_semiColonChar__func "${docker__totInput}"`
    case "${totInput_tmp}" in
        ${DOCKER__EMPTYSTRING})
            docker__totInput=${DOCKER__EMPTYSTRING}

            return
            ;;
        *)
            docker__enter_add_link_checkout_or_profile_handler__sub
            ;;
    esac
}
docker__enter_add_link_checkout_or_profile_handler__sub() {
    #Check if 'docker__totInput' is already added to 'target_cacheFpath'?
    local isFound=`checkFor_exact_match_of_pattern_within_file__func "${docker__totInput}" "${target_cacheFpath}"`
    if [[ ${isFound} == true ]]; then
        local ERRMSG_GITLINK_ALREADY_ADDED="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: ${exp_env_var_type__input} already added"
        show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_GITLINK_ALREADY_ADDED}" \
                    "${DOCKER__NUMOFLINES_2}" \
                    "${DOCKER__TIMEOUT_10}" \
                    "${DOCKER__NUMOFLINES_1}" \
                    "${DOCKER__NUMOFLINES_1}"

        #Move-up and clean
        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_5}"

        return
    fi

    #Check current number of entries
    if [[ ${docker__cacheFpath_numOfLines} -ge ${DOCKER__GIT_CACHE_MAX} ]]; then
        local ERRMSG_MAX_NUMOFENTRIES_REACHED="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: maximum number of entries reached "
            ERRMSG_MAX_NUMOFENTRIES_REACHED+="(${DOCKER__FG_SOFTLIGHTRED}${docker__cacheFpath_numOfLines}${DOCKER__NOCOLOR})\n"
        ERRMSG_MAX_NUMOFENTRIES_REACHED+="***${DOCKER__FG_YELLOW}ADVICE${DOCKER__NOCOLOR}: please remove unused entries"
    
        show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_MAX_NUMOFENTRIES_REACHED}" \
                    "${DOCKER__NUMOFLINES_2}" \
                    "${DOCKER__TIMEOUT_10}" \
                    "${DOCKER__NUMOFLINES_1}" \
                    "${DOCKER__NUMOFLINES_1}"

        #Move-up and clean
        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_6}"

        return
    fi

    #Only do this check if 'exp_env_var_type__input = DOCKER__LINK'
    if [[ ${exp_env_var_type__input} == ${DOCKER__LINK} ]] && \
                        [[ ${weblink_check_timeOut__input} -ne ${DOCKER__NUMOFMATCH_0} ]]; then
        local ERRMSG_CHOSEN_WEBLINK_IS_NOTACCESSIBLE="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: (git-)link is NOT accessable"

        #Get the status from 'docker__linkStatusArr' (if present)
        linkStatusArr_status=`retrieve_data_specified_by_col_within_2Darray__func "${docker__totInput}" "${DOCKER__COLNUM_2}" "${docker__linkStatusArr[@]}"`
        if [[ ! -z ${linkStatusArr_status} ]]; then    #status was found in 'docker__linkStatusArr'
            webLink_isAccessible=${linkStatusArr_status}

        else    #could not find 'line' in 'docker__linkStatusArr'
            #Check if web-link is reachable
            webLink_isAccessible=`checkIf_webLink_isAccessible__func ${docker__totInput} ${weblink_check_timeOut__input}`

            #Update array
            docker__linkStatusArr__add_data__sub "${line}" "${webLink_isAccessible}"
        fi
        
        #Show error message if not accessible
        if [[ ${webLink_isAccessible} == false ]]; then #not accessible
            #Show error message and output answer to extern variable 'extern__ret'
            show_msg_wo_menuTitle_w_confirmation__func "${ERRMSG_CHOSEN_WEBLINK_IS_NOTACCESSIBLE}" \
                    "${DOCKER__Y_SLASH_N}" \
                    "${DOCKER__REGEX_YN}" \
                    "${DOCKER__NUMOFLINES_2}" \
                    "${DOCKER__TIMEOUT_10}" \
                    "${DOCKER__NUMOFLINES_1}" \
                    "${DOCKER__NUMOFLINES_1}"

            #Get answer
            answer=${extern__ret}

            #Unset extern variable
            unset extern__ret

            #Move-up and clean
            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_5}"

            #If 'extern__ret = n', then exit function
            if [[ ${answer} == "${DOCKER__N}" ]]; then
                return
            fi
        fi
    fi

#---This part is similar (if not the same) as subroutine 'docker__any_choose_link_checkout_profile__sub'
    #Update cache-files
    #Remark:
    #   In this subroutine it will also be determined at which line-number...
    #   ...the insertion will take place 'docker__totInput'
    docker__update_cache_files__sub "${docker__totInput}" "${exp_env_var_type__input}"

    #Update 'docker__cacheFpath_numOfLines'
    docker__cacheFpath_numOfLines=`cat ${target_cacheFpath} | wc -l`

    #Write to output-file 'outFpath__input'
    write_data_to_file__func "${docker__totInput}" "${outFpath__input}"

    #At this stage, update the file 'exported_env_var.txt' only...
    #...if it does not contain data for the specified 'repository:tag'...
    #...as specified in 'dockerfile_fpath__input'.
    if [[ ${docker__env_var_repositoryTag_isFound} == false ]]; then 
        docker__update_exported_env_var_file_handler__sub "${docker__totInput}" "${exp_env_var_type__input}"
    fi

    #IMPORTANT: re-retrieve link, checkout, link-checkout profile, and docker__env_var_repositoryTag_isFound
    docker__retrieve__exported_env_var__and__flag_repositoryTag_isFound__sub

    #Initialize sequence-related variables
    #Note: this will make sure that the FIRST page is shown.
    docker__seqNum_init__sub

    #Reset 'docker__totInput'
    docker__totInput=${DOCKER__EMPTYSTRING}

    #Break the loop of subroutine 'docker__menuOptions_handler__sub'
    docker__flag_refresh_all=true  #set flag to 'true'

    #Move-up and clean a specified number of lines
    docker__moveUp_and_clean_basedOn_chosen_numOfLines__sub
#---This part is similar (if not the same) as subroutine 'docker__any_choose_link_checkout_profile__sub'
}

docker__update_cache_files__sub() {
    #Input args
    local data__input=${1}
    local expEnvVarType__input=${2}

    #Define variables
    local docker_arg1=${DOCKER__EMPTYSTRING}
    local docker_arg2=${DOCKER__EMPTYSTRING}
    local docker_arg1_colon_arg2=${DOCKER__EMPTYSTRING}
    local lineNum_insert=0
    local cacheFpath_sel=${DOCKER__EMPTYSTRING}


    #set 'lineNum_insert'
    if [[ ${docker__env_var_repositoryTag_isFound} == true ]]; then
        lineNum_insert=${DOCKER__LINENUM_2}
    else
        lineNum_insert=${DOCKER__LINENUM_1}
    fi

    case "${expEnvVarType__input}" in
        ${DOCKER__LINK})
            docker_arg1=${data__input}

            #Get 'docker_arg2'
            if [[ ${docker__env_var_repositoryTag_isFound} == true ]]; then 
                docker_arg2=`retrieve_env_var_checkout_from_file__func "${dockerfile_fpath__input}" "${exported_env_var_fpath__input}"`
            else
                docker_arg2=`retrieve_line_from_file__func "${DOCKER__LINENUM_1}" "${docker__checkoutCacheFpath}"`
            fi

            #Insert/append 'docker_arg1'
            if [[ -f ${target_cacheFpath} ]]; then
                insert_string_into_file_at_specified_lineNum__func "${docker_arg1}" \
                        "${lineNum_insert}" \
                        "${target_cacheFpath}" \
                        "${DOCKER__TRUE}"
            fi

            #Insert/append 'docker_arg1_colon_arg2'
            #Remark:
            #   Do this ONLY if:
            #   1. file 'docker__linkCheckoutProfileCacheFpath' exists
            #   2. file 'docker__linkCheckoutProfileCacheFpath' contains NO data
            if  [[ -f ${docker__linkCheckoutProfileCacheFpath} ]] && [[ ! -s ${docker__linkCheckoutProfileCacheFpath} ]]; then
                if [[ ! -z ${docker_arg2} ]]; then
                    docker_arg1_colon_arg2="${docker_arg1}${DOCKER__COLON}${docker_arg2}"

                    insert_string_into_file_at_specified_lineNum__func "${docker_arg1_colon_arg2}" \
                            "${lineNum_insert}" \
                            "${docker__linkCheckoutProfileCacheFpath}" \
                            "${DOCKER__TRUE}"
                fi
            fi
            ;;
        ${DOCKER__CHECKOUT})
            docker_arg2=${data__input}

            #Get 'docker_arg1'
            if [[ ${docker__env_var_repositoryTag_isFound} == true ]]; then 
                docker_arg1=`retrieve_env_var_link_from_file__func "${dockerfile_fpath__input}" "${exported_env_var_fpath__input}"`
            else
                docker_arg1=`retrieve_line_from_file__func "${DOCKER__LINENUM_1}" "${docker__linkCacheFpath}"`
            fi

            #Insert/append 'docker_arg1'
            if [[ -f ${target_cacheFpath} ]]; then 
                insert_string_into_file_at_specified_lineNum__func "${docker_arg2}" \
                        "${lineNum_insert}" \
                        "${target_cacheFpath}" \
                        "${DOCKER__TRUE}"
            fi

            #Insert/append 'docker_arg1_colon_arg2'
            #Remark:
            #   Do this ONLY if:
            #   1. file 'docker__linkCheckoutProfileCacheFpath' exists
            #   2. file 'docker__linkCheckoutProfileCacheFpath' contains NO data
            if  [[ -f ${docker__linkCheckoutProfileCacheFpath} ]] && [[ ! -s ${docker__linkCheckoutProfileCacheFpath} ]]; then
                if [[ ! -z ${docker_arg1} ]]; then
                    docker_arg1_colon_arg2="${docker_arg1}${DOCKER__COLON}${docker_arg2}"
                
                    insert_string_into_file_at_specified_lineNum__func "${docker_arg1_colon_arg2}" \
                            "${lineNum_insert}" \
                            "${docker__linkCheckoutProfileCacheFpath}" \
                            "${DOCKER__TRUE}"
                fi
            fi
            ;;
        ${DOCKER__LINKCHECKOUT_PROFILE})
            #Set 'docker_arg1_colon_arg2'
            docker_arg1_colon_arg2=${data__input}

            #Insert/append 'docker_arg1_colon_arg2'
            if [[ -f ${docker__linkCheckoutProfileCacheFpath} ]]; then
                insert_string_into_file_at_specified_lineNum__func "${docker_arg1_colon_arg2}" \
                        "${lineNum_insert}" \
                        "${target_cacheFpath}" \
                        "${DOCKER__TRUE}"
            fi
            ;;
    esac
}
docker__update_other_cache_files_due_to_chosen_object() {
    #--------------------------------------------------------------------
    # With 'chosen object' we mean the chosen:
    #   'link, checkout, or link-checkout profile'
    # Remarks:
    # 1. expEnvVarType__input = DOCKER__LINKCHECKOUT_PROFILE, then
    #   check whether the cache-file of the 'link' and 'checkout'
    #   need to be updated.
    # 2. expEnvVarType__input = DOCKER__LINK or DOCKER__CHECKOUT, then
    #   check wehter the cache0file of the 'link-checkout profile'
    #   needs to be updated.
    #--------------------------------------------------------------------

    #Input args
    local data__input=${1}
    local expEnvVarType__input=${2}

    #Define variables
    local docker_arg1=${DOCKER__EMPTYSTRING}
    local docker_arg2=${DOCKER__EMPTYSTRING}
    local docker_arg1_colon_arg2=${DOCKER__EMPTYSTRING}

    case "${expEnvVarType__input}" in
        ${DOCKER__LINK})
            docker_arg1=${data__input}

            #Get 'docker_arg2'
            if [[ ${docker__env_var_repositoryTag_isFound} == true ]]; then 
                docker_arg2=`retrieve_env_var_checkout_from_file__func "${dockerfile_fpath__input}" "${exported_env_var_fpath__input}"`
            else
                docker_arg2=`retrieve_line_from_file__func "${DOCKER__LINENUM_1}" "${docker__checkoutCacheFpath}"`
            fi

            #Insert/append 'docker_arg1_colon_arg2'
            if [[ ! -z ${docker_arg2} ]]; then
                docker_arg1_colon_arg2="${docker_arg1}${DOCKER__COLON}${docker_arg2}"

                insert_string_into_file_at_specified_lineNum__func "${docker_arg1_colon_arg2}" \
                        "${DOCKER__LINENUM_1}" \
                        "${docker__linkCheckoutProfileCacheFpath}" \
                        "${DOCKER__TRUE}"
            fi
            ;;
        ${DOCKER__CHECKOUT})
            docker_arg2=${data__input}

            #Get 'docker_arg1'
            if [[ ${docker__env_var_repositoryTag_isFound} == true ]]; then 
                docker_arg1=`retrieve_env_var_link_from_file__func "${dockerfile_fpath__input}" "${exported_env_var_fpath__input}"`
            else
                docker_arg1=`retrieve_line_from_file__func "${DOCKER__LINENUM_1}" "${docker__linkCacheFpath}"`
            fi

            #Insert/append 'docker_arg1_colon_arg2'
            if [[ ! -z ${docker_arg1} ]]; then
                docker_arg1_colon_arg2="${docker_arg1}${DOCKER__COLON}${docker_arg2}"

                insert_string_into_file_at_specified_lineNum__func "${docker_arg1_colon_arg2}" \
                        "${DOCKER__LINENUM_1}" \
                        "${docker__linkCheckoutProfileCacheFpath}" \
                        "${DOCKER__TRUE}"
            fi
            ;;
        ${DOCKER__LINKCHECKOUT_PROFILE})
            #Get 'link' part from 'data__input'
            docker_arg1=`echo "${data__input}" | rev | cut -d"${DOCKER__COLON}" -f2- | rev`

            #Insert at the 1st line
            insert_string_into_file_at_specified_lineNum__func "${docker_arg1}" \
                        "${DOCKER__LINENUM_1}" \
                        "${docker__linkCacheFpath}" \
                        "${DOCKER__TRUE}"

            #Get 'checkout' part from 'data__input'
            docker_arg2=`echo "${data__input}" | rev | cut -d"${DOCKER__COLON}" -f1 | rev`

            #Insert at the 1st line
            insert_string_into_file_at_specified_lineNum__func "${docker_arg2}" \
                        "${DOCKER__LINENUM_1}" \
                        "${docker__checkoutCacheFpath}" \
                        "${DOCKER__TRUE}"
            ;;
    esac
}
docker__update_exported_env_var_file_handler__sub() {
    #Input args
    local data__input=${1}
    local expEnvVarType__input=${2}

    #Define variables
    local docker_arg1=${DOCKER__EMPTYSTRING}
    local docker_arg2=${DOCKER__EMPTYSTRING}

    #Get 'docker_arg1' and 'docker_arg2' values
    case "${expEnvVarType__input}" in
        ${DOCKER__LINK})
            docker_arg1=${data__input}

            #Get 'docker_arg2'
            if [[ ${docker__env_var_repositoryTag_isFound} == true ]]; then 
                docker_arg2=`retrieve_env_var_checkout_from_file__func "${dockerfile_fpath__input}" "${exported_env_var_fpath__input}"`
            else
                docker_arg2=`retrieve_line_from_file__func "${DOCKER__LINENUM_1}" "${docker__checkoutCacheFpath}"`
            fi
            ;;
        ${DOCKER__CHECKOUT})
            docker_arg2=${data__input}

            #Get 'docker_arg1'
            if [[ ${docker__env_var_repositoryTag_isFound} == true ]]; then 
                docker_arg1=`retrieve_env_var_link_from_file__func "${dockerfile_fpath__input}" "${exported_env_var_fpath__input}"`
            else
                docker_arg1=`retrieve_line_from_file__func "${DOCKER__LINENUM_1}" "${docker__linkCacheFpath}"`
            fi
            ;;
        ${DOCKER__LINKCHECKOUT_PROFILE})
            #Remark:
            #   'data__input' contains 'docker_arg1' and 'docker_arg2'
            #   which are separated by a colon ':'
            docker_arg2=`echo "${data__input}" | rev | cut -d"${DOCKER__COLON}" -f1 | rev`
            docker_arg1=`echo "${data__input}" | rev |cut -d"${DOCKER__COLON}" -f2- | rev`
            ;;
    esac

    #Check if 'docker_arg1' or 'docker_arg2' is an Empty String
    if [[ -z ${docker_arg1} ]] || [[ -z ${docker_arg2} ]]; then
        return
    fi

    #Update 'exported_env_var_fpath__input'
    update_exported_env_var__func "${docker_arg1}" \
                        "${docker_arg2}" \
                        "${dockerfile_fpath__input}" \
                        "${exported_env_var_fpath__input}"
}

docker__enter_del_handler__sub() {
    #Define variables
    local lineNum_toBeDel_arr=()
    local lineNum_toBeDel_arrItem=${DOCKER__EMPTYSTRING}
    local lineNum_toBeDel_string=${DOCKER__EMPTYSTRING}
    local excludeVal=${DOCKER__EMPTYSTRING}
    local excludeLinkVal=${DOCKER__EMPTYSTRING}
    local excludeCheckoutVal=${DOCKER__EMPTYSTRING}

    #Backup 'docker__cacheFpath_numOfLines'
    local dataFpath_numOfLines_bck=${docker__cacheFpath_numOfLines}

    #Retrieve the corrected to-be-deleted line-numbers
    local lineNum_toBeDel_string=`xtract_indexes_from_a_rangeAndOrGroup_in_descendingOrder__func \
                        "${docker__totInput}" \
                        "${DOCKER__REGEX_0_TO_9_COMMA_DASH}"`

    #Convert string (delimited by a space) to array
    read -a lineNum_toBeDel_arr <<< "${lineNum_toBeDel_string}"

    #Get 'link' and/or 'checkout' value from 'exported_env_var_fpath__input'
    #Remark:
    #   This is important, because this value or values will be excluded,...
    #   ...thus exempt from deletion.
    case "${exp_env_var_type__input}" in
        ${DOCKER__LINK})
            #Retrieve the configured environment variable 'link'
            excludeVal=`retrieve_env_var_link_from_file__func "${dockerfile_fpath__input}" \
                        "${exported_env_var_fpath__input}"`
            ;;
        ${DOCKER__CHECKOUT})
            #Retrieve the configured environment variable 'checkout'
            excludeVal=`retrieve_env_var_checkout_from_file__func "${dockerfile_fpath__input}" \
                        "${exported_env_var_fpath__input}"`
            ;;
        ${DOCKER__LINKCHECKOUT_PROFILE})
            excludeLinkVal=`retrieve_env_var_link_from_file__func "${dockerfile_fpath__input}" \
                        "${exported_env_var_fpath__input}"`

            excludeCheckoutVal=`retrieve_env_var_checkout_from_file__func "${dockerfile_fpath__input}" \
                        "${exported_env_var_fpath__input}"`

            excludeVal="${excludeLinkVal}${DOCKER__COLON}${excludeCheckoutVal}"
            ;;
    esac

    #Remove lines of 'target_cacheFpath' specified by the line-numbers in 'lineNum_toBeDel_arr'
    #Remark:
    #   It is important that 'lineNum_toBeDel_arr' contains a list of indexes in a DESCENDING order.
    for lineNum_toBeDel_arrItem in "${lineNum_toBeDel_arr[@]}"
    do
        delete_lineNum_from_file__func "${lineNum_toBeDel_arrItem}" "${excludeVal}" "${target_cacheFpath}"
    done

    #Update 'docker__cacheFpath_numOfLines'
    docker__cacheFpath_numOfLines=`cat ${target_cacheFpath} | wc -l`

    #Take action based on whether 'dataFpath_numOfLines' has changed or not.
    #Remark:
    #   If 'dataFpath_numOfLines' has changed than it means that data were deleted.
    if [[ ${dataFpath_numOfLines} -lt ${dataFpath_numOfLines_bck} ]]; then
        #Set flag to 'true'
        docker__flag_refresh_all=true

        #Move-up and clean a specified number of lines
        docker__moveUp_and_clean_basedOn_chosen_numOfLines__sub
    else
        moveToBeginning_and_cleanLine__func
    fi

    #Reset variable
    docker__totInput=${DOCKER__EMPTYSTRING}
}

docker__escapeKey_handler__sub() {
    #Get the key-output
    local keyOutput=`functionKey_detection__func "${docker__keyInput}"`
    case "${keyOutput}" in
        ${DOCKER__ENUM_FUNC_F6})
            docker__escapeKey_choose_handler__sub
            ;;
        ${DOCKER__ENUM_FUNC_F7})
            docker__escapeKey_add_handler__sub
            ;;
        ${DOCKER__ENUM_FUNC_F8})
            docker__escapeKey_del_handler__sub
            ;;
        ${DOCKER__ENUM_FUNC_F12})
            docker__escapeKey_exit_handler__sub
            ;;
        *)
            moveToBeginning_and_cleanLine__func
            ;;
    esac
}

docker__tab_handler__Sub() {
    #Clean and Move to the beginning of line
    moveToBeginning_and_cleanLine__func     
}

docker__escapeKey_choose_handler__sub() {
    #Hide cursor
    cursor_hide__func

    #Reset variables
    #Remark:
    #   Only if a switch has taken place.
    #   For example from 'F7 or F8' to 'F6'
    if [[ ${docker__readInputDialog} != ${readInputDialog1__input} ]]; then
        docker__keyInput=${DOCKER__EMPTYSTRING}
        docker__totInput=${DOCKER__EMPTYSTRING}
    fi

    #Move-up and clean lines
    if [[ ${docker__readInputDialog} == ${readInputDialog3__input} ]]; then #true
        docker__flag_refresh_all=true  #set flag to 'true'

        docker__moveUp_and_clean_basedOn_chosen_numOfLines__sub
    else
        moveToBeginning_and_cleanLine__func
    fi

    #Update 'docker__readInputDialog'
    docker__readInputDialog=${readInputDialog1__input}

    #Show cursor
    cursor_show__func
}

docker__escapeKey_add_handler__sub() {
    #Hide cursor
    cursor_hide__func

    #Reset variables
    #Remark:
    #   Only if a switch has taken place.
    #   For example from 'F6 or F8' to 'F7'
    if [[ ${docker__readInputDialog} != ${readInputDialog2__input} ]]; then
        docker__keyInput=${DOCKER__EMPTYSTRING}
        docker__totInput=${DOCKER__EMPTYSTRING}
    fi

    #Move-up and clean lines
    #Remark:
    #   Do this only for 2 cases:
    #   1. when switching from 'F8' to 'F7'
    #   2. when 'exp_env_var_type__input = DOCKER__LINKCHECKOUT_PROFILE'
    if [[ ${docker__readInputDialog} == ${readInputDialog3__input} ]] || \
                        [[ ${exp_env_var_type__input} == ${DOCKER__LINKCHECKOUT_PROFILE} ]]; then
        docker__flag_refresh_all=true           #Set flag to 'true'

        docker__moveUp_and_clean_basedOn_chosen_numOfLines__sub
    else
        moveToBeginning_and_cleanLine__func
    fi

    #Update 'docker__readInputDialog'
    docker__readInputDialog=${readInputDialog2__input}

    #Show cursor
    cursor_show__func



    #For 'link-checkout profle', switch to a different table...
    #...by default show the link cache-file content.
    if [[ ${exp_env_var_type__input} == ${DOCKER__LINKCHECKOUT_PROFILE} ]]; then
        #Set flag to 'true'
        docker__flag_refresh_all=true

        #Run special sub-menu to add 'link' and 'checkout'
        docker__escapeKey_add_linkCheckout_profile__sub
    fi
}
docker__escapeKey_add_linkCheckout_profile__sub() {
    #Define constants
    local CHOOSE_LINK="-:choose link: "
    local CHOOSE_CHECKOUT="-:choose checkout: "

    #Define and initialize variables
    local cacheFpath=${DOCKER__EMPTYSTRING}
    local checkoutSel=${DOCKER__EMPTYSTRING}
    local linkSel=${DOCKER__EMPTYSTRING}
    local matchPattern=${DOCKER__EMPTYSTRING}
    local menuType=${DOCKER__LINK}
    local readInputDialog=${DOCKER__EMPTYSTRING}
    local selItem=${DOCKER__EMPTYSTRING}

    #Remark:
    #   The 'result_from_output' could be a key-input or selected table-item.
    local result_from_output=${DOCKER__EMPTYSTRING}
    #Remark:
    #   'tot_numOfLines' retrieved from 'result_from_output' representing the
    #       total number of lines of the table drawn within 
    #        'show_pathContent_w_selection__func'.
    #   Note: this value may be needed in case the above mentioned table
    #       needs to be cleared.
    local tot_numOfLines_from_output=0

    #Show file-content based on 'menuType' selection
    while true
    do
        #Select input parameters based on the 'menuType' value
        if [[ ${menuType} == ${DOCKER__LINK} ]]; then   #link
            cacheFpath=${docker__linkCacheFpath}
            readInputDialog="${readInputDialog2__input}${CHOOSE_LINK}"
            selItem=${linkSel}
        else    #checkout
            cacheFpath=${docker__checkoutCacheFpath}
            readInputDialog="${readInputDialog2__input}${CHOOSE_CHECKOUT}"
            selItem=${checkoutSel}
        fi

        #Check if the selected 'linkSel' and 'checkoutSel' are NOT Empty Strings?
        if [[ ! -z ${linkSel} ]] && [[ ! -z ${checkoutSel} ]]; then #true
            menuOptions=${menuOptions3__input}
            matchPattern=${matchPattern3__input}
        else    #false
            menuOptions=${menuOptions2__input}
            matchPattern=${matchPattern2__input}
        fi

        #Show file-content
        show_pathContent_w_selection__func "${cacheFpath}" \
                        "${selItem}" \
                        "${menuTitle__input}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${info__input}" \
                        "${menuOptions}" \
                        "${matchPattern}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${readInputDialog}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${DOCKER__TABLEROWS_10}" \
                        "${DOCKER__TRUE}" \
                        "${docker__show_pathContent_w_selection_func_out__fpath}" \
                        "${DOCKER__EMPTYSTRING}" \
                        "${DOCKER__FALSE}"

        #Get result_from_output
        result_from_output=`retrieve_line_from_file__func "${DOCKER__LINENUM_1}" \
                        "${docker__show_pathContent_w_selection_func_out__fpath}"`
        tot_numOfLines_from_output=`retrieve_line_from_file__func "${DOCKER__LINENUM_2}" \
                        "${docker__show_pathContent_w_selection_func_out__fpath}"`

        #Handle 'result_from_output'
        case "${result_from_output}" in
            ${DOCKER__ENUM_FUNC_F1})    #link-menu
                menuType=${DOCKER__LINK}

                moveUp_and_cleanLines__func "${tot_numOfLines_from_output}"
                ;;
            ${DOCKER__ENUM_FUNC_F2})    #checkout-menu
                menuType=${DOCKER__CHECKOUT}

                moveUp_and_cleanLines__func "${tot_numOfLines_from_output}"
                ;;
            ${DOCKER__ENUM_FUNC_F3})    #confirm
                #Add profile (and more...)
                docker__escapeKey_add_linkCheckout_profile_confirm__sub

                #Move-up or move-down and clean based on the condition (as mentioned in the subroutine)
                docker__relative_move_and_clean_due_to_switch_between_different_tables__sub

                #Switch back to 'readInputDialog1__input' (Choose)
                docker__escapeKey_add_linkCheckout_profile_switch_to_choose__sub

                break   #important

                # moveUp_and_cleanLines__func "${tot_numOfLines_from_output}"
                ;;
            ${DOCKER__ENUM_FUNC_F5})    #abort
                moveUp_and_cleanLines__func "${tot_numOfLines_from_output}"

                #Switch back to 'readInputDialog1__input' (Choose)
                docker__escapeKey_add_linkCheckout_profile_switch_to_choose__sub

                break   #important
                ;;
            ${DOCKER__ENUM_FUNC_F12})    #abort
                exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_2}"

                ;;
            *)
                moveUp_and_cleanLines__func "${tot_numOfLines_from_output}"

                if [[ ${menuType} == ${DOCKER__LINK} ]]; then   #link
                    linkSel=${result_from_output}
                else    #checkout
                    checkoutSel=${result_from_output}
                fi
                ;;
        esac
    done
}
docker__escapeKey_add_linkCheckout_profile_confirm__sub() {
    #IMPORTANT: Set 'docker__totInput'
    docker__totInput="${linkSel}${DOCKER__COLON}${checkoutSel}"

    #Execute 'docker__enter_add_link_checkout_or_profile_handler__sub'
    docker__enter_add_link_checkout_or_profile_handler__sub
}
docker__relative_move_and_clean_due_to_switch_between_different_tables__sub() {
    #Input args
    local tot_numOfLines_from__input=${1}   #from this table with the specified total number of lines
    local tot_numOfLines_to__input=${2} #to this table with the specified total number of lines

    #Define variables
    local rel_numOfLines=0

    #Check if both values are the same?
    if [[ ${tot_numOfLines_from__input} -eq ${tot_numOfLines_to__input} ]]; then    #true
        return
    fi

    #Steps:
    #   1. Calculate 'rel_numOfLines' based on the condition
    #   2. if 'tot_numOfLines_from__input > tot_numOfLines_to__input', then move-UP and clean
    #   3. if 'tot_numOfLines_from__input < tot_numOfLines_to__input', then move-DOWN and clean
    if [[ ${tot_numOfLines_from__input} -gt ${tot_numOfLines_to__input} ]]; then    #true
        #calculate 'rel_numOfLines'
        rel_numOfLines=$((tot_numOfLines_from__input - tot_numOfLines_to__input))

        #Move-up and clean
        moveUp_and_cleanLines__func "${rel_numOfLines}"
    else    #tot_numOfLines_from__input < tot_numOfLines_to__input
        #calculate 'rel_numOfLines'
        rel_numOfLines=$((tot_numOfLines_to__input - tot_numOfLines_from__input))

        #move-down and clean
        moveDown_and_cleanLines__func "${rel_numOfLines}" "${rel_numOfLines}"OfLines
    fi    
}
docker__escapeKey_add_linkCheckout_profile_switch_to_choose__sub() {
    #Reset variables
    docker__keyInput=${DOCKER__EMPTYSTRING}
    docker__totInput=${DOCKER__EMPTYSTRING}

    #Update 'docker__readInputDialog'
    docker__readInputDialog=${readInputDialog1__input}
}

docker__escapeKey_del_handler__sub() {
    #Hide cursor
    cursor_hide__func

    #Reset variables
    #Remark:
    #   Only if a switch has taken place.
    #   For example from 'F6 or F7' to 'F8'
    if [[ ${docker__readInputDialog} != ${readInputDialog3__input} ]]; then
        docker__keyInput=${DOCKER__EMPTYSTRING}
        docker__totInput=${DOCKER__EMPTYSTRING}

        docker__flag_refresh_all=true  #set flag to 'true'

        docker__moveUp_and_clean_basedOn_chosen_numOfLines__sub
    else
        moveToBeginning_and_cleanLine__func
    fi

    #Update 'docker__readInputDialog'
    docker__readInputDialog=${readInputDialog3__input}

    #Show cursor
    cursor_show__func
}

docker__escapeKey_exit_handler__sub() {
    #Clean and Move to the beginning of line
    moveToBeginning_and_cleanLine__func

    #Show last key-input
    echo "${readInputDialog1__input}${docker__keyInput}" 

    #Exit this file
    exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_2}"
}

docker__next_handler__sub() {
    #Hide cursor
    cursor_hide__func

    #Update sequence-related values
    #1. docker__cacheFpath_lineNum_base
    #2. docker__cacheFpath_lineNum_min_bck
    #3. docker__cacheFpath_lineNum_min
    #4. docker__cacheFpath_lineNum_max
    #5. docker__flag_turnPage_isAllowed
    docker__seqNum_handler__sub "${docker__cacheFpath_lineNum_base}" \
                        "${docker__cacheFpath_lineNum_min}" \
                        "${DOCKER__TABLEROWS_10}" \
                        "${DOCKER__NEXT}"

    #Select the appropriate 'number of lines'
    if [[ ${docker__flag_turnPage_isAllowed} == true ]]; then
        docker__moveUp_and_clean_basedOn_chosen_numOfLines__sub
    else
        moveToBeginning_and_cleanLine__func   
    fi

    #Show cursor
    cursor_show__func
}
docker__prev_handler__sub() {
    #Hide cursor
    cursor_hide__func

    #Update sequence-related values
    #1. docker__cacheFpath_lineNum_base
    #2. docker__cacheFpath_lineNum_min_bck
    #3. docker__cacheFpath_lineNum_min
    #4. docker__cacheFpath_lineNum_max
    #5. docker__flag_turnPage_isAllowed
    docker__seqNum_handler__sub "${docker__cacheFpath_lineNum_base}" \
                        "${docker__cacheFpath_lineNum_min}" \
                        "${DOCKER__TABLEROWS_10}" \
                        "${DOCKER__PREV}"

    #Select the appropriate 'number of lines'
    if [[ ${docker__flag_turnPage_isAllowed} == true ]]; then
        docker__moveUp_and_clean_basedOn_chosen_numOfLines__sub
    else
        #Clean and Move to the beginning of line
        moveToBeginning_and_cleanLine__func
    fi

    #Show cursor
    cursor_show__func
}
docker__moveUp_and_clean_basedOn_chosen_numOfLines__sub() {
    case "${docker__readInputDialog}" in
        ${readInputDialog1__input})    #hash (e.g. Choose)
            docker__tot_numOfLines=${docker__tot1_numOfLines}
            ;;
        ${readInputDialog2__input})    #hash (e.g. Add)
            docker__tot_numOfLines=${docker__tot2_numOfLines}
            ;;
        ${readInputDialog3__input})    #hash (e.g. Del)
            docker__tot_numOfLines=${docker__tot3_numOfLines}
            ;;
    esac

    #move-up and clean
    moveUp_and_cleanLines__func "${docker__tot_numOfLines}"
}

docker__any_handler__sub() {
    case "${docker__readInputDialog}" in
        ${readInputDialog1__input}) #Choose
            docker__any_choose_handler__sub
            ;;
        ${readInputDialog2__input}) #Add
            docker__any_add_handler__sub
            ;;
        ${readInputDialog3__input}) #Del
            docker__any_del_handler__sub
            ;;
    esac

    #Clean and Move to the beginning of line
    moveToBeginning_and_cleanLine__func
}

docker__any_choose_handler__sub() {
    #Check if 'docker__cacheFpath_numOfLines = 0', which means that 'target_cacheFpath' contains No data
    if [[ ${docker__cacheFpath_numOfLines} -eq ${DOCKER__NUMOFMATCH_0} ]]; then
        return
    fi

    #Check if 'docker__keyInput' is a number
    local isNumeric=`isNumeric__func ${docker__keyInput}`
    case "${isNumeric}" in
        false)
            return
            ;;
        true)
            docker__any_choose_link_checkout_profile__sub
            ;;
    esac
}
docker__any_choose_link_checkout_profile__sub() {
    #IMPORTANT: set 'docker__keyInput = DOCKER__TABLEROWS_10' if 'docker__keyInput = 0'
    if [[ ${docker__keyInput} -eq ${DOCKER__NUMOFMATCH_0} ]]; then
        docker__keyInput=${DOCKER__TABLEROWS_10}
    fi

    #Get the absolute line-number
    #Note: 'docker__keyInput' is the relative line-number (0-9)
    docker__lineNum_abs=$((docker__cacheFpath_lineNum_base + docker__keyInput))

    #Check if 'docker__lineNum_abs > docker__cacheFpath_numOfLines' 
    if [[ ${docker__lineNum_abs} -gt ${docker__cacheFpath_numOfLines} ]]; then
        return
    fi

#---This part is similar (if not the same) as subroutine 'docker__enter_add_handler__sub'
    #Move selected item to the top of 'target_cacheFpath'
    #***Output: docker__line
    docker__move_selected_item_to_top_of_cache_file__sub "${docker__lineNum_abs}"

    #Update 'exported_env_var.txt'
    docker__update_exported_env_var_file_handler__sub "${docker__line}" "${exp_env_var_type__input}"

    # #Insert/append to file 'docker__linkCheckoutProfileCacheFpath'
    # docker__update_cache_files__sub "${DOCKER__EMPTYSTRING}" "${DOCKER__LINKCHECKOUT_PROFILE}"

    #Write to output file
    write_data_to_file__func "${docker__line}" "${outFpath__input}"

    #IMPORTANT: re-retrieve link, checkout, link-checkout profile, and docker__env_var_repositoryTag_isFound
    docker__retrieve__exported_env_var__and__flag_repositoryTag_isFound__sub

    #Update other cache-files which are influenced by the chosen 'docker__totInput' value
    docker__update_other_cache_files_due_to_chosen_object "${docker__line}" "${exp_env_var_type__input}"

    #Initialize sequence-related variables
    #Note: this will make sure that the FIRST page is shown.
    docker__seqNum_init__sub

    #Break the loop of subroutine 'docker__menuOptions_handler__sub'
    docker__flag_refresh_all=true  #set flag to 'true'

    #Move-up and clean a specified number of lines
    docker__moveUp_and_clean_basedOn_chosen_numOfLines__sub
#---This part is similar (if not the same) as subroutine 'docker__enter_add_handler__sub'
}
docker__move_selected_item_to_top_of_cache_file__sub() {
    #Input args
    local lineNum_abs=${1}

    #Retrieve 'string' from file based on the specified 'lineNum__input'
    docker__line=`retrieve_line_from_file__func "${lineNum_abs}" "${target_cacheFpath}"`

    #Delete line specified by 'lineNum_abs'
    delete_lineNum_from_file__func "${lineNum_abs}" "${DOCKER__EMPTYSTRING}" "${target_cacheFpath}"

    #Insert 'line' at the top of the file.
    insert_string_into_file_at_specified_lineNum__func "${docker__line}" "${DOCKER__LINENUM_1}" "${target_cacheFpath}" "${DOCKER__TRUE}"
}

docker__any_add_handler__sub() {
    #Append 'docker__keyInput' and 'docker__keyInput_add' to 'docker__totInput'
    #Remark:
    #   Only when adding 'link' and 'checkout'
    docker__any_add_link_or_checkout__sub
}
docker__any_add_link_or_checkout__sub() {
    #wait for another 0.5 seconds to capture additional characters.
    #Remark:
    #   This part has been implemented just in case long text has been copied/pasted.
    read -rs -t0.01 docker__keyInput_add

    #Append 'docker__keyInput_add' to 'docker__keyInput'
    docker__keyInput="${docker__keyInput}${docker__keyInput_add}"

    #Append key-input
    docker__totInput="${docker__totInput}${docker__keyInput}"

    #Check and correct unwanted spaces
    docker__totInput=`remove_whiteSpaces__func ${docker__totInput}` 

    #Clean and Move to the beginning of line
    moveToBeginning_and_cleanLine__func
}

docker__any_del_handler__sub() {
    if [[ ${docker__keyInput} =~ ${DOCKER__REGEX_0_TO_9_COMMA_DASH} ]]; then
        #wait for another 0.5 seconds to capture additional characters.
        #Remark:
        #   This part has been implemented just in case long text has been copied/pasted.
        read -rs -t0.01 docker__keyInput_add

        #Append 'docker__keyInput_add' to 'docker__keyInput'
        docker__keyInput="${docker__keyInput}${docker__keyInput_add}"

        #Append key-input
        docker__totInput="${docker__totInput}${docker__keyInput}"

        #Check and correct unwanted chars
        #***Output: docker__totInput
        docker__any_del_skip_and_correct_indexes__sub
    else    #contains no data
        docker__keyInput=${DOCKER__EMPTYSTRING}
    fi

    #Clean and Move to the beginning of line
    moveToBeginning_and_cleanLine__func
}
docker__any_del_skip_and_correct_indexes__sub() {
    if [[ ! -z ${docker__totInput} ]]; then #contains data
        #Backup the old 'docker__subTotInput_leftOfLastComma'
        docker__subTotInput_leftOfLastComma_bck=${docker__subTotInput_leftOfLastComma}

        #Get the new 'docker__subTotInput_leftOfLastComma'
        #Remark:
        #   Any substring which is on the RIGHT-side of the comma...
        #   ...will NOT be checked and corrected!
        local result=`retrieve_subStrings_delimited_by_lastChar_within_string__func "${docker__totInput}" "${DOCKER__COMMA}"`
        docker__subTotInput_leftOfLastComma=`echo "${result}" | cut -d"${SED__RS}" -f1`
        docker__subTotInput_rightOfLastComma=`echo "${result}" | cut -d"${SED__RS}" -f2`

        #Compare the old and new 'docker__subTotInput_leftOfLastComma'
        if [[ ! -z ${docker__subTotInput_leftOfLastComma} ]]; then  #contains data
            if [[ "${docker__subTotInput_leftOfLastComma}" != "${docker__subTotInput_leftOfLastComma_bck}" ]]; then #not the same
                #Skip and Correct Unwanted chars in 'docker__subTotInput_leftOfLastComma'
                docker__subTotInput_leftOfLastComma=`skip_and_correct_unwanted_chars__func "${docker__subTotInput_leftOfLastComma}"`

                #Update variable
                if [[ -z ${docker__subTotInput_rightOfLastComma} ]]; then   #contains no data
                    if [[ ! -z ${docker__subTotInput_leftOfLastComma} ]]; then
                        docker__totInput="${docker__subTotInput_leftOfLastComma}${DOCKER__COMMA}"
                    else
                        docker__totInput=${DOCKER__EMPTYSTRING}
                    fi
                else    #contains data
                    docker__totInput="${docker__subTotInput_leftOfLastComma}${docker__subTotInput_rightOfLastComma}"
                fi
            fi
        fi
    fi
}


#---MAIN SUBROUTINE
main_sub() {
    docker__get_source_fullpath__sub

    docker__load_global_fpath_paths__sub

    docker__init_variables__sub

    docker__retrieve_all_cacheFpaths__sub

    docker__remove_files__sub

    docker__remove_allEmptyLines_and_append_caretReturn__sub

    docker__trim_info_toFit_within_specified_windowSize__sub

    docker__calc_numOfLines_of_inputArgs__sub

    docker__prev_next_var_set__sub

    docker__retrieve__exported_env_var__and__flag_repositoryTag_isFound__sub

    docker__init_move_link_checkout_or_profile_to_top__sub

    docker__show_menu_handler__sub
}



#---EXECUTE
main_sub
