clear all
close all
NSTATOIN=254661;


total=[];

tic
for i=1:2500
seis = randn(100,100);
total = [total;seis];
end
toc
