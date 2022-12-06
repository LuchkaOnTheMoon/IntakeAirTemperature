%% In-take Air Temperature (IAT) Negative Temperature Coefficient (NTC) series 
%% sensor calculator (BoosterPlug approach), for GNU Octave (largely compatible 
%% with Matlab).
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
% Stock IAT parameters.
% R25: thermistor’s resistance @ 25°C [ohm]
% Beta: thermistor’s beta value [K].
R25  = 3000.0;
Beta = 3950.0;

% Desired AFR delta [%].
AfrDelta = 6;

% Temperature range and step [°C].
% Format is Tmin : Tstep : Tmax.
T = -20 : 0.01 : +50;

% BoosterPlug NTC parameters.
% CalculateOrCheck: 0 to calculate ideal BoosterPlug NTC parameters, otherwise 
%                   given parameters are used to check for resulting AFR ratio 
%                   increment flatness.
% R25_BoosterPlug:  series NTC resistance @ 25°C [ohm]
% Beta_BoosterPlug: series NTC beta value [K]
CalculateOrCheck = 0;
R25_BoosterPlug  = 3000;
Beta_BoosterPlug = 3850;

%%%% PROCESSING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (CalculateOrCheck == 0)
    %%%% CALCULATOR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate stock IAT resistance over given temperature range.
    Rstock = R25 .* exp (Beta .* (1 ./ (T + 273.15) - 1 / 298.15));

    % For each ambient temperature level, calculate required temperature offset 
    % to achieve desired constant AFR increment.
    Tdelta = -(T + 273.15) * AfrDelta / (AfrDelta + 100);

    % Perform NTC model fitting to calculate and print R25 and Beta parameters 
    % of the ideal target NTC sensor by shifting T axis by Tdelta.
    k0 = [R25, Beta];
    f = @(k, x) (k(1) .* exp (k(2) .* (1 ./ (x + 273.15) - 1 / 298.15)));
    pkg load optim;
    [B, R, J, COVB, MSE] = nlinfit(T - Tdelta, Rstock, f, k0);
    printf("R25_Target = %.1f ohm, Beta_Target = %.1f K\n", B(1), B(2));

    % Calculate target NTC resistance over given temperature range.
    Rtarget = B(1) .* exp (B(2) .* (1 ./ (T + 273.15) - 1 / 298.15));

    % Calculate series NTC resistance (BoosterPlug approach) by subtracting 
    % stock resistance from target.
    Rbooster = Rtarget - Rstock;

    % Perform NTC model fitting to calculate and print R25 and Beta parameters 
    % of the series NTC sensor.
    [B, R, J, COVB, MSE] = nlinfit(T, Rbooster, f, k0);
    printf("R25_BoosterPlug = %.1f ohm, Beta_BoosterPlug = %.1f K\n", B(1), B(2));

    % Plot all NTCs curves.
    figure(1); hold on; grid on;
    title('NTC sensor curve');
    xlabel('Air Temperature [°C]');
    ylabel('Resistance [kOhm]');
    plot(T, Rstock ./ 1e3, '-r');
    plot(T, Rtarget ./ 1e3, '-b');
    plot(T, Rbooster ./ 1e3, '-k');
    plot(T, (Rbooster + Rstock) ./ 1e3, '--k');
    legend('Stock', 'Target', 'BoosterPlug only', 'Stock + BoosterPlug');

    % Plot all temperatures offsets.
    figure(2); hold on; grid on;
    title('Temperature offset');
    xlabel('Air Temperature [°C]');
    ylabel('Offset [°C]');
    plot(T, Tdelta, '-b');
    legend('Target');
else
    %%%% CHECK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate stock IAT resistance over given temperature range.
    Rstock = R25 .* exp (Beta .* (1 ./ (T + 273.15) - 1 / 298.15));
    
    % Calculate series NTC resistance over given temperature range.
    Rbooster = R25_BoosterPlug .* exp (Beta_BoosterPlug .* (1 ./ (T + 273.15) - 1 / 298.15));
    
    % Calculate total IAT resistance (BoosterPlug approach) by summing stock
    % resistance with BoosterPlug.
    Rtotal = Rbooster + Rstock;
    
    % Calculate introduced temperature offset over given temperature range.
    Tdelta = ones(1, length(T)) * NaN;
    for ii = 1:length(T)
        jj = max(find(Rstock >= Rtotal(ii)));
        if length(jj) > 0
            Tdelta(ii) = T(jj) - T(ii);
        end
    end
    
    % Calculate the corresponding AFR delta.
    AfrDelta = (((T + 273.15) ./ (T + Tdelta + 273.15)) - 1) .* 100;
    
    % Plot all temperatures offsets.
    figure(1); hold on; grid on;
    title('Temperature offset');
    xlabel('Air Temperature [°C]');
    ylabel('Offset [°C]');
    plot(T, Tdelta, '-b');
    
    % Plot all temperatures offsets.
    figure(2); hold on; grid on;
    title('AFR Delta');
    xlabel('Air Temperature [°C]');
    ylabel('AFR Delta [%]');
    plot(T, AfrDelta, '-b');
end
