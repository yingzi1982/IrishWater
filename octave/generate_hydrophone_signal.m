#!/usr/bin/env octave

clear all
close all
clc

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
t = hydrophone_signal(:,1);

cut_time_start = 102.8-0.5;
[cut_time_start cut_time_start_index]=findNearest(t,cut_time_start);

cut_time_end = cut_time_start+6;;
[cut_time_end cut_time_end_index]=findNearest(t,cut_time_end);

hydrophone_signal = hydrophone_signal(cut_time_start_index:cut_time_end_index,:);
hydrophone_signal(:,1) = hydrophone_signal(:,1) - hydrophone_signal(1,1);

save("-ascii",['../backup/hydrophone_signal'],'hydrophone_signal')
