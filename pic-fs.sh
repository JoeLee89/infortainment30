#!/bin/bash
source ./common_func.sh

#===============================================================
#Check PIC SW button from PIC event
#===============================================================
PIC_SWByEvent() {
  title b "Check PIC SW button from PIC event"

  while true; do
    #  sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section PIC_GetPICEvent_and_DisplayEventTime
    print_command "sudo ./idll-test.exe --external-sw 1 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section PIC_External_Function_SW_Test"
    sudo ./idll-test.exe --external-sw 1 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section PIC_External_Function_SW_Test

    printf "q to exit ,or enter repeat test..\n"
    read -p "" leave
    if [ "$leave" == "q" ]; then
      break
    fi
  done
}

#===============================================================
#(BSEC/BACC only) Check PIC FS button from get port/ get pin
#===============================================================
GetPortPin_BSEC() {
  title b "(BSEC/BACC only) Check PIC FS button from get port/ get pin"
  read -p "Enter key to test.." confirm

  while true; do
    #  sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section PIC_GetPICEvent_and_DisplayEventTime
    print_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section GPI_BACC_FS"
    sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section GPI_BACC_FS

    printf "[q] to exit ,or enter to repeat test..\n"
    read -p "" leave
    if [ "$leave" == "q" ]; then
      break
    fi
  done
}

#===============================================================
#main
#===============================================================
while true; do
  printf  "\n"
  printf  "${COLOR_RED_WD}1. PIC BUTTON STATUS BY PIC EVENT${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}2. PIC BUTTON FROM GET PORT/PIN (BSEC/BACC only)${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}=========================================================${COLOR_REST}\n"
  printf "CHOOSE ONE TO TEST: "
  read -p "" input

  if [ "$input" == 1 ]; then
    PIC_SWByEvent
  elif [ "$input" == 2 ]; then
    GetPortPin_BSEC
  fi

done