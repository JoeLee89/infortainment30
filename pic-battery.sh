#!/bin/bash
source ./common_func.sh
battery_wanring_reset(){
  if [ "$1" == "low" ]; then
    temp=$(sudo ./idll-test.exe --pic-batteries-voltage 0,0,0 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section BatSetGetLowVoltageManual [PIC][BATTERY][MANU])
  else
    temp=$(sudo ./idll-test.exe --pic-batteries-voltage 0,0,0 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section BatSetGetWarningVoltageManual [PIC][BATTERY][MANU])
  fi
}

pic_battery_low(){

  while true ; do

    pic_battery_preliminary
    battery_wanring_reset "warning"

    #confirm if the setting voltage is the same as getting voltage in low voltage idll function
    launch_command "sudo ./idll-test.exe --pic-batteries-voltage "$low1,$low2,$low3" -- --EBOARD_TYPE EBOARD_ADi_SC1X --section BatSetGetLowVoltageManual [PIC][BATTERY][MANU]"
    compare_result "$result" "batteriesGet.Volts1=$low1, batteriesGet.Volts2=$low2, batteriesGet.Volts3=$low3"

    #wait 12 minute to confirm if pic generate related pic battery warning event manually

    msg=(
      "Going to check PIC event, if there is battery event..."
      "**** So plug in battery first, if they are unplugged to avoid initial fail.***"
    )
    title_list r msg[@]
    read -p ""

    for (( i = 1; i < 12; i++ )); do
      printcolor y "$i minute"
      printcolor y "Start to check PIC event if there is any battery event every minute within 12 minsutes..."
      sleep 60
      confirm_pic_message "battery_alarm" "newest_unread" "all" "check"
    done

#    confirm_pic_message "battery_alarm" "newest_unread" "all" "check"
    printcolor b "Retest to press enter key, or [q] key to exit..."
    read -p "" input

    if [[ "$input" == "q" || "$input" == "Q" ]]; then
      break
    fi

  done

}

#===============================================================
#pic_battery_low_callback
#===============================================================

pic_battery_low_callback(){
  pic_battery_preliminary
  battery_wanring_reset "warning"

  while true ; do
    printcolor y "Input Interval (unit: minute):"
    read -p "" interval
    printcolor y "Input Mask (1,2,4,7):"
    read -p "" mask

    launch_command "sudo ./idll-test.exe --pic-batteries-voltage "$low1,$low2,$low3" -- --EBOARD_TYPE EBOARD_ADi_SC1X --section BatSetGetLowVoltageManual [PIC][BATTERY][MANU]"
    compare_result "$result" "batteriesGet.Volts1=$low1, batteriesGet.Volts2=$low2, batteriesGet.Volts3=$low3"

     #use callback function to detect if any matched event in log file
    mesg=(
      "Now starting callback function to monitor if any battery [Low] event is triggered. (Mask="$mask", Interval="$interval" min)"
      "PIC= $low1"
      "Sram1= $low2"
      "Sram2= $low3"
    )
    title_list b mesg[@]
    print_command "sudo ./idll-test.exe --INTERVAL $interval --PIN_MASK 0x0$mask -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Callback_PIC_BatLow_Manual [CALLBACK][PIC][MANU]"
    sudo ./idll-test.exe --INTERVAL $interval --PIN_MASK 0x0$mask -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Callback_PIC_BatLow_Manual [CALLBACK][PIC][MANU]

    printcolor b "Enter to retest, or [q] key to exit..."
    read -p "" input

    if [[ "$input" == "q" || "$input" == "Q" ]]; then
      break
    fi

  done

}

#===============================================================
#pic_battery_warning
#===============================================================

pic_battery_warning(){

  while true ; do
    pic_battery_preliminary
    battery_wanring_reset "low"
    launch_command "sudo ./idll-test.exe --pic-batteries-voltage "$low1,$low2,$low3" -- --EBOARD_TYPE EBOARD_ADi_SC1X --section BatSetGetWarningVoltageManual [PIC][BATTERY][MANU]"
    compare_result "$result" "batteriesGet.Volts1=$low1, batteriesGet.Volts2=$low2, batteriesGet.Volts3=$low3"

    #loop every minute within 12 minute to confirm if pic generate related pic battery warning event manually
    msg=(
      "Going to check PIC event, if there is battery event..."
      "**** So plug in battery first, if they are unplugged to avoid initial fail.***"
    )
    title_list r msg[@]
    read -p ""

    for (( i = 1; i < 12; i++ )); do
      printcolor y "$i minute"
      printcolor y "Start to check PIC event if there is any battery event every minute within 12 minsutes..."
      sleep 60
      confirm_pic_message "battery_alarm" "newest_unread" "all" "check"
    done

    printcolor b "Retest to press enter key, or [q] key to exit..."
    read -p "" input

    if [[ "$input" == "q" || "$input" == "Q" ]]; then
      break
    fi

  done
}

#===============================================================
#pic_battery_warning_callback
#===============================================================

pic_battery_warning_callback(){
  pic_battery_preliminary
  battery_wanring_reset "low"

  while true ; do
    printcolor y "Input Interval (unit: minute):"
    read -p "" interval
    printcolor y "Input Mask (1,2,4,7):"
    read -p "" mask

    launch_command "sudo ./idll-test.exe --pic-batteries-voltage "$low1,$low2,$low3" -- --EBOARD_TYPE EBOARD_ADi_SC1X --section BatSetGetWarningVoltageManual [PIC][BATTERY][MANU]"
    compare_result "$result" "batteriesGet.Volts1=$low1, batteriesGet.Volts2=$low2, batteriesGet.Volts3=$low3"

     #use callback function to detect if any matched event in log file
    mesg=(
      "Now starting callback function to monitor if any battery [Low] event is triggered. (Mask="$mask", Interval="$interval" min)"
      "PIC= $low1"
      "Sram1= $low2"
      "Sram2= $low3"
    )
    title_list b mesg[@]
    print_command "sudo ./idll-test.exe --INTERVAL $interval --PIN_MASK 0x0$mask -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Callback_PIC_BatWarn_Manual [CALLBACK][PIC][MANU]"
    sudo ./idll-test.exe --INTERVAL $interval --PIN_MASK 0x0$mask -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Callback_PIC_BatWarn_Manual [CALLBACK][PIC][MANU]

#    printcolor y "Start to check PIC event if there is battery event..."
#    confirm_pic_message "battery_alarm" "newest_unread" "all" "check"
    printcolor b "Enter to Retest, or [q] key to exit..."
    read -p "" input
    if [[ "$input" == "q" || "$input" == "Q" ]]; then
      break
    fi

  done

}

#===============================================================
#pic_battery_time_detection
#===============================================================

pic_battery_time_detection() {
  printf "${COLOR_RED_WD}check pic battery voltage by event  ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}==================================  ${COLOR_REST}\n"

  title b "Reset PIC event log"
  confirm_pic_message "battery" "newest_unread" "all" "no"

  while true; do

    printcolor y "Starting counting down in 10 minute, please wait..."
    for (( i = 0; i < 11; i++ )); do
      m=$((11-i))
      printcolor y "\r$m minute left.."
      sleep 60
    done

    printcolor b "Start getting pic event"
    confirm_pic_message "battery" "newest_unread" "all" "check"


    read -p "enter key to test again, or press q to exit test:" input
    if [[ "$input" == "q" || "$input" == "Q" ]]; then
        break
    fi

  done
}

#===============================================================
#check pic battery voltage by event
#===============================================================
GetByEvent() {
  title b "check pic battery voltage by event"
  print_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section PIC_GetPICEvent_and_CheckPICBatteryVoltage"
  sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section PIC_GetPICEvent_and_CheckPICBatteryVoltage
}

#===============================================================
#check pic battery voltage directly
#===============================================================
GetDirect() {
  title b "check pic battery voltage directly"
  print_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section PIC_Battery_PICEventByType"
  sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section PIC_Battery_PICEventByType
}


#===============================================================
#MAIN
#===============================================================
while true; do
  printf "\n"
  printf "${COLOR_RED_WD}1. BATTERY VOLTAGE BY EVENT ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}2. BATTERY VOLTAGE GET DIRECTLY ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}3. BATTERY WARNING MANUAL ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}4. BATTERY LOW MANUAL  ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}5. BATTERY WARNING WITH CALLBACK ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}6. BATTERY LOW WITH CALLBACK ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}7. BATTERY EVENT CHECK (TIMER COUNT DOWN) ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}======================================${COLOR_REST}\n"
  printf "CHOOSE ONE TO TEST: "
  read -p "" input

  if [ "$input" == 1 ]; then
    GetByEvent
  elif [ "$input" == 2 ]; then
    GetDirect
  elif [ "$input" == 3 ]; then
    pic_battery_warning
  elif [ "$input" == 4 ]; then
    pic_battery_low
  elif [ "$input" == 5 ]; then
    pic_battery_warning_callback
  elif [ "$input" == 6 ]; then
    pic_battery_low_callback
  elif [ "$input" == 7 ]; then
    pic_battery_time_detection
  fi

done