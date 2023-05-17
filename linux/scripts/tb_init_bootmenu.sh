#!/bin/bash
#---CHARACTER CONSTANTS
TB_DASH="-"
TB_ENTER=$'\x0a'

#---COLOR CONSTANTS
TB_NOCOLOR=$'\e[0;0m'
TB_FG_BLUE_33=$'\e[30;38;5;33m'
TB_FG_BLUE_45=$'\e[30;38;5;45m'
TB_FG_GREEN_158=$'\e[30;38;5;158m'
TB_FG_GREY_243=$'\e[30;38;5;243m'
TB_FG_GREY_246=$'\e[30;38;5;246m'
TB_FG_ORANGE_131=$'\e[30;38;5;131m'
TB_FG_ORANGE_208=$'\e[30;38;5;208m'
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

#---MENU CONSTANTS
TB_MENU="(${TB_FG_GREY_246}Menu${TB_NOCOLOR})"
TB_MENUITEM_BOOTINTO="Boot into"
TB_MENUITEM_OVERLAYMODE="Overlay-mode"
TB_MODE_BACKUPMODE="backup-mode"
TB_MODE_DISABLED="disabled"
TB_MODE_NORMALMODE="normal-mode"
TB_MODE_RESTOREMODE="restore-mode"
TB_MODE_SAFEMODE="safe-mode"
TB_MODE_NONPERSISTENT="non-persistent"
TB_MODE_PERSISTENT="persistent"

TB_OPTIONS_B="b"
TB_OPTIONS_N="n"
TB_OPTIONS_R="r"
TB_OPTIONS_Q="q"
TB_OPTIONS_Y="y"
TB_OPTIONS_BACK="Back"
TB_OPTIONS_REBOOT="Reboot"
TB_OPTIONS_QUIT_CTRL_C="Quit (${TB_FG_GREY_246}Ctrl+C${TB_NOCOLOR})"

TB_READDIALOG_ARE_YOU_SURE_YOU_WISH_TO_REBOOT="Are you sure you wish to reboot (y/n)? "
TB_READDIALOG_PLEASE_CHOOSE_AN_OPTION="Please choose an option: "

TB_TITLE_BOOTINTO="${TB_FG_BLUE_45}TB-INIT.SH: ${TB_FG_BLUE_33}BOOT-INTO-MENU${TB_NOCOLOR}"
TB_TITLE_TB_INIT_SH="${TB_FG_BLUE_45}TB-INIT.SH: ${TB_FG_BLUE_33}MAIN-MENU${TB_NOCOLOR}"
TB_TITLE_TIBBO="TIBBO"

#---NUMERIC CONSTANTS
TB_EXITCODE_99=99

TB_ITEMNUM_1=1
TB_ITEMNUM_2=2
TB_ITEMNUM_3=3
TB_ITEMNUM_4=4

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

#---OPTION CONSTANTS
TB_TB_ROOTFS_RO_IS_NULL="tb_rootfs_ro=null"
TB_TB_ROOTFS_RO_IS_TRUE="tb_rootfs_ro=true"

#---PATTERN CONSTANTS
TB_PATTERN_TB_BACKUP="tb_backup"
TB_PATTERN_TB_NOBOOT="tb_noboot"
TB_PATTERN_TB_OVERLAY="tb_overlay"
TB_PATTERN_TB_RESTORE="tb_restore"
TB_PATTERN_TB_ROOTFS_RO="tb_rootfs_ro"

#---LEGEND CONSTANTS
TB_LEGEND="${TB_FG_GREY_246}Legend:${TB_NOCOLOR}"
TB_LEGEND_S="="
TB_LEGEND_S_W_DESCRIPTION="${TB_LEGEND_S} : ${TB_FG_GREY_246}same${TB_NOCOLOR}"
TB_LEGEND_N="${TB_FG_GREEN_158}+${TB_NOCOLOR}"
TB_LEGEND_N_W_DESCRIPTION="${TB_LEGEND_N} : ${TB_FG_GREY_246}new${TB_NOCOLOR}"
TB_LEGEND_P="${TB_LEGEND_N}${TB_FG_RED_9}*${TB_NOCOLOR}"
TB_LEGEND_P_W_DESCRIPTION="${TB_LEGEND_P}: ${TB_FG_GREY_246}new with priority${TB_NOCOLOR}"

#---REMARK CONSTANTS
TB_REMARK="${TB_FG_BLUE_45}Remark:${TB_NOCOLOR}"
TB_REMARK_A_REBOOT_IS_REQUIRED_FOR_THE_CHANGE_TO_TAKE_EFFECT="${TB_FG_BLUE_33}a reboot is required for the change to take effect${TB_NOCOLOR}"

#---SPACE CONSTANTS
TB_EMPTYSTRING=""
TB_ONESPACE=" "
TB_TWOSPACES="${TB_ONESPACE}${TB_ONESPACE}"
TB_THREESPACES="${TB_TWOSPACES}${TB_ONESPACE}"
TB_FOURSPACES="${TB_TWOSPACES}${TB_TWOSPACES}"

#---PATHS
proc_dir="/proc"
tb_reserve_dir="/tb_reserve"
tb_init_bootargs_cfg_fpath=${tb_reserve_dir}/.tb_init_bootargs.cfg
tb_init_bootargs_tmp_fpath=${tb_reserve_dir}/.tb_init_bootargs.tmp
tb_proc_cmdline_fpath=${proc_dir}/cmdline



#---VARIABLES
tb_bootinto_get_printable="${TB_EMPTYSTRING}"
tb_bootinto_set="${TB_EMPTYSTRING}"
tb_bootinto_set_printable="${TB_EMPTYSTRING}"
tb_mychoice="${TB_EMPTYSTRING}"
tb_overlaymode_set="${TB_EMPTYSTRING}"
tb_overlaymode_set_printable="${TB_EMPTYSTRING}"
tb_remark="${TB_EMPTYSTRING}"

tb_mychoice_regex="[12rq]"
tb_reboot_reegex="[yn]"

flag_bootinto_isset=false
flag_overlaymode_isset=${TB_LEGEND_S}



#---FUNCTIONS
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

function get_current_printable_datetime__func() {
    #Get local time-zone
    local mytimezone=$(curl https://ipapi.co/timezone 2> /dev/null)
    #Set time-zone
    timedatectl set-timezone ${mytimezone}

    #Get city from 'mytimezone'
    local mycity=$(echo ${mytimezone} | cut -d"/" -f2)
    
    #Get current-date
    local mydate=$(date +%Y/%b/%d)
    
    #Combine data
    local mylocationinfo="${mycity}, ${mydate}"

    #Add color
    local ret="${TB_FG_GREY_246}${mylocationinfo}${TB_NOCOLOR}"

    #Output
    echo -e "${ret}"
}

function get_overlaymode_setting__func() {
    #Get 'tb_overlay' value (if present)
    local tb_overlay_val="${TB_EMPTYSTRING}"
    if [[ -f "${tb_proc_cmdline_fpath}" ]]; then
        tb_overlay_val=$(grep -o "${TB_PATTERN_TB_OVERLAY}.*" "${tb_proc_cmdline_fpath}")
    fi

    #Get 'tb_rootfs_ro' values from 2 files (if present)
    #Remarks:
    #   Regarding tB_rootfs_ro, check both files '/tb_reserve/tb_init_bootargs.cfg' and '/proc/cmdline'
    #   'tb_rootfs_ro_custom_val' take precedence over 'tb_rootfs_ro_builtin_val'
    local tb_rootfs_ro_builtin_val="${TB_EMPTYSTRING}"
    if [[ -f "${tb_proc_cmdline_fpath}" ]]; then
        tb_rootfs_ro_builtin_val=$(grep -o "${TB_PATTERN_TB_ROOTFS_RO}.*" "${tb_proc_cmdline_fpath}")
    fi
    local tb_rootfs_ro_custom_val="${TB_EMPTYSTRING}"
    if [[ -f "${tb_init_bootargs_cfg_fpath}" ]]; then
        tb_rootfs_ro_custom_val=$(grep -o "${TB_PATTERN_TB_ROOTFS_RO}.*" "${tb_init_bootargs_cfg_fpath}")
    fi

    #Check whether the current overlay-mode is set to 'persistent' or 'non-persistent'
    flag_overlaymode_isset="${TB_LEGEND_S}"
    tb_overlaymode_set="${TB_MODE_DISABLED}"
    tb_overlaymode_set_printable="${TB_FG_YELLOW_33}${TB_MODE_DISABLED}${TB_NOCOLOR}"

    if [[ -n "${tb_overlay_val}" ]]; then
        if [[ -z ${tb_rootfs_ro_custom_val} ]]; then  #tb_rootfs_ro is NOT set in '/tb_reserve/tb_init_bootargs.cfg'
            if [[ -z ${tb_rootfs_ro_builtin_val} ]]; then  #tb_rootfs_ro is NOT set in '/proc/cmdline'
                tb_overlaymode_set="${TB_MODE_PERSISTENT}"

                tb_overlaymode_set_printable="${TB_FG_GREEN_158}${TB_MODE_PERSISTENT}${TB_NOCOLOR}"
            else    #tb_rootfs_ro is set in '/proc/cmdline'
                tb_overlaymode_set="${TB_MODE_NONPERSISTENT}"

                tb_overlaymode_set_printable="${TB_FG_RED_187}${TB_MODE_NONPERSISTENT}${TB_NOCOLOR}"
            fi

            #Set flag to 'false'
            flag_overlaymode_isset="${TB_LEGEND_S}"
        else    #tb_rootfs_ro is set in '/tb_reserve/tb_init_bootargs.cfg'
            if [[ "${tb_rootfs_ro_custom_val}" == "${TB_TB_ROOTFS_RO_IS_NULL}" ]]; then
                tb_overlaymode_set="${TB_MODE_PERSISTENT}"

                tb_overlaymode_set_printable="${TB_FG_GREEN_158}${TB_MODE_PERSISTENT}${TB_NOCOLOR}"

                if [[ -z ${tb_rootfs_ro_builtin_val} ]]; then
                    flag_overlaymode_isset="${TB_LEGEND_S}"
                else
                    flag_overlaymode_isset="${TB_LEGEND_N}"
                fi
            else
                tb_overlaymode_set="${TB_MODE_NONPERSISTENT}"

                tb_overlaymode_set_printable="${TB_FG_RED_187}${TB_MODE_NONPERSISTENT}${TB_NOCOLOR}"

                if [[ -n ${tb_rootfs_ro_builtin_val} ]]; then
                    flag_overlaymode_isset="${TB_LEGEND_S}"
                else
                    flag_overlaymode_isset="${TB_LEGEND_N}"
                fi
            fi
        fi
    fi

    #Set legend to whether '[c]' or '[n]'
    if [[ "${tb_overlaymode_set}" != "${TB_MODE_DISABLED}" ]]; then
        if [[ "${flag_overlaymode_isset}" == "${TB_LEGEND_S}" ]]; then
            tb_overlaymode_set_printable="${tb_overlaymode_set_printable}: ${TB_LEGEND_S}"

            remove_file__func "${tb_init_bootargs_cfg_fpath}"
        else
            tb_overlaymode_set_printable="${tb_overlaymode_set_printable}: ${TB_LEGEND_N}"
        fi
    fi
}

function remove_file__func() {
    #Input args
    local targetfpath=${1}

    #Remove file
    if [[ -f ${targetfpath} ]]; then
        rm ${targetfpath}
    fi
}

function get_bootinto_setting__func() {
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
    flag_bootinto_isset="${TB_LEGEND_S}"
    tb_bootinto_get_printable="${TB_EMPTYSTRING}"
    tb_bootinto_set="${TB_MODE_DISABLED}"
    # tb_bootinto_set_printable="${TB_FG_YELLOW_33}${tb_bootinto_set}${TB_NOCOLOR}"
    tb_bootinto_set_printable="${tb_bootinto_set}"

    #Update variables based on the results (e.g., backup_result, restore_result, noboot_result)
    if [[ -n "${noboot_result}" ]]; then
        tb_bootinto_get_printable=$(echo "${noboot_result}" | cut -d"=" -f2 | sed 's/\s+//g' | tr -d '\r')

        tb_bootinto_set="${TB_MODE_SAFEMODE}"
        # tb_bootinto_set_printable="${TB_FG_YELLOW_33}${TB_MODE_SAFEMODE}${TB_NOCOLOR}"

        flag_bootinto_isset="${TB_LEGEND_P}"
    fi
    if [[ -n "${backup_result}" ]]; then
        bootinto_get_raw=$(echo "${backup_result}" | cut -d"=" -f2 | sed 's/\s+//g' | tr -d '\r')
        bootinto_get_if=$(echo "${bootinto_get_raw}" | cut -d";" -f1)
        bootinto_get_of=$(echo "${bootinto_get_raw}" | cut -d";" -f2)

        tb_bootinto_get_printable="${TB_FG_GREY_246}if:${TB_NOCOLOR}${bootinto_get_if}${TB_FG_GREY_246},${TB_NOCOLOR}${TB_FG_GREY_246}of:${TB_NOCOLOR}${bootinto_get_of}"

        tb_bootinto_set="${TB_MODE_BACKUPMODE}"
        # tb_bootinto_set_printable="${TB_FG_RED_187}${TB_MODE_BACKUPMODE}${TB_NOCOLOR}"

        flag_bootinto_isset="${TB_LEGEND_P}"
    fi
    if [[ -n "${restore_result}" ]]; then
        bootinto_get_raw=$(echo "${restore_result}" | cut -d"=" -f2 | sed 's/\s+//g' | tr -d '\r')
        bootinto_get_if=$(echo "${bootinto_get_raw}" | cut -d";" -f1)
        bootinto_get_of=$(echo "${bootinto_get_raw}" | cut -d";" -f2)

        tb_bootinto_get_printable="${TB_FG_GREY_246}if:${TB_NOCOLOR}${bootinto_get_if}${TB_FG_GREY_246},${TB_NOCOLOR}${TB_FG_GREY_246}of:${TB_NOCOLOR}${bootinto_get_of}"

        tb_bootinto_set="${TB_MODE_RESTOREMODE}"
        # tb_bootinto_set_printable="${TB_FG_GREEN_158}${TB_MODE_RESTOREMODE}${TB_NOCOLOR}"

        flag_bootinto_isset="${TB_LEGEND_P}"
    fi

    #Set legend to whether '[c]' or '[p]'
    if [[ "${tb_bootinto_set}" != "${TB_MODE_DISABLED}" ]]; then
        if [[ ${flag_bootinto_isset} != "${TB_LEGEND_S}" ]]; then
            tb_bootinto_set_printable="${tb_bootinto_set}: ${TB_LEGEND_P}"
        else
            tb_bootinto_set_printable="${tb_bootinto_set}"
        fi
    fi
}

function movedown_and_clean__func() {
    #Input args
    local numoflines__input=${1}

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
}

function moveup_and_clean__func() {
    #Input args
    local numoflines__input=${1}

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
    read -t0.01 -p "" tmp
}



#---SUBROUTINES
trap tb_ctrl_c__sub SIGINT
tb_ctrl_c__sub() {
    exit__func "${TB_EXITCODE_99}" "${TB_NUMOFLINES_2}"
}

tibbo_print_title__sub() {
    print_centered_string_w_leading_trailing_emptylines__func "${TB_TITLE_TIBBO}" "${TB_TABLEWIDTH}" "${TB_BG_ORANGE_215}" "${TB_NUMOFLINES_2}" "${TB_NUMOFLINES_0}"
}

mainmenu_print_title__sub() {
    local mylocationinfo=$(get_current_printable_datetime__func)

    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
    print_leading_trailing_strings_on_opposite_sides__func "${TB_TITLE_TB_INIT_SH}" "${mylocationinfo}" "${TB_TABLEWIDTH}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
}

mainmenu_print_body__sub() {
    #Remark:
    #   This function will pass values to global variables 'tb_overlaymode_set' and 'tb_overlaymode_set_printable'
    get_overlaymode_setting__func
    print_menuitem__func "${TB_FOURSPACES}" "${TB_ITEMNUM_1}" "${TB_MENUITEM_OVERLAYMODE}" "${tb_overlaymode_set_printable}"

    #Remark:
    #   This function will pass values to global variables 'tb_bootinto_set' and 'tb_bootinto_set_printable'
    get_bootinto_setting__func
    print_menuitem__func "${TB_FOURSPACES}" "${TB_ITEMNUM_2}" "${TB_MENU} ${TB_MENUITEM_BOOTINTO}" "${tb_bootinto_set_printable}"

    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_OPTIONS_R}" "${TB_OPTIONS_REBOOT}" "${TB_EMPTYSTRING}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_OPTIONS_Q}" "${TB_OPTIONS_QUIT_CTRL_C}" "${TB_EMPTYSTRING}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
}

mainmenu_print_legend__sub() {
    #Print
    print_menuitem__func "${TB_EMPTYSTRING}" "${TB_EMPTYSTRING}" "${TB_LEGEND}" "${TB_EMPTYSTRING}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_EMPTYSTRING}" "${TB_LEGEND_S_W_DESCRIPTION}" "${TB_EMPTYSTRING}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_EMPTYSTRING}" "${TB_LEGEND_N_W_DESCRIPTION}" "${TB_EMPTYSTRING}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_EMPTYSTRING}" "${TB_LEGEND_P_W_DESCRIPTION}" "${TB_EMPTYSTRING}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
}

mainmenu_print_remark__sub() {
    if [[ "${flag_overlaymode_isset}" == "${TB_LEGEND_S}" ]] && [[ "${flag_bootinto_isset}" == "${TB_LEGEND_S}" ]]; then
        return 0;
    fi

    #Print
    print_menuitem__func "${TB_EMPTYSTRING}" "${TB_EMPTYSTRING}" "${TB_REMARK}" "${TB_EMPTYSTRING}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_EMPTYSTRING}" "${TB_REMARK_A_REBOOT_IS_REQUIRED_FOR_THE_CHANGE_TO_TAKE_EFFECT}" "${TB_EMPTYSTRING}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
}

mainmenu_readdialog_choice__sub() {
    while [[ 1 ]]
    do
        #Select an option
        read -N1 -r -p "${TB_READDIALOG_PLEASE_CHOOSE_AN_OPTION}" tb_mychoice
        # movedown_and_clean__func "${TB_NUMOFLINES_1}"

        #Only continue if a valid option is selected
        if [[ ! -z ${tb_mychoice} ]]; then
            if [[ ${tb_mychoice} =~ ${tb_mychoice_regex} ]]; then
                movedown_and_clean__func "${TB_NUMOFLINES_1}"

                break
            else
                if [[ ${tb_mychoice} == ${TB_ENTER} ]]; then
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

mainmenu_readdialog_handler__sub() {
    #Goto the selected option
    case ${tb_mychoice} in
        1)
            mainmenu_readdialog_overlaymode_toggle__sub
            ;;
        2)
            mainmenu_readdialog_bootinto_config__sub
            ;;
        r)
            mainmenu_readdialog_reboot__sub
            ;;
        q)
            exit__func "${TB_EXITCODE_99}" "${TB_NUMOFLINES_2}"
            ;;
    esac
}

mainmenu_readdialog_overlaymode_toggle__sub() {
    #Switch 'tb_overlaymode_set' to 'persistent' or 'non-persistent'
    if [[ "${tb_overlaymode_set}" == "${TB_MODE_PERSISTENT}" ]]; then
        echo "${TB_TB_ROOTFS_RO_IS_TRUE}" | tee "${tb_init_bootargs_cfg_fpath}" > /dev/null
    else
        echo "${TB_TB_ROOTFS_RO_IS_NULL}" | tee "${tb_init_bootargs_cfg_fpath}" > /dev/null
    fi
}

mainmenu_readdialog_bootinto_config__sub() {
    #Print header
    tibbo_print_title__sub    

    #Print bootinto menutitle
    bootinto_print_title__sub

    #Print body
    bootinto_print_body__sub
}
bootinto_print_title__sub() {
    local mylocationinfo=$(get_current_printable_datetime__func)

    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
    print_leading_trailing_strings_on_opposite_sides__func "${TB_TITLE_BOOTINTO}" "${mylocationinfo}" "${TB_TABLEWIDTH}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
}
bootinto_print_body__sub() {
    #Define and initialize variables
    local print_safemode="${TB_MODE_SAFEMODE}"
    local print_backupmode="${TB_MODE_BACKUPMODE}"
    local print_restoremode="${TB_MODE_RESTOREMODE}"
    local print_disabled="${TB_MODE_DISABLED}"

    #Update variables (if appliable)
    if [[ "${tb_bootinto_set}" != "${TB_MODE_SAFEMODE}" ]]; then
        print_safemode="${TB_FG_GREY_246}${print_safemode}${TB_NOCOLOR}"
    else
        print_safemode="${print_safemode} (${tb_bootinto_get_printable})"
    fi
    if [[ "${tb_bootinto_set}" != "${TB_MODE_BACKUPMODE}" ]]; then
        print_backupmode="${TB_FG_GREY_246}${print_backupmode}${TB_NOCOLOR}"
    else
        print_backupmode="${print_backupmode} (${tb_bootinto_get_printable})"
    fi
    if [[ "${tb_bootinto_set}" != "${TB_MODE_RESTOREMODE}" ]]; then
        print_restoremode="${TB_FG_GREY_246}${print_restoremode}${TB_NOCOLOR}"
    else
        print_restoremode="${print_restoremode} (${tb_bootinto_get_printable})"
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
    print_menuitem__func "${TB_FOURSPACES}" "${TB_OPTIONS_B}" "${TB_OPTIONS_BACK}" "${TB_EMPTYSTRING}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
}

mainmenu_readdialog_reboot__sub() {
    #Define variables
    local mychoice="${TB_OPTIONS_N}"

    #Move-down one line
    movedown_and_clean__func "${TB_NUMOFLINES_1}"

    #Show read-dialog
    while [[ 1 ]]
    do
        #Select an option
        read -N1 -r -p "${TB_READDIALOG_ARE_YOU_SURE_YOU_WISH_TO_REBOOT}" mychoice
        # movedown_and_clean__func "${TB_NUMOFLINES_1}"

        #Only continue if a valid option is selected
        if [[ ! -z ${mychoice} ]]; then
            if [[ ${mychoice} =~ ${tb_reboot_reegex} ]]; then
                movedown_and_clean__func "${TB_NUMOFLINES_1}"

                break
            else
                if [[ ${mychoice} == ${TB_ENTER} ]]; then
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

    if [[ "${mychoice}" == "${TB_OPTIONS_Y}" ]]; then
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

        #Print main-menu title
        mainmenu_print_title__sub

        #Print body
        mainmenu_print_body__sub

        #Print legend
        mainmenu_print_legend__sub

        #Print remark (if any)
        mainmenu_print_remark__sub

        #Show read-dialog (loop)
        #Note: result is passed to global variable 'tb_mychoice'
        mainmenu_readdialog_choice__sub

        #Take action
        mainmenu_readdialog_handler__sub
    done
}



#---EXECUTE
main__sub
