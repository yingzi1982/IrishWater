#!/usr/bin/env octave

clear all
close all
clc

arg_list = argv ();
if length(arg_list) > 0
  signal_name=arg_list{1};
else
  signal_name = input('Please input signal name: ','s');
end

signal_file=['../backup/' signal_name];
disp(['Frequency analysis of signal: ' signal_file])

s = load(signal_file);

t = s(:,1);
s = s(:,2);
dt= t(2)-t(1);
Fs = 1/dt;
%-------------------------------------
%step=100;
%window=128;
dB_lower_limit=-1000;
step = fix(5*Fs/1000);     # one spectral slice every 5 ms
window = fix(40*Fs/1000);  # 40 ms data window
nfft = 2^nextpow2(window);
noverlap= window-step;

[S, f, t] = specgram(s, nfft, Fs, window, noverlap);
psd = 2*abs(S).^2;

psd=10*log10(psd);
psd(psd<dB_lower_limit)=dB_lower_limit;
[T F] = meshgrid(t,f);
spectrogram=[T(:),F(:),psd(:)];
save("-ascii",['../backup/' signal_name '_spectrogram'],'spectrogram')
%-------------------------------------

nfft = 2^nextpow2((length(s)));
S = fft(s,nfft);

f = transpose(Fs*(0:(nfft/2))/nfft);

spectrum =2*abs(S(1:nfft/2+1)/nfft);
psd = 2*abs(S(1:nfft/2+1)/nfft).^2;
psd_percentage = cumsum(psd)/sum(psd);
psd = 10*log10(psd);

spectrum=[f, spectrum, psd, psd_percentage];

save("-ascii",['../backup/' signal_name '_spectrum'],'spectrum')
