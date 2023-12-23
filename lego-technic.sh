#! /bin/bash

randstr=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 8 | head -n 1)
project=compute-technic
containerid=$project-build-$randstr
imageid=$project-build-$(id -u)

if [ "$1" = "-path_select" ]; then
    mkdir -p $PWD/vis_edges/
    docker run \
        --name $containerid \
        -v "$PWD:/ComputeTechnic/LEGO_Technic_data/1_debug" \
        -v "$PWD/vis_edges:/ComputeTechnic/python" \
        $imageid /ComputeTechnic/build/lego_technic_main $1 $2
fi

if [ "$1" = "-vis_edges" ]; then
    lego_vis_edges $2
fi

docker rm $containerid