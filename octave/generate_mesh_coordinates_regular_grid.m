#!/usr/bin/env octave

clear all
close all
clc

[dx_status dx] = system('grep dx ../backup/meshInformation | cut -d = -f 2');
dx = str2num(dx);

[dy_status dy] = system('grep dy ../backup/meshInformation | cut -d = -f 2');
dy = str2num(dy);

[dz_status dz] = system('grep dz ../backup/meshInformation | cut -d = -f 2');
dz = str2num(dz);

[nx_status nx] = system('grep nx ../backup/meshInformation | cut -d = -f 2');
nx = str2num(nx);

[ny_status ny] = system('grep ny ../backup/meshInformation | cut -d = -f 2');
ny = str2num(ny);

[nz_status nz] = system('grep nz ../backup/meshInformation | cut -d = -f 2');
nz = str2num(nz);

[xmin_status xmin] = system('grep xmin ../backup/meshInformation | cut -d = -f 2');
xmin = str2num(xmin);

[ymin_status ymin] = system('grep ymin ../backup/meshInformation | cut -d = -f 2');
ymin = str2num(ymin);

[zmin_status zmin] = system('grep zmin ../backup/meshInformation | cut -d = -f 2');
zmin = str2num(zmin);

[xmax_status xmax] = system('grep xmax ../backup/meshInformation | cut -d = -f 2');
xmax = str2num(xmax);

[ymax_status ymax] = system('grep ymax ../backup/meshInformation | cut -d = -f 2');
ymax = str2num(ymax);

[zmax_status zmax] = system('grep zmax ../backup/meshInformation | cut -d = -f 2');
zmax = str2num(zmax);


mesh_dx=dx;
mesh_dy=dy;
mesh_dz=dz;

resample_rate=2;

mesh_x = [xmin+dx/2:mesh_dx:xmax-dx/2];
mesh_y = [ymin+dy/2:mesh_dy:ymax-dy/2];
mesh_z = [zmin+dz/2:mesh_dz:zmax-dz/2];

mesh_x_sparse = [xmin+dx:mesh_dx*2:xmax-dx];
mesh_y_sparse = [ymin+dy:mesh_dy*2:ymax-dy];
mesh_z_sparse = [zmin+dz:mesh_dz*2:zmax-dz];

fileID = fopen(['../backup/mesh_sparseInformation'],'w');
fprintf(fileID, 'xmin = %f\n', xmin);
fprintf(fileID, 'ymin = %f\n', ymin);
fprintf(fileID, 'zmin = %f\n', zmin);

fprintf(fileID, '\n');

fprintf(fileID, 'xmax = %f\n', xmax);
fprintf(fileID, 'ymax = %f\n', ymax);
fprintf(fileID, 'zmax = %f\n', zmax);

fprintf(fileID, '\n');

fprintf(fileID, 'dx = %f\n', dx*resample_rate);
fprintf(fileID, 'dy = %f\n', dy*resample_rate);
fprintf(fileID, 'dz = %f\n', dz*resample_rate);

fprintf(fileID, '\n');

fprintf(fileID, 'nx = %i\n', nx/resample_rate);
fprintf(fileID, 'ny = %i\n', ny/resample_rate);
fprintf(fileID, 'nz = %i\n', nz/resample_rate);
fclose(fileID);

%if(length(mesh_x)!=nx | length(mesh_y)!=ny | length(mesh_z)!=nz)
%error('check mesh element number!')
%end

[MESH_Z MESH_Y MESH_X] = ndgrid(mesh_z,mesh_y,mesh_x);
mesh = [reshape(MESH_X,[],1) reshape(MESH_Y,[],1) reshape(MESH_Z,[],1)];
save("-ascii",['../backup/mesh.xyz'],'mesh');

[MESH_Z_SPARSE MESH_Y_SPARSE MESH_X_SPARSE] = ndgrid(mesh_z_sparse,mesh_y_sparse,mesh_x_sparse);
mesh_sparse = [reshape(MESH_X_SPARSE,[],1) reshape(MESH_Y_SPARSE,[],1) reshape(MESH_Z_SPARSE,[],1)];
save("-ascii",['../backup/mesh_sparse.xyz'],'mesh_sparse');
