% Copyright (C) 2016  Gregory L. Futia
% This work is licensed under a Creative Commons Attribution 4.0 International License
% Tests the wigner distribution function


clear;
close all;

w0 = 5E-6;

N = 2^10;

dx = 1E-6;

x = -(N/2 -1)*dx:dx:(N/2)*dx;


u_x1 = exp(-(x-0E-6).^2/w0^2);
u_x2 = exp(-(x-60E-6).^2/w0^2);

u_x = u_x1 + u_x2;


I_x = u_x.*conj(u_x);

[W_xfx, fx] = wigner(u_x, x);

imagesc(fx, x, abs(W_xfx));
colormap gray;

I_xp = sum(W_xfx, 2);

figure;
plot(x, I_x);
hold on;
plot(x, I_xp*max(I_x)/max(I_xp), 'r--');