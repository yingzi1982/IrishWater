#!/bin/bash

for shootingNumbering in $(seq 1 9)
#for shootingNumbering in $(seq 1 1)
do

echo $shootingNumbering

./octave.sh generate_hydrophone_signal.m $shootingNumbering

./octave.sh generate_signal_spectrum.m hydrophone_signal

cd ../gmt
./plot_signal.sh hydrophone_signal
cd ../bash

mv ../figures/hydrophone_signal.pdf ../figures/hydrophone_signal_$shootingNumbering\.pdf
done
