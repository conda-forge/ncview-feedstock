#!/bin/bash

if [[ $(uname -s) == Darwin ]]
then
    X_PREFIX=/usr/X11
    # install xquartz
    sudo mv /usr/local/conda_mangled/* /usr/local/
    /usr/local/Homebrew/bin/brew install --cask xquartz
else
    X_PREFIX=$PREFIX
fi

export ac_cv_lib_expat_XML_GetBase=yes

./configure --prefix=${PREFIX} \
            --x-libraries=${X_PREFIX}/lib \
            --x-includes=${X_PREFIX}/include \
            --with-nc-config=${PREFIX}/bin/nc-config \
            --with-udunits2_incdir=${PREFIX}/include \
            --with-udunits2_libdir=${PREFIX}/lib \
            --with-png_incdir=${PREFIX}/include \
            --with-png_libdir=${PREFIX}/lib

make
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
make check
fi
make install
