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

xmin=-20
xmax=-4
ymin=48
ymax=58

region=$xmin/$xmax/$ymin/$ymax

width=2.2 #inch
UTM_ZONE=28
projection=u$UTM_ZONE/1:1

figfolder=../figures/
backupfolder=../backup/

#--------------------------------
name=topo
xyz=$backupfolder$name.xyz
originalgrd=/ichec/work/nuig02/yingzi/geological_data/GEBCO/gebco_08.nc
grd=$backupfolder$name.nc
cpt=./my_ibcao.cpt
grad=$backupfolder$name.int.nc
ps=$figfolder$name.ps
pdf=$figfolder$name.pdf

gmt grdcut $originalgrd -R${region} -N -G$grd

gmt grd2xyz $grd -R -fg | gmt mapproject -R -J$projection -F -C > $xyz

gmt grdmath $grd 1000 DIV = $grd

gmt grdgradient $grd -A15 -Ne0.75 -G$grad
gmt grdimage -R -E150 -JM$width\i $grd -I$grad -C$cpt -Bxa4f2+l"Longitude (deg)" -Bya3f1.5+l"Latitude (deg)" -K > $ps #  Bya2fg2
gmt pscoast -R -J -Di -Wthinner -O -K >> $ps

colorbar_width=`echo "$width*1/2" | bc -l`
colorbar_height=0.1
colorbar_vertical_offset=0
colorbar_horizontal_offset=`echo "($width/2)-($colorbar_width/2)" | bc -l`
gmt psscale -DjCB+w$colorbar_width\i/$colorbar_height\i+o$colorbar_horizontal_offset\i/$colorbar_vertical_offset\i+h -Bxa2f1+l"Elevation (km)" -C$cpt -R -J -O >> $ps

gmt psconvert -A -Tf $ps -D$figfolder

rm -f $grd $grad 
rm -f $ps
#--------------------------------
name=sed
xyz=$backupfolder$name.xyz
originalgrd=/ichec/work/nuig02/yingzi/geological_data/sedmentThickness/sedthick_world_v2.grd
grd=$backupfolder$name.nc
grad=$backupfolder$name.int.nc
cpt=$backupfolder$name.cpt
ps=$figfolder$name.ps
pdf=$figfolder$name.pdf

gmt grdcut $originalgrd -R${region} -N -G$grd

gmt grd2xyz $grd -R -fg | gmt mapproject -R -J$projection -F -C > $xyz

gmt grdmath $grd 1000 DIV = $grd

gmt grdgradient $grd -A15 -Ne0.75 -G$grad
gmt grd2cpt $grd -CGMT_rainbow -L0/10 -E0.1 > $cpt

gmt grdimage -R -E150 -JM$width\i $grd -I$grad -C$cpt -Bxa4f2+l"Longitude (deg)" -Bya3f1.5+l"Latitude (deg)" -K > $ps #  Bya2fg2
gmt pscoast -R -J -Di -Wthinner -Ggray -O -K >> $ps

colorbar_width=`echo "$width*1/2" | bc -l`
colorbar_height=0.1
colorbar_vertical_offset=0
colorbar_horizontal_offset=`echo "($width/2)-($colorbar_width/2)" | bc -l`
gmt psscale -DjCB+w$colorbar_width\i/$colorbar_height\i+o$colorbar_horizontal_offset\i/$colorbar_vertical_offset\i+h -Bxa3f1.5+l"Thickness (km)" -C$cpt -R -J -O >> $ps

gmt psconvert -A -Tf $ps -D$figfolder

rm -f gmt.conf
rm -f gmt.history
rm -f $grd $grad 
rm -f $ps
