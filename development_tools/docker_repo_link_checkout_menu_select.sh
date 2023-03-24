#!/bin/bash -m
#Remark: by using '-m' the INTERRUPT executed here will NOT propagate to the UPPERLAYER scripts
#---INPUT ARGS
dockerFile_fpath__input=${1}
exp_env_var_type__input=${2}
menuOption_link__input=${3}
menuOption_checkout__input=${4}
menuOption_linkCheckoutProfile__input=${5}



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
    #Remark: 
    #   The following constants will be passed into...
    #   ...script 'docker_show_choose_add_del_from_cache.sh'
    DOCKER__LINK_MENUTITLE="${menuOption_link__input}"
    DOCKER__LINK_LOCATION_INFO="${DOCKER__FOURSPACES}${DOCKER__FG_ORANGE223}Location${DOCKER__NOCOLOR}: "
    DOCKER__LINK_MENUOPTIONS="${DOCKER__FOURSPACES_F6_CHOOSE}\n"
    DOCKER__LINK_MENUOPTIONS+="${DOCKER__FOURSPACES_F7_ADD}\n"
    DOCKER__LINK_MENUOPTIONS+="${DOCKER__FOURSPACES_F8_DEL}\n"
    DOCKER__LINK_MENUOPTIONS+="${DOCKER__FOURSPACES_F12_QUIT}"
    DOCKER__LINK_CHOOSE_LINK="Choose link: "
    DOCKER__LINK_ADD_LINK="Add link (${DOCKER__FG_YELLOW};c${DOCKER__NOCOLOR}lear): "
    DOCKER__LINK_DELETE_LINK="Del link: "

    DOCKER__CHECKOUT_MENUTITLE="${menuOption_checkout__input}"
    DOCKER__CHECKOUT_LOCATION_INFO="${DOCKER__FOURSPACES}${DOCKER__FG_ORANGE223}Location${DOCKER__NOCOLOR}: "
    DOCKER__CHECKOUT_MENUOPTIONS="${DOCKER__FOURSPACES_F6_CHOOSE}\n"
    DOCKER__CHECKOUT_MENUOPTIONS+="${DOCKER__FOURSPACES_F7_ADD}\n"
    DOCKER__CHECKOUT_MENUOPTIONS+="${DOCKER__FOURSPACES_F8_DEL}\n"
    DOCKER__CHECKOUT_MENUOPTIONS+="${DOCKER__FOURSPACES_F12_QUIT}"
    DOCKER__CHECKOUT_CHOOSE_CHECKOUT="Choose checkout: "
    DOCKER__CHECKOUT_ADD_CHECKOUT="Add checkout (${DOCKER__FG_YELLOW};c${DOCKER__NOCOLOR}lear): "
    DOCKER__CHECKOUT_DELETE_CHECKOUT="Del checkout: "

    DOCKER__PROFILE_MENUTITLE="${menuOption_linkCheckoutProfile__input}"
    DOCKER__PROFILE_LOCATION_INFO="${DOCKER__FOURSPACES}${DOCKER__FG_ORANGE223}Location${DOCKER__NOCOLOR}: "
    DOCKER__PROFILE_MENUOPTIONS1="${DOCKER__FOURSPACES_F6_CHOOSE}\n"
    DOCKER__PROFILE_MENUOPTIONS1+="${DOCKER__FOURSPACES_F7_ADD}\n"
    DOCKER__PROFILE_MENUOPTIONS1+="${DOCKER__FOURSPACES_F8_DEL}\n"
    DOCKER__PROFILE_MENUOPTIONS1+="${DOCKER__FOURSPACES_F12_QUIT}"

    #Remark: 
    #   The following constants will be passed into...
    #   ...function 'show_pathContent_w_selection__func'...
    #   ...in script 'docker_show_choose_add_del_from_cache.sh'
    DOCKER__PROFILE_MENUOPTIONS2="${DOCKER__FOURSPACES_F1_CHOOSE_LINK}\n"   #
    DOCKER__PROFILE_MENUOPTIONS2+="${DOCKER__FOURSPACES_F2_CHOOSE_CHECKOUT}\n"
    DOCKER__PROFILE_MENUOPTIONS2+="${DOCKER__FOURSPACES_F5_ABORT}\n"
    DOCKER__PROFILE_MENUOPTIONS2+="${DOCKER__FOURSPACES_F12_QUIT}"
    DOCKER__PROFILE_MENUOPTIONS3="${DOCKER__FOURSPACES_F1_CHOOSE_LINK}\n"
    DOCKER__PROFILE_MENUOPTIONS3+="${DOCKER__FOURSPACES_F2_CHOOSE_CHECKOUT}\n"
    DOCKER__PROFILE_MENUOPTIONS3+="${DOCKER__FOURSPACES_F3_CONFIRM}\n"
    DOCKER__PROFILE_MENUOPTIONS3+="${DOCKER__FOURSPACES_F5_ABORT}\n"
    DOCKER__PROFILE_MENUOPTIONS3+="${DOCKER__FOURSPACES_F12_QUIT}"
    DOCKER__PROFILE_MATCHPATTERN2="${DOCKER__ENUM_FUNC_F1}" #paired with 'DOCKER__PROFILE_MENUOPTIONS2'
    DOCKER__PROFILE_MATCHPATTERN2+="${DOCKER__ONESPACE}"
    DOCKER__PROFILE_MATCHPATTERN2+="${DOCKER__ENUM_FUNC_F2}"
    DOCKER__PROFILE_MATCHPATTERN2+="${DOCKER__ONESPACE}"
    DOCKER__PROFILE_MATCHPATTERN2+="${DOCKER__ENUM_FUNC_F5}"
    DOCKER__PROFILE_MATCHPATTERN2+="${DOCKER__ONESPACE}"
    DOCKER__PROFILE_MATCHPATTERN2+="${DOCKER__ENUM_FUNC_F12}"
    DOCKER__PROFILE_MATCHPATTERN3="${DOCKER__ENUM_FUNC_F1}" #paired with 'DOCKER__PROFILE_MENUOPTIONS3'
    DOCKER__PROFILE_MATCHPATTERN3+="${DOCKER__ONESPACE}"
    DOCKER__PROFILE_MATCHPATTERN3+="${DOCKER__ENUM_FUNC_F2}"
    DOCKER__PROFILE_MATCHPATTERN3+="${DOCKER__ONESPACE}"
    DOCKER__PROFILE_MATCHPATTERN3+="${DOCKER__ENUM_FUNC_F3}"
    DOCKER__PROFILE_MATCHPATTERN3+="${DOCKER__ONESPACE}"
    DOCKER__PROFILE_MATCHPATTERN3+="${DOCKER__ENUM_FUNC_F5}"
    DOCKER__PROFILE_MATCHPATTERN3+="${DOCKER__ONESPACE}"
    DOCKER__PROFILE_MATCHPATTERN3+="${DOCKER__ENUM_FUNC_F12}"
    DOCKER__PROFILE_CHOOSE_PROFILE="Choose profile: "
    DOCKER__PROFILE_ADD_PROFILE="Add profile:"  #notice: there is NO trailing space
    # DOCKER__PROFILE_ADD_PROFILE="Add new profile by choosing ${DOCKER__FG_GREEN41}link${DOCKER__NOCOLOR}(${DOCKER__FG_LIGHTGREY}F2${DOCKER__NOCOLOR})"
    # DOCKER__PROFILE_ADD_PROFILE+="-"
    # DOCKER__PROFILE_ADD_PROFILE+="${DOCKER__FG_GREEN119}checkout${DOCKER__NOCOLOR}(${DOCKER__FG_LIGHTGREY}F3${DOCKER__NOCOLOR})"
    # DOCKER__PROFILE_ADD_PROFILE+=" pair"
    DOCKER__PROFILE_DELETE_PROFILE="Del profile: "
}

docker__init_variables__sub() {
    docker__allThreeCacheFpaths=${DOCKER__EMPTYSTRING}
    docker__target_cacheFpath=${DOCKER__EMPTYSTRING}
    docker__linkCacheFpath=${DOCKER__EMPTYSTRING}
    docker__checkoutCacheFpath=${DOCKER__EMPTYSTRING}
    docker__linkCheckoutProfileCacheFpath=${DOCKER__EMPTYSTRING}

    docker__exp_env_var_menuTitle=${DOCKER__EMPTYSTRING}
    docker__exp_env_var_locationInfo=${DOCKER__EMPTYSTRING}
    docker__exp_env_var_locationInfo_fpath=${DOCKER__EMPTYSTRING}
    docker__exp_env_var_menuOptions1=${DOCKER__EMPTYSTRING}     #passed into script 'docker_show_choose_add_del_from_cache.sh' (this is reason why no 'docker__exp_env_var_matchPattern1' is defined)
    docker__exp_env_var_menuOptions2=${DOCKER__EMPTYSTRING}     #used only for 'link-checkout profile'; passed into function 'show_pathContent_w_selection__func'
    docker__exp_env_var_menuOptions3=${DOCKER__EMPTYSTRING}     #used only for 'link-checkout profile'; passed into function 'show_pathContent_w_selection__func'
    docker__exp_env_var_matchPattern2=${DOCKER__EMPTYSTRING}    #used in combo with 'docker__exp_env_var_menuOptions2'; passed into function 'show_pathContent_w_selection__func'
    docker__exp_env_var_matchPattern3=${DOCKER__EMPTYSTRING}    #used in combo with 'docker__exp_env_var_menuOptions3'; passed into function 'show_pathContent_w_selection__func'
    docker__exp_env_var_option_choose=${DOCKER__EMPTYSTRING}
    docker__exp_env_var_option_add=${DOCKER__EMPTYSTRING}
    docker__exp_env_var_option_del=${DOCKER__EMPTYSTRING}

    docker__exitCode=0
}

docker__generate_and_create_cache_filenames__sub() {
    #Generate cache-filenames (e.g. ltps_sunplus__latest__link.cache, ltps_sunplus__latest__checkout.cache)
    #Remarks:
    #   'docker__allThreeCacheFpaths' contains 2 outputs which are separated by  a 'SED__RS'.
    #   1. 'link_cache_fpath'
    #   2. 'checkout_cache_fpath'
    #   3. 'linkCheckoutProfile_cache_fpath'  
    docker__allThreeCacheFpaths=`generate_cache_filenames_basedOn_specified_repositoryTag__func "${docker__docker_cache__dir}" "${dockerFile_fpath__input}"`
    docker__linkCacheFpath=`echo "${docker__allThreeCacheFpaths}" | cut -d"${SED__RS}" -f1`
    docker__checkoutCacheFpath=`echo "${docker__allThreeCacheFpaths}" | cut -d"${SED__RS}" -f2`
    docker__linkCheckoutProfileCacheFpath=`echo "${docker__allThreeCacheFpaths}" | cut -d"${SED__RS}" -f3`

    #Create and write data to the cache-files.
    createAndWrite_data_to_cacheFiles_ifNotExist__func "${docker__linkCacheFpath}" \
                        "${docker__checkoutCacheFpath}" \
                        "${docker__linkCheckoutProfileCacheFpath}" \
                        "${dockerFile_fpath__input}" \
                        "${docker__exported_env_var__fpath}"
}

docker__prep_input_args__sub() {
    case "${exp_env_var_type__input}" in
        ${DOCKER__LINK})
            docker__exp_env_var_menuTitle=${DOCKER__LINK_MENUTITLE}
            docker__exp_env_var_locationInfo_fpath="${DOCKER__FG_LIGHTGREY}${docker__linkCacheFpath}${DOCKER__NOCOLOR}"
            docker__exp_env_var_locationInfo="${DOCKER__LINK_LOCATION_INFO}"
            docker__exp_env_var_locationInfo+="${docker__exp_env_var_locationInfo_fpath}"
            docker__exp_env_var_menuOptions1=${DOCKER__LINK_MENUOPTIONS}
            docker__exp_env_var_menuOptions2=${DOCKER__EMPTYSTRING}
            docker__exp_env_var_menuOptions3=${DOCKER__EMPTYSTRING}
            docker__exp_env_var_matchPattern2=${DOCKER__EMPTYSTRING}
            docker__exp_env_var_matchPattern3=${DOCKER__EMPTYSTRING}
            docker__exp_env_var_option_choose=${DOCKER__LINK_CHOOSE_LINK}
            docker__exp_env_var_option_add=${DOCKER__LINK_ADD_LINK}
            docker__exp_env_var_option_del=${DOCKER__LINK_DELETE_LINK}

            docker__target_cacheFpath=${docker__linkCacheFpath}
            ;;
        ${DOCKER__CHECKOUT})
            docker__exp_env_var_menuTitle=${DOCKER__CHECKOUT_MENUTITLE}
            docker__exp_env_var_locationInfo_fpath="${DOCKER__FG_LIGHTGREY}${docker__checkoutCacheFpath}${DOCKER__NOCOLOR}"
            docker__exp_env_var_locationInfo="${DOCKER__CHECKOUT_LOCATION_INFO}"
            docker__exp_env_var_locationInfo+="${docker__exp_env_var_locationInfo_fpath}"
            docker__exp_env_var_menuOptions1=${DOCKER__CHECKOUT_MENUOPTIONS}
            docker__exp_env_var_menuOptions2=${DOCKER__EMPTYSTRING}
            docker__exp_env_var_menuOptions3=${DOCKER__EMPTYSTRING}
            docker__exp_env_var_matchPattern2=${DOCKER__EMPTYSTRING}
            docker__exp_env_var_matchPattern3=${DOCKER__EMPTYSTRING}
            docker__exp_env_var_option_choose=${DOCKER__CHECKOUT_CHOOSE_CHECKOUT}
            docker__exp_env_var_option_add=${DOCKER__CHECKOUT_ADD_CHECKOUT}
            docker__exp_env_var_option_del=${DOCKER__CHECKOUT_DELETE_CHECKOUT}

            docker__target_cacheFpath=${docker__checkoutCacheFpath}
            ;;
        ${DOCKER__LINKCHECKOUT_PROFILE})
            docker__exp_env_var_menuTitle=${DOCKER__PROFILE_MENUTITLE}
            docker__exp_env_var_locationInfo_fpath="${DOCKER__FG_LIGHTGREY}${docker__linkCheckoutProfileCacheFpath}${DOCKER__NOCOLOR}"
            docker__exp_env_var_locationInfo="${DOCKER__PROFILE_LOCATION_INFO}"
            docker__exp_env_var_locationInfo+="${docker__exp_env_var_locationInfo_fpath}"
            docker__exp_env_var_menuOptions1=${DOCKER__PROFILE_MENUOPTIONS1}
            docker__exp_env_var_menuOptions2=${DOCKER__PROFILE_MENUOPTIONS2}
            docker__exp_env_var_menuOptions3=${DOCKER__PROFILE_MENUOPTIONS3}
            docker__exp_env_var_matchPattern2=${DOCKER__PROFILE_MATCHPATTERN2}
            docker__exp_env_var_matchPattern3=${DOCKER__PROFILE_MATCHPATTERN3}
            docker__exp_env_var_option_choose=${DOCKER__PROFILE_CHOOSE_PROFILE}
            docker__exp_env_var_option_add=${DOCKER__PROFILE_ADD_PROFILE}
            docker__exp_env_var_option_del=${DOCKER__PROFILE_DELETE_PROFILE}

            docker__target_cacheFpath=${docker__linkCheckoutProfileCacheFpath}
            ;;
    esac
}

docker__show_choose_add_del_handler__sub() {
    #Execute script show/choose/add/del git-link(s)
    ${docker__show_choose_add_del_from_cache__fpath} "${docker__exp_env_var_menuTitle}" \
                        "${docker__exp_env_var_locationInfo}" \
                        "${docker__exp_env_var_menuOptions1}" \
                        "${docker__exp_env_var_menuOptions2}" \
                        "${docker__exp_env_var_menuOptions3}" \
                        "${docker__exp_env_var_matchPattern2}" \
                        "${docker__exp_env_var_matchPattern3}" \
                        "${docker__exp_env_var_option_choose}" \
                        "${docker__exp_env_var_option_add}" \
                        "${docker__exp_env_var_option_del}" \
                        "${docker__exported_env_var__fpath}" \
                        "${docker__target_cacheFpath}" \
                        "${docker__allThreeCacheFpaths}" \
                        "${docker__show_choose_add_del_from_cache_out__fpath}" \
                        "${dockerFile_fpath__input}" \
                        "${exp_env_var_type__input}" \
                        "${DOCKER__TIMEOUT_0}" \
                        "${DOCKER__NUMOFLINES_2}"

    #Get the exitcode just in case a Ctrl-C was pressed in script 'docker__show_choose_add_del_from_cache__fpath'.
    docker__exitCode=$?
    if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
        exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_1}"
    fi
}



#---MAIN SUBROUTINE
main_sub() {
    docker__get_source_fullpath__sub

    docker__load_global_fpath_paths__sub

    # load_tibbo_title__func "${DOCKER__NUMOFLINES_2}"

    docker__load_constants__sub

    docker__init_variables__sub

    docker__generate_and_create_cache_filenames__sub

    docker__prep_input_args__sub

    docker__show_choose_add_del_handler__sub
}



#---EXECUTE
main_sub
