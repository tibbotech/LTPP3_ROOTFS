#!/bin/bash
#---Define colors
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

DOCKER__MENUTITLE="${DOCKER__TITLE_FG_LIGHTBLUE}DOCKER MAIN-MENU${DOCKER__NOCOLOR}"
DOCKER__SUBMENUTITLE="${DOCKER__TITLE_FG_LIGHTBLUE}DOCKER SUB-MENU: CREATE IMAGE(S)${DOCKER__NOCOLOR}"
DOCKER__VERSION="v21.03.17-0.0.1"

DOCKER__EXITING_NOW="Exiting Docker Main-menu..."
DOCKER__QUIT_CTRL_C="Quit (Ctrl+C)"

#---CHAR CONSTANTS
DOCKER__DASH="-"
DOCKER__DOT="."
DOCKER__EMPTYSTRING=""
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
function press_any_key__func()
{
	#Define constants
	local cTIMEOUT_ANYKEY=10

	#Initialize variables
	local keypressed=""
	local tcounter=0

	#Show Press Any Key message with count-down
	echo -e "\r"
	while [[ ${tcounter} -le ${cTIMEOUT_ANYKEY} ]];
	do
		delta_tcounter=$(( ${cTIMEOUT_ANYKEY} - ${tcounter} ))

		echo -e "\rPress (a)bort or any key to continue... (${delta_tcounter}) \c"
		read -N 1 -t 1 -s -r keypressed

		if [[ ! -z "${keypressed}" ]]; then
			if [[ "${keypressed}" == "a" ]] || [[ "${keypressed}" == "A" ]]; then
				exit
			else
				break
			fi
		fi
		
		tcounter=$((tcounter+1))
	done
	echo -e "\r"
}

function GOTO__func
{
	#Input args
    LABEL=$1
	
	#Define Command line
    cmd_line=$(sed -n "/$LABEL:/{:a;n;p;ba;};" $0 | grep -v ':$')
	
	#Execute Command line
    eval "${cmd_line}"
	
	#Exit Function
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

function cmd_exec__func()
{
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
    docker__create_an_image_from_dockerfile_filename="docker_create_an_image_from_dockerfile.sh"
    docker__create_images_from_dockerlist_filename="docker_create_images_from_dockerlist.sh"
    docker__create_image_from_existing_repository_filename="docker_create_image_from_existing_repository.sh"
    docker__create_image_from_container_filename="docker_create_image_from_container.sh"
    docker__run_container_from_a_repository_filename="docker_run_container_from_a_repository.sh"
    docker__run_exited_container_filename="docker_run_exited_container.sh"
    docker__remove_image_filename="docker_remove_image.sh"
    docker__remove_container_filename="docker_remove_container.sh"
    docker__cp_fromto_container_filename="docker_cp_fromto_container.sh"
    docker__create_dockerfile_filename="docker_create_dockerfile_filename.sh"
    docker__ssh_to_host_filename="docker_ssh_to_host.sh"

    docker__save_filename="docker_save.sh"
    docker__load_filename="docker_load.sh"

    docker__run_chroot_filename="docker_run_chroot.sh"

    docker__git_push_filename="git_push.sh"
    docker__git_pull_filename="git_pull.sh"
    docker__git_create_checkout_local_branch_filename="git_create_checkout_local_branch.sh"
    docker__git_delete_local_branch_filename="git_delete_local_branch.sh"

    docker__current_script_fpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
    docker__current_dir=$(dirname ${docker__current_script_fpath})
    if [[ ${docker__current_dir} == ${DOCKER__DOT} ]]; then
        docker__current_dir=$(pwd)
    fi

    docker__my_LTPP3_ROOTFS_development_tools_dir=${docker__current_dir}/development_tools

    docker__create_an_image_from_dockerfile_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__create_an_image_from_dockerfile_filename}
    docker__create_images_from_dockerlist_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__create_images_from_dockerlist_filename}
    docker__create_image_from_existing_repository_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__create_image_from_existing_repository_filename}
    docker__create_image_from_container_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__create_image_from_container_filename}
    docker__run_container_from_a_repository_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__run_container_from_a_repository_filename}
    docker__run_exited_container_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__run_exited_container_filename}
    docker__remove_image_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__remove_image_filename}
    docker__remove_container_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__remove_container_filename}
    docker__cp_fromto_container_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__cp_fromto_container_filename}
    docker__create_dockerfile_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__create_dockerfile_filename}
    docker__ssh_to_host_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__ssh_to_host_filename}

    docker__save_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__save_filename}
    docker__load_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__load_filename}

    docker__run_chroot_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__run_chroot_filename}

    docker__git_push_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__git_push_filename}
    docker__git_pull_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__git_pull_filename}
    docker__git_create_checkout_local_branch_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__git_create_checkout_local_branch_filename}
    docker__git_delete_local_branch_fpath=${docker__my_LTPP3_ROOTFS_development_tools_dir}/${docker__git_delete_local_branch_filename}
}

docker__load_header__sub() {
    echo -e "\r"
    echo -e "${DOCKER__TITLE_BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__TITLE_BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__init_variables__sub() {
    docker__mychoice=""
}

docker__mainmenu__sub() {
    while true
    do
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        show_leadingAndTrailingStrings_separatedBySpaces__func "${DOCKER__MENUTITLE}" "${DOCKER__VERSION}" "${DOCKER__TABLEWIDTH}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}1. Create ${DOCKER__IMAGEID_FG_BORDEAUX}images${DOCKER__NOCOLOR} using a ${DOCKER__FG_DARKBLUE}docker-file${DOCKER__NOCOLOR}/${DOCKER__TITLE_FG_LIGHTBLUE}docker-list${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}2. Create an ${DOCKER__IMAGEID_FG_BORDEAUX}image${DOCKER__NOCOLOR} from a ${DOCKER__REPOSITORY_FG_PURPLE}repository${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}3. Create an ${DOCKER__IMAGEID_FG_BORDEAUX}image${DOCKER__NOCOLOR} from a ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}4. Run ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR} from a ${DOCKER__REPOSITORY_FG_PURPLE}repository${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}5. Run an *exited* ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}6. Remove ${DOCKER__IMAGEID_FG_BORDEAUX}image${DOCKER__NOCOLOR}/${DOCKER__REPOSITORY_FG_PURPLE}repository${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}7. Remove ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}8. Copy a ${DOCKER__FILES_FG_ORANGE}file${DOCKER__NOCOLOR} from/to a ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}9. ${DOCKER__CHROOT_FG_GREEN}Chroot${DOCKER__NOCOLOR} (from in/outside a container)"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}r. ${DOCKER__REPOSITORY_FG_PURPLE}Repository${DOCKER__NOCOLOR}-list"
        echo -e "${DOCKER__FOURSPACES}c. ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}Container${DOCKER__NOCOLOR}-list"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}s. ${DOCKER__GENERAL_FG_YELLOW}SSH${DOCKER__NOCOLOR} to a ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}i. Import an ${DOCKER__IMAGEID_FG_BORDEAUX}image${DOCKER__NOCOLOR} file"
        echo -e "${DOCKER__FOURSPACES}e. Export an ${DOCKER__IMAGEID_FG_BORDEAUX}image${DOCKER__NOCOLOR} file"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}g. ${DOCKER__INSIDE_FG_LIGHTGREY}Git${DOCKER__NOCOLOR} Menu"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}q. ${DOCKER__QUIT_CTRL_C}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        # echo -e "\r"

        while true
        do
            #Select an option
            read -N1 -r -p "Please choose an option: " docker__mychoice
            echo -e "\r"

            #Only continue if a valid option is selected
            if [[ ! -z ${docker__mychoice} ]]; then
                if [[ ${docker__mychoice} =~ [1-9rcseipgq] ]]; then
                    break
                else
                    if [[ ${docker__mychoice} == ${DOCKER__ENTER} ]]; then
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
        case ${docker__mychoice} in
            1)
                docker__create_images_menu__sub
                ;;

            2)
                cmd_exec__func "${docker__create_image_from_existing_repository_fpath}"
                ;;

            3)
                cmd_exec__func "${docker__create_image_from_container_fpath}"
                ;;

            4)
                cmd_exec__func "${docker__run_container_from_a_repository_fpath}"
                ;;

            5)
                cmd_exec__func "${docker__run_exited_container_fpath}"
                ;;

            6)
                cmd_exec__func "${docker__remove_image_fpath}"
                ;;

            7)
                cmd_exec__func "${docker__remove_container_fpath}"
                ;;

            8)
                cmd_exec__func "${docker__cp_fromto_container_fpath}"
                ;;

            9)
                cmd_exec__func "${docker__run_chroot_fpath}"
                ;;

            c)
                docker__list_container__sub
                ;;

            r)
                docker__list_repository__sub
                ;;

            s)
                cmd_exec__func "${docker__ssh_to_host_fpath}"
                ;;

            i)
                cmd_exec__func "${docker__load_fpath}"
                ;;

            e)
                cmd_exec__func "${docker__save_fpath}"
                ;;

            g)  
                docker__git_menu__sub
                ;;

            q)
                exit
                ;;
        esac
    done
}

docker__create_images_menu__sub() {
    echo -e "\r"

    while true
    do
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        show_leadingAndTrailingStrings_separatedBySpaces__func "${DOCKER__SUBMENUTITLE}" "${DOCKER__VERSION}" "${DOCKER__TABLEWIDTH}"
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
        echo -e "${DOCKER__FOURSPACES}h. Home"
        echo -e "${DOCKER__FOURSPACES}q. $DOCKER__QUIT_CTRL_C"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        # echo -e "\r"

        while true
        do
            #Select an option
            read -N1 -r -p "Please choose an option: " docker__mychoice
            echo -e "\r"

            #Only continue if a valid option is selected
            if [[ ! -z ${docker__mychoice} ]]; then
                if [[ ${docker__mychoice} =~ [1-2rcseipghq] ]]; then
                    break
                else
                    if [[ ${docker__mychoice} == ${DOCKER__ENTER} ]]; then
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
        case ${docker__mychoice} in
            1)
                cmd_exec__func "${docker__create_an_image_from_dockerfile_fpath}"
                ;;

            2)
                cmd_exec__func "${docker__create_images_from_dockerlist_fpath}"
                ;;

            c)
                docker__list_container__sub
                ;;

            r)
                docker__list_repository__sub
                ;;

            s)
                cmd_exec__func "${docker__ssh_to_host_fpath}"
                ;;

            e)
                cmd_exec__func "${docker__save_fpath}"
                ;;

            i)
                cmd_exec__func "${docker__load_fpath}"
                ;;

            g)  
                docker__git_menu__sub
                ;;

            h)
                echo -e "\r"

                docker__mainmenu__sub
                ;;

            q)
                echo -e "\r"
                echo -e "\r"

                exit 0
                ;;
        esac
    done
}

docker__git_menu__sub() {
    echo -e "\r"

    while true
    do
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        show_leadingAndTrailingStrings_separatedBySpaces__func "${DOCKER__SUBMENUTITLE}" "${DOCKER__VERSION}" "${DOCKER__TABLEWIDTH}"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}1. Git ${DOCKER__OUTSIDE_BG_LIGHTGREY}${DOCKER__OUTSIDE_FG_WHITE}Push${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}2. Git ${DOCKER__INSIDE_BG_WHITE}${DOCKER__INSIDE_FG_LIGHTGREY}Pull${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FOURSPACES}3. Git ${DOCKER__FG_LIGHTGREEN}create${DOCKER__NOCOLOR}/${DOCKER__FG_LIGHTSOFTYELLOW}checkout${DOCKER__NOCOLOR} branch"
        echo -e "${DOCKER__FOURSPACES}4. Git ${DOCKER__FG_SOFTLIGHTRED}delete${DOCKER__NOCOLOR} ${DOCKER__INSIDE_FG_LIGHTGREY}local${DOCKER__NOCOLOR} Brabranchnch"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        echo -e "${DOCKER__FOURSPACES}h. Home"
        echo -e "${DOCKER__FOURSPACES}q. $DOCKER__QUIT_CTRL_C"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
        # echo -e "\r"

        while true
        do
            #Select an option
            read -N1 -r -p "Please choose an option: " docker__mychoice
            echo -e "\r"

            #Only continue if a valid option is selected
            if [[ ! -z ${docker__mychoice} ]]; then
                if [[ ${docker__mychoice} =~ [1-4hq] ]]; then
                    break
                else
                    if [[ ${docker__mychoice} == ${DOCKER__ENTER} ]]; then
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
        case ${docker__mychoice} in
            1)  
                cmd_exec__func "${docker__git_push_fpath}"
                ;;

            2)  
                cmd_exec__func "${docker__git_pull_fpath}"
                ;;

            3)
                cmd_exec__func "${docker__git_create_checkout_local_branch_fpath}"
                ;;

            4)
                cmd_exec__func "${docker__git_delete_local_branch_fpath}"
                ;;

            h)
                echo -e "\r"

                docker__mainmenu__sub
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


main_sub() {
    docker__load_header__sub

    docker__environmental_variables__sub

    docker__init_variables__sub

    docker__mainmenu__sub
}

#Execute main subroutine
main_sub
