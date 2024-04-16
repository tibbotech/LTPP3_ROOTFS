##################################################################################
# Makefile created by Ngoc Hien Tran
# NOTE 1:
#	/root/SP7021/linux/kernel/drivers/Makefile needs to be modified by adding
#		the following line to that file:
#			obj-$(CONFIG_TPD) += tpd/
##################################################################################
obj-$(CONFIG_TPD) += tpd.o

# Ensure the ARCH and CROSS_COMPILE variables are set appropriately for your target platform
ARCH ?= arm
CROSS_COMPILE ?= arm-linux-gnueabihf-

# Specify the location of the kernel build directory
# You can adjust KERNEL_BUILD_DIR to match your actual kernel build directory
KERNEL_BUILD_DIR := /root/SP7021/linux/kernel

all:
	$(MAKE) -C $(KERNEL_BUILD_DIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KERNEL_BUILD_DIR) M=$(PWD) clean
