#!/usr/bin/env octave

clear all
close all
clc

arg_list = argv ();
if length(arg_list) == 1
  shootingNumbering=arg_list{1};
  shootingNumbering=str2num(shootingNumbering);
end

%audioFile='../backup/wav/MGE04220120140718_110400Ch2_eugene.wav';
%audioInfo = audioinfo(audioFile);
%[y,Fs] = audioread(audioFile);
%y = y(:,1); % channel selection
%disp(['the sampling rate of wav file is ' int2str(Fs) 'Hz'])

%nt=length(y);
%dt = 1/Fs;
%t= [0:nt-1]'*dt;
%hydrophone_signal = [t y];

hydrophone_signal = load('../backup/Rx18A.txt');
dlmwrite('../backup/total_measured_hydrophone_signal',hydrophone_signal,' ');

dt = hydrophone_signal(2,1)-hydrophone_signal(1,1);
fs=1/dt;

[hydrophone_signal_pks hydrophone_signal_idx] = findpeaks(hydrophone_signal(:,2),"MinPeakHeight",100,...
                              "MinPeakDistance",round(10*fs),"DoubleSided");
t_peak=hydrophone_signal(hydrophone_signal_idx,1);
shooting_time_delay=mean(diff(t_peak));


t = hydrophone_signal(:,1);

%cut_time_start = 102.8-0.5;
%cut_time_start = cut_time_start + 1;
shooting_interval=12.5;
cut_time_start = shooting_interval*(shootingNumbering-1); 
[cut_time_start cut_time_start_index]=findNearest(t,cut_time_start);

%cut_time_end = cut_time_start+6;;
cut_time_end = cut_time_start+shooting_interval;;
[cut_time_end cut_time_end_index]=findNearest(t,cut_time_end);

hydrophone_signal = hydrophone_signal(cut_time_start_index:cut_time_end_index,:);
t = hydrophone_signal(:,1);
t = t - t(1);
hydrophone_signal = hydrophone_signal(:,2);
hydrophone_signal_energy = hydrophone_signal.^2;
hydrophone_signal_energy_percentage = cumsum(hydrophone_signal_energy)/sum(hydrophone_signal_energy);

hydrophone_signal = [t hydrophone_signal hydrophone_signal_energy_percentage];

save("-ascii",['../backup/hydrophone_signal'],'hydrophone_signal')
