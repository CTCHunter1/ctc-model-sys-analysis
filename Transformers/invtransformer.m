function [U_x, x] = invtransformer(U_fx, fx)
% Copyright (C) 2016  Gregory L. Futia
% This work is licensed under a Creative Commons Attribution 4.0 International License

% determine the number of vectors in fx
% M number of row, N number of columns
N = length(U_fx);
dfx = fx(2) - fx(1);

%fxs = 2*max(fx);
%xmax = (N-1)*(1/fxs);
x = linspace(-.5/dfx, .5/dfx, N);

%dFx = fx(2) - fx(1);

% ifftshift reorders the points from -pi to pi back to 0 to 2*pi for the
% inverse fourier transform 
U_x = N*dfx*ifftshift(ifft(ifftshift(U_fx))); % 1/sqrt(N) makes this unitary
