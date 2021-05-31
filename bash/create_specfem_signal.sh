#!/bin/bash

./octave.sh generate_specfem_signal.m

./octave.sh generate_signal_spectrum.m specfem_signal_surface
./octave.sh generate_signal_spectrum.m specfem_signal_bottom

cd ../gmt
./plot_signal.sh specfem_signal_surface
./plot_signal.sh specfem_signal_bottom
