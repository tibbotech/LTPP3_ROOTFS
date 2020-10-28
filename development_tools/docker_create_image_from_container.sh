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
DOCKER_YELLOW='\033[1;33m'
DOCKER_LIGHTGREEN='\033[1;32m'
DOCKER_ORANGE='\033[0;33m'
DOCKER_LIGHTRED='\033[1;31m'
DOCKER_CYAN='\033[0;36m'
DOCKER_PURPLE='\033[0;35m'
DOCKER_NOCOLOR='\033[0;0m'

DOCKER_READ_LIGHTGREEN=$'\e[1;32m'
DOCKER_READ_ORANGE=$'\e[0;33m'
DOCKER_READ_LIGHTRED=$'\e[1;31m'
DOCKER_READ_PURPLE=$'\e[0;35m'
DOCKER_READ_NOCOLOR=$'\e[0;0m'


#---Show Docker Image List
echo -e "\r"
echo -e "------------------------------------------------------------"
echo -e "\t${DOCKER_YELLOW}Create${DOCKER_NOCOLOR} Docker ${DOCKER_CYAN}Image${DOCKER_NOCOLOR} from ${DOCKER_READ_LIGHTRED}Container${DOCKER_NOCOLOR}"
echo -e "------------------------------------------------------------"
sudo sh -c "docker container ls"
echo -e "\r"

while true
do
    #Provide a CONTAINER-ID from which you want to create an Image
    read -p "Choose a ${DOCKER_READ_PURPLE}CONTAINER-ID${DOCKER_READ_NOCOLOR} (e.g. dfc5e2f3f7ee): " mycontainerid_input
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
                read -p "Provide a ${DOCKER_READ_LIGHTGREEN}REPOSITORY${DOCKER_READ_NOCOLOR} (e.g. ubuntu_test) for this new image: " myrepository_input
                if [[ ! -z ${myrepository_input} ]]; then   #input was NOT an Empty String
                    
                    while true
                    do
                        #Provide a TAG for this new image
                        read -p "Provide a ${DOCKER_READ_ORANGE}TAG${DOCKER_READ_NOCOLOR} (e.g. test) for this new image: " mytag_input
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
                                echo -e "A REPOSITORY '${DOCKER_LIGHTGREEN}${myrepository_input}${DOCKER_NOCOLOR}' with this TAG '${DOCKER_ORANGE}${mytag_input}${DOCKER_NOCOLOR}' already exist"

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
            echo -e "Provided CONTAINER-ID: ${DOCKER_PURPLE}${mycontainerid_input}${DOCKER_NOCOLOR} not found"

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

