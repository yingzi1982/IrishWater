#!/usr/bin/env octave

clear all
close all
clc

data_folder='../OUTPUT_FILES/';

[NSTEP_status NSTEP] = system('grep ^NSTEP ../backup/Par_file | cut -d = -f 2');
NSTEP = str2num(NSTEP);

startColumnNumber=round(NSTEP/2);
startRowNumber=1;

source_signal = dlmread([data_folder 'plot_source_time_function.txt'],'',startColumnNumber,startRowNumber);
source_signal_RMS = rms(source_signal);

fileID = fopen([data_folder 'output_list_stations.txt']);
station = textscan(fileID,'%s %s %f %f %f');
fclose(fileID);

stationName = station{1};
networkName = station{2};
longorUTM = station{3};
latorUTM = station{4};
burial = station{5};

stationNumber = length(stationName);

signal_RMS = zeros(stationNumber,1);

tic ();

for nStation = 1:stationNumber
  signal = dlmread([data_folder networkName{nStation} '.' stationName{nStation} '.CXP.semp'],'',startColumnNumber,startRowNumber);
  signal_RMS(nStation) = rms(signal);
end

signal_RMS_dB = -20*log10(signal_RMS/source_signal_RMS);

fileID = fopen(['../backup/transmissionLoss'],'w');
for nStation = 1:stationNumber
  fprintf(fileID,'%s  %f  %f  %f  %f\n',networkName{nStation},longorUTM(nStation),latorUTM(nStation),burial(nStation),signal_RMS_dB(nStation));
end
fclose(fileID);

elapsed_time = toc ()
