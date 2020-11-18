#!/usr/bin/env octave

clear all
close all
clc

[nx_status nx] = system('grep nx ../backup/meshInformation | cut -d = -f 2');
nx = str2num(nx);
[ny_status ny] = system('grep ny ../backup/meshInformation | cut -d = -f 2');
ny = str2num(ny);
[nz_status nz] = system('grep nz ../backup/meshInformation | cut -d = -f 2');
nz = str2num(nz);

NREGIONS = nx*ny*nz;

fileID = fopen(['../backup/NREGIONS'],'w');
fprintf(fileID, 'NREGIONS = %i\n', NREGIONS);
fclose(fileID);

fileID = fopen(['../backup/regions'],'w');
for i = 1:nx
  for j = 1:ny
    for k = 1:nz
      fprintf(fileID, '%i %i %i %i %i %i %i\n', i,i,j,j,k,k,1);
    end
  end
end
fclose(fileID);
%--------------------------------------
