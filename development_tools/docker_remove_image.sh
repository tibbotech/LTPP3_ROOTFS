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
DOCKER__NOCOLOR='\033[0;0m'
DOCKER__YELLOW='\033[1;33m'
DOCKER__ORANGE='\033[0;33m'
DOCKER__LIGHTRED='\033[1;31m'

DOCKER__READ_LIGHTRED=$'\e[1;31m'
DOCKER__READ_NOCOLOR=$'\e[0;0m'

DOCKER__BG_LIGHTBLUE='\e[30;48;5;45m'


#---Show Main Banner
echo -e "\r"
echo -e "${DOCKER__BG_LIGHTBLUE}                               DOCKER${DOCKER__BG_LIGHTBLUE}                               ${DOCKER__NOCOLOR}"


#---Show Docker Image List
echo -e "\r"
echo -e "--------------------------------------------------------------------"
echo -e "\t${DOCKER__YELLOW}Remove${DOCKER__NOCOLOR} Docker Image(s)"
echo -e "--------------------------------------------------------------------"
sudo sh -c "docker image ls"
echo -e "\r"

while true
do
    #Show input field
    echo -e "${DOCKER__ORANGE}Remarks:${DOCKER__NOCOLOR}" 
    echo -e "- multiple image-ids can be removed."
    echo -e "- Use comma as separator (e.g. 0f7478cf7cab,5f1b8726ca97)"
    read -p "Remove the following ${DOCKER__READ_LIGHTRED}IMAGE-ID(s)${DOCKER__READ_NOCOLOR}: " myimageid_input
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
                    echo -e "Removed IMAGE-ID: ${DOCKER__LIGHTRED}${myimageid_item}${DOCKER__NOCOLOR}"
                    echo -e "\r"
                    echo -e "Removing ALL unlinked images"
                    echo -e "y\n" | sudo sh -c "docker image prune"
                    echo -e "Removing ALL stopped containers"
                    echo -e "y\n" | sudo sh -c "docker container prune"
                else
                    echo -e "\r"
                    echo -e "***ERROR: Invalid IMAGE-ID: ${DOCKER__LIGHTRED}${myimageid_item}${DOCKER__NOCOLOR}"
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
