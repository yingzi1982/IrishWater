#!/usr/bin/env octave

clear all
close all
clc

s_data=load('../backup/DTSactiveGuns_NoGhost.txt');
[nt_data nelement_data]=size(s_data);

fs_data=102400;
dt_data=1/fs_data;
t_max_data=(nt_data-1)*dt_data;
t_data =[0:dt_data:t_max_data]'; 

%distance=13;
%s_data = [t_data s_data*distance];
s_data = [t_data s_data];
dlmwrite('../backup/airgun_signature',s_data,' ');


%[dt_status dt] = system('grep ^DT ../backup/Par_file | cut -d = -f 2');
%dt = str2num(dt);
%fs=1/dt

