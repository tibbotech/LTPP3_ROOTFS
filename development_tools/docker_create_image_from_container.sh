#!/bin/bash
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


#---Define colors
DOCKER__YELLOW='\033[1;33m'
DOCKER__LIGHTGREEN='\033[1;32m'
DOCKER__ORANGE='\033[0;33m'
DOCKER__LIGHTRED='\033[1;31m'
DOCKER__CYAN='\033[0;36m'
DOCKER__PURPLE='\033[0;35m'
DOCKER__NOCOLOR='\033[0;0m'

DOCKER__READ_LIGHTGREEN=$'\e[1;32m'
DOCKER__READ_ORANGE=$'\e[0;33m'
DOCKER__READ_LIGHTRED=$'\e[1;31m'
DOCKER__READ_PURPLE=$'\e[0;35m'
DOCKER__READ_NOCOLOR=$'\e[0;0m'

DOCKER__BG_LIGHTBLUE='\e[30;48;5;45m'


#---Show Main Banner
echo -e "\r"
echo -e "${DOCKER__BG_LIGHTBLUE}                               DOCKER${DOCKER__BG_LIGHTBLUE}                               ${DOCKER__NOCOLOR}"


#---Show Docker Image List
echo -e "\r"
echo -e "--------------------------------------------------------------------"
echo -e "\t${DOCKER__YELLOW}Create${DOCKER__NOCOLOR} Docker ${DOCKER__CYAN}Image${DOCKER__NOCOLOR} from ${DOCKER__READ_LIGHTRED}Container${DOCKER__NOCOLOR}"
echo -e "--------------------------------------------------------------------"
sudo sh -c "docker container ls"
echo -e "\r"

while true
do
    #Provide a CONTAINER-ID from which you want to create an Image
    read -p "Choose a ${DOCKER__READ_PURPLE}CONTAINER-ID${DOCKER__READ_NOCOLOR} (e.g. dfc5e2f3f7ee): " mycontainerid_input
    if [[ ! -z ${mycontainerid_input} ]]; then    #input is NOT an EMPTY STRING

        #Check if 'mycontainerid_input' is found in ' docker container ls'
        mycontainerid_isFound=`sudo docker container ls | awk '{print $1}' | grep -w ${mycontainerid_input}`
        if [[ ! -z ${mycontainerid_isFound} ]]; then    #match was found

            #Show Docker Image List
            echo -e "\r"            
            sudo sh -c "docker image ls"
            echo -e "\r"

            while true
            do
                #Provide a REPOSITORY for this new image
                read -p "Provide a ${DOCKER__READ_LIGHTGREEN}REPOSITORY${DOCKER__READ_NOCOLOR} (e.g. ubuntu_test) for this new image: " myrepository_input
                if [[ ! -z ${myrepository_input} ]]; then   #input was NOT an Empty String
                    
                    while true
                    do
                        #Provide a TAG for this new image
                        read -p "Provide a ${DOCKER__READ_ORANGE}TAG${DOCKER__READ_NOCOLOR} (e.g. test) for this new image: " mytag_input
                        if [[ ! -z ${mytag_input} ]]; then   #input is NOT an Empty String

                            myrepository_with_this_tag_isUnique=`sudo docker image ls | grep -w "${myrepository_input}" | grep -w "${mytag_input}"`    #check if 'myrepository_input' AND 'mytag_input' is found in 'docker image ls'
                            if [[ -z ${myrepository_with_this_tag_isUnique} ]]; then    #match was NOT found
                                #Create Docker Image based on chosen Container-ID                
                                sudo sh -c "docker commit ${mycontainerid_input} ${myrepository_input}:${mytag_input}"            

                                #Show Docker Image List
                                echo -e "\r"            
                                sudo sh -c "docker image ls"
                                echo -e "\r"

                                exit
                            else
                                echo -e "\r"
                                echo -e "A REPOSITORY '${DOCKER__LIGHTGREEN}${myrepository_input}${DOCKER__NOCOLOR}' with this TAG '${DOCKER__ORANGE}${mytag_input}${DOCKER__NOCOLOR}' already exist"

                                sleep 3

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
            echo -e "Provided CONTAINER-ID: ${DOCKER__PURPLE}${mycontainerid_input}${DOCKER__NOCOLOR} not found"

            sleep 2

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

