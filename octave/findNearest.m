function [nearestVal nearestIndex]=findNearest(A,a)
% find the index of nearest value

nearestIndex = interp1(A,1:length(A),a,'nearest');
nearestVal = A(nearestIndex);
