#!/bin/bash
#---Define colors
DOCKER__NOCOLOR=$'\e[0;0m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__CONTAINER_FG_BRIGHTPRUPLE=$'\e[30;38;5;141m'
DOCKER__OUTSIDE_FG_WHITE=$'\e[30;38;5;231m'

DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'
DOCKER__TITLE_BG_LIGHTBLUE=$'\e[30;48;5;45m'
DOCKER__REMARK_BG_ORANGE=$'\e[30;48;5;208m'
DOCKER__CONTAINER_BG_BRIGHTPRUPLE=$'\e[30;48;5;141m'

#---Define constants
DOCKER__TITLE="TIBBO"


#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C_func INT

function CTRL_C_func() {
    echo -e "\r"
    echo -e "\r"
    echo -e "Exiting now..."
    echo -e "\r"
    echo -e "\r"

    exit
}


#---Local functions & subroutines
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

docker__load_header__sub() {
    echo -e "\r"
    echo -e "${DOCKER__TITLE_BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__TITLE_BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__init_variables__sub() {
    docker__mycontainerid=""
    docker__mycontainerid_isFound=""

}

docker_run_specified_exited_container__sub() {
    #Get number of containers
    local numof_containers=`docker container ps -a | head -n -1 | wc -l`

    echo -e "----------------------------------------------------------------------"
    echo -e "\t${DOCKER__GENERAL_FG_YELLOW}RUN${DOCKER__NOCOLOR} EXITED ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER${DOCKER__NOCOLOR}"
    echo -e "----------------------------------------------------------------------"
        docker ps -a

        if [[ ${numof_containers} -eq 0 ]]; then
            echo -e "\r"
            echo -e "\t\t=:${DOCKER__ERROR_FG_LIGHTRED}NO *EXITED* CONTAINERS FOUND${DOCKER__NOCOLOR}:="
            echo -e "----------------------------------------------------------------------"
            echo -e "\r"

            press_any_key__localfunc

            exit
        else
            echo -e "----------------------------------------------------------------------"
        fi

    echo -e "\r"

    while true
    do
        read -p "Choose a ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER-ID${DOCKER__NOCOLOR} (e.g. dfc5e2f3f7ee): " docker__mycontainerid

        if [[ ! -z ${docker__mycontainerid} ]]; then
            docker__mycontainerid_isFound=`docker container ps -a | awk '{print $1}' | grep -w ${docker__mycontainerid}`          

            if [[ ! -z ${docker__mycontainerid_isFound} ]]; then    #match was found
                docker start ${docker__mycontainerid}

                echo -e "\r"
                    docker ps -a
                echo -e "\r"

                exit
            else
                echo -e "\r"
                echo -e "***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: non-existing CONTAINER ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}${mycontainerid}${DOCKER__NOCOLOR}"

                press_any_key__localfunc

                tput cuu1	#move UP with 1 line
                tput el		#clear until the END of line
                tput cuu1	#move UP with 1 line
                tput el		#clear until the END of line
                tput cuu1	#move UP with 1 line
                tput el		#clear until the END of line
                tput cuu1	#move UP with 1 line
                tput el		#clear until the END of line
                tput cuu1	#move UP with 1 line
                tput el		#clear until the END of line    
            fi
        else
            tput cuu1	#move UP with 1 line
            tput el		#clear until the END of line
        fi
    done
}

main_sub() {
    docker__load_header__sub

    docker__init_variables__sub

    docker_run_specified_exited_container__sub
}


#Execute main subroutine
main_sub