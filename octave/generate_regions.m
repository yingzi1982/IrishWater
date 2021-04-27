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

fileID = fopen(['../backup/NREGIONS'],'W');
fprintf(fileID, 'NREGIONS = %i\n', NREGIONS);
fclose(fileID);

nx =[1:nx];
ny =[1:ny];
nz =[1:nz];

[NZ NY NX] = ndgrid(nz,ny,nx);

regions = [repmat(reshape(NX,[],1),1,2) repmat(reshape(NY,[],1),1,2) repmat(reshape(NZ,[],1),1,2)];

fmt = [repmat(' %d',1,6),'\n'];
fileID = fopen(['../backup/regions.part'],'W');
  fprintf(fileID,fmt, regions.')
fclose(fileID);
