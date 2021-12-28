#!/bin/bash
source ./common_func.sh

#===============================================================
#Setting watchdog timeout
#===============================================================
SetWatchDogTimeOut() {
  title b "Setting watchdog timeout"
  read -p "Input the watchdog timeout, when you need the time is larger than 100 (second), or just enter to continue by default setting (0 10 100 200): " timeout

  #clear all pic event
  title b "Clear all pic power related event first"
  confirm_pic_message "power" "newest_unread" "all" ""

  if [[ "$timeout" -gt 100 ]]; then
    print_command "sudo ./idll-test.exe --watchdog $timeout -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_Watchdog"
    sudo ./idll-test.exe --watchdog $timeout -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_Watchdog

    #check if the watchdog related unread event should be 0, after been read.
    title b "Now confirm PIC watchdog related event"
    amount=$(picevent_amount_confirm "power")
    title b "Now confirm PIC watchdog related event"
    if [[ "$amount" -gt 0 ]]; then
      title r "Fail: PIC still has $amount new watchdog events."
      read -p ""
    else
      title g "Confirm pic watchdog event pass."
    fi

  else
    for count in 0 10 100 200; do
      launch_command "sudo ./idll-test.exe --watchdog $count -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_Watchdog"

      #check if the watchdog related unread event should be 0, after been read.
      amount=$(picevent_amount_confirm "power")
      title b "Now confirm PIC watchdog related event"
      if [[ "$amount" -gt 0 ]]; then
        title r "Fail: PIC still has $amount new watchdog events."
        read -p ""
      else
        title g "Confirm pic watchdog event pass."
      fi

      #watchdog timeout set 0 should be no event, only pass word.
      if [[ "$count" = 0 ]]; then
        compare_result "$result" "pass"
      else
        compare_result "$result" "Event found: Watchdog Timeout"
      fi

    done
  fi

}

#===============================================================
#Test watchdog timeout callback function (callback)
#===============================================================
WatchDogCallback() {
  pic_rtc_sync

  #clear all pic event
  title b "Clear all pic power related event first"
  confirm_pic_message "power" "newest_unread" "all" ""

  read -p "Input the watchdog timeout, when you need the time is larger than 100 (second), or just enter to continue by default setting (0 10 100 200): " timeout
  if [[ "$timeout" -gt 100 ]]; then
    title b "Now the test is starting. The result will display, after the setting timer $timeout seconds."
    launch_command "sudo ./idll-test.exe --WATCHDOG_TIMEOUT "$timeout" --SYSTEM_RESTART false -- --EBOARD_TYPE EBOARD_ADi_"$board" --section Callback_PIC_WDTimeout_Manual [CALLBACK][PIC][MANU]"
    compare_result "$result" "passed"

  else
    for i in 0 1 10 100; do
      title b "Test watchdog timeout callback timeout: $i sec"
      title b "Test watchdog timeout callback sytem restart: FALSE"
      launch_command "sudo ./idll-test.exe --WATCHDOG_TIMEOUT $i --SYSTEM_RESTART false -- --EBOARD_TYPE EBOARD_ADi_"$board" --section Callback_PIC_WDTimeout_Manual [CALLBACK][PIC][MANU]"

      if [[ "$i" = 0 ]]; then
        compare_result "$result" "failed"
      else
        compare_result "$result" "Watchdog system restart: false"
        compare_result "$result" "Event found: Watchdog Timeout"
        compare_result "$result" "Watchdog timeout seconds: $i"
      fi

      if [ "$status" == "fail" ]; then
        read -p ""
        status=""
      fi

    done

  fi

}

loop_watchdog(){

  while true; do
    pic_rtc_sync
    title b "Test watchdog callback timeout: 1 sec"
    title b "Test watchdog timeout callback system restart: FALSE"
    launch_command "sudo ./idll-test.exe --WATCHDOG_TIMEOUT 1 --SYSTEM_RESTART false -- --EBOARD_TYPE EBOARD_ADi_"$board" --section Callback_PIC_WDTimeout_Manual [CALLBACK][PIC][MANU]"

    if [[ "$i" = 0 ]]; then
      compare_result "$result" "failed"
    else
      compare_result "$result" "Watchdog system restart: false"
      compare_result "$result" "Event found: Watchdog Timeout"
      compare_result "$result" "Watchdog timeout seconds: $i"
    fi
  done
}

#===============================================================
#Test watchdog system restart (callback)
#===============================================================
WatchDog_RestartSystem() {
  title b "Test watchdog system restart (callback)"
  printcolor w "Input how many seconds to trigger watchdog function "
  printcolor w "Or input 0 to SKIP the watchdog setting, so you can check the event log."
  read -p "Wait time: " timeout

  pic_rtc_sync
  if [[ "$timeout" -ne 0 ]]; then
    print_command "sudo ./idll-test.exe --WATCHDOG_TIMEOUT $timeout --SYSTEM_RESTART true -- --EBOARD_TYPE EBOARD_ADi_"$board" --section Callback_PIC_WDTimeout_Manual [CALLBACK][PIC][MANU]"
    sudo ./idll-test.exe --WATCHDOG_TIMEOUT $timeout --SYSTEM_RESTART true -- --EBOARD_TYPE EBOARD_ADi_"$board" --section Callback_PIC_WDTimeout_Manual [CALLBACK][PIC][MANU]
  fi

#  confirm_pic_message "rtc_alarm" "newest_unread" "all" ""
  confirm_pic_message "power" "newest_unread" "all" ""

}


#===============================================================
#MAIN
#===============================================================
while true; do
  printf "\n"
  printf "${COLOR_RED_WD}1. SET WATCHDOG TIMEOUT (NO CALLBACK)${COLOR_REST}\n"
  printf "${COLOR_RED_WD}2. WATCHDOG TIMEOUT CALLBACK (NO RESTART)  ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}3. WATCHDOG SYSTEM RESTART ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}======================================${COLOR_REST}\n"
  printf "CHOOSE ONE TO TEST: "
  read -p "" input

  if [ "$input" == 1 ]; then
    SetWatchDogTimeOut
  elif [ "$input" == 2 ]; then
    WatchDogCallback
  elif [ "$input" == 3 ]; then
    WatchDog_RestartSystem

  fi

done
