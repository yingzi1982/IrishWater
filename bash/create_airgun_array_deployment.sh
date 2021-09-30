#!/bin/bash

./octave.sh rotate_airgun_array.m

cd ../gmt
./plot_airgun_array_deployment.sh
