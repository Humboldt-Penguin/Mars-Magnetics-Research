clc
clear all
close all

addpath('/Users/luju/Dropbox/Mac/Documents/Slepian/slepian_golf-master')
addpath('/Users/luju/Dropbox/Mac/Documents/Slepian/slepian_hotel-master')
addpath('/Users/luju/Dropbox/Mac/Documents/Slepian/slepian_hotel-master/MGS')
addpath('//Users/luju/Dropbox/Mac/Documents/Slepian/slepian_alpha-master')
addpath('/Users/luju/Dropbox/Mac/Documents/MAVEN_Tracks/maven.mag.calibrated/AllYearMaven');
myFolder = '/Users/luju/Dropbox/Mac/Documents/MAVEN_Tracks/maven.mag.calibrated/AllYearMaven';
addpath(myFolder);

filePattern = fullfile(myFolder, '*2016*.sts');
jpegFiles = dir(filePattern);

% Eridania basin:
h = 200;
downsample = 1;
clon = 183;
clat = -2.6;
Th = 15;

% parpool(2) % run parpool in terminal and with some test files first to "warm up"

len = length(jpegFiles);
fprintf(1, 'Now reading %s\n', myFolder);

tic
% for k = 1:length(jpegFiles)
parfor k = 1:len
    baseFileName = jpegFiles(k).name;

%     fprintf(1, 'Now reading %s\n\n', baseFileName);
    fprintf(1, 'Progress: %u/%u \n', k, len);
    
    writemagshape_v2(baseFileName,h,downsample,clon,clat,Th);
end
toc