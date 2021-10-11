#!/usr/bin/env octave

clear all
close all
clc

airgun_array_deployment = load('../backup/original_airgun_array_deployment.txt');

[theta,rho] = cart2pol(airgun_array_deployment(:,1),airgun_array_deployment(:,2));

xy_rotated=pol2cart(theta+deg2rad(90+(180-166)),rho);

dlmwrite('../backup/airgun_array_deployment',xy_rotated,' ');
