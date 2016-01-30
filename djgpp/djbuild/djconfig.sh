#! /bin/sh

src=../@SRCDIR@
export TEST_FINDS_EXE=Y
export PATH_SEPARATOR=:
target=djgpp
export AS=as.exe
export LD=ld.exe
export NM=nm.exe
export CC=gcc
export ac_cv_func_mmap_dev_zero=no
export lt_cv_sys_max_cmd_len=12000
export ac_cv_prog_LN='ln -s'
export ac_cv_prog_LN_S='ln -s'
export ac_cv_prog_AWK='awk'
CONFIG_SHELL=`/bin/sh -c 'echo $0'`
case $CONFIG_SHELL in *.exe) ;; *) CONFIG_SHELL=$CONFIG_SHELL.exe ;; esac
export CONFIG_SHELL
#
conf_options="$target"
conf_options="$conf_options --prefix=/dev/env/DJDIR"
#conf_options="$conf_options --disable-nls"
conf_options="$conf_options --disable-werror"
conf_options="$conf_options --enable-languages=c,c++,fortran,objc,obj-c++,ada"
#conf_options="$conf_options --enable-languages=c,c++,fortran,objc,obj-c++"
conf_options="$conf_options --enable-libquadmath-support"
conf_options="$conf_options --enable-lto"
#
srcdir=`(cd $src && pwd) | sed -e 's,^[a-zA-Z]:/,/,' -e 's,^/dev/[a-zA-Z]/,/,'`
builddir=`pwd | sed -e 's,^[a-zA-Z]:/,/,' -e 's,^/dev/[a-zA-Z]/,/,'`
#
echo "Configuring GCC ..."
echo "Source directory : $srcdir"
echo "Build directory : $builddir"
#
$srcdir/configure $conf_options $*
