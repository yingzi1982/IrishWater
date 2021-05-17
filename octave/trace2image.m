function [image]=trace2image(trace,nt,range)

resample = floor(rows(trace)/nt);

t = trace(:,1);
t = t-t(1);

trace = trace(:,2:end);

TRACE = abs(hilbert(trace));
TRACE = TRACE/max(abs(TRACE(:)));

t = t(1:resample:end);
TRACE = TRACE(1:resample:end,:);


[RANGE T] = meshgrid(range,t);

image = reshape(TRACE,[],1);
RANGE = reshape(RANGE(:,:),[],1);
T = reshape(T(:,:),[],1);

image = [RANGE T image];
end
