function [rootPath,mavenPath] = startup_withWarnings(warnings)


% Enter user/system-specific path from root to (1) repository and (2)
% unzipped maven files (may or may not be separated into months)
rootPath = "C:\Users\zk117\Documents\01.Research\Mars-Magnetics";
mavenPath = "C:\Users\zk117\Documents\00.local_WL-202\MAVEN_MAG\raw";

%{
WARNING:
    This function restores your path to default.

DESCRIPTION: 
    Call this function at the beginning of scripts to "refresh" the MATLAB
    environment (variables and path)

INPUTS:
    Each unique user should specify their own "rootPath", or path to the
    root directory (Mars-Magnetics) on their system below.
%}


if warnings
    prompt = "The startup function restores your path to default and clears all variables. Are you sure you want to continue? y/n: ";
    flag = input(prompt,"s");    
    % if isempty(ans)
    %     text = 'n';
    % end
else
    flag = 'y';
end

if strcmp(flag, 'y') || strcmp(flag, 'Y')
    clc
    clear
    restoredefaultpath
end


end