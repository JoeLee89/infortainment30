#!/bin/bash
source ./common_func.sh

#===============================================================
#Check intrusion port by getport
#===============================================================

IntruGetPort() {
  title b "Check intrusion port by getport"

  while true; do
    print_command "sudo ./idll-test -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section PIC_Intrusion_ports"
    sudo ./idll-test -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section PIC_Intrusion_ports

    read -p "q to exit " leave
    if [ "$leave" == "q" ]; then
      break
    fi

  done
}

#===============================================================
#check PIC intrution event from PIC even log
#===============================================================
IntruGetEvent() {
  title b "Now check PIC intrution event from PIC even log"

  while true; do
    print_command "sudo ./idll-test -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section PIC_GetPICEvent_and_DisplayEventTime"
    sudo ./idll-test -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section PIC_GetPICEvent_and_DisplayEventTime

    read -p "Enter to test again, or press [q] to exit " leave
    if [ "$leave" == "q" ]; then
      break
    fi

  done
}

#===============================================================
#check PIC intrusion call back function auto test
#===============================================================
IntruCallback_Auto() {
  title b "Now check PIC intrusion call back function auto test"
  print_command "sudo ./idll-test -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section Callback_PIC_Intrusion_Auto [CALLBACK][PIC][UNITTEST]"
  sudo ./idll-test -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section Callback_PIC_Intrusion_Auto [CALLBACK][PIC][UNITTEST]
}

#===============================================================
#check PIC intrusion call back function 3 mode open/close/open_close
#===============================================================
mask_setting(){
  local m input
  m=$1
  input=$2
  target_bin=""
  for (( i = 0; i < input; i++ )); do
   if [ "$m" -eq 0 ]; then
     ((m++))
   else
     ((m--))
   fi
   target_bin=$m$target_bin
   target_dec=$((2#$target_bin))
  done
}


IntruCallback_Manual_3Mode() {
  title b "Now check PIC intrusion call back function 3 mode open/close/open_close"
  read -p "How many supported intrusion pin : " input
  mask_setting "0" "$input"

  for i in "OPEN" "CLOSE" "OPEN_OR_CLOSE"; do
      printf "${COLOR_BLUE_WD}Now pinmask set ${COLOR_YELLOW_WD}$target_bin ${COLOR_BLUE_WD}PIC intrusion available ${COLOR_REST}\n"

      printf "${COLOR_BLUE_WD}trigger mode = ${COLOR_YELLOW_WD}$i ${COLOR_REST}\n"
      printf "${COLOR_BLUE_WD}=============================================== ${COLOR_REST}\n"
      print_command "sudo ./idll-test --pic-cb-intr-pinmask $target_dec --pic-cb-intr-event $i -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section Callback_PIC_Intrusion_Manu [CALLBACK][PIC][MANU]"
      sudo ./idll-test --pic-cb-intr-pinmask $target_dec --pic-cb-intr-event $i -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section Callback_PIC_Intrusion_Manu [CALLBACK][PIC][MANU]

  done
  mask_setting "1" "$input"
#  target_bin=$((target_bin>>1))

  for i in "OPEN" "CLOSE" "OPEN_OR_CLOSE"; do
      printf "${COLOR_BLUE_WD}Now pinmask set ${COLOR_YELLOW_WD}$target_bin ${COLOR_BLUE_WD}PIC intrusion available ${COLOR_REST}\n"

      printf "${COLOR_BLUE_WD}trigger mode = ${COLOR_YELLOW_WD}$i ${COLOR_REST}\n"
      printf "${COLOR_BLUE_WD}=============================================== ${COLOR_REST}\n"
      print_command "sudo ./idll-test --pic-cb-intr-pinmask $target_dec --pic-cb-intr-event $i -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section Callback_PIC_Intrusion_Manu [CALLBACK][PIC][MANU]"
      sudo ./idll-test --pic-cb-intr-pinmask $target_dec --pic-cb-intr-event $i -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section Callback_PIC_Intrusion_Manu [CALLBACK][PIC][MANU]

  done

  #test the mask set to 0 behavior
  printf "${COLOR_BLUE_WD}Now pinmask set ${COLOR_YELLOW_WD}0000 0000 ${COLOR_BLUE_WD}PIC intrusion availble ${COLOR_REST}\n"
  printf "${COLOR_BLUE_WD}trigger mode =  ${COLOR_YELLOW_WD}OPEN_OR_CLOSE ${COLOR_REST}\n"
  printf "${COLOR_BLUE_WD}================================================= ${COLOR_REST}\n"
  launch_command "sudo ./idll-test --pic-cb-intr-pinmask 0 --pic-cb-intr-event OPEN_OR_CLOSE -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section Callback_PIC_Intrusion_Manu [CALLBACK][PIC][MANU]"
  compare_result "$result" "failed"
}

#===============================================================
#main
#===============================================================
while true; do
  printf "\n"
  printf "${COLOR_RED_WD}1. INTRUSION GET PORT${COLOR_REST}\n"
  printf "${COLOR_RED_WD}2. GET STATUS BY EVENT${COLOR_REST}\n"
  printf "${COLOR_RED_WD}3. INTRUSION CALLBACK AUTO${COLOR_REST}\n"
  printf "${COLOR_RED_WD}4. INTRUSION CALLBACK WITH 3 MODE (open/close/open_close) ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}=========================================================${COLOR_REST}\n"
  printf "CHOOSE ONE TO TEST: "
  read -p "" input

  if [ "$input" == 1 ]; then
    IntruGetPort
  elif [ "$input" == 2 ]; then
    IntruGetEvent
  elif [ "$input" == 3 ]; then
    IntruCallback_Auto
  elif [ "$input" == 4 ]; then
    IntruCallback_Manual_3Mode
  fi

done
