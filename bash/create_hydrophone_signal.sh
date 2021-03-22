#!/bin/bash

./matlab.sh generate_hydrophone_signal.m
./octave.sh generate_signal_spectrum.m hydrophone_signal

cd ../gmt
./plot_signal.sh hydrophone_signal
