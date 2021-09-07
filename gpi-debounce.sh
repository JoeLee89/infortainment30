#!/bin/bash
source ./common_func.sh

#===============================================================
# GPI get port/get pin / callback function
#===============================================================
GetPortPin_Callback() {
  title b "GPI get port/get pin / callback function"
  printf "[q] key to exit, or enter key to continue...\n"
  read -p "" input

  while true; do

    if [ "$input" == 'q' ]; then
      break
    fi
    print_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section GPI_Button"
    sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section GPI_Button

    read -p "[q] exit test, or enter key to keep looping..." input
    if [ "$input" == "q" ]; then
      break
    fi

  done
}

#===============================================================
#Debounce check
#===============================================================
Debounce() {
  title b "Debounce check"
  printf "[q] key to exit, or enter key to continue...\n"
  read -p "" input

  #for all in $(seq 0 ${first})
  while true; do
    if [ "$input" == "q" ]; then
      break
    fi

    for all in 0 500 5000 50000 65535; do
      while true; do
        scxx=$(echo "$all*0.1" | bc)
        printf "debounce = ${COLOR_BLUE_WD} $all ${COLOR_REST}\n"
        printf "(SCXX/SA3) debounce time = ${COLOR_BLUE_WD} $scxx ms ${COLOR_REST}\n"
        printf "(LEC1) debounce time = ${COLOR_BLUE_WD} $all ms ${COLOR_REST}\n"
        print_command "sudo ./idll-test.exe --DEBOUNCE $all -- --EBOARD_TYPE EBOARD_ADi_SC1X --section GPI_SetDebounce"
        sudo ./idll-test.exe --DEBOUNCE $all -- --EBOARD_TYPE EBOARD_ADi_SC1X --section GPI_SetDebounce
        sleep 0.5

        read -p "[q] to exit debounce time= $all ms loop, or enter key to loop" leave
        if [ "$leave" == "q" ]; then
          break
        fi
      done

    done

    read -p "[q] to exit all debounce test" leave
    if [ "$leave" == "q" ]; then
      break
    fi

  done
}

#===============================================================
#Check bad parameter...
#===============================================================
BadParameter() {
  printf "${COLOR_RED_WD}Check bad parameter ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}===================${COLOR_REST}\n"
  read -p "enter key to test..." continue
  sudo ./idll-test.exe --DEBOUNCE 65536 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section GPI_SetDebounce
}

#===============================================================
#DI Pulse Width detection auto...
#===============================================================
DiPulseWidth_auto() {
  printf "${COLOR_RED_WD}DI Pulse Width detection automatically (loopback cable) ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}======================================================== ${COLOR_REST}\n"
  read -p " " continue
  sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI
  sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section DI_PW_GetSetTimeout [ADiDLL][DI_INTERRUPT][AUTO][UNITTEST]
}

#===============================================================
# DI PWD interrupt (no timeout)
#===============================================================
DiPwdInterrupt_NoTimeout() {
  title b "DI PWD interrupt manually (w/o timeout)"
  title b "Now test with PWD timeout default value(no setting)"

  for x in "true" "false"; do

    if [ "$x" == "true" ]; then
      printcolor y "Trigger mode=  low-high-low "
    else
      printcolor y "Trigger mode=  high-low-high"
    fi

    printcolor y "Mask= DI 0-15 (Mask all set = 1)"
    print_command "sudo ./idll-test.exe --DI-Int false --DI-Mask 65535 --DI-PW-Polarity $x -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
    sudo ./idll-test.exe --DI-Int false --DI-Mask 65535 --DI-PW-Polarity $x -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu

    if [ "$x" == "true" ]; then
      printcolor y "Trigger mode=  low-high-low"
    else
      printcolor y "Trigger mode=  high-low-high"
    fi

    printcolor y "Mask= DI 16-31 (Mask all set = 1)"
    print_command "sudo ./idll-test.exe --DI-Int false --DI-Mask 4294901760 --DI-PW-Polarity $x -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
    sudo ./idll-test.exe --DI-Int false --DI-Mask 4294901760 --DI-PW-Polarity $x -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu

  done
}
#===============================================================
# DI PWD interrupt
#===============================================================
DiPwdInterrupt_Timeout() {
  title b "Now test with PWD timeout manually setting"
  read -p "Input DI PWD time out(0.1ms)=" timeout
  timeoutprint=$(echo $timeout*0.1 | bc)

  for x in "true" "false"; do

    ##############################################################
    #Set PWD timeout & to compare the getting PWD timeout result
    title b "Set PWD timeout & get PWD timeout result"
    launch_command "sudo ./idll-test.exe --DI-PWD-Enable true --DI-PWD-Timeout $timeout -- --EBOARD_TYPE EBOARD_ADi_SC1X --section DI_PW_GetSetTimeout_Manu"
    compare_result "$result" "Get : PWD Timeout Enabled = 1, PWD Timeout = $timeout"

    ##############################################################
    #setting pwd interrupt mask value
    title b "**Try to confirm [higher] or [lower] pwd time setting can trigger event, and make sure pulse width"

    if [ "$x" == "true" ]; then
      printcolor y "Trigger mode=  low-high-low"
    else
      printcolor y "Trigger mode=  high-low-high"
    fi

    title b "Now set trigger mode as ($x)"

    printcolor y "DI PWD time out= $timeoutprint ms"
    printcolor y "Mask= DI 0-15 (Mask setting = 1)"
    print_command "sudo ./idll-test.exe --DI-Int false --DI-Mask 65535 --DI-PW-Polarity $x -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
    sudo ./idll-test.exe --DI-Int false --DI-Mask 65535 --DI-PW-Polarity $x -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu

    if [ "$x" == "true" ]; then
      printf "${COLOR_YELLOW_WD}Trigger mode=  low-high-low ${COLOR_REST}\n"
    else
      printf "${COLOR_YELLOW_WD}Trigger mode=  high-low-high ${COLOR_REST}\n"
    fi
    printf "${COLOR_YELLOW_WD}DI PWD time out= $timeoutprint ms ${COLOR_REST}\n"
    printf "${COLOR_YELLOW_WD}Mask= DI 16-31 (Mask setting = 1) ${COLOR_REST}\n"

    print_command "sudo ./idll-test.exe --DI-Int false --DI-Mask 4294901760 --DI-PW-Polarity $x -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
    sudo ./idll-test.exe --DI-Int false --DI-Mask 4294901760 --DI-PW-Polarity $x -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu

  done
}

#===============================================================
# DI PWD interrupt with timeout disabled
#===============================================================
DiPwdInterrupt_Timeout_disabled() {
  title b "Now test with PWD timeout manually setting"
  read -p "Input DI PWD time out(0.1ms)=" timeout
  timeoutprint=$(echo $timeout*0.1 | bc)

  for x in "true" "false"; do

    ##############################################################
    #Set PWD timeout & to compare the getting PWD timeout result
    title b "Set PWD timeout & get PWD timeout result"
    launch_command "sudo ./idll-test.exe --DI-PWD-Enable true --DI-PWD-Timeout $timeout -- --EBOARD_TYPE EBOARD_ADi_SC1X --section DI_PW_GetSetTimeout_Manu"
    compare_result "$result" "Get : PWD Timeout Enabled = 0, PWD Timeout = $timeout"

    ##############################################################
    #setting pwd interrupt mask value
    title b "**Try to confirm [higher] or [lower] pwd time setting can trigger event, and make sure pulse width"

    if [ "$x" == "true" ]; then
      printcolor y "Trigger mode=  low-high-low"
    else
      printcolor y "Trigger mode=  high-low-high"
    fi

    title b "Now set trigger mode as ($x)"

    printcolor y "DI PWD time out= $timeoutprint ms"
    printcolor y "Mask= DI 0-31 (Mask setting = 1)"
    print_command "sudo ./idll-test.exe --DI-Int false --DI-Mask 65535 --DI-PW-Polarity $x -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
    sudo ./idll-test.exe --DI-Int false --DI-Mask 4294967295 --DI-PW-Polarity $x -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu

  done
}

#===============================================================
# DI interrupt
#===============================================================
#DiInterrpt() {
#  title b "DI interrupt manually test"
#
#  for i in $(seq 1 4); do
#    if [ "$i" == 1 ]; then
#
#      msg=(
#      "Mask= DI 0-15 (Mask set = 0)"
#      "Mask= DI 16-31 (Mask set = 1)"
#      "Trigger mode= Rising edge"
#      )
#      title_list y "msg[@]"
#      launch_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 4294901760 --DI-Int-Rising true --DI-Int-Falling false -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
##      print_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 4294901760 --DI-Int-Rising true --DI-Int-Falling false -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
##      sudo ./idll-test.exe --DI-Int true --DI-Mask 4294901760 --DI-Int-Rising true --DI-Int-Falling false -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu
#
#      msg=(
#      "Mask= DI 0-15 (Mask set = 1)"
#      "Mask= DI 16-31 (Mask set = 0)"
#      "Trigger mode= Rising edge"
#      )
#      title_list y "msg[@]"
#      launch_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 65535 --DI-Int-Rising true --DI-Int-Falling false -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
##      print_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 65535 --DI-Int-Rising true --DI-Int-Falling false -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
##      sudo ./idll-test.exe --DI-Int true --DI-Mask 65535 --DI-Int-Rising true --DI-Int-Falling false -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu
#
#    elif [ "$i" == 2 ]; then
#      msg=(
#      "Mask= DI 0-15 (Mask set = 0)"
#      "Mask= DI 16-31 (Mask set = 1)"
#      "Trigger mode= Falling edge"
#      )
#      title_list y "msg[@]"
#      launch_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 4294901760 --DI-Int-Rising false --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
##      print_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 4294901760 --DI-Int-Rising false --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
##      sudo ./idll-test.exe --DI-Int true --DI-Mask 4294901760 --DI-Int-Rising false --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu
#
#      msg=(
#      "Mask= DI 0-15 (Mask set = 1)"
#      "Mask= DI 16-31 (Mask set = 0)"
#      "Trigger mode= Falling edge"
#      )
#      title_list y "msg[@]"
#      launch_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 65535 --DI-Int-Rising false --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
##      print_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 65535 --DI-Int-Rising false --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
##      sudo ./idll-test.exe --DI-Int true --DI-Mask 65535 --DI-Int-Rising false --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu
#
#    elif [ "$i" == 3 ]; then
#      msg=(
#      "Mask= DI 0-15 (Mask set = 0)"
#      "Mask= DI 16-31 (Mask set = 1)"
#      "Trigger mode= Rising/Falling edge"
#      )
#      title_list y "msg[@]"
#      launch_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 4294901760 --DI-Int-Rising true --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
##      print_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 4294901760 --DI-Int-Rising true --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
##      sudo ./idll-test.exe --DI-Int true --DI-Mask 4294901760 --DI-Int-Rising true --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu
#
#      msg=(
#      "Mask= DI 0-15 (Mask set = 1)"
#      "Mask= DI 16-31 (Mask set = 0)"
#      "Trigger mode= Rising/Falling edge"
#      )
#      title_list y "msg[@]"
#      launch_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 65535 --DI-Int-Rising true --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
##      print_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 65535 --DI-Int-Rising true --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
##      sudo ./idll-test.exe --DI-Int true --DI-Mask 65535 --DI-Int-Rising true --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu
#
#    elif [ "$i" == 4 ]; then
#      msg=(
#      "Mask= DI 0-15 (Mask set = 1)"
#      "Mask= DI 16-31 (Mask set = 1)"
#      "Trigger mode= NONE (can NOT trigger any pin)"
#      )
#      title_list y "msg[@]"
#      launch_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 4294967295 --DI-Int-Rising false --DI-Int-Falling false -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
##      print_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 4294967295 --DI-Int-Rising false --DI-Int-Falling false -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
##      sudo ./idll-test.exe --DI-Int true --DI-Mask 4294967295 --DI-Int-Rising false --DI-Int-Falling false -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu
#    fi
#
#  done
#
#
#}


DiInterrpt() {
  title b "DI interrupt manually test"
  #i=rising m=falling

  for i in "true" "false"; do

    for m in "true" "false";do

      status2=""

      if [ "$i" == "true" ]; then
        status1="Rising"
      else
        status1=""
      fi

      if [ "$m" == "true" ]; then
        status2="Falling"
      else
        status2=""
      fi

      if [[ "$i" == "false" && "$m" == "false"  ]]; then
        status1="NONE (can NOT trigger any pin)"
        status2=""
      fi

      msg=(
      "Mask= DI 0-15 (Mask set = 0)"
      "Mask= DI 16-31 (Mask set = 1)"
      "Trigger mode= $status1/$status2 edge"
      )
      title_list y "msg[@]"
      print_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 4294901760 --DI-Int-Rising $i --DI-Int-Falling $m -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
      sudo ./idll-test.exe --DI-Int true --DI-Mask 4294901760 --DI-Int-Rising $i --DI-Int-Falling $m -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu
#      launch_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 4294901760 --DI-Int-Rising $i --DI-Int-Falling $m -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"

      msg=(
      "Mask= DI 0-15 (Mask set = 1)"
      "Mask= DI 16-31 (Mask set = 0)"
      "Trigger mode= $status1/$status2 edge"
      )
      title_list y "msg[@]"
      print_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 65535 --DI-Int-Rising $i --DI-Int-Falling $m -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
      sudo ./idll-test.exe --DI-Int true --DI-Mask 65535 --DI-Int-Rising $i --DI-Int-Falling $m -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu
#      launch_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 65535 --DI-Int-Rising $i --DI-Int-Falling $m -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
    done
  done

  #comfirm if all mask set to 0 should be failed
  msg=(
      "Mask= DI 0-15 (Mask set = 0)"
      "Mask= DI 16-31 (Mask set = 0)"
      "Trigger mode= Rising/Falling edge"
      )
      title_list y "msg[@]"
      print_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 0 --DI-Int-Rising true --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
      result=$(sudo ./idll-test.exe --DI-Int true --DI-Mask 0 --DI-Int-Rising true --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu)
      compare_result "$result" "failed"


#
#    elif [ "$i" == 2 ]; then
#      msg=(
#      "Mask= DI 0-15 (Mask set = 0)"
#      "Mask= DI 16-31 (Mask set = 1)"
#      "Trigger mode= Falling edge"
#      )
#      title_list y "msg[@]"
#      launch_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 4294901760 --DI-Int-Rising false --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
##      print_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 4294901760 --DI-Int-Rising false --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
##      sudo ./idll-test.exe --DI-Int true --DI-Mask 4294901760 --DI-Int-Rising false --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu
#
#      msg=(
#      "Mask= DI 0-15 (Mask set = 1)"
#      "Mask= DI 16-31 (Mask set = 0)"
#      "Trigger mode= Falling edge"
#      )
#      title_list y "msg[@]"
#      launch_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 65535 --DI-Int-Rising false --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
##      print_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 65535 --DI-Int-Rising false --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
##      sudo ./idll-test.exe --DI-Int true --DI-Mask 65535 --DI-Int-Rising false --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu
#
#    elif [ "$i" == 3 ]; then
#      msg=(
#      "Mask= DI 0-15 (Mask set = 0)"
#      "Mask= DI 16-31 (Mask set = 1)"
#      "Trigger mode= Rising/Falling edge"
#      )
#      title_list y "msg[@]"
#      launch_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 4294901760 --DI-Int-Rising true --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
##      print_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 4294901760 --DI-Int-Rising true --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
##      sudo ./idll-test.exe --DI-Int true --DI-Mask 4294901760 --DI-Int-Rising true --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu
#
#      msg=(
#      "Mask= DI 0-15 (Mask set = 1)"
#      "Mask= DI 16-31 (Mask set = 0)"
#      "Trigger mode= Rising/Falling edge"
#      )
#      title_list y "msg[@]"
#      launch_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 65535 --DI-Int-Rising true --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
##      print_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 65535 --DI-Int-Rising true --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
##      sudo ./idll-test.exe --DI-Int true --DI-Mask 65535 --DI-Int-Rising true --DI-Int-Falling true -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu
#
#    elif [ "$i" == 4 ]; then
#      msg=(
#      "Mask= DI 0-15 (Mask set = 1)"
#      "Mask= DI 16-31 (Mask set = 1)"
#      "Trigger mode= NONE (can NOT trigger any pin)"
#      )
#      title_list y "msg[@]"
#      launch_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 4294967295 --DI-Int-Rising false --DI-Int-Falling false -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
##      print_command "sudo ./idll-test.exe --DI-Int true --DI-Mask 4294967295 --DI-Int-Rising false --DI-Int-Falling false -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu"
##      sudo ./idll-test.exe --DI-Int true --DI-Mask 4294967295 --DI-Int-Rising false --DI-Int-Falling false -- --EBOARD_TYPE EBOARD_ADi_SC1X --section Register_DI_Manu
#    fi

#  done


}
#===============================================================
# confirm pulse width (loopback cable)
#===============================================================
ConfirmPulseWidth() {
  #DI Pulse Width detection manually...

  printf "${COLOR_RED_WD}DI Pulse Width detection manually-- confirm pulse width (loopback cable) ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}========================================================================${COLOR_REST}\n"
  read -p " " continue

  while true; do
    do_on=500
    do_off=50

    printf "${COLOR_RED_WD}Default DO on time=500. type value or keep default ${COLOR_REST}\n"
    read -p "DO on time= " do_on_input
    printf "${COLOR_RED_WD}Default DO off time=50. type value or keep default ${COLOR_REST}\n"
    read -p "DO off time= " do_off_input

    if [ "$do_on_input" == "" ]; then
      :
    else
      do_on=$do_on_input
    fi

    if [ "$do_off_input" == "" ]; then
      :
    else
      do_off=$do_off_input
    fi

    for i in "false" "true"; do
      if [ "$i" == "false" ]; then
        printf "trigger point= ${COLOR_BLUE_WD} Wave Down ${COLOR_REST}\n"
        sudo ./idll-test.exe --DI-PW-Polarity $i --DI-PW-DO-ON-Time $do_on --DI-PW-DO-OFF-Time $do_off --DI-PW-DO-ON-OFF-Cycle 5 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section DI_PW_INT_DoLinkDi [ADiDLL][DI_INTERRUPT][MANUAL]
        printf "${COLOR_BLUE_WD}The returned Pulse Width should be similar with DO-ON times... ${COLOR_REST}\n"
      else
        printf "trigger point= ${COLOR_BLUE_WD} Wave UP ${COLOR_REST}\n"
        sudo ./idll-test.exe --DI-PW-Polarity $i --DI-PW-DO-ON-Time $do_on --DI-PW-DO-OFF-Time $do_off --DI-PW-DO-ON-OFF-Cycle 5 -- --EBOARD_TYPE EBOARD_ADi_SC1X --section DI_PW_INT_DoLinkDi [ADiDLL][DI_INTERRUPT][MANUAL]
        printf "${COLOR_BLUE_WD}The returned Pulse Width should be similar with DO-OFF times... ${COLOR_REST}\n"

      fi

    done

    read -p "[q] to exit, or enter key to loop test..." leave
    if [ "$leave" == "q" ]; then
      break
    fi

  done
}

#===============================================================
# callback for bsec card
#===============================================================
Callback_Bsec() {
  printf "${COLOR_RED_WD}callback check(bsec card only DLL 3.7)${COLOR_REST}\n"
  printf "${COLOR_RED_WD}==============================${COLOR_REST}\n"
  printf "enter key to test, or press ctrl + C to exit...\n"
  read -p "" continue

  #for all in $(seq 0 ${first})
  while true; do
    #  if [ $input == 'q' ]; then
    #    break
    #  fi
    #
    #  read -p "q to exit " leave
    #  if [ "$leave" == "q" ]; then
    #    break
    #  fi
    sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_SC1X --section GPI_BACC_INT_CALLBACK

  done
}



while true; do
  printf  "\n"
  printf  "${COLOR_RED_WD}1. GET PORT/PIN ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}2. DEBOUNCE/CALLBACK ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}3. BAD PARAMETER ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}4. DI PULSE WIDTH DETECTION AUTO ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}5. DI PWD INTERRUPT (No Timeout setting) ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}6. DI PWD INTERRUPT (Timeout enabled) ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}7. DI PWD INTERRUPT (Timeout disabled) ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}8. DI INTERRUPT ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}9. PULSE WIDTH CONFIRM(loopback cable) ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}10. CALLBACK (BSEC ONLY) ${COLOR_REST}\n"
  printf  "${COLOR_RED_WD}======================================${COLOR_REST}\n"
  printf  "CHOOSE ONE TO TEST: "
  read -p "" input

  if [ "$input" == 1 ]; then
    GetPortPin_Callback
  elif [ "$input" == 2 ]; then
    Debounce
  elif [ "$input" == 3 ]; then
    BadParameter
  elif [ "$input" == 4 ]; then
    DiPulseWidth_auto

  elif [ "$input" == 5 ]; then
    DiPwdInterrupt_NoTimeout
  elif [ "$input" == 6 ]; then
    DiPwdInterrupt_Timeout
  elif [ "$input" == 7 ]; then
    DiPwdInterrupt_Timeout_disabled
  elif [ "$input" == 8 ]; then
    DiInterrpt
  elif [ "$input" == 9 ]; then
    ConfirmPulseWidth
  elif [ "$input" == 10 ]; then
    Callback_Bsec
  fi

done