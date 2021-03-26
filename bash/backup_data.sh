#!/bin/bash
#workingDir=/ichec/work/ngear019b/yingzi/irishWater/
workingDir=/ichec/work/nuig02/yingzi/specfem3d/work/irish_water/
output_folder=$workingDir\OUTPUT_FILES/

backup_folder=../backup/

cp $output_folder/output_list_sources.txt $backup_folder
cp $output_folder/output_list_stations.txt $backup_folder
cp $output_folder/plot_source_time_function.txt $backup_folder
cp $output_folder/ARRAY.S1.FXP.semp $backup_folder/specfem_hydrophone_signal

#signal_folder=$backup_folder\signal
#mkdir -p $signal_folder
#mv $output_folder/*semp $backup_folder
#find $output_folder/ -name '*.semp' -exec mv {} $backup_folder \;

#find $output_folder/ -name '*.semp' -exec rsync --ignore-existing -raz --progress {} $signal_folder \;
