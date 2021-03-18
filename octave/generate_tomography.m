#!/usr/bin/env octave

clear all
close all
clc

[DEPTH_BLOCK_KM_status DEPTH_BLOCK_KM] = system('grep DEPTH_BLOCK_KM ../backup/Mesh_Par_file.part | cut -d = -f 2');
DEPTH_BLOCK_KM = str2num(DEPTH_BLOCK_KM);
depth_block=1000*DEPTH_BLOCK_KM;


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
interface_slice_index = find(y>=y_slice&y<y_slice+dy);

[X Y] = meshgrid(x,y);

topo=load('../backup/topo.xyz');
TOPO = griddata (topo(:,1), topo(:,2), topo(:,3), X, Y,'linear');
sed=load('../backup/sed.xyz');
SED = griddata (sed(:,1), sed(:,2), sed(:,3), X, Y,'linear');
SED = TOPO - SED;

water_sediment_interface = TOPO;
sediment_rock_interface = SED;

dlmwrite('../backup/water_sediment_interface',[reshape(X,[],1) reshape(Y,[],1) reshape(water_sediment_interface,[],1)],' ');
dlmwrite('../backup/sediment_rock_interface',[reshape(X,[],1) reshape(Y,[],1) reshape(sediment_rock_interface,[],1)],' ');

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

%clear mesh z_mesh_interp_on_water_sediment_interface z_mesh_interp_on_sediment_rock_interface;
%-------------------------------------------------
mesh_sparse=dlmread('../backup/mesh_sparse.xyz'); 
x_mesh_sparse = mesh_sparse(:,1);
y_mesh_sparse = mesh_sparse(:,2);
z_mesh_sparse = mesh_sparse(:,3);

[dx_sparse_status dx_sparse] = system('grep dx ../backup/mesh_sparseInformation | cut -d = -f 2');
dx_sparse = str2num(dx_sparse);
[dy_sparse_status dy_sparse] = system('grep dy ../backup/mesh_sparseInformation | cut -d = -f 2');
dy_sparse = str2num(dy_sparse);
[dz_sparse_status dz_sparse] = system('grep dz ../backup/mesh_sparseInformation | cut -d = -f 2');
dz_sparse = str2num(dz_sparse);

z_mesh_sparse_interp_on_water_sediment_interface = interp2(X,Y,water_sediment_interface, x_mesh_sparse,y_mesh_sparse);

mask_water_sparse = z_mesh_sparse > z_mesh_sparse_interp_on_water_sediment_interface;
mask_water_bathymetry_sparse = z_mesh_sparse <= z_mesh_sparse_interp_on_water_sediment_interface+dz_sparse&mask_water_sparse;
dlmwrite('../backup/mask_water_sparse',mask_water_sparse,' ');
dlmwrite('../backup/mask_water_bathymetry_sparse',mask_water_bathymetry_sparse,' ');
%clear mesh_sparse z_mesh_sparse_interp_on_water_sediment_interface;
%-------------------------------------------------

regionsMaterialNumbering = zeros(size(z_mesh));
regionsMaterialNumbering(find(mask_sediment)) = 1;
regionsMaterialNumbering(find(mask_rock)) = 3;

%---------------------------
materials = load('../backup/materials');

% use copernicus or measured sound speed profile in water column
c_in_depth=load('../backup/c_in_depth_interp');
disp('copernicus sound speed profile is adopted')
%c_in_depth=load('../backup/c_in_depth_measured_interp');
%disp('measured sound speed profile is adopted')

depth_interp = [min(c_in_depth(:,1)):10:depth_block]';
%c_in_depth = interp1(c_in_depth(:,1),c_in_depth(:,2),depth_interp,'spline','extrap');
c_in_depth = interp1(c_in_depth(:,1),c_in_depth(:,2),depth_interp,'linear','extrap');
c_in_depth = [depth_interp c_in_depth];


clock
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

disp('running mesh_slice')
clock
%-----------------
mesh_slice_index = find(y_mesh>=y_slice&y_mesh<y_slice+dy);
mesh_slice_x = x_mesh(mesh_slice_index);
mesh_slice_z = z_mesh(mesh_slice_index);
mesh_slice_regionsMaterialNumbering = regionsMaterialNumbering(mesh_slice_index);
[mesh_slice_regionsMaterialNumbering mesh_slice_regionsMaterialNumbering_index] = findNearest(materials(:,1),mesh_slice_regionsMaterialNumbering);
mesh_slice_sound_speed = materials(mesh_slice_regionsMaterialNumbering_index,3);
mesh_slice_sound_speed = [mesh_slice_x mesh_slice_z mesh_slice_sound_speed];
dlmwrite('../backup/mesh_slice_sound_speed',mesh_slice_sound_speed,' ');
