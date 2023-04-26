%% In-take Air Temperature (IAT) Negative Temperature Coefficient (NTC) sensor 
%% measured data fitting script, for GNU Octave (largely compatible with 
%% Matlab).
%%
%% Copyright (C) 2022 - Luchika De Sousa
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

% IAT measured data points.
% x: air temperatures array [°C]
% y: measured thermistor’s resistance [ohm]
x = [0 5 10 15 20 25 30];
y = [9399 7263 5658 4441 3511 2795 2240];

% Range trim in number of samples, trim(1) left trim, trim(2) right trim.
trim = [0, 0];

% Initial model guess, for data fitting.
% k0 = [R25, Beta];
% R25: thermistor’s resistance @ 25°C [ohm]
% Beta: thermistor’s beta value [K].
k0 = [2700, 3950];

%%%% PROCESSING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Trim measured data.
x = x(1 + trim(1) : end + trim(2));
y = y(1 + trim(1) : end + trim(2));

% NTC model definition.
f = @(k, x) (k(1) .* exp (k(2) .* (1 ./ (x + 273.15) - 1 / 298.15)));

% Perform model fitting.
pkg load optim;
[B, R, J, COVB, MSE] = nlinfit(x, y, f, k0);

% Print and plot.
figure(); hold on; grid on;
printf("R25: %.1f, Beta: %.1f\r\n", B(1), B(2));
T = -20 : 0.1 : +50;
R = f(B, T);
plot(T, R ./ 1e3, '-b');
scatter(x, y ./ 1e3, 'r');
title('IAT NTC measured data fitting');
xlabel('Air Temperature [°C]');
ylabel('NTC Resistance [kOhm]');
