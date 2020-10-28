#!/bin/bash
#---Define variables
cNO="n"
CYES="y"

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
				echo -e "\r"
				echo -e "\r"
				
				exit
			else
				break
			fi
		fi
		
		tcounter=$((tcounter+1))
	done
	echo -e "\r"
}

make_your_choice__localfunc() {
	#Input args
	local myoption_default=${1}

	#Define constants
	local cTIMEOUT_ANYKEY=10

	#Initialize variables
	local tcounter=0

	#Show Press Any Key message with count-down
	echo -e "\r"
	while [[ ${tcounter} -le ${cTIMEOUT_ANYKEY} ]];
	do
		delta_tcounter=$(( ${cTIMEOUT_ANYKEY} - ${tcounter} ))

		echo -e "\rPress (y)es/(n)o OR (a)bort... (${delta_tcounter}) \c"
		read -N 1 -t 1 -s -r myoption

		if [[ ! -z "${myoption}" ]]; then
			if [[ "${myoption}" == "a" ]] || [[ "${myoption}" == "A" ]]; then
				echo -e "\r"
				echo -e "\r"

				exit
			else
				if [[ "${myoption}" =~ [y,Y,n,N] ]]; then
					break
				fi
			fi
		fi
		
		tcounter=$((tcounter+1))
	done
	echo -e "\r"

	#In case no choice was made (myoption="")
	if [[ -z "${myoption}" ]]; then
		myoption=${myoption_default}
		echo -e "\r"
	fi
}


#---Define Path Variables
home_dir=~
Downloads_dir=${home_dir}/Downloads
scripts_dir=${home_dir}/scripts
sunplus_foldername="SP7021"
sunplus_dir=${home_dir}/${sunplus_foldername}
initramfs_dir=${sunplus_dir}/linux/rootfs/initramfs
disk_foldername="disk"
Downloads_disk_dir=${Downloads_dir}/${disk_foldername}
disk_dir=${initramfs_dir}/${disk_foldername}
disk_sunplus_targz_filename="disk_sunplus.tar.gz"
scripts_disk_sunplus_targz_fpath=${scripts_dir}/${disk_sunplus_targz_filename}
initramfs_disk_sunplus_targz_fpath=${initramfs_dir}/${disk_sunplus_targz_filename}



#---Executing commands
if [[ -d ${disk_dir} ]]; then
	if [[ -d "${Downloads_disk_dir}" ]]; then
		echo -e "\r"
		echo "***WARNING: Folder <${disk_foldername}> already exists at location <${Downloads_dir}>"
		echo -e "\r"
		echo ">>>Rename folder and continue (y/n)"
			make_your_choice__localfunc ${CYES}

		if [[ "${myoption}" == "n" ]] || [[ "${myoption}" == "N" ]]; then
			echo -e "\r"
			echo ">>>Please take action and..." 
			echo ">>>re-run this script again"
			echo ">>>Exiting Now..."
			echo -e "\r"
		else
				disk_tspan=$(date +%Y%m%d%H%M%S)
				disk_ren_foldername="${disk_foldername}.${disk_tspan}"
				Downloads_disk_ren_dir=${Downloads_dir}/${disk_ren_foldername}
			echo -e "\r"
			echo ">>>Renaming folder: ${disk_foldername}"
			echo ">>>to: ${disk_ren_foldername}"
			echo ">>>in: ${Downloads_dir}"
				sudo mv ${Downloads_disk_dir} ${Downloads_disk_ren_dir}
		fi		
	fi

	echo -e "\r"
	echo ">Moving: ${disk_foldername}"
	echo ">from: ${initramfs_dir}"
	echo ">to: ${Downloads_dir}"
		sudo mv ${disk_dir} ${Downloads_dir}/

	echo -e "\r"
	echo ">Navigate to ${Downloads_dir}"
		cd ${Downloads_dir}

	echo -e "\r"
	echo ">Would you like to backup the <disk> folder?"
	make_your_choice__localfunc ${cNO}

	if [[ "${myoption}" == "y" ]] || [[ "${myoption}" == "Y" ]]; then
			disk_tspan=$(date +%Y%m%d%H%M%S)
			disk_targz_filename="disk.revertphase.${disk_tspan}.tar.gz"
		echo -e "\r"
		echo ">>>Backing up: ${disk_foldername}"
		echo ">>>as: ${disk_targz_filename}"
		echo ">>>in: ${Downloads_dir}"
			sudo tar -czvf ${disk_targz_filename} ${disk_foldername}
	fi

	echo -e "\r"
	echo ">Removing: ${disk_foldername}"
	echo ">in: ${Downloads_dir}"
		sudo rm -rf ${Downloads_disk_dir}
else
    echo "---INFO: Directory not found <${disk_dir}>---"
fi
echo -e "\r"


press_any_key__localfunc
echo -e "\r"
if [[ -f ${scripts_disk_sunplus_targz_fpath} ]]; then
    echo "---Unpacking <${scripts_disk_sunplus_targz_fpath}> to <${initramfs_dir}>---"
    sudo tar -C ${initramfs_dir} -xzvf ${scripts_disk_sunplus_targz_fpath}

else
    echo "---ERROR: File not found <${scripts_disk_sunplus_targz_fpath}>---"
    echo ">Exiting Now..."

    exit
fi
echo -e "\r"
