#!/usr/bin/env octave

clear all
close all
clc

ARRAY_flag=1;
LARRAY_flag=0;
HARRAY_flag=1;
BARRAY_flag=1;
VARRAY_flag=1;

HARRAY_depth = -150;

%receiver = load('../backup/receiver');
%topo = load('../backup/topo.xyz');
%depthShift=100;
%depth = abs(griddata(topo(:,1),topo(:,2),topo(:,3),receiver(:,1),receiver(:,2)));
%depth = (depth + depthShift);
%[source_depth_status source_depth] = system('grep depth ../DATA/FORCESOLUTION | cut -d : -f 2');
%source_depth = str2num(source_depth);
%depth = source_depth;
[latorUTM_status latorUTM] = system('grep latorUTM ../DATA/FORCESOLUTION | cut -d : -f 2');
latorUTM_source = str2num(latorUTM);
latorUTM = latorUTM_source;

%---------------------------------------------------------
rc=load('../backup/rc_utm');
longorUTM = rc(:,1);
latorUTM = rc(:,2);
stationNumber= length(longorUTM);
stationSize = size(longorUTM);
burial = -150*ones(stationSize);
elevation  = zeros(stationSize);

fileID = fopen(['../DATA/STATIONS'],'w');
for nStation = 1:stationNumber
  stationName = ['S' int2str(nStation)];
  networkName = ['ARRAY'];
  if ARRAY_flag
    fprintf(fileID,'%s  %s  %f  %f  %f  %f\n',stationName,networkName,latorUTM(nStation),longorUTM(nStation),elevation(nStation),burial(nStation));
  end
end
fclose(fileID);
%---------------------------------------------------------
longorUTM  = [1500:500:4000]';
stationNumber= length(longorUTM);
stationSize = size(longorUTM);

latorUTM   = latorUTM*ones(stationSize);
burial = -150*ones(stationSize);
elevation  = zeros(stationSize);

%The option USE_SOURCES_RECEIVERS_Z set to .true. will then discard the elevation and set burial as the z coordinate.

fileID = fopen(['../DATA/STATIONS'],'a');
for nStation = 1:stationNumber
  stationName = ['S' int2str(nStation)];
  networkName = ['LARRAY'];
  if LARRAY_flag
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


%---------------------------------------------------------
mask_water =dlmread('../backup/mask_water');
z_HARRAY = HARRAY_depth;
mask_HARRAY = mask_water & z_mesh <= z_HARRAY & z_mesh > z_HARRAY -dz;
index_HARRAY = find(mask_HARRAY);
longorUTM = x_mesh(index_HARRAY);
latorUTM  = y_mesh(index_HARRAY);
depth     = z_mesh(index_HARRAY);
elevation = zeros(size(index_HARRAY));
stationNumber = length(index_HARRAY);
burial = depth;

fileID = fopen(['../DATA/STATIONS'],'a');
for nStation = 1:stationNumber
  stationName = ['S' int2str(nStation)]; networkName = ['HARRAY'];
  if HARRAY_flag
    fprintf(fileID,'%s  %s  %f  %f  %f  %f\n',stationName,networkName,latorUTM(nStation),longorUTM(nStation),elevation(nStation),burial(nStation));
  end
end
fclose(fileID);
%---------------------------------------------------------
mask_water_bathymetry =dlmread('../backup/mask_water_bathymetry');
mask_BARRAY = mask_water_bathymetry;
index_BARRAY = find(mask_BARRAY);
longorUTM = x_mesh(index_BARRAY);
latorUTM  = y_mesh(index_BARRAY);
depth     = z_mesh(index_BARRAY);
elevation = zeros(size(index_BARRAY));
stationNumber = length(index_BARRAY);
burial = depth;

fileID = fopen(['../DATA/STATIONS'],'a');
for nStation = 1:stationNumber
  stationName = ['S' int2str(nStation)]; networkName = ['BARRAY'];
  if BARRAY_flag
    fprintf(fileID,'%s  %s  %f  %f  %f  %f\n',stationName,networkName,latorUTM(nStation),longorUTM(nStation),elevation(nStation),burial(nStation));
  end
end
fclose(fileID);
%---------------------------------------------------------

y_VARRAY = latorUTM_source;
mask_VARRAY = mask_water & y_mesh <= y_VARRAY & y_mesh > y_VARRAY -dy;
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
