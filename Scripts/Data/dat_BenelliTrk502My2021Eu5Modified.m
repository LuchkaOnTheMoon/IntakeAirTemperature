% Benelli TRK 502 MY 2021 (Euro 5) modified IAT NTC thermistor's measured data 
% points. Modified IAT sensor realized using the following network of NTC 
% thermistors, all having a Beta of 3950K:
%
% (10k + 2k) // (10k + 3k), + = series, // = parallel.
%
% Row #1: Air temperature [°C]
% Row #2: Thermistor's resistance [Ohm]
data = [ 8.3,  8.0,  7.9,   7.1,   7.4,   7.8,   8.0,   7.9,   3.7,   4.1,   3.8,   5.4,   6.3,   7.1,  12.2, 14.3, 15.2, 15.0, 15.3, 18.0, 18.2, 18.4, 18.9, 19.8, 21.2, 21.2, 52.8, 50.4, 49.1, 44.7, 44.3, 43.6, 42.1, 41.8, 36.3, 35.9, 35.3, 33.5, 33.1, 32.9, 29.8, 29.6, 29.3, 29.0;
        8970, 9000, 9030, 11490, 11320, 11170, 10740, 10740, 13680, 13600, 13870, 14070, 13770, 13340, 10650, 9740, 9320, 9340, 9230, 8270, 8230, 8180, 8020, 7730, 7360, 7350, 2100, 2221, 2342, 2750, 2805, 2880, 3077, 3111, 3870, 3950, 4030, 4350, 4410, 4460, 5030, 5160, 5230, 5300];
        
% Input data range trim in number of samples.
% trim(1) = number of samples to trim from the left, 
% trim(2) = number of samples to trim from right.
trim = [14, 3];

% Initial model guess, for data fitting.
% k0 = [R25, Beta];
% R25: Thermistor's resistance @ 25°C [ohm]
% Beta: Thermistor's beta value [K].
k0 = [2700, 3950];