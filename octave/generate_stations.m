#!/usr/bin/env octave

clear all
close all
clc

RARRAY_flag=1;
SARRAY_flag=1;
LARRAY_flag=1;
HARRAY_flag=0;
BARRAY_flag=0;
VARRAY_flag=0;

rc=load('../backup/rc_utm');
rc_longorUTM = rc(:,1);
rc_latorUTM = rc(:,2);

rc_burial=-150;

sr=load('../backup/sr_utm');
sr_longorUTM = sr(:,1);
sr_latorUTM = sr(:,2);

k=(sr_latorUTM-rc_latorUTM)/(sr_longorUTM -rc_longorUTM);

water_sediment_interface=load('../backup/water_sediment_interface');
%------------------------------------------------------------
[nx_status nx] = system('grep nx ../backup/meshInformation | cut -d = -f 2');
nx = str2num(nx);
[xmin_status xmin] = system('grep xmin ../backup/meshInformation | cut -d = -f 2');
xmin = str2num(xmin);
[xmax_status xmax] = system('grep xmax ../backup/meshInformation | cut -d = -f 2');
xmax = str2num(xmax);
[dx_status dx] = system('grep dx ../backup/meshInformation | cut -d = -f 2');
dx = str2num(dx);

[ny_status ny] = system('grep ny ../backup/meshInformation | cut -d = -f 2');
ny = str2num(ny);
[ymin_status ymin] = system('grep ymin ../backup/meshInformation | cut -d = -f 2');
ymin = str2num(ymin);
[ymax_status ymax] = system('grep ymax ../backup/meshInformation | cut -d = -f 2');
ymax = str2num(ymax);
[dy_status dy] = system('grep dy ../backup/meshInformation | cut -d = -f 2');
dy = str2num(dy);

[nz_status nz] = system('grep nz ../backup/meshInformation | cut -d = -f 2');
nz = str2num(nz);
[zmin_status zmin] = system('grep zmin ../backup/meshInformation | cut -d = -f 2');
zmin = str2num(zmin);
[zmax_status zmax] = system('grep zmax ../backup/meshInformation | cut -d = -f 2');
zmax = str2num(zmax);
[dz_status dz] = system('grep dz ../backup/meshInformation | cut -d = -f 2');
dz = str2num(dz);

[THICKNESS_OF_X_PML_status THICKNESS_OF_X_PML] = system('grep THICKNESS_OF_X_PML ../backup/Mesh_Par_file.part | cut -d = -f 2');
THICKNESS_OF_X_PML = str2num(THICKNESS_OF_X_PML);
[THICKNESS_OF_Y_PML_status THICKNESS_OF_Y_PML] = system('grep THICKNESS_OF_Y_PML ../backup/Mesh_Par_file.part | cut -d = -f 2');
THICKNESS_OF_Y_PML = str2num(THICKNESS_OF_Y_PML);
[THICKNESS_OF_Z_PML_status THICKNESS_OF_Z_PML] = system('grep THICKNESS_OF_Z_PML ../backup/Mesh_Par_file.part | cut -d = -f 2');
THICKNESS_OF_Z_PML = str2num(THICKNESS_OF_Z_PML);
%---------------------------------------------------------
resample_rate=2;
%resample_rate=3;
x_mesh = [xmin+THICKNESS_OF_X_PML+dx:dx*resample_rate:xmax-THICKNESS_OF_X_PML-dx];
y_mesh = [ymin+THICKNESS_OF_Y_PML+dy:dy*resample_rate:ymax-THICKNESS_OF_Y_PML-dy];
z_mesh = [zmin+THICKNESS_OF_Z_PML+dz:dz*resample_rate:zmax];
%---------------------------------------------------------
longorUTM = [rc_longorUTM];
latorUTM = [rc_latorUTM];
stationNumber= length(longorUTM);
stationSize = size(longorUTM);
burial = rc_burial;
elevation  = zeros(stationSize);

fileID = fopen(['../DATA/STATIONS'],'w');
for nStation = 1:stationNumber
  stationName = ['S' int2str(nStation)];
  networkName = ['RARRAY'];
  if RARRAY_flag
    fprintf(fileID,'%s  %s  %f  %f  %f  %f\n',stationName,networkName,latorUTM(nStation),longorUTM(nStation),elevation(nStation),burial(nStation));
  end
end
fclose(fileID);

%---------------------------------------------------------
longorUTM = [0];
latorUTM = [0];
stationNumber= length(longorUTM);
stationSize = size(longorUTM);
burial = -7;
elevation  = zeros(stationSize);

fileID = fopen(['../DATA/STATIONS'],'a');
for nStation = 1:stationNumber
  stationName = ['S' int2str(nStation)];
  networkName = ['SARRAY'];
  if SARRAY_flag
    fprintf(fileID,'%s  %s  %f  %f  %f  %f\n',stationName,networkName,latorUTM(nStation),longorUTM(nStation),elevation(nStation),burial(nStation));
  end
end
fclose(fileID);
%---------------------------------------------------------
LARRAY_depth=[-25 -75 rc_burial];
for i = 1:length(LARRAY_depth)

longorUTM  = x_mesh;
latorUTM   = longorUTM*k;
stationNumber= length(longorUTM);
stationSize = size(longorUTM);

longorUTM = [longorUTM];
latorUTM = [latorUTM];
burial = [LARRAY_depth(i)*ones(stationSize)];
elevation  = [zeros(stationSize)];


%The option USE_SOURCES_RECEIVERS_Z set to .true. will then discard the elevation and set burial as the z coordinate.

fileID = fopen(['../DATA/STATIONS'],'a');
for nStation = 1:stationNumber
  stationName = ['S' int2str(nStation)];
  networkName = ['LARRAY' int2str(-LARRAY_depth(i))];
  if LARRAY_flag
    fprintf(fileID,'%s  %s  %f  %f  %f  %f\n',stationName,networkName,latorUTM(nStation),longorUTM(nStation),elevation(nStation),burial(nStation));
  end
end
fclose(fileID);
end

%---------------------------------------------------------
[X_MESH Y_MESH Z_MESH] =meshgrid(x_mesh,y_mesh,rc_burial);

longorUTM = reshape(X_MESH,[],1);
latorUTM  = reshape(Y_MESH,[],1);
burial = reshape(Z_MESH,[],1);
stationNumber= length(longorUTM);
stationSize = size(longorUTM);
elevation  = zeros(stationSize);

fileID = fopen(['../DATA/STATIONS'],'a');
for nStation = 1:stationNumber
  stationName = ['S' int2str(nStation)]; networkName = ['HARRAY'];
  if HARRAY_flag
    fprintf(fileID,'%s  %s  %f  %f  %f  %f\n',stationName,networkName,latorUTM(nStation),longorUTM(nStation),elevation(nStation),burial(nStation));
  end
end
fclose(fileID);
%---------------------------------------------------------
[X_MESH Y_MESH] = meshgrid(x_mesh,y_mesh);
Z_MESH = griddata (water_sediment_interface(:,1), water_sediment_interface(:,2), water_sediment_interface(:,3), X_MESH, Y_MESH);
Z_MESH = Z_MESH + resample_rate*dz;

longorUTM = reshape(X_MESH,[],1);
latorUTM  = reshape(Y_MESH,[],1);
burial    = reshape(Z_MESH,[],1);
stationNumber= length(longorUTM);
stationSize = size(longorUTM);
elevation  = zeros(stationSize);

fileID = fopen(['../DATA/STATIONS'],'a');
for nStation = 1:stationNumber
  stationName = ['S' int2str(nStation)]; networkName = ['BARRAY'];
  if BARRAY_flag
    fprintf(fileID,'%s  %s  %f  %f  %f  %f\n',stationName,networkName,latorUTM(nStation),longorUTM(nStation),elevation(nStation),burial(nStation));
  end
end
fclose(fileID);
%---------------------------------------------------------
[X_MESH Z_MESH] = meshgrid(x_mesh,z_mesh);
Y_MESH=X_MESH*(sr_latorUTM-rc_latorUTM)/(sr_longorUTM-rc_longorUTM);

longorUTM = reshape(X_MESH,[],1);
latorUTM  = reshape(Y_MESH,[],1);
burial    = reshape(Z_MESH,[],1);
stationNumber= length(longorUTM);
stationSize = size(longorUTM);
elevation  = zeros(stationSize);

fileID = fopen(['../DATA/STATIONS'],'a');
for nStation = 1:stationNumber
  stationName = ['S' int2str(nStation)];
  networkName = ['VARRAY'];
  if VARRAY_flag
    fprintf(fileID,'%s  %s  %f  %f  %f  %f\n',stationName,networkName,latorUTM(nStation),longorUTM(nStation),elevation(nStation),burial(nStation));
  end
end
fclose(fileID);
