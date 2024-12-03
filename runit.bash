#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: $0 <year>"
    exit
fi
#nohup bash tlauto_run.bash ${1}-02-10 6 &
nohup bash tlauto_run.bash ${1}-02-05 6 &
