#!/bin/bash 

runningName=irishWater
workingDir=/ichec/work/ngear019b/yingzi/$runningName/
mkdir $workingDir
cp -r ../DATA/ $workingDir
cp -r ../bin/ $workingDir
mkdir $workingDir/OUTPUT_FILES
mkdir $workingDir/DATABASES_MPI
cd $workingDir

module load intel gcc
#cd ../

NPROC=`grep ^NPROC DATA/Par_file | grep -v -E '^[[:space:]]*#' | cut -d = -f 2`

rm -rf OUTPUT_FILES/*
rm -rf DATABASES_MPI/*

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
