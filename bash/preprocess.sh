#!/bin/bash

module purge

#./create_geological_data.sh

./update_Par_settings.sh

./octave.sh generate_sources.m

./create_model.sh

./octave.sh generate_stations.m
