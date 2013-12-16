#!/bin/bash

hosts=( "$@" )
session_name=tmux-cluster-ssh-`date "+%s"`

function help {
  echo "Useage $0 <host1> [<host2>...]"
}

[ "$1" == "-h" ] && help
[ "$1" == "--help" ] && help
[ $# -eq 0 ] && help

if [ $TMUX ]; then
  echo "Already inside a tmux session. Exiting."
  exit 1
fi

tmux new-session  -s "$session_name" -d "ssh ${hosts[0]}"
unset hosts[0]

for h in ${hosts[@]} ; do
   tmux split-window -t "$session_name" "ssh ${h}"
   tmux select-layout -t "$session_name" tiled
done
tmux set-window-option -t "$session_name" synchronize-panes on
tmux attach -t "$session_name"
