#!/bin/bash
source ./common_func.sh


#===============================================================
#Check crypto serial number/ go get crypto config zone
#===============================================================
Crypto_Serial_ConigZone(){
  title b "Check crypto serial number/ go get crypto config zone"
  launch_command "sudo ./idll-test.exe --LOOP 1 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section Crypto"
}


#===============================================================
#Encode string in SHA mode by crypto
#===============================================================
CryptoEncode_SHA(){
  title b "Encode string in SHA mode by crypto"
  read -p "Input string you need to generate SHA256 key: " input
  print_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section Crypto_SHA"
  result1=$(printf $input | sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section Crypto_SHA)
  echo "$result1"

  #start to generate sha256 key by OS to compare if both OS/idll have the same key
  result2=$(printf $input | sha256sum)
  length=${#result2}
  os=""
  for (( i = 0; i < length; i=i+2 )); do
    os="$os${result2:i:2} "

    if [[ "$os" =~ "  " ]]; then
      #change lowcase to highcase string
      os="0x${os^^}"
      #clear blank string from last position in strings
      os=$(echo "$os" | sed 's/ *$//g')
      break

    fi
  done

  mesg=(
  "The following result should be the same:"
  "Generate by OS= $os"
  "Generate by idll= $result1"

  )
  title_list b mesg[@]

  compare_result "$result1" "$os"

}


#===============================================================
#set/get key and decode/encode string in AES 128/256 bit
#===============================================================
CryptoEncode_AES(){
  title b "set/get key and decode/encode string in AES 128/256 bit"
  launch_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section Crypto_AES"

}


#===============================================================
#MAIN
#===============================================================
while true; do
  printf "\n"
  printf "${COLOR_RED_WD}1. CRYPTO SERIAL NUMBER / CONFIG ZONE ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}2. ENCODE IN SHA MODE ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}3. AES 128/256 BIT SET/GET KEY/DECODE/ENCODE ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}======================================${COLOR_REST}\n"
  printf "CHOOSE ONE TO TEST: "
  read -p "" input

  if [ "$input" == 1 ]; then
    Crypto_Serial_ConigZone
  elif [ "$input" == 2 ]; then
    CryptoEncode_SHA
  elif [ "$input" == 3 ]; then
    CryptoEncode_AES

  fi

done
