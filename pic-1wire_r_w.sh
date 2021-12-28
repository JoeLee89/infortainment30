#!/bin/bash
source ./common_func.sh
#the definition of writing data to eeprom
#the data content can be extended by space for each data
write_data

size_check() {
  local result i
  for ((i = 0; i < 3; i++)); do
    result=$(sudo ./idll-test.exe --dallas-eeprom-write 0:0:255 -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_1Wire_EEPROM_Manual_write | grep -i "device $i" | sed "s/1Wire - device $i size: //g" | sed "s/1Wire-device$i//g" | sed "s/size://g" |sed "s/\s//g")
    if [[ "$result" && "$result" -ne 0 ]]; then
      size[$i]=$result
      wire_number=${#size[@]}
    fi

  done
}
size_check

#===============================================================
#auto test same/random pattern loop test
#===============================================================
WireWriteSave_Auto() {
  #  title b "auto test same/random pattern loop test   \nTest should test on both only [1] and [all] 1-wire devices are connected condition \n(please test at least 20 times)"
  msg=(
    "Auto test same/random pattern loop test"
    "Please test both only [1] and [all] 1-wire devices are connected test"
    "(please test at least 20 times)"
  )
  title_list r "msg[@]"
  read -p "Press looping number to test or [q] key to skip: " input
  x=0

  while true; do
    #    printf "X=$x \n"
    #    printf "input=$input\n"

    if [[ "$input" == "q" || "$input" == "" ]]; then
      break
    elif [[ "$x" -lt "$input" ]]; then
      launch_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_1Wire_EEPROM_Same_Pattern_0xA5"
      compare_result "$result" "pass"
      launch_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_1Wire_EEPROM_Random_Pattern"
      compare_result "$result" "pass"
    fi

    #    if [[ "$result1" =~ 'fail' ]] || [[ "$result2" =~ 'fail' ]]; then
    #      printf "${COLOR_RED_WD}Found error \n${COLOR_REST}"
    #      read -p ""
    #      break
    #    else
    #      printf "${COLOR_YELLOW_WD}Test Pass.. \n${COLOR_REST}"
    #    fi

    if [[ "$x" == "$input" ]]; then
      printf "Press looping number to test or [q] key to skip.. \n"
      printf "Loop times: "
      read -p "" input
      x=0
    fi

    ((x++))

  done
}

#===============================================================
#1-wire 00 chip function test
#===============================================================

write_RandomSamePattern(){
  local ee_size choise content position m
  ee_size=$1
  choise=$2
  type=$3
  data=""

  m=0
  for (( position = 0; position < ee_size; position++ )); do
    if [[ "$m" -gt $((${#write_data[@]}-2)) ]]; then
      m=0
    else
      ((m++))
    fi

    if [[ "$type" == "same"  ]]; then
      data="254"
    else
      data=${write_data[$m]}
    fi
#    echo "type=$type"
#    echo "choise=$choise"
#    echo "data=$data"
    launch_command "sudo ./idll-test.exe --dallas-eeprom-write $choise:$position:$data -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_1Wire_EEPROM_Manual_write"
    compare_RandomSamePattern "$choise" "$data" "$position"
  done
}


compare_RandomSamePattern(){
  local position content choise
  position=$3
  choise=$1
  data="0:	$2"

#  #convert 10dex to 16hex format, dut to the god damn ouput in hex format
#  content=$( echo "obase=16;$data"|bc )
#  if [[ ${#content} -eq 1 ]]; then
#    content=0x0$content
#  else
#    content=0x$content
#  fi

  printf "\n\n\n\n\n"
  title b "The expected result should include data as the following list:"
  title b "Assuming data = $data"
  launch_command "sudo ./idll-test.exe --dallas-eeprom-read $choise:$position:1 -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_1Wire_EEPROM_Manual_read"
  compare_result "$result" "$data"
}


Wire0_WriteSave_Manual(){
  local input type input input02 i target_eeprom writing_size
  title b "ALL 1wires read/write with same/random data function test "
  read -p "Input how many byte need to write, or just enter to test with all supported size for each 1wire: " input
  read -p "Input which 1wire needed to write, or just enter to test with all supported 1wire(0-2): " input02

  amount=${#size[@]}
  list=${size[*]}
  target_eeprom=${input02:-"all"}

  #make target_writing_size content has the same amount as actual eeproms plugged in, if user choose specific data length to test on all eeproms
  #if user choosed all eeprom, then will make $target_writing_size the same value as $size
  #so next process will depend on user eeprom choise to save data with the right data length
  if [ "$input" ]; then
    for (( i = 0; i < amount; i++ )); do
      target_writing_size[$i]=$input
    done
  else
    target_writing_size=("${size[@]}")
  fi

  if [ "$target_eeprom" == "all" ]; then
    target_writing_size_list=${target_writing_size[@]}
  else
#    printcolor r "${target_writing_size[$input02]}"
    target_writing_size_list=${target_writing_size[$target_eeprom]}
  fi

  mseg=(
  "Total 1wire amount: $amount"
  "1wire original size (0-end): $list"
  "=================================================="
  "Target 1wire : $target_eeprom"
  "1wire target writing size: $target_writing_size_list"
  )
  title_list r mseg[@]
  read -p "Test will start with above info, please Confirm if they are correct."

  for type in "random" "same";do
    if [ "$target_eeprom" == "all" ]; then
      for number in $(seq 0 "$amount"); do
        #point the correct size saved in target_writing_size list, while user input the only one eeprom
        writing_size=${target_writing_size[$number]}
        write_RandomSamePattern "$writing_size" "$number" "$type"
      done
    else
      #point the correct size saved in target_writing_size list, while user input the only one eeprom
      writing_size=${target_writing_size[$target_eeprom]}
      echo "$writing_size"
      echo "$target_eeprom"
      echo "$type"
      write_RandomSamePattern "$writing_size" "$target_eeprom" "$type"
    fi
  done

}
read_write_directly(){
  local wireid size
  read -p "Input how many byte need to write for each 1wire: " size
  read -p "Input which 1wire needed to write supported 1wire(0-2): " wireid
  size=${size:-"50"}
  wireid=${wireid:-"0"}
  write_RandomSamePattern "$size" "$wireid" "random"
}


#===============================================================
#Search / Check i-wire ID
#===============================================================
SearchID() {
  title b "Search / Check i-wire ID"
  print_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_1Wire_IDs"
  sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_1Wire_IDs
  msg=(
    "device 0 size: ${size[0]}"
    "device 1 size: ${size[1]}"
    "device 2 size: ${size[2]}"
  )
    title_list y "msg[@]"
}

#===============================================================
#Bad parameter check
#===============================================================
BadParameter() {
  printf "${COLOR_RED_WD}Now test with bad address ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}=========================  ${COLOR_REST}\n"
  read -p "enter key to test..." continue
  bad=9999999999
  for all in $(seq 0 2); do
    printf "${COLOR_RED_WD}sudo ./idll-test.exe --dallas-eeprom-write $all:$bad:255/255/255 -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_1Wire_EEPROM_Manual_write ${COLOR_REST}\n"
    sudo ./idll-test.exe --dallas-eeprom-write $all:$bad:255/255/255 -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_1Wire_EEPROM_Manual_write
    sleep 0.5
    printf "${COLOR_RED_WD}sudo ./idll-test.exe --dallas-eeprom-read $all:$bad:3 -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_1Wire_EEPROM_Manual_read ${COLOR_REST}\n"
    sudo ./idll-test.exe --dallas-eeprom-read $all:$bad:3 -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_1Wire_EEPROM_Manual_read
  done

  printf "${COLOR_RED_WD}Now test with bad data ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}======================  ${COLOR_REST}\n"
  read -p "" continue
  bad="g/g/g"
  for all in $(seq 0 2); do
    printf "${COLOR_RED_WD}sudo ./idll-test.exe --dallas-eeprom-write $all:0:$bad -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_1Wire_EEPROM_Manual_write ${COLOR_REST}\n"
    sudo ./idll-test.exe --dallas-eeprom-write $all:0:$bad -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_1Wire_EEPROM_Manual_write
  done

  printf "${COLOR_RED_WD}Now test with bad reading length ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}================================  ${COLOR_REST}\n"
  read -p "" continue
  for all in $(seq 0 2); do
    printf "${COLOR_RED_WD}sudo ./idll-test.exe --dallas-eeprom-read $all:0:-1 -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_1Wire_EEPROM_Manual_read ${COLOR_REST}\n"
    sudo ./idll-test.exe --dallas-eeprom-read $all:0:-1 -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_1Wire_EEPROM_Manual_read
  done
}

#===============================================================
#data iterating stack read/write
#===============================================================
write() {
  title "writing data : $1"
  launch_command "sudo ./idll-test.exe --dallas-eeprom-write $2:0:$1 -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_1Wire_EEPROM_Manual_write"
  compare_result "$result" "passed"
}

read_data() {
#  data_length=$(($1 + 1))
  local n=0
  local content p data_length

  data_length=$(($1+1))
  #  title "writing data : $1"
  #  printf "data_length=$data_length\n"
  launch_command "sudo ./idll-test.exe --dallas-eeprom-read $2:0:$data_length -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_1Wire_EEPROM_Manual_read"


  for ((p = 0; p < data_length; p++)); do
    content="$p:	${write_data[$n]}"

    msg=(
      "The test will assume the expected data like the following setting"
      "The expected data: $content"
    )
    title_list b "msg[@]"
    compare_result "$result" "$content"

    if [[ "$n" < $((${#write_data[*]} - 1)) ]]; then
      ((n++))
    else
      n=0
    fi

  done
}

main() {
  local i k m deviceid msg
  read -p "Type the device number(ID) you want to verify (0-2): " deviceid
  loop=${size[$deviceid]}
  #  command_data=""

  msg=(
    "Below is the verify basic setting"
    "================================="
    "Device ID = $deviceid"
    "Writing data size= $loop bit"
    "Looping data= ${write_data[*]}"
  )
  title_list b msg[@]
  read -p "enter key to test..."


  for ((i = 0; i < loop; i++)); do

    #m is the list pointer
    m=0
    #repeat write_data / read data from 0~$i for each test for the following test
    for ((k = 0; k < $((i+1)); k++)); do

      command_data=$command_data${write_data[$m]}/
      #confirm how many strings in command_data
      len=${#command_data}
      len=$((len - 1))
      #the last strings need to be remove, it will add repeated "//" string
      result_data=${command_data:0:$len}

      if [[ "$m" < $((${#write_data[*]} - 1)) ]]; then
        ((m++))
      else
        m=0
      fi
    done

    if [ "$result_data" ]; then
      write "$result_data" "$deviceid"
      read_data "$i" "$deviceid"
    fi

    command_data=""

  done
}

#===============================================================
#MAIN
#===============================================================

while true; do
  printf "\n"
  printf "${COLOR_RED_WD}1. ALL 1-WIRE READ/WRITE AUTO ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}2. 1-WIRE_READ/WRITE MANUAL ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}3. SEARCH ID / SIZE${COLOR_REST}\n"
  printf "${COLOR_RED_WD}4. BAD PARAMETER ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}5. 1-WIRE_READ/WRITE DIRECTLY ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}6. DATA STACK ITERATING WRITE/READ ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}======================================${COLOR_REST}\n"
  printf "CHOOSE ONE TO TEST: "
  read -p "" input

  if [ "$input" == 1 ]; then
    WireWriteSave_Auto
  elif [ "$input" == 2 ]; then
    Wire0_WriteSave_Manual
  elif [ "$input" == 3 ]; then
    SearchID
  elif [ "$input" == 4 ]; then
    BadParameter
  elif [ "$input" == 5 ]; then
    read_write_directly
  elif [ "$input" == 6 ]; then
    main

  fi

done
