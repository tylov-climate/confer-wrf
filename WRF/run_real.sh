#!/bin/bash

###############################################
# Script example for a normal MPI job on Fram #
###############################################

## Project: replace XXXX with your project ID
#SBATCH --account=nn9853k 

## Job name:
#SBATCH --job-name=re@YYYY@DD
## Allocating amount of resources:
##SBATCH --nodes=1
## Number of tasks (aka processes) to start on each node: Pure mpi, one task per core
##SBATCH --ntasks-per-node=1
#SBATCH --nodes=4 --ntasks-per-node=32

## No memory pr task since this option is turned off on Fram in partition normal.
## Run for 10 minutes, syntax is d-hh:mm:ss
#SBATCH --time=0-08:10:00 

## Set email notifictions
##SBATCH --mail-user=tbahaga@icpac.net
#SBATCH --mail-user=tylo@norceresearch.no


# you may not place bash commands before the last SBATCH directive
######################################################
## Setting variables and prepare runtime environment:
##----------------------------------------------------
## Recommended safety settings:
set -o errexit # Make bash exit on any error
set -o nounset # Treat unset variables as errors

# Loading Software modules
# Allways be explicit on loading modules and setting run time environment!!!

module purge
module load WRF/4.4-foss-2022a-dmpar
# Type "module avail MySoftware" to find available modules and versions
# It is also recommended to to list loaded modules, for easier debugging:
#module list  

#######################################################
## Prepare jobs, moving input files and making sure 
# output is copied back and taken care of
##-----------------------------------------------------

# Make sure output is copied back after job finishes
#savefile outputfile1 outputfile2

########################################################
# Run the application, and we typically time it:
##------------------------------------------------------

# Backup WPS logs
mkdir -p LOGS
cp -af ../WPS/*.log LOGS
cp -af ../WPS/*.sh LOGS
cp -af ../WPS/slurm* LOGS
cp -af ../WPS/namelist.wps LOGS
gzip -c2 ../WPS/metgrid.log.0000 > LOGS/metgrid.log.0000.gz
ls -al ../WPS > LOGS/ls_wps.log

# Make sure geo_em and met_em data are linked.
echo "Link WPS geo_em.d??.nc and met_em.d* files."
ln -sf ../WPS/geo_em.d??.nc .
ln -sf ../WPS/met_em.d* .

# Run the application  - please add hash in front of srun and remove 
# hash in front of mpirun if using intel-toolchain 
mpirun ./real.exe >& my_real.log
# For OpenMPI (foss and iomkl toolchains), srun is recommended:
#time srun MySoftWare-exec

## For IntelMPI (intel toolchain), mpirun is recommended:
#time mpirun MySoftWare-exec

# Backup real.exe logs
mkdir -p LOGS
cp -af namelist.input LOGS/namelist.input.real.$(date -r namelist.input "+%Y%m%d-%H%M")
cp -af rsl.error.0000 LOGS/rsl.error.0000.real.$(date -r rsl.error.0000 "+%Y%m%d-%H%M")
ls -al > LOGS/ls_real.log.$(date "+%Y%m%d-%H%M")


#########################################################
# That was about all this time; lets call it a day...
##-------------------------------------------------------
# Finish the script
exit 0
