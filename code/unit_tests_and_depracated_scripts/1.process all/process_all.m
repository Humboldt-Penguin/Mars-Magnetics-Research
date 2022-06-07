%{ 
Calls writemagshape on a folder of MAVEN track data files with 
input parameters h, downsample, clon, clat, Th.

Running some trials shows parallel processing adds a ~%30 improvement 
in processing time.
%}

clc
clear all
close all

addpath("C:\Users\Zain\Documents\_Research\Mars\Slepian Libraries\slepian_alpha-master");
addpath("C:\Users\Zain\Documents\_Research\Mars\Slepian Libraries\slepian_golf-master");
addpath("C:\Users\Zain\Documents\_Research\Mars\Slepian Libraries\slepian_hotel-master");
addpath("C:\Users\Zain\Documents\_Research\Mars\Slepian Libraries\slepian_hotel-master\MGS");

myFolder = 'C:\Users\Zain\Documents\_Research\Mars\MAVEN_Tracks\2015\01\';
addpath(myFolder);

filePattern = fullfile(myFolder, '*.sts');
jpegFiles = dir(filePattern);

% Eridania basin:
h = 1000;
downsample = 1;
clon = 137;
clat = -5;
Th = 50;

% parpool(2) % run parpool in terminal and with some test files first to "warm up"

len = length(jpegFiles);
fprintf(1, 'Now reading %s\n', myFolder);

tic
% for k = 1:len
parfor k = 1:len
    baseFileName = jpegFiles(k).name;

%     fprintf(1, 'Now reading %s\n\n', baseFileName);
    fprintf(1, 'Progress: %u/%u \n', k, len);
    
    writemagshape_v2(baseFileName,h,downsample,clon,clat,Th);
end
toc