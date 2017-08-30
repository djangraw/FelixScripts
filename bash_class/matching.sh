#!/bin/bash

echo -n "Type in something : "
read response
echo "You said: $response"


# By default, the regular expression matching in bash is limited
if [[ "$response" == [0-9][0-9][0-9] ]] ; then
  echo "This is a three-digit number!"

# This uses grep to do a simple match
elif $( echo "$response" | grep -q "^[0-9]\+$" ) ; then
  echo "This is a integer!"

elif $( echo "$response" | grep -q "^[0-9]\+\.[0-9]*$" ) ; then
  echo "This is a floating point number!"

# We can get more sophisticated with extended matching
elif $( echo "$response" | egrep -q '^(\+|-)?[0-9]+\.?[0-9]+(e\+[0-9]+|e-[0-9]+|e[0-9]+)?$' ) ; then
  echo "This is scientific notation!"

# We can look for specific patterns
elif $( echo "$response" | egrep -q '^[[:alpha:]]{3}[[:blank:]]+[0-9]?[0-9][[:blank:]]+[0-9]{4}$' ) ; then
  echo "This is the date!"

# Huh?
else echo "What the?"

fi
