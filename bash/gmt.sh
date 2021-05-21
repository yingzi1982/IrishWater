#!/bin/bash

module purge

cd ../gmt

./plot_deployment.sh
./plot_sound_speed_slice.sh

./plot_source_signal.sh

./plot_trace_image.sh

./plot_transmission_loss.sh

./plot_snapshot_2D_vertical_slice.sh
