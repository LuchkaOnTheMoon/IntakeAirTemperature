%% In-take Air Temperature (IAT) Negative Temperature Coefficient (NTC) sensor 
%% measured data fitting script, for GNU Octave (largely compatible with 
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

% IAT measured data points.
% x: air temperatures array [°C]
% y: measured thermistor’s resistance [ohm]
x = [5.00, 5.40, 5.80, 6.00, 6.50, 7.22, 7.50, 7.80, 8.10, 8.40, 8.80, 9.35, ...
    9.78, 10.00, 10.30, 11.00, 11.60, 12.54, 13.26, 13.80, 14.00, 14.10, ...
    14.20, 14.30, 14.40, 14.51, 15.30, 27.30, 27.43, 27.49, 35.16, 36.40, ...
    37.00, 37.12, 37.15, 37.36, 44.50, 45.65, 46.32, 46.37, 46.60, 47.40, ...
    50.00, 50.25, 51.00, 51.50, 53.00, 55.65, 56.20, 57.50];
y = [4813.00, 4760.00, 4685.00, 4646.00, 4547.00, 4413.00, 4356.00, 4295.00, ...
    4230.00, 4172.00, 4091.00, 3981.00, 3900.00, 3860.00, 3801.00, 3676.00, ...
    3566.00, 3478.00, 3199.00, 3106.00, 3086.00, 3065.00, 3046.00, 3029.00, ...
    3009.00, 2997.00, 2911.00, 1929.00, 1894.00, 1892.00, 1440.00, 1390.00, ...
    1367.00, 1340.00, 1371.00, 1370.00, 1018.00, 980.00, 1002.00, 1000.00, ...
    994.00, 944.00, 870.00, 825.00, 811.00, 844.00, 800.00, 750.00, 749.00, ...
    745.00];

% Range trim in number of samples, trim(1) left trim, trim(2) right trim.
trim = [+18, -14];

% Initial model guess, for data fitting.
% k0 = [R25, Beta];
% R25: thermistor’s resistance @ 25°C [ohm]
% Beta: thermistor’s beta value [K].
k0 = [2000, 3829];

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
T = 0:0.1:100;
R = f(B, T);
plot(T, R ./ 1e3, '-b');
scatter(x, y ./ 1e3, 'r');
title('IAT NTC measured data fitting');
xlabel('Air Temperature [°C]');
ylabel('NTC Resistance [kOhm]');
