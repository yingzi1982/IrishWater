#!/bin/bash
module load gmt

rm -f gmt.conf
rm -f gmt.history

gmt gmtset MAP_FRAME_AXES WeSn
gmt gmtset MAP_FRAME_TYPE plain
#gmt gmtset MAP_FRAME_PEN thick
#gmt gmtset MAP_TICK_PEN thick
#gmt gmtset MAP_TICK_LENGTH_PRIMARY -3p
#gmt gmtset MAP_DEGREE_SYMBOL none
#gmt gmtset MAP_GRID_CROSS_SIZE_PRIMARY 0.0i
#gmt gmtset MAP_GRID_CROSS_SIZE_SECONDARY 0.0i
#gmt gmtset MAP_GRID_PEN_PRIMARY thin,black
#gmt gmtset MAP_GRID_PEN_SECONDARY thin,black
gmt gmtset MAP_ORIGIN_X 100p
gmt gmtset MAP_ORIGIN_Y 100p
#gmt gmtset FORMAT_GEO_OUT +D
gmt gmtset COLOR_NAN 255/255/255
gmt gmtset COLOR_FOREGROUND 255/255/255
gmt gmtset COLOR_BACKGROUND 0/0/0
gmt gmtset FONT 12p,Helvetica,black
#gmt gmtset PS_MEDIA custom_2.8ix2.8i
gmt gmtset PS_MEDIA letter
gmt gmtset PS_PAGE_ORIENTATION portrait
gmt gmtset DIR_GSHHG /ichec/work/nuig02/yingzi/geological_data/gshhg-gmt-2.3.7/
#gmt gmtset GMT_VERBOSE d

figfolder=../figures/
backupfolder=../backup/
#----------------------------
width=1.2
height=2.2
projection=X$width\i/-$height\i

name=c_in_depth_interp
xyz=$backupfolder$name
ps=$figfolder$name.ps
pdf=$figfolder$name.pdf

xmin=`gmt gmtinfo $xyz -C | awk '{print $1/1000}'`
xmax=`gmt gmtinfo $xyz -C | awk '{print $2/1000}'`
ymin=`gmt gmtinfo $xyz -C | awk '{print $3}'`
ymax=`gmt gmtinfo $xyz -C | awk '{print $4}'`
region=$ymin/$ymax/$xmin/$xmax
#region=1492/$ymax/0/$xmax
awk '{print $2, $1/1000}' $xyz | gmt psxy -J$projection -R$region -Bxa8f4+l"C\ \(m/s\)" -Bya1f0.5+l"Depth (km)" -Wthin,black -K > $ps
name=c_in_depth
xyz=$backupfolder$name
awk '{print $2, $1/1000}' $xyz | gmt psxy -J -R -Sc0.01i -N -Gred -W -O >> $ps

gmt psconvert -A -Tf $ps -D$figfolder

rm -f $ps
#----------------------------

rm -f gmt.conf
rm -f gmt.history
