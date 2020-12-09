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
DOCKER__READ_FG_NOCOLOR=$'\e[0;0m'
DOCKER__READ_BG_LIGHTBLUE='\e[30;48;5;45m'

#---Define variables
enkrypted_text__filename="enkrypted_git_txt.bin"
krypt_key__filename="mykryptonyte_key.rsa"

#---Define paths
home_dir="/home/imcase"
home_scripts_dir=${home_dir}/scripts
home_scripts_encrypted_keys_dir=${home_scripts_dir}/encrypted_keys
krypt_key__fpath=${home_scripts_encrypted_keys_dir}/${krypt_key__filename}
enkrypted_text__fpath=${home_scripts_encrypted_keys_dir}/${enkrypted_text__filename}


#---Show Main Banner
echo -e "\r"
echo -e "${DOCKER__READ_BG_LIGHTBLUE}                            GIT PUSH${DOCKER__READ_BG_LIGHTBLUE}                             ${DOCKER__READ_FG_NOCOLOR}"


#---Login
username="imcase"

if [[ -f ${enkrypted_text__fpath} ]] && [[ -f ${krypt_key__fpath} ]] ; then
	password=`sudo sh -c "openssl rsautl -inkey ${krypt_key__fpath} -decrypt < ${enkrypted_text__fpath}"`
else
    echo -e "\r"
	read -e  -r -s -p "${username}-Password: " password
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
