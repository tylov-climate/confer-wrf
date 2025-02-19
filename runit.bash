#!/bin/bash
# Script by Tyge Løvset, NORCE Reginal Climate, 2024

if [ -z "$2" ]; then
  echo "Usage: $0 <year-imonth-iday> <run_months>"
  echo " e.g.: $0 1991-02-10 6"
  echo ""
  exit
fi
nohup bash tlauto_run.bash $* &
