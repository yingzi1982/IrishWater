#!/bin/bash 

runningName=irishWater
workingDir=/ichec/work/ngear019b/yingzi/$runningName/
#rm -f $workingDir
mkdir -p /tmp/empty & rsync -r --delete /tmp/empty/ $workingDir
mkdir -p $workingDir
mkdir $workingDir/OUTPUT_FILES
mkdir $workingDir/DATABASES_MPI

cp -r ../DATA/ $workingDir
cp -r ../bin/ $workingDir

cd $workingDir

module load intel/2018u4 gcc

NPROC=`grep ^NPROC DATA/Par_file | grep -v -E '^[[:space:]]*#' | cut -d = -f 2`

if [ "$NPROC" -eq 1 ]; then
  bin/xmeshfem3D
  bin/xgenerate_databases
  bin/xspecfem3D
else
  mpiexec -n $NPROC bin/xmeshfem3D
  mpiexec -n $NPROC bin/xgenerate_databases
  #rm DATABASES_MPI/*bin
  mpiexec -n $NPROC bin/xspecfem3D
fi
cd -
module unload intel/2018u4 gcc 
