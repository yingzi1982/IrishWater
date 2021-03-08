#!/bin/bash

./matlab.sh generate_hydrophone_signal.m
./octave.sh generate_spectrogram.m

cd ../gmt
./plot_hydrophone_signal.sh

cd ../bash
./git.sh push
