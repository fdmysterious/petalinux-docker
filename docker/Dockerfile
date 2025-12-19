FROM ubuntu:18.04 AS base_env

ENV DEBIAN_FRONTEND=noninteractive
ARG PTLNX_INSTALLER=petalinux-v2020.2-final-installer.run

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
RUN dpkg --add-architecture i386 && apt-get update -y
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
   libncurses5-dev:i386 \
   openssl\
   xterm\
   autoconf \
   libtool\
   texinfo\
   zlib1g:i386\
   zlib1g-dev:i386\
   libc6:i386\
   libc6-dev:i386\
   gcc-multilib\
   build-essential\
   automake \
   screen\
   g++\
   xz-utils\
   patch\
   python3-jinja2\
   diffutils\
   iputils-ping\
   python3\
   cpio\
   gnupg \
   less \
   rsync \
   bc \
   lsb-release \
   device-tree-compiler\
   libtinfo5

FROM base_env AS install_stage

RUN useradd -m -s /bin/bash installer

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

COPY ./patch_petalinux.sh .
RUN chmod +x ./patch_petalinux.sh

RUN chown -R installer:users /workspace

USER installer
WORKDIR /workspace

# Patch and run installer
RUN ./patch_petalinux.sh ./$PTLNX_INSTALLER
RUN ./$PTLNX_INSTALLER -p aarch64 -d /opt/petalinux

USER root

# Change user ownership for installation folder
RUN chown -R root:root /opt/petalinux

#######

FROM base_env AS final

RUN apt install -y vim
COPY --from=install_stage /opt/petalinux /opt/petalinux

## Ensure standard system binaries are available in PATH
ENV PATH="/usr/sbin:/usr/bin:/sbin:/bin:${PATH}"

## Install `tini` (as PID 1) to handle OS signals properly
ENV TINI_VERSION=v0.19.0
## Download the static tini binary into the image
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
## Make tini executable so it can be used as entrypoint
RUN chmod +x /usr/bin/tini

## Install `gosu` to drop privileges and run as the runtime user (`builder`).
RUN apt-get install -y --no-install-recommends gosu

## Clean up apt lists to reduce image size
RUN rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

COPY ./user_entrypoint.sh /opt/user_entrypoint.sh
RUN chmod +x /opt/user_entrypoint.sh

RUN mkdir -p /yocto/dl /yocto/ss
RUN chmod 777 /yocto/dl /yocto/ss

# Customize shell prompt
RUN echo "export PS1='\[\e[0m\][\[\e[34m\]\w\[\e[0m\]] > '" >> /etc/bash.bashrc

ENTRYPOINT ["/usr/bin/tini", "--", "/opt/entrypoint.sh"]
