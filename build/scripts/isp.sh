TOP=../

export PATH=$PATH:$TOP/build/tools/isp/

X=xboot.img
U=u-boot.img
K=uImage
ROOTFS=rootfs.img
D=dtb


# Partition name = file name
cp $X xboot0
cp $U uboot0
cp $X xboot1
cp $U uboot1
cp $U uboot2
cp $K kernel

touch reserve

if [ "$1" != "SDCARD" ]; then
	cp $ROOTFS rootfs
fi
cp $D DTB

# Note:
#     If partitions' sizes listed before "kernel" are changed,
#     please make sure U-Boot settings of CONFIG_ENV_OFFSET, CONFIG_ENV_SIZE, CONFIG_SRCADDR_KERNEL and CONFIG_SRCADDR_DTB
#     are changed accordingly.
for ADDR in "CONFIG_ENV_OFFSET" "CONFIG_ENV_SIZE" "CONFIG_SRCADDR_DTB" "CONFIG_SRCADDR_KERNEL"
do
	cat ${TOP}boot/uboot/.config | grep --color -e ${ADDR}
done

if [ "$1" = "EMMC" ]; then
	isp pack_image ISPBOOOT.BIN \
		xboot0 uboot0 \
		xboot1 0x100000 \
		uboot1 0x100000 \
		uboot2 0x100000 \
		env 0x80000 \
		env_redund 0x80000 \
		reserve 0x100000 \
		dtb 0x40000 \
		kernel 0x2000000 \
		rootfs 0x1e0000000
elif [ "$1" = "NAND" ]; then
	isp pack_image ISPBOOOT.BIN \
		xboot0 uboot0 \
		xboot1 0x100000 \
		uboot1 0x100000 \
		uboot2 0x100000 \
		env 0x80000 \
		env_redund 0x80000 \
		reserve 0x100000 \
		dtb 0x40000 \
		kernel 0x1900000 \
		rootfs 0xe000000
elif [ "$1" = "PNAND" ]; then
	isp pack_image ISPBOOOT.BIN \
		xboot0 uboot0 \
		xboot1 0x100000 \
		uboot1 0x100000 \
		uboot2 0x100000 \
		env 0x80000 \
		env_redund 0x80000 \
		reserve 0x100000 \
		dtb 0x40000 \
		kernel 0x1900000 \
		rootfs 0xe000000
elif [ "$1" = "USB" ]; then
	isp pack_image ISPBOOOT.BIN \
		xboot0 uboot0 \
		xboot1 0x100000 \
		uboot1 0x100000 \
		reserve 0x100000 \
		dtb 0x40000 \
		kernel 0xd80000
fi

rm -rf xboot0
rm -rf uboot0
rm -rf xboot1
rm -rf uboot1
rm -rf uboot2
rm -rf kernel
rm -rf DTB
rm -rf env
rm -rf env_redund
rm -rf rootfs
rm -rf reserve

# Create image for booting from SD card or USB storage.
if [ "$1" = "SDCARD" ]; then
	mkdir -p boot2linux_SDcard
	cp -rf $U $K $N ./boot2linux_SDcard
	if [ "$2" = "Q645" -o "$2" = "SP7350" ]; then
		dd if=$X of=boot2linux_SDcard/ISPBOOOT.BIN
	else
		dd if=/dev/zero of=boot2linux_SDcard/ISPBOOOT.BIN bs=1024 count=64
		dd if=$X of=boot2linux_SDcard/ISPBOOOT.BIN conv=notrunc
	fi
fi
if [ "$1" = "USB" ]; then
	mkdir -p boot2linux_usb
	isp extract4boot2linux_usbboot ISPBOOOT.BIN boot2linux_usb/ISPBOOOT.BIN
	rm -f ISPBOOOT.BIN
fi

# Create image for partial update:
#     isp extract4update ISPBOOOT.BIN ISP_UPDT.BIN [list of partitions ...]
#   Example:
#     isp extract4update ISPBOOOT.BIN ISP_UPDT.BIN uboot2
#     isp extract4update ISPBOOOT.BIN ISP_UPDT.BIN kernel dtb
#     isp extract4update ISPBOOOT.BIN ISP_UPDT.BIN uboot2 kernel dtb
#
#   Execute update in U-Boot:
#     run update_usb
#     run update_sdcard
#

