#!/bin/bash
source ./common_func.sh

#===============================================================
#Getting PIC RTC time
#===============================================================
SetGetPICTime() {
  title b "new setting up the date 2028/02/28/12/30/30"
  launch_command "sudo ./idll-test.exe --pic-time 2028/02/29/12/30/40 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_RTC"
#  result=$(echo "$result" | sed 's/\r//g')
  compare_result "$result" "PICRTClock: PIC RTClock after set: 28/02/29 12:30:40"
#  read -p ""

  title b "new setting up the date 2027/02/28/12/30/30"
  launch_command "sudo ./idll-test.exe --pic-time 2027/02/29/12/30/40 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_RTC"
  compare_result "$result" "PICRTClock: PIC RTClock after set: 27/03/01 12:30:40"
#  read -p ""

  title b "Getting PIC RTC time"
#  print_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_RTC_GETCLOCK"
#  sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_RTC_GETCLOCK
  for (( i = 0; i < 50; i++ )); do
    title b "Now sync up PIC time with RTC time"
    pic_rtc_sync
    pic_time
    title b "Now compare PIC time with RTC time, if they are the same."
    now=$(date +%s)
    differential=$((pic_time-now))

    if [[ "$differential" -lt 2 || "$differential" -gt -2 ]]; then
      printcolor g "Both result of RTC/PIC time is the same as the following list:"
      mseg=(
      "RTC: $(date +%s)"
      "PIC Time : $pic_time"
      )
      title_list y mseg[@]

    else
      printcolor r "Both result of RTC/PIC time are incorrect as the following list:"
      mseg=(
      "RTC: $(date +%s)"
      "PIC Time : $pic_time"
      )
      title_list y mseg[@]
      read -p ""
    fi
  done
}

#===============================================================
# RTC calibrate
#===============================================================
rtc_calibrate(){
  ###########################################################################
  #test pic rtc timer , try to faster pic rtc time by looping 10000 with pic calibrate 127
  pic_rtc_sync

  for (( i = 0; i < 10000; i++ )); do
    title b "Now try to make pic faster in 1.2 sec loop $i/10000"
    print_command "sudo ./idll-test.exe --RTC-CAL-VALUE=127 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section RtcCalibrateManual"
    sudo ./idll-test.exe --RTC-CAL-VALUE=127 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section RtcCalibrateManual
  done

  pic_time=$(sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_RTC_GETCLOCK | grep -i "clock" | sed 's/PICRTClock: PIC RTClock: //g' | sed 's/\//-/g')
  pic_sec=$(date -d "$pic_time" +%s)
  echo "$pic_sec"
  now=$(date +%s)
  echo "$now"
  difference=$((now-pic_sec))
  printcolor w "The differential between PIC RTC/system RTC : $difference"
  if [[ "$difference" -lt 2 ]]; then
    title g "Test result: PASS"
    read -p "enter key to continue..."
  else
    title r "Test result: FAIL, due to the differential is higher than 2"
    read -p "enter key to continue..."
  fi

  ###########################################################################
  #test pic rtc timer , try to slower pic rtc time by looping 10000 with pic calibrate -128
  pic_rtc_sync
  for (( i = 20000; i > 0; i-- )); do
    title b "Now try to make pic delay slower in 1.2 sec loop $i/20000"
    sudo ./idll-test.exe --RTC-CAL-VALUE=-128 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section RtcCalibrateManual
    print_command "sudo ./idll-test.exe --RTC-CAL-VALUE=-128 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section RtcCalibrateManual"

  done

  pic_time=$(sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_RTC_GETCLOCK | grep -i "clock" | sed 's/PICRTClock: PIC RTClock: //g' | sed 's/\//-/g')
  pic_sec=$(date -d "$pic_time" +%s)
  now=$(date +%s)
  difference=$((now-pic_sec))
  printcolor w "The differential between PIC RTC/system RTC : $difference"

  if [[ $difference -gt -2 ]]; then
    title g "Test result: PASS"
    read -p "enter key to continue..."
  else
    title r "Test result: FAIL, due to the differential is higher than 2"
    read -p "enter key to continue..."
  fi
  ###########################################################################
  #set pic time back to normal mode
  title b "Now will set pic time back to normal mode"
  read -p ""
  for (( i = 0; i < 10000; i++ )); do
    title b "Now try to make pic get back to normal RTC speed. loop $i/10000"
    print_command "sudo ./idll-test.exe --RTC-CAL-VALUE=127 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section RtcCalibrateManual"
    sudo ./idll-test.exe --RTC-CAL-VALUE=127 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section RtcCalibrateManual


  done

}

#===============================================================
#Setting PIC RTC time
#===============================================================
SetPICTime() {
  title b "Setting PIC RTC time"
  read -p "Type date format e.g. 20991231235959(year.month.date.hour.minute.second) to test:
or just enter by default test : " date
  if [ "$date" == "" ]; then
    sudo ./idll-test.exe --pic-time 2099/12/31/23/59/59 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_RTC
    sleep 1
    sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_RTC_GETCLOCK
  else
    sudo ./idll-test.exe --pic-time ${date:0:4}/${date:4:2}/${date:6:2}/${date:8:2}/${date:10:2}/${date:12:2} -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_RTC
    sleep 1
    sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_RTC_GETCLOCK
  fi
}

#===============================================================
#Getting PIC RTC time
#===============================================================
GetPICTime() {
  title b "Getting PIC RTC time"
  print_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_RTC_GETCLOCK"
  sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_RTC_GETCLOCK
}

SyncPICTime() {
  title b "Start sync up System RTC / PIC RTC time"
  pic_rtc_sync
}

#===============================================================
#Setting PIC RTC time with error parameter
#===============================================================
BadParameter() {
  printf "${COLOR_RED_WD}Setting PIC RTC time with error parameter ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}========================================= ${COLOR_REST}\n"
  read -p " " continue
  printf "${COLOR_RED_WD}sudo ./idll-test.exe --pic-time 2100/22/23/23/23/23 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_RTC  ${COLOR_REST}\n"
  sudo ./idll-test.exe --pic-time 2100/22/23/23/23/23 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_RTC
  sudo ./idll-test.exe --pic-time 2120/2/29/11/12/30 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_RTC
}

#===============================================================
#main
#===============================================================
while true; do
  printf "${COLOR_RED_WD}1. SET/GET PIC RTC TIME${COLOR_REST}\n"
  printf "${COLOR_RED_WD}2. PIC RTC CALIBRATE${COLOR_REST}\n"
  printf "${COLOR_RED_WD}3. BAD PARAMETER${COLOR_REST}\n"
  printf "${COLOR_RED_WD}4. GET PIC TIME${COLOR_REST}\n"
  printf "${COLOR_RED_WD}5. SYNC SYSTEM TIME / PIC TIME${COLOR_REST}\n"
  printf "${COLOR_RED_WD}=========================================================${COLOR_REST}\n"
  printf "CHOOSE ONE TO TEST: "
  read -p "" input

  if [ "$input" == 1 ]; then
    SetGetPICTime
  elif [ "$input" == 2 ]; then
    rtc_calibrate
  elif [ "$input" == 3 ]; then
    BadParameter
  elif [ "$input" == 4 ]; then
    GetPICTime
  elif [ "$input" == 5 ]; then
    SyncPICTime
  fi

done

