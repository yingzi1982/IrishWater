#!/bin/bash

./octave.sh generate_specfem_signal.m

./octave.sh generate_signal_spectrum.m specfem_signal

cd ../gmt
./plot_signal.sh specfem_signal
