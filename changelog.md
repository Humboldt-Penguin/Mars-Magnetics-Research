# Change log

This is for my own reference to supplement tags, and because I cluttered my commit history.

### v3.1 (2022-06-10)
- Wrote first functional version of `generate_crater_locations.m` and documentation.
	- Finalized format for verbose function (with saveLogs option) and location input files.
- Small adjustments.


### v3.0 (2022-06-07)
- Second major reorganization of repository. 
- Fleshing out main scripts documentation.
- Adjusting paths in `getPaths.m` and `startup.m`.
	- Reduced Maven files are now written/accessed from the path in `getPaths.m`, as opposed to a "200km/" folder.
- Small fixes.


### v2.0 (2022-05-28)
- First major reorganization of repository. Structure oriented towards git annex or rclone setup.
- `redice_MAVEN_MAG.m`: Maven file reducing script
- Improved ability for any user to pull repository and run scripts on their machine:
	- `startup.m` for Matlab search paths, mainly for inputfiles,
	- `getPaths.m` for data input/output paths.