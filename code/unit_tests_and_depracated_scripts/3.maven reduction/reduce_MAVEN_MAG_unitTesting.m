clc
clear
fprintf('Started running at %s.\n', datestr(now,'HH:MM'));

%%% INPUTS (see decription for more details)

% inputfile_mavenFolders = "inputfile_allMavenFolders.txt";
inputfile_mavenFolders = "inputfile_test.txt";
maxAltitude = 200;
verbose = true;
% yippee = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%{ 
DESCRIPTION:
    Works with unzipped data downloaded from:
        https://pds-ppi.igpp.ucla.edu/search/view/?f=null&id=pds://PPI/maven.mag.calibrated/data/pc/highres

    Takes a list of folders (specified by an inputfile_created by the user)
    containing raw MAVEN_MAG .sts files and removes all measurements taken
    at night and measurements where the satellite is above a certain
    altitude.

INPUTS:
    inputfile_mavenFolders
        Text file containing the names of folders to be reduced

    maxAltitude
        Cutoff for satellite altitudes in kilometers. Any measurements with
        an altitude greater than this will be removed from the sts files.

OUTPUTS:
    A folder containing the reduced .sts files. The location of this folder
    is specified in `getPaths.m`.
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Get full paths of all MAVEN .sts files

mavenFiles = convert_inputfile_to_fullpaths(inputfile_mavenFolders);

% Traverse each file, look at each measurement, and cut it out if it's above the maxAltitude

reducedMavenPath = getPaths('reducedMaven');
altitudeSpecific_reducedMavenPath = fullfile(reducedMavenPath,strcat(num2str(maxAltitude),'km'));
[~,~] = mkdir(altitudeSpecific_reducedMavenPath);

% for i=1 : length(mavenfiles(:,1))
i = 1;    
    tic

    %%% open file, skip header, and scan into raw_data

%     thisMavenFile = mavenFiles(i,:);
%     thisMavenFile = "C:\Users\zk117\Documents\00.local_WL-202\MAVEN_MAG\raw\test\mvn_mag_l2_2014283pc_20141010_v01_r01.sts";
    thisMavenFile = "C:\Users\zk117\Documents\00.local_WL-202\MAVEN_MAG\raw\2014\10\mvn_mag_l2_2014283pc_20141010_v01_r01.sts";
%     thisMavenFile = "C:\Users\zk117\Documents\00.local_WL-202\MAVEN_MAG\raw\2017\05\mvn_mag_l2_2017125pc_20170505_v01_r01.sts";

    



    file = fopen(thisMavenFile,'r');
        
    for j=1:140
        line = fgets(file);
    end
    while ~contains(line, "20")
        line = fgets(file);
    end

    raw_data = textscan(file,generate_formatSpec('%f',18));  
    fclose(file);
    

    % note that we miss the first line of data, but the loss is
    % insignificant and i can't think of any way around this


    %%% cut out nighttime and >maxAltitude data

    raw_data = cell2mat(raw_data);
    lines_total = length(raw_data(:,1));

    hour = raw_data(:,3);
    indices_hour = find(hour < 8 | hour> 20);
    raw_data = raw_data(indices_hour,:);

    posX = raw_data(:,12); posY = raw_data(:,13); posZ = raw_data(:,14);
    [~,~,r] = cart2sph(posX,posY,posZ);
    indices_alt = find(r < 3390+maxAltitude); % 3390 is the radius of mars
    raw_data = raw_data(indices_alt,:);

    lines_kept = length(raw_data(:,1));






    %%% if there are remaining measurements, write into .sts file



    date_yrdoy = extractBetween(thisMavenFile,'l2_','pc_');
    shortFn = strcat("mvn_mag_", extractBetween(date_yrdoy,1,4), "_", extractBetween(date_yrdoy,4,6));

    if lines_kept > 0
        raw_data = raw_data.';

        %%% extract justYearMonth (ex "\2014\10") from mavenPath vs thisMaven differential

        rawMavenPath = getPaths('rawMaven');
        [yearmonthPath,~,~] = fileparts(thisMavenFile);
        
        start = strlength(rawMavenPath)+1;
        last = strlength(yearmonthPath);
        
        justYearMonth = extractBetween(yearmonthPath,start,last);

        %%% write to file

        outputFolderPath = fullfile(altitudeSpecific_reducedMavenPath, justYearMonth);
        [~,~] = mkdir(outputFolderPath);

        outputFilePath = fullfile(outputFolderPath, strcat(shortFn,'.sts'));
        file = fopen(outputFilePath, 'w');

            formatSpec = ['%.0f\t%.0f\t%.0f\t%.0f\t%.0f\t%.0f\t%f\t%.2f\t%.2f\t' ...
                '%.2f\t%.0f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.0f\n'];
            fprintf(file, formatSpec, raw_data);
        
        fclose(file);

        percentReduction = 100*(1-(lines_kept/lines_total));
        t = toc;

        fprintf("%s was reduced by %.3f%% in %.2f seconds. \n", shortFn, percentReduction, t);
    else
        fprintf("%s had no data that fit criteria, so it will not be saved. \n", shortFn);
    end




fprintf('Finished running at %s.\n', datestr(now,'HH:MM'));



%% Functions


function [formatSpec] = generate_formatSpec(base,numRepeat)
    formatSpec = '';
    for i=1:numRepeat
        formatSpec = strcat(formatSpec,base);
    end
end


