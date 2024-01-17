#! /bin/bash

source build_deb.sh

(set -xe; podman build -t $project .)