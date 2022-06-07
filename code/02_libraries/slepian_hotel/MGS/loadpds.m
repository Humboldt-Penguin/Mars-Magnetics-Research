function [posX,posY,posZ,magX,magY,magZ,sam,sap,sao,date,...
    RMSBvalsX,RMSBvalsY,RMSBvalsZ,BstatX,BstatY,BstatZ,...
    BdynX,BdynY,BdynZ,alerttype]=loadpds(filename)

%{
WARNING: Edits made by Zain Kamal (zain.kamal@rutgers.edu)

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


% debugging
verbose = false; 
if verbose
    fprintf(1, 'loadpds.m is verbose\n');
end
    

%% Check for Mars and pc coordinate system in header -- if not, then alert

fileID = fopen(filename,'r');

% skip the first few lines
for i=1:4
    line = fgets(fileID);
end


% set alerts:
cmdline = textscan(line,'%s%s%s%s%s%s%s%s%s%s%s%s');

if ~strcmp(cmdline{4},'-mars')
    posX=[]; posY=[]; posZ=[];
    magX=[]; magY=[]; magZ=[];
    sam=[]; sap=[]; sao=[];
    date=int16.empty(0,7);
    RMSBvalsX=[]; RMSBvalsY=[]; RMSBvalsZ=[];
    BstatX=[]; BstatY=[]; BstatZ=[];
    BdynX=[]; BdynY=[]; BdynZ=[];
    alerttype=1;
    return
end
if ~strcmp(cmdline{7},'-pc')
    posX=[]; posY=[]; posZ=[];
    magX=[]; magY=[]; magZ=[];
    sam=[]; sap=[]; sao=[];
    date=int16.empty(0,7);
    RMSBvalsX=[]; RMSBvalsY=[]; RMSBvalsZ=[];
    BstatX=[]; BstatY=[]; BstatZ=[];
    BdynX=[]; BdynY=[]; BdynZ=[];
    alerttype=2;
    return
end

%% Skip the rest of the header and read raw data

linecount = 0;

for i=1:140
    line=fgets(fileID);
    linecount = linecount + 1;
end

while ~contains(line, "20")
    line = fgets(fileID);
    linecount = linecount + 1;
end

if verbose
    fprintf(1, 'First start reading data at line: %u\n', linecount);
end

clear linecount;

% note that we read 29 arguments, even though there are usually only 18
C = textscan(fileID, '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f'); 
fclose(fileID);

date=[C{1} C{2} C{3} C{4} C{5} C{6} C{7}];
magX=C{8};
magY=C{9};
magZ=C{10};
posX=C{12};
posY=C{13};
posZ=C{14};
RMSBvalsX=C{15};
RMSBvalsY=C{16};
RMSBvalsZ=C{17};
% Note: these are typically NaN, but I have no use for them yet
BstatX=C{19};
BstatY=C{20};
BstatZ=C{21};
BdynX=C{23};
BdynY=C{24};
BdynZ=C{25};
sam=C{27};
sap=C{28};
sao=C{29};
alerttype=[];

%% Explanations of data products:
%{
mag:
Array[3] giving B-field components in the              
order Bx, By, Bz. The coordinate system                
is file dependent.

Range:
Gain range of the instrument at the time of            
the sample. Sample quantization is gain                
range dependent.  

pos:
The location of the spacecraft at the time              
of the mag vector in the same coordinate                
system as the field data.
rms:
A four vector giving the root mean square              
of the outboard delta words (there are 23              
delta words between fullwords, sampled at              
either 32, 16, or 8 per second depending                
on data rate allocation).
Explanations rms: The magnetometer output is
averaged on board with non-overlapping boxcar
functions and then sent to Earth. This value
gives the rms between the measured values that
are averaged to give one measurement value.
bsc:
A four vector giving the (static) spacecraft            
field in payload coordinates (this has been            
removed from the measured field to compensate          
for spacecraft field); see sc_mod.ker          
bd:
A four vector giving the (dynamic) spacecraft          
field in payload coordinates (this has been            
removed from the measured field to compensate          
for spacecraft field); see sc_mod.ker
sam:
Solar array (-Y panel) current from sc engineering      
data base in units mA        
sap:
Solar array (+Y panel) current from sc engineering      
data base in units mA
sao:
Solar array output current (total) from sc              
engineering data base uin units mA
For SAM_I, SAP_I, and SAO_I, '-99' is used as a fill value when the      
solar array currents are negative.  This denotes data when the            
spacecraft was in darkness.  '-999' is used as a fill value when the      
solar array currents data is not available for the time.
%}