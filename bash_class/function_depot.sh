#!/bin/bash

function throwError
# Display an error message and exit with a non-zero status.
{
  echo ERROR: $1
  exit 1
}

function status
# Give some standard status info.
{
  date
  uptime
  who | grep $USER
  checkquota
}

function processFile
# Nonsensical function.
{  
  local TMPDIR=/data/user/tmpdir
  echo $TMPDIR
  sort $1 | grep $2
}

function generateLoad
# Generate 5-8 seconds of 100% load on 1 CPU.
{
  for i in {1..500000}
  do
    let j=i++
  done
}

function pickRandomLine
# Pick a line from a file at random
{
  num=$(wc -l $1 | awk '{print $1}')
  line=$(( ( ( $RANDOM * 32768 ) + $RANDOM ) % $num ))
  sed -n "${line}p" $1
}

function __current_load {
  local load=$(uptime | cut -d"," -f4 | cut -d":" -f2 | cut -d" " -f2)
  local loadint=$(echo -n $load | cut -d"." -f1)
  local R="\033[0;31m" # red
  local G="\033[0;32m" # green
  local Y="\033[0;33m" # yellow
  local B="\033[0;34m" # blue
  local BR="\033[1;31m" # bold red
  local BBR="\033[5;30;43m" # blinking black on yellow
  local RESET="\033[0;37m" # reset
  local t=$(sort -u /proc/cpuinfo | grep -c '^processor')
  local loadnorm=$(echo "($load*100)/$t" | bc)
  if [[ $loadnorm -lt 20 ]]; then
    echo -e "$B${load}"
  elif [[ $loadnorm -lt 40 ]]; then
    echo -e "$G${load}"
  elif [[ $loadnorm -lt 60 ]]; then
    echo -e "$Y${load}"
  elif [[ $loadnorm -lt 80 ]]; then
    echo -e "$R${load}"
  else
    echo -e "$BBR${load}"
  fi
}

function tiny_prompt {
  unset PROMPT_COMMAND
  export PS1='$ '
}

function normal_prompt {
  export PROMPT_COMMAND='echo -ne "\033]0;${HOSTNAME%%.*}"; echo -ne "\007"'
  export PS1='[\u@\h \W]$ '
}

function load_prompt {
  export PROMPT_COMMAND='echo -ne "\033]0;${HOSTNAME%%.*}"; echo -ne "\007"'
  export PS1='[\u@\h \W $(__current_load)\[\033[0m\]]$ ' # variable
}

function color_prompt {
  export PROMPT_COMMAND='echo -ne "\033]0;${HOSTNAME%%.*}"; echo -ne "\007"'
  local K="\[\033[0;30m\]" # black
  local R="\[\033[0;31m\]" # red
  local G="\[\033[0;32m\]" # green
  local Y="\[\033[0;33m\]" # yellow
  local B="\[\033[0;34m\]" # blue
  local M="\[\033[0;35m\]" # magenta
  local C="\[\033[0;36m\]" # cyan
  local W="\[\033[0;37m\]" # white
  local BK="\[\033[1;30m\]" # bold black
  local BR="\[\033[1;31m\]" # bold red
  local BG="\[\033[1;32m\]" # bold green
  local BY="\[\033[1;33m\]" # bold yellow
  local BB="\[\033[1;34m\]" # bold blue
  local BM="\[\033[1;35m\]" # bold magenta
  local BC="\[\033[1;36m\]" # bold cyan
  local BW="\[\033[1;37m\]" # bold white
  local RESET="\[\033[0;37m\]" # reset

  export PS1="$B\u $G\h $Y\W$RESET "
}

