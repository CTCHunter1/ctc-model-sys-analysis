function [U_fx, fx] = transformer(u_x, x)
% Copyright (C) 2016  Gregory L. Futia
% This work is licensed under a Creative Commons Attribution 4.0 International License

% expect the number of parameters in t to be equal to those in u
% the sampling period
dX = x(2) - x(1);
fxs = 1/dX;
% determine the number of vectors in t
N = length(x);

% find the frequencys at each point of the dft
%w = 2*pi*(1/dX)*[(-N)/2:(N-1)/2]/N;
fx = linspace(-.5/dX, .5/dX, N);


% center shift the dft
% the FFT goes from 0 to 2*pi, fftshift reorders the points to be from
% -pi to pi
U_fx = dX*fftshift(fft(fftshift(u_x)));   % 1/sqrt(N) makes this unitary
%U_fx = (1/N)*fftshift(fft(fftshift(u_x)));   % 1/sqrt(N) makes this unitary
%U_fx = fftshift(fft(fftshift(u_x))); 