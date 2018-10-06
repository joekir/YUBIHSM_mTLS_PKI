FROM ubuntu:16.04

RUN apt-get update && apt-get upgrade -y
RUN apt-get install sudo wget curl vim libcurl3 libssl1.0.2 libusb-1.0-0 libbsd0 libedit2 libncurses5 libengine-pkcs11-openssl opensc opensc-pkcs11 -y

WORKDIR /tmp
RUN wget https://developers.yubico.com/YubiHSM2/Releases/yubihsm2-sdk-1.0.1-ubuntu1604-amd64.tar.gz && tar -zxf yubihsm2-sdk-1.0.1-ubuntu1604-amd64.tar.gz
WORKDIR /tmp/yubihsm2-sdk
RUN dpkg -i libyubihsm*.deb
RUN dpkg -i yubihsm-shell*.deb
RUN dpkg -i yubihsm-pkcs11*.deb

RUN useradd -s /bin/bash -u 1000 -G sudo -m docker
RUN echo "docker ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN mkdir -p /pki
RUN chown -R docker:docker /pki
#COPY $PWD /pki
WORKDIR /pki

USER docker
