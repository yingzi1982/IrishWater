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
#gmt gmtset FONT 9p,Times-Roman,black
#gmt gmtset PS_MEDIA custom_2.8ix2.8i
gmt gmtset PS_MEDIA letter
gmt gmtset PS_PAGE_ORIENTATION portrait
#gmt gmtset GMT_VERBOSE d

backupfolder=../backup/
figfolder=../figures/
mkdir -p $figfolder

#-----------------------------------------------------
name=airgun_array_deployment

xyz=$backupfolder$name

ps=$figfolder/$name.ps
pdf=$figfolder/$name.pdf

xmin=`gmt gmtinfo $xyz -C | awk '{print $1}'`
xmax=`gmt gmtinfo $xyz -C | awk '{print $2}'`
ymin=`gmt gmtinfo $xyz -C | awk '{print $3}'`
ymax=`gmt gmtinfo $xyz -C | awk '{print $4}'`

offset=5
xmin=`echo "$xmin-$offset"| bc -l`
xmax=`echo "$xmax+$offset"| bc -l`
ymin=`echo "$ymin-$offset"| bc -l`
ymax=`echo "$ymax+$offset"| bc -l`

region=$xmin/$xmax/$ymin/$ymax
width=2.2
height=`echo "$width*(($ymax)-($ymin))/(($xmax)-($xmin))" | bc -l`
projection=X$width\i/$height\i

gmt psbasemap -R$region -J$projection -Bxa5.0f2.5+l"Easting (km) " -Bya5.0f2.5+l"Northing (km)" -K > $ps

awk '{ print $1, $2}' $xyz   | gmt psxy -R -J -Sc0.05i -Gred  -N -Wthinner,black -O >> $ps
#-------------------------------------

gmt psconvert -A -Tf $ps -D$figfolder
rm -f $ps

rm -f gmt.conf
rm -f gmt.history
module unload gmt
