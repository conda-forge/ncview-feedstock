#!/bin/bash

if [[ $(uname -s) == Darwin ]]
then
    X_PREFIX=/usr/X11
    # install xquartz
    sudo mv /usr/local/conda_mangled/* /usr/local/
    /usr/local/Homebrew/bin/brew install --cask xquartz
    # ncview still contains K&R-era C that breaks under conda-forge's newer
    # default C language mode on macOS, so compile it in a pre-C23 GNU mode.
    export CFLAGS="${CFLAGS} -std=gnu17"
else
    X_PREFIX=$PREFIX
fi

# ncview's configure script looks specifically for libpng.so, even on macOS.
# Preseed the autoconf cache so the check succeeds and the later link step can
# continue to use the portable -lpng flag.
if [[ $(uname -s) == Darwin ]]; then
    as_cr_letters='abcdefghijklmnopqrstuvwxyz'
    as_cr_LETTERS='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    as_cr_Letters=$as_cr_letters$as_cr_LETTERS
    as_cr_digits='0123456789'
    as_cr_alnum=$as_cr_Letters$as_cr_digits
    as_tr_sh="eval sed 'y%*+%pp%;s%[^_$as_cr_alnum]%_%g'"

    PNG_INCDIR=${PREFIX}/include
    PNG_LIBDIR=${PREFIX}/lib
    PNG_LIBNAME=libpng.so
    as_ac_File=`printf "%s\n" "ac_cv_file_$PNG_LIBDIR/$PNG_LIBNAME" | $as_tr_sh`
    eval "export $as_ac_File=yes"
fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == "1" ]]; then
    # The following is borrowed from `configure`.
    # Note that we don't `export` and thus don't pollute
    # `configure` itself.
    # Avoid depending upon Character Ranges.
    as_cr_letters='abcdefghijklmnopqrstuvwxyz'
    as_cr_LETTERS='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    as_cr_Letters=$as_cr_letters$as_cr_LETTERS
    as_cr_digits='0123456789'
    as_cr_alnum=$as_cr_Letters$as_cr_digits
    # Sed expression to map a string onto a valid variable name.
    as_tr_sh="eval sed 'y%*+%pp%;s%[^_$as_cr_alnum]%_%g'"

    # Now follow cache variables for dep checks
    UDUNITS2_INCDIR=${PREFIX}/include
    UDUNITS2_LIBDIR=${PREFIX}/lib
    # Note that we need .a here to appease the configure script,
    # we nonetheless link agains the shared library.
    UDUNITS2_LIBNAME=libudunits2.a
    as_ac_File=`printf "%s\n" "ac_cv_file_$UDUNITS2_LIBDIR/$UDUNITS2_LIBNAME" | $as_tr_sh`
    eval "export $as_ac_File=yes"

    PNG_INCDIR=${PREFIX}/include
    PNG_LIBDIR=${PREFIX}/lib
    if [[ $(uname -s) == Darwin ]]; then
        PNG_LIBNAME=libpng.dylib
    else
        PNG_LIBNAME=libpng.so
    fi
    as_ac_File=`printf "%s\n" "ac_cv_file_$PNG_LIBDIR/$PNG_LIBNAME" | $as_tr_sh`
    eval "export $as_ac_File=yes"
fi

export ac_cv_lib_expat_XML_GetBase=yes

./configure --prefix="${PREFIX}" \
            --x-includes="${PREFIX}/include" \
            --x-libraries="${PREFIX}/lib" \
            --with-nc-config="${PREFIX}/bin/nc-config" \
            --with-udunits2_incdir="${PREFIX}/include" \
            --with-udunits2_libdir="${PREFIX}/lib" \
            --with-png_incdir="${PREFIX}/include" \
            --with-png_libdir="${PREFIX}/lib"

make
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
make check
fi
make install
