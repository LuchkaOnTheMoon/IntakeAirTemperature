# Scripts
This folder contains the following GNU Octave scripts:
- scr_MeasuredDataFitting.m: performs data fitting and calculate thermistors' parameters (Beta and R25) starting from two or more measured data points.
- scr_RdeltaCalculator.m: calculates and generates "Rdelta Tables", reporting the exact series resistance offset to be applied to original IAT sensor probe to have a prescribed temperature negative offset (fuel/air stoichiometric ratio enrichment) for a given ambient temperature, very useful e.g. when testing with a simple series potentiometer on a dyno.
- scr_BoosterPlugCalculator.m: according to the "BoosterPlug approach" of connecting a second thermistor in series with stock IAT to enrich the fuel mixture by given percentage, calculates Beta and R25 parameters of such thermistor, or double checks resulting AFR percentage increment against given.
- scr_BelinassuCalculator.m: according to the "Belinassu approach" of replacing stock IAT thermistor with another one to enrich the fuel mixture by given percentage, calculates Beta and R25 parameters of such replacement thermistor, or double checks resulting AFR percentage increment against given.
