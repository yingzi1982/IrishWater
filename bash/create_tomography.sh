#!/bin/bash

#./create_mesh_coordinates.sh
./create_mesh_coordinates_regular_grid.sh

./octave.sh generate_tomography.m

cd ../gmt
./plot_sound_speed_slice.sh
