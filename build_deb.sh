#! /bin/bash

randstr=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
project=lego-technic
containerid=$project-build-$randstr
imageid=$project-build-$(id -u)

(set -xe; podman build --target builder --progress=plain -t $imageid .)

set -xe

podman run \
    --name $containerid \
    $imageid

current_script=$( dirname "$(readlink -f "$0")" )
podman cp $containerid:/dist $current_script
podman rm $containerid