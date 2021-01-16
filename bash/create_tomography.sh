#!/bin/bash

./create_mesh_coordinates.sh

./octave.sh generate_tomography.m

cd ../gmt
./plot_sound_speed_slice.sh
