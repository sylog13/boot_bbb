#!/bin/bash

function get_cross_tool()
{
    echo "--- $FUNCNAME ---"
    if [ ! -d crosstool-ng ]; then
        echo "crosstool-ng is not exist!!! Get new one..."
        git clone https://github.com/crosstool-ng/crosstool-ng.git

        cd $TOOLCHAIN_DIR
        ./bootstrap
        ./configure --prefix=${PWD}
        make
        make install
    fi
}

function config_toolchain()
{
    echo "--- $FUNCNAME ---"
    cd $TOOLCHAIN_DIR

    bin/ct-ng show-arm-cortex_a8-linux-gnueabi

    bin/ct-ng distclean
    bin/ct-ng arm-cortex_a8-linux-gnueabi

    # custom configure in command line
    echo "--- CT_VCHECK 1 ---"
    cat .config |grep CT_VCHECK
    sed -i 's/CT_VCHECK="load"/CT_VCHECK=""/g' .config
    echo "--- CT_PREFIX_DIR_R0 ---"
    sed -i 's/CT_PREFIX_DIR_RO=y/\#\ CT_PREFIX_DIR_RO\ is\ not\ set/g' .config
    #echo "CT_ARCH_ARM_TUPLE_USE_EABIHF=y" >> .config
    echo "--- CT_ARCH_ARM_EABI ---"
    sed -i '/CT_ARCH_ARM_EABI=y/a CT_ARCH_ARM_TUPLE_USE_EABIHF=y' .config
    echo "--- CT_ARCH_FPU ---"
    sed -i 's/CT_ARCH_FPU=""/CT_ARCH_FPU="neon"/g' .config
    echo "--- CT_ARM_FLOAT_HW ---"
    sed -i 's/#\ CT_ARCH_FLOAT_HW\ is\ not\ set/CT_ARCH_FLOAT_HW=y/g' .config
    echo "--- CT_ARCH_FLOAT_SW ---"
    sed -i 's/CT_ARCH_FLOAT_SW=y/#\ CT_ARCH_FLOAT_SW\ is\ not\ set/g' .config
    echo "--- CT_ARCH_FLOAT ---"
    sed -i 's/CT_ARCH_FLOAT="soft"/CT_ARCH_FLOAT="hard"/g' .config
}

function build_toolchain()
{
    echo "--- $FUNCNAME ---"

    cd $TOOLCHAIN_DIR
    bin/ct-ng build
}

export TOP_DIR=`pwd`
export TOOLCHAIN_DIR=$TOP_DIR/crosstool-ng

get_cross_tool
config_toolchain
build_toolchain

