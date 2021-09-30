#!/usr/bin/env octave

clear all
close all
clc

xy = load('../backup/airgun_array_deployment');

[theta,rho] = cart2pol(xy(:,1),xy(:,2));

xy_rotated=pol2cart(theta-deg2rad(166-90),rho);

dlmwrite('../backup/airgun_array_deployment_rotated',xy_rotated,' ');
