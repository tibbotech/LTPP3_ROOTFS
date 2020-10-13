#!/bin/bash
#--------------------------------------------------------------------
# This script should be copied into /usr/local/bin
# Dependencies:
#   /etc/udev/rules.d/detect.rules
#   /etc/systemd/system/sd-detect@.service
#--------------------------------------------------------------------
# This script is run AFTER 'sd-detect@.service'
#--------------------------------------------------------------------
# REMARK: this script is written based on 'usb-mount.sh'
#--------------------------------------------------------------------
#---Define variables
etc_dir=/etc
dev_dir=/dev
usr_dir=/usr
bin_dir=/bin
media_dir=/media
sbin_dir=/sbin
usr_bin_dir=${usr_dir}/bin
usr_local_bin_dir=${usr_dir}/local/bin

regex_pattern="mmcblk*p*"


#---Input arg
DEVPART=${1}
DEVFULLPATH="${dev_dir}/${DEVPART}"


#---Local functions
usage_sub() 
{
	echo -e "\r"
    echo "Usage: $0 <dev_id> (e.g. mmcblk1p1)"
	echo -e "\r"
	
    exit 1
}

function get_MEDIAFULLPATH__func() {
	#---------------------------------------------------------------#
	# 	Check if this ${mediafullpath} (e.g. /media/HIEN_E) can be	 	#
	# found in /etc/mtab.											#
	# 	if ${mediafullpath} does exist, then check whether				#
	# ${mtab_devfullpath} matches with ${devfullpath}						#
	# 	If NO match, then it means that the mounted devfullpath 		#
	# (e.g. /dev/sda1) is not ACTIVE, and thus can be UNmounted		#
	#	and Removed													#
	#---------------------------------------------------------------#
	#Input args
    local mediapart=${1}

    #In case 'mediapart' is an empty string
    #It means that the Micro-SD card does NOT have a label
    if [[ -z ${mediapart} ]]; then
    #    mediapart="${DEVPART}"
        mediapart="MMC_DRIVE"
    fi

	#Using the Mount information, get ${mtab_devfullpath} (e.g. /dev/sda1) which is stored in /etc/mtab
    local mediafullpath=${media_dir}/${mediapart}	#redefine variable, but now with seqnum
	local mtab_devfullpath=`cat ${etc_dir}/mtab | grep -w "${mediafullpath}" | cut -d " " -f1`	#grep EXACT match

	if [[ ! -z ${mtab_devfullpath} ]]; then	#only continue if ${mtab_devfullpath} is NOT an empty string
		#Rename 'mediapart', because '${mediafullpath}' was found in /etc/mtab
		local seqnum=0
		while true
		do
			mediapart="${mediapart}_${seqnum}"	#redefine variable, but now with seqnum
			mediafullpath=${media_dir}/${mediapart}	#redefine variable, but now with seqnum

			mediafullpath_isFound=`cat ${etc_dir}/mtab | grep "${mediafullpath}" | cut -d " " -f1`
			#Only continue if ${mtab_devfullpath} is an empty string...
			#	...this would mean that '${mediafullpath}' has not been used yet as a mount-point
			if [[ -z ${mediafullpath_isFound} ]]; then
				break
			else
				seqnum=$((seqnum + 1))
			fi
		done
	fi

	#OUTPUT
	echo ${mediafullpath}
}

remove_unused_mountpoints__sub() {
	#---------------------------------------------------------------#
	# 	Delete all empty folders in directory /media that aren't 	#
	# being used as mount points. 									#
	# 	If the drive was unmounted prior to removal we no longer	#
	# know its mount point, and we don't want to leave it orphaned.	#
	#---------------------------------------------------------------#
	#Define variables
	mediafullpath_array=${media_dir}/*	#note: mediafullpath_array is an ARRAY containing mediafullpaths

	for mediafullpath_arrayitem in ${mediafullpath_array}	#note: mediafullpath_arrayitem is the same as 'mediafullpath'
	do
		#Using the Mount information, get ${mtab_devfullpath} (e.g. /dev/sda1) which is stored in /etc/mtab
		mtab_devfullpath=`cat ${etc_dir}/mtab | grep "${mediafullpath_arrayitem}" | cut -d " " -f1`

		if [[ -z ${mtab_devfullpath} ]]; then	#no match was found for '${mediafullpath_arrayitem}
			if [[ -d "$mediafullpath_arrayitem" ]]; then
				#${usr_bin_dir}/umount -l ${mediafullpath_arrayitem}	#unmount with forcibly removing entry in /etc/mtab

				${usr_bin_dir}/umount ${mediafullpath_arrayitem}	#unmount

				${usr_bin_dir}/rm -r ${mediafullpath_arrayitem}	#remove
			fi
		else
			#Get info for the ${devfullpath}
			ID_FS_LABEL=""	#initialize variable (IMPORTANT)
			eval $(${sbin_dir}/blkid -o udev ${mtab_devfullpath})
			mediapart=${ID_FS_LABEL}

			if [[ -z ${mediapart} ]]; then	#In case no info is found, then umount & remove the ${mediafullpath}
				#${usr_bin_dir}/umount -l ${mediafullpath_arrayitem}	#unmount with forcibly removing entry in /etc/mtab

				${usr_bin_dir}/umount ${mediafullpath_arrayitem}	#unmount

				${usr_bin_dir}/rm -r ${mediafullpath_arrayitem}	#remove
			fi
		fi
	done
}

do_Mount_sub()
{
	#Remove unused mointpoints
	remove_unused_mountpoints__sub

    #Get info for this drive: $ID_FS_LABEL, $ID_FS_UUID, and $ID_FS_TYPE
	ID_FS_LABEL=""	#initialize variable (IMPORTANT)
    eval $(${sbin_dir}/blkid -o udev ${DEVFULLPATH})
	MEDIAPART=${ID_FS_LABEL}
	
	#Get MEDIAFULLPATH
	#MEDIAFULLPATH=${media_dir}/${MEDIAPART}
	MEDIAFULLPATH=`get_MEDIAFULLPATH__func "${MEDIAPART}"`



	#Create folder ${MEDIAPART}
	if [[ ! -d ${MEDIAFULLPATH} ]]; then
		mkdir -p ${MEDIAFULLPATH}
	fi

	#Mount DEVFULLPATH (e.g. /dev/sda1) to an available MOUNTPOINT (e.g. /media/HIEN_E)
	${usr_bin_dir}/mount -t vfat -o rw,users,umask=000,exec ${DEVFULLPATH} ${MEDIAFULLPATH}

	#Get permission of directory
	MEDIAFULLPATH_permission=`ls -ld ${MEDIAFULLPATH} | cut -d" " -f1`

	echo -e "\r"
	echo -e "\r"
	echo -e "*********************************************************"
	echo -e "* Mounted MMC:\t\t${DEVFULLPATH}"
	echo -e "* To mount-point:\t${MEDIAFULLPATH}"
	echo -e "* Permission:\t\t${MEDIAFULLPATH_permission}"
	echo -e "*********************************************************"
	echo -e "\r"
	echo -e "\r"
}

#---Show message
echo -e "\r"
echo -e "\r"
echo -e "*********************************************************"
echo -e "* $(date +%Y/%m/%d-%H:%M:%S): Detected MMC <${DEVPART}>"
echo -e "*********************************************************"
echo -e "\r"


#---Check input args
if [[ $# -ne 1 ]]; then	#input args is not equal to 2 
    usage_sub
else
    if [[ ${1} != ${regex_pattern} ]]; then	#only allow the following keys to be pressed 'sd'
		usage_sub
	fi
fi


#---Mount MMC SD-card
do_Mount_sub