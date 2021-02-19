#!/bin/bash
#---Define colors
DOCKER__NOCOLOR=$'\e[0;0m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__IMAGEID_FG_BORDEAUX=$'\e[30;38;5;198m'
DOCKER__OUTSIDE_FG_WHITE=$'\e[30;38;5;231m'

DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'
DOCKER__TITLE_BG_LIGHTBLUE=$'\e[30;48;5;45m'
DOCKER__IMAGEID_BG_BORDEAUX=$'\e[30;48;5;198m'
DOCKER__REMARK_BG_ORANGE=$'\e[30;48;5;208m'

#---Define constants
DOCKER__TITLE="TIBBO"


#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C__func INT

function CTRL_C__func() {
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
    docker__myimageid=""
    docker__myimageid_input=""
    docker__myimageid_subst=""
    docker__myimageid_arr=()
    docker__myimageid_item=""
    docker__myimageid_isFound=""
    docker__myanswer=""
}

docker__input_imageid__sub() {
    #RESET VARIABLE (IMPORTANT)
    if [[ ${docker__myanswer} != "b" ]]; then
        docker__myimageid=""
    fi

	while true
	do
		echo -e "${DOCKER__REMARK_BG_ORANGE}Remarks:${DOCKER__NOCOLOR}" 
		echo -e "- Multiple image-ids can be removed"
		echo -e "- Comma-separator will be auto-appended (e.g. 0f7478cf7cab,5f1b8726ca97)"
		echo -e "- [On an Empty Field] press ENTER to stop input"
		echo -e "${DOCKER__IMAGEID_BG_BORDEAUX}Remove the following ${DOCKER__OUTSIDE_FG_WHITE}IMAGE-ID(s)${DOCKER__NOCOLOR}:${DOCKER__IMAGEID_BG_BORDEAUX}${DOCKER__OUTSIDE_FG_WHITE}${docker__myimageid}${DOCKER__NOCOLOR}"
		read -p "Paste your input (here): " docker__myimageid_input

		if [[ -z ${docker__myimageid_input} ]]; then
			break
		else
			if [[ -z ${docker__myimageid} ]]; then
				docker__myimageid="${docker__myimageid_input}"
			else
				docker__myimageid="${docker__myimageid},${docker__myimageid_input}"
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

docker__remove_specified_images__sub() {
    #Get number of images
    local numof_images=`docker image ls | head -n -1 | wc -l`

    echo -e "----------------------------------------------------------------------"
    echo -e "\t${DOCKER__GENERAL_FG_YELLOW}Remove${DOCKER__NOCOLOR} DOCKER ${DOCKER__IMAGEID_FG_BORDEAUX}IMAGE(s)${DOCKER__NOCOLOR}"
    echo -e "----------------------------------------------------------------------"
        docker image ls
    
    if [[ ${numof_images} -eq 0 ]]; then
        echo -e "\r"
        echo -e "\t\t=:${DOCKER__ERROR_FG_LIGHTRED}NO IMAGES FOUND${DOCKER__NOCOLOR}:="
        echo -e "----------------------------------------------------------------------"
        echo -e "\r"

        press_any_key__localfunc

        exit
    else
        echo -e "----------------------------------------------------------------------"
    fi    

    #Add an empty line
    echo -e "\r"
    
    while true
    do
        #Input CONTAINERID(s) which you want to REMOVE
        #REMARK: subroutine 'docker__input_imageid__sub' will output variable 'docker__myimageid'
        docker__input_imageid__sub

        if [[ ! -z ${docker__myimageid} ]]; then
            #Substitute COMMA with SPACE
            docker__myimageid_subst=`echo ${docker__myimageid} | sed 's/,/\ /g'`

            #Convert to Array
            eval "docker__myimageid_arr=(${docker__myimageid_subst})"

            #Go thru each array-item
            echo -e "\r"

            while true
            do
                read -p "Do you wish to continue (y/n/q/b)? " docker__myanswer
                if [[ ! -z ${docker__myanswer} ]]; then          
                    if [[ ${docker__myanswer} == "y" ]] || [[ ${docker__myanswer} == "Y" ]]; then
                        for docker__myimageid_item in "${docker__myimageid_arr[@]}"
                        do 
                            docker__myimageid_isFound=`docker image ls | awk '{print $3}' | grep -w ${docker__myimageid_item}`
                            if [[ ! -z ${docker__myimageid_isFound} ]]; then
                                docker image rmi -f ${docker__myimageid_item} > /dev/null
                                echo -e "\r"
                                echo -e "Removed IMAGE-ID: ${DOCKER__IMAGEID_FG_BORDEAUX}${docker__myimageid_item}${DOCKER__NOCOLOR}"
                                echo -e "\r"
                                echo -e "Removing ALL unlinked images"
                                echo -e "y\n" | docker image prune
                                echo -e "Removing ALL stopped containers"
                                echo -e "y\n" | docker container prune
                            else
                                echo -e "\r"
                                echo -e "***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Invalid IMAGE-ID: ${DOCKER__IMAGEID_FG_BORDEAUX}${docker__myimageid_item}${DOCKER__NOCOLOR}"
                            fi
                        done

                        echo -e "\r"
                        echo -e "----------------------------------------------------------------------"
                            docker image ls
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
            tput el		#clear until the END of line
            tput cuu1	#move UP with 1 line
            tput el		#clear until the END of line
        fi
    done
}

main_sub() {
    docker__load_header__sub

    docker__init_variables__sub

    docker__remove_specified_images__sub
}


#Execute main subroutine
main_sub
