#!/bin/bash

# This script provides wisdom

FORTUNE=/usr/games/fortune

while true; do
echo "On which topic do you want advice?"
cat << topics
politics
startrek
kernelnewbies
sports
bofh-excuses
magic
love
literature
drugs
education
topics

echo
echo -n "Make your choice: "
read topic
echo
echo "Free advice on the topic of $topic: "
echo
$FORTUNE $topic
echo

done
