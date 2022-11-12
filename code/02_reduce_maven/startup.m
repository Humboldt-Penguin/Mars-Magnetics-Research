%{
DESCRIPTION: 
    Run this script the first time you use this repository or launch MATLAB
    to initialize the correct paths.

WARNING: 
    This will restore MATLAB's default path, which might interfere with
    other projects. If you want to avoid this, comment out the
    "restoredefaultpath" line.

CHANGELOG:

    2022-06-07
        - Added logs folder

    2022-05-28:
        - First version completed.
%}

restoredefaultpath;

repoPath = getPaths('repo');

% Main scripts (technically not needed because this is where you should
% always be working from
addpath(genpath(fullfile(repoPath, "code\01_main_scripts\")));

% Library functions
addpath(genpath(fullfile(repoPath, "code\02_libraries\")));

% Inputfile generator scripts
addpath(genpath(fullfile(repoPath, "code\03_input_files\")));

% Logs
addpath(genpath(fullfile(repoPath, "code\04_logs\")));

clear
clc

fprintf("Ready to start.\n")