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
#gmt gmtset DIR_GSHHG /ichec/work/nuig02/yingzi/geological_data/gshhg-gmt-2.3.7/
gmt gmtset DIR_GSHHG ~/geological_data/gshhg-gmt-2.3.7/
#gmt gmtset GMT_VERBOSE d

figfolder=../figures/
backupfolder=../backup/

sr=$backupfolder\sr
sr_x=`awk '{ print $1}' $sr`
sr_y=`awk '{ print $2}' $sr`
rc=$backupfolder\rc

xmin=-20
xmax=-4
ymin=48
ymax=58
region=$xmin/$xmax/$ymin/$ymax

delta=0.5


echo $region > $backupfolder\region

UTM_ZONE=28


sub_xmin=`echo "$sr_x-$delta" | bc -l`
sub_xmax=`echo "$sr_x+$delta" | bc -l`
sub_ymin=`echo "$sr_y-$delta" | bc -l`
sub_ymax=`echo "$sr_y+$delta" | bc -l`
sub_region=$sub_xmin/$sub_xmax/$sub_ymin/$sub_ymax
#echo $sub_region
sub_polygon_file=$backupfolder\sub_polygon
rm -rf $sub_polygon_file
cat <<EOF >>$sub_polygon_file
$sub_xmin $sub_ymin
$sub_xmin $sub_ymax
$sub_xmax $sub_ymax
$sub_xmax $sub_ymin
EOF

projection=u$UTM_ZONE/1:1

width=2.2 #inch

#--------------------------------
name=topo
xyz=$backupfolder$name.xyz
#originalgrd=/ichec/work/nuig02/yingzi/geological_data/GEBCO/gebco_08.nc
originalgrd=~/geological_data/GEBCO/gebco_08.nc
grd=$backupfolder$name.nc
cpt=./my_ibcao.cpt
grad=$backupfolder$name.int.nc
ps=$figfolder$name.ps
pdf=$figfolder$name.pdf


gmt grdcut $originalgrd -R${region} -N -G$grd

sr_utm=`cat $sr | gmt mapproject -R${sub_region} -J$projection -F -C`
rc_utm=`cat $rc | gmt mapproject -R${sub_region} -J$projection -F -C`

echo 0 0  > $backupfolder\sr_utm
sr_utm_x=`echo $sr_utm | awk '{ print $1}'`
sr_utm_y=`echo $sr_utm | awk '{ print $2}'`

rc_utm_x=`echo $rc_utm | awk -v sr_utm_x="$sr_utm_x" -v sr_utm_y="$sr_utm_y" '{ print $1-sr_utm_x}'`
rc_utm_y=`echo $rc_utm | awk -v sr_utm_x="$sr_utm_x" -v sr_utm_y="$sr_utm_y" '{ print $2-sr_utm_y}'`
echo $rc_utm_x $rc_utm_y > $backupfolder\rc_utm

gmt grd2xyz $grd -R${sub_region} -fg | gmt mapproject -R${sub_region} -J$projection -F -C | awk -v sr_utm_x="$sr_utm_x" -v sr_utm_y="$sr_utm_y" '{print $1-sr_utm_x, $2-sr_utm_y, $3}' > $xyz

gmt grdmath $grd 1000 DIV = $grd

gmt grdgradient $grd -A15 -Ne0.75 -G$grad
gmt grdimage -R${region} -E150 -JM$width\i $grd -I$grad -C$cpt -Bxa4f2+l"Longitude (deg)" -Bya3f1.5+l"Latitude (deg)" -K > $ps #  Bya2fg2
gmt pscoast -R -J -Di -Wthinner -O -K >> $ps

#cat $sub_polygon_file | gmt psxy -R -J -W1p,red -O -K >> $ps #-G-red -G+red 
cat $sr | gmt psxy -R -J -Sa0.05i -Gred   -N -Wthinner,black -O -K >> $ps
#cat $rc | gmt psxy -R -J -St0.05i -Gblue  -N -Wthinner,black -O -K >> $ps


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
#originalgrd=/ichec/work/nuig02/yingzi/geological_data/sedmentThickness/sedthick_world_v2.grd
originalgrd=~/geological_data/sedmentThickness/sedthick_world_v2.grd
grd=$backupfolder$name.nc
grad=$backupfolder$name.int.nc
cpt=$backupfolder$name.cpt
ps=$figfolder$name.ps
pdf=$figfolder$name.pdf


gmt grdcut $originalgrd -R${region} -N -G$grd

gmt grd2xyz $grd -R${sub_region} -fg | gmt mapproject -R${sub_region} -J$projection -F -C | awk -v sr_utm_x="$sr_utm_x" -v sr_utm_y="$sr_utm_y" '{print $1-sr_utm_x, $2-sr_utm_y, $3}' > $xyz

gmt grdmath $grd 1000 DIV = $grd

gmt grdgradient $grd -A15 -Ne0.75 -G$grad
gmt grd2cpt $grd -CGMT_rainbow -L0/10 -E0.1 > $cpt

gmt grdimage -R$region -E150 -JM$width\i $grd -I$grad -C$cpt -Bxa4f2+l"Longitude (deg)" -Bya3f1.5+l"Latitude (deg)" -K > $ps #  Bya2fg2
gmt pscoast -R -J -Di -Wthinner -Ggray -O -K >> $ps

#cat $sub_polygon_file | gmt psxy -R -J -W1p,red -O -K >> $ps #-G-red -G+red 
cat $sr | gmt psxy -R -J -Sa0.05i -Gred  -N -Wthinner,black -O -K >> $ps
#cat $rc | gmt psxy -R -J -St0.05i -Gblue  -N -Wthinner,black -O -K >> $ps

colorbar_width=`echo "$width*1/2" | bc -l`
colorbar_height=0.1
colorbar_vertical_offset=0
colorbar_horizontal_offset=`echo "($width/2)-($colorbar_width/2)" | bc -l`
gmt psscale -DjCB+w$colorbar_width\i/$colorbar_height\i+o$colorbar_horizontal_offset\i/$colorbar_vertical_offset\i+h -Bxa3f1.5+l"Thickness (km)" -C$cpt -R -J -O >> $ps

gmt psconvert -A -Tf $ps -D$figfolder

rm -f gmt.conf
rm -f gmt.history
rm -f $cpt
rm -f $grd $grad 
rm -f $ps
#----------------------------
xmin=`gmt info -C $xyz | awk '{ print $1}'`
xmax=`gmt info -C $xyz | awk '{ print $2}'`
ymin=`gmt info -C $xyz | awk '{ print $3}'`
ymax=`gmt info -C $xyz | awk '{ print $4}'`
echo sub region: $xmin $xmax $ymin $ymax
#xLength=`echo "$xmax-($xmin)" | bc -l`
#yLength=`echo "$ymax-($ymin)" | bc -l`
#echo "X length="$xLength
#echo "Y length="$yLength
