%% In-take Air Temperature (IAT) Negative Temperature Coefficient (NTC) 
%% replacement sensor calculator (Belinassu approach), for GNU Octave (largely 
%% compatible with Matlab).
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

% Belinassu NTC parameters.
% CalculateOrCheck: 0 to calculate ideal Belinassu NTC parameters, otherwise 
%                   given parameters are used to check for resulting AFR ratio 
%                   increment flatness.
% R25_Belinassu:    replacement NTC resistance @ 25°C [ohm]
% Beta_Belinassu:   replacement NTC beta value [K]
% SeriesOrParallel: if more than one value is provided for R25_Belinassu and
%                   Beta_Belinassu, specify if given thermistors should be
%                   considered as connected in series or parallel, 0 for series,
%                   otherwise for parallel.
CalculateOrCheck    = 1;
R25_Belinassu       = [10000.0, 20000.0];
Beta_Belinassu      = [3950.0, 3950.0];
SeriesOrParallel    = 1;

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

    % Plot all NTCs curves.
    figure(1); hold on; grid on;
    title('NTC sensor curve');
    xlabel('Air Temperature [°C]');
    ylabel('Resistance [kOhm]');
    plot(T, Rstock ./ 1e3, '-r');
    plot(T, Rtarget ./ 1e3, '-b');
    legend('Stock', 'Target');

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
    
    % Calculate replacement NTC resistance over given temperature range.
    assert(length(R25_Belinassu) == (length(Beta_Belinassu)));
    if (length(R25_Belinassu) > 0)
        R = zeros(length(R25_Belinassu), length(T));
        for ii = 1:length(R25_Belinassu)
            R(ii, :) = R25_Belinassu(ii) .* exp (Beta_Belinassu(ii) .* (1 ./ (T + 273.15) - 1 / 298.15));
        end
        if (SeriesOrParallel == 0)
            Rbelinassu = sum(R, 1);
        else
            Rbelinassu = 1 ./ sum(1 ./ R, 1);
        end
    else
        Rbelinassu = R25_Belinassu .* exp (Beta_Belinassu .* (1 ./ (T + 273.15) - 1 / 298.15));
    end
    
    % Calculate introduced temperature offset over given temperature range.
    Tdelta = ones(1, length(T)) * NaN;
    for ii = 1:length(T)
        jj = max(find(Rstock >= Rbelinassu(ii)));
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
