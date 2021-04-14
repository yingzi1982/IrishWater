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
name=water_sediment_interface

xyz=$backupfolder$name
sr=$backupfolder\output_list_sources.txt
rc=$backupfolder\output_list_stations.txt

ps=$figfolder/deployment.ps
pdf=$figfolder/deployment.pdf

xmin=`grep xmin ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
xmax=`grep xmax ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
dx=`grep dx ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
ymin=`grep ymin ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
ymax=`grep ymax ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
dy=`grep dy ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`

zmin=`gmt gmtinfo $xyz -C | awk '{print $5}'`
zmax=`gmt gmtinfo $xyz -C | awk '{print $6}'`
#echo $zmin $zmax

grd=$backupfolder$name.nc
grad=$backupfolder$name.int.nc
grdcontour=$backupfolder\grdcontour

cpt=$backupfolder$name.cpt

region=$xmin/$xmax/$ymin/$ymax
inc=$dx/$dy
width=2.2
height=`echo "$width*(($ymax)-($ymin))/(($xmax)-($xmin))" | bc -l`
projection=X$width\i/$height\i

cat $xyz | awk '{print $1/1000, $2/1000, $3}' | gmt blockmean -R$region -I$inc | gmt surface -R$region -I$inc -G$grd
gmt grd2cpt $grd -CGMT_rainbow.cpt -L-1880/-1779 -E100 > $cpt
#gmt makecpt -Crainbow -T-1880/-1779/10 > $cpt

gmt psbasemap -R$region -J$projection -Bxa2.0f1.0+l"Easting (km) " -Bya1.0f0.5+l"Northing (km)" -K > $ps

#gmt grdgradient $grd -A15 -Ne0.75 -G$grad
#gmt grdimage -R -J  -B $grd -I$grad -C$cpt -O -K >> $ps
gmt grdimage -R -J  -B $grd -C$cpt -O -K >> $ps
gmt grdcontour $grd -R -J -C20 -A40+f8p+u" m" -Gd1.5i -O -K > $grdcontour
cat $grdcontour >> $ps
sr=`awk '{ print $1/1000, $2/1000 }' $sr`
rc=`awk 'NR<=1{ print $3/1000, $4/1000 }' $rc`
echo -e "$sr \n $rc" | gmt psxy -R -J  -N -Wthinner,black,.- -O -K >> $ps
cat ../backup/pml_edge | gmt psxy -R -J -Sc0.05i -Gred  -N -Wthinner,black -O -K >> $ps
echo $sr   | gmt psxy -R -J -Sa0.05i -Gred  -N -Wthinner,black -O -K >> $ps
echo $rc   | gmt psxy -R -J -St0.05i -Gyellow  -N -Wthinner,black -O >> $ps
rm -f $grd $grad
#-------------------------------------

#colorbar_width=$height
#colorbar_height=0.16
#$colorbar_horizontal_position=`echo "$width+0.1" | bc -l`
#colorbar_vertical_position=`echo "$colorbar_width/2" | bc -l`
#domain=$colorbar_horizontal_position\i/$colorbar_vertical_position\i/$colorbar_width\i/$colorbar_height\i
#gmt psscale -D$domain -C$cpt -Bxa20f10+l"Elevation (m)" -By -O >> $ps
rm -f $cpt

gmt psconvert -A -Tf $ps -D$figfolder
rm -f $ps

rm -f gmt.conf
rm -f gmt.history
module unload gmt
