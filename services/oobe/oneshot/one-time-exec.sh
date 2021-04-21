#!/bin/bash
#---VARIABLES
usr_sbin_dir=/usr/sbin
home_ubuntu_dir=/home/ubuntu
home_ubuntu_ssh_dir=/home/ubuntu/.ssh
root_dir=/root
root_ssh_dir=${root_dir}/.ssh

#Resize
sudo ${usr_sbin_dir}/resize2fs /dev/mmcblk0p8

#For user 'ubuntu': create folder '.ssh'
mkdir ${home_ubuntu_ssh_dir}

#Generate ssh-key for user 'ubuntu'
ssh-keygen -t rsa -f ${home_ubuntu_ssh_dir}/id_rsa -q -P ""

#For user 'root': create folder '.ssh'
mkdir ${root_ssh_dir}

#Generate ssh-key for user 'root'
ssh-keygen -t rsa -f ${root_ssh_dir}/id_rsa -q -P ""
