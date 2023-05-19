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
TB_PATTERN_LOST_AND_FOUND="lost+found"
TB_PATTERN_TB_BACKUP="tb_backup"
TB_PATTERN_TB_NOBOOT="tb_noboot"
TB_PATTERN_TB_OVERLAY="tb_overlay"
TB_PATTERN_TB_RESTORE="tb_restore"
TB_PATTERN_TB_ROOTFS_RO="tb_rootfs_ro"

#---LEGEND CONSTANTS
TB_LEGEND="${TB_FG_GREY_246}Legend:${TB_NOCOLOR}"
TB_LEGEND_SAME="="
TB_LEGEND_SAME_W_DESCRIPTION="${TB_LEGEND_SAME} : ${TB_FG_GREY_246}same${TB_NOCOLOR}"
TB_LEGEND_NEW="${TB_FG_GREEN_158}+${TB_NOCOLOR}"
TB_LEGEND_NEW_W_DESCRIPTION="${TB_LEGEND_NEW} : ${TB_FG_GREY_246}new${TB_NOCOLOR}"
TB_LEGEND_NEW_PRIORITY="${TB_LEGEND_NEW}${TB_FG_RED_9}*${TB_NOCOLOR}"
TB_LEGEND_NEW_PRIORITY_W_DESCRIPTION="${TB_LEGEND_NEW_PRIORITY}: ${TB_FG_GREY_246}new with priority${TB_NOCOLOR}"

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
overlay_dir="/overlay"
proc_dir="/proc"
rootfs_dir="/"
tb_reserve_dir="/tb_reserve"
tb_init_bootargs_cfg_fpath=${tb_reserve_dir}/.tb_init_bootargs.cfg
tb_init_bootargs_tmp_fpath=${tb_reserve_dir}/.tb_init_bootargs.tmp
tb_overlay_current_cfg_fpath=${tb_reserve_dir}/.tb_overlay_current.cfg
tb_proc_cmdline_fpath=${proc_dir}/cmdline



#---VARIABLES
tb_bootinto_get="${TB_EMPTYSTRING}"
tb_bootinto_remarks="${TB_EMPTYSTRING}"
tb_bootinto_set="${TB_EMPTYSTRING}"
tb_bootinto_set_printable="${TB_EMPTYSTRING}"
tb_mychoice="${TB_EMPTYSTRING}"
tb_overlaymode_set="${TB_EMPTYSTRING}"
tb_overlaymode_set_printable="${TB_EMPTYSTRING}"
tb_overlaymode_tag="${TB_EMPTYSTRING}"
tb_remark="${TB_EMPTYSTRING}"

tb_proc_cmdline_tb_overlay_get="${TB_EMPTYSTRING}"
tb_proc_cmdline_tb_rootfs_ro_get="${TB_EMPTYSTRING}"
tb_init_bootargs_cfg_tb_rootfs_ro_get="${TB_EMPTYSTRING}"

tb_mychoice_regex="[12rq]"
tb_reboot_reegex="[yn]"

flag_bootinto_isset=false



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

function extract_if_and_of_from_string__func() {
    #Extract 'if' and 'of'
    local if=$(cut -d";" -f1 <<< "${tb_bootinto_get}")
    local of=$(cut -d";" -f2 <<< "${tb_bootinto_get}")

    #Update variables which are made ready for printing
    tb_bootinto_remarks="${TB_FOURSPACES}${TB_FG_BLUE_33}if${TB_NOCOLOR}:${TB_FG_BLUE_45}${if}${TB_NOCOLOR}\n"
    tb_bootinto_remarks+="${TB_FOURSPACES}${TB_FG_BLUE_33}of${TB_NOCOLOR}:${TB_FG_BLUE_45}${of}${TB_NOCOLOR}\n"
}

function extract_overlaymode_info__func() {
    #Check if folder 'lost+found' is present at locations '/' and '/overlay'
    local flag_lostandfound_ispresent=$(extract_overlaymode_info__checkif_lostandfound_ispresent____func)

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
            tb_overlaymode_set_printable="${TB_FG_YELLOW_33}${TB_MODE_DISABLED}${TB_NOCOLOR}"
            ;;
    esac    

    #Append tag (if applicable)
    if [[ -n "${tb_overlaymode_tag}" ]]; then
        tb_overlaymode_set_printable+=": ${tb_overlaymode_tag}"

        #Remove 'tb_init_bootargs_cfg_fpath' (if applicable)
        extract_overlaymode_info__remove_tb_init_bootargs_cfg____func
    fi
}
function extract_overlaymode_info__checkif_lostandfound_ispresent____func() {
    #Remark:
    #   If folder 'lost+found' is found at both locations, then it means that
    #       overlay-mode = persistent
    #   On the other hand, if folder'lost+found is not present at both locations, then
    #       overlay-mode = non-persistent
    local rootfs_flag_lostandfound_ispresent=$(ls -l "${rootfs_dir}" | grep "${TB_PATTERN_LOST_AND_FOUND}")
    local overlay_flag_lostandfound_ispresent=$(ls -l "${overlay_dir}" | grep "${TB_PATTERN_LOST_AND_FOUND}")
    local ret=false
    if [[ -n "${rootfs_flag_lostandfound_ispresent}" ]] && [[ -n "${overlay_flag_lostandfound_ispresent}" ]]; then
        ret=true
    fi

    #Output
    echo "${ret}"
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
        if [[ -z ${tb_init_bootargs_cfg_tb_rootfs_ro_get} ]]; then  #tb_rootfs_ro is NOT set in '/tb_reserve/tb_init_bootargs.cfg'
            #Remark:
            #   Since file '/tb_reserve/tb_init_bootargs.cfg' does NOT exist or contains NO data
            #       flag 'flag_lostandfound_ispresent' does NOT need to be evaluated here.
            if [[ -z ${tb_proc_cmdline_tb_rootfs_ro_get} ]]; then  #tb_rootfs_ro is NOT set in '/proc/cmdline'
                tb_overlaymode_set="${TB_MODE_PERSISTENT}"
            else    #tb_rootfs_ro is set in '/proc/cmdline'
                tb_overlaymode_set="${TB_MODE_NONPERSISTENT}"
            fi

            #Set flag to 'false'
            tb_overlaymode_tag="${TB_LEGEND_SAME}"
        else    #tb_rootfs_ro is set in '/tb_reserve/tb_init_bootargs.cfg'
            if [[ "${tb_init_bootargs_cfg_tb_rootfs_ro_get}" == "${TB_TB_ROOTFS_RO_IS_NULL}" ]]; then
                tb_overlaymode_set="${TB_MODE_PERSISTENT}"

                if [[ ${flag_lostandfound_ispresent} == true ]]; then
                    tb_overlaymode_tag="${TB_LEGEND_SAME}"
                else    #flag_lostandfound_ispresent = false
                    tb_overlaymode_tag="${TB_LEGEND_NEW}"
                fi
            else    #tb_init_bootargs_cfg_tb_rootfs_ro_get = true
                tb_overlaymode_set="${TB_MODE_NONPERSISTENT}"

                if [[ ${flag_lostandfound_ispresent} == false ]]; then
                    tb_overlaymode_tag="${TB_LEGEND_SAME}"
                else    #flag_lostandfound_ispresent = true
                    tb_overlaymode_tag="${TB_LEGEND_NEW}"
                fi
            fi
        fi
    fi
}
function extract_overlaymode_info__remove_tb_init_bootargs_cfg____func() {
    if [[ "${tb_overlaymode_tag}" == "${TB_LEGEND_SAME}" ]]; then
        remove_file__func "${tb_init_bootargs_cfg_fpath}"
    else    #tb_overlaymode_tag = TB_LEGEND_NEW
        if [[ -z ${tb_proc_cmdline_tb_rootfs_ro_get} ]] && \
                [[ "${tb_init_bootargs_cfg_tb_rootfs_ro_get}" == "${TB_TB_ROOTFS_RO_IS_NULL}" ]]; then
            remove_file__func "${tb_init_bootargs_cfg_fpath}"
        fi

        if [[ -n ${tb_proc_cmdline_tb_rootfs_ro_get} ]] && \
                [[ "${tb_init_bootargs_cfg_tb_rootfs_ro_get}" == "${TB_TB_ROOTFS_RO_IS_TRUE}" ]]; then
            remove_file__func "${tb_init_bootargs_cfg_fpath}"
        fi
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
    flag_bootinto_isset="${TB_LEGEND_SAME}"
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

        flag_bootinto_isset="${TB_LEGEND_NEW_PRIORITY}"
    fi
    if [[ -n "${backup_result}" ]]; then
        tb_bootinto_get=$(echo "${backup_result}" | cut -d"=" -f2 | sed 's/\s+//g' | tr -d '\r')

        tb_bootinto_set="${TB_MODE_BACKUPMODE}"
        # tb_bootinto_set_printable="${TB_FG_RED_187}${TB_MODE_BACKUPMODE}${TB_NOCOLOR}"

        flag_bootinto_isset="${TB_LEGEND_NEW_PRIORITY}"
    fi
    if [[ -n "${restore_result}" ]]; then
        tb_bootinto_get=$(echo "${restore_result}" | cut -d"=" -f2 | sed 's/\s+//g' | tr -d '\r')

        tb_bootinto_set="${TB_MODE_RESTOREMODE}"
        # tb_bootinto_set_printable="${TB_FG_GREEN_158}${TB_MODE_RESTOREMODE}${TB_NOCOLOR}"

        flag_bootinto_isset="${TB_LEGEND_NEW_PRIORITY}"
    fi

    #Update printable or remove file
    if [[ "${tb_bootinto_set}" != "${TB_MODE_DISABLED}" ]]; then
        if [[ ${flag_bootinto_isset} != "${TB_LEGEND_SAME}" ]]; then
            tb_bootinto_set_printable="${tb_bootinto_set}: ${TB_LEGEND_NEW_PRIORITY}"
        else
            tb_bootinto_set_printable="${tb_bootinto_set}"
        fi
    else
        #Remove file (if present)
        remove_file__func "${tb_init_bootargs_tmp_fpath}"
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

function remove_file__func() {
    #Input args
    local targetfpath=${1}

    #Remove file
    if [[ -f ${targetfpath} ]]; then
        rm ${targetfpath}
    fi
}



#---SUBROUTINES
trap tb_ctrl_c__sub SIGINT
tb_ctrl_c__sub() {
    exit__func "${TB_EXITCODE_99}" "${TB_NUMOFLINES_2}"
}

mainmenu_extract_info__func() {
    #Remark:
    #   This function will pass values to global variables 'tb_overlaymode_set' and 'tb_overlaymode_set_printable'
    extract_overlaymode_info__func

    #Remark:
    #   This function will pass values to global variables 'tb_bootinto_set' and 'tb_bootinto_set_printable'
    extract_bootinto_info__func
}

tibbo_print_title__sub() {
    print_centered_string_w_leading_trailing_emptylines__func "${TB_TITLE_TIBBO}" "${TB_TABLEWIDTH}" "${TB_BG_ORANGE_215}" "${TB_NUMOFLINES_2}" "${TB_NUMOFLINES_0}"
}

mainmenu_print_title__sub() {
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
    print_leading_trailing_strings_on_opposite_sides__func "${TB_TITLE_TB_INIT_SH}" "${tb_proc_cmdline_tb_overlay_get_printable}" "${TB_TABLEWIDTH}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
}

mainmenu_print_body__sub() {
    print_menuitem__func "${TB_FOURSPACES}" "${TB_ITEMNUM_1}" "${TB_MENUITEM_OVERLAYMODE}" "${tb_overlaymode_set_printable}"
    print_menuitem__func "${TB_FOURSPACES}" "${TB_ITEMNUM_2}" "${TB_MENU} ${TB_MENUITEM_BOOTINTO}" "${tb_bootinto_set_printable}"

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
    if [[ "${tb_overlaymode_tag}" == "${TB_LEGEND_SAME}" ]] && [[ "${flag_bootinto_isset}" == "${TB_LEGEND_SAME}" ]]; then
        return 0;
    fi

    #Print
    print_menuitem__func "${TB_EMPTYSTRING}" "${TB_EMPTYSTRING}" "${TB_REMARKS}" "${TB_EMPTYSTRING}"
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
    #First check if 'tb_overlay' is set in '/proc/cmdline'
    #Remark:
    #   If not set, then it means that overlay feature is not enabled.
    #   In this case, exit subroutine right away.
    if [[ -z "${tb_proc_cmdline_tb_overlay_get}" ]]; then
        return 0;
    fi

    #Update 'tb_rootfs_ro_set' based on 'tb_overlaymode_set' value.
    #Remarks:
    #   1. 
    #   2. In file 'tb_init_bootargs_cfg_fpath' will be validated again, and
    #       if needed, removed in function 'extract_overlaymode_info__func'
    if [[ "${tb_overlaymode_set}" == "${TB_MODE_PERSISTENT}" ]]; then   #currently 'tb_overlaymode_set = TB_MODE_NONPERSISTENT'
        tb_rootfs_ro_set="${TB_TB_ROOTFS_RO_IS_TRUE}"
    else    #currently 'tb_overlaymode_set = TB_MODE_PERSISTENT'
        tb_rootfs_ro_set="${TB_TB_ROOTFS_RO_IS_NULL}"
    fi

    #Write to file
    echo "${tb_rootfs_ro_set}" | tee "${tb_init_bootargs_cfg_fpath}" > /dev/null
}

mainmenu_readdialog_bootinto_config__sub() {
    #Print header
    tibbo_print_title__sub    

    #Print bootinto menutitle
    bootinto_print_title__sub

    #Print body
    bootinto_print_body__sub

    #Print remark
    bootinto_print_remark__sub
}
bootinto_print_title__sub() {
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
    print_leading_trailing_strings_on_opposite_sides__func "${TB_TITLE_BOOTINTO}" "${tb_proc_cmdline_tb_overlay_get_printable}" "${TB_TABLEWIDTH}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
}
bootinto_print_body__sub() {
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
    print_menuitem__func "${TB_FOURSPACES}" "${TB_OPTIONS_B}" "${TB_OPTIONS_BACK}" "${TB_EMPTYSTRING}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
}
bootinto_print_remark__sub() {
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
        #Note: result is passed to global variable 'tb_mychoice'
        mainmenu_readdialog_choice__sub

        #Take action
        mainmenu_readdialog_handler__sub
    done
}



#---EXECUTE
main__sub
