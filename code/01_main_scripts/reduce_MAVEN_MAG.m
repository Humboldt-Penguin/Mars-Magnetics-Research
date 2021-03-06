clc
clear

%%% INPUTS (see decription for more details)

% inputfile_mavenFolders = "inputfile_allMavenFolders.txt";
% inputfile_mavenFolders = "inputfile_5-28-22_2014-2018.txt";
% inputfile_mavenFolders = "inputfile_5-31-22_2019-2021.txt";

% inputfile_mavenFolders = "2014-10_to_2017-06.txt";
% inputfile_mavenFolders = "2017-07_to_2019-12.txt";
inputfile_mavenFolders = "2020-01_to_2021-10.txt";

altitudeCutoff = 200;

% verbose = true;
% yippee = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%{ 
DESCRIPTION:
    Works with unzipped data downloaded from:
        https://pds-ppi.igpp.ucla.edu/search/view/?f=null&id=pds://PPI/
        maven.mag.calibrated/data/pc/highres

    Takes MAVEN_MAG .sts files and removes the heading, all daytime
    measurements (8:59 AM to 8:00 PM), and measurements where the satellite is
    above a certain altitude (200 km). The reduced versions are written to
    a new directory defined in `getPaths.m`.

    Note that the outputted time estimates for each file reduction are not
    accurate when using parallel processing ("parfor"). Although each file
    appears to take longer, the overall process is significantly faster.

INPUTS:
    inputfile_mavenFolders
        Text file containing the names of folders to be reduced

    altitudeCutoff
        Cutoff for satellite altitudes in kilometers. Any measurements with
        an altitude greater than this will be removed from the sts files.

OUTPUTS:
    A folder containing the reduced .sts files. The location of this folder
    is specified in `getPaths.m`.


CHANGELOG:

    2022-07-16
        - Increased nighttime range by two hours, as per Luju recommendation.

    2022-06-07
        - Changed output folder to be just "<reducedMavenPath>/" instead of
        "<`reducedMavenPath`>/<altitudeCutoff>km/" so that other scripts can
        access it.

    2022-05-28:
        - First version completed, all files processed and uploaded to Box:
            https://rutgers.box.com/s/o9nc40xrd4auip4fjokd3ntif3xg4n0z

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Basic outputs
fprintf('Input file = %s\n\n', inputfile_mavenFolders);
fprintf('Started running at %s.\n\n', datestr(now,'HH:MM'));

% Get full paths of all MAVEN .sts files

mavenFiles = convert_inputfile_to_fullpaths(inputfile_mavenFolders);


% Creat directory for reduced files

reducedMavenPath = getPaths('reducedMaven');
% altitudeSpecific_reducedMavenPath = fullfile(reducedMavenPath,strcat(num2str(altitudeCutoff),'km'));
% [~,~] = mkdir(altitudeSpecific_reducedMavenPath);
[~,~] = mkdir(reducedMavenPath);

% Traverse each file, look at each measurement, and cut it out if it's above the altitudeCutoff

parfor i=1 : length(mavenFiles(:,1))   
    tic

    thisMavenFile = mavenFiles(i,:);

    [raw_data, factorReduction] = reduceData(thisMavenFile,altitudeCutoff);

    shortFn = shortenFilename(thisMavenFile);

    if factorReduction ~= -1
%         [t] = writeReducedMavenFile(raw_data, thisMavenFile, altitudeSpecific_reducedMavenPath);
        [t] = writeReducedMavenFile(raw_data, thisMavenFile, reducedMavenPath);
        fprintf("%s was reduced by a factor of %.1f in %.2f seconds. \n", shortFn, factorReduction, t);
    else
        fprintf("%s had no data that fit criteria, so it will not be saved. \n", shortFn);
    end

end

fprintf('\nFinished running at %s.\n', datestr(now,'HH:MM'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Functions


function [formatSpec] = generate_formatSpec(base,numRepeat)
    formatSpec = '';
    for i=1:numRepeat
        formatSpec = strcat(formatSpec,base);
    end
end



function [raw_data,factorReduction] = reduceData(thisMavenFile,altitudeCutoff)

    %{ 
        Take a file, extract the data, and return a reduced version of the
        data (daytime and altitude values filtered out) as a double array,
        along with how much of the file has been removed.
    %}
    
    %%% open file and skip header

    file = fopen(thisMavenFile,'r');

    for j=1:140
        line = fgets(file);
    end
    while ~contains(line, "20")
        line = fgets(file);
    end

    
    %%% scan file into raw_data

    raw_data = textscan(file,generate_formatSpec('%f',18));  
        % note that we miss the first line of data, but the loss is
        % insignificant and i can't think of any way around this

    fclose(file);


    %%% cut out daytime and >altitudeCutoff data

    raw_data = cell2mat(raw_data);

    lines_total = length(raw_data(:,1));

    hour = raw_data(:,3);
    indices_hour = hour < 9 | hour > 19; % 8:00 PM to 8:59 AM
    raw_data = raw_data(indices_hour,:);

    posX = raw_data(:,12); posY = raw_data(:,13); posZ = raw_data(:,14);

    %     [~,~,r] = cart2sph(posX,posY,posZ);
    hypotXY = hypot(posX,posY);
    r = hypot(hypotXY,posZ);
    
    indices_alt = r < (3390 + altitudeCutoff); % 3390 is the avg radius of mars
    raw_data = raw_data(indices_alt,:);

    lines_kept = length(raw_data(:,1));

    raw_data = raw_data.'; %% why do i transpose again hehe um oops uh uh oops haha um ??? haha hehe um uh uh oops haha haha uh hehe im uh haha uh uhh he hehe ha um yeah uh oopsy daisies haha yeah hehe... yeah!... um yeah haha uh yeah yeheahahe

%     percentReduction = 100*(1-(lines_kept/lines_total));
    if lines_kept == 0
        factorReduction = -1;
    else
        factorReduction = lines_total / lines_kept;
    end

end


function [shortFn] = shortenFilename(thisMavenFile)
    date_yrdoy = extractBetween(thisMavenFile,'l2_','pc_');
    shortFn = strcat("mvn_mag_", extractBetween(date_yrdoy,1,4), "_", extractBetween(date_yrdoy,5,7));
end


function [t] = writeReducedMavenFile(raw_data, thisMavenFile, altitudeSpecific_reducedMavenPath)

    %{ 
        Take the reduced data and write it to a new .sts file in a new
        folder.
    %}

    %%% extract justYearMonth (ex "\2014\10") from mavenPath vs thisMaven differential

    [yearmonthPath,~,~] = fileparts(thisMavenFile);

    rawMavenPath = getPaths('rawMaven');
    start = strlength(rawMavenPath)+1;
    last = strlength(yearmonthPath);
    
    justYearMonth = extractBetween(yearmonthPath,start,last);

    %%% write to file

    outputFolderPath = fullfile(altitudeSpecific_reducedMavenPath, justYearMonth);
    [~,~] = mkdir(outputFolderPath{1});

    shortFn = shortenFilename(thisMavenFile);
    outputFilePath = fullfile(outputFolderPath, strcat(shortFn,'.sts'));
    file = fopen(outputFilePath, 'w');

        formatSpec = ['%.0f\t%.0f\t%.0f\t%.0f\t%.0f\t%.0f\t%f\t%.2f\t%.2f\t' ...
            '%.2f\t%.0f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.0f\n'];
        fprintf(file, formatSpec, raw_data);
    
    fclose(file);

    t = toc;
end