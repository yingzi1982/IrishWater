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

length=2.2i
height=2.6i
#---------------------------------------------------------
name=wiggle
ps=$figfolder$name.ps
pdf=$figfolder$name.pdf

sourcesFile=$backupfolder\output_list_sources.txt
receiversFile=$backupfolder\output_list_stations.txt
receiverRange=`awk '{ print $3/1000}' $receiversFile`
receiverNumber=`echo $receiverRange | wc -w`
receiverRangeStart=`echo $receiverRange | awk '{print $1}'`
receiverRangeEnd=`echo $receiverRange | awk '{print $NF}'`
receiverRangeSpacing=`echo "($receiverRangeEnd-$receiverRangeStart)/($receiverNumber-1)" | bc -l`

xmin=`echo "$receiverRangeStart-$receiverRangeSpacing" | bc -l`
xmax=`echo "$receiverRangeEnd+$receiverRangeSpacing" | bc -l`
ymin=0
ymax=9
region=$xmin/$xmax/$ymin/$ymax
projection=X$length/$height
resampling=1
gmt psbasemap -R$region -J$projection -Bxa1f.5+l"Easting (km)" -Bya3f1.5+l"Time (s)"  -K > $ps
scale=`echo "1/$receiverRangeSpacing" | bc -l`

for i in $(seq 1 $receiverNumber)
do
 originalxy=$backupfolder\ARRAY.S$i\.FXP.semp
 xmin=`gmt gmtinfo $originalxy -C | awk '{print $1}'`
 xmax=`gmt gmtinfo $originalxy -C | awk '{print $2}'`
 ymin=`gmt gmtinfo $originalxy -C | awk '{print $3}'`
 ymax=`gmt gmtinfo $originalxy -C | awk '{print $4}'`
 range=`echo $receiverRange | awk -v i=$i '{print $i}'`
 startTime=$xmin
 normalization=`echo $ymin $ymax | awk ' { if(sqrt($1^2)>(sqrt($2^2))) {print sqrt($1^2)} else {print sqrt($2^2)}}'`
 dB=`echo $normalization | awk '{printf "%.1f", 20*log($1)/log(10)}'`

 cat $originalxy | awk -v normalization="$normalization"  -v startTime="$startTime" -v range="$range" -v resampling="$resampling" 'NR%resampling==0 { print range,$1-startTime,$2/normalization}' | gmt pswiggle -R -J -Z$scale -G-blue -G+red -P -Wthinnest,black -O -K >> $ps

echo " `echo "$range-$receiverRangeSpacing/2" | bc -l` 7. 90 10p $dB dB" | gmt pstext -R -J -F+a+f -O -K >> $ps
done

gmt psbasemap -R -J -B --MAP_FRAME_AXES='' -O >> $ps

#---------------------------------------------------------

gmt psconvert -A -Tf $ps -D$figfolder

rm -f $ps

rm -f gmt.conf
rm -f gmt.history
module unload gmt
