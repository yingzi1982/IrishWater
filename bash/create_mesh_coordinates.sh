#!/bin/bash

NPROC=64
NPROC_XI=8
NPROC_ETA=8

Par_file=../DATA/Par_file
cat ../backup/Par_file > $Par_file

#oldString=`grep "^NSTEP " $Par_file`
#newString='NSTEP                           = 1'
#sed -i "s/$oldString/$newString/g" $Par_file

local_path=`grep "^LOCAL_PATH " $Par_file | cut -d = -f 2`
cd ../
rm -rf $local_path/*
cd -

Mesh_Par_file=../DATA/meshfem3D_files/Mesh_Par_file
cat ../backup/Mesh_Par_file.part > $Mesh_Par_file

echo "" >> $Mesh_Par_file
cat ../backup/NMATERIALS >> $Mesh_Par_file
echo "" >> $Mesh_Par_file
cat ../backup/materials >> $Mesh_Par_file
echo "" >> $Mesh_Par_file
cat ../backup/NREGIONS >> $Mesh_Par_file
echo "" >> $Mesh_Par_file
cat ../backup/regions >> $Mesh_Par_file

module load intel gcc
./specfem.sh not_run_solver
module unload intel gcc

cd ..
./bin/xcombine_vol_data 0 10 rho.bin $local_path $local_path 1 #0 for low resolution; 1 for high resolution

vtkFile=../DATABASES_MPI/proc000000_mesh.vtk
rm -f $vtkFile

./octave.sh vtk2xyz.m
