#!/bin/bash
#---PATHS
tpd_ko_filename="tpd.ko"
src_tpd_dir="/root/SP7021/linux/kernel/drivers/tpd"
src_tpd_ko_fpath="${src_tpd_dir}/${tpd_ko_filename}"
dst_tpd_dir="/root/SP7021/linux/rootfs/initramfs/disk/usr/lib/modules/5.10.59-yocto-standard-ge78cbd8c7cbb-dirty/kernel/tpd"



#---MAIN
if [ ! -d "${dst_tpd_dir}" ]; then
    mkdir -p "${dst_tpd_dir}"
fi
cp "${src_tpd_ko_fpath}" "${dst_tpd_dir}"
