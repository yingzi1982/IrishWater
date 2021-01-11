#!/bin/bash
#module load octave/4.4.1
module load octave

octave_script=$1
input_parameters=$2

cd ../octave

echo $input_parameters | ./$octave_script

module unload octave
