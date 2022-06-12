clc
clear

%%% INPUTS (see decription for more details)
crater_database_path = 'C:\Users\zk117\Documents\00.local_WL-202\Mars_Magnetics\geological_features\crater_database\Catalog_Mars_Release_2020_1kmPlus_FullMorphData.csv';
minDiam = 50;
maxDiam = 100;

saveLogs = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%{ 
DESCRIPTION:
    This script goes through a global database of Mars impact craters [1]
    and finds craters with diameters between user-inputted values. The
    crater ID, coordinates, and diameter of these craters are stored in a
    text document in `code/03_input_files/craters/`.

    [1]: DOI:10.1029/2011JE003967


INPUTS:
    crater_database_path
        Path to the CSV file downloaded from here: http://craters.sjrdesign.net/
    
    minDiam
        Minimum crater diameter in kilometers.

    maxDiam
        Maximum crater diameter in kilometers.


OUTPUTS:
    A text file in \code\03_input_files\locations\craters containing the
    crater ID, coordinates, and diameter of craters between minDiam and
    maxDiam, sorted by increasing diameter.


CHANGELOG:

    2022-06-10
        - First functional version completed

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

global logs; %#ok<*GVMIS> 
% if global is causing problems with parfor, just replace 
% "verbose("    --> "logs = verbose(...)" and edit verbose function to
% return the message value

logs = "";

tic
% verbose(sprintf("Started running at %s.", datestr(now,'HH:MM')));
verbose(sprintf("Minimum diameter = %.0f km \nMaximum diameter = %.0f km", minDiam, maxDiam));


%%% read crater data

[fid,msg] = fopen(crater_database_path,'r');
clear crater_database_path;
assert(fid>=3, msg)
clear msg;

fgets(fid); % skip header

formatSpec = "";
for i=1:29 % There are only 28 extraneous arguments but you need 29 here or it randomly inserts 1's (first instance is in row 17181). I spent an hour debugging this, fuck my life.
    formatSpec = strcat(formatSpec, " %*s");
end
clear i;

craterData = textscan(fid, strcat('%s %f %f %*f %*f %f', formatSpec), 'Delimiter', ',');
clear formatSpec;

fclose(fid);
clear fid ans;

% verbose(sprintf("Database has %0.f craters.", length(craterData{1,1})));
assert(length(craterData{1,1}) == 392431, sprintf('Crater database has been altered; There should be 392431 entries, but the inputted file has %.0f', length(craterData{1,1})));


id = craterData{1,1}(:);
lat = craterData{1,2}(:);
lon = craterData{1,3}(:);
diam = craterData{1,4}(:);
clear craterData;

%{ 
craterData fields:
    CRATER_ID
    LAT_CIRC_IMG (degrees North)
    LON_CIRC_IMG (degrees East)
    DIAM_CIRC_IMG (km)

See [1] for more information on each field.
%}



%%% min/max diameter cut

minDiam_indices = find(diam > minDiam);

id = id(minDiam_indices);
lon = lon(minDiam_indices);
lat = lat(minDiam_indices);
diam = diam(minDiam_indices);

clear minDiam_indices;

maxDiam_indices = find(diam < maxDiam);

id = id(maxDiam_indices);
lon = lon(maxDiam_indices);
lat = lat(maxDiam_indices);
diam = diam(maxDiam_indices);


clear maxDiam_indices;



%%% sort by increasing diameter

% % Debugging: check sort with first 5 values
% id = id(1:5);
% lat = lat(1:5);
% lon = lon(1:5);
% diam = diam(1:5);


[diam, sorted_indices] = sort(diam);
id = id(sorted_indices);
lat = lat(sorted_indices);
lon = lon(sorted_indices);
clear sorted_indices;

assert(~isempty(id), 'No craters fit the given constraints.');

verbose(sprintf("There are %0.f craters that fit these diameter constraints.", length(id)));

abort = input("Enter \'y\' to write these to a file, or any other key to abort.\n", "s");
assert(strcmp(abort,"y"), "Aborted.")
clear abort



% NOT NEEDED IN THIS INSTANCE, BUT KEEP THIS HANDY FOR FUTURE SCRIPTS --
% THIS WOULD HAVE BEEN VERY HELPFUL FOR REDUCE_MAVEN_MAG

%%% save logs to log folder 

if saveLogs
    logsFolderPath = fullfile(getPaths('repo'), '\code\04_logs'); %#ok<UNRCH> 
    
    filename = sprintf('generate_crater_locations__%s.txt', datestr(now,'mm-dd-yyyy_HH:MM'));
    
    % [fid,msg] = fopen(fullfile(logsFolderPath, filename),'w');
    % assert(fid>=3, msg)
    fid = 1;
    
    fprintf(fid, ...
        "%s\n" + ...
        "Generated on %s\n\n", ...
        filename, datestr(now,'mm/dd/yyyy HH:MM'));
    
    fprintf(fid, logs);
    
    
    % fclose(fid);
end



%%% write to inputfile

craterFolderPath = fullfile(getPaths('repo'), '\code\03_input_files\locations\craters');
[~,~] = mkdir(craterFolderPath);

filename = sprintf('craters_%0.fkm_to_%0.fkm.txt', minDiam, maxDiam);
clear minDiam maxDiam;

[fid,msg] = fopen(fullfile(craterFolderPath, filename),'w');
clear craterFolderPath;
assert(fid>=3, msg)
% fid = 1;

fprintf(fid, ...
    "%s\n" + ...
    "Generated on %s\n\n", ...
    filename, datestr(now,'mm/dd/yyyy HH:MM'));

clear filename;

fprintf(fid, logs);
clear logs;


fprintf(fid,"\nEach line represents a crater. The fields are:" + ...
    "\n\tCRATER_ID" + ...
    "\n\tLON_CIRC_IMG (degrees East)" + ...
    "\n\tLAT_CIRC_IMG (degrees North)" + ...
    "\n\tDIAM_CIRC_IMG (km)" + ...
    "\n\nFor more information on each field, see DOI:10.1029/2011JE003967.\n\n");



fprintf(fid, "\n~~~~~START DATA~~~~~\n");

for i=1:length(id)
    fprintf(fid, "%s\t%f\t%f\t%f\n", id{i},lon(i),lat(i),diam(i));
end

fclose(fid);

fprintf("Finished runnning in %.2f seconds.\n", toc);

clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Functions


function verbose(message)
    % For the sake of debugging, this function provides a centralized place
    % to control how outputs are handled (printed to terminal, stored and
    % then written to a file at the end, etc)

    global logs;
    message = strcat(message, "\n \n");
    fprintf(message);
    logs = strcat(logs, message);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Self-notes:

 
%{ 

interesting but annoying problem: instead of just printing logs to the
terminal, i'm trying to also save it to a file. i'm accomplishing that by
TOO LAZY TO WRITE ALL THIS OUT FUCK OUTTA HERE

old method, reliable:

logs = "";

log = sprintf("Started running at %s.\n\n", datestr(now,'HH:MM'));
logs(end+1) = log;
fprintf(log);


now trying to make logs global kekw.


%}
 

 
%{ 

pretty good verbose method, but I JUST FUCKING REALIZED i don't necessarily
want all my verbose print debugging stuff to be outputted to 

actually fuck it yes i do lulw, temp prints can just be flagged with an "if
verbose" i can't be arsed


%}

