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
name=deployment

sourcesFile=$backupfolder\output_list_sources.txt
receiversFile=$backupfolder\output_list_stations.txt
meshInformationFile=../backup/meshInformation

ps=$figfolder$name.ps
pdf=$figfolder$name.pdf

xmin=`grep xmin ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
xmax=`grep xmax ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
zmin=`grep zmin ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
zmax=`grep zmax ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`

width=2.2
height=`echo "$width*(($zmax)-($zmin))/(($xmax)-($xmin))" | bc -l`
projection=X$width\i/$height\i

region=$xmin/$xmax/$zmin/$zmax

gmt psbasemap -R$region -J$projection  -Bxa2f1+l"Easting (km) " -Bya1f0.5+l"Elevation (km)" -K > $ps
cat ../backup/water_polygon | awk '{ print $1/1000,$2/1000}' | gmt psxy -R -J -Gcyan -W1p,black -O -K >> $ps #-G-red -G+red 
cat ../backup/sediment_polygon | awk '{ print $1/1000,$2/1000}' | gmt psxy -R -J -Gyellow -W1p,black -O -K >> $ps #-G-red -G+red 
awk '{ print $3/1000, $5/1000 }' $receiversFile | gmt psxy -R -J -Sc0.03i -Gyellow -N -Wthinner,black -O -K >> $ps
awk '{ print $1/1000, $3/1000 }' $sourcesFile   | gmt psxy -R -J -Sa0.05i -Gred  -N -Wthinner,black -O >> $ps


gmt psconvert -A -Tf $ps -D$figfolder
rm -f $ps

rm -f gmt.conf
rm -f gmt.history
module unload gmt
