% TEST LOADPDS DIRECTLY TO MAKE SURE SOME LINES OF DATA AREN'T BEING
% SKIPPED!!!!


clc
% clear all
% close all

% function temp = loadpds_test(filename)

addpath('C:\Users\Zain\Documents\_Research\Mars\MAVEN_Tracks\2015\01');
filename = 'mvn_mag_l2_2015001pc_20150101_v01_r01.sts';

fileID = fopen(filename, "r");


for i=1:4
    line = fgets(fileID);
end

for i=1:141
    line = fgets(fileID);
end

line

% C = textscan(fileID, '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f');



