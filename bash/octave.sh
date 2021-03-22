#!/bin/bash
#module load octave/4.4.1
module load octave

octave_script=$1
input_parameters=$2

cd ../octave

./$octave_script $input_parameters

module unload octave
