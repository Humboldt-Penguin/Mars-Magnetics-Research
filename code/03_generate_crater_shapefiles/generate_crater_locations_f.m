function [craters] = generate_crater_locations_f(crater_database_path, minDiam, maxDiam)

% crater_database_path = 'C:\Users\zk117\Documents\00.local_WL-202\Mars_Magnetics\geological_features\crater_database\Catalog_Mars_Release_2020_1kmPlus_FullMorphData.csv';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%{ 
DESCRIPTION:
    preface: this is just `generate_crater_locations.m` in function form,
    so I can call it from `generate_crater_shapefiles.m`.

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
    maxDiam, sorted by increasing diameter. See [1] for more information.


CHANGELOG:

    2022-06-10
        - First functional version completed

    2022-06-24
        - Copy made and converted from script to function

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


% fullTimer = tic;

% open crater database file and read into cell
    [fid,msg] = fopen(crater_database_path,'r');
        assert(fid>=3, msg)

        fgets(fid); % skip header
    
        formatSpec = "";
        for i=1:29 % There are only 28 extraneous arguments but you need 29 here or it randomly inserts 1's (first instance is in row 17181). I spent an hour debugging this, fuck my life.
            formatSpec = strcat(formatSpec, " %*s");
        end
        
        craterData = textscan(fid, strcat('%s %f %f %*f %*f %f', formatSpec), 'Delimiter', ',');
        
    fclose(fid);
    
% check if any rows were removed from original file
    assert(length(craterData{1,1}) == 392431, sprintf('Crater database has been altered; There should be 392431 entries, but the inputted file has %.0f', length(craterData{1,1})));

% convert to table (for easy cuts)
    id = craterData{1,1}(:);
    lat = craterData{1,2}(:);
    clon = craterData{1,3}(:);
    diam = craterData{1,4}(:);
    clear craterData;
    craters = table(id, clon, lat, diam);
        %{ 
        craterData fields:
            CRATER_ID
            LAT_CIRC_IMG (degrees North)
            LON_CIRC_IMG (degrees East)       [TECHNICALLY CLON]
            DIAM_CIRC_IMG (km)
        See [1] for more information on each field.
        %}

% min/max diameter cut
    minDiamCut = craters.diam >= minDiam;
    craters = craters(minDiamCut,:);

    maxDiamCut = craters.diam <= maxDiam;
    craters = craters(maxDiamCut,:);
        
    clear minDiamCut maxDiamCut;

% sort by increasing diameter
    craters = sortrows(craters, 'diam');

assert(~isempty(id), 'No craters fit the given constraints.');


% fprintf("Finished extracting crater data in %.2f seconds.\n", toc(fullTimer));




end