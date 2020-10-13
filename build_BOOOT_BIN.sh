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


#---Define variables
press_any_key__localfunc
echo -e "\r"
echo "---Defining Varabiles (Filenames, Directories, Paths, Full-Paths)---"
echo -e "\r"
home_dir=~
sunplus_foldername="SP7021"
working_dir=${home_dir}/${sunplus_foldername}

#Navigate to ~/SP7021/
echo -e "\r"
echo ">Navigating to <${working_dir}>"
cd ${working_dir}

#---Adding Entry to PATH
press_any_key__localfunc
echo -e "\r"
echo ">Adding <${working_dir}/boot/uboot/tools> to <PATH>"
echo -e "\r"
echo "export PATH=\$PATH:"${working_dir}/boot/uboot/tools

# #---Remove DOUBLE ENTRIES
# echo -e "\r"
# echo ">Removing double-entries in <PATH> (if any)"
# echo -e "\r"
# PATH=`perl -e 'print join ":", grep {!$h{$_}++} split ":", $ENV{PATH}'`
# export PATH

checkif_matchisFound=`cat ${home_dir}/.bashrc | grep "${tobeExported_entry}"`
if [[ -z "${checkif_matchisFound}" ]]; then
	echo "${tobeExported_entry}" >> ${home_dir}/.bashrc
fi

#---Execute '.bashrc'
echo -e "\r"
echo "---Executing script <${home_dir}/.bashrc>---"
echo -e "\r"
source ${home_dir}/.bashrc

#---Build files
press_any_key__localfunc
echo -e "\r"
echo "---Executing: <make all>---"
echo -e "\r"
sudo env "PATH=$PATH" make all

