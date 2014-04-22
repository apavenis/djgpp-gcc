#! /bin/sh

for mft in manifest/*.mft ; do
    log=${mft/\.mft/.log}
    echo "#### Checking $mft ########"
    doschk $mft >$log 2>&1
    awk 'BEGIN{on=1} /resolve\ to\ the\ same\ SysV/{on=0} {if(on){print}}' $log
done
