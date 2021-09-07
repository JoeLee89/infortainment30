#!/bin/bash
source ./common_func.sh

num=(
  $((2#0001))
  $((2#0010))
  $((2#0100))
  $((2#0111))
  )
#===============================================================
# All LED setport test
#===============================================================
SetPort() {
  local i
  title b "All LED setport test"

  for i in ${num[*]}; do
#    launch_command "sudo ./idll-test.exe --PORT_VAL $i -- --EBOARD_TYPE EBOARD_ADi_SC1X --section HighCurrent_LED_SetPort"
    print_command "sudo ./idll-test.exe --PORT_VAL $i -- --EBOARD_TYPE EBOARD_ADi_SC1X --section HighCurrent_LED_SetPort"

    result=$(sudo ./idll-test.exe --PORT_VAL "$i" -- --EBOARD_TYPE EBOARD_ADi_SC1X --section HighCurrent_LED_SetPort)
    echo "$result"
    result=$(echo "$result" | grep -i "Port value:" | sed 's/\r//g')
    compare_result "$result" "Port value: $i"
    sleep 2
  done

  reset=$(sudo ./idll-test.exe --PORT_VAL 0 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section HighCurrent_LED_SetPort)
}

#===============================================================
# All LED setport test
#===============================================================
SetPin() {
  title "All LED setpin test"
  read -p "enter key to continue..."

  for all in $(seq 0 2); do
    print_command "sudo ./idll-test.exe --PIN_NUM $all --PIN_VAL true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section HighCurrent_LED_SetPin"
    result=$(sudo ./idll-test.exe --PIN_NUM $all --PIN_VAL true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section HighCurrent_LED_SetPin)
    echo "$result"
    result1=$(echo "$result" | grep -i "Pin number:" | sed 's/\r//g' )
    result2=$(echo "$result" | grep -i "Pin value: 1" | sed 's/\r//g' )
    compare_result "$result1" "Pin number: $all"
    compare_result "$result2" "Pin value: 1"
    sleep 2

    print_command "sudo ./idll-test.exe --PIN_NUM $all --PIN_VAL false -- --EBOARD_TYPE EBOARD_ADi_SC1X --section HighCurrent_LED_SetPin"
    result=$(sudo ./idll-test.exe --PIN_NUM $all --PIN_VAL false -- --EBOARD_TYPE EBOARD_ADi_SC1X --section HighCurrent_LED_SetPin)
    echo "$result"
    result1=$(echo "$result" | grep -i "Pin number:" | sed 's/\r//g' )
    result2=$(echo "$result" | grep -i "Pin value: 0" | sed 's/\r//g' )
    compare_result "$result" "Pin number: $all"
    compare_result "$result" "Pin value: 0"
  done
}

#===============================================================
# paramenter
#===============================================================
BadParameter() {
  title b "Bad parameter test"
  read -p "enter key to continue..."
  launch_command "sudo ./idll-test.exe --PIN_NUM 999999999 --PIN_VAL true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section HighCurrent_LED_SetPin"
  launch_command "sudo ./idll-test.exe --PIN_NUM 1 --PIN_VAL gsf -- --EBOARD_TYPE EBOARD_ADi_SC1X --section HighCurrent_LED_SetPin"
  launch_command "sudo ./idll-test.exe --PORT_VAL 66666666666666666 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section HighCurrent_LED_SetPort"
}


#=====================================================================================
#MAIN
#=====================================================================================
while true; do
  printf  "${COLOR_RED_WD}1. SETPORT${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}2. SETPIN${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}3. PARAMETER${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}==================================${COLOR_REST}\n"
  printf  "CHOOSE ONE TO TEST: \n"
  read -p "" input

  if [ "$input" == 1 ]; then
    SetPort
  elif [ "$input" == 2 ]; then
    SetPin
  elif [ "$input" == 3 ]; then
    BadParameter
  fi

done