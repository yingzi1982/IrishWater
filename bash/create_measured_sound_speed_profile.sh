#!/bin/bash 

./octave.sh generate_measured_sound_speed_profile.m

cd ../gmt
./plot_measured_sound_speed_profile.sh
