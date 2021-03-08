%#!/usr/bin/env octave

clear all
close all
clc

[y,Fs] = audioread('../backup/eugene_wav/MGE04220120140718_110400Ch2.wav');
disp(['the sampling rate of wav file is ' int2str(Fs) 'Hz'])

nt=length(y);
dt = 1/Fs;
t= [0:nt-1]'*dt;
hydrophone_signal = [t y];

cut_time_start = 0;
cut_number_start = round(cut_time_start/dt)+1;

cut_time_end = 15.01;
cut_number_end = round(cut_time_end/dt);

hydrophone_signal = hydrophone_signal(cut_number_start:cut_number_end,:);
hydrophone_signal(:,1) = hydrophone_signal(:,1) - hydrophone_signal(1,1);

save("-ascii",['../backup/hydrophone_signal'],'hydrophone_signal')

s=hydrophone_signal(:,2);

nfft = 2^nextpow2((length(s))*10);
S = fft(s,nfft);

f = transpose(Fs*(0:(nfft/2))/nfft);
P = abs(S/nfft);
hydrophone_spectrum =[f,P(1:nfft/2+1)];
save("-ascii",['../backup/hydrophone_spectrum'],'hydrophone_spectrum')
