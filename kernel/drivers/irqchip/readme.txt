# Please put the following files in this folder, e.g.:
#       irq-sp7021-intc.c
#       irq-sp7021-intc.c.patch
#
# Remark:
#   The 'new' c-file are used to to compare with the 'old' c-file.
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
#   6.1 Navigate to /root/LTPP3_ROOTFS/kernel/drivers/irqchip
#   6.2 Run the following commands:
#       rm *.c
#       rm *.patch
#   7. From your (Windows) PC, using WinSCP, copy the NEW c-file to to '/root/LTPP3_ROOTFS/kernel/drivers/irqchip':
#       irq-sp7021-intc.c
#   8. To create NEW PATCHES, run the following commands:
#       diff -u /root/SP7021/linux/kernel/drivers/irqchip/irq-sp7021-intc.c /root/LTPP3_ROOTFS/kernel/drivers/irqchip/irq-sp7021-intc.c > /root/LTPP3_ROOTFS/kernel/drivers/irqchip/irq-sp7021-intc.c.patch
#   9. In folder '/root/LTPP3_ROOTFS/kernel/drivers/irqchip', confirm that the new 'dtsi' and 'patch' files are present.
#   10. Once confirmed, navigate to '/root/LTPP3_ROOTFS'
#   11. Run the following commands:
#       git add .
#       git commit -m "created new patch files"
#       git push
#