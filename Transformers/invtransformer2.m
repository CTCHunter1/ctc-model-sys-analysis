function [u_xy, x, y] = invtransformer2(U_fxfy, fx, fy)
% Copyright (C) 2016  Gregory L. Futia
% This work is licensed under a Creative Commons Attribution 4.0 International License>.


% determine the number of vectors in fx
% M number of row, N number of columns
[M N] = size(U_fxfy);

fxs = 2*max(fx);
xmax = (N-1)*(1/fxs);
x = linspace(-xmax/2, xmax/2, N);

fys = 2*max(fy);
ymax = (M-1)*(1/fys);
y = linspace(-ymax/2, ymax/2, M);

dFx = fx(2) - fx(1);
dFy = fx(2) - fx(1);

% ifftshift reorders the points from -pi to pi back to 0 to 2*pi for the
% inverse fourier transform 
% fftshiftss are explained 
% @ http://www.mathworks.com/matlabcentral/newsreader/view_thread/285244
u_xy = N*M*dFy*dFx*fftshift(ifft2(ifftshift(U_fxfy))); % 1/sqrt(N) makes this unitary
