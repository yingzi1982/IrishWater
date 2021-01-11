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
sound_speed_in_water = [1450:1:1550]';

water     = [1030*ones(size(sound_speed_in_water)) sound_speed_in_water     0*ones(size(sound_speed_in_water))  9999*ones(size(sound_speed_in_water)) 9999*ones(size(sound_speed_in_water))  0*ones(size(sound_speed_in_water))  1*ones(size(sound_speed_in_water))];
%Muddy sand and sand
%0.9db/lambda #Q=pi*8.686/alpha
solid_sediment  = [1530 1700  1000    25   15  0  2];
fluid_sediment  = [1530 1700  1000    25   15  0  1];
solid_crust     = [2600 5800  3200    100  80  0  2];
fluid_crust     = [2600 5800  3200    100  80  0  1];


materials = [solid_sediment;fluid_sediment;solid_crust;fluid_crust;water];

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
