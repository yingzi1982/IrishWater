#!/bin/bash
module load gmt
rm -f gmt.conf
rm -f gmt.history

gmt gmtset MAP_FRAME_AXES WeSn
gmt gmtset MAP_FRAME_TYPE plain
gmt gmtset MAP_FRAME_PEN thick
gmt gmtset MAP_TICK_PEN thick
gmt gmtset MAP_TICK_LENGTH_PRIMARY -3p
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
#gmtset MAP_ANNOT_ORTHO snew
gmt gmtset FONT 9p,Times-Roman,black
#gmt gmtset PS_MEDIA custom_2.8ix2.8i
gmt gmtset PS_MEDIA letter   
gmt gmtset PS_PAGE_ORIENTATION portrait
#gmt gmtset GMT_VERBOSE d

backupfolder=../backup/
figfolder=../figures/
mkdir -p $figfolder

#name=ARRAY.S1.CXP.semp
name=$1

ps=$figfolder$name.ps
pdf=$figfolder$name.pdf


originalxy=$backupfolder/$name

xmin=`gmt gmtinfo $originalxy -C | awk '{printf "%10.5f", $1}'`
xmax=`gmt gmtinfo $originalxy -C | awk '{printf "%10.5f", $2}'`
ymin=`gmt gmtinfo $originalxy -C | awk '{printf "%10.5f", $3}'`
ymax=`gmt gmtinfo $originalxy -C | awk '{printf "%10.5f", $4}'`

normalization=`echo $ymin $ymax | awk ' { if(sqrt($1^2)>(sqrt($2^2))) {print sqrt($1^2)} else {print sqrt($2^2)}}'|  awk '{printf "%d", $1}'`

timeDuration=`echo "(($xmax)-($xmin))" | bc -l`
#region=$xmin/$xmax/-1/1
region=0/$timeDuration/-1/1
#region=0/1/-1/1
projection=X2.2i/0.6i

resampling=1

awk -v xmin="$xmin" -v resampling="$resampling" -v normalization="$normalization" 'NR%resampling==0 {print $1-xmin, $2/normalization}' $originalxy | gmt psxy -J$projection -R$region -Bxa0.5f.25+l"Time (s)" -Bya1f0.5+l"A. (x$normalization Pa)" -Wthin,black > $ps


rm -f $grd $cpt 

gmt psconvert -A -Tf $ps -D$figfolder
rm -f $ps

rm -f gmt.conf
rm -f gmt.history
module unload gmt
