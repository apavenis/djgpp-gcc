#! /bin/sh
src=../@SRCDIR@
export TEST_FINDS_EXE=Y
export PATH_SEPARATOR=:
CONFIG_SHELL=`/bin/sh -c 'echo $0'`
case $CONFIG_SHELL in *.exe) ;; *) CONFIG_SHELL=$CONFIG_SHELL.exe ;; esac
export CONFIG_SHELL
top=`( cd ..; pwd ) | sed -e 's/^[a-zA-Z]:\//\//g' -e 's/^\/dev\/[a-zA-Z]\//\//g'`
target=i586-pc-msdosdjgpp
export AS=as
export CC=gcc
export ac_cv_func_mmap_dev_zero=no
export lt_cv_sys_max_cmd_len=12000
inst_prefix=$top/install.gcc
make SHELL=$CONFIG_SHELL install prefix=$inst_prefix
