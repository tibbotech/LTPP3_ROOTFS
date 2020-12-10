#!/bin/bash
#---Define colors
GIT__NOCOLOR=$'\e[0;0m'
GIT__TITLE_BG_LIGHTBLUE='\e[30;48;5;45m'

#---Define variables
git__enkrypted_text__filename="enkrypted_git_txt.bin"
git__krypt_key__filename="mykryptonyte_key.rsa"

#---Define paths
git__home_dir="/home/imcase"
git__home_scripts_dir=${git__home_dir}/scripts
git__home_scripts_encrypted_keys_dir=${git__home_scripts_dir}/encrypted_keys
git__krypt_key__fpath=${git__home_scripts_encrypted_keys_dir}/${git__krypt_key__filename}
git__enkrypted_text__fpath=${git__home_scripts_encrypted_keys_dir}/${git__enkrypted_text__filename}


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

git__load_header__sub() {
    echo -e "\r"
    echo -e "${GIT__TITLE_BG_LIGHTBLUE}                                DOCKER${GIT__TITLE_BG_LIGHTBLUE}                                ${GIT__NOCOLOR}"
}


git__add_comment_push__sub() {
    #Define local variables
    local username=""
    local password=""
    local commit_description=""
    local ts_current=""

    
    if [[ -f ${git__enkrypted_text__fpath} ]] && [[ -f ${git__krypt_key__fpath} ]] ; then
        username="imcase"
        password=`sudo sh -c "openssl rsautl -inkey ${git__krypt_key__fpath} -decrypt < ${git__enkrypted_text__fpath}"`
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
    sudo sh -c "git add ."

    #---Timespan
    ts_current=$(date +%Y%m%d_%H%M%S)

    #---Commit
    echo -e "\r"
    read -p "Provide a description for this commit: " commit_description

    if [[ -z ${commit_description} ]]; then
        commit_description="docker_committed_on_${ts_current}"
    fi

    sudo sh -c "git commit -m '${commit_description}'"

    #Push
    sudo sh -c "git push https://${username}:${password}@github.com/tibbotech/LTPP3_ROOTFS"
}

main_sub() {
    git__load_header__sub

    git__add_comment_push__sub
}


#Execute main subroutine
main_sub
