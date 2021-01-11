#!/bin/bash
module load matlab

matlab_script=$1

cd ../octave

matlab -nodisplay -nosplash -nodesktop -r "run('$matlab_script');exit;"

module unload matlab
