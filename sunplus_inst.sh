#!/bin/bash
#---Local Functions
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


#---Check if currently NOT logged in as "root"
echo -e "\r"
echo "---Checking current user---"
echo -e "\r"
current_user=`whoami`

if [[ ${current_user} == "root" ]]; then
	echo -e "\r"
	echo ">Current user is <root>..."
	echo ">>>Please login as a normal user (e.g. imcase)"
	echo -e "\r"
	echo "Exiting Now..."
	echo -e "\r"
	echo -e "\r"

	exit
fi


#---Define path variables
press_any_key__localfunc
echo -e "\r"
echo "---Defining Varabiles (Filenames, Directories, Paths, Full-Paths)---"
echo -e "\r"
home_dir=~
etc_dir=/etc
home_scripts_dir=${home_dir}/scripts
Downloads_dir=${home_dir}/Downloads
sunplus_foldername="SP7021"
work_dir=${home_dir}/${sunplus_foldername}
initramfs_dir=${work_dir}/linux/rootfs/initramfs
extra_dir=${initramfs_dir}/extra
extra_etc_dir=${extra_dir}${etc_dir}
build_disk_filename="build_disk.sh"
build_disk_bck_filename=${build_disk_filename}.bak
build_disk_mod_filename=${build_disk_filename}.mod
build_disk_fpath=${initramfs_dir}/${build_disk_filename} 
build_disk_bck_fpath=${initramfs_dir}/${build_disk_bck_filename} 
build_disk_mod_fpath=${home_scripts_dir}/${build_disk_mod_filename} 


#---Check if current working directory
echo -e "\r"
echo "---Checking current working directory---"
echo -e "\r"
current_working_dir=`pwd`

if [[ ${current_working_dir} != ${home_dir} ]]; then
	echo -e "\r"
	echo ">Current working directory is <${current_working_dir}>..."
	echo ">>>Please navigate to <${home_dir}>..."
	echo ">>>...And execute script again."
	echo -e "\r"
	echo "Exiting Now..."
	echo -e "\r"
	echo -e "\r"

    exit
fi


#---Check if Sunplus is already installed
if [[ -d ${work_dir} ]]; then
    echo -e "\r"
    echo "---WARNING: Sunplus already installed---"
    echo "Location: ${work_dir}"
    echo -e "\r"

    exit
fi


#---Execute commands
press_any_key__localfunc
echo -e "\r"
echo "---Installing Libraries for Sunplus---"
echo -e "\r"
sudo apt-get install openssl libssl-dev bison flex -y

press_any_key__localfunc
echo -e "\r"
echo "---Cloning Sunplus Image (in other words: writing data to local disk)---"
echo -e "\r"
git clone https://github.com/sunplus-plus1/SP7021.git

echo -e "\r"
echo ">Navigating to ${work_dir}"
echo -e "\r"
cd ${work_dir}

echo -e "\r"
echo ">Adding <${working_dir}/boot/uboot/tools> to <PATH>"
echo -e "\r"
echo "export PATH=\$PATH:"${work_dir}/boot/uboot/tools >>  ${home_dir}/.bashrc

#Remove DOUBLE ENTRIES in
echo -e "\r"
echo ">Removing double-entries in <PATH> (if any)"
echo -e "\r"
PATH=`perl -e 'print join ":", grep {!$h{$_}++} split ":", $ENV{PATH}'`
export PATH


press_any_key__localfunc
echo -e "\r"
echo "---Executing script <${home_dir}/.bashrc>---"
echo -e "\r"
source ${home_dir}/.bashrc

press_any_key__localfunc
echo -e "\r"
echo "---Updating submodules with git-command---"
echo -e "\r"
git submodule update --init --recursive
git submodule update --remote --merge
git submodule foreach --recursive git checkout master

echo -e "\r"
echo ">Navigating to ${work_dir}"
echo -e "\r"
cd ${work_dir}

press_any_key__localfunc
echo -e "\r"
echo "---Executing: <make config <<< 2>---"
echo -e "\r"
make config <<< 2 		#Select: [2] LTPP3G2 Board

press_any_key__localfunc
echo -e "\r"
echo "---Executing: <make all>---"
echo -e "\r"
make all

#Note: The defconfig of LTPP3G2 is composite by many modules, 
#the content is vary from modules to modules. So if you want to build it, 
#please be sure you have deconfig that you are using and 
#to replace linux/kernel/arch/arm/configs/sp7021_chipC_ltpp3g2_defconfig


###FIX error messages:
#	WARN:	uid is 0 but '/etc' is owned by 1000
echo -e "\r"
echo ">chown root:root ${etc_dir}"
echo ">in: ${extra_dir}"
	sudo chown root:root ${extra_etc_dir}

	
###FIX error messages:
#	WARN:	/etc is group writable
echo -e "\r"
echo ">chmod 755 ${etc_dir}"
echo ">in: ${extra_dir}"
	sudo chmod 755 ${extra_etc_dir}


#Rename "build_disk.sh" to "build_disk.sh.bak"
press_any_key__localfunc
echo -e "\r"
echo ">Renaming ${build_disk_filename}" 
echo -e "to: ${build_disk_bck_filename}"
echo -e "in: ${initramfs_dir}"
echo -e "\r"
sudo mv ${build_disk_fpath} ${build_disk_bck_fpath}


#Copy modified file to location: ~/SP7021/linux/rootfs/initramfs
press_any_key__localfunc
echo -e "\r"
echo ">Copying ${build_disk_mod_filename}" 
echo -e "as: ${build_disk_filename}"
echo -e "from: ${home_scripts_dir}"
echo -e "to: ${initramfs_dir}"
echo -e "\r"
sudo cp ${build_disk_mod_fpath}  ${build_disk_fpath}


#Make file "build_disk.sh" executable
press_any_key__localfunc
echo -e "\r"
echo ">Changing permission of ${build_disk_filename}"
echo -e "in: ${initramfs_dir}"
echo -e "\r"
sudo chmod +x ${build_disk_fpath}
