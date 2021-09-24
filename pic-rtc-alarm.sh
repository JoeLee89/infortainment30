#!/bin/bash
source ./common_func.sh
#===============================================================
#GET PIC EVENT
#===============================================================
PicEvent() {
  while true; do
    print_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_GetPICEvent_and_DisplayEventTime"
    sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_GetPICEvent_and_DisplayEventTime

    read -p "[q] to exit, or enter key to loop test PIC event" input
    if [ "$input" == "q" ]; then
      break
    fi

  done
}

#===============================================================
#PIC RTC alarm
#===============================================================

#setting the pic alarm time and compare set and get result, if they are the same
alarm_compare_set_get(){
    # to compare setting alarm time with the result getting value from pic alarm time are correct
    #==============================================================================
    print_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_RTC_ALARM_GET_manual [PIC][RTC][ALARM][MANUAL]"
    picresult=$(sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_RTC_ALARM_GET_manual [PIC][RTC][ALARM][MANUAL] )
    echo "$picresult"
    RTC=$(echo "$picresult" | grep -i "RTC time" )
    Alarm=$(echo "$picresult" | grep -i "Alarm time" )
    RTCtime=$(echo "${RTC:39:8}")
    Alarmtime=$(echo "${Alarm:45:8}")

    #transfer alarm time/ now pic rtc time to seconds , and then minor both value to confirm the difference if it is the same as setting amount seconds
    #==============================================================================
    time=$(($(date +%s -d "$Alarmtime") - $(date +%s -d "$RTCtime")))

    if [[ "$time" == "$key" ]]; then
      printcolor g "RTC alarm time setting is correct !!"
      msg=(
      "The PIC setting alarm time= $key"
      "The differential between RTC time/ expectd alarm time= $time"
      )
      title_list b msg[@]
      echo "$picresult"

    else
      msg=(
      "The PIC setting alarm time= $key"
      "The differential between RTC time/ expected alarm time= $time"
      )
      title_list b msg[@]
      printcolor r "RTC alarm time setting is failed comparing to RTC time !!"
      echo "$picresult"
      read -p ""
    fi
}

PicRtcAlarm(){
  title b "Setting PIC RTC Alarm"
  confirm_pic_message "rtc_alarm" "newest_unread" "all" ""

  while true; do
    printcolor r "Type waiting second before alarm trigger"
    read -p "Seconds=  " key

    printcolor r "Set alarm behavior setting"
    printcolor r "Type 0: only event/ 1: power button trigger"
    read -p "Trigger mode= " input

    print_command "sudo ./idll-test.exe --pic-alarm_seconds $key -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_RTC_ALARM_SET_manual [PIC][RTC][ALARM][MANUAL]"
    sudo ./idll-test.exe --pic-alarm_seconds $key -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_RTC_ALARM_SET_manual [PIC][RTC][ALARM][MANUAL]

    print_command "sudo ./idll-test.exe --rtc-alarm-conf $input -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_RTC_ALARM_CONF_SET_manual [PIC][RTC][ALARM][MANUAL]"
    sudo ./idll-test.exe --rtc-alarm-conf $input -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_RTC_ALARM_CONF_SET_manual [PIC][RTC][ALARM][MANUAL]

    title b "Confirm if RTC alarm time setting is correct..."
    alarm_compare_set_get

    title b "Now Counting down $key seconds to trigger alarm time..."
    for (( i = 0; i < $key; i++ )); do
        sleep 1
        printcolor r "\r$i.."
    done

    #confirm alarm config setting if both setting/getting match
    #==============================================================================
    title b "Get PIC alarm behavior setting"
    launch_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_RTC_ALARM_CONF_GET_manual [PIC][RTC][ALARM][MANUAL]"
    compare_result "$result" "Current RTC Alarm Configuration is '$input'"

    #check if the trigger time match the setting alarm time from pic event
    #==============================================================================
    title b "Now will confirm if event exists and date time match the one been setting before."

    #to get how many event related to rtc alarm
    confirm_pic_message "rtc_alarm" "newest_unread" "255" ""

    picresult=$(sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_RTC_ALARM_GET_manual [PIC][RTC][ALARM][MANUAL])

    for (( i = 0; i < pic_log_filter_amount; i++ )); do
      result=$(confirm_pic_message "rtc_alarm" "newest_unread" "0" "")
      printcolor w "$result"
      pic_catch_content=$(echo "$result" | grep "Time")
      picevent_alarmtime=${pic_catch_content:17:8}

      if [[ "$Alarmtime" == "$picevent_alarmtime" ]]; then
        mesg=(
        "The PIC event time: $picevent_alarmtime"
        "The PIC Alarm expected time:  $Alarmtime"
        )
        title_list b mesg[@]
        printcolor y "Alarm time VS. PIC trigger event match!!!"
      else
        mesg=(
        "The PIC event time: $picevent_alarmtime"
        "The PIC Alarm expected time:  $Alarmtime"
        )
        title_list b mesg[@]

        printcolor b "$picresult"
        printcolor b "$result"
        printcolor y "Found alarm event!! But the alarm time getting from PIC can't match the setting alarm time!!"
        read -p "Confirm above list to check what's different..."
      fi
    done

    read -p "q to exit loop RTC alarm test, or enter to repeat test: " leave
    if [ "$leave" == "q" ]; then
      break
    fi
  done
}



#===============================================================
#PIC RTC alarm callback
#===============================================================
PicRtcAlarm_Callback() {
  while true; do
    title b "Setting PIC RTC Alarm (callback)"
    printcolor w "Set alarm behavior setting"
    printcolor w "type 0: only event/ 1: power button trigger"
    read -p "trigger mode= " config

    printcolor w "Set alarm time"
    read -p "seconds= " time

    print_command "sudo ./idll-test.exe --rtc-alarm-conf $config --pic-alarm_seconds $time -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section Callback_PIC_RtcAlarm_Manual [CALLBACK][PIC][MANU]"
    sudo ./idll-test.exe --rtc-alarm-conf $config --pic-alarm_seconds $time -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section Callback_PIC_RtcAlarm_Manual [CALLBACK][PIC][MANU]

    read -p "[q] to exit loop RTC alarm callback test, or enter key to repeat test " leave

    if [ "$leave" == "q" ]; then
      break
    fi
  done
}

#===============================================================
#MAIN
#===============================================================
while true; do
  printf "\n"
  printf "${COLOR_RED_WD}1. GET PIC EVENT${COLOR_REST}\n"
  printf "${COLOR_RED_WD}2. PIC RTC ALARM  ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}3. PIC RTC ALARM CALLBACK ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}======================================${COLOR_REST}\n"
  printf "CHOOSE ONE TO TEST: "
  read -p "" input

  if [ "$input" == 1 ]; then
    PicEvent
  elif [ "$input" == 2 ]; then
    PicRtcAlarm
  elif [ "$input" == 3 ]; then
    PicRtcAlarm_Callback

  fi

done
