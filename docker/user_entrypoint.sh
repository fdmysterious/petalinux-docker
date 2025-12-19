#!/bin/bash

export SHELL="/bin/bash"
export DL_DIR=/yocto/dl
export SSTATE_DIR=/yocto/ss
export HOME=/home/builder

source /opt/petalinux/settings.sh /opt/petalinux

exec $@
