#!/bin/bash 

runningName=irishWater_attenuation
#runningName=irishWater
workingDir=/ichec/work/ngear019b/yingzi/$runningName/
mkdir -p $workingDir
cp -r ../DATA/ $workingDir
cp -r ../bin/ $workingDir

rm -rf $workingDir/OUTPUT_FILES
mkdir $workingDir/OUTPUT_FILES
rm -rf $workingDir/DATABASES_MPI
mkdir $workingDir/DATABASES_MPI
cd $workingDir

module load intel gcc

NPROC=`grep ^NPROC DATA/Par_file | grep -v -E '^[[:space:]]*#' | cut -d = -f 2`

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
