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
ntios_su_add_name="ntios-su-add"
ntios_su_addasperand_name="${ntios_su_add_name}@"

bin_dir=/bin
etc_dir=/etc
etc_default_dir=${etc_dir}/default
etc_profile_d_dir=${etc_dir}/profile.d
etc_tibbo_sudo_dir=${etc_dir}/tibbo/sudo
lib_dir=/lib
sbin_dir=/sbin
usr_dir=/usr
bin_systemctl_fpath=${bin_dir}/systemctl
sbin_init_dir=${sbin_dir}/init
usr_bin_dir=${usr_dir}/bin
usr_lib_dir=${usr_dir}/lib
usr_local_bin_dir=${usr_dir}/local/bin
etc_systemd_system_dir=${etc_dir}/systemd/system
etc_systemd_system_multi_user_target_wants_dir=${etc_systemd_system_dir}/multi-user.target.wants

localtime_dir=${etc_dir}/localtime
passwd_fpath=${etc_dir}/passwd
sshd_fpath=${etc_dir}/ssh/sshd_config
sudo_fpath=${usr_bin_dir}/sudo
systemd_fpath=${lib_dir}/systemd/systemd
yaml_fpath=${etc_dir}/netplan/\*.yaml
zoneinfo_dir=${usr_dir}/share/zoneinfo

# enable_eth1_before_login_service_filename="enable-eth1-before-login.service"
# enable_eth1_before_login_service_fpath=${etc_systemd_system_dir}/${enable_eth1_before_login_service_filename}
# enable_eth1_before_login_service_symlink_fpath=${etc_systemd_system_multi_user_target_wants_dir}/${enable_eth1_before_login_service_filename}

# daisychain_state_service_filename="daisychain_state.service"
# daisychain_state_service_fpath=${etc_systemd_system_dir}/${daisychain_state_service_filename}
# daisychain_state_service_symlink_fpath=${etc_systemd_system_multi_user_target_wants_dir}/${daisychain_state_service_filename}

create_chown_pwm_service_filename="create-chown-pwm.service"
create_chown_pwm_service_fpath=${etc_systemd_system_dir}/${create_chown_pwm_service_filename}
create_chown_pwm_service_symlink_fpath=${etc_systemd_system_multi_user_target_wants_dir}/${create_chown_pwm_service_filename}

one_time_exec_before_login_service_filename="one-time-exec-before-login.service"
one_time_exec_before_login_service_fpath=${etc_systemd_system_dir}/${one_time_exec_before_login_service_filename}
one_time_exec_before_login_service_symlink_fpath=${etc_systemd_system_multi_user_target_wants_dir}/${one_time_exec_before_login_service_filename}

enable_ufw_before_login_service_filename="enable-ufw-before-login.service"
enable_ufw_before_login_service_fpath=${etc_systemd_system_dir}/${enable_ufw_before_login_service_filename}
enable_ufw_before_login_service_symlink_fpath=${etc_systemd_system_multi_user_target_wants_dir}/${enable_ufw_before_login_service_filename}

environment_fpath=${etc_dir}/environment

arm_linux_gnueabihf_filename="arm-linux-gnueabihf"
arm_linux_gnueabihf_fpath=${usr_lib_dir}/${arm_linux_gnueabihf_filename}

sudoers_filename="sudoers"
sudoers_fpath=${etc_dir}/${sudoers_filename}

sudoers_org_filename="${sudoers_filename}.org"
sudoers_org_fpath=${etc_tibbo_sudo_dir}/${sudoers_org_filename}

wifipwrmgmt_sh_filename="wifipwrmgmt.sh"
wifipwrmgmt_sh_fpath=${usr_local_bin_dir}/${wifipwrmgmt_sh_filename}

wifipwrmgmt_run_sh_filename="wifipwrmgmt_run.sh"
wifipwrmgmt_run_sh_fpath=${etc_profile_d_dir}/${wifipwrmgmt_run_sh_filename}


#---Define useraccount variables
root_pwd="root"
username="ubuntu"
user_pwd=${username}


#---Execute commands
press_any_key__localfunc
echo -e "\r"
echo "---User-account---"
echo -e "\r"
echo ">changing <root> password"
	echo -e "${root_pwd}\n${root_pwd}" | passwd root
echo -e "\r"
echo ">adding <${username}>"
	adduser --quiet --disabled-password --shell /bin/bash --home /home/${username} --gecos "User" ${username}
echo -e "\r"
echo ">>>changing password of <${username}>"
	echo -e "${user_pwd}\n${user_pwd}" | passwd ${username}

echo -e "\r"
echo ">>>Add <${username}> to group <dip>"
	usermod -a -G dip ubuntu

echo -e "\r"
echo ">>>Create group <gpio>"
	groupadd gpio

echo -e "\r"
echo ">>>>>Add <${username}> to group <gpio>"
	usermod -a -G gpio ubuntu

echo -e "\r"
echo ">>>>>Add <root> to group <gpio>"
	usermod -a -G gpio root	

echo -e "\r"
echo ">>>Create group <gpiod>"
	groupadd gpiod

echo -e "\r"
echo ">>>>>Add <${username}> to group <gpiod>"
	usermod -a -G gpiod ubuntu

echo -e "\r"
echo ">>>>>Add <root> to group <gpiod>"
	usermod -a -G gpiod root	

echo -e "\r"
echo ">>>Add <${username}> to group <dialout>"
	usermod -a -G dialout ubuntu

press_any_key__localfunc
echo -e "\r"
echo "---Updates & Upgrades--"
echo -e "\r"
	apt-get -y update
	apt-get -y upgrade
echo -e "\r"


press_any_key__localfunc
echo -e "\r"
echo "---Install Mandatory Apps"
echo -e "\r"
	apt-get -y install apt-utils
	apt-get -y install sudo

# echo -e "\r"
# echo "---MANDATORY: chown & chmod of files and folders---"
# echo -e "\r"
# ###THE FOLLOWING DOES NOT FIX error messages:
# #	WARN:	uid is 0 but '/etc' is owned by 1000
# echo ">chown root:root ${etc_dir}/"
# 	chown root:root ${etc_dir}/
# ###THE FOLLOWING DOES NOT FIX error messages:
# #	WARN:	/etc is group writablevim .etc.
# echo ">chmod 755 ${etc_dir}/"
# 	chmod 755 ${etc_dir}/

echo -e "\r"
echo "FIX ERROR: WARN: uid is 0 but '/etc/default' is owned by 1000"
echo ">chown root:root ${etc_dir}/default"
	chown root:root ${etc_dir}/default

echo -e "\r"
echo "FIX ERROR: WARN:	uid is 0 but '/lib' is owned by 1000"
echo "FIX ERROR: WARN:	uid is 0 but '/usr/sbin' is owned by 1000"
echo "FIX ERROR: WARN:	uid is 0 but '/usr' is owned by 1000"
echo ">chown root:root ${lib_dir}/"
	chown root:root ${lib_dir}/
echo ">chown root:root ${usr_dir}/"
	chown root:root ${usr_dir}/
echo ">chown root:root ${usr_dir}/sbin"
	chown root:root ${usr_dir}/sbin


echo -e "\r"
echo "FIX ERROR message sudo: /usr/bin/sudo must be owned by uid 0 and have the setuid bit set"
echo ">chown root:root ${sudo_fpath}"
	chown root:root ${sudo_fpath}
echo ">chmod a=rx,u+ws ${sudo_fpath}"
	chmod a=rx,u+ws ${sudo_fpath}


echo -e "\r"
echo ">>>adding user <${username}> to ${etc_dir}/sudoers---"
echo -e "\r"
	echo "" | tee -a ${etc_dir}/sudoers
	echo "#---:MY ADDED SUDOERS:---" | tee -a ${etc_dir}/sudoers
	echo "${username} ALL=(ALL:ALL) ALL" | tee -a ${etc_dir}/sudoers
	echo "${username} ALL=(root) NOPASSWD: ${bin_systemctl_fpath} start ${ntios_su_addasperand_name}*" | tee -a ${etc_dir}/sudoers

if [[ ! -d "${etc_tibbo_sudo_dir}" ]]; then
	echo -e "\r"
	echo -e ">>>Create: ${etc_tibbo_sudo_dir}"
	mkdir -p "${etc_tibbo_sudo_dir}"
fi

echo -e "\r"
echo -e ">>>Copying: ${sudoers_filename}"
echo -e ">As: ${sudoers_org_filename}"
echo -e ">from: ${etc_dir}"
echo -e ">to: ${etc_tibbo_sudo_dir}"
	cp ${sudoers_fpath} ${sudoers_org_fpath}


press_any_key__localfunc
echo -e "\r"
echo "---MANDATORY: installing <dbus>---"
echo -e "\r"
	apt-get -y install dbus

echo -e "\r"
echo "---MANDATORY: installing <networkd-dispatcher>---"
echo -e "\r"
	echo -e "6\n73" | apt-get -y install networkd-dispatcher

echo -e "\r"
echo "---MANDATORY: installing <systemd>---"
echo -e "\r"
	apt-get -y install systemd

echo -e "\r"
echo ">>>Fixing ERROR: Sub-process ${usr_dir}/bin/dpkg returned an error code (1)"
echo -e "\r"
	apt-get reinstall gconf2
	dpkg-reconfigure gconf2
	dpkg --configure -a
	apt-get -y install -f


press_any_key__localfunc
echo -e "\r"
echo "---MANDATORY: Creating symlink </sbin/init> pointing to <${lib_dir}/systemd/systemd---"
echo -e "\r"
	ln -s ${systemd_fpath} ${sbin_init_dir}


press_any_key__localfunc
echo -e "\r"
echo "---Installing Network related Tools---"
echo -e "\r"
	apt-get -y install iputils-ping
	apt-get -y install net-tools
	apt-get -y install iproute2 iproute2-doc
	apt-get -y install netplan.io
	apt-get -y install traceroute

echo -e "\r"
echo ">>>Fixing ERROR: Dependency failed for Serial Getty on ttyS0"
echo -e "\r"
	apt-get -y install udev


press_any_key__localfunc
echo -e "\r"
echo "---Installing <openssh-server>---"
echo -e "\r"
	apt-get -y install openssh-server

# echo -e "\r"
# if [[ -f ${sshd_fpath} ]]; then
# 	echo ">>>configuring <openssh-server>"
# 	echo ">>>>>set to allow root login"
# 		search_str="#PermitRootLogin"
# 		old_str="#PermitRootLogin prohibit-password"
# 		new_str="PermitRootLogin yes"
# 		replace_string_with_another_string__localfunc "${search_str}" "${old_str}" "${new_str}" "${sshd_fpath}"

# 	echo -e "\r"
# 	echo ">>>configuring <openssh-server>"
# 		systemctl restart ssh
# else
# 	echo ">>>File NOT found: ${sshd_fpath}"
# 	echo ">>>>>Unable to configure <openssh-server>"
# fi
# echo -e "\r"


# press_any_key__localfunc
# echo -e "\r"
# echo "---Creating /home/ubuntu/.ssh---"
# 	mkdir /home/ubuntu/.ssh

# echo -e "\r"
# echo "---Generating ssh-key---"
# echo -e "\r"
# 	ssh-keygen -t rsa -f /home/ubuntu/.ssh/id_rsa -q -P ""


press_any_key__localfunc
echo -e "\r"
echo "---Installing <Additional software>---"
echo -e "\r"
	apt-get -y install dialog
	apt-get -y install vim
 	apt-get -y install nano
	apt-get -y install lrzsz
	apt-get -y install wget
	apt-get -y install less
	apt-get -y install mtools
	apt-get -y install bsdmainutils
	apt-get -y install git
	apt-get -y install expect
	apt-get -y install software-properties-common
	apt-get -y install build-essential
	apt-get -y install gdbserver
	apt-get -y install libgpiod-dev
	apt-get -y install gpiod

echo -e "\r"
echo "---Installing <curl>---"
echo -e "\r"
	apt-get -y install curl

echo -e "\r"
echo "---Installing <gnupg>---"
echo -e "\r"
	apt-get -y install gnupg

echo "---Configure <PPA>---"
echo -e "\r"
echo ">Add Tibbo-PPA-Key"
	curl -s --compressed "https://tibbotech.github.io/ltpp3g2_ppa/ppa/KEY.gpg" | apt-key add -

echo -e "\r"
echo ">Add Tibbo-PPA to 'sources.list'"
	curl -s --compressed -o /etc/apt/sources.list.d/my_list_file.list "https://tibbotech.github.io/ltpp3g2_ppa/u0_6_0/my_list_file.list"

echo -e "\r"
echo ">Installing update"
echo -e "\r"
	apt-get -y update

#echo -e "\r"
#echo "---Installing <tibbo-oobe>---"
#echo -e "\r"
#	apt-get -y install tibbo-oobe

# echo -e "\r"
# echo "---Installing <pmount>---"
# echo ">Will be used to AUTO-DETECT and MOUNT USB-devices"
# echo -e "\r"
# 	apt-get -y install pmount

echo -e "\r"
echo "---Installing <modprobe = kmod>---"
echo -e "\r"
	apt-get -y install kmod

echo -e "\r"
echo "---Installing <iptables>---"
echo -e "\r"
	apt-get -y install iptables

echo -e "\r"
echo "---Applying <modprobe ip_tables>---"
echo -e "\r"
	modprobe ip_tables

echo -e "\r"
echo "---Installing <ufw>---"
echo -e "\r"
	apt-get -y install ufw

echo -e "\r"
echo "---Configuring <ufw-rules>---"
echo "Allow:"
echo -e "\tFTP (TCP: 20,21)"
echo -e "\tSSH (TCP: 22)"
echo -e "\tHTTP (TCP: 80)"
echo -e "\tHTTP (TCP: 8080)"
# echo -e "\tHTTPS (TCP: 443)"
# echo -e "\tSoftEther (TCP: 992)"
# echo -e "\tSoftEther (TCP: 5555)"
# echo -e "\tOpenVPN (TCP: 1194)"
echo -e "\r"
	ufw allow 20
	ufw allow 21
	ufw allow 22
	ufw allow 53
	ufw allow 67
	ufw allow 68
	ufw allow 80
	ufw allow 8080
	ufw allow 443
	ufw allow 547
	# ufw allow 992
	# ufw allow 5555
	# ufw allow 1194

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
echo "---Installing Locales---"
echo -e "\r"
	apt-get -y install locales


echo ">>>Fixing ERROR: regarding locales (this might take a while...)"
echo -e "\r"
	echo "en_US.UTF-8" | tee -a /etc/locale.gen
	locale-gen en_US.UTF-8
	dpkg-reconfigure --frontend noninteractive locales


echo -e "\r"
echo "---Update Environment Variables---"
	PATH=$PATH:${arm_linux_gnueabihf_fpath}	#update 'PATH'
	export PATH	#export variable
	sed -i "/PATH/d" /etc/environment	#remove line containing pattern 'PATH'
	echo -e "PATH=\"${PATH}\"" >>  ${environment_fpath}	#add new line


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
echo "---Enable Services---"
# echo -e "\r"
# echo ">Create symlink for <${enable_eth1_before_login_service_filename}>"
# 	ln -s ${enable_eth1_before_login_service_fpath} ${enable_eth1_before_login_service_symlink_fpath}

# echo -e "\r"
# echo ">Create symlink for <${daisychain_state_service_filename}>"
# 	ln -s ${daisychain_state_service_fpath} ${daisychain_state_service_symlink_fpath}

echo -e "\r"
echo ">Create symlink for <${create_chown_pwm_service_filename}>"
	ln -s ${create_chown_pwm_service_fpath} ${create_chown_pwm_service_symlink_fpath}

echo -e "\r"
echo ">Create symlink for <${one_time_exec_before_login_service_filename}>"
	ln -s ${one_time_exec_before_login_service_fpath} ${one_time_exec_before_login_service_symlink_fpath}

echo -e "\r"
echo ">Create symlink for <${enable_ufw_before_login_service_filename}>"
	ln -s ${enable_ufw_before_login_service_fpath} ${enable_ufw_before_login_service_symlink_fpath}

echo -e "\r"


press_any_key__localfunc
echo -e "\r"
echo ">Reloading udev-rules..."
	udevadm control --reload-rules
echo -e "\r"
echo ">Reloading Daemon..."
	systemctl daemon-reload	
echo -e "\r"


press_any_key__localfunc
echo -e "\r"
echo "---Updates & Upgrades (FINAL)--"
echo -e "\r"
	apt-get -y update
	apt-get -y upgrade
echo -e "\r"
