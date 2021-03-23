#!/bin/bash

./matlab.sh generate_hydrophone_signal.m
./octave.sh filter_signal.m hydrophone_signal

./octave.sh generate_signal_spectrum.m hydrophone_signal
./octave.sh generate_signal_spectrum.m hydrophone_signal_filtered

cd ../gmt
./plot_signal.sh hydrophone_signal
./plot_signal.sh hydrophone_signal_filtered
