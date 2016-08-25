% Created By: G. Futia
% Copyright (C) 2016  Gregory L. Futia
% This work is licensed under a Creative Commons Attribution 4.0 International License

function [dt] = findFWHM(G_t, t)

peak = max(G_t);
N = length(G_t);

t1 = 0;
t2 = 0;

% find first point
for(ii = 1:N)
    if(G_t(ii) > .5*peak)
        t1 = t(ii);
        break;
    end
end

% find the peak
for(jj = (ii):N)
    if(G_t(jj) > .99*peak)
        tp = t(jj);
        break;
    end
end


% find the peak
for(kk = (jj+1):N)
    if(G_t(kk) < .5*peak)
        t2 = t(kk);
        break;
    end
end

dt = abs(t2 - t1);

return;

if((kk-ii) < 5)
    return;
end

% linearize around t2 and t1 and refind the fwhm
tlin = dt/3;    % distance to linearize around

% linearize around t1
P1 = polyfit(t(((t > (t1 - tlin/2)) & (t < (t1 + tlin/2)))), ...
    G_t(((t > (t1 - tlin/2)) & (t < (t1 + tlin/2)))), 1);

t1_lin = (peak/2 - P1(2))/P1(1);


% linearize around t2
P2 = polyfit(t(((t > (t2 - tlin/2)) & (t < (t2 + tlin/2)))), ...
    G_t(((t > (t2 - tlin/2)) & (t < (t2 + tlin/2)))), 1);

t2_lin = (peak/2 - P2(2))/P2(1);


dt = abs(t2_lin - t1_lin);

