#!/bin/bash

TOP_DIR=`pwd`


function get_uboot()
{
    cd $TOP_DIR
    source set-path-arm-cortex_a8-linux-gnueabihf

    echo "--- ${FUNCNAME} ---"
    if [ ! -d u-boot ]; then
        echo "U-Boot is not exist!!! Get new one..."
        git clone git://git.denx.de/u-boot.git
        cd u-boot
        git checkout v2021.01
        cd -
    fi

    cd u-boot
}

function build_uboot()
{
    echo "--- ${FUNCNAME} ---"
    source $TOP_DIR/memo/ch03/set-path-arm-cortex_a8-linux-gnueabihf
    make am335x_evm_defconfig
    make
}

get_uboot
build_uboot


