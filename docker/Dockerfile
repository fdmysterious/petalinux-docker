FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ARG PTLNX_INSTALLER=petalinux-v2023.2-10121855-installer.run

# Environment
# Disable user interaction with debian commands.
# see man 7 debconf (may need the debconf-doc pacakge)
ENV DEBIAN_FRONTEND=noninteractive

# Configure dash to bash
# https://superuser.com/questions/715722/how-to-do-dpkg-reconfigure-dash-as-bash-automatically
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN dpkg-reconfigure dash

# Install dependencies
# → Architecture i386 for zlib1g:i386 package
#RUN dpkg --add-architecture i386 && apt-get update -y
RUN apt-get update -y

# → Install apt-utils needed to configure the libc6:i386 package
RUN apt-get install -y apt-utils

# → Install tzdata
# ⚠ Remove to use UTC by default
RUN ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime
RUN apt-get install -y tzdata
RUN dpkg-reconfigure tzdata

# → language stuff
RUN apt-get install -y language-pack-en

# → packages for petalinux
RUN apt-get install -y \
   iproute2 \
   gawk \
   gcc \
   net-tools\
   libncurses5-dev \
   openssl\
   xterm\
   autoconf \
   libtool\
   texinfo\
   zlib1g\
   zlib1g-dev\
   gcc-multilib\
   build-essential\
   automake \
   screen\
   g++\
   xz-utils\
   gcc-11\
   patch\
   python3-jinja2\
   diffutils\
   debianutils\
   iputils-ping\
   python3\
   cpio\
   gnupg \
   less \
   rsync \
   bc \
   lsb-release \
   libtinfo5

# Removed dependencies for now:
#zlib1g:i386\
#cpp-11=11.3.0-1ubuntu1~22.04  \
#libselinux1\
#libstdc++\

   #RUN apt-get install -y\
   #                iproute2\
   #                gcc\
   #                g++\
   #                zlib1g\
   #                zlib1g:i386\
   #                zlib1g-dev\
#                libssl-dev\
#                flex\
#                bison\
#                libselinux1\
#                autoconf\
#                libtool\
#                texinfo\
#                gcc-multilib\
#                build-essential\
#                screen\
#                pax\
#                gawk\
#                python3\
#                python3-pexpect\
#                python3-git\
#                python3-jinja2\
#                xz-utils\
#                debianutils\
#                iputils-ping\
#                pylint3\
#                cpio\
#                xterm\
#                libncurses5-dev\
#                net-tools

RUN apt install -y vim

# Create petalinux user and directory
RUN mkdir -p /opt/petalinux
RUN useradd -s /bin/bash -g users  -m petalinux
RUN chown petalinux:users /opt/petalinux
RUN chmod 755 /opt/petalinux

# Go to petalinux home directory
USER petalinux
WORKDIR /home/petalinux

# Copy required files
COPY --chown=petalinux:users ./$PTLNX_INSTALLER .
RUN chmod +x ./$PTLNX_INSTALLER

COPY --chown=petalinux:users ./patch_petalinux.sh .
RUN chmod +x ./patch_petalinux.sh

# Patch and run installer
RUN ./patch_petalinux.sh ./$PTLNX_INSTALLER
RUN ./$PTLNX_INSTALLER -p aarch64 -d /opt/petalinux

USER root

# Install tftp
RUN apt install -y xinetd tftpd tftp
COPY ./tftp /etc/xinetd.d/tftp
RUN mkdir -p /tftpboot
RUN chown -R nobody /tftpboot
RUN chmod -R 777 /tftpboot


#RUN ./update_esdk.sh
#RUN rm -r esdk.sh.split update_esdk.sh

# Install sudo, give sudo user privileges
RUN apt install sudo
RUN usermod -aG sudo petalinux
RUN chpasswd <<<"petalinux:petalinux"

USER petalinux

WORKDIR /home/petalinux
RUN rm $PTLNX_INSTALLER patch_petalinux.sh petalinux_installation_log

# Create cache folders for yocto
RUN mkdir -p cache/{downloads,sstate-cache}
RUN mkdir -p outputs
RUN chmod 755 outputs

# Source the petalinux stuff in the .bashrc
RUN echo "export DL_DIR=$HOME/cache/downloads"        >> ~/.bashrc
RUN echo "export SSTATE_DIR=$HOME/cache/sstate-cache" >> ~/.bashrc
RUN echo "source /opt/petalinux/settings.sh"          >> ~/.bashrc