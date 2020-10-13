#Download base image ubuntu 20.04
FROM ubuntu:20.04

# LABEL about the custom image
LABEL maintainer="luis@tibbo.com"
LABEL version="0.1"
LABEL description="This is an image for our base linux image creation"

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update

RUN apt upgrade

