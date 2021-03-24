#!/usr/bin/env octave

clear all
close all
clc

ARRAY_flag=1;
LARRAY_flag=0;
HARRAY_flag=1;
BARRAY_flag=1;
VARRAY_flag=1;

[longorUTM_status longorUTM] = system('grep longorUTM ../DATA/FORCESOLUTION | cut -d : -f 2');
sr_longorUTM = str2num(longorUTM);
[latorUTM_status latorUTM] = system('grep latorUTM ../DATA/FORCESOLUTION | cut -d : -f 2');
sr_latorUTM = str2num(latorUTM);

rc=load('../backup/rc_utm');
rc_longorUTM = rc(:,1);
rc_latorUTM = rc(:,2);
rc_burial=-150;

mask_water =dlmread('../backup/mask_water_sparse');
mask_water_bathymetry =dlmread('../backup/mask_water_bathymetry_sparse');
mesh=dlmread('../backup/mesh_sparse.xyz');

x_mesh = mesh(:,1);
y_mesh = mesh(:,2);
z_mesh = mesh(:,3);

[dx_status dx] = system('grep dx ../backup/mesh_sparseInformation | cut -d = -f 2');
dx = str2num(dx);
[dy_status dy] = system('grep dy ../backup/mesh_sparseInformation | cut -d = -f 2');
dy = str2num(dy);
[dz_status dz] = system('grep dz ../backup/mesh_sparseInformation | cut -d = -f 2');
dz = str2num(dz);
%---------------------------------------------------------
longorUTM = rc_longorUTM;
latorUTM = rc_latorUTM;
stationNumber= length(longorUTM);
stationSize = size(longorUTM);
burial = rc_burial*ones(stationSize);
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

%---------------------------------------------------------
HARRAY_burial = -150;
z_HARRAY = HARRAY_burial;
mask_HARRAY = mask_water & z_mesh <= z_HARRAY & z_mesh > z_HARRAY -dz;
index_HARRAY = find(mask_HARRAY);
longorUTM = x_mesh(index_HARRAY);
latorUTM  = y_mesh(index_HARRAY);
burial     = z_mesh(index_HARRAY);
elevation = zeros(size(index_HARRAY));
stationNumber = length(index_HARRAY);

fileID = fopen(['../DATA/STATIONS'],'a');
for nStation = 1:stationNumber
  stationName = ['S' int2str(nStation)]; networkName = ['HARRAY'];
  if HARRAY_flag
    fprintf(fileID,'%s  %s  %f  %f  %f  %f\n',stationName,networkName,latorUTM(nStation),longorUTM(nStation),elevation(nStation),burial(nStation));
  end
end
fclose(fileID);
%---------------------------------------------------------
mask_BARRAY = mask_water_bathymetry;
index_BARRAY = find(mask_BARRAY);
longorUTM = x_mesh(index_BARRAY);
latorUTM  = y_mesh(index_BARRAY);
burial     = z_mesh(index_BARRAY);
elevation = zeros(size(index_BARRAY));
stationNumber = length(index_BARRAY);

fileID = fopen(['../DATA/STATIONS'],'a');
for nStation = 1:stationNumber
  stationName = ['S' int2str(nStation)]; networkName = ['BARRAY'];
  if BARRAY_flag
    fprintf(fileID,'%s  %s  %f  %f  %f  %f\n',stationName,networkName,latorUTM(nStation),longorUTM(nStation),elevation(nStation),burial(nStation));
  end
end
fclose(fileID);
%---------------------------------------------------------
k=(sr_latorUTM-rc_latorUTM)/(sr_longorUTM-rc_longorUTM);

mask_VARRAY = mask_water & y_mesh >= x_mesh*k & y_mesh < x_mesh*k+dy;
index_VARRAY = find(mask_VARRAY);
longorUTM = x_mesh(index_VARRAY);
latorUTM  = y_mesh(index_VARRAY);
burial     = z_mesh(index_VARRAY);
elevation = zeros(size(index_VARRAY));
stationNumber = length(index_VARRAY);

fileID = fopen(['../DATA/STATIONS'],'a');
for nStation = 1:stationNumber
  stationName = ['S' int2str(nStation)];
  networkName = ['VARRAY'];
  if VARRAY_flag
    fprintf(fileID,'%s  %s  %f  %f  %f  %f\n',stationName,networkName,latorUTM(nStation),longorUTM(nStation),elevation(nStation),burial(nStation));
  end
end
fclose(fileID);
