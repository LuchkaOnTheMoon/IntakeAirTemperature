%% In-take Air Temperature (IAT) Negative Temperature Coefficient (NTC) sensor 
%% measured data fitting script, for GNU Octave (largely compatible with 
%% Matlab).
%%
%% Copyright (C) 2023 - Luchika De Sousa
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
% Source data and settings file.
filename = '.\Data\dat_BenelliTrk502My2021Eu5Modified.m';

%%%% PROCESSING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load source data and interpolation settings from given file.
assert(isfile(filename), 'Source file not found.');
run(filename);
assert(size(data, 1) == 2, 'Invalid source data array, must have two rows.');
assert(size(data, 2) >= 2, ...
        'Invalid source data array, must contain at least two data samples.');
assert(size(trim) == [1, 2], 'Invalid trim settings.');
assert(trim(1) >= 0, 'Invalid left trim value, must be >= 0.');
assert(trim(2) >= 0, 'Invalid right trim value, must be >= 0.');
assert(size(k0) == [1, 2], 'Invalid initial model guess settings.');

% Sort measured data in ascending temperature order.
data = sortrows(data', 1)';

% Derive from measured data a proper temperature range over which later display
% the estimated NTC curve.
temperatureRange = min(data(1, :)) : 0.1 : max(data(1, :));

% Trim measured data.
data = data(:, 1 + trim(1) : end - trim(2));

% NTC model definition.
f = @(k, x) (k(1) .* exp (k(2) .* (1 ./ (x + 273.15) - 1 / 298.15)));

% Perform model fitting.
pkg load optim;
[B, R, J, COVB, MSE] = nlinfit(data(1, :), data(2, :), f, k0);

% Calculate NTC thermistor's estimated curve over previously defined temperature
% range.
estimatedNtcResistance = f(B, temperatureRange);

% Print and plot results.
figure(); hold on; grid on;
printf("R25: %.1f, Beta: %.1f\r\n", B(1), B(2));
plot(temperatureRange, estimatedNtcResistance ./ 1e3, '-b');
scatter(data(1, :), data(2, :) ./ 1e3, 'r');
title('IAT NTC measured data fitting');
xlabel('Air Temperature [°C]');
ylabel('NTC Resistance [kOhm]');
