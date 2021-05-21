#!/bin/bash

module purge

cd ../gmt

./plot_deployment.sh
./plot_sound_speed_slice.sh
#./plot_virtual_airgun_source_signal.sh
./plot_source_signal.sh

./plot_signal.sh hydrophone_signal
./plot_signal.sh ARRAY.S1.FXP.semp_amplified

./plot_transmission_loss.sh

 plot_snapshot_2D_vertical_slice.sh
