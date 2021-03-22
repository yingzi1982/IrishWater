#!/bin/bash

#./matlab.sh generate_hydrophone_signal.m
#./octave.sh generate_signal_spectrum.m hydrophone_signal

cd ../gmt
echo hydrophone_signal | ./plot_signal.sh

cd ../bash
./git.sh push
