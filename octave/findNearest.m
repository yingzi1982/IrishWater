function [nearestVal nearestIndex]=findNearest(A,a)
% find the index of nearest value
for ia = 1: length(a)
  nearestRange = abs(A-a(ia));
  temp = find(nearestRange == min(nearestRange));
  temp = temp(1);
  nearestIndex(ia) = temp; % select the first one
  nearestVal(ia) = A(temp);
end
end
