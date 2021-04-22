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
name=mesh_slice_sound_speed
sr=$backupfolder\output_list_sources.txt
rc=$backupfolder\output_list_stations.txt
sr=`awk '{ print 0, $3/1000 }' $sr`
rc=`awk 'NR<=1{ print sqrt(($3/1000)^2+($4/1000)^2), $5/1000 }' $rc`


xyz=$backupfolder$name
grd=$backupfolder$name.nc
cpt=$backupfolder$name\.cpt
meshInformationFile=../backup/meshInformation

ps=$figfolder$name.ps
pdf=$figfolder$name.pdf

xmin=`grep xmin ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
xmax=`grep xmax ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
dx=`grep dx ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
zmin=`grep zmin ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
zmax=`grep zmax ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
dz=`grep dz ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`

rmin=`cat $xyz | awk '{print $3}' | gmt gmtinfo -C | awk '{print $1/1000}'`
rmax=`cat $xyz | awk '{print $3}' | gmt gmtinfo -C | awk '{print $2/1000}'`
range=`echo "($rmax - $rmin)" | bc -l`
dr=`echo "$dx * $range/($xmax - $xmin)" | bc -l`
inc=$dr/$dz

region=$rmin/$rmax/$zmin/$zmax

#cmin=`cat $xyz | awk '{if($5 < 1550) print $5}'| gmt gmtinfo -C | awk '{print $1}'`
#cmax=`cat $xyz | awk '{if($5 < 1550) print $5}'| gmt gmtinfo -C | awk '{print $2}'`
cmin=1490
cmax=1510

width=2.2

awk '{print $3/1000, $4/1000, $5}' $xyz  | gmt blockmean -R${region} -I${inc} | gmt surface -R${region} -I${inc} -Ll$cmin -Lu$cmax -G$grd

gmt makecpt -CGMT_seis.cpt -Iz -T$cmin/$cmax -Z > $cpt

height=`echo "($zmax - $zmin)/$range*$width" | bc -l`

projection=X-$width\i/$height\i

gmt psbasemap -R$region -J$projection -Bxa2.0f1.+l"Range (km) " -Bya2.0f1.0+l"Elevation (km)" -K > $ps

#cat ../backup/water_polygon | awk '{ print $1/1000,$2/1000}' | gmt psclip -R -J -B -O -K >> $ps
gmt grdimage -R -J -B $grd -C$cpt -O -K >> $ps
#gmt psclip  -R -J -B -C -O -K >> $ps
cat ../backup/sediment_polygon | awk '{ print $1/1000,$2/1000}' | gmt psxy -R -J -Ggray80 -W1p,black -O -K >> $ps #-G-red -G+red 
cat ../backup/rock_polygon | awk '{ print $1/1000,$2/1000}' | gmt psxy -R -J -Ggray60 -W1p,black -O -K >> $ps #-G-red -G+red 
echo $sr | gmt psxy -R -J -Sa0.05i -Gred  -N -Wthinner,black -O -K >> $ps
echo $rc | gmt psxy -R -J -St0.05i -Gyellow  -N -Wthinner,black -O -K >> $ps

colorbar_width=$height
colorbar_height=0.16
colorbar_horizontal_position=`echo "$width+0.1" | bc -l` colorbar_vertical_position=`echo "$colorbar_width/2" | bc -l`
domain=$colorbar_horizontal_position\i/$colorbar_vertical_position\i/$colorbar_width\i/$colorbar_height\i
gmt psscale -D$domain -C$cpt -Bxa5f2.5+l"C (m/s)" -By -O >> $ps

gmt psconvert -A -Tf $ps -D$figfolder
rm -f $ps
rm -f $grd $cpt
rm -f gmt.conf
rm -f gmt.history
module unload gmt
