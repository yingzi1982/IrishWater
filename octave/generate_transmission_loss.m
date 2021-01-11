#!/usr/bin/env octave

clear all
close all
clc

[f0_status f0] = system('grep ATTENUATION_f0_REFERENCE ../backup/Par_file | cut -d = -f 2');
f0 = str2num(f0);

[dt_status dt] = system('grep ^DT ../backup/Par_file | cut -d = -f 2');
dt = str2num(dt);

%cut off header, select last 20 period
periodNumber=50;
pointNumber=round(1/f0*periodNumber/dt);
startNumber=40000;

source_signal = dlmread(['../OUTPUT_FILES/plot_source_time_function.txt']);
%source_signal_RMS = rms(source_signal(startNumber:startNumber+periodNumber-1,2));
source_signal_RMS = rms(source_signal(end-pointNumber:end,2));
%source_signal_RMS = rms(source_signal(:,2));
%source_signal_RMS = max(abs(source_signal(end-pointNumber:end,2)));

fileID = fopen('../OUTPUT_FILES/output_list_stations.txt');
station = textscan(fileID,'%s %s %f %f %f');
fclose(fileID);

stationName = station{1};
networkName = station{2};
longorUTM = station{3};
latorUTM = station{4};
burial = station{5};

stationNumber = length(stationName);

signal_RMS_dB = zeros(stationNumber,1);

tic ();

fileID = fopen(['../backup/transmissionLoss'],'w');

for nStation = 1:stationNumber
  signal = dlmread(['../OUTPUT_FILES/' networkName{nStation} '.' stationName{nStation} '.CXP.semp']);
  %signal_RMS_dB(nStation) = -20*log10(rms(signal(startNumber:startNumber+periodNumber-1,2))/source_signal_RMS);
  signal_RMS_dB(nStation) = -20*log10(rms(signal(end-pointNumber:end,2))/source_signal_RMS);
  %signal_RMS_dB(nStation) = -20*log10(rms(signal(:,2))/source_signal_RMS);
  %signal_RMS_dB(nStation) = -20*log10(max(abs(signal(end-pointNumber:end,2)))/source_signal_RMS);
  fprintf(fileID,'%s  %f  %f  %f  %f\n',networkName{nStation},longorUTM(nStation),latorUTM(nStation),burial(nStation),signal_RMS_dB(nStation));
end
fclose(fileID);

elapsed_time = toc ()
