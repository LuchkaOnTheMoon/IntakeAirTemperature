%% In-take Air Temperature (IAT) Negative Temperature Coefficient (NTC) sensor 
%% theoretical data fitting script, for GNU Octave (largely compatible with 
%% Matlab).
%%
%% Copyright (C) 2022 - Luca Novarini
%% 
%% This program is free software: you can redistribute it and/or modify it under
%% the terms of the GNU General Public License as published by the Free Software
%% Foundation, either version 3 of the License, or (at your option) any later
%% version.
%% 
%% This program is distributed in the hope that it will be useful, but WITHOUT 
%% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
%% FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more 
%% details.
%% 
%% You should have received a copy of the GNU General Public License along with 
%% this program. If not, see <https://www.gnu.org/licenses/>.

clear all; close all; clc; 

%%%% USER PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IAT theoretical data points.
% x: air temperatures array [°C]
% y: theoretical thermistor’s resistance [ohm]
x = [0 0 20 20 40 40 60 60 80 80 100 100];
y = [5400 6600 2280 2870 1060 1360 530 700 290 390 160 230];

% Initial model guess, for data fitting.
% k0 = [R25, Beta];
% R25: thermistor’s resistance @ 25°C [ohm]
% Beta: thermistor’s beta value [adim].
k0 = [2000, 3829];

%%%% PROCESSING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NTC model definition.
f = @(k, x) (k(1) .* exp (k(2) .* (1 ./ (x + 273.15) - 1 / 298.15)));

% Perform model fitting.
pkg load optim;
[B, R, J, COVB, MSE] = nlinfit(x, y, f, k0);

% Print and plot.
figure(); hold on; grid on;
printf("R25: %.1f, Beta: %.1f\r\n", B(1), B(2));
T = 0:0.1:100;
R = f(B, T);
plot(T, R ./ 1e3, '-b');
scatter(x, y ./ 1e3, 'r');
title('IAT NTC theoretical data fitting');
xlabel('Air Temperature [°C]');
ylabel('NTC Resistance [kOhm]');
