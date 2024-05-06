#!/bin/bash
#---INPUT ARGS
pathlookup_isdisabled=${1}



#---BOOLEAN CONSTANTS
DOCKER__TRUE=true
DOCKER__FALSE=false

DOCKER__N="n"
DOCKER__Y="y"



#---CACHE CONSTANTS
DOCKER__ENTER_CMDLINE_MODE_CACHE_MAX=50  ##maximum number of entries for 'docker_enter_cmdline_mode.sh'
DOCKER__GIT_CACHE_MAX=50    #maximum number of entries for Git-Link and Git-Checkout



#---CHARACTER CONSTANTS
DOCKER__ASTERISK="*"
DOCKER__CARET="^"
DOCKER__COLON=":"
DOCKER__COMMA=","
DOCKER__DASH="-"
DOCKER__DOT="."
DOCKER__HASH="#"
DOCKER__HOOKLEFT="<"
DOCKER__HOOKRIGHT=">"
DOCKER__MINUS="-"
DOCKER__PIPE="|"
DOCKER__PLUS="+"
DOCKER__SEMICOLON=";"
DOCKER__SLASH="/"
DOCKER__UNDERSCORE="_"
DOCKER__DOUBLE_UNDERSCORE="${DOCKER__UNDERSCORE}${DOCKER__UNDERSCORE}"

DOCKER__DOTSLASH="./"
DOCKER__SLASHDOT="/."
DOCKER__SPACEDOT=" ."

DOCKER__ESCAPED_BACKSLASH="\\"
DOCKER__DOUBLE_ESCAPED_BACKSLASH="${DOCKER__ESCAPED_BACKSLASH}${DOCKER__ESCAPED_BACKSLASH}"
DOCKER__TRIPLE_ESCAPED_BACKSLASH="${DOCKER__ESCAPED_BACKSLASH}${DOCKER__ESCAPED_BACKSLASH}${DOCKER__ESCAPED_BACKSLASH}"
DOCKER__QUADRUPLE_ESCAPED_BACKSLASH="${DOCKER__ESCAPED_BACKSLASH}${DOCKER__ESCAPED_BACKSLASH}${DOCKER__ESCAPED_BACKSLASH}${DOCKER__ESCAPED_BACKSLASH}"

DOCKER__ESCAPED_ASTERISK="\*"
DOCKER__ESCAPED_BACKSLASHSPACE="\\ "
DOCKER__ESCAPED_BACKSLASHDOT="\\."
DOCKER__ESCAPED__BACKSLASH_ESCAPE_DOT="\\\."    #used in grep
DOCKER__ESCAPED_DOTBACKSLASH=".\\"
DOCKER__ESCAPED_HOOKLEFT="\<"
DOCKER__ESCAPED_HOOKRIGHT="\>"
DOCKER__ESCAPED_QUOTE="\""
DOCKER__ESCAPED_SLASH="\/"
DOCKER__DOUBLE_ESCAPE_SLASH="${DOCKER__ESCAPED_SLASH}${DOCKER__ESCAPED_SLASH}"

DOCKER__ESCAPED_T="\t"

DOCKER__EMPTYSTRING=""

DOCKER__BACKSPACE=$'\b'
DOCKER__CR="$'\r'"
DOCKER__DEL=$'\x7e'
DOCKER__ENTER=$'\x0a'
DOCKER__ESCAPEKEY=$'\x1b'   #note: this escape key is ^[
DOCKER__TAB=$'\t'

DOCKER__CARET_C="^C"

#Remarks:
#   This cosntant has to be used in combination with 'disable_stty_intr__func' and 'enable_stty_intr__func'
#   For example see script: docker_enter_cmdline_mode.sh
DOCKER__CTRL_C=$'\003'
DOCKER__CTRL_H=\^H



#---COLOR CONSTANTS
DOCKER__NOCOLOR=$'\e[0;0m'
DOCKER__BLINKING=$'\e[5m'
DOCKER__DIM=$'\e[2m'
DOCKER__ITALIC=$'\e[3m'
DOCKER__FG_BORDEAUX=$'\e[30;38;5;198m'
DOCKER__FG_BRIGHTPRUPLE=$'\e[30;38;5;141m'
DOCKER__FG_BRIGHTLIGHTPURPLE=$'\e[30;38;5;147m'
DOCKER__FG_BROWN94=$'\e[30;38;5;94m'
DOCKER__FG_BROWN137=$'\e[30;38;5;137m'
DOCKER__FG_DARKBLUE=$'\e[30;38;5;33m'
DOCKER__FG_RED1=$'\e[30;38;5;1m'
DOCKER__FG_RED9=$'\e[30;38;5;9m'
DOCKER__FG_RED125=$'\e[30;38;5;125m'
DOCKER__FG_ORANGE130=$'\e[30;38;5;130m'
DOCKER__FG_ORANGE131=$'\e[30;38;5;131m'
DOCKER__FG_ORANGE172=$'\e[30;38;5;172m'
DOCKER__FG_ORANGE203=$'\e[30;38;5;203m'
DOCKER__FG_ORANGE208=$'\e[30;38;5;208m'
DOCKER__FG_ORANGE215=$'\e[30;38;5;215m'
DOCKER__FG_ORANGE223=$'\e[30;38;5;223m'
DOCKER__FG_GREEN=$'\e[30;38;5;82m'
DOCKER__FG_GREEN41=$'\e[30;38;5;41m'
DOCKER__FG_GREEN48=$'\e[30;38;5;48m'
DOCKER__FG_GREEN71=$'\e[30;38;5;71m'
DOCKER__FG_GREEN85=$'\e[30;38;5;85m'
DOCKER__FG_GREEN119=$'\e[30;38;5;119m'
DOCKER__FG_GREEN155=$'\e[30;38;5;155m'
DOCKER__FG_GREEN158=$'\e[30;38;5;158m'
DOCKER__FG_LIGHTBLUE=$'\e[30;38;5;45m'
DOCKER__FG_LIGHTGREEN=$'\e[1;32m'
DOCKER__FG_LIGHTGREY=$'\e[30;38;5;246m'
DOCKER__FG_LIGHTGREY_250=$'\e[30;38;5;250m'
DOCKER__FG_LIGHTPINK=$'\e[30;38;5;218m'
DOCKER__FG_LIGHTRED=$'\e[1;31m'
DOCKER__FG_LIGHTSOFTYELLOW=$'\e[30;38;5;229m'
DOCKER__FG_ORANGE=$'\e[30;38;5;215m'
DOCKER__FG_PINK=$'\e[30;38;5;213m'
DOCKER__FG_PURPLE=$'\e[30;38;5;93m'
DOCKER__FG_PURPLERED=$'\e[30;38;5;198m'
DOCKER__FG_RED187=$'\e[30;38;5;187m'
DOCKER__FG_SOFTDARKBLUE=$'\e[30;38;5;38m'
DOCKER__FG_SOFTLIGHTRED=$'\e[30;38;5;131m'
DOCKER__FG_WHITE=$'\e[30;38;5;231m'
DOCKER__FG_YELLOW=$'\e[1;33m'

DOCKER__BG_BRIGHTPRUPLE=$'\e[30;48;5;141m'
DOCKER__BG_BORDEAUX=$'\e[30;48;5;198m'
DOCKER__BG_GREEN85=$'\e[30;48;5;85m'
DOCKER__BG_ORANGE=$'\e[30;48;5;215m'
DOCKER__BG_LIGHTBLUE=$'\e[30;48;5;45m'
DOCKER__BG_LIGHTGREY=$'\e[30;48;5;246m'
DOCKER__BG_LIGHTSOFTYELLOW=$'\e[30;48;5;229m'
DOCKER__BG_SOFTDARKBLUE=$'\e[30;48;5;38m'
DOCKER__BG_WHITE=$'\e[30;48;5;15m'

DOCKER__BLINK=$'\e[5m'



#---COMMAND CONSTANTS
DOCKER__CD="cd"
DOCKER__EXIT="exit"



#---DIMENSION CONSTANTS
DOCKER__TEN=10
DOCKER__NINE=9

DOCKER__PERC_80=80
DOCKER__TERMINALWINDOW_WIDTH=$(tput cols)
DOCKER__TABLEWIDTH=$((( DOCKER__TERMINALWINDOW_WIDTH * DOCKER__PERC_80)/100 ))
DOCKER__TABLEROWS_10=10
DOCKER__TABLEROWS_20=20
DOCKER__TABLECOLS_0=0
DOCKER__TABLECOLS_MAX_7=7



#---DOCKER RELATED CONSTANTS
DOCKER__CFG_NAME1="docker__dockerFile_fpath"

DOCKER__NONE="<none>"
DOCKER__BCK="bck"
DOCKER__PATTERN_EXITED="Exited"
DOCKER__PATTERN_REPOSITORY_TAG="repository:tag"

DOCKER__STATE_RUNNING="Running"
DOCKER__STATE_EXITED="Exited"
DOCKER__STATE_NOTFOUND="NotFound"

DOCKER__MENUTITLE_CONTAINERLIST="${DOCKER__FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}-list"
DOCKER__MENUTITLE_REPOSITORYLIST="${DOCKER__FG_PURPLE}Repository${DOCKER__NOCOLOR}-list"
DOCKER__MENUTITLE_UPDATED_CONTAINERLIST="Updated ${DOCKER__FG_BORDEAUX}Container${DOCKER__NOCOLOR}-list"
DOCKER__MENUTITLE_UPDATED_REPOSITORYLIST="Updated ${DOCKER__FG_BORDEAUX}Image${DOCKER__NOCOLOR}-list"

DOCKER__READINPUTDIALOG_CHOOSE_IMAGEID_FROM_LIST="Choose an ${DOCKER__FG_BORDEAUX}Image-ID${DOCKER__NOCOLOR} (e.g. 0f7478cf7cab): "
DOCKER__READDIALOG_DO_YOU_WISH_TO_CONTINUE_YNR="Do you wish to continue (y/n/r)? "
DOCKER__READDIALOG_DO_YOU_WISH_TO_CONTINUE_YN="Do you wish to continue (y/n)? "

DOCKER__ECHOMSG_NORESULTS_FOUND="${FOUR_SPACES}-:${FG_YELLOW}No results found${DOCKER__NOCOLOR}:-"

DOCKER__ERROR="***${DOCKER__FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}"

DOCKER__ERRMSG_CHOSEN_CONTAINERID_DOESNOT_EXISTS="${DOCKER__ERROR}: Invalid input value "
DOCKER__ERRMSG_CHOSEN_IMAGEID_DOESNOT_EXISTS="${DOCKER__ERROR}: Invalid input value "
DOCKER__ERRMSG_NO_CONTAINERS_FOUND="=:${DOCKER__FG_LIGHTRED}NO CONTAINERS FOUND${DOCKER__NOCOLOR}:="
DOCKER__ERRMSG_NO_EXITED_CONTAINERS_FOUND="=:${DOCKER__FG_LIGHTRED}NO *EXITED* CONTAINERS FOUND${DOCKER__NOCOLOR}:="
DOCKER__ERRMSG_NO_IMAGES_FOUND="=:${DOCKER__FG_LIGHTRED}NO IMAGES FOUND${DOCKER__NOCOLOR}:="

DOCKER__INVALID_OR_NOT_A_DIRECTORY="${DOCKER__ERROR}: Invalid or not a directory"
DOCKER__INVALID_OR_NOT_A_FILE="${DOCKER__ERROR}: Invalid or not a file"

DOCKER__WARNING="***${DOCKER__FG_BORDEAUX}WARNING${DOCKER__NOCOLOR}"

DOCKER__CONFIGNAME____DOCKER__DOCKERFILE_FPATH="docker__dockerFile_fpath"



#---ENV VARIABLES (WHICH ARE USED IN THE DOCKERFILE FILES)
DOCKER__CONTAINER_ENV1="CONTAINER_ENV1"
DOCKER__CONTAINER_ENV2="CONTAINER_ENV2"



#---EXCLUSION CONSTANTS
DOCKER__EXCL_CMD_ARR=()
DOCKER__EXCL_CMD_ARR+=("${DOCKER__CD}")
DOCKER__EXCL_CMD_ARR+=("${DOCKER__EXIT}")



#---EXIT CONSTANTS
DOCKER__EXITCODE_0=0    #no error
DOCKER__EXITCODE_99=99  #an error which tells the device to exit
DOCKER__EXITCODE_130=130    #job was terminted by the owner (not an error)



#---FILE RELATED CONSTANTS
DOCKER__CHECKOUT="checkout"
DOCKER__CACHE="cache"
DOCKER__DOCKERFILE="dockerfile"
DOCKER__LINK="link"
DOCKER__LINKCHECKOUT_PROFILE="linkcheckout_profile"

DOCKER__DIRLIST_REMARKS="${DOCKER__BG_ORANGE}Remarks:${DOCKER__NOCOLOR}\n"
DOCKER__DIRLIST_REMARKS+="${DOCKER__DASH} append ${DOCKER__FG_YELLOW}/${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}to list directory${DOCKER__NOCOLOR} "
DOCKER__DIRLIST_REMARKS+="(e.g. ${DOCKER__FG_LIGHTGREY}/etc${DOCKER__NOCOLOR}${DOCKER__FG_YELLOW}/${DOCKER__NOCOLOR})\n"

DOCKER__DIRLIST_REMARKS+="${DOCKER__DASH} append ${DOCKER__FG_YELLOW}*${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}to copy entire folder${DOCKER__NOCOLOR} "
DOCKER__DIRLIST_REMARKS+="(e.g. ${DOCKER__FG_LIGHTGREY}/etc/${DOCKER__NOCOLOR}${DOCKER__FG_YELLOW}*${DOCKER__NOCOLOR})\n"
DOCKER__DIRLIST_REMARKS+="            ${DOCKER__FG_LIGHTGREY}to copy files & folders based on keyword${DOCKER__NOCOLOR} "
DOCKER__DIRLIST_REMARKS+="(e.g. ${DOCKER__FG_LIGHTGREY}/etc/${DOCKER__NOCOLOR}${DOCKER__FG_YELLOW}rc*${DOCKER__NOCOLOR})\n"

DOCKER__DIRLIST_REMARKS+="${DOCKER__DASH} append ${DOCKER__FG_YELLOW}{${DOCKER__NOCOLOR}.${DOCKER__FG_YELLOW},${DOCKER__NOCOLOR}.${DOCKER__FG_YELLOW}}${DOCKER__NOCOLOR}: "
DOCKER__DIRLIST_REMARKS+="${DOCKER__FG_LIGHTGREY}to copy range of files/folders${DOCKER__NOCOLOR} "
DOCKER__DIRLIST_REMARKS+="(e.g. ${DOCKER__FG_LIGHTGREY}/etc/${DOCKER__NOCOLOR}${DOCKER__FG_YELLOW}{b,m}${DOCKER__NOCOLOR})\n"

DOCKER__DIRLIST_REMARKS+="  (${DOCKER__FG_BORDEAUX}NOTE:${DOCKER__NOCOLOR} ${DOCKER__FG_LIGHTGREY_250}asterisk and range can${DOCKER__NOCOLOR} "
DOCKER__DIRLIST_REMARKS+="${DOCKER__FG_RED1}NOT${DOCKER__NOCOLOR} ${DOCKER__FG_LIGHTGREY_250}be used simultanously${DOCKER__NOCOLOR}!)\n"

DOCKER__DIRLIST_REMARKS+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}ENTER${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}to confirm${DOCKER__NOCOLOR}\n"
DOCKER__DIRLIST_REMARKS+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}TAB${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}auto-complete${DOCKER__NOCOLOR}\n"
DOCKER__DIRLIST_REMARKS+="${DOCKER__DASH} ${DOCKER__FG_YELLOW}Ctrl+C${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}quit${DOCKER__NOCOLOR}"

DOCKER__DIRLIST_REMARKS_EXTENDED="${DOCKER__DIRLIST_REMARKS}\n"
DOCKER__DIRLIST_REMARKS_EXTENDED+="${DOCKER__DASH} ${DOCKER__FG_YELLOW};b${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}back${DOCKER__NOCOLOR}\n"
DOCKER__DIRLIST_REMARKS_EXTENDED+="${DOCKER__DASH} ${DOCKER__FG_YELLOW};c${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}clear${DOCKER__NOCOLOR}\n"
DOCKER__DIRLIST_REMARKS_EXTENDED+="${DOCKER__DASH} ${DOCKER__FG_YELLOW};h${DOCKER__NOCOLOR}: ${DOCKER__FG_LIGHTGREY}home${DOCKER__NOCOLOR}"



#---FUNCTION-KEY CONSTANTS
DOCKER__ENUM_FUNC_F1="F1"
DOCKER__ENUM_FUNC_F2="F2"
DOCKER__ENUM_FUNC_F3="F3"
DOCKER__ENUM_FUNC_F4="F4"
DOCKER__ENUM_FUNC_F5="F5"
DOCKER__ENUM_FUNC_F6="F6"
DOCKER__ENUM_FUNC_F7="F7"
DOCKER__ENUM_FUNC_F8="F8"
DOCKER__ENUM_FUNC_F9="F9"
DOCKER__ENUM_FUNC_F10="F10"
DOCKER__ENUM_FUNC_F12="F12"
DOCKER__FUNC_O="O"
DOCKER__FUNC_P="P"
DOCKER__FUNC_Q="Q"
DOCKER__FUNC_R="R"
DOCKER__FUNC_S="S"
DOCKER__FUNC_SLB="["    #square-left-bracket (SLB)
DOCKER__FUNC_15="15"
DOCKER__FUNC_17="17"
DOCKER__FUNC_18="18"
DOCKER__FUNC_19="19"
DOCKER__FUNC_20="20"
DOCKER__FUNC_21="21"
DOCKER__FUNC_24="24"



#---GIT CONSTANTS
GIT__LAST_COMMIT=1

GIT__PLACEHOLDER_ABBREV_COMMIT_HASH="%h"
GIT__PLACEHOLDER_SUBJECT="%s"

GIT__NOT_TAGGED="<not-tagged>"
GIT__PUSHED="pushed"
GIT__UNPUSHED="unpushed"

GIT__PATTERN_REMOTES="remotes"
GIT__PATTERN_TAGS="tags"
GIT__PATTERN_HEADS="heads"

GIT__CMD_GIT_ADD_DOT="git add ."
GIT__CMD_GIT_BRANCH="git branch"
GIT__CMD_GIT_CHECKOUT="git checkout"
GIT__CMD_GIT_COMMIT_DASH_M="git commit -m"
GIT__CMD_GIT_LS_REMOTE="git ls-remote"
GIT__CMD_GIT_PULL="git pull"
GIT__CMD_GIT_PUSH="git push"
GIT__CMD_GIT_RESET="git reset"
GIT__CMD_GIT_SHOW_REF="git show-ref"
GIT__CMD_GIT_TAG="git tag"

GIT__LOCATION_LOCAL="local"
GIT__LOCATION_REMOTE="remote"

GIT__REMOTES_ORIGIN="remotes/origin"
GIT__REMOTES_ORIGIN_MAIN="${GIT__REMOTES_ORIGIN}/main"

GIT__ERROR_MALFORMED_OBJECT_NAME_TAGS="error: malformed object name tags/"



#---MENU CONSTANTS
DOCKER__MENU="(${DOCKER__FG_LIGHTGREY}Menu${DOCKER__NOCOLOR})"



#---NUMERIC CONSTANTS
DOCKER__COLNUM_1=1
DOCKER__COLNUM_2=2
DOCKER__COLNUM_3=3

DOCKER__LINENUM_0=0
DOCKER__LINENUM_1=1
DOCKER__LINENUM_2=2

DOCKER__MINUS_ONE=-1

DOCKER__NUMOFCHARS_1=1
DOCKER__NUMOFCHARS_2=2
DOCKER__NUMOFCHARS_3=3
DOCKER__NUMOFCHARS_4=4
DOCKER__NUMOFCHARS_5=5
DOCKER__NUMOFCHARS_6=6
DOCKER__NUMOFCHARS_7=7
DOCKER__NUMOFCHARS_8=8
DOCKER__NUMOFCHARS_9=9
DOCKER__NUMOFCHARS_10=10

DOCKER__NUMOFLINES_0=0
DOCKER__NUMOFLINES_1=1
DOCKER__NUMOFLINES_2=2
DOCKER__NUMOFLINES_3=3
DOCKER__NUMOFLINES_4=4
DOCKER__NUMOFLINES_5=5
DOCKER__NUMOFLINES_6=6
DOCKER__NUMOFLINES_7=7
DOCKER__NUMOFLINES_8=8
DOCKER__NUMOFLINES_9=9
DOCKER__NUMOFLINES_10=10
DOCKER__NUMOFLINES_12=12

DOCKER__NUMOFMATCH_0=0
DOCKER__NUMOFMATCH_1=1
DOCKER__NUMOFMATCH_2=2
DOCKER__NUMOFMATCH_3=3
DOCKER__NUMOFMATCH_4=4
DOCKER__NUMOFMATCH_5=5
DOCKER__NUMOFMATCH_6=6
DOCKER__NUMOFMATCH_7=7
DOCKER__NUMOFMATCH_8=8
DOCKER__NUMOFMATCH_9=9
DOCKER__NUMOFMATCH_10=10
DOCKER__NUMOFMATCH_20=20

DOCKER__SPACE_BETWEEN_WORDS=4

DOCKER__TIMEOUT_3=3
DOCKER__TIMEOUT_5=5
DOCKER__TIMEOUT_10=10
DOCKER__TIMEOUT_30=30

DOCKER__TRAP_NUM_2=2



#---OVERLAY CONSTANTS
DOCKER__DISKPARTNAME_OVERLAY="overlay"
DOCKER__DISKPARTNAME_TB_RESERVE="tb_reserve"
DOCKER__DISKPARTNAME_ROOTFS="rootfs"
DOCKER__DISKPARTNAME_REMAINING="remaining"

DOCKER__DISKSIZESETTING="Disksize-setting"
DOCKER__DISKSIZE_0K_IN_BYTES=0
DOCKER__DISKSIZE_1K_IN_BYTES=1024
DOCKER__DISKSIZE_4G_TOTAL_IN_BYTES=3909091328   #found this value via fdisk -l
DOCKER__DISKSIZE_4G_CORRECTION_IN_BYTES=38063309    #determined after boot-image
DOCKER__DISKSIZE_4G_IN_BYTES=$((DOCKER__DISKSIZE_4G_TOTAL_IN_BYTES - DOCKER__DISKSIZE_4G_CORRECTION_IN_BYTES))
DOCKER__DISKSIZE_4G_IN_MBYTES=$((DOCKER__DISKSIZE_4G_IN_BYTES/DOCKER__DISKSIZE_1K_IN_BYTES/DOCKER__DISKSIZE_1K_IN_BYTES))
DOCKER__DISKSIZE_8G_IN_BYTES=$((DOCKER__DISKSIZE_4G_IN_BYTES*2))    #it is assumed that the disksize of ltpp3g2-03 is 2 x DOCKER__DISKSIZE_4G_IN_BYTES
DOCKER__DISKSIZE_8G_IN_MBYTES=$((DOCKER__DISKSIZE_8G_IN_BYTES/DOCKER__DISKSIZE_1K_IN_BYTES/DOCKER__DISKSIZE_1K_IN_BYTES))
DOCKER__DISKSIZE_0X1E0000000="0x1e0000000"

DOCKER__FSTAB_DEV_MMCBLK0P="/dev/mmcblk0p"
DOCKER__FSTAB_DEV_MMCBLK09="/dev/mmcblk0p9"
DOCKER__FSTAB_EXT4="ext4"
DOCKER__FSTAB_TB_RESERVE_DIR="/${DOCKER__DISKPARTNAME_TB_RESERVE}"

DOCKER__OVERLAY_SIZE_DEFAULT=4   #in MB
DOCKER__RESERVED_SIZE_DEFAULT=128   #in MB
DOCKER__ROOTFS_SIZE_DEFAULT=1536    #in MB

DOCKER__PATTERN_EMMC="EMMC"
DOCKER__PATTERN_ROOTFS_0X1E0000000="rootfs 0x1e0000000"
DOCKER__PATTERN_DUMMY="Dummy"
DOCKER__PATTERN_ISP_C_1="fprintf(fd, \"uuid=\${uuid_gpt_%s},\", basename(isp_info.file_header.partition_info[i].file_name));"
DOCKER__PATTERN_ISP_C_2="isp_info.file_header.partition_info[i].file_name,\"rootfs\""
DOCKER__PATTERN_ISP_C_3="// The emmc rootfs partition is set to EXT2 fs, and the partition size is all remaining space."
DOCKER__PATTERN_PENTAGRAM_COMMON_H="\"b_c=console=tty1 console=ttyS0,115200 earlyprintk\0\""
DOCKER__PATTERN_TB_INIT_ADDITIONAL_PARTITIONS="#---ADDITIONAL PARTITIONS"
DOCKER__PATTERN_TB_INIT_MOUNT_ADDITIONAL_PARTITIONS="#---MOUNT ADDITIONAL PARTITIONS"

DOCKER__OVERLAYMODE="Overlay-mode"
DOCKER__OVERLAYMODE_NONPERSISTENT="non-persistent"
DOCKER__OVERLAYMODE_PERSISTENT="persistent"
DOCKER__OVERLAYSETTING="Overlay-setting"
DOCKER__OVERLAYFS_ENABLED="enabled"
DOCKER__OVERLAYFS_DISABLED="disabled"

DOCKER__PENTAGRAM_TB_ROOTFS_RO_TRUE="tb_rootfs_ro=true"

DOCKER__SED_PATTERN_ISP_C_2_WO_ROOTFS="isp_info.file_header.partition_info\[i\].file_name"
DOCKER__SED_PATTERN_ISP_C_2_W_ROOTFS="isp_info.file_header.partition_info\[i\].file_name,\\\"rootfs\\\""
DOCKER__SED_PATTERN_PENTAGRAM_COMMON_H_WO_BACKSLASH0="\\\"b_c=console=tty1 console=ttyS0,115200 earlyprintk"
DOCKER__SED_PATTERN_PENTAGRAM_COMMON_H_W_BACKSLASH0="\\\"b_c=console=tty1 console=ttyS0,115200 earlyprintk\\\0\\\""
DOCKER__SED_TB_INIT_MAIN_DIR="\\/"
DOCKER__SED_TB_INIT_DEV_MMCBLK0P="\\/dev\\/mmcblk0p"
DOCKER__SED_TB_OVERLAY_DEV_MMCBLK0P10="tb_overlay=\\/dev\\/mmcblk0p10"


#---PATH CONSTANTS
DOCKER__DOTDOT="${DOCKER__DOT}${DOCKER__DOT}"
DOCKER__SLASH_DOTDOT_SLASH="${DOCKER__SLASH}${DOCKER__DOTDOT}${DOCKER__SLASH}"
DOCKER__COLOR_SLASH=${DOCKER__FG_LIGHTGREY}${DOCKER__SLASH}${DOCKER__NOCOLOR}
DOCKER__COLOR_DOTDOT="${DOCKER__FG_LIGHTRED}${DOCKER__DOT}${DOCKER__DOT}${DOCKER__NOCOLOR}"
DOCKER__COLOR_SLASH_DOTDOT="${DOCKER__COLOR_SLASH}${DOCKER__COLOR_DOTDOT}"
DOCKER__COLOR_SLASH_DOTDOT_SLASH="${DOCKER__COLOR_SLASH}${DOCKER__COLOR_DOTDOT}${DOCKER__COLOR_SLASH}"
DOCKER__COLOR_SLASH_DOTDOT_SLASH_DOTDOT="${DOCKER__COLOR_SLASH}${DOCKER__COLOR_DOTDOT}${DOCKER__COLOR_SLASH}${DOCKER__COLOR_DOTDOT}"



#---PATTERN CONSTANTS
DOCKER__PATTERN_B_C_IS_CONSOLE="b_c=console"
DOCKER__PATTERN_DOCKER_IO="docker.io"
DOCKER__PATTERN_EMMC_ROOT_IS_ROOT="emmc_root=root"
DOCKER__PATTERN_IF="if"
DOCKER__PATTERN_TOP="top"



#---PERMISSION CONSTANTS
DOCKER__CHMOD_755="755"



#---PHASE CONSTANTS
PHASE_SHOW_REMARKS=0
PHASE_SHOW_READINPUT=1
PHASE_SHOW_KEYINPUT_HANDLER=2



#---PRINT CONSTANTS
DOCKER__THREEDASHES_COLON="---:"
DOCKER__SIXDASHES_COLON="------:"
DOCKER__NINEDASHES_COLON="---------:"

DOCKER__PREV="prev"
DOCKER__NEXT="next"

DOCKER__AS="${DOCKER__FG_YELLOW}AS${DOCKER__NOCOLOR}"
DOCKER__FROM="${DOCKER__FG_YELLOW}FROM${DOCKER__NOCOLOR}"
DOCKER__TO="${DOCKER__FG_YELLOW}TO${DOCKER__NOCOLOR}"

DOCKER__CHECK="${DOCKER__FG_ORANGE}CHECK${DOCKER__NOCOLOR}"
DOCKER__CHECK_LOCAL="${DOCKER__FG_ORANGE}CHECK (LOCAL)${DOCKER__NOCOLOR}"
DOCKER__CHECK_REMOTE="${DOCKER__FG_ORANGE}CHECK (REMOTE)${DOCKER__NOCOLOR}"
DOCKER__COMPLETED="${DOCKER__FG_ORANGE}COMPLETED${DOCKER__NOCOLOR}"
DOCKER__EXECUTED="${DOCKER__FG_ORANGE}EXECUTED${DOCKER__NOCOLOR}"
DOCKER__INFO="${DOCKER__FG_ORANGE}INFO${DOCKER__NOCOLOR}"
DOCKER__INPUT="${DOCKER__FG_YELLOW}INPUT${DOCKER__NOCOLOR}"
DOCKER__NOTICE="${DOCKER__FG_ORANGE131}NOTICE${DOCKER__NOCOLOR}"
DOCKER__PRECHECK="${DOCKER__FG_PURPLERED}PRE${NOCOLOR}${FG_ORANGE}-CHECK:${DOCKER__NOCOLOR}"
DOCKER__LOCATION="${DOCKER__FG_YELLOW}LOCATION${DOCKER__NOCOLOR}"
DOCKER__QUESTION="${DOCKER__FG_YELLOW}QUESTION${DOCKER__NOCOLOR}"
DOCKER__REQUEST="${DOCKER__FG_ORANGE}REQUEST${DOCKER__NOCOLOR}"
DOCKER__RESULT="${DOCKER__FG_ORANGE}RESULT${DOCKER__NOCOLOR}"
DOCKER__START="${DOCKER__FG_ORANGE}START${DOCKER__NOCOLOR}"
DOCKER__STATUS="${DOCKER__FG_ORANGE}STATUS${DOCKER__NOCOLOR}"
DOCKER__STOPPED="${DOCKER__FG_ORANGE}STOPPED${DOCKER__NOCOLOR}"
DOCKER__SUGGESTION="${DOCKER__FG_ORANGE}SUGGESTION${DOCKER__NOCOLOR}"
DOCKER__UPDATE="${DOCKER__FG_ORANGE}UPDATE${DOCKER__NOCOLOR}"

DOCKER__LOCATION_LLOCAL="local"

DOCKER__STATUS_FAILED="${DOCKER__FG_LIGHTRED}FAILED${DOCKER__NOCOLOR}"
DOCKER__STATUS_MISSING="${DOCKER__FG_LIGHTRED}MISSING${DOCKER__NOCOLOR}"
DOCKER__STATUS_OUTOFBOUND="${DOCKER__FG_LIGHTRED}OUT-OF-BOUND${DOCKER__NOCOLOR}"
DOCKER__STATUS_SUCCESSFUL="${DOCKER__FG_GREEN}SUCCESSFUL${DOCKER__NOCOLOR}"

DOCKER__STATUS_LDISABLED="${DOCKER__FG_LIGHTGREY}disabled${DOCKER__NOCOLOR}"
DOCKER__STATUS_LDISABLED_IGNORE="${DOCKER__FG_LIGHTRED}disabled${DOCKER__NOCOLOR} (ignore)"
DOCKER__STATUS_LDONE="${DOCKER__FG_GREEN}done${DOCKER__NOCOLOR}"
DOCKER__STATUS_LFAILED="${DOCKER__FG_LIGHTRED}failed${DOCKER__NOCOLOR}"
DOCKER__STATUS_LINSTALLED="${DOCKER__FG_GREEN}installed${DOCKER__NOCOLOR}"
DOCKER__STATUS_LNOTINSTALLED="${DOCKER__FG_LIGHTRED}not-installed${DOCKER__NOCOLOR}"
DOCKER__STATUS_LPRESENT="${DOCKER__FG_GREEN}present${DOCKER__NOCOLOR}"
DOCKER__STATUS_LNOTPRESENT="${DOCKER__FG_LIGHTRED}not-present${DOCKER__NOCOLOR}"
DOCKER__STATUS_LNOTPRESENT_IGNORE="${DOCKER__FG_LIGHTRED}not-present${DOCKER__NOCOLOR} (ignore)"
DOCKER__STATUS_LVALID="${DOCKER__FG_GREEN}valid${DOCKER__NOCOLOR}"
DOCKER__STATUS_LINVALID="${DOCKER__FG_LIGHTRED}invalid${DOCKER__NOCOLOR}"
DOCKER__STATUS_LNOMATCHFOUND="${DOCKER__FG_LIGHTRED}no-match found${DOCKER__NOCOLOR}"

DOCKER__NO_ACTION_REQUIRED="No action required"



#---READ-INPUT CONSTANTS
DOCKER__ABORT="a"
DOCKER__BACK="b"
DOCKER__CLEAR="c"
DOCKER__FINISH="f"
DOCKER__HOME="h"
DOCKER__NO="n"
DOCKER__OVERWRITE="o"
DOCKER__QUIT="q"
DOCKER__REDO="r"
DOCKER__SKIP="s"
DOCKER__YES="y"

DOCKER__Y_SLASH_N="${DOCKER__Y}/${DOCKER__N}"
DOCKER__Y_SLASH_N_SLASH_B="${DOCKER__Y_SLASH_N}/${DOCKER__BACK}${DOCKER__FG_LIGHTGREY}ack${DOCKER__NOCOLOR}"
DOCKER__Y_SLASH_N_SLASH_H="${DOCKER__Y_SLASH_N}/${DOCKER__HOME}${DOCKER__FG_LIGHTGREY}ome${DOCKER__NOCOLOR}"
DOCKER__Y_SLASH_N_SLASH_O="${DOCKER__Y_SLASH_N}/${DOCKER__OVERWRITE}${DOCKER__FG_LIGHTGREY}verwrite${DOCKER__NOCOLOR}"
DOCKER__Y_SLASH_N_SLASH_Q="${DOCKER__Y_SLASH_N}/${DOCKER__QUIT}${DOCKER__FG_LIGHTGREY}uit${DOCKER__NOCOLOR}"
DOCKER__Y_SLASH_N_SLASH_R="${DOCKER__Y_SLASH_N}/${DOCKER__REDO}${DOCKER__FG_LIGHTGREY}edo${DOCKER__NOCOLOR}"

DOCKER__Y_SLASH_N_SLASH_B_SLASH_Q="${DOCKER__Y_SLASH_N}/"
DOCKER__Y_SLASH_N_SLASH_B_SLASH_Q+="${DOCKER__BACK}${DOCKER__FG_LIGHTGREY}ack${DOCKER__NOCOLOR}/"
DOCKER__Y_SLASH_N_SLASH_B_SLASH_Q+="${DOCKER__QUIT}${DOCKER__FG_LIGHTGREY}uit${DOCKER__NOCOLOR}"

DOCKER__Y_SLASH_N_SLASH_R_SLASH_Q="${DOCKER__Y_SLASH_N}/"
DOCKER__Y_SLASH_N_SLASH_R_SLASH_Q+="${DOCKER__REDO}${DOCKER__FG_LIGHTGREY}edo${DOCKER__NOCOLOR}/"
DOCKER__Y_SLASH_N_SLASH_R_SLASH_Q+="${DOCKER__QUIT}${DOCKER__FG_LIGHTGREY}uit${DOCKER__NOCOLOR}"

DOCKER__Y_SLASH_N_SLASH_O_SLASH_B_SLASH_H="${DOCKER__Y_SLASH_N_SLASH_O}/"
DOCKER__Y_SLASH_N_SLASH_O_SLASH_B_SLASH_H+="${DOCKER__BACK}${DOCKER__FG_LIGHTGREY}ack${DOCKER__NOCOLOR}/"
DOCKER__Y_SLASH_N_SLASH_O_SLASH_B_SLASH_H+="${DOCKER__HOME}${DOCKER__FG_LIGHTGREY}ome${DOCKER__NOCOLOR}"

DOCKER__SEMICOLON_ABORT=";a"
DOCKER__SEMICOLON_BACK=";b"
DOCKER__SEMICOLON_CLEAR=";c"
DOCKER__SEMICOLON_DELETE=";d"
DOCKER__SEMICOLON_FINISH=";f"
DOCKER__SEMICOLON_HOME=";h"
DOCKER__SEMICOLON_REDO=";r"
DOCKER__SEMICOLON_SKIP=";s"

DOCKER__SEMICOLON_ABORT_COLORED="${DOCKER__FG_YELLOW}${DOCKER__SEMICOLON_ABORT}${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}bort${DOCKER__NOCOLOR}"
DOCKER__SEMICOLON_BACK_COLORED="${DOCKER__FG_YELLOW}${DOCKER__SEMICOLON_BACK}${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}ack${DOCKER__NOCOLOR}"
DOCKER__SEMICOLON_CLEAR_COLORED="${DOCKER__FG_YELLOW}${DOCKER__SEMICOLON_CLEAR}${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}lear${DOCKER__NOCOLOR}"
DOCKER__SEMICOLON_FINISH_COLORED="${DOCKER__FG_YELLOW}${DOCKER__SEMICOLON_FINISH}${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}inish${DOCKER__NOCOLOR}"
DOCKER__SEMICOLON_REDO_COLORED="${DOCKER__FG_YELLOW}${DOCKER__SEMICOLON_REDO}${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}edo${DOCKER__NOCOLOR}"
DOCKER__SEMICOLON_SKIP_COLORED="${DOCKER__FG_YELLOW}${DOCKER__SEMICOLON_SKIP}${DOCKER__NOCOLOR}${DOCKER__FG_LIGHTGREY}kip${DOCKER__NOCOLOR}"

DOCKER__COMMA_COLORED="${DOCKER__FG_LIGHTGREY},${DOCKER__NOCOLOR}"
DOCKER__SEMICOLON_BACK_CLEAR_COLORED="${DOCKER__SEMICOLON_BACK_COLORED}${DOCKER__SEMICOLON_CLEAR_COLORED}"
DOCKER__SEMICOLON_CLEAR_ABORT_COLORED="${DOCKER__SEMICOLON_CLEAR_COLORED}${DOCKER__SEMICOLON_ABORT_COLORED}"
DOCKER__SEMICOLON_CLEAR_REDO_ABORT_COLORED="${DOCKER__SEMICOLON_CLEAR_COLORED}${DOCKER__SEMICOLON_REDO_COLORED}${DOCKER__SEMICOLON_ABORT_COLORED}"
DOCKER__SEMICOLON_CLEAR_REDO_FINISH_ABORT_COLORED="${DOCKER__SEMICOLON_CLEAR_COLORED}${DOCKER__SEMICOLON_REDO_COLORED}${DOCKER__SEMICOLON_FINISH_COLORED}${DOCKER__SEMICOLON_ABORT_COLORED}"
DOCKER__SEMICOLON_CLEAR_FINISH_ABORT_COLORED="${DOCKER__SEMICOLON_CLEAR_COLORED}${DOCKER__SEMICOLON_FINISH_COLORED}${DOCKER__SEMICOLON_ABORT_COLORED}"

#---REGEX CONSTANTS
DOCKER__REGEX_YN="[yn]"
DOCKER__REGEX_YNB="[ynb]"
DOCKER__REGEX_YNH="[ynh]"
DOCKER__REGEX_YNQ="[ynq]"
DOCKER__REGEX_YNR="[ynr]"
DOCKER__REGEX_YNBQ="[ynbq]"
DOCKER__REGEX_YNOBH="[ynobh]"
DOCKER__REGEX_0_TO_9="[1-90]"
DOCKER__REGEX_0_TO_9_COMMA_DASH="[1-90,-]"
DOCKER__REGEX_1q="[1q]"
DOCKER__REGEX_1_TO_4q="[1-4q]"
#Note: it is important to escape the dollar-sign ($)
DOCKER__REGEX_DOT_SLASH_EXACTMATCH="^[./]+\$" #^: leading, +\$:trailing
#Note: it is important to escape the backslash (\) and dollar-sign ($)
DOCKER__REGEX_BACKSLASH_DOT_SLASH_EXACTMATCH="^[\\./]+\$"   #^: leading, +\$:trailing



#---SED CONSTANTS
SED__ASTERISK="*"
SED__BACKSLASH="\\\\"
SED__DOT="\\."
SED__SLASH="\\/"

SED__GS=$'\x1D'
SED__RS=$'\x1E'
SED__STX=$'\x02'
SED__ETX=$'\x03'

SED_SUBST_BACKSLASHSPACE="${DOCKER__SEMICOLON}backslashspace${DOCKER__SEMICOLON}"
SED_SUBST_BACKSLASH="${DOCKER__SEMICOLON}backslash${DOCKER__SEMICOLON}"
SED_SUBST_SPACE="${DOCKER__SEMICOLON}space${DOCKER__SEMICOLON}"
SED_SUBST_BACKSLASHT="${DOCKER__SEMICOLON}backslasht${DOCKER__SEMICOLON}"

# SED_SUBST_BACKSLASHSPACE="${SED__STX}backslashspace${SED__ETX}"
# SED_SUBST_BACKSLASH="${SED__STX}backslash${SED__ETX}"
# SED_SUBST_SPACE="${SED__STX}space${SED__ETX}"
# SED_SUBST_BACKSLASHT="${SED__STX}backslasht${SED__ETX}"

SED__DOUBLE_BACKSLASH=${SED__BACKSLASH}${SED__BACKSLASH}
SED__BACKSLASH_DOT="${SED__BACKSLASH}${SED__DOT}"

SED__HTTP="http"
SED__HXXP="hxxp"

SED_LBRACKET_63_SEMICOLON_1H="\\[63;1H"
SED_LEFBRACKET_0_SEMICOLON_0M="\\[0;0m"



#---SET CONSTANTS
DOCKER__REMOVE_ALL="REMOVE-ALL"



#---SPACE CONSTANTS
DOCKER__ZEROSPACE="${SED__STX}" #used in function 'show_msg_w_menuTitle_only_func'
DOCKER__ONESPACE=" "
DOCKER__TWOSPACES=${DOCKER__ONESPACE}${DOCKER__ONESPACE}
DOCKER__THREESPACES=${DOCKER__TWOSPACES}${DOCKER__ONESPACE}
DOCKER__FOURSPACES=${DOCKER__TWOSPACES}${DOCKER__TWOSPACES}
DOCKER__FIVESPACES=${DOCKER__FOURSPACES}${DOCKER__ONESPACE}
DOCKER__SEVENSPACES=${DOCKER__FOURSPACES}${DOCKER__THREESPACES}
DOCKER__EIGHTSPACES=${DOCKER__FOURSPACES}${DOCKER__FOURSPACES}
DOCKER__TENSPACES=${DOCKER__FIVESPACES}${DOCKER__FIVESPACES}



#---CONSTANTS THAT MUST BE LOADED HERE!
#---MENU CONSTANTS
DOCKER__TITLE="TIBBO"
DOCKER__ARROWUP="arrowUp"
DOCKER__ARROWDOWN="arrowDown"
DOCKER__CTRL_C_COLON_QUIT="Ctrl+C: Quit"
DOCKER__EXITING_NOW="Exiting now..."
DOCKER__HORIZONTALLINE="---------------------------------------------------------------------"
DOCKER__LATEST="latest"

DOCKER__PLEASE_CHOOSE_AN_OPTION="Please choose an option: "
DOCKER__QUIT_CTRL_C="${DOCKER__FG_LIGHTGREY}Quit${DOCKER__NOCOLOR} (${DOCKER__FG_LIGHTGREY}Ctrl+C${DOCKER__NOCOLOR})"

DOCKER__FOURSPACES_Y_YES="${DOCKER__FOURSPACES}y. ${DOCKER__FG_LIGHTGREY}Yes${DOCKER__NOCOLOR}"
DOCKER__FOURSPACES_N_NO="${DOCKER__FOURSPACES}n. ${DOCKER__FG_LIGHTGREY}No${DOCKER__NOCOLOR}"
DOCKER__FOURSPACES_B_BACK="${DOCKER__FOURSPACES}b. ${DOCKER__FG_LIGHTGREY}Back${DOCKER__NOCOLOR}"
DOCKER__FOURSPACES_C_CHOOSE="${DOCKER__FOURSPACES}c. ${DOCKER__FG_LIGHTGREY}Choose${DOCKER__NOCOLOR}"
DOCKER__FOURSPACES_Q_QUIT="${DOCKER__FOURSPACES}q. ${DOCKER__FG_LIGHTGREY}Quit${DOCKER__NOCOLOR} (${DOCKER__FG_LIGHTGREY}Ctrl+C${DOCKER__NOCOLOR})"
DOCKER__FOURSPACES_QUIT_CTRL_C="${DOCKER__FOURSPACES}${DOCKER__FG_LIGHTGREY}Quit${DOCKER__NOCOLOR} (${DOCKER__FG_LIGHTGREY}Ctrl+C${DOCKER__NOCOLOR})"

DOCKER__FOURSPACES_F6_CHOOSE="${DOCKER__FOURSPACES}${DOCKER__ENUM_FUNC_F6}: ${DOCKER__FG_LIGHTGREY}Choose${DOCKER__NOCOLOR}"
DOCKER__FOURSPACES_F7_ADD="${DOCKER__FOURSPACES}${DOCKER__ENUM_FUNC_F7}: ${DOCKER__FG_LIGHTGREY}Add${DOCKER__NOCOLOR}"
DOCKER__FOURSPACES_F8_DEL="${DOCKER__FOURSPACES}${DOCKER__ENUM_FUNC_F8}: ${DOCKER__FG_LIGHTGREY}Del${DOCKER__NOCOLOR}"
DOCKER__FOURSPACES_F8_DEL+=" (${DOCKER__FG_LIGHTGREY}e.g.${DOCKER__NOCOLOR}, ${DOCKER__FG_LIGHTGREY}1,3,4${DOCKER__NOCOLOR}, ${DOCKER__FG_LIGHTGREY}2${DOCKER__NOCOLOR}, ${DOCKER__FG_LIGHTGREY}5-0${DOCKER__NOCOLOR})"
DOCKER__FOURSPACES_F12_QUIT="${DOCKER__FOURSPACES}${DOCKER__ENUM_FUNC_F12}: ${DOCKER__FG_LIGHTGREY}Quit${DOCKER__NOCOLOR} (${DOCKER__FG_LIGHTGREY}Ctrl+C${DOCKER__NOCOLOR})"

DOCKER__FOURSPACES_F1_CHOOSE_LINK="${DOCKER__FOURSPACES}${DOCKER__ENUM_FUNC_F1}: ${DOCKER__FG_LIGHTGREY}Choose link${DOCKER__NOCOLOR}"
DOCKER__FOURSPACES_F2_CHOOSE_CHECKOUT="${DOCKER__FOURSPACES}${DOCKER__ENUM_FUNC_F2}: ${DOCKER__FG_LIGHTGREY}Choose checkout${DOCKER__NOCOLOR}"
DOCKER__FOURSPACES_F5_ABORT="${DOCKER__FOURSPACES}${DOCKER__ENUM_FUNC_F5}: ${DOCKER__FG_LIGHTGREY}Abort${DOCKER__NOCOLOR}"
DOCKER__FOURSPACES_F3_CONFIRM="${DOCKER__FOURSPACES}${DOCKER__ENUM_FUNC_F3}: ${DOCKER__FG_LIGHTGREEN}Confirm${DOCKER__NOCOLOR}"

DOCKER__ONESPACE_PREV="${DOCKER__ONESPACE}${DOCKER__HOOKLEFT} ${DOCKER__FG_LIGHTGREY}${DOCKER__PREV}${DOCKER__NOCOLOR}"
DOCKER__ONESPACE_NEXT="${DOCKER__FG_LIGHTGREY}${DOCKER__NEXT}${DOCKER__NOCOLOR} ${DOCKER__HOOKRIGHT}${DOCKER__ONESPACE}"

DOCKER__CONFIGURED="(cfg)"



#---WEB CONSTANTS
DOCKER__HTTP_200=200



#---VARIABLES
docker__docker_login_cmd="docker login"
docker__docker_pull_cmd="docker pull"
docker__docker_push_cmd="docker push"
docker__images_cmd="docker images"
docker__ps_a_cmd="docker ps -a"

docker__images_repoColNo=1
docker__images_tagColNo=2
docker__images_IDColNo=3
docker__ps_a_containerIdColno=1


#---EXTERN CONSTANTS & VARIABLES
#---------------------------------------------------------------------
#***WARNING***
#   Extern variables can be called from anywhere. 
#   Therefore, use it with caution.
#---------------------------------------------------------------------
extern__req="${DOCKER__EMPTYSTRING}"
extern__ret="${DOCKER__EMPTYSTRING}"



#---SPECIFAL FUNCTIONS
function erase_ctrl_h__func() {
    stty erase ${DOCKER__CTRL_H}
}

function cursor_hide__func() {
    printf '\e[?25l'
}
function cursor_show__func() {
    printf '\e[?25h'
}

function enable_expansion__func() {
    set +f
}
function disable_expansion__func() {
    set -f
}

function enable_keyboard_input__func() {
    stty echo
}
function disable_keyboard_input__func() {
    stty -echo
}

function enable_ctrl_c__func() {
    trap ${DOCKER__TRAP_NUM_2}

    trap docker__ctrl_c__sub SIGINT
}

function disable_ctrl_c__func() {
    trap '' ${DOCKER__TRAP_NUM_2}
}

function enable_stty_intr__func() {
    stty sane

    #This function MUST be executed
    #Note: 
    #   If this function is NOT executed, when pressing <backspace>
    #   MobaXterm sends (^H).
    erase_ctrl_h__func
}

function disable_stty_intr__func() {
    stty intr ''
}

function unset_extern_variables__func() {
    unset extern__req
    unset extern__ret
}

function cmd_exec__func() {
    #Input args
    cmd=${1}

    #Define local variable
    currUser=$(whoami)

    #Exec command
    if [[ ${currUser} != "root" ]]; then
        sudo ${cmd}
    else
        ${cmd}
    fi
}

function exit__func() {
    #Input args
    exitCode__input=${1}
    numOfLines__input=${2}

    #Turn-on Expansion
    enable_expansion__func
    
    #Show mouse cursor
    cursor_show__func

    #Enable keyboard-input
    enable_keyboard_input__func

    #Unset extern variable
    unset_extern_variables__func

    #Move-down cursor
    moveDown_and_cleanLines__func "${numOfLines__input}"

    #Exit with code
    exit ${exitCode__input}
}

function goto__func() {
	#Input args
    LABEL=$1
	
	#Define Command line
    cmd=$(sed -n "/$LABEL:/{:a;n;p;ba;};" $0 | grep -v ':$')
	
	#Execute Command line
    eval "${cmd}"
	
	#Exit Function
    exit
}

function load_tibbo_title__func() {
    #Input args
    local prepend_numOfLines__input=${1}

    #Print
    show_header__func "${DOCKER__TITLE}" "${DOCKER__TABLEWIDTH}" "${DOCKER__BG_ORANGE}" "${prepend_numOfLines__input}" "${DOCKER__NUMOFLINES_0}"
}

function press_any_key__func() {
    #Input args
    local timeout__input=${1}
    local prepend_numOfLines__input=${2}
    local append_numOfLines__input=${3}

	#Initialize variables
	local keyInput=""
	local tCounter=0
    local timeout=${timeout__input}
    if [[ -z ${timeout} ]]; then
        timeout=${DOCKER__TIMEOUT_10}
    fi
    local prepend_numOfLines=${prepend_numOfLines__input}
    if [[ -z ${prepend_numOfLines} ]]; then
        prepend_numOfLines=${DOCKER__NUMOFLINES_1}
    fi
    local append_numOfLines=${append_numOfLines__input}
    if [[ -z ${append_numOfLines} ]]; then
        append_numOfLines=${DOCKER__NUMOFLINES_1}
    fi

	#Show Press Any Key message with count-down
	moveDown_and_cleanLines__func "${prepend_numOfLines}"
	while [[ ${tCounter} -le ${timeout} ]];
	do
		delta_tcounter=$(( ${timeout} - ${tCounter} ))

		echo -e "\rPress (a)bort or any key to continue... (${delta_tcounter}) \c"
		read -N1 -t1 -rs keyInput

		if [[ ! -z "${keyInput}" ]]; then
			if [[ "${keyInput}" == "a" ]] || [[ "${keyInput}" == "A" ]]; then
				exit
			else
				break
			fi
		fi
		
		tCounter=$((tCounter+1))
	done
	moveDown_and_cleanLines__func "${append_numOfLines}"
}

function confirmation_w_timer__func() {
    #Input args
    local confirmation_choices__input=${1}
    local confirmation_regEx__input=${2}
    local timeout__input=${3}
    local prepend_numOfLines__input=${4}
    local append_numOfLines__input=${5}

    #Define constants
    local ECHOMSG_DO_YOU_WISH_TO_CONTINUE="Do you wish to continue"

    #Define regEx
    local regEx="${confirmation_regEx__input}"

    #Initialization
	local ret="${DOCKER__EMPTYSTRING}"
	local tCounter=0

    local timeout=${timeout__input}
    if [[ -z ${timeout} ]]; then
        timeout=${DOCKER__TIMEOUT_10}
    fi

    local prepend_numOfLines=${prepend_numOfLines__input}
    if [[ -z ${prepend_numOfLines} ]]; then
        prepend_numOfLines=${DOCKER__NUMOFLINES_1}
    fi
    local append_numOfLines=${append_numOfLines__input}
    if [[ -z ${append_numOfLines} ]]; then
        append_numOfLines=${DOCKER__NUMOFLINES_1}
    fi
    local after_confirmation_append_numOfLines=$((append_numOfLines - 1))

    #Hide cursor
    # cursor_hide__func

	#Show Press Any Key message with count-down
	moveDown_and_cleanLines__func "${prepend_numOfLines}"
	while [[ ${tCounter} -le ${timeout} ]];
	do
		delta_tcounter=$(( ${timeout} - ${tCounter} ))

		read -N1 -t1 -r -p "${ECHOMSG_DO_YOU_WISH_TO_CONTINUE} (${confirmation_choices__input}) (${delta_tcounter})? " ret
		if [[ ! -z ${ret} ]]; then
            if [[ ${ret} == ${DOCKER__ENTER} ]]; then
                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
            else
                if [[ ${ret} =~ ${regEx} ]]; then
                    moveDown_and_cleanLines__func "${after_confirmation_append_numOfLines}"

                    break
                else
                    moveToBeginning_and_cleanLine__func

                    # moveUp_and_cleanLines__func "${prepend_numOfLines__input}"
                fi
			fi
        else
            moveToBeginning_and_cleanLine__func
		fi
		
		tCounter=$((tCounter+1))
	done
	moveDown_and_cleanLines__func "${append_numOfLines}"

    #Check if 'ret' is an Empty String.
    #If true, then set 'ret = n'
    if [[ -z ${ret} ]]; then
        ret="${DOCKER__N}"
    fi

    #Hide cursor
    # cursor_show__func

    #Update 'extern__ret'
    #Remark:
    #   This extern variable can be called from anywhere. Therefore, use it with caution.
    extern__ret=${ret}
}



#---ARRAY FUNCTIONS
# function array_find_and_move_element_toTop__func() {
#     #Input args
#     local pattern__input=${1}
#     shift
#     local arr__input=("$@")

#     #Define variables
#     local arr_leftOfMatch=()
#     local arr_rightOfMatch=()
#     local arr_new=()

#     local arrLen=0
#     local arrIndex_max=0
#     local index_match=0
#     local lineNum_match=0
#     local numOfElements_leftOfMatch=0
#     local startIndex_rightOfMatch=0

#     #Get length of array 'arr__input'
#     local arrLen=${#arr__input[@]}
#     local arrIndex_max=$((arrLen - 1))

#     #Check if there is an EXACT MATCH of 'pattern__input' within 'arr__input'.
#     #If true, then get the array-index.
#     #1. Get the line-number:
#     lineNum_match=`echo "${arr__input[@]}" | xargs -n1 | grep -nw "${pattern__input}" | cut -d"${DOCKER__COLON}" -f1`

#     #Check if 'lineNum_match = 0'.
#     #If true, then exit function, because no match was found.
#     if [[ ${lineNum_match} -eq ${DOCKER__NUMOFMATCH_0} ]]; then
#         echo "${arr__input[@]}"

#         return
#     fi

#     #2. Get the array-index:
#     index_match=$((lineNum_match - 1))

#     #Check if 'index_match = 0'.
#     #If true, then exit function, because 'pattern__input' is already on the top.
#     if [[ ${index_match} -eq ${DOCKER__NUMOFMATCH_0} ]]; then
#         echo "${arr__input[@]}"

#         return
#     fi

#     #Get the 'numOfElements_leftOfMatch' and 'startIndex_rightOfMatch'
#     numOfElements_leftOfMatch=$((lineNum_match - 1))
#     startIndex_rightOfMatch=$((index_match + 1))

#     #Get 'arr_leftOfMatch'
#     arr_leftOfMatch=("${arr__input[@]:0:numOfElements_leftOfMatch}")

#     #Check if 'startIndex_rightOfMatch <= arrIndex_max'
#     #If false, then no need to get 'arr_rightOfMatch'
#     if [[ ${startIndex_rightOfMatch} -le ${arrIndex_max} ]]; then
#         #Get 'arr_rightOfMatch'
#         arr_rightOfMatch=("${arr__input[@]:startIndex_rightOfMatch}")
#     fi

#     #Compose 'arr_new'
#     arr_new[0]=${arr__input[index_match]}
#     arr_new+=(${arr_leftOfMatch[@]})
#     arr_new+=(${arr_rightOfMatch[@]})

#     #Output
#     echo "${arr_new[@]}"
# }

function checkFor_leading_partialMatch_of_pattern_within_array__func() {
    #Turn-off Expansion
    disable_expansion__func

    #Input Args
    local pattern__input="${1}"
    shift
    local arr__input=("$@")

    #Define variables
    local arrItem="${DOCKER__EMPTYSTRING}"
    local isFound="${DOCKER__EMPTYSTRING}"
    local ret="false"

    #Loop thru array
    for arrItem in "${arr__input[@]}"
    do   
        isFound=`echo "${pattern__input}" | grep "^${arrItem}"`
        if [[ ! -z "${isFound}" ]]; then
            ret="true"

            break
        fi
    done

    #Output
    echo "${ret}"
}

function array_count_numOf_elements__func() {
    #Input args
    local dataArr__input=("$@")

    #Check number of elements WITHOUT empty lines!!!
    local ret=`printf "%s\n" ${dataArr__input[@]} | grep -c '[^[:space:]]'`

    #Output
    echo "${ret}"
}

function array_find_and_move_element_toTop__func() {
    #Input args
    local pattern__input=${1}
    shift
    local arr__input=("$@")

    #Define variables
    local arr_leftOfMatch=()
    local arr_rightOfMatch=()
    local arr_new=()

    local arrLen=0
    local arrIndex_max=0
    local index_match=0
    local lineNum_match=0
    local numOfElements_leftOfMatch=0
    local startIndex_rightOfMatch=0

    #Get length of array 'arr__input'
    local arrLen=${#arr__input[@]}
    local arrIndex_max=$((arrLen - 1))

    #Check if there is match of 'pattern__input' within 'arr__input'.
    #If true, then get the array-index.
    #1. Get the line-number:
    lineNum_match=`echo "${arr__input[@]}" | xargs -n1 | grep -n "${pattern__input}" | cut -d":" -f1`

    #Check if 'lineNum_match = 0'.
    #If true, then exit function, because no match was found.
    if [[ ${lineNum_match} -eq ${DOCKER__NUMOFMATCH_0} ]]; then
        echo "${arr__input[@]}"

        return
    fi

    #2. Get the array-index:
    index_match=$((lineNum_match - 1))

    #Check if 'index_match = 0'.
    #If true, then exit function, because 'pattern__input' is already on the top.
    if [[ ${index_match} -eq ${DOCKER__NUMOFMATCH_0} ]]; then
        echo "${arr__input[@]}"

        return
    fi

    #Get the 'numOfElements_leftOfMatch' and 'startIndex_rightOfMatch'
    numOfElements_leftOfMatch=$((lineNum_match - 1))
    startIndex_rightOfMatch=$((index_match + 1))

    #Get 'arr_leftOfMatch'
    arr_leftOfMatch=("${arr__input[@]:0:numOfElements_leftOfMatch}")

    #Check if 'startIndex_rightOfMatch <= arrIndex_max'
    #If false, then no need to get 'arr_rightOfMatch'
    if [[ ${startIndex_rightOfMatch} -le ${arrIndex_max} ]]; then
        #Get 'arr_rightOfMatch'
        arr_rightOfMatch=("${arr__input[@]:startIndex_rightOfMatch}")
    fi

    #Compose 'arr_new'
    arr_new[0]=${arr__input[index_match]}
    arr_new+=(${arr_leftOfMatch[@]})
    arr_new+=(${arr_rightOfMatch[@]})

    #Output
    echo "${arr_new[@]}"
}

function array_subst_string__func() {
    #Input args
    local oldString__input=${1}
    local newSubString__input=${2}
    shift
    shift
    local dataArr__input=("$@")

    #Replace all 'oldString__input' with 'newSubString__input'
    local ret=`printf '%s\n' "${dataArr__input[@]}" | sed "s/${oldString__input}/${newSubString__input}/g"`

    #Output
    #Note: the output is an array-STRING!!!
    echo "${ret[@]}"
}

function checkForMatch_of_pattern_within_1darray__func() {
    #Input args
    local pattern__input=${1}
    shift
    local dataArr__input=("$@")

    #Loop thru array-elements and find a match
    local dataArrItem="${DOCKER__EMPTYSTRING}"
    local ret=false
    for dataArrItem in "${dataArr__input[@]}"
    do
        if [[ "${pattern__input}" == "${dataArrItem}" ]]; then
            ret=true

            break
        fi
    done

    #Output
    echo "${ret}"
}

function checkForExactMatch_of_pattern_within_2darray__func() {
    #Input args
    local pattern__input=${1}
    local colNum__input=${2}
    local delimiterchar__input=${3}
    shift
    shift
    shift
    local dataArr__input=("$@")
    
    #Define variables
    local dataArrItem="${DOCKER__EMPTYSTRING}"
    local colValue="${DOCKER__EMPTYSTRING}"
    local ret=false

    #Loop thru array-elements and find a match
    for dataArrItem in "${dataArr__input[@]}"
    do
        #Get value of the 1st column
        colValue=$(echo "${dataArrItem}" | cut -d"${delimiterchar__input}" -f"${colNum__input}")
        if [[ "${pattern__input}" == "${colValue}" ]]; then
            ret=true

            break
        fi
    done

    #Output
    echo "${ret}"
}

function combine_two_arrays_of_same_length_and_writeTo_file__func() {
    #Input args
    local delimiterChar__input=${1}
    local delimiterColor__input=${2}
    local outputFpath__input=${3}   #write the output to this file
    local flag_count_emptyLines_isEnabled__input=${4}
    shift
    shift
    shift
    shift
    #Remark:
    #   When passing two arrays into this function,...
    #   These two arrays are combined into one array.
    #Example:
    #   arr1=("one" "two" "three")
    #   arr2=("four" "five" "six")
    #   arrTot__input=("one" "two" "three" "four" "five" "six")
    local arrTot__input=("$@")


    #Remove file (if present)
    if [[ -f ${outputFpath__input} ]]; then
        rm ${outputFpath__input}
    fi


    #Get length of 'arrTot__input'
    local arrTotLen=${#arrTot__input[@]}

    #Check if flag is set to 'false'
    if [[ ${flag_count_emptyLines_isEnabled__input} == false ]]; then
        #Recalculate array-length (without empty lines)
        arrTotLen=`array_count_numOf_elements__func "${arrTot__input[@]}"`
    fi
    local arrTotLen_half=$((arrTotLen/2))


    #Initialization
    local arr1=()
    local arr2=()
    local count=0
    local index=0

    #Split 'arrTot__input' into two arrays
    # #First half:
    # local arr1=(`echo "${arrTot__input[@]:0:$((${#arrTot__input[@]} / 2 ))}"`)
    # #Second half:
    # local arr2=(`echo "${arrTot__input[@]:$((${#arrTot__input[@]} / 2 ))}"`)
    for arrTotItem in "${arrTot__input[@]}"
    do
        #Add 'arrTotItem' to 'arr1/arr2'
        if [[ ${count} -lt ${arrTotLen_half} ]]; then
            arr1[index]="${arrTotItem}"
        else
            arr2[index]="${arrTotItem}"
        fi

        #Incremenet counter
        count=$((count + 1))

        #Handle 'index'
        if [[ ${count} -eq ${arrTotLen_half} ]]; then
            #Reset index
            index=0
        else
            #Increment index
            index=$((index + 1))
        fi
    done


    #Get array-lengths
    local arr1Len=${#arr1[@]}
    local arr2Len=${#arr2[@]}

    #Check if 'arr1Len != arr2Len'
    if [[ ${arr1Len} -ne ${arr2Len} ]]; then
        echo "${ret[@]}"

        return
    fi


    #Check if 'delimiterColor__input' is an Empty String
    if [[ -z "${delimiterChar__input}" ]]; then
        delimiterChar__input=${DOCKER__COLON}
    fi


    #Combine arrays
    for ((i=0; i<${arr1Len}; i++ ))
    do 
        if [[ -z "${delimiterColor__input}" ]]; then
            echo "${arr1[${i}]}${delimiterChar__input}${arr2[${i}]}" >> \
                        ${outputFpath__input}
        else
            echo "${arr1[${i}]}${delimiterColor__input}${delimiterChar__input}${DOCKER__NOCOLOR}${arr2[${i}]}" >> \
                        ${outputFpath__input}
        fi
    done
}

function show_array_w_menuTitle_w_confirmation__func() {
    #Input args
    local menuTitle__input=${1}
    local confirmation_choices__input=${2}
    local confirmation_regEx__input=${3}
    local prepend_numOfLines__input=${4}
    local confirmation_timeout__input=${5}
    local confirmation_prepend_numOfLines__input=${6}
    local confirmation_append_numOfLines__input=${7}
    shift
    shift
    shift
    shift
    shift
    shift
    shift
    local dataArr__input=("$@")

    #Move-down cursor
    moveDown_and_cleanLines__func "${prepend_numOfLines__input}"

    #Print horizontal line
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Print menu-title
    show_centered_string__func "${menuTitle__input}" "${DOCKER__TABLEWIDTH}"

    #Print horizontal line
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Print message
    for dataArrItem in "${dataArr__input[@]}"
    do
        echo -e "${DOCKER__FOURSPACES}${dataArrItem}"
    done

    #Move-down and clean 1 line
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    #Print horizontal line
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Show press-any-key dialog
    confirmation_w_timer__func "${confirmation_choices__input}" \
                        "${confirmation_regEx__input}" \
                        "${confirmation_timeout__input}" \
                        "${confirmation_prepend_numOfLines__input}" \
                        "${confirmation_append_numOfLines__input}"
}

#---BC RELATED FUNCTIONS
function bc_substract_x_from_y() {
    #Input args
    local x=${1}
    local y=${2}

    #Substract x from y
    local ret=$(echo ${x} - ${y} | bc)

    #Output
    echo "${ret}"

    return 0;
}

function bc_is_x_greaterthan_zero() {
    #Input args
    local x=${1}

    #Define variables
    local ret=false

    #Check if value 'x > 0'
    if [[ $(bc <<< "${x} > 0") -gt 0 ]]; then
        ret=true
    fi

    #Output
    echo "${ret}"

    return 0;
}


#---CONTAINER RELATED FUNCTIONS
function container_exec_cmd_and_receive_output__func() {
    #Input args
    local containerid__arg="${1}"
    local cmd__arg="${2}"
    local outputfpath__arg="${3}"

    local ret_raw=${DOCKER__EMPTYSTRING}
    local ret=${DOCKER__EMPTYSTRING}

    #Execute command and capture output
    if [[ -n ${containerid__arg} ]]; then
        ret_raw=$(docker exec -t "${containerid__arg}" /bin/bash -c "${cmd__arg}")

        #Remove trailing carriage returns '\r'
        ret=$(printf "%s" "${ret_raw}" | tr -d '\r')
    else
        ret=$(eval "${cmd__arg}")
    fi

    #Get exitcode
    exitcode=$?
    if [[ ${exitcode} -ne 0 ]]; then    #an error occurred
        ret=${DOCKER__EMPTYSTRING}
    fi

    #OUTPUT
    echo "${ret}" > "${outputfpath__arg}"
}


#---DOCKER RELATED FUNCTIONS
function check_containerID_state__func() {
    #Input args
    local containerid__input=${1}

    #Check if 'containterID__input' is running
    local stdOutput=`${docker__ps_a_cmd} --format "table {{.ID}}|{{.Status}}" | grep -w "${containerid__input}"`
    if [[ -z ${stdOutput} ]]; then  #contains NO data
        echo "${DOCKER__STATE_NOTFOUND}"
    else    #contains data
        local stdOutput2=`echo ${stdOutput} | grep -w "${DOCKER__PATTERN_EXITED}"`
        if [[ ! -z ${stdOutput2} ]]; then   #contains data
            echo "${DOCKER__STATE_EXITED}"
        else    #contains NO data
            echo "${DOCKER__STATE_RUNNING}"
        fi
    fi
}

function checkIf_isRunning_inside_container__func() {
    #Define contants
    local PATTERN_DOCKER="docker"

    #Check if you are currently inside a docker container
    local ret=false
    if [[ -f "${docker__dotdockerenv__fpath}" ]]; then
        ret=true
    fi

    #Output
    echo "${ret}"
}

function checkIf_repoTag_isUniq__func() {
    #Input args
    local repoName__input=${1}
    local tag__input=${2}

    #Define variables
    local dataArr=()
    local dataArr_item="${DOCKER__EMPTYSTRING}"
    local stdOutput1="${DOCKER__EMPTYSTRING}"
    local stdOutput2="${DOCKER__EMPTYSTRING}"

    #Write 'docker images' command output to array
    readarray dataArr <<< $(docker images)

    #Check if repository:tag is unique
    local ret=true

    for dataArr_item in "${dataArr[@]}"
    do                                                      
        stdOutput1=`echo ${dataArr_item} | awk '{print $1}' | grep -w "${repoName__input}"`
        if [[ ! -z ${stdOutput1} ]]; then
            stdOutput2=`echo ${dataArr_item} | awk '{print $2}' | grep -w "${tag__input}"`
            if [[ ! -z ${stdOutput2} ]]; then
                ret=false

                break
            fi
        fi                                             
    done

    #Output
    echo "${ret}"
}

function createAndWrite_data_to_cacheFiles_ifNotExist__func() {
    #Input args
    local link_cache_fpath__input=${1}
    local checkout_cache_fpath__input=${2}
    local linkCheckoutProfile_cache_Fpath=${3}
    local dockerfile_fpath__input=${4}
    local exported_env_var_fpath__input=${5}

    #Get the git-link from file 'exported_env_var_fpath__input'
    local git_link=`retrieve_env_var_link_from_file__func "${dockerfile_fpath__input}" "${exported_env_var_fpath__input}"`

    #Get the git-checkout from file 'exported_env_var_fpath__input'
    local git_checkout=`retrieve_env_var_checkout_from_file__func "${dockerfile_fpath__input}" "${exported_env_var_fpath__input}"`
    
    #Check if file 'link_cache_fpath__input' is exists
    #Renark:
    #   If not present, then:
    #       Write the retrieved git-link to cache 'dockerfile_fpath__input'
    if [[ ! -f ${link_cache_fpath__input} ]]; then
        if [[ ! -z ${git_link} ]]; then
            echo ${git_link} > ${link_cache_fpath__input}
        else
            touch ${link_cache_fpath__input}
        fi
    fi

    #Check if file 'checkout_cache_fpath__input' is exists
    #Renark:
    #   If not present, then:
    #       Write the retrieved git-checkout to cache 'dockerfile_fpath__input'
    if [[ ! -f ${checkout_cache_fpath__input} ]]; then
        if [[ ! -z ${git_checkout} ]]; then
            echo ${git_checkout} > ${checkout_cache_fpath__input}
        else
            touch ${checkout_cache_fpath__input}
        fi
    fi

    #Check if file 'checkout_cache_fpath__input' is exists
    #Renark:
    #   If not present, then:
    #       Write the retrieved git-link & checkout to cache 'dockerfile_fpath__input'
    if [[ ! -f ${linkCheckoutProfile_cache_Fpath} ]]; then
        if [[ ! -z ${git_link} ]] && [[ ! -z ${git_checkout} ]]; then
            echo "${git_link}${DOCKER__COLON}${git_checkout}" > ${linkCheckoutProfile_cache_Fpath}
        else
            touch ${linkCheckoutProfile_cache_Fpath}
        fi
    fi
}

function generate_cache_filenames_basedOn_specified_repositoryTag__func() {
    #Input args
    local cache_dir__input=${1}
    local dockerfile_fpath__input=${2}

    #Check if directory exist
    #If false, then create directory
    if [[ ! -d ${cache_dir__input} ]]; then
        mkdir -p ${cache_dir__input}
    fi

    #Get repository:tag from file
    if [[ ! -f ${dockerfile_fpath__input} ]]; then
        return
    fi

    #Get the repository:tag from 'dockerfile_fpath__input'
    local dockerfile_fpath_repositoryTag=`retrieve_repositoryTag_from_dockerfile__func "${dockerfile_fpath__input}"`

    #Replace ':' with '_-_'
    local repositoryTag_subst=`echo "${dockerfile_fpath_repositoryTag}" | sed "s/${DOCKER__COLON}/${DOCKER__DOUBLE_UNDERSCORE}/g"`

    #Create cache-filenames
    local link_cache_filename="${repositoryTag_subst}${DOCKER__DOUBLE_UNDERSCORE}${DOCKER__LINK}.${DOCKER__CACHE}"
    local checkout_cache_filename="${repositoryTag_subst}${DOCKER__DOUBLE_UNDERSCORE}${DOCKER__CHECKOUT}.${DOCKER__CACHE}"
    local linkCheckoutProfile_cache_filename="${repositoryTag_subst}${DOCKER__DOUBLE_UNDERSCORE}${DOCKER__LINKCHECKOUT_PROFILE}.${DOCKER__CACHE}"

    #Create cache-fullpaths
    local link_cache_fpath=${cache_dir__input}/${link_cache_filename}
    local checkout_cache_fpath=${cache_dir__input}/${checkout_cache_filename}
    local linkCheckoutProfile_cache_fpath=${cache_dir__input}/${linkCheckoutProfile_cache_filename}

    #Update 'ret'
    #Remarks:
    #   'ret' contains 2 outputs which are separated by  a 'SED__RS'.
    #   1. 'link_cache_fpath'
    #   2. 'checkout_cache_fpath'
    #   3. 'linkCheckoutProfile_cache_fpath'
    ret="${link_cache_fpath}${SED__RS}${checkout_cache_fpath}${SED__RS}${linkCheckoutProfile_cache_fpath}"

    #Output
    echo "${ret}"
}

#---ESCAPE-KEY RELATED FUNCTIONS
function functionKey_detection__func() {
    #Define variables
    local ret="${DOCKER__EMPTYSTRING}"

    # Flush "^[" within 0.1 sec timeout.
    read -rsn1 -t 0.1 key2
    
    #Check if 2nd key is the kapital letter 'O'
    case "${key2}" in
        "${DOCKER__FUNC_O}")
            #Check if the 3rd key is any of the following letters
            read -rsn1 -t 0.1 key3
            case "${key3}" in
                "${DOCKER__FUNC_P}")    #F1
                    ret=${DOCKER__ENUM_FUNC_F1}
                    ;;
                "${DOCKER__FUNC_Q}")    #F2
                    ret=${DOCKER__ENUM_FUNC_F2}
                    ;;
                "${DOCKER__FUNC_R}")    #F3
                    ret=${DOCKER__ENUM_FUNC_F3}
                    ;;
                "${DOCKER__FUNC_S}")    #F4
                    ret=${DOCKER__ENUM_FUNC_F4}
                    ;;
                *)
                    ;;
            esac
            ;;
        "${DOCKER__FUNC_SLB}")
            #Check if the following 2 keys are any of the following 2-digit numbers
            read -rsn2 -t 0.1 key3
            case "${key3}" in
                "${DOCKER__FUNC_15}")    #F5
                    ret=${DOCKER__ENUM_FUNC_F5}
                    ;;
                "${DOCKER__FUNC_17}")    #F6
                    ret=${DOCKER__ENUM_FUNC_F6}
                    ;;
                "${DOCKER__FUNC_18}")    #F7
                    ret=${DOCKER__ENUM_FUNC_F7}
                    ;;
                "${DOCKER__FUNC_19}")    #F8
                    ret=${DOCKER__ENUM_FUNC_F8}
                    ;;
                "${DOCKER__FUNC_20}")    #F9
                    ret=${DOCKER__ENUM_FUNC_F9}
                    ;;
                "${DOCKER__FUNC_21}")    #F10
                    ret=${DOCKER__ENUM_FUNC_F10}
                    ;;
                "${DOCKER__FUNC_24}")    #F12
                    ret=${DOCKER__ENUM_FUNC_F12}
                    ;;
                *)
                    ;;
            esac
    esac

    #Flush "stdin" with 0.1  sec timeout.
    read -rsn5 -t 0.1

    #Output
    echo "${ret}"
}



#---FILE RELATED FUNCTIONS
function append_caretReturn_ifNotPresent_within_file__func() {
    disable_expansion__func

    #Input args
    local targetfpath__input=${1}

    #Check if file exists
    if [[ ! -s ${targetfpath__input} ]]; then   #does not exist
        return
    fi

    #Check if file ends with a 'newline' (aka caret-return)
    local caretReturn_isFound=`tail -c1 ${targetfpath__input} | wc -l`
    if [[ ${caretReturn_isFound} -eq ${DOCKER__NUMOFMATCH_0} ]]; then   #no caret-return found
        #Append caret-return
        echo "" >> ${targetfpath__input}
    fi

    enable_expansion__func
}

function append_string_to_file__func() {
    #Input args
    string__input=${1}
    targetfpath__input=${2}

    #Write
    echo "${string__input}" | tee -a ${targetfpath__input} >/dev/null
}

function checkIf_dir_exists__func() {
    #Input args
    local containerid__input="${1}"
    local dir__input="${2}"

    #Check if dir exists
    local ret=false
    if [[ ! -z ${dir__input} ]]; then #contains data
        if [[ ${dir__input} == ${DOCKER__SLASH} ]]; then
            ret=true
        else
            if [[ -z ${containerid__input} ]]; then #no container-ID provided
                ret=`lh_checkIf_dir_exists__func "${dir__input}"`
            else    #container-ID provided
                ret=`container_checkIf_dir_exists__func "${containerid__input}" "${dir__input}"`
            fi
        fi
    else
        ret=false
    fi

    #Output
    echo -e "${ret}"
}
function container_checkIf_dir_exists__func() {
	#Input args
    local containerid__input="${1}"
	local dir__input="${2}"

	#Define docker command
    local docker__bin_bash__dir=/bin/bash
    local docker_exec_cmd="docker exec -t ${containerid__input} ${docker__bin_bash__dir} -c"

    # #Prepend backslash in front of special chars (e.g., backslash, space, asterisk, etc.)
    # local dir_prepended_backslash=`prepend_backSlash_inFrontOf_specialChars__func \
    #                         "${dir__input}" \
    #                         "${DOCKER__TRUE}"`

    #Check if directory exists
    local ret_raw=`${docker_exec_cmd} "[ -d \"${dir__input}\" ] && echo true || echo false"`

    #Remove carriage returns '\r' caused by '/bin/bash -c'
    local ret=`echo "${ret_raw}" | tr -d $'\r'`

    #Output
    echo -e "${ret}"
}
function lh_checkIf_dir_exists__func() {
	#Input args
	local dir__input="${1}"

    # #Prepend backslash in front of special chars (e.g., backslash, space, asterisk, etc.)
    # local dir_prepended_backslash=`prepend_backSlash_inFrontOf_specialChars__func \
    #                         "${dir__input}" \
    #                         "${DOCKER__TRUE}"`

    #Check if directory exists
    if [[ -d "${dir__input}" ]]; then
        echo true
    else
        echo false
    fi
}

function checkIf_file_contains_only_dots_and_Slashes__func() {
    #Input args
    local targetfpath__input=${1}
    local tmpFpath__input=${2}

    #Backup 'targetfpath__input'
    cp ${targetfpath__input} ${tmpFpath__input}

    #Replace all dots and slashes with an Empty String
    sed -i 's/\(\.*\/*\)//g' ${tmpFpath__input}

    #Remove whitespaces (if any)
    sed -i '/^$/d;s/[[:blank:]]//g' ${tmpFpath__input}

    #Check file 'tmpFpath__input' contains any data
    #Remarks:
    #   file is empty -> 'targetfpath__input' contains only dot and/or slash.
    #   file is not empty -> 'targetfpath__input' contains NOT only dot and/or slash.
    if [[ ! -s ${tmpFpath__input} ]]; then  #file is empty
        echo "true"
    else    #file is NOT empty
        echo "false"
    fi
}

function checkIf_file_exists__func() {
    #Input args
    local containerid__input=${1}
    local fpath__input=${2}

    #Check if dir exists
    local ret=false
    if [[ ! -z ${fpath__input} ]]; then #contains data
        if [[ ${fpath__input} != ${DOCKER__SLASH} ]]; then  #input is not a slash
            if [[ -z ${containerid__input} ]]; then #no container-ID provided
                ret=`lh_checkIf_file_exists__func "${fpath__input}"`
            else    #container-ID provided
                ret=`container_checkIf_file_exists__func "${containerid__input}" "${fpath__input}"`
            fi
        fi
    fi

    #Output
    echo -e "${ret}"
}
function container_checkIf_file_exists__func() {
	#Input args
    local containerid__input=${1}
	local fpath__input=${2}

	#Define variables
    local docker__bin_bash__dir=/bin/bash
    local docker_exec_cmd="docker exec -t ${containerid__input} ${docker__bin_bash__dir} -c"

    #Check if directory exists
    local ret_raw=`${docker_exec_cmd} "[ -f "${fpath__input}" ] && echo true || echo false"`

    #Remove carriage returns '\r' caused by '/bin/bash -c'
    local ret=`echo "${ret_raw}" | tr -d $'\r'`

    #Output
    echo -e "${ret}"
}
function lh_checkIf_file_exists__func() {
	#Input args
	local fpath__input=${1}

     #Check if directory exists
     if [[ -f ${fpath__input} ]]; then
        echo true
     else
        echo false
     fi
}

function checkIf_dirnames_are_the_same__func() {
    #Input args
    local fpath_new__input=${1}
    local fpath_bck__input=${2}

    #Retrieve dirname from 'fpath1__input' and 'fpath2__input'
    local dir1=`get_dirname_from_specified_path__func "${fpath_new__input}"`
    local dir2=`get_dirname_from_specified_path__func "${fpath_bck__input}"`

    #Check if both paths are the same
    if [[ ${dir1} == ${dir2} ]]; then
        echo "true"
    else
        echo "false"
    fi
}

function checkIf_files_are_different__func() {
    #Input args
    local file1__input=${1}
    local file2__input=${2}

    #Check if the files exist
    if [[ ! -f ${file1__input} ]]; then
        echo "true"

        return  #exit function
    fi

    if [[ ! -f ${file2__input} ]]; then
        echo "true"

        return  #exit function
    fi

    #Compare both files
    local stdOutput=`diff ${file1__input} ${file2__input}`
    if [[ -z ${stdOutput} ]]; then
        echo "false"
    else
        echo "true"
    fi
}

function checkIf_fpaths_are_the_same__func() {
    #---------------------------------------------------------------------
    # Two full-paths are compared with each other to see if they are the
    # same. Should the input values end with a slash, then that slash will
    # be removed.
    #---------------------------------------------------------------------
    #Input args
    local fpath1__input=${1}
    local fpath2__input=${2}

    #Define and initialize variables
    local fpath1_rev=${fpath1__input}
    local fpath2_rev=${fpath2__input}
    local fpath1_lastChar="${DOCKER__EMPTYSTRING}"
    local fpath2_lastChar="${DOCKER__EMPTYSTRING}"

    local fpath1_len=${#fpath1__input}
    local fpath2_len=${#fpath2__input}

    #Get the last character
    fpath1_lastChar=`get_last_nChars_ofString__func "${fpath1__input}" "${DOCKER__NUMOFCHARS_1}"`
    if [[ ${fpath1_lastChar} == ${DOCKER__SLASH} ]]; then
        fpath1_rev=${fpath1__input:0:(fpath1_len-1)}
    fi
    fpath2_lastChar=`get_last_nChars_ofString__func "${fpath2__input}" "${DOCKER__NUMOFCHARS_1}"`
    if [[ ${fpath2_lastChar} == ${DOCKER__SLASH} ]]; then
        fpath2_rev=${fpath2__input:0:(fpath2_len-1)}
    fi

    #Check if both paths are the same
    if [[ ${fpath1_rev} == ${fpath2_rev} ]]; then
        echo "true"
    else
        echo "false"
    fi
}

function get_fullpath_by_combining_dir_with_fileorfolder() {
    #Input args
    local dir__input="${1}"
    local content__input="${2}"

    #Combine 'dir__input' and 'content__input'
    #***NOTE: double-slashes (//) will be substituted by single-slash (/)
    #EXPLANATION:
    #   s: substitute command in sed.
    #   #//*#/#g: search and replace pattern.
    #   //: pattern to search for (consecutive forward slashes).
    #   /: replacement (a single forward slash).
    #   g: stands for global, meaning that all occurrences of the pattern on each 
    #       line will be replaced, not just the first one.
    local ret=$(echo "${dir__input}/${content__input}" | sed 's#//*#/#g')

    #OUTPUT
    echo "${ret}"
}

function find_and_remove_all_lines_from_file_forGiven_keyWord__func() {
    #Input args
    local fpath__input=${1}
    local keyWord__input=${2}

    #Check if 'fpath__input' exists
    if [[ ! -f ${fpath__input} ]]; then
        return
    fi

    #Find and remove all lines containg the specified 'keyWord__input'
    sed -i "/${keyWord__input}/d"  ${fpath__input}
}

function get_basename_rev1__func() {
    #Input args
    local fpath__input=${1}

    #Get basename (which is a file or folder)
    local ret=`echo ${fpath__input} | rev | cut -d"${DOCKER__SLASH}" -f1 | rev`

    #Output
    echo -e "${ret}"
}

function get_basename_rev2__func() {
    #Input args
    local fpath__input=${1}

    #Get basename (which is a file or folder)
    local ret=$(basename "${fpath__input}")

    #Output
    echo -e "${ret}"
}

function get_dirname_from_specified_path__func() {
    #Input args
    local fpath__input=${1}

    #Get dirname
    local dir=`echo ${fpath__input} | rev | cut -d"${DOCKER__SLASH}" -f2- | rev`
    if [[ ${dir} == "${DOCKER__EMPTYSTRING}" ]]; then
        ret=${DOCKER__SLASH}
    else
        ret=${dir}${DOCKER__SLASH}
    fi

    #Output
    echo -e "${ret}"
}

function get_numOfLines_wo_emptyLines_in_file__func() {
    #Input args
    local targetfpath__input=${1}

    #Define variables
    local ret=0

    #Check if file exists
    if [[ ! -f ${targetfpath__input} ]]; then
        echo "${ret}"
    fi

    #Check number of lines WITHOUT empty lines!!!
    ret=`<${targetfpath__input} grep -c '[^[:space:]]'`

    #Output
    echo "${ret}"
}

function get_output_from_file__func() {
    #Input args
    outputFpath__input=${1}
    lineNum__input=${2}

    #Read from file
    if [[ -f ${outputFpath__input} ]]; then
        ret=`cat ${outputFpath__input} | head -n${lineNum__input} | tail -n+${lineNum__input}`
    else
        ret="${DOCKER__EMPTYSTRING}"
    fi

    #Output
    echo -e "${ret}"
}

function read_1stline_from_file__func() {
    #Input args
    local targetfpath__input=${1}
 
    #Read the first line from file
    local ret=$(awk 'NR == 1' "${targetfpath__input}")

    #Output
    echo -e "${ret}"
}

function remove_allEmptyLines_within_file__func() {
    #Input args
    targetfpath__input=${1}

    #Check if file exists
    if [[ ! -s ${targetfpath__input} ]]; then   #does not exist
        return
    fi

    #Remove all empty lines
    sed -i '/^$/d' ${targetfpath__input}
}

function remove_all_lines_from_file_after_a_specified_lineNum__func() {
    #Input args
    local targetfpath__input="${1}"
    local tmpFpath__input="${2}"
    local lineNumMax__input="${3}"

    #Check if the number of linies of file 'targetfpath__input'
    local targetFpath_numOfLines=`cat ${targetfpath__input} | wc -l`
    #Check if 'targetFpath_numOfLines < lineNumMax__input'
    #If true, then do nothing and exit function
    if [[ ${targetFpath_numOfLines} -le ${lineNumMax__input} ]]; then
        return
    fi

    #Remove all lines which follows AFTER 'lineNumMax__input'...
    #...and write to a temporary file 'tmpFpath__input'
    head -n${lineNumMax__input} "${targetfpath__input}" > ${tmpFpath__input}

    #Copy 'tmpFpath__input' to 'targetfpath__input'
    cp ${tmpFpath__input} ${targetfpath__input}
}

function remove_file__func() {
    #Input args
    local containerid__input=${1}
    local targetfpath__input=${2}
    local prependstring__input=${3}

    #Remove file
    if [[ -z ${containerid__input} ]]; then #no container-ID provided
        lh_remove_file__func "${targetfpath__input}" "${prependstring__input}"
    else    #container-ID provided
        container_remove_file__func "${containerid__input}" "${targetfpath__input}" "${prependstring__input}"
    fi
}

function lh_remove_file__func() {
    #Input args
    targetfpath__input=${1}
    prependstring__input=${2}

    #Start with generating 'printmsg'
    local printmsg="---:"

    #Override the default 'printmsg' (as defined above)
    if [[ -n "${prependstring__input}" ]]; then
        printmsg="${prependstring__input}"
    fi

    #Continue with updating 'printmsg'
    printmsg+="${DOCKER__STATUS}: remove ${DOCKER__FG_LIGHTGREY}${targetfpath__input}${DOCKER__NOCOLOR}: "

    #Remove file and update 'printmsg' based on the exitcode
    if [[ -f "${targetfpath__input}" ]]; then
        rm "${targetfpath__input}"; exitcode=$?

        if [[ ${exitcode} -eq 0 ]]; then
            printmsg+="${DOCKER__STATUS_SUCCESSFUL}"
        else
            printmsg+="${DOCKER__STATUS_FAILED}"
        fi

        #Print
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
    fi
}
function container_remove_file__func() {
    #Input args
    local containerid__input=${1}
    local targetfpath__input=${2}
    local prependstring__input=${3}

    #Define variables
    local cmd="rm ${targetfpath__input}"
    local docker__bin_bash__dir=/bin/bash
    local docker_exec_cmd="docker exec -t ${containerid__input} ${docker__bin_bash__dir} -c"
    local printmsg="---:"

    #Override the default 'printmsg' (as defined above)
    if [[ -n "${prependstring__input}" ]]; then
        printmsg="${prependstring__input}"
    fi

    #Continue with updating 'printmsg'
    printmsg+="${DOCKER__STATUS}: remove ${DOCKER__FG_LIGHTGREY}${targetfpath__input}${DOCKER__NOCOLOR}: "

    #Remove file and update 'printmsg' based on the exitcode
    if [[ $(checkIf_file_exists__func "${containerid__input}" "${targetfpath__input}") == true ]]; then
        ${docker_exec_cmd} "${cmd}"

        if [[ ${exitcode} -eq 0 ]]; then
            printmsg+="${DOCKER__STATUS_SUCCESSFUL}"
        else
            printmsg+="${DOCKER__STATUS_FAILED}"
        fi

        #Print
        show_msg_only__func "${printmsg}" "${DOCKER__NUMOFLINES_0}" "${DOCKER__NUMOFLINES_0}"
    fi
}

function retrieve_files_from_specified_dir_basedOn_matching_patterns__func() {
    #Input args
    local dir__input=${1}
    local pattern1__input=${2}
    local pattern2__input=${3}

    #Define variables
    local arrPattern1=()
    local arrPattern2=()
    local arrMatch=()
    local dir_w_asterisk="${DOCKER__EMPTYSTRING}"
    local ret="${DOCKER__EMPTYSTRING}"

    #Check if 'dir__input' is a directory
    if [[ ! -d ${dir__input} ]]; then
        echo "${ret}"

        return
    fi

    #Set 'dir_w_asterisk'
    dir_w_asterisk="${dir__input}/${DOCKER__ASTERISK}"

    #Replace multiple slashes with a single slash (/)
    dir_w_asterisk=`subst_multiple_chars_with_single_char__func "${dir_w_asterisk}" \
                    "${DOCKER__ESCAPED_SLASH}" \
                    "${DOCKER__ESCAPED_SLASH}"`

    #Retrieve files based on matching pattern1 and write to arrPattern1
    readarray -t arrPattern1 < <(grep -l "${pattern1__input}" ${dir_w_asterisk})

    #Retrieve files based on matching pattern2 and write to arrPattern2
    readarray -t arrPattern2 < <(grep -l "${pattern2__input}" ${dir_w_asterisk})

    #Preparing arrays
    #   1. sed 's/ /\n/g': replace all spaces with '\n'
    #      (in other words, strings separated by space are placed underneath each other)
    #   2. sort
    #   3. uniq 
    arrPattern1=$(echo "${arrPattern1[@]}" | sed 's/ /\n/g' | sort | uniq)
    arrPattern2=$(echo "${arrPattern2[@]}" | sed 's/ /\n/g' | sort | uniq)

    #Check for match between 'arrPattern1' and 'arrPattern2' and retrieve ONLY the matching elements
    #   1. sed 's/ /\n/g': replace all spaces with '\n'
    #      (in other words, strings separated by space are placed underneath each other)
    #   2. sort
    #   3. uniq -d: means only get the duplicate (or matching) elements between the two arrays
    arrMatch=$(echo ${arrPattern1[@]} ${arrPattern2[@]} | sed 's/ /\n/g' | sort | uniq -d)

    #***IMPORTANT: Rearrange strings back which are delimited by a space
    ret=$(echo ${arrMatch[@]} | sed 's/\n/ /g')

    #Output
    echo "${ret}"
}

function retrieve_string_based_on_specified_pattern_colnum_delimiterchar_from_file__func() {
    #Input args
    local targetfpath__input=${1}
    local pattern__input=${2}
    local colnum__input=${3}
    local delimiterchar__input=${4}

    #Find result based on provded 'pattern__input'
    local ret=$(grep -F "${pattern__input}" "${targetfpath__input}" | cut -d"${delimiterchar__input}" -f"${colnum__input}")

    #Output
    echo "${ret}"

    return 0;
}

function retrieve_linenum_based_on_specified_pattern_colnum_delimiterchar_from_file__func() {
    #Input args
    local targetfpath__input=${1}
    local pattern__input=${2}
    local colnum__input=${3}
    local delimiterchar__input=${4}

    #Find result based on provded 'pattern__input'
    local ret=$(grep -nF "${pattern__input}" "${targetfpath__input}" | cut -d"${delimiterchar__input}" -f"${colnum__input}")

    #Output
    echo "${ret}"

    return 0;
}

function subst_leading_string_with_another_string_within_file__func() {
    #Input args
    local oldSubString__input=${1}
    local newSubString__input=${2}
    local targetfpath__input=${3}
    local flag_enableExcludes__input=${4}

    #IMPORTANT:
    #   It is important to do the following 2 steps before using 'sed'.
    #   Failure to do so, will result in an error.
    #STEP1: prepend backslash (\) in front of any special chars except for slash (/) and dot (.)
    oldSubString__input=`prepend_backSlash_inFrontOf_specialChars__func "${oldSubString__input}" "${flag_enableExcludes__input}"`

    #Substitute
    #Note: notice the (^), which tells sed to only replace the LEADING substring.
    sed -i "s/^${oldSubString__input}/${newSubString__input}/g" "${targetfpath__input}"
}

function subst_trailing_string_with_another_string_within_file__func() {
    #Input args
    local oldSubString__input=${1}
    local newSubString__input=${2}
    local targetfpath__input=${3}
    local flag_enableExcludes__input=${4}

    #IMPORTANT:
    #   It is important to do the following 2 steps before using 'sed'.
    #   Failure to do so, will result in an error.
    #STEP1: prepend backslash (\) in front of any special chars except for slash (/) and dot (.)
    oldSubString__input=`prepend_backSlash_inFrontOf_specialChars__func "${oldSubString__input}" "${flag_enableExcludes__input}"`

    #Substitute
    #Note: notice the (^), which tells sed to only replace the LEADING substring.
    sed -i "s/${oldSubString__input}$/${newSubString__input}/g" "${targetfpath__input}"
}

function write_array_to_file__func() {
    #Input args
    local outputFpath__input=${1}
    shift
    local dataArr__input=("$@")

    #Remove file (if present)
    if [[ -f ${outputFpath__input} ]]; then
        rm ${outputFpath__input}
    fi

    #Write
    local dataArrItem="${DOCKER__EMPTYSTRING}"
    for dataArrItem in "${dataArr__input[@]}"
    do
        echo "${dataArrItem}" >> ${outputFpath__input}
    done
}

function write_data_to_file__func() {
    #Input args
    string__input=${1}
    targetfpath__input=${2}

    #Write
    echo "${string__input}" | tee ${targetfpath__input} >/dev/null
}



#---GIT FUNCTIONS
function git__checkIf_branch_alreadyExists__func() {
    #Input args
    local branchName_input=${1}

    #Check if 'branchName_input' already exists
    local stdOutput=`${GIT__CMD_GIT_BRANCH} | grep -w "${branchName_input}" 2>&1`
    if [[ ! -z ${stdOutput} ]]; then #contains data
        echo ${DOCKER__TRUE}
    else    #contains no data
        echo ${DOCKER__FALSE}
    fi
}

function git__checkIf_branch_isCheckedOut__func() {
    #Input args
    local branchName_input=${1}

    #Check if 'branchName_input' already exists
    local stdOutput=`${GIT__CMD_GIT_BRANCH} | grep -w "${branchName_input}" | grep "${DOCKER__ESCAPED_ASTERISK}" 2>&1`
    if [[ ! -z ${stdOutput} ]]; then #contains data
        echo ${DOCKER__TRUE}
    else    #contains no data
        echo ${DOCKER__FALSE}
    fi
}

function git__checkIf_branch_isPushed__func() {
    #Input args
    local branchName_input=${1}

    #Check if 'branchName_input' already exists
    # local stdOutput=`${GIT__CMD_GIT_LS_REMOTE} | grep "${GIT__PATTERN_HEADS}" | rev | cut -d"/" -f1 | rev | grep "^${branchName_input}$"`
    local stdOutput=`${GIT__CMD_GIT_BRANCH} -r | cut -d"/" -f2 | awk '{print $1}' | grep "^${branchName_input}$"`
    if [[ ! -z ${stdOutput} ]]; then #contains data
        echo ${GIT__PUSHED}
    else    #contains no data
        echo ${GIT__UNPUSHED}
    fi
}

function git__checkIf_tag_contains_specified_branchName__func() {
    #Input args
    local branchName__input=${1}
    local tag__input=${2}

    #Check
    #Remarks:
    #   sed 's/*//g': convert asterisk (*) to Empty String
    #   sed sed 's/^ *//g': convert leading spaces to Empty String
    #   sed 's/ *$//g': convert trailing spaces to Empty String
    local stdOutput=`${GIT__CMD_GIT_BRANCH} --contains tags/${tag__input} | \
                        sed 's/*//g' | \
                        sed 's/^ *//g' | \
                        sed 's/ *$//g' | \
                        grep "^${branchName__input}$"`
    if [[ ! -z ${stdOutput} ]]; then #contains data
        echo ${DOCKER__TRUE}
    else    #contains no data
        echo ${DOCKER__FALSE}
    fi
}

function git__check_local_if_tag_isAlready_inUse___func() {
    local tag__input=${1}

    #Check if 'branchName_input' already exists
    local stdOutput=`${GIT__CMD_GIT_TAG} | grep "^${tag__input}$" 2>&1`
    if [[ ! -z ${stdOutput} ]]; then #contains data
        echo ${DOCKER__TRUE}
    else    #contains no data
        echo ${DOCKER__FALSE}
    fi   
}

function git__check_remote_if_tag_isAlready_inUse__func() {
    local tag__input=${1}

    #Check if 'branchName_input' already exists
    local stdOutput=`${GIT__CMD_GIT_LS_REMOTE} --tags origin | \
                        grep "${GIT__PATTERN_TAGS}" | \
                        rev | \
                        cut -d"/" -f1 | \
                        rev | \
                        grep "^${tag__input}$" 2>&1`
    if [[ ! -z ${stdOutput} ]]; then #contains data
        echo ${DOCKER__TRUE}
    else    #contains no data
        echo ${DOCKER__FALSE}
    fi   
}

function git__get_current_branchName__func() {
    #Get branch-name
    local ret=`git symbolic-ref --short -q HEAD`

    #Output
    echo "${ret}"
}

function git__get_full_commitHash_for_specified_tag__func() {
    #Input args
    local tag__input=${1}
    local location__input=${2}  #GIT__LOCATION_LOCAL or GIT__LOCATION_REMOTE

    #Define variables
    local ret="${DOCKER__EMPTYSTRING}"

    #Check if 'tag__input' is an Empty String
    if [[ -z ${tag__input} ]]; then
        echo "${ret}"

        return
    fi

    #Check if 'location__input' is NOT 'GIT__LOCATION_LOCAL' and 'GIT__LOCATION_REMOTE'
    if [[ "${location__input}" != "${GIT__LOCATION_LOCAL}" ]] && \
            [[ "${location__input}" != "${GIT__LOCATION_REMOTE}" ]]; then
        echo "${ret}"

        return
    fi

    #FIRST: try to retrieve the full commit-hash by including the dereference-pattern (^{})
    if [[ ${location__input} == ${GIT__LOCATION_LOCAL} ]]; then
        ret=`${GIT__CMD_GIT_SHOW_REF} --tags | grep "\^{}" | grep "${tag__input}" | awk '{print $1}'`
    else
        ret=`${GIT__CMD_GIT_LS_REMOTE} --tags | grep "\^{}" | grep "${tag__input}" | awk '{print $1}'`
    fi

    #SECOND: if including the dereference-pattern (^{}) does NOT give any result, then...
    #        ...try without the dereference-pattern (^{}).
    if [[ -z ${ret} ]]; then
        if [[ ${location__input} == ${GIT__LOCATION_LOCAL} ]]; then
            ret=`${GIT__CMD_GIT_SHOW_REF} --tags | grep "${tag__input}" | awk '{print $1}'`
        else
            ret=`${GIT__CMD_GIT_LS_REMOTE} --tags |  grep "${tag__input}" | awk '{print $1}'`
        fi
    fi

    #Output
    echo "${ret}"
}

function git__get_tag_for_specified_branchName__func() {
    #Input args
    local branchName__input=${1}
    local flag_include_remoteTags_isEnabled__input=${2}

    #Get list of all local tags and write to array
    local localTags_arr=()
    readarray -t localTags_arr < <(${GIT__CMD_GIT_SHOW_REF} --tags | rev | cut -d"/" -f1 | rev)

    #Get list of all remote tags and write to array
    local remoteTags_arr=()
    if [[ ${flag_include_remoteTags_isEnabled__input} == true ]]; then
        readarray -t remoteTags_arr < <(${GIT__CMD_GIT_LS_REMOTE} --tags | rev | cut -d"/" -f1 | rev)
    fi

    #Combine arrays
    local totalTags_arr=("${localTags_arr[@]}" "${remoteTags_arr[@]}")

    #Sort and Uniq
    local totalTags_sortUniq_string=`printf "%s\n" "${totalTags_arr[@]}" | sort | uniq | sed 's/\n//g'`

    #Convert string to array
    local totalTags_sortUniq_arr=(`echo ${totalTags_sortUniq_string}`)

    #Loop thru array and check for each array-element (aka tag) if it contains the 'branchName__input'
    local match_isFound=false
    local totalTags_sortUniq_arrItem="${DOCKER__EMPTYSTRING}"
    local ret="${DOCKER__EMPTYSTRING}"
    for totalTags_sortUniq_arrItem in "${totalTags_sortUniq_arr[@]}"
    do
        match_isFound=`git__checkIf_tag_contains_specified_branchName__func \
                        "${branchName__input}" \
                        "${totalTags_sortUniq_arrItem}"`
        if [[ ${match_isFound} == true ]]; then
            ret=${totalTags_sortUniq_arrItem}

            break
        fi
    done

    #Output
    echo "${ret}"
}

function git__get_tag_for_specified_commitHash__func() {
    #Input args
    local abbrevCommitHash__input=${1}

    #Get tag
    local ret=`git log -a --pretty=oneline --graph | git name-rev --stdin --tag | \
                        grep "${abbrevCommitHash__input}"| \
                        grep "tags" | \
                        cut -d"(" -f2 | \
                        cut -d")" -f1 | \
                        cut -d"/" -f2- | \
                        cut -d"^" -f1 | \
                        cut -d"~" -f1 | \
                        sort | \
                        uniq`

    #Output
    echo "${ret}"
}

function git__get_tags__func() {
    #Input args
    local location__input=${1}  #GIT__LOCATION_LOCAL or GIT__LOCATION_REMOTE

    #Check if 'location__input' is NOT 'GIT__LOCATION_LOCAL' and 'GIT__LOCATION_REMOTE'
    if [[ "${location__input}" != "${GIT__LOCATION_LOCAL}" ]] && \
            [[ "${location__input}" != "${GIT__LOCATION_REMOTE}" ]]; then
        echo "${ret}"

        return
    fi

    #Get all tags
    local ret="${DOCKER__EMPTYSTRING}"
    if [[ ${location__input} == ${GIT__LOCATION_LOCAL} ]]; then
        ret=`${GIT__CMD_GIT_SHOW_REF} --tags | rev | cut -d"/" -f1 | rev | sort | uniq | tr -d "[:blank:]"`
    else    #git_location__input = GIT__LOCATION_REMOTE
        #Remark:
        #   cut -d "^" -f2-: used to remove the derefenced symbols (^{}) behind the tags (e.g. vtest123^{})
        ret=`${GIT__CMD_GIT_LS_REMOTE} --tags | rev | cut -d "^" -f2- | cut -d"/" -f1 | rev | sort | uniq | tr -d "[:blank:]"`
    fi

    #Output
    echo "${ret}"
}

function git__get_branches_for_specified_commitHash__func() {
    #Input args
    local abbrevCommitHash__input=${1}
    local location__input=${2}  #GIT__LOCATION_LOCAL or GIT__LOCATION_REMOTE

    #Check if 'location__input' is NOT 'GIT__LOCATION_LOCAL' and 'GIT__LOCATION_REMOTE'
    if [[ "${location__input}" != "${GIT__LOCATION_LOCAL}" ]] && \
            [[ "${location__input}" != "${GIT__LOCATION_REMOTE}" ]]; then
        echo "${ret}"

        return
    fi

    #Choose command
    if [[ ${git_location__input} == ${GIT__LOCATION_LOCAL} ]]; then
        grep_cmd="grep -v"  #-v means exclude
    else    #git_location__input = GIT__LOCATION_REMOTE
        grep_cmd="grep"
    fi

    #Get all tags
    local ret=`${GIT__CMD_GIT_BRANCH} -a --contains "${docker__full_commitHash}" | \
                        ${grep_cmd} "${GIT__PATTERN_REMOTES}" | \
                        rev | \
                        cut -d"/" -f1 | \
                        rev | \
                        sort | \
                        uniq | \
                        tr -d "[:blank:]"`

    #Output
    echo "${ret}"
}

function git__log_for_unpushed_local_commits__func() {
    #Remark:
    #   1. This function retrieves the git-information
    #      for UNPUSHED commits to REMOTE
    #   2. branchName__input -> can NOT be an Empty String
    #   3. last_nth_commit__input: last (n) commits -> can be an Empty String
    #   4. placeHolder__input -> can be an Empty String
    #Reference:
    #   See link: https://git-scm.com/docs/pretty-formats
    #Input args
    local branchName__input=${1}
    local last_nth_commit__input=${2} 
    local placeHolder__input=${3}

    #Define variables
    local ret="${DOCKER__EMPTYSTRING}"

    #Check if 'branchName__input' and 'last_nth_commit__input' are Empty Strings
    if [[ -z ${branchName__input} ]]; then
        echo "${ret}"

        return
    fi

    #Retrieve info
    if [[ -z "${last_nth_commit__input}" ]]; then
        ret=`git log ${branchName__input} --not --remotes --pretty=format:${placeHolder__input}`
    else
        ret=`git log -${last_nth_commit__input} ${branchName__input} --not --remotes --pretty=format:${placeHolder__input}`
    fi
     
    #Output
    echo "${ret}"
}

function git__log_for_pushed_and_unpushed_commits__func() {
    #Remark:
    #   1. This function retrieves the git-information
    #      for PUSHED and UNPUSHED commits.
    #   2. branchName__input -> can be an Empty String
    #   3. last_nth_commit__input: last (n) commits -> can be an Empty String
    #   4. placeHolder__input -> can NOT be an Empty String
    #Reference:
    #   See link: https://git-scm.com/docs/pretty-formats
    #Input args
    local branchName__input=${1}
    local last_nth_commit__input=${2} 
    local placeHolder__input=${3}

    #Compose command
    local cmd="git log"
    if [[ ! -z "${last_nth_commit__input}" ]]; then
        cmd="${cmd} -${last_nth_commit__input}"
    fi

    if [[ ! -z "${branchName__input}" ]]; then
        cmd="${cmd} ${branchName__input}"
    fi

    if [[ ! -z "${placeHolder__input}" ]]; then
        cmd="${cmd} --pretty=format:${placeHolder__input}"
    fi

    #Retrieve info
    local ret=`eval ${cmd}`

    #Output
    echo "${ret}"
}

function git__retrieve_parent_branchName__func() {
    #Retrieve parent branch-name
    local ret=$(git show-branch -a | \
                        grep '\*' | \
                        grep -v `git rev-parse --abbrev-ref HEAD` | \
                        head -n1 | \
                        sed 's/.*\[\(.*\)\].*/\1/' | \
                        sed 's/[\^~].*//')

    #Output
    echo "${ret}"
}

function git__retrieve_branchName_for_specified_tag__func() {
    #Input args
    local tag__input=${1}

    #Get branch-name
    local ret="${DOCKER__EMPTYSTRING}"
    ret=`${GIT__CMD_GIT_BRANCH} --contains tags/${tag__input} | \
                        sed 's/*//g' | \
                        sed 's/^ *//g' | \
                        sed 's/ *$//g'`
    #Output
    echo "${ret}"
}

function git__retrieve_tag_for_specified_branchName__func() {
    #Input args
    local branchName__input=${1}

    #Get abbreviated commit hash
    local abbrevCommitHash=`git__log_for_pushed_and_unpushed_commits__func ""${DOCKER__EMPTYSTRING}"" \
                        ""${DOCKER__EMPTYSTRING}"" \
                        "${GIT__PLACEHOLDER_ABBREV_COMMIT_HASH}"`

    #Get tag
    local ret=`git__get_tag_for_specified_commitHash__func "${abbrevCommitHash}"`

    #Output
    echo "${ret}"
}



#---MOVE FUNCTIONS
function moveUp__func() {
    #Input args
    local numOfLines__input=${1}

    #Clear lines
    local tCounter=1
    while [[ ${tCounter} -le ${numOfLines__input} ]]
    do
        tput cuu1	#move UP with 1 line

        tCounter=$((tCounter+1))  #increment by 1
    done
}

function moveUp_and_cleanLines__func() {
    #Input args
    local numOfLines__input=${1}

    #Clear lines
    local xPos_curr=0

    if [[ ${numOfLines__input} -ne ${DOCKER__NUMOFMATCH_0} ]]; then
        local tCounter=1
        while [[ ${tCounter} -le ${numOfLines__input} ]]
        do
            #clean current line, Move-up 1 line and clean
            tput el1
            tput cuu1
            tput el

            #Increment tCounter by 1
            tCounter=$((tCounter+1))
        done
    else
        tput el1
    fi

    #Get current x-position of cursor
    xPos_curr=`tput cols`

    #Move to the beginning of line
    tput cub ${xPos_curr}
}

function moveToBeginning_and_cleanLine__func() {
    #Clean to begining of line
    tput el1

    #Get current x-position of cursor
    xPos_curr=`tput cols`

    #Move to the beginning of line
    tput cub ${xPos_curr}
}

function moveDown__func() {
    #Input args
    local numOfLines__input=${1}

    #Clear lines
    local tCounter=1
    while [[ ${tCounter} -le ${numOfLines__input} ]]
    do
        #Move-down 1 line
        tput cud1

        #Increment tCounter by 1
        tCounter=$((tCounter+1))
    done
}

function moveDown_and_cleanLines__func() {
    #Input args
    local numOfLines__input=${1}

    #Clear lines
    local tCounter=1
    while [[ ${tCounter} -le ${numOfLines__input} ]]
    do
        #Move-down 1 line and clean
        tput cud1
        tput el1

        #Increment tCounter by 1
        tCounter=$((tCounter+1))
    done
}

function moveDown_oneLine_then_moveUp_and_clean__func() {
    #Input args
    local numOfLines__input=${1}

    #Move-down 1 line
    tput cud1

    #Move-up and clean a specified number of times
    moveUp_and_cleanLines__func "${numOfLines__input}"
}

function moveLeft_and_clean_trailing_chars() {
    #Input args
    local numOfChars__input=${1}

    local tCounter=1
    while [[ ${tCounter} -le ${numOfChars__input} ]]
    do
        #Move-left 1 char
        tput cub1

        #Remove last char
        tput el

        #Increment tCounter by 1
        tCounter=$((tCounter+1))
    done
}

function moveUp_oneLine_then_moveRight__func() {
    #Input args
    local mainMsg=${1}
    local keyInput=${2}

    #Get lengths
    local mainMsg_wo_regEx=$(printf "%s" "$mainMsg" | sed "s/$(echo -e "\e")[^m]*m//g")
    local mainMsg_wo_regEx_len=${#mainMsg_wo_regEx}
    local keyInput_wo_regEx=$(printf "%s" "$keyInput" | sed "s/$(echo -e "\e")[^m]*m//g")
    local keyInput_wo_regEx_len=${#keyInput_wo_regEx}
    local total_len=$((mainMsg_wo_regEx_len + keyInput_wo_regEx_len))

    #Move cursor up by 1 line
    tput cuu1
    #Move cursor to right
    tput cuf ${total_len}
}



#---SHOW FUNCTIONS
function center_string_and_writeTo_file__func() {
    #Input args
    local string__input=${1}
    local maxStrLen__input=${2}
    local writeToThisFile__input=${3}

    #Define one-space constant
    local ONESPACE=" "

    #Get string 'without visiable' color characters
    local strInput_wo_colorChars=`echo "${string__input}" | sed "s,\x1B\[[0-9;]*m,,g"`

    #Get string length
    local strInput_wo_colorChars_len=${#strInput_wo_colorChars}

    #Calculated the number of spaces to-be-added
    local numOf_spaces=$(( (maxStrLen__input-strInput_wo_colorChars_len)/2 ))

    #Create a string containing only EMPTY SPACES
    local emptySpaces_string=`duplicate_char__func "${ONESPACE}" "${numOf_spaces}" `

    #Print text including Leading Empty Spaces
    printf "%s" "${emptySpaces_string}${string__input}" >> ${writeToThisFile__input}
}

function show_array_elements_w_menuTitle__func() {
    #Input args
    local menuTitle__input=${1}
    local menuOptions__input=${2}
    local dataArr_pageNum__input=${3}    #page-number
    local dataArr_pageSize__input=${4}  #number of lines to be shown
    shift
    shift
    shift
    shift
    local dataArr__input=("$@")


    #Hide cursor
    cursor_hide__func

    #Disable keyboard-input
    disable_keyboard_input__func


    #Print horizontal line
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    #Print menu-title
    show_centered_string__func "${menuTitle__input}" "${DOCKER__TABLEWIDTH}"
    #Print horizontal line
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"


    #Get the array-length
    local dataArrLen=${#dataArr__input[@]}


    #set the default flag value
    local flag_showAll=false

    #Check if 'dataArr_pageNum__input' and 'dataArr_pageSize__input' are Empty Strings
    if [[ -z ${dataArr_pageNum__input} ]] || [[ -z ${dataArr_pageSize__input} ]]; then
        flag_showAll=true
    fi

    #Check if 'dataArr_pageSize__input => dataArrLen'
    if [[ ${dataArr_pageSize__input} -ge ${dataArrLen} ]]; then
        flag_showAll=true
    fi


    #Calculate the 'dataArr_lineNum_start' and 'dataArr_lineNum_end'
    local dataArr_lineNum_start=$((((dataArr_pageNum__input - 1)*dataArr_pageSize__input) + 1))
    local dataArr_lineNum_end=$((dataArr_pageNum__input*dataArr_pageSize__input))
    if [[ ${dataArr_lineNum_end} -gt ${dataArrLen} ]]; then
        dataArr_lineNum_end=${dataArrLen}
    fi


    #Show array-elements
    local dataArr_lineNum=${DOCKER__LINENUM_0}
    local print_lineNum=${DOCKER__LINENUM_0}
    for dataArrItem in "${dataArr__input[@]}"
    do
        #Increment array-linenumber
        dataArr_lineNum=$((dataArr_lineNum + 1))
 
        #Check if 'dataArr_lineNum > dataArr_lineNum_end'
        if [[ ${dataArr_lineNum} -gt ${dataArr_lineNum_end} ]] && [[ ${flag_showAll} == false ]]; then
            break
        fi

        #Check if 'dataArr_lineNum => dataArr_lineNum_start'
        if [[ ${dataArr_lineNum} -ge ${dataArr_lineNum_start} ]]; then
            echo "${DOCKER__FOURSPACES}${dataArrItem}"

            print_lineNum=$((print_lineNum + 1))
        fi
    done


    #Fill-up table with empty lines
    while [[ ${print_lineNum} -lt ${dataArr_pageSize__input} ]]
    do
        #Print an Empty Line
        echo ""${DOCKER__EMPTYSTRING}""

        #increment line-number
        print_lineNum=$((print_lineNum + 1))
    done


    #Move-down cursor
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"


    #Show 'prev' and 'next'
    if [[ ${flag_showAll} == false ]]; then
        local prev_only_print="${DOCKER__ONESPACE_PREV}"

        local oneSpacePrev_len=`get_stringlen_wo_regEx__func "${DOCKER__ONESPACE_PREV}"`
        local oneSpaceNext_len=`get_stringlen_wo_regEx__func "${DOCKER__ONESPACE_NEXT}"`
        local space_between_prev_and_next_len=$(( DOCKER__TABLEWIDTH - (oneSpacePrev_len + oneSpaceNext_len) - 1 ))
        local space_between_prev_and_next=`duplicate_char__func "${DOCKER__ONESPACE}" "${space_between_prev_and_next_len}"`
        local prev_spaces_next_print="${DOCKER__ONESPACE_PREV}${space_between_prev_and_next}${DOCKER__ONESPACE_NEXT}"

        local docker_space_between_leftBoundary_and_next_len=$(( DOCKER__TABLEWIDTH - oneSpacePrev_len - 1 ))
        local docker_space_between_leftBoundary_and_next=`duplicate_char__func "${DOCKER__ONESPACE}" "${docker_space_between_leftBoundary_and_next_len}"`
        local next_only_print="${docker_space_between_leftBoundary_and_next}${DOCKER__ONESPACE_NEXT}"

        if [[ ${dataArr_lineNum_start} -eq ${DOCKER__NUMOFMATCH_1} ]]; then
            echo "${next_only_print}"
        else
            if [[ ${dataArr_lineNum_end} -eq ${dataArrLen} ]]; then 
                echo "${prev_only_print}"
            else
                echo "${prev_spaces_next_print}"
            fi
        fi

        #Show line-number range between 'prev' and 'next'
        lineNum_range_msg="${DOCKER__FG_LIGHTGREY}${dataArr_pageNum__input}${DOCKER__NOCOLOR} "
        lineNum_range_msg+="to ${DOCKER__FG_LIGHTGREY}${dataArr_pageSize__input}${DOCKER__NOCOLOR} "
        lineNum_range_msg+="(${DOCKER__FG_SOFTLIGHTRED}${dataArrLen}${DOCKER__NOCOLOR})"

        #Caclulate the length of 'lineNum_range_msg' without regEx
        lineNum_range_msg_wo_regEx_len=`get_stringlen_wo_regEx__func "${lineNum_range_msg}"`

        #Determine the start-position of where to place 'lineNum_range_msg'
        lineNum_range_msg_startPos=$(( (DOCKER__TABLEWIDTH/2) - (lineNum_range_msg_wo_regEx_len/2) ))

        #Move-up
        if [[ ${flag_showAll} == false ]]; then
            moveUp__func "${DOCKER__LINENUM_1}"
        fi

        #Move cursor to start-position 'lineNum_range_msg_startPos'
        tput cuf ${lineNum_range_msg_startPos}

        #Print 'lineNum_range_msg'
        echo -e "${lineNum_range_msg}"
    fi

    if [[ ! -z ${menuOptions__input} ]]; then
        ##Print horizontal line
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Print menu-options
        echo -e "${menuOptions__input}"
    fi

    #Print horizontal line
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"


    #Show cursor
    cursor_show__func

    #Enable keyboard-input
    enable_keyboard_input__func
}

function show_centered_string__func() {
    #Input args
    local string__input=${1}
    local tableWidth__input=${2}
    local bg_color__input=${3}

    #Set 'bg_color__input' to 'DOCKER__NOCOLOR'
    if [[ -z ${bg_color__input} ]]; then
        bg_color__input=${DOCKER__NOCOLOR}
    fi

    #Get string 'without visiable' color characters
    local strInput_wo_colorChars=`echo "${string__input}" | sed "s,\x1B\[[0-9;]*m,,g"`

    #Get string-length
    local strInput_wo_colorChars_len=${#strInput_wo_colorChars}

    #Create string containing only empty spaces
    local emptySpaces=`duplicate_char__func "${DOCKER__ONESPACE}" "${tableWidth__input}"`

    #Calculated the number of spaces to-be-prepended
    local string_startPos=$(( (tableWidth__input - strInput_wo_colorChars_len)/2 ))


    #Print text including Leading Empty Spaces
    echo -e "${bg_color__input}${emptySpaces}${DOCKER__NOCOLOR}"

    #Move cursor up
    tput cuu1

    #cursor to the right specified by 'string_startPos'
    tput cuf ${string_startPos}

    #Print string
    echo -e "${bg_color__input}${string__input}${DOCKER__NOCOLOR}"
}

function show_errMsg_wo_menuTitle_and_exit_func() {
    #Input args
    local msg__input=${1}
    local prepend_numOfLines__input=${2}
    local append_numOfLines__input=${3}

    #Move down and clean
    moveDown_and_cleanLines__func "${prepend_numOfLines__input}"
    
    #Print
    echo -e "${msg__input}"

    #Move down and clean
    moveDown_and_cleanLines__func "${append_numOfLines__input}"

    #Exit
    exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_0}"
}

function show_header__func() {
    #Input args
    local menuTitle__input=${1}
    local tableWidth__input=${2}
    local bg_color__input=${3}
    local prepend_numOfLines__input=${4}
    local append_numOfLines__input=${5}

    #Move-down and clean
    moveDown_and_cleanLines__func "${prepend_numOfLines__input}"

    #Print title
    show_centered_string__func "${menuTitle__input}" "${tableWidth__input}" "${bg_color__input}"

    #Move-down and clean
    moveDown_and_cleanLines__func "${append_numOfLines__input}"
}

function show_leadingAndTrailingStrings_separatedBySpaces__func() {
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
    local spaces_leading=`duplicate_char__func "${DOCKER__ONESPACE}" "${numOf_spaces}"`

    #Print text including Leading Empty Spaces
    echo -e "${leadStr__input}${spaces_leading}${trailStr__input}"
}

function show_msg_only__func() {
    #Input args
    local msg__input=${1}
    local prepend_numOfLines__input=${2}
    local append_numOfLines__input=${3}
    local prepend_horizontal_line__input=${4}
    local append_horizontal_line__input=${5}


    #Initialization
    if [[ -z ${prepend_numOfLines__input} ]]; then
        prepend_numOfLines__input=${DOCKER__NUMOFLINES_0}
    fi

    if [[ -z ${append_numOfLines__input} ]]; then
        append_numOfLines__input=${DOCKER__NUMOFLINES_0}
    fi

    #Prepend empty line
    moveDown_and_cleanLines__func "${prepend_numOfLines__input}"

    #Prepend horizontal line
    if [[ -n ${prepend_horizontal_line__input} ]]; then
        if [[ ${prepend_horizontal_line__input} == true ]]; then
            duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        fi
    fi

    #Print
    echo -e "${msg__input}"

    #Prepend horizontal line
    if [[ -n ${append_horizontal_line__input} ]]; then
        if [[ ${append_horizontal_line__input} == true ]]; then
            duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        fi
    fi

    #Append empty line
    moveDown_and_cleanLines__func "${append_numOfLines__input}"
}

function show_msg_w_menuTitle_only_func() {
    #Input args
    local menuTitle__input=${1}
    local msg__input=${2}
    local msg_indent__input=${3}    #If NO indent, specify 'DOCKER__ZEROSPACE' (however, DO NOT use DOCKER__EMPTYSTRING)
    local prepend_numOfLines__input=${4}    #add number of empty lines BEFORE table
    local afterMsg_numOfLines__input=${5}   #add number of empty lines AFTER 'msg__input'
    local append_numOfLines__input=${6} #add number of empty lines AFTER table
    local tibboHeader_prepend_numOfLines__input=${7}


    #Initialization
    if [[ -z ${prepend_numOfLines__input} ]]; then
        prepend_numOfLines__input=${DOCKER__NUMOFLINES_0}
    fi

    if [[ -z ${afterMsg_numOfLines__input} ]]; then
        afterMsg_numOfLines__input=${DOCKER__NUMOFLINES_0}
    fi


    if [[ -z ${append_numOfLines__input} ]]; then
        append_numOfLines__input=${DOCKER__NUMOFLINES_0}
    fi

    #Print Tibbo-title (if applicable)
    if [[ ! -z ${tibboHeader_prepend_numOfLines__input} ]]; then
        load_tibbo_title__func "${tibboHeader_prepend_numOfLines__input}"
    else
        moveDown_and_cleanLines__func "${prepend_numOfLines__input}"
    fi

    #Horizontal line
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Print 'menuTitle__input'
    show_centered_string__func "${menuTitle__input}" "${DOCKER__TABLEWIDTH}"

    #Horizontal line
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    
    #CHeck if 'msg_indent__input' is an Empty String or Not
    if [[ -z ${msg_indent__input} ]]; then  #is an Empty String
        show_centered_string__func "${msg__input}" "${DOCKER__TABLEWIDTH}"
    else    #is NOT an Empty String
        #Check if 'msg_indent__input' is 'DOCKER__ZEROSPACE'
        #Remark:
        #   This means that NO indent should be applied
        if [[ ${msg_indent__input} == ${DOCKER__ZEROSPACE} ]]; then
            msg_indent__input="${DOCKER__EMPTYSTRING}"
        fi
        echo -e "${msg_indent__input}${msg__input}"
    fi
    
    #Append 1 emoty line
    moveDown_and_cleanLines__func "${afterMsg_numOfLines__input}"

    #Horizontal line
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Append empty lines
    moveDown_and_cleanLines__func "${append_numOfLines__input}"
}

function show_msg_w_menuTitle_w_pressAnyKey_w_ctrlC_func() {
    #Input args
    local menuTitle__input=${1}
    local msg__input=${2}
    local exitCode__input=${3}

    #Horizontal line
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Print 'menuTitle__input'
    show_centered_string__func "${menuTitle__input}" "${DOCKER__TABLEWIDTH}"

    #Horizontal line
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    
    #Move-down and clean 1 line
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    #Print message
    show_centered_string__func "${msg__input}" "${DOCKER__TABLEWIDTH}"
    
    #Move-down and clean 1 line
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    #Horizontal line
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Move-down and clean 1 line
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    #Show press any key
    press_any_key__func "${DOCKER__TIMEOUT_10}" \
                        "${DOCKER__NUMOFLINES_0}" \
                        "${DOCKER__NUMOFLINES_0}"

    #Exit
    exit__func "${exitCode__input}" "${DOCKER__NUMOFLINES_2}"
}

function show_msg_wo_menuTitle_w_PressAnyKey__func() {
    #Input args
    local msg__input=${1}
    local prepend_numOfLines__input=${2}
    local confirmation_timeout__input=${3}
    local confirmation_prepend_numOfLines__input=${4}
    local confirmation_append_numOfLines__input=${5}

    #Move-down cursor
    moveDown_and_cleanLines__func "${prepend_numOfLines__input}"

    #Print
    echo -e "${msg__input}"

    #Show press-any-key dialog
    press_any_key__func "${confirmation_timeout__input}" \
                        "${confirmation_prepend_numOfLines__input}" \
                        "${confirmation_append_numOfLines__input}"
}

function show_msg_w_menuTitle_w_confirmation__func() {
    #Input args
    local menuTitle__input=${1}
    local msg__input=${2}
    local confirmation_choices__input=${3}
    local confirmation_regEx__input=${4}
    local prepend_numOfLines__input=${5}
    local confirmation_timeout__input=${6}
    local confirmation_prepend_numOfLines__input=${7}
    local confirmation_append_numOfLines__input=${8}

    #Move-down cursor
    moveDown_and_cleanLines__func "${prepend_numOfLines__input}"

    #Print horizontal line
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Print menu-title
    show_centered_string__func "${menuTitle__input}" "${DOCKER__TABLEWIDTH}"

    #Print horizontal line
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Print message
    echo -e "${msg__input}"

    #Move-down and clean 1 line
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    #Print horizontal line
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Show press-any-key dialog
    confirmation_w_timer__func "${confirmation_choices__input}" \
                        "${confirmation_regEx__input}" \
                        "${confirmation_timeout__input}" \
                        "${confirmation_prepend_numOfLines__input}" \
                        "${confirmation_append_numOfLines__input}"
}

function show_msg_wo_menuTitle_w_confirmation__func() {
    #Input args
    local msg__input=${1}
    local confirmation_choices__input=${2}
    local confirmation_regEx__input=${3}
    local prepend_numOfLines__input=${4}
    local confirmation_timeout__input=${5}
    local confirmation_prepend_numOfLines__input=${6}
    local confirmation_append_numOfLines__input=${7}

    #Move-down cursor
    moveDown_and_cleanLines__func "${prepend_numOfLines__input}"

    #Print
    if [[ ! -z "${msg__input}" ]]; then
        echo -e "${msg__input}"
    fi

    #Show press-any-key dialog
    confirmation_w_timer__func "${confirmation_choices__input}" \
                        "${confirmation_regEx__input}" \
                        "${confirmation_timeout__input}" \
                        "${confirmation_prepend_numOfLines__input}" \
                        "${confirmation_append_numOfLines__input}"
}

function show_menuTitle_w_adjustable_indent__func() {
    #Input args
    local menuTitle__input=${1}
    local menuTitle_indent__input=${2}

    #Show list
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    if [[ -z ${menuTitle_indent__input} ]]; then
        show_centered_string__func "${menuTitle__input}" "${DOCKER__TABLEWIDTH}"
    else
        echo "${menuTitle_indent__input}${menuTitle__input}"
    fi
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
}

function show_repoList_or_containerList_w_menuTitle__func() {
    #Input args
    local menuTitle__input=${1}
    local dockerCmd__input=${2}

    #Show list
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${menuTitle__input}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    
    if [[ ${dockerCmd__input} == ${docker__ps_a_cmd} ]]; then
        ${docker__containerlist_tableinfo__fpath}
    else
        ${docker__repolist_tableinfo__fpath}
    fi

    #Move-down cursor
    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

    #Print
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    echo -e "${DOCKER__FOURSPACES_QUIT_CTRL_C}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
}

function show_repoList_or_containerList_w_menuTitle_w_confirmation__func() {
    #Input args
    local menuTitle__input=${1}
    local msg__input=${2}
    local docker_cmd__input=${3}
    local prepend_numOfLines__input=${4}
    local confirmation_timeout__input=${5}
    local confirmation_prepend_numOfLines__input=${6}
    local confirmation_append_numOfLines__input=${7}
    local tibboHeader_prepend_numOfLines__input=${8}

    #Print Tibbo-title (if applicable)
    if [[ ! -z ${tibboHeader_prepend_numOfLines__input} ]]; then
        load_tibbo_title__func "${tibboHeader_prepend_numOfLines__input}"
    else
        moveDown_and_cleanLines__func "${prepend_numOfLines__input}"
    fi

    #Horizontal line
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Print title    
    show_centered_string__func "${menuTitle__input}" "${DOCKER__TABLEWIDTH}"

    #Horizontal line
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"


    #Get number of containers
    local numOfElements=`${docker_cmd__input} | head -n -1 | wc -l`
    if [[ ${numOfElements} -gt 0 ]]; then    #containers were found
        #Show list of repository/container elements
        if [[ ${docker_cmd__input} == ${docker__images_cmd} ]]; then
            ${docker__repolist_tableinfo__fpath}
        else
            ${docker__containerlist_tableinfo__fpath}
        fi

        #Move-down cursor
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
    else    #no containers found
        #Move-down cursor
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        #Print message
        show_centered_string__func "${msg__input}" "${DOCKER__TABLEWIDTH}"

        #Move-down cursor
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        #Horizontal line
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        #Move-down cursor
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        #Show press-any-key dialog
        press_any_key__func "${confirmation_timeout__input}" \
                            "${confirmation_prepend_numOfLines__input}" \
                            "${confirmation_append_numOfLines__input}"
    fi
}



#---READ-DiALOG FUNCTIONS
function readDialog_w_Output__func() {
    #Input args
    local readMsg__input=${1}
    local defaultVal__input=${2}
    local outputFpath__input=${3}
    local prepend_numOfLines__input=${4}
    local append_numOfLines__input=${5}

    #Remove file (if present)
    if [[ -f ${outputFpath__input} ]]; then
        rm ${outputFpath__input}
    fi


    #Check if 'prepend_numOfLines' is an Empty String
    if [[ -z ${prepend_numOfLines__input} ]]; then
        prepend_numOfLines__input=${DOCKER__NUMOFLINES_0}
    fi

    #Check if 'append_numOfLines__input' is an Empty String
    if [[ -z ${append_numOfLines__input} ]]; then
        append_numOfLines__input=${DOCKER__NUMOFLINES_0}
    fi


    #Move-down and clean
    moveDown_and_cleanLines__func "${prepend_numOfLines__input}"


    #Initialization
    local ret=${defaultVal__input}
    local ret_semiColonVal="${DOCKER__EMPTYSTRING}"

    #Start loop
    while true
    do
        echo -e "${readMsg__input}${ret}"

        #Move cursor up
        moveUp_oneLine_then_moveRight__func "${readMsg__input}" "${ret}"
        
        #Execute read-input
        read -N1 -rs -p "" keyInput

        case "${keyInput}" in
            ${DOCKER__ENTER})
                #Check if there were any ';b', ';c', ';h' issued.
                #In other words, whether 'ret' contains any of the above semi-colon chars.
                #Remarks:
                #   1. If that's the case then function 'get_endResult_ofString_with_semiColonChar__func'
                #   ...will handle and return a modified 'ret'.
                #   2. If the input arg 'ret_bck' contains a ';c', then function 'get_endResult_ofString_with_semiColonChar__func'
                #   ...will return remaining substring which is on the RIGHT-side of ';c'.
                #   In case this substring is an <Empty String>, then 'ret' will be resetted to 'DOCKER__EMPTYSTRING'
                #   ...and the readdialog will be shown again.
                ret_bck=${ret}  #set value
                ret=`get_endResult_ofString_with_semiColonChar__func "${ret_bck}"`
         
                if [[ ! -z ${ret} ]]; then    #'ret' contains data
                    moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                    case "${ret}" in
                        ${DOCKER__SEMICOLON_BACK})
                            #Retrieve the substring preceding (;b) and write to variable 'ret'
                            ret=`echo "${ret_bck}" | sed "s/${DOCKER__SEMICOLON_BACK}$//g"`

                            #Set 'ret_semiColonVal'
                            ret_semiColonVal=${DOCKER__SEMICOLON_BACK}
                            ;;
                        ${DOCKER__SEMICOLON_HOME})
                            #Retrieve the substring preceding (;h) and write to variable 'ret'
                            ret=`echo "${ret_bck}" | sed "s/${DOCKER__SEMICOLON_HOME}$//g"`

                            #Set 'ret_semiColonVal'
                            ret_semiColonVal=${DOCKER__SEMICOLON_HOME}
                            ;;
                    esac

                    break
                else    #'ret' is an Empty String
                    #Reset variable
                    ret="${DOCKER__EMPTYSTRING}"

                    #First Move-down, then Move-up, after that clean line
                    moveToBeginning_and_cleanLine__func
                fi
                ;;
            ${DOCKER__BACKSPACE})
                #Update variable
                ret=`readDialog_w_Output_backSpace_handler__func "${ret}"`

                #First Move-down, then Move-up, after that clean line
               moveToBeginning_and_cleanLine__func
                ;;
            ${DOCKER__ESCAPEKEY})
                #Handle Arrowkey-press
                readDialog_w_Output_arrowKeys_handler__func

                #First Move-down, then Move-up, after that clean line
                moveToBeginning_and_cleanLine__func
                ;;
            ${DOCKER__TAB})
                #First Move-down, then Move-up, after that clean line
                moveToBeginning_and_cleanLine__func
                ;;
            *)
                #wait for another 0.5 seconds to capture additional characters.
                #Remark:
                #   This part has been implemented just in case long text has been copied/pasted.
                read -rs -t0.01 keyInput_addit

                #Append 'keyInput_addit' to 'keyInput'
                keyInput="${keyInput}${keyInput_addit}"

                #Append 'keyInput' to 'ret'
                ret="${ret}${keyInput}"

                #First Move-down, then Move-up, after that clean line
                moveToBeginning_and_cleanLine__func
                ;;
        esac
    done


    #Move-down and clean
    moveDown_and_cleanLines__func "${append_numOfLines__input}"


    #Output
    echo "${ret}" > ${outputFpath__input}
    echo "${ret_semiColonVal}" >> ${outputFpath__input}
}
function readDialog_w_Output_arrowKeys_handler__func() {
    # Flush "stdin" with 0.1  sec timeout.
    read -rsn1 -t 0.1 tmp
    if [[ "$tmp" == "[" ]]; then
        # Flush "stdin" with 0.1  sec timeout.
        read -rsn1 -t 0.1 tmp
    fi

    #Flush "stdin" with 0.1  sec timeout.
    read -rsn5 -t 0.1
}
function readDialog_w_Output_backSpace_handler__func() {
    #Input args
    str_input=${1}

    #CHeck if 'str_input' is an EMPTYSTRING
    if [[ -z ${str_input} ]]; then
        return
    fi

    #Constants
    OFFSET=0

    #Lengths
    str_input_len=${#str_input}
    str_output_len=$((str_input_len-1))

    #Get result
    str_output=${str_input:${OFFSET}:${str_output_len}}

    #Output
    echo "${str_output}"
}

function show_pathContent_w_selection__func() {
#---Input args
    local path__input=${1}  #could be a directory or file
    local selItem__input=${2}
    local menuTitle__input=${3}
    local remark__input=${4}
    local info__input=${5}
    local menuOptions__input=${6}
    local matchPattern__input=${7}  #match pattern of 'menuOptions__input'
    local errMsg__input=${8}
    local readDialog__input=${9}
    local pattern1__input=${10}
    local pattern2__input=${11}
    local table_index_max__input=${12}
    local flag_table_index_max_isFixed__input=${13}
    local outputFpath__input=${14}
    local tibboHeader_prepend_numOfLines__input=${15}
    local flag_show_tibboHeader_isEnabled__input=${16}



#---Define variables
    local fpath_arr=()
    local fpath_arrIndex=0
    local fpath_arrLen=0
    local fpath_arrItem="${DOCKER__EMPTYSTRING}"
    local fpath_arrItem_base="${DOCKER__EMPTYSTRING}"
    local fpath_arrItem_marked="${DOCKER__EMPTYSTRING}"
    local fpath_arrItem_conv="${DOCKER__EMPTYSTRING}"
    local fpath_arrItem_print="${DOCKER__EMPTYSTRING}"
    local fpath_arr_string="${DOCKER__EMPTYSTRING}"

    local fpath_arrTmp=()
    local fpath_arrTmpLen=0
    local fpath_arrTmp_string="${DOCKER__EMPTYSTRING}"

    #Relative array, which contains only the number of elements equal to 'table_index_max__input'.
    #This array is renewed with each loop.
    local fpath_relArr=()
    local fpath_relArrIndex=0
    local fpath_relArrIndex_sel=0
    local fpath_relArrLen=0
    local fpath_relArrItem_sel="${DOCKER__EMPTYSTRING}"

    local keyInput="${DOCKER__EMPTYSTRING}"
    local keyOutput="${DOCKER__EMPTYSTRING}"
    local pattern1_result="${DOCKER__EMPTYSTRING}"
    local pattern2_result="${DOCKER__EMPTYSTRING}"
    local ret="${DOCKER__EMPTYSTRING}"

    local table_index=0
    local table_index_base=0
    local table_index_base_try_next=0

    local table_index_max_bck=0

    local lineNum_range_relMax=0
    local lineNum_range_relMin=0
    local lineNum_range_msg_startPos=0
    local lineNum_range_msg_wo_regEx_len=0
    local lineNum_range_msg="${DOCKER__EMPTYSTRING}"

    local flag_break_main_whileLoop=false
    local flag_isSet_toBreak_loop=false
    local flag_matched_key_isPressed=false



#---Remove file (if present)
    if [[ -f ${outputFpath__input} ]]; then
        rm ${outputFpath__input}
    fi



#---Trim message to fit within the specified terminal window-size 'DOCKER__TABLEWIDTH'
    info__input=`trim_string_toFit_specified_windowSize__func "${info__input}" "${DOCKER__TABLEWIDTH}" "${DOCKER__TRUE}"`



#---Define 'prev' and 'next' variables
    local prev_only_print="${DOCKER__ONESPACE_PREV}"

    local oneSpacePrev_len=`get_stringlen_wo_regEx__func "${DOCKER__ONESPACE_PREV}"`
    local oneSpaceNext_len=`get_stringlen_wo_regEx__func "${DOCKER__ONESPACE_NEXT}"`
    local space_between_prev_and_next_len=$(( DOCKER__TABLEWIDTH - (oneSpacePrev_len + oneSpaceNext_len) - 1 ))
    local space_between_prev_and_next=`duplicate_char__func "${DOCKER__ONESPACE}" "${space_between_prev_and_next_len}"`
    local prev_spaces_next_print="${DOCKER__ONESPACE_PREV}${space_between_prev_and_next}${DOCKER__ONESPACE_NEXT}"

    local docker_space_between_leftBoundary_and_next_len=$(( DOCKER__TABLEWIDTH - oneSpacePrev_len - 1 ))
    local docker_space_between_leftBoundary_and_next=`duplicate_char__func "${DOCKER__ONESPACE}" "${docker_space_between_leftBoundary_and_next_len}"`

    local next_only_print="${docker_space_between_leftBoundary_and_next}${DOCKER__ONESPACE_NEXT}"



#---Retrieve array containing matching elements based on the specified patterns
    #Remarks:
    #   1. Only do this if 'path__input' is a directory.
    #   2. if 'path__input' is a file, then no matching required, in this case...
    #      ...just read the content of the file into array 'fpath_arrTmp'.
    if [[ -d ${path__input} ]]; then    #is a directory
        fpath_arrTmp_string=`retrieve_files_from_specified_dir_basedOn_matching_patterns__func "${path__input}" \
                            "${pattern1__input}" \
                            "${pattern2__input}"`

#-------Convert string to array
        read -a fpath_arrTmp <<< "${fpath_arrTmp_string}"
    else    #is a file or...
        if [[ -s ${path__input} ]]; then    #file contains data
            local path_numOfLines=`get_numOfLines_wo_emptyLines_in_file__func "${path__input}"`
            if [[ ${path_numOfLines} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
                readarray -t fpath_arrTmp < <(cat "${path__input}")
            fi
        fi
    fi



#---Get Length of 'fpath_arrTmp'
    fpath_arrTmpLen=${#fpath_arrTmp[@]}



#---Check if a match string 'selItem__input' is provided
    if [[ ${fpath_arrTmpLen} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
        if [[ ! -z ${selItem__input} ]]; then   #contains data
            #Rearrange array and place 'selItem__input' on top of the array.
            #Note: the output 'fpath_arr_string' is a string.
            fpath_arr_string=`array_find_and_move_element_toTop__func "${selItem__input}" "${fpath_arrTmp[@]}"`

            #Convert string to array
            #Remark:
            #   Even though the array has been re-arranged,
            #   still 'fpath_arr' will not be written to a file!
            read -a fpath_arr <<< "${fpath_arr_string}"
        else    #contains no data
            fpath_arr=("${fpath_arrTmp[@]}")
        fi
    fi

    #Get 'fpath_arrLen'
    fpath_arrLen=${#fpath_arr[@]}


#---Backup 'table_index_max__input'
    table_index_max_bck=${table_index_max__input}



#---Set 'table_index_max__input' (if needed)
    #Note: 
    #   The condition to check whether 'array contains no data' is preferred over...
    #   ...checking whether the 'array-length is zero', because...
    #   ...should the array contains empty lines then the array-length is non-zero.
    #   This is behavior is unwanted.
    if [[ ${flag_table_index_max_isFixed__input} == false ]]; then
        if [[ -z "${fpath_arr[@]}" ]]; then   #array contains no data
            table_index_max__input=${DOCKER__NUMOFLINES_5}
        else    #array contains data
            if [[ ${fpath_arrLen} -le ${DOCKER__NUMOFLINES_5} ]]; then
                table_index_max__input=${DOCKER__NUMOFLINES_5}
            else
                if [[ ${fpath_arrLen} -le ${table_index_max__input} ]]; then
                    table_index_max__input=${fpath_arrLen}
                fi
            fi
        fi
    fi



#---Calculate num-of-lines of input-args
    #non-fixed objects
    local tibboHeader_numOfLines=0
    if [[ ${flag_show_tibboHeader_isEnabled__input} == true ]]; then
        #Update 'fixed_numOfLines'<
        tibboHeader_numOfLines=$((tibboHeader_prepend_numOfLines__input + 1))  #due to title and 'tibboHeader_prepend_numOfLines__input'
    fi
    local menuTitle_numOfLines=`get_numOfLines_for_specified_string_or_file__func "${menuTitle__input}"`
    local remark_numOfLines=`get_numOfLines_for_specified_string_or_file__func "${remark__input}"`
    local info_numOfLines=`get_numOfLines_for_specified_string_or_file__func "${info__input}"`
    local menuOptions_numOfLines=`get_numOfLines_for_specified_string_or_file__func "${menuOptions__input}"`
    local readDialog_numOfLines=`get_numOfLines_for_specified_string_or_file__func "${readDialog__input}"`

    #fixed objects
    local fixed_numOfLines=${DOCKER__NUMOFLINES_4}    #due to a fixed number of horizontal and empty lines
    if [[ ${remark_numOfLines} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
        fixed_numOfLines=$((fixed_numOfLines + 1))  #due to the preceding horizontal line
    fi
    if [[ ${info_numOfLines} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
        fixed_numOfLines=$((fixed_numOfLines + 1))  #due to the preceding horizontal line
    fi
    if [[ ${menuOptions_numOfLines} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
        fixed_numOfLines=$((fixed_numOfLines + 1))  #due to the preceding horizontal line
    fi
    # if [[ ${menuOptions_numOfLines} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
    #     fixed_numOfLines=$((fixed_numOfLines + 1))  #due to the preceding empty line
    # fi

    #total
    local tot_numOfLines=$((tibboHeader_numOfLines + menuTitle_numOfLines + remark_numOfLines + info_numOfLines + menuOptions_numOfLines + readDialog_numOfLines + fixed_numOfLines + table_index_max__input))



#---Show directory content
    while true
    do
#-------Show cursor
        cursor_hide__func

#-------Disable keyboard-input
        disable_keyboard_input__func

#-------Show Tibbo-header
        if [[ ${flag_show_tibboHeader_isEnabled__input} == true ]]; then
            #Check if 'tibboHeader_prepend_numOfLines__input' is an Empty String
            if [[ -z ${tibboHeader_prepend_numOfLines__input} ]]; then
                tibboHeader_prepend_numOfLines__input=${DOCKER__NUMOFLINES_2}
            fi

            #Print Tibbo-title
            load_tibbo_title__func "${tibboHeader_prepend_numOfLines__input}"
        fi

#-------Show menu-title
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        show_centered_string__func "${menuTitle__input}" "${DOCKER__TABLEWIDTH}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        if [[ ! -z ${fpath_arr[@]} ]]; then
            #Initialization
            flag_isSet_toBreak_loop=false
            fpath_relArr=()
            fpath_relArrIndex=0
            fpath_arrIndex=0
            keyInput=0
            table_index=0

            #Loop thru array
            for fpath_arrItem in "${fpath_arr[@]}"
            do
                #Increment array-index
                fpath_arrIndex=$((fpath_arrIndex + 1))

                if [[ ${fpath_arrIndex} -gt ${table_index_base} ]]; then
                    #increment table-index
                    table_index=$((table_index + 1))

                    #Check if 'table_index = table_index_max__input'
                    #Remark:
                    #   If true, set 'table_index = 0'
                    if [[ ${table_index} -eq ${table_index_max_bck} ]]; then
                        table_index=${DOCKER__NUMOFMATCH_0}

                        flag_isSet_toBreak_loop=true
                    fi

#-------------------Get 'fpath_arrItem_base' without directory
                    if [[ -d ${path__input} ]]; then    #is a directory
                        fpath_arrItem_base=`basename ${fpath_arrItem}`  
                    else    #is a file
                        fpath_arrItem_base=${fpath_arrItem}
                    fi
        
#-------------------Convert 'SED_SUBST_SPACE' back to '<space>'
                    fpath_arrItem_conv=`echo "${fpath_arrItem_base}" | sed "s/${SED_SUBST_SPACE}/${DOCKER__ONESPACE}/g"`

#-------------------Increment relative index 'fpath_relArrIndex'
                    if [[ ${table_index} -eq ${DOCKER__NUMOFMATCH_0} ]]; then   #when a turnover has happened
                        fpath_relArrIndex=$((table_index_max__input - 1))
                    else    #in normal conditions
                        fpath_relArrIndex=$((table_index - 1))
                    fi

#-------------------Add 'fpath_arrItem_conv' to 'fpath_relArr'
                    #Remark:
                    #   This array contains only data which matches both patterns...
                    #   ...'pattern1__input' and 'pattern2__input'.
                    fpath_relArr[${fpath_relArrIndex}]=${fpath_arrItem_conv}

#-------------------Set 'fpath_arrItem_marked' (default)
                    fpath_arrItem_marked=${fpath_arrItem_conv}

#-------------------Mark the 1st array-element 'fpath_arrItem_marked' with 'DOCKER__BG_LIGHTSOFTYELLOW' (if applicable)
                    if [[ ${fpath_relArrIndex} -eq ${DOCKER__NUMOFMATCH_0} ]]; then #true
                        #Check if 'selItem__input' contains data?
                        if [[ ! -z ${selItem__input} ]]; then   #true
                            #Color 'fpath_arrItem_conv' if 'selItem__input != DOCKER__EMPTYSTRING'
                            fpath_arrItem_marked="${DOCKER__BG_LIGHTSOFTYELLOW}${fpath_arrItem_marked}${DOCKER__NOCOLOR}"
                        fi
                    fi

                    #Define and set 'fpath_arrItem_print'
                    if [[ ${table_index} -ne ${DOCKER__NUMOFMATCH_0} ]]; then
                        fpath_arrItem_print="${DOCKER__FOURSPACES}${table_index}. ${fpath_arrItem_marked}"
                    else
                        fpath_arrItem_print="${DOCKER__THREESPACES}${DOCKER__FG_LIGHTGREY}${DOCKER__LINENUM_1}${DOCKER__NOCOLOR}${table_index}. ${fpath_arrItem_marked}"
                    fi

                    # #Substitute 'http' with 'hxxp' (if present)
                    # #Remark:
                    # #   This substitution is required in order to eliminate the underlines for hyperlinks
                    # fpath_arrItem_print=`subst_string_with_another_string__func "${fpath_arrItem_print}" \
                    #         "${SED__HTTP}" \
                    #         "${SED__HXXP}"`
                                
                    #Show fpath_arrItem_conv
                    echo "${fpath_arrItem_print}"
                fi

                #Prevously 'table_index' was set to '0'.
                #This means that the maximum number of items allowed to-be-shown has been reached.
                #In this case, break the for-loop.
                if [[ ${flag_isSet_toBreak_loop} == true ]]; then
                    break
                fi
            done    #end of for
        else
            if [[ ! -z ${errMsg__input} ]]; then
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                show_centered_string__func "${errMsg__input}" "${DOCKER__TABLEWIDTH}"
            fi
        fi



#-------Get array-length
        fpath_relArrLen=${#fpath_relArr[@]}



#-------Fill up table with Empty Lines (if needed)
        #Check if 'flag_isSet_toBreak_loop = false'
        #Remark:
        #   Remember that if 'flag_isSet_toBreak_loop = true', then...
        #   ...the for-loop was broken due to 'table_index = table_index_max__input'.
        if [[ ${flag_isSet_toBreak_loop} == false ]]; then
            while [[ ${table_index} -lt ${table_index_max__input} ]]
            do
                #increment line-number
                table_index=$((table_index + 1))

                #Print an Empty Line
                echo ""${DOCKER__EMPTYSTRING}""
            done
        fi



#------Show 'prev' and 'next'
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        #Calculate the 'table_index_base_try_next'
        #Remark:
        #   By doing this it can be determined whether the last-page has been reached or not.
        table_index_base_try_next=$((table_index_base + table_index_max__input))

        #Check if the specified file contains less than or equal to 10 lines
        if [[ ${fpath_arrLen} -le ${table_index_max__input} ]]; then #less than 10 lines
            #Don't show anything
            echo -e "${EMPTYSTRING}"
        else    #file contains more than 10 lines
            if [[ ${table_index_base} -eq ${DOCKER__NUMOFMATCH_0} ]]; then   #range 1-10
                echo -e "${next_only_print}"
            else    #all other ranges
                if [[ ${table_index_base_try_next} -ge ${fpath_arrLen} ]]; then  #last range value (e.g. 40-50), assuming 50 is the last-index
                    echo -e "${prev_only_print}"
                else   #range 10-20, 20-30, 30-40, etc.
                    echo -e "${prev_spaces_next_print}"
                fi
            fi
        fi



#-------Show line-number range between 'prev' and 'next'
        lineNum_range_relMax=$((table_index_base + table_index_max__input))

        #Check if 'lineNum_range_relMax' has exceeded the maximum number array-items
        if [[ ${lineNum_range_relMax} -gt ${fpath_arrLen} ]]; then
            lineNum_range_relMax=${fpath_arrLen}
        fi

        #Check if 'fpath_arrLen = 0'
        if [[ ${fpath_arrLen} -eq ${DOCKER__NUMOFMATCH_0} ]]; then  #array contains no data
            lineNum_range_relMin=${DOCKER__LINENUM_0}
        else    #array contains data
            lineNum_range_relMin=$((table_index_base + 1))
        fi

        lineNum_range_max_abs=${fpath_arrLen}

        #Prepare the line-number range message
        lineNum_range_msg="${DOCKER__FG_LIGHTGREY}${lineNum_range_relMin}${DOCKER__NOCOLOR} "
        lineNum_range_msg+="to ${DOCKER__FG_LIGHTGREY}${lineNum_range_relMax}${DOCKER__NOCOLOR} "
        lineNum_range_msg+="(${DOCKER__FG_SOFTLIGHTRED}${lineNum_range_max_abs}${DOCKER__NOCOLOR})"

        # show_centered_string__func "${lineNum_range_msg}" "${DOCKER__TABLEWIDTH}"

        #Caclulate the length of 'lineNum_range_msg' without regEx
        lineNum_range_msg_wo_regEx_len=`get_stringlen_wo_regEx__func "${lineNum_range_msg}"`

        #Determine the start-position of where to place 'lineNum_range_msg'
        lineNum_range_msg_startPos=$(( (DOCKER__TABLEWIDTH/2) - (lineNum_range_msg_wo_regEx_len/2) ))

        #Move cursor to start-position 'lineNum_range_msg_startPos'
        tput cuu1 && tput cuf ${lineNum_range_msg_startPos}

        #Print 'lineNum_range_msg'
        echo -e "${lineNum_range_msg}"



#-------Show info & menu-options
        # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        info__input=`trim_string_toFit_specified_windowSize__func "${info__input}" \
                        "${DOCKER__TABLEWIDTH}" \
                        "${DOCKER__TRUE}"`
        if [[ ! -z ${info__input} ]]; then
            duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
            echo -e "${info__input}"
        fi
        if [[ ! -z ${remark__input} ]]; then
            duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
            echo -e "${remark__input}"
        fi
        if [[ ! -z ${menuOptions__input} ]]; then
            duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
            echo -e "${menuOptions__input}"
        fi
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"



#-------Enable keyboard-input
        enable_keyboard_input__func

#-------Show cursor
        cursor_show__func

#-------Read-input
        while true
        do
            #Show read-input
            read -N1 -p "${readDialog__input}" keyInput

            #Check if 'keyInput' is a numeric value
            case "${keyInput}" in
                ${DOCKER__ENTER})
                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                    ;;
                ${DOCKER__ESCAPED_HOOKLEFT})
                    #Only decrement if 'table_index_base > table_index_max__input'
                    #Remark:
                    #   Notice that 'table_index_base_try_next' is used here and NOT 'table_index_base'
                    if [[ ${table_index_base_try_next} -gt ${table_index_max__input} ]]; then
                        #Set the index-base value (e.g., 0,10,20,etc...)
                        table_index_base=$((table_index_base - table_index_max__input))

                        #Move-up and clean each line until the top of the table
                        moveUp_and_cleanLines__func "${tot_numOfLines}"

                        #Break this for-loop
                        break
                    else
                        moveToBeginning_and_cleanLine__func
                    fi

                    ;;
                ${DOCKER__ESCAPED_HOOKRIGHT})
                    #Only decrement if 'table_index_base_try_next < fpath_arrLen'
                    #Remark:
                    #   Notice that 'table_index_base_try_next' is used here and NOT 'table_index_base'
                    if [[ ${table_index_base_try_next} -lt ${fpath_arrLen} ]]; then
                        #Set the index-base value (e.g., 0,10,20,etc...)
                        table_index_base=$((table_index_base + table_index_max__input))

                        #Move-up and clean each line until the top of the table
                        moveUp_and_cleanLines__func "${tot_numOfLines}"

                        #Break this for-loop
                        break
                    else
                        moveToBeginning_and_cleanLine__func
                    fi
                    ;;
                ${DOCKER__ESCAPEKEY})
                    moveToBeginning_and_cleanLine__func

                    #Get the function-key 'keyOutput' based on the chosen 'keyInput'
                    keyOutput=`functionKey_detection__func "${keyInput}"`
                    case "${keyOutput}" in
                        # ${DOCKER__ENUM_FUNC_F12})
                        #     #Print read-input dialog with 'keyOutput' value
                        #     echo "${readDialog__input}"
                            
                        #     #Important: set flag to true
                        #     flag_matched_key_isPressed=true

                        #     # #Exit
                        #     # exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_2}"
                        #     ;;
                        "${DOCKER__EMPTYSTRING}") #arrow-key was pressed
                            flag_matched_key_isPressed=false
                            ;;
                        *)  #OTHER F-KEYS AS SPECIFIED BY 'matchPattern__input'
                            if [[ ! -z ${matchPattern__input} ]]; then  #not an Empty String             
                                #Check if the retrieved function-key 'keyOutput' matches the pattern 'matchPattern__input'
                                flag_matched_key_isPressed=`checkForMatch_of_a_pattern_within_string__func \
                                        "${keyOutput}" \
                                        "${matchPattern__input}"`

                                #Check if 'flag_matched_key_isPressed = true'
                                if [[ ${flag_matched_key_isPressed} == true ]]; then
                                     #Print read-input dialog with 'keyOutput' value
                                    echo "${readDialog__input}"
                                fi
                            fi
                            ;;
                    esac

                    #Check if a matched function-key was pressed
                    if [[ ${flag_matched_key_isPressed} == true ]]; then  #match was found
                        #Set output 'ret'
                        ret=${keyOutput}

                        #Break the main while-loop
                        flag_break_main_whileLoop=true

                        #Break this for-loop
                        break
                    fi
                    ;;
                *)
                    if [[ ${keyInput} =~ [1-90] ]]; then
                        #IMPORTANT: If 'keyInput = 0', then set 'keyInput = table_index_max__input'
                        if [[ ${keyInput} -eq ${DOCKER__NUMOFMATCH_0} ]]; then
                            keyInput=${table_index_max__input}
                        fi

                        #Only handle the following condition if 'keyInput =< fpath_relArrLen'
                        if [[ ${keyInput} -le ${fpath_relArrLen} ]]; then
                            #If 'keyInput = 0', then set 'keyInput = table_index_max__input'
                            #Remark:
                            #   This part is actually not necessary since it has been executed already previously.
                            if [[ ${keyInput} -eq ${DOCKER__NUMOFMATCH_0} ]]; then
                                keyInput=${table_index_max__input}
                            fi

                            #Convert to array-index
                            #Remark:
                            #   -1 is a correction due to array starting with 'index = 0'
                            fpath_relArrIndex_sel=$(( keyInput - 1 ))

                            #Get the selected 'fpath_relArrItem_sel'
                            fpath_relArrItem_sel="${fpath_relArr[fpath_relArrIndex_sel]}"

                            #Determine the output 'ret' based on whether 'path__input' is a 'directory' or 'file' 
                            if [[ -d ${path__input} ]]; then    #directory
                                ret=${path__input}/${fpath_relArrItem_sel}
                            else    #file
                                ret=${fpath_relArrItem_sel}
                            fi

                            #Move-down and clean lines
                            # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_3}"

                            #Break the main while-loop
                            flag_break_main_whileLoop=true

                            #Break this for-loop
                            break
                        else
                            moveToBeginning_and_cleanLine__func
                        fi             
                    else    #any other keys
                        #'matchPattern__input' could contain any keys other than function-keys or numbers [1-90]
                        #Remark:
                        #   This part has been tested, but NOT thoroughly.                
                        if [[ ! -z ${matchPattern__input} ]]; then  #not an Empty String
                            #Check if the retrieved function-key 'keyInput' matches the pattern 'matchPattern__input'
                            flag_matched_key_isPressed=`checkForMatch_of_a_pattern_within_string__func \
                                    "${keyInput}" \
                                    "${matchPattern__input}"`

                            #Check if a matched function-key was pressed
                            if [[ ${flag_matched_key_isPressed} == true ]]; then  #match was found
                                #Set output 'ret'
                                ret=${keyInput}

                                #Break the main while-loop
                                flag_break_main_whileLoop=true

                                #Break this for-loop
                                break
                            fi
                        fi

                        moveToBeginning_and_cleanLine__func
                    fi
                    ;;
            esac
        done    #end of while

        #Check if 'flag_break_main_whileLoop = true'
        if [[ ${flag_break_main_whileLoop} == true ]]; then
            break
        fi
    done    #end of main while



#---Output
    #write to line-number: 1
    echo "${ret}" > ${outputFpath__input}

    #write to line-number: 2
    #Remark:
    #   This may be useful in case the whole table needs to be cleared...
    #   ...which was drawn by this subroutine 'show_pathContent_w_selection__func'.
    echo "${tot_numOfLines}" >> ${outputFpath__input}
}

function show_fileContent_wo_select__func() {
#---Input args
    local fpath__input=${1}
    local menuTitle__input=${2}
    local remark__input=${3}
    local info__input=${4}
    local menuOptions__input=${5}
    local errMsg__input=${6}
    local readDialog__input=${7}
    local regEx__input=${8}
    local outputFpath__input=${9}
    local table_index_max__input=${10}
    local menuTitle_indent__input=${11}  #leading spaces to-be-added before 'menuTitle__input'
    local flag_pressAnyKey_isEnabled=${12}
    local tibboHeader_prepend_numOfLines__input=${13}
    local flag_show_tibboHeader_isEnabled__input=${14}



#---Define variables
    local fpath_arr=()
    local fpath_arrIndex=0
    local fpath_arrLen=0
    local fpath_arrItem="${DOCKER__EMPTYSTRING}"

    local keyInput="${DOCKER__EMPTYSTRING}"
    local keyOutput="${DOCKER__EMPTYSTRING}"

    local table_index=0
    local table_index_base=0
    local table_index_base_try_next=0

    local flag_break_main_whileLoop=false
    local flag_isSet_toBreak_loop=false



#---Remove file (if present)
    if [[ -f ${outputFpath__input} ]]; then
        rm ${outputFpath__input}
    fi



#---Trim message to fit within the specified terminal window-size 'DOCKER__TABLEWIDTH'
    info__input=`trim_string_toFit_specified_windowSize__func "${info__input}" "${DOCKER__TABLEWIDTH}" "${DOCKER__TRUE}"`



#---Define 'prev' and 'next' variables
    local prev_only_print="${DOCKER__ONESPACE_PREV}"

    local oneSpacePrev_len=`get_stringlen_wo_regEx__func "${DOCKER__ONESPACE_PREV}"`
    local oneSpaceNext_len=`get_stringlen_wo_regEx__func "${DOCKER__ONESPACE_NEXT}"`
    local space_between_prev_and_next_len=$(( DOCKER__TABLEWIDTH - (oneSpacePrev_len + oneSpaceNext_len) - 1 ))
    local space_between_prev_and_next=`duplicate_char__func "${DOCKER__ONESPACE}" "${space_between_prev_and_next_len}"`
    local prev_spaces_next_print="${DOCKER__ONESPACE_PREV}${space_between_prev_and_next}${DOCKER__ONESPACE_NEXT}"

    local docker_space_between_leftBoundary_and_next_len=$(( DOCKER__TABLEWIDTH - oneSpacePrev_len - 1 ))
    local docker_space_between_leftBoundary_and_next=`duplicate_char__func "${DOCKER__ONESPACE}" "${docker_space_between_leftBoundary_and_next_len}"`
    local next_only_print="${docker_space_between_leftBoundary_and_next}${DOCKER__ONESPACE_NEXT}"



#---Store directory content in array'
    if [[ -s ${fpath__input} ]]; then   #file contains data
        local path_numOfLines=`get_numOfLines_wo_emptyLines_in_file__func "${fpath__input}"`
        if [[ ${path_numOfLines} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
            readarray -t fpath_arr < ${fpath__input}
        fi
    fi



#---Get 'fpath_arrLen'
    fpath_arrLen=${#fpath_arr[@]}



#---Set 'table_index_max__input' (if needed)
    #Note: 
    #   The condition to check whether 'array contains no data' is preferred over...
    #   ...checking whether the 'array-length is zero', because...
    #   ...should the array contains empty lines then the array-length is non-zero.
    #   This is behavior is unwanted.
    if [[ -z "${fpath_arr[@]}" ]]; then   #array contains no data
        table_index_max__input=${DOCKER__NUMOFLINES_5}
    else    #array contains data
        if [[ ${fpath_arrLen} -le ${DOCKER__NUMOFLINES_5} ]]; then
            table_index_max__input=${DOCKER__NUMOFLINES_5}
        else
            if [[ ${fpath_arrLen} -le ${table_index_max__input} ]]; then
                table_index_max__input=${fpath_arrLen}
            fi
        fi
    fi



#---Calculate num-of-lines of input-args
    #non-fixed objects
    local tibboHeader_numOfLines=0
    if [[ ${flag_show_tibboHeader_isEnabled__input} == true ]]; then
        #Update 'fixed_numOfLines'<
        tibboHeader_numOfLines=$((tibboHeader_prepend_numOfLines__input + 1))  #due to title and 'tibboHeader_prepend_numOfLines__input'
    fi
    menuTitle_numOfLines=`get_numOfLines_for_specified_string_or_file__func "${menuTitle__input}"`
    remark_numOfLines=`get_numOfLines_for_specified_string_or_file__func "${remark__input}"`
    info_numOfLines=`get_numOfLines_for_specified_string_or_file__func "${info__input}"`
    menuOptions_numOfLines=`get_numOfLines_for_specified_string_or_file__func "${menuOptions__input}"`
    readDialog_numOfLines=`get_numOfLines_for_specified_string_or_file__func "${readDialog__input}"`

    #fixed objects
    fixed_numOfLines=${DOCKER__NUMOFLINES_4}    #due to a fixed number of horizontal and empty lines
    if [[ ${remark_numOfLines} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
        fixed_numOfLines=$((fixed_numOfLines + 1))  #due to the preceding horizontal line
    fi
    if [[ ${info_numOfLines} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
        fixed_numOfLines=$((fixed_numOfLines + 1))  #due to the preceding horizontal line
    fi
    if [[ ${menuOptions_numOfLines} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
        fixed_numOfLines=$((fixed_numOfLines + 1))  #due to the preceding horizontal line
    fi
    if [[ ${flag_pressAnyKey_isEnabled} == true ]]; then
        fixed_numOfLines=$((fixed_numOfLines + 1))  #due to the preceding horizontal line
    fi
    # if [[ ${flag_pressAnyKey_isEnabled} == true ]]; then
    #     fixed_numOfLines=$((fixed_numOfLines + 1))  #due to the preceding empty line
    # fi

    #total
    tot_numOfLines=$((tibboHeader_numOfLines + menuTitle_numOfLines + remark_numOfLines + info_numOfLines + menuOptions_numOfLines + readDialog_numOfLines + fixed_numOfLines + table_index_max__input))



#---Show directory content
    while true
    do
#-------Show cursor
        cursor_hide__func

#-------Disable keyboard-input
        disable_keyboard_input__func

#-------Show Tibbo-header
        if [[ ${flag_show_tibboHeader_isEnabled__input} == true ]]; then
            #Check if 'tibboHeader_prepend_numOfLines__input' is an Empty String
            if [[ -z ${tibboHeader_prepend_numOfLines__input} ]]; then
                tibboHeader_prepend_numOfLines__input=${DOCKER__NUMOFLINES_2}
            fi

            #Print Tibbo-title
            load_tibbo_title__func "${tibboHeader_prepend_numOfLines__input}"
        fi

#-------Show menu-title
        # duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        show_menuTitle_w_adjustable_indent__func "${menuTitle__input}" "${menuTitle_indent__input}"
        # duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        if [[ ! -z ${fpath_arr[@]} ]]; then
            #Initialization
            flag_isSet_toBreak_loop=false
            fpath_arrIndex=0
            keyInput=0
            table_index=0

            #Loop thru array
            for fpath_arrItem in "${fpath_arr[@]}"
            do
                #Increment array-index
                fpath_arrIndex=$((fpath_arrIndex + 1))

                #Turn
                if [[ ${fpath_arrIndex} -gt ${table_index_base} ]]; then
                    #increment table-index
                    table_index=$((table_index + 1))

                    #Check if 'table_index = table_index_max__input'
                    #Remark:
                    #   If true, set 'table_index = 0'
                    if [[ ${table_index} -eq ${table_index_max__input} ]]; then
                        table_index=${DOCKER__NUMOFMATCH_0}

                        flag_isSet_toBreak_loop=true
                    fi

                    #Print fpath_arrItem
                    # echo "${DOCKER__FOURSPACES}${fpath_arrItem}"
                    echo "${fpath_arrItem}"
                fi

                #Prevously 'table_index' was set to '0'.
                #This means that the maximum number of items allowed to-be-shown has been reached.
                #In this case, break the for-loop.
                if [[ ${flag_isSet_toBreak_loop} == true ]]; then
                    break
                fi
            done    #end of for
        else
            if [[ ! -z ${errMsg__input} ]]; then
                moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                show_centered_string__func "${errMsg__input}" "${DOCKER__TABLEWIDTH}"
            fi
        fi



#-------Fill up table with Empty Lines (if needed)
        #Check if 'flag_isSet_toBreak_loop = false'
        #Remark:
        #   Remember that if 'flag_isSet_toBreak_loop = true', then...
        #   ...the for-loop was broken due to 'table_index = table_index_max__input'.
        if [[ ${flag_isSet_toBreak_loop} == false ]]; then
            while [[ ${table_index} -lt ${table_index_max__input} ]]
            do
                #increment line-number
                table_index=$((table_index + 1))

                #Print an Empty Line
                echo ""${DOCKER__EMPTYSTRING}""
            done
        fi



#------Show 'prev' and 'next'
        moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

        #Calculate the 'table_index_base_try_next'
        #Remark:
        #   By doing this it can be determined whether the last-page has been reached or not.
        table_index_base_try_next=$((table_index_base + table_index_max__input))

        #Check if the specified file contains less than or equal to 10 lines
        if [[ ${fpath_arrLen} -le ${table_index_max__input} ]]; then #less than 10 lines
            #Don't show anything
            echo -e "${EMPTYSTRING}"
        else    #file contains more than 10 lines
            if [[ ${table_index_base} -eq ${DOCKER__NUMOFMATCH_0} ]]; then   #range 1-10
                echo -e "${next_only_print}"
            else    #all other ranges
                if [[ ${table_index_base_try_next} -ge ${fpath_arrLen} ]]; then  #last range value (e.g. 40-50), assuming 50 is the last-index
                    echo -e "${prev_only_print}"
                else   #range 10-20, 20-30, 30-40, etc.
                    echo -e "${prev_spaces_next_print}"
                fi
            fi
        fi


#-------Show line-number range between 'prev' and 'next'
        lineNum_range_relMax=$((table_index_base + table_index_max__input))
        #Check if 'lineNum_range_relMax' has exceeded the maximum number array-items
        if [[ ${lineNum_range_relMax} -gt ${fpath_arrLen} ]]; then
            lineNum_range_relMax=${fpath_arrLen}
        fi

        #Check if 'fpath_arrLen = 0'
        if [[ ${fpath_arrLen} -eq ${DOCKER__NUMOFMATCH_0} ]]; then  #array contains no data
            lineNum_range_relMin=${DOCKER__LINENUM_0}
        else    #array contains data
            lineNum_range_relMin=$((table_index_base + 1))
        fi

        lineNum_range_max_abs=${fpath_arrLen}

        #Prepare the line-number range message
        lineNum_range_msg="${DOCKER__FG_LIGHTGREY}${lineNum_range_relMin}${DOCKER__NOCOLOR} "
        lineNum_range_msg+="to ${DOCKER__FG_LIGHTGREY}${lineNum_range_relMax}${DOCKER__NOCOLOR} "
        lineNum_range_msg+="(${DOCKER__FG_SOFTLIGHTRED}${lineNum_range_max_abs}${DOCKER__NOCOLOR})"

        # show_centered_string__func "${lineNum_range_msg}" "${DOCKER__TABLEWIDTH}"

        #Caclulate the length of 'lineNum_range_msg' without regEx
        lineNum_range_msg_wo_regEx_len=`get_stringlen_wo_regEx__func "${lineNum_range_msg}"`

        #Determine the start-position of where to place 'lineNum_range_msg'
        lineNum_range_msg_startPos=$(( (DOCKER__TABLEWIDTH - lineNum_range_msg_wo_regEx_len)/2 ))

        #Move cursor to start-position 'lineNum_range_msg_startPos'
        tput cuu1 && tput cuf ${lineNum_range_msg_startPos}

        #Print 'lineNum_range_msg'
        echo -e "${lineNum_range_msg}"



#-------Show info
        # moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        if [[ ! -z ${info__input} ]]; then
            duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
            #Trim 'info__input' (if necessary)
            info__input=`trim_string_toFit_specified_windowSize__func "${info__input}" \
                            "${DOCKER__TABLEWIDTH}" \
                            "${DOCKER__TRUE}"`
            echo -e "${info__input}"
        fi
#-------Show remark
        if [[ ! -z ${remark__input} ]]; then
            duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
            echo -e "${remark__input}"
        fi
#-------Show menu-options
        if [[ ! -z ${menuOptions__input} ]]; then
            duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
            echo -e "${menuOptions__input}"
        fi
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"


#-------Enable keyboard-input
        enable_keyboard_input__func


#-------Show cursor
        cursor_show__func


#-------Check if 'flag_pressAnyKey_isEnabled = true'
        if [[ "${flag_pressAnyKey_isEnabled}" == true ]]; then
            #Check if array 'fpath_arr' contains data
            #Note: 
            #   The condition to check whether 'array contains no data' is preferred over...
            #   ...checking whether the 'array-length is zero', because...
            #   ...should the array contains empty lines then the array-length is non-zero.
            #   This is behavior is unwanted.
            if [[ -z "${fpath_arr[@]}" ]]; then   #array contains no data
                return
            else    #array contains data
                if [[ ${fpath_arrLen} -le ${table_index_max__input} ]]; then
                    return
                fi
            fi
        fi


#-------Read-input
        while true
        do
            #Show read-input
            read -N1 -r -p "${readDialog__input}" keyInput

            #Check if 'keyInput' is a numeric value
            case "${keyInput}" in
                ${DOCKER__ENTER})
                    #Check if 'flag_pressAnyKey_isEnabled = true'
                    #Remark:
                    #   If true, then exit upon pressing Enter.
                    if [[ ${flag_pressAnyKey_isEnabled} == true ]]; then
                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"

                        return
                    fi

                    moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                    ;;
                ${DOCKER__ESCAPED_HOOKLEFT})
                    #Only decrement if 'table_index_base > table_index_max__input'
                    #Remark:
                    #   Notice that 'table_index_base_try_next' is used here and NOT 'table_index_base'
                    if [[ ${table_index_base_try_next} -gt ${table_index_max__input} ]]; then
                        #Set the index-base value (e.g., 0,10,20,etc...)
                        table_index_base=$((table_index_base - table_index_max__input))

                        #Move-up and clean each line until the top of the table
                        moveUp_and_cleanLines__func "${tot_numOfLines}"

                        #Break this for-loop
                        break
                    else
                        moveToBeginning_and_cleanLine__func
                    fi

                    ;;
                ${DOCKER__ESCAPED_HOOKRIGHT})
                    #Only decrement if 'table_index_base_try_next < fpath_arrLen'
                    #Remark:
                    #   Notice that 'table_index_base_try_next' is used here and NOT 'table_index_base'
                    if [[ ${table_index_base_try_next} -lt ${fpath_arrLen} ]]; then
                        #Set the index-base value (e.g., 0,10,20,etc...)
                        table_index_base=$((table_index_base + table_index_max__input))

                        #Move-up and clean each line until the top of the table
                        moveUp_and_cleanLines__func "${tot_numOfLines}"

                        #Break this for-loop
                        break
                    else
                        moveToBeginning_and_cleanLine__func
                    fi
                    ;;
                # ${DOCKER__ESCAPEKEY})
                #     moveToBeginning_and_cleanLine__func

                #     #Get the function-key which was pressed
                #     keyOutput=`functionKey_detection__func "${keyInput}"`

                #     #Check if 'flag_pressAnyKey_isEnabled = true'
                #     #Remarks:
                #     #   1. If true, then exit upon pressing other function-keys (F1 to F12)
                #     #   2. In order to remove the unwanted escaped chars,...
                #     #      ...function 'functionKey_detection__func' should be executed...
                #     #      ...BEFORE this condtion, 
                #     if [[ ${flag_pressAnyKey_isEnabled} == true ]]; then
                #         return
                #     fi

                #     #Check if function-key F12 was pressed
                #     if [[ ${keyOutput} == ${DOCKER__ENUM_FUNC_F12} ]]; then
                #         #Print read-input dialog
                #         echo "${readDialog__input}"

                #         #Update 'keyInput'
                #         keyInput=${keyOutput}

                #         #Break the main while-loop
                #         flag_break_main_whileLoop=true

                #         #Break this for-loop
                #         break                   

                #         # #Exit
                #         # exit__func "${DOCKER__EXITCODE_0}" "${DOCKER__NUMOFLINES_2}"
                #     fi
                #     ;;
                *)
                    #Check if 'flag_pressAnyKey_isEnabled = true'
                    #Remark:
                    #   If true, then exit upon pressing any other keys (e.g., a,b,@,etc...)
                    if [[ ${flag_pressAnyKey_isEnabled} == true ]]; then
                        moveToBeginning_and_cleanLine__func

                        return
                    fi

                    if [[ ${keyInput} =~ ${regEx__input} ]]; then
                            # if [[ ${keyInput} =~ [yn] ]]; then
                            #     moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_2}"
                            # else
                            #     moveDown_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
                            # fi

                            #Break the main while-loop
                            flag_break_main_whileLoop=true

                            #Break this for-loop
                            break
                    else
                        moveToBeginning_and_cleanLine__func
                    fi
                    ;;
            esac
        done    #end of while

        #Check if 'flag_break_main_whileLoop = true'
        if [[ ${flag_break_main_whileLoop} == true ]]; then
            break
        fi
    done    #end of main while



#---Output
    #Write to file
    echo "${keyInput}" > ${outputFpath__input}  
}



#---STRING FUNCTIONS
function append_a_specified_numofchars_to_string() {
    #Input Args
    local string__input=${1}
    local char__input=${2}
    local string_maxlen__input=${3}

    #Define variables
    local string_len=${#string__input}
    local ret="${string__input}"

    #Append 
    while [[ ${string_len} -lt ${string_maxlen__input} ]]
    do
        #Append char
        ret="${ret}${char__input}"

        #Get string length
        string_len=${#ret}
    done

    #Output
    echo "${ret}"

    return 0;
}

function checkForMatch_of_a_pattern_within_string__func() {
    #Turn-off Expansion
    disable_expansion__func

    #Input Args
    local pattern__input=${1}
    local string__input=${2}

    #Find any match (not exact)
    local stdOutput=`echo "${string__input}" | grep "${pattern__input}"`
    if [[ -z ${stdOutput} ]]; then  #no match
        echo "false"
    else    #match
        echo "true"
    fi

    #Turn-on Expansion
    enable_expansion__func
}



function checkForExactMatch_of_a_pattern_within_file__func() {
    #Turn-off Expansion
    disable_expansion__func

    #Input Args
    local pattern__input=${1}
    local dataFpath__input=${2}

    #Check if file exists
    if [[ ! -s ${dataFpath__input} ]]; then #does not exist
        echo "false"

        return
    fi

    #Find match
    local isFound=`cat ${dataFpath__input} | grep "^${pattern__input}$"`
    if [[ -z ${isFound} ]]; then  #no match
        echo "false"
    else    #match
        echo "true"
    fi

    #Turn-on Expansion
    enable_expansion__func
}

function checkForMatch_dockerCmd_result__func() {
    #Input Args
    local pattern__input=${1}
    local dockerCmd__input=${2}
    local dockerTableColno__input=${3}

    #Find any match (not exact)
    local stdOutput=`${dockerCmd__input} | awk -v COLNUM=${dockerTableColno__input} '{print $COLNUM}' | grep -w ${pattern__input}`
    if [[ -z ${stdOutput} ]]; then  #no match
        echo "false"
    else    #match
        echo "true"
    fi
}

function checkForMatch_of_a_pattern_within_file__func() {
    #Turn-off Expansion
    disable_expansion__func

    #Input Args
    local pattern__input=${1}
    local dataFpath__input=${2}

    #Check if file exists
    if [[ ! -s ${dataFpath__input} ]]; then #does not exist
        echo "false"

        return
    fi

    #Find match
    local isFound=`cat "${dataFpath__input}" | grep "${pattern__input}"`
    if [[ -z ${isFound} ]]; then  #no match
        echo "false"
    else    #match
        echo "true"
    fi

    #Turn-on Expansion
    enable_expansion__func
}

function checkForMatch_of_patterns_within_file__func() {
    #Turn-off Expansion
    disable_expansion__func

    #Input Args
    local pattern1__input=${1}
    local pattern2__input=${2}
    local dataFpath__input=${3}

    #Check if file exists
    if [[ ! -f ${dataFpath__input} ]]; then #does not exist
        echo "false"

        return
    fi

    #Compose command line
    local cmd="cat ${dataFpath__input}"
    if [[ ! -z ${pattern1__input} ]]; then
        cmd+=" | grep -w \"${pattern1__input}\""
    fi
    if [[ ! -z ${pattern2__input} ]]; then
        cmd+=" | grep -w \"${pattern2__input}\""
    fi

    #Find match
    local isFound=`eval "${cmd}"`
    if [[ -z ${isFound} ]]; then  #no match
        echo "false"
    else    #match
        echo "true"
    fi

    #Turn-on Expansion
    enable_expansion__func
}

function checkForMatch_of_a_pattern_of_a_column_within_file__func() {
    #Turn-off Expansion
    disable_expansion__func

    #Input Args
    local targetString__input=${1}
    local pattern__input=${2}
    local col__input=${3}
    local dataFpath__input=${4}

    #Compose command line
    local matchString=`cat "${dataFpath__input}" | grep -w "${pattern__input}" | awk -v COLNUM="${col__input}" '{print $COLNUM}'`
    
    #Check if 'col3_string = targetString__input' 
    if [[ "${matchString}" == "${targetString__input}" ]]; then  #no match
        echo "true"
    else    #match
        echo "false"
    fi

    #Turn-on Expansion
    enable_expansion__func
}

function checkForMatch_multi_patterns_under_specified_columns_within_file__func() {
    #Turn-off Expansion
    disable_expansion__func

    #Input Args
    local targetString1__input=${1}
    local pattern1__input=${2}
    local col1__input=${3}
    local targetString2__input=${4}
    local pattern2__input=${5}
    local col2__input=${6}
    local dataFpath__input=${7}

    #FIRST MATCH: check if a match can be found for 'targetString1__input'
   local  match1_isFound=`checkForMatch_of_a_pattern_of_a_column_within_file__func "${targetString1__input}" \
        "${pattern1__input}" \
        "${col1__input}" \
        "${dataFpath__input}"`    

    #SECOND MATCH: check if a match can be found for 'targetString2__input'
    local match2_isFound=`checkForMatch_of_a_pattern_of_a_column_within_file__func "${targetString2__input}" \
        "${pattern2__input}" \
        "${col2__input}" \
        "${dataFpath__input}"`    

    #Output
    if [[ ${match1_isFound} == true ]] && [[ ${match2_isFound} == true ]]; then
        echo "true"
    else
        echo "false"
    fi

    #Turn-on Expansion
    enable_expansion__func
}

function checkForMatch_of_a_word_within_file__func() {
    #Turn-off Expansion
    disable_expansion__func

    #Input Args
    local pattern__input=${1}
    local dataFpath__input=${2}

    #Check if file exists
    if [[ ! -s ${dataFpath__input} ]]; then #does not exist
        echo "false"

        return
    fi

    #Find match
    local isFound=`cat "${dataFpath__input}" | grep -w "${pattern__input}"`
    if [[ -z ${isFound} ]]; then  #no match
        echo "false"
    else    #match
        echo "true"
    fi

    #Turn-on Expansion
    enable_expansion__func
}

function checkIf_string_contains_a_leading_specified_chars__func() {
    #Note:
    #   Regarding 'backslashes', whenever 'backslashes' are passed into a function...
    #   these 'backslashes' will be ESCAPED.
    #Example:
    #   passed into function: \\\\
    #   received by function:   \\
    #Input args
    local string__input=${1}
    local numOfChars__input=${2}
    local keyWord__input=${3}

    #Get the first char(s)
    local firstChars=`get_first_nChars_ofString__func "${string__input}" "${numOfChars__input}"`

    #Compare
    #Note: 
    #   It is important to 'double-quote' the variables which are going to be compared.
    #Reason:
    #   If 'double-quotes' are NOT used, comparing variables might fail.
    #Example:
    #   firstChars=\\
    #   keyWord__input=\\
    #   When no 'double-quotes' are used comparing these 2 variables would fail.
    if [[ "${firstChars}" == "${keyWord__input}" ]]; then
        echo "true"
    else
        echo "false"
    fi
}

function checkIf_string_contains_a_trailing_specified_chars__func() {
    #Note:
    #   Regarding 'backslashes', whenever 'backslashes' are passed into a function...
    #   these 'backslashes' will be ESCAPED.
    #Example:
    #   passed into function: \\\\
    #   received by function:   \\
	#Input args
	local string__input=${1}
    local numOfChars__input=${2}
    local keyWord__input=${3}

    #Check if 'string__input' already has a trailing slash
    local string_len=${#string__input}
    local lastChar_pos=$((string_len - numOfChars__input))

    #Get the last char(s)
    local lastChars=${string__input:lastChar_pos:string_len}

    #Compare
    #Note: 
    #   It is important to 'double-quote' the variables which are going to be compared.
    #Reason:
    #   If 'double-quotes' are NOT used, comparing variables might fail.
    #Example:
    #   firstChars=\\
    #   keyWord__input=\\
    #   When no 'double-quotes' are used comparing these 2 variables would fail.
    if [[ "${lastChars}" == "${keyWord__input}" ]]; then
        echo "true"
    else
        echo "false"
    fi
}

function checkIf_string_contains_nonSpace_chars__func() {
    #Turn-off Expansion
    set -f

    #Input Args
    local string__input=${1}

    #Remove all spaces from string
    local str_wo_spaces="${string__input//${DOCKER__ONESPACE}}"

    #Check if 'string_input' contains spaces only
    if [[ -z "${str_wo_spaces}" ]]; then
        echo "false"
    else
        echo "true"
    fi

    #Turn-on Expansion
    set +f
}

function checkIf_string_contains_only_specified_regEx__func() {
    #Input args
    local string__input=${1}
    local regex__input=${2}

    #Check if 'string__input' contains only chars specified by 'regEx'
    if [[ ${string__input} =~ ${regex__input} ]]; then
        echo "true"
    else
        echo "false"
    fi
}

function count_numOfChar_within_string__func() {
    #Input Args
    local string__input=${1}
    local pattern__input=${2}

    #Count
    local ret=`echo "${string__input}" | grep -o "${pattern__input}" | wc -l`

    #Output
    echo "${ret}"

}

function delete_lineNum_from_file__func() {
    #Input args
    local lineNum__input=${1}
    local excludeVal__input=${2}
    local targetfpath__input=${3}

    #Check if 'lineNum__input = 0'
    if [[ ${lineNum__input} -eq ${DOCKER__NUMOFMATCH_0} ]]; then
        return
    fi

    #Check if 'targetfpath__input' does NOT exist
    if [[ ! -f ${targetfpath__input} ]]; then
        return
    fi

    #Get the 'line' for 'lineNum__input'
    local line=`retrieve_line_from_file__func "${lineNum__input}" "${targetfpath__input}"`

    #Delete line-number
    if [[ "${line}" != "${excludeVal__input}" ]]; then
        sed -i "${lineNum__input}d" ${targetfpath__input}
    fi
}

function duplicate_char__func() {
    #Input args
    local char__input=${1}
    local numOfTimes__input=${2}

    #Duplicate 'char__input'
    local ret=`printf '%*s' "${numOfTimes__input}" | tr ' ' "${char__input}"`

    #Print text including Leading Empty Spaces
    echo -e "${ret}"
}

function get_char_at_specified_position__func() {
    #Input Args
    local string__input=${1}
    local pos__input=${2}

    #Calculate the 'index'
    #Remark:
    #   The 'index' starts with '0'.
    local index=0
    if [[ ${pos__input} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
        index=$((pos__input - 1))
    fi

    #Get the first character
    local ret=${string__input:index:1}    

    #Output
    echo -e "${ret}"
}

function get_endResult_ofString_with_semiColonChar__func() {
    #Input args
    local string__input=${1}

    #Define variables
    local adjacentChar="${DOCKER__EMPTYSTRING}"
    local leftPart="${DOCKER__EMPTYSTRING}"
    local rightPart="${DOCKER__EMPTYSTRING}"
    local ret="${DOCKER__EMPTYSTRING}"

    local abortIsFound=false
    local backIsFound=false
    local clearIsFound=false
    local finishIsFound=false
    local homeIsFound=false
    local redoIsFound=false
    local skipIsFound=false

    local rightPart_len=0

    #Check if ';a' is found.
    #If TRUE, then return 'DOCKER__SEMICOLON_ABORT'
    abortIsFound=`checkForMatch_of_a_pattern_within_string__func "${DOCKER__SEMICOLON_ABORT}" "${string__input}"`
    if [[ ${abortIsFound} == true ]]; then
        ret="${DOCKER__SEMICOLON_ABORT}"

        echo "${ret}"
        
        return
    fi

    #Check if ';f' is found
    #If TRUE, then return 'DOCKER__SEMICOLON_FINISH'
    finishIsFound=`checkForMatch_of_a_pattern_within_string__func "${DOCKER__SEMICOLON_FINISH}" "${string__input}"`
    if [[ ${finishIsFound} == true ]]; then
        ret=${DOCKER__SEMICOLON_FINISH}

        echo "${ret}"

        return
    fi

    #Check if ';f' is found
    #If TRUE, then return 'DOCKER__SEMICOLON_REDO'
    redoIsFound=`checkForMatch_of_a_pattern_within_string__func "${DOCKER__SEMICOLON_REDO}" "${string__input}"`
    if [[ ${redoIsFound} == true ]]; then
        ret=${DOCKER__SEMICOLON_REDO}

        echo "${ret}"

        return
    fi

    #Check if ';s' is found
    #If TRUE, then return 'DOCKER__SEMICOLON_SKIP'
    skipIsFound=`checkForMatch_of_a_pattern_within_string__func "${DOCKER__SEMICOLON_SKIP}" "${string__input}"`
    if [[ ${skipIsFound} == true ]]; then
        ret=${DOCKER__SEMICOLON_SKIP}

        echo "${ret}"

        return
    fi

    #Check if ';h' is found
    #If TRUE, then return 'DOCKER__SEMICOLON_HOME'
    homeIsFound=`checkForMatch_of_a_pattern_within_string__func "${DOCKER__SEMICOLON_HOME}" "${string__input}"`
    if [[ ${homeIsFound} == true ]]; then
        ret=${DOCKER__SEMICOLON_HOME}

        echo "${ret}"
        
        return
    fi

    #Check if ';b' is found
    #If TRUE, then return 'DOCKER__SEMICOLON_BACK'
    backIsFound=`checkForMatch_of_a_pattern_within_string__func "${DOCKER__SEMICOLON_BACK}" "${string__input}"`
    if [[ ${backIsFound} == true ]]; then
        ret=${DOCKER__SEMICOLON_BACK}

        echo "${ret}"

        return
    fi

    #Check if ';c' is found.
    #If FALSE, then return the original 'string__input'.
    clearIsFound=`checkForMatch_of_a_pattern_within_string__func "${DOCKER__SEMICOLON_CLEAR}" "${string__input}"`
    if [[ ${clearIsFound} == false ]]; then
        ret="${string__input}"

        echo "${ret}"
        
        return
    fi

    #If (;c) was found previously then, retrieve the substring which is on the right-side of the semi-colon (;).
    #Remark:
    #   In case there were multiple (;c)' issued and thus residing in 'string__input',...
    #   ...then just make sure to get the substring at the last semi-colon (;).
    rightPart=`echo "${string__input}" | rev | cut -d";" -f1 | rev`

    rightPart_len=${#rightPart}

    #Get string without semicolon.
    #Remark:
    #   Please note that if result 'ret' contains any leading and trailing spaces,...
    #   ...then these spaces will be removed and therefore not included in the output.
    ret=${rightPart:1:rightPart_len}

    #Output
    echo "${ret}"
}

function get_numOfLines_for_specified_string_or_file__func() {
    #Input args
    local param__input=${1}

    #Get number of lines
    local ret=${DOCKER__NUMOFLINES_0}
    if [[ ! -f ${param__input} ]]; then    #not a file
        ret=`echo -e "${param__input}" | sed '/^\s*$/d' | wc -l`
    else    #is a file
        #Check if file exists
        if [[ ! -f ${param__input} ]]; then #does not exist
            ret=${DOCKER__NUMOFLINES_0}
        else
            ret=`cat "${param__input}" | sed '/^\s*$/d' | wc -l`
        fi
    fi

    #Output
    echo "${ret}"
}

function get_stringlen_wo_regEx__func() {
    #Input args
    local string__input=${1} 

    #Get string without color regex. 
    local string_wo_regEx=$(printf "%s" "${string__input}" | sed "s/$(echo -e "\e")[^m]*m//g")

    #Get length
    local string_wo_regEx_len=${#string_wo_regEx}

    #Output
    echo "${string_wo_regEx_len}"
}

function get_first_nChars_ofString__func() {
    #Input args
    local string__input=${1}
    local numOfChars__input=${2}

    #Define local variable
    local ret=${string__input:0:numOfChars__input}

    #Output
    echo "${ret}"
}

function get_last_nChars_ofString__func() {
    #Input args
    local string__input=${1}
    local numOfChars__input=${2}

    #Define local variable
    local ret=${string__input: -numOfChars__input}

    #Output
    echo "${ret}"
}

function insert_string_at_specified_lineNum_in_file__func() {
    #Input args
    local string__input=${1}
    local lineNum__input=${2}
    local targetfpath__input=${3}
    local flag_checkIf_already_inserted__input=${4}

    #Check if 'string__input' is found in file 'targetfpath__input'
    local isFound=false
    if [[ ${flag_checkIf_already_inserted__input} == true ]]; then
        isFound=`checkForExactMatch_of_a_pattern_within_file__func "${string__input}" "${targetfpath__input}"`
        if [[ ${isFound} == true ]]; then
            return
        fi
    fi

    #Get number of lines of 'targetfpath__input'
    local targetFpath_numOfLines=`get_numOfLines_for_specified_string_or_file__func "${targetfpath__input}"`

    #Check if file contains data
    #If true, then insert
    #If false, then just write
    if [[ -s ${targetfpath__input} ]]; then #contains data
        #Check if 'targetfpath__input' contains at least the number of lines equal or greater than 'lineNum__input'
        if [[ ${targetFpath_numOfLines} -ge ${lineNum__input} ]]; then
            sed -i "${lineNum__input}i${string__input}" ${targetfpath__input}   #insert at 'lineNum__input'
        else
            echo "${string__input}" >> ${targetfpath__input}    #append
        fi
    else    #contains no data
        echo "${string__input}" > ${targetfpath__input}
    fi
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

function prepend_backSlash_inFrontOf_specialChars__func() {
	#Input args
	local string__input=${1}
    local flag_enableExcludes__input=${2}

	#Define excluding chars
	local SED_EXCLUDES="${DOCKER__DOTSLASH}"

	#Prepend a backslash '\' in front of any special chars execpt for chars specified by 'SED_EXCLUDES'
    local ret="${DOCKER__EMPTYSTRING}"
    if [[ ${flag_enableExcludes__input} == true ]]; then
	    ret=`echo "${string__input}" | sed "s/[^[:alnum:]${SED_EXCLUDES}]/${SED__BACKSLASH}&/g"`
    else
        ret=`echo "${string__input}" | sed "s/[^[:alnum:]]/${SED__BACKSLASH}&/g"`
    fi

	#Output
	echo "${ret}"
}

function remove_trailing_char__func() {
    #Input args
    local string__input=${1}
	local char__input=${2}

    #Get string without trailing specified char
	#REMARK:
	#	char__input: character to be removed
	#	REMARK: 
	#		Make sure to prepend escape-char '\' if needed
	#		For example: slash '/' prepended with escape-char becomes '\/')
	#	*: all of specified 'char__input' value
	#	$: start from the end
	local ret=`echo "${string__input}" | sed s"/${char__input}*$//g"`

    #Output
    echo -e "${ret}"
}

function remove_whiteSpaces__func() {
    #Input args
    local orgString__input=${1}
    
    #Remove white spaces
    local ret=`echo -e "${orgString__input}" | tr -d "[:blank:]"`

    #Output
    echo -e "${ret}"
}

function replace_or_append_string_based_on_pattern_in_file__func() {
    #Input args
    local string__input=${1}
    local pattern__input=${2}
    local targetfpath__input=${3}
    local onlywrite_if_pattern_isfound__input=${4}  #by default is false (0)

    #Check if file exists
    #Note: if false, then add string to file.
    if [[ ! -f "${targetfpath__input}" ]]; then #file does NOT exist
        #Write to file
        echo -e "${string__input}" | tee ${targetfpath__input} >/dev/null

        #Exit
        return 0;
    fi

    #Check if 'pattern__input' is found in file 'targetfpath__input'
    #...and get the 'line' containing this 'pattern__input'.
    local line=$(grep -F "${pattern__input}" "${targetfpath__input}")
    if [[ -n "${line}" ]]; then
        sed -i "s/${line}/${string__input}/g" ${targetfpath__input}
    else
        if [[ ${onlywrite_if_pattern_isfound__input} == false ]]; then
            echo -e "${string__input}" | tee -a ${targetfpath__input} >/dev/null
        fi
    fi
}

function replace_string_with_another_string_in_file__func() {
    #Input args
    local sed_oldstring__input=${1}
    local sed_newstring__input=${2}
    local targetfpath__input=${3}

    #Check if file exists
    if [[ ! -f "${targetfpath__input}" ]]; then #file does NOT exist
        return 0;
    fi

    #Replace 
    sed -i "s/${sed_oldstring__input}/${sed_newstring__input}/g" ${targetfpath__input}
}

function retrieve_data_specified_by_col_within_2Darray__func() {
	#Input args
	local inString__input=${1}
    local outString_col__input=${2}
    shift
    shift
    local dataArr__input=("$@")

	#Define variables
	local dataArrItem="${DOCKER__EMPTYSTRING}"
	local ret="${DOCKER__EMPTYSTRING}"
	local stdOutput="${DOCKER__EMPTYSTRING}"

	for dataArrItem in "${dataArr__input[@]}"
	do
		#Check if'inString__input' is found in 'dataArrItem'
		stdOutput=`echo "${dataArrItem}" | grep "${inString__input}"`
		if [[ ! -z ${stdOutput} ]]; then	#match was found
			#Get data in the 2nd column
			ret=`echo "${stdOutput}" | awk -v COLNUM="${outString_col__input}" '{print $COLNUM}'`

			break
		fi
	done

	#Output
	echo "${ret}"
}

function retrieve__data_specified_by_col_within_file__func() {
    #----------------------------------------------------------------------
    # Note: 
    #   If 'char__input' is NOT present within the specified 'string__input'
    #   then this function will output an Empty String. 
    #----------------------------------------------------------------------
    #Input args
    local inString__input=${1}
    local outString_col__input=${2}
    local targetfpath__input=${3}

    #Find 'pattern__input'
    local line=`cat ${targetfpath__input} | grep "${inString__input}"`

    #Get data
    # local ret=`echo "${line}" | awk -v COLNUM="${outString_col__input}" '{print $COLNUM}'`
    local ret=$(grep -F "${inString__input}" ${targetfpath__input} | awk -vCOL="${outString_col__input}" '{print $COL}')

    #Output
    echo "${ret}"
}


function retrieve_line_from_file__func() {
    #Input args
    local lineNum__input=${1}
    local targetfpath__input=${2}

    #Define variable
    local ret="${DOCKER__EMPTYSTRING}"

    #Check if 'lineNum__input = 0'
    if [[ ${lineNum__input} -eq ${DOCKER__NUMOFMATCH_0} ]]; then
        return
    fi

    #Check if 'targetfpath__input' does NOT exist
    if [[ ! -f ${targetfpath__input} ]]; then
        return
    fi


    #Retrieve line based on the specified 'lineNum__input'
    local ret=`sed "${lineNum__input}q;d" ${targetfpath__input}`

    #Output
    echo "${ret}"
}

function retrieve_lineNum_from_file__func() {
    #Input args
    local line__input=${1}
    local targetfpath__input=${2}

    #Define variables
    local ret=0

    #Check if 'targetfpath__input' contains data
    if [[ -s ${targetfpath__input} ]]; then #contains data
        #Retrieve line-number based on the specified 'line__input'
        ret=`cat ${targetfpath__input} | grep -n "^${line__input}$" | cut -d":" -f1`

        #Check if 'ret' is an Empty String
        if [[ -z ${ret} ]]; then    #true
            ret=0
        fi
    fi

    #Output
    echo "${ret}"    
}

function retrieve_subStrings_delimited_by_lastChar_within_string__func() {
    #----------------------------------------------------------------------
    # Note: 
    #   If 'char__input' is NOT present within the specified 'string__input'
    #   then this function will output an Empty String. 
    #----------------------------------------------------------------------
    #Input args
    local string__input=${1}
    local char__input=${2}

    #Define variables
    local char_isFound=false
    local ret_left=${EMPTYSTRING}
    local ret_right=${EMPTYSTRING}
    local ret=${EMPTYSTRING}

    #Check if 'char__input' is found in 'string__input'
    local char_isFound=`checkForMatch_of_a_pattern_within_string__func "${char__input}" "${string__input}"`

    #Retrieve the sub-string which is on the left-side of the specified 'char__input'.
    if [[ ${char_isFound} == true ]]; then
        ret_left=`echo "${string__input}" | rev | cut -d"${char__input}" -f2- | rev`
        ret_right=`echo "${string__input}" | rev | cut -d"${char__input}" -f1 | rev`
    fi

    #Output
    #1. ret_left
    #2. ret_right
    #Both results are delimited by 'SED__RS'
    echo "${ret_left}${SED__RS}${ret_right}"
}

function subst_char_with_another_char__func() {
    #Input args
    local string__input=${1}
    local charOld__input=${2}
    local charNew__input=${3}

    #Replace
    local ret=`echo "${string__input}" | sed "s/${charOld__input}/${charNew__input}/g"`

	#Output
	echo "${ret}"
}

function subst_multiple_chars_with_single_char__func() {
    #Input args
    local string__input=${1}
    local charOld__input=${2}
    local charNew__input=${3}

    #Replace
    local ret=`echo "${string__input}" | sed "s/${charOld__input}${charOld__input}*/${charNew__input}/g"`

	#Output
	echo "${ret}"
}

function subst_trailing_char_with_another_char__func() {
    #Input args
    local string__input=${1}
    local charOld__input=${2}
    local charNew__input=${3}

    #Replace
    local ret=`echo "${string__input}" | sed "s/${charOld__input}$/${charNew__input}/g"`

	#Output
	echo "${ret}"
}

function trim_string_toFit_specified_windowSize__func() {
    #Input args
    local string__input=${1}
    local tableSize__input=${2}
    local flag_enableColor__input=${3}

    #Define variables
    local constStr="${DOCKER__EMPTYSTRING}"
    local dotdot_print=${DOCKER__DOTDOT}
    local leadingStr="${DOCKER__EMPTYSTRING}"
    local leadingStr_lastChar="${DOCKER__EMPTYSTRING}"
    local leadingStr_left="${DOCKER__EMPTYSTRING}"
    local leadingStr_right="${DOCKER__EMPTYSTRING}"
    local ret="${DOCKER__EMPTYSTRING}"
    local slash_print=${DOCKER__SLASH}
    local slas_dotdot_Slash_print=${DOCKER__SLASH_DOTDOT_SLASH}
    local trailingStr="${DOCKER__EMPTYSTRING}"
    local trailingStr_left="${DOCKER__EMPTYSTRING}"
    local trailingStr_right="${DOCKER__EMPTYSTRING}"

    local leadingStr_len=0
    local numOfTrailingChars=0
    local numOfSlashes=0
    local string_len=0
    local trailingStr_len=0
    local trailingStr_left_len=0
    local trailingStr_right_len=0
    local totStr_len=0

    local isDirectory=false
    local isFile=false

    #Check if 'flag_enableColor__input = true'
    if [[ ${flag_enableColor__input} == true ]]; then
        slash_print=${DOCKER__COLOR_SLASH}
        slas_dotdot_Slash_print=${DOCKER__COLOR_SLASH_DOTDOT_SLASH}
        dotdot_print=${DOCKER__COLOR_DOTDOT}
    fi

    #Get length of 'string__input'
    string_len=`get_stringlen_wo_regEx__func "${string__input}"`

    #Check if 'string_len <= tableSize__input'
    if [[ ${string_len} -le ${tableSize__input} ]]; then
        echo "${string__input}"

        return
    fi

    #Check if 'string__input' is a path?
    if [[ -d ${string__input} ]] || [[ -f ${string__input} ]]; then   #true
        #Replace multiple slashes with a single slash (/)
        string__input=`subst_multiple_chars_with_single_char__func "${string__input}" \
                        "${DOCKER__ESCAPED_SLASH}" \
                        "${DOCKER__ESCAPED_SLASH}"`
    fi

    #Retrieve the number of slashes '/''
    numOfSlashes=`count_numOfChar_within_string__func "${string__input}" "${DOCKER__SLASH}"`

    #Select case based on the number of slashes
    case "${numOfSlashes}" in
        ${DOCKER__NUMOFMATCH_0})
            leadingStr="${DOCKER__EMPTYSTRING}"
            ;;
        ${DOCKER__NUMOFMATCH_1})
            leadingStr_left=`echo "${string__input}" | cut -d"${DOCKER__SLASH}" -f1`
            leadingStr=${leadingStr_left}${slash_print}
            ;;
        ${DOCKER__NUMOFMATCH_2})
            leadingStr_left=`echo "${string__input}" | cut -d"${DOCKER__SLASH}" -f1`
            leadingStr_right=`echo "${string__input}" | cut -d"${DOCKER__SLASH}" -f2`
            leadingStr=${leadingStr_left}${slash_print}${leadingStr_right}${slash_print}
            ;;
        *)
            leadingStr_left=`echo "${string__input}" | cut -d"${DOCKER__SLASH}" -f1`
            leadingStr_right=`echo ${string__input} | rev | cut -d"/" -f2- | cut -d"/" -f1 | rev`
            leadingStr="${leadingStr_left}${slas_dotdot_Slash_print}${leadingStr_right}${slash_print}"
            ;;   
    esac

    #Get string on the right-side of the last slash
    trailingStr=`echo ${string__input} | rev | cut -d"${DOCKER__SLASH}" -f1 | rev`

    #Get lengths
    trailingStr_len=`get_stringlen_wo_regEx__func "${trailingStr}"`
    leadingStr_len=`get_stringlen_wo_regEx__func "${leadingStr}"`

    #Calculate the total length
    totStr_len=$((leadingStr_len + trailingStr_len))

    #Check if 'totStr_len > tableSize__input'
    if [[ ${totStr_len} -gt ${tableSize__input} ]]; then
        #Recalculate 'trailingStr_len'
        trailingStr_len=$((tableSize__input - leadingStr_len))

        #Calculate the lenght of 'trailingStr_left'
        #Note: -1 due to 1 dot which will replace the trailing char of 'trailingStr_left'
        trailingStr_left_len=$(( (trailingStr_len/2) - 2 )) 

        #Calculate the lenght of 'trailingStr_right'
        #Note: -1 due to 1 dot which will replace the leading char of 'trailingStr_right'
        trailingStr_right_len=$(( (trailingStr_len/2) - 1 )) 

        #Get 'trailingStr_left'
        trailingStr_left=`get_first_nChars_ofString__func "${trailingStr}" "${trailingStr_left_len}"`

        #Get 'trailingStr_right'
        trailingStr_right=`get_last_nChars_ofString__func "${trailingStr}" "${trailingStr_right_len}"`

        #Get 'trailingStr'
        trailingStr="${trailingStr_left}${dotdot_print}${trailingStr_right}"

    fi

    #Compose the output string
    ret="${leadingStr}${trailingStr}"

    #Output
    echo "${ret}"
}

function skip_and_correct_unwanted_chars__func() {
    #---------------------------------------------------------------------
    # Remarks:
    #   The allowed chars are specified by the provided regex 
	#		'DOCKER__REGEX_0_TO_9_COMMA_DASH'.
    #   Should there be any unwanted char found within 'string__input', 
    #   	then this unwanted char is skipped.
    #---------------------------------------------------------------------
    #Input args
    local string__input=${1}

    #Define variables
	local char="${DOCKER__EMPTYSTRING}"
	local dash_isFound=false
	local index=0
    local ret="${DOCKER__EMPTYSTRING}"
    local string_noSpaces="${DOCKER__EMPTYSTRING}"
	local string_filtered="${DOCKER__EMPTYSTRING}"
	local string_final="${DOCKER__EMPTYSTRING}"
	local string_leftOfComma="${DOCKER__EMPTYSTRING}"
	local string_remain="${DOCKER__EMPTYSTRING}"
	local string_singleComma="${DOCKER__EMPTYSTRING}"
	local string_singleDash="${DOCKER__EMPTYSTRING}"
	local string_leftOfDash="${DOCKER__EMPTYSTRING}"
	local string_rightOfDash="${DOCKER__EMPTYSTRING}"

    #Step 1.1: remove all spaces
    string_noSpaces=`echo "${string__input}" | sed 's/ //g'`
    
	#Step 1.2: remove all multiple commas
    string_singleComma=`echo "${string_noSpaces}" | sed "s/${DOCKER__COMMA}${DOCKER__COMMA}*/${DOCKER__COMMA}/g"`

	#Step 1.3: remove all multiple dashes
    string_singleDash=`echo "${string_singleComma}" | sed "s/${DOCKER__DASH}${DOCKER__DASH}*/${DOCKER__DASH}/g"`

    #Step 2: check each 'char' of 'string__input'..
	#...and filter out unwanted chars
    for (( index=1; index<=${#string_singleDash}; index++ ))
    do
		#Get 'char'
		char=${string_singleDash:index-1:1}

		#Check if 'char' is wanted or unwanted
		if [[ ${char} =~ ${DOCKER__REGEX_0_TO_9_COMMA_DASH} ]]; then	#wanted
			string_filtered="${string_filtered}${char}"
		fi
    done	#end of while

	#Step 3: Check each substring delimited by a comma ','
	string_remain=${string_filtered}

    while true
    do
        #Get the index(es) on the left-side of the comma ','
        string_leftOfComma=`echo "${string_remain}" | cut -d"${DOCKER__COMMA}" -f1`
        if [[ ! -z ${string_leftOfComma} ]]; then  #contains data
            #Check if a dash '-' is found in 'string_leftOfComma'
            dash_isFound=`checkForMatch_of_a_pattern_within_string__func "${DOCKER__DASH}" "${string_leftOfComma}"`
            if [[ ${dash_isFound} == false ]]; then #dash not found
				#Append to 'string_final'
				string_final="${string_final}${DOCKER__COMMA}${string_leftOfComma}"
            else    #dash was found
                #Get the minimum and maximum range values
                string_leftOfDash=`echo "${string_leftOfComma}" | cut -d"${DOCKER__DASH}" -f1`
                string_rightOfDash=`echo "${string_leftOfComma}" | cut -d"${DOCKER__DASH}" -f2`

				#Check if 'string_leftOfDash' OR 'string_rightOfDash' is contains data
				if [[ ! -z ${string_leftOfDash} ]] || [[ ! -z ${string_rightOfDash} ]]; then	#one or the other is true
					#Check if 'string_leftOfDash' is an Empty String
					if [[ -z ${string_leftOfDash} ]]; then	#true
						string_leftOfDash=${string_rightOfDash}
					fi

					#Check if 'string_rightOfDash' is an Empty String
					if [[ -z ${string_rightOfDash} ]]; then	#true
						string_rightOfDash=${string_leftOfDash}
					fi

					#Append to 'string_final' ONLY if 'string_leftOfDash <= string_rightOfDash'
					if [[ ${string_leftOfDash} -le ${string_rightOfDash} ]]; then
						string_final="${string_final}${DOCKER__COMMA}${string_leftOfDash}${DOCKER__DASH}${string_rightOfDash}"
					fi
				fi
            fi
        fi

        #Get the remaining indexes which are on the right-side of the comma ','
        string_remain=`echo "${string_remain}" | cut -d"${DOCKER__COMMA}" -f2-`

        #Exit when 'string_leftOfComma = string_remain'
        #Remark:
        #   This means that there are no comma's left anymore.
        if [[ "${string_remain}" == "${string_leftOfComma}" ]]; then
            break
        fi
    done

	#Remove leading comma
	ret=`echo "${string_final}" | sed "s/^\${DOCKER__COMMA}//g"`

	#remove trailing comma
	ret=`echo "${ret}" | sed "s/${DOCKER__COMMA}$//g"`

    #Output
    echo "${ret}"
}

function xtract_indexes_from_a_rangeAndOrGroup_in_descendingOrder__func() {
    #---------------------------------------------------------------------
    # Remarks:
    #   The allowed chars are specified by the provided regex 
	#		'DOCKER__REGEX_0_TO_9_COMMA_DASH'.
    #   Should there be any unwanted char found within 'string__input', 
    #   	then this unwanted char is skipped.
    #   The following 'string__input' notation are allowed:
    #       1,2,3,etc...
    #       1-10
    #       Combination: 1,2,3,1-10
    #---------------------------------------------------------------------
    #input args
    local string__input=${1}

    #Define variables
    local index_xtracted_arr=()
    local index_xtracted_arrIndex=0

    local dataArrItem="${DOCKER__EMPTYSTRING}"
    local string_leftOfComma="${DOCKER__EMPTYSTRING}"
    local string_remain="${DOCKER__EMPTYSTRING}"
    local ret="${DOCKER__EMPTYSTRING}"

    local counter=0
    local index_range_min=0
    local index_range_max=0
    local index_revalidated=0

    local dash_isFound=false

    #Recheck 'string__input' and allow only chars specified by regex 'DOCKER__REGEX_0_TO_9_COMMA_DASH'
    index_revalidated=`skip_and_correct_unwanted_chars__func "${string__input}" "${DOCKER__REGEX_0_TO_9_COMMA_DASH}"`

    #Initialization
    string_remain=${index_revalidated}

    #Extract the indexes from 'index_revalidated'
    while true
    do
        #Get the index(es) on the left-side of the comma ','
        string_leftOfComma=`echo "${string_remain}" | cut -d"${DOCKER__COMMA}" -f1`
        if [[ ! -z ${string_leftOfComma} ]]; then  #contains data
            #Check if a dash '-' is found in 'string_leftOfComma'
            dash_isFound=`checkForMatch_of_a_pattern_within_string__func "${DOCKER__DASH}" "${string_leftOfComma}"`
            if [[ ${dash_isFound} == false ]]; then #dash not found
                #Add 'string_leftOfComma' to array 'index_xtracted_arr'
                index_xtracted_arr[${index_xtracted_arrIndex}]=${string_leftOfComma}

                #Increment array-index
                index_xtracted_arrIndex=$((index_xtracted_arrIndex + 1))
            else    #dash was found
                #Get the minimum and maximum range values
                index_range_min=`echo "${string_leftOfComma}" | cut -d"${DOCKER__DASH}" -f1`
                index_range_max=`echo "${string_leftOfComma}" | cut -d"${DOCKER__DASH}" -f2`

                #Add indexes to array 'index_xtracted_arr' in the range of 'index_range_min to index_range_max'
                #Note: the values 'index_range_min' and 'index_range_max' included.
                for (( counter=${index_range_min}; counter<=${index_range_max}; counter+=1 )); do
                    #Add 'counter' to array 'index_xtracted_arr'
                    index_xtracted_arr[${index_xtracted_arrIndex}]=${counter}

                    #Increment array-index
                    index_xtracted_arrIndex=$((index_xtracted_arrIndex + 1))
                done
            fi
        fi

        #Get the remaining indexes which are on the right-side of the comma ','
        string_remain=`echo "${string_remain}" | cut -d"${DOCKER__COMMA}" -f2-`

        #Exit when 'string_leftOfComma = string_remain'
        #Remark:
        #   This means that there are no comma's left anymore.
        if [[ "${string_remain}" == "${string_leftOfComma}" ]]; then
            break
        fi
    done

    #Steps:
    #1. Read 'index_xtracted_arr' value: echo "${index_xtracted_arr[@]}"
    #2. Flip result from horizontal to vertical: xargs -n1
    #3. (IMPORTANT) Sort numerical values(n) in descending order(r):  sort -nr
    #4. remove double-entries(u): uniq
    #5. Flip result from vertical back to horizontal: xargs -n1
    ret=`echo "${index_xtracted_arr[@]}" | xargs -n1 | sort -rn | uniq | xargs`
    
    #Output as string
    echo "${ret}"
}



#---SUNPLUS-RELATED
function retrieve_env_var_checkout_from_file__func() {
    #Input args
    local dockerfile_fpath__input=${1}
    local exported_env_var_fpath__input=${2}

    #Get the repository:tag from 'dockerfile_fpath__input'
    local dockerfile_fpath_repositoryTag=`retrieve_repositoryTag_from_dockerfile__func "${dockerfile_fpath__input}"`

    #Get the 'checkout' from file 'exported_env_var_fpath__input' (3rd column)
    local ret=`cat ${exported_env_var_fpath__input} | grep -w "${dockerfile_fpath_repositoryTag}" | awk '{print $3}'`

    #Output
    echo "${ret}"
}
function retrieve_env_var_link_from_file__func() {
    #Input args
    local dockerfile_fpath__input=${1}
    local exported_env_var_fpath__input=${2}

    #Get the repository:tag from 'dockerfile_fpath__input'
    local dockerfile_fpath_repositoryTag=`retrieve_repositoryTag_from_dockerfile__func "${dockerfile_fpath__input}"`

    #Get the 'link' from file 'exported_env_var_fpath__input' (2nd column)
    local ret=`cat ${exported_env_var_fpath__input} | grep -w "${dockerfile_fpath_repositoryTag}" | awk '{print $2}'`

    #Output
    echo "${ret}"
}

function subst_string_with_another_string__func() {
    #Input args
    local string__input=${1}
    local oldSubString__input=${2}
    local newSubString__input=${3}

    #Substitute
    local ret=`echo "${string__input}" | sed "s/${oldSubString__input}/${newSubString__input}/g"`

    #Output
    echo "${ret}"
}

function update_exported_env_var__func() {
    #Input args
    local docker_arg1__input=${1}
    local docker_arg2__input=${2}
    local dockerfile_fpath__input=${3}
    local exported_env_var_fpath__input=${4}

    #Define Message Constants
    local ERRMSG_DOCKERFILE_NOT_FOUND="${DOCKER__ERROR}: Dockerfile '${dockerFile__input}' not found"
    local ERRMSG_EXPORTEDFILE_NOT_FOUND="${DOCKER__ERROR}: Environment variable file '${exported_env_var_fpath__input}' not found"

    #Get repository:tag from file
    local dockerfile_fpath_repositoryTag="${DOCKER__EMPTYSTRING}"
    if [[ -s ${dockerfile_fpath__input} ]]; then
        dockerfile_fpath_repositoryTag=`retrieve_repositoryTag_from_dockerfile__func "${dockerfile_fpath__input}"`
    else
        show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_DOCKERFILE_NOT_FOUND}" "${DOCKER__NUMOFLINES_1}"
    fi

    #Check if file exist
    if [[ -s ${exported_env_var_fpath__input} ]]; then
        #Check if 'dockerfile_fpath_repositoryTag' is already present in file
        repository_tag_lineNum=`cat ${exported_env_var_fpath__input} | grep -nw "${dockerfile_fpath_repositoryTag}" | cut -d"${DOCKER__COLON}" -f1`
        #If present, then remove line containing the 'dockerfile_fpath_repositoryTag'
        if [[ ${repository_tag_lineNum} -gt ${DOCKER__NUMOFMATCH_0} ]]; then
            #Check if 'docker_arg1__input' is an Empty String
            #Note: this means that 'docker_arg2__input' was changed.
            if [[ -z ${docker_arg1__input} ]]; then
                docker_arg1__input=`cat ${exported_env_var_fpath__input} | grep "${dockerfile_fpath_repositoryTag}" | awk '{print $2}'`
            fi

            #Check if 'docker_arg2__input' is an Empty String
            #Note: this means that 'docker_arg1__input' was changed.
            if [[ -z ${docker_arg2__input} ]]; then
                docker_arg2__input=`cat ${exported_env_var_fpath__input} | grep "${dockerfile_fpath_repositoryTag}" | awk '{print $3}'`
            fi

            #Remove current entry in 'exported_env_var.txt'
            sed -i "${repository_tag_lineNum}d" ${exported_env_var_fpath__input}
        fi

        #Add the new data to file 'docker__exported_env_var__fpath' as follows:
        #   dockerfile_fpath_repositoryTag<space>docker_arg1__input<space>DOCKER_ARG2__input
        #Remark:
        #   1. This data will be retrieved in 'docker__create_an_image_from_dockerfile.sh' and 'docker_create_images_from_dockerlist.sh'
        #   2. This means that 'input args' will not be used in those two mentioned files.
        echo "${dockerfile_fpath_repositoryTag} ${docker_arg1__input} ${docker_arg2__input}" >> ${exported_env_var_fpath__input}
    else
        show_msg_wo_menuTitle_w_PressAnyKey__func "${ERRMSG_EXPORTEDFILE_NOT_FOUND}" "${DOCKER__NUMOFLINES_1}"
    fi
}

function retrieve_repositoryTag_from_dockerfile__func() {
    #Input args
    local dockerfile_fpath__input=${1}

    #Retrieve repository:tag
    local ret=`egrep -w "${DOCKER__PATTERN_REPOSITORY_TAG}" ${dockerfile_fpath__input} | cut -d"\"" -f2`

    #Output
    echo "${ret}"
}

#---WEB-RELATED
function checkIf_webLink_isAccessible__func() {
    #Input args
    local webLink__input=${1}
    local timeout__input=${2}

    #Check if 'webLink__input' is reachable
    local response=`timeout ${timeout__input} curl --silent --head --location --output /dev/null --write-out '%{http_code}' ${webLink__input}`
    if [[ ${response} -eq ${DOCKER__HTTP_200} ]]; then
        echo "true"
    else
        echo "false"
    fi
}



#---SUBROUTINES
trap docker__ctrl_c__sub SIGINT

docker__ctrl_c__sub() {
    
    # #Turn-on Expansion
    # enable_expansion__func
    
    # #Show mouse cursor
    # cursor_show__func

    # #Enable keyboard-input
    # enable_keyboard_input__func

    #Unset variables
    exit__func "${DOCKER__EXITCODE_99}" "${DOCKER__NUMOFLINES_2}"
}

docker__get_source_fullpath__sub() {
    #Define constants
    DOCKER__PHASE_CHECK_CACHE=1
    DOCKER__PHASE_FIND_PATH=10
    DOCKER__PHASE_EXIT=100

    #Define variables
    docker__phase=""

    docker__current__dir=""
    docker__parent__dir=""
    docker__search__dir=""
    docker__tmp__dir=""

    docker__development_tools__foldername=""
    docker__LTPP3_ROOTFS__foldername=""
    docker__global__filename=""
    locaocker__parentDir_of_LTPP3_ROOTFS__dir=""

    docker__mainmenu_path_cache__filename=""
    docker__mainmenu_path_cache__fpath=""

    docker__find_dir_result__arr=()
    docker__find_dir_result__arritem=""

    docker__path_of_development_tools__found=""
    docker__parentpath_of_development__tools=""

    docker__isfound=""

    docker__retry_ctr=0

    #Update variables
    docker__bin_bash__dir=/bin/bash
    docker__current__dir=$(dirname $(readlink -f $0))
    docker__parent__dir="$(dirname "${docker__current__dir}")"
    docker__tmp__dir=/tmp

    docker__development_tools__foldername="development_tools"
    docker__global__filename="docker_global.sh"
    docker__LTPP3_ROOTFS__foldername="LTPP3_ROOTFS"

    docker__mainmenu_path_cache__filename="docker__mainmenu_path.cache"
    docker__mainmenu_path_cache__fpath="${docker__tmp__dir}/${docker__mainmenu_path_cache__filename}"

    #Initialize variables
    docker__phase="${DOCKER__PHASE_CHECK_CACHE}"
    docker__result=false


    #Start loop
    while true
    do
        case "${docker__phase}" in
            "${DOCKER__PHASE_CHECK_CACHE}")
                if [[ -f "${docker__mainmenu_path_cache__fpath}" ]]; then
                    #Get the directory stored in cache-file
                    docker__LTPP3_ROOTFS_development_tools__dir=$(awk 'NR==1' "${docker__mainmenu_path_cache__fpath}")

                    #Move one directory up
                    docker__parentpath_of_development__tools=$(dirname "${docker__LTPP3_ROOTFS_development_tools__dir}")

                    #Check if 'development_tools' is in the 'LTPP3_ROOTFS' folder
                    docker__isfound=$(docker__checkif_paths_are_related "${docker__current__dir}" \
                            "${docker__parentpath_of_development__tools}" "${docker__LTPP3_ROOTFS__foldername}")
                    if [[ ${docker__isfound} == false ]]; then
                        docker__phase="${DOCKER__PHASE_FIND_PATH}"
                    else
                        docker__result=true

                        docker__phase="${DOCKER__PHASE_EXIT}"
                    fi
                else
                    docker__phase="${DOCKER__PHASE_FIND_PATH}"
                fi
                ;;
            "${DOCKER__PHASE_FIND_PATH}")   
                #Print
                echo -e "---:\e[30;38;5;215mSTART\e[0;0m: find path of folder \e[30;38;5;246m'${docker__development_tools__foldername}\e[0;0m"

                #Initialize variables
                docker__LTPP3_ROOTFS_development_tools__dir=""
                docker__search__dir="${docker__current__dir}"   #start with search in the current dir

                #Start loop
                while true
                do
                    #Get all the directories containing the foldername 'LTPP3_ROOTFS'...
                    #... and read to array 'find_result_arr'
                    readarray -t docker__find_dir_result__arr < <(find  "${docker__search__dir}" -type d -iname "${docker__LTPP3_ROOTFS__foldername}" 2> /dev/null)

                    #Iterate thru each array-item
                    for docker__find_dir_result__arritem in "${docker__find_dir_result__arr[@]}"
                    do
                        echo -e "---:\e[30;38;5;215mCHECKING\e[0;0m: ${docker__find_dir_result__arritem}"

                        #Find path
                        docker__isfound=$(docker__checkif_paths_are_related "${DOCKER__EMPTYSTRING}" \
                                "${docker__find_dir_result__arritem}"  "${docker__LTPP3_ROOTFS__foldername}")
                        if [[ ${docker__isfound} == true ]]; then
                            #Update variable 'docker__path_of_development_tools__found'
                            docker__path_of_development_tools__found="${docker__find_dir_result__arritem}/${docker__development_tools__foldername}"

                            #Check if 'directory' exist
                            if [[ -d "${docker__path_of_development_tools__found}" ]]; then    #directory exists
                                #Update variable
                                #Remark:
                                #   'docker__LTPP3_ROOTFS_development_tools__dir' is a global variable.
                                #   This variable will be passed 'globally' to script 'docker_global.sh'.
                                docker__LTPP3_ROOTFS_development_tools__dir="${docker__path_of_development_tools__found}"

                                break
                            fi
                        fi
                    done

                    #Check if 'docker__LTPP3_ROOTFS_development_tools__dir' contains any data
                    if [[ -z "${docker__LTPP3_ROOTFS_development_tools__dir}" ]]; then  #contains no data
                        case "${docker__retry_ctr}" in
                            0)
                                docker__search__dir="${docker__parent__dir}"    #next search in the 'parent' directory
                                ;;
                            1)
                                docker__search__dir="/" #finally search in the 'main' directory (the search may take longer)
                                ;;
                            *)
                                echo -e "\r"
                                echo -e "***\e[1;31mERROR\e[0;0m: folder \e[30;38;5;246m${docker__development_tools__foldername}\e[0;0m: \e[30;38;5;131mNot Found\e[0;0m"
                                echo -e "\r"

                                #Update variable
                                docker__result=false

                                #set phase
                                docker__phase="${DOCKER__PHASE_EXIT}"

                                break
                                ;;
                        esac

                        ((docker__retry_ctr++))
                    else    #contains data
                        #Print
                        echo -e "---:\e[30;38;5;215mCOMPLETED\e[0;0m: find path of folder \e[30;38;5;246m'${docker__development_tools__foldername}\e[0;0m"


                        #Write to file
                        echo "${docker__LTPP3_ROOTFS_development_tools__dir}" | tee "${docker__mainmenu_path_cache__fpath}" >/dev/null

                        #Print
                        echo -e "---:\e[30;38;5;215mSTATUS\e[0;0m: write path to temporary cache-file: \e[1;33mDONE\e[0;0m"

                        #Update variable
                        docker__result=true

                        #set phase
                        docker__phase="${DOCKER__PHASE_EXIT}"

                        #Exit loop
                        break
                    fi
                done
                ;;    
            "${DOCKER__PHASE_EXIT}")
                break
                ;;
        esac
    done

    #Exit if 'docker__result = false'
    if [[ ${docker__result} == false ]]; then
        exit 99
    fi

    #Retrieve directories
    #Remark:
    #   'docker__LTPP3_ROOTFS__dir' is a global variable.
    #   This variable will be passed 'globally' to script 'docker_global.sh'.
    docker__LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS_development_tools__dir%/*}    #move one directory up: LTPP3_ROOTFS/
    docker__parentDir_of_LTPP3_ROOTFS__dir=${docker__LTPP3_ROOTFS__dir%/*}    #move two directories up. This directory is the one-level higher than LTPP3_ROOTFS/

    docker__enter_cmdline_mode__dir=${docker__parentDir_of_LTPP3_ROOTFS__dir}/enter_cmd_mode
    docker__enter_cmdline_mode_cache__dir=${docker__enter_cmdline_mode__dir}/cache

    docker__LTPP3_ROOTFS_boot__dir=${docker__LTPP3_ROOTFS__dir}/boot
    docker__LTPP3_ROOTFS_boot_configs__dir=${docker__LTPP3_ROOTFS_boot__dir}/configs
    docker__LTPP3_ROOTFS_build__dir=${docker__LTPP3_ROOTFS__dir}/build
    docker__LTPP3_ROOTFS_build_scripts__dir=${docker__LTPP3_ROOTFS_build__dir}/scripts
    docker__LTPP3_ROOTFS_docker__dir=${docker__LTPP3_ROOTFS__dir}/docker
    docker__LTPP3_ROOTFS_docker_dockerfiles__dir=${docker__LTPP3_ROOTFS_docker__dir}/dockerfiles
    docker__LTPP3_ROOTFS_docker_list__dir=${docker__LTPP3_ROOTFS_docker__dir}/list
    docker__LTPP3_ROOTFS_linux__dir=${docker__LTPP3_ROOTFS__dir}/linux
    docker__LTPP3_ROOTFS_linux_scripts__dir=${docker__LTPP3_ROOTFS_linux__dir}/scripts
    docker__LTPP3_ROOTFS_motd__dir=${docker__LTPP3_ROOTFS__dir}/motd
    docker__LTPP3_ROOTFS_motd_update_motd__dir=${docker__LTPP3_ROOTFS_motd__dir}/update-motd.d



#---filenames used in multiple places
    docker__cmdline__filename="cmdline"
    docker__docker_fs_partition_diskpartsize_dat__filename="docker_fs_partition_diskpartsize.dat"
    docker__docker_fs_partition_diskpartsize_dat_4g__filename="docker_fs_partition_diskpartsize.dat.4g"
    docker__docker_fs_partition_diskpartsize_dat_8g__filename="docker_fs_partition_diskpartsize.dat.8g"
    # docker__docker_fs_partition_diskpartsize_dat_userdefined__filename="docker_fs_partition_diskpartsize.dat.userdefined"
    docker__docker_fs_partition_conf__filename="docker_fs_partition.conf"
    docker__fstab__filename="fstab"
    docker__fstab_overlaybck__filename="fstab.overlaybck"
    docker__init__filename="init"
    docker__isp_c__filename="isp.c"
    docker__isp_c_overlaybck__filename="isp.c.overlaybck"
    docker__isp_sh__filename="isp.sh"
    docker__isp_sh_overlaybck__filename="isp.sh.overlaybck"
    docker__pentagram_common_h__filename="pentagram_common.h"
    docker__pentagram_common_h_overlaybck__filename="pentagram_common.h.overlaybck"
    docker__tb_init_sh__filename="tb_init.sh"
    docker__tb_init_bootmenu__filename="tb_init_bootmenu"
    docker__96_overlayboot_notice__filename="96-overlayboot-notice"
    docker__98_normalboot_notice__filename="98-normalboot-notice"
    docker__99_wlan_notice__filename="99-wlan-notice"



#---docker__rootfs__dir - contents
    docker__dootfs__dir="/"
    docker__dotdockerenv__fpath="${docker__dootfs__dir}/.dockerenv"



#---docker__docker__dir - contents
    docker__dockerfile_autogen_filename="dockerfile_autogen"

    docker__docker__dir=${docker__parentDir_of_LTPP3_ROOTFS__dir}/docker
    docker__docker_cache__dir=${docker__docker__dir}/cache
    docker__docker_config__dir=${docker__docker__dir}/config
    docker__docker_dockerfiles__dir=${docker__docker__dir}/dockerfiles
    docker__docker_images__dir=${docker__docker__dir}/images
    docker__docker_overlayfs__dir=${docker__docker__dir}/overlayfs

    docker__docker_overlayfs_cmdline__fpath=${docker__docker_overlayfs__dir}/${docker__cmdline__filename}
    docker__docker_overlayfs_fstab__fpath=${docker__docker_overlayfs__dir}/${docker__fstab__filename}
    docker__docker_fs_partition_diskpartsize_dat__fpath=${docker__docker_overlayfs__dir}/${docker__docker_fs_partition_diskpartsize_dat__filename}
    docker__docker_fs_partition_diskpartsize_dat_4g__fpath=${docker__docker_overlayfs__dir}/${docker__docker_fs_partition_diskpartsize_dat_4g__filename}
    docker__docker_fs_partition_diskpartsize_dat_8g__fpath=${docker__docker_overlayfs__dir}/${docker__docker_fs_partition_diskpartsize_dat_8g__filename}
    # docker__docker_fs_partition_diskpartsize_dat_userdefined__fpath=${docker__docker_overlayfs__dir}/${docker__docker_fs_partition_diskpartsize_dat_userdefined__filename}
    docker__docker_fs_partition_conf__fpath=${docker__docker_overlayfs__dir}/${docker__docker_fs_partition_conf__filename}
    docker__docker_overlayfs_isp_c__fpath=${docker__docker_overlayfs__dir}/${docker__isp_c__filename}
    docker__docker_overlayfs_isp_sh__fpath=${docker__docker_overlayfs__dir}/${docker__isp_sh__filename}
    docker__docker_overlayfs_pentagram_common_h__fpath=${docker__docker_overlayfs__dir}/${docker__pentagram_common_h__filename}
    docker__docker_overlayfs_tb_init_sh__fpath=${docker__docker_overlayfs__dir}/${docker__tb_init_sh__filename}
    docker__docker_overlayfs_tb_init_bootmenu__fpath=${docker__docker_overlayfs__dir}/${docker__tb_init_bootmenu__filename}
    docker__docker_overlayfs_96_overlayboot_notice__fpath=${docker__docker_overlayfs__dir}/${docker__96_overlayboot_notice__filename}
    docker__docker_overlayfs_98_normalboot_notice__fpath=${docker__docker_overlayfs__dir}/${docker__98_normalboot_notice__filename}

#---docker__docker_config__dir - contents
    docker__export_env_var_menu_cfg__filename="docker_export_env_var_menu.cfg"
    docker__export_env_var_menu_cfg__fpath=${docker__docker_config__dir}/${docker__export_env_var_menu_cfg__filename}


#---docker__enter_cmdline_mode_cache__dir - contents
    docker__enter_cmdline_mode_cache__filename="docker_enter_cmdline_mode.cache"
    docker__enter_cmdline_mode_cache__fpath=${docker__enter_cmdline_mode_cache__dir}/${docker__enter_cmdline_mode_cache__filename}


#---docker__LTPP3_ROOTFS_development_tools__dir - contents
    compgen__query_w_autocomplete__filename="compgen_query_w_autocomplete.sh"
    compgen__query_w_autocomplete__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${compgen__query_w_autocomplete__filename}

    dirlist__readInput_w_autocomplete__filename="dirlist_readInput_w_autocomplete.sh"
    dirlist__readInput_w_autocomplete__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${dirlist__readInput_w_autocomplete__filename}

    docker__build_ispboootbin_filename="docker_build_ispboootbin.sh"
    docker__build_ispboootbin_fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__build_ispboootbin_filename}

    docker__fs_partition_menu__filename="docker_fs_partition_menu.sh"
    docker__fs_partition_menu__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__fs_partition_menu__filename}

    docker__fs_partition_diskpartition_menu_filename="docker_fs_partition_diskpartition_menu.sh"
    docker__fs_partition_diskpartition_menu_fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__fs_partition_diskpartition_menu_filename}

    docker__fs_partition_diskpartition_menu_output_filename="docker_fs_partition_diskpartition_menu.output"
    docker__fs_partition_diskpartition_menu_output_fpath=${docker__tmp__dir}/${docker__fs_partition_diskpartition_menu_output_filename}

    docker__fs_partition_disksize_menu__filename="docker_fs_partition_disksize_menu.sh"
    docker__fs_partition_disksize_menu__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__fs_partition_disksize_menu__filename}

    # docker__fs_partition_disksize_menu_output__filename="docker_fs_partition_disksize_menu.output"
    # docker__fs_partition_disksize_menu_output__fpath=${docker__tmp__dir}/${docker__fs_partition_disksize_menu_output__filename}

    docker__fs_partition_disksize_userdefined__filename="docker_fs_partition_disksize_userdefined.sh"
    docker__fs_partition_disksize_userdefined__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__fs_partition_disksize_userdefined__filename}

    docker__fs_partition_disksize_userdefined_output__filename="docker_fs_partition_disksize_userdefined.output"
    docker__fs_partition_disksize_userdefined_output__fpath=${docker__tmp__dir}/${docker__fs_partition_disksize_userdefined_output__filename}

    docker__container_build_ispboootbin_filename="docker_container_build_ispboootbin.sh"
    docker__container_build_ispboootbin_fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__container_build_ispboootbin_filename}

    docker__containerlist_tableinfo__filename="docker_containerlist_tableinfo.sh"
    docker__containerlist_tableinfo__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__containerlist_tableinfo__filename}

    docker__container_run_remove_build_menu__filename="docker_container_run_remove_build_menu.sh"
    docker__container_run_remove_build_menu__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__container_run_remove_build_menu__filename}

    docker__cp_fromto_container__filename="docker_cp_fromto_container.sh"
    docker__cp_fromto_container__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__cp_fromto_container__filename}

    docker__create_image_from_container__filename="docker_create_image_from_container.sh"
    docker__create_image_from_container__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__create_image_from_container__filename}

    docker__create_an_image_from_dockerfile__filename="docker_create_an_image_from_dockerfile.sh"
    docker__create_an_image_from_dockerfile__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__create_an_image_from_dockerfile__filename}

    docker__create_images_from_dockerlist__filename="docker_create_images_from_dockerlist.sh"
    docker__create_images_from_dockerlist__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__create_images_from_dockerlist__filename}

    docker__create_image_from_existing_repository__filename="docker_create_image_from_existing_repository.sh"
    docker__create_image_from_existing_repository__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__create_image_from_existing_repository__filename}

    docker__create_images_from_dockerfile_dockerlist_menu__filename="docker_create_images_from_dockerfile_dockerlist_menu.sh"
    docker__create_images_from_dockerfile_dockerlist_menu__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__create_images_from_dockerfile_dockerlist_menu__filename}

    docker__dockerhub_menu__filename="dockerhub_menu.sh"
    docker__dockerhub_menu__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__dockerhub_menu__filename}

    docker__enter_command__filename="docker_enter_command.sh"
    docker__enter_command__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__enter_command__filename}

    docker__enter_cmdline_mode__filename="docker_enter_cmdline_mode.sh"
    docker__enter_cmdline_mode__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__enter_cmdline_mode__filename}

    docker__export_env_var_menu__filename="docker_export_env_var_menu.sh"
    docker__export_env_var_menu__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__export_env_var_menu__filename}

    docker__git_menu__filename="git_menu.sh"
    docker__git_menu__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__git_menu__filename}

    docker__image_create_remove_rename_menu__filename="docker_image_create_remove_rename_menu.sh"
    docker__image_create_remove_rename_menu__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__image_create_remove_rename_menu__filename}

    docker__load__filename="docker_load.sh"
    docker__load__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__load__filename}

    docker__readInput_w_autocomplete__filename="docker_readInput_w_autocomplete.sh"
    docker__readInput_w_autocomplete__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__readInput_w_autocomplete__filename}

    docker__remove_container__filename="docker_remove_container.sh"
    docker__remove_container__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__remove_container__filename}
    
    docker__ispboootbin_version_input__filename="docker_ispboootbin_version_input.sh"
    docker__ispboootbin_version_input__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__ispboootbin_version_input__filename}

    docker__remove_image__filename="docker_remove_image.sh"
    docker__remove_image__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__remove_image__filename}

    docker__rename_repotag__filename="docker_rename_repotag.sh"
    docker__rename_repotag__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__rename_repotag__filename}

    docker__repo_link_checkout_menu_select__filename="docker_repo_link_checkout_menu_select.sh"
    docker__repo_link_checkout_menu_select__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__repo_link_checkout_menu_select__filename}

    docker__repo_linkcheckout_profile_menu_select__filename="docker_repo_linkcheckout_profile_menu_select.sh"
    docker__repo_linkcheckout_profile_menu_select__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__repo_linkcheckout_profile_menu_select__filename}

	docker__repolist_tableinfo__filename="docker_repolist_tableinfo.sh"
	docker__repolist_tableinfo__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__repolist_tableinfo__filename}

    docker__run_chroot__filename="docker_run_chroot.sh"
    docker__run_chroot__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__run_chroot__filename}

    docker__run_container_from_a_repository__filename="docker_run_container_from_a_repository.sh"
    docker__run_container_from_a_repository__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__run_container_from_a_repository__filename}

    docker__run_exited_container__filename="docker_run_exited_container.sh"
    docker__run_exited_container__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__run_exited_container__filename}

    docker__select_dockerfile__filename="docker_select_dockerfile.sh"
    docker__select_dockerfile__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__select_dockerfile__filename}

    docker__show_choose_add_del_from_cache__filename="docker_show_choose_add_del_from_cache.sh"
    docker__show_choose_add_del_from_cache__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__show_choose_add_del_from_cache__filename}

    docker__save__filename="docker_save.sh"
    docker__save__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__save__filename}

    docker__ssh_to_host__filename="docker_ssh_to_host.sh"
    docker__ssh_to_host__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__ssh_to_host__filename}

    git__git_create_checkout_local_branch__filename="git_create_checkout_local_branch.sh"
    git__git_create_checkout_local_branch__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${git__git_create_checkout_local_branch__filename}

    git__git_delete_local_branch__filename="git_delete_local_branch.sh"
    git__git_delete_local_branch__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${git__git_delete_local_branch__filename}
    
    git__git_pull__filename="git_pull.sh"
    git__git_pull__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${git__git_pull__filename}
    
    git__git_pull_origin_otherBranch__filename="git_pull_origin_otherbranch.sh"
    git__git_pull_origin_otherBranch__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${git__git_pull_origin_otherBranch__filename}
    
    git__git_push__filename="git_push.sh"
    git__git_push__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${git__git_push__filename}

    git__git_readInput_w_autocomplete__filename="git_readInput_w_autocomplete.sh"
    git__git_readInput_w_autocomplete__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${git__git_readInput_w_autocomplete__filename}

    git__git_tag_create_and_push__filename="git_tag_create_and_push.sh"
    git__git_tag_create_and_push__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${git__git_tag_create_and_push__filename}

    # git__git_tag_create_link_and_push__filename="git_tag_create_link_and_push.sh"
    # git__git_tag_create_link_and_push__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${git__git_tag_create_link_and_push__filename}

    git__git_tag_remove__filename="git_tag_remove.sh"
    git__git_tag_remove__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${git__git_tag_remove__filename}

    git__git_tag_rename__filename="git_tag_rename.sh"
    git__git_tag_rename__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${git__git_tag_rename__filename}

    git__git_tag_menu__filename="git_tag_menu.sh"
    git__git_tag_menu__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${git__git_tag_menu__filename}

    git__git_undo_last_unpushed_commit__filename="git_undo_last_unpushed_commit.sh"
    git__git_undo_last_unpushed_commit__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${git__git_undo_last_unpushed_commit__filename}


#---docker__proc__dir - contents
    docker__proc__dir="/proc"
    docker__proc_1__dir="${docker__proc__dir}/1"
    docker__proc_1_cgroup__fpath="${docker__proc_1__dir}/cgroup"

#---docker__root__dir - contents
    docker__root__dir="/root"   #this is the 
    docker__home_dotbashrc__fpath="${docker__root__dir}/.bashrc"
    docker__config_json__fpath="${docker__root__dir}/.docker/config.json"


#---docker__LTPP3_ROOTFS_docker__dir - contents
    docker__dockerfile_ltps_sunplus__filename="dockerfile_ltps_sunplus"
    docker__dockerfile_ltps_sunplus_fpath=${docker__LTPP3_ROOTFS_docker_dockerfiles__dir}/${docker__dockerfile_ltps_sunplus__filename}

    docker__LTPP3_ROOTFS_docker_environment__dir=${docker__LTPP3_ROOTFS_docker__dir}/environment
    docker__exported_env_var__filename="exported_env_var.txt"
    docker__exported_env_var__fpath=${docker__LTPP3_ROOTFS_docker_environment__dir}/${docker__exported_env_var__filename}

    docker__LTPP3_ROOTFS_docker_environment__dir=${docker__LTPP3_ROOTFS_docker__dir}/environment
    docker__exported_env_var_default__filename="exported_env_var_default.txt"
    docker__exported_env_var_default__fpath=${docker__LTPP3_ROOTFS_docker_environment__dir}/${docker__exported_env_var_default__filename}

    docker__LTPP3_ROOTFS_build_scripts_isp_sh__fpath=${docker__LTPP3_ROOTFS_build_scripts__dir}/${docker__isp_sh__filename}
    docker__LTPP3_ROOTFS_boot_configs_pentagram_common_h__fpath=${docker__LTPP3_ROOTFS_boot_configs__dir}/${docker__pentagram_common_h__filename}

    docker__LTPP3_ROOTFS_docker_version__dir=${docker__LTPP3_ROOTFS_docker__dir}/version
    docker__ispboootbin_version_txt__filename="ispboootbin_version.txt"
    docker__ispboootbin_version_txt__fpath=${docker__LTPP3_ROOTFS_docker_version__dir}/${docker__ispboootbin_version_txt__filename}

#---docker__LTPP3_ROOTFS_linux_scripts__dir - contents
    docker__LTPP3_ROOTFS_linux_scripts_tb_init_sh__fpath=${docker__LTPP3_ROOTFS_linux_scripts__dir}/${docker__tb_init_sh__filename}
    docker__LTPP3_ROOTFS_linux_scripts_tb_init_bootmenu__fpath=${docker__LTPP3_ROOTFS_linux_scripts__dir}/${docker__tb_init_bootmenu__filename}


#---docker__LTPP3_ROOTFS_motd__dir - contents
    docker__LTPP3_ROOTFS_motd_update_motd_96_overlayboot_notice__fpath=${docker__LTPP3_ROOTFS_motd_update_motd__dir}/${docker__96_overlayboot_notice__filename}
    docker__LTPP3_ROOTFS_motd_update_motd_98_normalboot_notice__fpath=${docker__LTPP3_ROOTFS_motd_update_motd__dir}/${docker__98_normalboot_notice__filename}
    docker__LTPP3_ROOTFS_motd_update_motd_99_wlan_notice__fpath=${docker__LTPP3_ROOTFS_motd_update_motd__dir}/${docker__99_wlan_notice__filename}

#---docker__SP7021__dir - contents
    #Note: this directory MUST be the same as the 'SP7021_dir' which is defined in 'sunplus_inst.sh'
    docker__SP7021__dir="${docker__root__dir}/SP7021"
    docker__SP7021_boot_uboot_include_configs__dir=${docker__SP7021__dir}/boot/uboot/include/configs
    docker__SP7021_boot_uboot_tools__dir=${docker__SP7021__dir}/boot/uboot/tools
    docker__SP7021_build__dir=${docker__SP7021__dir}/build
    docker__SP7021_build_tools_isp__dir=${docker__SP7021__dir}/build/tools/isp
    docker__SP7021_linux_rootfs_initramfs_disk_dir=${docker__SP7021__dir}/linux/rootfs/initramfs/disk
    docker__SP7021_linux_rootfs_initramfs_disk_sbin__dir=${docker__SP7021_linux_rootfs_initramfs_disk_dir}/sbin
    docker__SP7021_linux_rootfs_initramfs_disk_etc__dir=${docker__SP7021_linux_rootfs_initramfs_disk_dir}/etc
    docker__SP7021_linux_rootfs_initramfs_disk_etc_update_motd_d__dir=${docker__SP7021_linux_rootfs_initramfs_disk_etc__dir}/update-motd.d
    docker__SP7021_linux_rootfs_initramfs_disk_etc_tibbo__dir=${docker__SP7021_linux_rootfs_initramfs_disk_etc__dir}/tibbo
    docker__SP7021_linux_rootfs_initramfs_disk_etc_tibbo_version__dir=${docker__SP7021_linux_rootfs_initramfs_disk_etc_tibbo__dir}/version
    docker__SP7021_linux_rootfs_initramfs_disk_etc_tibbo_proc__dir=${docker__SP7021_linux_rootfs_initramfs_disk_etc_tibbo__dir}/proc

    docker__SP7021_build_tools_isp_isp_c__fpath=${docker__SP7021_build_tools_isp__dir}/${docker__isp_c__filename}
    docker__SP7021_build_tools_isp_isp_c_overlaybck__fpath=${docker__SP7021_build_tools_isp__dir}/${docker__isp_c_overlaybck__filename}
    docker__SP7021_build_isp_sh__fpath=${docker__SP7021_build__dir}/${docker__isp_sh__filename}
    docker__SP7021_build_isp_sh_overlaybck__fpath=${docker__SP7021_build__dir}/${docker__isp_sh_overlaybck__filename}
    docker__SP7021_boot_uboot_include_configs_pentagram_common_h__fpath=${docker__SP7021_boot_uboot_include_configs__dir}/${docker__pentagram_common_h__filename}
    docker__SP7021_boot_uboot_include_configs_pentagram_common_h_overlaybck__fpath=${docker__SP7021_boot_uboot_include_configs__dir}/${docker__pentagram_common_h_overlaybck__filename}
    docker__SP7021_linux_rootfs_initramfs_disk_etc_fstab__fpath=${docker__SP7021_linux_rootfs_initramfs_disk_etc__dir}/${docker__fstab__filename}
    docker__SP7021_linux_rootfs_initramfs_disk_etc_fstab_overlaybck__fpath=${docker__SP7021_linux_rootfs_initramfs_disk_etc__dir}/${docker__fstab_overlaybck__filename}
    docker__SP7021_linux_rootfs_initramfs_disk_sbin_init__fpath=${docker__SP7021_linux_rootfs_initramfs_disk_sbin__dir}/${docker__init__filename}
    docker__SP7021_linux_rootfs_initramfs_disk_sbin_tb_init_sh__fpath="${docker__SP7021_linux_rootfs_initramfs_disk_sbin__dir}/${docker__tb_init_sh__filename}"
    docker__SP7021_linux_rootfs_initramfs_disk_sbin_tb_init_bootmenu__fpath="${docker__SP7021_linux_rootfs_initramfs_disk_sbin__dir}/${docker__tb_init_bootmenu__filename}"
    docker__SP7021_linux_rootfs_initramfs_disk_etc_tibbo_proc_cmdline__fpath=${docker__SP7021_linux_rootfs_initramfs_disk_etc_tibbo_proc__dir}/${docker__cmdline__filename}
    docker__SP7021_linux_rootfs_initramfs_disk_etc_update_motd_d_96_overlayboot_notice__fpath="${docker__SP7021_linux_rootfs_initramfs_disk_etc_update_motd_d__dir}/${docker__96_overlayboot_notice__filename}"
    docker__SP7021_linux_rootfs_initramfs_disk_etc_update_motd_d_98_normalboot_notice__fpath="${docker__SP7021_linux_rootfs_initramfs_disk_etc_update_motd_d__dir}/${docker__98_normalboot_notice__filename}"
    docker__SP7021_linux_rootfs_initramfs_disk_etc_update_motd_d_99_wlan_notice__fpath="${docker__SP7021_linux_rootfs_initramfs_disk_etc_update_motd_d__dir}/${docker__99_wlan_notice__filename}"

#---docker__tmp__dir - contents
    compgen__query_w_autocomplete_out__filename="compgen_query_w_autocomplete.out"
    compgen__query_w_autocomplete_out__fpath=${docker__tmp__dir}/${compgen__query_w_autocomplete_out__filename}

    dirlist__readInput_w_autocomplete_out__filename="dirlist_readInput_w_autocomplete.out"
    dirlist__readInput_w_autocomplete_out__fpath=${docker__tmp__dir}/${dirlist__readInput_w_autocomplete_out__filename}

    dirlist__src_ls_1aA_output__filename="dirlist_src_ls_1aA.output"
    dirlist__src_ls_1aA_output__fpath=${docker__tmp__dir}/${dirlist__src_ls_1aA_output__filename}
    dirlist__src_ls_1aA_tmp__filename="dirlist_src_ls_1aA.tmp"
    dirlist__src_ls_1aA_tmp__fpath=${docker__tmp__dir}/${dirlist__src_ls_1aA_tmp__filename}
    dirlist__dst_ls_1aA_output__filename="dirlist_dst_ls_1aA.output"
    dirlist__dst_ls_1aA_output__fpath=${docker__tmp__dir}/${dirlist__dst_ls_1aA_output__filename}
    dirlist__dst_ls_1aA_tmp__filename="dirlist_dst_ls_1aA.tmp"
    dirlist__dst_ls_1aA_tmp__fpath=${docker__tmp__dir}/${dirlist__dst_ls_1aA_tmp__filename}

    dclcau_lh_ls__filename="dclcau_lh_ls.sh"
    dclcau_lh_ls__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${dclcau_lh_ls__filename}
    dclcau_dc_ls__filename="dclcau_dc_ls.sh"
    dclcau_dc_ls__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${dclcau_dc_ls__filename}

    docker_build_ispboootbin_tmp_sh_filename="docker_build_ispboootbin_tmp.sh"
    docker_build_ispboootbin_tmp_sh_fpath="${docker__tmp__dir}/${docker_build_ispboootbin_tmp_sh_filename}"

    docker__container_exec_cmd_and_receive_output_out__filename="container_exec_cmd_and_receive_output.out"
    docker__container_exec_cmd_and_receive_output_out__fpath=${docker__tmp__dir}/${docker__container_exec_cmd_and_receive_output_out__filename}

    docker__create_an_image_from_dockerfile_out__filename="docker_create_an_image_from_dockerfile.out"
    docker__create_an_image_from_dockerfile_out__fpath=${docker__tmp__dir}/${docker__create_an_image_from_dockerfile_out__filename}

    docker__create_images_from_dockerlist_out__filename="docker_create_images_from_dockerlist.out"
    docker__create_images_from_dockerlist_out__fpath=${docker__tmp__dir}/${docker__create_images_from_dockerlist_out__filename}

    docker__enter_cmdline_mode_out__filename="docker_enter_cmdline_mode.out"
    docker__enter_cmdline_mode_out__fpath=${docker__tmp__dir}/${docker__enter_cmdline_mode_out__filename}

    docker__enter_cmdline_mode_tmp__filename="docker_enter_cmdline_mode.tmp"
    docker__enter_cmdline_mode_tmp__fpath=${docker__tmp__dir}/${docker__enter_cmdline_mode_tmp__filename}

    docker__export_env_var_menu_out__filename="docker_export_env_var_menu.out"
    docker__export_env_var_menu_out__fpath=${docker__tmp__dir}/${docker__export_env_var_menu_out__filename}

    docker__readInput_w_autocomplete_out__filename="docker_readInput_w_autocomplete.out"
    docker__readInput_w_autocomplete_out__fpath=${docker__tmp__dir}/${docker__readInput_w_autocomplete_out__filename}

    docker__repo_link_checkout_menu_select_out__filname="docker_repo_link_checkout_menu_select.out"
    docker__repo_link_checkout_menu_select_out__fpath=${docker__tmp__dir}/${docker__repo_link_checkout_menu_select_out__filname}

    docker__repo_linkcheckout_profile_menu_select_out__filename="docker_repo_linkcheckout_profile_menu_select.out"
    docker__repo_linkcheckout_profile_menu_select_out__fpath=${docker__tmp__dir}/${docker__repo_linkcheckout_profile_menu_select_out__filename}

    docker__readDialog_w_Output__func_out__filename="readDialog_w_Output__func.out"
    docker__readDialog_w_Output__func_out__fpath=${docker__tmp__dir}/${docker__readDialog_w_Output__func_out__filename}

    docker__select_dockerfile_out__filename="docker_select_dockerfile.out"
    docker__select_dockerfile_out__fpath=${docker__tmp__dir}/${docker__select_dockerfile_out__filename}

    docker__show_choose_add_del_from_cache_out__filename="docker_show_choose_add_del_from_cache.out"
    docker__show_choose_add_del_from_cache_out__fpath=${docker__tmp__dir}/${docker__show_choose_add_del_from_cache_out__filename}

    docker__show_fileContent_wo_select_func_out__filename="show_fileContent_wo_select__func.out"
    docker__show_fileContent_wo_select_func_out__fpath=${docker__tmp__dir}/${docker__show_fileContent_wo_select_func_out__filename}

    docker__show_pathContent_w_selection_func_out__filename="show_pathContent_w_selection__func.out"
    docker__show_pathContent_w_selection_func_out__fpath=${docker__tmp__dir}/${docker__show_pathContent_w_selection_func_out__filename}

    git__git_create_checkout_local_branch_out__filename="git_create_checkout_local_branch.out"
    git__git_create_checkout_local_branch_out__fpath=${docker__tmp__dir}/${git__git_create_checkout_local_branch_out__filename}

    git__git_tag_create_link_and_push_out__filename="git_tag_create_link_and_push.out"
    git__git_tag_create_link_and_push_out__fpath=${docker__tmp__dir}/${git__git_tag_create_link_and_push_out__filename}

    git__git_delete_local_branch_out__filename="git_delete_local_branch.out"
    git__git_delete_local_branch_out__fpath=${docker__tmp__dir}/${git__git_delete_local_branch_out__filename}

    git__git_push_out__filename="git_push.out"
    git__git_push_out__fpath=${docker__tmp__dir}/${git__git_push_out__filename}

    git__git_readInput_w_autocomplete_out__filename="git_readInput_w_autocomplete.out"
    git__git_readInput_w_autocomplete_out__fpath=${docker__tmp__dir}/${git__git_readInput_w_autocomplete_out__filename}

    git__git_tag_create_and_push_out__filename="git_tag_create_and_push.out"
    git__git_tag_create_and_push_out__fpath=${docker__tmp__dir}/${git__git_tag_create_and_push_out__filename}

    git__git_tag_rename_out__filename="git_tag_rename.out"
    git__git_tag_rename_out__fpath=${docker__tmp__dir}/${git__git_tag_rename_out__filename}

    git__git_tag_remove_out__filename="git_tag_remove.out"
    git__git_tag_remove_out__fpath=${docker__tmp__dir}/${git__git_tag_remove_out__filename}

    git__git_undo_last_unpushed_commit_out__filename="git_undo_last_unpushed_commit.out"
    git__git_undo_last_unpushed_commit_out__fpath=${docker__tmp__dir}/${git__git_undo_last_unpushed_commit_out__filename}


#---REAL PATH (ON THE LTPP3G2)
    docker__sbin__dir=/sbin
    docker__sbin_tb_init_sh__fpath=${docker__sbin__dir}/${docker__tb_init_sh__filename}

    docker__etc_tibbo_proc__dir=/etc/tibbo/proc
    docker__etc_tibbo_proc_cmdline__fpath=${docker__etc_tibbo_proc__dir}/${docker__cmdline__filename}


    #OLD VERSION (is temporarily present for backwards compaitibility)
	# docker__dockercontainer_dirlist__filename="dockercontainer_dirlist.sh"
	# docker__dockercontainer_dirlist__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__dockercontainer_dirlist__filename}
	# docker__localhost_dirlist__filename="localhost_dirlist.sh"
	# docker__localhost_dirlist__fpath=${docker__LTPP3_ROOTFS_development_tools__dir}/${docker__localhost_dirlist__filename}
}


docker__create_dir__sub() {
    if [[ ! -d ${docker__docker__dir} ]]; then
        mkdir -p ${docker__docker__dir}
    fi
    if [[ ! -d ${docker__docker_overlayfs__dir} ]]; then
        mkdir -p ${docker__docker_overlayfs__dir}
    fi
    if [[ ! -d ${docker__docker_cache__dir} ]]; then
        mkdir -p ${docker__docker_cache__dir}
    fi
    if [[ ! -d ${docker__docker_config__dir} ]]; then
        mkdir -p ${docker__docker_config__dir}
    fi
    if [[ ! -d ${docker__docker_dockerfiles__dir} ]]; then
        mkdir -p ${docker__docker_dockerfiles__dir}
    fi
    if [[ ! -d ${docker__docker_images__dir} ]]; then
        mkdir -p ${docker__docker_images__dir}
    fi
    if [[ ! -d ${docker__enter_cmdline_mode__dir} ]]; then
        mkdir -p ${docker__enter_cmdline_mode__dir}
    fi
    if [[ ! -d ${docker__enter_cmdline_mode_cache__dir} ]]; then
        mkdir -p ${docker__enter_cmdline_mode_cache__dir}
    fi
    if [[ ! -d ${docker__tmp__dir} ]]; then
        mkdir -p ${docker__tmp__dir}
    fi
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
                #Check if 'scriptdir__input' is an Empty String
                if [[ -n "${scriptdir__input}" ]]; then
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
                #Check if 'scriptdir__input' is an Empty String
                if [[ -n "${scriptdir__input}" ]]; then
                    #Check if 'development_tools' is under the folder 'LTPP3_ROOTFS'
                    isfound3=$(echo "${scriptdir__input}" | \
                            grep -w "${finddir__input}.*")
                    if [[ -z "${isfound3}" ]]; then
                        ret=false
                    else
                        ret=true
                    fi
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

docker__create_exported_env_var_file__sub() {
    #Check if 'docker__exported_env_var.txt' is present
    if [[ ! -f ${docker__exported_env_var__fpath} ]]; then
        #Copy from 'docker__exported_env_var_default__fpath' to 'docker__exported_env_var__fpath'
        #Remark:
        #   Both paths are defined in 'docker__global__fpath'
        cp ${docker__exported_env_var_default__fpath} ${docker__exported_env_var__fpath}
    fi
}



#---MAIN SUBROUTINE
main__sub() {
    docker__get_source_fullpath__sub

    docker__create_dir__sub

    docker__create_exported_env_var_file__sub
}



#---EXECUTE MAIN
main__sub
