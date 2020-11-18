#!/bin/bash

module purge

cd ../gmt
./plot_deployment.sh
./plot_wiggle.sh

cd -
