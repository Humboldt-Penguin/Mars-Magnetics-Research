clc
clear all
close all

mavenBasePath = 'C:\Users\Zain\Documents\_Research\Mars\MAVEN_Tracks\';
infile_mavenFolders = 'inputfile_mavenFolders.txt'; 
infile_locations = 'inputfile_locations.txt';
outFolderPath = 'C:\Users\Zain\Documents\_Research\Mars\Shape_Files';

%{ 
DESCRIPTION:
    Creates shape files of scalar magnetic field for each location in a set
    of location parameters

INPUTS:
    mavenBasePath: path where Maven files are stored

    infile_mavenFolders: name of text file, where each line is the path to
    a Maven file folder from `mavenBasePath`

    infile_locations: name of text file, where each line is a location
    parametrized by height, downsample, colongitude, colatitude, and theta

    outFolderPath: path the folder which will contain folders of shape
    files for each location

OUTPUTS:
    a folder of shape files for each line in `infile_locations`

%}

% Add paths
addpath( ...
    'C:\Users\Zain\Documents\_Research\Mars\Slepian Libraries\slepian_alpha-master', ...
    'C:\Users\Zain\Documents\_Research\Mars\Slepian Libraries\slepian_golf-master', ...
    'C:\Users\Zain\Documents\_Research\Mars\Slepian Libraries\slepian_hotel-master', ...
    'C:\Users\Zain\Documents\_Research\Mars\Slepian Libraries\slepian_hotel-master\MGS' ...
);


% Input Maven track folders and location parameters
[mavenFiles,inputFolders] = createFiles(mavenBasePath, infile_mavenFolders);
[locations,h,downsample,clon,clat,Th] = inputLocations(infile_locations);

clear infile_locations mavenBasePath infile_mavenFolders;


% Create shape files

% parpool(2)
for i_loc=1 : length(locations) % location index

    folderName = sprintf('%s (clon=%d, clat=%d, Th=%d, h=%d)',locations{i_loc},clon(i_loc),clat(i_loc),Th(i_loc),h(i_loc));
    targetFolder = fullfile(outFolderPath, folderName);
    [~] = mkdir(targetFolder);

    fprintf(1, '\nNow processing %s\n\n', folderName);

    tic
    processLocation(mavenFiles,targetFolder,inputFolders,locations{i_loc},h(i_loc),downsample(i_loc),clon(i_loc),clat(i_loc),Th(i_loc));
    toc

end


%% FUNCTIONS

function [mavenFiles,inputFolders] = createFiles(mavenBasePath, infile_mavenFolders)

    file = fopen(infile_mavenFolders,'r');
        inputFolders = textscan(file,'%s');
    fclose(file);
    
    inputFolders = inputFolders{1};
    mavenFiles = [];
    
    for i=1 : length(inputFolders)
        thisFolder = fullfile(strcat(mavenBasePath,inputFolders{i}), '*sts');
        this_mavenFiles = dir(thisFolder);
        mavenFiles = [mavenFiles; this_mavenFiles];
    end
    
    return
end


function [locations,h,downsample,clon,clat,Th] = inputLocations(infile_locations)

    file = fopen(infile_locations,'r');
        thisline = '';
        while ~(contains(thisline, "START DATA:"))
            thisline = fgets(file);
        end
        P = textscan(file,'%s%f%f%f%f%f');
    fclose(file);

    
    locations=P{1}; h=P{2}; downsample=P{3}; clon=P{4}; clat=P{5}; Th=P{6};

end


function processLocation(mavenFiles, targetFolder, inputFolders, location, h, downsample, clon, clat, Th)

    metaFile = fullfile(targetFolder, 'metadata.txt');
    file = fopen(metaFile, 'w');
    fprintf(file, 'location: %s\n\nh: %d\ndownsample: %d\nclon: %d\nclat: %d\nTh: %d\n\nFolders used:\n', location, h, downsample, clon, clat, Th);
    for i=1:length(inputFolders)
        fprintf(file, '%s\n', inputFolders{i});
    end
    fclose(file);


    len = length(mavenFiles);

    parfor i_file = 1:len
%         fprintf(1, "Reading %s:\n\n", mavenFiles(i_file).name)
        fprintf(1, 'Progress: %u/%u \n', i_file, len);
        fullFileName = fullfile(mavenFiles(i_file).folder, mavenFiles(i_file).name);
        writemagshape_v3(fullFileName,targetFolder,h,downsample,clon,clat,Th);
    end 

end
