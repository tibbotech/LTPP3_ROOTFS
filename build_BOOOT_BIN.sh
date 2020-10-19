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


#---Define variables
press_any_key__localfunc
echo -e "\r"
echo -e "---Defining Varabiles (Filenames, Directories, Paths, Full-Paths)---"
echo -e "\r"
home_dir=~
SP7xxx_foldername="SP7021"
SP7xxx_dir=${home_dir}/${SP7xxx_foldername}

#Navigate to ~/SP7021/
echo -e "\r"
echo -e ">Navigating to <${SP7xxx_dir}>"
cd ${SP7xxx_dir}

#---Adding Entry to PATH
press_any_key__localfunc
#Define environment variable
SP7xxx_boot_uboot_tools_dir=${SP7xxx_dir}/boot/uboot/tools

echo -e "\r"
echo -e ">Adding <${SP7xxx_boot_uboot_tools_dir} to <PATH>"
echo -e "\r"
echo -e "export PATH=\$PATH:${SP7xxx_boot_uboot_tools_dir}"

# #---Remove DOUBLE ENTRIES
# echo -e "\r"
# echo -e ">Removing double-entries in <PATH> (if any)"
# echo -e "\r"
# PATH=`perl -e 'print join ":", grep {!$h{$_}++} split ":", $ENV{PATH}'`
# export PATH

checkif_matchisFound=`cat ${home_dir}/.bashrc | grep "${SP7xxx_boot_uboot_tools_dir}"`
if [[ -z "${checkif_matchisFound}" ]]; then
	echo -e "export PATH=\$PATH:${SP7xxx_boot_uboot_tools_dir}" >> ${home_dir}/.bashrc
fi

#---Execute '.bashrc'
echo -e "\r"
echo -e "---Executing script <${home_dir}/.bashrc>---"
echo -e "\r"
source ${home_dir}/.bashrc

#---Build files
press_any_key__localfunc
echo -e "\r"
echo -e "---Executing: <make all>---"
echo -e "\r"
env "PATH=$PATH" make all