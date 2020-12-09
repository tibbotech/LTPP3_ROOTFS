#!/bin/bash
#---Define constants
DOCKER__SPACE=" "


#---Define colors
DOCKER__READ_NOCOLOR=$'\e[0;0m'
DOCKER__READ_FG_LIGHTRED=$'\e[1;31m'
DOCKER__READ_FG_PURPLE=$'\e[0;35m'
DOCKER__READ_FG_YELLOW=$'\e[1;33m'
DOCKER__READ_FG_ORANGE=$'\e[30;38;5;208m'
DOCKER__READ_FG_PURPLE=$'\e[0;35m'

DOCKER__READ_BG_WHITE=$'\e[30;48;5;15m'
DOCKER__READ_BG_LIGHTBLUE=$'\e[30;48;5;45m'
DOCKER__READ_BG_LIGHTPINK=$'\e[30;48;5;218m'


#---Define PATHS
DOCKER__ISPBOOOT_BIN_FILENAME="ISPBOOOT.BIN"

docker__current_dir=`pwd`
DOCKER__ROOT_SP7XXX_OUT_DIR=/root/SP7021/out


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

#---Local Functions
function cell__remove_whitespaces__func() {
    #Input args
    local orgstring=${1}
    
    #Remove white spaces
    local outputstring=`echo -e "${orgstring}" | tr -d "[:blank:]"`

    #OUTPUT
    echo ${outputstring}
}


#---Show Main Banner
echo -e "\r"
echo -e "${DOCKER__READ_BG_LIGHTBLUE}                                DOCKER${DOCKER__READ_BG_LIGHTBLUE}                                ${DOCKER__READ_NOCOLOR}"


#---Choose to Copy from Inside to Outside or Vice versa
echo -e "\r"
echo -e "Do you wish to Copy from:"
echo -e "${DOCKER__SPACE}1. ${DOCKER__READ_BG_WHITE}INSIDE${DOCKER__READ_NOCOLOR} > ${DOCKER__READ_BG_LIGHTPINK}OUTSIDE${DOCKER__READ_NOCOLOR} container"
echo -e "${DOCKER__SPACE}2. ${DOCKER__READ_BG_LIGHTPINK}OUTSIDE${DOCKER__READ_NOCOLOR} > ${DOCKER__READ_BG_WHITE}INSIDE${DOCKER__READ_NOCOLOR} container"
echo -e "\r"

while true
do
	read -N1 -p "Choose an option: " mycopychoice

	mycopychoice=`cell__remove_whitespaces__func "${mycopychoice}"`

	if [[ ! -z ${mycopychoice} ]]; then
		if [[ ${mycopychoice} =~ [1,2] ]]; then
			break      
		else
			echo -e "\r"
			echo -e "***${DOCKER__READ_FG_LIGHTRED}ERROR${DOCKER__READ_NOCOLOR}: Invalid option '${mycopychoice}'"

			sleep 1

			tput cuu1
			tput el
			tput cuu1
			tput el
		fi
	else
		tput cuu1
		tput el
	fi
done

#---Show Docker Containers' List
echo -e "\r"
echo -e "----------------------------------------------------------------------"
echo -e "\tDocker '${DOCKER__READ_FG_YELLOW}Containers${DOCKER__READ_NOCOLOR}' List"
echo -e "----------------------------------------------------------------------"
sudo sh -c "docker container ls"

#Choose a docker container id
echo -e "\r"

while true
do
	read -p "Provide the ${DOCKER__READ_FG_PURPLE}CONTAINER-ID${DOCKER__READ_NOCOLOR}: " mycontainerid
	
	mycontainerid=`cell__remove_whitespaces__func "${mycontainerid}"`

	if [[ ! -z ${mycontainerid} ]]; then
		mycontainerid_isFound=`sudo docker container ls | awk '{print $1}' | grep -w ${mycontainerid}`
		
		if [[ ! -z ${mycontainerid_isFound} ]]; then
			break         
		else
			echo -e "\r"
			echo -e "***${DOCKER__READ_FG_LIGHTRED}ERROR${DOCKER__READ_NOCOLOR}: Invalid CONTAINER-ID: '${DOCKER__LIGHTRED}${mycontainerid}${DOCKER__READ_NOCOLOR}'"

			sleep 2

			tput cuu1
			tput el
			tput cuu1
			tput el
			tput cuu1
			tput el
		fi
	else
		tput cuu1
		tput el
	fi
done


if [[ ${mycopychoice} -eq 1 ]]; then
	#---SOURCE: Provide the Location of the file which you want to copy (located INSIDE the container!)
	echo -e "\r"
	while true
	do
		read -e -p "Provide ${DOCKER__READ_BG_WHITE}Source-Location${DOCKER__READ_NOCOLOR} (inside Container): " -i "${DOCKER__ROOT_SP7XXX_OUT_DIR}" mysource_dir

		if [[ ! -z ${mysource_dir} ]]; then
			break
		else
			tput cuu1
		fi
	done

	#---SOURCE: Provide the file which you want to copy (located INSIDE the container!)
	echo -e "\r"
	while true
	do
		read -e -p "Provide ${DOCKER__READ_BG_WHITE}Source-Filename${DOCKER__READ_NOCOLOR} (inside Container): " -i "${DOCKER__ISPBOOOT_BIN_FILENAME}" mysource_filename

		if [[ ! -z ${mysource_filename} ]]; then
			break
		fi
	done

	#---DESTINATION: Provide the location where you want to copy to (located OUTSIDE the container!)
	echo -e "\r"
	while true
	do
		read -e -p "Provide ${DOCKER__READ_BG_LIGHTPINK}Destination-Location${DOCKER__READ_NOCOLOR} (outside Container): " -i "${docker__current_dir}" mydest_dir

		if [[ ! -z ${mydest_dir} ]]; then
			break
		fi
	done


	#---Summary
	echo -e "\r"
	echo -e "--------------------------------------------------------------------"
	echo "Overview:"
	echo -e "--------------------------------------------------------------------"
	echo "${DOCKER__READ_BG_WHITE}Source Full-path${DOCKER__READ_NOCOLOR}: ${mysource_dir}/${mysource_filename}"
	echo "${DOCKER__READ_BG_LIGHTPINK}Destination Full-path${DOCKER__READ_NOCOLOR}: ${mydest_dir}/${mysource_filename}"
	echo -e "--------------------------------------------------------------------"

else
	#---SOURCE: Provide the location where you want to copy to (located OUTSIDE the container!)
	echo -e "\r"
	while true
	do
		read -e -p "Provide ${DOCKER__READ_BG_LIGHTPINK}Source-Location${DOCKER__READ_NOCOLOR} (outside Container): " -i "${docker__current_dir}" mysource_dir 

		if [[ ! -z ${mysource_dir} ]]; then
			break
		fi
	done	

	#---SOURCE: Provide the file which you want to copy (located INSIDE the container!)
	echo -e "\r"
	while true
	do
		read -e -p "Provide ${DOCKER__READ_BG_LIGHTPINK}Source-Filename${DOCKER__READ_NOCOLOR} (inside Container): " -i "${DOCKER__ISPBOOOT_BIN_FILENAME}" mysource_filename

		if [[ ! -z ${mysource_filename} ]]; then
			break
		fi
	done

	#---DESTINATION: Provide the Location of the file which you want to copy (located INSIDE the container!)
	echo -e "\r"
	while true
	do
		read -e -p "Provide ${DOCKER__READ_BG_WHITE}Destination-Location${DOCKER__READ_NOCOLOR} (inside Container): " -i "${DOCKER__ROOT_SP7XXX_OUT_DIR}" mydest_dir

		if [[ ! -z ${mydest_dir} ]]; then
			break
		fi
	done

	#---Summary
	echo -e "\r"
	echo -e "--------------------------------------------------------------------"
	echo "Overview:"
	echo -e "--------------------------------------------------------------------"
	echo "${DOCKER__READ_BG_LIGHTPINK}Source Full-path${DOCKER__READ_NOCOLOR}: ${mysource_dir}/${mysource_filename}"
	echo "${DOCKER__READ_BG_WHITE}Destination Full-path${DOCKER__READ_NOCOLOR}: ${mydest_dir}/${mysource_filename}"
	echo -e "--------------------------------------------------------------------"

fi

#---COPY: ~/SP7021/out/ISPBOOOT.BIN (within a container) to /mnt/<networkdrive>
echo -e "\r"
while true
do
	read -N1 -p "Do you wish to continue (y/n)?" myanswer

	if [[ ! -z ${myanswer} ]]; then
		if [[ ${myanswer} =~ [y,n] ]]; then
			break
		else
			tput cuu1
			tput el
		fi
	else 
		tput cuu1
		tput el
	fi
done
echo -e "\r"

#---Confirm answer and take action
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
