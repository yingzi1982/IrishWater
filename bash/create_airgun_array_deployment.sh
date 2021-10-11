#!/bin/bash

./octave.sh ./generate_airgun_array_deployment.m

cd ../gmt
./plot_airgun_array_deployment.sh
