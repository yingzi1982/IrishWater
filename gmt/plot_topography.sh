#!/bin/bash
module load gmt

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
cpt=./ibcao.cpt
grad=$backupfolder$name.int.nc
ps=$figfolder$name.ps
pdf=$figfolder$name.pdf

gmt grdcut $originalgrd -R${region} -N -G$grd

gmt grd2xyz $grd -R -fg | gmt mapproject -R -J$projection -F -C > $xyz
xmin=`gmt info -C $xyz | awk '{ print $1}'`
xmax=`gmt info -C $xyz | awk '{ print $2}'`
ymin=`gmt info -C $xyz | awk '{ print $3}'`
ymax=`gmt info -C $xyz | awk '{ print $4}'`

gmt grdgradient $grd -A15 -Ne0.75 -G$grad
gmt grdimage -R -E150 -JM$width\i $grd -I$grad -C$cpt -Bxa4f2+l"Longitude (deg)" -Bya3f1.5+l"Latitude (deg)" -K > $ps #  Bya2fg2
gmt pscoast -R -J -Di -Wthinner -O -K >> $ps

#colorbar_width=$height
#colorbar_height=0.16
#colorbar_horizontal_position=`echo "$width+0.1" | bc -l`
#colorbar_vertical_position=`echo "$colorbar_width/2" | bc -l`
#domain=$colorbar_horizontal_position\i/$colorbar_vertical_position\i/$colorbar_width\i/$colorbar_height\i
#gmt psscale -D$domain -C$cpt -Bxa20f10 -By+l"dB" -O >> $ps
gmt psscale -DJBC+o0/0.4i -R -J -C$cpt -Bx2000f1000 -By+l"Depth" -O >> $ps

gmt psconvert -A -Tf $ps -D$figfolder

rm gmt.conf
rm gmt.history
rm -f $grd $grad 
rm -f $ps
#--------------------------------
echo 'finish topo'
exit
name=sed
xyz=$backupfolder$name.xyz
originalgrd=/ichec/work/nuig02/yingzi/geological_data/sedmentThickness/sedthick_world_v2.grd
grd=$backupfolder$name.nc
grad=$backupfolder$name.int.nc
cpt=$backupfolder$name.cpt
ps=$figfolder$name.ps
eps=$figfolder$name.eps
pdf=$figfolder$name.pdf

gmt grdcut $originalgrd -R${region} -N -G$grd
#gmt grd2xyz $grd -R -fg | awk '{ print $1, $2, $3 }' | gmt mapproject -R -J$projection_cartesian -F -C > $xyz
gmt grd2xyz $grd -R -fg | awk '{ print $1, $2, $3 }' | gmt blockmean -R -I${inc} | gmt surface -R -I${inc} -Ll0 -Lu10000 -G$grd
gmt grd2xyz $grd -R -fg | awk '{ print $1, $2, $3 }' | gmt mapproject -R -J$projection_cartesian -F -C > $xyz

gmt grdgradient $grd -A15 -Ne0.75 -G$grad
gmt grd2cpt $grd -CGMT_rainbow.cpt -L0/10000 -E100 > $cpt

gmt grdimage -R  -J${projection} $grd -I$grad -C$cpt -Bxa4f2+l"Longitude (deg)" -Bya3f1.5+l"Latitude (deg)" -K > $ps #  Bya2fg2

echo "-10000 150 10000 150" > gray.cpt
gmt pscoast -R -J -Di -Gc -O -K >> $ps
gmt grdimage -R -J $grd -I$grad -Cgray.cpt -O -K >> $ps
gmt pscoast -R -J -Q -O -K >> $ps

gmt pscoast -R -J -Di -Wthinner -O -K >> $ps
gmt psxy $receiverPostion -R -J -O -K -St0.1i -Gred -Wthin,black >> $ps
gmt psxy $sourcePostion -R -J -O -K -Sa0.1i -Gred -Wthin,black >> $ps

gmt psscale -D$domain -C$cpt -E -Ba5000f2500+l"Thickness (m)" -O >> $ps
#gs $ps
gmt psconvert -A -Tf $ps -D$figfolder
rm -f $grd $grad 
rm -f $ps
#--------------------------------
name=moho
xyz=$backupfolder$name.xyz
originalgrd=/ichec/work/ucd01/yingzi/MOHO/Europe_moho_depth_2007.grd
grd=$backupfolder$name.nc
grad=$backupfolder$name.int.nc
cpt=$backupfolder$name.cpt
ps=$figfolder$name.ps
eps=$figfolder$name.eps
pdf=$figfolder$name.pdf

gmt grdcut $originalgrd -R${region} -N -G$grd
gmt grd2xyz $grd -R -fg | awk '{ print $1, $2, $3*1000 }' | gmt mapproject -R -J$projection_cartesian -F -C > $xyz
gmt grd2xyz $grd -R -fg | awk '{ print $1, $2, $3*1000 }' | gmt blockmean -R -I${inc} | gmt surface -R -I${inc} -Ll10000 -Lu35000 -G$grd

gmt grdgradient $grd -A15 -Ne0.75 -G$grad
gmt grd2cpt $grd -CGMT_rainbow.cpt -L10000/35000 -E100 > $cpt

gmt grdimage -R -J${projection} $grd -I$grad -C$cpt -Bxa4f2+l"Longitude (deg)" -Bya3f1.5+l"Latitude (deg)" -K > $ps #  Bya2fg2

gmt pscoast -R -J -Di -Wthinner -O -K >> $ps
gmt psxy $receiverPostion -R -J -O -K -St0.1i -Gred -Wthin,black >> $ps
gmt psxy $sourcePostion -R -J -O -K -Sa0.1i -Gred -Wthin,black >> $ps

gmt psscale -D$domain -C$cpt -E -Ba15000f7500+l"Depth (m)" -O >> $ps
#gs $ps
gmt psconvert -A -Tf $ps -D$figfolder
rm -f $grd $grad 
rm -f $ps
#--------------------------------
ps=$figfolder\perspective.ps
eps=$figfolder\perspective.eps
pdf=$figfolder\perspective.pdf
view_angle=130/25
vertical_shift=1.12i
#--------------------------------
name=moho
gmt gmtset MAP_FRAME_AXES wESn
xyz=$backupfolder$name.xyz
originalgrd=/ichec/work/ucd01/yingzi/MOHO/Europe_moho_depth_2007.grd
grd=$backupfolder$name.nc
grad=$backupfolder$name.int.nc
cpt=$backupfolder$name.cpt

gmt grdcut $originalgrd -R${region} -N -G$grd
gmt grd2xyz $grd -R -fg | awk '{ print $1, $2, $3*1000 }' | gmt mapproject -R -J$projection_cartesian -F -C > $xyz
gmt grd2xyz $grd -R -fg | awk '{ print $1, $2, $3*1000 }' | gmt blockmean -R -I${inc} | gmt surface -R -I${inc} -Ll10000 -Lu35000 -G$grd

gmt grdgradient $grd -A15 -Ne0.75 -G$grad
gmt grd2cpt $grd -CGMT_rainbow.cpt -L10000/35000 -E100 > $cpt

gmt grdimage -R -J${projection} -p$view_angle $grd -I$grad -C$cpt -Bxa4f2+l"Longitude (deg)" -Bya3f1.5+l"Latitude (deg)" -K > $ps #  Bya2fg2

gmt pscoast -R -J -p -Di -Wthinner -O -K >> $ps
#gmt psxy $receiverPostion -R -J -p -O -K -St0.1i -Gred -Wthin,black >> $ps
#gmt psxy $sourcePostion -R -J -p -O -K -Sa0.1i -Gred -Wthin,black >> $ps

gmt psscale  -R -J -p -D$domain -C$cpt -E -Ba15000f7500+l"Depth (m)" -O -K >> $ps
rm -f $grd $grad 
#--------------------------------
name=sed
gmt gmtset MAP_FRAME_AXES wesn
xyz=$backupfolder$name.xyz
originalgrd=/ichec/work/ucd01/yingzi/sedmentThickness/sedthick_world_v2.grd
grd=$backupfolder$name.nc
grad=$backupfolder$name.int.nc
cpt=$backupfolder$name.cpt

gmt grdcut $originalgrd -R${region} -N -G$grd
#gmt grd2xyz $grd -R -fg | awk '{ print $1, $2, $3 }' | gmt mapproject -R -J$projection_cartesian -F -C > $xyz
gmt grd2xyz $grd -R -fg | awk '{ print $1, $2, $3 }' | gmt blockmean -R -I${inc} | gmt surface -R -I${inc} -Ll0 -Lu10000 -G$grd
gmt grd2xyz $grd -R -fg | awk '{ print $1, $2, $3 }' | gmt mapproject -R -J$projection_cartesian -F -C > $xyz

gmt grdgradient $grd -A15 -Ne0.75 -G$grad
gmt grd2cpt $grd -CGMT_rainbow.cpt -L0/10000 -E100 > $cpt

gmt grdimage -R -J$projection -p $grd -I$grad -C$cpt -Y$vertical_shift -Bxa4f2+l"Longitude (deg)" -Bya3f1.5+l"Latitude (deg)" -O -K >> $ps #  Bya2fg2

echo "-10000 150 10000 150" > gray.cpt
gmt pscoast -R -J -p -Di -Gc -O -K >> $ps
gmt grdimage -R -J -p $grd -I$grad -Cgray.cpt -O -K >> $ps
gmt pscoast -R -J -p -Q -O -K >> $ps

gmt pscoast -R -J -p -Di -Wthinner -O -K >> $ps
#gmt psxy $receiverPostion -R -J -p  -O -K -St0.1i -Gred -Wthin,black >> $ps
#gmt psxy $sourcePostion -R -J -p  -O -K -Sa0.1i -Gred -Wthin,black >> $ps

gmt psscale -R -J -p -D$domain -C$cpt -E -Ba5000f2500+l"Thickness (m)" -O -K >> $ps
rm -f $grd $grad 
#--------------------------------
name=topo
gmt gmtset MAP_FRAME_AXES wesn
xyz=$backupfolder$name.xyz
originalgrd=/ichec/work/ucd01/yingzi/GEBCO/gebco_08.nc
grd=$backupfolder$name.nc
grad=$backupfolder$name.int.nc

gmt grdcut $originalgrd -R${region} -N -G$grd
gmt grd2xyz $grd -R -fg | awk '{ print $1, $2, $3 }' | gmt mapproject -R -J$projection_cartesian -F -C > $xyz
gmt grd2xyz $grd -R -fg | awk '{ print $1, $2, $3 }' | gmt blockmode -R -I${inc} | gmt surface -R -I${inc} -G$grd

cpt=./ibcao.cpt
gmt grdgradient $grd -A15 -Ne0.75 -G$grad

gmt grdimage -R -J${projection} -p $grd -I$grad -C$cpt -Y$vertical_shift -Bxa4f2+l"Longitude (deg)" -Bya3f1.5+l"Latitude (deg)" -K -O >> $ps #  Bya2fg2

gmt pscoast -R -J -p -Di -Wthinner -O -K >> $ps
gmt psxy $receiverPostion -R -J -p -O -K -St0.1i -Gred -Wthin,black >> $ps
gmt psxy $sourcePostion -R -J -p -O -K -Sa0.1i -Gred -Wthin,black >> $ps

gmt psscale -R -J -D$domain -C$cpt -p -E -Bxa2500f1250+l"Elevation (m)" -O >> $ps
#gs $ps
rm -f $grd $grad 
#gs $ps
gmt psconvert -A -Tf $ps -D$figfolder
rm -f $ps
