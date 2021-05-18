#!/usr/bin/env octave

clear all
close all
clc

ARRAY_flag =0;
LARRAY_flag=0;
HBVARRAY_flag=1;

backup_folder=['../backup/'];
%signal_folder=['../OUTPUT_FILES/'];
signal_folder=['/ichec/work/ngear019b/yingzi/irishWater/OUTPUT_FILES/'];

source_signal = load([backup_folder 'plot_source_time_function.txt']);
t = source_signal(:,1);
s = source_signal(:,2);

resample_rate=4;

octaveFreq=load(['../backup/octaveFreq']);
source_signal_octavePSD = octavePSD([t(1:resample_rate:end) s(1:resample_rate:end,:)],octaveFreq);

startRowNumber=0;
startColumnNumber=1;

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
band='.FXP.semp';
%------------------------------------
if ARRAY_flag
  ARRAY_index=find(strcmp("ARRAY",networkName));
  ARRAY_stationNumber=length(ARRAY_index);

  for nStation = 1:ARRAY_stationNumber
    copyfile ([signal_folder networkName{ARRAY_index(nStation)} '.' stationName{ARRAY_index(nStation)} band], [backup_folder]);
  end
end
%------------------------------------
if LARRAY_flag
  LARRAY_index=find(strcmp("LARRAY",networkName));
  LARRAY_stationNumber=length(LARRAY_index);


  LARRAY_x = longorUTM(LARRAY_index);
  LARRAY_y = latorUTM(LARRAY_index);
  left_range_index = find(LARRAY_x<=0);
  right_range_index = find(LARRAY_x>0);
  left_range = sqrt(LARRAY_x(left_range_index).^2+LARRAY_y(left_range_index).^2);
  right_range = -sqrt(LARRAY_x(right_range_index).^2+LARRAY_y(right_range_index).^2);
  LARRAY_range = [left_range;right_range];

  LARRAY=[];
  LARRAY = [t(1:resample_rate:end) LARRAY];

  for nStation = 1:LARRAY_stationNumber
    signal = dlmread([signal_folder networkName{LARRAY_index(nStation)} '.' stationName{LARRAY_index(nStation)} band],'',startRowNumber,startColumnNumber);
    LARRAY = [LARRAY signal((1:resample_rate:end))];
  end
LARRAY_nt = 1000;
[LARRAY_trace]=trace2image(LARRAY,LARRAY_nt,LARRAY_range);
dlmwrite('../backup/LARRAY_trace_image',LARRAY_trace,' ');
end

%------------------------------------
if HBVARRAY_flag
  snapshot_start=500;
  snapshot_step =500;
  snapshot_end=length(t);
  snapshot_index = round([snapshot_start:snapshot_step:snapshot_end]/resample_rate);
  snapshot_number = length(snapshot_index);

  dlmwrite('../backup/snapshotTimeIndex',[snapshot_start snapshot_step snapshot_end],' ');

  HBVARRAY_set = {'HARRAY','BARRAY','VARRAY'};
  for nHBVARRAY=1:length(HBVARRAY_set)
    ARRAY_name=HBVARRAY_set{nHBVARRAY};
    ARRAY_index=find(strcmp(ARRAY_name,networkName));
    ARRAY_stationNumber=length(ARRAY_index);

    ARRAY=[];
    for nStation = 1:ARRAY_stationNumber
        signal = dlmread([signal_folder networkName{ARRAY_index(nStation)} '.' stationName{ARRAY_index(nStation)} band],'',startRowNumber,startColumnNumber);
        ARRAY = [ARRAY signal(1:resample_rate:end)];
    end

    snapshots = ARRAY(snapshot_index,:);
    snapshots = transpose(snapshots);
    dlmwrite(['../backup/snapshots_' ARRAY_name],snapshots,' ');

    ARRAY_octavePSD = octavePSD([t(1:resample_rate:end) ARRAY],octaveFreq);
    transmissionLossPSD = -(ARRAY_octavePSD - source_signal_octavePSD);
    transmissionLossPSD = transpose(transmissionLossPSD);
    dlmwrite(['../backup/transmissionLossPSD_' ARRAY_name],transmissionLossPSD,' ');
  end
end
