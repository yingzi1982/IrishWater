#!/bin/bash

./matlab.sh generate_airgun_array_signature.m

#nCol=1
for nCol in $(seq 1 36)
do
cat ../backup/airgun_array_signature | awk -v nCol="$nCol" '{print $1, $(nCol+1)}' > ../backup/airgun_array_signature_$nCol

cd ../gmt
./plot_source_signal.sh
#./plot_single_signal.sh airgun_array_signature_$nCol
#rm -f ../backup/airgun_array_signature_$nCol
#cd ../bash
done

