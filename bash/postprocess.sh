#!/bin/bash

#./backup_data.sh
#./process_data.sh
exit

./create_hydrophone_signal.sh
./octave.sh generate_signal_spectrum.m specfem_hydrophone_signal


cd ../gmt
./plot_signal.sh hydrophone_signal
./plot_signal.sh specfem_hydrophone_signal
./plot_virtual_airgun_source_signal.sh
./plot_source_signal.sh
./plot_sound_speed_slice.sh
./plot_deployment.sh
./plot_transmission_loss.sh
