#!/usr/bin/env octave

clear all
close all
clc

backup_folder=['../backup/'];
%signal_folder=['../OUTPUT_FILES/'];
signal_folder=['/ichec/work/ngear019b/yingzi/irishWater/OUTPUT_FILES/'];

ref=0.1^6;

%----------------------------
source_signal = load([backup_folder 'plot_source_time_function.txt']);
t = source_signal(:,1);
s = source_signal(:,2);

dt= t(2)-t(1);
Fs = 1/dt;

octaveFreq=load(['../backup/octaveFreq']);

source_signal_octavePSD = octavePSD(s/ref,Fs,octaveFreq);

%----------------------------

fileID = fopen([backup_folder 'output_list_stations.txt']);
station = textscan(fileID,'%s %s %f %f %f');
fclose(fileID);

stationName = station{1};
networkName = station{2};
longorUTM = station{3};
latorUTM = station{4};
burial = station{5};
stationNumber = length(stationName);

LARRAY_index=find(strcmp("LARRAY",networkName));
LARRAY_stationNumber=length(LARRAY_index);
HBVARRAY_index=find(strcmp("HARRAY",networkName)|strcmp("BARRAY",networkName)|strcmp("VARRAY",networkName));
HBVARRAY_stationNumber=length(HBVARRAY_index);

startRowNumber=0;
startColumnNumber=1;

LARRAY=[];
LARRAY = [t LARRAY];
for nStation = 1:LARRAY_stationNumber
  signal = dlmread([signal_folder networkName{LARRAY_index(nStation)} '.' stationName{LARRAY_index(nStation)} '.FXP.semp'],'',startRowNumber,startColumnNumber);
  LARRAY = [LARRAY signal];
end

dlmwrite('../backup/LARRAY',LARRAY,' ');


HBVARRAY=[];
for nStation = 1:HBVARRAY_stationNumber
  signal = dlmread([signal_folder networkName{HBVARRAY_index(nStation)} '.' stationName{HBVARRAY_index(nStation)} '.FXP.semp'],'',startRowNumber,startColumnNumber);
  HBVARRAY = [HBVARRAY signal];
end

snapshot_start=500;
snapshot_step =500;
snapshot_end=length(t);
snapshot_index = [snapshot_start:snapshot_step:snapshot_end];
snapshot_number = length(snapshot_index);
snapshot= HBVARRAY(snapshot_index,:);

fileID = fopen([backup_folder 'snapshots'],'w');
fprintf(fileID, '#snapshot_start: %d\n', snapshot_start);
fprintf(fileID, '#snapshot_step: %d\n', snapshot_step);
for nStation = 1:HBVARRAY_stationNumber
  fprintf(fileID,'%s  %f  %f  %f',networkName{HBVARRAY_index(nStation)},longorUTM(HBVARRAY_index(nStation)),latorUTM(HBVARRAY_index(nStation)),burial(HBVARRAY_index(nStation)));
  for nSnapshot = 1:snapshot_number
    fprintf(fileID, ' %e', snapshot(nSnapshot,nStation));
  end
  fprintf(fileID,'\n');
end
fclose(fileID);

HBVARRAY_octavePSD = octavePSD(HBVARRAY/ref,Fs,octaveFreq);

fileID = fopen([backup_folder 'octavePSD'],'w');
for nStation = 1:HBVARRAY_stationNumber
  fprintf(fileID,'%s  %f  %f  %f',networkName{HBVARRAY_index(nStation)},longorUTM(HBVARRAY_index(nStation)),latorUTM(HBVARRAY_index(nStation)),burial(HBVARRAY_index(nStation)));
  for nOctaveFreq = 1:length(octaveFreq)
    fprintf(fileID, ' %e', HBVARRAY_octavePSD(nOctaveFreq,nStation)-source_signal_octavePSD(nOctaveFreq));
  end
  fprintf(fileID,'\n');
end
fclose(fileID);
