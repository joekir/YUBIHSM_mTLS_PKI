#!/bin/bash

set -eu

find ../../../Intermediates/ -mindepth 1 -maxdepth 1 -type d -print0 | 
    while IFS= read -r -d $'\0' line; do
        HOST_OCSP_BASE=`readlink -f $line` INT_NUM_CA=${line: -1} ./build.sh
    done
