#! /bin/sh

#
# Work in the progress
#
# Configuring gcc for cross-native build og DJGPP port under Linux
# 
# - only C and C++ compilers are included now
# - one must install GMP, MPFR, MPC and ZLIB development files
#   for DJGPP
#

target=i586-pc-msdosdjgpp

../gnu/gcc-4.80-20120906/configure \
    --build=i586-pc-linux-gnu \
    --host=i586-pc-msdosdjgpp \
    --target=$target \
    --enable-languages="c,c++" \
    --with-native-system-header-dir=/usr/$target/sys-include \
    --disable-libstdcxx-pch \
    --disable-nls


