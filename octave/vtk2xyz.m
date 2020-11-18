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

nx2 = nx*2 + 1;
ny2 = ny*2 + 1;
nz2 = nz*2 + 1;

index = zeros(nx*ny*nz,1);

for i = 1:nx
  for j = 1:ny
    for k = 1:nz
      %center points
      %i2 = 2*i;
      %j2 = 2*j;
      %k2 = 2*k;

      %corner points
      i2 = 2*i + 1;
      j2 = 2*j + 1;
      k2 = 2*k + 1;
      index(k+(j-1)*nz+(i-1)*nz*ny) = k2 + (j2-1)*nz2 + (i2-1)*nz2*ny2;
    end
  end
end
%--------------------------------------
vtkFile='../DATABASES_MPI/proc000000_mesh.vtk';
vtkHeaderLineNumber=5;
[pointNumber_status pointNumber] = system(['cat ' vtkFile ' | grep -m 1 POINTS | awk ''{print $2}''']);
pointNumber = str2num(pointNumber);

mesh=dlmread(vtkFile,'',[vtkHeaderLineNumber 0 vtkHeaderLineNumber+pointNumber-1 2]);

mesh = mesh(index,:);
save("-ascii",['../backup/mesh.xyz'],'mesh');
