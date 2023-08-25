%% In-take Air Temperature (IAT) Negative Temperature Coefficient (NTC) series 
%% sensor calculator (BoosterPlug approach), for GNU Octave (largely compatible 
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
% Mode: Script operational mode.
%       = 0 to calculate ideal series NTC parameters based on given stock IAT
%			parameters and desired AFR delta.
%		= 1 to calculate ideal series NTC R25 value based on given stock IAT 
%			parameters and desired AFR delta but forcing given NTC target Beta.
%       = 2 to check how good given series NTC parameters are working to obtain
%       	desired AFR ratio (check for resulting AFR ratio decrement 
%			flatness).
mode = 1;

% Stock IAT parameters array, defined as: [R25, Beta]
% R25: Thermistor's resistance @ 25°C [ohm]
% Beta: Thermistor's beta value [K].
stockNtc = [2100.3, 3422.5];

% Desired AFR delta [%].
desiredAfrDelta = 6;

% Desired Beta value [K].
% Only used in Mode = 1 to impose replacement thermistor Beta, thus limiting 
% calculation to R25_Target only.
targetBeta = 3950.0;

% Temperature range and step [°C].
% Format is Tmin : Tstep : Tmax.
temperatureRange = 5 : 0.01 : 45;

% Series NTC parameters (R25 and Beta tuple(s)).
% Only used in Mode = 2 to check resulting AFR ratio decrement flatness against
% desired AFR delta specified above.
%
% Simple usage: consider to use a single series NTC thermistor by defining
%               seriesNtc = { [R25, Beta] };
% Example:      seriesNtc = { [4700, 3950] }; 
%
% Advanced usage: consider to use a network of series/parallel connected 
%                 series NTC thermistors, each with its own R25 and Beta
%                 value, by defining seriesNtc as a complex cell array like
%                 the following: 
%                 seriesNtc = { [R25_1, Beta_1]    [R25_2, Beta_2]     [R25_3, Beta_3] ; ...
%                               [R25_4, Beta_4]    {}                  {}              };
%                 In this case, NTC_1, NTC_2 and NTC_3 are considered to be 
%                 connected in series, then in parallel with NTC_4. In other 
%                 words, cell array columns are considered as series thermistors,
%                 while cell array rows are considered as parallel paths.
%                 Total number of columns/rows is arbitrary, fill not fitted 
%                 series thermistors columns with empty cell to consider them as
%                 a short circuit.
% Example:        If you want to check the result obtained by connecting three 
%                 thermistor having a Beta of 3950 K in series having a R25 
%                 value of 1 kOhm, 2 kOhm and 10 kOhm respectively, then 
%                 connected in parallel with a single thermistor having R25 = 
%                 4.7 kOhm and Beta = 3432 K, then connected in parallel with a 
%                 series of two thermistors having a R25 of 1 kOhm and 10 kOhm,
%                 respectively, and a Beta of 3950 K and 3432 K, respectively,
%                 you'll have to type in:
%                 seriesNtc = { [1000, 3950]   [2000, 3950]    [10000, 3950]   ; ...
%                               [4700, 3432]   {}              {}              ; ...
%                               [1000, 3950]   [10000, 3432]   {}              };
seriesNtc = { [10e3, 3950]   [2e3, 3950] ; ...
              [10e3, 3950]   [3e3, 3950] };

%%%% PROCESSING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ((mode == 0) || (mode == 1))
    %%%% CALCULATOR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate stock IAT resistance over given temperature range.
    stockNtcResistance = stockNtc(1) .* exp (stockNtc(2) ...
                        .* (1 ./ (temperatureRange + 273.15) - 1 / 298.15));

    % For each ambient temperature level, calculate required temperature offset 
    % to achieve desired constant AFR increment.
    temperatureDelta = -(temperatureRange + 273.15) * desiredAfrDelta ...
                                                    / (desiredAfrDelta + 100);

    % Perform NTC model fitting to calculate and print R25 and Beta parameters 
    % of the ideal target NTC sensor by shifting T axis by Tdelta.
    pkg load optim;
    f = @(k, x) (k(1) .* exp (k(2) .* (1 ./ (x + 273.15) - 1 / 298.15)));
    [B, R, J, COVB, MSE] = nlinfit(temperatureRange - temperatureDelta, ...
                                        stockNtcResistance, f, stockNtc);
    printf("Target R25 = %.2f Ohm, Target Beta = %.2f K\n", B(1), B(2));

    % Calculate target NTC resistance over given temperature range.
    targetNtcResistance = B(1) .* exp (B(2) .* ...
                            (1 ./ (temperatureRange + 273.15) - 1 / 298.15));

    % Calculate series NTC resistance by subtracting stock resistance from 
	% target.
    seriesNtcResistance = targetNtcResistance - stockNtcResistance;

    % Perform NTC model fitting to calculate and print R25 and Beta parameters 
    % of the series NTC sensor.
    if (mode == 0)
        [B, R, J, COVB, MSE] = nlinfit(temperatureRange, ...
                                            seriesNtcResistance, f, stockNtc);
    else
        f = @(k, x) (k(1) .* exp (targetBeta ...
                                        .* (1 ./ (x + 273.15) - 1 / 298.15)));
        [B, R, J, COVB, MSE] = nlinfit(temperatureRange, ...
                                            seriesNtcResistance, f, stockNtc);
        B(2) = targetBeta;
    end
    printf("Series R25 = %.1f Ohm, Series Beta = %.1f K\n", B(1), B(2));
    
    % If Beta has been forced (in mode = 1),
    if (mode == 1)
        % Update series NTC resistance over given temperature range.
        seriesNtcResistance = B(1) .* exp (B(2) .* ...
                            (1 ./ (temperatureRange + 273.15) - 1 / 298.15)); 
    end

    % Plot all NTCs curves.
    figure(1); hold on; grid on;
    title('NTC sensor curve');
    xlabel('Air Temperature [°C]');
    ylabel('Resistance [kOhm]');
    plot(temperatureRange, stockNtcResistance ./ 1e3, '-r');
    plot(temperatureRange, targetNtcResistance ./ 1e3, '-b');
    plot(temperatureRange, seriesNtcResistance ./ 1e3, '-k');
    plot(temperatureRange, (stockNtcResistance + seriesNtcResistance) ./ 1e3, '--k');
    legend('Stock', 'Target', 'Series NTC only', 'Stock + Series NTC');
elseif (mode == 2)
    %%%% CHECK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate stock IAT resistance over given temperature range.
    stockNtcResistance = stockNtc(1) .* exp (stockNtc(2) ...
                .* (1 ./ (temperatureRange + 273.15) - 1 / 298.15));
    
    % Calculate total series NTC resistance over given temperature range.
    numOfParallBranches = size(seriesNtc, 1);
    numOfSeriesThermistors = size(seriesNtc, 2);
    assert(numOfParallBranches > 0, 'seriesNtc incorrectly defined.');
    assert(numOfSeriesThermistors > 0, 'seriesNtc incorrectly defined.');
    assert(length(size(seriesNtc)) == 2, 'seriesNtc incorrectly defined.');
    seriesNtcResistance = +Inf * ones(1, length(temperatureRange));
    for ii = 1:numOfParallBranches
        seriesBranchResistance = zeros(1, length(temperatureRange));
        for jj = 1:numOfSeriesThermistors
            if !isempty(seriesNtc{ii, jj})
                seriesBranchResistance = seriesBranchResistance + ...
                    seriesNtc{ii, jj}(1) .* exp (seriesNtc{ii, jj}(2) ...
                    .* (1 ./ (temperatureRange + 273.15) - 1 / 298.15));
            end
        end
        seriesNtcResistance = 1 ./ (1 ./ seriesNtcResistance ...
                                        + 1 ./ seriesBranchResistance);
    end

	% If using a complex network of thermistors,
    if ((numOfParallBranches > 1) || (numOfSeriesThermistors > 1))
        % Perform NTC model fitting to calculate and print R25 and Beta 
        % parameters for the series NTC thermistors network.
        pkg load optim;
        f = @(k, x) (k(1) .* exp (k(2) .* (1 ./ (x + 273.15) - 1 / 298.15)));
        [B, R, J, COVB, MSE] = nlinfit(temperatureRange, ... 
                                        seriesNtcResistance, f, stockNtc);
        printf("Equivalent R25 = %.2f Ohm\nEquivalent Beta = %.2f K\n", B(1), B(2));
    end
    
    % Calculate total IAT resistance by summing stock resistance with series 
	% resistance.
    totalNtcResistance = stockNtcResistance + seriesNtcResistance;

    % Re-calculate stock IAT resistance, but this time over a very, very 
	% extended temperature range.
    extendedTemperatureRange = -1000 : 0.01 : +1000;
    stockNtcResistance = stockNtc(1) .* exp (stockNtc(2) ...
                .* (1 ./ (extendedTemperatureRange + 273.15) - 1 / 298.15));
    
    % Calculate introduced temperature offset over given temperature range.
    temperatureDelta = ones(1, length(temperatureRange)) * NaN;
    for ii = 1:length(temperatureRange)
        jj = max(find(stockNtcResistance >= totalNtcResistance(ii)));
        if length(jj) > 0
            temperatureDelta(ii) = extendedTemperatureRange(jj) ...
                                    - temperatureRange(ii);
        else
            error("Can't find problem solution.");
        end
    end
    
    % Calculate the corresponding AFR delta.
    afrDelta = (((temperatureRange + 273.15) ./ (temperatureRange ...
                                    + temperatureDelta + 273.15)) - 1) .* 100;
    
    % Print overall AFR delta statistics.
    printf("AFR average error = %.1f%%\nAFR variance = %.1f%%\n", ...
        desiredAfrDelta - mean(afrDelta), abs(afrDelta(end) - afrDelta(1)));
    
    % Plot resulting AFR VS target.
    figure(2); hold on; grid on;
    title('AFR Delta');
    xlabel('Air Temperature [°C]');
    ylabel('AFR Delta [%]');
    plot(temperatureRange, afrDelta, '-b');
    plot(temperatureRange, ones(length(temperatureRange), 1) .* desiredAfrDelta, '-r');
    legend('Obtained', 'Target', "location", 'southeast');
else
	%%%% INVALID MODE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    assert(false, 'Invalid Mode specified.');
end
