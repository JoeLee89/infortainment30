#!/bin/bash
source ./common_func.sh
#===============================================================
#com port test on each supported feature
#===============================================================
number_random() {
  for (( i = 0; i < $1; i++ )); do
    re=$(shuf -i 0-9 -n 1)
#    echo "$re"
    number=$number$re
  done
  echo $number
}

com_list=("LEC1_COM1" "LEC1_COM2")
baudrate=("110" "300" "600" "1200" "2400" "4800" "9600" "14400" "19200" "38400" "56000" "57600" "115200")
baudrate_default=115200
databit=("3" "4")
databit_default=4
flowctrl=("1" "2")
flowctrl_default=1
paritybit=("1" "2" "3" "4" "5")
paritybit_default=1
stopbit=("1" "2")
stopbit_default=1
read_interval_default=500
read_len=("1" "10" "15" "21" "99" "251")
read_len_default=100
data_default=$(number_random read_len_default)


#Testing with BAUDRATE
###################################################
Feature(){
  title b "Testing with BAUDRATE"
  printcolor w "Now connect each com port with loopback."
  printcolor w "Input com port number you need to test, or Enter to test all"
  read -p "" input
  input=${input:-"all"}

#  board_name=$(sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section adiLibInit)
#  if [[ "$board_name" =~ "LEC1"  ]]; then
#    port1="LEC1_COM""$port1"
#    port2="LEC1_COM""$port2"
#  else
#    port1="COM""$port1"
#    port2="COM""$port2"
#  fi


  case $input in
  "1")

    com_list=("LEC1_COM1")
    ;;
  "2")
    com_list=("LEC1_COM2")
    ;;
  "all")
    com_list=("LEC1_COM1" "LEC1_COM2")
    ;;
  esac

  for list in ${baudrate[*]}; do
    for com in ${com_list[*]}; do
      printf "Com port Test setting:"
      mesg=(
      "com port: $com"
      "Baud rate: $list"
      "Data: $data_default"
      )
      title_list b mesg[@]

      launch_command  "sudo ./idll-test.exe --serial-port1 $com --serial-port2 $com --BAUDRATE $list --DATABIT $databit_default --FLOWCTRL $flowctrl_default --PARITYBIT $paritybit_default --STOPBIT $stopbit_default --SERIAL_WRITE $data_default --READ_LEN $read_len_default --LOOP 1 --READ_INTERVAL $read_interval_default -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SerialPort_RW"
      result00=$(echo "$result" | grep -i "baudrate" | sed 's/\s//g')
      compare_result "$result" "passed"
      compare_result "$result00" "baudrate=$list"
    done
  done

  #Testing with DATABIT
  ###################################################
  title b "Testing with DATABIT"

  for list in ${databit[*]}; do
    for com in ${com_list[*]}; do
      printf "Com port Test setting:"
      mesg=(
      "com port: $com"
      "Databit: $list"
      "Data: $data_default"
      )
      title_list b mesg[@]

      launch_command  "sudo ./idll-test.exe --serial-port1 $com --serial-port2 $com --BAUDRATE $baudrate_default --DATABIT $list --FLOWCTRL $flowctrl_default --PARITYBIT $paritybit_default --STOPBIT $stopbit_default --SERIAL_WRITE $data_default --READ_LEN $read_len_default --LOOP 1 --READ_INTERVAL $read_interval_default -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SerialPort_RW"
      result00=$(echo "$result" | grep -i "databit" | sed 's/\s//g')
      compare_result "$result" "passed"
      compare_result "$result00" "databit=$list"
    done
  done

  #Testing with flowctrl
  ###################################################
#  title b "Testing with FLOWCTRL"
#
#  for list in ${flowctrl[*]}; do
#    for com in ${com_list[*]}; do
#      printf "Com port Test setting:"
#      mesg=(
#      "com port: $com"
#      "Flowctrl: $list"
#      "Data: $data_default"
#      )
#      title_list b mesg[@]
#
#      launch_command  "sudo ./idll-test.exe --serial-port1 $com --serial-port2 $com --BAUDRATE $baudrate_default --DATABIT $databit_default --FLOWCTRL $list --PARITYBIT $paritybit_default --STOPBIT $stopbit_default --SERIAL_WRITE $data_default --READ_LEN $read_len_default --LOOP 1 --READ_INTERVAL $read_interval_default -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SerialPort_RW"
#      result00=$(echo "$result" | grep -i "flowctrl" | sed 's/\s//g')
#      compare_result "$result" "passed"
#      compare_result "$result00" "flowCtrl=$list"
#    done
#  done

  #Testing with paritybit
  ###################################################
  title b "Testing with PARITYBIT"

  for list in ${paritybit[*]}; do
    for com in ${com_list[*]}; do
      printf "Com port Test setting:"
      mesg=(
      "com port: $com"
      "paritybit: $list"
      "Data: $data_default"
      )
      title_list b mesg[@]

      launch_command  "sudo ./idll-test.exe --serial-port1 $com --serial-port2 $com --BAUDRATE $baudrate_default --DATABIT $databit_default --FLOWCTRL $flowctrl_default --PARITYBIT $list --STOPBIT $stopbit_default --SERIAL_WRITE $data_default --READ_LEN $read_len_default --LOOP 1 --READ_INTERVAL $read_interval_default -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SerialPort_RW"
      result00=$(echo "$result" | grep -i "parity" | sed 's/\s//g')
      compare_result "$result" "passed"
      compare_result "$result00" "parity=$list"
    done
  done

  #Testing with stopbit
  ###################################################
  title b "Testing with STOPBIT"

  for list in ${stopbit[*]}; do
    for com in ${com_list[*]}; do
      printf "Com port Test setting:"
      mesg=(
      "com port: $com"
      "stopbit: $list"
      "Data: $data_default"
      )
      title_list b mesg[@]

      launch_command  "sudo ./idll-test.exe --serial-port1 $com --serial-port2 $com --BAUDRATE $baudrate_default --DATABIT $databit_default --FLOWCTRL $flowctrl_default --PARITYBIT $paritybit_default --STOPBIT $list --SERIAL_WRITE $data_default --READ_LEN $read_len_default --LOOP 1 --READ_INTERVAL $read_interval_default -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SerialPort_RW"
      result00=$(echo "$result" | grep -i "stopbit" | sed 's/\s//g')
      compare_result "$result" "passed"
      compare_result "$result00" "stopbit=$list"
    done
  done

  #Testing with different data length
  ###################################################
  title b "Testing with DATA length"

  for list in ${read_len[*]}; do
    data=$(number_random list)
    for com in ${com_list[*]}; do
      printf "Com port Test setting:"
      mesg=(
      "com port: $com"
      "Data: $data"
      )
      title_list b mesg[@]

      launch_command  "sudo ./idll-test.exe --serial-port1 $com --serial-port2 $com --BAUDRATE $baudrate_default --DATABIT $databit_default --FLOWCTRL $flowctrl_default --PARITYBIT $paritybit_default --STOPBIT $stopbit_default --SERIAL_WRITE $data --READ_LEN $list --LOOP 1 --READ_INTERVAL 1000 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SerialPort_RW"
  #    result00=$(echo "$result" | grep -i "stopbit" | sed 's/\s//g')
      compare_result "$result" "passed"
  #    compare_result "$result00" "stopbit=$list"
    done
  done
}

PortToPort(){
  com1="LEC1_COM1"
  com2="LEC1_COM2"
  title b "Testing with Port to Port"
  printcolor w "Now connect com port:($com1) with com port:($com2) with null cable."
  printcolor  w "How many loop you need to test: (at least 10)"
  read -p "" loop
  printcolor  w "Input port1 number:"
  read -p "" port1
  printcolor  w "Input port2 number:"
  read -p "" port2


  loop=${loop:-10}
  port1=${port1:-1}
  port2=${port2:-2}

  board_name=$(sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section adiLibInit)
  if [[ "$board_name" =~ "LEC1"  ]]; then
    port1="LEC1_COM""$port1"
    port2="LEC1_COM""$port2"
  else
    port1="COM""$port1"
    port2="COM""$port2"
  fi

  for (( i = 0; i < loop; i++ )); do
    for list in ${read_len[*]}; do
      data=$(number_random list)
      printf "Com port Test setting:"
      mesg=(
      "Input Data: $data_default"
      )
      title_list b mesg[@]
      launch_command  "sudo ./idll-test.exe --serial-port1 $port1 --serial-port2 $port2 --BAUDRATE $baudrate_default --DATABIT $databit_default --FLOWCTRL $flowctrl_default --PARITYBIT $paritybit_default --STOPBIT $stopbit_default --SERIAL_WRITE $data_default --READ_LEN $read_len_default --LOOP 1 --READ_INTERVAL $read_interval_default -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SerialPort_RW"
      compare_result "$result" "passed"
    done
  done
}

PinFeature(){

  printcolor  w "Input com port number:"
  read -p "" port
  port=${port:-1}
  port="LEC1_COM""$port"

  if [[ "$port" =~ "COM1" ]]; then
    mask_default=3
    set_signal_default=3
  else
    mask_default=1
    set_signal_default=1
  fi

  title b "Start setting pin."
  for (( i = 0; i < $((set_signal_default+1)); i++ )); do

    printf "Com port pin test setting:"
      mesg=(
      "Mask: $mask_default"
      "Signal value: $i"
      )

      title_list b mesg[@]
      launch_command "sudo ./idll-test.exe --serial-port $port --signal-mask $mask_default --signal-value $i -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section adiSerialSetSignal [ADiDLL][LEC1][RAWCOM][SIGNAL]"
      compare_result "$result" "signal=0x$i"
      compare_result "$result" "mask=0x$mask_default"

      title b "Confirm each pin status"
      launch_command "sudo ./idll-test.exe --serial-port $port -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section adiSerialGetSignal [ADiDLL][LEC1][RAWCOM][SIGNAL]"

      case $i in
      0)
        compare_result "$result" "RTS: 0"
        compare_result "$result" "CTS: 0"
        if [[ "$port" =~ "COM1" ]]; then
          compare_result "$result" "DTR: 0"
          compare_result "$result" "DSR: 0"
          compare_result "$result" "DCD: 0"
          compare_result "$result" "RI : 0"
        fi

        ;;
      1)
        compare_result "$result" "RTS: 1"
        compare_result "$result" "CTS: 1"
        if [[ "$port" =~ "COM1" ]]; then

          compare_result "$result" "DTR: 0"
          compare_result "$result" "DSR: 0"
          compare_result "$result" "DCD: 0"
          compare_result "$result" "RI : 0"
        fi
        ;;
      2)
        compare_result "$result" "RTS: 0"
        compare_result "$result" "CTS: 0"
        if [[ "$port" =~ "COM1" ]]; then
          compare_result "$result" "DTR: 1"
          compare_result "$result" "DSR: 1"
          compare_result "$result" "DCD: 1"
          compare_result "$result" "RI : 1"
        fi
        ;;
      3)
        compare_result "$result" "RTS: 1"
        compare_result "$result" "CTS: 1"
        if [[ "$port" =~ "COM1" ]]; then
          compare_result "$result" "DTR: 1"
          compare_result "$result" "DSR: 1"
          compare_result "$result" "DCD: 1"
          compare_result "$result" "RI : 1"
        fi
        ;;
      esac


  done

  title b "Start setting MASK value."
  for (( i = 0; i < $((mask_default+1)); i++ )); do

    printf "Com port pin test setting:"
      mesg=(
      "Mask: $i"
      "Signal value: $set_signal_default"
      )
      title_list b mesg[@]

      #reset each pin status before mask task
      sudo ./idll-test.exe --serial-port $port --signal-mask $mask_default --signal-value 0 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section adiSerialSetSignal [ADiDLL][LEC1][RAWCOM][SIGNAL]
      #start to test mask value
      launch_command "sudo ./idll-test.exe --serial-port $port --signal-mask $i --signal-value $set_signal_default -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section adiSerialSetSignal [ADiDLL][LEC1][RAWCOM][SIGNAL]"

      compare_result "$result" "signal=0x$set_signal_default"
      compare_result "$result" "mask=0x$i"

      title b "Confirm each pin status"
      launch_command "sudo ./idll-test.exe --serial-port $port -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section adiSerialGetSignal [ADiDLL][LEC1][RAWCOM][SIGNAL]"

      case $i in
      0)
        compare_result "$result" "RTS: 0"
        compare_result "$result" "CTS: 0"
        if [[ "$port" =~ "COM1" ]]; then
          compare_result "$result" "DTR: 0"
          compare_result "$result" "DSR: 0"
          compare_result "$result" "DCD: 0"
          compare_result "$result" "RI : 0"
        fi

        ;;
      1)
        compare_result "$result" "RTS: 1"
        compare_result "$result" "CTS: 1"
        if [[ "$port" =~ "COM1" ]]; then

          compare_result "$result" "DTR: 0"
          compare_result "$result" "DSR: 0"
          compare_result "$result" "DCD: 0"
          compare_result "$result" "RI : 0"
        fi
        ;;
      2)
        compare_result "$result" "RTS: 0"
        compare_result "$result" "CTS: 0"
        if [[ "$port" =~ "COM1" ]]; then
          compare_result "$result" "DTR: 1"
          compare_result "$result" "DSR: 1"
          compare_result "$result" "DCD: 1"
          compare_result "$result" "RI : 1"
        fi
        ;;
      3)
        compare_result "$result" "RTS: 1"
        compare_result "$result" "CTS: 1"
        if [[ "$port" =~ "COM1" ]]; then
          compare_result "$result" "DTR: 1"
          compare_result "$result" "DSR: 1"
          compare_result "$result" "DCD: 1"
          compare_result "$result" "RI : 1"
        fi
        ;;
      esac


  done


}
#===============================================================
#MAIN
#===============================================================
while true; do
  printf "\n"
  printf "${COLOR_RED_WD}1. COM PORT FUNCTION (LOOPBACK) ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}2. PORT TO PORT TEST ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}3. COM PORT / RAW COM FULL PIN TEST (LEC1) ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}======================================${COLOR_REST}\n"
  printf "CHOOSE ONE TO TEST: "
  read -p "" input

  if [ "$input" == 1 ]; then
    Feature
  elif [ "$input" == 2 ]; then
    PortToPort
  elif [ "$input" == 3 ]; then
    PinFeature

  fi

done