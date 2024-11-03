#!/bin/bash
# Download MAM series from 1991-2023

if [ -z "$3" ]; then
  echo "Usage $0 YEAR IMON IDAY"
  echo "  YEAR: 1991 .. 2023"
  echo "  IMON: init month"
  echo "  IDAY: init day of month"
  echo ""
  exit
fi

# Note: February starts at date 10th.
year=$1
imon=$2
iday=$3
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

echo Input: $flx_root/$year/$subdir

#page=https://www.ncei.noaa.gov/data/climate-forecast-system/access/reforecast/6-hourly-by-pressure-level-9-month-runs/1992/199205/19920511
#page=https://www.ncei.noaa.gov/data/climate-forecast-system/access/operational-9-month-forecast/6-hourly-by-pressure/2022/202205/20220501/2022050100

var="flxf"
page="$flx_root/$year/$subdir"
#page=https://www.ncei.noaa.gov/data/climate-forecast-system/access/reforecast/6-hourly-flux-9-month-runs/1991/199102/19910210/flxf1991021000.01.1991021000.grb2 

start=$iday
for (( month = imon; month <= imon+5; month ++ )); do
  for (( day = start; day <= 31; day ++ )); do
    ymd=$(printf "%04d%02d%02d" $year $month $day)

    for run in "00" "06" "12" "18"; do
      #wget -nd -np -P . -r -R "index.html*" $page/$var$ymd$run.01.1996042600.grb2
      #echo wget -c "$page/${var}${ymd}${run}.01.${itime}.grb2"
      wget -c "$page/${var}${ymd}${run}.01.${itime}.grb2"
      #printf "\n"
    done
  done
  start=1
done


var="pgbf"
page="$pl_root/$year/$subdir"
#page=https://www.ncei.noaa.gov/data/climate-forecast-system/access/reforecast/6-hourly-by-pressure-level-9-month-runs/1991/199102/19910210/pgbf1991021000.01.1991021000.grb2 

start=$iday
for (( month = imon; month <= imon+5; month ++ )); do
  for (( day = start; day <= 31; day ++ )); do
    ymd=$(printf "%04d%02d%02d" $year $month $day)

    for run in "00" "06" "12" "18"; do
      #wget -nd -np -P . -r -R "index.html*" $page/$var$ymd$run.01.1996042600.grb2
      #echo wget -c "$page/${var}${ymd}${run}.01.${itime}.grb2"
      wget -c "$page/${var}${ymd}${run}.01.${itime}.grb2"
      #printf "\n"
    done
  done
  start=1
done
