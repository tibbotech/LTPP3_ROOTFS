#!/bin/bash
#---COLOR CONSTANTS
DOCKER__NOCOLOR=$'\e[0m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__SUCCESS_FG_LIGHTGREEN=$'\e[1;32m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__PORTS_FG_LIGHTBLUE=$'\e[1;34m'
DOCKER__REPOSITORY_FG_PURPLE=$'\e[30;38;5;93m'
DOCKER__CONTAINER_FG_BRIGHTPRUPLE=$'\e[30;38;5;141m'
DOCKER__IP_FG_LIGHTCYAN=$'\e[1;36m'
DOCKER__FILES_FG_ORANGE=$'\e[30;38;5;215m'
DOCKER__TAG_FG_LIGHTPINK=$'\e[30;38;5;218m'

DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'
DOCKER__TITLE_BG_LIGHTBLUE=$'\e[30;48;5;45m'

#---CONSTANTS
DOCKER__TITLE="TIBBO"

DOCKER__SSH_LOCALPORT=10022
DOCKER__SSH_PORT=22

#---CHARACTER CHONSTANTS
DOCKER__DASH="-"
DOCKER__EMPTYSTRING=""


#---NUMERIC CONSTANTS
DOCKER__TABLEWIDTH=70

DOCKER__NUMOFLINES_1=1
DOCKER__NUMOFLINES_2=2
DOCKER__NUMOFLINES_3=3
DOCKER__NUMOFLINES_4=4
DOCKER__NUMOFLINES_5=5
DOCKER__NUMOFLINES_6=6



#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C_func INT



#---FUNCTIONS
function CTRL_C_func() {
    echo -e "\r"
    echo -e "\r"
    # echo -e "Exiting now..."
    # echo -e "\r"
    # echo -e "\r"
    
    exit
}

function press_any_key__func() {
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



#---FUNCTIONS
function cmd_was_executed_successfully__func() {
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
        echo failed
    fi
}

function get_available_localport__func() {
    local ssh_localport=${DOCKER__SSH_LOCALPORT}    #initial value
    local pattern=${DOCKER__EMPTYSTRING}
    local localport_isUnique=${DOCKER__EMPTYSTRING}

    while true
    do
        #Define search pattern (e.g. 10022->22)
        search_pattern="${ssh_localport}->22"
        
        #Check if 'search_pattern' can be found in 'docker image ls'
        localport_isUnique=`docker container ls | grep ${search_pattern}`
        if [[ -z ${localport_isUnique} ]]; then #match was NOT found
            docker__ssh_localport=${ssh_localport}   #set value for 'docker__ssh_localport'

            break   #exit loop
        else    #match was found
            ssh_localport=$((ssh_localport+1))  #define a new value for 'ssh_localport'
        fi
    done
}

function get_assigned_ipv4_addresses__func() {
    #Define local constants
    local ERRMSG_NO_IP_ADDRESS_FOUND="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: no ip-address found"

    #Define local variabes
    local iproute_line=${DOCKER__EMPTYSTRING}
    local dev_colno=0
    local src_colno=0
    local nic_name=${DOCKER__EMPTYSTRING}
    local ipv4addr=${DOCKER__EMPTYSTRING}
    local ipv4addr_isPresent=${DOCKER__EMPTYSTRING}
    local nic_belongs_toDocker=${DOCKER__EMPTYSTRING}
    local numOf_iproute_results=0
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
        echo -e "${ERRMSG_NO_IP_ADDRESS_FOUND}"    
        echo -e "\r"
        echo -e "\r"
    fi
}

function show_centered_string__func()
{
    #Input args
    local str_input=${1}
    local maxStrLen_input=${2}

    #Define one-space constant
    local ONESPACE=" "

    #Get string 'without visiable' color characters
    local strInput_wo_colorChars=`echo "${str_input}" | sed "s,\x1B\[[0-9;]*m,,g"`

    #Get string length
    local strInput_wo_colorChars_len=${#strInput_wo_colorChars}

    #Calculated the number of spaces to-be-added
    local numOf_spaces=$(( (maxStrLen_input-strInput_wo_colorChars_len)/2 ))

    #Create a string containing only EMPTY SPACES
    local emptySpaces_string=`duplicate_char__func "${ONESPACE}" "${numOf_spaces}" `

    #Print text including Leading Empty Spaces
    echo -e "${emptySpaces_string}${str_input}"
}

function duplicate_char__func()
{
    #Input args
    local char_input=${1}
    local numOf_times=${2}

    #Duplicate 'char_input'
    local char_duplicated=`printf '%*s' "${numOf_times}" | tr ' ' "${char_input}"`

    #Print text including Leading Empty Spaces
    echo -e "${char_duplicated}"
}

function moveUp_and_cleanLines__func() {
    #Input args
    local numOf_lines_toBeCleared=${1}

    #Clear lines
    local numOf_lines_cleared=1
    while [[ ${numOf_lines_cleared} -le ${numOf_lines_toBeCleared} ]]
    do
        tput cuu1	#move UP with 1 line
        tput el		#clear until the END of line

        numOf_lines_cleared=$((numOf_lines_cleared+1))  #increment by 1
    done
}



#---SUBROUTINES
docker__load_header__sub() {
    echo -e "\r"
    echo -e "${DOCKER__TITLE_BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__TITLE_BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__init_variables__sub() {
    docker__ipv4addr1=${DOCKER__EMPTYSTRING}
    docker__ipv4_addr_summarize_str=${DOCKER__EMPTYSTRING}
    docker__ipv4_addr_summarize_arr=()
    docker__ssh_localport=${DOCKER__SSH_LOCALPORT}
}

docker__run_specified_repository_as_container__sub() {
    #Define local constants
    local MENUTITLE="Run ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER${DOCKER__NOCOLOR} from specfied ${DOCKER__REPOSITORY_FG_PURPLE}REPOSITORY${DOCKER__NOCOLOR}"
    local SUBMENUTITLE="Updated ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER${DOCKER__NOCOLOR}-list"

    #Define local variables
    local exitCode=0
    local containerName=${DOCKER__EMPTYSTRING}
    local myRepository=${DOCKER__EMPTYSTRING}
    local myRepository_isFound=${DOCKER__EMPTYSTRING}
    local myTags_detected=${DOCKER__EMPTYSTRING}
    local myTags_firstTag_detected
    local myTag=${DOCKER__EMPTYSTRING}
    local myTag_isFound=${DOCKER__EMPTYSTRING}
    local myRespository_colon_tag=${DOCKER__EMPTYSTRING}
    local myRespository_colon_tag_isFound=${DOCKER__EMPTYSTRING}

    local errMsg=${DOCKER__EMPTYSTRING}

    #Show menu-title
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    show_centered_string__func "${MENUTITLE}" "${DOCKER__TABLEWIDTH}"
    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

    #Get number of images
    local numof_images=`docker image ls | head -n -1 | wc -l`
    if [[ ${numof_images} -eq 0 ]]; then
        #Update error-message
        errMsg="=:${DOCKER__ERROR_FG_LIGHTRED}NO IMAGES FOUND${DOCKER__NOCOLOR}:="

        echo -e "\r"
        show_centered_string__func "${errMsg}" "${DOCKER__TABLEWIDTH}"
        echo -e "\r"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

        press_any_key__func

        exit
    else
        docker image ls
        echo -e "\r"
        duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
    fi    

    while true
    do
        #Request for REPOSITORY input
        read -p "Provide ${DOCKER__REPOSITORY_FG_PURPLE}REPOSITORY${DOCKER__NOCOLOR} (e.g. ubuntu_sunplus): " myRepository
        if [[ ! -z ${myRepository} ]]; then #input was NOT an EMPTY STRING

            myRepository_isFound=`docker image ls | awk '{print $1}' | grep -w "${myRepository}"` #check if 'myRepository' is found in 'docker image ls'
            if [[ ! -z ${myRepository_isFound} ]]; then #match was found
                while true
                do
                    #Find tag belonging to 'myRepository' (Exact Match)
                    myTags_detected=$(docker image ls | grep -w "${myRepository}" | awk '{print $2}')
                    myTags_firstTag_detected=`echo -e ${myTags_detected} | cut -d" " -f1`

                    #Request for TAG input
                    read -e -p "Provide ${DOCKER__TAG_FG_LIGHTPINK}TAG${DOCKER__NOCOLOR} (e.g. latest): " -i ${myTags_firstTag_detected} myTag
                    if [[ ! -z ${myTag} ]]; then    #input was NOT an EMPTY STRING

                        myTag_isFound=`docker image ls | grep -w "${myRepository}" | grep -w "${myTag}"`    #check if 'myRepository' AND 'myTag' is found in 'docker image ls'
                        if [[ ! -z ${myTag_isFound} ]]; then    #match was found
                            
                            #Combine 'myRepository' and 'myTag', but separated by a colon ':'
                            myRespository_colon_tag="${myRepository}:${myTag}"

                            myRespository_colon_tag_isFound=`docker container ls | grep -w "${myRespository_colon_tag}"`    #check if 'myRespository_colon_tag' is found in 'docker container ls'
                            if [[ -z ${myRespository_colon_tag_isFound} ]]; then    #match was NOT found, thus 'myTag_isFound' is an EMPTY STRING
                                #Define Container Name
                                containerName="containerOf__${myRepository}_${myTag}"
                                
                                #Get an unused value for the 'docker__ssh_localport'
                                #Note: 
                                #   function 'get_available_localport__func' does NOT have an output, instead...
                                #   ....'docker__ssh_localport' is set in this function
                                get_available_localport__func

                                #Run Docker Container
                                echo -e "\r"
                                docker run -d -p ${docker__ssh_localport}:${DOCKER__SSH_PORT} --name ${containerName} ${myRespository_colon_tag} > /dev/null

                                #Check if exitCode=0
                                exitCode=$? #get exitCode
                                if [[ ${exitCode} -eq 0 ]]; then    #exitCode=0, which means that command was executed successfully
                                    #Show DOCKER CONTAINERS
                                    #Show Container's list
                                    echo -e "\r"

                                    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"
                                    show_centered_string__func "${SUBMENUTITLE}" "${DOCKER__TABLEWIDTH}"
                                    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}" 
                                    
                                    docker ps -a

                                    echo -e "\r"
                                    duplicate_char__func "${DOCKER__DASH}" "${DOCKER__TABLEWIDTH}"

                                    echo -e "\r"
                                    echo -e "Summary:"
                                    echo -e "\tChosen REPOSITORY:\t\t\t${DOCKER__REPOSITORY_FG_PURPLE}${myRepository}${DOCKER__NOCOLOR}"
                                    echo -e "\tCreated CONTAINER-ID:\t\t\t${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}${containerName}${DOCKER__NOCOLOR}"
                                    echo -e "\tTCP-port to-used-for SSH:\t\t${DOCKER__PORTS_FG_LIGHTBLUE}${docker__ssh_localport}${DOCKER__NOCOLOR}"
                                   
                                    get_assigned_ipv4_addresses__func
                                   
                                    echo -e "\tAvailable ip-address(es) for SSH:"
                                   
                                    for ipv4 in "${docker__ipv4_addr_summarize_arr[@]}"; do 
                                        echo -e "\t\t\t\t\t\t${DOCKER__IP_FG_LIGHTCYAN}${ipv4}${DOCKER__NOCOLOR}"
                                    done
                                   
                                    echo -e "\r"


                                    #Show EXAMPLE OF HOW TO SSH FROM a REMOTE PC
                                    docker__ipv4addr1=$(cut -d" " -f1 <<< ${docker__ipv4_addr_summarize_str})
                                    echo -e "\r"
                                    echo -e "How to SSH from a remote PC?"
                                    echo -e "\tDefault login/pass: ${DOCKER__GENERAL_FG_YELLOW}root/root${DOCKER__NOCOLOR}"
                                    echo -e "\tSample:"
                                    echo -e "\t\tssh ${DOCKER__GENERAL_FG_YELLOW}root${DOCKER__NOCOLOR}@${DOCKER__IP_FG_LIGHTCYAN}${docker__ipv4addr1}${DOCKER__NOCOLOR} -p ${DOCKER__PORTS_FG_LIGHTBLUE}${docker__ssh_localport}${DOCKER__NOCOLOR}"
                                    echo -e "\r"
                                    echo -e "\r"
                                    
                                    exit
                                else
                                    break
                                fi
                            else
                                #Get running Container-ID
                                containerid=`docker container ls | grep -w "${myRepository}:${myTag}" | awk '{print $1}'`

                                #Update error-message
                                errMsg="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Chosen ${DOCKER__REPOSITORY_FG_PURPLE}REPOSITORY${DOCKER__NOCOLOR}:${DOCKER__TAG_FG_LIGHTPINK}TAG${DOCKER__NOCOLOR} already running as CONTAINER-ID: ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}${containerid}${DOCKER__NOCOLOR}"

                                #Show error-message
                                echo -e "\r"
                                echo -e "${errMsg}"

                                press_any_key__func

                                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_6}"

                                break
                            fi
                        else
                            #Update error-message
                            errMsg="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Un-matched pair ${DOCKER__REPOSITORY_FG_PURPLE}REPOSITORY${DOCKER__NOCOLOR} <-> ${DOCKER__TAG_FG_LIGHTPINK}TAG${DOCKER__NOCOLOR}"

                            #Show error-message
                            echo -e "\r"
                            echo -e "${errMsg}"

                            press_any_key__func

                            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_5}"              
                        fi
                    else
                        moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"   
                    fi
                done
            else
                #Update error-message
                errMsg="***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: non-existing repository ${DOCKER__REPOSITORY_FG_PURPLE}${myRepository}${DOCKER__NOCOLOR}"

                #Show error-message
                echo -e "\r"
                echo -e "${errMsg}"

                press_any_key__func

                moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_5}"
            fi 
        else
            moveUp_and_cleanLines__func "${DOCKER__NUMOFLINES_1}"
        fi
    done
}

main_sub() {
    docker__load_header__sub

    docker__init_variables__sub

    docker__run_specified_repository_as_container__sub
}


#Execute main subroutine
main_sub
