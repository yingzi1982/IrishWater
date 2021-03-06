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
array=VARRAY

sr=$backupfolder\output_list_sources.txt
stations_file=$backupfolder\output_list_stations.txt
sr=`awk '{ print 0, $3/1000 }' $sr`
rc=`awk 'NR==1{ print sqrt(($3/1000)^2+($4/1000)^2), $5/1000 }' $stations_file`

snapshotFile=$backupfolder$name\_$array
snapshots=`cat $snapshotFile`

coordinate=`grep $array $stations_file | awk '{print $3/1000, $4/1000, $5/1000}'`
left_coordinate=`echo "$coordinate" | awk '$1<=0{print sqrt(($1)^2+($2)^2), $3}'` 
right_coordinate=`echo "$coordinate" | awk '$1>0{print -sqrt(($1)^2+($2)^2), $3}'` 
coordinate=`echo -e "$left_coordinate\n$right_coordinate"`


rmin=`echo "$coordinate" | gmt gmtinfo -C | awk '{print $1}'`
rmax=`echo "$coordinate" | gmt gmtinfo -C | awk '{print $2}'`
zmin=`echo "$coordinate" | gmt gmtinfo -C | awk '{print $3}'`
zmax=`echo "$coordinate" | gmt gmtinfo -C | awk '{print $4}'`

range=`echo "$rmax - $rmin" | bc -l`
depth=`echo "$zmax - $zmin" | bc -l`

dx=`grep dx ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000*2 }'`
dy=`grep dy ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000*2 }'`
dz=`grep dz ../backup/meshInformation | cut -d = -f 2 | awk '{ print $1/1000*2 }'`
dr=`echo "sqrt($dx*$dx+$dy*$dy)" | bc -l`

originalxyz=`paste <(echo "$coordinate") <(echo "$snapshots") --delimiters ' '`

width=2.2
height=`echo "$depth/$range*$width" | bc -l`
projection=X-$width\i/$height\i
region=$rmin/$rmax/$zmin/$zmax
inc=$dr/$dz

lowerLimit=-1
upperLimit=1
inc_cpt=0.01
cpt=$backupfolder$name\.cpt
gmt makecpt -CGMT_seis.cpt -T$lowerLimit/$upperLimit/$inc_cpt -Z > $cpt
#gmt makecpt -Cpolar -T$lowerLimit/$upperLimit/$inc_cpt -Z > $cpt


snapshot_start=`awk '{print $1}' ../backup/snapshotTimeIndex`
snapshot_step=`awk '{print $2}' ../backup/snapshotTimeIndex`
snapshot_end=`awk '{print $3}' ../backup/snapshotTimeIndex`

#snapshot_number=`awk '{print NF-2; exit}' $originalxyz`
#for iSnapshot in $(seq 1 $snapshot_number)
for iSnapshot in $(seq 2 43)
do
grd=$backupfolder$name\_$array.grd
echo plotting \# $iSnapshot snapshot
iColumn=$(($iSnapshot + 2))
ps=$figfolder$name\_$iSnapshot.ps
pdf=$figfolder$name\_$iSnapshot.pdf

normalization=`echo "$originalxyz" | awk  -v rmin="$rmin" -v rmax="$rmax" -v zmin="$zmin" -v iColumn="$iColumn" '$1>rmin+0.2 && $1<rmax -0.2 && $2<=-0.2  && $2 >zmin+0.5{print $iColumn}' | gmt gmtinfo -C | awk '{print sqrt($1^2+$2^2)/sqrt(2)}'`

echo "$originalxyz" | awk  -v normalization="$normalization"  -v iColumn="$iColumn" '{print $1, $2, $iColumn/normalization}' | gmt blockmean -R$region -I$inc | gmt surface -Ll$lowerLimit -Lu$upperLimit -R$region -I$inc -G$grd

gmt gmtset MAP_FRAME_AXES WeSn
gmt grdimage -R$region -J$projection -Bxa2.0f1.0+l"Distance (km) " -Bya1.0f0.5+l"Elevation (km)" $grd -C$cpt -K > $ps
#gmt psclip  -R -J -B -C -O -K >> $ps
cat ../backup/sediment_polygon | awk '{ print $1/1000,$2/1000}' | gmt psxy -R -J -Ggray80 -W1p,black -O -K >> $ps #-G-red -G+red 
cat ../backup/rock_polygon | awk '{ print $1/1000,$2/1000}' | gmt psxy -R -J -Ggray60 -W1p,black -O -K >> $ps #-G-red -G+red 
echo $sr | gmt psxy -R -J -Sa0.05i -Gred  -N -Wthinner,black -O -K >> $ps
echo $rc | gmt psxy -R -J -St0.05i -Gyellow  -N -Wthinner,black -O -K >> $ps
#-------------------------------------
colorbar_width=$height
colorbar_height=0.16
colorbar_horizontal_position=`echo "$width+0.1" | bc -l`
colorbar_vertical_position=`echo "$colorbar_width/2" | bc -l`
domain=$colorbar_horizontal_position\i/$colorbar_vertical_position\i/$colorbar_width\i/$colorbar_height\i
gmt psscale -D$domain -C$cpt -Bxa1f0.5 -By -O -K >> $ps

#-------------------------------------
gmt gmtset MAP_FRAME_AXES N

originalxy=$backupfolder/specfem_signal_surface

tmin=`gmt gmtinfo $originalxy -C | awk '{print $1}'`
tmax=`gmt gmtinfo $originalxy -C | awk '{print $2}'`
ymin=`gmt gmtinfo $originalxy -C | awk '{print $3}'`
ymax=`gmt gmtinfo $originalxy -C | awk '{print $4}'`
timeDuration=`echo "(($tmax)-($tmin))" | bc -l`
normalization2=`echo $ymin $ymax | awk ' { if(sqrt($1^2)>(sqrt($2^2))) {print sqrt($1^2)} else {print sqrt($2^2)}}'`
#region2=0/$timeDuration/-1/1
region2=0/6/-1/1

offset2=`echo "(($height)+1.1)" | bc -l`

height2=0.5
width2=$width
projection2=X$width2\i/$height2\i

iSnapshot_time_numbering=$((snapshot_start + (iSnapshot - 1) * snapshot_step))

resample_rate=10
awk  -v resample_rate="$resample_rate" -v  tmin="$tmin" -v normalization2="$normalization2" '(NR)%resample_rate==0{print $1-tmin, $2/normalization2}' $originalxy | gmt psxy -J$projection2 -R$region2 -Bxa2f1+l"Time (s)" -Bya1f0.5 -Wthin,black -Y$offset2 -O -K >> $ps
#awk  -v tmin="$tmin" -v normalization2="$normalization2" -v iSnapshot_time_numbering="$iSnapshot_time_numbering" 'NR==iSnapshot_time_numbering{print $1-tmin, $2/normalization2}' $originalxy | gmt psxy -J -R -Sc0.02i -Gred -O >> $ps
awk  -v tmin="$tmin" -v normalization2="$normalization2" -v iSnapshot_time_numbering="$iSnapshot_time_numbering" 'NR==iSnapshot_time_numbering{print $1-tmin, 0}' $originalxy | gmt psxy -J -R -Sc0.02i -Gred -O >> $ps

gmt psconvert -A -Tf $ps -D$figfolder
rm -f $ps $grd
done
rm -f $cpt

cd ../figures
snapshot_file_list=`ls -v snapshots_*pdf`
gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=snapshots.pdf $snapshot_file_list
rm -f snapshots_*.pdf

rm -f gmt.conf
rm -f gmt.history
module unload gmt
