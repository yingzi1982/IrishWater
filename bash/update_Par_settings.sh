#!/bin/bash

Par_file=../backup/Par_file
NPROC=`grep ^NPROC $Par_file | cut -d = -f 2`

Mesh_Par_file=../backup/Mesh_Par_file.part

NPROC_XI=`grep ^NPROC_XI $Mesh_Par_file | cut -d = -f 2`
NPROC_ETA=`grep ^NPROC_ETA $Mesh_Par_file | cut -d = -f 2`

if [ $NPROC -ne $(( $NPROC_XI*$NPROC_ETA )) ]
then
echo $NPROC not equal to $NPROC_XI x $NPROC_ETA
fi

multiplier=1
SPACING_XI=7

SPACING_ETA=$SPACING_XI

NEX_XI=$(($NPROC_XI*8*$multiplier))
NEX_ETA=$(($NPROC_ETA*8*$multiplier))

LATITUDE_MIN=`grep ^LATITUDE_MIN $Mesh_Par_file | cut -d = -f 2`
LONGITUDE_MIN=`grep ^LONGITUDE_MIN $Mesh_Par_file | cut -d = -f 2`

LATITUDE_MAX=`echo "$LATITUDE_MIN + $NEX_ETA*$SPACING_ETA" | bc -l`
LONGITUDE_MAX=`echo "$LONGITUDE_MIN + $NEX_XI*$SPACING_XI" | bc -l`

oldString=`grep "^LATITUDE_MAX" $Mesh_Par_file`
newString="LATITUDE_MAX                    = $LATITUDE_MAX"
sed -i "s/$oldString/$newString/g" $Mesh_Par_file

oldString=`grep "^LONGITUDE_MAX" $Mesh_Par_file`
newString="LONGITUDE_MAX                   = $LONGITUDE_MAX"
sed -i "s/$oldString/$newString/g" $Mesh_Par_file

oldString=`grep "^NEX_XI" $Mesh_Par_file`
newString="NEX_XI                          = $NEX_XI"
sed -i "s/$oldString/$newString/g" $Mesh_Par_file

oldString=`grep "^NEX_ETA" $Mesh_Par_file`
newString="NEX_ETA                         = $NEX_ETA"
sed -i "s/$oldString/$newString/g" $Mesh_Par_file
