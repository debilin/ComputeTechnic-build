#! /bin/bash

randstr=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
project=compute-technic
containerid=$project-build-$randstr
imageid=$project-build-$(id -u)

(set -xe; docker build --progress=plain -t $imageid .)

set -xe

docker run \
    --name $containerid \
    $imageid

docker cp $containerid:/ComputeTechnic/build/lego_vis_edges ./dist
docker rm $containerid