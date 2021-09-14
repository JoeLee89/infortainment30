#!/bin/bash
COLOR_REST='\e[0m'
COLOR_RED='\e[101m'
COLOR_RED_WD='\e[0;31m'
COLOR_BLUE='\e[104m'
COLOR_RED_WD='\e[0;31m'
COLOR_BLUE_WD='\e[0;34m'
COLOR_YELLOW_WD='\e[93m'
#m=0
m="i"
if [ "$m" -eq "0"  ]; then
    echo "good"
elif [ "$m" == "i" ]; then
  echo "bad"
fi

#bank=$(sudo ./idll-test.exe --SOURCE_BANK 0x0 --DEST_BANK 0x1 --ADDRESS 0x0 --LENGTH 0x1 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section SramBankCompareManual | grep -i "sram bank" | sed 's/SRAM Bank\[Number:Size\]\=\[0x//g' | sed 's/:0x[0-9]*]//g' | sed 's/\s//g')
  #display each bank capacity in hex unit
#  bank_capacity_hex=$(sudo ./idll-test.exe --SOURCE_BANK 0x0 --DEST_BANK 0x1 --ADDRESS 0x0 --LENGTH 0x1 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section SramBankCompareManual | grep -i "sram bank" | sed 's/SRAM Bank\[Number:Size\]\=\[0x//g' | sed 's/[0-9]:0x//g' | sed 's/\]//g' | sed 's/\s//g')
#  bank_capacity_hex=80000
  bank_capacity_hex=


#  bank_amount=$(sudo ./idll-test.exe --SOURCE_BANK 0x0 --DEST_BANK 0x1 --ADDRESS 0x0 --LENGTH 0x1 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section SramBankCompareManual | grep -i "sram bank" | sed 's/SRAM Bank\[Number:Size\]\=\[0x//g' | sed 's/\s//g')


#  #display how many bank
#  bank_amount=$(echo ${bank_amount:0:1})
  bank_amount=

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
#  address=$( sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section SRAM_Capacity | grep -i 'size' | sed 's/SRAM size: //g' | sed 's/\/r//g')
  address=$(sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section SRAM_Capacity | grep -i 'SRAM size' | sed 's/SRAM size: //g' | sed 's/\/r//g' | sed 's/\s//g' |sed 's/]//g')

  #display sram capacity in dec unit
#  address=$(echo ${address:0:8})

  #display bank capacity for each bank in dec format
  address_dec=$((16#$bank_capacity_hex))

  bank_address=""
#  echo "bankamount=$bank_amount"
  for (( p = 0; p < bank_amount; p++ )); do
    bank_address[$p]=$((address_dec*p))
  done
  echo "bank_address= ${bank_address[*]}"

  #bank address list for some function usage
#  bank_address=(${bank_address_list[@]})
  echo "SRAM each bank first address = ${bank_address[*]}"
  echo "bank amount = ${#bank_address[*]}"
  #input how many SRAM size
  totalsize=$address

#
#a=2
#if  (("$a" != 3)) && (("$a" == 2)); then
#  printf "good"
#
#fi
#
#if  [[ "$a" != 3 && "$a" == 2 ]]; then
#  printf "good"
#
#fi
#
#if  [ "$a" -ne 3 ] && [ "$a" == 2 ]; then
#  printf "good"
#
#fi

#totalsize=123466
#mainsize=$((totalsize/4+1))
#echo "$mainsize"
#
#bank_address=("0" "8388608" )
#
#
#
#if [ ${bank_address[2]} ]; then
#
#  printf "good"
#
#fi
