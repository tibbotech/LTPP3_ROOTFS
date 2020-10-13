#Download base image ubuntu 20.04
FROM ubuntu:20.04

# LABEL about the custom image
LABEL maintainer="luis@tibbo.com"
LABEL version="0.1"
LABEL description="This is an image for our base linux image creation"

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update

RUN apt-get -y upgrade

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
                        wget                

RUN apt-get -y install vim  \
                        nano

RUN cd ~ && RUN git clone https://github.com/tibbotech/LTPP3_ROOTFS.git

RUN LTPP3_ROOTFS/sunplus_inst.sh