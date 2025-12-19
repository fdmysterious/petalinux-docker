#!/bin/bash

groupadd --gid "${HOST_GID:-1000}" builder
useradd --shell /bin/bash --gid "${HOST_GID:-1000}" --uid "${HOST_UID:-1000}" builder

mkdir -p /home/builder /project /yocto/dl /yocto/ss
chown -R builder:builder /home/builder /project /yocto/dl /yocto/ss

# Run as 'builder' using exec + gosu to drop root privileges
exec gosu builder /opt/user_entrypoint.sh "$@"
