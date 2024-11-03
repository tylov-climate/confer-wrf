# confer-wrf

This folder contains scripts to run Fram WRF simulations for the CONFER project.

```bash
tlauto_run.bash YYYY-MM-DD MONTHS [download [force]]
```
This will create all neccesary files and submit the jobs needed for the complete simulation.
If the input files are not yet downloaded it will download them for the given year YYYY.
It is possible to download all files from the year given up to last year by giving "download" as the 3rd argument.
The script will only do the downloads in that case and stop.

MM and DD are the initialization month and date. It will process MONTHS months, i.e. until the last day of the final month.
E.g. `tlauto_run.bash 1991-02-10 6` will run 1991-02-10 to 1991-07-31 inclusive.

There will be created a 6 

Run-folder:
```
rundir: /cluster/work/users/${USER}/MAM_CFSv2_downscaling/MAM_${YYYY}${MM}${DD}00  # $USER is username

outdir: /nird/projects/NS9853K/users/tylo/CFSv2_downscaled_wrfout/MAM-WRFOUT/MAM_${YYYY}${MM}${DD}00 
```
