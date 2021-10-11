#!/bin/bash


#18A
echo -13.07019135 51.15862502 > ../backup/sr
echo -13.14 51.1456 > ../backup/rc
#canyon
#echo -11.361 51.131 > ../backup/sr
#echo -11.531 51.061 > ../backup/rc


module purge


#./create_geological_data.sh

./update_Par_settings.sh

./create_airgun_array.sh
exit
./octave.sh generate_sources.m

./create_model.sh

./octave.sh generate_stations.m
