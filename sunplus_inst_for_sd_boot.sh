#!/bin/bash
#---Local Functions
press_any_key__func() {
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
press_any_key__func
echo -e "\r"
echo "---Defining Varabiles (Filenames, Directories, Paths, Full-Paths)---"
echo -e "\r"
config_sh_filename="config.sh"
home_dir=~
LTPP3_ROOTFS_dir=${home_dir}/LTPP3_ROOTFS
LTPP3_ROOTFS_build_scripts_dir=${LTPP3_ROOTFS_dir}/build/scripts
SP7021_dir=${home_dir}/SP7021
SP7021_build_dir=${SP7021_dir}/build
src_config_sh_fpath=${LTPP3_ROOTFS_build_scripts_dir}/${config_sh_filename}
dst_config_sh_fpath=${SP7021_build_dir}/${config_sh_filename}



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
if [[ -d ${SP7021_dir} ]]; then
	echo -e "\r"
	echo "---Removing existing directory: ${SP7021_dir}---"
	echo -e "\r"
	rm -rf ${SP7021_dir}
fi


#---Execute commands
press_any_key__func
echo -e "\r"
echo "---Installing Libraries for Sunplus---"
echo -e "\r"
apt-get install openssl libssl-dev bison flex -y

press_any_key__func
echo -e "\r"
echo "---Cloning Sunplus Image---"
echo -e "\r"
echo ">Git-link: ${CONTAINER_ENV1}"
echo -e "\r"
git clone ${CONTAINER_ENV1}

echo -e "\r"
echo ">Navigating to ${SP7021_dir}"
echo -e "\r"
cd ${SP7021_dir}

echo -e "\r"
echo ">Adding <${SP7021_dir}/boot/uboot/tools> to <PATH>"
echo -e "\r"
echo "export PATH=\$PATH:"${SP7021_dir}/boot/uboot/tools >>  ${home_dir}/.bashrc

#Remove DOUBLE ENTRIES in
echo -e "\r"
echo ">Removing double-entries in <PATH> (if any)"
echo -e "\r"
PATH=`perl -e 'print join ":", grep {!$h{$_}++} split ":", $ENV{PATH}'`
export PATH


press_any_key__func
echo -e "\r"
echo "---Executing script <${home_dir}/.bashrc>---"
echo -e "\r"
source ${home_dir}/.bashrc

press_any_key__func
echo -e "\r"
echo "---Updating submodules with git-command---"
echo -e "\r"

#-------------------------------------------------------------------
# This part is not correct
#-------------------------------------------------------------------
# git submodule update --init --recursive
# git submodule update --remote --merge
# git submodule foreach --recursive git checkout master
# git checkout 03645855a9a533cda7c4324072ef51d1fcfb8f7f
# For example: 
# 	cd linux
# 	git status
# Result:
# 	On branch master
# 	Your branch is up to date with 'origin/master'.
#
# 	nothing to commit, working tree clean	
#-------------------------------------------------------------------

#-------------------------------------------------------------------
# It should be like this (verified with Jim)
#-------------------------------------------------------------------
# For example: 
# 	cd linux
# 	git status
# Result:
# 	HEAD detached at a649d0cc1	<--- This is the commit
# 	nothing to commit, working tree clean
#-------------------------------------------------------------------
echo ">Git-checkout: ${CONTAINER_ENV2}"
echo -e "\r"
git checkout ${CONTAINER_ENV2}
echo ">git submodule update --init --recursive"
echo -e "\r"
git submodule update --init --recursive
echo -e "\r"


#-------------------------------------------------------------------
# This part is implemented to FIX the ISSUE that instead of the CORRECT 
#	DTB-file 'sp7021-ltpp3g2revD.dtb', the WRONG file 
#	'sp7021-ltpp3g2-sunplus.dtb' is created.
# With the consequence that the wrong '/root/SP7021/out/u-boot.img', and
#	thus '/root/SP7021/out/boot2linux_SDcard/u-boot.img' is created.
#-------------------------------------------------------------------
press_any_key__func
echo -e "\r"
echo ">Copy file ${config_sh_filename}"
echo ">>>From: ${LTPP3_ROOTFS_build_scripts_dir}"
echo ">>>To: ${SP7021_build_dir}"
echo -e "\r"
cp ${src_config_sh_fpath} ${dst_config_sh_fpath}; exitcode=$?
if [[ ${exitcode} -ne 0 ]]; then
	exit 99
fi

echo -e "\r"
echo "---Executing: <chmod 755 ${dst_config_sh_fpath}>---"
echo -e "\r"
chmod 755 ${dst_config_sh_fpath}; exitcode=$?
if [[ ${exitcode} -ne 0 ]]; then
	exit 99
fi
#-------------------------------------------------------------------

press_any_key__func
echo -e "\r"
echo ">Navigating to ${SP7021_dir}"
echo -e "\r"
cd ${SP7021_dir}

#-------------------------------------------------------------------
# This part is implemented to be able to BOOT from SD-card
#-------------------------------------------------------------------
echo -e "\r"
echo "---Executing: <echo -e "7\n2\n2" | make config>---"		#select: [7] > [2] > [2]
echo -e "\r"
echo -e "7\n2\n2" | make config; exitcode=$?
if [[ ${exitcode} -ne 0 ]]; then
	exit 99
fi
#-------------------------------------------------------------------

echo -e "\r"
echo "---Executing: <make all>---"
echo -e "\r"
make all; exitcode=$?
if [[ ${exitcode} -ne 0 ]]; then
	exit 99
fi

echo -e "\r"
echo "---Installing dosfstools mtools---"
echo -e "\r"
apt-get install dosfstools mtools -y

echo -e "\r"
echo "---Executing: <make all>---"
echo -e "\r"
make all; exitcode=$?
if [[ ${exitcode} -ne 0 ]]; then
	exit 99
fi
