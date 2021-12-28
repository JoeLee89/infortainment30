#!/bin/bash
source ./common_func.sh

#===============================================================
#basic info/initial
#===============================================================
ErrorString() {
  print_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_"$board" --section Error_String_Message"
  sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_"$board" --section Error_String_Message
}

Initial() {
  while true; do
#    echo "$board"
    print_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section adiLibInit"
    result=$(sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_"$board" --section adiLibInit)
    echo "$result"
    if [[ "$result" == ""  ]]; then
      print_command "sudo ./idll-test.exe --ALLOW_INIT_FAIL true -- --EBOARD_TYPE EBOARD_ADi_"$board" --section InitBatDetect [ADiDLL][INIT][BAT_DETECT]"
      sudo ./idll-test.exe --ALLOW_INIT_FAIL true -- --EBOARD_TYPE EBOARD_ADi_"$board" --section InitBatDetect [ADiDLL][INIT][BAT_DETECT]
    fi

    read -p "Input [q] to exit loop.." input
      if [[ "$input" == "q"  ]]; then
        break
    fi
    done
}

SystemInfo() {
  print_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_"$board" --section SYS_Info"
  sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_"$board" --section SYS_Info
}

FPGA_FW_SHA256() {
  title b "FPGA FW SHA256 verify"
  read -p "input FPGA F/W 64 char sha256 data: " input

  data=("aa" "12" "@@")
  for i in "${data[@]}"; do
    title b "start to input value: $i"
    print_command "sudo ./idll-test.exe --fpga-fw-sha256 $i -- --EBOARD_TYPE EBOARD_ADi_"$board" \"Scenario: adiLibGetFirmwareSHA256\""
    result=$(sudo ./idll-test.exe --fpga-fw-sha256 $i -- --EBOARD_TYPE EBOARD_ADi_"$board" "Scenario: adiLibGetFirmwareSHA256")
    echo "$result"
    compare_result "$result" "failed"

  done
  print_command "sudo ./idll-test.exe --fpga-fw-sha256 $input -- --EBOARD_TYPE EBOARD_ADi_"$board" \"Scenario: adiLibGetFirmwareSHA256\""
  sudo ./idll-test.exe --fpga-fw-sha256 "$input" -- --EBOARD_TYPE EBOARD_ADi_"$board" "Scenario: adiLibGetFirmwareSHA256"
}

#===============================================================
#MAIN
#===============================================================
while true; do
  printf "\n"
  printf "${COLOR_RED_WD}1. ERROR STRING ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}2. INITIAL ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}3. SYSTEM INFO ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}4. FPGA FW SHA256 CONFIRM ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}======================================${COLOR_REST}\n"
  printf "CHOOSE ONE TO TEST: "
  read -p "" input

  if [ "$input" == 1 ]; then
    ErrorString
  elif [ "$input" == 2 ]; then
    Initial
  elif [ "$input" == 3 ]; then
    SystemInfo
  elif [ "$input" == 4 ]; then
    FPGA_FW_SHA256

  fi

done
