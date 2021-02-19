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
DOCKER__FIVE_SPACES="     "


#---Trap ctrl-c and Call ctrl_c()
trap CTRL_C__func INT

function CTRL_C__func() {
    echo -e "\r"
    echo -e "\r"
    echo -e "${DOCKER__ERROR_FG_LIGHTRED}Loading${DOCKER__NOCOLOR} Docker Image Interrupted..."
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
    docker__current_dir=`dirname "$0"`
    docker__parent_dir=${docker__current_dir%/*}    #gets one directory up
    docker__first_dir=${docker__parent_dir%/*}    #gets one directory up
    docker__images_dir=${docker__first_dir}/docker/images
    docker__image_fpath=""
}


docker__load_handler__sub() {
    echo -e "----------------------------------------------------------------------"
    echo -e "\t${DOCKER__GENERAL_FG_YELLOW}Load${DOCKER__NOCOLOR} a Docker Image-file"
    echo -e "----------------------------------------------------------------------"

    #Define variables
    local arr_line=""
    local images_list_filename=""

    #Get all files at the specified location
    local images_list_fpath_string=`find ${docker__images_dir} -maxdepth 1 -type f`
    local arr_line=""

    #Check if '' is an EMPTY STRING
    if [[ -z ${images_list_fpath_string} ]]; then
        echo -e "${DOCKER__FIVE_SPACES}No image found at location: ${DOCKER__FILES_FG_ORANGE}${docker__images_dir}${DOCKER__NOCOLOR}"
    else
        #Convert string to array (with space delimiter)
        local images_list_fpath_arr=(${images_list_fpath_string})

        #Initial sequence number
        local seqnum=1

        #Show all files
        for arr_line in "${images_list_fpath_arr[@]}"
        do
            #Get filename only
            images_list_filename=`basename ${arr_line}`  
        
            #Show filename
            echo -e "${DOCKER__FIVE_SPACES}${seqnum}. ${images_list_filename}"

            #increment sequence-number
            seqnum=$((seqnum+1))
        done
    fi

    echo -e "----------------------------------------------------------------------"
    echo -e "${DOCKER__FIVE_SPACES}m. manual input"
    echo -e "----------------------------------------------------------------------"
    

    #Choose an option
    while true
    do
        while true
        do
            #Show read-input
            read -p "Your choice: " mychoice

            #Check if 'mychoice' is a numeric value
            if [[ ${mychoice} =~ [1-9,0,m] ]]; then
                #check if 'mychoice' is one of the numbers shown in the overview...
                #... AND 'mychoice' is NOT '0'
                if [[ ${mychoice} -lt ${seqnum} ]] && [[ ${mychoice} -ne 0 ]]; then
                    arrnum=$((mychoice-1))
                    myoutput_fpath=${images_list_fpath_arr[${arrnum}]}

                    echo -e "\r"
                    echo -e "Your have selected:"
                    echo -e "${DOCKER__FILES_FG_ORANGE}"    #echo used to start a color for 'read'
                    echo -e "\t${myoutput_fpath}"
                    echo -e "${DOCKER__NOCOLOR}"    #echo used to reset color

                    break   #exit loop
                elif [[ ${mychoice} == "m" ]]; then
                    myoutput_fpath=${images_list_fpath_arr[0]}  #'images_list_fpath_arr' contains the full-path

                    echo -e "\r"
                    echo -e "Provide full-path of your Image-file:"
                    echo -e "${DOCKER__FILES_FG_ORANGE}"    #echo used to start a color for 'read'
                    read -e -p $'\t' -i "${myoutput_fpath}" myoutput_fpath
                    echo -e "${DOCKER__NOCOLOR}"    #echo used to reset color

                    break
                else
                    tput cuu1   #move-UP one line
                    tput el #clean until end of line

                fi
            else
                tput cuu1   #move-UP one line
                tput el #clean until end of line    

            fi
        done

        #Double-check if chosen image-file still exist
        if [[ -f ${myoutput_fpath} ]]; then
            while true
            do
                read -p "Do you wish to continue (y/n)? " myanswer
                if  [[ ${myanswer} == "y" ]]; then
                    echo -e "\r"
                    echo -e "Loading image: ${DOCKER__FILES_FG_ORANGE}${myoutput_fpath}${DOCKER__NOCOLOR}"
                    echo -e "\r"
                    echo -e "Please wait...this might take a while..."

                        docker image load --input ${myoutput_fpath} > /dev/null

                    echo -e "\r"
                    echo -e "Load completed!!!"
                        
                    echo -e "\r"
                        docker__load_header__sub
                    echo -e "----------------------------------------------------------------------"
                        docker image ls
                    echo -e "----------------------------------------------------------------------"
                    echo -e "\r"

                    sleep 2

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

                    break
                else    #Empty String
                    tput cuu1	#move UP with 1 line
                    tput el		#clear until the END of line
                fi
            done
        else    #directory does NOT exist
            echo -e "\r"
            echo -e "File: ${DOCKER__ERROR_FG_LIGHTRED}${myoutput_fpath}${DOCKER__NOCOLOR} does NOT exist"

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
            tput cuu1	#move UP with 1 line
            tput el		#clear until the END of line
            tput cuu1	#move UP with 1 line
            tput el		#clear until the END of line
        fi
    done
}

main_sub() {
    docker__load_header__sub

    docker__environmental_variables__sub

    docker__load_handler__sub
}

main_sub
