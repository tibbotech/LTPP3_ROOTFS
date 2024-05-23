#!/bin/bash -m
#Remark: by using '-m' the INTERRUPT executed here will NOT propagate to the UPPERLAYER scripts
#---INPUT ARGS
disksize__input=${1}
global_fpath__input=${2}



#---FUNCTIONS
docker__readdialog_w_output__func() {
    #Input args
    local readdialog__input=${1}
    local readdialog_default__input=${2}
    
    #Define variables
    local ret="${DOCKER__EMPTYSTRING}"

    #Initialize variables
    docker__readdialog_output="${DOCKER__EMPTYSTRING}"

    #Show readinputdialog
    readDialog_w_Output__func "${readdialog__input}" \
            "${readdialog_default__input}" \
            "${docker__readDialog_w_Output__func_out__fpath}" \
            "${DOCKER__NUMOFLINES_0}" \
            "${DOCKER__NUMOFLINES_0}"

    #Get the exitcode just in case a Ctrl-C was pressed in function 'readDialog_w_Output__func'
    docker__exitcode=$?
    if [[ ${docker__exitcode} -eq ${DOCKER__EXITCODE_99} ]]; then
        docker__readdialog_output="${DOCKER__EMPTYSTRING}"
    else
        #Get docker__result_from_output
        docker__readdialog_output=`retrieve_line_from_file__func "${DOCKER__LINENUM_1}" \
                        "${docker__readDialog_w_Output__func_out__fpath}"`
    fi
}


#---SUBROUTINES
#Check if 'docker_global.sh' is already loaded.
#Note: this can be simply done by trying to read the constant 'DOCKER__THISFILE_ISREACHABLE'
docker__check_inputarg__sub() {
    if [[ -z "${global_fpath__input}" ]]; then
        docker__tmp__dir=/tmp
        docker__development_tools__foldername="development_tools"
        docker__global__filename="docker_global.sh"
        docker__mainmenu_path_cache__filename="docker__mainmenu_path.cache"
        docker__mainmenu_path_cache__fpath="${docker__tmp__dir}/${docker__mainmenu_path_cache__filename}"

        if [[ ! -f "${docker__mainmenu_path_cache__fpath}" ]]; then
            echo -e "\r"
            echo -e "***\e[1;31mERROR\e[0;0m: \e[30;38;5;246mInput argument\e[0;0m: \e[30;38;5;131mNOT provided\e[0;0m"
            echo -e "\r"

            exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_0}"
        else
            #Get the directory stored in cache-file
            docker__LTPP3_ROOTFS_development_tools__dir=$(awk 'NR==1' "${docker__mainmenu_path_cache__fpath}")

            #Get fullpath of 'docker_global.sh'
            global_fpath__input="${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__global__filename}"
        fi
    fi
}

docker__load_global_fpath_paths__sub() {
    source ${global_fpath__input}
}

docker__load_constants__sub() {
    DOCKER__MENUTITLE="${DOCKER__FG_LIGHTBLUE}DOCKER: "
    DOCKER__MENUTITLE+="${DOCKER__FG_DARKBLUE}CONFIGURE "
    DOCKER__MENUTITLE+="${DOCKER__FG_RED9}DISK${DOCKER__NOCOLOR}-${DOCKER__FG_RED9}PARTITION${DOCKER__NOCOLOR} "
    DOCKER__MENUTITLE+="(${DOCKER__FG_DARKBLUE}MB${DOCKER__NOCOLOR})"

    DOCKER__ERRMSG_ALREADY_INUSE="${DOCKER__FG_LIGHTRED}already in-use${DOCKER__NOCOLOR}"
    DOCKER__ERRMSG_CANNOT_BE_ZERO="${DOCKER__FG_LIGHTRED}can't be zero${DOCKER__NOCOLOR}"
    DOCKER__ERRMSG_INVALID="${DOCKER__FG_LIGHTRED}invalid${DOCKER__NOCOLOR}"
    DOCKER__ERRMSG_TOO_LARGE="${DOCKER__FG_LIGHTRED}too large${DOCKER__NOCOLOR}"

    DOCKER__ERRMSG_DOCKER_FS_PARTITION_CONF_NOT_EXIST="${DOCKER__ERROR}: file ${DOCKER__FG_LIGHTGREY_250}${docker__docker_overlayfs__dir}${DOCKER__NOCOLOR}/"
    DOCKER__ERRMSG_DOCKER_FS_PARTITION_CONF_NOT_EXIST+="${DOCKER__FG_LIGHTGREY}${docker__docker_fs_partition_conf__filename}${DOCKER__NOCOLOR} ${DOCKER__FG_LIGHTRED}not${DOCKER__NOCOLOR} found.\n"
    DOCKER__ERRMSG_DOCKER_FS_PARTITION_CONF_NOT_EXIST+="${DOCKER__ERROR}: parameter ${DOCKER__FG_LIGHTGREY}Disksize-setting${DOCKER__NOCOLOR} ${DOCKER__FG_LIGHTRED}not${DOCKER__NOCOLOR} set!!!"

    DOCKER__WRNMSG_OVERLAY_LESSTHAN_RECOMMEND_VALUE="${DOCKER__FG_LIGHTPINK}< recommended value: ${DOCKER__OVERLAY_SIZE_DEFAULT}${DOCKER__NOCOLOR}"
    DOCKER__WRNMSG_ROOTFS_LESSTHAN_RECOMMEND_VALUE="${DOCKER__FG_LIGHTPINK}< recommended value: ${DOCKER__ROOTFS_SIZE_DEFAULT}${DOCKER__NOCOLOR}"
    DOCKER__WRNMSG_SWAPFILE_GREATERTHAN_RECOMMEND_VALUE="${DOCKER__FG_LIGHTPINK}> recommended value: ${DOKCER__SWAPFILE_SIZE_DEFAULT}${DOCKER__NOCOLOR}"
    DOCKER__INFOMSG_UNALLOCATED_DISKSPACE_LEFT="${DOCKER__FG_ORANGE130}unallocated${DOCKER__NOCOLOR} diskspace left:"

    DOCKER__READDIALOG_HEADER="---:${DOCKER__INPUT}"
}

docker__init_variables__sub() {
    docker__docker_fs_partition_diskpartsize_dat_userdefined__fpath="${DOCKER__EMPTYSTRING}"

    docker__disksize_set=0
    docker__overlaymode_set="${DOCKER__OVERLAYMODE_NONPERSISTENT}"
    docker__overlaysetting_set="${DOCKER__OVERLAYFS_DISABLED}"

    docker__readdialog_output="${DOCKER__EMPTYSTRING}"

    docker__reservedfs_size=${DOCKER__RESERVED_SIZE_DEFAULT}
    docker__rootfs_size=${DOCKER__ROOTFS_SIZE_DEFAULT}
    docker__overlay_size=$((disksize__input - docker__reservedfs_size - docker__rootfs_size))
    docker__remain_size=0
    docker__remain_size_bck=0

    #***NOTE: the reason why 'swapfile' is NOT added to this array is because
    #   'swapfile' is part of 'tb_reserve'
    docker__isp_partition_array_default=()
    docker__isp_partition_array_default[0]="${DOCKER__DISKPARTNAME_TB_RESERVE} ${docker__reservedfs_size}"
    docker__isp_partition_array_default[1]="${DOCKER__DISKPARTNAME_ROOTFS} ${docker__rootfs_size}"
    docker__isp_partition_array_default[2]="${DOCKER__DISKPARTNAME_OVERLAY} ${docker__overlay_size}"
    docker__isp_partition_array_default[3]="${DOCKER__DISKPARTNAME_REMAINING} ${docker__remain_size}"

    #***NOTE: the reason why 'swapfile' is NOT added to this array is because
    #   'swapfile' is part of 'tb_reserve'
    docker__isp_partition_array=("${docker__isp_partition_array_default[@]}")
    docker__isp_partition_writetofile_array=("${docker__isp_partition_array_default[@]}")

    docker__diskpartname="${DOCKER__EMPTYSTRING}"
    docker__diskpartsize="${DOCKER__EMPTYSTRING}"

    docker__exitcode=0

    docker__regex3q="[3q]"
    docker__regex1234q="[1-4q]"
    docker__regex="${docker__regex1234q}"
}

docker__preprep__sub() {
    #Define variables
    local backupFile_isFound=false

    #---------------------------------------------------------------------
    #***IMPORTANT: check if file exist
    #---------------------------------------------------------------------
    if [[ ! -f "${docker__docker_fs_partition_conf__fpath}" ]]; then    #file does NOT exist
        #Print
        show_msg_only__func "${DOCKER__ERRMSG_DOCKER_FS_PARTITION_CONF_NOT_EXIST}" "${DOCKER__NUMOFLINES_2}" "${DOCKER__NUMOFLINES_0}"

        exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_0}"
    fi

    #---------------------------------------------------------------------
    #REMOVE FILE: docker__docker_fs_partition_diskpartsize_dat__fpath
    #---------------------------------------------------------------------
    if [[ -f "${docker__docker_fs_partition_diskpartsize_dat__fpath}" ]]; then
        rm "${docker__docker_fs_partition_diskpartsize_dat__fpath}"
    fi

    #---------------------------------------------------------------------
    #DISK-SIZE SETTING: RETRIEVE
    #---------------------------------------------------------------------
    docker__disksize_set=$(retrieve__data_specified_by_col_within_file__func "${DOCKER__DISKSIZESETTING}" \
            "${DOCKER__COLNUM_2}" \
            "${docker__docker_fs_partition_conf__fpath}")

    #---------------------------------------------------------------------
    #DOCKER_FS_PARTITION_DISKPARTSIZE.DAT: RESTORE FROM BACKUP
    #---------------------------------------------------------------------
    case "${docker__disksize_set}" in
        "${DOCKER__DISKSIZE_4G_IN_MBYTES}")
            #Check if file exist
            if [[ -f "${docker__docker_fs_partition_diskpartsize_dat_4g__fpath}" ]]; then   #file exists
                #Rename file
                cp "${docker__docker_fs_partition_diskpartsize_dat_4g__fpath}" "${docker__docker_fs_partition_diskpartsize_dat__fpath}"

                #Change flag to 'true'
                backupFile_isFound=true
            fi
            ;;
        "${DOCKER__DISKSIZE_8G_IN_MBYTES}")
            #Check if file exist
            if [[ -f "${docker__docker_fs_partition_diskpartsize_dat_8g__fpath}" ]]; then   #file exists
                #Rename file
                cp "${docker__docker_fs_partition_diskpartsize_dat_8g__fpath}" "${docker__docker_fs_partition_diskpartsize_dat__fpath}"

                #Change flag to 'true'
                backupFile_isFound=true
            fi
            ;;
        *)
            #Update 'docker__docker_fs_partition_diskpartsize_dat_userdefined__fpath'
            #Note: each USER-DEFINED disk-size setting has a backup filename with the following format:
            #   ${docker__docker_fs_partition_diskpartsize_dat__fpath}.${docker__disksize_set}
            #Example:
            #   docker_fs_partition_diskpartsize.dat.3000   (with '3000' in 'MB')
            docker__docker_fs_partition_diskpartsize_dat_userdefined__fpath="${docker__docker_fs_partition_diskpartsize_dat__fpath}.${docker__disksize_set}"

            #Check if file exist
            if [[ -f "${docker__docker_fs_partition_diskpartsize_dat_userdefined__fpath}" ]]; then   #file exists
                #Rename file
                cp "${docker__docker_fs_partition_diskpartsize_dat_userdefined__fpath}" "${docker__docker_fs_partition_diskpartsize_dat__fpath}"

                #Change flag to 'true'
                backupFile_isFound=true
            fi
            ;;
    esac

    #---------------------------------------------------------------------
    #DISK-PARTITION:
    #1. Update array 'docker__isp_partition_array'
    #2. Write file 'docker__docker_fs_partition_diskpartsize_dat__fpath'
    #---------------------------------------------------------------------
    if [[ "${backupFile_isFound}" == true ]]; then
        #Reset array
        docker__isp_partition_array=()

        #Read each line from file
        while read line
        do
            #Add each line to array
            docker__isp_partition_array[i]="${line}"

            #Increment index by 1
            ((i++))
        done < "${docker__docker_fs_partition_diskpartsize_dat__fpath}"
    else
        docker__isp_part_arr_update_and_writeto_file "${docker__isp_partition_array_default[@]}"
    fi

    #---------------------------------------------------------------------
    #OVERLAY-MODE: retrieve from file
    #---------------------------------------------------------------------
    docker__overlaymode_set=$(retrieve__data_specified_by_col_within_file__func "${DOCKER__OVERLAYMODE}" \
            "${DOCKER__COLNUM_2}" \
            "${docker__docker_fs_partition_conf__fpath}")
    #Remark:
    #   It could happen that 'docker__overlaymode_set' is NOT set  yet
    #   In that case, automatically set 'docker__overlaymode_set' to the default setting 'DOCKER__OVERLAYMODE_NONPERSISTENT'.
    if [[ -z "${docker__overlaymode_set}" ]]; then  #file is found
        #Set variable
        docker__overlaymode_set="${DOCKER__OVERLAYMODE_NONPERSISTENT}"

        #Generate 'filecontent'
        filecontent="${DOCKER__OVERLAYMODE} ${docker__overlaymode_set}"

        #Replace/Append to file
        replace_or_append_string_based_on_pattern_in_file__func "${filecontent}" \
                "${DOCKER__OVERLAYMODE}" \
                "${docker__docker_fs_partition_conf__fpath}" \
                "${DOCKER__FALSE}"
    fi


    #---------------------------------------------------------------------
    #OVERLAY-SETTING: retrieve from file
    #---------------------------------------------------------------------
    docker__overlaysetting_set=$(retrieve__data_specified_by_col_within_file__func "${DOCKER__OVERLAYSETTING}" \
            "${DOCKER__COLNUM_2}" \
            "${docker__docker_fs_partition_conf__fpath}")
    #Remark:
    #   It can happen that 'docker__overlaysetting_set' is an 'Empty String'
    #   ...in case file 'docker__docker_fs_partition_conf__fpath' has
    #   ...no 'DOCKER__OVERLAYSETTING' input.
    #   In that case, automatically set 'docker__overlaysetting_set = DOCKER__OVERLAYFS_DISABLED'.
    if [[ -z "${docker__overlaysetting_set}" ]]; then
        docker__overlaysetting_set="${DOCKER__OVERLAYFS_DISABLED}"

        #Generate 'filecontent'
        filecontent="${DOCKER__OVERLAYSETTING} ${DOCKER__OVERLAYFS_DISABLED}"

        #Replace/Append to file
        replace_or_append_string_based_on_pattern_in_file__func "${filecontent}" \
                "${DOCKER__OVERLAYSETTING}" \
                "${docker__docker_fs_partition_conf__fpath}" \
                "${DOCKER__FALSE}"
    fi
}

docker__menu__sub() {
    #Define variables
    local diskpart_arritem="${DOCKER__EMPTYSTRING}"
    local exitcode=0
    local grep_overlay="${DOCKER__EMPTYSTRING}"
    local mychoice="${DOCKER__EMPTYSTRING}"
    local ret=0

    #Show menu
    while true
    do
        #Enable Ctrl+C
        enable_ctrl_c__func

        #IMPORTANT: reset variables
        docker__regex="${docker__regex1234q}"
        exitcode=0

        #Get Git-information
        #Output:
        #   docker_git_current_info_msg
        docker__menu_get_git_info__sub

        #Load header
        load_tibbo_title__func "${DOCKER__NUMOFLINES_2}"

        #Print horizontal line
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Print menut-title
        show_leadingAndTrailingStrings_separatedBySpaces__func "${DOCKER__MENUTITLE}" "${docker_git_current_info_msg}" "${DOCKER__TABLEWIDTH}"

        #Print horizontal line
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Print body
        docker__menu_body_print_sub

        #Movedown and clean line(s)
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        #Print horizontal line
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Print menu-options
        docker__menu_options_print_sub

        #Print horizontal line
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Check if 'overlay' partition is present in 'docker__isp_partition_array'
        #Remark:
        #   If 'overlay' partition is NOT present, then DISABLE option '3' and '4'
        grep_overlay=$(echo ${docker__isp_partition_array[@]} | grep -w "${DOCKER__DISKPARTNAME_OVERLAY}")
        if [[ -z "${grep_overlay}" ]] || \
            [[ "${docker__overlaysetting_set}" == "${DOCKER__OVERLAYFS_DISABLED}" ]]; then  #'overlay' is NOT found or Disabled
            docker__regex="${docker__regex3q}"
        fi

        while true
        do
            #Select an option
            read -N1 -r -p "Please choose an option: " mychoice
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            #Only continue if a valid option is selected
            if [[ ! -z ${mychoice} ]]; then
                if [[ ${mychoice} =~ ${docker__regex} ]]; then
                    break
                else
                    if [[ ${mychoice} == ${DOCKER__ENTER} ]]; then
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
        case ${mychoice} in
            1)  
                #Disable Ctrl+C
                disable_ctrl_c__func

                docker__partitiondisk__sub "true" "${docker__isp_partition_array_default[@]}"
                ;;
            2)
                #Disable Ctrl+C
                disable_ctrl_c__func

                docker__partitiondisk__sub "false" "${docker__isp_partition_array[@]}"
                ;;
            3)
                docker__overlaysetting__sub
                ;;
            4)
                docker__overlaymode__sub
                ;;
            q)
                exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_1}"
                ;;
        esac
    done

    #Write to file
    write_data_to_file__func "${ret}" "${docker__fs_partition_disksize_menu_output__fpath}"
}
docker__menu_get_git_info__sub() {
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
docker__menu_body_print_sub() {
    #Define variables
    local diskpart_arritem="${DOCKER__EMPTYSTRING}"
    local diskpart_arritem_left="${DOCKER__EMPTYSTRING}"
    local diskpart_arritem_right="${DOCKER__EMPTYSTRING}"
    local diskpart_arritem_print="${DOCKER__EMPTYSTRING}"
    local diskpart_arritem_left_len=0
    local diskpart_arritem_left_max=0


    #---------------------------------------------------------------------
    #---THIS PART IS DEDICATED TO THE PRINTING OF THE:
    #       LEFT-STRING (e.g. rootfs, tb_reserve, overlay, etc.)
    #       RIGHT-STRING (e.g. 1536, 128, 256 etc...)
    #Determine the longest string of 'diskpart_arritem_left'
    #---------------------------------------------------------------------
    diskpart_arritem_left_max=$(printf '%s\n' ${docker__isp_partition_array[@]} | wc -L)

    #---------------------------------------------------------------------
    #Increase 'diskpart_arritem_left_max' with '4'
    #Remark:
    #   This is the Empty Space between the left-string and right-string
    #---------------------------------------------------------------------
    diskpart_arritem_left_max=$((diskpart_arritem_left_max + DOCKER__NUMOFCHARS_8))

    #---------------------------------------------------------------------
    #Print 'partition sizes'
    #---------------------------------------------------------------------
    for diskpart_arritem in "${docker__isp_partition_array[@]}"
    do  
        #Get the left-string 'diskpart_arritem_left'
        diskpart_arritem_left=$(echo "${diskpart_arritem}" | cut -d" " -f1)

        #Append 'Empty Spaces' to 'diskpart_arritem_left'
        diskpart_arritem_left=$(append_a_specified_numofchars_to_string "${diskpart_arritem_left}" \
                "${DOCKER__ONESPACE}" \
                "${diskpart_arritem_left_max}")

        #Get the right-string 'diskpart_arritem_right'
        diskpart_arritem_right=$(echo "${diskpart_arritem}" | cut -d" " -f2)

        #Update variable
        diskpart_arritem_print="${DOCKER__FOURSPACES}${DOCKER__FG_ORANGE172}${diskpart_arritem_left}${DOCKER__NOCOLOR}"
        diskpart_arritem_print+="${DOCKER__FG_ORANGE215}${diskpart_arritem_right}${DOCKER__NOCOLOR}"

        #Print
        echo -e "${diskpart_arritem_print}"

        # #Calculate the 'disksize_remain'
        # disksize_remain=$(bc_substract_x_from_y "${disksize_remain}" "${diskpart_arritem_right}")
    done
}
docker__menu_options_print_sub() {
    #Define variables
    local configpartitions_print="${DOCKER__EMPTYSTRING}"
    local overlaymode_print="${DOCKER__EMPTYSTRING}"
    local overlaysetting_print="${DOCKER__EMPTYSTRING}"
    local grep_overlay="${DOCKER__EMPTYSTRING}"
    
    #---------------------------------------------------------------------
    #OVERLAY-SETTING:
    #Check if 'overlay' partition is present in 'docker__isp_partition_array'
    #---------------------------------------------------------------------
    grep_overlay=$(echo ${docker__isp_partition_array[@]} | grep -w "${DOCKER__DISKPARTNAME_OVERLAY}")
    if [[ -n "${grep_overlay}" ]]; then  #pattern 'overlay' is found
        overlaysetting_print="${DOCKER__FOURSPACES}3. ${DOCKER__OVERLAYSETTING} "

        if [[ "${docker__overlaysetting_set}" == "${DOCKER__OVERLAYFS_ENABLED}" ]]; then
            overlaysetting_print+="(${DOCKER__FG_GREEN158}${docker__overlaysetting_set}${DOCKER__NOCOLOR})"
        else
            overlaysetting_print+="(${DOCKER__FG_RED187}${docker__overlaysetting_set}${DOCKER__NOCOLOR})"
        fi
    else    #pattern 'overlay' is NOT found
        overlaysetting_print="${DOCKER__FG_LIGHTGREY}${DOCKER__FOURSPACES}3.${DOCKER__NOCOLOR} ${DOCKER__OVERLAYSETTING} "

        #IMPORTANT TO KNOW:
        #   The menu shows 'Overlay-setting (disableD)', but
        #   ...the ACTUAL value which is stored in file 'docker_fs_partition.conf' stays untouched.
        overlaysetting_print+="(${DOCKER__FG_RED187}${DOCKER__OVERLAYFS_DISABLED}${DOCKER__NOCOLOR})"
    fi

    #---------------------------------------------------------------------
    #(RE)CONFIGURE PARTITIONS & OVERLAY-MODE
    #   dash (-) (do NOT change the pentagram_common.h)
    #   persistent ('overlay' partition is RW; do NOT remove 'overlay' partition after reboot)
    #   non-persistent ('overlay' partition is RO; remove 'overlay' partition after reboot)
    #---------------------------------------------------------------------
    if [[ -n "${grep_overlay}" ]] && \
            [[ "${docker__overlaysetting_set}" == "${DOCKER__OVERLAYFS_ENABLED}" ]]; then  #'overlay' is found and enabled
        configpartitions_print="${DOCKER__FOURSPACES}1. Configure ${DOCKER__BLINKING}new${DOCKER__NOCOLOR} partitions\n"
        configpartitions_print+="${DOCKER__FOURSPACES}2. Reconfigure ${DOCKER__DIM}existing${DOCKER__NOCOLOR} partitions"

        overlaymode_print="${DOCKER__FOURSPACES}4. ${DOCKER__OVERLAYMODE} "
    else   #for all other cases
        configpartitions_print="${DOCKER__FG_LIGHTGREY}${DOCKER__FOURSPACES}1.${DOCKER__NOCOLOR} Configure ${DOCKER__BLINKING}new${DOCKER__NOCOLOR} partitions\n"
        configpartitions_print+="${DOCKER__FG_LIGHTGREY}${DOCKER__FOURSPACES}2.${DOCKER__NOCOLOR} Reconfigure ${DOCKER__DIM}existing${DOCKER__NOCOLOR} partitions"

        overlaymode_print="${DOCKER__FG_LIGHTGREY}${DOCKER__FOURSPACES}4.${DOCKER__NOCOLOR} ${DOCKER__OVERLAYMODE} "
    fi

    if [[ "${docker__overlaymode_set}" == "${DOCKER__OVERLAYMODE_PERSISTENT}" ]]; then
        overlaymode_print+="(${DOCKER__FG_GREEN158}${docker__overlaymode_set}${DOCKER__NOCOLOR})"
    else
        overlaymode_print+="(${DOCKER__FG_RED187}${docker__overlaymode_set}${DOCKER__NOCOLOR})"
    fi


    #Print
    echo -e "${configpartitions_print}"
    echo -e "${overlaysetting_print}"
    echo -e "${overlaymode_print}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${DOCKER__FOURSPACES}q. $DOCKER__QUIT_CTRL_C"
}

docker__partitiondisk__sub() {
    #Input args
    #***IMPORTANT TO KNOW:
    #   If flag_configure_new_partitions_is_chosen__input = true -> option 1. Configure new partitions
    #   If flag_configure_new_partitions_is_chosen__input = false -> option 2. Reconfigure existing partitions
    local flag_configure_new_partitions_is_chosen__input=${1}
    shift
    #***IMPORTANT TO KNOW:
    #   If flag_configure_new_partitions_is_chosen__input = true -> dataarr__input = docker__isp_partition_array_default
    #   If flag_configure_new_partitions_is_chosen__input = false -> dataarr__input = docker__isp_partition_array
    local dataarr__input=("$@")

    #Define constants
    local PHASE_ARRAYDATA_RETRIEVE=1
    local PHASE_PARTITIONNAME_INPUT=10
    local PHASE_PARTITIONSIZE_INPUT=20
    local PHASE_UPDATE=30
    local PHASE_EXIT=100

    #Define variables
    local isp_partition_writetofile_array_bck=()
    local dataarr_len=0
    local dataarr_lastindex=0
    local dataarr_tb_reserve_size=0
    local j=0
    local phase="${PHASE_ARRAYDATA_RETRIEVE}"
    local readdialog_diskpartname="${DOCKER__EMPTYSTRING}"
    local readdialog_diskpartsize_default="${DOCKER__EMPTYSTRING}"

    #Initialize global variables
    docker__remain_size=${disksize__input}
    docker__remain_size_bck=${disksize__input}

    #Movedown and clean line(s)
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"


    #---------------------------------------------------------------------
    #docker__isp_partition_writetofile_array: Backup & Initialize
    #---------------------------------------------------------------------
    #REMARKS:
    #   1. Always backup (whether flag_configure_new_partitions_is_chosen__input = true or false)
    #   2. A backup is made because array 'docker__isp_partition_writetofile_array' may contain
    #       data which was previously inputted.
    #   3. Only Initialize if 'Configure new partitions' is chosen.
    #---------------------------------------------------------------------
    #Backup
    isp_partition_writetofile_array_bck=("${docker__isp_partition_writetofile_array[@]}")

    #Initialize
    if [[ "${flag_configure_new_partitions_is_chosen__input}" == true ]]; then
        docker__isp_partition_writetofile_array=("${docker__isp_partition_array_default[@]}")
    fi


    #Show readinputdialog
    while true
    do
        case "${phase}" in
            "${PHASE_ARRAYDATA_RETRIEVE}")
                #---------------------------------------------------------------------
                #Index overview:
                #   j = 1024: swapfile
                #   j = 0   : tb_reserve
                #   j = 1   : rootfs
                #   j = 2   : overlay
                #---------------------------------------------------------------------

                #Get array-length
                dataarr_len=${#dataarr__input[@]}
                #Determine the LAST array-index
                dataarr_lastindex=$((dataarr_len - 1))

                #Get 'docker__diskpartname' and 'docker__diskpartsize'
                docker__diskpartname=$(echo "${dataarr__input[j]}" | cut -d" " -f1)
                docker__diskpartsize=$(echo "${dataarr__input[j]}" | cut -d" " -f2)

                if [[ ${j} -eq 0 ]]; then  #tb_reserve
                    #Remember the current 'dataarr_tb_reserve_size-size'
                    dataarr_tb_reserve_size=${docker__diskpartsize}
                elif [[ ${j} -eq 1024 ]]; then  #swapfile
                    #Set 'docker__diskpartname'
                    #***NOTE: index = 1024 does NOT exist in array 'dataarr__input' and 
                    #   therefore needs to be manually set.
                    docker__diskpartname=${DOCKER__DISKPARTNAME_TB_RESERVE}

                    #Deterimine which 'docker__diskpartsize' to use
                    #***NOTE: this depends on whether:
                    #   a. Configure new partitions is chosen -> flag_configure_new_partitions_is_chosen__input = true
                    #   b. Reconfigure existing partitions -> flag_configure_new_partitions_is_chosen__input = false
                    if [[ "${flag_configure_new_partitions_is_chosen__input}" == true ]]; then
                        docker__diskpartsize=${DOKCER__SWAPFILE_SIZE_DEFAULT}
                    else
                        docker__diskpartsize=$((dataarr_tb_reserve_size - DOCKER__RESERVED_SIZE_DEFAULT))
                    fi
                elif [[ ${j} -eq 2 ]]; then    #overlay
                    #Set 'docker__diskpartsize' to 'docker__remain_size'
                    #***NOTE: this depends on whether configure new partitions is chosen -> flag_configure_new_partitions_is_chosen__input = true.
                    if [[ "${flag_configure_new_partitions_is_chosen__input}" == true ]]; then
                        docker__diskpartsize=${docker__remain_size}
                    fi
                elif [[ ${j} -gt 2 ]]; then    #Other disk partition name
                    #Reset 'docker__diskpartname'
                    #***NOTE: do this in 2 situations:
                    #   a. Configure new partitions is chosen -> flag_configure_new_partitions_is_chosen__input = true.
                    if [[ "${flag_configure_new_partitions_is_chosen__input}" == true ]]; then
                        docker__diskpartname="${DOCKER__EMPTYSTRING}"
                    fi

                    #   b. docker__diskpartname = remaining -> since 'new' or 'existing' disk partition name may be 
                    #       'added' or 'edited', variable 'docker__diskpartname' MUST be resetted.
                    if [[ "${docker__diskpartname}" == "${DOCKER__DISKPARTNAME_REMAINING}" ]]; then
                        docker__diskpartname="${DOCKER__EMPTYSTRING}"
                    fi
                fi

                #Goto next-phase
                phase="${PHASE_PARTITIONNAME_INPUT}"
                ;;
            "${PHASE_PARTITIONNAME_INPUT}")
                #---------------------------------------------------------------------
                #PARTITION-NAME:
                #   j <= 2: PREDEFINED PARTITION-NAMES: tb_reserve, rootfs, overlay
                #   j > 2: INPUT PARTITION-NAME
                #Remark:
                #   Provide the partition-name of the 'additonal' fs
                #   ...and write to variable 'docker__diskpartname'
                #---------------------------------------------------------------------
                case ${j} in
                    #tb_reserve
                    "0") 
                        phase="${PHASE_PARTITIONSIZE_INPUT}"
                        ;;
                    #swapfile
                    "1024")
                        phase="${PHASE_PARTITIONSIZE_INPUT}"
                        ;;
                    #rootfs                   
                    "1")
                        phase="${PHASE_PARTITIONSIZE_INPUT}"
                        ;;
                    #overlay
                    "2")
                        #Check if 'docker__diskpartname' is an <Empty String>
                        if [[ -z "${docker__diskpartname}" ]]; then   #is an Empty String
                            #Update variable
                            docker__diskpartname="${DOCKER__DISKPARTNAME_OVERLAY}"
                        fi
                        phase="${PHASE_PARTITIONSIZE_INPUT}"
                        ;;
                    #all other partitions
                    *)
                        #---------------------------------------------------------------------
#-----------------------#Other disk partition name
                        #---------------------------------------------------------------------
                        #***Note: this function implicitely updates 'docker__diskpartname'
                        #---------------------------------------------------------------------
                        #Define array containing only the elements of array 'docker__isp_partition_writetofile_array' to be checked against!
                        isp_partition_writetofile_tobechecked=("${docker__isp_partition_writetofile_array[@]:0:j}")

                        #Input and get a valid disk partition name
                        docker__other_diskpartname_handler__sub "${docker__diskpartname}" \
                                "${j}" \
                                "${isp_partition_writetofile_tobechecked[@]}"

                        #Remark:
                        #   If no additional partition-name is provided,
                        #   ...then it means that f(inish) was pressed.
                        case "${docker__diskpartname}" in
                            "${DOCKER__SEMICOLON_REDO}")
                                #Reset array
                                docker__isp_partition_writetofile_array=()

                                #Reset dvariables
                                docker__remain_size=${disksize__input}
                                docker__remain_size_bck=${disksize__input}

                                #Reset index
                                j=0

                                #Goto next-phase
                                phase="${PHASE_ARRAYDATA_RETRIEVE}"
                                ;;
                            "${DOCKER__SEMICOLON_FINISH}")
                                phase="${PHASE_UPDATE}"
                                ;;
                            "${DOCKER__SEMICOLON_ABORT}")
                                #***IMPORTANT: Restore backup
                                docker__isp_partition_writetofile_array=("${isp_partition_writetofile_array_bck[@]}")

                                #Goto next-phase
                                phase="${PHASE_EXIT}"
                                ;;
                            *)
                                #Goto next-phase
                                phase="${PHASE_PARTITIONSIZE_INPUT}"
                                ;;
                        esac
                esac
                ;;
            "${PHASE_PARTITIONSIZE_INPUT}")
                #---------------------------------------------------------------------
                #PARTITION-NAME:
                #   j = 1024: swapfile: disk-size <= 1024 MB
                #   j = 0: tb_reserve: disk-size = 128 MB
                #   j = 1: rootfs: disksize >= 1536 MB
                #   j = 2: overlay: disksize >= 4 MB
                #   j > 2: additional partitions: disksize > 0 MB
                #Remark:
                #   Provide the partition-name of the 'additonal' fs
                #   ...and write to variable 'docker__diskpartname'
                #---------------------------------------------------------------------
                case ${j} in
                    "0")
                        #---------------------------------------------------------------------
                        #Update 'docker__isp_partition_writetofile_array'
                        #---------------------------------------------------------------------
                        docker__isp_partition_writetofile_array[j]="${docker__diskpartname} ${DOCKER__RESERVED_SIZE_DEFAULT}"

                        #---------------------------------------------------------------------
                        #Calculate 'docker__remain_size'
                        #---------------------------------------------------------------------
                        docker__remain_size=$(bc_substract_x_from_y "${docker__remain_size}" "${DOCKER__RESERVED_SIZE_DEFAULT}")

                        #---------------------------------------------------------------------
                        #Backup 'docker__remain_size'
                        #---------------------------------------------------------------------
                        docker__remain_size_bck="${docker__remain_size}"

                        #***NOTE: this index is reserved for 'swapfilesize' input
                        j=1024

                        #Goto next-phase
                        phase="${PHASE_ARRAYDATA_RETRIEVE}"
                        ;;
                    *)
                        #---------------------------------------------------------------------
                        #Update 'readdialog_diskpartname'
                        #---------------------------------------------------------------------
                        # readdialog_diskpartname="${DOCKER__READDIALOG_HEADER}: ${docker__diskpartname} "
                        if [[ ${j} -eq 1024 ]]; then   #swapfile
                            #Set 'readdialog_diskpartname' to 'swapfile'
                            #***NOTE: this is the name which will be shown in the READINPUT DIALOG.
                            readdialog_diskpartname="${DOCKER__SWAPFILE} "
                        else    #all other folders (e.g., tb_reserve, rootfs, overlay, etc.)
                            readdialog_diskpartname="${docker__diskpartname} "
                        fi

                        #---------------------------------------------------------------------
                        #Readinput dialog options (e.g., clear, redo, abort, etc.)
                        #---------------------------------------------------------------------
                        #***NOTE: swapfiles-ize will be added to tb_reserve-size
                        if [[ ${j} -eq 1024 ]]; then  #swapfile
                            readdialog_diskpartname+="(${DOCKER__SEMICOLON_CLEAR_ABORT_COLORED}) "
                        elif [[ ${j} -eq 1 ]]; then  #rootfs
                            readdialog_diskpartname+="(${DOCKER__SEMICOLON_CLEAR_REDO_ABORT_COLORED}) "           
                        elif [[ ${j} -eq 2 ]]; then #overlay
                            readdialog_diskpartname+="(${DOCKER__SEMICOLON_CLEAR_REDO_ABORT_COLORED}) "
                        elif [[ ${j} -gt 2 ]]; then #anything else except for 'tb_reserve, rootfs, overlay'
                            readdialog_diskpartname+="(${DOCKER__SEMICOLON_CLEAR_REDO_FINISH_ABORT_COLORED}) "
                        fi
                        readdialog_diskpartname+="(${DOCKER__FG_ORANGE215}${docker__remain_size}${DOCKER__NOCOLOR}): "

                        #---------------------------------------------------------------------
#-----------------------#Set readdialog_diskpartsize_default
                        #---------------------------------------------------------------------
                        if [[ -n "${docker__diskpartsize}" ]] && [[ ${docker__diskpartsize} -ne 0 ]]; then  #docker__diskpartsize > 0 (and NOT Empty String)
                            #In general, set 'readdialog_diskpartsize_default = docker__diskpartsize'
                            readdialog_diskpartsize_default="${docker__diskpartsize}"

                            #HOWEVER, for a few exceptional cases we set 'readdialog_diskpartsize_default = docker__remain_size'
                            #Case 1: Configure new partitions
                            if [[ "${flag_configure_new_partitions_is_chosen__input}" == "true" ]]; then
                                #Case 1.1: index 'j > 2'
                                if [[ ${j} -gt 2 ]]; then
                                    #Case 1.2: index 'j != 1024'
                                    if [[ ${j} -ne 1024 ]]; then
                                        readdialog_diskpartsize_default="${docker__remain_size}"
                                    fi
                                fi

                            #Case 2: Reconfigure existing partitions
                            else    #flag_configure_new_partitions_is_chosen__input = false
                                #Case 2.1: index 'j = dataarr_lastindex'
                                if [[ ${j} -eq ${dataarr_lastindex} ]]; then
                                    readdialog_diskpartsize_default="${docker__remain_size}"
                                fi
                            fi
                        else    #docker__diskpartsize = 0 (or Empty String)
                            readdialog_diskpartsize_default="${docker__remain_size}"
                        fi

                        #---------------------------------------------------------------------
#-----------------------#Show readinput dialog
                        #---------------------------------------------------------------------
                        #Remarks:
                        #   The readinput dialog will not stop until a non Empty String is inputted.
                        #       This functionality is implicitely built-in.
                        #   This function outputs a value for variable 'docker__readdialog_output'
                        #---------------------------------------------------------------------
                        docker__readdialog_w_output__func "${readdialog_diskpartname}" "${readdialog_diskpartsize_default}"

                        #---------------------------------------------------------------------
                        #Readinput dialog output handler
                        #---------------------------------------------------------------------
                        if [[ ! -z "${docker__readdialog_output}" ]]; then
                            if [[ $(isNumeric__func "${docker__readdialog_output}") == true ]]; then
                                #---------------------------------------------------------------------
#-------------------------------#docker__remain_size: UPDATE 
                                #---------------------------------------------------------------------
                                docker__remain_size=$(bc_substract_x_from_y "${docker__remain_size}" "${docker__readdialog_output}")

                                case "${docker__readdialog_output}" in
                                    #---------------------------------------------------------------------
                                    #docker__readdialog_output = 0
                                    #---------------------------------------------------------------------
                                    "0")
                                        #Move-up and clean line(s)
                                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                                        #Print error message
                                        echo -e "${readdialog_diskpartname}${docker__readdialog_output} (${DOCKER__ERRMSG_CANNOT_BE_ZERO})"

                                        #Revert back to the backup
                                        docker__remain_size=${docker__remain_size_bck}

                                        #Goto next-phase
                                        phase="${PHASE_PARTITIONSIZE_INPUT}"
                                        ;;

                                    #---------------------------------------------------------------------
                                    #docker__readdialog_output > 0
                                    #---------------------------------------------------------------------
                                    *) 
                                        if [[ "${docker__remain_size}" -eq 0 ]]; then   #docker__remain_size = 0
                                            #Update 'docker__isp_partition_writetofile_array'
                                            docker__isp_partition_writetofile_array[j]="${docker__diskpartname} ${docker__readdialog_output}"

                                            #Goto next-phase
                                            phase="${PHASE_UPDATE}"

                                        else    #docker__remain_size != 0
                                            if [[ $(bc_is_x_greaterthan_zero "${docker__remain_size}") == true ]]; then #docker__remain_size > 0
                                                #swapfile: j = 1024
                                                if [[ ${j} -eq 1024 ]] && [[ "${docker__readdialog_output}" -gt "${DOKCER__SWAPFILE_SIZE_DEFAULT}" ]]; then
                                                    #Move-up and clean line(s)
                                                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                                                    #Print error message
                                                    echo -e "${readdialog_diskpartname}${docker__readdialog_output} (${DOCKER__WRNMSG_SWAPFILE_GREATERTHAN_RECOMMEND_VALUE})"

                                                    #Revert back to the backup
                                                    docker__remain_size=${docker__remain_size_bck}

                                                    #Goto next-phase
                                                    phase="${PHASE_PARTITIONSIZE_INPUT}"

                                                #rootfs: j = 1 and 'readdialog_output < DOCKER__ROOTFS_SIZE_DEFAULT'
                                                elif [[ ${j} -eq 1 ]] && [[ "${docker__readdialog_output}" -lt "${DOCKER__ROOTFS_SIZE_DEFAULT}" ]]; then
                                                    #Move-up and clean line(s)
                                                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                                                    #Print error message
                                                    echo -e "${readdialog_diskpartname}${docker__readdialog_output} (${DOCKER__WRNMSG_ROOTFS_LESSTHAN_RECOMMEND_VALUE})"

                                                    #Revert back to the backup
                                                    docker__remain_size=${docker__remain_size_bck}

                                                    #Goto next-phase
                                                    phase="${PHASE_PARTITIONSIZE_INPUT}"

                                                #overlay: j = 2 and  'docker__readdialog_output < DOCKER__ROOTFS_SIZE_DEFAULT'
                                                elif [[ ${j} -eq 2 ]] && [[ "${docker__readdialog_output}" -lt "${DOCKER__OVERLAY_SIZE_DEFAULT}" ]]; then
                                                    #Move-up and clean line(s)
                                                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                                                    #Print error message
                                                    echo -e "${readdialog_diskpartname}${docker__readdialog_output} (${DOCKER__WRNMSG_OVERLAY_LESSTHAN_RECOMMEND_VALUE})"

                                                    #Revert back to the backup
                                                    docker__remain_size=${docker__remain_size_bck}

                                                    #Goto next-phase
                                                    phase="${PHASE_PARTITIONSIZE_INPUT}"

                                                #new partition
                                                else
                                                    #Update index 'j'
                                                    if [[ ${j} -eq 1024 ]]; then    #swapfile
                                                        #Add 'swapfile-size' to 'tb_reserve-size'
                                                        docker__readdialog_output=$((docker__readdialog_output + DOCKER__RESERVED_SIZE_DEFAULT))

                                                        #Update array 'docker__isp_partition_writetofile_array'
                                                        docker__isp_partition_writetofile_array[0]="${docker__diskpartname} ${docker__readdialog_output}"

                                                        #Set j=1, which means handle 'rootfs' next
                                                        j=1
                                                    else    #all other cases (e.g., rootfs, overlay)
                                                        docker__isp_partition_writetofile_array[j]="${docker__diskpartname} ${docker__readdialog_output}"

                                                        ((j++))
                                                    fi

                                                    #Update 'docker__remain_size_bck'
                                                    docker__remain_size_bck=${docker__remain_size}

                                                    #Goto next-phase
                                                    phase="${PHASE_ARRAYDATA_RETRIEVE}"
                                                fi

                                            else    #docker__remain_size < 0
                                                #Move-up and clean line(s)
                                                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                                                #Print error message
                                                echo -e "${readdialog_diskpartname}${docker__readdialog_output} (${DOCKER__ERRMSG_TOO_LARGE})"

                                                #Revert back to the backup
                                                docker__remain_size=${docker__remain_size_bck}

                                                #Goto next-phase
                                                phase="${PHASE_PARTITIONSIZE_INPUT}"
                                            fi
                                        fi
                                        ;;
                                esac
                            
                            #---------------------------------------------------------------------
                            #NOT NUMERIC && NOT EMPTY-STRING
                            #---------------------------------------------------------------------
                            else
                                case "${docker__readdialog_output}" in
                                    "${DOCKER__SEMICOLON_REDO}")
                                        #Remark:
                                        #   r(edo) is available starting from the 'overlay' input
                                        if [[ ${j} -gt 1 ]]; then
                                            #Reset array
                                            docker__isp_partition_writetofile_array=()

                                            #Reset dvariables
                                            docker__remain_size=${disksize__input}
                                            docker__remain_size_bck=${disksize__input}

                                            #Reset index
                                            j=0

                                            #Goto next-phase
                                            phase="${PHASE_ARRAYDATA_RETRIEVE}"
                                        fi
                                        ;;
                                    "${DOCKER__SEMICOLON_FINISH}")
                                        #Remark:
                                        #   f(inish) is available over the 'overlay' input
                                        if [[ ${j} -gt 2 ]]; then
                                            phase="${PHASE_UPDATE}"
                                        else
                                            phase="${PHASE_PARTITIONSIZE_INPUT}"
                                        fi
                                        ;;
                                    "${DOCKER__SEMICOLON_ABORT}")
                                        #***IMPORTANT: Restore backup
                                        docker__isp_partition_writetofile_array=("${isp_partition_writetofile_array_bck[@]}")
                                        
                                        #Goto next-phase
                                        phase="${PHASE_EXIT}"
                                        ;;
                                    *)
                                        #Move-up and clean line(s)
                                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                                        #Print error message
                                        echo -e "${readdialog_diskpartname}${docker__readdialog_output} (${DOCKER__ERRMSG_INVALID})"

                                        #Revert back to the backup
                                        docker__remain_size=${docker__remain_size_bck}

                                        #Goto next-phase
                                        phase="${PHASE_PARTITIONSIZE_INPUT}"
                                        ;;
                                esac
                            fi
                        
                        #---------------------------------------------------------------------
                        #EMPTY STRING
                        #---------------------------------------------------------------------
                        else    #is an Empty String
                            #Goto next-phase
                            phase="${PHASE_PARTITIONSIZE_INPUT}"
                            
                            #Moveup and clean line(s)
                            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                        fi
                        ;;
                esac
                ;;
            "${PHASE_UPDATE}")
                #---------------------------------------------------------------------
                #Check if 'docker__remain_size > 0'
                #---------------------------------------------------------------------
                if [[ $(bc_is_x_greaterthan_zero "${docker__remain_size}") == true ]]; then
                    #Print error message
                    echo -e "---:${DOCKER__INFO}: ${DOCKER__INFOMSG_UNALLOCATED_DISKSPACE_LEFT} ${DOCKER__FG_ORANGE131}${docker__remain_size}${DOCKER__NOCOLOR}"
                fi

                #---------------------------------------------------------------------
                #Increment index
                #Note:
                #   This is needed to add 'remaining' to the array
                #---------------------------------------------------------------------
                ((j++))

                #---------------------------------------------------------------------
                #Add 'docker__remain_size' to array
                #---------------------------------------------------------------------
                docker__isp_partition_writetofile_array[j]="${DOCKER__DISKPARTNAME_REMAINING} ${docker__remain_size}"

                #---------------------------------------------------------------------
                #USING 'docker__isp_partition_writetofile_array' do the following:
                #1. Update array 'docker__isp_partition_array'
                #2. Update file 'docker__docker_fs_partition_diskpartsize_dat__fpath' with new data
                #---------------------------------------------------------------------
                docker__isp_part_arr_update_and_writeto_file "${docker__isp_partition_writetofile_array[@]}"

                #Goto next-phase
                phase="${PHASE_EXIT}"
                ;;
             "${PHASE_EXIT}")
                break
                ;;
        esac
    done
}
docker__isp_part_arr_update_and_writeto_file() {
    #Input args
    local dataarr__input=("$@")

    #Define variables
    local k=0

    #---------------------------------------------------------------------
    #RESET ARRAY: docker__isp_partition_array
    #---------------------------------------------------------------------
    docker__isp_partition_array=()

    #---------------------------------------------------------------------
    #UPDATE ARRAY: docker__isp_partition_array
    #---------------------------------------------------------------------
    for k in "${!dataarr__input[@]}"; do 
        docker__isp_partition_array[k]="${dataarr__input[$k]}"
    done

    #---------------------------------------------------------------------
    #Write to file 'docker__docker_fs_partition_diskpartsize_dat__fpath'
    #---------------------------------------------------------------------
    write_array_to_file__func "${docker__docker_fs_partition_diskpartsize_dat__fpath}" "${dataarr__input[@]}"

    #---------------------------------------------------------------------
    #Backup file 'docker__docker_fs_partition_diskpartsize_dat__fpath' based on 'DISK-SIZE SETTING'
    #Note: the 'disk-size setting' can be found in file 'docker__docker_fs_partition_conf__fpath'
    #---------------------------------------------------------------------
    case "${docker__disksize_set}" in
        "${DOCKER__DISKSIZE_4G_IN_MBYTES}")
            cp "${docker__docker_fs_partition_diskpartsize_dat__fpath}" "${docker__docker_fs_partition_diskpartsize_dat_4g__fpath}"
            ;;
        "${DOCKER__DISKSIZE_8G_IN_MBYTES}")
            cp "${docker__docker_fs_partition_diskpartsize_dat__fpath}" "${docker__docker_fs_partition_diskpartsize_dat_8g__fpath}"
            ;;
        *)  #user-defined
            cp "${docker__docker_fs_partition_diskpartsize_dat__fpath}" "${docker__docker_fs_partition_diskpartsize_dat_userdefined__fpath}"
            ;;
    esac
}
docker__other_diskpartname_handler__sub() {
    #Input args
    local docker__diskpartname__input=${1}
    local j__input=${2}
    shift 2
    local dataarr_writetofile__input=("$@")

    #Define variables
    local readdialog_diskpartname="${DOCKER__FG_YELLOW}new${DOCKER__NOCOLOR} partition-name "
    readdialog_diskpartname+="(${DOCKER__SEMICOLON_CLEAR_REDO_FINISH_ABORT_COLORED}): "

    #---------------------------------------------------------------------
    #READ-DIALOG: REQUEST INPUT PARTITION-NAME
    #---------------------------------------------------------------------
    while true
    do
        #Show readinputdialog
        #This function will output a value for variable 'docker__readdialog_output'
        docker__readdialog_w_output__func "${readdialog_diskpartname}" "${docker__diskpartname__input}"
        if [[ ! -z "${docker__readdialog_output}" ]]; then  #is NOT an Empty String
            #Check if partition-name is already in use
            if [[ $(checkForExactMatch_of_pattern_within_2darray__func \
                    "${docker__readdialog_output}" \
                    "${DOCKER__COLNUM_1}" \
                    "${DOCKER__ONESPACE}" \
                    "${dataarr_writetofile__input[@]}") == false ]]; then
                break
            else
                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                echo "${readdialog_diskpartname}${docker__readdialog_output} (${DOCKER__ERRMSG_ALREADY_INUSE})"
            fi
        fi
    done

    #---------------------------------------------------------------------
    #UPDATE VARIABLE
    #---------------------------------------------------------------------
    docker__diskpartname="${docker__readdialog_output}"
}

docker__overlaymode__sub() {
    #Define variables
    local filecontent="${DOCKER__EMPTYSTRING}"

    #---------------------------------------------------------------------
    #TOGGLE BETWEEN {PERSISTENT | NON-PERSISTENT}
    #---------------------------------------------------------------------
    if [[ "${docker__overlaymode_set}" == "${DOCKER__OVERLAYMODE_NONPERSISTENT}" ]]; then
        docker__overlaymode_set="${DOCKER__OVERLAYMODE_PERSISTENT}"
    else
        docker__overlaymode_set="${DOCKER__OVERLAYMODE_NONPERSISTENT}"
    fi

    #Update variable
    filecontent="${DOCKER__OVERLAYMODE} ${docker__overlaymode_set}"

    #---------------------------------------------------------------------
    #OVERLAY-MODE: write to file
    #---------------------------------------------------------------------
    replace_or_append_string_based_on_pattern_in_file__func "${filecontent}" \
            "${DOCKER__OVERLAYMODE}" \
            "${docker__docker_fs_partition_conf__fpath}" \
            "${DOCKER__FALSE}"
}

docker__overlaysetting__sub() {
    #Define variables
    local filecontent="${DOCKER__EMPTYSTRING}"

    #---------------------------------------------------------------------
    #TOGGLE BETWEEN {DISABLED | ENABLED}
    #---------------------------------------------------------------------
    if [[ "${docker__overlaysetting_set}" == "${DOCKER__OVERLAYFS_DISABLED}" ]]; then
        docker__overlaysetting_set="${DOCKER__OVERLAYFS_ENABLED}"
    else
        docker__overlaysetting_set="${DOCKER__OVERLAYFS_DISABLED}"
    fi

    #---------------------------------------------------------------------
    #OVERLAY-SETTING: write to file
    #---------------------------------------------------------------------
    #Update variable
    filecontent="${DOCKER__OVERLAYSETTING} ${docker__overlaysetting_set}"

    #Replace/Append to file
    replace_or_append_string_based_on_pattern_in_file__func "${filecontent}" \
            "${DOCKER__OVERLAYSETTING}" \
            "${docker__docker_fs_partition_conf__fpath}" \
            "${DOCKER__FALSE}"
}



#---MAIN SUBROUTINE
main__sub() {
    docker__check_inputarg__sub

    docker__load_global_fpath_paths__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__preprep__sub

    docker__menu__sub
}



#---EXECUTE
main__sub
