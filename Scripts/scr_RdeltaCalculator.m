clear all; close all; clc; figure(); hold on; grid on;

R25 = 2100.3;
beta = 3422.5;
Trange = [-10, +49];
Tdelta = [-21, -40];

T = Trange(1):1:Trange(2);
R = R25 .* exp(beta .* (1 ./ (T + 273) - 1 / 298));
Toffset = Tdelta(1):-1:Tdelta(2);
Roffset = R25 .* exp(beta .* (1 ./ (T + Toffset' + 273) - 1 / 298));
Rdelta = Roffset - R;

plot(T, Rdelta);
