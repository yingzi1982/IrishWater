#!/bin/bash

./backup_data.sh
./process_data.sh
exit

./create_hydrophone_signal.sh

./octave.sh generate_signal_spectrum.m specfem_hydrophone_signal

./gmt.sh
