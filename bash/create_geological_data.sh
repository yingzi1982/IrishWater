#!/bin/bash

./create_copernicus.sh

cd ../gmt/

./plot_topography_and_sendiment.sh
./plot_hydrology.sh
