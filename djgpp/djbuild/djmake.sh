#! /bin/sh

src=../@SRCDIR@
export TEST_FINDS_EXE=Y
export PATH_SEPARATOR=:
export AS=as.exe
export LD=ld.exe
export CC=gcc.exe
export ac_cv_func_mmap_dev_zero=no
export lt_cv_sys_max_cmd_len=12000
export ac_setrlimit=no
export glibcxx_cv_prog_CXX_pch=no
CONFIG_SHELL=`/bin/sh -c 'echo $0'`
case $CONFIG_SHELL in *.exe) ;; *) CONFIG_SHELL=$CONFIG_SHELL.exe ;; esac
export CONFIG_SHELL
#
make SHELL=$CONFIG_SHELL $*
