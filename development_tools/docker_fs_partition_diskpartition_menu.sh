#!/bin/bash -m
#Remark: by using '-m' the INTERRUPT executed here will NOT propagate to the UPPERLAYER scripts
#---INPUT ARGS
disksize__input=${1}
global_fpath__input=${2}



#---FUNCTIONS
docker__readdialog_w_output__func() {
    #Input args
    local readdialog__input=${1}
    local partitionsize_default__input=${2}
    
    #Define variables
    local ret="${DOCKER__EMPTYSTRING}"

    #Show read-dialog
    readDialog_w_Output__func "${readdialog__input}" \
            "${partitionsize_default__input}" \
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
        docker__tmp_dir=/tmp
        docker__development_tools__foldername="development_tools"
        docker__global__filename="docker_global.sh"
        docker__mainmenu_path_cache__filename="docker__mainmenu_path.cache"
        docker__mainmenu_path_cache__fpath="${docker__tmp_dir}/${docker__mainmenu_path_cache__filename}"

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

    DOCKER__READDIALOG_ABORT="${DOCKER__FG_YELLOW}a${DOCKER__FG_LIGHTGREY}bort${DOCKER__NOCOLOR}"

    DOCKER__READDIALOG_REDO="${DOCKER__FG_YELLOW}r${DOCKER__FG_LIGHTGREY}edo${DOCKER__NOCOLOR}"

    DOCKER__READDIALOG_REDO_ABORT="${DOCKER__FG_YELLOW}r${DOCKER__FG_LIGHTGREY}edo${DOCKER__NOCOLOR}, "
    DOCKER__READDIALOG_REDO_ABORT+="${DOCKER__FG_YELLOW}a${DOCKER__FG_LIGHTGREY}bort${DOCKER__NOCOLOR}"

    DOCKER__READDIALOG_REDO_SKIP_ABORT="${DOCKER__FG_YELLOW}r${DOCKER__FG_LIGHTGREY}edo${DOCKER__NOCOLOR}, "
    DOCKER__READDIALOG_REDO_SKIP_ABORT+="${DOCKER__FG_YELLOW}s${DOCKER__FG_LIGHTGREY}kip${DOCKER__NOCOLOR}, "
    DOCKER__READDIALOG_REDO_SKIP_ABORT+="${DOCKER__FG_YELLOW}a${DOCKER__FG_LIGHTGREY}bort${DOCKER__NOCOLOR}"

    DOCKER__READDIALOG_SKIP="${DOCKER__FG_YELLOW}s${DOCKER__FG_LIGHTGREY}kip${DOCKER__NOCOLOR}"
}

docker__init_variables__sub() {
    applychange_status=false

    disksize_remain=${disksize__input}

    docker__readdialog_output="${DOCKER__EMPTYSTRING}"

    docker__overlaymode="${DOCKER__OVERLAYMODE_DEFAULT}"

    docker__reservedfs_size=${DOCKER__RESERVED_SIZE_DEFAULT}
    docker__rootfs_size=${DOCKER__ROOTFS_SIZE_DEFAULT}
    docker__overlayfs_size=$((disksize__input - docker__reservedfs_size - docker__rootfs_size))

    docker__diskpart_arr=()
    docker__diskpart_arr[0]="${DOCKER__RESERVED_FS} ${docker__reservedfs_size}"
    docker__diskpart_arr[1]="${DOCKER__ROOTFS_FS} ${docker__rootfs_size}"
    docker__diskpart_arr[2]="${DOCKER__OVERLAY_FS} ${docker__overlayfs_size}"

    docker__diskpart_default_arr=()
    docker__diskpart_default_arr[0]="${DOCKER__RESERVED_FS} ${docker__reservedfs_size}"
    docker__diskpart_default_arr[1]="${DOCKER__ROOTFS_FS} ${docker__rootfs_size}"
    docker__diskpart_default_arr[2]="${DOCKER__OVERLAY_FS} ${docker__overlayfs_size}"
    docker__diskpart_default_left="${DOCKER__EMPTYSTRING}"
    docker__diskpart_default_right="${DOCKER__EMPTYSTRING}"

    docker__exitcode=0

    regex="[1-3q]"
}

docker__menu__sub() {
    #Define variables
    local diskpart_arritem="${DOCKER__EMPTYSTRING}"

    local mychoice="${DOCKER__EMPTYSTRING}"
    local exitcode=0
    local ret=0

    #Show menu
    while true
    do
        #Enable Ctrl+C
        enable_ctrl_c__func

        #IMPORTANT: reset variables
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

        #Movedown and clean
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        #Print horizontal line
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Print menu-options
        docker__menu_options_print_sub

        #Print horizontal line
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        while true
        do
            #Select an option
            read -N1 -r -p "Please choose an option: " mychoice
            moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

            #Only continue if a valid option is selected
            if [[ ! -z ${mychoice} ]]; then
                if [[ ${mychoice} =~ ${regex} ]]; then
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
                docker__partitiondisk__sub
                ;;
            2)
                echo "set overlay-mode: in progress"
                ;;
            3)
                echo "apply change: in progress"
                echo "make sure to write 'isp.sh' and 'pentagram_common.h' to 'docker__docker_overlayfs__dir'"
                echo "the temp-files can be found in:"
                echo "    /home/imcase/repo/LTPP3_ROOTFS/boot/configs/pentagram_common.h"
                echo "    /home/imcase/repo/LTPP3_ROOTFS/build/scripts/isp.sh"
                echo ""
                ;;
            3)
                echo "apply change: in progress"
                echo "make sure to REMOVE 'isp.sh' and 'pentagram_common.h' at 'docker__docker_overlayfs__dir'"
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

    #---THIS PART IS DEDICATED TO THE PRINTING OF THE:
    #       LEFT-STRING (e.g. rootfs, reserved, overlay, etc.)
    #       RIGHT-STRING (e.g. 1536, 128, 256 etc...)
    #Determine the longest string of 'diskpart_arritem_left'
    for diskpart_arritem in "${docker__diskpart_arr[@]}"
    do  
        #Get the left-string of array-item 'diskpart_arritem'
        diskpart_arritem_left=$(echo "${diskpart_arritem}" | cut -d" " -f1)
        #Get the length of left-string 'diskpart_arritem_left'
        diskpart_arritem_left_len=${#diskpart_arritem_left}
        #Update 'diskpart_arritem_left_max' (if applicable)
        if [[ ${diskpart_arritem_left_len} -gt ${diskpart_arritem_left_max} ]]; then
            diskpart_arritem_left_max=${diskpart_arritem_left_len}
        fi
    done

    #Increase 'diskpart_arritem_left_max' with '4'
    #Remark:
    #   This is the Empty Space between the left-string and right-string
    diskpart_arritem_left_max=$((diskpart_arritem_left_max + DOCKER__NUMOFCHARS_8))

    #Show Partition Overview
    for diskpart_arritem in "${docker__diskpart_arr[@]}"
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
    done
}
docker__menu_options_print_sub() {
    echo -e "${DOCKER__FOURSPACES}1. Partition disk"
    #overlay-modes:
    #   default (do NOT change the pentagram_common.h)
    #   rw (insert string 'tb_overlay' in pentagram_common.h)
    #   ro (insert string 'tb_rootfs_ro' in pentagram_common.h)
    echo -e "${DOCKER__FOURSPACES}2. Set overlay-mode"
    echo -e "${DOCKER__FOURSPACES}3. Apply overlay"
    echo -e "${DOCKER__FOURSPACES}4. Remove overlay"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${DOCKER__FOURSPACES}q. $DOCKER__QUIT_CTRL_C"
}

docker__partitiondisk__sub() {
    #Disable Ctrl+C
    disable_ctrl_c__func

    #Define constants
    local READDIALOG_HEADER="---:${DOCKER__INPUT}"

    #Define variables
    local diskpart_new_arr=()
    
    local disksize_remain_bck=0

    local readdialog_partitionsize="${DOCKER__EMPTYSTRING}"
    local readdialog_partitionsize_default="${DOCKER__EMPTYSTRING}"

    local i=0
    local j=0
    local k=0

    #Initialize variables
    disksize_remain=${disksize__input}
    disksize_remain_bck=${disksize__input}

    #Movedown and clean
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    #Show read-dialog
    while true
    do
        docker__readdialog_output="${DOCKER__EMPTYSTRING}"

        #Select readdialog_partitionsize-item
        case ${j} in
            0)  #rootfs
                docker__diskpart_default_left=$(echo "${docker__diskpart_default_arr[j]}" | cut -d" " -f1)
                docker__diskpart_default_right=$(echo "${docker__diskpart_default_arr[j]}" | cut -d" " -f2)
                ;;
            1)  #reserved
                docker__diskpart_default_left=$(echo "${docker__diskpart_default_arr[j]}" | cut -d" " -f1)
                docker__diskpart_default_right=$(echo "${docker__diskpart_default_arr[j]}" | cut -d" " -f2)
                ;;
            2)  #overlay
                docker__diskpart_default_left=$(echo "${docker__diskpart_default_arr[j]}" | cut -d" " -f1)
                docker__diskpart_default_right=$(echo "${docker__diskpart_default_arr[j]}" | cut -d" " -f2)
                ;;
            *)  #additional
                docker__diskpart_default_left="${DOCKER__EMPTYSTRING}"
                ;;
        esac

        #Partition-NAME read-dialog handler (only for additonal fs)
        #Remark:
        #   Provide the partition-name of the additonal fs
        #   ...and write to variable 'docker__diskpart_default_left'
        if [[ ${j} -gt 2 ]]; then   #j > 2
            #Note: variable 'docker__diskpart_default_left' is updated in this subroutine
            docker__partitionname__sub

            #Remark:
            #   If no additional partition-name is provided,
            #   ...then it means that s(kip) was pressed.
            if [[ -z "${docker__diskpart_default_left}" ]]; then
                break
            fi
        fi

        #Partition-SIZE read-dialog handler
        if [[ ${j} -gt 0 ]]; then   #j > 0: do NOT show the read-dialog for the 'reserved-fs'
            #Initalize variables
            docker__readdialog_output="${DOCKER__EMPTYSTRING}"

            #Update 'readdialog_partitionsize'
            readdialog_partitionsize="${READDIALOG_HEADER}: ${docker__diskpart_default_left} "
            
            if [[ ${j} -eq 1 ]]; then  #rootfs
                readdialog_partitionsize+="(${DOCKER__READDIALOG_ABORT}) "           
            elif [[ ${j} -eq 2 ]]; then #overlay
                readdialog_partitionsize+="(${DOCKER__READDIALOG_REDO_ABORT}) "
            elif [[ ${j} -gt 2 ]]; then #anything else except for 'reserved'
                readdialog_partitionsize+="(${DOCKER__READDIALOG_REDO_SKIP_ABORT}) "
            fi
            readdialog_partitionsize+="(${DOCKER__FG_ORANGE215}${disksize_remain}${DOCKER__NOCOLOR}): "


            #Show read-dialog
            #Remark:
            #   For rootfs: show the default-value
            #   For overlay: show the remainder of the available disk-size
            #   For additional: 
            #   1. First show the read-dialog to provide partition-name (see above)
            #   2. Then show the read-dialog to provide the partition-size
            if [[ ${j} -eq 1 ]]; then
                readdialog_partitionsize_default="${docker__diskpart_default_right}"
            else
                readdialog_partitionsize_default="${disksize_remain}"
            fi

            #Remarks:
            #   The read-dialog will not stop until a non Empty String is inputted.
            #       This functionality is implicitely built-in.
            #   This function outputs a value for variable 'docker__readdialog_output'
            docker__readdialog_w_output__func "${readdialog_partitionsize}" "${readdialog_partitionsize_default}"

            #Only continue if a valid option is selected
            if [[ ! -z "${docker__readdialog_output}" ]]; then  #is NOT an Empty String
                if [[ $(isNumeric__func "${docker__readdialog_output}") == true ]]; then  #is numeric
                    #Calculate 'disksize_remain'
                    disksize_remain=$(echo ${disksize_remain} - ${docker__readdialog_output} | bc)

                    if [[ "${disksize_remain}" -gt 0 ]]; then
                        #Update 'diskpart_new_arr'
                        diskpart_new_arr[j]="${docker__diskpart_default_left} ${docker__readdialog_output}"

                        #Backup 'disksize_remain'
                        disksize_remain_bck=${disksize_remain}

                        #Increment index
                        ((j++))
                    elif [[ "${disksize_remain}" -eq 0 ]]; then
                        #Update 'diskpart_new_arr'
                        diskpart_new_arr[j]="${docker__diskpart_default_left} ${docker__readdialog_output}"

                        break
                    else    #disksize_remain < 0
                        #Revert back to the backup
                        disksize_remain=${disksize_remain_bck}
                    fi
                else    #is NOT numeric
                    case "${docker__readdialog_output}" in
                        "${DOCKER__REDO}")
                            #Remark:
                            #   r(edo) is available starting from the 'overlay' input
                            if [[ ${j} -gt 1 ]]; then
                                #Reset array
                                diskpart_new_arr=()

                                #Reset dvariables
                                disksize_remain=${disksize__input}
                                disksize_remain_bck=${disksize__input}

                                #Reset index
                                j=0
                            fi
                            ;;
                        "${DOCKER__SKIP}")
                            #Remark:
                            #   s(kip) is available starting from the 'additional partition-name/size' input
                            if [[ ${j} -gt 2 ]]; then
                                break
                            fi
                            ;;
                        "${DOCKER__ABORT}")
                            return 0;
                            ;;
                        *)
                            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_0}"
                            ;;
                    esac
                fi
            else    #is an Empty String
                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
            fi
        else    #j = 0
            #Update 'diskpart_new_arr'
            diskpart_new_arr[j]="${docker__diskpart_default_left} ${DOCKER__RESERVED_SIZE_DEFAULT}"

            #Calculate 'disksize_remain'
            disksize_remain=$((disksize_remain - DOCKER__RESERVED_SIZE_DEFAULT))

            #Backup 'disksize_remain'
            disksize_remain_bck="${disksize_remain}"

            #Increment index
            ((j++))
        fi
    done

    #Reset array
    docker__diskpart_arr=()
    #Update 'docker__diskpart_arr' with the new values
    for k in "${!diskpart_new_arr[@]}"; do 
        docker__diskpart_arr[k]="${diskpart_new_arr[$k]}"
    done
}
docker__partitionname__sub() {
    #Define variables
    local readdialog_partitionname="${READDIALOG_HEADER}: ${DOCKER__FG_LIGHTGREY}new${DOCKER__NOCOLOR} partition-name (${DOCKER__READDIALOG_SKIP}): "

    #Read-dialog handler
    while true
    do
        #Show read-dialog
        #This function will output a value for variable 'docker__readdialog_output'
        docker__readdialog_w_output__func "${readdialog_partitionname}" "${DOCKER__EMPTYSTRING}"

        if [[ ! -z "${docker__readdialog_output}" ]]; then  #is NOT an Empty String
            if [[ "${docker__readdialog_output}" == "${DOCKER__SKIP}" ]]; then
                docker__readdialog_output="${DOCKER__EMPTYSTRING}"
            fi

            break
        else    #is an Empty String
            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        fi
    done

    #Update variable
    docker__diskpart_default_left="${docker__readdialog_output}"
}



#---MAIN SUBROUTINE
main__sub() {
    docker__check_inputarg__sub

    docker__load_global_fpath_paths__sub

    docker__load_constants__sub

    docker__init_variables__sub

    docker__menu__sub
}



#---EXECUTE
main__sub
