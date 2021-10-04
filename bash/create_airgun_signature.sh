#!/bin/bash

./octave.sh generate_airgun_signature.m

#nCol=1
for nCol in $(seq 1 36)
do
cat ../backup/airgun_signature | awk -v nCol="$nCol" '{print $1, $(nCol+1)}' > ../backup/airgun_signature_$nCol

cd ../gmt
./plot_single_signal.sh airgun_signature_$nCol
cd ../bash
done
