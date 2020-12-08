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
DOCKER__NOCOLOR='\033[0;0m'
DOCKER__YELLOW='\033[1;33m'
DOCKER__ORANGE='\033[0;33m'
DOCKER__LIGHTRED='\033[1;31m'

DOCKER__READ_LIGHTRED=$'\e[1;31m'
DOCKER__READ_NOCOLOR=$'\e[0;0m'

DOCKER__BG_LIGHTBLUE='\e[30;48;5;45m'

#SHOW DOCKER BANNER
echo -e "\r"
echo -e "${DOCKER__BG_LIGHTBLUE}                               DOCKER${DOCKER__BG_LIGHTBLUE}                               ${DOCKER__NOCOLOR}"

#---Show Docker Image List
echo -e "\r"
echo -e "--------------------------------------------------------------------"
echo -e "\t${DOCKER__YELLOW}Remove${DOCKER__NOCOLOR} Docker Container(s)"
echo -e "--------------------------------------------------------------------"
sudo sh -c "docker container ls"
echo -e "\r"

while true
do
    #Show input field
    echo -e "${DOCKER__ORANGE}Remarks:${DOCKER__NOCOLOR}" 
    echo -e "- multiple image-ids can be removed."
    echo -e "- Use comma as separator (e.g. 3e2226b5fb4c,78ae00114c5a)"
    read -p "Remove the following ${DOCKER__READ_LIGHTRED}CONTAINER-ID${DOCKER__READ_NOCOLOR}: " mycontainerid_input
    if [[ ! -z ${mycontainerid_input} ]]; then
        #Substitute COMMA with SPACE
        mycontainerid_input_subst=`echo ${mycontainerid_input} | sed 's/,/\ /g'`

        #Convert to Array
        eval "mycontainerid_arr=(${mycontainerid_input_subst})"

        #Go thru each array-item
        echo -e "\r"
        read -p "Do you wish to continue (y/n/q)? " myanswer                  
        if [[ ${myanswer} == "y" ]] || [[ ${myanswer} == "Y" ]]; then
            for mycontainerid_item in "${mycontainerid_arr[@]}"
            do 
                mycontainerid_isFound=`sudo docker container ls | awk '{print $1}' | grep -w ${mycontainerid_item}`
                if [[ ! -z ${mycontainerid_isFound} ]]; then
                    sudo sh -c "docker container rm -f ${mycontainerid_item}" > /dev/null
                    echo -e "\r"
                    echo -e "Removed CONTAINER-ID: ${DOCKER__LIGHTRED}${mycontainerid_item}${DOCKER__NOCOLOR}"
                    echo -e "\r"
                    echo -e "Removing ALL unlinked images"
                    echo -e "y\n" | sudo sh -c "docker image prune"
                    echo -e "Removing ALL stopped containers"
                    echo -e "y\n" | sudo sh -c "docker container prune"                
                else
                    echo -e "\r"
                    echo -e "***ERROR: Invalid CONTAINER-ID: ${DOCKER__LIGHTRED}${mycontainerid_item}${DOCKER__NOCOLOR}"
                fi
            done

            echo -e "\r"
            sudo sh -c "docker image ls"
            echo -e "\r"
            sudo sh -c "docker container ls"
            echo -e "\r"
        elif [[ ${myanswer} == "q" ]] || [[ ${myanswer} == "Q" ]]; then
            echo -e "\r"
            echo -e "Exiting now..."
            echo -e "\r"
            echo -e "\r"

            exit
        fi
    else
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
