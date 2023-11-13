#!/bin/bash
#---CONSTANTS
WAITTIME=5  #in seconds
DIVIDER=60  #in seconds

PATTERN_SLASH_MEDIA="/media"

PRINT_ERROR="***ERROR"

DEV_SDA1=/dev/sda1
DEV_SDB1=/dev/sdb1
DEV_MMCBLK1P1=/dev/mmcblk1p1

tmp_dir=/tmp
dummy_txt_filename=".dummy.txt"
media_sync_tmp_filename="media_sync.tmp"
media_sync_tmp_fpath=${tmp_dir}/${media_sync_tmp_filename}



#---SUBROUTINES
sync_media_folders__sub() {
    local media_folders_arr=()
    local media_folders_arritem=""
    local dummy_txt_fpath=""
    local errmsg=""

    readarray -t media_folders_arr < <(mount | grep -o "${PATTERN_SLASH_MEDIA}.*" | awk '{print $1}')

    for media_folders_arritem in "${media_folders_arr[@]}"
    do
        dummy_txt_fpath="${media_folders_arritem}/${dummy_txt_filename}"

        if [[ -f "${dummy_txt_fpath}" ]]; then
            rm "${dummy_txt_fpath}"
        fi

        if [[ -f "${media_sync_tmp_fpath}" ]]; then
            rm "${media_sync_tmp_fpath}"
        fi

        touch "${dummy_txt_fpath}" 2> "${media_sync_tmp_fpath}"

        #Note: if 'media_sync_tmp_fpath' contains data, then an error had occurred
        if [[ -s "${media_sync_tmp_fpath}" ]]; then
            errmsg="\n"
            errmsg+="${PRINT_ERROR}: The above error occurs, because currently you are...\n"
            errmsg+="${PRINT_ERROR}: ...in an UNMOUNTED folder '${media_folders_arritem}'.\n"
            errmsg+="${PRINT_ERROR}: Please LEAVE this folder immediately!\n"

            echo -e "${errmsg}"

            umount "${media_folders_arritem}" 2> /dev/null

            rm -rf "${media_folders_arritem}" 2> /dev/null
        else
            #Convert 5 seconds into minutes
            #Note:
            #   This can be simply done by dividing '5' by '60'.
            #   The result 'find_past_x_seconds' is time-period which will be used by 'find'
            #       to check for the files and folders which have been created/modified within
            #       the past '5' seconds
            waittime_min=$(awk "BEGIN { printf \"%.5f\", ${WAITTIME} / ${DIVIDER} }")

            #Check if any FILES has been created/modified
            #Note: files which have been deleted will not be detected
            modified_file=$(find "${media_folders_arritem}" -type f -mmin -${waittime_min} 2> /dev/null)

            #Check if any FOLDERS has been created/modified
            #Note: FOLDERS which have been deleted will not be detected
            modified_folder=$(find "${media_folders_arritem}" -type d -mmin -${waittime_min} 2> /dev/null)

            if [[ -n "${modified_file}" ]] && [[ "${modified_file}" != "${dummy_txt_fpath}" ]]; then
                sync
            fi

            if [[ -n "${modified_folder}" ]]; then
                sync     
            fi
        fi


        if [[ -f "${dummy_txt_fpath}" ]]; then
            rm "${dummy_txt_fpath}"
        fi

        if [[ -f "${media_sync_tmp_fpath}" ]]; then
            rm "${media_sync_tmp_fpath}"
        fi
    done

}



#---MAIN
main__sub() {
    sync_media_folders__sub
}



#---EXECUTE MAIN
main__sub