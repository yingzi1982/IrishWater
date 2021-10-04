clear all; clc;

airgun_array_deployment = load('../backup/airgun_array_deployment');

volume=airgun_array_deployment(:,3);
pressure=airgun_array_deployment(:,4);

elementNumber=length(volume);

% add path to source code
%addpath source/
addpath ~/SeismicAirgun/source/

[nt_status nt] = system('grep ^NSTEP ../backup/Par_file | cut -d = -f 2');
nt = str2num(nt);
[dt_status dt] = system('grep ^DT ../backup/Par_file | cut -d = -f 2');
dt = str2num(dt);
tmin=0;
tmax=(nt-1)*dt;
%tmax=0.5;

%%% SeismicAirgun simulation
%src_pressure = 2000; % source pressure [psi]
%src_volume = 45; % source volume [in^3]
src_area = 10; % port area of source [in^2]
src_depth = 7; % depth of source [m]

% pressure (psi), volume (in^3), port/throat area (in^2)

dt = dt; % sampling interval
time = [tmin tmax]; % bounds on time vector
r = 1; % distance from airgun to receiver.

% tuning parameters
%alpha = 0.8; % decay of amplitude of pressure perturbation
%beta = 0.45; % rate of ascent of bubble
%F = 0.4; % fraction of mass that is not ejected from source
alpha = 1.0; % decay of amplitude of pressure perturbation
beta = 0.0; % rate of ascent of bubble
F = 0.0; % fraction of mass that is not ejected from source

p_array=[];
for n=1:elementNumber

src_pressure = pressure(n);
src_volume = volume(n);

src_props = [src_pressure, src_volume, src_area]; 
physConst = physical_constants(src_depth, r, time, alpha, beta, F); % physical constant
plot_outputs = false; % false = do not plot outputs, true = plot outputs
output = SeismicAirgun(src_props, physConst, dt, plot_outputs);

t=transpose(output.tPres);
nt=length(t);

p=transpose(output.pPresBarM*10^5);
zerohead=zeros(200,1);
p = [zerohead;p];
p = p(1:nt);
p_array = [p_array p];
end

p_array = [t p_array];
dlmwrite('../backup/airgun_array_signature',p_array,' ');
