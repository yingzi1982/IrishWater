#!/bin/bash 
#https://marine.copernicus.eu/

module load conda
source activate python3

OUTPUT_DIRECTORY=../backup/
OUTPUT_FILENAME=copernicus.nc
USERNAME='yying2'
PASSWORD='Ying_1982'

python -m motuclient --motu https://nrt.cmems-du.eu/motu-web/Motu --service-id GLOBAL_ANALYSIS_FORECAST_PHY_001_024-TDS --product-id global-analysis-forecast-phy-001-024 --longitude-min -20 --longitude-max -4 --latitude-min 48 --latitude-max 58 --date-min "2020-08-01 12:00:00" --date-max "2020-08-01 12:00:00" --depth-min 0.0 --depth-max 5500.0 --variable sea_water_salinity --variable sea_water_potential_temperature  --out-dir $OUTPUT_DIRECTORY --out-name $OUTPUT_FILENAME --user $USERNAME --pwd $PASSWORD

module unload conda

module load netcdf/gcc
module load octave

cd ../octave
./generate_copernicus.m

module unload netcdf/gcc
module unload octave
