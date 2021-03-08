#!/usr/bin/env octave

clear all
close all
clc

[DEPTH_BLOCK_KM_status DEPTH_BLOCK_KM] = system('grep DEPTH_BLOCK_KM ../backup/Mesh_Par_file.part | cut -d = -f 2');
DEPTH_BLOCK_KM = str2num(DEPTH_BLOCK_KM);
depth_block=1000*DEPTH_BLOCK_KM;

data_file='SVP_13_z_c_EXTRAP_2500m.txt';
c_in_depth_measured = load(['../backup/' data_file]);

save("-ascii",['../backup/c_in_depth_measured'],'c_in_depth_measured')

depth_interp = [0:5:depth_block]';

c_in_depth_measured_interp = interp1(c_in_depth_measured(:,1),c_in_depth_measured(:,2),depth_interp,'linear','extrap');
c_in_depth_measured_interp = [depth_interp c_in_depth_measured_interp];

save("-ascii",['../backup/c_in_depth_measured_interp'],'c_in_depth_measured_interp')
