#!/bin/bash
source ./common_func.sh

#===============================================================
#Blinking function test
#===============================================================
Blink() {
  local period=2000
  local duty_cycle=50
  local result
  if [ "$1" == "scxx" ]; then
    led_amount=31
    period_verify_value=("0" "1" "2" "100" "5000" "40000" "65500" "65535")
    duty_cycle_value=("1" "19" "20" "49" "50" "80" "99")
  elif [ "$1" == "sa3" ]; then
    led_amount=15
    period_verify_value=("0" "1" "2" "100" "5000" "40000" "65500" "65535")
    duty_cycle_value=("1" "19" "20" "49" "50" "80" "99")
  elif [ "$1" == "lec1" ]; then
    led_amount=31
    period_verify_value=("2" "100" "5000" "40000" "65500" "65535")
    duty_cycle_value=("1" "19" "20" "49" "50" "80" "99")
  fi
  ########################################################################
  #loop all pin test
  title b "Now will loop 100 times to check if the set/get port are the same"
  read -p "input [q] to skip or enter to test..." input

  if [ "$input" != "q" ]; then
    repeat_blink
  fi

  ###########################################################################
  #test basic blink / period test
  title b "Reset blinking function...   reset all port to high, before test... "
  if [ "$1" == "sa3" ]; then
    for (( i = 0; i < 16; i++ )); do
      launch_command "sudo ./idll-test.exe --PIN_NUM $i --PERIOD 0 --DUTY_CYCLE 99 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetDoLedBlink"
    done
    launch_command "sudo ./idll-test.exe --PORT_VAL 4294967295 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetPort"
#    compare_result "$result" "Port value: 65535"
  else
    for (( i = 0; i < 32; i++ )); do
      launch_command "sudo ./idll-test.exe --PIN_NUM $i --PERIOD 0 --DUTY_CYCLE 99 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetDoLedBlink"
    done
    launch_command "sudo ./idll-test.exe --PORT_VAL 4294967295 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetPort"

  fi

  title b "Change DUTY CYCLE value"
  for all in $(seq 0 $led_amount); do

    for duty_cyclell in "${duty_cycle_value[@]}"; do
      scxx=$(echo "$period*0.1" | bc)
      printf "${COLOR_BLUE_WD}LED: $all ${COLOR_REST}\n"
      printf "${COLOR_BLUE_WD}Duty cycle:${COLOR_RED_WD} $duty_cyclell ${COLOR_REST}\n"
      printf "${COLOR_BLUE_WD}period (LEC1: 0/1=disable blinking): $period = $(($period * 10))ms ${COLOR_REST}\n"
      printf "${COLOR_BLUE_WD}period (SCxx/SA3 : 0/1=disable blinking): $period = $scxx ms ${COLOR_REST}\n"
      read -p "enter key to continue above test..." continue

      launch_command "sudo ./idll-test.exe --PIN_NUM $all --PERIOD $period --DUTY_CYCLE $duty_cyclell -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetDoLedBlink"
      if [[ "$result" =~ "failed" && "$result" =~ "nReadDutyCycle == nDutyCycle" && "$result" =~ "Duty cycle: $duty_cyclell" ]]; then
        printcolor g "============================================"
        printcolor g "Result PASS include : Duty cycle: $duty_cyclell"
        printcolor g "============================================"
      elif [[ "$result" =~ "Duty cycle: $duty_cyclell" ]]; then
        printcolor g "============================================"
        printcolor g "Result PASS include : Duty cycle: $duty_cyclell"
        printcolor g "============================================"
      else
        printcolor r "============================================"
        printcolor r "Result: FAIL"
        printcolor r "============================================"

      fi
      echo ""
#      compare_result "$result" "Duty cycle: $duty_cyclell"
      #read -p "enter key to continue..." continue

      #sleep 1
    done

    printf "${COLOR_RED_WD}Change PERIOD value ${COLOR_REST}\n"
    printf "${COLOR_RED_WD}======================= ${COLOR_REST}\n\n"
    read -p "enter key to continue..." continue

    for perioddd in "${period_verify_value[@]}"; do
      scxx=$(echo "$perioddd*0.1" | bc)
      printf "${COLOR_BLUE_WD}LED: $all ${COLOR_REST}\n"
      printf "${COLOR_BLUE_WD}Duty cycle: $duty_cycle ${COLOR_REST}\n"
      printf "${COLOR_BLUE_WD}period(LEC1 : 0/1=disable blinking): ${COLOR_RED_WD}$perioddd  = $(($perioddd * 10))ms ${COLOR_REST}\n"
      printf "${COLOR_BLUE_WD}period(SCxx/SA3: 0=disable blinking): ${COLOR_RED_WD}$perioddd  = $scxx ms ${COLOR_REST}\n"

      if [ $perioddd == 0 ] || [ $perioddd == 1 ]; then
        printf "${COLOR_RED_WD}Note: (LEC1) period =1/0 should stopping blinking!! \n${COLOR_REST}"
        printf "${COLOR_RED_WD}Note: (SCxx/SA3) period = 0 should stopping blinking!! \n${COLOR_REST}"
      fi

      read -p "enter key to continue above test..." continue


      launch_command "sudo ./idll-test.exe --PIN_NUM $all --PERIOD $perioddd --DUTY_CYCLE $duty_cycle -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetDoLedBlink"
      if [[ "$result" =~ "failed" && "$result" =~ "nReadDutyCycle == nDutyCycle" && "$result" =~ "Period: $perioddd" ]]; then
        printcolor g "============================================"
        printcolor g "Result PASS include : Period: $perioddd"
        printcolor g "============================================"
      elif [[ "$result" =~ "Period: $perioddd" ]]; then
        printcolor g "============================================"
        printcolor g "Result PASS include : Period: $perioddd"
        printcolor g "============================================"
      else
        printcolor r "============================================"
        printcolor r "Result: FAIL"
        printcolor r "============================================"

      fi
      echo ""
#      compare_result "$result" "Period: $perioddd"

    done

    title b "Start to disable LED blinking function"
    printcolor r "(SCxx/SA3) LED: $all should be back to solid on as it's set port before ..."
    printcolor r "(LEC1) LED: $all won't keep its original state, it on/off randomly ..."
    read -p "enter key to continue..." continue
    print_command "sudo ./idll-test.exe --PIN_NUM $all --PERIOD 0 --DUTY_CYCLE 99 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetDoLedBlink"
    sudo ./idll-test.exe --PIN_NUM $all --PERIOD 0 --DUTY_CYCLE 99 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetDoLedBlink

  done

  title b "All LED should be OFF"
  read -p "enter key to continue..." continue
  sudo ./idll-test.exe --PORT_VAL 0 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetPort


}

repeat_blink(){
  for (( i = 0; i < 100; i++ )); do
    random_period=$(shuf -i 2-65535 -n 1)
    random_duty=$(shuf -i 1-99 -n 1)
    random_pin=$(shuf -i 0-$led_amount -n 1)
    launch_command "sudo ./idll-test.exe --PIN_NUM $random_pin --PERIOD $random_period --DUTY_CYCLE $random_duty -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetDoLedBlink"
#    compare_result "$result" "Period: $random_period"
#    compare_result "$result" "Duty cycle: $random_duty"
    if [[ "$result" =~ "failed" && "$result" =~ "nReadDutyCycle == nDutyCycle"  ]]; then
      printcolor g "============================================"
      printcolor g "Result: PASS"
      printcolor g "============================================"
    elif [[ "$result" =~ "Period: $random_period" || "$result" =~ "Duty cycle: $random_duty" ]]; then
      printcolor g "============================================"
      printcolor g "Result: PASS"
      printcolor g "============================================"
    else
      printcolor r "============================================"
      printcolor r "Result: FAIL"
      printcolor r "============================================"

    fi
  done
#  sudo ./idll-test.exe --PORT_VAL 0 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetPort
#  sudo ./idll-test.exe --PIN_NUM 65535 --PERIOD 0 --DUTY_CYCLE 0 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetDoLedBlink
}

All_blink(){
  printcolor w "How many led is supported for the project?"
  read -p "" amount

  for (( i = 0; i < amount; i++ )); do
    launch_command "sudo ./idll-test.exe --PIN_NUM $i --PERIOD 1000 --DUTY_CYCLE 50 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetDoLedBlink"
  done

  while true ; do
    printf "Press 'x' to reset LED / exit the blink loop.. \r"

    read -rsn 1 -t 0.01 input

    if [ "$input" == "x" ]; then

      for (( x = 0; x < amount; x++ )); do
        launch_command "sudo ./idll-test.exe --PIN_NUM $x --PERIOD 0 --DUTY_CYCLE 50 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetDoLedBlink"
      done
      return
    fi

  done


}

#===============================================================
#Brightness for LEC1 A3
#===============================================================
## this script need to add correct script
Brightness(){
  brightness=("10" "9" "8" "7" "6" "5" "4" "3" "2" "1" "0")
  for led in $(seq 0 11);do
    for brightness_value in "${brightness[@]}"; do
      printcolor r "LED: $led"
      printcolor r "Setting Brightness: $brightness_value"

      if [ "$brightness_value" == 0 ]; then
        printcolor r "Note: the LED will stop blinking/ turned LED OFF, while brightness = 0"
      elif [ "$brightness_value" == 10 ]; then
        printcolor r "Note: the LED will stop blinking/ turned LED SOLID ON, while brightness = 10"
      fi

      printcolor w "Enter to test brightness setting."
      read -p ""
      launch_command "sudo ./idll-test.exe --PIN_NUM $led --BLINK 100 --DUTY_CYCLE 50 --BRIGHTNESS $brightness_value -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_Drive_SetBlink"
      compare_result "result" "$brightness_value"

    done

  done

}

Brightness_loop(){
  local value led
  for all in $(seq 0 100); do
    value=$(shuf -i 0-10 -n 1)
    led=$(shuf -i 0-31 -n 1)
    launch_command "sudo ./idll-test.exe --PIN_NUM $led --BLINK 100 --DUTY_CYCLE 50 --BRIGHTNESS $value -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_Drive_SetBlink"
    compare_result "result" "$value"

  done
}


#===============================================================
#LED Set port function test
#===============================================================
SetPort() {
  num=(
    $((2#00000000000000000000000000000001))
    $((2#00000000000000000000000000000010))
    $((2#00000000000000000000000000000100))
    $((2#00000000000000000000000000001000))
    $((2#00000000000000000000000000010000))
    $((2#00000000000000000000000000100000))
    $((2#00000000000000000000000001000000))
    $((2#00000000000000000000000010000000))
    $((2#00000000000000000000000100000000))
    $((2#00000000000000000000001000000000))
    $((2#00000000000000000000010000000000))
    $((2#00000000000000000000100000000000))
    $((2#00000000000000000001000000000000))
    $((2#00000000000000000010000000000000))
    $((2#00000000000000000100000000000000))
    $((2#00000000000000001000000000000000))
    $((2#00000000000000010000000000000000))
    $((2#00000000000000100000000000000000))
    $((2#00000000000001000000000000000000))
    $((2#00000000000010000000000000000000))
    $((2#00000000000100000000000000000000))
    $((2#00000000001000000000000000000000))
    $((2#00000000010000000000000000000000))
    $((2#00000000100000000000000000000000))
    $((2#00000001000000000000000000000000))
    $((2#00000010000000000000000000000000))
    $((2#00000100000000000000000000000000))
    $((2#00001000000000000000000000000000))
    $((2#00010000000000000000000000000000))
    $((2#00100000000000000000000000000000))
    $((2#01000000000000000000000000000000))
    $((2#10000000000000000000000000000000))
    $((2#11111111111111111111111111111111))
    $((2#00000000000000000000000000000000))
    )

  num_sa3=(
    $((2#0000000000000000))
    $((2#1111111111111111))
    )

  if [ "$1" == "scxx" ] || [ "$1" == "lec1" ]; then
      num_actual=("${num[@]}")
#      printf "num_actual=${num_actual[*]}\n"
#      printf "num_actual[0]=${num_actual[0]}\n"
  elif [ "$1" == "sa3" ]; then
    for (( i = 0; i < 18; i++ )); do
        num_actual[$i]=${num[$i]}
        if [ "$i" == 16 ]; then
          num_actual[$i]=${num_sa3[0]}
        elif [ "$i" == 17 ]; then
          num_actual[$i]=${num_sa3[1]}
        fi

#          printf "num_actual=${num_actual[*]}\n"
    done

  fi

  title b "All LED setport test"
  read -p "enter key to continue..." continue

  for i in ${num_actual[*]}; do
    printcolor r $i
    print_command "sudo ./idll-test.exe --PORT_VAL $i -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetPort"
    launch_command "sudo ./idll-test.exe --PORT_VAL $i -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetPort"
    compare_result "$result" "Port value: $i"
    sleep 1
  done

  sudo ./idll-test.exe --PORT_VAL 0 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetPort
  title b "Now will loop 1000 times to check if the set/get port are the same"
  read -p "input [q] to skip or enter to test..." input

  if [ "$input" != "q" ]; then
    for (( i = 0; i < 1000; i++ )); do
      random=$(shuf -i 0-$((${#num_actual[@]}-1)) -n 1)
      printcolor y "random=$random"

      launch_command "sudo ./idll-test.exe --PORT_VAL ${num_actual[$random]} -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetPort"
      compare_result "$result" "Port value: ${num_actual[$random]}"
    done
    #reset all port to light off
   launch_command "sudo ./idll-test.exe --PORT_VAL 0 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetPort"
  fi

}

#===============================================================
#LED Set pin function test
#===============================================================
SetPin() {
  printf "${COLOR_RED_WD}All LED setpin test ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}====================${COLOR_REST}\n"
  read -p "enter key to continue..." continue

  if [ "$1" == "scxx" ] || [ "$1" == "lec1" ]; then
      num_pin=31
  elif [ "$1" == "sa3" ]; then
      num_pin=15
  fi

  for all in $(seq 0 $num_pin); do
    launch_command "sudo ./idll-test.exe --PIN_NUM $all --PIN_VAL true -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetPin"
    compare_result "$result" "Pin number: $all, Pin value: 1"
    sleep 1
    launch_command "sudo ./idll-test.exe --PIN_NUM $all --PIN_VAL false -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetPin"
    compare_result "$result" "Pin number: $all, Pin value: 0"
  done

  title b "Now will loop 1000 times to check if the set/get pin are the same"
  read -p "input [q] to skip or enter to test..." input

  if [ "$input" != "q" ]; then
    for (( i = 0; i < 1000; i++ )); do
      random=$(shuf -i 0-$num_pin -n 1)
      launch_command "sudo ./idll-test.exe --PIN_NUM $random --PIN_VAL true -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetPin"
      compare_result "$result" "Pin number: $random, Pin value: 1"
      launch_command "sudo ./idll-test.exe --PIN_NUM $random --PIN_VAL false -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetPin"
      compare_result "$result" "Pin number: $random, Pin value: 0"
    done
    #reset all port to light off
    launch_command "sudo ./idll-test.exe --PORT_VAL 0 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetPort"
  fi
}

#===============================================================
#Bad parameter test
#===============================================================
BadParameter() {
  printf "${COLOR_RED_WD}Bad parameter test ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}===================${COLOR_REST}\n"
  read -p "enter key to continue..."

  command_line=(
  "sudo ./idll-test.exe --PIN_NUM 9999999 --PIN_VAL true -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetPin"
  "sudo ./idll-test.exe --PIN_NUM 1 --PIN_VAL dd -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetPin"
  "sudo ./idll-test.exe --PORT_VAL 999999999999999 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetPort"
  "sudo ./idll-test.exe --PIN_NUM 0 --PERIOD 65536 --DUTY_CYCLE 99 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetDoLedBlink"
  "sudo ./idll-test.exe --PIN_NUM 0 --PERIOD 0 --DUTY_CYCLE 100 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetDoLedBlink"
  )

  for command in "${command_line[@]}";do
    launch_command "$(echo "$command")"
    compare_result "$result" "failed" "skip"
  done

}

#===============================================================
#MAIN
#===============================================================
while true; do
  printf "\n"
  printf "${COLOR_RED_WD}1. (SCXX) BLINK ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}2. (LEC1) BLINK ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}3. (SA3X) BLINK ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}4. (SCXX/LEC1/BSEC)SET PORT ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}5. (SCXX/LEC1/BSEC)SET PIN ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}6. (SA3)SET PORT ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}7. (SA3)SET PIN ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}8. BRIGHTNESS ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}9. BLINK LOOP ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}10. BAD PARAMETER ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}======================================${COLOR_REST}\n"
  printf "CHOOSE ONE TO TEST: "
  read -p "" input

  if [ "$input" == 1 ]; then
    Blink scxx
  elif [ "$input" == 2 ]; then
    Blink lec1
  elif [ "$input" == 3 ]; then
    Blink sa3
  elif [ "$input" == 4 ]; then
    SetPort scxx
  elif [ "$input" == 5 ]; then
    SetPin scxx
  elif [ "$input" == 6 ]; then
    SetPort sa3
  elif [ "$input" == 7 ]; then
    SetPin sa3
  elif [ "$input" == 8 ]; then
    SetPin Brightness
  elif [ "$input" == 9 ]; then
    All_blink
  elif [ "$input" == 10 ]; then
    BadParameter

  fi

done
