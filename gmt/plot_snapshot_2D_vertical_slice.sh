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
name=snapshots

sr=$backupfolder\output_list_sources.txt
rc=$backupfolder\output_list_stations.txt
sr=`awk '{ print 0, $3/1000 }' $sr`
rc=`awk 'NR<=1{ print sqrt(($3/1000)^2+($4/1000)^2), $5/1000 }' $rc`

snapshotFile=$backupfolder$name
meshInformationFile=../backup/meshInformation


xmin=`grep xmin ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
xmax=`grep xmax ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
dx=`grep dx ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
dy=`grep dy ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
dz=`grep dz ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
zmin=`grep zmin ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
zmax=`grep zmax ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`

array=VARRAY
originalxyz=$backupfolder$name\_$array.xyz

left_coordinate=`grep $array $snapshotFile | awk '$2<=0{print sqrt(($2/1000)^2+($3/1000)^2), $4/1000}'` 
left_originalxyz=`grep $array $snapshotFile | awk '$2<=0{for(i=5;i<=NF;i++){printf "%s ", $i}; printf "\n"}'`
right_coordinate=`grep $array $snapshotFile | awk '$2>0{print -sqrt(($2/1000)^2+($3/1000)^2), $4/1000}'` 
right_originalxyz=`grep $array $snapshotFile | awk '$2>0{for(i=5;i<=NF;i++){printf "%s ", $i}; printf "\n"}'`
paste <(echo "$left_coordinate") <(echo "$left_originalxyz") --delimiters ' ' > $originalxyz
paste <(echo "$right_coordinate") <(echo "$right_originalxyz") --delimiters ' ' >> $originalxyz

rmin=`cat $originalxyz | awk '{print $1, $2}' | gmt gmtinfo -C | awk '{print $1}'`
rmax=`cat $originalxyz | awk '{print $1, $2}' | gmt gmtinfo -C | awk '{print $2}'`
water_zmin=`cat $originalxyz | awk '{print $1, $2}' | gmt gmtinfo -C | awk '{print $3}'`
water_zmax=`cat $originalxyz | awk '{print $1, $2}' | gmt gmtinfo -C | awk '{print $4}'`

range=`echo "$rmax - $rmin" | bc -l`

width=2.2
height=`echo "($zmax - $zmin)/$range*$width" | bc -l`
projection=X-$width\i/$height\i

region=$rmin/$rmax/$zmin/$zmax
dr=`echo "$dx * $range/($xmax - $xmin)" | bc -l`
inc=$dr/$dz

lowerLimit=-1
upperLimit=1
inc_cpt=0.01
cpt=$backupfolder$name\.cpt
gmt makecpt -CGMT_seis.cpt -T$lowerLimit/$upperLimit/$inc_cpt -Z > $cpt
#gmt makecpt -Cpolar -T$lowerLimit/$upperLimit/$inc_cpt -Z > $cpt

snapshot_number=`awk '{print NF-2; exit}' $originalxyz`

#for iSnapshot in $(seq 1 $snapshot_number)
for iSnapshot in $(seq 1 30)
do
grd=$backupfolder$name\_$array.grd
echo plotting \# $iSnapshot snapshot
iColumn=$(($iSnapshot + 2))
ps=$figfolder$name\_$iSnapshot.ps
pdf=$figfolder$name\_$iSnapshot.pdf

normalization=`cat $originalxyz | awk  -v rmin="$rmin" -v rmax="$rmax" -v water_zmin="$water_zmin" -v iColumn="$iColumn" '$1>rmin+0.2 && $1<rmax -0.2 && $2<=-0.2  && $2 >water_zmin+0.5{print $iColumn}' | gmt gmtinfo -C | awk '{print sqrt($1^2+$2^2)}'`

cat $originalxyz | awk  -v normalization="$normalization"  -v iColumn="$iColumn" '{print $1, $2, $iColumn/normalization}' | gmt blockmean -R$region -I$inc | gmt surface -Ll$lowerLimit -Lu$upperLimit -R$region -I$inc -G$grd

gmt grdimage -R$region -J$projection -Bxa2.0f1.0+l"Distance (km) " -Bya1.0f0.5+l"Elevation (km)" $grd -C$cpt -K > $ps
#gmt psclip  -R -J -B -C -O -K >> $ps
cat ../backup/sediment_polygon | awk '{ print $1/1000,$2/1000}' | gmt psxy -R -J -Ggray80 -W1p,black -O -K >> $ps #-G-red -G+red 
echo $sr | gmt psxy -R -J -Sa0.05i -Gred  -N -Wthinner,black -O -K >> $ps
echo $rc | gmt psxy -R -J -St0.05i -Gyellow  -N -Wthinner,black -O -K >> $ps
#-------------------------------------
colorbar_width=$height
colorbar_height=0.16
colorbar_horizontal_position=`echo "$width+0.1" | bc -l`
colorbar_vertical_position=`echo "$colorbar_width/2" | bc -l`
domain=$colorbar_horizontal_position\i/$colorbar_vertical_position\i/$colorbar_width\i/$colorbar_height\i
gmt psscale -D$domain -C$cpt -Bxa1f0.5 -By -O >> $ps

gmt psconvert -A -Tf $ps -D$figfolder
rm -f $ps $grd
done
rm -f $cpt $originalxyz

cd ../figures
snapshot_file_list=`ls -v snapshots_*pdf`
gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=snapshots.pdf $snapshot_file_list
rm -f snapshots_*.pdf

rm -f gmt.conf
rm -f gmt.history
module unload gmt
