clear all; close all; clc; figure(); hold on; grid on;
pkg load optim;

% Measured data
x = [0 0 20 20 40 40 60 60 80 80 100 100];
y = [5400 6600 2280 2870 1060 1360 530 700 290 390 160 230];

% Trim
trim = [+0, -0];
x = x(1 + trim(1) : end + trim(2));
y = y(1 + trim(1) : end + trim(2));

% Model
f = @(k, x) (k(1) .* exp (k(2) .* (1 ./ (x + 273.15) - 1 / 298.15)));

% Initial guess
k0 = [2000, 3829];

% Perform model fitting
[B, R, J, COVB, MSE] = nlinfit(x, y, f, k0);

% Print and plot
printf("R25: %.1f, Beta: %.1f\r\n", B(1), B(2));
T = 0:0.1:100;
R = f(B, T);
plot(T, R ./ 1e3, '-b');
scatter(x, y ./ 1e3, 'r');
title('ER-6n 2007 IAT NTC model fitting');
xlabel('Temp [°C]');
ylabel('R [kOhm]');
