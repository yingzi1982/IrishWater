#!/usr/bin/env octave

clear all
close all
clc

[xmin_status xmin] = system('grep LONGITUDE_MIN ../backup/Mesh_Par_file.part | cut -d = -f 2');
xmin = str2num(xmin);
[xmax_status xmax] = system('grep LONGITUDE_MAX ../backup/Mesh_Par_file.part | cut -d = -f 2');
xmax = str2num(xmax);
[nx_status nx] = system('grep NEX_XI ../backup/Mesh_Par_file.part | cut -d = -f 2');
nx = str2num(nx);

[ymin_status ymin] = system('grep LATITUDE_MIN ../backup/Mesh_Par_file.part | cut -d = -f 2');
ymin = str2num(ymin);
[ymax_status ymax] = system('grep LATITUDE_MAX ../backup/Mesh_Par_file.part | cut -d = -f 2');
ymax = str2num(ymax);
[ny_status ny] = system('grep NEX_ETA ../backup/Mesh_Par_file.part | cut -d = -f 2');
ny = str2num(ny);

[DEPTH_BLOCK_KM_status DEPTH_BLOCK_KM] = system('grep DEPTH_BLOCK_KM ../backup/Mesh_Par_file.part | cut -d = -f 2');
DEPTH_BLOCK_KM = str2num(DEPTH_BLOCK_KM);
zmin=-1000*DEPTH_BLOCK_KM;

dx = (xmax-xmin)/nx;
dy = (ymax-ymin)/ny;
dz = min(dx,dy);
%dz = 20;

nxInterface = nx+1;
nyInterface = ny+1;

x = linspace(xmin,xmax,nxInterface);
y = linspace(ymin,ymax,nyInterface);
[X Y] = meshgrid(x,y);

topInterface = [0.0*ones(size(X))];
bottomInterface = [zmin*ones(size(X))];

dlmwrite('../backup/top_interface',topInterface,' ');
dlmwrite('../backup/bottom_interface',bottomInterface,' ');

% interfaces numbered from bottom to top; mesh top interface and seperating interfaces;
topInterface = transpose(topInterface);
interfaces = [topInterface(:)];
interfaceNumber = columns(interfaces);
zmax = max(interfaces(:));

[INTERFACES_FILE_status INTERFACES_FILE] = system('grep INTERFACES_FILE ../backup/Mesh_Par_file.part | cut -d = -f 2');
INTERFACES_FILE = strtrim(INTERFACES_FILE);
[SUPPRESS_UTM_PROJECTION_status SUPPRESS_UTM_PROJECTION] = system('grep SUPPRESS_UTM_PROJECTION ../backup/Par_file | cut -d = -f 2');
SUPPRESS_UTM_PROJECTION = strtrim(SUPPRESS_UTM_PROJECTION);

fileID = fopen(['../DATA/meshfem3D_files/' INTERFACES_FILE],'w');

fprintf(fileID, '%i\n', interfaceNumber);

for i = 1:interfaceNumber
  fprintf(fileID, '%s %i %i %f %f %f %f\n', SUPPRESS_UTM_PROJECTION, nxInterface, nyInterface, xmin, ymin, dx, dy);
  interfaceName = ['interface_' int2str(i)];
  fprintf(fileID, '%s\n',interfaceName);
  iInterface = interfaces(:,i);
  save("-ascii",['../DATA/meshfem3D_files/' interfaceName],'iInterface')
end

NZ = zeros(interfaceNumber,1);

for i = 1:interfaceNumber
  if (i == 1)
  iLowest = zmin;
  else
  iLowest = min(interfaces(:,i-1));
  end
  iHighest = max(interfaces(:,i));
  NZ(i) = round((iHighest - iLowest)/dz);
  fprintf(fileID, '%i\n',NZ(i));
end
fclose(fileID);
%--------------------------------------
nz = sum(NZ);


fileID = fopen(['../backup/meshInformation'],'w');
fprintf(fileID, 'xmin = %f\n', xmin);
fprintf(fileID, 'ymin = %f\n', ymin);
fprintf(fileID, 'zmin = %f\n', zmin);

fprintf(fileID, '\n');

fprintf(fileID, 'xmax = %f\n', xmax);
fprintf(fileID, 'ymax = %f\n', ymax);
fprintf(fileID, 'zmax = %f\n', zmax);

fprintf(fileID, '\n');

fprintf(fileID, 'dx = %f\n', dx);
fprintf(fileID, 'dy = %f\n', dy);
fprintf(fileID, 'dz = %f\n', dz);

fprintf(fileID, '\n');

fprintf(fileID, 'nx = %i\n', nx);
fprintf(fileID, 'ny = %i\n', ny);
fprintf(fileID, 'nz = %i\n', nz);
fclose(fileID);
