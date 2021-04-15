#!/bin/bash

#case 1
#echo -13.10 49.25 > ../backup/sr
#case 2
#echo -13.05 50.65 > ../backup/sr
#case 3
#echo -12.5 48.9 > ../backup/sr
#echo -13.15 51.085 > ../backup/sr

#18A
echo -13.07019135 51.15862502 > ../backup/sr
#echo -13.06977865 51.15753811 > ../backup/sr
#echo -13.06946172 51.15666206 > ../backup/sr
#echo -13.06910869 51.15555438 > ../backup/sr
#mean value#echo -13.0696351 51.15709489 > ../backup/sr
#mean value#echo -13.1403 51.15709489 > ../backup/sr

echo -13.14 51.1456 > ../backup/rc

module purge

#./create_geological_data.sh

./update_Par_settings.sh

./octave.sh generate_sources.m

./create_model.sh
exit

./octave.sh generate_stations.m
