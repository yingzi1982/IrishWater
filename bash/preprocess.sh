#!/bin/bash

#case 1
#echo -13.10 49.25 > ../backup/sr
#case 2
#echo -13.05 50.65 > ../backup/sr
#case 3
#echo -12.5 48.9 > ../backup/sr
echo -13.15 51.085 > ../backup/sr

module purge

./create_geological_data.sh

./create_measured_sound_speed_profile.sh

./update_Par_settings.sh

./octave.sh generate_sources.m

./create_model.sh

./octave.sh generate_stations.m
