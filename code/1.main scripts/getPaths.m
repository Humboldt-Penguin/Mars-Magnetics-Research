function varargout = getPaths(varargin)


% EDIT THIS STRUCT ACCORDING TO YOUR SYSTEM (see description)
pathTo = struct( ...
'repo',          'C:\Users\zk117\Documents\01.Research\Mars-Magnetics', ...
'rawMaven',      'C:\Users\zk117\Documents\00.local_WL-202\Mars-Magnetics_Data\MAVEN_MAG\raw', ...
'reducedMaven',  'C:\Users\zk117\Documents\00.local_WL-202\Mars-Magnetics_Data\MAVEN_MAG\reduced'...
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
        will be stored (eg if reducedMavenPath='...\reduced', then one
        sub-folder might bem '\reduced\200km\...').

%}

for i=1 : nargin
    varargout{i} = pathTo.(varargin{i});
end


end