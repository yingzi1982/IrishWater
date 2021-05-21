#!/bin/bash
source /usr/share/modules/init/bash
module load apps gmt
rm gmt.conf
rm gmt.history

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

runningName=$1
traceImageName=$2
backupfolder=../running/$runningName/backup/
figfolder=../figures/$runningName/
traceImageFile=$backupfolder$traceImageName
mkdir -p $figfolder

#-----------------------------------------------------
ps=$figfolder$traceImageName.ps
eps=$figfolder$traceImageName.eps
pdf=$figfolder$traceImageName.pdf

#xmin=`gmt gmtinfo $traceImageFile -C | awk '{print $1}'`
#xmax=`gmt gmtinfo $traceImageFile -C | awk '{print $2}'`
xmin=-90
xmax=90
ymin=`gmt gmtinfo $traceImageFile -C | awk '{print $3}'`
ymax=`gmt gmtinfo $traceImageFile -C | awk '{print $4}'`
nx=200
ny=300
xinc=`echo "($xmax-($xmin))/$nx" | bc -l`
yinc=`echo "($ymax-($ymin))/$ny" | bc -l`

zmin=-3
zmax=0
zinc=`echo "($zmax-($zmin))/50" | bc -l`
cpt=$backupfolder$runningName.cpt
gmt makecpt -Chot.cpt -T$zmin/$zmax/$zinc -Z -Iz > $cpt
domain=1.1i/-0.4i/1.2i/0.16ih

grd=$backupfolder$runningName.nc

projection=X1.8i/2.2i
region=$xmin/$xmax/$ymin/$ymax

cat $traceImageFile | awk '{print $1,$2,log($3)}' | gmt blockmean -R$region -I$xinc/$yinc | gmt surface -R$region -I$xinc/$yinc -G$grd
#cat $traceImageFile | awk '{print $1,$2,$3}' | gmt blockmean -R$region -I$xinc/$yinc | gmt surface -R$region -I$xinc/$yinc -G$grd
gmt grdimage -R$region -J$projection  -Bxa45f22.5+l"Angle (deg) " -Bya0.04f0.02+l"Time (s)" $grd -C$cpt > $ps

gmt ps2raster -A -Te $ps -D$figfolder
epstopdf --outfile=$pdf $eps
rm -f $ps $eps $cpt
rm -f $figfolder\ps2raster_*bb

