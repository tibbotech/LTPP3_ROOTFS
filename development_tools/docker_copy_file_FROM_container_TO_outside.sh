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

#---Define colors
DOCKER_NOCOLOR='\033[0;0m'
DOCKER_YELLOW='\033[1;33m'
DOCKER_ORANGE='\033[0;33m'
DOCKER_LIGHTRED='\033[1;31m'

DOCKER_READ_LIGHTRED=$'\e[1;31m'
DOCKER_READ_NOCOLOR=$'\e[0;0m'
DOCKER_READ_LIGHTCYAN=$'\e[1;36m'
DOCKER_READ_ORANGE=$'\e[0;33m'


#---Define PATHS
DOCKER__ISPBOOOT_BIN_FILENAME="ISPBOOOT.BIN"

docker__current_dir=`pwd`
DOCKER__ROOT_SP7XXX_OUT_DIR=/root/SP7021/out


#---Show Docker Containers' List
echo -e "\r"
echo -e "------------------------------------------------------------"
echo -e "\tDocker ${DOCKER_YELLOW}Containers${DOCKER_NOCOLOR}' List"
echo -e "------------------------------------------------------------"
sudo sh -c "docker container ls"

#---Choose a docker container id
echo -e "\r"

while true
do
	read -p "Provide the ${DOCKER_READ_LIGHTRED}CONTAINER-ID${DOCKER_READ_NOCOLOR}: " mycontainerid
	
	mycontainerid_isFound=`sudo docker container ls | awk '{print $1}' | grep -w ${mycontainerid}`
	if [[ ! -z ${mycontainerid_isFound} ]]; then
		break         
	else
		echo -e "\r"
		echo -e "***ERROR: Invalid CONTAINER-ID: ${DOCKER_LIGHTRED}${mycontainerid}${DOCKER_NOCOLOR}"

		sleep 3

		tput cuu1
		tput el
		tput cuu1
		tput el
		tput cuu1
		tput el
	fi
done

#---SOURCE: Provide the Location of the file which you want to copy (located INSIDE the container!)
echo -e "\r"
while true
do
	read -e -p "Provide ${DOCKER_READ_LIGHTCYAN}Source-Location${DOCKER_READ_NOCOLOR} (inside Container): " -i "${DOCKER__ROOT_SP7XXX_OUT_DIR}" mysource_dir

	if [[ ! -z ${mysource_dir} ]]; then
		break
	fi
done

#---SOURCE: Provide the file which you want to copy (located INSIDE the container!)
echo -e "\r"
while true
do
	read -e -p "Provide ${DOCKER_READ_LIGHTCYAN}Source-Filename${DOCKER_READ_NOCOLOR} (inside Container): " -i "${DOCKER__ISPBOOOT_BIN_FILENAME}" mysource_filename

	if [[ ! -z ${mysource_filename} ]]; then
		break
	fi
done

#---DESTINATION: Provide the location where you want to copy to (located OUTSIDE the container!)
echo -e "\r"
while true
do
	read -e -p "Provide ${DOCKER_READ_ORANGE}Destination-Location${DOCKER_READ_NOCOLOR} (outside Container): " -i "${docker__current_dir}" mydest_dir

	if [[ ! -z ${mydest_dir} ]]; then
		break
	fi
done


#---Summary
echo -e "\r"
echo "----------------------------------------------------------------------"
echo "Overview:"
echo "----------------------------------------------------------------------"
echo "${DOCKER_READ_LIGHTCYAN}Source${DOCKER_READ_NOCOLOR} Full-path: ${DOCKER_READ_LIGHTCYAN}${DOCKER__ROOT_SP7XXX_OUT_DIR}/${mysource_filename}${DOCKER_READ_NOCOLOR}"
echo "${DOCKER_READ_ORANGE}Destination${DOCKER_READ_NOCOLOR} Full-path: ${DOCKER_READ_ORANGE}${mydest_dir}/${mysource_filename}${DOCKER_READ_NOCOLOR}"
echo "----------------------------------------------------------------------"

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

	sudo sh -c "docker cp ${mycontainerid}:${DOCKER__ROOT_SP7XXX_OUT_DIR}/${mysource_filename} ${mydest_dir}/${mysource_filename}"

	echo -e "Copy completed...Exiting now..."
	echo -e "\r"
	echo -e "\r"
fi

