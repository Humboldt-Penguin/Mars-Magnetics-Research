function varargout = getPaths(varargin)


% EDIT THIS STRUCT ACCORDING TO YOUR SYSTEM (see description)
pathTo = struct( ...
'repo',             'C:\Users\zk117\Documents\01.Research\Mars-Magnetics', ...
'rawMaven',         'C:\Users\zk117\Documents\00.local_WL-202\Mars_Magnetics\MAVEN_MAG\raw', ...
'reducedMaven',     'C:\Users\zk117\Documents\00.local_WL-202\Mars_Magnetics\MAVEN_MAG\reduced', ...
'shapefiles',       'C:\Users\zk117\Documents\00.local_WL-202\Mars_Magnetics\magnetic_shapefiles', ...
'matfiles',         'C:\Users\zk117\Documents\00.local_WL-202\Mars_Magnetics\MAVEN_MAG\reduced\matfiles' ...
);



%{
DESCRIPTION: 
    This is purely for convenience. Instead of inputting paths at the top
    of every script that needs them, just change this function once and
    call it when needed.

    When using this repository, you must first edit the "pathTo" struct
    with your user/system specific paths from root to each of the following
    (see inputs for more detail).


INPUT:
    repo: 
        'Mars-Magnetics' repository
    
    rawMaven:
        Folder containing unzipped MAVEN files (may or may not be separated
        into months).

    reducedMaven:
        Folder where 'reduced' files created from 'reduce_MAVEN_MAG.m'
        will be stored.
        These files can also be downloaded from here:
            https://rutgers.box.com/s/o9nc40xrd4auip4fjokd3ntif3xg4n0z
    
CHANGELOG:

    2022-05-28:
        - First version completed.

%}

for i=1 : nargin
    varargout{i} = pathTo.(varargin{i});
end


end