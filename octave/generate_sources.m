#!/usr/bin/env octave

clear all
close all
clc

[LATITUDE_MIN_status LATITUDE_MIN]=system('grep LATITUDE_MIN ../backup/Mesh_Par_file.part | cut -d = -f 2');
LATITUDE_MIN = str2num(LATITUDE_MIN);
[LATITUDE_MAX_status LATITUDE_MAX]=system('grep LATITUDE_MAX ../backup/Mesh_Par_file.part | cut -d = -f 2');
LATITUDE_MAX = str2num(LATITUDE_MAX);


[f0_status f0] = system('grep ATTENUATION_f0_REFERENCE ../backup/Par_file | cut -d = -f 2');
f0 = str2num(f0);
[nt_status nt] = system('grep ^NSTEP ../backup/Par_file | cut -d = -f 2');
nt = str2num(nt);
[dt_status dt] = system('grep ^DT ../backup/Par_file | cut -d = -f 2');
dt = str2num(dt);
fs=1/dt;

%signalType='quasiSingleFreq';
signalType='ricker';
%signalType='noise';
if strcmp(signalType,'ricker')
[t_cut s_cut] = ricker(f0, dt);
%s_cut = -cumsum(s_cut);
%s_cut(1)=0;

elseif strcmp(signalType,'noise')
t_cut = [0:dt:(nt-1)*dt]';
%s_cut = pinkNoise(nt)';
seed=82;
rand('seed',seed);
s_cut = randn(nt, 1);

[B,A] = oct3dsgn(f0,fs);
s_cut = filter(B,A,s_cut);

stepNumber=round(1/f0/dt*2);
hanningWindow=hanning(2*stepNumber+1);
window=ones(nt,1);
window(1:stepNumber) = hanningWindow(1:stepNumber);
s_cut = s_cut.*window;

elseif strcmp(signalType,'quasiSingleFreq')
t_cut = [0:dt:(nt-1)*dt]';
s_cut = sin(2*pi*f0*t_cut);
stepNumber=round(1/f0/dt*2);
hanningWindow=hanning(2*stepNumber+1);
window=ones(nt,1);
window(1:stepNumber) = hanningWindow(1:stepNumber);
s_cut = s_cut.*window;

end
%f_start_filter=100;
%f_end_filter=20000;
%Wn=[f_start_filter f_end_filter]*2/Fs;
%N = 3;
%[a,b] = butter(N,Wn);
%s = filtfilt(a,b,s);
%s=s.*hanning(length(s))


sourceTimeFunction= [t_cut s_cut];
save("-ascii",['../backup/sourceTimeFunction'],'sourceTimeFunction')

nfft = 2^nextpow2(length(t_cut)*10);
S_cut = fft(s_cut,nfft);

Fs=1/dt;
f = transpose(Fs*(0:(nfft/2))/nfft);
P_cut = abs(S_cut/nfft);
sourceFrequencySpetrum =[f,P_cut(1:nfft/2+1)];
save("-ascii",['../backup/sourceFrequencySpetrum'],'sourceFrequencySpetrum')

s = zeros(nt,1);
s(1:length(s_cut)) = s_cut;

s = cumsum(s,2);
s = s/max(s);

longorUTM  = [0.0];
latorUTM   = [0.0];
depth      = [-50.0];


sourceNumber= length(depth);
sourceSize = size(depth);

time_Shift = 0.0*ones(sourceSize);

%factor_force_source = 1.0*ones(sourceSize);
factor_force_source = (1/0.000000035326)*ones(sourceSize);
f0=f0*ones(sourceSize);

component_dir_vect_source_E    = 1.0*ones(sourceSize);
component_dir_vect_source_N    = 1.0*ones(sourceSize);
component_dir_vect_source_Z_UP = 1.0*ones(sourceSize);


fileID = fopen(['../DATA/FORCESOLUTION'],'w');

for nSource = 1:sourceNumber
  fprintf(fileID, 'FORCE_%i\n', nSource)
  fprintf(fileID, 'time shift: %f\n', time_Shift(nSource))
  fprintf(fileID, 'f0: %f\n', f0(nSource))
  fprintf(fileID, 'latorUTM: %f\n', latorUTM(nSource))
  fprintf(fileID, 'longorUTM: %f\n', longorUTM(nSource))
  fprintf(fileID, 'depth: %f\n', depth(nSource))
  fprintf(fileID, 'factor force source: %e\n', factor_force_source(nSource))
  fprintf(fileID, 'component dir vect source E: %f\n', component_dir_vect_source_E(nSource))
  fprintf(fileID, 'component dir vect source N: %f\n', component_dir_vect_source_N(nSource))
  fprintf(fileID, 'component dir vect source Z_UP: %f\n', component_dir_vect_source_Z_UP(nSource))
  stf_file_name=['STF_' int2str(i)];
  fprintf(fileID, './DATA/%s\n', stf_file_name)

  stf_fileID = fopen(['../DATA/' stf_file_name],'w');
  fprintf(stf_fileID, '%f\n', dt)
  for i =1:nt
    fprintf(stf_fileID, '%f\n', s(i))
  end
  fclose(stf_fileID);

end

fclose(fileID);
