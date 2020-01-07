#!/bin/bash

if [[ $(uname -s) == Darwin ]]
then
    X_PREFIX=/usr/X11
else
    X_PREFIX=$PREFIX
fi

./configure --prefix=${PREFIX} \
            --x-libraries=${X_PREFIX}/lib \
            --x-includes=${X_PREFIX}/include \
            --with-nc-config=${PREFIX}/bin/nc-config \
            --with-udunits2_incdir=${PREFIX}/include \
            --with-udunits2_libdir=${PREFIX}/lib \
            --with-png_incdir=${PREFIX}/include \
            --with-png_libdir=${PREFIX}/lib

make
make check
make install
