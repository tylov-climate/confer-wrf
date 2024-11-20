#!/bin/bash

###############################################
# Slurm settings
###############################################

## Project: replace XXXX with your project ID
#SBATCH --account=nn9853k 

## Job name:
#SBATCH --job-name=cp@YYYY@DD
## Allocating amount of resources:
#SBATCH --nodes=1 --ntasks-per-node=32

## No memory pr task since this option is turned off on Fram in partition normal.
## Run for 10 minutes, syntax is d-hh:mm:ss
#SBATCH --time=0-01:00:00 

## Set email notifictions
#SBATCH --mail-user=tylo@norceresearch.no


# you may not place bash commands before the last SBATCH directive
######################################################
## Setting variables and prepare runtime environment:
##----------------------------------------------------
## Recommended safety settings:
#set -o errexit # Make bash exit on any error
set -o nounset # Treat unset variables as errors

rundir="@RUNDIR"
outdir="@OUTDIR"

mkdir -p LOGS
cp -af namelist.input LOGS/namelist.input.wrf
cp -af rsl.error.0000 LOGS/rsl.error.0000.wrf
cp -af *.sh LOGS
cp -af *.log LOGS
cp -af slurm* LOGS
ls -al > LOGS/ls_wrf.log

target=$outdir/$(basename $rundir)

#mkdir -p $target
scp -rpq LOGS $USER@login.nird.sigma2.no:$target > my_copy.log
scp -pq TAVGSFC $USER@login.nird.sigma2.no:$target >> my_copy.log
scp -pq wrfdaily_d* $USER@login.nird.sigma2.no:$target >> my_copy.log
scp -pq wrfpress_d* $USER@login.nird.sigma2.no:$target >> my_copy.log
scp -pq wrfhydro_hourly_d* $USER@login.nird.sigma2.no:$target >> my_copy.log
scp -pq my_copy.log $USER@login.nird.sigma2.no:$target/LOGS

exit 0
