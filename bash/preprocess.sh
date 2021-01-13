#!/bin/bash

#case 1
echo -13.05 50.65 > ../backup/sr

#case 2
#echo -13.81 49.63 > ../backup/sr

module purge

./create_geological_data.sh

./update_Par_settings.sh

./octave.sh generate_sources.m

./create_model.sh

./octave.sh generate_stations.m
