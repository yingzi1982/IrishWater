#!/bin/bash
#not run src/specfem3D/prepare_optimized_arrays.F90

module load intel/2018u4 gcc

rm -f ../bin/*

# create executables
cd ../../../
./configure FC=gfortran CC=gcc MPIFC=mpif90

make clean
make xmeshfem3D
make xgenerate_databases
make xspecfem3D

cd -

cp ../../../bin/xmeshfem3D ../bin/
cp ../../../bin/xgenerate_databases ../bin/
cp ../../../bin/xspecfem3D ../bin/
exit

cd ../../../
./configure FC=ifort CC=icc --without-mpi

make clean
make  xcombine_vol_data_vtk
make  xcombine_vol_data

cd -

cp ../../../bin/xcombine_vol_data_vtk ../bin/
cp ../../../bin/xcombine_vol_data ../bin/

module unload intel/2018u4 gcc
