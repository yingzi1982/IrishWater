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

for type in so thetao c
do

sr_file=$backupfolder/sr

name=$type\_on_surface

if [ "$type" == "so" ]; then
psscale_label=Salinity\ \(PSU\)
psscale_tick=a2f1
elif [ "$type" == "thetao" ]; then
psscale_label=Temp.\ \(@.C\)
psscale_tick=a2f1
elif [ "$type" == "c" ]; then
psscale_label=C\ \(m/s\)
psscale_tick=a15f7.5
fi

width=2.2 #inch
inc=5m

xyz=$backupfolder$name
grd=$backupfolder$name.nc
cpt=$backupfolder$name.cpt
ps=$figfolder$name.ps
pdf=$figfolder$name.pdf

xmin=`gmt gmtinfo $xyz -C | awk '{print $1}'`
xmax=`gmt gmtinfo $xyz -C | awk '{print $2}'`
ymin=`gmt gmtinfo $xyz -C | awk '{print $3}'`
ymax=`gmt gmtinfo $xyz -C | awk '{print $4}'`
zmin=`gmt gmtinfo $xyz -C | awk '{print $5}'`
zmax=`gmt gmtinfo $xyz -C | awk '{print $6}'`
region=$xmin/$xmax/$ymin/$ymax
#echo $type: 'zmin=' $zmin 'zmax=' $zmax

cat $xyz | gmt blockmean -R${region} -I${inc} | gmt surface -R${region} -I${inc} -Ll$zmin -Lu$zmax -G$grd

gmt makecpt -CGMT_seis.cpt -Iz -T$zmin/$zmax -Z > $cpt

gmt grdimage -R -E150 -JM$width\i $grd -C$cpt -Bxa4f2+l"Longitude (deg)" -Bya3f1.5+l"Latitude (deg)" -K > $ps #  Bya2fg2
gmt pscoast -R -J -Di -Wthinner -Ggray -O -K >> $ps

#cat $sub_polygon_file | gmt psxy -R -J -W1p,red -O -K >> $ps #-G-red -G+red 
cat $sr_file | gmt psxy -R -J -Sa0.05i -Gred  -N -Wthinner,black -O -K >> $ps

colorbar_width=`echo "$width*1/2" | bc -l`
colorbar_height=0.1
colorbar_vertical_offset=0
colorbar_horizontal_offset=`echo "($width/2)-($colorbar_width/2)" | bc -l`
gmt psscale -DjCB+w$colorbar_width\i/$colorbar_height\i+o$colorbar_horizontal_offset\i/$colorbar_vertical_offset\i+h -Bx$psscale_tick+l"$psscale_label" -C$cpt -R -J -O >> $ps

gmt psconvert -A -Tf $ps -D$figfolder

rm -f $cpt
rm -f $grd
rm -f $ps
#----------------------------
width=1.2
height=2.2
projection=X$width\i/-$height\i

name=$type\_in_depth_interp
xyz=$backupfolder$name
ps=$figfolder$name.ps
pdf=$figfolder$name.pdf

if [ "$type" == "so" ]; then
x_label=Salinity\ \(PSU\)
x_tick=a.5f0.25
elif [ "$type" == "thetao" ]; then
x_label=Temp.\ \(@.C\)
x_tick=a4f2
elif [ "$type" == "c" ]; then
x_label=C\ \(m/s\)
x_tick=a8f4
fi

xmin=`gmt gmtinfo $xyz -C | awk '{print $1/1000}'`
xmax=`gmt gmtinfo $xyz -C | awk '{print $2/1000}'`
ymin=`gmt gmtinfo $xyz -C | awk '{print $3}'`
ymax=`gmt gmtinfo $xyz -C | awk '{print $4}'`
region=$ymin/$ymax/0/$xmax

awk '{print $2, $1/1000}' $xyz | gmt psxy -J$projection -R$region -Bx$x_tick+l"$x_label" -Bya1f0.5+l"Depth (km)" -Wthin,black -K > $ps
awk '{print $2, $1/1000}' $xyz | gmt psxy -J -R -Sc0.01i -N -Gred -W -O >> $ps
gmt psconvert -A -Tf $ps -D$figfolder

rm -f $ps
done
#----------------------------

rm -f gmt.conf
rm -f gmt.history
