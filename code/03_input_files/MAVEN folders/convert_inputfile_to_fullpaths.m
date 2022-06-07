function [mavenFiles] = convert_inputfile_to_fullpaths(inputfile_mavenFolders)

%{ 
DESCRIPTION:
    Produces a list of .sts files (full path from root) based on a list of
    inputted folders

INPUT:
    inputfile_mavenFolders
        Text file where each line is a folder in mavenPath (see
        getPaths.m) containing .sts files

OUTPUT:
    mavenFiles
        List of all .sts files (full path from root) in the folders
        specified by the input file.
%}

%%% Import inputfile.txt as a cell array ("cellar"), where each line is a new cell

[~,rawMavenPath] = getPaths('repo', 'rawMaven');

% fin_fullpath = fullfile(repoPath, "code/3.input files/MAVEN folders/", inputfile_mavenFolders); 
    % edited out this line bc startup adds all to path, so no need to be so
    % specific with your path. being this specific would mean we can't make
    % any subfolders in "3.input folders" :(

% file = fopen(fin_fullpath,'r');
file = fopen(inputfile_mavenFolders,'r');
    inputFolders_cellar = textscan(file,'%s');
fclose(file);

inputFolders_cellar = inputFolders_cellar{1};



%%% Go through each folder and append all .sts files to an array
    % commented out lines implement preallocation, but annoyingly, it
    % literally only saves 0.01-0.1 seconds T_T

mavenFiles = [];

% mavenFiles = cell(1523,1);
% mavenFiles(:) = {''};
% index = 1;

for i=1 : length(inputFolders_cellar) % for every folder we'd like to traverse
   these_mavenFiles = dir( fullfile(rawMavenPath, inputFolders_cellar{i}, '*sts') ); 
    for j=1 : length(these_mavenFiles)
        fn = fullfile(these_mavenFiles(j).folder, these_mavenFiles(j).name);
        mavenFiles = [mavenFiles; fn];
%         mavenFiles{index} = fn; 
%         index = index + 1;
    end
end


end