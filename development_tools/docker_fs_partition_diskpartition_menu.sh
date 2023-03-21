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

    #Show read-dialog
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

            exit 99
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

    DOCKER__READDIALOG_HEADER="---:${DOCKER__INPUT}"

    DOCKER__ERRMSG_ALREADY_INUSE="${DOCKER__FG_LIGHTRED}already in-use${DOCKER__NOCOLOR}"
    DOCKER__ERRMSG_CANNOT_BE_ZERO="${DOCKER__FG_LIGHTRED}can't be zero${DOCKER__NOCOLOR}"
    DOCKER__ERRMSG_INVALID="${DOCKER__FG_LIGHTRED}invalid${DOCKER__NOCOLOR}"
    DOCKER__ERRMSG_TOO_LARGE="${DOCKER__FG_LIGHTRED}too large${DOCKER__NOCOLOR}"

    DOCKER__WRNMSG_LESSTHAN_RECOMMEND_VALUE="${DOCKER__FG_LIGHTPINK}< recommend value: ${DOCKER__ROOTFS_SIZE_DEFAULT}${DOCKER__NOCOLOR}"
    DOCKER__INFOMSG_UNALLOCATED_DISKSPACE_LEFT="${DOCKER__FG_ORANGE130}unallocated${DOCKER__NOCOLOR} diskspace left:"
}

docker__init_variables__sub() {
    docker__disksize_remain=${disksize__input}
    
    docker__overlaymode_set="${DOCKER__OVERLAYMODE_PERSISTENT}"
    docker__overlaysetting_set="${DOCKER__OVERLAYFS_DISABLED}"

    docker__readdialog_output="${DOCKER__EMPTYSTRING}"

    docker__reservedfs_size=${DOCKER__RESERVED_SIZE_DEFAULT}
    docker__rootfs_size=${DOCKER__ROOTFS_SIZE_DEFAULT}
    docker__overlayfs_size=$((disksize__input - docker__reservedfs_size - docker__rootfs_size))

    docker__isp_partition_array=()
    docker__isp_partition_array[0]="${DOCKER__DISKPARTNAME_TB_RESERVE} ${docker__reservedfs_size}"
    docker__isp_partition_array[1]="${DOCKER__DISKPARTNAME_ROOTFS} ${docker__rootfs_size}"
    docker__isp_partition_array[2]="${DOCKER__DISKPARTNAME_OVERLAY} ${docker__overlayfs_size}"
    docker__isp_partition_array[3]="${DOCKER__DISKPARTNAME_REMAINING} 0"

    docker__isp_partition_array_default=()
    docker__isp_partition_array_default[0]="${DOCKER__DISKPARTNAME_TB_RESERVE} ${docker__reservedfs_size}"
    docker__isp_partition_array_default[1]="${DOCKER__DISKPARTNAME_ROOTFS} ${docker__rootfs_size}"
    docker__isp_partition_array_default[2]="${DOCKER__DISKPARTNAME_OVERLAY} ${docker__overlayfs_size}"
    docker__isp_partition_array_default[3]="${DOCKER__DISKPARTNAME_REMAINING} 0"

    docker__diskpartname="${DOCKER__EMPTYSTRING}"
    docker__diskpartsize="${DOCKER__EMPTYSTRING}"

    docker__exitcode=0

    docker__regex12q="[12q]"
    docker__regex1234q="[1-4q]"
    docker__regex="${docker__regex1234q}"
}

docker__preprep__sub() {
    #Define variables
    local i=0

    #Check if file 'docker__docker_fs_partition_diskpartsize_dat__fpath' is present:
    #If true, then RETRIEVE the data from file
    #If false, then WRITE default array-data to file
    if [[ -f "${docker__docker_fs_partition_diskpartsize_dat__fpath}" ]]; then
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
        #Write default array-data to file 'docker__docker_fs_partition_diskpartsize_dat__fpath'
        write_array_to_file__func "${docker__docker_fs_partition_diskpartsize_dat__fpath}" \
                "${docker__isp_partition_array_default[@]}"
    fi



    #Check if file 'docker__docker_fs_partition_conf__fpath' is present:
    #If true, then RETRIEVE the data from file
    #If false, then WRITE default array-data to file
    if [[ -f "${docker__docker_fs_partition_conf__fpath}" ]]; then
        docker__overlaymode_set=$(retrieve__data_specified_by_col_within_file__func "${DOCKER__OVERLAYMODE}" \
                "${DOCKER__COLNUM_2}" \
                "${docker__docker_fs_partition_conf__fpath}")
        #Remark:
        #   It can happen that 'docker__overlaymode_set' is an 'Empty String'
        #   ...in case file 'docker__docker_fs_partition_conf__fpath' has
        #   ...no 'DOCKER__OVERLAYMODE' input.
        #   In that case, automatically set 'docker__overlaymode_set = DOCKER__OVERLAYMODE_PERSISTENT'.
        if [[ -z "${docker__overlaymode_set}" ]]; then
            #Set variable
            docker__overlaymode_set="${DOCKER__OVERLAYMODE_PERSISTENT}"

            #Generate 'filecontent'
            filecontent="${DOCKER__OVERLAYMODE} ${DOCKER__OVERLAYMODE_PERSISTENT}"

            #Replace/Append to file
            replace_or_append_string_based_on_pattern_in_file__func "${filecontent}" \
                    "${DOCKER__OVERLAYMODE}" \
                    "${docker__docker_fs_partition_conf__fpath}"
        fi

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
                    "${docker__docker_fs_partition_conf__fpath}"
        fi
    else
        #Generate 'filecontent'
        filecontent="${DOCKER__OVERLAYMODE} ${DOCKER__OVERLAYMODE_PERSISTENT}\n"
        filecontent+="${DOCKER__OVERLAYSETTING} ${DOCKER__OVERLAYFS_DISABLED}"

        #Replace/Append to file
        replace_or_append_string_based_on_pattern_in_file__func "${filecontent}" \
                "${DOCKER__PATTERN_DUMMY}" \
                "${docker__docker_fs_partition_conf__fpath}"
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
        if [[ -z "${grep_overlay}" ]]; then  #pattern 'overlay' is found
            docker__regex="${docker__regex12q}"
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
    # local disksize_remain=${disksize__input}

    #---THIS PART IS DEDICATED TO THE PRINTING OF THE:
    #       LEFT-STRING (e.g. rootfs, tb_reserve, overlay, etc.)
    #       RIGHT-STRING (e.g. 1536, 128, 256 etc...)
    #Determine the longest string of 'diskpart_arritem_left'
    diskpart_arritem_left_max=$(printf '%s\n' ${docker__isp_partition_array[@]} | wc -L)

    #Increase 'diskpart_arritem_left_max' with '4'
    #Remark:
    #   This is the Empty Space between the left-string and right-string
    diskpart_arritem_left_max=$((diskpart_arritem_left_max + DOCKER__NUMOFCHARS_8))

    #Print 'partition sizes'
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
    local overlaymode_print="${DOCKER__EMPTYSTRING}"
    local overlaysetting_print="${DOCKER__EMPTYSTRING}"
    local grep_overlay="${DOCKER__EMPTYSTRING}"

    ###Configure new/existing partition
    #Print options
    echo -e "${DOCKER__FOURSPACES}1. Configure ${DOCKER__BLINKING}new${DOCKER__NOCOLOR} partition"
    echo -e "${DOCKER__FOURSPACES}2. Configure ${DOCKER__DIM}existing${DOCKER__NOCOLOR} partition"

    ###Overlay-setting
    #Check if 'overlay' partition is present in 'docker__isp_partition_array'
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

    echo -e "${overlaysetting_print}"

    ###Overlay-mode
    #   dash (-) (do NOT change the pentagram_common.h)
    #   persistent ('overlay' partition is RW; do NOT remove 'overlay' partition after reboot)
    #   non-persistent ('overlay' partition is RO; remove 'overlay' partition after reboot)
    if [[ -n "${grep_overlay}" ]] && \
            [[ "${docker__overlaysetting_set}" == "${DOCKER__OVERLAYFS_ENABLED}" ]]; then  #'overlay' is found and enabled
        overlaymode_print="${DOCKER__FOURSPACES}4. ${DOCKER__OVERLAYMODE} "
    else    #'overlay' is found and enabled
        overlaymode_print="${DOCKER__FG_LIGHTGREY}${DOCKER__FOURSPACES}4.${DOCKER__NOCOLOR} ${DOCKER__OVERLAYMODE} "
    fi

    if [[ "${docker__overlaymode_set}" == "${DOCKER__OVERLAYMODE_PERSISTENT}" ]]; then
        overlaymode_print+="(${DOCKER__FG_GREEN158}${docker__overlaymode_set}${DOCKER__NOCOLOR})"
    else
        overlaymode_print+="(${DOCKER__FG_RED187}${docker__overlaymode_set}${DOCKER__NOCOLOR})"
    fi
    echo -e "${overlaymode_print}"

    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${DOCKER__FOURSPACES}q. $DOCKER__QUIT_CTRL_C"
}

docker__partitiondisk__sub() {
    #Input args
    local isnewdiskpartconfig__input=${1}
    shift
    local dataarr__input=("$@")

    #Define constants
    local PHASE_ARRAYDATA_RETRIEVE=1
    local PHASE_PARTITIONNAME_INPUT=10
    local PHASE_PARTITIONSIZE_INPUT=20
    local PHASE_UPDATE=30
    local PHASE_EXIT=100

    #Define variables
    local isp_partition_array_new=()
    local disksize_remain_bck=0
    local i=0
    local j=0
    local goto_next_input=true
    local phase="${PHASE_ARRAYDATA_RETRIEVE}"
    local readdialog_diskpartsize="${DOCKER__EMPTYSTRING}"
    local readdialog_diskpartsize_default="${DOCKER__EMPTYSTRING}"

    #Initialize variables
    docker__disksize_remain=${disksize__input}
    disksize_remain_bck=${disksize__input}

    #Movedown and clean line(s)
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    #Show read-dialog
    while true
    do
        case "${phase}" in
        "${PHASE_ARRAYDATA_RETRIEVE}")
                #Retrieve data from array 'dataarr__input'
                docker__diskpartname=$(echo "${dataarr__input[j]}" | cut -d" " -f1)
                docker__diskpartsize=$(echo "${dataarr__input[j]}" | cut -d" " -f2)

                #If 'docker__diskpartname = remaining', then reset variable
                if [[ "${docker__diskpartname}" ==  "${DOCKER__DISKPARTNAME_REMAINING}" ]]; then
                    docker__diskpartname="${DOCKER__EMPTYSTRING}"
                fi

                #Goto next-phase
                phase="${PHASE_PARTITIONNAME_INPUT}"
                ;;
            "${PHASE_PARTITIONNAME_INPUT}")       
                #Partition-NAME read-dialog handler (only for 'additonal' fs)
                #Remark:
                #   Provide the partition-name of the 'additonal' fs
                #   ...and write to variable 'docker__diskpartname'
                case "${j}" in
                    "0")    #tb_reserve
                        #Goto next-phase
                        phase="${PHASE_PARTITIONSIZE_INPUT}"
                        ;;
                    "1")    #rootfs
                        #Goto next-phase
                        phase="${PHASE_PARTITIONSIZE_INPUT}"
                        ;;
                    "2")    #overlay
                        #Check if 'docker__diskpartname' is an <Empty String>
                        if [[ -z "${docker__diskpartname}" ]]; then   #is an Empty String
                            #Update variable
                            docker__diskpartname="${DOCKER__DISKPARTNAME_OVERLAY}"
                        fi
                        phase="${PHASE_PARTITIONSIZE_INPUT}"
                        ;;
                    *)  #all other partitions
                        #Note: variable 'docker__diskpartname' is updated in this subroutine
                        docker__diskpartname_handler__sub "${docker__diskpartname}" "${isp_partition_array_new[@]}"

                        #Remark:
                        #   If no additional partition-name is provided,
                        #   ...then it means that f(inish) was pressed.
                        case "${docker__diskpartname}" in
                            "${DOCKER__SEMICOLON_REDO}")
                                #Reset array
                                isp_partition_array_new=()

                                #Reset dvariables
                                docker__disksize_remain=${disksize__input}
                                disksize_remain_bck=${disksize__input}

                                #Reset flag
                                goto_next_input=true

                                #Reset index
                                j=0

                                #Goto next-phase
                                phase="${PHASE_ARRAYDATA_RETRIEVE}"
                                ;;
                            "${DOCKER__SEMICOLON_FINISH}")
                                phase="${PHASE_UPDATE}"
                                ;;
                            "${DOCKER__SEMICOLON_ABORT}")
                                phase="${PHASE_EXIT}"
                                ;;
                            *)
                                phase="${PHASE_PARTITIONSIZE_INPUT}"
                                ;;
                        esac
                esac
                ;;
            "${PHASE_PARTITIONSIZE_INPUT}")
                #Partition-SIZE read-dialog handler
                if [[ "${j}" -gt 0 ]]; then   #j > 0: do NOT show the read-dialog for the 'tb_reserve-fs'
                    #Update 'readdialog_diskpartsize'
                    readdialog_diskpartsize="${DOCKER__READDIALOG_HEADER}: ${docker__diskpartname} "
                    
                    if [[ ${j} -eq 1 ]]; then  #rootfs
                        readdialog_diskpartsize+="(${DOCKER__SEMICOLON_CLEAR_ABORT_COLORED}) "           
                    elif [[ ${j} -eq 2 ]]; then #overlay
                        readdialog_diskpartsize+="(${DOCKER__SEMICOLON_CLEAR_REDO_ABORT_COLORED}) "
                    elif [[ ${j} -gt 2 ]]; then #anything else except for 'tb_reserve'
                        readdialog_diskpartsize+="(${DOCKER__SEMICOLON_CLEAR_REDO_FINISH_ABORT_COLORED}) "
                    fi
                    readdialog_diskpartsize+="(${DOCKER__FG_ORANGE215}${docker__disksize_remain}${DOCKER__NOCOLOR}): "

                    #Show read-dialog
                    if [[ -n "${docker__diskpartsize}" ]] && [[ ${docker__diskpartsize} -ne 0 ]]; then
                        readdialog_diskpartsize_default="${docker__diskpartsize}"
                        
                        #Only apply this condition for partitions other than 'tb_reserve' and 'rootfs'
                        #Only apply this condition if 'isnewdiskpartconfig__input = true'
                        if [[ "${j}" -gt 1 ]] && [[ "${isnewdiskpartconfig__input}" == "true" ]]; then
                            readdialog_diskpartsize_default="${docker__disksize_remain}"
                        fi
                    else
                        readdialog_diskpartsize_default="${docker__disksize_remain}"
                    fi

                    #Remarks:
                    #   The read-dialog will not stop until a non Empty String is inputted.
                    #       This functionality is implicitely built-in.
                    #   This function outputs a value for variable 'docker__readdialog_output'
                    docker__readdialog_w_output__func "${readdialog_diskpartsize}" "${readdialog_diskpartsize_default}"

                    #Only continue if a valid option is selected
                    if [[ ! -z "${docker__readdialog_output}" ]]; then  #is NOT an Empty String
                        if [[ $(isNumeric__func "${docker__readdialog_output}") == true ]]; then  #is numeric
                            #Calculate 'docker__disksize_remain'
                            docker__disksize_remain=$(bc_substract_x_from_y "${docker__disksize_remain}" "${docker__readdialog_output}")

                            case "${docker__readdialog_output}" in
                                "0")
                                    #Move-up and clean line(s)
                                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                                    #Print error message
                                    echo -e "${readdialog_diskpartsize}${docker__readdialog_output} (${DOCKER__ERRMSG_CANNOT_BE_ZERO})"

                                    #Revert back to the backup
                                    docker__disksize_remain=${disksize_remain_bck}

                                    #Goto next-phase
                                    phase="${PHASE_PARTITIONSIZE_INPUT}"
                                    ;;
                                *)
                                    if [[ "${docker__disksize_remain}" -eq 0 ]]; then
                                        #Update 'isp_partition_array_new'
                                        isp_partition_array_new[j]="${docker__diskpartname} ${docker__readdialog_output}"

                                        #Goto next-phase
                                        phase="${PHASE_UPDATE}"
                                    else
                                        #Check if 'docker__disksize_remain > 0'
                                        if [[ $(bc_is_x_greaterthan_zero "${docker__disksize_remain}") == true ]]; then
                                            #Only show this message for 'rootfs' and only if 'docker__readdialog_output < DOCKER__ROOTFS_SIZE_DEFAULT'
                                            if [[ ${j} -eq 1 ]] && [[ "${docker__readdialog_output}" -lt "${DOCKER__ROOTFS_SIZE_DEFAULT}" ]]; then
                                                #Move-up and clean line(s)
                                                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                                                #Print error message
                                                echo -e "${readdialog_diskpartsize}${docker__readdialog_output} (${DOCKER__WRNMSG_LESSTHAN_RECOMMEND_VALUE})"
                                            fi

                                            #Update 'isp_partition_array_new'
                                            isp_partition_array_new[j]="${docker__diskpartname} ${docker__readdialog_output}"

                                            #Backup 'docker__disksize_remain'
                                            disksize_remain_bck=${docker__disksize_remain}

                                            #Increment index
                                            ((j++))

                                            #Goto next-phase
                                            phase="${PHASE_ARRAYDATA_RETRIEVE}"
                                        else    #docker__disksize_remain < 0
                                            #Move-up and clean line(s)
                                            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                                            #Print error message
                                            echo -e "${readdialog_diskpartsize}${docker__readdialog_output} (${DOCKER__ERRMSG_TOO_LARGE})"

                                            #Revert back to the backup
                                            docker__disksize_remain=${disksize_remain_bck}

                                            #Goto next-phase
                                            phase="${PHASE_PARTITIONSIZE_INPUT}"
                                        fi
                                    fi
                                    ;;
                            esac
                        else    #is NOT numeric
                            case "${docker__readdialog_output}" in
                                "${DOCKER__SEMICOLON_REDO}")
                                    #Remark:
                                    #   r(edo) is available starting from the 'overlay' input
                                    if [[ ${j} -gt 1 ]]; then
                                        #Reset array
                                        isp_partition_array_new=()

                                        #Reset dvariables
                                        docker__disksize_remain=${disksize__input}
                                        disksize_remain_bck=${disksize__input}

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
                                    #Goto next-phase
                                    phase="${PHASE_EXIT}"
                                    ;;
                                *)
                                    #Move-up and clean line(s)
                                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                                    #Print error message
                                    echo -e "${readdialog_diskpartsize}${docker__readdialog_output} (${DOCKER__ERRMSG_INVALID})"

                                    #Revert back to the backup
                                    docker__disksize_remain=${disksize_remain_bck}

                                    #Goto next-phase
                                    phase="${PHASE_PARTITIONSIZE_INPUT}"
                                    ;;
                            esac
                        fi
                    else    #is an Empty String
                        #Goto next-phase
                        phase="${PHASE_PARTITIONSIZE_INPUT}"
                        
                        #Moveup and clean line(s)
                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                    fi
                else    #j = 0
                    #Update 'isp_partition_array_new'
                    isp_partition_array_new[j]="${docker__diskpartname} ${DOCKER__RESERVED_SIZE_DEFAULT}"

                    #Calculate 'docker__disksize_remain'
                    docker__disksize_remain=$(bc_substract_x_from_y "${docker__disksize_remain}" "${DOCKER__RESERVED_SIZE_DEFAULT}")

                    #Backup 'docker__disksize_remain'
                    disksize_remain_bck="${docker__disksize_remain}"

                    #Increment index
                    ((j++))

                    #Goto next-phase
                    phase="${PHASE_ARRAYDATA_RETRIEVE}"
                fi
                ;;
            "${PHASE_UPDATE}")
                #Check if 'docker__disksize_remain > 0'
                if [[ $(bc_is_x_greaterthan_zero "${docker__disksize_remain}") == true ]]; then
                    #Print error message
                    echo -e "---:${DOCKER__INFO}: ${DOCKER__INFOMSG_UNALLOCATED_DISKSPACE_LEFT} ${DOCKER__FG_ORANGE131}${docker__disksize_remain}${DOCKER__NOCOLOR}"
                fi

                #Increment index
                ((j++))

                #Add 'docker__disksize_remain' to array
                isp_partition_array_new[j]="${DOCKER__DISKPARTNAME_REMAINING} ${docker__disksize_remain}"

                #Update array 'docker__isp_partition_array' and 
                #...file 'docker__docker_fs_partition_diskpartsize_dat__fpath' with new data
                docker__isp_partition_array_update__sub "${isp_partition_array_new[@]}"

                phase="${PHASE_EXIT}"
                ;;
             "${PHASE_EXIT}")
                break
                ;;
        esac
    done
}
docker__isp_partition_array_update__sub() {
    #Input args
    local dataarr__input=("$@")

    #Define variables
    local k=0

    #Reset array
    docker__isp_partition_array=()

    #Update 'docker__isp_partition_array' with new data
    for k in "${!dataarr__input[@]}"; do 
        docker__isp_partition_array[k]="${dataarr__input[$k]}"
    done

    #Update 'docker__docker_fs_partition_diskpartsize_dat__fpath' with new data
    write_array_to_file__func "${docker__docker_fs_partition_diskpartsize_dat__fpath}" "${dataarr__input[@]}"
}
docker__diskpartname_handler__sub() {
    #Input args
    local readdialog_diskpartname_default__input=${1}
    shift
    local dataarr__input=("$@")

    #Define variables
    local readdialog_diskpartname="${DOCKER__READDIALOG_HEADER}: ${DOCKER__FG_LIGHTGREY}new${DOCKER__NOCOLOR} "
    readdialog_diskpartname+="partition-name (${DOCKER__SEMICOLON_CLEAR_REDO_FINISH_ABORT_COLORED}): "

    #Read-dialog handler
    while true
    do
        #Show read-dialog
        #This function will output a value for variable 'docker__readdialog_output'
        docker__readdialog_w_output__func "${readdialog_diskpartname}" "${readdialog_diskpartname_default__input}"

        if [[ ! -z "${docker__readdialog_output}" ]]; then  #is NOT an Empty String
            #Check if partition-name is already in use
            if [[ $(checkForExactMatch_of_pattern_within_2darray__func \
                    "${docker__readdialog_output}" \
                    "${DOCKER__COLNUM_1}" \
                    "${DOCKER__ONESPACE}" \
                    "${dataarr__input[@]}") == false ]]; then
                break
            else
                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                echo "${readdialog_diskpartname}${docker__readdialog_output} (${DOCKER__ERRMSG_ALREADY_INUSE})"
            fi
        # else    #is an Empty String
        #     moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        fi
    done

    #Update variable
    docker__diskpartname="${docker__readdialog_output}"
}

docker__overlaymode__sub() {
    #Define variables
    local filecontent="${DOCKER__EMPTYSTRING}"

    #Flip 'docker__overlaymode_set' value
    if [[ "${docker__overlaymode_set}" == "${DOCKER__OVERLAYMODE_NONPERSISTENT}" ]]; then
        docker__overlaymode_set="${DOCKER__OVERLAYMODE_PERSISTENT}"
    else
        docker__overlaymode_set="${DOCKER__OVERLAYMODE_NONPERSISTENT}"
    fi

    #Update variable
    filecontent="${DOCKER__OVERLAYMODE} ${docker__overlaymode_set}"

    #Replace/Append to file
    replace_or_append_string_based_on_pattern_in_file__func "${filecontent}" \
            "${DOCKER__OVERLAYMODE}" \
            "${docker__docker_fs_partition_conf__fpath}"
}

docker__overlaysetting__sub() {
    #Define variables
    local filecontent="${DOCKER__EMPTYSTRING}"

    #Flip 'docker__overlaysetting_set' value
    if [[ "${docker__overlaysetting_set}" == "${DOCKER__OVERLAYFS_DISABLED}" ]]; then
        docker__overlaysetting_set="${DOCKER__OVERLAYFS_ENABLED}"
    else
        docker__overlaysetting_set="${DOCKER__OVERLAYFS_DISABLED}"
    fi

    #Update variable
    filecontent="${DOCKER__OVERLAYSETTING} ${docker__overlaysetting_set}"

    #Replace/Append to file
    replace_or_append_string_based_on_pattern_in_file__func "${filecontent}" \
            "${DOCKER__OVERLAYSETTING}" \
            "${docker__docker_fs_partition_conf__fpath}"
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
