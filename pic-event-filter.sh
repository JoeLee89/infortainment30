#!/bin/bash
source ./common_func.sh

#===============================================================
#pic_event_interlock
#===============================================================

confirm_pic_read_unread_amount() {
  if [[ "$4" != "skip" ]]; then
    if [[ "$3" == "$4" ]]; then
      printcolor b "The both unread (search by type) and (search by any) amount are the same."
    else
      printcolor r "The both unread (search by type) and (search by any) amount are NOT the same."
      read -p ""
    fi
  fi

  if [[ "$(($2+$3))" -eq "$1" ]]; then
    printcolor b "The read + unread event = total event."
  else
    printcolor r "The read + unread event NOT = total event."
    read -p ""
  fi

}

print_read_unread_message() {
  mesg=(
    "Total event (by type)(read+unread) = $1"
    "Read event (by type) = $2"
    "Unread event = $3"
    "Unread event (by any) = $4"
  )
  title_list b mesg[@]
}

interlock_event() {

  local ii
  for ii in "oldest" "newest"; do
    #make pic all related target event as read
    local finish=0
    confirm_pic_message "any" "newest_unread" "all" ""
    title b "Now test function from [$ii] order"
    printcolor y "***Now trigger any interlock at least 6 times.***"
    read -p "enter key to continue, when trigger interlock action is finished..."

    status1="$ii""_read"
    status2="$ii""_unread"
    status3="$ii""_any"

    for j in "intrusion_open" "intrusion_close"; do
      while true; do
        confirm_pic_message "$j" "$status3" "255" ""
        pic_event_amount=$pic_log_filter_amount
        confirm_pic_message "$j" "$status1" "255" ""
        pic_event_read=$pic_log_filter_amount
        confirm_pic_message "$j" "$status2" "255" ""
        pic_event_unread=$pic_log_filter_amount
        confirm_pic_message "any" "$status2" "255" ""
        pic_event_any=$pic_log_filter_amount

        title b "Now confirm [$j] event from $ii"
        print_read_unread_message "$pic_event_amount" "$pic_event_read" "$pic_event_unread" "$pic_event_any"
        confirm_pic_read_unread_amount "$pic_event_amount" "$pic_event_read" "$pic_event_unread" "skip"

        #if all unread event is read, start to compare date time priority
        if [[ "$pic_event_unread" != 0 ]]; then
          confirm_pic_message "$j" "$status2" "0" "check"
        else
          case $ii in
          "oldest")
            datetime_compare "higher"
            date_time_prepare "reset"
            ;;
          "newest")
            datetime_compare "lower"
            date_time_prepare "reset"
            ;;
          esac
          break
        fi

      done
    done
#      if [[ "$finish" > 2 ]]; then
#        printcolor y "the event from unread to read status verification is finished."
#        break
#      fi

      #      confirm_pic_message "intrusion_close" "any" "255" ""
      #      pic_event_amount=$pic_log_filter_amount
      #      confirm_pic_message "intrusion_close" "newest_read" "255" ""
      #      pic_event_read=$pic_log_filter_amount
      #      confirm_pic_message "intrusion_close" "newest_unread" "255" ""
      #      pic_event_unread=$pic_log_filter_amount
      #
      #      printcolor y "Now confirm intrusion close event from newest"
      #      printcolor y "=============================================="
      #
      #      printcolor b "intrusion all event = $pic_event_amount"
      #      printcolor b "intrusion read event = $pic_event_read"
      #      printcolor b "intrusion unread event = $pic_event_unread"
      #
      #      confirm_pic_read_unread_amount "$pic_event_amount" "$pic_event_read" "$pic_event_unread"



  done
}

#
#interlock_fromOld_event(){
#  #make pic related event as read event.
#  confirm_pic_message "any" "newest_unread" "all" ""
#
#  printcolor y "Now trigger any interlock at least 6 times."
#  read -p "enter key to continue, when trigger interlock is finished..."
#
#  while true; do
#    confirm_pic_message "intrusion_open" "any" "255" ""
#    pic_event_amount=$pic_log_filter_amount
#    confirm_pic_message "intrusion_open" "oldest_read" "255" ""
#    pic_event_read=$pic_log_filter_amount
#    confirm_pic_message "intrusion_open" "oldest_unread" "255" ""
#    pic_event_unread=$pic_log_filter_amount
#
#    printcolor y "Now confirm intrusion open event from oldest"
#    printcolor y "============================================"
#
#    printcolor b "intrusion all event = $pic_event_amount"
#    printcolor b "intrusion read event = $pic_event_read"
#    printcolor b "intrusion unread event = $pic_event_unread"
#
#    confirm_pic_read_unread_amount "$pic_event_amount" "$pic_event_read" "$pic_event_unread"
#
#    confirm_pic_message "intrusion_close" "any" "255" ""
#    pic_event_amount=$pic_log_filter_amount
#    confirm_pic_message "intrusion_close" "oldest_read" "255" ""
#    pic_event_read=$pic_log_filter_amount
#    confirm_pic_message "intrusion_close" "oldest_unread" "255" ""
#    pic_event_unread=$pic_log_filter_amount
#
#    printcolor y "Now confirm intrusion close event from oldest"
#    printcolor y "=============================================="
#
#    printcolor b "intrusion all event = $pic_event_amount"
#    printcolor b "intrusion read event = $pic_event_read"
#    printcolor b "intrusion unread event = $pic_event_unread"
#
#    confirm_pic_read_unread_amount "$pic_event_amount" "$pic_event_read" "$pic_event_unread"
#
#    if [[ "$pic_event_unread" != 0 ]]; then
#      confirm_pic_message "intrusion_open" "newest_read" "1" ""
#      confirm_pic_message "intrusion_close" "newest_read" "1" ""
#    else
#      break
#    fi
#  done
#
#}

#===============================================================
#pic_event_power
#===============================================================
#confirm_pic_message "power" "any" "255" ""
power_event() {
  local ii
  printcolor y "Choose one of number to test:"
  printcolor y "===================================="
  printcolor y "[1]: event from newest."
  printcolor y "[2]: event from oldest."
  read -p "" key
  if [ "$key" == "1" ]; then
    #make pic all related target event as read
    ii="newest"
  elif [ "$key" == "2" ]; then
    ii="oldest"
  fi

  confirm_pic_message "power" "newest_any" "255" ""
  pic_event_amount=$pic_log_filter_amount
  confirm_pic_message "power" "newest_read" "255" ""
  pic_event_read=$pic_log_filter_amount
  confirm_pic_message "power" "newest_unread" "255" ""
  pic_event_unread=$pic_log_filter_amount


  title b "So far the power event in PIC log as the following:"
  print_read_unread_message "$pic_event_amount" "$pic_event_read" "$pic_event_unread" "none"

  if [ "$pic_event_unread" == "0" ]; then
    printcolor r "We found the power event has no any unread event, so power off DUT in G3, and resume to S0 state, and choose me again."
    read -p ""
    return
  fi

  while true; do
    status1="$ii""_read"
    status2="$ii""_unread"
    status3="$ii""_any"

    confirm_pic_message "power" "$status3" "255" ""
    pic_event_amount=$pic_log_filter_amount
    confirm_pic_message "power" "$status1" "255" ""
    pic_event_read=$pic_log_filter_amount
    confirm_pic_message "power" "$status2" "255" ""
    pic_event_unread=$pic_log_filter_amount

    title b "Now confirm power event from $ii"
    print_read_unread_message "$pic_event_amount" "$pic_event_read" "$pic_event_unread" "none"

    confirm_pic_read_unread_amount "$pic_event_amount" "$pic_event_read" "$pic_event_unread" "skip"
    if [[ "$pic_event_unread" != 0 ]]; then
      confirm_pic_message "power" "$status2" "0" "check"
    else
      case $ii in
        "oldest")
          datetime_compare "higher"
          date_time_prepare "reset"
          ;;
        "newest")
          datetime_compare "lower"
          date_time_prepare "reset"
          ;;
      esac
      printcolor y "the event from unread to read status verification is finished."
      break
    fi

  done

}

#===============================================================
#pic_event_battery
#===============================================================

battery_event() {
  local ii
  printcolor y "Choose one of number to test:"
  printcolor y "===================================="
  printcolor y "[1]: event from newest."
  printcolor y "[2]: event from oldest."
  read -p "" key
  if [ "$key" == "1" ]; then

    ii="newest"
  elif [ "$key" == "2" ]; then
    ii="oldest"
  fi

  confirm_pic_message "battery" "newest_any" "255" ""
  pic_event_amount=$pic_log_filter_amount
  confirm_pic_message "battery" "newest_read" "255" ""
  pic_event_read=$pic_log_filter_amount
  confirm_pic_message "battery" "newest_unread" "255" ""
  pic_event_unread=$pic_log_filter_amount

  title b "So far the battery event status in PIC log as the following:"
  print_read_unread_message "$pic_event_amount" "$pic_event_read" "$pic_event_unread" "none"

  if [ "$pic_event_unread" == "0" ]; then
    printcolor r "We found the event has no any unread event."
    printcolor r "So doing both (power off DUT in G3, and then resume DUT in S0) action at least twice."
    printcolor r "Then back to this test."
    read -p ""
  fi

  while true; do
    status1="$ii""_read"
    status2="$ii""_unread"
    status3="$ii""_any"
    confirm_pic_message "battery" "$status3" "255" ""
    pic_event_amount=$pic_log_filter_amount
    confirm_pic_message "battery" "$status1" "255" ""
    pic_event_read=$pic_log_filter_amount
    confirm_pic_message "battery" "$status2" "255" ""
    pic_event_unread=$pic_log_filter_amount

    printcolor y "Now confirm battery event status from $ii"
    printcolor y "============================================="
    print_read_unread_message "$pic_event_amount" "$pic_event_read" "$pic_event_unread" "none"

    confirm_pic_read_unread_amount "$pic_event_amount" "$pic_event_read" "$pic_event_unread" "skip"
    if [[ "$pic_event_unread" != 0 ]]; then
      confirm_pic_message "battery" "$status2" "0" "check"
    else
      case $ii in
        "oldest")
          datetime_compare "higher"
          date_time_prepare "reset"
          ;;
        "newest")
          datetime_compare "lower"
          date_time_prepare "reset"
          ;;
      esac
      printcolor y "the event from unread to read status verification is finished."
      break
    fi

  done

}

#===============================================================
#button event
#===============================================================

button_event() {
  local ii
  for ii in "oldest" "newest"; do
    title b "Now test function from [$ii] order"
    #make pic all related target event as read
    confirm_pic_message "any" "newest_unread" "all" ""
    printcolor y "Now trigger any button at least 5 times."
    read -p "enter key to continue, when trigger interlock action is finished..."

    while true; do
      status1="$ii""_read"
      status2="$ii""_unread"
      status3="$ii""_any"
      confirm_pic_message "button" "$status3" "255" ""
      pic_event_amount=$pic_log_filter_amount
      confirm_pic_message "button" "$status1" "255" ""
      pic_event_read=$pic_log_filter_amount
      confirm_pic_message "button" "$status2" "255" ""
      pic_event_unread=$pic_log_filter_amount

      printcolor y "Now confirm button event from $ii"
      printcolor y "============================================="
      print_read_unread_message "$pic_event_amount" "$pic_event_read" "$pic_event_unread" "none"

      confirm_pic_read_unread_amount "$pic_event_amount" "$pic_event_read" "$pic_event_unread" "skip"

      if [[ "$pic_event_unread" != 0 ]]; then
        confirm_pic_message "button" "$status2" "0" "check"
      else
        case $ii in
          "oldest")
            datetime_compare "higher"
            date_time_prepare "reset"
            ;;
          "newest")
            datetime_compare "lower"
            date_time_prepare "reset"
            ;;
        esac
        printcolor y "the event from unread to read status verification is finished."
        break
      fi

    done
  done
}
#===============================================================
#battery alarm event
#===============================================================

battery_alarm_event() {

  local ii

  for ii in "oldest" "newest"; do
    #make pic all related target event as read
    confirm_pic_message "any" "newest_unread" "all" ""
    title b "Now test function from [$ii] order"
    title b "Now set up battery alarm setting to trigger RTC alarm."
    print_command "sudo ./idll-test.exe --pic-batteries-voltage "33,33,33" -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section BatSetGetLowVoltageManual [PIC][BATTERY][MANU]"
    sudo ./idll-test.exe --pic-batteries-voltage "33,33,33" -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section BatSetGetLowVoltageManual [PIC][BATTERY][MANU]

    title r "***Now to adjust one of the battery voltage=3.0v. Press enter key, when you finish.***"
    read -p ""
    #reset PIC battery warning behavior by rechecking the pic battery voltage.
    sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_Battery_PICEventByType

    title r "***Now adjust one of the battery voltage=2.8v. This will make PIC trigger the battery event.***"
    read -p "Press enter key, when you finish adjusting the battery voltage by DC source"


    loop_with_time 12

    while true; do
      status1="$ii""_read"
      status2="$ii""_unread"
      status3="$ii""_any"
      confirm_pic_message "battery_alarm" "$status3" "255" ""
      pic_event_amount=$pic_log_filter_amount
      confirm_pic_message "battery_alarm" "$status1" "255" ""
      pic_event_read=$pic_log_filter_amount
      confirm_pic_message "battery_alarm" "$status2" "255" ""
      pic_event_unread=$pic_log_filter_amount
      confirm_pic_message "any" "$status2" "255" ""
      pic_event_any=$pic_log_filter_amount

      printcolor y "Now confirm battery alarm event from $ii"
      printcolor y "============================================="
      print_read_unread_message "$pic_event_amount" "$pic_event_read" "$pic_event_unread" "$pic_event_any"

      confirm_pic_read_unread_amount "$pic_event_amount" "$pic_event_read" "$pic_event_unread" "$pic_event_any"
      if [[ "$pic_event_unread" != 0 ]]; then
        confirm_pic_message "battery_alarm" "$status2" "0" "check"
      else
        case $ii in
          "oldest")
            datetime_compare "higher"
            date_time_prepare "reset"
            ;;
          "newest")
            datetime_compare "lower"
            date_time_prepare "reset"
            ;;
        esac
        printcolor y "the event from unread to read status verification is finished."
        break
      fi

    done
  done
}

#===============================================================
#RTC alarm event
#===============================================================

rtc_alarm_event() {
  local ii
  for ii in "oldest" "newest"; do
    #make pic all related target event as read
    confirm_pic_message "any" "newest_unread" "all" ""
    # trigger rtc alarm 5 time, so it will have enough event to compare
    title b "Now test function from [$ii] order"
    title b "Now trigger PIC RTC alarm for 5 times:"
    for ((i = 0; i < 5; i++)); do
      sudo ./idll-test.exe --pic-alarm_seconds 2 -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section PIC_RTC_ALARM_SET_manual [PIC][RTC][ALARM][MANUAL]
      printcolor y "Wait 2 second for RTC alarm trigger...."
      sleep 3
    done

    while true; do
      status1="$ii""_read"
      status2="$ii""_unread"
      status3="$ii""_any"
      confirm_pic_message "rtc_alarm" "$status3" "255" ""
      pic_event_amount=$pic_log_filter_amount
      confirm_pic_message "rtc_alarm" "$status1" "255" ""
      pic_event_read=$pic_log_filter_amount
      confirm_pic_message "rtc_alarm" "$status2" "255" ""
      pic_event_unread=$pic_log_filter_amount
      confirm_pic_message "any" "$status2" "255" ""
      pic_event_any=$pic_log_filter_amount

      title b "Now confirm RTC alarm event from $ii"
      print_read_unread_message "$pic_event_amount" "$pic_event_read" "$pic_event_unread" "$pic_event_any"

      confirm_pic_read_unread_amount "$pic_event_amount" "$pic_event_read" "$pic_event_unread" "$pic_event_any"
      if [[ "$pic_event_unread" != 0 ]]; then
        confirm_pic_message "rtc_alarm" "$status2" "0" "check"
      else
        case $ii in
          "oldest")
            datetime_compare "higher"
            date_time_prepare "reset"
            ;;
          "newest")
            datetime_compare "lower"
            date_time_prepare "reset"
            ;;
        esac
        printcolor y "the event from unread to read status verification is finished."
        break
      fi

    done
  done
}
#===============================================================
#pic queue event amount check
#===============================================================

queue_amount() {
  launch_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 --section Callback_PIC_EventQueueFull_Auto [CALLBACK][PIC][UNITTEST]"
  compare_result "$result" "passed"
}

#===============================================================
#pic event filter by user
#===============================================================

filter_user() {
  mseg=(
  "The following type list you can choose by number to display all unread new pic event: "
  "1. battery"
  "2. intrusion_open"
  "3. intrusion_close"
  "4. power"
  "5. button"
  "6. battery_alarm"
  "7. rtc_alarm"
  "8. any"
  )
  title_list w mseg[@]
  read -p "Type your choose: " input
  case $input in
  1)
    confirm_pic_message "battery" "newest_unread" "all" ""
    ;;
  2)
    confirm_pic_message "intrusion_open" "newest_unread" "all" ""
    ;;
  3)
    confirm_pic_message "intrusion_close" "newest_unread" "all" ""
    ;;
  4)
    confirm_pic_message "power" "newest_unread" "all" ""
    ;;
  5)
    confirm_pic_message "button" "newest_unread" "all" ""
    ;;
  6)
    confirm_pic_message "battery_alarm" "newest_unread" "all" ""
    ;;
  7)
    confirm_pic_message "rtc_alarm" "newest_unread" "all" ""
    ;;
  8)
    confirm_pic_message "any" "newest_unread" "all" ""
    ;;
  esac

}
#===============================================================
#MAIN
#===============================================================
while true; do
  printf "\n"
  printf "${COLOR_RED_WD}1. INTERLOCK EVENT ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}2. POWER EVENT ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}3. BATTERY EVENT${COLOR_REST}\n"
  printf "${COLOR_RED_WD}4. BUTTON EVENT ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}5. BATTERY ALARM EVENT ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}6. RTC ALARM EVENT${COLOR_REST}\n"
  printf "${COLOR_RED_WD}7. PIC QUEUE AMOUNT ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}8. PIC EVENT FILTER CHOOSE BY USER ${COLOR_REST}\n"
  printf "${COLOR_RED_WD}======================================${COLOR_REST}\n"
  printf "CHOOSE ONE TO TEST: "
  read -p "" input

  if [ "$input" == 1 ]; then
    interlock_event
  elif [ "$input" == 2 ]; then
    power_event
  elif [ "$input" == 3 ]; then
    battery_event
  elif [ "$input" == 4 ]; then
    button_event
  elif [ "$input" == 5 ]; then
    battery_alarm_event
  elif [ "$input" == 6 ]; then
    rtc_alarm_event
  elif [ "$input" == 7 ]; then
    queue_amount
  elif [ "$input" == 8 ]; then
    filter_user
  fi

done
