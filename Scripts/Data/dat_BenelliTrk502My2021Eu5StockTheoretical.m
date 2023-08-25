% Benelli TRK 502 MY 2021 (Euro 5) stock IAT NTC thermistor's theoretical data 
% points, extracted from Workshop Manual.
% Row #1: Air temperature [°C]
% Row #2: Thermistor's resistance [Ohm]
data = [   0,    5,   10,   15,   20,   25,   30;
        9399, 7263, 5658, 4441, 3511, 2795, 2240];
        
% Input data range trim in number of samples.
% trim(1) = number of samples to trim from the left, 
% trim(2) = number of samples to trim from right.
trim = [0, 0];

% Initial model guess, for data fitting.
% k0 = [R25, Beta];
% R25: Thermistor's resistance @ 25°C [ohm]
% Beta: Thermistor's beta value [K].
k0 = [2700, 3950];