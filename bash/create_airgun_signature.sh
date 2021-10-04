#!/bin/bash

nCol=1
cat ../backup/airgun_signature | awk -v nCol="$nCol" '{print $1, $(nCol+1)}' > ../backup/airgun_signature_$nCol

cd ../gmt
./plot_single_signal.sh airgun_signature_$nCol
