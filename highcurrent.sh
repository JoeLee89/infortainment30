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
#    launch_command "sudo ./idll-test.exe --PORT_VAL $i -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section HighCurrent_LED_SetPort"
    print_command "sudo ./idll-test.exe --PORT_VAL $i -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section HighCurrent_LED_SetPort"

    result=$(sudo ./idll-test.exe --PORT_VAL "$i" -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section HighCurrent_LED_SetPort)
    echo "$result"
    result=$(echo "$result" | grep -i "Port value:" | sed 's/\r//g')
    compare_result "$result" "Port value: $i"
    sleep 2
  done

  reset=$(sudo ./idll-test.exe --PORT_VAL 0 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section HighCurrent_LED_SetPort)
}

#===============================================================
# All LED setport test
#===============================================================
SetPin() {
  title "All LED setpin test"
  read -p "enter key to continue..."

  for all in $(seq 0 2); do
    print_command "sudo ./idll-test.exe --PIN_NUM $all --PIN_VAL true -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section HighCurrent_LED_SetPin"
    result=$(sudo ./idll-test.exe --PIN_NUM $all --PIN_VAL true -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section HighCurrent_LED_SetPin)
    echo "$result"
    result1=$(echo "$result" | grep -i "Pin number:" | sed 's/\r//g' )
    result2=$(echo "$result" | grep -i "Pin value: 1" | sed 's/\r//g' )
    compare_result "$result1" "Pin number: $all"
    compare_result "$result2" "Pin value: 1"
    sleep 2

    print_command "sudo ./idll-test.exe --PIN_NUM $all --PIN_VAL false -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section HighCurrent_LED_SetPin"
    result=$(sudo ./idll-test.exe --PIN_NUM $all --PIN_VAL false -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section HighCurrent_LED_SetPin)
    echo "$result"
    result1=$(echo "$result" | grep -i "Pin number:" | sed 's/\r//g' )
    result2=$(echo "$result" | grep -i "Pin value: 0" | sed 's/\r//g' )
    compare_result "$result" "Pin number: $all"
    compare_result "$result" "Pin value: 0"
  done
}

#===============================================================
# brightness/ blinking
#===============================================================
## this script need to add correct script
info(){
  local brightness="w" period="w" duty="w"
  printf "\n\n\n"
  case $5 in
    "brightness")
      brightness="r"
      ;;
    "period")
      period="r"
      ;;
    "duty")
      duty="r"
      ;;
  esac

  printcolor w "LED: $1"
  printcolor $brightness "Setting brightness: $2"
  printcolor $period "Blinking period: $3"
  printcolor $duty "Duty cycle: $4"
  printcolor w "Whole blinking period second: $(($3*10)) ms"
  printcolor w "==============================================="
}


HC_brightness_blink() {
  led_amount=3
  brightness=9
  duty_cycle=50
  blink_period=100
  brightness_verify_value=("10" "9" "8" "7" "6" "5" "4" "3" "2" "1" "0")
  duty_cycle_list=("99" "98" "50" "10" "2" "1")
  blink_period_list=("65535" "5989" "39999" "10" "1" "0")

  #reset each pin status
  for (( i = 0; i < led_amount; i++ )); do
    launch_command "sudo ./idll-test.exe --PIN_NUM $i --PERIOD 0 --DUTY_CYCLE 99 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_SetDoLedBlink"
  done

  for led in $(seq 0 $led_amount); do
    # brightness test
    for brightness_value in "${brightness_verify_value[@]}"; do
      info $led $brightness_value $blink_period $duty_cycle "brightness"

      if [ "$brightness_value" == 0 ]; then
        printcolor r "Note: the LED will stop blinking/ turned LED OFF, while brightness = 0 "
      elif [ "$brightness_value" == 10 ]; then
        printcolor r "Note: the LED will stop blinking/ turned LED SOLID ON, while brightness = 10"
      fi

      read -p "enter to continue above setting..."
      launch_command "sudo ./idll-test.exe --PIN_NUM $all --BLINK $blink_period --DUTY_CYCLE $duty_cycle --BRIGHTNESS $brightness_value -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_Drive_SetBlink"
      compare_result "$result" "Brightness: $brightness_value"
    done

    #duty function test
    for duty_value in "${duty_cycle_list[@]}"; do
      info $led $brightness $blink_period $duty_value "duty"

      read -p "enter to continue above setting..."
      launch_command "sudo ./idll-test.exe --PIN_NUM $all --BLINK $blink_period --DUTY_CYCLE $duty_value --BRIGHTNESS $brightness -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_Drive_SetBlink"
      compare_result "$result" "Duty cycle: $dutycycle"
    done

    #period function test
    for period_value in "${blink_period_list[@]}"; do
      info $led $brightness $period_value $duty_cycle "period"
      if [[ "$period_value" -eq 0 || "$period_value" -eq 1 ]]; then
          printcolor r "Note: the LED will stop blinking/ LED SOLID ON, while blinking period = 0 or 1"
      fi

      read -p "enter to continue above setting..."
      launch_command "sudo ./idll-test.exe --PIN_NUM $all --BLINK $period_value --DUTY_CYCLE  $duty_cycle --BRIGHTNESS $brightness -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section GPO_LED_Drive_SetBlink"
      compare_result "$result" "Duty cycle: $dutycycle"
    done


  done

}


#===============================================================
# paramenter
#===============================================================
BadParameter() {
  title b "Bad parameter test"
  read -p "enter key to continue..."
  launch_command "sudo ./idll-test.exe --PIN_NUM 999999999 --PIN_VAL true -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section HighCurrent_LED_SetPin"
  launch_command "sudo ./idll-test.exe --PIN_NUM 1 --PIN_VAL gsf -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section HighCurrent_LED_SetPin"
  launch_command "sudo ./idll-test.exe --PORT_VAL 66666666666666666 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section HighCurrent_LED_SetPort"
}


#=====================================================================================
#MAIN
#=====================================================================================
while true; do
  printf  "${COLOR_RED_WD}1. SETPORT${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}2. SETPIN${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}3. BLINK/DUTY/BRIGHTNESS${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}4. PARAMETER${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}==================================${COLOR_REST}\n"
  printf  "CHOOSE ONE TO TEST: \n"
  read -p "" input

  if [ "$input" == 1 ]; then
    SetPort
  elif [ "$input" == 2 ]; then
    SetPin
  elif [ "$input" == 3 ]; then
    HC_brightness_blink
  elif [ "$input" == 4 ]; then
    BadParameter
  fi

done