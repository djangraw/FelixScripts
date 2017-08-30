#!/bin/bash
i=$(sort -u /proc/cpuinfo | grep -c '^physical id')
c=$(sort -u /proc/cpuinfo | grep -c '^core id')
t=$(sort -u /proc/cpuinfo | grep -c '^processor')

if [[ $i != 0 ]] ; then cpu=$((i*c)) ; else cpu=$t ; fi

echo cpu = $cpu
echo threads = $t

