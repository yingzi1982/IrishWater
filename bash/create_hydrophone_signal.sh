#!/bin/bash

#./matlab.sh generate_hydrophone_signal.m
./octave.sh generate_hydrophone_signal.m
#./octave.sh filter_signal.m hydrophone_signal

./octave.sh generate_signal_spectrum.m hydrophone_signal
#./octave.sh generate_signal_spectrum.m hydrophone_signal_filtered
