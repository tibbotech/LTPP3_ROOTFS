# Building Images for LTPS

## System Requirements 
* At least 35GB of hard drive space (50GB recommended)
* A clean installation of Ubuntu Server 20.04
  * Ubuntu Desktop 20.04 is viable, but is a significantly larger download and install
  * Installation via a virtual machine is supported
    * A virtual bridge is highly recommended (not necessary if running Hyper-V)

## Getting started
After installing Ubuntu, log in with the username you specified during the setup process.

You will need to install several packages to build images:
* Git
* Docker
* qemu-user-static

To do so, run the following commands:

    sudo apt-get update
    sudo apt-get install git docker.io qemu-user-static
    sudo mkdir /repo
    sudo chown $USER /repo
    cd /repo
    git clone https://github.com/tibbotech/LTPP3_ROOTFS.git

<br>

***

<br>

## Building 

<br>

We have created a script designed to simplify and automate most of the process of building images. To access it, run the following commands:

    cd LTPP3_ROOTFS
    sudo ./docker_mainmenu.sh

You will be presented with an interactive menu, as illustrated below.

![Main Menu](doc/docker_main_menu.png "Main Menu")

Select option #1 (type `1`). This will take you to a submenu, as illustrated below.

![Main Menu](doc/docker_main_menu2.png "Main Menu")

This list is dynamically updated. Enter the number for `docker_multiple_input_files.txt` and press `Enter`.

You will be asked to confirm whether you wish to continue.
Type `y` — no need to press `Enter`. 

This will begin the process of downloading the various files needed to build images. As some of these files are very large (up to nearly 10GB), how long this process takes is highly dependent on your Internet connection, as well as your processor and storage speed.

<br>

***

<br>

## Getting the Binary 

After the script completes successfully, the images containing the different steps of the build process are displayed.

<br>

### Detailed Explanation                              

dockerfile_ltps_init
dockerfile_ltps_sunplus
dockerfile_ltps_rootfs
dockerfile_ltps_preference
dockerfile_ltps_ispboootbin

| Repository                | Description                                           |
| ---                       | ---                                                   |
| `ubuntu`                  | Base Ubuntu Image                                     |
| `ltps_init`               | Base Ubuntu Image + Build Tools                       |
| `ltps_sunplus`            | `ltps_init` + Sunplus Software + LTPS Kernel Build    |
| `ltps_rootfs`             | `ltps_sunplus` + Base Image Files                     |
| `ltps_rootfs_preferences` | `ltps_rootfs` + Additional Drivers and Options        |
| `ltps_rootfs_ispboootbin` | `ltps_rootfs_preferences` with `ISPBOOOT.BIN` Created |

<br>

![Main Menu](doc/docker_main_menu3.png "Main Menu")

You will now be back at the main menu of the interactive script.

Select option #4 (type `4`). This will take you to a submenu, as illustrated below.

![Main Menu](doc/docker_main_menu4.png "Main Menu")

Type the name of image you want to use; in this case, that would be `ubuntu_diskpostprep_uart_buildbin`.

At the subsequent prompt, type the name of the tag you want to use. To use the default ("latest"), just press `Enter`.

![Main Menu](doc/docker_main_menu5.png "Main Menu")

### Manual Extraction
A container has been created. Now you can SSH into it (after exiting the interactive script) to get the image. Remember to use the IP address that the script outputs for the container. For example:

    ssh root@10.0.2.15 -p 10022

As illustrated in the image above, the default login and password is `root`.

Alternatively, you can also SFTP into the container (at the same IP address and port) to extract the image.

The `ISPBOOOT.bin` file used to image an LTPP3(G2) is located in `/root/SP7021/out`.

### Scripted Extraction
In addition, we have created a script to help with extracting the image. Just run:

    sudo docker_cp_fromto_container.sh

![Main Menu](doc/docker_main_menu6.png "Main Menu")

You can specify which file to extract or insert into the container. In this case, you'll want to type `1` to extract the image. Press `Enter` to select the default file. Press `Enter` again for the default location.

You will be prompted to confirm that you want to continue. Type `y`.

![Main Menu](doc/docker_main_menu7.png "Main Menu")

<br>

***

<br>

# Updating LTPP3(G2) Firmware
Now that you have a functional image for your device, it's time to flash the board.

## Requirements
* Physical access to the device
* A power supply for the board
* A USB flash drive
* A jumper or jump wire

If you want to monitor the progress of the operation, you will also need a USB cable with a Type-C connector.

## Step-by-Step Instructions
Before you begin, if the device is in an enclosure — such as an LTPB3 — you will need to remove the "top" cover to access the board.

If you plan on monitoring the progress of the operation, first connect your computer to the LTPP3(G2) board with the USB cable. There is a built-in serial console port (USB Type-C) behind the USB Type-A ports. Then open your preferred terminal application (e.g., IO Ninja or Putty) and prepare to open the port.

1. Copy `ISPBOOOT.BIN` to the USB flash drive.
2. Place the jumper on CN11 (perpendicular to the nearest edge of the board). This is located on the "right" side of the board next to the MD and RST buttons.
3. Insert the USB flash drive into the USB Type-A port **next to the HDMI port**.
4. Power on the device.

_(Optional)_ You can now open the port on your preferred terminal application to monitor the progress of the operation.

![Update Complete](doc/Update_Complete.png "Update Complete")

If you're monitoring via a terminal, you'll see "ISP all: Done" (as illustrated in the image above) when the update is complete.

At this point, you should:
1. Power off the device.
2. Remove the USB flash drive.
3. Remove the jumper
4. Press the RST button to restart the device.
5. _(Optional)_ Replace the "top" cover if you're using an enclosure.

You now have a functional LTPP3(G2)! 