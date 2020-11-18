#!/usr/bin/env octave

clear all
close all
clc

[nx_status nx] = system('grep nx ../backup/meshInformation | cut -d = -f 2');
nx = str2num(nx);
[xmin_status xmin] = system('grep xmin ../backup/meshInformation | cut -d = -f 2');
xmin = str2num(xmin);
[xmax_status xmax] = system('grep xmax ../backup/meshInformation | cut -d = -f 2');
xmax = str2num(xmax);

[ny_status ny] = system('grep ny ../backup/meshInformation | cut -d = -f 2');
ny = str2num(ny);
[ymin_status ymin] = system('grep ymin ../backup/meshInformation | cut -d = -f 2');
ymin = str2num(ymin);
[ymax_status ymax] = system('grep ymax ../backup/meshInformation | cut -d = -f 2');
ymax = str2num(ymax);
[dy_status dy] = system('grep dy ../backup/meshInformation | cut -d = -f 2');
dy = str2num(dy);

x = linspace(xmin,xmax,nx+1);
y = linspace(ymin,ymax,ny+1);

[latorUTM_status latorUTM] = system('grep latorUTM ../DATA/FORCESOLUTION | cut -d : -f 2');
latorUTM = str2num(latorUTM);
y_slice=latorUTM;
slice_index = find(abs(y-y_slice)<1/4*dy);

[X Y] = meshgrid(x,y);

%interface = griddata (x, y, z, X, Y);
water_sediment_interface = 0.5*X-2000;

top_interface = dlmread('../backup/top_interface');
bottom_interface = dlmread('../backup/bottom_interface');

top_interface_slice = [x; top_interface(slice_index,:)]';
bottom_interface_slice = [x; bottom_interface(slice_index,:)]';
water_sediment_interface_slice = [x; water_sediment_interface(slice_index,:)]';
water_polygon = [top_interface_slice;flipud(water_sediment_interface_slice)];
sediment_polygon = [water_sediment_interface_slice;flipud(bottom_interface_slice)];

dlmwrite('../backup/water_sediment_interface_slice',water_sediment_interface_slice,' ');

dlmwrite('../backup/water_polygon',water_polygon,' ');
dlmwrite('../backup/sediment_polygon',sediment_polygon,' ');

mesh=dlmread('../backup/mesh.xyz');

x_mesh = mesh(:,1);
y_mesh = mesh(:,2);
z_mesh = mesh(:,3);

z_mesh_interp_on_water_sediment_interface = interp2(X,Y,water_sediment_interface, x_mesh,y_mesh);

mask_water = z_mesh > z_mesh_interp_on_water_sediment_interface;
mask_sediment = z_mesh <= z_mesh_interp_on_water_sediment_interface;
dlmwrite('../backup/mask_water',mask_water,' ');

regionsMaterialNumbering = ones(rows(mesh),1);
regionsMaterialNumbering(find(mask_water)) = 1;
regionsMaterialNumbering(find(mask_sediment)) = 2;

regions=load('../backup/regions');
regions = [regions(:,[1:6]) regionsMaterialNumbering];

dlmwrite('../backup/regions',regions,' ');
