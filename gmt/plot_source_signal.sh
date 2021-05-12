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
gmt gmtset PS_CHAR_ENCODING Symbol

backupfolder=../backup/
figfolder=../figures/
mkdir -p $figfolder

backupfolder=../backup/
figfolder=../figures/
mkdir -p $figfolder

ps=$figfolder\sourceSignal.ps
pdf=$figfolder\sourceSignal.pdf


name=sourceTimeFunction
originalxy=$backupfolder$name

xmin=`gmt gmtinfo $originalxy -C | awk '{print $1}'`
xmax=`gmt gmtinfo $originalxy -C | awk '{print $2}'`
ymin=`gmt gmtinfo $originalxy -C | awk '{print $3}'`
ymax=`gmt gmtinfo $originalxy -C | awk '{print $4}'`
#xmax=3

normalization=`echo $ymin $ymax | awk ' { if(sqrt($1^2)>(sqrt($2^2))) {print sqrt($1^2)} else {print sqrt($2^2)}}'`
echo max pressure=$normalization Pa
timeDuration=`echo "(($xmax)-($xmin))" | bc -l`
region=0/$timeDuration/-$normalization/$normalization
projection=X2.2i/0.6i

awk -v xmin="$xmin" '{print $1-xmin, $2}' $originalxy | gmt psxy -J$projection -R$region -Bxa0.2f0.1+l"Time (s)" -Bya3e6f1.5e6+l"Pa" -Wthin,black -K > $ps
#------------------------

name=sourceFrequencySpetrum
originalxy=$backupfolder$name

xmin=1
xmax=300
#ymin=`gmt gmtinfo $originalxy -C | awk '{print $3}'`
ymin=150
ymax=`gmt gmtinfo $originalxy -C | awk '{print $4+5}'`

echo max pressure level =$normalization dB

region=$xmin/$xmax/$ymin/$ymax
projection=X2.2il/0.6i
offset=1.23i

awk '{print $1, $2}' $originalxy | gmt psxy -J$projection -R$region -Bxa20f10+l"Frequency (Hz)" -Bya20f10+l"dB/Hz" -Wthin,black -Y$offset -O >> $ps

gmt psconvert -A -Tf $ps -D$figfolder
rm -f $ps

rm -f gmt.conf
rm -f gmt.history
module unload gmt
