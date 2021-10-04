clear all; clc;

% add path to source code
%addpath source/
addpath ~/SeismicAirgun/source/

[nt_status nt] = system('grep ^NSTEP ../backup/Par_file | cut -d = -f 2');
nt = str2num(nt);
[dt_status dt] = system('grep ^DT ../backup/Par_file | cut -d = -f 2');
dt = str2num(dt);
tmin=0;
tmax=(nt-1)*dt;

%%% SeismicAirgun simulation
%src_pressure = 2000; % source pressure [psi]
src_pressure = 0; % source pressure [psi]
src_volume = 45; % source volume [in^3]
src_area = 10; % port area of source [in^2]
src_depth = 7; % depth of source [m]

% pressure (psi), volume (in^3), port/throat area (in^2)
src_props = [src_pressure, src_volume, src_area]; 

dt = dt; % sampling interval
time = [tmin tmax]; % bounds on time vector
r = 1; % distance from airgun to receiver.

% tuning parameters
alpha = 0.8; % decay of amplitude of pressure perturbation
beta = 0.45; % rate of ascent of bubble
F = 0.4; % fraction of mass that is not ejected from source
%alpha = 1.0; % decay of amplitude of pressure perturbation
%beta = 0.0; % rate of ascent of bubble
%F = 0.0; % fraction of mass that is not ejected from source

physConst = physical_constants(src_depth, r, time, alpha, beta, F); % physical constant
plot_outputs = false; % false = do not plot outputs, true = plot outputs
output = SeismicAirgun(src_props, physConst, dt, plot_outputs);

t=output.tPres;
p=output.pPresBarM;
whos t p
max(p)
min(p)
