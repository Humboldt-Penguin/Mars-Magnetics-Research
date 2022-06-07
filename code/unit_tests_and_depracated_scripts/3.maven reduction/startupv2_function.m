function [repoPath,mavenPath] = startup()
% function [repoPath,mavenPath] = startup(resetPath)

%{
DESCRIPTION: 
    Call this function at the beginning of scripts to "refresh" the MATLAB
    environment (variables and path)

INPUT:
  Enter user/system-specific path from root to (1) "Mars-Magnetics"
  repository and (2) unzipped maven files [may or may not be separated into
  months]
%}

% clc
% clear

repoPath = "C:\Users\zk117\Documents\01.Research\Mars-Magnetics";
mavenPath = "C:\Users\zk117\Documents\00.local_WL-202\MAVEN_MAG\raw";

addpath(repoPath);
addpath(mavenPath);

% if resetPath
%     restoredefaultpath
% end


end