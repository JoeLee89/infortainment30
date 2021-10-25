#!/bin/bash
source ./common_func.sh
loop_time=$(date +%s --date="+12 hour")
file_name="lec1_auto.bat"
times=0
other() {
  print_command "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 "Scenario: adiWatchdogSetSystemRestart" -s"

  other=$(sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 "Scenario: adiWatchdogSetSystemRestart" -s)
  echo "$other"
  echo "================================================================================================" >> result.log
  echo "sudo ./idll-test.exe -- --EBOARD_TYPE EBOARD_ADi_LEC1 "Scenario: adiWatchdogSetSystemRestart" -s" >> result.log
  echo "================================================================================================" >> result.log
  echo "$other" >> result.log
}

#while true; do
#  date=$(date '+%D-%k')
#  if [[ $date =~ '10/23/21-17' ]]; then
#    break
#  fi
#  sleep 5
#  echo $date
#  echo 'wait...'
#
#done


while true; do
  ((times++))
  echo "<<Times=$times>>" >> result.log

  echo "$(date +%D-%T)" >>result.log
#  other

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

