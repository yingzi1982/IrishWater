#!/usr/bin/env octave

clear all
close all
clc

% define the different materials in the model as:
% #material_id  #rho  #vp  #vs  #Q_Kappa  #Q_mu  #anisotropy_flag  #domain_id
%     Q_Kappa          : Q_Kappa attenuation quality factor
%     Q_mu             : Q_mu attenuation quality factor
%     anisotropy_flag  : 0 = no anisotropy / 1,2,... check the implementation in file aniso_model.f90
%     domain_id        : 1 = acoustic / 2 = elastic
sound_speed_in_water = [1450:0.1:1550]';

water     = [1030*ones(size(sound_speed_in_water)) sound_speed_in_water     0*ones(size(sound_speed_in_water))  9999*ones(size(sound_speed_in_water)) 9999*ones(size(sound_speed_in_water))  0*ones(size(sound_speed_in_water))  1*ones(size(sound_speed_in_water))];

%Muddy sand and sand
%0.9db/lambda #Q=pi*8.686/alpha

sediment_1     = [1530 1800  1000    30   20  0  2];
sediment_2     = [2200 2500  1550    80   50  0  2];
sediment = [sediment_1;sediment_2];
sediment_pml = sediment;
sediment_pml(:,[4 5]) = 9999;

%sediment  = [2200 3000  1550  80   50  0  2];
%P and S wave velocities of consolidated sediments from a seafloor seismic survey in the North Celtic Sea Basin, offshore Ireland

crust         = [2600 5800  3200    100  80  0  2];
crust_pml     = [2600 5800  3200    9999  9999  0  2];

%Muddy sand and sand
%0.9db/lambda #Q=pi*8.686/alpha

%materials = [sediment;sediment_pml;crust;crust_pml;water];
materials = [sediment;sediment_pml;water];

NMATERIALS = rows(materials);
materials = [[1:NMATERIALS]' materials];

fileID = fopen(['../backup/NMATERIALS'],'w');
fprintf(fileID, 'NMATERIALS = %i\n',NMATERIALS);
fclose(fileID);

fileID = fopen(['../backup/materials'],'w');
for n = 1:NMATERIALS
  fprintf(fileID, '%i %f %f %f %f %f %i %i \n',materials(n,1),materials(n,2),materials(n,3),materials(n,4),materials(n,5),materials(n,6),materials(n,7),materials(n,8));
end
fclose(fileID);
