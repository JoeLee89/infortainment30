#!/bin/bash
source ./common_func.sh
#===============================================================
# Secmeter feature test
#===============================================================
SecMeterFeature(){
  title b "Secmeter feature test"
  print_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SA3X --section SecMeter_New"
  sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SA3X --section SecMeter_New
}

#===============================================================
# secmeter bitpattern test
#===============================================================
SecMeterBitpattern(){
  title b "Secmeter bitpattern test"
  print_command "sudo ./idll-test.exe --sec-pattern 1,2,3,4,5,6,7 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section SecMeter_BitPattern"
  sudo ./idll-test.exe --sec-pattern 1,2,3,4,5,6,7 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section SecMeter_BitPattern
}

#===============================================================
# Secmeter cycle counter
#===============================================================
SecMeterCycleCounter(){
  title b "Secmeter cycle counter"

  while true; do
    printcolor w "type how many counter number you need."
    read -p "sec-counter-num:" num
    time=$((num*8000))

    print_command "sudo ./idll-test.exe --sec-counter-num $num --sec-reserve-time $time -- --EBOARD_TYPE EBOARD_ADi_SA3X --section SecMeter_Cycle"
    sudo ./idll-test.exe --sec-counter-num $num --sec-reserve-time $time -- --EBOARD_TYPE EBOARD_ADi_SA3X --section SecMeter_Cycle
    read -p "[q] to exit loop test, or enter key to loop test" input
    if [ "$input" == "q" ]; then
        break
    fi
  done
}

#===============================================================
# #value counting ONLY with ID 0
#===============================================================
SecMeterCount_NoId(){
  for all in $(seq 0 5);do
    title b "Start counting with ID=0 from 0-5 value "

    printcolor r  "Counting value= $all"
    read -p "enter key to continue... " continue

    if [ "$all" == 0 ]; then
      printcolor r "Note: Counting value: $all will cause error, due to spec setting from 1"
      read -p "" continue

    fi
    print_command "sudo ./idll-test.exe --sec-increment-value $all -- --EBOARD_TYPE EBOARD_ADi_SA3X --section SecMeter"
    sudo ./idll-test.exe --sec-increment-value $all -- --EBOARD_TYPE EBOARD_ADi_SA3X --section SecMeter

  done
}

#===============================================================
#Show text directly without id setting
#===============================================================
SecMeterShowText_Noid(){
  title b "Show text directly without id setting"
  printcolor w "TEXT= adlink9 "

  read -p "enter key to continue ... " continue
  print_command "sudo ./idll-test.exe --sec-display-text adlink9 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section SecMeter_Display"
  sudo ./idll-test.exe --sec-display-text adlink9 -- --EBOARD_TYPE EBOARD_ADi_SA3X --section SecMeter_Display
}

#===============================================================
#show text/countering with all ID
#===============================================================
ShowTextCountValue_AllID(){
  for all in $(seq 0 30);do
    printcolor b "Set/Show text with ID=$all "
    printcolor b "================================"
    printcolor b "Set/Show text with ID=$all "
    printcolor y "TEXT= adi_dll "
    read -p "enter key to continue ... " continue

    print_command "sudo ./idll-test.exe --LOOP 3 --sec-counter-id $all -- --EBOARD_TYPE EBOARD_ADi_SA3X --section SecMeter_SetCounterText"
    sudo ./idll-test.exe --LOOP 3 --sec-counter-id $all -- --EBOARD_TYPE EBOARD_ADi_SA3X --section SecMeter_SetCounterText

    printcolor b "Counting with ID=$all ... "
    printcolor b "================================"
    printcolor b "SecMeter ID= $all "
    printcolor y "Counting value= 1 "
    read -p "enter key to continue ... " continue

    sudo ./idll-test.exe --sec-counter-id $all -- --EBOARD_TYPE EBOARD_ADi_SA3X --section SecMeter

  done
}

#===============================================================


while true; do
  printf  "\n"
  printf  "${COLOR_RED_WD}1. SECMETER FEATURE ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}2. SECMETER BIT PATTERN ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}3. SECMETER CYCLE COUNTER ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}4. VALUE COUNT ONLY with ID 0 ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}5. SHOW TEXT DIRECTLY Without ID ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}6. SHOW TEXT/COUNTING VALUE WITH ALL ID ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}======================================${COLOR_REST}\n"
  printf  "CHOOSE ONE TO TEST: "
  read -p "" input

  if [ "$input" == 1 ]; then
    SecMeterFeature
  elif [ "$input" == 2 ]; then
    SecMeterBitpattern
  elif [ "$input" == 3 ]; then
    SecMeterCycleCounter

  elif [ "$input" == 4 ]; then
    SecMeterCount_NoId

  elif [ "$input" == 5 ]; then
    SecMeterShowText_Noid

  elif [ "$input" == 6 ]; then
    ShowTextCountValue_AllID

  fi

done