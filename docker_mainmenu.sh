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

DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'
DOCKER__TITLE_BG_LIGHTBLUE=$'\e[30;48;5;45m'
DOCKER__INSIDE_BG_WHITE=$'\e[30;48;5;15m'
DOCKER__OUTSIDE_BG_LIGHTGREY=$'\e[30;48;5;246m'

#---Define constants
DOCKER__TITLE="TIBBO"
DOCKER__DOT="."
DOCKER__FIVESPACES="     "
DOCKER__READ_FG_EXITING_NOW="Exiting Docker Main-menu..."


#---Trap ctrl-c and Call ctrl_c()

# trap CTRL_C_func INT

# function CTRL_C_func() {
#     echo -e "\r"
#     echo -e "\r"
#     echo -e ${DOCKER__READ_FG_EXITING_NOW}
#     echo -e "\r"
#     echo -e "\r"

#     exit
# }


#---Local functions & subroutines
function GOTO__func {
	#Input args
    LABEL=$1
	
	#Define Command line
    cmd_line=$(sed -n "/$LABEL:/{:a;n;p;ba;};" $0 | grep -v ':$')
	
	#Execute Command line
    eval "${cmd_line}"
	
	#Exit Function
    exit
}

press_any_key__localfunc() {
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

docker__cmd_exec() {
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
    docker__ssh_to_host_filename="docker__ssh_to_host.sh"

    docker__save_filename="docker_save.sh"
    docker__load_filename="docker_load.sh"

    docker__run_chroot_filename="docker_run_chroot.sh"

    docker__git_push_filename="git_push.sh"
    docker__git_pull_filename="git_pull.sh"

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
        echo -e "----------------------------------------------------------------------"
        echo -e "${DOCKER__TITLE_FG_LIGHTBLUE}DOCKER MAIN-MENU${DOCKER__NOCOLOR}\t\t\t\tv21.03.17-0.0.1"
        echo -e "----------------------------------------------------------------------"
        echo -e "${DOCKER__FIVESPACES}1. Create ${DOCKER__IMAGEID_FG_BORDEAUX}images${DOCKER__NOCOLOR} using a ${DOCKER__FG_DARKBLUE}docker-file${DOCKER__NOCOLOR}/${DOCKER__TITLE_FG_LIGHTBLUE}docker-list${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FIVESPACES}2. Create an ${DOCKER__IMAGEID_FG_BORDEAUX}image${DOCKER__NOCOLOR} from a ${DOCKER__REPOSITORY_FG_PURPLE}repository${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FIVESPACES}3. Create an ${DOCKER__IMAGEID_FG_BORDEAUX}image${DOCKER__NOCOLOR} from a ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FIVESPACES}4. Run ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR} from a ${DOCKER__REPOSITORY_FG_PURPLE}repository${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FIVESPACES}5. Run an *EXITED* ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FIVESPACES}6. Remove ${DOCKER__IMAGEID_FG_BORDEAUX}image-ID${DOCKER__NOCOLOR} (${DOCKER__REPOSITORY_FG_PURPLE}repository${DOCKER__NOCOLOR})"
        echo -e "${DOCKER__FIVESPACES}7. Remove ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}container-ID${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FIVESPACES}8. Copy a ${DOCKER__FILES_FG_ORANGE}file${DOCKER__NOCOLOR} from/to a ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FIVESPACES}9. Run ${DOCKER__CHROOT_FG_GREEN}CHROOT${DOCKER__NOCOLOR} from *WITHIN* a ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR}"
        echo -e "----------------------------------------------------------------------"
        echo -e "${DOCKER__FIVESPACES}r. Docker ${DOCKER__REPOSITORY_FG_PURPLE}repository${DOCKER__NOCOLOR} List"
        echo -e "${DOCKER__FIVESPACES}c. Docker ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR} List"
        echo -e "----------------------------------------------------------------------"
        echo -e "${DOCKER__FIVESPACES}s. SSH"
        echo -e "----------------------------------------------------------------------"
        echo -e "${DOCKER__FIVESPACES}i. Load from File"
        echo -e "${DOCKER__FIVESPACES}e. Save to File"
        echo -e "----------------------------------------------------------------------"
        echo -e "${DOCKER__FIVESPACES}p. Git ${DOCKER__OUTSIDE_BG_LIGHTGREY}${DOCKER__OUTSIDE_FG_WHITE}Push${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FIVESPACES}g. Git ${DOCKER__INSIDE_BG_WHITE}${DOCKER__INSIDE_FG_LIGHTGREY}Pull${DOCKER__NOCOLOR}"
        echo -e "----------------------------------------------------------------------"
        echo -e "${DOCKER__FIVESPACES}q. Quit (Ctrl+C)"
        echo -e "----------------------------------------------------------------------"
        echo -e "\r"	

        while true
        do
            #Select an option
            read -N 1 -e -p "Please choose an option: " docker__mychoice
            echo -e "\r"

            #Only continue if a valid option is selected
            if [[ ! -z ${docker__mychoice} ]]; then
                if [[ ${docker__mychoice} =~ [1-9,r,c,s,e,i,p,g,q] ]]; then
                    break
                else
                    tput cuu1	#move UP with 1 line
                    tput cuu1	#move UP with 1 line
                    tput el		#clear until the END of line
                fi
            else
                tput cuu1	#move UP with 1 line
                tput el		#clear until the END of line
            fi
        done
            
        #Goto the selected option
        case ${docker__mychoice} in
            1)
                docker__create_images_menu__sub
                ;;

            2)
                docker__cmd_exec "${docker__create_image_from_existing_repository_fpath}"
                ;;

            3)
                docker__cmd_exec "${docker__create_image_from_container_fpath}"
                ;;

            4)
                docker__cmd_exec "${docker__run_container_from_a_repository_fpath}"
                ;;

            5)
                docker__cmd_exec "${docker__run_exited_container_fpath}"
                ;;

            6)
                docker__cmd_exec "${docker__remove_image_fpath}"
                ;;

            7)
                docker__cmd_exec "${docker__remove_container_fpath}"
                ;;

            8)
                docker__cmd_exec "${docker__cp_fromto_container_fpath}"
                ;;

            9)
                docker__cmd_exec "${docker__run_chroot_fpath}"
                ;;

            c)
                docker__list_container__sub
                ;;

            r)
                docker__list_repository__sub
                ;;

            s)
                docker__cmd_exec "${docker__ssh_to_host_fpath}"
                ;;

            e)
                docker__cmd_exec "${docker__save_fpath}"
                ;;

            i)
                docker__cmd_exec "${docker__load_fpath}"
                ;;

            p)  
                docker__cmd_exec "${docker__git_push_fpath}"
                ;;

            g)  
                docker__cmd_exec "${docker__git_pull_fpath}"
                ;;

            q)
                exit
                ;;
        esac
    done
}

docker__create_images_menu__sub() {
    while true
    do
        echo -e "----------------------------------------------------------------------"
        echo -e "${DOCKER__TITLE_FG_LIGHTBLUE}DOCKER CREATE IMAGE(S)${DOCKER__NOCOLOR}"
        echo -e "----------------------------------------------------------------------"
        echo -e "${DOCKER__FIVESPACES}1. Create an ${DOCKER__IMAGEID_FG_BORDEAUX}image${DOCKER__NOCOLOR} using a ${DOCKER__FG_DARKBLUE}docker-file${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FIVESPACES}2. Create ${DOCKER__IMAGEID_FG_BORDEAUX}images${DOCKER__NOCOLOR} using a ${DOCKER__TITLE_FG_LIGHTBLUE}docker-list${DOCKER__NOCOLOR}"
        echo -e "----------------------------------------------------------------------"
        echo -e "${DOCKER__FIVESPACES}r. Docker ${DOCKER__REPOSITORY_FG_PURPLE}repository${DOCKER__NOCOLOR} List"
        echo -e "${DOCKER__FIVESPACES}c. Docker ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}container${DOCKER__NOCOLOR} List"
        echo -e "----------------------------------------------------------------------"
        echo -e "${DOCKER__FIVESPACES}s. SSH"
        echo -e "----------------------------------------------------------------------"
        echo -e "${DOCKER__FIVESPACES}i. Load from File"
        echo -e "${DOCKER__FIVESPACES}e. Save to File"
        echo -e "----------------------------------------------------------------------"
        echo -e "${DOCKER__FIVESPACES}p. Git ${DOCKER__OUTSIDE_BG_LIGHTGREY}${DOCKER__OUTSIDE_FG_WHITE}Push${DOCKER__NOCOLOR}"
        echo -e "${DOCKER__FIVESPACES}g. Git ${DOCKER__INSIDE_BG_WHITE}${DOCKER__INSIDE_FG_LIGHTGREY}Pull${DOCKER__NOCOLOR}"
        echo -e "----------------------------------------------------------------------"
        echo -e "${DOCKER__FIVESPACES}h. Home"
        echo -e "${DOCKER__FIVESPACES}q. Quit (Ctrl+C)"
        echo -e "----------------------------------------------------------------------"
        echo -e "\r"	

        while true
        do
            #Select an option
            read -N 1 -e -p "Please choose an option: " docker__mychoice
            echo -e "\r"

            #Only continue if a valid option is selected
            if [[ ! -z ${docker__mychoice} ]]; then
                if [[ ${docker__mychoice} =~ [1-2,r,c,s,e,i,p,g,h,q] ]]; then
                    break
                else
                    tput cuu1	#move UP with 1 line
                    tput cuu1	#move UP with 1 line
                    tput el		#clear until the END of line
                fi
            else
                tput cuu1	#move UP with 1 line
                tput el		#clear until the END of line
            fi
        done
            
        #Goto the selected option
        case ${docker__mychoice} in
            1)
                echo -e "\r"
                echo -e "***STILL IN PROGRESS***"
                echo -e "***PLEASE DO NOT USE THIS OPTION YET***"
                echo -e "\r"

                docker__cmd_exec "${docker__create_an_image_from_dockerfile_fpath}"
                ;;

            2)
                docker__cmd_exec "${docker__create_images_from_dockerlist_fpath}"
                ;;

            c)
                docker__list_container__sub
                ;;

            r)
                docker__list_repository__sub
                ;;

            s)
                docker__cmd_exec "${docker__ssh_to_host_fpath}"
                ;;

            e)
                docker__cmd_exec "${docker__save_fpath}"
                ;;

            i)
                docker__cmd_exec "${docker__load_fpath}"
                ;;

            p)  
                docker__cmd_exec "${docker__git_push_fpath}"
                ;;

            g)  
                docker__cmd_exec "${docker__git_pull_fpath}"
                ;;

            h)
                docker__mainmenu__sub
                ;;

            q)
                exit
                ;;
        esac
    done
}

docker__list_repository__sub() {
    #Load header
    docker__load_header__sub

    #Get number of containers
    local numof_containers=`docker image ls | head -n -1 | wc -l`

    echo -e "----------------------------------------------------------------------"
    echo -e "\t${DOCKER__REPOSITORY_FG_PURPLE}REPOSITORY'S${DOCKER__NOCOLOR} ${DOCKER__GENERAL_FG_YELLOW}LIST${DOCKER__NOCOLOR} "
    echo -e "----------------------------------------------------------------------"
    
    #Get Docker Image's List
    docker image ls

    if [[ ${numof_containers} -eq 0 ]]; then
        echo -e "\r"
        echo -e "\t\t=:${DOCKER__ERROR_FG_LIGHTRED}NO IMAGES FOUND${DOCKER__NOCOLOR}:="
        echo -e "----------------------------------------------------------------------"
        echo -e "\r"

        press_any_key__localfunc
    else
        echo -e "\r"
        echo -e "\r"
    fi
}

docker__list_container__sub() {
    #Load header
    docker__load_header__sub

    #Get number of containers
    local numof_containers=`docker ps -a | head -n -1 | wc -l`

    echo -e "----------------------------------------------------------------------"
    echo -e "\t${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER'S${DOCKER__NOCOLOR} ${DOCKER__GENERAL_FG_YELLOW}LIST${DOCKER__NOCOLOR} "
    echo -e "----------------------------------------------------------------------"
    
    #Get Docker Container's List
    docker ps -a


    if [[ ${numof_containers} -eq 0 ]]; then
        echo -e "\r"
        echo -e "\t\t=:${DOCKER__ERROR_FG_LIGHTRED}NO CONTAINERS FOUND${DOCKER__NOCOLOR}:="
        echo -e "----------------------------------------------------------------------"
        echo -e "\r"

        press_any_key__localfunc
    else
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
