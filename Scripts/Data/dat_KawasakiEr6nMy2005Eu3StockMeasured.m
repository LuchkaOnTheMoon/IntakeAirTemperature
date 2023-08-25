% Kawasaki ER-6n MY 2005 (Euro 3) stock IAT NTC thermistor's measured data.
% Row #1: Air temperature [°C]
% Row #2: Thermistor's resistance [Ohm]
data = [5.00, 5.40, 5.80, 6.00, 6.50, 7.22, 7.50, 7.80, 8.10, 8.40, 8.80, 9.35, 9.78, 10.00, 10.30, 11.00, 11.60, 12.54, 13.26, 13.80, 14.00, 14.10, 14.20, 14.30, 14.40, 14.51, 15.30, 27.30, 27.43, 27.49, 35.16, 36.40, 37.00, 37.12, 37.15, 37.36, 44.50, 45.65, 46.32, 46.37, 46.60, 47.40, 50.00, 50.25, 51.00, 51.50, 53.00, 55.65, 56.20, 57.50;
        4813, 4760, 4685, 4646, 4547, 4413, 4356, 4295, 4230, 4172, 4091, 3981, 3900,  3860,  3801,  3676,  3566,  3478,  3199,  3106,  3086,  3065,  3046,  3029,  3009,  2997,  2911,  1929,  1894,  1892,  1440,  1390,  1367,  1340,  1371,  1370,  1018,   980,  1002,  1000,   994,   944,   870,   825,   811,   844,   800,   750,   749,   745];
        
% Input data range trim in number of samples.
% trim(1) = number of samples to trim from the left, 
% trim(2) = number of samples to trim from right.
trim = [0, 0];

% Initial model guess, for data fitting.
% k0 = [R25, Beta];
% R25: Thermistor's resistance @ 25°C [ohm]
% Beta: Thermistor's beta value [K].
k0 = [2000, 3435];