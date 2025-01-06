#!/bin/bash

function get_cross_tool()
{
    echo "--- $FUNCNAME ---"
    if [ ! -d crosstool-ng ]; then
        echo "crosstool-ng is not exist!!! Get new one..."
        git clone https://github.com/crosstool-ng/crosstool-ng.git
    fi

    cd crosstool-ng
    ./bootstrap
    ./configure --prefix=${PWD}
    make
    make install
}

get_cross_tool
