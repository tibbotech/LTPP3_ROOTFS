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



#Define variables
ISPBOOOT_BIN_filename="ISPBOOOT.BIN"
SP7xxx_foldername="SP7021"

home_dir=~
SP7xxx_dir=${home_dir}/${SP7xxx_foldername}
SP7xxx_out_dir=${SP7xxx_dir}/out
mnt_dir=/mnt

#Request for input
while true
do
    read -e -p "Target IP-address (e.g. 192.168.1.100): " target_ipv4

    if [[ ! -z ${target_ipv4} ]]; then
        ipv4_pattern='^([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)$'

        if [[ ! ${target_ipv4} =~ ${ipv4_pattern} ]]; then
            echo -e "\r"
            echo -e "***ERROR: not a valid IPv4-address"

            sleep 2

            tput cuu1	#move UP with 1 line
            tput el		#clear until the END of line
            tput cuu1	#move UP with 1 line
            tput el		#clear until the END of line
            tput cuu1	#move UP with 1 line
            tput el		#clear until the END of line
        else
            break
        fi
    else
        tput cuu1	#move UP with 1 line
        tput el		#clear until the END of line
    fi
done
while true
do
    read -e -p "Target Network-share (e.g. Shared): " networkshare

    if [[ ! -z ${networkshare} ]]; then
        break
    else
        tput cuu1	#move UP with 1 line
        tput el		#clear until the END of line
    fi
done
while true
do
    read -e -p "Username (e.g. foo): " username

    if [[ ! -z ${username} ]]; then
        break
    else
        tput cuu1	#move UP with 1 line
        tput el		#clear until the END of line
    fi
done
while true
do
    read -rs -p "Password (e.g. bar): " password

    if [[ ! -z ${password} ]]; then
        break
    else
        tput cuu1	#move UP with 1 line
        tput el		#clear until the END of line
    fi
done


#Create directory /mnt/Shared (if needed)
if [[ ! -d ${mnt_dir}/${networkshare} ]]; then
	sudo mkdir ${mnt_dir}/${networkshare}
fi


#Mount Network Drive
sudo mount -t cifs -o user=${username},pass=${password} //${target_ipv4}/${networkshare} ${mnt_dir}/${networkshare}


#Check Mounted Network Drive
checkif_networkdrive_isMounted=`sudo mount | grep "${mnt_dir}/${networkshare}"`
if [[ ! -z ${checkif_networkdrive_isMounted} ]]; then
	echo -e "\r"
	echo "Network drive <//${target_ipv4}/${networkshare}> successfully mounted!!!"
	echo -e "\r"
else
    echo -e "\r"
	echo "Failed to mount: Network drive <//${target_ipv4}/${networkshare}>"
    echo -e "\r"

	exit
fi

#Copy ~/SP7021/out/ISPBOOOT.BIN to /mnt/Shared
sudo rsync -ah --progress ${SP7xxx_out_dir}/${ISPBOOOT_BIN_filename} ${mnt_dir}/${networkshare}/${ISPBOOOT_BIN_filename}