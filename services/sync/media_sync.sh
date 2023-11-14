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
media_sync_tmp_filename="media_sync.tmp"
media_sync_tmp_fpath=${tmp_dir}/${media_sync_tmp_filename}



#---SUBROUTINES
sync_media_folders__sub() {
    local media_folders_arr=()
    local media_folders_arritem=""
    local errmsg=""

    readarray -t media_folders_arr < <(mount | grep -o "${PATTERN_SLASH_MEDIA}.*" | awk '{print $1}')

    for media_folders_arritem in "${media_folders_arr[@]}"
    do
        if [[ -f "${media_sync_tmp_fpath}" ]]; then
            rm "${media_sync_tmp_fpath}"
        fi

        sync ${media_folders_arritem} 2> "${media_sync_tmp_fpath}"
        # touch "${dummy_txt_fpath}" 2> "${media_sync_tmp_fpath}"
        
        #Note: if 'media_sync_tmp_fpath' contains data, then an error had occurred
        if [[ -s "${media_sync_tmp_fpath}" ]]; then
            errmsg="\n"
            errmsg+="${PRINT_ERROR}: The above error occurs, because currently you are...\n"
            errmsg+="${PRINT_ERROR}: ...in an UNMOUNTED folder '${media_folders_arritem}'.\n"
            errmsg+="${PRINT_ERROR}: Please LEAVE this folder immediately!\n"

            echo -e "${errmsg}"

            umount "${media_folders_arritem}" 2> /dev/null

            rm -rf "${media_folders_arritem}" 2> /dev/null
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