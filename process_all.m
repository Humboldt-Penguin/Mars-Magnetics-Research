% Calls writemagshape on a folder of MAVEN track data files and passes it
% some input parameters specified on lines 21-25. Running a few trials has
% revealed that the parallel processing adds a ~%30 improvement in
% processing time.

clc
clear all
close all

addpath("C:\Users\Zain\Documents\_Research\Mars\Slepian Libraries\slepian_alpha-master");
addpath("C:\Users\Zain\Documents\_Research\Mars\Slepian Libraries\slepian_golf-master");
addpath("C:\Users\Zain\Documents\_Research\Mars\Slepian Libraries\slepian_hotel-master");
addpath("C:\Users\Zain\Documents\_Research\Mars\Slepian Libraries\slepian_hotel-master\MGS");

addpath('C:\Users\Zain\Documents\_Research\Mars\MAVEN_Tracks\2015\01');
myFolder = 'C:\Users\Zain\Documents\_Research\Mars\MAVEN_Tracks\2015\01';

filePattern = fullfile(myFolder, '*.sts');
jpegFiles = dir(filePattern);

h = 15000;
downsample = 1;
clon = 137;
clat = -5;
Th = 50;

% parpool(2) % preferrable, just run this in the terminal before you start

tic
% for k = 1:length(jpegFiles)
parfor k = 1:length(jpegFiles)
    baseFileName = jpegFiles(k).name;
    fullFileName = fullfile(myFolder, baseFileName);
%   fprintf(1, 'Now reading %s\n', fullFileName);
    writemagshape(baseFileName,h,downsample,clon,clat,Th);
end
toc