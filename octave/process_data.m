#!/usr/bin/env octave

clear all
close all
clc

backup_folder=['../backup/'];
%signal_folder=[backup_folder 'signals/'];
%signal_folder=['../OUTPUT_FILES/'];
signal_folder=['/ichec/work/ngear019b/yingzi/irishWater/OUTPUT_FILES/'];

[NSTEP_status NSTEP] = system(['grep ^NSTEP ' backup_folder 'Par_file | cut -d = -f 2']);
NSTEP = str2num(NSTEP);

ref=0.1^6;

%----------------------------
source_signal = load([backup_folder 'plot_source_time_function.txt']);
t = source_signal(:,1);
s = source_signal(:,2);

dt= t(2)-t(1);
Fs = 1/dt;

octaveFreq=load(['../backup/octaveFreq']);

octavePSD = octavePSD(s/ref,Fs,octaveFreq);

exit
%----------------------------

source_signal_RMS = rms(source_signal);

fileID = fopen([backup_folder 'output_list_stations.txt']);
station = textscan(fileID,'%s %s %f %f %f');
fclose(fileID);

stationName = station{1};
networkName = station{2};
longorUTM = station{3};
latorUTM = station{4};
burial = station{5};

stationNumber = length(stationName);

signal_RMS = zeros(stationNumber,1);

snapshot_start=500;
snapshot_step =500;
snapshot_end=NSTEP;
snapshot_index = [snapshot_start:snapshot_step:snapshot_end];
snapshot_number = length(snapshot_index);
snapshots = zeros(snapshot_number,stationNumber);

LARRAY=[];

for nStation = 1:stationNumber
  if mod(nStation,1000) == 0
     fprintf('%d\n',nStation);
  end

  signal = dlmread([signal_folder networkName{nStation} '.' stationName{nStation} '.FXP.semp'],'',startRowNumber,startColumnNumber);
  signal_RMS(nStation) = rms(signal);
  snapshots(:,nStation) = signal(snapshot_index);

  if(strcmp(networkName{nStation},'LARRAY'))
    LARRAY = [LARRAY signal];
  end
end

dlmwrite('../backup/LARRAY',LARRAY,' ');


signal_RMS_dB = -20*log10(signal_RMS/source_signal_RMS);

fileID = fopen([backup_folder 'transmissionLoss'],'w');
for nStation = 1:stationNumber
  fprintf(fileID,'%s  %f  %f  %f  %f\n',networkName{nStation},longorUTM(nStation),latorUTM(nStation),burial(nStation),signal_RMS_dB(nStation));
end
fclose(fileID);

fileID = fopen([backup_folder 'snapshots'],'w');
fprintf(fileID, '#snapshot_start: %d\n', snapshot_start);
fprintf(fileID, '#snapshot_step: %d\n', snapshot_step);
for nStation = 1:stationNumber
  fprintf(fileID,'%s  %f  %f  %f',networkName{nStation},longorUTM(nStation),latorUTM(nStation),burial(nStation));
  for nSnapshot = 1:snapshot_number
    fprintf(fileID, ' %e', snapshots(nSnapshot,nStation));
  end
  fprintf(fileID,'\n');
end
fclose(fileID);
