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


#---Local functions
get_assigned_ipv4_addresses__func() {
    #Define variabes
    local iproute_line=""
    local dev_colno=0
    local src_colno=0
    local nic_name=""
    local ipv4addr=""
    local nic_belongs_toDocker=""
    local ipv4addr_isPresent=""
    local i=0

    #Get Network-adapter vs. IP-address
    local numOf_iproute_results=`ip route | wc -l`
    if [[ $numOf_iproute_results -ne 0 ]]; then
        for ((i = 1 ; i <= ${numOf_iproute_results} ; i++)); do
            iproute_line=`ip route | head -"$i" | tail -1`	#get ip route result for line i
            
            dev_colno=`echo ${iproute_line} | awk '{ for (k=1; k<=NF; ++k) { if ($k ~ "dev") print k } }'`	#get column number of "dev"
            if [[ ${dev_colno} -ne 0 ]]; then
                src_colno=`echo ${iproute_line} | awk '{ for (k=1; k<=NF; ++k) { if ($k ~ "src") print k } }'`	#get column number of "src"
                if [[ ${src_colno} -ne 0 ]]; then
                    dev_colno=$((dev_colno+1))	#get nic column number
                    src_colno=$((src_colno+1))	#get ip address column number
                    nic_name=`echo ${iproute_line} | awk -v c=${dev_colno} '{ print $c }'`	#get result on right-side of "dev"
                    ipv4addr=`echo ${iproute_line} | awk -v c=${src_colno} '{ print $c }'`	#get result on right-side of "src"
                    
                    #Check if 'nic_name' value is found in the 'docker network inspect bridge' result
                    nic_belongs_toDocker=$(sudo sh -c "docker network inspect bridge | grep '${nic_name}'") 
                    if [[ -z ${nic_belongs_toDocker} ]]; then   #'nic_name' does not belong to 'docker'
                        if [[ ${ipv4addr} =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then  #'ip4addr' is valid
                            
                            #Check if 'ipv4addr' is already added to 'docker_ipv4_addr_summarize_str'
                            ipv4addr_isPresent=$(echo ${docker_ipv4_addr_summarize_str} | grep ${ipv4addr})  
                            if [[ -z ${ipv4addr_isPresent} ]]; then #'ipv4addr' is unique
                                if [[ -z ${docker_ipv4_addr_summarize_str} ]]; then
                                    docker_ipv4_addr_summarize_str="${ipv4addr}"
                                else
                                    docker_ipv4_addr_summarize_str="${docker_ipv4_addr_summarize_str} ${ipv4addr}"
                                fi
                            fi
                        fi
                    fi		
                fi
            fi
        done

        eval "docker_ipv4_addr_summarize_arr=(${docker_ipv4_addr_summarize_str})"
    else
        echo -e "\r"
        echo -e "***ERROR: no ip-address found"    
        echo -e "\r"
        echo -e "\r"
    fi
}

#---Define colors
DOCKER_NOCOLOR='\033[0m'
DOCKER_ORANGE='\033[0;33m'
DOCKER_LIGHTRED='\033[1;31m'
DOCKER_LIGHTGREEN='\033[1;32m'
DOCKER_YELLOW='\033[1;33m'
DOCKER_LIGHTBLUE='\033[1;34m'
DOCKER_LIGHTCYAN='\033[1;36m'

#---Define constants
DOCKER_SSH_LOCALPORT=10022
DOCKER_SSH_PORT=22

#---Define and Initalize Variables
docker_ipv4_addr_summarize_str=""
docker_ipv4_addr_summarize_arr=()


#Select REPOSITORY
#1. Show docker image list
#2. Ask for the REPOSITORY to run
echo -e "\r"
echo -e "------------------------------------------------------------"
echo -e "\t${DOCKER_ORANGE}RUN${DOCKER_NOCOLOR} CONTAINER ${DOCKER_ORANGE}w${DOCKER_NOCOLOR}/ ${DOCKER_YELLOW}SSH${DOCKER_NOCOLOR} CAPABILITY"
echo -e "------------------------------------------------------------"
echo -e "\r"
    sudo sh -c "docker image ls"
echo -e "\r"

while true
do
    read -p "Run the following REPOSITORY (e.g. ubuntu_apps): " myrepository

    if [[ ! -z ${myrepository} ]]; then

        myrepository_isFound=`sudo docker image ls | grep ${myrepository}`
        if [[ ! -z ${myrepository_isFound} ]]; then
            container_name="containerOf__${myrepository}"
            sudo sh -c "docker run -d -p ${DOCKER_SSH_LOCALPORT}:${DOCKER_SSH_PORT} --name ${container_name} ${myrepository} " > /dev/null

            #Show DOCKER CONTAINERS
            echo -e "\r"
                sudo sh -c "docker container ls"
            echo -e "\r"
            echo -e "Summary:"
            echo -e "\tChosen REPOSITORY:\t\t\t${DOCKER_LIGHTRED}${myrepository}${DOCKER_NOCOLOR}"
            echo -e "\tCreated CONTAINER-ID:\t\t\t${DOCKER_ORANGE}${container_name}${DOCKER_NOCOLOR}"
            echo -e "\tTCP-port to-used-for SSH:\t\t${DOCKER_LIGHTBLUE}${DOCKER_SSH_LOCALPORT}${DOCKER_NOCOLOR}"
                get_assigned_ipv4_addresses__func
            echo -e "\tAvailable ip-address(es) for SSH:"
                for ipv4 in "${docker_ipv4_addr_summarize_arr[@]}"; do 
                    echo -e "\t\t\t\t\t\t${DOCKER_LIGHTCYAN}${ipv4}${DOCKER_NOCOLOR}"
                done
            echo -e "\r"


            #Show EXAMPLE OF HOW TO SSH FROM a REMOTE PC
                docker_ip4addr1=$(cut -d" " -f1 <<< ${docker_ipv4_addr_summarize_str})
            echo -e "\r"
            echo -e "How to SSH from a remote PC?"
            echo -e "\tDefault login/pass: ${DOCKER_LIGHTGREEN}root/root${DOCKER_NOCOLOR}"
            echo -e "\tExample:"
            echo -e "\t\tssh ${DOCKER_LIGHTGREEN}root${DOCKER_NOCOLOR}@${DOCKER_LIGHTCYAN}${docker_ip4addr1}${DOCKER_NOCOLOR} -p ${DOCKER_LIGHTBLUE}${DOCKER_SSH_LOCALPORT}${DOCKER_NOCOLOR}"
            echo -e "\r"

            exit
        else
            echo -e "\r"
            echo -e "Chosen REPOSITORY: ${DOCKER_LIGHTRED}${myrepository}${DOCKER_NOCOLOR} does NOT exist"

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