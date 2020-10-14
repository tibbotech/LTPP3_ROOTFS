#!/bin/bash
#---Local Functions
replace_string_with_another_string__localfunc() {
	#input args
	search_str=${1}
	old_str=${2}
	new_str=${3}
	file_name=${4}

	#define variables
	file_name_bak=$file_name".bak"

	#show input args
	echo "---Replace old-string with a new-string---"
	echo ">old-string: $old_str"
	echo ">new-string: $new_str"
	echo ">file-name: $file_name"
	echo ">backup file-name: $file_name_bak"
	echo ""

	#first make a backup of the file
	echo ">backing up file: $file_name to $file_name_bak"
	mv $file_name $file_name_bak

	#replace old string with new string
	echo ">start replacing string..."
	while read line
	do
		if [[ $line =~ $search_str ]]; then
			echo ${line//$old_str/$new_str} >> $file_name
		else
			echo $line >> $file_name
		fi
	done < $file_name_bak

	RESULT=$?
	if [ $RESULT -eq 0 ]; then
		echo ">string replaced successfully"
	else
		mv $file_name_bak $file_name	
	fi
}

press_any_key__localfunc() {
	#Define constants
	local cTIMEOUT_ANYKEY=0

	#Initialize variables
	local keypressed=""
	local tcounter=0

	#Show Press Any Key message with count-down
	echo -e "\r"
	while [[ ${tcounter} -le ${cTIMEOUT_ANYKEY} ]];
	do
		delta_tcounter=$(( ${cTIMEOUT_ANYKEY} - ${tcounter} ))

		echo -e "\rPress (a)bort or any key to continue... (${delta_tcounter}) \c"
		read -N 1 -t 1 -s -r keypressed

		if [[ ! -z "${keypressed}" ]]; then
			if [[ "${keypressed}" == "a" ]] || [[ "${keypressed}" == "A" ]]; then
				exit
			else
				break
			fi
		fi
		
		tcounter=$((tcounter+1))
	done
	echo -e "\r"
}


#---Define path variables
echo -e "\r"
echo "---Defining Varabiles (Filenames, Directories, Paths, Full-Paths)---"
echo -e "\r"
etc_dir=/etc
etc_default_dir=${etc_dir}/default
lib_dir=/lib
usr_dir=/usr
sbin_init_dir=/sbin/init
usr_bin_dir=${usr_dir}/bin
etc_systemd_system_dir=${etc_dir}/systemd/system
etc_systemd_system_multi_user_target_wants_dir=${etc_systemd_system_dir}/multi-user.target.wants

systemd_fpath=${lib_dir}/systemd/systemd
localtime_dir=${etc_dir}/localtime
zoneinfo_dir=${usr_dir}/share/zoneinfo

passwd_fpath=${etc_dir}/passwd
sudo_fpath=${usr_bin_dir}/sudo

sshd_fpath=${etc_dir}/ssh/sshd_config
yaml_fpath=${etc_dir}/netplan/\*.yaml


#---Execute commands
press_any_key__localfunc
echo -e "\r"
echo "---Updates & Upgrades--"
echo -e "\r"
	apt-get update -y
	apt-get upgrade -y
echo -e "\r"


press_any_key__localfunc
echo -e "\r"
echo "---MANDATORY: installing <apt-utils>---"
echo -e "\r"
apt-get install apt-utils -y
echo -e "\r"

press_any_key__localfunc
echo -e "\r"
echo "---MANDATORY: installing <dbus>---"
echo -e "\r"
	apt-get install dbus -y

echo -e "\r"
echo "---MANDATORY: installing <networkd-dispatcher>---"
echo -e "\r"
	echo -e "6\n73" | apt-get install networkd-dispatcher -y

echo -e "\r"
echo "---MANDATORY: installing <systemd>---"
echo -e "\r"
	apt-get install systemd -y

echo -e "\r"
echo ">>>Fixing ERROR: Sub-process ${usr_dir}/bin/dpkg returned an error code (1)"
echo -e "\r"
	apt-get reinstall gconf2
	dpkg-reconfigure gconf2
	dpkg --configure -a
	apt-get install -f


press_any_key__localfunc
echo -e "\r"
echo "---MANDATORY: Creating symlink </sbin/init> pointing to <${lib_dir}/systemd/systemd---"
echo -e "\r"
	ln -s ${systemd_fpath} ${sbin_init_dir}


press_any_key__localfunc
echo -e "\r"
echo "---Installing Network related Tools---"
echo -e "\r"
	apt install iputils-ping -y
	apt-get install net-tools -y
	apt-get install iproute2 iproute2-doc -y
	apt-get install netplan.io -y

echo -e "\r"
echo ">>>Fixing ERROR: Dependency failed for Serial Getty on ttyS0"
echo -e "\r"
	apt-get install udev -y


press_any_key__localfunc
echo -e "\r"
echo "---Installing <openssh-server>---"
echo -e "\r"
	apt-get install openssh-server -y

echo -e "\r"
if [[ -f ${sshd_fpath} ]]; then
	echo ">>>configuring <openssh-server>"
	echo ">>>>>set to allow root login"
		search_str="#PermitRootLogin"
		old_str="#PermitRootLogin prohibit-password"
		new_str="PermitRootLogin yes"
		replace_string_with_another_string__localfunc "${search_str}" "${old_str}" "${new_str}" "${sshd_fpath}"

	echo -e "\r"
	echo ">>>configuring <openssh-server>"
		systemctl restart ssh
else
	echo ">>>File NOT found: ${sshd_fpath}"
	echo ">>>>>Unable to configure <openssh-server>"
fi
echo -e "\r"

press_any_key__localfunc
echo -e "\r"
echo "---Installing <vim, lrzsz, wget, column, less, mlabel>---"
echo -e "\r"
	apt-get install vim -y
	apt-get install wget -y
	apt-get install bsdmainutils -y


echo -e "\r"
echo "---Installing <curl>---"
echo -e "\r"
	apt-get install curl -y

# echo -e "\r"
# echo "---Installing <pmount>---"
# echo ">Will be used to AUTO-DETECT and MOUNT USB-devices"
# echo -e "\r"
# 	apt-get install pmount -y

echo -e "\r"
echo "---Installing <modprobe = kmod>---"
echo -e "\r"
	apt-get install kmod -y

echo -e "\r"
echo "---Installing <iptables>---"
echo -e "\r"
	apt-get install iptables -y

echo -e "\r"
echo "---Applying <modprobe ip_tables>---"
echo -e "\r"
	modprobe ip_tables

echo -e "\r"
echo "---Installing <ufw>---"
echo -e "\r"
	apt-get install ufw -y


press_any_key__localfunc
echo -e "\r"
echo "---Setting DHCP by creating file <${yaml_fpath}>---"
echo -e "\r"
	echo "PLEASE NOTE: it is MANDATORY to right the right amount of SPACES"
	echo "network:" | tee -a ${yaml_fpath}
	echo "  version: 2" | tee -a ${yaml_fpath}
	echo "  renderer: networkd" | tee -a ${yaml_fpath}
	echo "  ethernets:" | tee -a ${yaml_fpath}
	echo "    eth0:" | tee -a ${yaml_fpath}
	echo "      dhcp4: true" | tee -a ${yaml_fpath}
	echo "      dhcp6: true" | tee -a ${yaml_fpath}
	echo "    eth1:" | tee -a ${yaml_fpath}
	echo "      dhcp4: true" | tee -a ${yaml_fpath}
	echo "      dhcp6: true" | tee -a ${yaml_fpath}
echo -e "\r"

echo -e "\r"
echo ">>>Applying <netplan>"
echo -e "\r"
	netplan apply


press_any_key__localfunc
echo -e "\r"
echo "---Update timezone---"
echo -e "\r"
echo ">>>get current location"
echo -e "\r"
	timezone=`curl https://ipapi.co/timezone`
echo -e "\r"
echo ">>>>location is $timezone"
echo -e "\r"
echo ">set timezone to $timezone"
echo -e "\r"
	unlink ${localtime_dir}	#remove symbolic link
	ln -s ${zoneinfo_dir}/$timezone ${localtime_dir}	#create new symbolic link with the updated timezone
echo -e "\r"


press_any_key__localfunc
echo -e "\r"
echo "---Updates & Upgrades (FINAL)--"
echo -e "\r"
	apt-get update -y
	apt-get upgrade -y
echo -e "\r"

