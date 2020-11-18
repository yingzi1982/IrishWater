#!/bin/bash
simulation="tl"
if [ $simulation == "wiggle" ]; then
# wiggle simulation
cp ../OUTPUT_FILES/*semp ../backup
cp ../OUTPUT_FILES/output_list_sources.txt ../backup
cp ../OUTPUT_FILES/output_list_stations ../backup

elif [ $simulation == "tl" ]; then
# transmission loss simulation
./octave.sh generate_transmission_loss.m
#cp ../OUTPUT_FILES/output_list_sources.txt ../backup
fi

#./gmt.sh
