function [qkappa qmu]=qpqs2qkappaqmu(qp,qs,vp,vs)
L=4/3*(vs./vp).^2;
qmu = qs;
qkappa = (1-L)./(1./qp - L./qmu);
end
