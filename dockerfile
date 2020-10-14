#---Download base image ubuntu 20.04
FROM ubuntu:20.04

#---LABEL about the custom image
LABEL maintainer="luis@tibbo.com"
LABEL version="0.1"
LABEL description="This is an image for our base linux image creation"

#---Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

#---Update and Upgrade
RUN apt-get -y update
RUN apt-get -y upgrade

#---Install required apps
RUN apt-get -y install	bison			    \
                        build-essential	    \
                        flex			    \ 
                        git			        \	 
                        libncurses5-dev     \
                        libssl-dev		    \
                        openssl			    \ 
                        qemu			    \ 
                        qemu-user-static    \ 
                        sshfs			    \
                        u-boot-tools	    \
                        wget                \
                        bc                  \
                        nano                \
                        vim

#---Retrieve files from git
RUN cd ~ && git clone https://github.com/tibbotech/LTPP3_ROOTFS.git

#---Run Sunplus installation and Configuration
RUN cd ~ && ~/LTPP3_ROOTFS/sunplus_inst.sh

#---Run Prepreparation of Disk (before Chroot)
#RUN cd ~ && ~/LTPP3_ROOTFS/disk_PRE_prep.sh