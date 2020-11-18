#!/bin/bash 

module load intel gcc
cd ../

NPROC=`grep ^NPROC DATA/Par_file | grep -v -E '^[[:space:]]*#' | cut -d = -f 2`

rm -rf OUTPUT_FILES/*

if [ "$NPROC" -eq 1 ]; then
  bin/xmeshfem3D
  bin/xgenerate_databases
  bin/xspecfem3D
else
  mpiexec -n $NPROC bin/xmeshfem3D
  mpiexec -n $NPROC bin/xgenerate_databases
  mpiexec -n $NPROC bin/xspecfem3D
fi
cd -
module unload intel gcc 
