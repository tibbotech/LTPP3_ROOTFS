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
DOCKER_YELLOW='\033[1;33m'
DOCKER_LIGHTGREEN='\033[1;32m'
DOCKER_ORANGE='\033[0;33m'
DOCKER_LIGHTRED='\033[1;31m'
DOCKER_CYAN='\033[0;36m'
DOCKER_PURPLE='\033[0;35m'
DOCKER_RGB_GREENBLUE='\033[38;5;79m'
DOCKER_NOCOLOR='\033[0;0m'

DOCKER_READ_LIGHTGREEN=$'\e[1;32m'
DOCKER_READ_ORANGE=$'\e[0;33m'
DOCKER_READ_LIGHTRED=$'\e[1;31m'
DOCKER_READ_PURPLE=$'\e[0;35m'
DOCKER_READ_RGB_GREENBLUE=$'\e[38;5;79m'
DOCKER_READ_NOCOLOR=$'\e[0;0m'

#Define paths
dockerfile_filename="dockerfile_autocreated_on"
dockerfile_fpath=""


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
        "#---Continue from REPOSITORY:TAG=${myrepositoryid}:${mytag_input}"\
        "FROM ${myrepositoryid}:${mytag_input}"\
        ""\
        "#---LABEL about the custom image"\
        "LABEL maintainer=\"hien@tibbo.com\""\
        "LABEL version=\"0.1\""\
        "LABEL description=\"Continue from image '${myrepositoryid}:${mytag_input}', and run 'build_BOOOT_BIN.sh'\""\
        "LABEL NEW repository:tag=\"${myrepositoryid_new}:${mytag_input}\""\
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
echo -e "------------------------------------------------------------"
echo -e "\t${DOCKER_YELLOW}Build${DOCKER_NOCOLOR} Docker ${DOCKER_CYAN}Image${DOCKER_NOCOLOR} from specified ${DOCKER_READ_LIGHTRED}dockerfile${DOCKER_NOCOLOR}"
echo -e "------------------------------------------------------------"
sudo sh -c "docker image ls"
echo -e "\r"


#Create timestamp
dockerfile_timestamp=$(date +%y%m%d%H%M%S)

while true
do
    #Provide a CONTAINER-ID from which you want to create an Image
    read -p "Choose a ${DOCKER_READ_PURPLE}REPOSITORY${DOCKER_READ_NOCOLOR} name from list (e.g. ubuntu_buildbin): " myrepositoryid
    if [[ ! -z ${myrepositoryid} ]]; then    #input is NOT an EMPTY STRING

        #Check if 'myrepositoryid' is found in ' docker container ls'
        myrepositoryid_isFound=`sudo docker image ls | awk '{print $1}' | grep -w ${myrepositoryid}`
        if [[ ! -z ${myrepositoryid_isFound} ]]; then    #match was found

            while true
            do
                #Provide a TAG for this new image
                read -p "Provide the ${DOCKER_READ_ORANGE}TAG${DOCKER_READ_NOCOLOR} (e.g. latest) matching with REPOSITORY ${DOCKER_READ_PURPLE}${myrepositoryid}${DOCKER_READ_NOCOLOR}: " mytag_input
                if [[ ! -z ${mytag_input} ]]; then   #input is NOT an Empty String        

                    #Find tag belonging to 'myrepositoryid' (Exact Match)
                    myrepositoryid_tag=$(sudo docker image ls | grep -w "${myrepositoryid}" | awk '{print $2}')
                    if [[ ${myrepositoryid_tag} == ${mytag_input} ]]; then

                        while true
                        do
                            #Provide a NEW CONTAINER-ID for the NEW image
                            read -p "Provide a ${DOCKER_READ_RGB_GREENBLUE}NEW REPOSITORY${DOCKER_READ_NOCOLOR} name (e.g. ubuntu_buildbin_NEW): " myrepositoryid_new
                                                    
                            #Check if 'myrepositoryid' is UNIQUE
                            myrepositoryid_new_isFound=`sudo docker image ls | awk '{print $1}' | grep -w ${myrepositoryid_new}`                           
                            if  [[ -z ${myrepositoryid_new_isFound} ]]; then    #match was NOT found

                                while true
                                do
                                    #Provide a REPOSITORY for this new image
                                    echo -e "Provide ${DOCKER_READ_LIGHTGREEN}dockerfile location${DOCKER_READ_NOCOLOR} (e.g. /repo/LTPP3_ROOTFS): "
                                    read -p "" mydockerfile_location_input
                                    if [[ -d ${mydockerfile_location_input} ]]; then   #input was NOT an Empty String
                                        #Generate a 'dockerfile' with content
                                        #OUTPUT: dockerfile_fpath
                                        create_dockerfile__sub "${dockerfile_filename}" "${mydockerfile_location_input}"

                                        echo -e "\r"
                                        echo -e "------------------------------------------------------------"
                                        echo -e "Summary"
                                        echo -e "------------------------------------------------------------"
                                        echo -e "CREATE ${DOCKER_RGB_GREENBLUE}REPOSITORY${DOCKER_NOCOLOR}:${DOCKER_READ_ORANGE}TAG${DOCKER_READ_NOCOLOR}:\t\t${myrepositoryid_new}:${mytag_input}"
                                        echo -e "BUILD WITH ${DOCKER_READ_PURPLE}REPOSITORY${DOCKER_READ_NOCOLOR}:${DOCKER_READ_ORANGE}TAG${DOCKER_READ_NOCOLOR}:\t${myrepositoryid}:${mytag_input}"                                        
                                        echo -e "Dockerfile Location:\t\t${dockerfile_fpath}"
                                        echo -e ""

                                        #Confirm if user wants to continue
                                        read -p "Do you wish to continue (y/n)? " myanswer
                                        if [[ ${myanswer} == "y" ]]; then
                                            sudo sh -c "docker build --tag ${myrepositoryid_new}:${mytag_input} - < ${dockerfile_fpath}"
                                        fi

                                        exit  #Exit function
                                    else    #input was an Empty String
                                        echo -e "\r"
                                        echo -e "***${DOCKER_LIGHTRED}ERROR${DOCKER_NOCOLOR}: unknown directory: ${mydockerfile_location_input}!!!"

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
                                echo -e "***${DOCKER_LIGHTRED}ERROR${DOCKER_NOCOLOR}: REPOSITORY ${DOCKER_RGB_GREENBLUE}${myrepositoryid_new}${DOCKER_NOCOLOR} already exist!!!"

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
                        echo -e "***${DOCKER_LIGHTRED}ERROR${DOCKER_NOCOLOR}: ${DOCKER_ORANGE}TAG${DOCKER_NOCOLOR} and ${DOCKER_READ_PURPLE}REPOSITORY${DOCKER_NOCOLOR} do NOT match!!!"

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
            echo -e "***${DOCKER_LIGHTRED}ERROR${DOCKER_NOCOLOR}: ${DOCKER_PURPLE}${myrepositoryid}${DOCKER_NOCOLOR} not found!!!"

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

