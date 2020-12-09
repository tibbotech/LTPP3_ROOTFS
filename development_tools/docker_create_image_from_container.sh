#!/bin/bash
#---Define colors
DOCKER__READ_FG_YELLOW=$'\e[1;33m'
DOCKER__READ_FG_LIGHTGREEN=$'\e[1;32m'
DOCKER__READ_FG_ORANGE=$'\e[0;33m'
DOCKER__READ_FG_LIGHTRED=$'\e[1;31m'
DOCKER__READ_FG_CYAN=$'\e[0;36m'
DOCKER__READ_FG_PURPLE=$'\e[0;35m'
DOCKER__READ_FG_LIGHTPINK=$'\e[30;38;5;218m'
DOCKER__READ_NOCOLOR=$'\e[0;0m'

DOCKER__READ_BG_LIGHTBLUE=$'\e[30;48;5;45m'


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


#---Show Main Banner
echo -e "\r"
echo -e "${DOCKER__READ_BG_LIGHTBLUE}                                DOCKER${DOCKER__READ_BG_LIGHTBLUE}                                ${DOCKER__READ_NOCOLOR}"

#---Show Docker Image List
echo -e "\r"
echo -e "----------------------------------------------------------------------"
echo -e "\t${DOCKER__READ_FG_YELLOW}Create${DOCKER__READ_NOCOLOR} Docker ${DOCKER__READ_FG_CYAN}Image${DOCKER__READ_NOCOLOR} from ${DOCKER__READ_FG_LIGHTRED}Container${DOCKER__READ_NOCOLOR}"
echo -e "----------------------------------------------------------------------"
sudo sh -c "docker container ls"
echo -e "\r"

while true
do
    #Provide a CONTAINER-ID from which you want to create an Image
    read -p "Choose a ${DOCKER__READ_FG_LIGHTGREEN}CONTAINER-ID${DOCKER__READ_NOCOLOR} (e.g. dfc5e2f3f7ee): " mycontainerid
    if [[ ! -z ${mycontainerid} ]]; then    #input is NOT an EMPTY STRING

        #Check if 'mycontainerid' is found in ' docker container ls'
        mycontainerid_isFound=`sudo docker container ls | awk '{print $1}' | grep -w ${mycontainerid}`
        if [[ ! -z ${mycontainerid_isFound} ]]; then    #match was found

            #Show Docker Image List
            echo -e "\r"            
            sudo sh -c "docker image ls"
            echo -e "\r"

            while true
            do
                #Provide a REPOSITORY for this new image
                read -p "Give a ${DOCKER__READ_FG_PURPLE}REPOSITORY${DOCKER__READ_NOCOLOR} name (e.g. ubuntu_test) for this *NEW* image: " myrepository_input
                if [[ ! -z ${myrepository_input} ]]; then   #input was NOT an Empty String
                    
                    while true
                    do
                        #Provide a TAG for this new image
                        read -p "Give a ${DOCKER__READ_FG_ORANGE}TAG${DOCKER__READ_NOCOLOR} (e.g. test) for this *NEW* image: " mytag_input
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
                                echo -e "***${DOCKER__READ_FG_LIGHTRED}ERROR${DOCKER__READ_NOCOLOR}: REPOSITORY '${DOCKER__READ_FG_PURPLE}${myrepository_input}${DOCKER__READ_NOCOLOR}' with TAG '${DOCKER__READ_FG_LIGHTPINK}${mytag_input}${DOCKER__READ_NOCOLOR}' already exist"

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
            echo -e "***${DOCKER__READ_FG_LIGHTRED}ERROR${DOCKER__READ_NOCOLOR}: non-existing CONTAINER ${DOCKER__READ_FG_LIGHTGREEN}${mycontainerid}${DOCKER__READ_NOCOLOR}"

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

