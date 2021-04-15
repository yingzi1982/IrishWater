#!/usr/bin/env octave

clear all
close all
clc

ARRAY_flag=1;
LARRAY_flag=0;
HARRAY_flag=1;
BARRAY_flag=1;
VARRAY_flag=1;

rc=load('../backup/rc_utm');
rc_longorUTM = rc(:,1);
rc_latorUTM = rc(:,2);
rc_burial=-150;

sr=load('../backup/sr_utm');
sr_longorUTM = sr(:,1);
sr_latorUTM = sr(:,2);

k=(sr_latorUTM-rc_latorUTM)/(sr_longorUTM -rc_longorUTM);
%------------------------------------------------------------
[nx_status nx] = system('grep nx ../backup/mesh_sparseInformation | cut -d = -f 2');
nx = str2num(nx);
[xmin_status xmin] = system('grep xmin ../backup/mesh_sparseInformation | cut -d = -f 2');
xmin = str2num(xmin);
[xmax_status xmax] = system('grep xmax ../backup/mesh_sparseInformation | cut -d = -f 2');
xmax = str2num(xmax);

[ny_status ny] = system('grep ny ../backup/mesh_sparseInformation | cut -d = -f 2');
ny = str2num(ny);
[ymin_status ymin] = system('grep ymin ../backup/mesh_sparseInformation | cut -d = -f 2');
ymin = str2num(ymin);
[ymax_status ymax] = system('grep ymax ../backup/mesh_sparseInformation | cut -d = -f 2');
ymax = str2num(ymax);
[dy_status dy] = system('grep dy ../backup/mesh_sparseInformation | cut -d = -f 2');
dy = str2num(dy);

[nz_status nz] = system('grep nz ../backup/mesh_sparseInformation | cut -d = -f 2');
nz = str2num(nz);
[zmin_status zmin] = system('grep zmin ../backup/mesh_sparseInformation | cut -d = -f 2');
zmin = str2num(zmin);
[zmax_status zmax] = system('grep zmax ../backup/mesh_sparseInformation | cut -d = -f 2');
zmax = str2num(zmax);
[dz_status dz] = system('grep dz ../backup/mesh_sparseInformation | cut -d = -f 2');
dz = str2num(dz);
x=linspace(xmin, xmax, nx);
y=linspace(ymin, ymax, ny);
z=linspace(zmin, zmax, nz);
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
[X Y] =meshgrid(x,y);
x_mesh = reshape(X,[],1);
y_mesh = reshape(Y,[],1);
z_mesh = ones(size(x_mesh))*HARRAY_burial;
longorUTM = x_mesh;
latorUTM  = y_mesh;
burial    = z_mesh;
elevation = zeros(size(x_mesh));
stationNumber = length(x_mesh);

fileID = fopen(['../DATA/STATIONS'],'a');
for nStation = 1:stationNumber
  stationName = ['S' int2str(nStation)]; networkName = ['HARRAY'];
  if HARRAY_flag
    fprintf(fileID,'%s  %s  %f  %f  %f  %f\n',stationName,networkName,latorUTM(nStation),longorUTM(nStation),elevation(nStation),burial(nStation));
  end
end
fclose(fileID);
%---------------------------------------------------------
[X Y] = meshgrid(x,y);
water_sediment_interface=load('../backup/water_sediment_interface');
Z = griddata (water_sediment_interface(:,1), water_sediment_interface(:,2), water_sediment_interface(:,3), X, Y,'nearest');
Z = Z + dz;

x_mesh = reshape(X,[],1);
y_mesh = reshape(Y,[],1);
z_mesh = reshape(Z,[],1);

longorUTM = x_mesh;
latorUTM  = y_mesh;
burial    = z_mesh;
elevation = zeros(size(x_mesh));
stationNumber = length(x_mesh);

fileID = fopen(['../DATA/STATIONS'],'a');
for nStation = 1:stationNumber
  stationName = ['S' int2str(nStation)]; networkName = ['BARRAY'];
  if BARRAY_flag
    fprintf(fileID,'%s  %s  %f  %f  %f  %f\n',stationName,networkName,latorUTM(nStation),longorUTM(nStation),elevation(nStation),burial(nStation));
  end
end
fclose(fileID);
%---------------------------------------------------------
[X Z] = meshgrid(x,z);
Y=X*(sr_latorUTM-rc_latorUTM)/(sr_longorUTM-rc_longorUTM);

x_mesh = reshape(X,[],1);
y_mesh = reshape(Y,[],1);
z_mesh = reshape(Z,[],1);

longorUTM = x_mesh;
latorUTM  = y_mesh;
burial    = z_mesh;
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
