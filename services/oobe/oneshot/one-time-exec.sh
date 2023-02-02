#!/bin/bash
#---COLORS CONSTANTS
NOCOLOR=$'\e[0m'
FG_LIGHTRED=$'\e[1;31m'
FG_ORANGE=$'\e[30;38;5;209m'
FG_LIGHTGREY=$'\e[30;38;5;246m'
FG_LIGHTGREEN=$'\e[30;38;5;71m'
FG_SOFLIGHTRED=$'\e[30;38;5;131m'



#---CONSTANTS
MOUNTPOINT_NONE="none"



#---VARIABLES
dev_dir=/dev
mmcblk0p8_device="mmcblk0p8"
dev_mmcblk0p8_dir=${dev_dir}/${mmcblk0p8_device}

mqueue_fs="mqueue"
dev_mqueue_dir=${dev_dir}/${mqueue_fs}

usr_sbin_dir=/usr/sbin
resize2fs_fpath=${usr_sbin_dir}/resize2fs

home_ubuntu_dir=/home/ubuntu
home_ubuntu_ssh_dir=/home/ubuntu/.ssh
home_ubuntu_ssh_id_rsa_fpath=${home_ubuntu_ssh_dir}/id_rsa


root_dir=/root
root_ssh_dir=${root_dir}/.ssh
root_ssh_id_rsa_fpath=${root_ssh_dir}/id_rsa



#---RESIZE
${resize2fs_fpath} ${dev_mmcblk0p8_dir}
echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: RESIZED ${FG_LIGHTGREY}${dev_mmcblk0p8_dir}${NOCOLOR}"

#---CHANGE PERMISSION HOME-FOLDER
#Change home folder owner to 'ubuntu'
chown ubuntu:ubuntu -R ${home_ubuntu_dir}

#---SSH
#For user 'ubuntu': create folder '.ssh'
if [[ ! -d ${home_ubuntu_ssh_dir} ]]; then
    mkdir ${home_ubuntu_ssh_dir}
    echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: CREATED DIRECTORY ${FG_LIGHTGREY}${home_ubuntu_ssh_dir}${NOCOLOR}"
fi

#Generate ssh-key for user 'ubuntu'
if [[ -f ${home_ubuntu_ssh_id_rsa_fpath} ]]; then
    rm ${home_ubuntu_ssh_id_rsa_fpath}

    echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: REMOVED FILE SSH-KEY for ${FG_LIGHTGREY}${home_ubuntu_ssh_id_rsa_fpath}${NOCOLOR}"
fi

ssh-keygen -t rsa -f ${home_ubuntu_ssh_id_rsa_fpath} -q -P ""
echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: GENERATED SSH-KEY for ${FG_LIGHTGREY}ubuntu${NOCOLOR}"

#Change owner to 'ubuntu'
chown ubuntu:ubuntu -R ${home_ubuntu_ssh_dir}


#For user 'root': create folder '.ssh'
if [[ ! -d ${root_ssh_dir} ]]; then
    mkdir ${root_ssh_dir}
    echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: CREATED DIRECTORY ${FG_LIGHTGREY}${root_ssh_dir}${NOCOLOR}"
fi

#Generate ssh-key for user 'root'
if [[ -f ${root_ssh_id_rsa_fpath} ]]; then
    rm ${root_ssh_id_rsa_fpath}

    echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: REMOVED FILE SSH-KEY for ${FG_LIGHTGREY}${root_ssh_id_rsa_fpath}${NOCOLOR}"
fi

ssh-keygen -t rsa -f ${root_ssh_id_rsa_fpath} -q -P ""
echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: GENERATED SSH-KEY for ${FG_LIGHTGREY}root${NOCOLOR}"



#---POSIX MESSAGE QUEUE
if [[ ! -d ${dev_mqueue_dir} ]]; then
    mkdir ${dev_mqueue_dir}

    echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: CREATED DIRECTORY ${FG_LIGHTGREY}${dev_mqueue_dir}${NOCOLOR}"
fi

currMountPoint=`mount | grep ${dev_mqueue_dir} | awk '{print $1}'`
if [[ ! -z ${currMountPoint} ]]; then
    if [[ ${currMountPoint} != ${MOUNTPOINT_NONE} ]]; then #/dev/mqueue is already mounted
        umount ${currMountPoint}    #unmount /dev/mqueue
        echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: REMOVED MOUNT DIRECTORY ${FG_LIGHTGREY}${dev_mqueue_dir}${NOCOLOR}"
    fi
fi

mount -t ${mqueue_fs} ${MOUNTPOINT_NONE} ${dev_mqueue_dir}
echo -e ":-->${FG_ORANGE}STATUS${NOCOLOR}: MOUNTED ${FG_LIGHTGREY}${dev_mqueue_dir}${NOCOLOR}"
