#!/bin/bash -m
#Remark: by using '-m' the INT will NOT propagate to the PARENT scripts
#---COLOR CONSTANTS
DOCKER__NOCOLOR=$'\e[0m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__TITLE_FG_LIGHTBLUE=$'\e[30;38;5;45m'
DOCKER__FG_DARKBLUE=$'\e[30;38;5;33m'
DOCKER__FG_SOFTDARKBLUE=$'\e[30;38;5;38m'
DOCKER__CHROOT_FG_GREEN=$'\e[30;38;5;82m'
DOCKER__REPOSITORY_FG_PURPLE=$'\e[30;38;5;93m'
DOCKER__CONTAINER_FG_BRIGHTPRUPLE=$'\e[30;38;5;141m'
DOCKER__IMAGEID_FG_BORDEAUX=$'\e[30;38;5;198m'
DOCKER__FILES_FG_ORANGE=$'\e[30;38;5;215m'
DOCKER__INSIDE_FG_LIGHTGREY=$'\e[30;38;5;246m'
DOCKER__OUTSIDE_FG_WHITE=$'\e[30;38;5;231m'

DOCKER__FG_SOFTLIGHTRED=$'\e[30;38;5;131m'
DOCKER__FG_LIGHTGREEN=$'\e[30;38;5;71m'
DOCKER__FG_LIGHTSOFTYELLOW=$'\e[30;38;5;229m'

DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'
DOCKER__TITLE_BG_LIGHTBLUE=$'\e[30;48;5;45m'
DOCKER__INSIDE_BG_WHITE=$'\e[30;48;5;15m'
DOCKER__OUTSIDE_BG_LIGHTGREY=$'\e[30;48;5;246m'

#---CONSTANTS
DOCKER__TITLE="TIBBO"

DOCKER__CREATEIMAGE_MENUTITLE="${DOCKER__TITLE_FG_LIGHTBLUE}DOCKER: CREATE IMAGE(S)${DOCKER__NOCOLOR}"
DOCKER__VERSION="v21.03.17-0.0.1"

DOCKER__EXITING_NOW="Exiting Docker Main-menu..."
DOCKER__QUIT_CTRL_C="Quit (Ctrl+C)"

#---CHAR CONSTANTS
DOCKER__DASH="-"
DOCKER__ENTER=$'\x0a'

DOCKER__ONESPACE=" "
DOCKER__TWOSPACES=${DOCKER__ONESPACE}${DOCKER__ONESPACE}
DOCKER__FOURSPACES=${DOCKER__TWOSPACES}${DOCKER__TWOSPACES}

#---NUMERIC CONSTANTS
DOCKER__TABLEWIDTH=70

DOCKER__NUMOFLINES_1=1
DOCKER__NUMOFLINES_2=2
DOCKER__NUMOFLINES_3=3
DOCKER__NUMOFLINES_4=4
DOCKER__NUMOFLINES_5=5

#---BOOLEAN CONSTANTS
TRUE=true
FALSE=false



#---FUNCTIONS
trap CTRL_C__func INT
function CTRL_C__func() {
    echo -e "\r"
    echo -e "\r"

    exit
}

function show_leadingAndTrailingStrings_separatedBySpaces__func()
{
    #Input args
    local leadStr_input=${1}
    local trailStr_input=${2}
    local maxStrLen_input=${3}

    #Define local variables
    local ONESPACE=" "

    #Get string 'without visiable' color characters
    local leadStr_input_wo_colorChars=`echo "${leadStr_input}" | sed "s,\x1B\[[0-9;]*m,,g"`
    local trailStr_input_wo_colorChars=`echo "${trailStr_input}" | sed "s,\x1B\[[0-9;]*m,,g"`

    #Get string length
    local leadStr_input_wo_colorChars_len=${#leadStr_input_wo_colorChars}
    local trailStr_input_wo_colorChars_len=${#trailStr_input_wo_colorChars}

    #Calculated the number of spaces to-be-added
    local numOf_spaces=$(( maxStrLen_input-(leadStr_input_wo_colorChars_len+trailStr_input_wo_colorChars_len) ))

    #Create a string containing only EMPTY SPACES
    local emptySpaces_string=`printf '%*s' "${numOf_spaces}" | tr ' ' "${ONESPACE}"`

    #Print text including Leading Empty Spaces
    echo -e "${leadStr_input}${emptySpaces_string}${trailStr_input}"
}

function show_centered_string__func()
{
    #Input args
    local str_input=${1}
    local maxStrLen_input=${2}

    #Define one-space constant
    local ONESPACE=" "

    #Get string 'without visiable' color characters
    local strInput_wo_colorChars=`echo "${str_input}" | sed "s,\x1B\[[0-9;]*m,,g"`

    #Get string length
    local strInput_wo_colorChars_len=${#strInput_wo_colorChars}

    #Calculated the number of spaces to-be-added
    local numOf_spaces=$(( (maxStrLen_input-strInput_wo_colorChars_len)/2 ))

    #Create a string containing only EMPTY SPACES
    local emptySpaces_string=`duplicate_char__func "${ONESPACE}" "${numOf_spaces}" `

    #Print text including Leading Empty Spaces
    echo -e "${emptySpaces_string}${str_input}"
}

function duplicate_char__func()
{
    #Input args
    local char_input=${1}
    local numOf_times=${2}

    #Duplicate 'char_input'
    local char_duplicated=`printf '%*s' "${numOf_times}" | tr ' ' "${char_input}"`

    #Print text including Leading Empty Spaces
    echo -e "${char_duplicated}"
}

function moveUp_and_cleanLines__func() {
    #Input args
    local numOf_lines_toBeCleared=${1}

    #Clear lines
    local numOf_lines_cleared=1
    while [[ ${numOf_lines_cleared} -le ${numOf_lines_toBeCleared} ]]
    do
        tput cuu1	#move UP with 1 line
        tput el		#clear until the END of line

        numOf_lines_cleared=$((numOf_lines_cleared+1))  #increment by 1
    done
}



#---SUBROUTINES
docker__environmental_variables__sub() {
    #---Define PATHS
    docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})
    if [[ ${docker__current_dir} == ${DOCKER__DOT} ]]; then
        docker__current_dir=$(pwd)
    fi
    docker__current_folder=`basename ${docker__current_dir}`

    docker__development_tools_folder="development_tools"
    if [[ ${docker__current_folder} != ${docker__development_tools_folder} ]]; then
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}/${docker__development_tools_folder}
    else
        docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}
    fi

    docker__create_an_image_from_dockerfile_filename="docker_create_an_image_from_dockerfile.sh"
    docker__create_an_image_from_dockerfile_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__create_an_image_from_dockerfile_filename}
    docker__create_images_from_dockerlist_filename="docker_create_images_from_dockerlist.sh"
    docker__create_images_from_dockerlist_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__create_images_from_dockerlist_filename}
    docker__ssh_to_host_filename="docker_ssh_to_host.sh"
    docker__ssh_to_host_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__ssh_to_host_filename}
    docker__save_filename="docker_save.sh"
    docker__save_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__save_filename}
    docker__load_filename="docker_load.sh"
    docker__load_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__load_filename}

    docker__git_menu_filename="git_menu.sh"
    docker__git_menu_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__git_menu_filename}
}

docker__load_header__sub() {
    echo -e "\r"
    echo -e "${DOCKER__TITLE_BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__TITLE_BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__init_variables__sub() {
    docker__myChoice=""
}

docker__create_images_menu__sub() {
    while true
    do
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        show_leadingAndTrailingStrings_separatedBySpaces__func "${DOCKER__CREATEIMAGE_MENUTITLE}" "${DOCKER__VERSION}" "${DOCKER__TABLEWIDTH}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}1. Create an ${DOCKER__IMAGEID_FG_BORDEAUX}image${DOCKER__NOCOLOR} using a ${DOCKER__FG_DARKBLUE}docker-file${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}2. Create ${DOCKER__IMAGEID_FG_BORDEAUX}images${DOCKER__NOCOLOR} using a ${DOCKER__TITLE_FG_LIGHTBLUE}docker-list${DOCKER__NOCOLOR}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}r. ${DOCKER__REPOSITORY_FG_PURPLE}Repository${DOCKER__NOCOLOR}-list"
        echo -e "${DOCKER__FOURSPACES}c. ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}-list"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}s. ${DOCKER__GENERAL_FG_YELLOW}SSH${DOCKER__NOCOLOR} to a ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}i. Load from File"
        echo -e "${DOCKER__FOURSPACES}e. Save to File"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}g. ${DOCKER__INSIDE_FG_LIGHTGREY}Git${DOCKER__NOCOLOR} Menu"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}q. $DOCKER__QUIT_CTRL_C"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        # echo -e "\r"

        while true
        do
            #Select an option
            read -N1 -r -p "Please choose an option: " docker__myChoice
            echo -e "\r"

            #Only continue if a valid option is selected
            if [[ ! -z ${docker__myChoice} ]]; then
                if [[ ${docker__myChoice} =~ [1-2rcseipghq] ]]; then
                    break
                else
                    if [[ ${docker__myChoice} == ${DOCKER__ENTER} ]]; then
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
        case ${docker__myChoice} in
            1)
                ${docker__create_an_image_from_dockerfile_fpath}
                ;;

            2)
                ${docker__create_images_from_dockerlist_fpath}
                ;;

            c)
                docker__list_container__sub
                ;;

            r)
                docker__list_repository__sub
                ;;

            s)
                ${docker__ssh_to_host_fpath}
                ;;

            e)
                ${docker__save_fpath}
                ;;

            i)
                ${docker__load_fpath}
                ;;

            g)  
                ${docker__git_menu_fpath}
                ;;

            q)
                echo -e "\r"
                echo -e "\r"

                exit 0
                ;;
        esac
    done
}

docker__list_repository__sub() {
    #Load header
    docker__load_header__sub

    #Define local constants
    local MENUTITLE_REPOSITORYLIST="${DOCKER__REPOSITORY_FG_PURPLE}Repository${DOCKER__NOCOLOR}-list"

    local ERRMSG_NO_IMAGES_FOUND="=:${DOCKER__ERROR_FG_LIGHTRED}NO IMAGES FOUND${DOCKER__NOCOLOR}:="

    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        show_centered_string__func "${MENUTITLE_REPOSITORYLIST}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Get number of containers
    local numOf_repositories=`docker image ls | head -n -1 | wc -l`
    if [[ ${numOf_repositories} -eq 0 ]]; then
        echo -e "\r"
            show_centered_string__func "${ERRMSG_NO_IMAGES_FOUND}" "${DOCKER__TABLEWIDTH}"
        echo -e "\r"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "\r"

        press_any_key__func
    else
            docker image ls
        echo -e "\r"
        echo -e "\r"
    fi
}

docker__list_container__sub() {
    #Load header
    docker__load_header__sub

    #Define local constants
    local MENUTITLE_CONTAINERLIST="${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}-list"
    
    local ERRMSG_NO_CONTAINERS_FOUND="=:${DOCKER__ERROR_FG_LIGHTRED}NO CONTAINERS FOUND${DOCKER__NOCOLOR}:="

    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        show_centered_string__func "${MENUTITLE_CONTAINERLIST}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Get number of containers
    local numOf_containers=`docker ps -a | head -n -1 | wc -l`
    if [[ ${numOf_containers} -eq 0 ]]; then
        echo -e "\r"
            show_centered_string__func "${ERRMSG_NO_CONTAINERS_FOUND}" "${DOCKER__TABLEWIDTH}"
        echo -e "\r"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "\r"

        press_any_key__func
    else
            docker ps -a
        echo -e "\r"
        echo -e "\r"
    fi
}



#---MAIN SUBROUTINE
main__sub() {
    docker__load_header__sub

    docker__environmental_variables__sub

    docker__init_variables__sub

    docker__create_images_menu__sub
}



#---EXECUTE
main__sub