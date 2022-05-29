%{
DESCRIPTION: 
    Run this script the first time you use this repository or launch MATLAB
    to initialize the correct paths.

WARNING: This will restore MATLAB's default path, which might interfere
with other projects. If you want to avoid this, comment out the
"restoredefaultpath" line.
%}

restoredefaultpath;

repoPath = getPaths('repo');

% Main scripts (technically not needed because this is where you should
% always be working from
addpath(genpath(fullfile(repoPath, "code\1.main scripts")));

% Library functions
addpath(genpath(fullfile(repoPath, "code\2.libraries")));

% Inputfile generator scripts
addpath(genpath(fullfile(repoPath, "code\3.input files\")));


clear
clc

fprintf("Ready to start.\n")