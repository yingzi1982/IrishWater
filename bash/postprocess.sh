#!/bin/bash

#./backup_data.sh
./process_data.sh

exit

cd ../gmt
./plot_virtual_airgun_source_signal.sh
./plot_source_signal.sh
./plot_sound_speed_slice.sh
./plot_deployment.sh
./plot_transmission_loss.sh
