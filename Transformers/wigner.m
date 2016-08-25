function [W_xfx, fx] = wigner(u_x, x)
% Copyright (C) 2016  Gregory L. Futia
% This work is licensed under a Creative Commons Attribution 4.0 International License
% Created On: 2010.12.21
% Description: Creates wigner distribution W, for input spataial 
% distribution Ex
% Performs shifting in frequency domain similar to how mywinger from the
% internet performs the transformation
 
% Lower case variables => spatial domain
% Upper case variables => spatial frequency domain

if(size(u_x, 2) == 2)
    error('E(x) must be a column vector');
end

N = length(u_x);

if(length(x) ~= N)
    error('x and Ex must have same length');
end


[U_fx, fx] = transformer(u_x, x);   % shift to spatial frequency domain

dfx = fx(2) - fx(1);
dx = x(2) - x(1);

k = 1j*2*pi*x'*fx/2;
U1_fx = U_fx.'*ones(1,N).*exp(-k);
U2_fx = U_fx.'*ones(1,N).*exp(k);

% the columns of all the matrixes are shifted by x/2
dim = 1;  % dimension to perform transform

u1_x = N*dfx*ifftshift(ifft(ifftshift(U1_fx, dim), [], dim), dim);    % the + shift
u2_x = N*dfx*ifftshift(ifft(ifftshift(U2_fx, dim), [], dim), dim);    % the - shift

dim = 2;
W_xfx = abs(dx*fftshift(fft(fftshift(u1_x.*conj(u2_x), dim), [], dim), dim)); % Wigner function


