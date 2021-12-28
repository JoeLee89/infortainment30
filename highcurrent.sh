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
#    launch_command "sudo ./idll-test.exe --PORT_VAL $i -- --EBOARD_TYPE EBOARD_ADi_"$board" --section HighCurrent_LED_SetPort"
    print_command "sudo ./idll-test.exe --PORT_VAL $i -- --EBOARD_TYPE EBOARD_ADi_"$board" --section HighCurrent_LED_SetPort"

    result=$(sudo ./idll-test.exe --PORT_VAL "$i" -- --EBOARD_TYPE EBOARD_ADi_"$board" --section HighCurrent_LED_SetPort)
    echo "$result"
    result=$(echo "$result" | grep -i "Port value:" | sed 's/\r//g')
    compare_result "$result" "Port value: $i"
    sleep 2
  done

  reset=$(sudo ./idll-test.exe --PORT_VAL 0 -- --EBOARD_TYPE EBOARD_ADi_"$board" --section HighCurrent_LED_SetPort)
}

#===============================================================
# All LED setport test
#===============================================================
SetPin() {
  title "All LED setpin test"
  read -p "enter key to continue..."

  for all in $(seq 0 2); do
    print_command "sudo ./idll-test.exe --PIN_NUM $all --PIN_VAL true -- --EBOARD_TYPE EBOARD_ADi_"$board" --section HighCurrent_LED_SetPin"
    result=$(sudo ./idll-test.exe --PIN_NUM $all --PIN_VAL true -- --EBOARD_TYPE EBOARD_ADi_"$board" --section HighCurrent_LED_SetPin)
    echo "$result"
    result1=$(echo "$result" | grep -i "Pin number:" | sed 's/\r//g' )
    result2=$(echo "$result" | grep -i "Pin value: 1" | sed 's/\r//g' )
    compare_result "$result1" "Pin number: $all"
    compare_result "$result2" "Pin value: 1"
    sleep 2

    print_command "sudo ./idll-test.exe --PIN_NUM $all --PIN_VAL false -- --EBOARD_TYPE EBOARD_ADi_"$board" --section HighCurrent_LED_SetPin"
    result=$(sudo ./idll-test.exe --PIN_NUM $all --PIN_VAL false -- --EBOARD_TYPE EBOARD_ADi_"$board" --section HighCurrent_LED_SetPin)
    echo "$result"
    result1=$(echo "$result" | grep -i "Pin number:" | sed 's/\r//g' )
    result2=$(echo "$result" | grep -i "Pin value: 0" | sed 's/\r//g' )
    compare_result "$result" "Pin number: $all"
    compare_result "$result" "Pin value: 0"
  done
}

#===============================================================
#Blinking function test
#===============================================================
Blink() {
  local period=2000
  local duty_cycle=50
  local result
  local led_amount
  local period_verify_value=("1" "99" "151" "1000" "9999" "10000")
  local duty_cycle_value=("1" "19" "20" "49" "50" "80" "99")
  ########################################################################
  printcolor r "How many DO pins is the project supported?"
  read -p "" amount
  led_amount=${led_amount:-2}
  ((led_amount-1))

  #loop all pin test
  title b "Now will loop 100 times to check if the set/get port are the same"
  read -p "input [q] to skip or enter to test..." input

  if [ "$input" != "q" ]; then
    repeat_blink $led_amount
  fi

  ###########################################################################
  #test basic blink / period test
  title b "Reset blinking function...   reset all port to high, before test... "

  for (( i = 0; i < led_amount; i++ )); do
    launch_command "sudo ./idll-test --PIN_NUM 0 --PERIOD 1 --DUTY_CYCLE 99 -- --EBOARD_TYPE EBOARD_ADi_"$board" --section LEC1_HCO3A_PWM [ADiDLL][HCO3A][PWM][POC]"
  done
  launch_command "sudo ./idll-test.exe --PORT_VAL 7 -- --EBOARD_TYPE EBOARD_ADi_"$board" --section HighCurrent_LED_SetPort"

  #######################################
  #Change DUTY CYCLE value
  title b "Change DUTY CYCLE value"
  for all in $(seq 0 $led_amount); do

    for duty_cyclell in "${duty_cycle_value[@]}"; do
      scxx=$(echo "$period*0.1" | bc)
      printf "${COLOR_BLUE_WD}LED: $all ${COLOR_REST}\n"
      printf "${COLOR_BLUE_WD}Duty cycle:${COLOR_RED_WD} $duty_cyclell ${COLOR_REST}\n"
      printf "${COLOR_BLUE_WD}period (LEC1: 0/1=disable blinking): $period = $period ms ${COLOR_REST}\n"
      printf "${COLOR_BLUE_WD}period (SCxx/SA3 : 0/1=disable blinking): $period = $scxx ms ${COLOR_REST}\n"
      read -p "enter key to continue above test..." continue

      launch_command "sudo ./idll-test.exe --PIN_NUM $all --PERIOD $period --DUTY_CYCLE $duty_cyclell -- --EBOARD_TYPE EBOARD_ADi_"$board" --section LEC1_HCO3A_PWM [ADiDLL][HCO3A][PWM][POC]"
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
    done

    ######################################################
    #Change PERIOD value
    printf "${COLOR_RED_WD}Change PERIOD value ${COLOR_REST}\n"
    printf "${COLOR_RED_WD}======================= ${COLOR_REST}\n\n"
    read -p "Enter to continue..."

    for perioddd in "${period_verify_value[@]}"; do
      scxx=$(echo "$perioddd*0.1" | bc)
      printf "${COLOR_BLUE_WD}LED: $all ${COLOR_REST}\n"
      printf "${COLOR_BLUE_WD}Duty cycle: $duty_cycle ${COLOR_REST}\n"
      printf "${COLOR_BLUE_WD}period(LEC1 : 0/1=disable blinking): ${COLOR_RED_WD}$perioddd  = $perioddd ms ${COLOR_REST}\n"
      printf "${COLOR_BLUE_WD}period(SCxx/SA3: 0=disable blinking): ${COLOR_RED_WD}$perioddd  = $scxx ms ${COLOR_REST}\n"

      if [ $perioddd == 0 ] || [ $perioddd == 1 ]; then
        printf "${COLOR_RED_WD}Note: (LEC1) period =1/0 should stop blinking!! \n${COLOR_REST}"
        printf "${COLOR_RED_WD}Note: (SCxx/SA3) period = 0 should stop blinking!! \n${COLOR_REST}"
      fi

      read -p "Enter to continue above test..."

      launch_command "sudo ./idll-test.exe --PIN_NUM $all --PERIOD $perioddd --DUTY_CYCLE $duty_cycle -- --EBOARD_TYPE EBOARD_ADi_"$board" --section LEC1_HCO3A_PWM [ADiDLL][HCO3A][PWM][POC]"
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
    ##############################################
    #confirm LED status after disabling blinking
    title b "Start to disable LED blinking function"
    printcolor r "(SCxx/SA3) LED: $all should be back to solid on as it's set port before ..."
    printcolor r "(LEC1) LED: $all won't keep its original state, it on/off randomly ..."
    read -p "Enter to test..."
    launch_command "sudo ./idll-test.exe --PIN_NUM $all --PERIOD 1 --DUTY_CYCLE 99 -- --EBOARD_TYPE EBOARD_ADi_"$board" --section LEC1_HCO3A_PWM [ADiDLL][HCO3A][PWM][POC]"

  done


  title b "All LED should be OFF"
  read -p "Enter to continue..."
  launch_command "sudo ./idll-test.exe --PORT_VAL 0 -- --EBOARD_TYPE EBOARD_ADi_"$board" --section HighCurrent_LED_SetPort"
}


disabling_blinking_muti_condition(){
  local period=1000 duty_cycle=50 brightness=50
  #LED multi disabling-blinking test
  printcolor r "How many DO pins is the project supported?"
  read -p "" amount
  amount=${amount:-3}
  title b "Enter to test LED multi disabling-blinking status."
  for led in $(seq 0 $((amount-1))); do
    case $1 in
    "setpin")
      for i in "true" "false" ; do

        launch_command "sudo ./idll-test.exe --PIN_NUM $led --PERIOD $period --DUTY_CYCLE $duty_cycle -- --EBOARD_TYPE EBOARD_ADi_"$board" --section LEC1_HCO3A_PWM [ADiDLL][HCO3A][PWM][POC]"
        title r "If the following script has error, please make sure the project supports BRIGHTNESS function."
        launch_command "sudo ./idll-test.exe --PIN_NUM $led --BRIGHTNESS $brightness -- --EBOARD_TYPE EBOARD_ADi_"$board" --section LEC1_HCO3A_Brightness_with_parameter [ADiDLL][HCO3A][PWM][POC]"


        case $i in
        "true")
          printcolor y "LED$led is going to set solid ON by set pin."
          printcolor y "Make sure it won't be blinking and should keep solid on."
          printcolor w "Enter to test."
          read -p ""
          launch_command "sudo ./idll-test.exe --PIN_NUM $led --PIN_VAL $i -- --EBOARD_TYPE EBOARD_ADi_"$board" --section HighCurrent_LED_SetPin"
          read -p ""
        ;;

        "false")
          printcolor y "LED$led is going to set solid OFF by set pin."
          printcolor y "Make sure it won't be blinking and should keep OFF."
          printcolor w "Enter to test."
          read -p ""
          launch_command "sudo ./idll-test.exe --PIN_NUM $led --PIN_VAL $i -- --EBOARD_TYPE EBOARD_ADi_"$board" --section HighCurrent_LED_SetPin"
          read -p ""
        ;;
        esac
      done
      ;;

    "brightness")
      for i in "true" "false" ; do

        launch_command "sudo ./idll-test.exe --PIN_NUM $led --PERIOD $period --DUTY_CYCLE $duty_cycle -- --EBOARD_TYPE EBOARD_ADi_"$board" --section LEC1_HCO3A_PWM [ADiDLL][HCO3A][PWM][POC]"
        title r "If the following script has error, please make sure the project supports BRIGHTNESS function."
        launch_command "sudo ./idll-test.exe --PIN_NUM $led --BRIGHTNESS $brightness -- --EBOARD_TYPE EBOARD_ADi_"$board" --section LEC1_HCO3A_Brightness_with_parameter [ADiDLL][HCO3A][PWM][POC]"

        case $i in
        "true")
          printcolor y "LED$led is going to set solid ON by set brightness=100."
          printcolor y "Make sure it won't be blinking and should keep solid on."
          printcolor w "Enter to test."
          read -p ""
          launch_command "sudo ./idll-test.exe --PIN_NUM $led --BRIGHTNESS 99 -- --EBOARD_TYPE EBOARD_ADi_"$board" --section LEC1_HCO3A_Brightness_with_parameter [ADiDLL][HCO3A][PWM][POC]"
          read -p ""
        ;;

        "false")
          printcolor y "LED$led is going to set solid OFF by set brightness=0."
          printcolor y "Make sure it won't be blinking and should keep OFF."
          printcolor w "Enter to test."
          read -p ""
          launch_command "sudo ./idll-test.exe --PIN_NUM $led --BRIGHTNESS 0 -- --EBOARD_TYPE EBOARD_ADi_"$board" --section LEC1_HCO3A_Brightness_with_parameter [ADiDLL][HCO3A][PWM][POC]"
          read -p ""
        ;;
        esac
      done

      ;;
    esac
  done


}

repeat_blink(){
  for (( i = 0; i < 100; i++ )); do
    random_period=$(shuf -i 2-10000 -n 1)
    random_duty=$(shuf -i 1-99 -n 1)
    random_pin=$(shuf -i 0-$(($1-1)) -n 1)
    launch_command "sudo ./idll-test.exe --PIN_NUM $random_pin --PERIOD $random_period --DUTY_CYCLE $random_duty -- --EBOARD_TYPE EBOARD_ADi_"$board" --section LEC1_HCO3A_PWM [ADiDLL][HCO3A][PWM][POC]"
    if [[ "$result" =~ "failed" && "$result" =~ "nReadDutyCycle == nDutyCycle"  ]]; then
      printcolor g "============================================"
      printcolor g "Result: PASS"
      printcolor g "============================================"
    elif [[ "$result" =~ "Period: $random_period" || "$result" =~ "Duty cycle: $random_duty" ]]; then
      printcolor g "============================================"
      printcolor g "Result: PASS"
      printcolor g "============================================"
    else
      read -p ""
      printcolor r "============================================"
      printcolor r "Result: FAIL"
      printcolor r "============================================"

    fi
  done
}

All_blink(){
  printcolor w "How many led is supported for the project?"
  read -p "" amount

  for (( i = 0; i < amount; i++ )); do
    launch_command "sudo ./idll-test.exe --PIN_NUM $i --PERIOD 100 --DUTY_CYCLE 50 -- --EBOARD_TYPE EBOARD_ADi_"$board" --section LEC1_HCO3A_PWM [ADiDLL][HCO3A][PWM][POC]"
  done

  while true ; do
    printf "Press 'x' to reset LED / exit the blink loop.. \r"

    read -rsn 1 -t 0.01 input

    if [ "$input" == "x" ]; then

      for (( x = 0; x < amount; x++ )); do
        launch_command "sudo ./idll-test.exe --PIN_NUM $x --PERIOD 0 --DUTY_CYCLE 50 -- --EBOARD_TYPE EBOARD_ADi_"$board" --section LEC1_HCO3A_PWM [ADiDLL][HCO3A][PWM][POC]"
      done
      return
    fi

  done


}

#===============================================================
#Brightness for LEC1 A3 32 DO
#===============================================================
## this script need to add correct script
Brightness(){
  brightness=("100" "99" "87" "70" "60" "51" "40" "30" "25" "10" "0")
  local duty_cycle=50 period=1000
  for led in $(seq 0 2);do
    #--------------------------------------------------------
    #test each brightness level with blinking action enabled
    for brightness_value in "${brightness[@]}"; do

      mesg=(
      "LED: $led"
      "Period: 1000 ms"
      "Duty Cycle: 50"
      "Brightness: $brightness_value"
      )
      title_list r mesg[@]

      if [ "$brightness_value" == 0 ]; then
        printcolor r "Note: the LED will stop blinking/ turned LED OFF, while brightness = $brightness_value"
      elif [ "$brightness_value" == 100 ]; then
        printcolor r "Note: the LED will stop blinking/ turned LED SOLID ON, while brightness = $brightness_value"
      fi

      printcolor w "Enter to test brightness setting."
      read -p ""
      launch_command "sudo ./idll-test.exe --PIN_NUM $led --PERIOD $period --DUTY_CYCLE $duty_cycle -- --EBOARD_TYPE EBOARD_ADi_"$board" --section LEC1_HCO3A_PWM [ADiDLL][HCO3A][PWM][POC]"
      launch_command "sudo ./idll-test.exe --PIN_NUM $led --BRIGHTNESS $brightness_value -- --EBOARD_TYPE EBOARD_ADi_"$board" --section LEC1_HCO3A_Brightness_with_parameter [ADiDLL][HCO3A][PWM][POC]"
      compare_result "$result" "Brightness: $brightness_value"
    done
  done

}

Brightness_loop(){
  local value led
  for all in $(seq 0 100); do
    value=$(shuf -i 0-100 -n 1)
    led=$(shuf -i 0-3 -n 1)
    launch_command "sudo ./idll-test.exe --PIN_NUM $led --BRIGHTNESS $value -- --EBOARD_TYPE EBOARD_ADi_"$board" --section LEC1_HCO3A_Brightness_with_parameter [ADiDLL][HCO3A][PWM][POC]"
#    launch_command "sudo ./idll-test.exe --PIN_NUM $led --PERIOD 100 --DUTY_CYCLE 50 -- --EBOARD_TYPE EBOARD_ADi_"$board" --section LEC1_HCO3A_PWM [ADiDLL][HCO3A][PWM][POC]"
    compare_result "$result" "$value"

  done
}


#===============================================================
# paramenter
#===============================================================
BadParameter() {
  title b "Bad parameter test"
  read -p "enter key to continue..."
  launch_command "sudo ./idll-test.exe --PIN_NUM 999999999 --PIN_VAL true -- --EBOARD_TYPE EBOARD_ADi_"$board" --section HighCurrent_LED_SetPin"
  compare_result "$result" "failed"
  launch_command "sudo ./idll-test.exe --PIN_NUM 1 --PIN_VAL gsf -- --EBOARD_TYPE EBOARD_ADi_"$board" --section HighCurrent_LED_SetPin"
  compare_result "$result" "failed"
  launch_command "sudo ./idll-test.exe --PORT_VAL 66666666666666666 -- --EBOARD_TYPE EBOARD_ADi_"$board" --section HighCurrent_LED_SetPort"
  compare_result "$result" "failed"
  launch_command "sudo ./idll-test.exe --PIN_NUM 0 --PERIOD 50 --DUTY_CYCLE 1001 -- --EBOARD_TYPE EBOARD_ADi_"$board" --section LEC1_HCO3A_PWM [ADiDLL][HCO3A][PWM][POC]"
  compare_result "$result" "failed"
  launch_command "sudo ./idll-test.exe --PIN_NUM 0 --PERIOD 10001 --DUTY_CYCLE 50 -- --EBOARD_TYPE EBOARD_ADi_"$board" --section LEC1_HCO3A_PWM [ADiDLL][HCO3A][PWM][POC]"
  compare_result "$result" "failed"

}


#=====================================================================================
#MAIN
#=====================================================================================
while true; do
  printf  "${COLOR_RED_WD}1. SETPORT${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}2. SETPIN${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}3. BLINK/DUTY${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}4. BRIGHTNESS${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}5. DISABLE BRIGHTNESS${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}6. DISABLE BLINK/DUTY${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}7. PARAMETER${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}==================================${COLOR_REST}\n"
  printf  "CHOOSE ONE TO TEST: \n"
  read -p "" input

  if [ "$input" == 1 ]; then
    SetPort
  elif [ "$input" == 2 ]; then
    SetPin
  elif [ "$input" == 3 ]; then
    Blink
  elif [ "$input" == 4 ]; then
    Brightness
  elif [ "$input" == 5 ]; then
    disabling_blinking_muti_condition "brightness"
  elif [ "$input" == 6 ]; then
    disabling_blinking_muti_condition "setpin"
  elif [ "$input" == 7 ]; then
    BadParameter
  fi

done