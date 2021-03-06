#!/bin/bash
module load gmt

rm -f gmt.conf
rm -f gmt.history

gmt gmtset MAP_FRAME_AXES Wesn
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

lowerLimit=50
upperLimit=100
#-----------------------------------------------------
octaveFreqNumber=`cat ../backup/octaveFreq| wc -l`


for nOctaveFreq in $(seq 1 1 $octaveFreqNumber)
#for nOctaveFreq in $(seq 1 1 2)
do

echo plotting $nOctaveFreq th transmission loss

sr=$backupfolder\output_list_sources.txt
rc=$backupfolder\output_list_stations.txt

name=transmissionLoss_$nOctaveFreq
tlFile=$backupfolder$name

transmissionLoss_HARRAY=`paste <(grep HARRAY $rc | awk '{print $2, $3, $4, $5}') <(awk -v nOctaveFreq="$nOctaveFreq" '{print $nOctaveFreq}' $backupfolder/transmissionLoss_HARRAY) --delimiters ' '`
transmissionLoss_BARRAY=`paste <(grep BARRAY $rc | awk '{print $2, $3, $4, $5}') <(awk -v nOctaveFreq="$nOctaveFreq" '{print $nOctaveFreq}' $backupfolder/transmissionLoss_BARRAY) --delimiters ' '`
transmissionLoss_VARRAY=`paste <(grep VARRAY $rc | awk '{print $2, $3, $4, $5}') <(awk -v nOctaveFreq="$nOctaveFreq" '{print $nOctaveFreq}' $backupfolder/transmissionLoss_VARRAY) --delimiters ' '`

echo -e "$transmissionLoss_HARRAY\n$transmissionLoss_BARRAY\n$transmissionLoss_VARRAY" > $tlFile

meshInformationFile=../backup/meshInformation

ps=$figfolder$name.ps
pdf=$figfolder$name.pdf

xmin=`grep xmin ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
xmax=`grep xmax ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
dx=`grep dx ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
ymin=`grep ymin ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
ymax=`grep ymax ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
dy=`grep dy ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
zmin=`grep zmin ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
zmax=`grep zmax ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`
dz=`grep dz ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000 }'`

xrange=`echo "($xmax) - ($xmin)" | bc -l`


#xmin=0
#zmin=-3
sr=`awk '{ print $1/1000, $2/1000 }' $sr`
rc=`awk 'NR<=1{ print $3/1000, $4/1000 }' $rc`

width=2.2
plot_small_gap=0.15
plot_big_gap=0.65

awk  '{print $2/1000, $4/1000, $5}' $tlFile | gmt gmtinfo -C | awk '{print "transimission loss in range [" $5, $6 "] dB"}'
inc_cpt=1
cpt=$backupfolder$name\.cpt
gmt makecpt -CGMT_seis.cpt -T$lowerLimit/$upperLimit/$inc_cpt -Z > $cpt

#-------------------------------------
array=HARRAY
region=$xmin/$xmax/$ymin/$ymax
inc=$dx/$dy
grd=$backupfolder$array\.nc

height=`echo "$width*(($ymax)-($ymin))/(($xmax)-($xmin))" | bc -l`
projection=X$width\i/$height\i

gmt psbasemap -R$region -J$projection -Bxa2.0f1.0+l"Easting (km) " -Bya2.0f1.0+l"Northing (km)" -Y4\i -K > $ps

grep $array $tlFile | awk '{print $2/1000, $3/1000, $5}' | gmt blockmean -R$region -I$inc | gmt surface -Ll$lowerLimit -Lu$upperLimit -R$region -I$inc -G$grd

gmt grdimage -R -J  -B $grd -C$cpt -O -K >> $ps
echo $sr | gmt psxy -R -J -Sa0.05i -Gred  -N -Wthinner,black -O -K >> $ps
echo $rc | gmt psxy -R -J -St0.05i -Gyellow  -N -Wthinner,black -O -K >> $ps
#echo "(a)" | gmt pstext -R -J -F+cTR -N -O -K >> $ps
rm -f $grd
#-------------------------------------
gmt gmtset MAP_FRAME_AXES WeSn
array=BARRAY
topo=$backupfolder\topo.xyz
topo_grd=$backupfolder\topo.nc
topo_grad=$backupfolder$topo.int.nc
grd=$backupfolder$array\.nc
grdcontour=$backupfolder\grdcontour

region=$xmin/$xmax/$ymin/$ymax
inc=$dx/$dy
height=`echo "$width*(($ymax)-($ymin))/(($xmax)-($xmin))" | bc -l`
projection=X$width\i/$height\i
offset=`echo "-($height+$plot_small_gap)" | bc -l`

cat $topo | awk '{print $1/1000, $2/1000, $3/1000}' | gmt blockmean -R$region -I$inc | gmt surface -R$region -I$inc -G$topo_grd

gmt grdgradient $topo_grd -A15 -Ne0.75 -G$topo_grad

gmt psbasemap -R$region -J$projection -Bxa2.0f1.0+l"Easting (km) " -Bya2.0f1.0+l"Northing (km)" -Y$offset\i -O -K >> $ps

grep $array $tlFile | awk '{print $2/1000, $3/1000, $5}' | gmt blockmean -R$region -I$inc | gmt surface -Ll$lowerLimit -Lu$upperLimit -R$region -I$inc -G$grd

gmt grdimage -R -J  -B $grd -I$topo_grad -C$cpt -O -K >> $ps
#gmt grdimage -R -J  -B $grd -C$cpt -O -K >> $ps
cat $grdcontour >> $ps
echo $sr | gmt psxy -R -J -Sa0.05i -Gred  -N -Wthinner,black -O -K >> $ps
echo $rc | gmt psxy -R -J -St0.05i -Gyellow  -N -Wthinner,black -O -K >> $ps
#echo "(c)" | gmt pstext -R -J -F+cTR -N -O -K >> $ps
rm -f $topo_grd $topo_grad $grd
#-------------------------------------
array=VARRAY

xmin=`grep $array $tlFile | awk '{print $2/1000, $3/1000}' | gmt gmtinfo -C | awk '{print $1}'`
xmax=`grep $array $tlFile | awk '{print $2/1000, $3/1000}' | gmt gmtinfo -C | awk '{print $2}'`
ymin=`grep $array $tlFile | awk '{print $2/1000, $3/1000}' | gmt gmtinfo -C | awk '{print $3}'`
ymax=`grep $array $tlFile | awk '{print $2/1000, $3/1000}' | gmt gmtinfo -C | awk '{print $4}'`

originalxyz=$backupfolder\$name$_$array.xyz
grep $array $tlFile | awk '$2<=0{print sqrt(($2/1000)^2+($3/1000)^2), $4/1000, $5}'   > $originalxyz
grep $array $tlFile | awk '$2>0{print -sqrt(($2/1000)^2+($3/1000)^2), $4/1000, $5}' >> $originalxyz

rmin=`cat $originalxyz | gmt gmtinfo -C | awk '{print $1}'`
rmax=`cat $originalxyz | gmt gmtinfo -C | awk '{print $2}'`

range=`echo "$rmax - ($rmin)" | bc -l`

region=$rmin/$rmax/$zmin/$zmax
dr=`echo "$dx * $range/$xrange" | bc -l`
inc=$dr/$dz
width=`echo "($range)/$xrange*($width)" | bc -l`
#height=0.8
height=`echo "$width*(($zmax)-($zmin))/$range" | bc -l`

sr=$backupfolder\output_list_sources.txt
rc=$backupfolder\output_list_stations.txt

sr=`awk '{ print 0, $3/1000 }' $sr`
rc=`awk 'NR<=1{ print sqrt(($3/1000)^2+($4/1000)^2), $5/1000 }' $rc`

projection=X-$width\i/$height\i

offset=`echo "-($height+$plot_big_gap)" | bc -l`
grd=$backupfolder$array\.nc

gmt psbasemap -R$region -J$projection -Bxa2.0f1.0+l"Distance (km) " -Bya1.0f0.5+l"Elevation (km)" -Y$offset\i  -O -K >> $ps

cat $originalxyz | gmt blockmean -R$region -I$inc | gmt surface -Ll$lowerLimit -Lu$upperLimit -R$region -I$inc -G$grd
gmt grdimage -R -J -B $grd -C$cpt -O -K >> $ps
#cat ../backup/water_polygon | awk '{ print $1/1000,$2/1000}' | gmt psclip -R -J -B -O -K >> $ps
#gmt psclip  -R -J -B -C -O -K >> $ps
cat ../backup/sediment_polygon | awk '{ print $1/1000,$2/1000}' | gmt psxy -R -J -Ggray80 -W1p,black -O -K >> $ps #-G-red -G+red 
cat ../backup/rock_polygon | awk '{ print $1/1000,$2/1000}' | gmt psxy -R -J -Ggray60 -W1p,black -O -K >> $ps #-G-red -G+red 
echo $sr | gmt psxy -R -J -Sa0.05i -Gred  -N -Wthinner,black -O -K >> $ps
echo $rc | gmt psxy -R -J -St0.05i -Gyellow  -N -Wthinner,black -O -K >> $ps
#echo "(b)" | gmt pstext -R -J -F+cTR -N -O -K >> $ps
rm -f $grd $originalxyz
#-------------------------------------

colorbar_width=$height
colorbar_height=0.16
colorbar_horizontal_position=`echo "$width+0.1" | bc -l`
colorbar_vertical_position=`echo "$colorbar_width/2" | bc -l`
domain=$colorbar_horizontal_position\i/$colorbar_vertical_position\i/$colorbar_width\i/$colorbar_height\i
gmt psscale -D$domain -C$cpt -Bxa20f10+l"TL (dB)" -By -O >> $ps
rm -f $cpt

gmt psconvert -A -Tf $ps -D$figfolder
rm -f $ps
rm -f $tlFile

done

rm -f gmt.conf
rm -f gmt.history
module unload gmt
