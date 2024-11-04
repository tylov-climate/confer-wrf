#!/bin/bash
# Download MAM series from 1991-2023
# Script by Tyge Løvset, NORCE, 2024

if [ -z "$2" ]; then
  echo "Usage $0 YEAR-IMON-IDAY RUN_MONTHS"
  echo "  YEAR: 1991 .. 2023"
  echo "  IMON: init month"
  echo "  IDAY: init day of month"
  echo "  RUN_MONTHS: simulation time"
  echo ""
  exit
fi

# Note: February starts at date 10th.
year=$(date "+%Y" -d "$1")
imon=$(date "+%m" -d "$1")
iday=$(date "+%d" -d "$1")
run_months=$2

itime=${year}${imon}${iday}00

if (( year < 2012 )); then
  root="https://www.ncei.noaa.gov/data/climate-forecast-system/access/reforecast"
  flx_root="$root/6-hourly-flux-9-month-runs"
  pl_root="$root/6-hourly-by-pressure-level-9-month-runs"
  subdir="${year}${imon}/${year}${imon}${iday}"
else
  root="https://www.ncei.noaa.gov/data/climate-forecast-system/access/operational-9-month-forecast"
  flx_root="$root/6-hourly-flux"
  pl_root="$root/6-hourly-by-pressure"
  subdir="${year}${imon}/${year}${imon}${iday}/${itime}"
fi

echo "----------------------------------"
echo Flxf input: $flx_root/$year/$subdir
echo Pgbf input: $pl_root/$year/$subdir
echo "----------------------------------"

# page=https://www.ncei.noaa.gov/data/climate-forecast-system/access/reforecast/6-hourly-by-pressure-level-9-month-runs/1992/199205/19920511
# page=https://www.ncei.noaa.gov/data/climate-forecast-system/access/operational-9-month-forecast/6-hourly-by-pressure/2022/202205/20220501/2022050100
# page=https://www.ncei.noaa.gov/data/climate-forecast-system/access/reforecast/6-hourly-flux-9-month-runs/1991/199102/19910210/flxf1991021000.01.1991021000.grb2

page1="$flx_root/$year/$subdir"
var1="flxf"

page2="$pl_root/$year/$subdir"
var2="pgbf"


end=$(date "+%Y%m%d" -d "$year-$imon-01 +$run_months months")
ymd=$(date "+%Y%m%d" -d "$1")

while [ "$ymd" != "$end" ]; do
    for run in 00 06 12 18; do
      wget -c -nv "$page1/${var1}${ymd}${run}.01.${itime}.grb2" &
      if [ "$run" == "18" ]; then
        wget -c -nv "$page2/${var2}${ymd}${run}.01.${itime}.grb2"
      else
        wget -c -nv "$page2/${var2}${ymd}${run}.01.${itime}.grb2" &
      fi
    done

    ymd=$(date "+%Y%m%d" -d "$ymd +1 day")
done

wait
echo "All downloaded"
exit 0
