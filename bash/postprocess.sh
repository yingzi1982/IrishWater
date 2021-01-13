#!/bin/bash
simulation="tl"
if [ $simulation == "wiggle" ]; then
cp ../OUTPUT_FILES/output_list_sources.txt ../backup
cp ../OUTPUT_FILES/output_list_stations.txt ../backup
# wiggle simulation
cp ../OUTPUT_FILES/*semp ../backup

elif [ $simulation == "tl" ]; then
# transmission loss simulation
cp ../OUTPUT_FILES/output_list_sources.txt ../backup
cp ../OUTPUT_FILES/output_list_stations.txt ../backup
./octave.sh generate_transmission_loss.m
fi

#./gmt.sh
