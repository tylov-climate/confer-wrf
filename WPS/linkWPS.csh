#!/bin/csh -f

set wps = /cluster/software/WPS/4.4-foss-2022a-dmpar/WPS-4.4

cp $wps/link_grib.csh .
ln -sf $wps/geogrid .
ln -sf $wps/metgrid .
ln -sf $wps/ungrib .
ln -sf $wps/util .
ln -sf ./ungrib/ungrib.exe .
ln -sf ./geogrid/geogrid.exe .
ln -sf ./geogrid/GEOGRID.TBL.ARW GEOGRID.TBL
ln -sf ./metgrid/metgrid.exe .
ln -sf ./metgrid/METGRID.TBL.ARW METGRID.TBL
