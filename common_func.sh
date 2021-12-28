#!/bin/bash
COLOR_REST='\e[0m'
COLOR_RED='\e[101m'
COLOR_RED_WD='\e[0;31m'
COLOR_BLUE='\e[104m'
COLOR_RED_WD='\e[0;31m'
COLOR_BLUE_WD='\e[0;36m'
COLOR_YELLOW_WD='\e[93m'
COLOR_GREEN_WD='\e[32m'

for i in "BSEC_BACC" "LEC1" "SC1X"; do
  board_init=$(sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_"$i" --section adiLibInit)
  if [[ "$board_init" =~ "detected" ]]; then
    board=$i
    echo "good"
  fi
done

#board="BSEC_BACC"
#board="LEC1"
#board="SC1X"



launch_command() {
  print_command "$1"
  result=$($1)
  printcolor w "$result"
}

#if $3 has input string, it will ignore $1 including fail message 
compare_result() {
  status=""
  if [[ "$1" =~ "failed" && "$3" == "" ]]; then
    #    echo "$1"
    if [[ "$2" =~ "failed" ]]; then
      printf "\n"
      printcolor g "================================================================"
      printcolor g "Result includes expected data : ($2)"
      printcolor g "================================================================"
      printcolor g "Result: PASS"
      printcolor g "================================================================"
      printf "\n\n\n"
      status=""
    else
      echo "$1"
      printf "\n"
      printcolor r "================================================================"
      printcolor r "Expected result above doesn't include : ($2) or result failed"
      printcolor r "================================================================"
      printcolor r "Result: FAIL"
      printcolor r "================================================================"
      printf "\n\n\n"
      status="fail"
      read -p ""
    fi
  elif [[ "$1" =~ $2 ]]; then
    printf "\n"
    printcolor g "================================================================"
    printcolor g "Result includes expected data : ($2)"
    printcolor g "================================================================"
    printcolor g "Result: PASS"
    printcolor g "================================================================"
    printf "\n\n\n"
    status=""
  else
    echo "$1"
    printf "\n"
    printcolor r "================================================================"
    printcolor r "Expected result above doesn't include : ($2) or result failed"
    printcolor r "================================================================"
    printcolor r "Result: FAIL"
    printcolor r "================================================================"
    printf "\n\n\n"
    status="fail"
    read -p ""

  fi
}


verify_result() {
  status=""
  if [[ "$1" =~ "failed" || "$1" =~ "error" ]]; then
    echo "$result"
    printf "\n"
    printcolor r "============================================"
    printcolor r "Result: FAIL"
    printcolor r "============================================"
    printf "\n\n\n"
    status="fail"
    read -p ""
  else
    echo "$result"
    printf "\n"
    printcolor g "============================================"
    printcolor g "Result: PASS"
    printcolor g "============================================"
    printf "\n\n\n"
    status=""
  fi

}

title_list() {
  printf "\n"
  arr=("${!2}")
  local i
  case $1 in
  r)
    #      echo ${#arr[@]}
    #      echo "${arr[1]}"
    printcolor r "==========================================================================================================="
    for i in "${arr[@]}"; do
      printcolor r "$i"
    done
    printcolor r "==========================================================================================================="
    ;;
  b)
    printcolor b "==========================================================================================================="
    for i in "${arr[@]}"; do
      printcolor b "$i"
    done
    printcolor b "==========================================================================================================="
    ;;
  y)
    printcolor y "==========================================================================================================="
    for i in "${arr[@]}"; do
      printcolor y "$i"
    done
    printcolor y "==========================================================================================================="
    ;;
  g)
    printcolor g "==========================================================================================================="
    for i in "${arr[@]}"; do
      printcolor g "$i"
    done
    printcolor g "==========================================================================================================="
    ;;
  w)
    printcolor w "==========================================================================================================="
    for i in "${arr[@]}"; do
      printcolor w "$i"
    done
    printcolor w "==========================================================================================================="
    ;;
  esac
}

print_command() {
  printf "\n"
  printcolor y "********************************************************* Command line ***********************************************************************"
  printcolor y "$1 "
  printcolor y "**********************************************************************************************************************************************"
}

title() {
  case $1 in
  r)
    #      echo ${#arr[@]}
    #      echo "${arr[1]}"
    printcolor r "==========================================================================================================="
    printcolor r "$2"
    printcolor r "==========================================================================================================="
    ;;
  b)
    printcolor b "==========================================================================================================="
    printcolor b "$2"
    printcolor b "==========================================================================================================="
    ;;
  y)
    printcolor y "==========================================================================================================="
    printcolor y "$2"
    printcolor y "==========================================================================================================="
    ;;
  g)
    printcolor g "==========================================================================================================="
    printcolor g "$2"
    printcolor g "==========================================================================================================="
    ;;
  w)
    printcolor w "==========================================================================================================="
    printcolor w "$2"
    printcolor w "==========================================================================================================="
    ;;
  esac
}

printcolor() {
  case $1 in
  "r")
    printf "${COLOR_RED_WD}$2 ${COLOR_REST}\n"
    ;;
  "b")
    printf "${COLOR_BLUE_WD}$2 ${COLOR_REST}\n"
    ;;
  "y")
    printf "${COLOR_YELLOW_WD}$2 ${COLOR_REST}\n"
    ;;
  "g")
    printf "${COLOR_GREEN_WD}$2 ${COLOR_REST}\n"
    ;;
  "w")
    echo "$2"
    ;;
  esac

}

#compare all time setting in datetime array to confirm if they are in order as expected setting.
# input higher mean: confirm from old to new PIC event time ("EPIC_STATUS_FROM_OLDEST_XXX")
# input lower mean: confirm from new to old PIC event time ("EPIC_STATUS_FROM_NEWEST_XXX")
datetime_compare() {
  printf "\n\n"
  title b "Start to compare PIC event log time order"
  printcolor b "timearray=${time_array[*]} "

  if [[ "${#time_array[*]}" -gt 1 ]]; then
    for ((i = 0; i < ${#time_array[*]}; i++)); do
      date1=$(date -d "${time_array[$i]}" +%s)
      date2=$(date -d "${time_array[$((i + 1))]}" +%s)
      #    echo "${time_array[$i]}"
      #    echo "${time_array[$((i+1))]}"
      if [[ "$1" == "higher" && "${time_array[$((i + 1))]}" != "" ]]; then
        if [[ "$date1" < "$date2" ]]; then
          printcolor b ""$i"th and $((i + 1))th event time results are correct from older to newer event."
        elif [[ "$date1" -eq "$date2" ]]; then
          printcolor b ""$i"th and $((i + 1))th event time results are equal to each other."
        else
          printcolor r "To compare the $ith with $((i + 1))th event time is not from older to newer event. "
          printcolor r "The "$i" time: ${time_array[$i]}"
          printcolor r "The $((i + 1)) time: ${time_array[$((i + 1))]}"
          read -p ""

        fi
      fi

      if [[ "$1" == "lower" && "${time_array[$((i + 1))]}" != "" ]]; then
        if [[ "$date1" > "$date2" ]]; then
          printcolor b ""$i"th and $((i + 1))th event time results are correct from newer to older event."
        elif [[ "$date1" -eq "$date2" ]]; then
          printcolor b ""$i"th and $((i + 1))th event time results are equal to each other."
        else
          printcolor r "To compare the "$i"th with $((i + 1))th event time is not from newer to older event. "
          printcolor r "the $i time:${time_array[$i]}"
          printcolor r "the $((i + 1)) time:${time_array[$((i + 1))]}"
          read -p ""
        fi
      fi
    done
    date_time_prepare "reset"

  else
    date_time_prepare "reset"
  fi

}

date_time_prepare() {
  case $1 in
  "add")
    temp=$(echo "$result" | grep -i 'time' | sed 's/\//-/g' | sed 's/--Time://g')
    temp=${temp:1:17}
    #    echo "$temp"
    #    echo $timecount

    time_array[$timecount]=$temp
    #    printcolor r "time${time_array[*]}"
    read -p ""
    ((timecount++))
    ;;
  "reset")
    timecount=0
    time_array=("")
    ;;
  esac

}

#time_array=("21-01-29 00:55:17" "21-01-29 00:55:18" "21-01-29 00:55:19")
#datetime_compare "higher"
#datetime_compare "lower"
#read -p ""

picevent_amount_confirm() {
  #confirm the pic power related event amount should be 0
  confirm_pic_message "$1" "newest_unread" "255" ""
  #  title r "$pic_log_filter_amount"
  if [[ "$pic_log_filter_amount" -eq 0 ]]; then
    echo 0
  else
    title r "PIC still has new event about power as the following list"
    confirm_pic_message "$1" "newest_unread" "all" ""
    echo $pic_log_filter_amount
  fi
}

#filter pic event with different type, and also to confirm if thery match as expected type
confirm_pic_message() {
  #event type:
  #battery/ intrusion_open/ intrusion_close/ power/ button/ battery_alarm/ rtc_alarm/ battery_alarm/ any

  #confirm_pic_message 1 2 3 4
  #1: event type you want to search
  #2: how the oder to display the result
  #3: set "all" means to display all the related log, or input number means to display the index number event
  #4: input "check" means need to confirm if the return log matchs the expected type(also save the result in time_array function ), or input "" means only output the result

  local type type_result status index loop result

  case $1 in
  "battery")
    type="EPIC_EVENT_BATTERY"
    type_result="Event.EventCode:4"
    ;;
  "intrusion_open")
    type="EPIC_EVENT_INTERLOCK_OPEN"
    type_result="INTERLOCK_OPEN:"
    ;;
  "intrusion_close")
    type="EPIC_EVENT_INTERLOCK_CLOSE"
    type_result="INTERLOCK_CLOSE:"
    ;;
  "power")
    type="EPIC_EVENT_POWER"
    type_result=("Event.EventCode:3 " "Event.EventCode:35" "Event.EventCode:67" "Event.EventCode:19" "Event.EventCode:51")
    ;;
  "button")
    type="EPIC_EVENT_BUTTON"
    type_result="BUTTON:"
    ;;
  "battery_alarm")
    type="EPIC_EVENT_BATTERY_ALARM"
    type_result="BATTERY Alarm/Warn"
    ;;
  "rtc_alarm")
    type="EPIC_EVENT_RTC_ALARM"
    type_result="Event.EventCode:7"
    ;;
  "any")
    type="EPIC_EVENT_ANY"
    ;;
  esac

  case $2 in
  "oldest_read")
    status="EPIC_STATUS_FROM_OLDEST_READ"
    ;;
  "oldest_unread")
    status="EPIC_STATUS_FROM_OLDEST_UNREAD"
    ;;
  "oldest_any")
    status="EPIC_STATUS_FROM_OLDEST_ANY"
    ;;
  "newest_read")
    status="EPIC_STATUS_FROM_NEWEST_READ"
    ;;
  "newest_unread")
    status="EPIC_STATUS_FROM_NEWEST_UNREAD"
    ;;
  "newest_any")
    status="EPIC_STATUS_FROM_NEWEST_ANY"
    ;;
  esac

  pic_log_filter_amount=$(sudo ./idll-test.exe --EVENT_TYPE "$type" --EVENT_STATUS "$status" --EVENT_INDEX 255 -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_adiEventGetWithFilter_Manu [ADiDLL][PIC] | grep -i "total number" | sed "s/\s//g" | sed "s/[A-Za-z]//g" | sed "s/://g")

  #confirm if index parameter is set to all, meaning it needs to loop each result to check if it includes all supported type
  if [ "$3" == "all" ]; then
    #    pic_log_filter_amount=10
    index=$pic_log_filter_amount
    date_time_prepare "reset"

    #check if the event amount is 0, if then exit
    if [[ "$index" -eq 0 ]]; then
      printf "\n\n"
      title b "No any target event exists in pic log."
      return
    else
      mesg=(
        "The total target events are found as below list, please confirm."
        "Search type: $type"
        "Search total amount: $index"
      )
      printf "\n\n"
      title_list b mesg[@]
      read -p "enter key to continue..."
    fi

    for ((i = 0; i < index; i++)); do

      #if $2 has unread , it needs to set search index always as 0, due to the total amount of unread will be reduced, once it has been read before.
      if [[ "$2" =~ "unread" ]]; then
        print_command "sudo ./idll-test.exe --EVENT_TYPE "$type" --EVENT_STATUS "$status" --EVENT_INDEX "0" -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_adiEventGetWithFilter_Manu [ADiDLL][PIC]"
        result=$(sudo ./idll-test.exe --EVENT_TYPE "$type" --EVENT_STATUS "$status" --EVENT_INDEX "0" -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_adiEventGetWithFilter_Manu [ADiDLL][PIC])
      else
        print_command "sudo ./idll-test.exe --EVENT_TYPE "$type" --EVENT_STATUS "$status" --EVENT_INDEX "$i" -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_adiEventGetWithFilter_Manu [ADiDLL][PIC]"
        result=$(sudo ./idll-test.exe --EVENT_TYPE "$type" --EVENT_STATUS "$status" --EVENT_INDEX "$i" -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_adiEventGetWithFilter_Manu [ADiDLL][PIC])
      fi

      if [[ "$1" != "any" && "$4" == "check" ]]; then

        #if type input power meaning it there are more than one type need to check, so loop all type with result
        if [[ "$1" == "power" ]]; then

          #loop type_result to check if one of type_result is in result
          for rr in "${type_result[@]}"; do
            printcolor y "expected result: $rr"
            printcolor y "====================================="

            if [[ "$result" =~ $rr ]]; then
              printcolor b "PIC log matchs with expected result as the following...\n"
              echo "$result"
              #to get the message related time, and filter the date/time only for function date_time_compare to analise
              date_time_prepare "add"
              #              time_array[$i]=$( echo "$result" | grep -i 'time' temp.txt | sed 's/\//-/g' | sed 's/--Time //g' )
            fi

          done

        else
          printcolor y "expected result: $type_result"
          printcolor y "====================================="

          if [[ "$result" =~ $type_result ]]; then
            printcolor b "Result match as the following...\n"
            #to get the message related time, and filter the date/time only for function date_time_compare to analize
            date_time_prepare "add"
            #            time_array[$i]=$( echo "$result" | grep -i 'time' temp.txt | sed 's/\//-/g' | sed 's/--Time //g' )
            echo "$result"
          else
            printcolor r "Can't find any type in result matching the expected type.."
            echo "$result"
            read -p ""
          fi

        fi
      else
        echo "$result"

      fi
    done

  elif [[ "$3" != "255" ]]; then
    index=$3
    print_command "sudo ./idll-test.exe --EVENT_TYPE "$type" --EVENT_STATUS "$status" --EVENT_INDEX "$index" -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_adiEventGetWithFilter_Manu [ADiDLL][PIC]"
    result=$(sudo ./idll-test.exe --EVENT_TYPE "$type" --EVENT_STATUS "$status" --EVENT_INDEX "$index" -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_adiEventGetWithFilter_Manu [ADiDLL][PIC])
    #    date_time_prepare "reset"

    if [[ "$1" == "power" && "$4" == "check" ]]; then
      local temp=0

      #loop type_result to check if one of type_result is in result
      for rr in "${type_result[@]}"; do
        printcolor y "expected result: $rr"
        printcolor y "====================================="
        if [[ "$result" =~ $rr ]]; then
          printcolor b "PIC log matchs with expected result as the following...\n"
          echo "$result"
          #to get the message related time, and filter the date/time only for function date_time_compare to analise
          date_time_prepare "add"
          #          time_array[$i]=$( echo "$result" | grep -i 'time' temp.txt | sed 's/\//-/g' | sed 's/--Time //g' )
        fi
      done

    elif [[ "$4" == "check" ]]; then
      printcolor y "expected result: $type_result"
      printcolor y "====================================="

      if [[ "$result" =~ $type_result ]]; then
        printcolor b "Result match as the following...\n"
        #to get the message related time, and filter the date/time only for function date_time_compare to analize
        date_time_prepare "add"
        #        time_array[$i]=$( echo "$result" | grep -i 'time' temp.txt | sed 's/\//-/g' | sed 's/--Time //g' )
        echo "$result"
      else
        printcolor r "Can't find any type in result matching the expected type.."
        echo "$result"
        read -p ""
      fi
    else
      echo "$result"
    fi
  fi

}
pic_time() {
  pic_time=$(sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_RTC_GETCLOCK | grep -i "clock" | sed 's/PICRTClock: PIC RTClock: //g' | sed 's/\//-/g')
  pic_time=$(date -d "$pic_time" +%s)
}

pic_rtc_sync() {
  local now_sec now_min now_hour now_day now_month now_year
  now_year=$(date '+%Y')
  now_month=$(date '+%m')
  now_day=$(date '+%d')
  now_hour=$(date '+%H')
  now_min=$(date '+%M')
  now_sec=$(date '+%S')
  #sync up RTC with pIC time
  sudo ./idll-test.exe --pic-time "$now_year/$now_month/$now_day/$now_hour/$now_min/$now_sec" -- --EBOARD_TYPE EBOARD_ADi_"$board" --section PIC_RTC
}

#setting pic time as pc rtc time/ input the warning or low battery voltage in the parameter for future function usage
pic_battery_preliminary() {
  pic_rtc_sync
  printcolor y "Input [PIC] monitoring voltage (input 0 means it will have no monitor behavior):"
  read -p "" low1
  if [[ "$low1" -eq 0 ]]; then
    low1="00"
  elif [[ "$low1" -lt 10 ]]; then
    low1=0$low1
  fi

  printcolor y "input [Sram1] monitoring voltage(input 0 means it will have no monitor behavior):"
  read -p "" low2
  if [[ "$low2" -eq 0 ]]; then
    low2="00"
  elif [[ "$low2" -lt 10 ]]; then
    low2=0$low2
  fi

  printcolor y "input [Sram2] monitoring voltage(input 0 means it will have no monitor behavior):"
  read -p "" low3
  if [[ "$low3" -eq 0 ]]; then
    low3="00"
  elif [[ "$low3" -lt 10 ]]; then
    low3=0$low3
  fi

  title b "Now reset all unread pic event to be read status"
  confirm_pic_message "battery_alarm" "newest_unread" "all" "no"
}

#counting in certain time for any need to count down usage
loop_with_time() {
  printcolor y "Starting counting down in $1 minute, please wait..."
  for ((i = 0; i < $1; i++)); do
    m=$(($1 - i))
    printcolor y "\r$m minute left.."
    sleep 60
  done
}

write_data() {
  local i r m
  for i in {0..5}; do
    write_data[$i]=$(shuf -i 0-255 -n 1)
#    echo "${write_data[@]}"
  done

  m=0
  for r in ${write_data[*]}; do
    re=$( echo "obase=16;$r"|bc )
    if [ ${#re} == 1 ]; then
      write_data_hex[$m]=0x0$re
    else
      write_data_hex[$m]=0x$re
    fi
    ((m++))
  done



}

#compare_result "11" "22"