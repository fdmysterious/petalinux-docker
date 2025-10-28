FROM ubuntu:22.04 AS base_env

ENV DEBIAN_FRONTEND=noninteractive
ARG PTLNX_INSTALLER=petalinux-v2024.1-05202009-installer.run

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
   libtinfo5 \
   dnsutils

FROM base_env AS install_stage

# Add installation user as installer refuse to install as root...
RUN useradd -s /bin/bash -g users installer

# Prepare installation directory
RUN mkdir -p /opt/petalinux
RUN chown installer:users /opt/petalinux
RUN chmod 755 /opt/petalinux

RUN mkdir -p /workspace
RUN chmod 755 /workspace

WORKDIR /workspace

# Copy required files
COPY ./$PTLNX_INSTALLER .
RUN chmod +x ./$PTLNX_INSTALLER

RUN chown -R installer:users /workspace

USER installer
WORKDIR /workspace

# Run installer
# -> Starting from 2024.1, added the -y argument that allow to accept license automatically
RUN ./$PTLNX_INSTALLER -y -p aarch64 -d /opt/petalinux

USER root

# Change user ownership for installation folder
RUN chown -R root:root /opt/petalinux

#######

FROM base_env AS final

RUN apt install -y vim
COPY --from=install_stage /opt/petalinux /opt/petalinux

COPY ./entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

COPY ./user_entrypoint.sh /opt/user_entrypoint.sh
RUN chmod +x /opt/user_entrypoint.sh

RUN mkdir -p /yocto/dl /yocto/ss
RUN chmod 777 /yocto/dl /yocto/ss

# Customize shell prompt
#echo "export PS1='\[\e[0m\][\[\e[34m\]\w\[\e[0m\]] > '" >> /etc/bash.bashrc

ENTRYPOINT ["/opt/entrypoint.sh"]
