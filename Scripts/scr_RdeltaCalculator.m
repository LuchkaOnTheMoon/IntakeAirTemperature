%% Negative Temperature Coefficient (NTC) sensor series resistance delta 
%% calculation script, for GNU Octave (largely compatible with Matlab).
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
R25 = 2100.3;               % Thermistors' resistance @ 25°C [Ohm].
beta = 3422.5;              % Thermistors' beta value [K].
Trange = [-10, +49];        % Air (ambient) temperature range [°C].
Tdelta = [-1, -20];         % Temperature delta range [°C].
filename = 'Rdelta.xlsx';   % Output table XLS filename.

%%%% PROCESSING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate NTC resistance in given temperature range.
T = Trange(1):1:Trange(2);
R = R25 .* exp(beta .* (1 ./ (T + 273) - 1 / 298));

% Calculate NTC resistance in the same temperature range, but applying a 
% variable delta in given range.
Toffset = Tdelta(1):-1:Tdelta(2);
Roffset = R25 .* exp(beta .* (1 ./ (T + Toffset' + 273) - 1 / 298));

% Calculate resistance delta between the two.
Rdelta = Roffset - R;

% Write output to Excel file.
if (isfile(filename))
    delete(filename);
end
pkg load io;
titleString = {'Air Temperature [degC]'};
xlswrite(filename, titleString, 'Rdelta', 'C1');
xlswrite(filename, T, 'Rdelta', 'C2');
titleString = {'Temperature Offset [degC]'};
xlswrite(filename, titleString, 'Rdelta', 'A3');
xlswrite(filename, Toffset', 'Rdelta', 'B3');
xlswrite(filename, Rdelta, 'Rdelta', 'C3');
