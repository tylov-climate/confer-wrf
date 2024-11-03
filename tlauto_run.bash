#!/bin/bash

if [ -z "$2" ]; then
  echo "Usage: $0 <year-imonth-iday> <run_months> [download [force]]"
  echo ""
  echo " e.g.: $0 1991-02-10 6"
  exit
fi
run_months=$2

year=$(date "+%Y" -d "$1")
imon=$(date "+%m" -d "$1")
iday=$(date "+%d" -d "$1")
year2=$(date "+%Y" -d "$year-$imon-01 +$run_months months -1 day")
imon2=$(date "+%m" -d "$year-$imon-01 +$run_months months -1 day")
iday2=$(date "+%d" -d "$year-$imon-01 +$run_months months -1 day")

echo $year, $imon, $iday
echo $year2, $imon2, $iday2

######################################################
## Setting variables and prepare runtime environment:
##----------------------------------------------------
## Recommended safety settings:
#set -o errexit # Make bash exit on any error
#set -o nounset # Treat unset variables as errors

########################################################################
# set directory to copy important scripts and files and creat working
#########################################################################
#startdir="/cluster/projects/nn9853k/tylo/start"
startdir=$(cd $(dirname $0) ; pwd)

#start=021000 # month, date, hour
start=${imon}${iday}00

outdir="/nird/projects/NS9853K/users/tylo/CFSv2_downscaled_wrfout/MAM-WRFOUT"
export outdir

rundir="/cluster/work/users/tylo/MAM_CFSv2_downscaling/MAM_${year}${start}"
export rundir

echo --------------------------------------------------------------------------------------------------
echo YEAR: $year.$start
echo RUNDIR: $rundir
echo HINDCAST: /cluster/projects/nn9853k/WRF_Hindcast_input/CFS2V_Reforecast_MAM/$year/${year}${start}

# Predownload all years...
if [ "$3" == "download" ]; then

  for (( ; year <= 2023; year++ )); do
    hindcast=/cluster/projects/nn9853k/WRF_Hindcast_input/CFS2V_Reforecast_MAM/$year/${year}${start}

    if [ -d $hindcast ] && [ "$4" != "force" ]; then
      echo "Hindcast source files already downloaded:"
      echo "    $hindcast"
    else
      mkdir -p $hindcast
      pushd $hindcast
        cp $startdir/cfs2v_reforecast_download.sh .
        if (( (year % 6) == 1 )); then 
          echo "./cfs2v_reforecast_download.sh $year $imon $iday"
          ./cfs2v_reforecast_download.sh $year $imon $iday
        else
          echo "nohup ./cfs2v_reforecast_download.sh $year $imon $iday &"
          nohup ./cfs2v_reforecast_download.sh $year $imon $iday &
        fi
      popd
    fi
  done # all years
  exit # stop after download all

else

  # Only download given input year - if needed
  hindcast=/cluster/projects/nn9853k/WRF_Hindcast_input/CFS2V_Reforecast_MAM/$year/${year}${start}

  if [ -d $hindcast ]; then
    echo "Hindcast source files already downloaded:"
    echo "    $hindcast"
  else
    mkdir -p $hindcast
    pushd $hindcast
      cp $startdir/cfs2v_reforecast_download.sh .
      echo "./cfs2v_reforecast_download.sh $year $imon $iday"
      ./cfs2v_reforecast_download.sh $year $imon $iday
    popd
  fi

fi

# Enter rundir:

if [ -d $rundir ]; then
  echo "Rundir already exists..."
fi
echo Rundir: $rundir
mkdir -p $rundir
cd $rundir

cp $startdir/tlauto_run.bash $rundir
cp $startdir/sbatch_wrapper.sh $rundir


rm -rf ANALYSIS
mkdir ANALYSIS

echo "CFS: link grb2 files..."
rm -rf CFS
mkdir CFS

pushd CFS
  ln -s /cluster/projects/nn9853k/WRF_Hindcast_input/CFS2V_Reforecast_MAM/$year/${year}${start}/*01.${year}${start}.grb2* .
popd

###############################################
# Loading Software modules
###############################################
# Allways be explicit on loading modules and setting run time environment!!!
# Type "module avail MySoftware" to find available modules and versions
# It is also recommended to to list loaded modules, for easier debugging:
#module list
#module purge
#module load WPS/4.4-foss-2022a-dmpar
#module load WRF/4.4-foss-2022a-dmpar
#module list

echo "WPS: copy script files..."
#rm -rf WPS
mkdir WPS

pushd WPS
  cp $startdir/WPS/linkWPS.csh .
  cp $startdir/WPS/namelist.wps .
  #cp $startdir/WPS/run_geogrid.sh .
  #cp $startdir/WPS/run_ungrib.sh .
  cp $startdir/WPS/run_wps.sh .
  cp $startdir/WPS/run_metgrid.sh .
  cp -r $startdir/WPS/ungrib/Variable_Tables .

  sed -i -e "s/YYYY2/$year2/g" -e "s/MM2/$imon2/g" -e "s/DD2/$iday2/g" \
         -e "s/YYYY/$year/g" -e "s/MM/$imon/g" -e "s/DD/$iday/g" namelist.wps
  sed -i -e "s/YYYY/$year/g" -e "s/DD/$iday/g" run_wps.sh
  sed -i -e "s/YYYY/$year/g" -e "s/DD/$iday/g" run_metgrid.sh

  echo "Link WPS files."
  ./linkWPS.csh

  ###############################################
  # Run WPS geogrid, ungrib and avg_tsfc
  ###############################################
  echo "Run all WPS: geogrid.exe, ungrib.exe and avg_tsfc.exe"
  wps_job=$(../sbatch_wrapper.sh run_wps.sh)
  echo "wps_job: $wps_job"
  
  ## sed -i "48s|SFLX|SST|" namelist.wps
  ## ./link_grib.csh $sstdir/oiss*grb
  ## ln -sf ./ungrib/Variable_Tables/Vtable.SST Vtable
  ## mpirun ./ungrib.exe >& my_ungrib3.log
  ##
  ## echo "interpolate SFC temperature over lake"
  ## ./util/avg_tsfc.exe >& my_avg_tsfc.log

  ###############################################
  # running metgrid
  ###############################################
  echo "Run metgrid.exe"
  metg_job=$(../sbatch_wrapper.sh --dependency=afterok:$wps_job run_metgrid.sh)
  echo "metg_job: $metg_job"

popd # WPS

#exit


###############################################
# preparing to run WRF
###############################################
#rm -rf WRFRUN
mkdir -p WRFRUN

pushd WRFRUN
  cp $startdir/WRF/linkWRF.csh .
  cp $startdir/WRF/run_real.sh .
  cp $startdir/WRF/run_wrf.sh .
  cp $startdir/WRF/tkb_hydro_d0?.txt .
  cp $startdir/WRF/namelist.input .
  cp $startdir/WRF/copy_output.sh .

  sed -i -e "s/YYYY2/$year2/g" -e "s/MM2/$imon2/g" -e "s/DD2/$iday2/g" \
         -e "s/YYYY/$year/g" -e "s/MM/$imon/g" -e "s/DD/$iday/g" namelist.input
  sed -i -e "s/YYYY/$year/g" -e "s/DD/$iday/g" run_real.sh
  sed -i -e "s/YYYY/$year/g" -e "s/DD/$iday/g" run_wrf.sh
  sed -i -e "s/YYYY/$year/g" -e "s/DD/$iday/g" copy_output.sh

  echo "Link WRF program files."
  ./linkWRF.csh
  
  ###############################################
  # run real.exe
  ###############################################
  echo "Run real.exe"
  real_job=$(../sbatch_wrapper.sh --dependency=afterok:$metg_job run_real.sh)
  echo "real_job: $real_job"
  
  ###############################################
  # run wrf.exe
  ###############################################
  echo "Run wrf.exe"
  wrf_job=$(../sbatch_wrapper.sh --dependency=afterok:$real_job run_wrf.sh)
  echo "wrf_job: $wrf_job"

  ###############################################
  # copy wrf.exe output
  ###############################################
  echo "Copy wrf.exe output to target"
  sbatch --dependency=afterok:$wrf_job copy_output.sh
popd # WRFRUN

echo "SUCCESS!"
