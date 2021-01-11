#!/bin/bash 

#SBATCH -A nuig02 #ucd01 dias01 nuig02 ngear015c
#SBATCH -p ProdQ # DevQ: 4 nodes x 1 hours; ProdQ: 40 nodes x 72 hours
#SBATCH -N 4
#SBATCH -t 15:00:00
#SBATCH -o output.txt
#SBATCH -e error.txt
#SBATCH --mail-user=yingzi.ying@me.com
#SBATCH --mail-type=ALL

#cd $SLURM_SUBMIT_DIR

cd ../bash
./preprocess.sh
./specfem.sh
