% Kawasaki ER-6n MY 2005 (Euro 3) stock IAT NTC thermistor's theoretical data 
% points, extracted from Workshop Manual.
% Row #1: Air temperature [°C]
% Row #2: Thermistor's resistance [Ohm]
data = [   0,    0,   20,   20,   40,   40,  60,  60,  80,  80, 100, 100;
        5400, 6600, 2280, 2870, 1060, 1360, 530, 700, 290, 390, 160, 230];
        
% Input data range trim in number of samples.
% trim(1) = number of samples to trim from the left, 
% trim(2) = number of samples to trim from right.
trim = [0, 0];

% Initial model guess, for data fitting.
% k0 = [R25, Beta];
% R25: Thermistor's resistance @ 25°C [ohm]
% Beta: Thermistor's beta value [K].
k0 = [2000, 3435];