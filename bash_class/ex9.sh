#!/bin/bash

source function_depot.sh

file=bogus.txt

[[ -e $file ]] || throwError "$file doesn't exist!"

[[ -r $file ]] || throwError "$file can't be read!"

(( $( wc -l $file | cut -d" " -f1 ) >= 10 )) || throwError "$file has less than 10 lines!"

contents=$( tail -n 10 $file )

echo "$contents"
