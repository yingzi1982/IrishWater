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

name=$1

ps=$figfolder$name.ps
pdf=$figfolder$name.pdf


originalxy=$backupfolder$name

ymin=`gmt gmtinfo $originalxy -C | awk '{print $3}'`
ymax=`gmt gmtinfo $originalxy -C | awk '{print $4}'`
tmin=`gmt gmtinfo $originalxy -C | awk '{print $1}'`
tmax=`gmt gmtinfo $originalxy -C | awk '{print $2}'`

if  [ $name == 'specfem_hydrophone_signal' ]
then
tmin=3.3
fi

normalization=`echo $ymax | awk '{printf "%.1e", $1}'`
#timeDuration=`echo "(($tmax)-($tmin))" | bc -l`
timeDuration=6
tmax=`echo "$tmin+$timeDuration" | bc -l`

region=$tmin/$tmax/-1/1
projection=X2.2i/0.6i

resample_rate=10

gmt gmtset MAP_FRAME_AXES WSn
awk  -v resample_rate="$resample_rate" -v  tmin="$tmin" -v normalization="$normalization" '(NR)%resample_rate==0{print $1, $2/normalization}' $originalxy | gmt psxy -J$projection -R$region -Bxa2f1+l"Time (s)" -Bya1f0.5+l"Amp. (x$normalization Pa)" -Wthin,$color -K > $ps

color=red
gmt gmtset MAP_FRAME_AXES E
gmt gmtset FONT 12p,Helvetica,$color

region=$tmin/$tmax/0/100
awk  -v resample_rate="$resample_rate" -v  tmin="$tmin" -v normalization="$normalization" '(NR)%resample_rate==0{print $1, $3*100}' $originalxy | gmt psxy -J$projection -R$region -Bx -Bya50f25+l"(%)" -Wthin,$color -O -K >> $ps

#------------------------
fmin=0
fmax=2000
width=2.2
height=0.8
projection=X$width\i/$height\i
offset=0.8i
gmt gmtset MAP_FRAME_AXES Wesn
gmt gmtset FONT 12p,Helvetica,black
originalxyz=$backupfolder$name\_spectrogram
cpt=$backupfolder$name.cpt
grd=$backupfolder$name.nc

nt=400
nf=300
tinc=`echo "($tmax-($tmin))/$nt" | bc -l`
finc=`echo "($fmax-($fmin))/$nf" | bc -l`
region=$tmin/$tmax/$fmin/$fmax

normalization=`gmt gmtinfo $originalxyz -C | awk '{print $6}'`

cat $originalxyz | awk -v normalization="$normalization" '{ print $1, $2, $3-normalization}' | blockmean -R$region -I$tinc/$finc | gmt blockmode -R$region -I$tinc/$finc | gmt surface -R$region -I$tinc/$finc -G$grd

gmt grd2cpt $grd -CGMT_rainbow.cpt -L-80/-39 -E100 > $cpt


gmt grdimage -R -J$projection $grd -C$cpt -Bxa2f1+l"Time (s)" -Bya500f250+l"Frequency (Hz)" -Y$offset -O -K >> $ps #  Bya2fg2


colorbar_width=$height
colorbar_height=0.16
colorbar_horizontal_position=`echo "$width+0.1" | bc -l`
colorbar_vertical_position=`echo "$colorbar_width/2" | bc -l`
domain=$colorbar_horizontal_position\i/$colorbar_vertical_position\i/$colorbar_width\i/$colorbar_height\i
gmt psscale -D$domain -C$cpt -Bxa10f5+l"(dB/Hz)" -By -O -K >> $ps

rm -f $cpt $grd
#------------------------
gmt gmtset MAP_FRAME_AXES WSn

projection=X2.2il/0.6i
originalxy=$backupfolder$name\_spectrum

xmin=1
xmax=300
ymin=`awk -v xmin="$xmin" -v xmax="$xmax" '$1>=xmin&&$1<=xmax {print}' $originalxy | gmt gmtinfo -C | awk '{print $3-10}'`
ymax=`awk -v xmin="$xmin" -v xmax="$xmax" '$1>=xmin&&$1<=xmax {print}' $originalxy | gmt gmtinfo -C | awk '{print $4+10}'`

region=$xmin/$xmax/$ymin/$ymax
offset=1.5i

resample_rate=1
awk '{print $1, $2}' $originalxy | gmt psxy -J$projection -R$region -Bxa100f50+l"Frequency (Hz)" -Bya40f20+l"SPL (dB/Hz)" -Wthin,black -Y$offset -O -K >> $ps

awk '{print $1, $2}' $backupfolder$name\_octavePSD | gmt psxy -J -R -B -Sc0.1 -Ggray -Wthinner,black -O -K >> $ps


color=red
gmt gmtset MAP_FRAME_AXES E
gmt gmtset FONT 12p,Helvetica,$color

region=$xmin/$xmax/0/100
awk  -v resample_rate="$resample_rate" '(NR)%resample_rate==0{print $1, $3*100}' $originalxy | gmt psxy -J$projection -R$region -Bx -Bya50f25+l"(%)" -Wthin,$color -O >> $ps


gmt psconvert -A -Tf $ps -D$figfolder
rm -f $ps

rm -f gmt.conf
rm -f gmt.history
module unload gmt
