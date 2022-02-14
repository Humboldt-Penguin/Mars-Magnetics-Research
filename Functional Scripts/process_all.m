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

myFolder = 'C:\Users\Zain\Documents\_Research\Mars\MAVEN_Tracks\2015\test\';
addpath(myFolder);

filePattern = fullfile(myFolder, '*.sts');
jpegFiles = dir(filePattern);

% h = 200;
% downsample = 1;
% clon = 137;
% clat = -5;
% Th = 50;

h = 1000000;
downsample = 1;
clon = 137;
clat = -5;
Th = 50;

% parpool(2) % run parpool in terminal and with some test files first to "warm up"

tic
% for k = 1:length(jpegFiles)
parfor k = 1:length(jpegFiles)
    baseFileName = jpegFiles(k).name;
    writemagshape_v2(baseFileName,h,downsample,clon,clat,Th);
end
toc