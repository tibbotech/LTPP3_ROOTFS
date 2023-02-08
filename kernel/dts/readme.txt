# Please put the new 'dtsi' and 'patch' files in this folder, e.g.:
#   sp7021-common.dtsi
#   sp7021-common.patch
#   sp7021-ltpp3g2revD.dtsi
#   sp7021-ltpp3g2revD.patch
#
# Remark:
#   The 'new' dtsi files are used to to compare with the 'old' files.
#   In case there is a difference, the 'patch' will be applied.
#
# IMPORTANT TO KNOW:
#   If a NEW patch has to be created, make sure to follow the following steps:
#   1. create the 1st two docker-images, in other words:
#       dockerfile_ltps_init
#       dockerfile_ltps_sunplus
#   2. Run a CONTAINER of the docker-image with the following REPOSITORY:TAG = ltps_sunplus:latest
#   3. SSH into this container
#   4. Navigate to /root/LTPP3_ROOTFS
#   5. git pull
#   6.1 Navigate to /root/LTPP3_ROOTFS/kernel/dts
#   6.2 Run the following commands:
        rm *.dtsi
        rm *.patch
#   7. From your (Windows) PC, using WinSCP, copy the NEW 'dtsi' files to to '/root/LTPP3_ROOTFS/kernel/dts':
#       sp7021-ltpp3g2revD.dtsi
#       sp7021-common.dtsi
#   8. To create NEW PATCHES, run the following commands:
#       diff -u /root/SP7021/linux/kernel/arch/arm/boot/dts/sp7021-common.dtsi /root/LTPP3_ROOTFS/kernel/dts/sp7021-common.dtsi > /root/LTPP3_ROOTFS/kernel/dts/sp7021-common.patch
#       diff -u /root/SP7021/linux/kernel/arch/arm/boot/dts/sp7021-ltpp3g2revD.dtsi /root/LTPP3_ROOTFS/kernel/dts/sp7021-ltpp3g2revD.dtsi > /root/LTPP3_ROOTFS/kernel/dts/sp7021-ltpp3g2revD.patch
#   9. In folder '/root/LTPP3_ROOTFS/kernel/dts', confirm that the new 'dtsi' and 'patch' files are present.
#   10. Once confirmed, navigate to '/root/LTPP3_ROOTFS'
#   11. Run the following commands:
#       git add .
#       git commit -m "created new patch files"
#       git push
#