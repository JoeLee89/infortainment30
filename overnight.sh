#!/bin/bash
source ./common_func.sh
times=0
loop_time=$(date +%s --date="+12 hour")
file_name="lec1_auto.bat"


#set start time will make the program pause, until the setting time reach
#input start time format ex. "10/26/21-11" to start setting wait time, or set to 0 to skip the function
#start_time="10/26/21-11"
start_time=0

#to set others=1 will set the other() function launch, if your project support the script
#or just set to =0 to skip the test
others_script=0

other() {
  print_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 "Scenario: adiWatchdogSetSystemRestart" -s"

  other=$(sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 "Scenario: adiWatchdogSetSystemRestart" -s)
  echo "$other"
  echo "================================================================================================" >> result.log
  echo "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 "Scenario: adiWatchdogSetSystemRestart" -s" >> result.log
  echo "================================================================================================" >> result.log
  echo "$other" >> result.log
}

wait_times() {
  while true; do
    date=$(date '+%D-%k')
    if [[ "$date" =~ $start_time ]]; then
      break
    fi
    sleep 5
    echo $date
    echo 'wait...'

  done
}

#====================================================
if [[ "$start_time" -ne 0 ]]; then
  wait_times
fi

while true; do
  ((times++))
  echo "<<Times=$times>>" >> result.log
  echo "$(date +%D-%T)" >>result.log

  if [[ "$others_script" -ne 0 ]]; then
    other
  fi

  while read line; do
    con=$(echo "$line" | grep -i "idll-test" | grep -v "#" | sed "s/\r//g")

    if [[ "${#con}" -ne 0 ]]; then
      echo "$(date +%D-%T)" >>result.log
      launch_command "$con"
      echo "================================================================================================" >> result.log
      echo "$con" >> result.log
      echo "================================================================================================" >> result.log
      echo "$result" >> result.log
    fi
  done < $file_name

  if [ "$(date +%s)" -gt "$loop_time" ]; then
    echo "The setting time's up!!"
    echo "The overall test times= $times"
    break
  fi

done

