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
                        wget                \
                        bc                  \
                        nano                \
                        vim                 \
                        openssh-server

RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
# Change '/etc/ssh/sshd_config' to allow SSH with root
RUN sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

ENV NOTVISIBLE="in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

#RUN cd ~ && git clone https://github.com/tibbotech/LTPP3_ROOTFS.git

#RUN cd ~ && ~/LTPP3_ROOTFS/sunplus_inst.sh