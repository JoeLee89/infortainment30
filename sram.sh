#!/bin/bash
source ./common_func.sh

sram_info(){
  #before process , it needs to reset sram mirror as none mirror
  temp=$(sudo ./idll-test.exe --sram-read 1:0:1 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_read)

  bank=$(sudo ./idll-test.exe --SOURCE_BANK 0x0 --DEST_BANK 0x1 --ADDRESS 0x0 --LENGTH 0x1 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SramBankCompareManual | grep -i "sram bank" | sed 's/SRAM Bank\[Number:Size\]\=\[0x//g' | sed 's/:0x[0-9]*]//g' | sed 's/\s//g')
  #display each bank capacity in hex unit
  bank_capacity_hex=$(sudo ./idll-test.exe --SOURCE_BANK 0x0 --DEST_BANK 0x1 --ADDRESS 0x0 --LENGTH 0x1 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SramBankCompareManual | grep -i "sram bank" | sed 's/SRAM Bank\[Number:Size\]\=\[0x//g' | sed 's/[0-9]:0x//g' | sed 's/\]//g' | sed 's/\s//g')

  bank_amount=$(sudo ./idll-test.exe --SOURCE_BANK 0x0 --DEST_BANK 0x1 --ADDRESS 0x0 --LENGTH 0x1 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SramBankCompareManual | grep -i "sram bank" | sed 's/SRAM Bank\[Number:Size\]\=\[0x//g' | sed 's/\s//g')

#  #display how many bank
  bank_amount=$(echo ${bank_amount:0:1})

  #incase if the project doesn't support to provide each bank info, it nees manual input info.
  if [[ "$bank_capacity_hex" == "" && "$bank_amount" == "" ]]; then
    echo "looks like some idlls are NOT supported for providing bank info, please input each bank capacity"
    echo "Note: Do NOT input '0x' strings, only number in HEX format (ex. 7fffff):"
    read -p "" capacity
    echo ""
    echo "Please input how many bank is supported: "
    read -p "" amount
  fi
  bank_capacity_hex=$capacity
  bank_amount=$amount


  #display sram capacity in dec unit
  address=$(sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Capacity | grep -i 'SRAM size' | sed 's/SRAM size: //g' | sed 's/\/r//g' | sed 's/\s//g' |sed 's/]//g')

  #display sram capacity in dec unit
#  address=$(echo ${address:0:8})

  #display bank capacity for each bank in dec format
  address_dec=$((16#$bank_capacity_hex))

  bank_address=""
#  echo "bankamount=$bank_amount"
  for (( p = 0; p < bank_amount; p++ )); do
    bank_address[$p]=$((address_dec*p))
  done

  #bank address list for some function usage
#  bank_address=(${bank_address_list[@]})
  echo "SRAM each bank first address = ${bank_address[*]}"
  #input how many SRAM size
  totalsize=$address

}

sram_info
write_data

#===============================================================
#SRAM sync/vsync test
#===============================================================
SramSyncVsync_Repeat(){
  local i
  title b "Auto test sync/vsync date test (repeat 10 times)"
  read -p ""

  for (( i = 0; i < 10; i++ )); do
    title b "Async sram test (repeat 10 times)"
    launch_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section ASYNC_SRAM"
    verify_result "$result"

    title b "Sync sram test (repeat 10 times)"
    launch_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SYNC_SRAM"
    verify_result "$result"

    if [ "$status" == "fail" ]; then
      break

    fi

  done

}
#===============================================================
#SRAM auto test with random/same pattern data
#===============================================================
SramAutoRandomSame(){
  title b "Auto test with same/random date test (repeat 10 times)"
  read -p "enter key to test..."

  for (( i = 0; i < 10; i++ )); do
    title b "Same pattern date test (repeat 10 times)"

    launch_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Same_Pattern_0xA5"
    verify_result "$result"

    launch_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Random_Pattern"
    verify_result "$result"

    if [ "$status" == "fail" ]; then
      break
    fi

  done

}
#===============================================================
#SRAM capacity check
#===============================================================
SramCapacity(){
#  sram_info
  title b "SRAM capacity check, while set it sram in mirror 1"
  launch_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Capacity"
#  sram_info
  printcolor y "sram size = $totalsize"
  printcolor y "sram bank amount = $bank_amount"
  printcolor y "sram each bank size = $address_dec"

  if [[ "$result" =~ $totalsize ]]; then
    printf  "\n${COLOR_YELLOW_WD}SRAM capacity PASS ${COLOR_REST}\n"
  else
    printf  "\n${COLOR_RED_WD}SRAM capacity is incorrect as setting SRAM = $sram_size, please check your DUT. ${COLOR_REST}\n"
    read -p ""
  fi
}


#===============================================================
#SRAM read/write with same/random data function test
#===============================================================
SramManualSramRandom(){
#  sram_info
  local m
  m=0
#  #input write how many byte you need 1=1byte=100000000
#  loop=1000
#  #input what data you need to write in each eeprom in DEX format
#  write_data=("255" "254" "111" "99" "0")
  printf "input write how many byte you need or Enter for all supported size:  \n"
  read -p "" input
  loop=${input:-totalsize}

  for f in 0 1; do
    if [ "$f" -eq 0 ]; then
      title b "Random writing data test"
    else
      title b "Same writing data test"
    fi

    for (( i = 0; i < loop; i++ )); do

        if [ "$m" -eq ${#write_data[*]} ]; then
          m=0
        fi

        #======================
        #write data
        title b "Writing data test"
        if [ "$f" -eq 0 ]; then
          data="0:	${write_data[$m]}"
          launch_command "sudo ./idll-test.exe --sram-write 1:$i:${write_data[$m]} -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_write"
        else
          data="0:	255"
          launch_command "sudo ./idll-test.exe --sram-write 1:$i:255 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_write"
        fi

        #======================
        #compare data
        printf "\n\n"

        title b "Compare Data"
        title b "Assuming data = $data "
        launch_command "sudo ./idll-test.exe --sram-read 1:$i:1 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_read"
        compare_result "$result" "$data"
        compare_result "$result" "mirror mode: 1"

        if [[ "$m" < ${#write_data[*]} ]]; then
          (( m++ ))
        fi

    done
    #sudo ./idll-test.exe --dallas-eeprom-write 0:4:99 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_1Wire_EEPROM_Manual_write

#    m=0
#    for (( i = 0; i < loop; i++ )); do
#        if [ "$m" -eq ${#write_data[*]} ]; then
#          m=0
#        fi
#
#        if [ "$f" -eq 0 ]; then
#          data="0:	${write_data[$m]}"
#        else
#          data="0:	255"
#        fi
#
#        title b "Assuming data = $data "
#        launch_command "sudo ./idll-test.exe --sram-read 1:$i:1 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_read"
#        compare_result "$result" "$data"
#        compare_result "$result" "mirror mode: 1"
#
#
#        if [[ "$m" -lt ${#write_data[*]} ]]; then
#          (( m++ ))
#        fi
#    done
  done

}
#===============================================================
#writing data in wrong address based on mirror mode maximum address to add extra 1 byte
#===============================================================
write_wrong_address(){
  echo ""
  #set up the third bank, because it is used only front 2 banks for mirror mode, no matter how the mirror 1 or 3 is.
  address=${bank_address[2]}
  title b "Now read the address out of the define in mode$1 : $address"
  launch_command "sudo ./idll-test.exe --sram-read $1:$address:1 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_read"
  compare_result "$result" "failed"

  echo ""
  title b "Now write the address out of the define in mode$1 : $address"
  launch_command "sudo ./idll-test.exe --sram-write $1:$address:255 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_write"
  compare_result "$result" "failed"
}

#===============================================================
#SRAM mirror 1 to all function test
#===============================================================

Sram_Mirror_1_All(){
  local m loop input_size
  local mirror_mode=3
  sram_info

  sram_bank_amount1=$bank_amount
  sram_each_bank_size1=$address_dec

  printcolor r "Enter the number to divide by to result in sram size in mirror mode:"
  read -p "" input
  printcolor r "Input how many byte you need to test or ENTER to test on all supported size:"
  read -p "" input_size
  loop=${input_size:-$address_dec}
  echo "loop= $loop"

  after_size=$((totalsize/input))
  size="SRAM size: $after_size"
  echo "$size"

  m=0
  for (( i = 0; i < loop; i++ )); do

      if [ "$m" == ${#write_data[*]} ]; then
        m=0
      fi

      launch_command "sudo ./idll-test.exe --sram-write $mirror_mode:$i:${write_data[$m]} -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_write"

      #comfirm sram capacity with mirror mode 3
      if [[ "$result" =~ $size ]]; then
        printcolor b  "\nSram capacity check PASS \n\n"
      else
        printcolor r  "\nSram capacity check FAIL \n\n"
        read -p ""
      fi

      #comfirm sram mirror mode
      compare_result "$result" "mirror mode: $mirror_mode"



      if [[ "$m" -lt ${#write_data[*]} ]]; then
        (( m++ ))
      fi

  done

  #read data / compare data with mirror mode1 /3
  title b "read data / compare data with mirror mode 1 / 3 "
  m=0
  for (( i = 0; i < loop; i++ )); do
      if [ "$m" -eq ${#write_data[*]} ]; then
        m=0
      fi

      data="0:	${write_data[$m]}"

      printf "\n\n\n\n\n"
      title b "Expected including data for the following test result = $data "

      #check data with Mirror=3
      title b "Mirror = 3 to check data with bank0"
      launch_command "sudo ./idll-test.exe --sram-read $mirror_mode:$i:1 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_read"
      compare_result "$result" "$data"

      sram_info
      sram_bank_amount2=$bank_amount
      sram_each_bank_size2=$address_dec

      if [[ "$sram_bank_amount2" -ne  "$sram_bank_amount1" || "$sram_each_bank_size2" -ne "$sram_each_bank_size1" ]]; then
        printcolor r "The following test result is different"
        printcolor r "======================================="
        printcolor r "the sram info BEFORE sram mirror test"
        printcolor r "the sram bank =$sram_bank_amount1"
        printcolor r "the sram bank size = $sram_each_bank_size1"
        printcolor r "======================================="
        printcolor r "the sram info AFTER sram mirror test"
        printcolor r "the sram bank =$sram_bank_amount2"
        printcolor r "the sram bank size = $sram_each_bank_size2"
        read -p ""
      fi

      #check data with bank0 with mirror=1
      title b "Mirror=1 to check data with bank0"
      launch_command "sudo ./idll-test.exe --sram-read 1:$i:1 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_read"
      compare_result "$result" "$data"

      #check data with all supported bank with mirror=1
      for address in ${bank_address[*]}; do
        if [ "$address" -ne 0 ]; then
          title b "Mirror=1 to check data other banks"
          launch_command "sudo ./idll-test.exe --sram-read 1:$(( address+i )):1 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_read"
          compare_result "$result" "$data"
        fi

      done

      if [[ "$m" < ${#write_data[*]} ]]; then
        (( m++ ))
      fi
  done

  #confirm if there is error returned, while writing in wrong address
  write_wrong_address "$mirror_mode"
}

#===============================================================
#SRAM mirror 2 to 2 function test SCXX/SA3
#===============================================================
Sram_Mirror_2_2_ScxxSa3(){
  local m loop
  local mirror22_mode=4

  printcolor r "enter the number to divide by to result in sram size in mirror mode:"
  read -p "" input
  printcolor r "Input how many byte you need to test or ENTER to test on all supported size:"
  read -p "" input_size

  loop=${input_size:-$address_dec}


  after_size=$((totalsize/input))
  size="SRAM size: $after_size"

  title b "Now test with mirror 2 to 2 "
  m=0
  for (( i = 0; i < loop; i++ )); do

      if [ "$m" == ${#write_data[*]} ]; then
        m=0
      fi

      #write data in bank0 first
      launch_command "sudo ./idll-test.exe --sram-write $mirror22_mode:$i:${write_data[$m]} -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_write"

      #write data in bank1 , the address will refer to bank1 first address + $i parameter
      launch_command "sudo ./idll-test.exe --sram-write $mirror22_mode:$((i+bank_address[1])):${write_data[$m]} -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_write"

      #comfirm sram capacity with mirror mode 4
      compare_result "$result" "$size"
      verify_result "$result"

      if [[ "$m" < ${#write_data[*]} ]]; then
        (( m++ ))
      fi

  done

  sram_info
  sram_bank_amount1=$bank_amount
  sram_each_bank_size1=$address_dec

  #read data / compare data with mirror mode1 / 4
  m=0
  for (( i = 0; i < loop; i++ )); do
      if [ "$m" == ${#write_data[*]} ]; then
        m=0
      fi

      data="0:	${write_data[$m]}"

      printf "\n\n\n\n\n"
      title b "Expected including data for the following test result = $data"

      #Mirror=4 to check data
      title b "Mirror=4 to check data with bank 0 / 1"

      launch_command "sudo ./idll-test.exe --sram-read $mirror22_mode:$i:1 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_read"
      verify_result "$result"
      compare_result "$result" "$data"

      launch_command "sudo ./idll-test.exe --sram-read $mirror22_mode:$((i+bank_address[1])):1 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_read"
      verify_result "$result"
      compare_result "$result" "$data"

      sram_info
      sram_bank_amount2=$bank_amount
      sram_each_bank_size2=$address_dec

      if [[ "$sram_bank_amount2" -ne  "$sram_bank_amount1" || "$sram_each_bank_size2" -ne "$sram_each_bank_size1" ]]; then
        printcolor r "The following test result is different"
        printcolor r "======================================="
        printcolor r "the sram info BEFORE sram mirror test"
        printcolor r "the sram bank =$sram_bank_amount1"
        printcolor r "the sram bank size = $sram_each_bank_size1"
        printcolor r "======================================="
        printcolor r "the sram info AFTER sram mirror test"
        printcolor r "the sram bank =$sram_bank_amount2"
        printcolor r "the sram bank size = $sram_each_bank_size2"
      fi

      #data compare data with mirror 1
      #Mirror=1 to check data with bank 0/2
      title b "Mirror=1 to check data with bank 0 / 2"
      for a in ${bank_address[0]} ${bank_address[2]}; do
        if [ "$a" ]; then
          launch_command "sudo ./idll-test.exe --sram-read 1:$((i+a)):1 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_read"
          verify_result "$result"
          compare_result "$result" "$data"
        fi

      done

      #Mirror=1 to check data with bank 1/3
      title b "Mirror=1 to check data with bank 1 / 3"
      for a in ${bank_address[1]} ${bank_address[3]}; do

        if [ "$a" ]; then
          launch_command "sudo ./idll-test.exe --sram-read 1:$((i+a)):1 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_read"
          verify_result "$result"
          compare_result "$result" "$data"

        fi

      done

      if [[ "$m" < ${#write_data[*]} ]]; then
        (( m++ ))
      fi
  done

  #confirm if there is error returned, while writing in wrong address
  write_wrong_address "$mirror22_mode"
}


#===============================================================
# (LEC1) (A3) SRAM mirror 2 to 2 function test
#===============================================================
Sram_Mirror_2_2_Lec1(){
  local m loop
  local mirror_mode=2
#  sram_info
  printcolor r "Enter the number to divide by to result in sram size in mirror mode:"
  read -p "" input
  printcolor r "Input how many byte you need to test or ENTER to test on all supported size:"
  read -p "" input_size
  loop=${input_size:-$address_dec}

  after_size=$((totalsize/input))
  size="SRAM size: $after_size"


  title b "(LEC1 only) Now test with mirror 2 to 2"
  #read -p " " continue

  for (( i = 0; i < loop; i++ )); do

      if [ "$m" == ${#write_data[*]} ]; then
        m=0
      fi
      #will write the same data in both bank 0/2, so both bank all have the same data.
      #write data in bank0 first
      launch_command "sudo ./idll-test.exe --sram-write $mirror_mode:$i:${write_data[$m]} -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_write"
      verify_result "$result"

      #write data in bank1 , the address will refer to bank1 first address + $i parameter
      if [[ "${bank_address[1]}" && "$bank_amount" -lt 2 ]]; then
        launch_command "sudo ./idll-test.exe --sram-write $mirror_mode:$((i+bank_address[1])):${write_data[$m]} -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_write"
        verify_result "$result"

      fi

      #comfirm sram capacity with mirror mode 4
      compare_result "$result" "$size"

      if [[ "$m" < ${#write_data[*]} ]]; then
        (( m++ ))
      fi

  done

  #read data / compare data with mirror mode1 / 4
  m=0
  for (( i = 0; i < loop; i++ )); do
      if [ "$m" == ${#write_data[*]} ]; then
        m=0
      fi

      data="0:	${write_data[$m]}"

      printf "\n\n\n\n\n"
      title r "Expected including data for the following test result = $data"

      #Mirror=2 to check data
      title b "Mirror=2 to check data with bank 0/1"

      #bank0 data compare with mirror2
      launch_command "sudo ./idll-test.exe --sram-read $mirror_mode:$i:1 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_read"
      verify_result "$result"
#      result=$( sudo ./idll-test.exe --sram-read $mirror_mode:$i:1 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_read )
#      printf  "$result\n"
      compare_result "$result" "$data"

      #bank2 data compare with mirror2
      if [[ "${bank_address[1]}" && "$bank_amount" -lt 2 ]]; then
        launch_command "sudo ./idll-test.exe --sram-read $mirror_mode:$((i+bank_address[1])):1 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_read"
        verify_result "$result"
        compare_result "$result" "$data"
      fi

      #data compare data with mirror 1
      #Mirror=1 to check data with bank 0/1
      title b "Mirror=1 to check data with bank 0/1"
      for a in ${bank_address[0]} ${bank_address[1]}; do
        if [ "$a" ]; then
          launch_command "sudo ./idll-test.exe --sram-read 1:$((i+a)):1 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_read"
          verify_result "$result"
          compare_result "$result" "$data"
        fi
      done

      #Mirror=1 to check data with bank 2/3
      title b "Mirror=1 to check data with bank 2 / 3"
      if [[ "$bank_amount" -gt 2 ]]; then
        for a in ${bank_address[2]} ${bank_address[3]}; do
          launch_command "sudo ./idll-test.exe --sram-read 1:$((i+a)):1 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_read"
          verify_result "$result"
          compare_result "$result" "$data"
        done
      fi


      if [[ "$m" -lt ${#write_data[*]} ]]; then
        (( m++ ))
      fi
  done
  #confirm if there is error returned, while writing in wrong address
  write_wrong_address "$mirror_mode"
}
#-----------------------------------------------------------------------------------------------------
BadParameter(){
  printf  "${COLOR_RED_WD}Now test with bad address  ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}============================== ${COLOR_REST}\n"
  printf "Press enter key to continue.. \n"
  read -p ""

  printf  "${COLOR_RED_WD}sudo ./idll-test.exe --sram-write 1:100000000000:255/255/255 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_write  ${COLOR_REST}\n"
  sudo ./idll-test.exe --sram-write 1:100000000000:255/255/255 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_write

  printf  "${COLOR_RED_WD}sudo ./idll-test.exe --sram-write 1:10:abcdef@/255/255 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_write  ${COLOR_REST}\n"
  sudo ./idll-test.exe --sram-write 1:100000000000:255/255/255 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_write

  printf  "${COLOR_RED_WD}sudo ./idll-test.exe --sram-read 1:10000000000:3 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_read  ${COLOR_REST}\n"
  sudo ./idll-test.exe --sram-read 1:100000000:3 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_read

    printf  "${COLOR_RED_WD}sudo ./idll-test.exe --sram-read 1:100:30000000000 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_read  ${COLOR_REST}\n"
  sudo ./idll-test.exe --sram-read 1:100000000:3 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_read

  printf  "${COLOR_RED_WD}sudo ./idll-test.exe --sram-read 2:1:3 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_read  ${COLOR_REST}\n"
  sudo ./idll-test.exe --sram-read 2:1:3 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_read

  printf  "${COLOR_RED_WD}sudo ./idll-test.exe --sram-read 5:1:3 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_read  ${COLOR_REST}\n"
  sudo ./idll-test.exe --sram-read 5:1:3 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_read
}

#===============================================================
#data iterating stack read/write
#===============================================================

write(){
  title b "Write data to sram"
  print_command "sudo ./idll-test.exe --sram-write 1:0:$1 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_write"
  sudo ./idll-test.exe --sram-write 1:0:$1 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_write
}

read_data(){
  local n p data_length
  data_length=$(($1+1))
  launch_command "sudo ./idll-test.exe --sram-read 1:0:$data_length -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_read"

  n=0
  for (( p = 0; p < data_length; p++ )); do
    content="$p:	${write_data[$n]}"
    printcolor "\n"
    printcolor b "Assuming data:\n"
    printcolor b "$content\n"
    printcolor b "=======================\n"
    compare_result "$result" "$content"

    if [[ "$n" -lt $((${#write_data[*]}-1)) ]]; then
      ((n++))
    else
      n=0
    fi
  done

}

sram_write_read_iterate(){
#  sram_info
  read -p "Type the how may byte need to write or just enter write in total size: " capacity
  if [ "$capacity" == "" ]; then
    loop=$totalsize
  else
    loop=$capacity
  fi

  printcolor b "Below is the verify basic setting\n"
  printcolor b "=================================\n"
#  printf "${COLOR_BLUE_WD}Device ID = $deviceid${COLOR_REST}\n"
  printcolor b "Writing data size= $loop byte\n"
  printcolor b "Looping data= ${write_data[*]}\n"
  printcolor b "=================================\n"
  read -p "enter key to test..."

  for (( i = 0; i < loop; i++ )); do
    printf "i=$i\n"
    #m is the list pointer
    m=0
    for (( k = 0; k < $((i+1)); k++ )); do
      command_data=$command_data${write_data[$m]}/
      #confirm how many strings in command_data
      len=${#command_data}
      len=$((len-1))

      #the last strings need to be remove, it will add repeaded // string
      result_data=${command_data:0:$len}

      if [[ "$m" -lt $((${#write_data[*]}-1)) ]]; then
        ((m++))
      else
        m=0
      fi
    done

    if [ "$result_data" ]; then
      write "$result_data"
      read_data "$i"
    fi
    command_data=""
  done
}

#===============================================================
#write with verify
#===============================================================
writewithverify(){
  local i m stepping
  sram_info
  stepping=100000

  #############################################################################
  #test sram with verify , est sram with verify
  for m in "SramAsyncWriteWithVerifyManual" "SramWriteWithVerifyManual"; do
    addresss=$address
    length=1

#    title b "Test sram with verify ($m) : Test sram with verify "
#    read -p "enter key to continue..."
#    for i in $(seq 1 $stepping $addresss); do
#
#      result=$(sudo ./idll-test.exe --ADDRESS 0x0 --LENGTH $i --SRAM-DATA-FILE="./fakefile.txt" -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section $m)
#      print_command "sudo ./idll-test.exe --ADDRESS 0x0 --LENGTH $i --SRAM-DATA-FILE="./fakefile.txt" -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section $m"
#      printcolor w "$result"
#      verify_result "$result"
#
#      if [[ "$status" == "fail" ]]; then
#        status=""
#        break
#      fi
#
#    done

    ################################################################################
    #Test sram with verify : address get higher while data length smaller
    title b "Test sram with verify ($m) : address get higher, while data length is smaller "
    read -p "enter key to continue..."
    while true; do

      title b "Test sram with verify ($m) : address get higher while data length smaller "
      result=$( sudo ./idll-test.exe --ADDRESS $((addresss-1)) --LENGTH $length --SRAM-DATA-FILE="./fakefile.txt" -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section $m )
      print_command "sudo ./idll-test.exe --ADDRESS $((addresss-1)) --LENGTH $length --SRAM-DATA-FILE="./fakefile.txt" -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section $m"
      printcolor w "$result"
      verify_result "$result"

      length=$((length+stepping))
      addresss=$((addresss-length))
      if [[ "$addresss" -lt 0 ]]; then
        break
      fi

      if [[ "$status" == "fail" ]]; then
        status=""
        read -p "enter key to continue..."
        break
      fi

    done
  done
}
#===============================================================
#sram bank copy
#===============================================================
bank_copy(){
#  sram_info
  local k i
  for k in "SramBankCopyManual" "SramAsyncBankCopyManual"; do

    for (( m = 0; m < bank-1; m++ )); do
      echo "abc"
      for (( i = 0; i < bank_capacity_hex; i=i+10000 )); do

        title b "Bank copy ($k) : data length setting from small to bigger + all bank compare"
        print_command "sudo ./idll-test.exe --ADDRESS 0x0 --LENGTH 0x$i --SOURCE_BANK 0x$m --DEST_BANK 0x$((m+1)) -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section $k"
        result=$(sudo ./idll-test.exe --ADDRESS 0x0 --LENGTH 0x$i --SOURCE_BANK 0x$m --DEST_BANK 0x$((m+1)) -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section $k)

        printcolor w "$result"
        verify_result "$result"

        if [[ "$status" == "fail" ]]; then
          status=""
          break
        fi

      done
    done
  done
}

#===============================================================
#sram bank compare
#===============================================================
bank_reset(){
  title b "Now make both banks sync up first."
  if [ "$bank" == "4" ]; then
    temp=$(sudo ./idll-test.exe --ADDRESS 0x0 --LENGTH 0x$bank_capacity_hex --SOURCE_BANK 0x0 --DEST_BANK 0x1 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SramBankCopyManual)
    temp=$(sudo ./idll-test.exe --ADDRESS 0x0 --LENGTH 0x$bank_capacity_hex --SOURCE_BANK 0x1 --DEST_BANK 0x2 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SramBankCopyManual)
    temp=$(sudo ./idll-test.exe --ADDRESS 0x0 --LENGTH 0x$bank_capacity_hex --SOURCE_BANK 0x2 --DEST_BANK 0x3 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SramBankCopyManual)
  else
    temp=$(sudo ./idll-test.exe --ADDRESS 0x0 --LENGTH 0x$bank_capacity_hex --SOURCE_BANK 0x0 --DEST_BANK 0x1 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SramBankCopyManual)
  fi
}

bank_compare(){
#  sram_info
  #reset bank data
  bank_reset


  ########################################################################
  #start to test
#  for k in "SramBankCompareManual" "SramAsyncBankCompareManual"; do
#    for (( m = 0; m < $((bank-1)); m++ )); do
#      for (( i = 0; i < bank_capacity_hex; i=i+10000 )); do
#        title b "Bank copy ($k) : Data length setting from small to bigger + all bank compare"
#        result=$(sudo ./idll-test.exe --SOURCE_BANK 0x$m --DEST_BANK 0x$((m+1)) --ADDRESS 0x$i --LENGTH 0x$((bank_capacity_hex-i)) -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section $k)
#        print_command "sudo ./idll-test.exe --SOURCE_BANK 0x$m --DEST_BANK 0x$((m+1)) --ADDRESS 0x$i --LENGTH 0x$((bank_capacity_hex-i)) -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section $k"
#        printcolor w "$result"
#        verify_result "$result"
#      done
#    done
#  done

  ########################################################################
  #write the data in bank 0, try to make 2 banks data different
  printf "\n\n\n"
  title b "Bank compare : Now try to write data in one of the bank and expect result will be failed."
  read -p ""
  steppingg=100000

  for h in "SramBankCompareManual" "SramAsyncBankCompareManual"; do
    #generate random number to prevent 2 banks have the same data

    for (( i = 0; i < bank_capacity_hex; i=i+steppingg )); do
      title b "$h Test"
      compare_fail_address=$((bank_capacity_hex+i))
      #make all bank sync up first, and then write data to first bank to make banks have different data
      bank_reset

      #write data in bank0
      ran=$(shuf -i 0-255 -n 1)
      title b "Now trying to write data in address: 0x$i"
      print_command "sudo ./idll-test.exe --sram-write 1:0x$i:$ran -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_write"
      sudo ./idll-test.exe --sram-write 1:0x$i:"$ran" -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_write


      launch_command "sudo ./idll-test.exe --SOURCE_BANK 0x0 --DEST_BANK 0x1 --ADDRESS 0x0 --LENGTH 0x$bank_capacity_hex -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section $h"
      verify_result "$result"



      if [ "$status" == "fail" ]; then
        printcolor g "***********The above result is PASSED, while try to make both bank different\n"
#        read -p "enter key to continue..."
        status=""
      else
        printcolor r "***********The above result is FAILED, because both bank data are the same, while try to make both bank different"
        read -p "Enter to continue..."
        status=""
      fi

      title b "Confirm if above test result has the the correct returned error address : $compare_fail_address"
      compare_result "$result" "0x$compare_fail_address" "skip"
    done


  done

  #################################################################
  #make bank data different from above test to prevent both bank data from being the same.
  sudo ./idll-test.exe --sram-write 1:0:1/2/3 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SRAM_Manual_write
  sudo ./idll-test.exe --ADDRESS 0x0 --LENGTH 0x"$bank_capacity_hex" --SOURCE_BANK 0x0 --DEST_BANK 0x1 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SramBankCopyManual

}

#===============================================================
#crc32 caculate
#===============================================================
crc32_caculate(){
#  idll-test --ADDRESS 0x0 --LENGTH 0x800 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SramAsyncCalculateCRC32Manual

  #try to verify with different length
  content_list=('ilovejoe' '1111' ' 22222222' '1' '23' 'iou')

  #loop for all list and write in sram / verify the data by crc32
  for l in "SramAsyncCalculateCRC32Manual" "SramCalculateCRC32Manual"; do
    for m in ${content_list[*]};do
      content=$m
      local length=$(echo "${#content}")
      #create a txt file to make the content is the same as sram
      start_address=$( shuf -i 0-$totalsize -n 1)
      differential=$((totalsize-start_address))

      if [[ "$differential" -lt "$length"  ]]; then
        content=${content:0:$differential}
        length=$differential
      fi

      printf  "$content" > temp.txt

      #write temp.txt data to sram in specific address
      sudo ./idll-test.exe --ADDRESS $start_address --LENGTH $length --SRAM-DATA-FILE="temp.txt" -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SramWriteWithVerifyManual

      title b "Test sram calculate CRC32 ($l)"
      title b "writing data : $m"
      launch_command "sudo ./idll-test.exe --ADDRESS $start_address --LENGTH $length -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section $l"
      local crc=$(crc32 temp.txt)
      compare_result "$result" "$crc"

    done
  done

  ####################################################################
  #try to write all supported capacity in sram, and try calculate the crc32 for all supported capacity
  for l in "SramAsyncCalculateCRC32Manual" "SramCalculateCRC32Manual"; do
    case $totalsize in
    "67108864")
      crc=$(crc32 fakefile.txt)
      file="fakefile.txt"
      ;;
    "33554432")
      crc=$(crc32 fake32m.txt)
      file="fake32m.txt"
      ;;
    "16777216")
      crc=$(crc32 fake16m.txt)
      file="fake16m.txt"
      ;;
    "8388608")
      crc=$(crc32 fake8m.txt)
      file="fake8m.txt"
      ;;
    esac

    title b "Try to write all supported capacity in sram, and calculate the all supported capacity crc32"
    launch_command "sudo ./idll-test.exe --ADDRESS 0x0 --LENGTH $totalsize --SRAM-DATA-FILE="$file" -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SramWriteWithVerifyManual"
#    print_command "sudo ./idll-test.exe --ADDRESS 0x0 --LENGTH $totalsize --SRAM-DATA-FILE="fake8m.txt" -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SramWriteWithVerifyManual"
#    sudo ./idll-test.exe --ADDRESS 0x0 --LENGTH $totalsize --SRAM-DATA-FILE="fake8m.txt" -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section SramWriteWithVerifyManual
    launch_command "sudo ./idll-test.exe --ADDRESS 0x0 --LENGTH $totalsize -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section $l"
    compare_result "$result" "$crc"
  done

}


#
while true; do
  printf  "\n"
  printf  "${COLOR_RED_WD}1. AUTO TEST SRAM SYNC/VSYNC (repeat 10 times) ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}2. AUTO TEST SAME/RANDOM DATA (repeat 10 times) ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}3. SRAM SIZE CHECK ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}4. SRAM MANUAL READ/WRITE SAME/RANDOM ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}5. SRAM MIRROR 1 to ALL (ALL PROJECTS)${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}6. SRAM MIRROR 2 TO 2 (SCXX/SA3) ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}7. SRAM MIRROR 2 TO 2 (LEC1)${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}8. BAD PARAMETER${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}9. DATA ITERATING READ/WRITE${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}10. SRAM WRITE WITH VERIFY${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}11. SRAM BANK COPY${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}12. SRAM BANK COMPARE${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}13. SRAM CRC32 CALCULATE${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}======================================${COLOR_REST}\n"
  printf  "CHOOSE ONE TO TEST: "
  read -p "" input

  if [ "$input" == 1 ]; then
    SramSyncVsync_Repeat
  elif [ "$input" == 2 ]; then
    SramAutoRandomSame
  elif [ "$input" == 3 ]; then
    SramCapacity
  elif [ "$input" == 4 ]; then
    SramManualSramRandom
  elif [ "$input" == 5 ]; then
    Sram_Mirror_1_All
  elif [ "$input" == 6 ]; then
    Sram_Mirror_2_2_ScxxSa3
  elif [ "$input" == 7 ]; then
    Sram_Mirror_2_2_Lec1
  elif [ "$input" == 8 ]; then
    BadParameter
  elif [ "$input" == 9 ]; then
    sram_write_read_iterate
  elif [ "$input" == 10 ]; then
    writewithverify
  elif [ "$input" == 11 ]; then
    bank_copy
  elif [ "$input" == 12 ]; then
    bank_compare
  elif [ "$input" == 13 ]; then
    crc32_caculate

  fi

done