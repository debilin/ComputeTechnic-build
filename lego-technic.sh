#! /bin/bash

randstr=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
project=compute-technic
containerid=$project-build-$randstr
imageid=$project-build-$(id -u)

mkdir -p $PWD/output/vis_edges/
docker run \
    --name $containerid \
    -w /ComputeTechnic/build \
    -v "$PWD/output:/ComputeTechnic/LEGO_Technic_data/1_debug" \
    -v "$PWD/output/vis_edges:/ComputeTechnic/python" \
    $imageid /ComputeTechnic/build/lego_technic_main $1 $2

if [ "$1" = "-vis_edges" ]; then
    lego_vis_edges $2
fi

docker rm $containerid