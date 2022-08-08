# Scripts
This folder contains the following GNU Octave scripts:
- scr_MeasuredDataFitting.m: script used to perform data fitting and calculate thermistors' parameters (Beta and R25) starting from measured datapoints.
- scr_TheoreticalDataFitting.m: similar to "scr_MeasuredDataFitting.m" and used to calculate thermistors' parameters starting from theoretical datapoints.
- scr_RdeltaCalculator.m: script used to generate "Rdelta Tables", reporting the exact series resistance offset to be applied to original IAT sensor probe to have a prescribed temperature negative offset (fuel/air stoichiometric ratio enrichment) for a given ambient temperature, very useful during testing phase (dyno).
