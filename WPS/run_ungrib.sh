#!/bin/bash

###############################################
# Script example for a normal MPI job on Fram #
###############################################

## Project: replace XXXX with your project ID
#SBATCH --account=nn9853k 

## Job name:
#SBATCH --job-name=ungrYYYY

## Allocating amount of resources:
##SBATCH --nodes=1
## Number of tasks (aka processes) to start on each node: Pure mpi, one task per core
##SBATCH --ntasks-per-node=1
#SBATCH --nodes=1 --ntasks-per-node=1

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

 module load WPS/4.4-foss-2022a-dmpar
 

###############################################
# link boundary pressure level data and run ungrib
###############################################
 echo "Ungrib PLEV"
 sed -i "s|prefix[= ]*'SFLX'|prefix = 'PLEV'|" namelist.wps
./link_grib.csh $rundir/CFS/pgb*.grb2
 #ln -sf /cluster/home/titikekb/masterwrf/WPS/ungrib/Variable_Tables/Vtable.CFSR_press_pgbh06 Vtable
 # Downloaded from https://github.com/yyr/wps/blob/master/ungrib/Variable_Tables/
 ln -sf ./Variable_Tables/Vtable.CFSR_press_pgbh06 Vtable
 #srun -n 1 ./ungrib.exe >& my_ungrib_pressure.log
 ./ungrib.exe >& my_ungrib_pressure.log

###############################################
# link boundary surface level data and run ungrib
###############################################
 echo "Ungrib SFLX"
 sed -i "s|prefix[= ]*'PLEV'|prefix = 'SFLX'|" namelist.wps
 ./link_grib.csh $rundir/CFS/flx*.grb2
 #ln -sf /cluster/home/titikekb/masterwrf/WPS/ungrib/Variable_Tables/Vtable.CFSR_sfc_flxf06 Vtable
 # Downloaded from https://github.com/yyr/wps/blob/master/ungrib/Variable_Tables/
 ln -sf ./Variable_Tables/Vtable.CFSR_sfc_flxf06 Vtable
 #srun -n 1 ./ungrib.exe >& my_ungrib_surface.log
 ./ungrib.exe >& my_ungrib_surface.log

###############################################
# interpolate SFC temperature over lake
# modis_lakes daily average temp
###############################################
 echo "interpolate SFC temperature over lake"
 #srun -n 1 ./util/avg_tsfc.exe >& my_tsfc.log
 ./util/avg_tsfc.exe >& my_tsfc.log

# clean up
#rm -fr GRIBFILE*
exit 0