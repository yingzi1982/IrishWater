#!/bin/bash

module load intel gcc

# create executables
cd ../../../
./configure FC=gfortran CC=gcc MPIFC=mpif90

make clean
make xmeshfem3D
make xgenerate_databases
make xspecfem3D

cd -

rm -f ../bin/*
cp ../../../bin/xmeshfem3D ../bin/
cp ../../../bin/xgenerate_databases ../bin/
cp ../../../bin/xspecfem3D ../bin/

module unload intel gcc
