#!/bin/bash

module load intel gcc

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

cd ../../../
./configure FC=ifort CC=icc --without-mpi

make clean
make  xcombine_vol_data_vtk
make  xcombine_vol_data

cd -

cp ../../../bin/xcombine_vol_data_vtk ../bin/
cp ../../../bin/xcombine_vol_data ../bin/

module unload intel gcc
