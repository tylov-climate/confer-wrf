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
set -o errexit # Make bash exit on any error
set -o nounset # Treat unset variables as errors

rundir="@RUNDIR"
outdir="@OUTDIR"

target=$outdir/$(basename $rundir)

mkdir -p $target
cp -p wrfdaily_d* $target
cp -p wrfpress_d* $target
cp -p wrfhydro_hourly_d* $target
