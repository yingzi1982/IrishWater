#!/bin/bash

./octave.sh generate_interfaces.m

./update_PML_settings.sh

./octave.sh generate_regions.m
./octave.sh generate_materials.m
./create_tomography.sh

Par_file=../DATA/Par_file
cat ../backup/Par_file > $Par_file

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
