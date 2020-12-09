#!/bin/bash
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


#---Define constants
DOCKER__SPACE=" "


#---Define colors
DOCKER__NOCOLOR='\033[0;0m'
DOCKER__YELLOW='\033[1;33m'
DOCKER__ORANGE='\033[0;33m'
DOCKER__LIGHTRED='\033[1;31m'

DOCKER__BG_WHITE='\e[30;48;5;15m'
DOCKER__BG_LIGHTBLUE='\e[30;48;5;45m'

DOCKER__READ_LIGHTRED=$'\e[1;31m'
DOCKER__READ_NOCOLOR=$'\e[0;0m'
DOCKER__READ_LIGHTCYAN=$'\e[1;36m'
DOCKER__READ_ORANGE=$'\e[0;33m'


#---Define PATHS
DOCKER__ISPBOOOT_BIN_FILENAME="ISPBOOOT.BIN"

docker__current_dir=`pwd`
DOCKER__ROOT_SP7XXX_OUT_DIR=/root/SP7021/out


#Show DOCKER
echo -e "\r"
echo -e "${DOCKER__BG_LIGHTBLUE}                               DOCKER${DOCKER__BG_LIGHTBLUE}                               ${DOCKER__NOCOLOR}"


#---Show Docker Containers' List
echo -e "\r"
echo -e "--------------------------------------------------------------------"
echo -e "\tDocker ${DOCKER__YELLOW}Containers${DOCKER__NOCOLOR}' List"
echo -e "--------------------------------------------------------------------"
sudo sh -c "docker container ls"

#---Choose to Copy from Inside to Outside or Vice versa
echo -e "\r"
echo -e "Do you wish to Copy from:"
echo -e "${DOCKER__SPACE}1. ${DOCKER__BG_WHITE}INSIDE${DOCKER__NOCOLOR} > OUTSIDE container"
echo -e "${DOCKER__SPACE}2. OUTSIDE > ${DOCKER__BG_WHITE}INSIDE${DOCKER__NOCOLOR} container"
echo -e "\r"

while true
do
	read -N1 -p "Choose an option: " mycopychoice
	
	if [[ ${mycopychoice} =~ [1,2] ]]; then
		break      
	else
		echo -e "\r"
		echo -e "***ERROR: Invalid option '${mycopychoice}'"

		sleep 1

		tput cuu1
		tput el
		tput cuu1
		tput el
	fi
done


#---Choose a docker container id
echo -e "\r"
echo -e "\r"

while true
do
	read -p "Provide the ${DOCKER__READ_LIGHTRED}CONTAINER-ID${DOCKER__READ_NOCOLOR}: " mycontainerid
	
	mycontainerid_isFound=`sudo docker container ls | awk '{print $1}' | grep -w ${mycontainerid}`
	if [[ ! -z ${mycontainerid_isFound} ]]; then
		break         
	else
		echo -e "\r"
		echo -e "***ERROR: Invalid CONTAINER-ID: ${DOCKER__LIGHTRED}${mycontainerid}${DOCKER__NOCOLOR}"

		sleep 3

		tput cuu1
		tput el
		tput cuu1
		tput el
		tput cuu1
		tput el
	fi
done

if [[ ${mycopychoice} -eq 1 ]]; then
	#---SOURCE: Provide the Location of the file which you want to copy (located INSIDE the container!)
	echo -e "\r"
	while true
	do
		read -e -p "Provide ${DOCKER__READ_LIGHTCYAN}Source-Location${DOCKER__READ_NOCOLOR} (inside Container): " -i "${DOCKER__ROOT_SP7XXX_OUT_DIR}" mysource_dir

		if [[ ! -z ${mysource_dir} ]]; then
			break
		fi
	done

	#---SOURCE: Provide the file which you want to copy (located INSIDE the container!)
	echo -e "\r"
	while true
	do
		read -e -p "Provide ${DOCKER__READ_LIGHTCYAN}Source-Filename${DOCKER__READ_NOCOLOR} (inside Container): " -i "${DOCKER__ISPBOOOT_BIN_FILENAME}" mysource_filename

		if [[ ! -z ${mysource_filename} ]]; then
			break
		fi
	done

	#---DESTINATION: Provide the location where you want to copy to (located OUTSIDE the container!)
	echo -e "\r"
	while true
	do
		read -e -p "Provide ${DOCKER__READ_ORANGE}Destination-Location${DOCKER__READ_NOCOLOR} (outside Container): " -i "${docker__current_dir}" mydest_dir

		if [[ ! -z ${mydest_dir} ]]; then
			break
		fi
	done
else
	#---SOURCE: Provide the location where you want to copy to (located OUTSIDE the container!)
	echo -e "\r"
	while true
	do
		read -e -p "Provide ${DOCKER__READ_LIGHTCYAN}Source-Location${DOCKER__READ_NOCOLOR} (outside Container): " -i "${docker__current_dir}" mysource_dir 

		if [[ ! -z ${mysource_dir} ]]; then
			break
		fi
	done	

	#---SOURCE: Provide the file which you want to copy (located INSIDE the container!)
	echo -e "\r"
	while true
	do
		read -e -p "Provide ${DOCKER__READ_LIGHTCYAN}Source-Filename${DOCKER__READ_NOCOLOR} (inside Container): " -i "${DOCKER__ISPBOOOT_BIN_FILENAME}" mysource_filename

		if [[ ! -z ${mysource_filename} ]]; then
			break
		fi
	done

	#---DESTINATION: Provide the Location of the file which you want to copy (located INSIDE the container!)
	echo -e "\r"
	while true
	do
		read -e -p "Provide ${DOCKER__READ_ORANGE}Destination-Location${DOCKER__READ_NOCOLOR} (inside Container): " -i "${DOCKER__ROOT_SP7XXX_OUT_DIR}" mydest_dir

		if [[ ! -z ${mydest_dir} ]]; then
			break
		fi
	done
fi

#---Summary
echo -e "\r"
echo -e "--------------------------------------------------------------------"
echo "Overview:"
echo -e "--------------------------------------------------------------------"
echo "${DOCKER__READ_LIGHTCYAN}Source${DOCKER__READ_NOCOLOR} Full-path: ${DOCKER__READ_LIGHTCYAN}${mysource_dir}/${mysource_filename}${DOCKER__READ_NOCOLOR}"
echo "${DOCKER__READ_ORANGE}Destination${DOCKER__READ_NOCOLOR} Full-path: ${DOCKER__READ_ORANGE}${mydest_dir}/${mysource_filename}${DOCKER__READ_NOCOLOR}"
echo -e "--------------------------------------------------------------------"

#---COPY: ~/SP7021/out/ISPBOOOT.BIN (within a container) to /mnt/<networkdrive>
echo -e "\r"
while true
do
	read -N1 -p "Do you wish to continue (y/n)?" myanswer

	if [[ ! -z ${myanswer} ]]; then
		if [[ ${myanswer} =~ [y,n] ]]; then
			break
		fi
	fi
done
echo -e "\r"

if [[ ${myanswer} == "y" ]]; then
	echo -e "\r"
	echo -e "Copy in Progress... Please wait..."

	if [[ ${mycopychoice} -eq 1 ]]; then
		sudo sh -c "docker cp ${mycontainerid}:${mysource_dir}/${mysource_filename} ${mydest_dir}/${mysource_filename}"
	else
		sudo sh -c "docker cp ${mysource_dir}/${mysource_filename} ${mycontainerid}:${mydest_dir}/${mysource_filename}"
	fi
	echo -e "Copy completed...Exiting now..."
	echo -e "\r"
	echo -e "\r"
fi

