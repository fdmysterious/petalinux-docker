#!/bin/bash

groupadd --gid $HOST_GID builder
useradd --shell /bin/bash --gid $HOST_GID --uid $HOST_UID builder

su -c "source /opt/user_entrypoint.sh $@" builder