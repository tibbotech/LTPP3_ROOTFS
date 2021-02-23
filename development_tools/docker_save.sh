#!/bin/bash
#---Define colors
DOCKER__NOCOLOR=$'\e[0m'
DOCKER__ERROR_FG_LIGHTRED=$'\e[1;31m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__FILES_FG_ORANGE=$'\e[30;38;5;215m'
DOCKER__TAG_FG_LIGHTPINK=$'\e[30;38;5;218m'

DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'

#---Define constants
DOCKER__TITLE="TIBBO"


#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C_func INT

function CTRL_C_func() {
    echo -e "\r"
    echo -e "\r"
    echo -e "${DOCKER__ERROR_FG_LIGHTRED}Saving${DOCKER__NOCOLOR} Docker Image Interrupted..."
    echo -e "\r"
    echo -e "Exiting now..."
    echo -e "\r"
    echo -e "\r"

    exit
}

docker__load_header__sub() {
    echo -e "\r"
    echo -e "${DOCKER__TITLE_BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__TITLE_BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}

docker__environmental_variables__sub() {
    #Define paths
    docker__current_script_fpath=$(realpath $0)
    docker__current_dir=$(dirname ${docker__current_script_fpath})
    docker__parent_dir=${docker__current_dir%/*}    #gets one directory up
    docker__first_dir=${docker__parent_dir%/*}    #gets one directory up
    docker__images_dir=${docker__first_dir}/docker/images
}

docker__create_dirs__sub() {
    #Create directory if not present
    if [[ ! -d ${docker__images_dir} ]]; then
        mkdir -p ${docker__images_dir}
    fi
}

docker__save_handler__sub() {
    echo -e "----------------------------------------------------------------------"
    echo -e "\t${DOCKER__GENERAL_FG_YELLOW}Save${DOCKER__NOCOLOR} a Docker Image"
    echo -e "----------------------------------------------------------------------"
        docker image ls
    echo -e "\r"


    while true
    do
        read -p "Provide ${DOCKER__ERROR_FG_LIGHTRED}REPOSITORY${DOCKER__NOCOLOR} (e.g. ubuntu_sunplus)? " myrepository
        if [[ ! -z ${myrepository} ]]; then

            myrepository_isFound=`docker image ls | grep -w "${myrepository}"`
            if [[ ! -z ${myrepository_isFound} ]]; then
                while true
                do        
                    #Find tag belonging to 'myrepository' (Exact Match)
                    mytag=$(docker image ls | grep -w "${myrepository}" | awk '{print $2}')

                    #Request for TAG input
                    read -e -p "Provide ${DOCKER__TAG_FG_LIGHTPINK}TAG${DOCKER__NOCOLOR} (e.g. latest): " -i ${mytag} mytag
                    if [[ ! -z ${mytag} ]]; then    #input was NOT an EMPTY STRING

                        mytag_isFound=`docker image ls | grep -w "${myrepository}" | grep -w "${mytag}"`    #check if 'myrepository' AND 'mytag' is found in 'docker image ls'
                        if [[ ! -z ${mytag_isFound} ]]; then    #match was found
                            #Compose image full-path
                            docker__image_fpath="${docker__images_dir}/${myrepository}_${mytag}.tar.gz"
                            
                            while true
                            do
                                echo -e "Provide Image-file full-path?"
                                echo -e "${DOCKER__FILES_FG_ORANGE}"    #echo used to start a color for 'read'
                                read -e -p $'\t' -i "${docker__image_fpath}" myoutput_fpath
                                echo -e "${DOCKER__NOCOLOR}"    #echo used to reset color

                                if [[ ! -z ${myoutput_fpath} ]]; then
                                    
                                    myoutput_dir=`dirname ${myoutput_fpath}`
                                    if [[ -d ${myoutput_dir} ]]; then
                                        echo -e "\r"
                                        echo -e "Saving selected docker: ${DOCKER__ERROR_FG_LIGHTRED}${myrepository}${DOCKER__NOCOLOR}:${DOCKER__TAG_FG_LIGHTPINK}${mytag}${DOCKER__NOCOLOR}"
                                        echo -e "To: ${DOCKER__FILES_FG_ORANGE}${myoutput_fpath}${DOCKER__NOCOLOR}"
                                        echo -e "\r"

                                        while true
                                        do
                                            read -p "Do you wish to continue (y/n)? " myanswer
                                            if  [[ ${myanswer} == "y" ]]; then
                                                echo -e "\r"
                                                echo -e "Please wait...this could take a while..."
                                                docker image save --output ${myoutput_fpath} ${myrepository}:${mytag} > /dev/null

                                                echo -e "\r"
                                                echo -e "Save completed!!!"
                                                echo -e "\r"

                                                exit
                                            elif  [[ ${myanswer} == "n" ]]; then
                                                tput cuu1	#move UP with 1 line
                                                tput el		#clear until the END of line
                                                tput cuu1	#move UP with 1 line
                                                tput el		#clear until the END of line
                                                tput cuu1	#move UP with 1 line
                                                tput el		#clear until the END of line
                                                tput cuu1	#move UP with 1 line
                                                tput el		#clear until the END of line
                                                tput cuu1	#move UP with 1 line
                                                tput el		#clear until the END of line
                                                tput cuu1	#move UP with 1 line
                                                tput el		#clear until the END of line
                                                tput cuu1	#move UP with 1 line
                                                tput el		#clear until the END of line
                                                tput cuu1	#move UP with 1 line
                                                tput el		#clear until the END of line
                                                tput cuu1	#move UP with 1 line
                                                tput el		#clear until the END of line

                                                break
                                            else    #Empty String
                                                tput cuu1	#move UP with 1 line
                                                tput el		#clear until the END of line
                                            fi
                                        done
                                    else    #directory does NOT exist
                                        echo -e "\r"
                                        echo -e "Directory: ${DOCKER__ERROR_FG_LIGHTRED}${myoutput_dir}${DOCKER__NOCOLOR} does NOT exist"

                                        sleep 2

                                        tput cuu1	#move UP with 1 line
                                        tput el		#clear until the END of line
                                        tput cuu1	#move UP with 1 line
                                        tput el		#clear until the END of line
                                        tput cuu1	#move UP with 1 line
                                        tput el		#clear until the END of line
                                        tput cuu1	#move UP with 1 line
                                        tput el		#clear until the END of line
                                        tput cuu1	#move UP with 1 line
                                        tput el		#clear until the END of line
                                        tput cuu1	#move UP with 1 line
                                        tput el		#clear until the END of line
                                    fi
                                else    #Empty String
                                    tput cuu1	#move UP with 1 line
                                    tput el		#clear until the END of line
                                    tput cuu1	#move UP with 1 line
                                    tput el		#clear until the END of line
                                fi
                            done
                        else
                            echo -e "\r"
                            echo -e "Provided TAG: ${DOCKER__ERROR_FG_LIGHTRED}${mytag}${DOCKER__NOCOLOR} does NOT belong to REPOSITORY: ${DOCKER__ERROR_FG_LIGHTRED}${myrepository}${DOCKER__NOCOLOR}"

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
                echo -e "Provided REPOSITORY: ${DOCKER__ERROR_FG_LIGHTRED}${myrepository}${DOCKER__NOCOLOR} does NOT exist"

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
}

main_sub() {
    docker__load_header__sub

    docker__environmental_variables__sub

    docker__create_dirs__sub

    docker__save_handler__sub

}

main_sub
