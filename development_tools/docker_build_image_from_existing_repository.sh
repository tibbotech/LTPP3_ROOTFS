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
DOCKER__YELLOW='\033[1;33m'
DOCKER__LIGHTGREEN='\033[1;32m'
DOCKER__ORANGE='\033[0;33m'
DOCKER__LIGHTRED='\033[1;31m'
DOCKER__CYAN='\033[0;36m'
DOCKER__PURPLE='\033[0;35m'
DOCKER__RGB_GREENBLUE='\033[38;5;79m'
DOCKER__NOCOLOR='\033[0;0m'

DOCKER__READ_LIGHTGREEN=$'\e[1;32m'
DOCKER__READ_ORANGE=$'\e[0;33m'
DOCKER__READ_LIGHTRED=$'\e[1;31m'
DOCKER__READ_PURPLE=$'\e[0;35m'
DOCKER__READ_RGB_GREENBLUE=$'\e[38;5;79m'
DOCKER__READ_NOCOLOR=$'\e[0;0m'

DOCKER__BG_LIGHTBLUE='\e[30;48;5;45m'


#Define paths
dockerfile_filename="dockerfile_autocreated_on"
dockerfile_fpath=""


#---SHow Main Banner
echo -e "\r"
echo -e "${DOCKER__BG_LIGHTBLUE}                               DOCKER${DOCKER__BG_LIGHTBLUE}                               ${DOCKER__NOCOLOR}"


#---Define subroutines
create_dockerfile__sub() {
    #Input args
    local filename_input=${1}
    local directory_input=${2}

    #Generate timestamp
    local filename_w_timestamp=${filename_input}_${dockerfile_timestamp}


    #Define filename
    dockerfile_fpath=${directory_input}/${filename_w_timestamp}

    #Define dockerfile content
    DOCKERFILE_CONTENT_ARR=(\
        "#---Continue from REPOSITORY:TAG=${myrepository}:${mytag}"\
        "FROM ${myrepository}:${mytag}"\
        ""\
        "#---LABEL about the custom image"\
        "LABEL maintainer=\"hien@tibbo.com\""\
        "LABEL version=\"0.1\""\
        "LABEL description=\"Continue from image '${myrepository}:${mytag}', and run 'build_BOOOT_BIN.sh'\""\
        "LABEL NEW repository:tag=\"${myrepository_new}:${mytag}\""\
        ""\
        "#---Disable Prompt During Packages Installation"\
        "ARG DEBIAN_FRONTEND=noninteractive"\
        ""\
        "#---Update local Git repository"\
        "RUN cd ~/LTPP3_ROOTFS && git pull"\
        ""\
        "#---Run Prepreparation of Disk (before Chroot)"\
        "RUN cd ~ && ~/LTPP3_ROOTFS/build_BOOOT_BIN.sh"\
    )


    #Cycle thru array and write each row to Global variable 'dockerfile_fpath'
	for ((i=0; i<${#DOCKERFILE_CONTENT_ARR[@]}; i++))
	do
        sudo sh -c "printf '%s\n' '${DOCKERFILE_CONTENT_ARR[$i]}' >> ${dockerfile_fpath}"
	done
}




#---Show Docker Image List
echo -e "\r"
echo -e "--------------------------------------------------------------------"
echo -e "\t${DOCKER__YELLOW}Build${DOCKER__NOCOLOR} Docker ${DOCKER__CYAN}Image${DOCKER__NOCOLOR} from existing ${DOCKER__READ_PURPLE}REPOSITORY${DOCKER__NOCOLOR}"
echo -e "--------------------------------------------------------------------"
sudo sh -c "docker image ls"
echo -e "\r"


#Create timestamp
dockerfile_timestamp=$(date +%y%m%d%H%M%S)

while true
do
    #Provide a CONTAINER-ID from which you want to create an Image
    read -p "Choose a ${DOCKER__READ_PURPLE}REPOSITORY${DOCKER__READ_NOCOLOR} name from list (e.g. ubuntu_buildbin): " myrepository
    if [[ ! -z ${myrepository} ]]; then    #input is NOT an EMPTY STRING

        #Check if 'myrepository' is found in ' docker container ls'
        myrepository_isFound=`sudo docker image ls | awk '{print $1}' | grep -w ${myrepository}`
        if [[ ! -z ${myrepository_isFound} ]]; then    #match was found

            while true
            do
                #Find tag belonging to 'myrepository' (Exact Match)
                myrepository_tag=$(sudo docker image ls | grep -w "${myrepository}" | awk '{print $2}')

                #Provide a TAG for this new image
                read -e -p "Provide the ${DOCKER__READ_ORANGE}TAG${DOCKER__READ_NOCOLOR} (e.g. latest) matching with REPOSITORY ${DOCKER__READ_PURPLE}${myrepository}${DOCKER__READ_NOCOLOR}: " -i ${myrepository_tag} mytag
                if [[ ! -z ${mytag} ]]; then   #input is NOT an Empty String        

                    mytag_isFound=`sudo docker image ls | grep -w "${myrepository}" | grep -w "${mytag}"`    #check if 'myrepository' AND 'mytag' is found in 'docker image ls'
                    if [[ ! -z ${mytag_isFound} ]]; then    #match was found

                        while true
                        do
                            #Provide a NEW CONTAINER-ID for the NEW image
                            read -p "Provide a ${DOCKER__READ_RGB_GREENBLUE}NEW REPOSITORY${DOCKER__READ_NOCOLOR} name (e.g. ubuntu_buildbin_NEW): " myrepository_new
                                                    
                            #Check if 'myrepository' is UNIQUE
                            myrepository_new_isFound=`sudo docker image ls | awk '{print $1}' | grep -w ${myrepository_new}`                           
                            if  [[ -z ${myrepository_new_isFound} ]]; then    #match was NOT found

                                while true
                                do
                                    #Provide a REPOSITORY for this new image
                                    echo -e "Provide ${DOCKER__READ_LIGHTGREEN}dockerfile location${DOCKER__READ_NOCOLOR} (e.g. /repo/LTPP3_ROOTFS): "
                                    read -p "" mydockerfile_location_input
                                    if [[ -d ${mydockerfile_location_input} ]]; then   #input was NOT an Empty String
                                        #Generate a 'dockerfile' with content
                                        #OUTPUT: dockerfile_fpath
                                        create_dockerfile__sub "${dockerfile_filename}" "${mydockerfile_location_input}"

                                        echo -e "\r"
                                        echo -e "--------------------------------------------------------------------"
                                        echo -e "Summary"
                                        echo -e "--------------------------------------------------------------------"
                                        echo -e "CREATE ${DOCKER__RGB_GREENBLUE}REPOSITORY${DOCKER__NOCOLOR}:${DOCKER__READ_ORANGE}TAG${DOCKER__READ_NOCOLOR}:\t\t${myrepository_new}:${mytag}"
                                        echo -e "BUILD WITH ${DOCKER__READ_PURPLE}REPOSITORY${DOCKER__READ_NOCOLOR}:${DOCKER__READ_ORANGE}TAG${DOCKER__READ_NOCOLOR}:\t${myrepository}:${mytag}"                                        
                                        echo -e "Dockerfile Location:\t\t${dockerfile_fpath}"
                                        echo -e ""

                                        #Confirm if user wants to continue
                                        read -p "Do you wish to continue (y/n)? " myanswer
                                        if [[ ${myanswer} == "y" ]]; then
                                            sudo sh -c "docker build --tag ${myrepository_new}:${mytag} - < ${dockerfile_fpath}"
                                        fi

                                        exit  #Exit function
                                    else    #input was an Empty String
                                        echo -e "\r"
                                        echo -e "***${DOCKER__LIGHTRED}ERROR${DOCKER__NOCOLOR}: unknown directory: ${mydockerfile_location_input}!!!"

                                        sleep 3

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
                            else
                                echo -e "\r"
                                echo -e "***${DOCKER__LIGHTRED}ERROR${DOCKER__NOCOLOR}: REPOSITORY ${DOCKER__RGB_GREENBLUE}${myrepository_new}${DOCKER__NOCOLOR} already exist!!!"

                                sleep 3

                                tput cuu1	#move UP with 1 line
                                tput el		#clear until the END of line
                                tput cuu1	#move UP with 1 line
                                tput el		#clear until the END of line
                                tput cuu1	#move UP with 1 line
                                tput el		#clear until the END of line 
                            fi
                        done
                    else    #input was an Empty String
                        echo -e "\r"
                        echo -e "***${DOCKER__LIGHTRED}ERROR${DOCKER__NOCOLOR}: ${DOCKER__ORANGE}TAG${DOCKER__NOCOLOR} and ${DOCKER__READ_PURPLE}REPOSITORY${DOCKER__NOCOLOR} do NOT match!!!"

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
        else    #NO match was found
            echo -e "\r"
            echo -e "***${DOCKER__LIGHTRED}ERROR${DOCKER__NOCOLOR}: ${DOCKER__PURPLE}${myrepository}${DOCKER__NOCOLOR} not found!!!"

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

