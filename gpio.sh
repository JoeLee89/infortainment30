#!/bin/bash
source ./common_func.sh

#===============================================================
#Set/Get Port
#===============================================================
set_get_port(){
  for (( i = 0; i < 16; i++ )); do
#    launch_command "sudo ./idll-test.exe --GPIO_PORT_VAL $i -- --EBOARD_TYPE EBOARD_ADi_"$board" --section SA3X_4xGPIO_by_Port"
    print_command "sudo ./idll-test.exe --GPIO_PORT_VAL $i -- --EBOARD_TYPE EBOARD_ADi_"$board" --section SA3X_4xGPIO_by_Port"
    result00=$(sudo ./idll-test.exe --GPIO_PORT_VAL $i -- --EBOARD_TYPE EBOARD_ADi_"$board" --section SA3X_4xGPIO_by_Port)
    result=$(sudo ./idll-test.exe --GPIO_PORT_VAL $i -- --EBOARD_TYPE EBOARD_ADi_"$board" --section SA3X_4xGPIO_by_Port | grep -i "adiGpioGetPort" |  sed 's/\\n//g')
    echo "$result00"

    j=$( echo "obase=16;$i"|bc )
    if [ "$i" -gt 0 ]; then
      if [[ "$result" =~ "adiGpioGetPort(0x$j$j)" ]]; then
        printcolor g "Test result is Pass"
        printcolor g "Test result includes adiGpioGetPort(0x$j$j)"
        echo ""

      else

        printcolor r "Test result is Failed"
        printcolor g "Test result doesn't include adiGpioGetPort(0x$j$j)"
        read -p ""
      fi

    else

      if [[ "$result" =~ "adiGpioGetPort(0x$j)" ]]; then
        printcolor g "Test result is Pass"
        printcolor g "Test result doesn't include adiGpioGetPort(0x$j)"
        echo ""

      else

        printcolor r "Test result is Failed"
        printcolor g "Test result doesn't include adiGpioGetPort(0x$j)"
        read -p ""
        echo ""
      fi

    fi

  done

  ################################################################################
  title b "Now will loop 1000 times to check if the set/get port are the same"
  read -p "input [q] to skip or enter to test..." input

  if [ "$input" != "q" ]; then
    for (( i = 0; i < 1000; i++ )); do
      random=$(shuf -i 0-15 -n 1)
      j_random=$( echo "obase=16;$random"|bc )
      launch_command "sudo ./idll-test.exe --GPIO_PORT_VAL $random -- --EBOARD_TYPE EBOARD_ADi_"$board" --section SA3X_4xGPIO_by_Port"

      if [ "$random" -gt 0 ]; then
        compare_result "$result" "(0x$j_random$j_random)"
      else
        compare_result "$result" "(0x$j_random)"
      fi

    done
  fi


}



set_get_pin(){

  for (( i = 0; i < 4; i++ )); do
    for state in "true" "false"; do
      launch_command "sudo ./idll-test.exe --GPIO_PIN_ID 0x$i --GPIO_PIN_VAL $state -- --EBOARD_TYPE EBOARD_ADi_"$board" --section SA3X_4xGPIO_by_Pin"
      compare_result "$result" "Read back pin value: $state"
      launch_command "sudo ./idll-test.exe --GPIO_PIN_ID 0x$((i+4)) --GPIO_PIN_VAL $state -- --EBOARD_TYPE EBOARD_ADi_"$board" --section SA3X_4xGPIO_by_Pin"
      compare_result "$result" "Read back pin value: $state"
    done

  done

##################################################################################
  title b "Now will loop 1000 times to check if the set/get port are the same"
  read -p "input [q] to skip or enter to test..." input

  if [ "$input" != "q" ]; then
    for (( i = 0; i < 1000; i++ )); do
      random=$(shuf -i 0-3 -n 1)

      for state in "true" "false"; do
        launch_command "sudo ./idll-test.exe --GPIO_PIN_ID 0x$random --GPIO_PIN_VAL $state -- --EBOARD_TYPE EBOARD_ADi_"$board" --section SA3X_4xGPIO_by_Pin"
        compare_result "$result" "Read back pin value: $state"
        launch_command "sudo ./idll-test.exe --GPIO_PIN_ID 0x$((random+4)) --GPIO_PIN_VAL $state -- --EBOARD_TYPE EBOARD_ADi_"$board" --section SA3X_4xGPIO_by_Pin"
        compare_result "$result" "Read back pin value: $state"
      done

    done
  fi



}

#===============================================================
#Bad parameter test
#===============================================================
BadParameter() {
  printf "${COLOR_RED_WD}Bad parameter test ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}===================${COLOR_REST}\n"
  read -p "enter key to continue..." continue

  printf "${COLOR_RED_WD}sudo ./idll-test.exe --GPIO_PIN_ID 0x99 --GPIO_PIN_VAL true -- --EBOARD_TYPE EBOARD_ADi_"$board" --section SA3X_4xGPIO_by_Pin ${COLOR_REST}\n"
  sudo ./idll-test.exe --GPIO_PIN_ID 0x99 --GPIO_PIN_VAL true -- --EBOARD_TYPE EBOARD_ADi_"$board" --section SA3X_4xGPIO_by_Pin

  printf "${COLOR_RED_WD}sudo ./idll-test.exe --GPIO_PORT_VAL 65535 -- --EBOARD_TYPE EBOARD_ADi_"$board" --section SA3X_4xGPIO_by_Port ${COLOR_REST}\n"
  sudo ./idll-test.exe --GPIO_PORT_VAL 65535 -- --EBOARD_TYPE EBOARD_ADi_"$board" --section SA3X_4xGPIO_by_Port


}

#===============================================================
#MAIN
#===============================================================
while true; do
  printf "\n"
  printf "${COLOR_RED_WD}1. SET PORT ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}2. SET PIN ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}3. BAD PARAMETER ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}======================================${COLOR_REST}\n"
  printf "CHOOSE ONE TO TEST: "
  read -p "" input

  if [ "$input" == 1 ]; then
    set_get_port
  elif [ "$input" == 2 ]; then
    set_get_pin
  elif [ "$input" == 3 ]; then
    BadParameter
  fi

done
