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

X_PML_NUMBER= ceil(THICKNESS_OF_X_PML/dx);
Y_PML_NUMBER= ceil(THICKNESS_OF_Y_PML/dy);
Z_PML_NUMBER= ceil(THICKNESS_OF_Z_PML/dz);

x = linspace(xmin,xmax,nx+1);
y = linspace(ymin,ymax,ny+1);

[X Y] = meshgrid(x,y);

topo=load('../backup/topo.xyz');
TOPO = griddata (topo(:,1), topo(:,2), topo(:,3), X, Y,'linear');
%--------------------------------------
%sed=load('../backup/sed.xyz');
%SED = griddata (sed(:,1), sed(:,2), sed(:,3), X, Y,'linear');
%SED = TOPO - SED;
%--------------------------------------

water_sediment_interface = TOPO;
sediment_sediment_interface = TOPO - 600;
sediment_rock_interface = TOPO - 600 - 600;

%sediment_rock_interface = SED;
%sediment_rock_interface = water_sediment_interface - 150;
%-------------------------------------------------
dlmwrite('../backup/water_sediment_interface',[reshape(X,[],1) reshape(Y,[],1) reshape(water_sediment_interface,[],1)],' ');
dlmwrite('../backup/sediment_sediment_interface',[reshape(X,[],1) reshape(Y,[],1) reshape(sediment_sediment_interface,[],1)],' ');
dlmwrite('../backup/sediment_rock_interface',[reshape(X,[],1) reshape(Y,[],1) reshape(sediment_rock_interface,[],1)],' ');

fileID = fopen(['../backup/interfacesInformation'],'w');
  fprintf(fileID,'water_sediment_interface_min = %f\n',min(water_sediment_interface(:)));
  fprintf(fileID,'water_sediment_interface_max = %f\n',max(water_sediment_interface(:)));
  fprintf(fileID,'sediment_sediment_interface_min = %f\n',min(sediment_sediment_interface(:)));
  fprintf(fileID,'sediment_sediment_interface_max = %f\n',max(sediment_sediment_interface(:)));
  fprintf(fileID,'sediment_rock_interface_min  = %f\n',min(sediment_rock_interface(:)));
  fprintf(fileID,'sediment_rock_interface_max  = %f\n',max(sediment_rock_interface(:)));
fclose(fileID);

top_interface = dlmread('../backup/top_interface');
bottom_interface = dlmread('../backup/bottom_interface');

rc=load('../backup/rc_utm');
rc_longorUTM = rc(:,1);
rc_latorUTM = rc(:,2);

sr=load('../backup/sr_utm');
sr_longorUTM = sr(:,1);
sr_latorUTM = sr(:,2);
k=(sr_latorUTM-rc_latorUTM)/(sr_longorUTM -rc_longorUTM);

y_slice = x*k;

top_interface_slice = interp2(X,Y,top_interface,x,y_slice);
bottom_interface_slice = interp2(X,Y,bottom_interface,x,y_slice);

water_sediment_interface_slice = interp2(X,Y,water_sediment_interface,x,y_slice);
sediment_sediment_interface_slice = interp2(X,Y,sediment_sediment_interface,x,y_slice);
sediment_rock_interface_slice = interp2(X,Y,sediment_rock_interface,x,y_slice);

left_range_index = find(x<=0);
right_range_index = find(x>0);
left_range = sqrt(x(left_range_index).^2+y_slice(left_range_index).^2);
right_range = -sqrt(x(right_range_index).^2+y_slice(right_range_index).^2);
range = [left_range';right_range'];

top_interface_slice = [range top_interface_slice'];
bottom_interface_slice = [range bottom_interface_slice'];
water_sediment_interface_slice = [range water_sediment_interface_slice'];
sediment_sediment_interface_slice = [range sediment_sediment_interface_slice'];
sediment_rock_interface_slice= [range sediment_rock_interface_slice'];

dlmwrite('../backup/water_sediment_interface_slice',water_sediment_interface_slice,' ');
dlmwrite('../backup/sediment_sediment_interface_slice',sediment_sediment_interface_slice,' ');
dlmwrite('../backup/sediment_rock_interface_slice',sediment_rock_interface_slice,' ');

water_polygon = [top_interface_slice;flipud(water_sediment_interface_slice)];
upper_sediment_polygon = [water_sediment_interface_slice;flipud(sediment_sediment_interface_slice)];
lower_sediment_polygon = [sediment_sediment_interface_slice;flipud(sediment_rock_interface_slice)];
rock_polygon = [sediment_rock_interface_slice;flipud(bottom_interface_slice)];

dlmwrite('../backup/water_polygon',water_polygon,' ');
dlmwrite('../backup/upper_sediment_polygon',upper_sediment_polygon,' ');
dlmwrite('../backup/lower_sediment_polygon',lower_sediment_polygon,' ');
dlmwrite('../backup/rock_polygon',rock_polygon,' ');

%-------------------------------------------------
readMeshFromFile='no';
if strcmp(readMeshFromFile,'yes')
  disp(['reading mesh from file ../backup/mesh.xyz'])
  mesh=dlmread('../backup/mesh.xyz'); 
  x_mesh = mesh(:,1);
  y_mesh = mesh(:,2);
  z_mesh = mesh(:,3);

  x_mesh = reshape(reshape(x_mesh,[],1),nz,ny,nx);
  y_mesh = reshape(reshape(y_mesh,[],1),nz,ny,nx);
  z_mesh = reshape(reshape(z_mesh,[],1),nz,ny,nx);
else
  disp(['creating regular mesh'])
  mesh_dx=dx;
  mesh_dy=dy;
  mesh_dz=dz;

  x_mesh = [xmin+dx/2:mesh_dx:xmax-dx/2];
  y_mesh = [ymin+dy/2:mesh_dy:ymax-dy/2];
  z_mesh = [zmin+dz/2:mesh_dz:zmax-dz/2];

  [z_mesh y_mesh x_mesh] = ndgrid(z_mesh,y_mesh,x_mesh);
end

z_mesh_interp_on_water_sediment_interface = interp2(X,Y,water_sediment_interface, x_mesh,y_mesh,'nearest');
z_mesh_interp_on_sediment_sediment_interface = interp2(X,Y,sediment_sediment_interface, x_mesh,y_mesh,'nearest');
z_mesh_interp_on_sediment_rock_interface = interp2(X,Y,sediment_rock_interface, x_mesh,y_mesh,'nearest');

mask_water = z_mesh > z_mesh_interp_on_water_sediment_interface;
mask_upper_sediment = z_mesh <= z_mesh_interp_on_water_sediment_interface & z_mesh > z_mesh_interp_on_sediment_sediment_interface;
mask_lower_sediment = z_mesh <= z_mesh_interp_on_sediment_sediment_interface & z_mesh > z_mesh_interp_on_sediment_rock_interface;
mask_rock = z_mesh <= z_mesh_interp_on_sediment_rock_interface;

%-------------------------------------------------

regionsMaterialNumbering = zeros(size(z_mesh));
%---------------------------
materials = load('../backup/materials');

% use copernicus or measured sound speed profile in water column
c_in_depth=load('../backup/c_in_depth_interp');
disp('copernicus sound speed profile is adopted')
%c_in_depth=load('../backup/c_in_depth_measured_interp');
%disp('measured sound speed profile is adopted')

depth_interp = [min(c_in_depth(:,1)):10:depth_block]';
c_in_depth = interp1(c_in_depth(:,1),c_in_depth(:,2),depth_interp,'spline','extrap');
c_in_depth = [depth_interp c_in_depth];

water_z = z_mesh(mask_water);
[water_z water_z_index] = findNearest(-c_in_depth(:,1),water_z);
water_sound_speed = c_in_depth(water_z_index,2);
[water_sound_speed water_sound_speed_index] = findNearest(materials(:,3),water_sound_speed);
water_materials_numbering = materials(water_sound_speed_index,1);

regionsMaterialNumbering(find(mask_water)) = water_materials_numbering;


%---------------------------
% 1D-PML
upper_sediment_material_numbering=1;
lower_sediment_material_numbering=2;
rock_material_numbering=3;
upper_sediment_pml_material_numbering=4;
lower_sediment_pml_material_numbering=5;
rock_pml_material_numbering=6;

regionsMaterialNumbering(find(mask_upper_sediment)) = upper_sediment_material_numbering;
regionsMaterialNumbering(find(mask_lower_sediment)) = lower_sediment_material_numbering;
regionsMaterialNumbering(find(mask_rock)) = rock_material_numbering;

X_TRANSITION_NUMBER=X_PML_NUMBER + 3;
Y_TRANSITION_NUMBER=Y_PML_NUMBER + 3;
Z_TRANSITION_NUMBER=Z_PML_NUMBER + 3;

xmin_edge_numbering=X_TRANSITION_NUMBER+1;
ymin_edge_numbering=Y_TRANSITION_NUMBER+1;
zmin_edge_numbering=Z_TRANSITION_NUMBER+1;

xmax_edge_numbering=nx-X_TRANSITION_NUMBER;
ymax_edge_numbering=ny-Y_TRANSITION_NUMBER;
zmax_edge_numbering=nz-Z_TRANSITION_NUMBER;


mask_edge_numbering=zeros(size(regionsMaterialNumbering));
mask_edge_numbering(:,:,[xmin_edge_numbering xmax_edge_numbering])=1;
mask_edge_numbering(:,[ymin_edge_numbering ymax_edge_numbering],:)=1;
mask_edge_numbering([zmin_edge_numbering],:,:)=1;

regionsMaterialNumbering(find(mask_upper_sediment&mask_edge_numbering)) = upper_sediment_pml_material_numbering;
regionsMaterialNumbering(find(mask_lower_sediment&mask_edge_numbering)) = lower_sediment_pml_material_numbering;
regionsMaterialNumbering(find(mask_rock&mask_edge_numbering)) = rock_pml_material_numbering;

xmin_layer_index=1:xmin_edge_numbering-1;
ymin_layer_index=1:ymin_edge_numbering-1;
xmax_layer_index=xmax_edge_numbering+1:nx;
ymax_layer_index=ymax_edge_numbering+1:ny;
zmin_layer_index=1:zmin_edge_numbering-1;
%here

regionsMaterialNumbering(:,:,xmin_layer_index) = repmat(regionsMaterialNumbering(:,:,xmin_edge_numbering),[1,1,X_TRANSITION_NUMBER]);

regionsMaterialNumbering(:,ymin_layer_index,:) = repmat(regionsMaterialNumbering(:,ymin_edge_numbering,:),[1,Y_TRANSITION_NUMBER,1]);

regionsMaterialNumbering(:,:,xmax_layer_index) = repmat(regionsMaterialNumbering(:,:,xmax_edge_numbering),[1,1,X_TRANSITION_NUMBER]);

regionsMaterialNumbering(:,ymax_layer_index,:) = repmat(regionsMaterialNumbering(:,ymax_edge_numbering,:),[1,Y_TRANSITION_NUMBER,1]);

regionsMaterialNumbering(:,ymin_layer_index,xmin_layer_index) = repmat(regionsMaterialNumbering(:,ymin_edge_numbering,xmin_edge_numbering),[1,Y_TRANSITION_NUMBER,X_TRANSITION_NUMBER]);

regionsMaterialNumbering(:,ymin_layer_index,xmax_layer_index) = repmat(regionsMaterialNumbering(:,ymin_edge_numbering,xmax_edge_numbering),[1,Y_TRANSITION_NUMBER,X_TRANSITION_NUMBER]);

regionsMaterialNumbering(:,ymax_layer_index,xmin_layer_index) = repmat(regionsMaterialNumbering(:,ymax_edge_numbering,xmin_edge_numbering),[1,Y_TRANSITION_NUMBER,X_TRANSITION_NUMBER]);

regionsMaterialNumbering(:,ymax_layer_index,xmax_layer_index) = repmat(regionsMaterialNumbering(:,ymax_edge_numbering,xmax_edge_numbering),[1,Y_TRANSITION_NUMBER,X_TRANSITION_NUMBER]);

%regionsMaterialNumbering(zmin_layer_index,:,:) = repmat(regionsMaterialNumbering(zmin_edge_numbering,:,:),[Z_TRANSITION_NUMBER,1,1]);

%regionsMaterialNumbering(zmin_layer_index,ymin_layer_index,xmin_layer_index) = repmat(regionsMaterialNumbering(zmin_edge_numbering,ymin_edge_numbering,xmin_edge_numbering),[Z_TRANSITION_NUMBER,Y_TRANSITION_NUMBER,X_TRANSITION_NUMBER]);
%regionsMaterialNumbering(zmin_layer_index,ymin_layer_index,xmax_layer_index) = repmat(regionsMaterialNumbering(zmin_edge_numbering,ymin_edge_numbering,xmax_edge_numbering),[Z_TRANSITION_NUMBER,Y_TRANSITION_NUMBER,X_TRANSITION_NUMBER]);
%regionsMaterialNumbering(zmin_layer_index,ymax_layer_index,xmin_layer_index) = repmat(regionsMaterialNumbering(zmin_edge_numbering,ymax_edge_numbering,xmin_edge_numbering),[Z_TRANSITION_NUMBER,Y_TRANSITION_NUMBER,X_TRANSITION_NUMBER]);
%regionsMaterialNumbering(zmin_layer_index,ymax_layer_index,xmax_layer_index) = repmat(regionsMaterialNumbering(zmin_edge_numbering,ymax_edge_numbering,xmax_edge_numbering),[Z_TRANSITION_NUMBER,Y_TRANSITION_NUMBER,X_TRANSITION_NUMBER]);
%%---------------------------

regionsMaterialNumbering = [reshape(regionsMaterialNumbering,[],1)];

dlmwrite('../backup/regionsMaterialNumbering',regionsMaterialNumbering,' ');

%-----------------
mesh_slice_index = find(y_mesh >= x_mesh*k & y_mesh < x_mesh*k+dy);
mesh_slice_x = x_mesh(mesh_slice_index);
mesh_slice_y = y_mesh(mesh_slice_index);
mesh_slice_z = z_mesh(mesh_slice_index);

mesh_slice_left_range_index = find(mesh_slice_x<=0);
mesh_slice_right_range_index = find(mesh_slice_x>0);
mesh_slice_left_range = sqrt(mesh_slice_x(mesh_slice_left_range_index).^2+mesh_slice_y(mesh_slice_left_range_index).^2);
mesh_slice_right_range = -sqrt(mesh_slice_x(mesh_slice_right_range_index).^2+mesh_slice_y(mesh_slice_right_range_index).^2);
mesh_slice_range = [mesh_slice_left_range;mesh_slice_right_range];

mesh_slice_regionsMaterialNumbering = regionsMaterialNumbering(mesh_slice_index);
[mesh_slice_regionsMaterialNumbering mesh_slice_regionsMaterialNumbering_index] = findNearest(materials(:,1),mesh_slice_regionsMaterialNumbering);
mesh_slice_sound_speed = materials(mesh_slice_regionsMaterialNumbering_index,3);
mesh_slice_sound_speed = [mesh_slice_x mesh_slice_y mesh_slice_range mesh_slice_z mesh_slice_sound_speed];
dlmwrite('../backup/mesh_slice_sound_speed',mesh_slice_sound_speed,' ');
