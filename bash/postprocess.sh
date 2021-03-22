#!/bin/bash

#./backup_data.sh
./process_data.sh

exit

cd ../gmt
./plot_sound_speed_slice.sh
./plot_deployment.sh
