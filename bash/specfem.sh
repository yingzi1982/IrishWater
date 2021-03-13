#!/bin/bash 

module load intel gcc
cd ../

NPROC=`grep ^NPROC DATA/Par_file | grep -v -E '^[[:space:]]*#' | cut -d = -f 2`

rm -rf OUTPUT_FILES/*

if [ "$NPROC" -eq 1 ]; then
  echo "Running xmeshfem3D"
  bin/xmeshfem3D
  echo "Running xgenerate_databases"
  bin/xgenerate_databases
 if [ "$#" -eq  "0" ]
   then
  echo "Running xspecfem3D"
  bin/xspecfem3D
  else
  echo not run solver: $1
 fi
else
  echo "Running xmeshfem3D"
  mpiexec -n $NPROC bin/xmeshfem3D
  echo "Running xgenerate_databases"
  mpiexec -n $NPROC bin/xgenerate_databases
 if [ "$#" -eq  "0" ]
   then
  echo "Running xspecfem3D"
  mpiexec -n $NPROC bin/xspecfem3D
  else
  echo not run solver: $1
 fi
fi
cd -
module unload intel gcc 
