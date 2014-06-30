#!/bin/bash

# Useage:
# nohup nice ./runCommands.sh n commands.txt > log.out &
#
# Executes commands listed in commands.txt, which should contain exactly one
# command per line. This script keeps n of the commands running in parallel 
# all the time.

if [ "$#" -ne 2 ]; then
  echo "Wrong number of arguments"
  echo "Usage: nohup nice ./runCommands.sh <NUMBER-OF-CORES-TO-USE> <COMMAND-FILE>"
  exit 1;
fi

max_jobs=$1
name=$2
count=$(grep -c ^ $name)
total=$count
tmp_file=/tmp/run_comands_$BASHPID
run_tmp_file=/tmp/running_comands_$BASHPID

#Different files we use
command_file="$name.to_run"
running_file="$name.running"
completed_file="$name.completed"
failed_file="$name.failed"
pid_file="$name.pid"

cp "$name" "$command_file"

#Create a pid file 
pid=$BASHPID
echo "$pid" >> "$pid_file"

#Remove PID file on exit
trap "{ clean_up; }" EXIT

function clean_up {
  rm -f "$pid_file"

  #Kill all running processes
  for child in $(ps -o pid --ppid $pid); do
    [ "$child" == "PID" ] && continue
    for grandchild in $(ps -o pid --ppid $child); do
      [ "$grandchild" == "PID" ] && continue
      kill $grandchild
    done
  done

  #Set exit value
  if [ -f $failed_file ]; then
    exit 1
  else
    exit 0
  fi
}

function run {
  command=$1
  id=$2
  echo "$command #($id)" >> $running_file 
  bash -c "$command"
  if [ $? -eq 0 ]; then
    echo "$command" >> $completed_file
  else
    echo "$command" >> $failed_file
  fi

  #Remove job of running file
  while [ -f $run_tmp_file ]; do
    sleep 1 
  done
  touch $run_tmp_file
  grep -v "($id)" $running_file > $run_tmp_file
  mv $run_tmp_file $running_file
}

id=0

#Start the jobs
while [ $count -ge 1 ]
do
	if [ $(jobs | grep -c Running) -lt $max_jobs ]; then
		command=$(head -n1 $command_file)
        ((id++))
        echo "Starting: $command ($id/$total)" 
		run "$command" $id &
        awk 'FNR>1' $command_file > $tmp_file
		mv $tmp_file $command_file
		count=$(grep -c ^ $command_file)
	else 	
		sleep 10
	fi	
done
echo "All jobs started"

#Wait for all jobs to finish
while [ $(jobs | grep -c Running) -gt 0 ]
do
  sleep 10
done
echo "All jobs finished"
