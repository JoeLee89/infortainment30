#!/bin/bash
source ./common_func.sh
title b "EP Fail test"
printf "Press enter key to test or [q] key to skip.. \n"
read -p "" input

while true; do
  if [ "$input" == "q" ]; then
      break
  else
    print_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_"$board" --section EP-FAIL"
    sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_"$board" --section EP-FAIL
  fi

  printf "Press enter key to test or [q] key to skip.. \n"
  read -p "" input
done
printf '12'