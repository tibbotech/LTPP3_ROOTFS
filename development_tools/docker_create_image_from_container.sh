#!/bin/bash
#---Define colors
DOCKER__NOCOLOR=$'\e[0;0m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__IMAGEID_FG_BORDEAUX=$'\e[30;38;5;198m'
DOCKER__REPOSITORY_FG_PURPLE=$'\e[30;38;5;93m'
DOCKER__CONTAINER_FG_BRIGHTPRUPLE=$'\e[30;38;5;141m'
DOCKER__TAG_FG_LIGHTPINK=$'\e[30;38;5;218m'

DOCKER__TITLE_BG_LIGHTBLUE=$'\e[30;48;5;45m'

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
    echo -e "${DOCKER__TITLE_BG_LIGHTBLUE}                                DOCKER${DOCKER__TITLE_BG_LIGHTBLUE}                                ${DOCKER__NOCOLOR}"
}

docker__create_image_of_specified_container__sub() {
    #Get number of containers
    local numof_containers=`sudo sh -c "docker container ls | head -n -1 | wc -l"`

    #---Show Docker Image List
    echo -e "----------------------------------------------------------------------"
    echo -e "\t${DOCKER__GENERAL_FG_YELLOW}Create${DOCKER__NOCOLOR} Docker ${DOCKER__IMAGEID_FG_BORDEAUX}IMAGE${DOCKER__NOCOLOR} from ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER${DOCKER__NOCOLOR}"
    echo -e "----------------------------------------------------------------------"
        sudo sh -c "docker container ls"

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
        #Provide a CONTAINER-ID from which you want to create an Image
        read -p "Choose a ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER-ID${DOCKER__NOCOLOR} (e.g. dfc5e2f3f7ee): " mycontainerid
        if [[ ! -z ${mycontainerid} ]]; then    #input is NOT an EMPTY STRING

            #Check if 'mycontainerid' is found in ' docker container ls'
            mycontainerid_isFound=`sudo docker container ls | awk '{print $1}' | grep -w ${mycontainerid}`
            if [[ ! -z ${mycontainerid_isFound} ]]; then    #match was found
                #Get number of images
                local numof_images=$((docker_image_ls_lines-1))

                #Show Docker Image List
                echo -e "\r"
                echo -e "----------------------------------------------------------------------"
                echo -e "\t${DOCKER__GENERAL_FG_YELLOW}Build${DOCKER__NOCOLOR} Docker ${DOCKER__IMAGEID_FG_BORDEAUX}IMAGE${DOCKER__NOCOLOR} from existing ${DOCKER__REPOSITORY_FG_PURPLE}REPOSITORY${DOCKER__NOCOLOR}"
                echo -e "----------------------------------------------------------------------"
                    sudo sh -c "docker image ls"

                if [[ ${numof_images} -eq 0 ]]; then
                    echo -e "\r"
                    echo -e "\t\t=:${DOCKER__ERROR_FG_LIGHTRED}NO IMAGES FOUND${DOCKER__NOCOLOR}:="
                    echo -e "----------------------------------------------------------------------"
                    echo -e "\r"

                    exit
                else
                    echo -e "----------------------------------------------------------------------"
                fi  

                while true
                do
                    #Provide a REPOSITORY for this new image
                    read -p "Give a ${DOCKER__REPOSITORY_FG_PURPLE}REPOSITORY${DOCKER__NOCOLOR} name (e.g. ubuntu_test) for this ${DOCKER__GENERAL_FG_YELLOW}NEW${DOCKER__NOCOLOR} ${DOCKER__IMAGEID_FG_BORDEAUX}IMAGE${DOCKER__NOCOLOR}: " myrepository_input
                    if [[ ! -z ${myrepository_input} ]]; then   #input was NOT an Empty String
                        
                        while true
                        do
                            #Provide a TAG for this new image
                            read -p "Give a ${DOCKER__TAG_FG_LIGHTPINK}TAG${DOCKER__NOCOLOR} (e.g. test) for this ${DOCKER__GENERAL_FG_YELLOW}NEW${DOCKER__NOCOLOR} ${DOCKER__IMAGEID_FG_BORDEAUX}IMAGE${DOCKER__NOCOLOR}: " mytag_input
                            if [[ ! -z ${mytag_input} ]]; then   #input is NOT an Empty String

                                myrepository_with_this_tag_isUnique=`sudo docker image ls | grep -w "${myrepository_input}" | grep -w "${mytag_input}"`    #check if 'myrepository_input' AND 'mytag_input' is found in 'docker image ls'
                                if [[ -z ${myrepository_with_this_tag_isUnique} ]]; then    #match was NOT found
                                    #Create Docker Image based on chosen Container-ID                
                                    sudo sh -c "docker commit ${mycontainerid} ${myrepository_input}:${mytag_input}"            

                                    #Show Docker Image List
                                    echo -e "\r"            
                                    sudo sh -c "docker image ls"
                                    echo -e "\r"

                                    exit
                                else
                                    echo -e "\r"
                                    echo -e "***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: REPOSITORY ${DOCKER__REPOSITORY_FG_PURPLE}${myrepository_input}${DOCKER__NOCOLOR} with TAG ${DOCKER__TAG_FG_LIGHTPINK}${mytag_input}${DOCKER__NOCOLOR} already exist"

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
                    else    #input was an Empty String
                        tput cuu1	#move UP with 1 line
                        tput el		#clear until the END of line
                    fi
                done
            else    #NO match was found
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

    docker__create_image_of_specified_container__sub
}


#Execute main subroutine
main_sub
