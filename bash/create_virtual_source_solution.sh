#!/bin/bash
module load matlab

cd ../octave/solid_bottom/

matlab -nodisplay -nodesktop -r "run ./PenWedgeRun.m"

module unload matlab
