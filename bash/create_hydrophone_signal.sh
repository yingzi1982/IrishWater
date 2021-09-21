#!/bin/bash

./octave.sh generate_hydrophone_signal.m
exit

./octave.sh generate_signal_spectrum.m hydrophone_signal

cd ../gmt
./plot_signal.sh hydrophone_signal
