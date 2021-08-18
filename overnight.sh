#!/bin/bash

loop_time=$(date +%s --date="+12 hour")
while true; do
#  time=$( date )
#  if [[ "$time" =~ "Sat Nov  7 07:00:" ]]; then
#      break
#  else
#      printf "not yet\n"
#  fi

  bash loop.sh >> result.log
  if [ "$(date +%s)" -gt "$loop_time" ]; then
    echo "OFF"
    break
  fi
done



