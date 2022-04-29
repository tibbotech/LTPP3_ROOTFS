#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---INPUT ARGS
dockerFile_fpath__input=${1}
exp_env_var_type__input=${2}
menuOption_link__input=${3}
menuOption_checkout__input=${4}
menuOption_linkCheckoutProfile__input=${5}




#---SUBROUTINES
docker__load_environment_variables__sub() {
    #Define paths
    docker__LTPP3_ROOTFS_development_tools__fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__LTPP3_ROOTFS_development_tools__dir=$(dirname ${docker__LTPP3_ROOTFS_development_tools__fpath})
    docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/

    docker__global_filename="docker_global.sh"
    docker__global__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__global_filename}
}

docker__load_source_files__sub() {
    source ${docker__global__fpath}
}

docker__load_header__sub() {
    show_header__func "${DOCKER__TITLE}" "${DOCKER__TABLEWIDTH}" "${DOCKER__BG_ORANGE}" "${DOCKER__NUMOFLINES_2}" "${DOCKER__NUMOFLINES_0}"
}

docker__load_constants__sub() {
    DOCKER__LINK_MENUTITLE="${menuOption_link__input}"
    DOCKER__LINK_LOCATION_INFO="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR}: "
    DOCKER__LINK_MENUOPTIONS="${DOCKER__FOURSPACES_F6_CHOOSE}\n"
    DOCKER__LINK_MENUOPTIONS+="${DOCKER__FOURSPACES_F7_ADD}\n"
    DOCKER__LINK_MENUOPTIONS+="${DOCKER__FOURSPACES_F8_DEL}\n"
    DOCKER__LINK_MENUOPTIONS+="${DOCKER__FOURSPACES_F12_QUIT}"
    DOCKER__LINK_CHOOSE_LINK="Choose link: "
    DOCKER__LINK_ADD_LINK="Add link (${DOCKER__FG_YELLOW};c${DOCKER__NOCOLOR}lear): "
    DOCKER__LINK_DELETE_LINK="Del link: "

    DOCKER__CHECKOUT_MENUTITLE="${menuOption_checkout__input}"
    DOCKER__CHECKOUT_LOCATION_INFO="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR}: "
    DOCKER__CHECKOUT_MENUOPTIONS="${DOCKER__FOURSPACES_F6_CHOOSE}\n"
    DOCKER__CHECKOUT_MENUOPTIONS+="${DOCKER__FOURSPACES_F7_ADD}\n"
    DOCKER__CHECKOUT_MENUOPTIONS+="${DOCKER__FOURSPACES_F8_DEL}\n"
    DOCKER__CHECKOUT_MENUOPTIONS+="${DOCKER__FOURSPACES_F12_QUIT}"
    DOCKER__CHECKOUT_CHOOSE_CHECKOUT="Choose checkout: "
    DOCKER__CHECKOUT_ADD_CHECKOUT="Add checkout (${DOCKER__FG_YELLOW};c${DOCKER__NOCOLOR}lear): "
    DOCKER__CHECKOUT_DELETE_CHECKOUT="Del checkout: "

    DOCKER__PROFILE_MENUTITLE="${menuOption_linkCheckoutProfile__input}"
    DOCKER__PROFILE_LOCATION_INFO="${DOCKER__FOURSPACES}${DOCKER__FG_VERYLIGHTORANGE}Location${DOCKER__NOCOLOR}: "
    DOCKER__PROFILE_MENUOPTIONS1="${DOCKER__FOURSPACES_F6_CHOOSE}\n"
    DOCKER__PROFILE_MENUOPTIONS1+="${DOCKER__FOURSPACES_F7_ADD}\n"
    DOCKER__PROFILE_MENUOPTIONS1+="${DOCKER__FOURSPACES_F8_DEL}\n"
    DOCKER__PROFILE_MENUOPTIONS1+="${DOCKER__FOURSPACES_F12_QUIT}"
    DOCKER__PROFILE_MENUOPTIONS2="${DOCKER__FOURSPACES_F1_CHOOSE_LINK}\n"
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
    DOCKER__PROFILE_MATCHPATTERN3="${DOCKER__ENUM_FUNC_F1}" #paired with 'DOCKER__PROFILE_MENUOPTIONS3'
    DOCKER__PROFILE_MATCHPATTERN3+="${DOCKER__ONESPACE}"
    DOCKER__PROFILE_MATCHPATTERN3+="${DOCKER__ENUM_FUNC_F2}"
    DOCKER__PROFILE_MATCHPATTERN3+="${DOCKER__ONESPACE}"
    DOCKER__PROFILE_MATCHPATTERN3+="${DOCKER__ENUM_FUNC_F3}"
    DOCKER__PROFILE_MATCHPATTERN3+="${DOCKER__ONESPACE}"
    DOCKER__PROFILE_MATCHPATTERN3+="${DOCKER__ENUM_FUNC_F5}"
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
    docker__exp_env_var_menuOptions1=${DOCKER__EMPTYSTRING}
    docker__exp_env_var_menuOptions2=${DOCKER__EMPTYSTRING} #used only for 'link-checkout profile'
    docker__exp_env_var_menuOptions3=${DOCKER__EMPTYSTRING} #used only for 'link-checkout profile'
    docker__exp_env_var_matchPattern2=${DOCKER__EMPTYSTRING}    #used in combo with 'docker__exp_env_var_menuOptions2'
    docker__exp_env_var_matchPattern3=${DOCKER__EMPTYSTRING}    #used in combo with 'docker__exp_env_var_menuOptions3'
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
                        "${docker__exported_env_var_fpath}"
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
                        "${docker__exported_env_var_fpath}" \
                        "${docker__target_cacheFpath}" \
                        "${docker__allThreeCacheFpaths}" \
                        "${docker__show_choose_add_del_from_cache_out__fpath}" \
                        "${dockerFile_fpath__input}" \
                        "${exp_env_var_type__input}" \
                        "${DOCKER__TIMEOUT_0}"

    #Get the exitcode just in case a Ctrl-C was pressed in script 'docker__show_choose_add_del_from_cache__fpath'.
    docker__exitCode=$?
    if [[ ${docker__exitCode} -eq ${DOCKER__EXITCODE_99} ]]; then
        exit__func "${docker__exitCode}" "${DOCKER__NUMOFLINES_2}"
    fi
}



#---MAIN SUBROUTINE
main_sub() {
    docker__load_environment_variables__sub

    docker__load_source_files__sub

    docker__load_header__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__generate_and_create_cache_filenames__sub

    docker__prep_input_args__sub

    docker__show_choose_add_del_handler__sub
}



#---EXECUTE
main_sub
