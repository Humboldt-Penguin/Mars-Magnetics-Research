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
h = 200;
downsample = 1;
clon = 137;
clat = -5;
Th = 50;
for k = 1:length(jpegFiles);
  baseFileName = jpegFiles(k).name;
  fullFileName = fullfile(myFolder, baseFileName);
%   fprintf(1, 'Now reading %s\n', fullFileName);
write_mag_shape(baseFileName,h,downsample,clon,clat,Th);
end


% clc
% clear all
% close all
% 
% addpath("C:\Users\Zain\Documents\_Research\Mars\Slepian Libraries\slepian_alpha-master");
% addpath("C:\Users\Zain\Documents\_Research\Mars\Slepian Libraries\slepian_golf-master");
% addpath("C:\Users\Zain\Documents\_Research\Mars\Slepian Libraries\slepian_hotel-master");
% addpath("C:\Users\Zain\Documents\_Research\Mars\Slepian Libraries\slepian_hotel-master\MGS");
% 
% dataset = "C:\Users\Zain\Documents\_Research\Mars\MAVEN_Tracks\2015\01";
% addpath(dataset);
% 
% 
% fn_template = fullfile(dataset, "*.sts");
% output = dir(fn_template);
% 
% max_alt = 1000000000;
% downsample = 1;
% colon = 185;
% colat = -40; % =90-lat; 0(north) -> 180(south)
% radial_intervals = 17;
% 
% for i = 1:length(output)
%     write_mag_shape( ...
%         output(i).name, ...
%         max_alt, downsample, colon, colat, radial_intervals ...
%     );
% end


