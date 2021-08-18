#!/bin/bash
source ./common_func.sh

#check_result(){
#  printf $1
#  printf "${COLOR_BLUE_WD}Expected get pin/port date: ${COLOR_REST}\n"
#  printf "${COLOR_BLUE_WD} $2 ${COLOR_REST}\n"
#  printf "${COLOR_BLUE_WD}============================ ${COLOR_REST}\n"
#
#  if [[ $1 =~ $2 ]]; then
#
#    printf "${COLOR_YELLOW_WD}Get Pin/Port value PASS ${COLOR_REST}\n"
#  else
#    printf "${COLOR_RED_WD}Get Pin/Port value Fail ${COLOR_REST}\n"
#  fi
#
#}

#===============================================================
#USER LED status change by SET PIN (SCXX/SA3X)
#===============================================================
SetPin_Scxx_Sa3x(){
  printf "${COLOR_RED_WD}USER LED status change by SET PIN ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}================================ ${COLOR_REST}\n"
  read -p "press enter key to continue...  "

  rest=$( sudo ./idll-test.exe --PORT_VAL 0 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section User_LED_SetPort )
  rest=$( sudo ./idll-test.exe --PORT_VAL 0 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section Mainboard_User_LED_SetPort )
  rest=$( sudo ./idll-test.exe --PORT_VAL 0 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section User_LED_SetPort )

  for all in 0 1 2 3;do
    for status in "true" "false"; do
      title b "Set up below setting:     \nUSER LED : $all      \nStatus: $status"
#      printcolor b "USER LED : $all"
#      printcolor b "Status: $status"
#      printcolor b "====================="
#      read -p "enter key to continue..." continue
      launch_command "sudo ./idll-test.exe --PIN_NUM $all --PIN_VAL $status -- --EBOARD_TYPE EBOARD_ADi_SA3X --section User_LED_SetPin"
      sleep 1
      case $status in
        true)
          value="value: 1"
          ;;
        false)
          value="value: 0"
          ;;
      esac
      title b "Expected get pin/port data: ( $value )"
      compare_result "$result" "$value"

    done
  done
}

#===============================================================
#USER LED status change by SET PIN BACKPLAN SIDE(BSEC)
#===============================================================
SetPin_Bsec_Backplan(){
  title b "USER LED status change by SET PIN"
  read -p "press enter key to continue...  "

  rest=$( sudo ./idll-test.exe --PORT_VAL 0 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section User_LED_SetPort )
  rest=$( sudo ./idll-test.exe --PORT_VAL 0 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section Mainboard_User_LED_SetPort )
  rest=$( sudo ./idll-test.exe --PORT_VAL 0 -- --EBOARD_TYPE EBOARD_ADi_BSEC --section User_LED_SetPort )

  for all in 0 1 2 3;do
    for status in "true" "false"; do
      title b "Set up below setting:     \nUSER LED : $all      \nStatus: $status"
#      printf "\n"
#      printcolor b "USER LED : $all"
#      printcolor b "Status: $status"
#      printcolor b "====================="

#      read -p "enter key to continue..." continue
      sleep 1
      launch_command "sudo ./idll-test.exe --PIN_NUM $all --PIN_VAL $status -- --EBOARD_TYPE EBOARD_ADi_SA3X --section User_LED_SetPin"

      case $status in
        true)
          value="value: 1"
          ;;
        false)
          value="value: 0"
          ;;
      esac

      title b "Expected get pin/port data: ( $value )"
      compare_result "$result" "$value"

    done
  done
}

#===============================================================
#USER LED status change by SET PIN MAINBOARD SIDE(BSEC)
#===============================================================
SetPin_Bsec_Mainboard(){
  title b "USER LED status change by SET PIN "
  read -p "press enter key to continue..."

  rest=$( sudo ./idll-test.exe --PORT_VAL 0 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section User_LED_SetPort )
  rest=$( sudo ./idll-test.exe --PORT_VAL 0 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section Mainboard_User_LED_SetPort )
  rest=$( sudo ./idll-test.exe --PORT_VAL 0 -- --EBOARD_TYPE EBOARD_ADi_BSEC --section User_LED_SetPort )

  for all in 0 1 2 3;do
    for status in "true" "false"; do
      title b "Set up below setting:     \nUSER LED : $all      \nStatus: $status"
#      printcolor b "USER LED : $all"
#      printcolor b "Status: $status"
#      printcolor b "====================="
#      read -p "enter key to continue..."
      sleep 2
#      launch_command "sudo ./idll-test.exe --PIN_NUM $all --PIN_VAL $status -- --EBOARD_TYPE EBOARD_ADi_BSEC --section User_LED_SetPin"
      launch_command "sudo ./idll-test.exe --PIN_NUM $all --PIN_VAL $status -- --EBOARD_TYPE EBOARD_ADi_SA3X --section Mainboard_User_LED_SetPin"

      case $status in
        true)
          value="value: 1"
          ;;
        false)
          value="value: 0"
          ;;
      esac
      title b "Expected get pin/port data: ( $value )"
      compare_result "$result" "$value"

    done
  done
}

#===============================================================
#(LEC1) MCU USER LED status change by SET PIN
#===============================================================
SetPin_Lec1(){
  title b "(LEC1) MCU USER LED status change by SET PIN"
  read -p "press enter key to test..."

  for all in 0 1 2 3;do
    for status in "true" "false"; do
      title b "Set up below setting:     \nUSER LED : $all      \nStatus: $status"
#      printcolor b "USER LED : $all"
#      printcolor b "Status: $status"
#      printcolor b "====================="
#      read -p "enter key to continue..."
      sleep 2
      launch_command "sudo ./idll-test.exe --PIN_NUM $all --PIN_VAL $status -- --EBOARD_TYPE EBOARD_ADi_BSEC --section Mainboard_User_LED_SetPin"

      case $status in
        true)
          value="value: 1"
          ;;
        false)
          value="value: 0"
          ;;
      esac

      title b "Expected get pin/port data: ( $value )"
      compare_result "$result" "$value"
    done
  done

}

#===============================================================
#USER LED status change by SET PORT (SCXX/SA3X)
#===============================================================
SetPort_Scxx_Sa3(){
  title b "USER LED status change by SET PORT"
  read -p "Press enter key to test..."

  for all in 1 2 4 8 15 0;do
      title b "Set up below setting:     \nUSER LED  Port: $all"
#      printf "\n"
#      printcolor b "USER LED  Port: $all"
#      printcolor b "========================"
#      read -p "enter key to continue test..."
      sleep 2
      launch_command "sudo ./idll-test.exe --PORT_VAL $all -- --EBOARD_TYPE EBOARD_ADi_SA3X --section User_LED_SetPort"

      value="value: $all"
      title b "Expected get pin/port data: ( $value )"
      compare_result "$result" "$value"

  done
}

#===============================================================
#USER LED status change by SET PORT BACKPLAN SIDE (BSEC)
#===============================================================
SetPort_Bsec_Backplan(){
  title b "USER LED status change by SET PORT"
  read -p "Press enter key to test..."

  for all in 1 2 4 8 15 0;do
      title b "Set up below setting:     \nUSER LED  Port: $all"
#      printf "\n"
#      printcolor b "USER LED  Port: $all"
#      printcolor b "========================"
#      read -p "enter key to continue..."
      sleep 2
      launch_command "sudo ./idll-test.exe --PORT_VAL $all -- --EBOARD_TYPE EBOARD_ADi_SA3X --section User_LED_SetPort"

      value="value: $all"
      title b "Expected get pin/port data: ( $value )"
      compare_result "$result" "$value"

  done
}

#===============================================================
#USER LED status change by SET PORT MAINBOARD SIDE (BSEC)
#===============================================================
SetPort_Bsec_Mainboard(){
  title b "USER LED status change by SET PORT"
  read -p "Press enter key to test..."

  for all in 1 2 4 8 15 0;do
      title b "Set up below setting:     \nUSER LED  Port: $all"
#      printf "\n"
#      printcolor b "USER LED  Port: $all"
#      printcolor b "========================"
#      read -p "enter key to continue..."
      sleep 2

      launch_command "sudo ./idll-test.exe --PORT_VAL $all -- --EBOARD_TYPE EBOARD_ADi_BSEC --section User_LED_SetPort"
      value="value: $all"
      title b "Expected get pin/port data: ( $value )"
      compare_result "$result" "$value"
  done
}

#===============================================================
#(LEC1) MCU USER LED status change by SET PORT
#===============================================================
SetPort_Lec1(){
  title b "(LEC1) MCU USER LED status change by SET PORT"
  read -p "press enter key to test .." key

  for all in 1 2 4 8 15 0;do
      title b "Set up below setting:     \nUSER LED  Port: $all"
#      printf "\n"
#      printcolor b "USER LED  Port: $all"
#      printcolor b "========================"
#      read -p "enter key to continue..."
      sleep 2
      launch_command "sudo ./idll-test.exe --PORT_VAL $all -- --EBOARD_TYPE EBOARD_ADi_BSEC --section Mainboard_User_LED_SetPort"

      value="value: $all"
      title b "Expected get pin/port data: ( $value )"
      compare_result "$result" "$value"

  done
}

#===============================================================
#Bad parameter test
#===============================================================
BadParameter(){
  printf "${COLOR_RED_WD}Bad parameter test  ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}=================== ${COLOR_REST}\n"

  print_command "sudo ./idll-test.exe --PORT_VAL W -- --EBOARD_TYPE EBOARD_ADi_SA3X --section User_LED_SetPort"
  sudo ./idll-test.exe --PORT_VAL W -- --EBOARD_TYPE EBOARD_ADi_SA3X --section User_LED_SetPort
  print_command "sudo ./idll-test.exe --PIN_NUM 1 --PIN_VAL 99999999 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section User_LED_SetPin"
  sudo ./idll-test.exe --PIN_NUM 1 --PIN_VAL 99999999 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section User_LED_SetPin
  print_command "sudo ./idll-test.exe --PIN_NUM 999 --PIN_VAL 1 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section User_LED_SetPin"
  sudo ./idll-test.exe --PIN_NUM 999 --PIN_VAL 1 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section User_LED_SetPin
}


#===============================================================
#main
#===============================================================

while true; do
  printf  "\n"
  printf  "${COLOR_RED_WD}1. (SCXX/SA3X/LEC1) SET PIN ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}2. (BSEC) SET PIN BACKPLAN ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}3. (BSEC) SET PIN MAINBOARD${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}4. (LEC1) SET PIN MCU USER LED${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}5. (SCXX/SA3X/LEC1) SET PORT ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}6. (BSEC) SET PORT BACKPLAN ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}7. (BSEC) SET PORT MAINBOARD ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}8. (LEC1) SET PORT MCU USER LED  ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}9. BAD PARAMETER ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}======================================${COLOR_REST}\n"
  printf  "CHOOSE ONE TO TEST: "
  read -p "" input

  if [ "$input" == 1 ]; then
    SetPin_Scxx_Sa3x
  elif [ "$input" == 2 ]; then
    SetPin_Bsec_Backplan
  elif [ "$input" == 3 ]; then
    SetPin_Bsec_Mainboard
  elif [ "$input" == 4 ]; then
    SetPin_Lec1

  elif [ "$input" == 5 ]; then
    SetPort_Scxx_Sa3
  elif [ "$input" == 6 ]; then
    SetPort_Bsec_Backplan
  elif [ "$input" == 7 ]; then
    SetPort_Bsec_Mainboard
  elif [ "$input" == 8 ]; then
    SetPort_Lec1
  elif [ "$input" == 9 ]; then
    BadParameter
  fi

done