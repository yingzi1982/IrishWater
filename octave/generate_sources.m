#!/usr/bin/env octave

clear all
close all
clc

[f0_status f0] = system('grep ATTENUATION_f0_REFERENCE ../backup/Par_file | cut -d = -f 2');
f0 = str2num(f0);
[nt_status nt] = system('grep ^NSTEP ../backup/Par_file | cut -d = -f 2');
nt = str2num(nt);
[dt_status dt] = system('grep ^DT ../backup/Par_file | cut -d = -f 2');
dt = str2num(dt);
fs=1/dt;

airgun_array_deployment = load('../backup/airgun_array_deployment');

airgun_array_signature = load('../backup/airgun_array_signature');

t = airgun_array_signature(:,1);
airgun_array_signature=airgun_array_signature(:,[2:end]);

if nt != length(airgun_array_signature)
    error ("Airgun array signature is not equal to NT!");
end

% filtering operation can modify amplitude of signal
%fcuts = [90 100];
fcuts = [1000 1100];
%fcuts = [290 300];
mags = [1 0];
devs = [0.05 0.01];
filter_parameters=[fcuts;mags;devs];
save("-ascii",['../backup/filter_parameters'],'filter_parameters')
[n,Wn,beta,ftype] = kaiserord(fcuts,mags,devs,fs);
hh = fir1(n,Wn,ftype,kaiser(n+1,beta),'noscale');

airgun_array_signature  = filtfilt(hh,1,airgun_array_signature);
airgun_array_signature = airgun_array_signature - mean(airgun_array_signature);
dlmwrite('../backup/airgun_array_signature_processed',[t airgun_array_signature],' ');

longorUTM  = airgun_array_deployment(:,1);
latorUTM   = airgun_array_deployment(:,2);
depth      = -7.0*ones(size(longorUTM));

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
  stf_file_name=['STF_' int2str(nSource)];
  fprintf(fileID, './DATA/%s\n', stf_file_name)

  stf_fileID = fopen(['../DATA/' stf_file_name],'w');
  fprintf(stf_fileID, '%f\n', dt)
  for i =1:nt
    fprintf(stf_fileID, '%f\n', airgun_array_signature(i,nSource))
  end
  fclose(stf_fileID);

end

fclose(fileID);
