#!/bin/bash
COLOR_REST='\e[0m'
COLOR_RED='\e[101m'
COLOR_RED_WD='\e[0;31m'
COLOR_BLUE='\e[104m'
COLOR_RED_WD='\e[0;31m'
COLOR_BLUE_WD='\e[0;34m'
COLOR_YELLOW_WD='\e[93m'


a=2
if  (("$a" != 3)) && (("$a" == 2)); then
  printf "good"

fi

if  [[ "$a" != 3 && "$a" == 2 ]]; then
  printf "good"

fi

if  [ "$a" -ne 3 ] && [ "$a" == 2 ]; then
  printf "good"

fi

#totalsize=123466
#mainsize=$((totalsize/4+1))
#echo "$mainsize"
#
#bank_address=("0" "8388608" )
#
#
#
#if [ ${bank_address[2]} ]; then
#
#  printf "good"
#
#fi
