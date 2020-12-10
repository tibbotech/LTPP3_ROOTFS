#!/bin/bash
#---Define constants
DOCKER__SPACE=" "

#---Define colors
DOCKER__NOCOLOR=$'\e[0;0m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__REPOSITORY_FG_PURPLE=$'\e[30;38;5;93m'
DOCKER__INSIDE_FG_LIGHTGREY=$'\e[30;38;5;246m'
DOCKER__OUTSIDE_FG_WHITE=$'\e[30;38;5;231m'

DOCKER__TITLE_BG_LIGHTBLUE='\e[30;48;5;45m'
DOCKER__INSIDE_BG_WHITE=$'\e[30;48;5;15m'
DOCKER__OUTSIDE_BG_LIGHTGREY=$'\e[30;48;5;246m'


#---Define variables
docker__mycopychoice=""
docker__mycontainerid=""
docker__mysource_dir=""
docker__mysource_filename=""
docker__mydest_dir=""
docker__myanswer=""

#---Define PATHS
DOCKER__ISPBOOOT_BIN_FILENAME="ISPBOOOT.BIN"
DOCKER__CURR_DIR=`pwd`
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

#---Local functions & subroutines
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

function cell__remove_whitespaces__func() {
    #Input args
    local orgstring=${1}
    
    #Remove white spaces
    local outputstring=`echo -e "${orgstring}" | tr -d "[:blank:]"`

    #OUTPUT
    echo ${outputstring}
}

docker__load_header__sub() {
    echo -e "\r"
    echo -e "${DOCKER__TITLE_BG_LIGHTBLUE}                                DOCKER${DOCKER__TITLE_BG_LIGHTBLUE}                                ${DOCKER__NOCOLOR}"
}

docker__choose_copy_direction__sub() {
	echo -e "\r"
	echo -e "Do you wish to Copy from:"
	echo -e "${DOCKER__SPACE}1. ${DOCKER__INSIDE_BG_WHITE}${DOCKER__INSIDE_FG_LIGHTGREY}INSIDE${DOCKER__NOCOLOR} > ${DOCKER__OUTSIDE_BG_LIGHTGREY}${DOCKER__OUTSIDE_FG_WHITE}OUTSIDE${DOCKER__NOCOLOR} container"
	echo -e "${DOCKER__SPACE}2. ${DOCKER__OUTSIDE_BG_LIGHTGREY}${DOCKER__OUTSIDE_FG_WHITE}OUTSIDE${DOCKER__NOCOLOR} > ${DOCKER__INSIDE_BG_WHITE}${DOCKER__INSIDE_FG_LIGHTGREY}INSIDE${DOCKER__NOCOLOR} container"
	echo -e "\r"

	while true
	do
		read -N1 -p "Choose an option: " docker__mycopychoice

		docker__mycopychoice=`cell__remove_whitespaces__func "${docker__mycopychoice}"`

		if [[ ! -z ${docker__mycopychoice} ]]; then
			if [[ ${docker__mycopychoice} =~ [1,2] ]]; then
				echo -e "\r"

				break  
			else
				echo -e "\r"
				echo -e "***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Invalid option '${docker__mycopychoice}'"

				press_any_key__localfunc

				tput cuu1
				tput el
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
}

docker__choose_containerid__sub() {
    #Get number of containers
    local numof_containers=`sudo sh -c "docker container ls | head -n -1 | wc -l"`

    #---Show Docker Image List
    echo -e "\r"
    echo -e "----------------------------------------------------------------------"
    echo -e "\t${DOCKER__GENERAL_FG_YELLOW}Create${DOCKER__NOCOLOR} Docker ${DOCKER__IMAGEID_FG_BORDEAUX}IMAGE${DOCKER__NOCOLOR} from ${DOCKER__CONTAINER_FG_BRIGHTPRUPLE}CONTAINER${DOCKER__NOCOLOR}"
    echo -e "----------------------------------------------------------------------"
        sudo sh -c "docker container ls"

        if [[ ${numof_containers} -eq 0 ]]; then
            echo -e "\r"
            echo -e "\t\t=:${DOCKER__ERROR_FG_LIGHTRED}NO CONTAINERS FOUND${DOCKER__NOCOLOR}:="
            echo -e "----------------------------------------------------------------------"
            echo -e "\r"

            exit
        else
            echo -e "----------------------------------------------------------------------"
        fi
    echo -e "\r"

	while true
	do
		read -p "Provide the ${DOCKER__REPOSITORY_FG_PURPLE}CONTAINER-ID${DOCKER__NOCOLOR}: " docker__mycontainerid
		
		docker__mycontainerid=`cell__remove_whitespaces__func "${docker__mycontainerid}"`

		if [[ ! -z ${docker__mycontainerid} ]]; then
			docker__mycontainerid_isFound=`sudo docker container ls | awk '{print $1}' | grep -w ${docker__mycontainerid}`
			
			if [[ ! -z ${docker__mycontainerid_isFound} ]]; then
				break         
			else
				echo -e "\r"
				echo -e "***${DOCKER__ERROR_FG_LIGHTRED}ERROR${DOCKER__NOCOLOR}: Invalid CONTAINER-ID: '${DOCKER__LIGHTRED}${docker__mycontainerid}${DOCKER__NOCOLOR}'"

				press_any_key__localfunc

				tput cuu1
				tput el
				tput cuu1
				tput el
				tput cuu1
				tput el
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
}

docker__get_source_destination_fpath__sub() {
	if [[ ${docker__mycopychoice} -eq 1 ]]; then
		#---SOURCE: Provide the Location of the file which you want to copy (located INSIDE the container!)
		echo -e "\r"
		while true
		do
			read -e -p "Input SOURCE-DIR (${DOCKER__INSIDE_BG_WHITE}${DOCKER__INSIDE_FG_LIGHTGREY}INSIDE${DOCKER__NOCOLOR}): " -i "${DOCKER__ROOT_SP7XXX_OUT_DIR}" docker__mysource_dir

			if [[ ! -z ${docker__mysource_dir} ]]; then
				break
			else
				tput cuu1
			fi
		done

		#---SOURCE: Provide the file which you want to copy (located INSIDE the container!)
		echo -e "\r"
		while true
		do
			read -e -p "Input SOURCE-FILE (${DOCKER__INSIDE_BG_WHITE}${DOCKER__INSIDE_FG_LIGHTGREY}INSIDE${DOCKER__NOCOLOR}): " -i "${DOCKER__ISPBOOOT_BIN_FILENAME}" docker__mysource_filename

			if [[ ! -z ${docker__mysource_filename} ]]; then
				break
			fi
		done

		#---DESTINATION: Provide the location where you want to copy to (located OUTSIDE the container!)
		echo -e "\r"
		while true
		do
			read -e -p "Input DEST-DIR (${DOCKER__OUTSIDE_BG_LIGHTGREY}${DOCKER__OUTSIDE_FG_WHITE}OUTSIDE${DOCKER__NOCOLOR}): " -i "${DOCKER__CURR_DIR}" docker__mydest_dir

			if [[ ! -z ${docker__mydest_dir} ]]; then
				break
			fi
		done


		#---Summary
		echo -e "\r"
		echo -e "--------------------------------------------------------------------"
		echo "Overview:"
		echo -e "--------------------------------------------------------------------"
		echo "${DOCKER__INSIDE_BG_WHITE}Source Full-path${DOCKER__NOCOLOR}: ${docker__mysource_dir}/${docker__mysource_filename}"
		echo "${DOCKER__OUTSIDE_BG_LIGHTGREY}Destination Full-path${DOCKER__NOCOLOR}: ${docker__mydest_dir}/${docker__mysource_filename}"
		echo -e "--------------------------------------------------------------------"
		echo -e "\r"
	else
		#---SOURCE: Provide the location where you want to copy to (located OUTSIDE the container!)
		echo -e "\r"
		while true
		do
			read -e -p "Input SOURCE-DIR (${DOCKER__OUTSIDE_BG_LIGHTGREY}${DOCKER__OUTSIDE_FG_WHITE}OUTSIDE${DOCKER__NOCOLOR}): " -i "${DOCKER__CURR_DIR}" docker__mysource_dir 

			if [[ ! -z ${docker__mysource_dir} ]]; then
				break
			fi
		done	

		#---SOURCE: Provide the file which you want to copy (located INSIDE the container!)
		echo -e "\r"
		while true
		do
			read -e -p "Input SOURCE-FILE (${DOCKER__OUTSIDE_BG_LIGHTGREY}${DOCKER__OUTSIDE_FG_WHITE}OUTSIDE${DOCKER__NOCOLOR}): " -i "${DOCKER__ISPBOOOT_BIN_FILENAME}" docker__mysource_filename

			if [[ ! -z ${docker__mysource_filename} ]]; then
				break
			fi
		done

		#---DESTINATION: Provide the Location of the file which you want to copy (located INSIDE the container!)
		echo -e "\r"
		while true
		do
			read -e -p "Input DEST-DIR (${DOCKER__INSIDE_BG_WHITE}${DOCKER__INSIDE_FG_LIGHTGREY}INSIDE${DOCKER__NOCOLOR}): " -i "${DOCKER__ROOT_SP7XXX_OUT_DIR}" docker__mydest_dir

			if [[ ! -z ${docker__mydest_dir} ]]; then
				break
			fi
		done

		#---Summary
		echo -e "\r"
		echo -e "--------------------------------------------------------------------"
		echo "Overview:"
		echo -e "--------------------------------------------------------------------"
		echo "${DOCKER__OUTSIDE_BG_LIGHTGREY}Source Full-path${DOCKER__NOCOLOR}: ${docker__mysource_dir}/${docker__mysource_filename}"
		echo "${DOCKER__INSIDE_BG_WHITE}Destination Full-path${DOCKER__NOCOLOR}: ${docker__mydest_dir}/${docker__mysource_filename}"
		echo -e "--------------------------------------------------------------------"
		echo -e "\r"
	fi
}

docker__copy_from_source_to_destination__sub() {
	while true
	do
		read -N1 -p "Do you wish to continue (y/n)?" docker__myanswer

		docker__myanswer=`cell__remove_whitespaces__func "${docker__myanswer}"`

		if [[ ! -z ${docker__myanswer} ]]; then
			if [[ ${docker__myanswer} =~ [y,n] ]]; then
				break
			else
				echo -e "\r"	#add empty line (necessary to clean 'read' line)

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
	if [[ ${docker__myanswer} == "y" ]]; then
		echo -e "\r"
		echo -e "Copy in Progress... Please wait..."

		if [[ ${docker__mycopychoice} -eq 1 ]]; then
			sudo sh -c "docker cp ${docker__mycontainerid}:${docker__mysource_dir}/${docker__mysource_filename} ${docker__mydest_dir}/${docker__mysource_filename}"
		else
			sudo sh -c "docker cp ${docker__mysource_dir}/${docker__mysource_filename} ${docker__mycontainerid}:${docker__mydest_dir}/${docker__mysource_filename}"
		fi
		
		echo -e "Copy completed...Exiting now..."
		echo -e "\r"
		echo -e "\r"
	fi
}


main_sub() {
    docker__load_header__sub

	docker__choose_copy_direction__sub

	docker__choose_containerid__sub

	docker__get_source_destination_fpath__sub

	docker__copy_from_source_to_destination__sub
}


#Execute main subroutine
main_sub
