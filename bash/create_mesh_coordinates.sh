#!/bin/bash

Par_file=../DATA/Par_file
cat ../backup/Par_file > $Par_file
oldString=`grep "^NPROC " $Par_file`
newString='NPROC                           = 1'
sed -i "s/$oldString/$newString/g" $Par_file

Mesh_Par_file=../DATA/meshfem3D_files/Mesh_Par_file

cat ../backup/Mesh_Par_file.part > $Mesh_Par_file

oldString=`grep "^NPROC_XI " $Mesh_Par_file`
newString='NPROC_XI                           = 1'
sed -i "s/$oldString/$newString/g" $Mesh_Par_file

oldString=`grep "^NPROC_ETA " $Mesh_Par_file`
newString='NPROC_ETA                          = 1'
sed -i "s/$oldString/$newString/g" $Mesh_Par_file

echo "" >> $Mesh_Par_file
cat ../backup/NMATERIALS >> $Mesh_Par_file
echo "" >> $Mesh_Par_file
cat ../backup/materials >> $Mesh_Par_file
echo "" >> $Mesh_Par_file
cat ../backup/NREGIONS >> $Mesh_Par_file
echo "" >> $Mesh_Par_file
cat ../backup/regions >> $Mesh_Par_file


vtkFile=../DATABASES_MPI/proc000000_mesh.vtk
rm -f $vtkFile

module load intel gcc
cd ../
bin/xmeshfem3D
cd -
module unload intel gcc

./octave.sh vtk2xyz.m
