#!/usr/bin/env octave

clear all
close all
clc

[amp_status amp] = system('grep amplitude ../backup/sourceAmplitude | cut -d = -f 2');
amp = str2num(amp);

signal = load('../backup/ARRAY.S1.FXP.semp');
t = signal(:,1);
s = signal(:,2)*amp;

s_energy = s.^2;
s_energy_percentage = cumsum(s_energy)/sum(s_energy);

specfem_signal = [t s s_energy_percentage];

save("-ascii",['../backup/specfem_signal_surface'],'specfem_signal')

signal = load('../backup/ARRAY.S2.FXP.semp');
t = signal(:,1);
s = signal(:,2)*amp;

s_energy = s.^2;
s_energy_percentage = cumsum(s_energy)/sum(s_energy);

specfem_signal = [t s s_energy_percentage];

save("-ascii",['../backup/specfem_signal_bottom'],'specfem_signal')
