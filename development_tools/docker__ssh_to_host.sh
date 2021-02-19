#!/bin/bash
#---Define colors
DOCKER__NOCOLOR=$'\e[0m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__PORTS_FG_LIGHTBLUE=$'\e[1;34m'
DOCKER__IP_FG_LIGHTCYAN=$'\e[1;36m'

DOCKER__TITLE_BG_LIGHTBLUE=$'\e[30;48;5;45m'

#---Define constants
DOCKER__SSH_LOCALPORT=10022
DOCKER__SSH_PORT=22


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

docker__cmd_exec() {
    #Input args
    cmd=${1}

    #Define local variable
    currUser=$(whoami)

    #Exec command
    if [[ ${currUser} != "root" ]]; then
        sudo ${cmd}
    else
        ${cmd}
    fi
}

docker__environmental_variables__sub() {
    docker__current_dir=`dirname "$0"`
    if [[ ${docker__current_dir} == ${DOCKER__DOT} ]]; then
        docker__current_dir=$(pwd)
    fi

}

docker__load_header__sub() {
    echo -e "\r"
    echo -e "${DOCKER__TITLE_BG_LIGHTBLUE}                                DOCKER${DOCKER__TITLE_BG_LIGHTBLUE}                                ${DOCKER__NOCOLOR}"
}

docker__init_variables__sub() {
    docker__ipv4_addr_summarize_str=""
    docker__ipv4_addr_summarize_arr=()
    docker__ssh_localport=${DOCKER__SSH_LOCALPORT}
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
                    nic_belongs_toDocker=$(docker network inspect bridge | grep '${nic_name}') 
                    if [[ -z ${nic_belongs_toDocker} ]]; then   #'nic_name' does not belong to 'docker'
                        if [[ ${ipv4addr} =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then  #'ip4addr' is valid
                            
                            #Check if 'ipv4addr' is already added to 'docker__ipv4_addr_summarize_str'
                            ipv4addr_isPresent=$(echo ${docker__ipv4_addr_summarize_str} | grep ${ipv4addr})  
                            if [[ -z ${ipv4addr_isPresent} ]]; then #'ipv4addr' is unique
                                if [[ -z ${docker__ipv4_addr_summarize_str} ]]; then
                                    docker__ipv4_addr_summarize_str="${ipv4addr}"
                                else
                                    docker__ipv4_addr_summarize_str="${docker__ipv4_addr_summarize_str} ${ipv4addr}"
                                fi
                            fi
                        fi
                    fi		
                fi
            fi
        done

        eval "docker__ipv4_addr_summarize_arr=(${docker__ipv4_addr_summarize_str})"
    else
        echo -e "\r"
        echo -e "***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: no ip-address found"    
        echo -e "\r"
        echo -e "\r"
    fi
}

docker__ssh_handler__sub() {
    #AVAILABLE HOSTNAME/IP-ADDRESS
    get_assigned_ipv4_addresses__func

    echo -e "\r"
    echo -e "Available ip-address(es) for SSH:"
    for ipv4 in "${docker__ipv4_addr_summarize_arr[@]}"; do 
        echo -e "\t${DOCKER__IP_FG_LIGHTCYAN}${ipv4}${DOCKER__NOCOLOR}"
    done

    #INPUT
    echo -e "\r"

    while true
    do
        read -e -p "${DOCKER__IP_FG_LIGHTCYAN}Host/IP${DOCKER__NOCOLOR} (e.g. 172.31.1.51): " -i ${docker__ipv4_addr_summarize_arr[0]} myhost
        if [[ ! -z ${myhost} ]]; then    #input was NOT an EMPTY STRING
            break
        fi
    done

    #PORT
    echo -e "\r"
    while true
    do
        read -e -p "${DOCKER__PORTS_FG_LIGHTBLUE}Port${DOCKER__NOCOLOR} (e.g. 10022): " -i "${docker__ssh_localport}" myport
        if [[ ! -z ${myport} ]]; then    #input was NOT an EMPTY STRING
            break
        fi
    done

    #EXECUTE
    ssh root@${myhost} -p ${myport}
}

main_sub() {
    docker__load_header__sub

    docker__init_variables__sub

    docker__ssh_handler__sub
}

#Execute main subroutine
main_sub
