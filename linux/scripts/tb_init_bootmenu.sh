#!/bin/bash
#---CHARACTER CONSTANTS
TB_BACKSPACE=$'\b'
TB_DASH="-"
TB_DOT="."
TB_DOTDOT=".."
TB_ENTER=$'\x0a'
TB_ESCAPEKEY=$'\x1b'
TB_SEMICOLON=";"
TB_SLASH="/"

#---COLOR CONSTANTS
TB_NOCOLOR=$'\e[0;0m'
TB_FG_BLUE_33=$'\e[30;38;5;33m'
TB_FG_BLUE_45=$'\e[30;38;5;45m'
TB_FG_GREEN_158=$'\e[30;38;5;158m'
TB_FG_GREY_243=$'\e[30;38;5;243m'
TB_FG_GREY_246=$'\e[30;38;5;246m'
TB_FG_ORANGE_131=$'\e[30;38;5;131m'
TB_FG_ORANGE_208=$'\e[30;38;5;208m'
TB_FG_ORANGE_215=$'\e[30;38;5;215m'
TB_FG_RED_9=$'\e[30;38;5;9m'
TB_FG_RED_187=$'\e[30;38;5;187m'
TB_FG_YELLOW_33=$'\e[1;33m'

TB_BG_ORANGE_215=$'\e[30;48;5;215m'

#---COMMAND CONSTANTS
REBOOT_CMD="reboot now"

#---DIMENSION CONSTANTS
TB_PERCENT_80=80
TB_TERMWINDOW_WIDTH=$(tput cols)
TB_TABLEWIDTH=$((( TB_TERMWINDOW_WIDTH * TB_PERCENT_80)/100 ))

TB_LISTPAGE_LEN=10

#---FLAG CONSTANTS
TB_OUTPUT_SOURCE="source"
TB_OUTPUT_DESTINATION="destination"

#---LEGEND CONSTANTS
TB_LEGEND="${TB_FG_GREY_246}Legend:${TB_NOCOLOR}"
TB_LEGEND_SAME="="
TB_LEGEND_SAME_W_DESCRIPTION="${TB_LEGEND_SAME} : ${TB_FG_GREY_246}same${TB_NOCOLOR}"
TB_LEGEND_NEW="${TB_FG_GREEN_158}+${TB_NOCOLOR}"
TB_LEGEND_NEW_W_DESCRIPTION="${TB_LEGEND_NEW} : ${TB_FG_GREY_246}new${TB_NOCOLOR}"
TB_LEGEND_NEW_PRIORITY="${TB_LEGEND_NEW}${TB_FG_RED_9}*${TB_NOCOLOR}"
TB_LEGEND_NEW_PRIORITY_W_DESCRIPTION="${TB_LEGEND_NEW_PRIORITY}: ${TB_FG_GREY_246}new with priority${TB_NOCOLOR}"

#---MENU CONSTANTS
TB_MENUITEM_BOOTINTO="Boot into"
TB_MENUITEM_ISPBOOOTBIN_BOOTSEQ="ISPBOOOT.BIN boot-seq"
TB_MENUITEM_OVERLAYMODE="Overlay-mode"
TB_MODE_ISPBOOOTBIN_BOOTSEQ_SDUSB0USB1="SD>USB0>USB1"
TB_MODE_ISPBOOOTBIN_BOOTSEQ_SDUSB1USB0="SD>USB1>USB0"
TB_MODE_ISPBOOOTBIN_BOOTSEQ_USB0SDUSB1="USB0>SD>USB1"
TB_MODE_ISPBOOOTBIN_BOOTSEQ_USB0USB1SD="USB0>USB1>SD"
TB_MODE_ISPBOOOTBIN_BOOTSEQ_USB1SDUSB0="USB1>SD>USB0"
TB_MODE_ISPBOOOTBIN_BOOTSEQ_USB1USB0SD="USB1>USB0>SD"
TB_MODE_BACKUPMODE="backup-mode"
TB_MODE_DISABLED="disabled"
TB_MODE_NORMALMODE="normal-mode"
TB_MODE_RESTOREMODE="restore-mode"
TB_MODE_SAFEMODE="safe-mode"
TB_MODE_NONPERSISTENT="non-persistent"
TB_MODE_PERSISTENT="persistent"

TB_OPTIONS_B="b"
TB_OPTIONS_H="h"
TB_OPTIONS_M="m"
TB_OPTIONS_N="n"
TB_OPTIONS_R="r"
TB_OPTIONS_P="p"
TB_OPTIONS_Q="q"
TB_OPTIONS_Y="y"
TB_OPTIONS_LARROW="<"
TB_OPTIONS_RARROW=">"
TB_OPTIONS_BACK="Back"
TB_OPTIONS_CLEAR="Clear"
TB_OPTIONS_HOME="Home"
TB_OPTIONS_MAIN="Main"
TB_OPTIONS_PAGE_PREV="Prev page"
TB_OPTIONS_PAGE_NEXT="Next page"
TB_OPTIONS_REBOOT="Reboot"
TB_OPTIONS_REDO="Redo"
TB_OPTIONS_QUIT_CTRL_C="Quit (${TB_FG_GREY_246}Ctrl+C${TB_NOCOLOR})"

TB_OPTIONS_SEMICOLON_B=";b"
TB_OPTIONS_SEMICOLON_C=";c"
TB_OPTIONS_SEMICOLON_H=";h"
TB_OPTIONS_SEMICOLON_M=";m"
TB_OPTIONS_SEMICOLON_Q=";q"

TB_READDIALOG_ARE_YOU_SURE_YOU_WISH_TO_REBOOT="Are you sure you wish to reboot (y/n)? "
TB_READDIALOG_CHOOSE_AN_OPTION="Choose an option: "
TB_READDIALOG_CHOOSE_AN_OPTION_AND_PRESS_ENTER="Choose an option (${TB_FG_GREY_246}and press ENTER${TB_NOCOLOR}): "
TB_READDIALOG_INPUT_AND_PRESS_ENTER="Input (${TB_FG_GREY_246}and press ENTER${TB_NOCOLOR}): "

TB_TITLE_BACKUP_CHOOSE_DESTINATION_DIR="${TB_FG_ORANGE_215}BACKUP:${TB_NOCOLOR} Choose destination-dir"
TB_TITLE_BACKUP_PROVIDE_DESTINATION_IMAGE_FILENAME="${TB_FG_ORANGE_215}BACKUP:${TB_NOCOLOR} Provide image-filename"
TB_TITLE_BACKUP_CHOOSE_SOURCE_PATH="${TB_FG_ORANGE_215}BACKUP:${TB_NOCOLOR} Choose source-path"
TB_TITLE_BOOTINTO="${TB_FG_BLUE_45}TB-INIT.SH: ${TB_FG_BLUE_33}BOOT-INTO-MENU${TB_NOCOLOR}"
TB_TITLE_ISPBOOOTBIN_BOOTSEQ="${TB_FG_BLUE_45}TB-INIT.SH: ${TB_FG_BLUE_33}ISPBOOOT.BIN BOOT-SEQ${TB_NOCOLOR}"
TB_TITLE_TB_INIT_SH="${TB_FG_BLUE_45}TB-INIT.SH: ${TB_FG_BLUE_33}MAIN-MENU${TB_NOCOLOR}"
TB_TITLE_TIBBO="TIBBO"

#---NUMERIC CONSTANTS
TB_EXITCODE_99=99

TB_ITEMNUM_1=1
TB_ITEMNUM_2=2
TB_ITEMNUM_3=3
TB_ITEMNUM_4=4
TB_ITEMNUM_5=5
TB_ITEMNUM_6=6

TB_NUMOFLINES_0=0
TB_NUMOFLINES_1=1
TB_NUMOFLINES_2=2
TB_NUMOFLINES_3=3
TB_NUMOFLINES_4=4
TB_NUMOFLINES_5=5
TB_NUMOFLINES_6=6
TB_NUMOFLINES_7=7
TB_NUMOFLINES_8=8
TB_NUMOFLINES_9=9
TB_NUMOFLINES_10=10
TB_NUMOFLINES_12=12

TB_TRAPNUM_2=2

#---OPTION CONSTANTS
TB_NOBOOT_IS_TRUE="tb_noboot=true"
TB_ROOTFS_RO_IS_EMPTYSTRING="tb_rootfs_ro="
TB_ROOTFS_RO_IS_NULL="tb_rootfs_ro=null"
TB_ROOTFS_RO_IS_TRUE="tb_rootfs_ro=true"

#---PATTERN CONSTANTS
TB_PATTERN_DEV_MMCBLK="/dev/mmcblk"
TB_PATTERN_TB_BACKUP="tb_backup"
TB_PATTERN_TB_NOBOOT="tb_noboot"
TB_PATTERN_TB_OVERLAY="tb_overlay"
TB_PATTERN_TB_RESTORE="tb_restore"
TB_PATTERN_TB_ROOTFS_RO="tb_rootfs_ro"

#---PRINT CONSTANTS
TB_PRINT_ERROR="***${TB_FG_RED_9}ERROR${TB_NOCOLOR}"

TB_MENU_WO_NOCOLOR="(${TB_FG_GREY_246}Menu)"
TB_MENU="(${TB_FG_GREY_246}Menu)${TB_NOCOLOR}"

TB_PRINT_MODE_ISPBOOOTBIN_BOOTSEQ_SDUSB0USB1="${TB_FG_GREEN_158}SD${TB_FG_GREY_246}>${TB_FG_GREEN_158}USB0${TB_FG_GREY_246}>${TB_FG_GREEN_158}USB1${TB_NOCOLOR}"
TB_PRINT_MODE_ISPBOOOTBIN_BOOTSEQ_SDUSB1USB0="${TB_FG_GREEN_158}SD${TB_FG_GREY_246}>${TB_FG_GREEN_158}USB1${TB_FG_GREY_246}>${TB_FG_GREEN_158}USB0${TB_NOCOLOR}"
TB_PRINT_MODE_ISPBOOOTBIN_BOOTSEQ_USB0SDUSB1="${TB_FG_GREEN_158}USB0${TB_FG_GREY_246}>${TB_FG_GREEN_158}SD${TB_FG_GREY_246}>${TB_FG_GREEN_158}USB1${TB_NOCOLOR}"
TB_PRINT_MODE_ISPBOOOTBIN_BOOTSEQ_USB0USB1SD="${TB_FG_GREEN_158}USB0${TB_FG_GREY_246}>${TB_FG_GREEN_158}USB1${TB_FG_GREY_246}>${TB_FG_GREEN_158}SD${TB_NOCOLOR}"
TB_PRINT_MODE_ISPBOOOTBIN_BOOTSEQ_USB1SDUSB0="${TB_FG_GREEN_158}USB1${TB_FG_GREY_246}>${TB_FG_GREEN_158}SD${TB_FG_GREY_246}>${TB_FG_GREEN_158}USB0${TB_NOCOLOR}"
TB_PRINT_MODE_ISPBOOOTBIN_BOOTSEQ_USB1USB0SD="${TB_FG_GREEN_158}USB1${TB_FG_GREY_246}>${TB_FG_GREEN_158}USB0${TB_FG_GREY_246}>${TB_FG_GREEN_158}SD${TB_NOCOLOR}"

TB_PRINT_OPTIONS_SEMICOLON_B="${TB_FG_YELLOW_33};${TB_NOCOLOR}b"
TB_PRINT_OPTIONS_SEMICOLON_C="${TB_FG_YELLOW_33};${TB_NOCOLOR}c"
TB_PRINT_OPTIONS_SEMICOLON_H="${TB_FG_YELLOW_33};${TB_NOCOLOR}h"
TB_PRINT_OPTIONS_SEMICOLON_M="${TB_FG_YELLOW_33};${TB_NOCOLOR}m"
TB_PRINT_OPTIONS_SEMICOLON_Q="${TB_FG_YELLOW_33};${TB_NOCOLOR}q"

#---REGEX CONSTANTS
TB_BOOTINTO_MYCHOICE_REGEX="[1234mq]"
TB_ISPBOOOTBIN_BOOTSEQ_MYCHOICE_REGEX="[123456mq]"
TB_MAINMENU_MYCHOICE_REGEX="[123rq]"
TB_RQ_REGEX="[rq]"
TB_YN_REGEX="[yn]"

#---REMARK CONSTANTS
TB_REMARKS="${TB_FG_BLUE_45}Remarks:${TB_NOCOLOR}"
TB_REMARK_A_REBOOT_IS_REQUIRED_FOR_THE_CHANGE_TO_TAKE_EFFECT="${TB_FG_BLUE_33}A reboot is required for the change to take effect${TB_NOCOLOR}"

#---SPACE CONSTANTS
TB_EMPTYSTRING=""
TB_ONESPACE=" "
TB_TWOSPACES="${TB_ONESPACE}${TB_ONESPACE}"
TB_THREESPACES="${TB_TWOSPACES}${TB_ONESPACE}"
TB_FOURSPACES="${TB_TWOSPACES}${TB_TWOSPACES}"

#---PATHS
media_dir="/media"
overlay_dir="/overlay"
proc_dir="/proc"
rootfs_dir="/"
tb_reserve_dir="/tb_reserve"
tb_tmp_dir="/tmp"

tb_init_bootargs_cfg_fpath=${tb_reserve_dir}/.tb_init_bootargs.cfg
tb_init_bootargs_tmp_fpath=${tb_reserve_dir}/.tb_init_bootargs.tmp
tb_init_bootseq_sdusb0usb1_fpath=${tb_reserve_dir}/.tb_init_bootseq_sdusb0usb1
tb_init_bootseq_sdusb1usb0_fpath=${tb_reserve_dir}/.tb_init_bootseq_sdusb1usb0
tb_init_bootseq_usb0sdusb1_fpath=${tb_reserve_dir}/.tb_init_bootseq_usb0sdusb1
tb_init_bootseq_usb0usb1sd_fpath=${tb_reserve_dir}/.tb_init_bootseq_usb0usb1sd
tb_init_bootseq_usb1sdusb0_fpath=${tb_reserve_dir}/.tb_init_bootseq_usb1sdusb0
tb_init_bootseq_usb1usb0sd_fpath=${tb_reserve_dir}/.tb_init_bootseq_usb1usb0sd
tb_overlay_current_cfg_fpath=${tb_reserve_dir}/.tb_overlay_current.cfg

tb_init_bootmenu_arraycontent_tmp_fpath=${tb_tmp_dir}/tb_init_bootmenu_arraycontent.tmp
tb_init_bootmenu_result_tmp_fpath=${tb_tmp_dir}/tb_init_bootmenu_result.tmp

tb_proc_cmdline_fpath=${proc_dir}/cmdline



#---VARIABLES
tb_bootinto_get="${TB_EMPTYSTRING}"
tb_bootinto_mychoice="${TB_EMPTYSTRING}"
tb_bootinto_remarks="${TB_EMPTYSTRING}"
tb_bootinto_set="${TB_EMPTYSTRING}"
tb_bootinto_set_printable="${TB_EMPTYSTRING}"
tb_bootinto_status="${TB_EMPTYSTRING}"
tb_dir_set="${TB_EMPTYSTRING}"
tb_dstfilename_set="${TB_EMPTYSTRING}"
tb_dstpath_set="${TB_EMPTYSTRING}"
tb_init_bootargs_cfg_tb_rootfs_ro_get="${TB_EMPTYSTRING}"
tb_ispboootbin_bootseq_set="${TB_EMPTYSTRING}"
tb_ispboootbin_bootseq_mychoice="${TB_EMPTYSTRING}"
tb_ispboootbin_bootseq_printable="${TB_EMPTYSTRING}"
tb_mainmenu_mychoice="${TB_EMPTYSTRING}"
tb_overlaymode_set="${TB_EMPTYSTRING}"
tb_overlaymode_set_printable="${TB_EMPTYSTRING}"
tb_overlaymode_tag="${TB_EMPTYSTRING}"
tb_proc_cmdline_tb_overlay_get="${TB_EMPTYSTRING}"
tb_proc_cmdline_tb_rootfs_ro_get="${TB_EMPTYSTRING}"
tb_remark="${TB_EMPTYSTRING}"
tb_srcpath_set="${TB_EMPTYSTRING}"

tb_dstpath_size_KB=0
tb_listpage_start=0
tb_numoflines_correction=${TB_NUMOFLINES_0}
tb_srcpath_size_B=0
tb_srcpath_size_KB=0

tb_path_list_arr=()
tb_path_list_arrlen=0

flag_backupmode_restoremode_exitloop=false
flag_backupmode_srcpath_select_exitloop=false
flag_bootintomenu_exitloop=false
flag_file_can_be_removed=false
flag_go_back_onestep=false
flag_ispboootbin_bootseq_exitloop=false
flag_navigate_to_dir_isenabled=false



#---FUNCTIONS
function backspace__func() {
    #Input args
    local string__input=${1}

    #CHeck if 'string__input' is an EMPTYSTRING
    if [[ -z ${string__input} ]]; then
        return
    fi

    #Constants
    local OFFSET=0

    #Lengths
    local str_input_len=${#string__input}
    local str_output_len=$((str_input_len-1))

    #Get result
    local str_output=${string__input:${OFFSET}:${str_output_len}}

    #Output
    echo "${str_output}"
}

function cursor_hide__func() {
    printf '\e[?25l'
}
function cursor_show__func() {
    printf '\e[?25h'
}

function duplicate_char__func() {
    #Input args
    local char__input=${1}
    local nchar__input=${2}

    #Duplicate 'char__input'
    local ret=`printf '%*s' "${nchar__input}" | tr ' ' "${char__input}"`

    #Print text including Leading Empty Spaces
    echo -e "${ret}"
}

function exit__func() {
    #Input args
    exitcode__input=${1}
    numoflines__input=${2}

    #Move-down cursor
    movedown_and_clean__func "${numoflines__input}"

    #Exit with code
    exit ${exitcode__input}
}

function extract_if_and_of_from_string__func() {
    #Extract 'if' and 'of'
    local if=$(cut -d";" -f1 <<< "${tb_bootinto_get}")
    local of=$(cut -d";" -f2 <<< "${tb_bootinto_get}")

    #Update variables which are made ready for printing
    tb_bootinto_remarks="${TB_FOURSPACES}${TB_FG_BLUE_33}if${TB_NOCOLOR}:${TB_FG_BLUE_45}${if}${TB_NOCOLOR}\n"
    tb_bootinto_remarks+="${TB_FOURSPACES}${TB_FG_BLUE_33}of${TB_NOCOLOR}:${TB_FG_BLUE_45}${of}${TB_NOCOLOR}\n"
}

function extract_overlaymode_info__func() {
    #Get 'tb_overlay' value (if present)
    tb_proc_cmdline_tb_overlay_get="${TB_EMPTYSTRING}"
    if [[ -f "${tb_proc_cmdline_fpath}" ]]; then
        tb_proc_cmdline_tb_overlay_get=$(grep -o "${TB_PATTERN_TB_OVERLAY}.*" "${tb_proc_cmdline_fpath}")
    fi

    #Get 'tb_rootfs_ro' values from 2 files (if present)
    tb_proc_cmdline_tb_rootfs_ro_get="${TB_EMPTYSTRING}"
    if [[ -f "${tb_proc_cmdline_fpath}" ]]; then
        tb_proc_cmdline_tb_rootfs_ro_get=$(grep -o "${TB_PATTERN_TB_ROOTFS_RO}.*" "${tb_proc_cmdline_fpath}")
    fi
    tb_init_bootargs_cfg_tb_rootfs_ro_get="${TB_EMPTYSTRING}"
    if [[ -f "${tb_init_bootargs_cfg_fpath}" ]]; then
        tb_init_bootargs_cfg_tb_rootfs_ro_get=$(grep -o "${TB_PATTERN_TB_ROOTFS_RO}.*" "${tb_init_bootargs_cfg_fpath}")
    fi
    tb_overlay_current_cfg_tb_rootfs_ro_get="${TB_EMPTYSTRING}"
    if [[ -f "${tb_overlay_current_cfg_fpath}" ]]; then
        tb_overlay_current_cfg_tb_rootfs_ro_get=$(grep -o "${TB_PATTERN_TB_ROOTFS_RO}.*" "${tb_overlay_current_cfg_fpath}")
    fi

    #Get tb_overlaymode_set and tb_overlaymode_tag
    extract_overlaymode_info__tb_overlaymode_set_and_tag____func

    #Update printable
    case "${tb_overlaymode_set}" in
        "${TB_MODE_PERSISTENT}")
            tb_overlaymode_set_printable="${TB_FG_GREEN_158}${tb_overlaymode_set}${TB_NOCOLOR}"
            ;;
        "${TB_MODE_NONPERSISTENT}")
            tb_overlaymode_set_printable="${TB_FG_RED_187}${tb_overlaymode_set}${TB_NOCOLOR}"

            ;;
        *)
            tb_overlaymode_set_printable="${TB_MODE_DISABLED}"
            ;;
    esac    

    #Append tag (if applicable)
    if [[ -n "${tb_overlaymode_tag}" ]]; then
        tb_overlaymode_set_printable+=": ${tb_overlaymode_tag}"

        #Remove 'tb_init_bootargs_cfg_fpath' (if applicable)
        extract_overlaymode_info__remove_tb_init_bootargs_cfg____func
    fi
}
function extract_overlaymode_info__tb_overlaymode_set_and_tag____func() {
    #Remark:
    #   This function passes results to global variables:
    #       tb_overlaymode_tag
    #       tb_overlaymode_set

    #Initialize global variables
    tb_overlaymode_tag="${TB_EMPTYSTRING}"
    tb_overlaymode_set="${TB_MODE_DISABLED}"

    #Validate overlay-mode (persistent or non-persistent)
    if [[ -n "${tb_proc_cmdline_tb_overlay_get}" ]]; then
        #Determine the 'tb_overlaymode_set'
        if [[ -z ${tb_init_bootargs_cfg_tb_rootfs_ro_get} ]]; then  #tb_rootfs_ro is NOT set in '/tb_reserve/tb_init_bootargs.cfg'
            if [[ -z ${tb_proc_cmdline_tb_rootfs_ro_get} ]]; then  #tb_rootfs_ro is NOT set in '/proc/cmdline'
                tb_overlaymode_set="${TB_MODE_PERSISTENT}"
            else    #tb_rootfs_ro is set in '/proc/cmdline'
                tb_overlaymode_set="${TB_MODE_NONPERSISTENT}"
            fi
        else    #tb_rootfs_ro is set in '/tb_reserve/tb_init_bootargs.cfg'
            if [[ "${tb_init_bootargs_cfg_tb_rootfs_ro_get}" == "${TB_ROOTFS_RO_IS_NULL}" ]]; then
                tb_overlaymode_set="${TB_MODE_PERSISTENT}"

                if [[ -z "${tb_proc_cmdline_tb_rootfs_ro_get}" ]]; then  #tb_rootfs_ro is NOT set in '/proc/cmdline'
                    flag_file_can_be_removed=true
                else    #tb_rootfs_ro is already set in '/proc/cmdline'
                    flag_file_can_be_removed=false
                fi
            else    #tb_init_bootargs_cfg_tb_rootfs_ro_get = true
                tb_overlaymode_set="${TB_MODE_NONPERSISTENT}"

                if [[ "${tb_proc_cmdline_tb_rootfs_ro_get}" == "${TB_ROOTFS_RO_IS_TRUE}" ]]; then  #tb_rootfs_ro is already set in '/proc/cmdline'
                    flag_file_can_be_removed=true
                else    #tb_rootfs_ro is NOT set in '/proc/cmdline'
                    flag_file_can_be_removed=false
                fi
            fi
        fi

        #Determine the 'tb_overlaymode_tag'
        if [[ "${tb_overlaymode_set}" == "${TB_MODE_PERSISTENT}" ]]; then
            if [[ "${tb_overlay_current_cfg_tb_rootfs_ro_get}" == "${TB_ROOTFS_RO_IS_EMPTYSTRING}" ]]; then
                tb_overlaymode_tag="${TB_LEGEND_SAME}"
            else    #tb_overlay_current_cfg_tb_rootfs_ro_get = TB_ROOTFS_RO_IS_TRUE
                tb_overlaymode_tag="${TB_LEGEND_NEW}"
            fi
        else    #tb_overlaymode_set = TB_MODE_NONPERSISTENT
            if [[ "${tb_overlay_current_cfg_tb_rootfs_ro_get}" == "${TB_ROOTFS_RO_IS_TRUE}" ]]; then
                tb_overlaymode_tag="${TB_LEGEND_SAME}"
            else    #tb_overlay_current_cfg_tb_rootfs_ro_get = TB_ROOTFS_RO_IS_EMPTYSTRING
                tb_overlaymode_tag="${TB_LEGEND_NEW}"
            fi
        fi
    fi
}
function extract_overlaymode_info__remove_tb_init_bootargs_cfg____func() {
    if [[ "${flag_file_can_be_removed}" == true ]]; then
        remove_file__func "${tb_init_bootargs_cfg_fpath}"
    fi
}

function extract_bootinto_info__func() {
    #Define and initialize variables
    local backup_result="${TB_EMPTYSTRING}"
    local bootinto_get_raw="${TB_EMPTYSTRING}"
    local bootinto_get_if="${TB_EMPTYSTRING}"
    local bootinto_get_of="${TB_EMPTYSTRING}"
    local noboot_result="${TB_EMPTYSTRING}"
    local restore_result="${TB_EMPTYSTRING}"

    #Get 'tb_backup', 'tb_noboot', tb_restore' values (if present)
    if [[ -f "${tb_init_bootargs_tmp_fpath}" ]]; then
        backup_result=$(grep -o "${TB_PATTERN_TB_BACKUP}.*" "${tb_init_bootargs_tmp_fpath}")
        restore_result=$(grep -o "${TB_PATTERN_TB_RESTORE}.*" "${tb_init_bootargs_tmp_fpath}")
        noboot_result=$(grep -o "${TB_PATTERN_TB_NOBOOT}.*" "${tb_init_bootargs_tmp_fpath}")
    fi
   
    #Initialize global variables
    tb_bootinto_status="${TB_LEGEND_SAME}"
    tb_bootinto_get="${TB_EMPTYSTRING}"
    tb_bootinto_set="${TB_MODE_DISABLED}"
    # tb_bootinto_set_printable="${TB_FG_YELLOW_33}${tb_bootinto_set}${TB_NOCOLOR}"
    tb_bootinto_set_printable="${tb_bootinto_set}"

    #Update variables based on the results (e.g., backup_result, restore_result, noboot_result)
    #Remarks:
    #   sed 's/\s+//g': remove whitespaces
    #   tr -d '\r': remove carriage return
    if [[ -n "${noboot_result}" ]]; then
        tb_bootinto_get=$(echo "${noboot_result}" | cut -d"=" -f2 | sed 's/\s+//g' | tr -d '\r')

        tb_bootinto_set="${TB_MODE_SAFEMODE}"
        # tb_bootinto_set_printable="${TB_FG_YELLOW_33}${TB_MODE_SAFEMODE}${TB_NOCOLOR}"

        tb_bootinto_status="${TB_LEGEND_NEW_PRIORITY}"
    fi
    if [[ -n "${backup_result}" ]]; then
        tb_bootinto_get=$(echo "${backup_result}" | cut -d"=" -f2 | sed 's/\s+//g' | tr -d '\r')

        tb_bootinto_set="${TB_MODE_BACKUPMODE}"
        # tb_bootinto_set_printable="${TB_FG_RED_187}${TB_MODE_BACKUPMODE}${TB_NOCOLOR}"

        tb_bootinto_status="${TB_LEGEND_NEW_PRIORITY}"
    fi
    if [[ -n "${restore_result}" ]]; then
        tb_bootinto_get=$(echo "${restore_result}" | cut -d"=" -f2 | sed 's/\s+//g' | tr -d '\r')

        tb_bootinto_set="${TB_MODE_RESTOREMODE}"
        # tb_bootinto_set_printable="${TB_FG_GREEN_158}${TB_MODE_RESTOREMODE}${TB_NOCOLOR}"

        tb_bootinto_status="${TB_LEGEND_NEW_PRIORITY}"
    fi

    #Update printable or remove file
    if [[ "${tb_bootinto_set}" != "${TB_MODE_DISABLED}" ]]; then
        if [[ ${tb_bootinto_status} != "${TB_LEGEND_SAME}" ]]; then
            tb_bootinto_set_printable="${tb_bootinto_set}: ${TB_LEGEND_NEW_PRIORITY}"
        else
            tb_bootinto_set_printable="${tb_bootinto_set}"
        fi
    else    #tb_bootinto_set = TB_MODE_DISABLED
        #Remove file (if present)
        remove_file__func "${tb_init_bootargs_tmp_fpath}"
    fi
}

function extract_ispboootbin_bootseq_info__func() {
    #Initialize variable
    tb_ispboootbin_bootseq_set="${TB_EMPTYSTRING}"

    #Update 'tb_ispboootbin_bootseq_set' based on the existing file
    while [[ -z "${tb_ispboootbin_bootseq_set}"  ]]
    do
        if [[ -f "${tb_init_bootseq_sdusb0usb1_fpath}" ]]; then
            tb_ispboootbin_bootseq_set="${TB_MODE_ISPBOOOTBIN_BOOTSEQ_SDUSB0USB1}"

            tb_ispboootbin_bootseq_printable="${TB_PRINT_MODE_ISPBOOOTBIN_BOOTSEQ_SDUSB0USB1}"

            break
        fi
        if [[ -f "${tb_init_bootseq_sdusb1usb0_fpath}" ]]; then
            tb_ispboootbin_bootseq_set="${TB_MODE_ISPBOOOTBIN_BOOTSEQ_SDUSB1USB0}"

            tb_ispboootbin_bootseq_printable="${TB_PRINT_MODE_ISPBOOOTBIN_BOOTSEQ_SDUSB1USB0}"

            break
        fi
        if [[ -f "${tb_init_bootseq_usb0sdusb1_fpath}" ]]; then
            tb_ispboootbin_bootseq_set="${TB_MODE_ISPBOOOTBIN_BOOTSEQ_USB0SDUSB1}"

            tb_ispboootbin_bootseq_printable="${TB_PRINT_MODE_ISPBOOOTBIN_BOOTSEQ_USB0SDUSB1}"

            break
        fi
        if [[ -f "${tb_init_bootseq_usb0usb1sd_fpath}" ]]; then
            tb_ispboootbin_bootseq_set="${TB_MODE_ISPBOOOTBIN_BOOTSEQ_USB0USB1SD}"

            tb_ispboootbin_bootseq_printable="${TB_PRINT_MODE_ISPBOOOTBIN_BOOTSEQ_USB0USB1SD}"

            break
        fi
        if [[ -f "${tb_init_bootseq_usb1sdusb0_fpath}" ]]; then
            tb_ispboootbin_bootseq_set="${TB_MODE_ISPBOOOTBIN_BOOTSEQ_USB1SDUSB0}"

            tb_ispboootbin_bootseq_printable="${TB_PRINT_MODE_ISPBOOOTBIN_BOOTSEQ_USB1SDUSB0}"

            break
        fi
        if [[ -f "${tb_init_bootseq_usb1usb0sd_fpath}" ]]; then
            tb_ispboootbin_bootseq_set="${TB_MODE_ISPBOOOTBIN_BOOTSEQ_USB1USB0SD}"

            tb_ispboootbin_bootseq_printable="${TB_PRINT_MODE_ISPBOOOTBIN_BOOTSEQ_USB1USB0SD}"

            break
        fi

        #In case 'tb_ispboootbin_bootseq_set' is still an Empty String
        #   then set to the default value 'tb_ispboootbin_bootseq_set = TB_MODE_ISPBOOOTBIN_BOOTSEQ_SDUSB0USB1'
        tb_ispboootbin_bootseq_set="${TB_MODE_ISPBOOOTBIN_BOOTSEQ_SDUSB0USB1}"
        #Update 'tb_ispboootbin_bootseq_printable'
        tb_ispboootbin_bootseq_printable="${TB_PRINT_MODE_ISPBOOOTBIN_BOOTSEQ_SDUSB0USB1}"
    done
}

function isNumeric__func() {
    #Input args
    local string__input=${1}

    #Define variables
    local re='^[0-9]+$'

    #Check if 'string__input' is numeric
    if [[ $string__input =~ $re ]] ; then
        echo true
    else
        echo false
    fi
}

function movedown__func() {
    #Input args
    local numoflines__input=${1}

    #Exit right away if 'numoflines__input = 0'
    if [[ ${numoflines__input} -eq 0 ]]; then
        return 0;
    fi

    #Hide cursor
    cursor_hide__func

    local tcounter=1
    while [[ ${tcounter} -le ${numoflines__input} ]]
    do
        #Move-up 1 line
        tput cud1
    
        #Increment tcounter by 1
        ((tcounter++))
    done

    #Show cursor
    cursor_show__func
}

function movedown_and_clean__func() {
    #Input args
    local numoflines__input=${1}

    #Hide cursor
    cursor_hide__func

    #Clear lines
    local tcounter=1
    while [[ ${tcounter} -le ${numoflines__input} ]]
    do
        #Move-down 1 line and clean
        tput cud1
        tput el1

        #Increment tcounter by 1
        ((tcounter++))
    done

    #Show cursor
    cursor_show__func
}

function moveup__func() {
    #Input args
    local numoflines__input=${1}

    #Exit right away if 'numoflines__input = 0'
    if [[ ${numoflines__input} -eq 0 ]]; then
        return 0;
    fi

    #Hide cursor
    cursor_hide__func

    local tcounter=1
    while [[ ${tcounter} -le ${numoflines__input} ]]
    do
        #Move-up 1 line
        tput cuu1
    
        #Increment tcounter by 1
        ((tcounter++))
    done

    #Show cursor
    cursor_show__func
}

function moveup_and_clean__func() {
    #Input args
    local numoflines__input=${1}

    #Hide cursor
    cursor_hide__func

    #Clear lines
    local xpos_current=0

    if [[ ${numoflines__input} -ne 0 ]]; then
        local tcounter=1
        while [[ ${tcounter} -le ${numoflines__input} ]]
        do
            #clean current line, Move-up 1 line and clean
            tput el1
            tput cuu1
            tput el

            #Increment tcounter by 1
            ((tcounter++))
        done
    else
        tput el1
    fi

    #Get current x-position of cursor
    xpos_current=$(tput cols)

    #Move to the beginning of line
    tput cub ${xpos_current}

    #Show cursor
    cursor_show__func
}

function print_centered_string__func() {
    #Input args
    local str__input=${1}
    local tablewidth__input=${2}
    local bgcolor__input=${3}

    #Set 'bgcolor__input' to 'TB_NOCOLOR'
    if [[ -z ${bgcolor__input} ]]; then
        bgcolor__input=${TB_NOCOLOR}
    fi

    #Get string 'without visiable' color characters
    local str_wo_colorchars=`echo "${str__input}" | sed "s,\x1B\[[0-9;]*m,,g"`

    #Get string-length
    local str_wo_colorchars_len=${#str_wo_colorchars}

    #Create string containing only empty spaces
    local str_of_emptyspaces=`duplicate_char__func "${TB_ONESPACE}" "${tablewidth__input}"`

    #Calculate the number of spaces to-be-prepended
    local str_startpos=$(( (tablewidth__input - str_wo_colorchars_len)/2 ))


    #Print empty spaces only with background color
    echo -e "${bgcolor__input}${str_of_emptyspaces}${TB_NOCOLOR}"

    #Move-up cursor
    tput cuu1

    #Move cursor to the start position to input string
    tput cuf ${str_startpos}

    #Print string
    echo -e "${bgcolor__input}${str__input}${TB_NOCOLOR}"
}

function print_centered_string_w_leading_trailing_emptylines__func() {
    #Input args
    local menutitle__input=${1}
    local tablewidth__input=${2}
    local bgcolor__input=${3}
    local prepend_numoflines__input=${4}
    local append_numoflines__input=${5}

    #Move-down and clean
    movedown_and_clean__func "${prepend_numoflines__input}"

    #Print title
    print_centered_string__func "${menutitle__input}" "${tablewidth__input}" "${bgcolor__input}"

    #Move-down and clean
    movedown_and_clean__func "${append_numoflines__input}"
}

function print_duplicate_char__func() {
    #Input args
    local char__input=${1}
    local nchar__input=${2}
    local bgcolor__input=${3}

    #Create string containing only empty spaces
    local chars=`duplicate_char__func "${char__input}" "${nchar__input}"`

    #Print string
    echo -e "${bgcolor__input}${chars}${TB_NOCOLOR}"
}

function print_leading_trailing_strings_on_opposite_sides__func() {
    #Input args
    local leadStr__input=${1}
    local trailStr__input=${2}
    local tableWidth__input=${3}

    #Get string 'without visiable' color characters
    local leadStr_input_wo_colorChars=`echo "${leadStr__input}" | sed "s,\x1B\[[0-9;]*m,,g"`
    local trailStr_input_wo_colorChars=`echo "${trailStr__input}" | sed "s,\x1B\[[0-9;]*m,,g"`

    #Get string length
    local leadStr_input_wo_colorChars_len=${#leadStr_input_wo_colorChars}
    local trailStr_input_wo_colorChars_len=${#trailStr_input_wo_colorChars}

    #Calculated the number of spaces to-be-added
    local numOf_spaces=$(( tableWidth__input-(leadStr_input_wo_colorChars_len+trailStr_input_wo_colorChars_len) ))

    #Create a string containing only EMPTY SPACES
    local spaces_leading=`duplicate_char__func "${TB_ONESPACE}" "${numOf_spaces}"`

    #Print text including Leading Empty Spaces
    echo -e "${leadStr__input}${spaces_leading}${trailStr__input}"
}

function print_menuitem__func() {
    #Input args
    local indent__input=${1}
    local optionitem__input=${2}
    local menumsg__input=${3}
    local bracketmsg__input=${4}

    #Update 'printmsg'
    local printmsg="${TB_EMPTYSTRING}"
    if [[ -n "${indent__input}" ]]; then
        printmsg+="${indent__input}"
    fi
    if [[ -n "${optionitem__input}" ]]; then
        printmsg+="${optionitem__input}. "
    fi
    printmsg+="${menumsg__input} "
    if [[ -n ${bracketmsg__input} ]]; then
        # printmsg+="(${TB_FG_GREY_246}${bracketmsg__input}${TB_NOCOLOR})"
        printmsg+="(${bracketmsg__input})"
    fi

    #Output
    echo -e "${printmsg}"
}

function readdialog_clean_buffer__func() {
    read -t0.01 -p "${TB_EMPTYSTRING}" tmp
}

function remove_file__func() {
    #Input args
    local targetfpath=${1}

    #Remove file
    if [[ -f ${targetfpath} ]]; then
        rm ${targetfpath}
    fi
}

function semicolon_option_validate_and_return_value() {
    #Input args
    local string__input=${1}

	#Define variables
	local all_chars_after_semicolon="${TB_EMPTYSTRING}"
	local all_chars_after_semicolon_len=0
	local semicolon_option="${TB_EMPTYSTRING}"
	local first_char_followed_after_semicolon="${TB_EMPTYSTRING}"
	local string_followed_after_first_char="${TB_EMPTYSTRING}"
	local string_followed_after_first_char_len=0
	local ret="${string__input}"

    #Find the right-most semi-colon and get the string on the right-side of this semicolon
    all_chars_after_semicolon=$(echo "${string__input}" | rev | cut -d";" -f1 | rev)

	if [[ -n "${all_chars_after_semicolon}" ]]; then
		#Get the T character on the right-side of the semicolon
		first_char_followed_after_semicolon=${all_chars_after_semicolon:0:1}

		#Get length of 'all_chars_after_semicolon'
		all_chars_after_semicolon_len=${#all_chars_after_semicolon}

		#Get the string which followed after this FIRST character
		string_followed_after_first_char=${all_chars_after_semicolon:1:all_chars_after_semicolon_len}

		#Get length of 'string_followed_after_first_char'
		string_followed_after_first_char_len=${#string_followed_after_first_char}

		#Combine semicolon (;) with 'first_char_followed_after_semicolon'
		semicolon_option="${TB_SEMICOLON}${first_char_followed_after_semicolon}"

		case "${semicolon_option}" in
			"${TB_OPTIONS_SEMICOLON_C}")
				#Remark: 
				#	if a semicolon-c (;c) was inputted,
				#		then return the substring followed AFTER this semicolon-c.
				ret="${string_followed_after_first_char}"

				#Note: if 'ret' is an empty string, then return the semicolon-c.
				if [[ -z "${ret}" ]]; then
					ret="${semicolon_option}"
				fi
				;;
			*)
				#Remarks:
				#	Only return a semicolon-<any char> (e.g. ;x)
				#		if this semicolon-<any char> is found on the RIGHTMOST side.
				#	For all other cases, return the original string 'string__input' 
				if [[ ${string_followed_after_first_char_len} -eq 0 ]]; then
					ret="${semicolon_option}"
				fi
				;;
		esac
	fi

	#Output
	echo "${ret}"
}



#---SUBROUTINES
trap tb_ctrl_c__sub SIGINT
tb_ctrl_c__sub() {
    #Remarks:
    #   'tb_numoflines_correction' has been implemented due to 
    #       subroutine 'bootintomenu_backupmode_dstfilename_choice_and_action__sub'
    #       where the cursor is moved up with 8 lines.
    local numoflines=$((TB_NUMOFLINES_2 + tb_numoflines_correction))

    exit__func "${TB_EXITCODE_99}" "${numoflines}"
}

tibbo_print_title__sub() {
    print_centered_string_w_leading_trailing_emptylines__func "${TB_TITLE_TIBBO}" "${TB_TABLEWIDTH}" "${TB_BG_ORANGE_215}" "${TB_NUMOFLINES_2}" "${TB_NUMOFLINES_0}"
}

extract_dir_content_and_output_tofile__sub() {
    #Input args
    local dir__input=${1}

    #Define variables
    local dir_clean="${TB_EMPTYSTRING}"
    local dir_clean_basename="${TB_EMPTYSTRING}"
    local dir_clean_dirname="${TB_EMPTYSTRING}"
    local dir_dirfpath_listarr=()
    local dir_dirfpath_listarr_item="${TB_EMPTYSTRING}"
    local dir_dirbasename="${TB_EMPTYSTRING}"
    local dir_filefpath_listarr=()
    local dir_filefpath_listarr_item="${TB_EMPTYSTRING}"
    local dir_filebasename="${TB_EMPTYSTRING}"
    local path_list_arr_index=0

    #Reset variable
    tb_path_list_arr=()

    #Pass "dir__input" content to array 'tb_path_list_arr'
    if [[ -d "${dir__input}" ]]; then
        #Remove the trailing backslash(es) (if present)
        dir_clean=$(echo "${dir__input}" | sed 's/\/*$//g')
        if [[ -z "${dir_clean}" ]]; then
            dir_clean="${TB_SLASH}"
        fi

        #Get the basename of 'dir_clean'
        dir_clean_basename=$(basename "${dir_clean}")

        #Get the dirname of 'dir_clean'
        dir_clean_dirname=$(dirname "${dir_clean}")
        
        #Get list of directory only for specified 'dir__input'
        readarray -t dir_dirfpath_listarr < <(find "${dir_clean}/" -maxdepth 1 -type d | sort --version-sort)

        #Get list of files only for specified 'dir__input'
        readarray -t dir_filefpath_listarr < <(find "${dir_clean}/" -maxdepth 1 -type f | sort --version-sort)

        #Combine 'dir_dirfpath_listarr' and 'dir_filefpath_listarr', but take only the BASENAME
        for dir_dirfpath_listarr_item in "${dir_dirfpath_listarr[@]}"
        do
            dir_dirbasename=$(basename "${dir_dirfpath_listarr_item}")
            if [[ "${dir_clean_basename}" != "${dir_dirbasename}" ]]; then
                tb_path_list_arr[path_list_arr_index]="[${dir_dirbasename}]"

                ((path_list_arr_index++))
            fi
        done

        for dir_filefpath_listarr_item in "${dir_filefpath_listarr[@]}"
        do
            dir_filebasename=$(basename "${dir_filefpath_listarr_item}")
            if [[ "-n ${dir_filebasename}" ]]; then
                tb_path_list_arr[path_list_arr_index]="${dir_filebasename}"

                ((path_list_arr_index++))
            fi
        done
    else    #array does NOT contain data
        tb_path_list_arr=()
    fi

    #Get array-length
    tb_path_list_arrlen=${#tb_path_list_arr[@]}
}

show_file_content__sub() {
    #Input args
    #Remarks:
    #   If both 'file__input' and 'dataarr__input' are provided,
    #       then 'file__input' gets the priority over 'dataarr__input'.
    local file__input=${1}
    local dir__input=${2}
    local listpagestart__input=${3}
    local listpagelen__input=${4}
    local indentstring__input=${5}
    local tablewidth__input=${6}



    #Define variables
    local arrow_info="${TB_EMPTYSTRING}"
    local arrow_info_pos=0
    local arrow_info_wo_color="${TB_EMPTYSTRING}"
    local arrow_info_wo_color_len=0
    local arrow_leftpos=0
    local arrow_rightpos=0
    local dir_clean="${TB_EMPTYSTRING}"
    local dir_clean_dirname="${TB_EMPTYSTRING}"
    local indentstring_len=0
    local ctr=1
    local listarr=()
    local listarr_item="${TB_EMPTYSTRING}"
    local listarr_len=0
    local menuitem_index=1
    local listpage_start=0
    local listpage_end=0
    local print_arrows="${TB_EMPTYSTRING}"



    #Update 'listarr'
    if [[ -f "${file__input}" ]]; then   #file exists
        readarray -t listarr < <(cat "${file__input}" | sed '/^$/d')
    else    #file does NOT exist
        listarr=()
    fi

    #Get 'listarr' length
    listarr_len=${#listarr[@]}



    #Calculate 'listpage_start' and 'listpage_end'
    listpage_start=${listpagestart__input}
    if [[ ${listpage_start} -gt ${listarr_len} ]]; then
        listpage_start=${listarr_len}
    fi

    listpage_end=$((listpagestart__input + listpagelen__input - 1))
    if [[ ${listpage_end} -gt ${listarr_len} ]]; then
        listpage_end=${listarr_len}
    fi

    #Initialize variables
    ctr=1
    menuitem_index=1

    #Print [.] and [..]
    if [[ -n "${dir__input}" ]] && \
            [[ "${dir__input}" != "${TB_SLASH}" ]]; then
        
        #Print [..]
        echo "${indentstring__input}${TB_OPTIONS_R}. ${TB_FG_BLUE_45}[${TB_DOTDOT}]${TB_NOCOLOR}"

        #Print [.]
        echo "${indentstring__input}${TB_OPTIONS_P}. ${TB_FG_BLUE_45}[${TB_DOT}]${TB_NOCOLOR}"

        #Set flag to true
        flag_navigate_to_dir_isenabled=true
    else
        #Reset flag to false
        flag_navigate_to_dir_isenabled=false
    fi

    #Print array-contents
    case "${listarr_len}" in
        "0")
            echo "${TB_EMPTYSTRING}"
            ;;
        *)
            #Remove the trailing backslash(es) (if present)
            dir_clean=$(echo "${dir__input}" | sed 's/\/*$//g')
            if [[ -z "${dir_clean}" ]]; then
                dir_clean="${TB_SLASH}"
            fi

            #Get the dirname of 'dir_clean'
            dir_clean_dirname=$(dirname "${dir_clean}")

            #List array content based on the specified 'listpage_start' and 'listpage_end'
            #Remark:
            #   This part will be skippe automatically if 'listarr=()'
            for listarr_item in "${listarr[@]}"
            do
                if [[ ${ctr} -ge ${listpage_start} ]] && [[ ${ctr} -le ${listpage_end} ]]; then
                    echo "${indentstring__input}${menuitem_index}. ${listarr_item}"

                    ((menuitem_index++))
                elif [[ ${ctr} -gt ${listpage_end} ]]; then
                    break
                fi

                ((ctr++))
            done
            ;;
    esac



    #Show arrow left and right
    indentstring_len=${#indentstring__input}
    arrow_leftpos=${indentstring_len}
    arrow_rightpos=$((tablewidth__input - arrow_leftpos - indentstring_len))

    arrow_info="${TB_FG_ORANGE_215}${listpage_start} ${TB_FG_GREY_246}to ${TB_FG_ORANGE_215}${listpage_end} "
    arrow_info+="${TB_FG_GREY_246}(${TB_FG_ORANGE_208}${listarr_len}${TB_FG_GREY_246})${TB_NOCOLOR}"
    arrow_info_wo_color=$(echo "${arrow_info}" | sed "s,\x1B\[[0-9;]*m,,g")
    arrow_info_wo_color_len=${#arrow_info_wo_color}
    arrow_info_pos=$(( (tablewidth__input - arrow_info_wo_color_len) / 2 ))

    #Move-down one line and move-right with 'arrow_leftpos' characters
    tput cud 1 && tput cuf ${arrow_leftpos}
    if [[ ${listpage_start} -gt 1 ]]; then
        #Print left arrow (<)
        echo "${TB_FG_YELLOW_33}<${TB_NOCOLOR}"
    else
        echo "${TB_EMPTYSTRING}"
    fi
    #Move-up one line and move-right with 'arrow_rightpos' characters
    tput cuu1 && tput cuf ${arrow_rightpos}
    #Print right arrow (>)
    if [[ ${listpage_end} -lt ${listarr_len} ]]; then
        echo "${TB_FG_YELLOW_33}>${TB_NOCOLOR}"
    else
        echo "${TB_EMPTYSTRING}"
    fi
    #Move-up one line
    tput cuu1 && tput cuf ${arrow_info_pos}
    #Print 'arrow_info'
    echo "${arrow_info}"

    #Print next-line
    echo -e "\r"
}



#---SECTION MAIN-MENU
mainmenu_extract_info__func() {
    #Remark:
    #   This function will pass values to global variables 'tb_overlaymode_set' and 'tb_overlaymode_set_printable'
    extract_overlaymode_info__func

    #Remark:
    #   This function will pass values to global variables 'tb_bootinto_set' and 'tb_bootinto_set_printable'
    extract_bootinto_info__func

    #Remark:
    #   This function will pass values to global variables 'tb_ispboootbin_bootseq_set' and 'tb_ispboootbin_bootseq_printable'
    extract_ispboootbin_bootseq_info__func
}

mainmenu_print_title__sub() {
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
    print_leading_trailing_strings_on_opposite_sides__func "${TB_TITLE_TB_INIT_SH}" \
            "${TB_EMPTYSTRING}" \
            "${TB_TABLEWIDTH}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
}

mainmenu_print_body__sub() {
    #Update 'print_menuitem_1', 'print_menuitem_2, 'print_menuitem_3' based on
    #   whether 'tb_proc_cmdline_tb_overlay_get' is an Empty String or Not.
    #In other words, whether 'tb_overlay' is found in '/proc/cmdline' or not.
    local print_menuitem_1=""
    local print_menuitem_2=""
    local print_menuitem_3=""

    if [[ -z "${tb_proc_cmdline_tb_overlay_get}" ]]; then
        print_menuitem_1="${TB_FG_GREY_246}"
        print_menuitem_2="${TB_FG_GREY_246}"
        print_menuitem_3="${TB_FG_GREY_246}"
    fi
    
    print_menuitem_1+="${TB_ITEMNUM_1}. ${TB_MENUITEM_OVERLAYMODE} "
    if [[ -z "${tb_proc_cmdline_tb_overlay_get}" ]]; then
        print_menuitem_2+="${TB_ITEMNUM_2}. ${TB_MENU_WO_NOCOLOR}"
        print_menuitem_3+="${TB_ITEMNUM_3}. ${TB_MENU_WO_NOCOLOR}"
    else
        print_menuitem_2+="${TB_ITEMNUM_2}. ${TB_MENU}"
        print_menuitem_3+="${TB_ITEMNUM_3}. ${TB_MENU}"
    fi

    if [[ -z "${tb_proc_cmdline_tb_overlay_get}" ]]; then
        tb_overlaymode_set_printable="${TB_MODE_DISABLED}"
        tb_bootinto_set_printable="${TB_MODE_DISABLED}"
        tb_ispboootbin_bootseq_printable="${TB_MODE_ISPBOOOTBIN_BOOTSEQ_SDUSB0USB1}"
    fi

    print_menuitem_1+="(${tb_overlaymode_set_printable})"
    print_menuitem_2+="${TB_MENUITEM_BOOTINTO} (${tb_bootinto_set_printable})"
    print_menuitem_3+="${TB_MENUITEM_ISPBOOOTBIN_BOOTSEQ} (${tb_ispboootbin_bootseq_printable})"

    if [[ -z "${tb_proc_cmdline_tb_overlay_get}" ]]; then
        print_menuitem_1+="${TB_NOCOLOR}"
        print_menuitem_2+="${TB_NOCOLOR}"
        print_menuitem_3+="${TB_NOCOLOR}"
    fi

    #Print body
    print_menuitem__func "${TB_FOURSPACES}" "${TB_EMPTYSTRING}" "${print_menuitem_1}" "${TB_EMPTYSTRING}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_EMPTYSTRING}" "${print_menuitem_2}" "${TB_EMPTYSTRING}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_EMPTYSTRING}" "${print_menuitem_3}" "${TB_EMPTYSTRING}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_OPTIONS_R}" "${TB_OPTIONS_REBOOT}" "${TB_EMPTYSTRING}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_OPTIONS_Q}" "${TB_OPTIONS_QUIT_CTRL_C}" "${TB_EMPTYSTRING}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
}

mainmenu_print_legend__sub() {
    #Print
    print_menuitem__func "${TB_EMPTYSTRING}" "${TB_EMPTYSTRING}" "${TB_LEGEND}" "${TB_EMPTYSTRING}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_EMPTYSTRING}" "${TB_LEGEND_SAME_W_DESCRIPTION}" "${TB_EMPTYSTRING}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_EMPTYSTRING}" "${TB_LEGEND_NEW_W_DESCRIPTION}" "${TB_EMPTYSTRING}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_EMPTYSTRING}" "${TB_LEGEND_NEW_PRIORITY_W_DESCRIPTION}" "${TB_EMPTYSTRING}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
}

mainmenu_print_remark__sub() {
    if [[ "${tb_overlaymode_tag}" == "${TB_LEGEND_SAME}" ]] && [[ "${tb_bootinto_status}" == "${TB_LEGEND_SAME}" ]]; then
        return 0;
    fi

    #Print
    print_menuitem__func "${TB_EMPTYSTRING}" "${TB_EMPTYSTRING}" "${TB_REMARKS}" "${TB_EMPTYSTRING}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_EMPTYSTRING}" "${TB_REMARK_A_REBOOT_IS_REQUIRED_FOR_THE_CHANGE_TO_TAKE_EFFECT}" "${TB_EMPTYSTRING}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
}

mainmenu_readdialog_choice__sub() {
    #Define and initialize variables
    local regex="${TB_MAINMENU_MYCHOICE_REGEX}"

    #Update 'regex' based on whether 'tb_proc_cmdline_tb_overlay_get' is an Empty String or Not.
    #In other words, whether 'tb_overlay' is found in '/proc/cmdline' or not.
    if [[ -z "${tb_proc_cmdline_tb_overlay_get}" ]]; then
        regex="${TB_RQ_REGEX}"
    fi
    
    while [[ 1 ]]
    do
        #Select an option
        read -N1 -r -p "${TB_READDIALOG_CHOOSE_AN_OPTION}" tb_mainmenu_mychoice
        # movedown_and_clean__func "${TB_NUMOFLINES_1}"

        #Only continue if a valid option is selected
        if [[ ! -z ${tb_mainmenu_mychoice} ]]; then
            if [[ ${tb_mainmenu_mychoice} =~ ${regex} ]]; then
                movedown_and_clean__func "${TB_NUMOFLINES_1}"

                break
            else
                if [[ ${tb_mainmenu_mychoice} == ${TB_ENTER} ]]; then
                    moveup_and_clean__func "${TB_NUMOFLINES_1}"                    
                else
                    moveup_and_clean__func "${TB_NUMOFLINES_0}"
                fi

                readdialog_clean_buffer__func
            fi
        else
            moveup_and_clean__func "${TB_NUMOFLINES_0}"

            readdialog_clean_buffer__func
        fi
    done
}

mainmenu_readdialog_action__sub() {
    #Goto the selected option
    case ${tb_mainmenu_mychoice} in
        1)
            overlaymode_toggle__sub
            ;;
        2)
            bootintomenu__sub
            ;;
        3)
            ispboootbin_bootseqmenu__sub
            ;;
        r)
            reboot__sub
            ;;
        q)
            exit__func "${TB_EXITCODE_99}" "${TB_NUMOFLINES_2}"
            ;;
    esac
}



#---SECTION: OVERLAY-MODE TOGGLE
overlaymode_toggle__sub() {
    #Update 'tb_rootfs_ro_set' based on 'tb_overlaymode_set' value.
    #Remarks:
    #   1. 
    #   2. In file 'tb_init_bootargs_cfg_fpath' will be validated again, and
    #       if needed, removed in function 'extract_overlaymode_info__func'
    if [[ "${tb_overlaymode_set}" == "${TB_MODE_PERSISTENT}" ]]; then   #currently 'tb_overlaymode_set = TB_MODE_NONPERSISTENT'
        tb_rootfs_ro_set="${TB_ROOTFS_RO_IS_TRUE}"
    else    #currently 'tb_overlaymode_set = TB_MODE_PERSISTENT'
        tb_rootfs_ro_set="${TB_ROOTFS_RO_IS_NULL}"
    fi

    #Write to file
    echo "${tb_rootfs_ro_set}" | tee "${tb_init_bootargs_cfg_fpath}" >/dev/null
}



#---SECTION: BOOT-INTO-MENU
bootintomenu_arraylist_show__sub() {
    #Input args
    local flag_output_src_or_dst__input=${1}
    local flag_show_option_back__input=${2}
    local listpagestart__input=${3}

    #Update variable
    local title_msg="${TB_TITLE_BACKUP_CHOOSE_SOURCE_PATH}"
    if [[ "${flag_output_src_or_dst__input}" == "${TB_OUTPUT_DESTINATION}" ]]; then
        title_msg="${TB_TITLE_BACKUP_CHOOSE_DESTINATION_DIR}"
    fi

    #Move-down one line
    movedown_and_clean__func "${TB_NUMOFLINES_1}"

    #Print title
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_FG_GREY_243}"
    print_leading_trailing_strings_on_opposite_sides__func "${title_msg}" \
            "${TB_EMPTYSTRING}" \
            "${TB_TABLEWIDTH}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_FG_GREY_243}"

    #Write array-content to file
    printf "%s\n" "${tb_path_list_arr[@]}" > "${tb_init_bootmenu_arraycontent_tmp_fpath}"


#>>>>>>>>THIS PART NEEDS TO BE UNCOMMENTED AFTER TESTING<<<<<<<<<<<<<<<<
    # #Show file content
    # show_file_content__sub "${tb_init_bootmenu_arraycontent_tmp_fpath}" \
    #         "${TB_EMPTYSTRING}" \
    #         "${listpagestart__input}" \
    #         "${TB_LISTPAGE_LEN}" \
    #         "${TB_FOURSPACES}" \
    #         "${TB_TABLEWIDTH}" \
    #         "${tb_init_bootmenu_result_tmp_fpath}"
#>>>>>>>>THIS PART NEEDS TO BE UNCOMMENTED AFTER TESTING<<<<<<<<<<<<<<<<


#>>>>>>>> FOR TESTING <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
extract_dir_content_and_output_tofile__sub "${tb_dir_set}"

printf "%s\n" "${tb_path_list_arr[@]}" > "${tb_init_bootmenu_arraycontent_tmp_fpath}"

show_file_content__sub "${tb_init_bootmenu_arraycontent_tmp_fpath}" \
        "${tb_dir_set}" \
        "${listpagestart__input}" \
        "${TB_LISTPAGE_LEN}" \
        "${TB_FOURSPACES}" \
        "${TB_TABLEWIDTH}"
#>>>>>>>> FOR TESTING <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


    #Show 'back'
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_FG_GREY_243}"
    if [[ "${flag_show_option_back__input}" == true ]]; then
        print_menuitem__func "${TB_FOURSPACES}" "${TB_OPTIONS_B}" "${TB_OPTIONS_BACK}" "${TB_EMPTYSTRING}"
    fi
    print_menuitem__func "${TB_FOURSPACES}" "${TB_OPTIONS_LARROW}" "${TB_OPTIONS_PAGE_PREV}" "${TB_EMPTYSTRING}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_OPTIONS_RARROW}" "${TB_OPTIONS_PAGE_NEXT}" "${TB_EMPTYSTRING}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_OPTIONS_H}" "${TB_OPTIONS_HOME}" "${TB_EMPTYSTRING}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_OPTIONS_M}" "${TB_OPTIONS_MAIN}" "${TB_EMPTYSTRING}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_OPTIONS_Q}" "${TB_OPTIONS_QUIT_CTRL_C}" "${TB_EMPTYSTRING}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_FG_GREY_243}"
}
bootintomenu_arraylistitem_choice_and_action__sub() {
    #Input args
    local flag_output_src_or_dst__input=${1}
    local flag_show_option_back__input=${2}
    local flag_exitloop_on_file_only__input=${3}

    #Initalize variables
    local path_list_arr_selindex=0
    local path_list_arr_selitem="${TB_EMPTYSTRING}"
    local path_list_arr_selitem_wo_brackets="${TB_EMPTYSTRING}"
    local path_list_arr_selitem_fpath="${TB_EMPTYSTRING}"
    local dir_set_bck="${TB_EMPTYSTRING}"
    local echomsg="${TB_EMPTYSTRING}"
    local echomsg_wo_color="${TB_EMPTYSTRING}"
    local echomsg_wo_color_len=0
    local keyinput="${TB_EMPTYSTRING}"
    local keyinput_tot="${TB_EMPTYSTRING}"
    local listpage_start_bck=0

    flag_backupmode_restoremode_exitloop=false
    flag_backupmode_srcpath_select_exitloop=false
    flag_go_back_onestep=false

    while [[ 1 ]]
    do
        #Reset variable
        keyinput="${TB_EMPTYSTRING}"

        #Update string
        echomsg="${TB_READDIALOG_CHOOSE_AN_OPTION_AND_PRESS_ENTER}${keyinput_tot}"

        #Get string w/o color
        echomsg_wo_color=$(echo "${echomsg}" | sed "s,\x1B\[[0-9;]*m,,g")

        #Update length
        echomsg_wo_color_len="${#echomsg_wo_color}"

        #Print message
        echo -e "${echomsg}"

        #Move up and then move to the end of 'echomsg'
        tput cuu1 && tput cuf "${echomsg_wo_color_len}"
        
        #Execute read-dialog and wait for input
        read -N1 -rs keyinput

        case "${keyinput}" in
            "${TB_OPTIONS_LARROW}")
                #Backup variable
                listpage_start_bck=${tb_listpage_start}

                #Decrement variable
                tb_listpage_start=$(( listpage_start_bck - TB_LISTPAGE_LEN))

                #Final action
                if [[ ${tb_listpage_start} -gt 0 ]]; then
                    movedown_and_clean__func "${TB_NUMOFLINES_2}"

                    break
                else
                    tb_listpage_start=${listpage_start_bck}
                fi
                ;;
            "${TB_OPTIONS_RARROW}")
                #Backup variable
                listpage_start_bck=${tb_listpage_start}

                #Incrementvariable
                tb_listpage_start=$(( tb_listpage_start + TB_LISTPAGE_LEN))

                #Final action
                if [[ ${tb_listpage_start} -lt ${tb_path_list_arrlen} ]]; then
                    movedown_and_clean__func "${TB_NUMOFLINES_2}"

                    break
                else
                    tb_listpage_start=${listpage_start_bck}
                fi
                ;;
            "${TB_OPTIONS_B}")
                if [[ "${flag_show_option_back__input}" == true ]]; then
                    #Move down and clean one line
                    movedown_and_clean__func "${TB_NUMOFLINES_1}"

                    #Set flags to true
                    flag_backupmode_srcpath_select_exitloop=true
                    flag_go_back_onestep=true

                    break
                fi
                ;;
            "${TB_OPTIONS_H}")
                #Move down and clean one line
                movedown_and_clean__func "${TB_NUMOFLINES_1}"

                #Set flags to true
                flag_backupmode_srcpath_select_exitloop=true
                flag_backupmode_restoremode_exitloop=true

                break
                ;;
            "${TB_OPTIONS_M}")
                #Move down and clean one line
                movedown_and_clean__func "${TB_NUMOFLINES_1}"

                #Set flags to true
                flag_backupmode_restoremode_exitloop=true
                flag_backupmode_srcpath_select_exitloop=true
                flag_bootintomenu_exitloop=true

                break
                ;;
            "${TB_OPTIONS_P}")
                #Backup variable
                dir_set_bck="${tb_dir_set}"

                if [[ "${flag_navigate_to_dir_isenabled}" == true ]]; then
                    #Update variable
                    tb_dir_set=$(dirname ${dir_set_bck})

                    if [[ "${tb_dir_set}" != "${dir_set_bck}" ]]; then
                        #Reset variable
                        tb_listpage_start=1

                        #Move down and clean one line
                        movedown_and_clean__func "${TB_NUMOFLINES_2}"

                        break
                    fi
                fi
                ;;
            "${TB_OPTIONS_Q}")
                #Move down and clean one line
                movedown_and_clean__func "${TB_NUMOFLINES_1}"

                #Exit script
                exit__func "${TB_EXITCODE_99}" "${TB_NUMOFLINES_2}"
                ;;
            "${TB_OPTIONS_R}")
                #Backup variable
                dir_set_bck="${tb_dir_set}"

                if [[ "${flag_navigate_to_dir_isenabled}" == true ]]; then
                    #Update variable
                    tb_dir_set="${TB_SLASH}"

                    if [[ "${tb_dir_set}" != "${dir_set_bck}" ]]; then
                        #Reset variable
                        tb_listpage_start=1

                        #Move down and clean one line
                        movedown_and_clean__func "${TB_NUMOFLINES_2}"

                        break
                    fi
                fi
                ;;
            "${TB_BACKSPACE}")
                #Get the updated 'keyinput_tot' after pressing BACKSPACE
                keyinput_tot=$(backspace__func "${keyinput_tot}")
                ;;
            "${TB_ENTER}")
                if [[ $(isNumeric__func "${keyinput_tot}") == true ]]; then
                    if [[ ${keyinput_tot} -le ${tb_path_list_arrlen} ]]; then
                        #Get array-index
                        path_list_arr_selindex=$((keyinput_tot - 1))

                        #Update variable
                        path_list_arr_selitem="${tb_path_list_arr[path_list_arr_selindex]}"

                        #Strip off brackets (if present)
                        path_list_arr_selitem_wo_brackets=$(echo "${path_list_arr_selitem}" | sed 's/\[//g' | sed 's/\]//g')

                        #Exit immediate if 'flag_exitloop_on_file_only__input = false'
                        #Remark:
                        #   This means that we don't care about the 'type' of 'path_list_arr_selitem'.
                        #   Therefore we also do NOT care about updating 'path_list_arr_selitem_fpath'.
                        if [[ "${flag_exitloop_on_file_only__input}" == false ]]; then
                            if [[ "${flag_output_src_or_dst__input}" == "${TB_OUTPUT_SOURCE}" ]]; then
                                tb_srcpath_set="${path_list_arr_selitem_wo_brackets}"
                            else    #flag_output_src_or_dst__input = TB_OUTPUT_DESTINATION
                                tb_dstpath_set="${path_list_arr_selitem_wo_brackets}"
                            fi

                            #Set flags to true
                            flag_backupmode_srcpath_select_exitloop=true
                            flag_backupmode_restoremode_exitloop=true

                            #Move down and clean one line
                            movedown_and_clean__func "${TB_NUMOFLINES_1}"

                            break
                        fi

                        #Update variable
                        path_list_arr_selitem_fpath="${tb_dir_set}/${path_list_arr_selitem_wo_brackets}"

                        #Check if 'path_list_arr_selitem_fpath' is a file
                        #   and exit immediate if true.
                        if [[ -d "${path_list_arr_selitem_fpath}" ]]; then
                            #Update 'tb_dir_set'
                            tb_dir_set="${path_list_arr_selitem_fpath}"

                            #Reset variable
                            tb_listpage_start=1
                        else        
                            if [[ "${flag_output_src_or_dst__input}" == "${TB_OUTPUT_SOURCE}" ]]; then
                                tb_srcpath_set="${path_list_arr_selitem_fpath}"
                            else    #flag_output_src_or_dst__input = TB_OUTPUT_DESTINATION
                                tb_dstpath_set="${path_list_arr_selitem_fpath}"
                            fi

                            #Set flags to true
                            flag_backupmode_srcpath_select_exitloop=true
                            flag_backupmode_restoremode_exitloop=true
                        fi

                        #Move down and clean one line
                        movedown_and_clean__func "${TB_NUMOFLINES_1}"

                        break
                    else
                        #Reset variable
                        keyinput_tot="${TB_EMPTYSTRING}"
                    fi
                else
                    #Reset variable
                    keyinput_tot="${TB_EMPTYSTRING}"
                fi
                ;;
            "${TB_ESCAPEKEY}")
                #Do nothing
                ;;
            *)
                if [[ -n "${keyinput}" ]]; then
                    #Update variable
                    keyinput_tot+="${keyinput}"
                fi
                ;;
        esac

        #Move up and clean one line
        moveup_and_clean__func "${TB_NUMOFLINES_0}"

        #Clean read-dialog buffer
        readdialog_clean_buffer__func
    done
}
bootintomenu__sub() {
    while [[ 1 ]]
    do
        #Initialize variables
        flag_bootintomenu_exitloop=false

        #Print header
        tibbo_print_title__sub    

        #Print bootinto menutitle
        bootintomenu_title_print__sub

        #Print body
        bootintomenu_body_print__sub

        #Print remark
        bootintomenu_remark_print__sub

        #Show read-dialog (loop)
        #Note: result is passed to global variable 'tb_bootinto_mychoice'
        bootintomenu_readdialog_choice__sub

        #Take action
        bootintomenu_readdialog_action__sub

        #Check if a flag was given to exit loop
        if [[ "${flag_bootintomenu_exitloop}" == true ]]; then
            break
        fi
    done
}
bootintomenu_title_print__sub() {
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
    print_leading_trailing_strings_on_opposite_sides__func "${TB_TITLE_BOOTINTO}" \
            "${TB_EMPTYSTRING}" \
            "${TB_TABLEWIDTH}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
}
bootintomenu_body_print__sub() {
    #Define and initialize variables
    local print_safemode="${TB_MODE_SAFEMODE}"
    local print_backupmode="${TB_MODE_BACKUPMODE}"
    local print_restoremode="${TB_MODE_RESTOREMODE}"
    local print_disabled="${TB_MODE_DISABLED}"

    #Extract 'bootinto' information
    extract_bootinto_info__func

    #Update variables (if appliable)
    if [[ "${tb_bootinto_set}" != "${TB_MODE_SAFEMODE}" ]]; then
        print_safemode="${TB_FG_GREY_246}${print_safemode} (false)${TB_NOCOLOR}"
    else
        print_safemode="${print_safemode} (true)"
    fi
    if [[ "${tb_bootinto_set}" != "${TB_MODE_BACKUPMODE}" ]]; then
        print_backupmode="${TB_FG_GREY_246}${print_backupmode} (false)${TB_NOCOLOR}"
    else
        print_backupmode="${print_backupmode} (true)"
    fi
    if [[ "${tb_bootinto_set}" != "${TB_MODE_RESTOREMODE}" ]]; then
        print_restoremode="${TB_FG_GREY_246}${print_restoremode} (false)${TB_NOCOLOR}"
    else
        print_restoremode="${print_restoremode} (true)"
    fi
    if [[ "${tb_bootinto_set}" == "${TB_MODE_SAFEMODE}" ]] || \
            [[ "${tb_bootinto_set}" == "${TB_MODE_BACKUPMODE}" ]] || \
            [[ "${tb_bootinto_set}" == "${TB_MODE_RESTOREMODE}" ]]; then
        print_disabled="${TB_FG_GREY_246}${print_disabled}${TB_NOCOLOR}"
    fi

    #Print
    print_menuitem__func "${TB_FOURSPACES}" "${TB_ITEMNUM_1}" "${print_safemode}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_ITEMNUM_2}" "${print_backupmode}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_ITEMNUM_3}" "${print_restoremode}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_ITEMNUM_4}" "${print_disabled}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_OPTIONS_M}" "${TB_OPTIONS_MAIN}" "${TB_EMPTYSTRING}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_OPTIONS_Q}" "${TB_OPTIONS_QUIT_CTRL_C}" "${TB_EMPTYSTRING}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
}
bootintomenu_remark_print__sub() {
    if [[ ! -s "${tb_init_bootargs_tmp_fpath}" ]]; then
        return 0;
    fi

    if [[ "${tb_bootinto_set}" == "${TB_MODE_SAFEMODE}" ]]; then
        return 0;
    fi

    #Extract 'if' and 'of'
    extract_if_and_of_from_string__func

    #Print
    print_menuitem__func "${TB_EMPTYSTRING}" "${TB_EMPTYSTRING}" "${TB_REMARKS}" "${TB_EMPTYSTRING}"
    print_menuitem__func "${TB_EMPTYSTRING}" "${TB_EMPTYSTRING}" "${tb_bootinto_remarks}" "${TB_EMPTYSTRING}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
}
bootintomenu_readdialog_choice__sub() {
    while [[ 1 ]]
    do
        #Select an option
        read -N1 -r -p "${TB_READDIALOG_CHOOSE_AN_OPTION}" tb_bootinto_mychoice

        #Only continue if a valid option is selected
        if [[ ! -z ${tb_bootinto_mychoice} ]]; then
            if [[ ${tb_bootinto_mychoice} =~ ${TB_BOOTINTO_MYCHOICE_REGEX} ]]; then
                movedown_and_clean__func "${TB_NUMOFLINES_1}"

                break
            else
                if [[ ${tb_bootinto_mychoice} == ${TB_ENTER} ]]; then
                    moveup_and_clean__func "${TB_NUMOFLINES_1}"                    
                else
                    moveup_and_clean__func "${TB_NUMOFLINES_0}"
                fi

                readdialog_clean_buffer__func
            fi
        else
            moveup_and_clean__func "${TB_NUMOFLINES_0}"

            readdialog_clean_buffer__func
        fi
    done
}
bootintomenu_readdialog_action__sub() {
    #Goto the selected option
    case ${tb_bootinto_mychoice} in
        1)
            bootintomenu_safemode__sub
            ;;
        2)
            bootintomenu_backupmode__sub
            ;;
        3)
            echo -e "in progress (${tb_bootinto_mychoice})"
            ;;
        4)
            bootintomenu_disable__sub
            ;;
        m)
            flag_bootintomenu_exitloop=true;
            ;;
        q)
            exit__func "${TB_EXITCODE_99}" "${TB_NUMOFLINES_2}"
            ;;
    esac
}
bootintomenu_safemode__sub() {
    #Remove file (if present)
    remove_file__func "${tb_init_bootargs_tmp_fpath}"

    #Update 'tb_rootfs_ro_set' based on 'tb_overlaymode_set' value.
    tb_bootinto_set="${TB_NOBOOT_IS_TRUE}"

    #Write to file
    echo "${tb_bootinto_set}" | tee "${tb_init_bootargs_tmp_fpath}" >/dev/null
}
bootintomenu_backupmode__sub() {
    #Define constants
    local PHASE_BOOTINTO_READDIALOG_BACKUPMODE_SRCPATH=10
    local PHASE_BOOTINTO_READDIALOG_BACKUPMODE_SRCSIZE=11
    local PHASE_BOOTINTO_READDIALOG_BACKUPMODE_DSTDIR=20
    local PHASE_BOOTINTO_READDIALOG_BACKUPMODE_DSTSIZE=21
    local PHASE_BOOTINTO_READDIALOG_BACKUPMODE_DSTFILE=22
    local PHASE_BOOTINTO_READDIALOG_BACKUPMODE_COMPARE_SIZES=30
    local PHASE_BOOTINTO_READDIALOG_BACKUPMODE_EXIT=100

    #Define variables
    local phase="${PHASE_BOOTINTO_READDIALOG_BACKUPMODE_SRCPATH}"

    #Initialize variables
    tb_dstpath_set="${TB_EMPTYSTRING}"
    tb_srcpath_set="${TB_EMPTYSTRING}"

    #Start loop
    while [[ 1 ]]
    do
        case "${phase}" in
            "${PHASE_BOOTINTO_READDIALOG_BACKUPMODE_SRCPATH}")
                bootintomenu_backupmode_srcpath_select__sub

#>>>>>>>> FOR TESTING <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
echo ${tb_srcpath_set}
#>>>>>>>> FOR TESTING <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

                if [[ "${flag_backupmode_restoremode_exitloop}" == true ]]; then
                    phase="${PHASE_BOOTINTO_READDIALOG_BACKUPMODE_EXIT}"
                else
                    phase="${PHASE_BOOTINTO_READDIALOG_BACKUPMODE_SRCSIZE}"
                fi
                ;;
            "${PHASE_BOOTINTO_READDIALOG_BACKUPMODE_SRCSIZE}")
                bootintomenu_backupmode_srcsize_get__sub

                if [[ "${flag_backupmode_restoremode_exitloop}" == true ]]; then
                    phase="${PHASE_BOOTINTO_READDIALOG_BACKUPMODE_EXIT}"
                else
                    phase="${PHASE_BOOTINTO_READDIALOG_BACKUPMODE_DSTDIR}"
                fi
                ;;
            "${PHASE_BOOTINTO_READDIALOG_BACKUPMODE_DSTDIR}")
                bootintomenu_backupmode_dstdir_select__sub

                if [[ "${flag_go_back_onestep}" == true ]]; then
                    phase="${PHASE_BOOTINTO_READDIALOG_BACKUPMODE_SRCPATH}"
                else
                    if [[ "${flag_backupmode_restoremode_exitloop}" == true ]]; then
                        phase="${PHASE_BOOTINTO_READDIALOG_BACKUPMODE_EXIT}"
                    else
                        phase="${PHASE_BOOTINTO_READDIALOG_BACKUPMODE_DSTFILE}"
                    fi
                fi
                ;;
            "${PHASE_BOOTINTO_READDIALOG_BACKUPMODE_DSTFILE}")
                bootintomenu_backupmode_dstfilename_input__sub

echo "${tb_dstfilename_set}"

                if [[ "${flag_go_back_onestep}" == true ]]; then
                    phase="${PHASE_BOOTINTO_READDIALOG_BACKUPMODE_DSTDIR}"
                else
                    if [[ "${flag_backupmode_restoremode_exitloop}" == true ]]; then
                        phase="${PHASE_BOOTINTO_READDIALOG_BACKUPMODE_EXIT}"
                    else
                        phase="${PHASE_BOOTINTO_READDIALOG_BACKUPMODE_DSTSIZE}"
                    fi
                fi
                ;;
            "${PHASE_BOOTINTO_READDIALOG_BACKUPMODE_DSTSIZE}")
                bootintomenu_backupmode_dstsize_get__sub

                if [[ "${flag_backupmode_restoremode_exitloop}" == true ]]; then
                    phase="${PHASE_BOOTINTO_READDIALOG_BACKUPMODE_EXIT}"
                else
                    phase="${PHASE_BOOTINTO_READDIALOG_BACKUPMODE_COMPARE_SIZES}"
                fi
                ;;
            "${PHASE_BOOTINTO_READDIALOG_BACKUPMODE_COMPARE_SIZES}")
                echo "in progress: PHASE_BOOTINTO_READDIALOG_BACKUPMODE_COMPARE_SIZES"

                phase="${PHASE_BOOTINTO_READDIALOG_BACKUPMODE_EXIT}"
                ;;
            "${PHASE_BOOTINTO_READDIALOG_BACKUPMODE_EXIT}")
                # echo "in progress: PHASE_BOOTINTO_READDIALOG_BACKUPMODE_EXIT"

                break
                ;;
        esac
    done
}
bootintomenu_backupmode_srcpath_select__sub() {
    #Define and initialize variables
    tb_listpage_start=1

    #Initialize variables
    tb_path_list_arr=()


#>>>>>>>>THIS PART NEEDS TO BE UNCOMMENTED AFTER TESTING<<<<<<<<<<<<<<<<
    #Get list of source-paths
    local srcpath_list_string=$(lsblk --noheadings --output PATH | grep "${TB_PATTERN_DEV_MMCBLK}" | sort --version-sort)

    #Convert string to array
    tb_path_list_arr=(${srcpath_list_string})

    #Get array-length
    tb_path_list_arrlen=${#tb_path_list_arr[@]}
#>>>>>>>>THIS PART NEEDS TO BE UNCOMMENTED AFTER TESTING<<<<<<<<<<<<<<<<


#>>>>>>>> FOR TESTING <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
tb_dir_set="/etc/systemd/system"
#>>>>>>>> FOR TESTING <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


    while [[ 1 ]]
    do
        #Print body
        bootintomenu_arraylist_show__sub "${TB_OUTPUT_SOURCE}" "false" "${tb_listpage_start}"

#>>>>>>>>THIS PART NEEDS TO BE UNCOMMENTED AFTER TESTING<<<<<<<<<<<<<<<<
        # #Show read-dialog
        # #Note: this subroutine passes the result to the global variable 'tb_srcpath_set'
        # bootintomenu_arraylistitem_choice_and_action__sub "${TB_OUTPUT_SOURCE}" "false" "false"
#>>>>>>>>THIS PART NEEDS TO BE UNCOMMENTED AFTER TESTING<<<<<<<<<<<<<<<<


#>>>>>>>> FOR TESTING <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
bootintomenu_arraylistitem_choice_and_action__sub "${TB_OUTPUT_SOURCE}" "false" "true"
#>>>>>>>> FOR TESTING <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


        if [[ "${flag_backupmode_srcpath_select_exitloop}" == true ]]; then
            break
        fi
    done
}
bootintomenu_backupmode_srcsize_get__sub() {
    #Note: 'blockdev' should only be used to get the size of the partitions (e.g. /dev/mmcblk0, /dev/mmcblk0p8)
    tb_srcpath_size_B=$(sudo blockdev --getsize64 "${tb_srcpath_set}" 2>/dev/null); exitcode=$?

    if [[ ${exitcode} -eq 0 ]]; then    #succesful
        #Convert to Kilobytes
        tb_srcpath_size_KB=$((tb_srcpath_size_B / 1024))
    else    #error
        #Set flag to true
        flag_backupmode_restoremode_exitloop=true

        #Move down and clean one line
        movedown_and_clean__func "${TB_NUMOFLINES_1}"

        #Print error-message
        local printmsg="${TB_PRINT_ERROR}: invalid or non-existing partition '${tb_srcpath_set}'"

        print_menuitem__func "${TB_EMPTYSTRING}" "${TB_EMPTYSTRING}" "${printmsg}" "${TB_EMPTYSTRING}"
    fi

}
bootintomenu_backupmode_dstdir_select__sub() {
    #Initialize variables
    tb_path_list_arr=()

    #Get list of source-paths
    local dstfldr_list_string=$(ls -1 ${media_dir} | sort --version-sort)
    local dstfldr_list_arr=(${dstfldr_list_string})
    local dstpath_list_string=$(printf "${media_dir}/%s\n" "${dstfldr_list_arr[@]}")

    #Convert string to array
    tb_path_list_arr=(${dstpath_list_string})

    #Get array-length
    tb_path_list_arrlen=${#tb_path_list_arr[@]}

    #Print body
    bootintomenu_arraylist_show__sub "${TB_OUTPUT_DESTINATION}" "true"

    #Show read-dialog
    #Note: this subroutine passes the result to the global variable 'tb_dstpath_set'
    bootintomenu_arraylistitem_choice_and_action__sub "${TB_OUTPUT_DESTINATION}" "true" "false"
}
bootintomenu_backupmode_dstfilename_input__sub() {
    #Print body
    bootintomenu_backupmode_dstfilename_body_print__sub

    #Show read-dialog
    #Note: this subroutine passes the result to the global variable 'tb_dstfilename_set'
    bootintomenu_backupmode_dstfilename_choice_and_action__sub
}
bootintomenu_backupmode_dstfilename_body_print__sub() {
    #Move-down one line
    movedown_and_clean__func "${TB_NUMOFLINES_1}"

    #Print title
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_FG_GREY_243}"
    print_leading_trailing_strings_on_opposite_sides__func "${TB_TITLE_BACKUP_PROVIDE_DESTINATION_IMAGE_FILENAME}" \
            "${TB_EMPTYSTRING}" \
            "${TB_TABLEWIDTH}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_FG_GREY_243}"

    #Leave an empty line for adding the read-dialog later on
    movedown_and_clean__func "${TB_NUMOFLINES_1}"

    #Show 'back'
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_FG_GREY_243}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_PRINT_OPTIONS_SEMICOLON_C}" "${TB_OPTIONS_CLEAR}" "${TB_EMPTYSTRING}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_PRINT_OPTIONS_SEMICOLON_B}" "${TB_OPTIONS_BACK}" "${TB_EMPTYSTRING}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_PRINT_OPTIONS_SEMICOLON_H}" "${TB_OPTIONS_HOME}" "${TB_EMPTYSTRING}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_PRINT_OPTIONS_SEMICOLON_M}" "${TB_OPTIONS_MAIN}" "${TB_EMPTYSTRING}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_PRINT_OPTIONS_SEMICOLON_Q}" "${TB_OPTIONS_QUIT_CTRL_C}" "${TB_EMPTYSTRING}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_FG_GREY_243}"

    #Move-up seven (7) lines
    moveup__func "${TB_NUMOFLINES_8}"
}
bootintomenu_backupmode_dstfilename_choice_and_action__sub() {
    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    # Note: this subroutine is similar to 
    #       'bootintomenu_arraylistitem_choice_and_action__sub'
    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    #Initalize variables
    local echomsg="${TB_EMPTYSTRING}"
    local echomsg_wo_color_len=0
    local keyinput="${TB_EMPTYSTRING}"
    local keyinput_tot="${TB_EMPTYSTRING}"
    local keyinput_tot_validated="${TB_EMPTYSTRING}"

    flag_backupmode_restoremode_exitloop=false
    flag_go_back_onestep=false

    #Set variable
    tb_numoflines_correction=${TB_NUMOFLINES_7}

    while [[ 1 ]]
    do
        #Reset variable
        keyinput="${TB_EMPTYSTRING}"

        #Update string
        echomsg="${TB_READDIALOG_INPUT_AND_PRESS_ENTER}${keyinput_tot}"

        #Get string w/o color
        echomsg_wo_color=$(echo "${echomsg}" | sed "s,\x1B\[[0-9;]*m,,g")

        #Update length
        echomsg_wo_color_len="${#echomsg_wo_color}"

        #Print message
        echo -e "${echomsg}"

        #Move up and then move to the end of 'echomsg'
        tput cuu1 && tput cuf "${echomsg_wo_color_len}"
        
        #Execute read-dialog and wait for input
        read -N1 -rs keyinput

        #Validate 'keyinput'
        case "${keyinput}" in
            "${TB_BACKSPACE}")
                #Get the updated 'keyinput_tot' after pressing BACKSPACE
                keyinput_tot=$(backspace__func "${keyinput_tot}")
                ;;
            "${TB_ENTER}")
                if [[ -n "${keyinput_tot}" ]]; then
                    keyinput_tot_validated=$(semicolon_option_validate_and_return_value "${keyinput_tot}")

                     #Validate 'keyinput_tot_validated'
                    case "${keyinput_tot_validated}" in
                        "${TB_OPTIONS_SEMICOLON_C}")
                            #Reset variable
                            keyinput_tot="${TB_EMPTYSTRING}"

                            moveup__func "${TB_NUMOFLINES_0}"
                            ;;
                        "${TB_OPTIONS_SEMICOLON_B}")
                            #Move down and clean one line
                            movedown__func "${TB_NUMOFLINES_7}"

                            #Set flag to true
                            flag_go_back_onestep=true

                            break
                            ;;
                        "${TB_OPTIONS_SEMICOLON_H}")
                            #Move down and clean one line
                            movedown__func "${TB_NUMOFLINES_8}"

                            #Set flag to true
                            flag_backupmode_restoremode_exitloop=true

                            break
                            ;;
                        "${TB_OPTIONS_SEMICOLON_M}")
                            #Move down and clean one line
                            movedown__func "${TB_NUMOFLINES_8}"

                            #Set flags to true
                            flag_bootintomenu_exitloop=true
                            flag_backupmode_restoremode_exitloop=true

                            break
                            ;;
                        "${TB_OPTIONS_SEMICOLON_Q}")
                            #Move down and clean one line
                            movedown__func "${TB_NUMOFLINES_8}"

                            #Exit script
                            exit__func "${TB_EXITCODE_99}" "${TB_NUMOFLINES_2}"
                            ;;
                        *)
                            #Check if 'keyinput_tot' and 'keyinput_tot_validated' are the same
                            #Remarks:
                            #   If both strings are the same, then it means that no semicolon-c was executed.
                            #   If both strings are different, then it means that a semicolon-c was executed.
                            if [[ "${keyinput_tot}" == "${keyinput_tot_validated}" ]]; then    #same
                                #Update variable
                                tb_dstfilename_set="${keyinput_tot}"

                                #Move down and clean one line
                                movedown__func "${TB_NUMOFLINES_8}"

                                break
                            else    #different
                                keyinput_tot="${keyinput_tot_validated}"
                            fi
                            ;;
                    esac
                else
                    #Reset variable
                    keyinput_tot="${TB_EMPTYSTRING}"
                fi
                ;;
            "${TB_ESCAPEKEY}")
                #Do nothing
                ;;
            *)
                if [[ -n "${keyinput}" ]]; then
                    #Update variable
                    keyinput_tot+="${keyinput}"
                fi
                ;;
        esac

        #Move up and clean one line
        moveup_and_clean__func "${TB_NUMOFLINES_0}"

        #Clean read-dialog buffer
        readdialog_clean_buffer__func
    done

    #Reset variable
    tb_numoflines_correction=${TB_NUMOFLINES_0}
}

bootintomenu_backupmode_dstsize_get__sub() {
    if [[ -d "${tb_dstpath_set}" ]]; then   #directory exists
        #Note: 'blockdev' should only be used to get the size of the partitions (e.g. /dev/mmcblk0, /dev/mmcblk0p8)
        tb_dstpath_size_KB=$(df --output='avail' -k "${tb_dstpath_set}" | \
                tail -n1 | \
                sed 's/^ *//g' | \
                sed 's/* $//g'); \
                exitcode=$?
    else    #directory does NOT exist
        exitcode=99
    fi

    if [[ ${exitcode} -gt 0 ]]; then    #succesful
        #Set flag to true
        flag_backupmode_restoremode_exitloop=true

        #Move down and clean one line
        movedown_and_clean__func "${TB_NUMOFLINES_1}"

        #Print error-message
        local printmsg="${TB_PRINT_ERROR}: invalid or non-existing directory '${tb_dstpath_set}'"

        print_menuitem__func "${TB_EMPTYSTRING}" "${TB_EMPTYSTRING}" "${printmsg}" "${TB_EMPTYSTRING}"
    fi
}

bootintomenu_disable__sub() {
    #Remove file (if present)
    remove_file__func "${tb_init_bootargs_tmp_fpath}"
}



#---SECTION: ISPBOOOT.BIN BOOT-SEQUENCE
ispboootbin_bootseqmenu__sub() {
    #Print header
    tibbo_print_title__sub    

    #Print bootinto menutitle
    ispboootbin_bootseqmenu__sub_title_print__sub

    #Print body
    ispboootbin_bootseqmenu_body_print__sub

    #Show read-dialog (loop)
    #Note: result is passed to global variable 'tb_ispboootbin_bootseq_mychoice'
    ispboootbin_bootseqmenu_readdialog_choice__sub

    #Take action
    ispboootbin_bootseqmenu_readdialog_action__sub
}
ispboootbin_bootseqmenu__sub_title_print__sub() {
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
    print_leading_trailing_strings_on_opposite_sides__func "${TB_TITLE_ISPBOOOTBIN_BOOTSEQ}" \
            "${TB_EMPTYSTRING}" \
            "${TB_TABLEWIDTH}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
}
ispboootbin_bootseqmenu_body_print__sub() {
    #Define and initialize variables
    local print_menuitem_1="${TB_FG_GREY_246}${TB_MODE_ISPBOOOTBIN_BOOTSEQ_SDUSB0USB1}${TB_NOCOLOR}"
    local print_menuitem_2="${TB_FG_GREY_246}${TB_MODE_ISPBOOOTBIN_BOOTSEQ_SDUSB1USB0}${TB_NOCOLOR}"
    local print_menuitem_3="${TB_FG_GREY_246}${TB_MODE_ISPBOOOTBIN_BOOTSEQ_USB0SDUSB1}${TB_NOCOLOR}"
    local print_menuitem_4="${TB_FG_GREY_246}${TB_MODE_ISPBOOOTBIN_BOOTSEQ_USB0USB1SD}${TB_NOCOLOR}"
    local print_menuitem_5="${TB_FG_GREY_246}${TB_MODE_ISPBOOOTBIN_BOOTSEQ_USB1SDUSB0}${TB_NOCOLOR}"
    local print_menuitem_6="${TB_FG_GREY_246}${TB_MODE_ISPBOOOTBIN_BOOTSEQ_USB1USB0SD}${TB_NOCOLOR}"

    #Extract 'ispboootbin bootseq' information
    extract_ispboootbin_bootseq_info__func

    #Update variables (if appliable)
    case "${tb_ispboootbin_bootseq_set}" in
        "${TB_MODE_ISPBOOOTBIN_BOOTSEQ_SDUSB0USB1}")
            print_menuitem_1="${TB_PRINT_MODE_ISPBOOOTBIN_BOOTSEQ_SDUSB0USB1}"
            ;;
        "${TB_MODE_ISPBOOOTBIN_BOOTSEQ_SDUSB0USB1}")
            print_menuitem_2="${TB_PRINT_MODE_ISPBOOOTBIN_BOOTSEQ_SDUSB1USB0}"
            ;;
        "${TB_MODE_ISPBOOOTBIN_BOOTSEQ_SDUSB0USB1}")
            print_menuitem_3="${TB_PRINT_MODE_ISPBOOOTBIN_BOOTSEQ_USB0SDUSB1}"
            ;;
        "${TB_MODE_ISPBOOOTBIN_BOOTSEQ_SDUSB0USB1}")
            print_menuitem_4="${TB_PRINT_MODE_ISPBOOOTBIN_BOOTSEQ_USB0USB1SD}"
            ;;
        "${TB_MODE_ISPBOOOTBIN_BOOTSEQ_SDUSB0USB1}")
            print_menuitem_5="${TB_PRINT_MODE_ISPBOOOTBIN_BOOTSEQ_USB1SDUSB0}"
            ;;
        "${TB_MODE_ISPBOOOTBIN_BOOTSEQ_SDUSB0USB1}")
            print_menuitem_6="${TB_PRINT_MODE_ISPBOOOTBIN_BOOTSEQ_USB1USB0SD}"
            ;;
    esac

    #Print
    print_menuitem__func "${TB_FOURSPACES}" "${TB_ITEMNUM_1}" "${print_menuitem_1}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_ITEMNUM_2}" "${print_menuitem_2}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_ITEMNUM_3}" "${print_menuitem_3}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_ITEMNUM_4}" "${print_menuitem_4}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_ITEMNUM_5}" "${print_menuitem_5}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_ITEMNUM_6}" "${print_menuitem_6}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_OPTIONS_M}" "${TB_OPTIONS_MAIN}" "${TB_EMPTYSTRING}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_OPTIONS_Q}" "${TB_OPTIONS_QUIT_CTRL_C}" "${TB_EMPTYSTRING}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
}
ispboootbin_bootseqmenu_readdialog_choice__sub() {
    while [[ 1 ]]
    do
        #Select an option
        read -N1 -r -p "${TB_READDIALOG_CHOOSE_AN_OPTION}" tb_ispboootbin_bootseq_mychoice

        #Only continue if a valid option is selected
        if [[ ! -z ${tb_ispboootbin_bootseq_mychoice} ]]; then
            if [[ ${tb_ispboootbin_bootseq_mychoice} =~ ${TB_ISPBOOOTBIN_BOOTSEQ_MYCHOICE_REGEX} ]]; then
                movedown_and_clean__func "${TB_NUMOFLINES_1}"

                break
            else
                if [[ ${tb_ispboootbin_bootseq_mychoice} == ${TB_ENTER} ]]; then
                    moveup_and_clean__func "${TB_NUMOFLINES_1}"                    
                else
                    moveup_and_clean__func "${TB_NUMOFLINES_0}"
                fi

                readdialog_clean_buffer__func
            fi
        else
            moveup_and_clean__func "${TB_NUMOFLINES_0}"

            readdialog_clean_buffer__func
        fi
    done
}
ispboootbin_bootseqmenu_readdialog_action__sub() {
    #Remove file starting with pattern '.tb_init_bootseq_*'
    remove_file__func "${tb_init_bootseq_sdusb0usb1_fpath}"
    remove_file__func "${tb_init_bootseq_sdusb1usb0_fpath}"
    remove_file__func "${tb_init_bootseq_usb0sdusb1_fpath}"
    remove_file__func "${tb_init_bootseq_usb0usb1sd_fpath}"
    remove_file__func "${tb_init_bootseq_usb1sdusb0_fpath}"
    remove_file__func "${tb_init_bootseq_usb1usb0sd_fpath}"

    #Create file based on the selection
    local targetfpath="${TB_EMPTYSTRING}"
    case "${tb_ispboootbin_bootseq_mychoice}" in
        "1")
            targetfpath="${tb_init_bootseq_sdusb0usb1_fpath}"
            ;;
        "2")
            targetfpath="${tb_init_bootseq_sdusb1usb0_fpath}"
            ;;
        "3")
            targetfpath="${tb_init_bootseq_usb0sdusb1_fpath}"
            ;;
        "4")
            targetfpath="${tb_init_bootseq_usb0usb1sd_fpath}"
            ;;
        "5")
            targetfpath="${tb_init_bootseq_usb1sdusb0_fpath}"
            ;;
        "6")
            targetfpath="${tb_init_bootseq_usb1usb0sd_fpath}"
            ;;
        *)
            #Do nothing
            ;;
    esac

    #Write to file
    touch "${targetfpath}" >/dev/null
}



#---SECTION: REBOOT
reboot__sub() {
    #Define variables
    local keyinput="${TB_OPTIONS_N}"

    #Move-down one line
    movedown_and_clean__func "${TB_NUMOFLINES_1}"

    #Show read-dialog
    while [[ 1 ]]
    do
        #Select an option
        read -N1 -r -p "${TB_READDIALOG_ARE_YOU_SURE_YOU_WISH_TO_REBOOT}" keyinput
        # movedown_and_clean__func "${TB_NUMOFLINES_1}"

        #Only continue if a valid option is selected
        if [[ ! -z ${keyinput} ]]; then
            if [[ ${keyinput} =~ ${TB_YN_REGEX} ]]; then
                movedown_and_clean__func "${TB_NUMOFLINES_1}"

                break
            else
                if [[ ${keyinput} == ${TB_ENTER} ]]; then
                    moveup_and_clean__func "${TB_NUMOFLINES_1}"                    
                else
                    moveup_and_clean__func "${TB_NUMOFLINES_0}"
                fi

                readdialog_clean_buffer__func
            fi
        else
            moveup_and_clean__func "${TB_NUMOFLINES_0}"

            readdialog_clean_buffer__func
        fi
    done

    if [[ "${keyinput}" == "${TB_OPTIONS_Y}" ]]; then
        movedown_and_clean__func "${TB_NUMOFLINES_1}"
        
        ${REBOOT_CMD}
    fi
}



#---MAIN SUBROUTINE
main__sub() {
    while [[ 1 ]]
    do
        #Print header
        tibbo_print_title__sub

        #Extract info from files
        mainmenu_extract_info__func

        #Print main-menu title
        mainmenu_print_title__sub

        #Print body
        mainmenu_print_body__sub

        #Print legend
        mainmenu_print_legend__sub

        #Print remark (if any)
        mainmenu_print_remark__sub

        #Show read-dialog (loop)
        #Note: result is passed to global variable 'tb_mainmenu_mychoice'
        mainmenu_readdialog_choice__sub

        #Take action
        mainmenu_readdialog_action__sub
    done
}



#---EXECUTE
main__sub
