#!/usr/bin/env octave

clear all
close all
clc

workingDir='/ichec/work/ngear019b/yingzi/irishWater/';
data_folder=[workingDir 'OUTPUT_FILES/'];

[NSTEP_status NSTEP] = system('grep ^NSTEP ../backup/Par_file | cut -d = -f 2');
NSTEP = str2num(NSTEP);

startRowNumber=0;
startColumnNumber=1;

fileID = fopen([data_folder 'output_list_stations.txt']);
station = textscan(fileID,'%s %s %f %f %f');
fclose(fileID);

stationName = station{1};
networkName = station{2};
longorUTM = station{3};
latorUTM = station{4};
burial = station{5};

stationNumber = length(stationName);

%combinedSignal=zeros(NSTEP,stationNumber);
combinedSignal=zeros(NSTEP,20);
band='FXP.semp'

%for nStation = 1:stationNumber
for nStation = 1:20
  combinedSignal(:,nStation) = dlmread([data_folder networkName{nStation} '.' stationName{nStation} '.' band],'',startRowNumber,startColumnNumber);
end

combinedSignalFile='../backup/combinedSignal.bin';
save ("-binary", combinedSignalFile,  "combinedSignal")
