#!/bin/bash
source ./common_func.sh
#===============================================================
#DIP switch status get by Getpin & Getport (SCxx/BSEC_Backplan)
#===============================================================
DipSwitch_GetPortPin() {
  title b "DIP switch status get by Getpin & Getport (SCxx/BSEC_Backplan)"

  while true; do
    print_command "sudo ./idll-test -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section GPI_User_DIP_SW"
    sudo ./idll-test -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section GPI_User_DIP_SW
    read -p "press [q] to exit, or enter key to test: " input
    if [ "$input" == "q" ]; then
      break
    fi
  done
}

#===============================================================
#DIP switch status get by Getpin & Getport (BSEC_Mainboard_DIP_SW)
#===============================================================
DipSwitch_GetportPin_BSEC() {
  title b "DIP switch status get by Getpin & Getport (BSEC_Mainboard_DIP_SW)"

  while true; do
    print_command "sudo ./idll-test -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section GPI_Mainboard_DIP_SW"
    sudo ./idll-test -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section GPI_Mainboard_DIP_SW

    printf "${COLOR_BLUE_WD}press q to exit ${COLOR_REST}\n"
    read -p "press [q] to exit loop or enter key to retest : " input
    if [ "$input" == "q" ]; then
      break
    fi

  done
}


#===============================================================
#MAIN
#===============================================================
while true; do
  printf "\n"
  printf "${COLOR_RED_WD}1. DIP SWITCH GET PORT/PIN (SCxx/SA3/BSEC_Backplan) ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}2. DIP SWITCH GET PORT/PIN (BSEC_Mainboard_DIP_SW) ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}======================================${COLOR_REST}\n"
  printf "CHOOSE ONE TO TEST: "
  read -p "" input

  if [ "$input" == 1 ]; then
    DipSwitch_GetPortPin
  elif [ "$input" == 2 ]; then
    DipSwitch_GetportPin_BSEC
  fi

done
