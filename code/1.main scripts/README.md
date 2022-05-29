Necessary matlab tools:
- parallel processing?
- curve fitting?

Scripts should be executed in this order:

1. Update `getPaths.m` with the appropriate paths for your system
2. `startup.m`
* sets library paths
* warning: this will restore your path to default
3. `reduce_MAVEN_MAG.m`
4. `process_batch.m`
* calls on `crater_coordinates.m` to

i don't break my scripts down into functions to allow for tracking variables through breakpoints