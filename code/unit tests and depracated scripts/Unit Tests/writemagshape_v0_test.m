clc
clear all
close all


baseFileName = 'mvn_mag_dummy.sts';
h = 5000-3390;
% h = 1000000;
downsample = 1;
clon = 137;
clat = -5;
Th = 100;

% verbose = true;

%%% Load data and downsample

% function [count] = writemagshape_v0(baseFileName,h,downsample,clon,clat,Th)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

posX=[];
posY=[];
posZ=[];
magX=[];
magY=[];
magZ=[];
expression = '\.';
[posXi,posYi,posZi,magXi,magYi,magZi]=loadpds(baseFileName);


posX=[posX;posXi(1:downsample:end)];
    posY=[posY;posYi(1:downsample:end)];
    posZ=[posZ;posZi(1:downsample:end)];
    magX=[magX;magXi(1:downsample:end)];
    magY=[magY;magYi(1:downsample:end)];
    magZ=[magZ;magZi(1:downsample:end)];


disp("initial");
disp("magX");
disp(magX);
disp(length(magX));
disp("posX");
disp(posX);
disp(length(posX));




[lon,cola,r,~,~,~,~,~]=MAGcart2sph(...
    posX,posY,posZ,magX,magY,magZ,[],[],[],[],[],[],[],[],[],[clon clat Th]);
%     posX,posY,posZ,magX,magY,magZ,[],[],[],[],[],[],[],[],[]);



disp("spherical cut");
disp("magX");
disp(magX);
disp(length(magX));
disp("lon");
disp(lon);
disp(length(lon));

%%% filter by height

indices = find(r<3390+h);
% fprintf(1, 'Now reading %s\n', baseFileName);
height = r(indices);
lonn = lon(indices);
latt = cola(indices);
magXX = magX(indices);
magYY = magY(indices);
magZZ = magZ(indices);

disp("height cut");
disp("magXX")
disp(magXX);
disp(length(magXX));
disp("lonn")
disp(lonn);
disp(length(lonn));



%% create shape file

[dlon,dcola,dr]=dcart2dsph(lonn,latt,magXX,magYY,magZZ);
explon = rad2deg((lonn));
explat = rad2deg((latt));
B = sqrt(dlon.^2 + dcola.^2 + dr.^2);
% index2 = find(explon > 180);
% explon(index2) = -360 + explon(index2);
explat = 90-explat;
expheight = height - 3390;
Bval = B;
Br = dr;
Blon = dlon;
Bcola = dcola;
lonval = explon;
latval = explat;
heightval = expheight;
test2 = struct('Geometry', 'Multipoint','B',num2cell(Bval),'Br',num2cell(Br),'Blon',num2cell(Blon),'Bcola',num2cell(Bcola),'Height',num2cell(heightval),'Lon', num2cell(lonval), 'Lat',num2cell(latval));
splitStr = regexp(baseFileName,expression,'split');

%% write to shape file
if numel(B) > 1
shapewrite(test2, splitStr{1});
end
% end