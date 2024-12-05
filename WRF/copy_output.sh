#!/bin/bash

###############################################
# Slurm settings
###############################################

## Project: replace XXXX with your project ID
#SBATCH --account=nn9853k 

## Job name:
#SBATCH --job-name=cp@YYYY@DD
## Allocating amount of resources:
#SBATCH --nodes=1 -ntasks-per-node=4

## No memory pr task since this option is turned off on Fram in partition normal.
## Run for 10 minutes, syntax is d-hh:mm:ss
#SBATCH --time=0-02:00:00

## Set email notifictions
#SBATCH --mail-user=tylo@norceresearch.no


# you may not place bash commands before the last SBATCH directive
######################################################
## Setting variables and prepare runtime environment:
##----------------------------------------------------
## Recommended safety settings:
set -o errexit # Make bash exit on any error
set -o nounset # Treat unset variables as errors

mkdir -p LOGS

target="@TARGET"
ssh $USER@login.nird.sigma2.no "mkdir -p $target/LOGS" > my_copy.log
scp -pq ../WPS/TAVGSFC $USER@login.nird.sigma2.no:$target >> my_copy.log
scp -pq ./wrfdaily_d* $USER@login.nird.sigma2.no:$target >> my_copy.log
scp -pq ./wrfpress_d* $USER@login.nird.sigma2.no:$target >> my_copy.log
scp -pq ./wrfhydro_hourly_d* $USER@login.nird.sigma2.no:$target >> my_copy.log
echo "$(date): COPYIED DATA SUCCESSFULLY" >> my_copy.log

cp -af namelist.input LOGS/namelist.input.wrf.$(date -r namelist.input "+%Y%m%d-%H%M")
cp -af my_wrf.log LOGS/my_wrf.log.$(date -r my_wrf.log "+%Y%m%d-%H%M")
gzip -c rsl.error.0000 > LOGS/rsl.error.0000.wrf.$(date -r rsl.error.0000 "+%Y%m%d-%H%M").gz
ls -al > LOGS/ls_wrf.log.$(date "+%Y%m%d-%H%M")
cp -af *.sh LOGS
cp -af slurm* LOGS
cp -af *.log LOGS
scp -pq ./LOGS/* $USER@login.nird.sigma2.no:$target/LOGS

exit 0
