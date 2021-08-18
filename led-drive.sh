#!/bin/bash
source ./common_func.sh
#===============================================================
#LED all function
#===============================================================
count_whole_blink_sec(){
  blink_period_=$(($1+1))
#  printf "blink_period_= $blink_period_\n"
  project_period_=$2
  echo "$(echo "scale=2; $blink_period_/$project_period_" | bc)"
}


LED_set_get(){
  title b "To set / get pin and set / get port value for all leds"
  read -p "This test will loop forever, until press CTRL+C..."

  while true; do
    launch_command "sudo ./idll-test.exe --LOOP 1 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section GPO_LED_Drive"
    compare_result "$result" "pass"
  done
}

LED(){
  if [ "$1" == "scxx" ]; then
    project_period=24
    led_amount=23
    brightness=250
    duty_cycle=128
    blink_period=50
    brightness_verify_value=("255" "200" "100" "10" "1" "0")
    duty_cycle_list=("255" "200" "100" "10" "1" "0")
    blink_period_list=("255" "200" "100" "10" "1" "0")
  elif [ "$1" == "sa3" ]; then
    project_period=6
    led_amount=15
    brightness=60
    duty_cycle=32
    blink_period=10
    brightness_verify_value=("63" "45" "20" "10" "1" "0")
    duty_cycle_list=("63" "40" "20" "10" "1" "0")
    blink_period_list=("63" "30" "10" "1" "0")
  fi

#  blink_period_sec=$((($blink_period+1)/$project_period))
  blink_period_sec=$(count_whole_blink_sec $blink_period $project_period)
#  duty_cycle=128


  for all in $(seq 0 $led_amount); do
    for brightness_ in "${brightness_verify_value[@]}"; do
      printf "\n\n\n"
      printcolor w "LED: $all"
      printcolor r "Setting brightness: $brightness_"
      printcolor w "Blinking period: $blink_period"
      printcolor w "Duty cycle: $duty_cycle"
      printcolor w "Whole blinking period second: $blink_period_sec"
      printcolor w "==============================================="

      if [ "$brightness_" == 0 ]; then
        printcolor r "Note: the LED will stop blinking/ turned LED OFF, while brightness = 0 "
      elif [ "$brightness_" == 255 ]; then
        printcolor r "Note: the LED will stop blinking/ turned LED SOLID ON, while brightness = 255"
      elif [ "$brightness_" == 63 ]; then
        printcolor r "Note: the LED will stop blinking/ turned LED SOLID ON, while brightness = 63"
      fi

      read -p "enter to continue above setting..."
      launch_command "sudo ./idll-test.exe --PIN_NUM $all --BLINK $blink_period --DUTY_CYCLE $duty_cycle --BRIGHTNESS $brightness_ -- --EBOARD_TYPE EBOARD_ADi_SA3X --section GPO_LED_Drive_SetBlink"
      compare_result "$result" "Brightness: $brightness_"
    done


    for dutycycle in "${duty_cycle_list[@]}"; do
      printf "\n\n\n"
      printcolor w "LED: $all"
      printcolor w "Setting brightness: $brightness"
      printcolor w "Blinking period: $blink_period"
      printcolor r "Duty cycle: $dutycycle"
      printcolor w "Whole blinking period second: $blink_period_sec"
      printcolor w "=============================================== "

      if [ "$dutycycle" == 0 ]; then
          printcolor r "Note: the LED will stop blinking / turned LED OFF, while duty cycle = 0"
      fi

      read -p "enter to continue above setting..."
      launch_command "sudo ./idll-test.exe --PIN_NUM $all --BLINK $blink_period --DUTY_CYCLE $dutycycle --BRIGHTNESS $brightness -- --EBOARD_TYPE EBOARD_ADi_SA3X --section GPO_LED_Drive_SetBlink"
      compare_result "$result" "Duty cycle: $dutycycle"
    done


    for blink in "${blink_period_list[@]}"; do

      #blink period setting
      printf "\n\n\n"
      printcolor w "LED: $all"
      printcolor w "Setting brightness: $brightness"
      printcolor r "Blinking period: $blink"
      printcolor w "Duty cycle: $duty_cycle"
      printcolor w "Whole blinking period second: $(count_whole_blink_sec $blink $project_period)"
      printcolor w "==============================================="

      if [ "$blink" == 0 ]; then
          printcolor r "Note: the LED will stop blinking/ LED SOLID ON, while blinking period = 0"
      fi

      read -p "enter to continue above setting..."
      launch_command "sudo ./idll-test.exe --PIN_NUM $all --BLINK $blink --DUTY_CYCLE $duty_cycle --BRIGHTNESS $brightness -- --EBOARD_TYPE EBOARD_ADi_SA3X --section GPO_LED_Drive_SetBlink"
      compare_result "$result" "nBlink: $blink"
    done



    #just disable the led not te be tested.
    read -p "enter to reset LED status..."
    sudo ./idll-test.exe --PIN_NUM $all --BLINK 0 --DUTY_CYCLE 0 --BRIGHTNESS 0 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section GPO_LED_Drive_SetBlink

  done
}

#===============================================================
#parameter
#===============================================================
parameter(){
  title "Check bad parameter... "

  print_command  "${COLOR_RED_WD}sudo ./idll-test.exe --PIN_NUM 25 --BLINK 23 --DUTY_CYCLE 255 --BRIGHTNESS 255 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section GPO_LED_Drive_SetBlink ${COLOR_REST}\n"
  sudo ./idll-test.exe --PIN_NUM 25 --BLINK 23 --DUTY_CYCLE 255 --BRIGHTNESS 255 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section GPO_LED_Drive_SetBlink

  print_command  "${COLOR_RED_WD}sudo ./idll-test.exe --PIN_NUM 23 --BLINK 256 --DUTY_CYCLE 255 --BRIGHTNESS 255 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section GPO_LED_Drive_SetBlink ${COLOR_REST}\n"
  sudo ./idll-test.exe --PIN_NUM 23 --BLINK 256 --DUTY_CYCLE 255 --BRIGHTNESS 255 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section GPO_LED_Drive_SetBlink

  print_command  "${COLOR_RED_WD}sudo ./idll-test.exe --PIN_NUM 23 --BLINK 23 --DUTY_CYCLE 256 --BRIGHTNESS 255 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section GPO_LED_Drive_SetBlink${COLOR_REST}\n"
  sudo ./idll-test.exe --PIN_NUM 23 --BLINK 23 --DUTY_CYCLE 256 --BRIGHTNESS 255 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section GPO_LED_Drive_SetBlink

  print_command  "${COLOR_RED_WD}sudo ./idll-test.exe --PIN_NUM 23 --BLINK 23 --DUTY_CYCLE 255 --BRIGHTNESS 256 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section GPO_LED_Drive_SetBlink${COLOR_REST}\n"
  sudo ./idll-test.exe --PIN_NUM 23 --BLINK 23 --DUTY_CYCLE 255 --BRIGHTNESS 256 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section GPO_LED_Drive_SetBlink
}


#===============================================================
#MAIN
#===============================================================

while true; do
  printf  "\n"
  printf  "${COLOR_RED_WD}1. (SCXX/BSEC) LED VERIFY ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}2. (SA3X) LED VERIFY ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}3. LED SET GET PORT/PIN VERIFY ${COLOR_REST}\n"

  printf  "${COLOR_RED_WD}4. BAD PARAMETER ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}======================================${COLOR_REST}\n"
  printf  "CHOOSE ONE TO TEST: "
  read -p "" input

  if [ "$input" == 1 ]; then
    LED scxx
  elif [ "$input" == 2 ]; then
    LED sa3
  elif [ "$input" == 3 ]; then
    LED_set_get
  elif [ "$input" == 4 ]; then
    parameter
  fi

done