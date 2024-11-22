#!/bin/bash
if [ "$1" != "-f" ]; then
    echo Usage $0 -f
    exit 1
fi

rm -f ../WPS/met_em.d*
rm -f ../WPS/metgrid.log.????
rm -f ../WPS/GRIBFILE.*
rm -f ../WPS/PLEV*
rm -f ../WPS/SFLX*

rm -f rsl.*
rm -f met_em.d*
rm -f wrfbdy_d01
rm -f wrffdda_d01
rm -f wrfrst_d*
rm -f wrfinput_d*
rm -f wrflowinp_d*
rm -f wrfdaily_d*
rm -f wrfpress_d*
rm -f wrfhydro_hourly_d*
