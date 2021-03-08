#!/bin/bash 

./octave.sh generate_virtual_airgun_source.m
cd ../gmt
./plot_virtual_airgun_source_signal.sh
