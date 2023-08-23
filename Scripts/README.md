# Scripts
This folder contains the following GNU Octave scripts:
- scr_MeasuredDataFitting.m: performs data fitting and calculate thermistors' parameters (Beta and R25) starting from two or more measured data points.
- scr_RdeltaTableGenerator.m: calculates and generates "Rdelta Tables", reporting the exact series resistance offset to be connected to stock IAT probe to have a prescribed temperature negative offset (air/fuel ratio leaning) for a given ambient temperature. Very useful e.g. when benchmarking with a simple series potentiometer on a dyno.
- scr_SeriesIatCalculator.m: according to the approach of connecting a second thermistor in series with stock IAT probe to enrich the fuel mixture by a given percentage, calculates Beta and R25 parameters of such thermistor, or double checks resulting AFR percentage increment against given values.
- scr_ReplacementIatCalculator.m: according to the approach of completely replacing stock IAT thermistor with another one to enrich the fuel mixture by a given percentage, calculates Beta and R25 parameters of such replacement thermistor, or double checks resulting AFR percentage increment against given values.
