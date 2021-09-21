#!/bin/bash

#for shootingNumbering in $(seq 1 9)
for shootingNumbering in $(seq 1 1)
do

./octave.sh generate_hydrophone_signal.m $shootingNumbering

./octave.sh generate_signal_spectrum.m hydrophone_signal

cd ../gmt
./plot_signal.sh hydrophone_signal
done
