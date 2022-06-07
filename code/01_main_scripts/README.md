# Code Documentation

## Toolboxes (output of `ver`):
- MATLAB                                                Version 9.12        (R2022a)
- Mapping Toolbox                                       Version 5.3         (R2022a)
- Optimization Toolbox                                  Version 9.3         (R2022a)
- Parallel Computing Toolbox                            Version 7.6         (R2022a)

## Scripts

This section describes the purpose of each script and a rough order in which to use them. More thorough description of purpose/inputs/outputs can be found at the top of each file.

1. Startup/configuration
    
    1. `getPaths.m`\
    (function) Provides other scripts with system-specific paths. Users should edit this before running any scripts in this repository.
    
    1. `startup.m`\
    (script) Adds all folders (most importantly libraries/inputfiles) to Matlab's path. Warning: This will reset Matlab's path to default; see file for more information. 

2. Pre-processing
    
    1. `reduce_MAVEN_MAG.m`\
    (script) Works with unzipped MAVEN_MAG .sts files ([source](https://pds-ppi.igpp.ucla.edu/search/view/?f=null&id=pds://PPI/maven.mag.calibrated/data/pc/highres)). Removes the heading, all daytime measurements (20:00-08:00), and measurements where the satellite is above a certain altitude (200 km). The reduced versions are written to a new directory defined in `getPaths.m`.
    
        * With parallel processing on my machine, this takes about 1-2 hours to reduce the file size by a factor of 100 to about 8.62 GB. The reduced files can be downloaded [here](https://rutgers.box.com/s/o9nc40xrd4auip4fjokd3ntif3xg4n0z).