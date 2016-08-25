function [U_fxfy, fx, fy] = transformer2(u_xy, x, y)
% Copyright (C) 2016  Gregory L. Futia
% This work is licensed under a Creative Commons Attribution 4.0 International License

% expect the number of parameters in t to be equal to those in u
% the sampling period
dX = x(2) - x(1);
dY = y(2) - y(1);
% determine the number of vectors in t
[M N] = size(u_xy);

% find the frequencys at each point of the dft
fx = linspace(-.5/dX, .5/dX, N);
fy = linspace(-.5/dY, .5/dY, M);


% center shift the dft
% the FFT goes from 0 to 2*pi, fftshift reorders the points to be from
% -pi to pi
%U_fxfy = (1/(M*N))*fftshift(fft2(u_xy, M, N));   % 1/sqrt(N) makes this unitary
% fft shifts are explained a @
% http://www.mathworks.com/matlabcentral/newsreader/view_thread/285244
U_fxfy = dX*dY*fftshift(fft2(ifftshift(u_xy), M, N));   % 1/sqrt(N) makes this unitary

