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

[nz_status nz] = system('grep nz ../backup/meshInformation | cut -d = -f 2');
nz = str2num(nz);
[zmin_status zmin] = system('grep zmin ../backup/meshInformation | cut -d = -f 2');
zmin = str2num(zmin);
[zmax_status zmax] = system('grep zmax ../backup/meshInformation | cut -d = -f 2');
zmax = str2num(zmax);
[dz_status dz] = system('grep dz ../backup/meshInformation | cut -d = -f 2');
dz = str2num(dz);

x = linspace(xmin,xmax,nx+1);
y = linspace(ymin,ymax,ny+1);

[latorUTM_status latorUTM] = system('grep latorUTM ../DATA/FORCESOLUTION | cut -d : -f 2');
latorUTM = str2num(latorUTM);
y_slice=latorUTM;
interface_slice_index = find(abs(y-y_slice)<1/4*dy);

[X Y] = meshgrid(x,y);

topo=load('../backup/topo.xyz');
TOPO = griddata (topo(:,1), topo(:,2), topo(:,3), X, Y,'linear');
sed=load('../backup/sed.xyz');
SED = griddata (sed(:,1), sed(:,2), sed(:,3), X, Y,'linear');
SED = TOPO - SED;

topo_min = min(TOPO(:));
topo_max = max(TOPO(:));

sed_min = min(SED(:));
sed_max = max(SED(:));

fileID = fopen(['../backup/interfaceInformation'],'w');
fprintf(fileID, 'topo_min = %f\n', topo_min);
fprintf(fileID, 'topo_max = %f\n', topo_max);
fprintf(fileID, '\n');
fprintf(fileID, 'sed_min = %f\n', sed_min);
fprintf(fileID, 'sed_max = %f\n', sed_max);
fclose(fileID)

water_sediment_interface = TOPO;
sediment_rock_interface = SED;

fileID = fopen(['../backup/interfacesInformation'],'w');
  fprintf(fileID,'water_sediment_interface_min = %f\n',min(water_sediment_interface(:)));
  fprintf(fileID,'water_sediment_interface_max = %f\n',max(water_sediment_interface(:)));
  fprintf(fileID,'sediment_rock_interface_min  = %f\n',min(sediment_rock_interface(:)));
  fprintf(fileID,'sediment_rock_interface_max  = %f\n',max(sediment_rock_interface(:)));
fclose(fileID);


top_interface = dlmread('../backup/top_interface');
bottom_interface = dlmread('../backup/bottom_interface');

top_interface_slice = [x; top_interface(interface_slice_index,:)]';
bottom_interface_slice = [x; bottom_interface(interface_slice_index,:)]';
water_sediment_interface_slice = [x; water_sediment_interface(interface_slice_index,:)]';
sediment_rock_interface_slice= [x; sediment_rock_interface(interface_slice_index,:)]';
water_polygon = [top_interface_slice;flipud(water_sediment_interface_slice)];
sediment_polygon = [water_sediment_interface_slice;flipud(sediment_rock_interface_slice)];
rock_polygon = [sediment_rock_interface_slice;flipud(bottom_interface_slice)];

dlmwrite('../backup/water_sediment_interface_slice',water_sediment_interface_slice,' ');
dlmwrite('../backup/sediment_rock_interface_slice',sediment_rock_interface_slice,' ');

dlmwrite('../backup/water_polygon',water_polygon,' ');
dlmwrite('../backup/sediment_polygon',sediment_polygon,' ');
dlmwrite('../backup/rock_polygon',rock_polygon,' ');

mesh=dlmread('../backup/mesh.xyz');

x_mesh = mesh(:,1);
y_mesh = mesh(:,2);
z_mesh = mesh(:,3);

z_mesh_interp_on_water_sediment_interface = interp2(X,Y,water_sediment_interface, x_mesh,y_mesh);
z_mesh_interp_on_sediment_rock_interface = interp2(X,Y,sediment_rock_interface, x_mesh,y_mesh);

mask_water = z_mesh > z_mesh_interp_on_water_sediment_interface;
mask_sediment = z_mesh <= z_mesh_interp_on_water_sediment_interface & z_mesh > z_mesh_interp_on_sediment_rock_interface;
mask_rock = z_mesh <= z_mesh_interp_on_sediment_rock_interface;
mask_water_bathymetry = z_mesh <= z_mesh_interp_on_water_sediment_interface+dz&mask_water;
dlmwrite('../backup/mask_water',mask_water,' ');
dlmwrite('../backup/mask_water_bathymetry',mask_water_bathymetry,' ');
%dlmwrite('../backup/mask_sediment',mask_sediment,' ');
%dlmwrite('../backup/mask_rock',mask_rock,' ');

regionsMaterialNumbering = zeros(size(z_mesh));
regionsMaterialNumbering(find(mask_sediment)) = 1;
%regionsMaterialNumbering(find(mask_sediment&mask_pml)) = 2;
regionsMaterialNumbering(find(mask_rock)) = 3;
%regionsMaterialNumbering(find(mask_rock&mask_pml)) = 4;


%---------------------------
materials = load('../backup/materials');

% use copernicus or measured sound speed profile in water column
c_in_depth=load('../backup/c_in_depth_interp');
disp('copernicus sound speed profile is adopted')
%c_in_depth=load('../backup/c_in_depth_measured_interp');
%disp('measured sound speed profile is adopted')

water_z = z_mesh(mask_water);
[water_z water_z_index] = findNearest(-c_in_depth(:,1),water_z);
water_sound_speed = c_in_depth(water_z_index,2);
[water_sound_speed water_sound_speed_index] = findNearest(materials(:,3),water_sound_speed);
water_materials_numbering = materials(water_sound_speed_index,1);

regionsMaterialNumbering(find(mask_water)) = water_materials_numbering;
%---------------------------

regions=load('../backup/regions');
regions = [regions(:,[1:6]) regionsMaterialNumbering];

dlmwrite('../backup/regions',regions,' ');

%-----------------
mesh_slice_index = find(abs(y_mesh-y_slice)<1/4*dy);
mesh_slice_x = x_mesh(mesh_slice_index);
mesh_slice_z = z_mesh(mesh_slice_index);
mesh_slice_regionsMaterialNumbering = regionsMaterialNumbering(mesh_slice_index);
[mesh_slice_regionsMaterialNumbering mesh_slice_regionsMaterialNumbering_index] = findNearest(materials(:,1),mesh_slice_regionsMaterialNumbering);
mesh_slice_sound_speed = materials(mesh_slice_regionsMaterialNumbering_index,3);
mesh_slice_sound_speed = [mesh_slice_x mesh_slice_z mesh_slice_sound_speed];
dlmwrite('../backup/mesh_slice_sound_speed',mesh_slice_sound_speed,' ');
