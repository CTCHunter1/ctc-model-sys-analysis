% Copyright (C) 2014  Gregory L. Futia
% This work is licensed under a Creative Commons Attribution 4.0 International License

% filename: test_trasnformer1D.m
% Created On: 2008.03.10
% Last Modified: 2008.05.14
% Discription: Runs Rectangle and Guassian test cases on the transformer
%              function. Transforms the Rectangle and Gaussian then 
%              inverse transforms to recover original. Plots the origional,
%              transformed, and inversere transformed to the screen.

% Clean up the work space
clear;
close all;

N = 2^8;

% adds shift
x0 = 0;
% Angular space to test over
x = linspace(-1E-3+x0, 1E-3+x0, N);

% For the rectangle
W = 1E-4;   %   width in (m)

% we now have fx and x
f1_x = rectpuls((x-x0)/(W));    % D.C. value of 1
[F1_fx temp_fx] = transformer(f1_x, x);
[if1_x, temp_x] = invtransformer(F1_fx, temp_fx);

F1_fx_theory = W*sinc(temp_fx*W);

% set W to the FWHM
a = 4*log(2)/W^2;
Ww = 4*sqrt(a*log(2));

f2_x = exp(-a*(x-x0).^2);
[F2_fx fx] = transformer(f2_x, x);
F2t_fx = sqrt(pi/a)*exp(-(fx*pi).^2/a);
[if2_x, temp_x] = invtransformer(F2_fx, temp_fx);

[F3_fx, ~] = transformer(f2_x, x);

% this sould match W
%fwhm(x, f2_x)

% these should both match Ww
%fwhm(fx*2*pi, abs(F2_fx))
%fwhm(fx*2*pi, F2t_fx)


figure;
%Rectangle Figures
subplot(3, 2, 1);
plot(x, f1_x);
title('rectangle original');
xlabel('x (m)');
ylabel('f1(x)');

subplot(3, 2, 3);
plot(temp_fx, abs(F1_fx));
hold on;
plot(temp_fx, abs(F1_fx_theory), 'r');
title('rectangle transformed');
xlabel('fx (1/m)');
ylabel('abs(F1(fx))');

subplot(3, 2, 5);
plot(temp_x, if1_x);
title('rectangle invtrasformed');
xlabel('x (m)');
ylabel('f1(x)');

% Gaussian Figures
subplot(3, 2, 2);
plot(x, f2_x);
title('gaussian original');
xlabel('x (m)');
ylabel('f2(x)');

subplot(3, 2, 4);
plot(fx, abs(F2_fx));
hold on;
plot(fx, F2t_fx, 'r');
title('gaussian transformed');
xlabel('fx (1/m)');
ylabel('F2(fx)');

subplot(3, 2, 6);
plot(temp_x, abs(if2_x));
title('gaussian invtrasformed');
xlabel('x (m)');
ylabel('f2(x)');

F_x = 10*ones(1,N);
[F_fx, fx] = transformer(F_x, x);

figure;
plot(fx, abs(F3_fx))
title('DFT using the dtft function');
xlabel('fx')
ylabel('Magnitude of field')


figure;
plot(fx, abs(F_fx))

