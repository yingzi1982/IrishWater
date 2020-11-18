#!/usr/bin/env octave

clear all
close all
clc
ARRAY_flag=1;
HARRAY_flag=0;
VARRAY_flag=0;

%receiver = load('../backup/receiver');
%topo = load('../backup/topo.xyz');
%depthShift=100;
%depth = abs(griddata(topo(:,1),topo(:,2),topo(:,3),receiver(:,1),receiver(:,2)));
%depth = (depth + depthShift);
[source_depth_status source_depth] = system('grep depth ../DATA/FORCESOLUTION | cut -d : -f 2');
source_depth = str2num(source_depth);
depth = -400;
%depth = source_depth;
[latorUTM_status latorUTM] = system('grep latorUTM ../DATA/FORCESOLUTION | cut -d : -f 2');
latorUTM_source = str2num(latorUTM);
latorUTM = latorUTM_source;

longorUTM  = [0:20:2500]';
stationNumber= length(longorUTM);
stationSize = size(longorUTM);

depth  = depth*ones(stationSize);

latorUTM   = latorUTM*ones(stationSize);
elevation  = zeros(stationSize);

burial = depth;
%The option USE_SOURCES_RECEIVERS_Z set to .true. will then discard the elevation and set burial as the z coordinate.

fileID = fopen(['../DATA/STATIONS'],'w');
for nStation = 1:stationNumber
  stationName = ['S' int2str(nStation)];
  networkName = ['ARRAY'];
  if ARRAY_flag
    fprintf(fileID,'%s  %s  %f  %f  %f  %f\n',stationName,networkName,latorUTM(nStation),longorUTM(nStation),elevation(nStation),burial(nStation));
  end
end
fclose(fileID);

mesh=dlmread('../backup/mesh.xyz');

x_mesh = mesh(:,1);
y_mesh = mesh(:,2);
z_mesh = mesh(:,3);

[dx_status dx] = system('grep dx ../backup/meshInformation | cut -d = -f 2');
dx = str2num(dx);
[dy_status dy] = system('grep dy ../backup/meshInformation | cut -d = -f 2');
dy = str2num(dy);
[dz_status dz] = system('grep dz ../backup/meshInformation | cut -d = -f 2');
dz = str2num(dz);

mask_water =dlmread('../backup/mask_water');
z_HARRAY = source_depth;
mask_HARRAY = mask_water & abs(z_mesh - z_HARRAY) < dz/2;
index_HARRAY = find(mask_HARRAY);
longorUTM = x_mesh(index_HARRAY);
latorUTM  = y_mesh(index_HARRAY);
depth     = z_mesh(index_HARRAY);
elevation = zeros(size(index_HARRAY));
stationNumber = length(index_HARRAY);
burial = depth;

fileID = fopen(['../DATA/STATIONS'],'a');
for nStation = 1:stationNumber
  stationName = ['S' int2str(nStation)];
  networkName = ['HARRAY'];
  if HARRAY_flag
    fprintf(fileID,'%s  %s  %f  %f  %f  %f\n',stationName,networkName,latorUTM(nStation),longorUTM(nStation),elevation(nStation),burial(nStation));
  end
end
fclose(fileID);

y_VARRAY = latorUTM_source;
mask_VARRAY = mask_water & abs(y_mesh - y_VARRAY) < dy/2;
index_VARRAY = find(mask_VARRAY);
longorUTM = x_mesh(index_VARRAY);
latorUTM  = y_mesh(index_VARRAY);
depth     = z_mesh(index_VARRAY);
elevation = zeros(size(index_VARRAY));
stationNumber = length(index_VARRAY);
burial = depth;

fileID = fopen(['../DATA/STATIONS'],'a');
for nStation = 1:stationNumber
  stationName = ['S' int2str(nStation)];
  networkName = ['VARRAY'];
  if VARRAY_flag
    fprintf(fileID,'%s  %s  %f  %f  %f  %f\n',stationName,networkName,latorUTM(nStation),longorUTM(nStation),elevation(nStation),burial(nStation));
  end
end
fclose(fileID);

if VARRAY_flag
  station_VS = [4000 - longorUTM latorUTM -depth];
  save('../backup/station_VS','-ascii','station_VS');
end
