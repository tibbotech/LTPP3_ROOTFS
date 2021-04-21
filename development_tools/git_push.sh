#!/bin/bash
#---Define colors
DOCKER__NOCOLOR=$'\e[0m'
DOCKER__FG_LIGHTRED=$'\e[1;31m'
DOCKER__FG_SOFTLIGHTBLUE=$'\e[30;38;5;80m'
DOCKER__GENERAL_FG_YELLOW=$'\e[1;33m'
DOCKER__INSIDE_FG_LIGHTGREY=$'\e[30;38;5;246m'
DOCKER__GIT_FG_WHITE=$'\e[30;38;5;243m'

DOCKER__TITLE_FG_LIGHTBLUE='\e[30;48;5;45m'

DOCKER__TITLE_BG_ORANGE=$'\e[30;48;5;215m'

#---Define constants
DOCKER__TITLE="TIBBO"
docker__enkrypted_text__filename="enkrypted_git_txt.bin"
docker__krypt_key__filename="mykryptonyte_key.rsa"


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

docker__environmental_variables__sub() {
    #---Define paths
    docker__home_dir="/home/imcase"
    docker__home_scripts_dir=${docker__home_dir}/scripts
    docker__home_scripts_encrypted_keys_dir=${docker__home_scripts_dir}/encrypted_keys
    docker__krypt_key__fpath=${docker__home_scripts_encrypted_keys_dir}/${docker__krypt_key__filename}
    docker__enkrypted_text__fpath=${docker__home_scripts_encrypted_keys_dir}/${docker__enkrypted_text__filename}
}

docker__load_header__sub() {
    echo -e "\r"
    echo -e "${DOCKER__TITLE_BG_ORANGE}                                 ${DOCKER__TITLE}${DOCKER__TITLE_BG_ORANGE}                                ${DOCKER__NOCOLOR}"
}


docker__add_comment_push__sub() {
    #Define local variables
    local username=""
    local password=""
    local commit_description=""
    local ts_current=""

    echo -e "----------------------------------------------------------------------"
    echo -e "${DOCKER__GENERAL_FG_YELLOW}Git${DOCKER__NOCOLOR} ${DOCKER__FG_SOFTLIGHTBLUE}PUSH${DOCKER__NOCOLOR}"
    echo -e "----------------------------------------------------------------------"

    if [[ -f ${docker__enkrypted_text__fpath} ]] && [[ -f ${docker__krypt_key__fpath} ]] ; then
        username="imcase"
        password=`openssl rsautl -inkey ${docker__krypt_key__fpath} -decrypt < ${docker__enkrypted_text__fpath}`
    else
        echo -e "\r"

        while true
        do  
            read -p "[GIT] Username: " username

            if [[ ! -z ${username} ]]; then
                break
            else
                tput cuu1
                tput el
            fi
        done

        while true
        do  
            read -e  -r -s -p "[GIT] Password: " password

            if [[ ! -z ${password} ]]; then
                echo -e "\r"

                break
            else
                echo -e "\r"

                tput cuu1
                tput el
            fi
        done
    fi

    #---Add items to commit
    git add .

    #---Timespan
    ts_current=$(date +%Y%m%d_%H%M%S)

    #---Commit
    echo -e "\r"
    read -p "Provide a description for this commit: " commit_description

    if [[ -z ${commit_description} ]]; then
        commit_description="docker_committed_on_${ts_current}"
    fi

    git commit -m "${commit_description}"


    #Push
    git push https://${username}:${password}@github.com/tibbotech/LTPP3_ROOTFS
}

main_sub() {
    docker__load_header__sub

    docker__environmental_variables__sub

    docker__add_comment_push__sub
}


#Execute main subroutine
main_sub
