#!/bin/bash
source ./common_func.sh

#===============================================================
#I2C_SPI device read/write test auto test
#===============================================================
I2CSPI_Auto() {
  title b "I2C_SPI device read/write test auto test"
  read -p "This test gonna loop forever, until press Ctrl+c to cancel test..."
  while true; do
    launch_command "sudo ./idll-test --LOOP 1 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section ExtI2C"
    compare_result "$result" "passed"

    launch_command "sudo ./idll-test --LOOP 1 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section Ext_SPI_RDID_REMS"
    compare_result "$result" "RDID: 0xC2 20 18"
    compare_result "$result" "REMS: 0xC2 17"

#    read -p "Press [q] to exit, or enter key to continue..." input
#    if [ "$input" == "q" ]; then
#      break
#    fi
  done
}

#===============================================================
#I2C frequency setting test
#===============================================================
I2CFreauency() {
  #test with correct parameter to i2c frequency
  title b "I2C frequency setting test with [CORRECT] parameter"
  for all in 0 124 500 5000 65535; do
    title b "I2C prescale number: $all"
    launch_command "sudo ./idll-test --I2C_PSCL $all -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section Ext_I2C_BUS"
    hz=$((12500000/(all+1)))
    compare_result "$result" "$hz Hz"
    compare_result "$result" "I2C Pre-Scale is : $all"

  done

  #test with wrong parameter to i2c frequency
  i2c_freq=65536

  title b "I2C frequency setting test with [WRONG] parameter"
  title b "I2C prescale number: $i2c_freq "
  launch_command "sudo ./idll-test --I2C_PSCL $i2c_freq -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section Ext_I2C_BUS"
  compare_result "$result" "failed"

}

#===============================================================
#I2C Writing
#===============================================================
I2CWrite() {
  title b "Input I2C device address, or enter as 0x50"
  read -p "0x" i2caddr
  if [ "$i2caddr" == "" ]; then
    i2caddr="50"
  fi
  print_command "sudo ./idll-test --SLAVE_ADDR 0x$i2caddr --I2C_CMD 0x00,0x00,0x01,0x02,0x03 --RESP_LEN 0 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section Ext_I2C_EXEC"
  sudo ./idll-test --SLAVE_ADDR 0x$i2caddr --I2C_CMD 0x00,0x00,0x01,0x02,0x03 --RESP_LEN 0 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section Ext_I2C_EXEC
}


#===============================================================
#I2C Reading
#===============================================================
I2CRead() {
  title b "Input I2C device address, or enter as 0x50"
  read -p "0x" i2caddr
  if [ "$i2caddr" == "" ]; then
    i2caddr="50"
  fi
  print_command "sudo ./idll-test --SLAVE_ADDR 0x$i2caddr --I2C_CMD 0x00,0x00 --RESP_LEN 3 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section Ext_I2C_EXEC"
  sudo ./idll-test --SLAVE_ADDR 0x$i2caddr --I2C_CMD 0x00,0x00 --RESP_LEN 3 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section Ext_I2C_EXEC
}

#===============================================================
#SPI Reading test
#===============================================================
SPIRead_RDID() {

  #===============================================================
  #SPI data reading from RDID
  #===============================================================
  title b "SPI data reading from RDID"
  launch_command "sudo ./idll-test --SPI_MODE 0 --SPI_CMD 0x9F --RESP_LEN 3 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section Ext_SPI_EXEC"
  compare_result "result" "0xC2 20 18"

}

#===============================================================
#SPI data reading from REMS
#===============================================================
SPIRead_REMS() {
  title b "SPI data reading from REMS"
  launch_command "sudo ./idll-test --SPI_MODE 0 --SPI_CMD 0x90,0x00,0x00,0x00 --RESP_LEN 2 -- --EBOARD_TYPE EBOARD_ADi_BSEC_BACC --section Ext_SPI_EXEC"
  compare_result "result" "C2 17"
}



#===============================================================
#MAIN
#===============================================================
while true; do
  printf "\n"
  printf "${COLOR_RED_WD}1. I2C/SPI READ/WRITE AUTO ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}2. I2C FREQUENCY SETTING ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}3. I2C MANUAL WRITE${COLOR_REST}\n"
  printf "${COLOR_RED_WD}4. I2C MANUAL READ ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}5. SPI READ RDID ZONE${COLOR_REST}\n"
  printf "${COLOR_RED_WD}6. SPI READ REMS ZONE ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}======================================${COLOR_REST}\n"
  printf "CHOOSE ONE TO TEST: "
  read -p "" input

  if [ "$input" == 1 ]; then
    I2CSPI_Auto
  elif [ "$input" == 2 ]; then
    I2CFreauency
  elif [ "$input" == 3 ]; then
    I2CWrite
  elif [ "$input" == 4 ]; then
    I2CRead
  elif [ "$input" == 5 ]; then
    SPIRead_RDID
  elif [ "$input" == 6 ]; then
    SPIRead_REMS
  fi

done
