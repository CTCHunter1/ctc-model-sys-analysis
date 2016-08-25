% Copyright (C) 2014  Gregory L. Futia
% This work is licensed under a Creative Commons Attribution 4.0 International License

% filename: test_trasnformer2D.m
% Created On: 2008.05.14
% Last Modified: 2008.05.14
% Discription: Runs Rectangle and Guassian test cases on the transformer
%              function. Transforms the Rectangle and Gaussian then 
%              inverse transforms to recover original. Plots the origional,
%              transformed, and inversere transformed to the screen.

% Clean up the work space
clear;
close all;

N = 2^8;
M = N;
% Angular space to test over
Xmax = 1E-3;
Ymax = Xmax;
x = linspace(-Xmax, Xmax, N);
y = linspace(-Ymax, Ymax, M);


% For the rextangles
Wx = 2E-4;   %   width in (m)
Wy = 2*Wx;     %   width in (m)

y0 = .2E-3;
x0 = .3E-3;

% Build the rectangle function
f1_xy = double(rectpuls((y-y0)/(Wy))).'*double(rectpuls((x-x0)/(Wx)));   
[F1_fxfy, temp_fx, temp_fy] = transformer2(f1_xy, x, y);
[if1_xy, temp_x, temp_y] = invtransformer2(F1_fxfy, temp_fx, temp_fy);

% Compare to analytic for Gaussian
F1_fxfy_theory = Wx*Wy*sinc(Wy*temp_fy).'*sinc(Wx*temp_fx);
error_rect = sum(sum(abs(F1_fxfy_theory - F1_fxfy)))

% For the gaussian
f2_xy = exp(-pi*((y-y0)/Wy).^2).'*exp(-pi*((x-x0)/Wx).^2);
[F2_fxfy temp_fx, temp_fy] = transformer2(f2_xy, x, y);
[if2_xy, temp_x, temp_y] = invtransformer2(F2_fxfy, temp_fx, temp_fy);

% Compare to analytic for gaussian
F2_fxfy_theory = Wx*Wy*exp(-pi*(Wy*temp_fy).^2).'*exp(-pi*(Wx*temp_fx).^2);
error_gauss = sum(sum(abs(F2_fxfy_theory - F2_fxfy)))

figure;
%Rectangle Figures
subplot(3, 2, 1);
imagesc(x, y, f1_xy);
title('rectangle original, f1(x,y)');
xlabel('x (m)');
ylabel('y (m)');

subplot(3, 2, 3);
imagesc(temp_fx, temp_fy, abs(F1_fxfy));
title('rectangle transformed, F1(fx,fy)');
xlabel('fx (1/m)');
ylabel('fy (1/m)');

subplot(3, 2, 5);
imagesc(x, y, if1_xy);
title('rectangle invtrasformed, if1(x,y)');
xlabel('x (m)');
ylabel('y (x)');

% Gaussian Figures
subplot(3, 2, 2);
imagesc(x, y, f2_xy);
title('gaussian original, f2(x,y)');
xlabel('x (m)');
ylabel('y (m)');

subplot(3, 2, 4);
imagesc(x, y, abs(F2_fxfy));
title('gaussian transformed, F2(fx,fy)');
xlabel('fx (1/m)');
ylabel('fx (1/m)');

subplot(3, 2, 6);
imagesc(temp_x, temp_y, if2_xy);
title('gaussian invtrasformed, if2(x,y)');
xlabel('x (m)');
ylabel('y (m)');

