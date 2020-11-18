#!/bin/bash

Par_file=../backup/Par_file

ATTENUATION_f0_REFERENCE=`grep ATTENUATION_f0_REFERENCE $Par_file | cut -d = -f 2`
oldString=`grep "^f0_FOR_PML" $Par_file`
newString="f0_FOR_PML                 = $ATTENUATION_f0_REFERENCE"
sed -i "s/$oldString/$newString/g" $Par_file

Mesh_Par_file=../backup/Mesh_Par_file.part

PMLElementNumber=5

dx=`grep dx ../backup/meshInformation | cut -d = -f 2`
dy=`grep dy ../backup/meshInformation | cut -d = -f 2`
dz=`grep dz ../backup/meshInformation | cut -d = -f 2`
thickness_of_x_pml=`echo $dx*$PMLElementNumber | bc`
thickness_of_y_pml=`echo $dy*$PMLElementNumber | bc`
thickness_of_z_pml=`echo $dz*$PMLElementNumber | bc`

oldString=`grep "^THICKNESS_OF_X_PML" $Mesh_Par_file`
newString="THICKNESS_OF_X_PML                 = $thickness_of_x_pml"
sed -i "s/$oldString/$newString/g" $Mesh_Par_file

oldString=`grep "^THICKNESS_OF_Y_PML" $Mesh_Par_file`
newString="THICKNESS_OF_Y_PML                 = $thickness_of_y_pml"
sed -i "s/$oldString/$newString/g" $Mesh_Par_file

oldString=`grep "^THICKNESS_OF_Z_PML" $Mesh_Par_file`
newString="THICKNESS_OF_Z_PML                 = $thickness_of_z_pml"
sed -i "s/$oldString/$newString/g" $Mesh_Par_file

