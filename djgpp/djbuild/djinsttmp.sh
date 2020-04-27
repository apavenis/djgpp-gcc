#! /bin/sh
src=../@SRCDIR@
export TEST_FINDS_EXE=Y
export PATH_SEPARATOR=:
CONFIG_SHELL=`/bin/sh -c 'echo $0'`
case $CONFIG_SHELL in *.exe) ;; *) CONFIG_SHELL=$CONFIG_SHELL.exe ;; esac
export CONFIG_SHELL
version=`cat $src/gcc/version.c | grep version_string | sed -e 's,^.*[=],,' | sed -e 's,[";],,g' | sed -e 's,^[\ ],,g'`
short_version=`echo $version | sed -e 's,[\ ].*,,' -e 's,^[ ]+,,g'`
arcprefix=gcc`echo $short_version | sed -e 's,\.,,g'`
top=`( cd ..; pwd ) | sed -e 's/^[a-zA-Z]:\//\//g' -e 's/^\/dev\/[a-zA-Z]\//\//g'`
target=i586-pc-msdosdjgpp
export AS=as
export CC=gcc
export ac_cv_func_mmap_dev_zero=no
export lt_cv_sys_max_cmd_len=12000
export ac_cv_prog_LN_S='ln -s'
export LC_NUMERIC=.
inst_prefix=$top/install.gcc
make SHELL=$CONFIG_SHELL install prefix=$inst_prefix
