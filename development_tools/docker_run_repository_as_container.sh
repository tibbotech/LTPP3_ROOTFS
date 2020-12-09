#!/bin/bash
#---Define colors
DOCKER__READ_FG_LIGHTRED=$'\e[1;31m'
DOCKER__READ_FG_LIGHTGREEN=$'\e[1;32m'
DOCKER__READ_FG_YELLOW=$'\e[1;33m'
DOCKER__READ_FG_ORANGE=$'\e[0;33m'
DOCKER__READ_FG_LIGHTBLUE=$'\e[1;34m'
DOCKER__READ_FG_PURPLE=$'\e[0;35m'
DOCKER__READ_FG_LIGHTCYAN=$'\e[1;36m'
DOCKER__READ_FG_RGB_GREENBLUE=$'\e[38;5;79m'
DOCKER__READ_FG_NOCOLOR=$'\e[0;0m'

DOCKER__READ_BG_LIGHTBLUE='\e[30;48;5;45m'

#---Define constants
DOCKER__SSH_LOCALPORT=10022
DOCKER__SSH_PORT=22


#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C__sub INT

function CTRL_C__sub() {
    echo -e "\r"
    echo -e "\r"
    echo -e "${DOCKER__EXITING_NOW}"
    echo -e "\r"
    echo -e "\r"
    echo -e "\r"
    
    exit
}

#---Local functions & subroutines
cmd_was_executed_successfully__func() {
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
        echo failed
    fi
}

get_available_localport__func() {
    local ssh_localport=${DOCKER__SSH_LOCALPORT}    #initial value
    local pattern=""

    while true
    do
        #Define search pattern (e.g. 10022->22)
        search_pattern="${ssh_localport}->22"
        
        #Check if 'search_pattern' can be found in 'docker image ls'
        localport_isUnique=`sudo docker container ls | grep ${search_pattern}`
        if [[ -z ${localport_isUnique} ]]; then #match was NOT found
            docker_ssh_localport=${ssh_localport}   #set value for 'docker_ssh_localport'

            break   #exit loop
        else    #match was found
            ssh_localport=$((ssh_localport+1))  #define a new value for 'ssh_localport'
        fi
    done
}

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
        echo -e "***${DOCKER__READ_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: no ip-address found"    
        echo -e "\r"
        echo -e "\r"
    fi
}

#---Show Main Banner
echo -e "\r"
echo -e "${DOCKER__READ_BG_LIGHTBLUE}                               DOCKER${DOCKER__READ_BG_LIGHTBLUE}                               ${DOCKER__READ_FG_NOCOLOR}"


#---Define and Initalize Variables
docker_ipv4_addr_summarize_str=""
docker_ipv4_addr_summarize_arr=()
docker_ssh_localport=${DOCKER__SSH_LOCALPORT}


#Select REPOSITORY
#1. Show docker image list
#2. Ask for the REPOSITORY to run
echo -e "\r"
echo -e "--------------------------------------------------------------------"
echo -e "\t${DOCKER__READ_FG_ORANGE}RUN${DOCKER__READ_FG_NOCOLOR} CONTAINER ${DOCKER__READ_FG_ORANGE}w${DOCKER__READ_FG_NOCOLOR}/ ${DOCKER__READ_FG_YELLOW}SSH${DOCKER__READ_FG_NOCOLOR} CAPABILITY"
echo -e "--------------------------------------------------------------------"
echo -e "\r"
    sudo sh -c "docker image ls"
echo -e "\r"

while true
do
    #Request for REPOSITORY input
    read -p "Provide ${DOCKER__READ_FG_PURPLE}REPOSITORY${DOCKER__READ_FG_NOCOLOR} (e.g. ubuntu_sunplus): " myrepository
    if [[ ! -z ${myrepository} ]]; then #input was NOT an EMPTY STRING

        myrepository_isFound=`sudo docker image ls | awk '{print $1}' | grep -w "${myrepository}"` #check if 'myrepository' is found in 'docker image ls'
        if [[ ! -z ${myrepository_isFound} ]]; then #match was found
            while true
            do

                #Find tag belonging to 'myrepository' (Exact Match)
                myrepository_tag=$(sudo docker image ls | grep -w "${myrepository}" | awk '{print $2}')

                #Request for TAG input
                read -e -p "Provide ${DOCKER__READ_FG_ORANGE}TAG${DOCKER__READ_FG_NOCOLOR} (e.g. latest): " -i ${myrepository_tag} mytag
                if [[ ! -z ${mytag} ]]; then    #input was NOT an EMPTY STRING

                    mytag_isFound=`sudo docker image ls | grep -w "${myrepository}" | grep -w "${mytag}"`    #check if 'myrepository' AND 'mytag' is found in 'docker image ls'
                    if [[ ! -z ${mytag_isFound} ]]; then    #match was found
                        
                        #Combine 'myrepository' and 'mytag', but separated by a colon ':'
                        myrespository_colon_tag="${myrepository}:${mytag}"

                        myrespository_colon_tag_isFound=`sudo docker container ls | grep -w "${myrespository_colon_tag}"`    #check if 'myrespository_colon_tag' is found in 'docker container ls'
                        if [[ -z ${myrespository_colon_tag_isFound} ]]; then    #match was NOT found, thus 'mytag_isFound' is an EMPTY STRING
                            #Define Container Name
                            container_name="containerOf__${myrepository}_${mytag}"
                            
                            #Get an unused value for the 'docker_ssh_localport'
                            #Note: 
                            #   function 'get_available_localport__func' does NOT have an output, instead...
                            #   ....'docker_ssh_localport' is set in this function
                            get_available_localport__func

                            #Run Docker Container
                            echo -e "\r"
                            sudo sh -c "docker run -d -p ${docker_ssh_localport}:${DOCKER__SSH_PORT} --name ${container_name} ${myrespository_colon_tag} " > /dev/null

                            #Check if exitcode=0
                            exitcode=$? #get exitcode
                            if [[ ${exitcode} -eq 0 ]]; then    #exitcode=0, which means that command was executed successfully
                                #Show DOCKER CONTAINERS
                                echo -e "\r"
                                    sudo sh -c "docker container ls"
                                echo -e "\r"
                                echo -e "Summary:"
                                echo -e "\tChosen REPOSITORY:\t\t\t${DOCKER__READ_FG_PURPLE}${myrepository}${DOCKER__READ_FG_NOCOLOR}"
                                echo -e "\tCreated CONTAINER-ID:\t\t\t${DOCKER__READ_FG_ORANGE}${container_name}${DOCKER__READ_FG_NOCOLOR}"
                                echo -e "\tTCP-port to-used-for SSH:\t\t${DOCKER__READ_FG_LIGHTBLUE}${docker_ssh_localport}${DOCKER__READ_FG_NOCOLOR}"
                                    get_assigned_ipv4_addresses__func
                                echo -e "\tAvailable ip-address(es) for SSH:"
                                    for ipv4 in "${docker_ipv4_addr_summarize_arr[@]}"; do 
                                        echo -e "\t\t\t\t\t\t${DOCKER__READ_FG_LIGHTCYAN}${ipv4}${DOCKER__READ_FG_NOCOLOR}"
                                    done
                                echo -e "\r"


                                #Show EXAMPLE OF HOW TO SSH FROM a REMOTE PC
                                    docker_ip4addr1=$(cut -d" " -f1 <<< ${docker_ipv4_addr_summarize_str})
                                echo -e "\r"
                                echo -e "How to SSH from a remote PC?"
                                echo -e "\tDefault login/pass: ${DOCKER__READ_FG_LIGHTGREEN}root/root${DOCKER__READ_FG_NOCOLOR}"
                                echo -e "\tSample:"
                                echo -e "\t\tssh ${DOCKER__READ_FG_LIGHTGREEN}root${DOCKER__READ_FG_NOCOLOR}@${DOCKER__READ_FG_LIGHTCYAN}${docker_ip4addr1}${DOCKER__READ_FG_NOCOLOR} -p ${DOCKER__READ_FG_LIGHTBLUE}${docker_ssh_localport}${DOCKER__READ_FG_NOCOLOR}"
                                echo -e "\r"
                                echo -e "\r"
                                
                                exit
                            else
                                break
                            fi
                        else
                            echo -e "\r"
                            echo -e "A Container of selected Image '${DOCKER__READ_FG_LIGHTRED}${myrepository}${DOCKER__READ_FG_NOCOLOR}:${DOCKER__READ_FG_LIGHTRED}${mytag}${DOCKER__READ_FG_NOCOLOR}' already running..."

                            sleep 3

                            tput cuu1	#move UP with 1 line
                            tput el		#clear until the END of line
                            tput cuu1	#move UP with 1 line
                            tput el		#clear until the END of line
                            tput cuu1	#move UP with 1 line
                            tput el		#clear until the END of line
                            tput cuu1	#move UP with 1 line
                            tput el		#clear until the END of line        

                            break
                        fi
                    else
                        echo -e "\r"
                        echo -e "Provided TAG: ${DOCKER__READ_FG_LIGHTRED}${mytag}${DOCKER__READ_FG_NOCOLOR} does NOT belong to REPOSITORY: ${DOCKER__READ_FG_LIGHTRED}${myrepository}${DOCKER__READ_FG_NOCOLOR}"

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
        else
            echo -e "\r"
            echo -e "***${DOCKER__READ_FG_LIGHTRED}ERROR${DOCKER__READ_FG_NOCOLOR}: non-existing repository '${myrepository}'"

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
