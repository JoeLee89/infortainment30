#!/bin/bash
source ./common_func.sh

GetSetPin_bsec(){
  title b "Get pin/set pin /get meter sense (BSEC/BACC only)"
  printf  "q key to exit, or enter key to continue...\n"
  read -p "" input
  m=0
  for (( i = 24; i < 32; i++ )); do
    if [ "$input" == "q" ]; then
        break
    fi
      sudo ./idll-test --DO_PIN_NUM $i --MSENSE_PIN_NUM $m   -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section HardMeter_BACC_SetPin
      (( m++ ))
done
}

GetSetPort_bsec(){
  title b "Get port/set port /get meter sense (BSEC/BACC only)"
  printf  "q key to exit, or enter key to continue...\n"
  read -p "" input

  for i in 1 2 4 8 16 32 64 128 255; do
    if [ "$input" == "q" ]; then
        break
    fi
      sudo ./idll-test --PORT_VAL $i -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section HardMeter_BACC_SetPort
  done
}



GetSetPin_SA3(){
  title b "Start counting hard meter by PIN"
  read -p "enter key to test.." continue
  local i

  for (( i = 0; i < 16; i++ )); do
    if [[ "$i" = 8 ]]; then
      printcolor r "going to test hard meter (9-16)"
      read -p "enter key to test..." continue
    fi
    launch_command "sudo ./idll-test --PIN_VAL $i --HM-Int-Count 1 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section HardMeter_ByPin"
    compare_result "$result" "passed"
  done

}


SetGetPort_SA3(){
  title b "Start counting hard meter by Port (1-8)"
  read -p "enter key to test" continue
  hex=$((2#1))

  while true; do
    launch_command "sudo ./idll-test --PORT_VAL $hex --HM-Int-Count 1 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section HardMeter_ByPort"
    compare_result "$result" "passed"
    hex=$((hex<<1))

#    read -p "" continue
    case $hex in
      $((2#100000000)))
        title b "going to test hard meter (9-16)"
        read -p "enter key to test..." continue
        ;;
      $((2#10000000000000000)))
        title b "going to test hard meter (1-16) set high for 1 mins"
        read -p "enter key to test..." continue

          #loop 1 min to confirm meter works fine
          after=$( date +%s --date="+1 minute")
          while true; do
            now=$(date +%s)
            launch_command "sudo ./idll-test --PORT_VAL 65535 --HM-Int-Count 1 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section HardMeter_ByPort"
            compare_result "$result" "passed"
            if [[ "$now" > $after ]]; then
              break
            fi
          done

          break
        ;;
      esac
  done
}

GetSetPin_SCXX(){
  title b "Start counting hard meter by PIN"
  read -p "enter key to test.." continue

  hex=$((2#1))
  for (( i = 0; i < 8; i++ )); do
    launch_command "sudo ./idll-test --PIN_VAL $i --HM-Int-Count 1 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section HardMeter_ByPin"
    compare_result "$result" "passed"
  done

}


SetGetPort_SCXX(){
  title b "Start counting hard meter by Port (1-8)"
  read -p "enter key to test" continue
  hex=$((2#1))

  while true; do
    launch_command "sudo ./idll-test --PORT_VAL $hex --HM-Int-Count 1 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section HardMeter_ByPort"
    compare_result "$result" "passed"
    hex=$((hex<<1))

    if [[ "$hex" == "$((2#100000000))" ]]; then
        break
    fi

  done

  after=$( date +%s --date="+1 minute")
  while true; do
      now=$(date +%s)
      launch_command "sudo ./idll-test --PORT_VAL 255 --HM-Int-Count 1 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section HardMeter_ByPort"
      compare_result "$result" "passed"
      if [[ "$now" > $after ]]; then
        break
      fi
  done


}

meter_detection(){
  local l
  expected_getport_plug_value="0xFFFF"
  meter_total_pin=9
  count=0
  for i in "plug" "unplug"; do
    title b "***************Now please make cable in $i status..*************************"
    read -p ""

    case $i in
    "plug")
      while true; do

        for (( l = 0; l < $meter_total_pin; l++ )); do
          title b "Now get detection ( PORT ) value"

          launch_command "sudo ./idll-test -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section HardMeter_Detection_ByPort"
          compare_result "$result" "$expected_getport_plug_value"

          printf "\n\n"
          title b "Now get detection ( PIN ) value"
          launch_command "sudo ./idll-test --HM_PIN_ID $l -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section HardMeter_Detection_ByPin"
          compare_result "$result" "pin: $l, status: true"
        done

        read -p "Enter to continue test or press [q] to skip get port function..." input
        if [[ "$input" == "q" ]]; then
          break
        fi

      done
      ;;

    "unplug")
      while true; do

        for (( l = 0; l < $meter_total_pin; l++ )); do
          title b "Now get detection ( PORT ) value"
          launch_command "sudo ./idll-test -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section HardMeter_Detection_ByPort"
          compare_result "$result" "0x0"

          title b "Now get detection ( PIN ) value"
          launch_command "sudo ./idll-test --HM_PIN_ID $l -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section HardMeter_Detection_ByPin"
          compare_result "$result" "pin: $l, status: false"
        done

        read -p "enter key continue test or press [q] to skip get port function..." input
        if [[ "$input" == "q" ]]; then
          break
        fi

      done
      ;;
    esac
  done
}

meter_detection_loop(){

  meter_total_pin=9

  read -p "Input the total supported pin number or Enter for 16 pins hard meter (8 or 16): " pin_number
  read -p "input how many minutes your need to test : " set_time
  pin_number=${pin_number:-16}
  case $pin_number in
  16)
    expected_getport_plug_value="0xFFFF"
    ;;
  8)
    expected_getport_plug_value="0xFF"
    ;;
  esac

  for i in "plug" "unplug"; do
    title b "***************Now please make cable in $i status..*************************"
    read -p ""

    case $i in
    "plug")

      after=$( date +%s --date="+$set_time minute")

      while true; do
        now=$( date +%s )

        for (( l = 0; l < $meter_total_pin; l++ )); do
          title b "Now get detection ( PORT ) value"
          launch_command "sudo ./idll-test -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section HardMeter_Detection_ByPort"
          compare_result "$result" "$expected_getport_plug_value"

          printf "\n\n"
          title b "Now get detection ( PIN ) value"
          launch_command "sudo ./idll-test --HM_PIN_ID $l -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section HardMeter_Detection_ByPin"
          compare_result "$result" "pin: $l, status: true"

        done

        #to get all port/pin status finisehd first, and will be interrupted if one of them is failed.
        if [[ "$now" > "$after" || "$status" == "fail" ]]; then
          break
        fi

      done
      ;;

    "unplug")

      after=$( date +%s --date="+$set_time minute")

      while true; do
        now=$( date +%s )

        for (( l = 0; l < $meter_total_pin; l++ )); do
          title b "Now get detection ( PORT ) value"
          launch_command "sudo ./idll-test -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section HardMeter_Detection_ByPort"
          compare_result "$result" "0x0"

          title b "Now get detection ( PIN ) value"
          launch_command "sudo ./idll-test --HM_PIN_ID $l -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section HardMeter_Detection_ByPin"
          compare_result "$result" "pin: $l, status: false"
        done

        if [[ "$now" > "$after" || "$status" == "fail" ]]; then
          break
        fi

      done
      ;;
    esac
  done
}


#
#increment_port(){
#
##  start /B /wait idll-test --PORT_VAL 0x1FF --HM-Int-Count 1 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section HardMeter_ByPort
#  read -p "How many hard meter support to your project: " total_port
#  read -p "How many counting on each meter: " increment_number
#  l=0
#  for (( i = 0; i < 6; i++ )); do
#      m=$((2**$i))
#      l=$((m+l))
#      launch_command "sudo ./idll-test --PORT_VAL $l --HM-Int-Count $increment_number -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section HardMeter_ByPort"
#      compare_result "$result" "adiHardMeterIncrementCounters: $increment_number"
#      compare_result "$result" "adiHardMeterIncrementCounters Port: $(echo "obase=16;$l|bc")"
#
#  done
#
#
#
#
#}



#========================================================================================================


while true; do
  printf  "${COLOR_RED_WD}1. GET PIN / SET PIN / GET METER SENSE (BSEC/BACC only)${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}2. Get PORT / SET PORT /GET METER SENSE (BSEC/BACC only)${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}3. Get PORT / SET PORT /GET METER SENSE (SA3)${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}4. GET PIN / SET PIN / GET METER SENSE (SA3)${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}5. Get PORT / SET PORT /GET METER SENSE (SCxx)${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}6. GET PIN / SET PIN / GET METER SENSE (SCxx)${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}7. METER DETECTION PIN/PORT ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}8. METER DETECTION PIN/PORT LOOP${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}=========================================================${COLOR_REST}\n"
  printf "CHOOSE ONE TO TEST: "
  read -p "" input

  if [ "$input" == 1 ]; then
    GetSetPin_bsec
  elif [ "$input" == 2 ]; then
    GetSetPort_bsec
  elif [ "$input" == 3 ]; then
      SetGetPort_SA3
  elif [ "$input" == 4 ]; then
      GetSetPin_SA3
  elif [ "$input" == 5 ]; then
      SetGetPort_SCXX
  elif [ "$input" == 6 ]; then
      GetSetPin_SCXX
  elif [ "$input" == 7 ]; then
      meter_detection
  elif [ "$input" == 8 ]; then
      meter_detection_loop
  fi

done