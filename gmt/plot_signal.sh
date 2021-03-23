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

tmin=`gmt gmtinfo $originalxy -C | awk '{print $1}'`
tmax=`gmt gmtinfo $originalxy -C | awk '{print $2}'`
ymin=`gmt gmtinfo $originalxy -C | awk '{print $3}'`
ymax=`gmt gmtinfo $originalxy -C | awk '{print $4}'`

normalization=`echo $ymin $ymax | awk ' { if(sqrt($1^2)>(sqrt($2^2))) {print sqrt($1^2)} else {print sqrt($2^2)}}'`
timeDuration=`echo "(($tmax)-($tmin))" | bc -l`
region=0/$timeDuration/-1/1
projection=X2.2i/0.6i

resample_rate=10
awk  -v resample_rate="$resample_rate" -v  tmin="$tmin" -v normalization="$normalization" '(NR)%resample_rate==0{print $1-tmin, $2/normalization}' $originalxy | gmt psxy -J$projection -R$region -Bxa5f2.5+l"Time (s)" -Bya1f0.5 -Wthin,black -K > $ps

#------------------------
fmin=0
fmax=2000
width=2.2
height=0.8
projection=X$width\i/$height\i
offset=0.8i
gmt gmtset MAP_FRAME_AXES Wesn
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


gmt grdimage -R -J$projection $grd -C$cpt -Bxa5f2.5+l"Time (s)" -Bya500f250+l"Frequency (Hz)" -Y$offset -O -K >> $ps #  Bya2fg2


colorbar_width=$height
colorbar_height=0.16
colorbar_horizontal_position=`echo "$width+0.1" | bc -l`
colorbar_vertical_position=`echo "$colorbar_width/2" | bc -l`
domain=$colorbar_horizontal_position\i/$colorbar_vertical_position\i/$colorbar_width\i/$colorbar_height\i
gmt psscale -D$domain -C$cpt -Bxa10f5+l"(dB/Hz)" -By -O -K >> $ps

rm -f $cpt $grd
#------------------------
fmax=500

projection=X2.2i/0.6i
originalxy=$backupfolder$name\_spectrum

normalization=`gmt gmtinfo $originalxy -C | awk '{print $4}'`

ymin=0
ymax=1

region=$fmin/$fmax/$ymin/$ymax
#projection=X2.2i/0.6i
offset=1.5i

gmt gmtset MAP_FRAME_AXES Sn
gmt gmtset MAP_GRID_PEN_PRIMARY thinnest,-
gmt psbasemap -J$projection -R$region -Bxa100f50g50+l"Frequency (Hz)" -By -Y$offset -O  -K >> $ps

color=red
gmt gmtset MAP_FRAME_AXES W
gmt gmtset FONT 12p,Helvetica,$color
resample_rate=1
awk  -v resample_rate="$resample_rate" -v normalization="$normalization" '(NR)%resample_rate==0 {print $1, $2/normalization}' $originalxy | gmt psxy -J -R -Bx -Bya1f0.5 -Wthin,$color -O  -K >> $ps

color=blue
gmt gmtset MAP_FRAME_AXES E
gmt gmtset FONT 12p,Helvetica,$color

ymin=-80
ymax=0
region=$fmin/$fmax/$ymin/$ymax
normalization=`gmt gmtinfo $originalxy -C | awk '{print $6}'`

resample_rate=1
awk  -v resample_rate="$resample_rate" -v normalization="$normalization" '(NR)%resample_rate==0 {print $1, $3-normalization}' $originalxy | gmt psxy -J -R$region -Bx -Bya40f20+l"(dB/Hz)" -Wthin,$color -O -K >> $ps

#------------------------
projection=X2.2i/0.6i
gmt gmtset MAP_FRAME_AXES Wesn
gmt gmtset FONT 12p,Helvetica,black

ymin=0
ymax=100

region=$fmin/$fmax/$ymin/$ymax
offset=0.8i

resample_rate=10

awk -v resample_rate="$resample_rate" '(NR)%resample_rate==0 {print $1, $4*100}' $originalxy | gmt psxy -J$projection -R$region  -Bxa100f50g50+l"Frequency (Hz)" -Bya20f10g10+l"(%)" -Wthin,black -Y$offset -O >> $ps

gmt psconvert -A -Tf $ps -D$figfolder
rm -f $ps

rm -f gmt.conf
rm -f gmt.history
module unload gmt
