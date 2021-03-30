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

sourcesFile=$backupfolder\output_list_sources.txt
receiversFile=$backupfolder\output_list_stations.txt

snapshotFile=$backupfolder$name
meshInformationFile=../backup/meshInformation

width=2.2
plot_gap=0.15

array=VARRAY
originalxyz=$backupfolder\$name$_$array.xyz
echo $originalxyz
exit

dx=`grep dx ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
dy=`grep dy ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`

grep $array $tlFile | awk '$2<=0{print sqrt(($2/1000)^2+($3/1000)^2), $4/1000, $5}'   > $originalxyz
grep $array $tlFile | awk '$2>0{print -sqrt(($2/1000)^2+($3/1000)^2), $4/1000, $5}' >> $originalxyz


xmin=`grep $array $tlFile | awk '{print $2/1000, $3/1000}' | gmt gmtinfo -C | awk '{print $1}'`
xmax=`grep $array $tlFile | awk '{print $2/1000, $3/1000}' | gmt gmtinfo -C | awk '{print $2}'`
ymin=`grep $array $tlFile | awk '{print $2/1000, $3/1000}' | gmt gmtinfo -C | awk '{print $3}'`
ymax=`grep $array $tlFile | awk '{print $2/1000, $3/1000}' | gmt gmtinfo -C | awk '{print $4}'`


lowerLimit=-1
upperLimit=1
inc_cpt=0.01
cpt=$backupfolder$name\.cpt
#gmt makecpt -CGMT_seis.cpt -T$lowerLimit/$upperLimit/$inc_cpt -Z > $cpt
gmt makecpt -Cpolar -T$lowerLimit/$upperLimit/$inc_cpt -Z > $cpt

#normalization_column=7
#normalization=`awk -v normalization_column="$normalization_column" '{print $normalization_column}' $snapshotFile | gmt gmtinfo -C | awk '{print $2}'`
snapshot_number=`awk '{print NF-4; exit}' $snapshotFile`

#for iSnapshot in $(seq 1 $snapshot_number)
for iSnapshot in $(seq 1 4)
do
echo plotting $iSnapshot snapshot
iColumn=$(($iSnapshot + 4))
ps=$figfolder$name\_$iSnapshot.ps
pdf=$figfolder$name\_$iSnapshot.pdf

#normalization=`grep VARRAY $snapshotFile | awk -v iColumn="$iColumn" '$4>-1500 {print $iColumn}' | gmt gmtinfo -C | awk '{print $2}'`
#-------------------------------------

region=$xmin/$xmax/$zmin/$zmax
inc=$dx/$dz

height=0.8
projection=X$width\i/$height\i

offset=`echo "-($height+$plot_gap)" | bc -l`
grd=$backupfolder$array\.nc

gmt psbasemap -R$region -J$projection -Bxa2.0f1.0+l"Easting (km) " -Bya1.0f0.5+l"Elevation (km)" -Y$offset\i  -O -K >> $ps

normalization=`grep $array $snapshotFile | awk -v iColumn="$iColumn" '{print $iColumn}' | gmt gmtinfo -C | awk '{print $2}'`
echo $normalization

grep $array $snapshotFile | awk  -v normalization="$normalization"  -v iColumn="$iColumn" '{print $2/1000, $4/1000, $iColumn/normalization}' | gmt blockmean -R$region -I$inc | gmt surface -Ll$lowerLimit -Lu$upperLimit -R$region -I$inc -G$grd

#cat ../backup/water_polygon | awk '{ print $1/1000,$2/1000}' | gmt psclip -R -J -B -O -K >> $ps
gmt grdimage -R -J -B $grd -C$cpt -O -K >> $ps
#gmt psclip  -R -J -B -C -O -K >> $ps
cat ../backup/sediment_polygon | awk '{ print $1/1000,$2/1000}' | gmt psxy -R -J -Ggray80 -W1p,black -O -K >> $ps #-G-red -G+red 
cat ../backup/rock_polygon | awk '{ print $1/1000,$2/1000}' | gmt psxy -R -J -Ggray60 -W1p,black -O -K >> $ps #-G-red -G+red 
awk '{ print $1/1000, $3/1000 }' $sourcesFile   | gmt psxy -R -J -Sa0.05i -Gred  -N -Wthinner,black -O -K >> $ps
#awk '{ print $3/1000, $5/1000 }' $receiversFile | gmt psxy -R -J -Sc0.03i -Gyellow -N -Wthinner,black -O -K >> $ps
echo "(b)" | gmt pstext -R -J -F+cTR -N -O -K >> $ps
rm -f $grd
#-------------------------------------
colorbar_width=$height
colorbar_height=0.16
colorbar_horizontal_position=`echo "$width+0.1" | bc -l`
colorbar_vertical_position=`echo "$colorbar_width/2" | bc -l`
domain=$colorbar_horizontal_position\i/$colorbar_vertical_position\i/$colorbar_width\i/$colorbar_height\i
gmt psscale -D$domain -C$cpt -Bxa1f0.5 -By -O >> $ps

gmt psconvert -A -Tf $ps -D$figfolder
rm -f $ps
done
rm -f $cpt

gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=$figfolder\snapshots.pdf $figfolder\snapshots_*.pdf
rm -f $figfolder\snapshots_*.pdf

rm -f gmt.conf
rm -f gmt.history
module unload gmt
