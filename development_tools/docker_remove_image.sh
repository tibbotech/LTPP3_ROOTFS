#!/bin/bash
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


#---Define colors
DOCKER_NOCOLOR='\033[0;0m'
DOCKER_YELLOW='\033[1;33m'
DOCKER_ORANGE='\033[0;33m'
DOCKER_LIGHTRED='\033[1;31m'

DOCKER_READ_LIGHTRED=$'\e[1;31m'
DOCKER_READ_NOCOLOR=$'\e[0;0m'


#---Show Docker Image List
echo -e "\r"
echo -e "------------------------------------------------------------"
echo -e "\t${DOCKER_YELLOW}Remove${DOCKER_NOCOLOR} Docker Image(s)"
echo -e "------------------------------------------------------------"
sudo sh -c "docker image ls"
echo -e "\r"

while true
do
    #Show input field
    echo -e "${DOCKER_ORANGE}Remarks:${DOCKER_NOCOLOR}" 
    echo -e "- multiple image-ids can be removed."
    echo -e "- Use comma as separator (e.g. 0f7478cf7cab,5f1b8726ca97)"
    read -p "Remove the following ${DOCKER_READ_LIGHTRED}IMAGE-ID(s)${DOCKER_READ_NOCOLOR}: " myimageid_input
    if [[ ! -z ${myimageid_input} ]]; then
        #Substitute COMMA with SPACE
        myimageid_input_subst=`echo ${myimageid_input} | sed 's/,/\ /g'`

        #Convert to Array
        eval "myimageid_arr=(${myimageid_input_subst})"

        #Go thru each array-item
        echo -e "\r"
        read -p "Do you wish to continue (y/n/q)? " myanswer                  
        if [[ ${myanswer} == "y" ]] || [[ ${myanswer} == "Y" ]]; then
            for myimageid_item in "${myimageid_arr[@]}"
            do 
                myimageid_isFound=`sudo docker image ls | awk '{print $3}' | grep -w ${myimageid_item}`
                if [[ ! -z ${myimageid_isFound} ]]; then
                    sudo sh -c "docker image rmi -f ${myimageid_item}" > /dev/null
                    echo -e "\r"
                    echo -e "Removed IMAGE-ID: ${DOCKER_LIGHTRED}${myimageid_item}${DOCKER_NOCOLOR}"
                    echo -e "\r"
                    echo -e "Removing ALL unlinked images"
                    echo -e "y\n" | sudo sh -c "docker image prune"
                    echo -e "Removing ALL stopped containers"
                    echo -e "y\n" | sudo sh -c "docker container prune"
                else
                    echo -e "\r"
                    echo -e "***ERROR: Invalid IMAGE-ID: ${DOCKER_LIGHTRED}${myimageid_item}${DOCKER_NOCOLOR}"
                fi
            done

            echo -e "\r"
            sudo sh -c "docker image ls"
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
