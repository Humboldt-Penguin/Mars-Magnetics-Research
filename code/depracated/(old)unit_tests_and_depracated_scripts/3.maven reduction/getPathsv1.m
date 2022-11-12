function [repoPath,rawMavenPath,reducedMavenPath] = getPathsv1()


%{
DESCRIPTION: 
    This is purely for convenience. Instead of inputting paths at the top of every
    script that needs them, just change this function once and call it when
    needed.

INPUT:
    Enter user/system-specific path from root to

    repoPath: 
        "Mars-Magnetics" repository
    
    rawMavenPath:
        Folder containing unzipped MAVEN files (may or may not be separated
        into months).

    reducedMavenPath:
        Folder where "reduced" files created from "reduce_MAVEN_MAG.m"
        will be stored (eg if reducedMavenPath="...\reduced", then one
        sub-folder might bem "\reduced\200km\...").

%}


repoPath = "C:\Users\zk117\Documents\01.Research\Mars-Magnetics";
rawMavenPath = "C:\Users\zk117\Documents\00.local_WL-202\MAVEN_MAG\raw";
reducedMavenPath = "C:\Users\zk117\Documents\00.local_WL-202\MAVEN_MAG\reduced";




end