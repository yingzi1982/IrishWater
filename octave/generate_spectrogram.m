#!/usr/bin/env octave

clear all
close all
clc

signal_file='../backup/hydrophone_signal';
disp(['calculating spectram of signal in file: ' signal_file])

s = load(signal_file);

t = s(:,1);
s = s(:,2);
dt= t(2)-t(1);
Fs = 1/dt;

%step=100;
%window=128;
step = fix(5*Fs/1000);     # one spectral slice every 5 ms
window = fix(40*Fs/1000);  # 40 ms data window
nfft = 2^nextpow2(window);
noverlap= window-step;

[S, f, t] = specgram(s, nfft, Fs, window, noverlap);
%f = f(2:fftn*fmax/Fs);
%S = abs(S(2:fftn*fmax/Fs,:));
S = abs(S);
S = S/max(S(:));           # normalize magnitude so that max is 0 dB.
%S = max(S, 10^(-40/10));   # clip below -40 dB.
%S = min(S, 10^(-3/10));    # clip above -3 dB.
S=20*log10(S);
%max(S(:))
%min(S(:))
[T F] = meshgrid(t,f);
spectrogram=[T(:),F(:),S(:)];
save("-ascii",['../backup/hydrophone_spectrogram'],'spectrogram')
