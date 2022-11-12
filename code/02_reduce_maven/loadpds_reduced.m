function [posX,posY,posZ,magX,magY,magZ,date,RMSBvalsX,RMSBvalsY,RMSBvalsZ,BstatX,BstatY,BstatZ,...
    BdynX,BdynY,BdynZ,alerttype] = loadpds_reduced(fin)

%{
WARNING: Edits made by Zain Kamal (zain.eris.kamal@rutgers.edu)

6/11/22:
    - `loadpds_reduced.m` made as a copy of `loadpds.m` to work with
    reduced maven files. Functionality is identical.
    - Removed extraneous output arguments (the original files only have 18
    fields, whereas the original lists 29 -- i have no idea why).

3/20/22:
    - Instead of skipping 500 lines in, we skip 140 in and then look for
    the first instance of "20" (year beginning)

2/13/22:
    - Comments explaining what stuff is doing
    - Not skipping the first few lines of data (skip 500 lines in)
%}

%{
[posX,posY,posZ,magX,magY,magZ,sam,sap,sao,date,...
   RMSBvalsX,RMSBvalsY,RMSBvalsZ,BstatX,BstatY,BstatZ,...
   BdynX,BdynY,BdynZ,alerttype]=loadpds(filename)

Reads a .STS file and returns the locations, magnetic field components,
and meta data such as solar panel output, error estimations, and date.
Description of the individual fields can be found inside this mfile

WARNING: I trimmed it to read only Mars and planetocentric. If you want
         to use it for anything else: you need to change the abort
         setting in this code.

INPUT:

filename      directory and name of the .STS file to be read

OUTPUT:

posX, posY, posZ  location in coordinates of the .STS file
magX, magY, magZ  magnetic field components in coordinate system defined
                  in the  .STS file (e.g. Planetocentric or SunState)
sam, sap, sao     Solar panel output: left solar panel: sam,
                  right solar panel: sap, total solar panel output: sao
date              date when the measurement was made by MGS
RMSBvalsX,Y,Z     Some error measure for B field (I think from binning)
BstatX,Y,Z        Some measure for B static noise (I think modeled)
BdynX,Y,Z         Some measure for B dynamic noise (I think modeled)
alerttype         Why not read? 1: Not Mars, 2: Not planetocentric
   
Example:
filename = 'datadir/DATA/MARS/1999/060_090MAR/MAG_PCENTRIC/99060.STS';
[posX,posY,posZ,magX,magY,magZ,sam,sap,sao,date,...
   RMSBvalsX,RMSBvalsY,RMSBvalsZ,BstatX,BstatY,BstatZ,...
   BdynX,BdynY,BdynZ,alerttype]=loadpds(filename);

Last modified by plattner-at-alumni.ethz.ch, 02/26/2015
%}

[fid,msg] = fopen(fin,'r');
    assert(fid>=3, msg)

    % the original loadpds takes 29 arguments even though the files only
    % have 18. I have no idea why. I corrected this.
    C = textscan(fid, '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f'); 

fclose(fid);

date=[C{1} C{2} C{3} C{4} C{5} C{6} C{7}]; % YEAR, DOY, HOUR, MIN, SEC, MSEC, DECIMAL_DAY

magX=C{8};
magY=C{9};
magZ=C{10};

% we skip 11 bc it's always 0, no idea what it is.

posX=C{12};
posY=C{13};
posZ=C{14};

% % These arguments always have values, but I currently have no use for them
% RMSBvalsX=C{15};
% RMSBvalsY=C{16};
% RMSBvalsZ=C{17};

% we skip 18 bc it's always 0, no idea what it is.


%---------------------------------------------------

% % These are not present in the original sts file...
% BstatX=C{19};
% BstatY=C{20};
% BstatZ=C{21};
% BdynX=C{23};
% BdynY=C{24};
% BdynZ=C{25};
% sam=C{27};
% sap=C{28};
% sao=C{29};
% alerttype=[];



end