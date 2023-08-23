%% Script for generating the table of series resistance values to be interposed 
%% with stock Intake Air Temperature (IAT) sensor to obtain a precise percentage
%% of leaning of the air/fuel ratio (AFR), for GNU Octave (largely compatible 
%% with Matlab).
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
stockNtcR25 = 2100.3;           % Stock IAT thermistors' resistance @ 25°C [Ohm].
stockNtcBeta = 3422.5;          % Stock IAT thermistors' beta value [K].
temperatureRange = 0 : 1 : 50;  % Air (ambient) temperature range [°C].
afrDeltaRange = 0 : 1 : 10;     % Air/Fuel Ratio variation range [%].
filename = 'SampleTable.xlsx';  % Output table (MS Excel format) filename.

%%%% PROCESSING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Delete previously created output file.
while (isfile(filename))
    delete(filename);
end

% Calculate stock IAT NTC resistance in given temperature range.
stockNtcResistance = stockNtcR25 .* exp(stockNtcBeta ...
                        .* (1 ./ (temperatureRange + 273) - 1 / 298));

% For each ambient temperature value, calculate required temperature delta 
% to achieve desired AFR delta.
temperatureDelta = -(temperatureRange' + 273.15) .* afrDeltaRange ...
                                                ./ (afrDeltaRange + 100);
                        
% Calculate ideal IAT NTC resistance (to achieve desired AFR delta) by applying
% pre-calculated temperature delta.
replacementNtcResistance = stockNtcR25 .* exp(stockNtcBeta .* ...
            (1 ./ (temperatureRange + temperatureDelta' + 273) - 1 / 298));

% Calculate resistance delta between the two.
resistanceDelta = replacementNtcResistance - stockNtcResistance;

% Write output to Excel file.
pkg load io;
xls = xlsopen(filename, true);
titleString = {'Air Temperature [°C]'};
xlswrite(filename, titleString, 'Rdelta [Ohm]', 'C1');
xlswrite(filename, temperatureRange, 'Rdelta [Ohm]', 'C2');
titleString = {'AFR delta [%]'};
xlswrite(filename, titleString, 'Rdelta [Ohm]', 'A3');
xlswrite(filename, afrDeltaRange', 'Rdelta [Ohm]', 'B3');
xlswrite(filename, resistanceDelta, 'Rdelta [Ohm]', 'C3');
xls = xlsclose(xls);
