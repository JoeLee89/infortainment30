#!/bin/bash
source ./common_func.sh

size_check() {
  local result i
  for ((i = 1; i < 5; i++)); do
    result=$(sudo ./idll-test --EMEM_TYPE EMEM_EEPROM"$i" -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section EEPROM_GetMemSize | grep -i "Memory size of EMEM_EEPROM" | sed "s/Memory size of EMEM_EEPROM$i: //g" | sed "s/\s//g")
    if [[ "$result" && "$result" -ne 0 ]]; then
      size[((i-1))]=$result
    fi
  done
  eeprom=${#size[@]}
}

size_check
write_data

#===============================================================
#Start Reading/Writing EEPROM data (AUTO Test)
#===============================================================
EepromReadWrite_Auto(){
  title b "Start Reading/Writing EEPROM data (AUTO Test)"
  printcolor w "Press looping number to test or [q] key to skip.. \n"
  read -p "loop time:" input
  x=0
  while true; do

    if [ "$input" == "q" ] || [ "$input" == "" ]|| [ "$input" == "Q" ]; then
      break
    elif [ "$x" -lt "$input" ]; then
      sudo ./idll-test --LOOP 1 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section EEPROM_Auto
    fi

    if [ "$x" == "$input" ]; then
        printf "Press looping number to test or [q] key to skip.. \n"
        read -p "" input
        x=0
    fi
    (( x++ ))
  done
}

#===============================================================
#EEPROM SIZE CHECK
#===============================================================
EepromSize(){
  title b "EEPROM data capacity check"

  for q in $(seq 1 $eeprom);do
#    title b "assume eeprom capacity = $size"
    launch_command "sudo ./idll-test --EMEM_TYPE EMEM_EEPROM$q -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section EEPROM_GetMemSize"

#    title b "Capacity check result"
#    compare_result "$result" "$size"
  done

  title r "**Please confirm if eeproms size above are correct as project spec. "
}

#===============================================================
# read/write with same/random data function test
#===============================================================

write_RandomSamePattern(){
  local ee_size choise content position m
  ee_size=$1
  choise=$2
  type=$3
  data=""

  m=0
  for (( position = 0; position < ee_size; position++ )); do
    if [[ "$m" -eq $((${#write_data[@]}-2)) ]]; then
      m=0
    else
      ((m++))
    fi

    if [[ "$type" == "same"  ]]; then
      data="254"
    else
      data=${write_data[$m]}
    fi

    mseg=(
    "Writing data to sram with below info"
    "============================================"
    "EEPROM ID: $choise"
    "EEPROM position: $position"
    "EEPROM data: $data"
    )
    title_list b mseg[@]

    launch_command "sudo ./idll-test --WRITE_MEM EMEM_EEPROM$choise,$position,$data -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section EEPROM_Write"
    compare_result "$result" "pass"
    compare_RandomSamePattern "$choise" "$data" "$position"
  done
}


compare_RandomSamePattern(){
  local position content choise data
  position=$3
  choise=$1
  data=$2

  #convert 10dex to 16hex format, dut to the god damn ouput in hex format
  content=$( echo "obase=16;$data"|bc )
  if [[ ${#content} -eq 1 ]]; then
    content=0x0$content
  else
    content=0x$content
  fi

  printf "\n\n\n\n\n"
  title b "Compare data process: the expected result should include data as the following list:"
  title b "Assuming data = $content"
  launch_command "sudo ./idll-test --READ_MEM EMEM_EEPROM$choise,$position,1 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section EEPROM_Read"
  compare_result "$result" "$content"
}


EepromReadWrite_RandomSamePattern(){
  local input type input02 i target_eeprom target_writing_size target_writing_size_list
  title b "ALL EEPROMs read/write with same/random data function test "
  read -p "Input how many byte need to write, or just enter to test with all supported size for each EEPROM: " input
  read -p "Input which EEPROM needed to write, or just enter to test with all supported EEPROM(1-2): " input02

  amount=${#size[@]}
  list=${size[*]}
  target_eeprom=${input02:-"all"}

  #make target_writing_size content has the same amount as actual eeproms plugged in, if user choose specific data length to test on all eeproms
  #if user choosed all eeprom, then will $make target_writing_size the same value as $size
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
    target_writing_size_list=${target_writing_size[$((target_eeprom-1))]}
  fi

  mseg=(
  "Total EEPROM amount: $amount"
  "EEPROM original size (0-end): $list"
  "=================================================="
  "Target EEPROM : $target_eeprom"
  "EEPROM target writing size: $target_writing_size_list"
  )
  title_list b mseg[@]
  read -p "Test will start with above info, please Confirm if they are correct."

  for type in "random" "same";do
    if [ "$target_eeprom" == "all" ]; then
      for number in $(seq 1 "$amount"); do
        #point the correct size saved in target_writing_size list, while user input the only one eeprom
        writing_size=${target_writing_size[$((number-1))]}
        write_RandomSamePattern "$writing_size" "$number" "$type"
      done
    else
      #point the correct size saved in target_writing_size list, while user input the only one eeprom
      writing_size=${target_writing_size[$((target_eeprom-1))]}
      write_RandomSamePattern "$writing_size" "$target_eeprom" "$type"
    fi
  done
}

read_write_directly(){
  loal target size
  read -p "Input how many byte need to write, or just enter to test with all supported size for each EEPROM: " size
  read -p "Input which EEPROM needed to write, or just enter to test with all supported EEPROM(1-2): " target
  write_RandomSamePattern "$size" "$target" "random"
}

#===============================================================
#bad parameter
#===============================================================
BadParameter(){
  #test with bad address
  printf  "${COLOR_RED_WD}Now test with bad address ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}========================= ${COLOR_REST}\n"
  read -p "" continue

  printf  "${COLOR_RED_WD}sudo ./idll-test --WRITE_MEM EMEM_EEPROM1,100000000,0,1,2,3,4,5,6,7,8,9 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section EEPROM_Write ${COLOR_REST}\n"
  sudo ./idll-test --WRITE_MEM EMEM_EEPROM1,100000000,0,1,2,3,4,5,6,7,8,9 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section EEPROM_Write

  printf  "${COLOR_RED_WD}sudo ./idll-test --READ_MEM EMEM_EEPROM1,1000000000,10 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section EEPROM_Read ${COLOR_REST}\n"
  sudo ./idll-test --READ_MEM EMEM_EEPROM1,1000000000,10 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section EEPROM_Read

  #Now test with bad data
  printf  "${COLOR_RED_WD}Now test with bad data ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}=======================${COLOR_REST}\n"
  read -p "" continue
  sudo ./idll-test --WRITE_MEM EMEM_EEPROM1,0,##77**,1,2,3,4,5,6,7,8,9 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section EEPROM_Write
  sudo ./idll-test --WRITE_MEM EMEM_EEPROM1,0,@#999999,1,2,3,4,5,6,7,8,9 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section EEPROM_Write

  #test with bad reading length
  printf  "${COLOR_RED_WD}Now test with bad reading length ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}================================${COLOR_REST}\n"
  read -p "" continue
  sudo ./idll-test --READ_MEM EMEM_EEPROM1,1,99999999910 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section EEPROM_Read
}


#===============================================================
#data iterating stack read/write
#===============================================================
write(){
  printf "\n\n\n\n"

  title b "Write data to eeprom"
  title b "data : $1"
  launch_command "sudo ./idll-test --WRITE_MEM EMEM_EEPROM$2,0,$1 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section EEPROM_Write"
#  sudo ./idll-test --WRITE_MEM EMEM_EEPROM"$2",0,$1 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section EEPROM_Write
  printf "\n"
}

read_data(){
  data_length=$(($1+1))

  printf "\n\n\n\n"
  title b "Read all data from eeprom first, and then compare the result"
  launch_command "sudo ./idll-test --READ_MEM EMEM_EEPROM$2,0,$data_length -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section EEPROM_Read"

  #n means loop write_data list, if the n number is higher the the length of write_data, it will cause fail not to get the write_data,
  #so it need to reset back to n=0, keep looping to get write_data value.
  n=0
  for (( p = 0; p < data_length; p++ )); do
#    content="$p:	${write_data[$n]}"
    write_data_hexx=$( echo "obase=16;${write_data[$n]}"|bc )

    if [ "$write_data_hexx" == "0" ]; then
      write_data_hexx="00"
    fi

    if [ "$p" == 0 ]; then
      content=x$write_data_hexx
    else
      content="$content$write_data_hexx"
    fi



    if [[ "$n" < $((${#write_data[*]}-1)) ]]; then
      ((n++))
    else
      n=0
    fi

  done
  title b "Start to verify eeprom data with expected data"
  title b "Assuming data: ( $content )"
  compare_result "$result" "$content"
}

main(){
  local i m deviceid
  loop=${size[$((deviceid-1))]}

  read -p "Type the device number (id) you want to verify (1-3): " deviceid
  printcolor b "Below is the verify basic setting"
  printcolor b "================================="
  printcolor b "Device ID = $deviceid"
  printcolor b "Writing data size= $loop byte"
  printcolor b "Looping data= ${write_data[*]}"
  printcolor b "================================="
  read -p "enter key to test..."


#  loop=10
  for (( i = 0; i < loop; i++ )); do
    #m is the list pointer
    m=0
    for (( k = 0; k < $((i+1)); k++ )); do
      command_data=$command_data${write_data[$m]},

#      temp_list[$m]=${write_data[$m]}
  #    printf "\n${#tm_data}\n"
      #confirm how many strings in command_data
      len=${#command_data}
      len=$((len-1))

      #the last strings need to be remove, it will add repeaded // string
      result_data=${command_data:0:$len}

#      printf " m=$m\n"
#      printf " k=$k\n"
#      printf " writedata=${write_data[$m]}\n"
#      printf " result=$result_data\n"
#      printf " temp_list=${temp_list[*]}\n\n"

      if [[ "$m" < $((${#write_data[*]}-1)) ]]; then
        ((m++))
      else
        m=0
      fi



    done
    echo "data=$result_data"
    echo "device id=$deviceid"
#    read -p ""
    if [ "$result_data" ]; then
      write "$result_data" "$deviceid"
      read_data "$i" "$deviceid"
    fi

    command_data=""
#    temp_list=("")

  done
}

#===============================================================
#MAIN
#===============================================================
while true; do
  printf "\n"
  printf "${COLOR_RED_WD}1. EEPROM READ/WRITE (AUTO TEST) ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}2. EEPROM SIZE ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}3. EEPROM READ/WRITE SAME/RANDOM DATA${COLOR_REST}\n"
  printf "${COLOR_RED_WD}4. DATA STACK ITERATING WRITE/READ ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}5. BAD PARAMETER ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}6. EEPROM READ/WRITE DATA DIRECTLY ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}======================================${COLOR_REST}\n"
  printf "CHOOSE ONE TO TEST: "
  read -p "" input

  if [ "$input" == 1 ]; then
    EepromReadWrite_Auto
  elif [ "$input" == 2 ]; then
    EepromSize
  elif [ "$input" == 3 ]; then
    EepromReadWrite_RandomSamePattern
  elif [ "$input" == 4 ]; then
    main
  elif [ "$input" == 5 ]; then
    BadParameter
  elif [ "$input" == 6 ]; then
    read_write_directly
  fi

done