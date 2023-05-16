#!/bin/bash
#---CHARACTER CONSTANTS
TB_DASH="-"
TB_ENTER=$'\x0a'

#---COLOR CONSTANTS
TB_NOCOLOR=$'\e[0;0m'
TB_FG_BLUE_33=$'\e[30;38;5;33m'
TB_FG_BLUE_45=$'\e[30;38;5;45m'
TB_FG_GREEN_158=$'\e[30;38;5;158m'
TB_FG_GREY_246=$'\e[30;38;5;246m'
TB_FG_ORANGE_215=$'\e[30;48;5;215m'
TB_FG_RED_187=$'\e[30;38;5;187m'
TB_FG_YELLOW_33=$'\e[1;33m'

#---DIMENSION CONSTANTS
TB_PERCENT_80=80
TB_TERMWINDOW_WIDTH=$(tput cols)
TB_TABLEWIDTH=$((( TB_TERMWINDOW_WIDTH * TB_PERCENT_80)/100 ))

#---MENU CONSTANTS
TB_MENUITEM_BOOTINTO="Boot into"
TB_MENUITEM_OVERLAYMODE="Overlay-mode"
TB_MODE_BACKUPMODE="backup-mode"
TB_MODE_DISABLED="disabled"
TB_MODE_NORMALMODE="normal-mode"
TB_MODE_RESTOREMODE="restore-mode"
TB_MODE_SAFEMODE="safe-mode"
TB_MODE_NONPERSISTENT="non-persistent"
TB_MODE_PERSISTENT="persistent"

TB_OPTIONS_Q="q"
TB_OPTIONS_QUIT_CTRL_C="${TB_FG_GREY_246}Quit${DOCKER__NOCOLOR} (${TB_FG_GREY_246}Ctrl+C${DOCKER__NOCOLOR})"

TB_READDIALOG_PLEASE_CHOOSE_AN_OPTION="Please choose an option: "

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

#---PATTERN CONSTANTS
TB_PATTERN_TB_BACKUP="tb_backup"
TB_PATTERN_TB_NOBOOT="tb_noboot"
TB_PATTERN_TB_OVERLAY="tb_overlay"
TB_PATTERN_TB_RESTORE="tb_restore"
TB_PATTERN_TB_ROOTFS_RO="tb_rootfs_ro"

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
tb_mychoice="${TB_EMPTYSTRING}"
tb_mychoice_regex="[12q]"

tb_bootinto_current=""
tb_bootinto_current_printable=""
tb_overlaymode_current=""
tb_overlaymode_current_printable=""



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

function get_current_overlaymode__func() {
    #Get 'tb_overlay' value (if present)
    local tb_overlay_val=""
    if [[ -f "${tb_proc_cmdline_fpath}" ]]; then
        tb_overlay_val=$(grep -o "${TB_PATTERN_TB_OVERLAY}.*" "${tb_proc_cmdline_fpath}")
    fi

    #Get 'tb_rootfs_ro' values from 2 files (if present)
    #Remarks:
    #   Regarding tB_rootfs_ro, check both files '/tb_reserve/tb_init_bootargs.cfg' and '/proc/cmdline'
    #   'tb_rootfs_ro_val1' take precedence over 'tb_rootfs_ro_val2'
    local tb_rootfs_ro_val1=""
    if [[ -f "${tb_init_bootargs_cfg_fpath}" ]]; then
        tb_rootfs_ro_val1=$(grep -o "${TB_PATTERN_TB_ROOTFS_RO}.*" "${tb_init_bootargs_cfg_fpath}")
    fi
    local tb_rootfs_ro_val2=""
    if [[ -f "${tb_proc_cmdline_fpath}" ]]; then
        tb_rootfs_ro_val2=$(grep -o "${TB_PATTERN_TB_ROOTFS_RO}.*" "${tb_proc_cmdline_fpath}")
    fi

    #Check whether the current overlay-mode is set to 'persistent' or 'non-persistent'
    tb_overlaymode_current="${TB_MODE_DISABLED}"
    tb_overlaymode_current_printable="${TB_FG_YELLOW_33}${TB_MODE_DISABLED}${TB_NOCOLOR}"
    if [[ -n "${tb_overlay_val}" ]]; then
        if [[ -z ${tb_rootfs_ro_val1} ]]; then
            if [[ -z ${tb_rootfs_ro_val2} ]]; then
                tb_overlaymode_current="${TB_MODE_PERSISTENT}"

                tb_overlaymode_current_printable="${TB_FG_GREEN_158}${TB_MODE_PERSISTENT}${TB_NOCOLOR}"
            else
                tb_overlaymode_current="${TB_MODE_NONPERSISTENT}"

                tb_overlaymode_current_printable="${TB_FG_RED_187}${TB_MODE_NONPERSISTENT}${TB_NOCOLOR}"
            fi
        else
            if [[ "${tb_rootfs_ro_val1}" == "${TB_TB_ROOTFS_RO_IS_NULL}" ]]; then
                tb_overlaymode_current="${TB_MODE_PERSISTENT}"

                tb_overlaymode_current_printable="${TB_FG_GREEN_158}${TB_MODE_PERSISTENT}${TB_NOCOLOR}"
            else
                tb_overlaymode_current="${TB_MODE_NONPERSISTENT}"

                tb_overlaymode_current_printable="${TB_FG_RED_187}${TB_MODE_NONPERSISTENT}${TB_NOCOLOR}"
            fi
        fi
    fi
}

function get_current_printable_bootinto__func() {
    #Get 'tb_backup', 'tb_noboot', tb_restore' values (if present)
    local tb_backup_val=""
    local tb_noboot_val=""
    local tb_restore_val=""
    if [[ -f "${tb_init_bootargs_tmp_fpath}" ]]; then
        tb_backup_val=$(grep -o "${TB_PATTERN_TB_BACKUP}" "${tb_init_bootargs_tmp_fpath}")
        tb_noboot_val=$(grep -o "${TB_PATTERN_TB_NOBOOT}" "${tb_init_bootargs_tmp_fpath}")
        tb_restore_val=$(grep -o "${TB_PATTERN_TB_RESTORE}" "${tb_init_bootargs_tmp_fpath}")
    fi
   
    #Determine whether the current operation-mode
    tb_bootinto_current="${TB_MODE_DISABLED}"
    tb_bootinto_current_printable="${TB_FG_YELLOW_33}${TB_MODE_DISABLED}${TB_NOCOLOR}"

    if [[ -n "${tb_backup_val}" ]]; then
        tb_bootinto_current_printable="${TB_FG_RED_187}${TB_MODE_BACKUPMODE}${TB_NOCOLOR}"

        return 0;
    fi
    if [[ -n "${tb_restore_val}" ]]; then
        tb_bootinto_current_printable="${TB_FG_GREEN_158}${TB_MODE_RESTOREMODE}${TB_NOCOLOR}"

        return 0;
    fi
    if [[ -n "${tb_noboot_val}" ]]; then
        tb_bootinto_current_printable="${TB_FG_YELLOW_33}${TB_MODE_SAFEMODE}${TB_NOCOLOR}"

        return 0;
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
        tcounter=$((tcounter+1))
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
            tcounter=$((tcounter+1))
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
    local optionitem__input=${1}
    local menumsg__input=${2}
    local bracketmsg__input=${3}

    #Update 'ret'
    local printmsg="${TB_FOURSPACES}${optionitem__input}. ${menumsg__input}"
    if [[ -n ${bracketmsg__input} ]]; then
        printmsg+="${TB_FG_GREY_246} (${TB_NOCOLOR}${bracketmsg__input}${TB_FG_GREY_246})${TB_NOCOLOR}"
    fi

    #Output
    echo -e "${printmsg}"
}



#---SUBROUTINES
trap tb_ctrl_c__sub SIGINT
tb_ctrl_c__sub() {
    exit__func "${TB_EXITCODE_99}" "${TB_NUMOFLINES_2}"
}

print_header__sub() {
    local mylocationinfo=$(get_current_printable_datetime__func)

    print_centered_string_w_leading_trailing_emptylines__func "${TB_TITLE_TIBBO}" "${TB_TABLEWIDTH}" "${TB_FG_ORANGE_215}" "${TB_NUMOFLINES_2}" "${TB_NUMOFLINES_0}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
    print_leading_trailing_strings_on_opposite_sides__func "${TB_TITLE_TB_INIT_SH}" "${mylocationinfo}" "${TB_TABLEWIDTH}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
}

print_body_adjustable_menuitems__sub() {
    #Remark:
    #   This function will pass values to global variables 'tb_overlaymode_current' and 'tb_overlaymode_current_printable'
    get_current_overlaymode__func
    print_menuitem__func "${TB_ITEMNUM_1}" "${TB_MENUITEM_OVERLAYMODE}" "${tb_overlaymode_current_printable}"

    #Remark:
    #   This function will pass values to global variables 'tb_bootinto_current' and 'tb_bootinto_current_printable'
    get_current_printable_bootinto__func
    print_menuitem__func "${TB_ITEMNUM_2}" "${TB_MENUITEM_BOOTINTO}" "${tb_bootinto_current_printable}"
}

print_body_fixed_menuitems__sub() {
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
    print_menuitem__func "${TB_OPTIONS_Q}" "${TB_OPTIONS_QUIT_CTRL_C}" "${TB_EMPTYSTRING}"
    print_duplicate_char__func "${TB_DASH}" "${TB_TABLEWIDTH}" "${TB_NOCOLOR}"
}

readdialog_make_a_choice_handler__sub() {
    while true
    do
        #Select an option
        read -N1 -r -p "${TB_READDIALOG_PLEASE_CHOOSE_AN_OPTION}" tb_mychoice
        movedown_and_clean__func "${TB_NUMOFLINES_1}"

        #Only continue if a valid option is selected
        if [[ ! -z ${tb_mychoice} ]]; then
            if [[ ${tb_mychoice} =~ ${tb_mychoice_regex} ]]; then
                # moveDown_and_cleanLines__func "${TB_NUMOFLINES_1}"

                break
            else
                if [[ ${tb_mychoice} == ${TB_ENTER} ]]; then
                    moveup_and_clean__func "${TB_NUMOFLINES_2}"
                else
                    moveup_and_clean__func "${TB_NUMOFLINES_1}"
                fi
            fi
        else
            moveup_and_clean__func "${TB_NUMOFLINES_1}"
        fi
    done
}

readdialog_take_action_handler__sub() {
    #Goto the selected option
    case ${tb_mychoice} in
        1)
            echo "1: in progress"
            ;;
        2)
            echo "2: in progress"
            ;;
        q)
            exit__func "${TB_EXITCODE_99}" "${TB_NUMOFLINES_2}"
            ;;
    esac
}


#---MAIN SUBROUTINE
main__sub() {
    while [[ 1 ]]
    do
        #Print header
        print_header__sub

        #Print body
        print_body_adjustable_menuitems__sub
        print_body_fixed_menuitems__sub

        #Show read-dialog (loop)
        #Note: result is passed to global variable 'tb_mychoice'
        readdialog_make_a_choice_handler__sub

        #Take action
        readdialog_take_action_handler__sub
    done
}



#---EXECUTE
main__sub
