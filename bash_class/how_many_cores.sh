#!/bin/bash
while IFS=: read -r tag num end
do
  pat="^physical id*" ; if [[ $tag =~ $pat && $num != $prev_i ]] ; then ((i++)) ; prev_i=$num ; fi
  pat="^core id*" ; if [[ $tag =~ $pat && $num != $prev_c ]] ; then ((c++)) ; prev_c=$num ; fi
  pat="^processor*" ; if [[ $tag =~ $pat && $num != $prev_p ]] ; then ((threads++)) ; prev_p=$num ; fi
done < <(sort -t: -n -k2  /proc/cpuinfo)

if [[ $i != 0 ]] ; then cpu=$((i*c)) ; else cpu=$threads ; fi

echo cpu = $cpu
echo threads = $threads

