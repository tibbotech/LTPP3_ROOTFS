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
    docker__mycontainerid_input=""
    docker__mycontainerid_subst=""
    docker__mycontainerid_arr=()
    docker__mycontainerid_item=""
    docker__mycontainerid_isFound=""
    docker__myanswer=""
}

docker__input_containerid__sub() {
    #RESET VARIABLE (IMPORTANT)
    if [[ ${docker__myanswer} != "b" ]]; then
        docker__mycontainerid=""
    fi

    while true
    do
        echo -e "${DOCKER__REMARK_BG_ORANGE}Remarks:${DOCKER__NOCOLOR}" 
        echo -e "- Multiple image-ids can be removed"
        echo -e "- Comma-separator will be auto-appended (e.g. 3e2226b5fb4c,78ae00114c5a)"
		echo -e "- [On an Empty Field] press ENTER to stop input"
        echo -e "${DOCKER__CONTAINER_BG_BRIGHTPRUPLE}Remove the following ${DOCKER__OUTSIDE_FG_WHITE}CONTAINER-ID${DOCKER__NOCOLOR}:${DOCKER__CONTAINER_BG_BRIGHTPRUPLE}${DOCKER__OUTSIDE_FG_WHITE}${docker__mycontainerid}${DOCKER__NOCOLOR}"
        read -p "Paste your input (here): " docker__mycontainerid_input

        if [[ -z ${docker__mycontainerid_input} ]]; then
            break
        else
            if [[ -z ${docker__mycontainerid} ]]; then
                docker__mycontainerid="${docker__mycontainerid_input}"
            else
                docker__mycontainerid="${docker__mycontainerid},${docker__mycontainerid_input}"
            fi

            tput cuu1
            tput el
            tput cuu1
            tput el
            tput cuu1
            tput el
            tput cuu1
            tput el
            tput cuu1
            tput el
            tput cuu1
            tput el
        fi
    done
}

docker_remove_specified_containers__sub() {
    #Get number of containers
    local numof_containers=`docker container ls | head -n -1 | wc -l`

    echo -e "----------------------------------------------------------------------"
    echo -e "\t${DOCKER__GENERAL_FG_YELLOW}Remove${DOCKER__NOCOLOR} ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER(s)${DOCKER__NOCOLOR}"
    echo -e "----------------------------------------------------------------------"
        docker container ls

        if [[ ${numof_containers} -eq 0 ]]; then
            echo -e "\r"
            echo -e "\t\t=:${DOCKER__ERROR_FG_LIGHTRED}NO CONTAINERS FOUND${DOCKER__NOCOLOR}:="
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
        #Input CONTAINERID(s) which you want to REMOVE
        #REMARK: subroutine 'docker__input_containerid__sub' will output variable 'docker__mycontainerid'
        docker__input_containerid__sub

        if [[ ! -z ${docker__mycontainerid} ]]; then
            #Substitute COMMA with SPACE
            docker__mycontainerid_subst=`echo ${docker__mycontainerid} | sed 's/,/\ /g'`

            #Convert to Array
            eval "docker__mycontainerid_arr=(${docker__mycontainerid_subst})"

            #Go thru each array-item
            echo -e "\r"
            while true
            do
                read -p "Do you wish to continue (y/n/q/b)? " docker__myanswer
                if [[ ! -z ${docker__myanswer} ]]; then          
                    if [[ ${docker__myanswer} == "y" ]] || [[ ${docker__myanswer} == "Y" ]]; then
                        for docker__mycontainerid_item in "${docker__mycontainerid_arr[@]}"
                        do 
                            docker__mycontainerid_isFound=`docker container ls | awk '{print $1}' | grep -w ${docker__mycontainerid_item}`
                            if [[ ! -z ${docker__mycontainerid_isFound} ]]; then
                                docker container rm -f ${docker__mycontainerid_item} > /dev/null
                                echo -e "\r"
                                echo -e "Removed CONTAINER-ID: ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}${docker__mycontainerid_item}${DOCKER__NOCOLOR}"
                                echo -e "\r"
                                echo -e "Removing ALL unlinked images"
                                echo -e "y\n" | docker image prune
                                echo -e "Removing ALL stopped containers"
                                echo -e "y\n" | docker container prune           
                            else
                                echo -e "\r"
                                echo -e "***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Invalid CONTAINER-ID: ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}${docker__mycontainerid_item}${DOCKER__NOCOLOR}"
                            fi
                        done

                        # echo -e "\r"
                        # docker image ls
                        echo -e "\r"
                        echo -e "\r"
                        echo -e "----------------------------------------------------------------------"
                            docker container ls
                        echo -e "----------------------------------------------------------------------"
                        echo -e "\r"

                        break
                    elif [[ ${docker__myanswer} == "n" ]]; then
                        tput cuu1
                        tput el
                        tput cuu1
                        tput el
                        tput cuu1
                        tput el
                        tput cuu1
                        tput el
                        tput cuu1
                        tput el
                        tput cuu1
                        tput el
                        tput cuu1
                        tput el
                        tput cuu1
                        tput el

                        break
                    elif [[ ${docker__myanswer} == "q" ]] || [[ ${docker__myanswer} == "Q" ]]; then
                        echo -e "\r"
                        echo -e "Exiting now..."
                        echo -e "\r"
                        echo -e "\r"

                        exit
                    elif [[ ${docker__myanswer} == "b" ]]; then
                        tput cuu1
                        tput el
                        tput cuu1
                        tput el
                        tput cuu1
                        tput el
                        tput cuu1
                        tput el
                        tput cuu1
                        tput el
                        tput cuu1
                        tput el
                        tput cuu1
                        tput el
                        tput cuu1
                        tput el

                        break
                    else
                        tput cuu1
                        tput el
                    fi
                else
                    tput cuu1
                    tput el
                fi
            done
        else
            tput cuu1	#move UP with 1 line
            tput el		#clear until the END of line
            tput cuu1	#move UP with 1 line
            tput el		#clear until the END of line
            tput cuu1	#move UP with 1 line
            tput el		#clear until the END of line
            tput cuu1	#move UP with 1 line
            tput el		#clear until the END of line
            tput cuu1	#move UP with 1 line
            tput cuu1	#move UP with 1 line
            tput el		#clear until the END of line
        fi
    done
}

main_sub() {
    docker__load_header__sub

    docker__init_variables__sub

    docker_remove_specified_containers__sub
}


#Execute main subroutine
main_sub