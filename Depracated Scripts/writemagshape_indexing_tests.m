clc
clear all
close all

addpath("C:\Users\Zain\Documents\_Research\Mars\Slepian Libraries\slepian_alpha-master");
addpath("C:\Users\Zain\Documents\_Research\Mars\Slepian Libraries\slepian_golf-master");
addpath("C:\Users\Zain\Documents\_Research\Mars\Slepian Libraries\slepian_hotel-master");
addpath("C:\Users\Zain\Documents\_Research\Mars\Slepian Libraries\slepian_hotel-master\MGS");

baseFileName = 'mvn_mag_dummy_2.sts';
downsample = 1;
clon = 137;
clat = -5;
Th = 80;
h = 4000;

%% initial
disp("initial");

[posX,posY,posZ,magX,magY,magZ]=loadpds(baseFileName);

[lon,~,~,~,~,~,~,~]=MAGcart2sph(...
     posX,posY,posZ,magX,magY,magZ,[],[],[],[],[],[],[],[],[]);


disp("magX");
disp(magX);
disp("size = " + length(magX));
disp(" ");

disp("lon");
disp(lon);
disp("size = " + length(lon));

disp("---------------------------");
%% naive spherical cut
disp("naive spherical cut");

[posX,posY,posZ,magX,magY,magZ]=loadpds(baseFileName);

[lon,~,~,~,~,~,~,~]=MAGcart2sph( ...
    posX,posY,posZ,magX,magY,magZ,[],[],[],[],[],[],[],[],[],[clon clat Th]);

disp("magX");
disp(magX);
disp("size = " + length(magX));
disp(" ");

disp("lon");
disp(lon);
disp("size = " + length(lon));

disp("---------------------------");
%% height cut
disp("height cut");

[posX,posY,posZ,magX,magY,magZ]=loadpds(baseFileName);

[lon,~,r,~,~,~,~,~]=MAGcart2sph( ...
    posX,posY,posZ,magX,magY,magZ,[],[],[],[],[],[],[],[],[]);

indices = find(r<3390+h);
magX = magX(indices);
lon = lon(indices);

disp("magX");
disp(magX);
disp("size = " + length(magX));
disp(" ");

disp("lon");
disp(lon);
disp("size = " + length(lon));

disp("---------------------------");
%% nighttime cut
disp("nighttime cut");

[posX,posY,posZ,magX,magY,magZ,~,~,~,date] = loadpds(baseFileName);

hod = date(:,3);
indices_hod = find(hod < 8 | hod > 20);

posX = posX(indices_hod);
posY = posY(indices_hod);
posZ = posZ(indices_hod);

magX = magX(indices_hod);
magY = magY(indices_hod);
magZ = magZ(indices_hod);

hod = hod(indices_hod);

[lon,~,~,~,~,~,~,~]=MAGcart2sph( ...
    posX,posY,posZ,magX,magY,magZ,[],[],[],[],[],[],[],[],[]);


disp("magX");
disp(magX);
disp("size = " + length(magX));
disp(" ");

disp("lon");
disp(lon);
disp("size = " + length(lon));

disp("---------------------------");
%% naive spherical -> height cut
disp("naive spherical -> height cut");


[posX,posY,posZ,magX,magY,magZ]=loadpds(baseFileName);

[lon,~,r,~,~,~,~,~]=MAGcart2sph( ...
    posX,posY,posZ,magX,magY,magZ,[],[],[],[],[],[],[],[],[],[clon clat Th]);

indices = find(r<3390+h);
magX = magX(indices);
lon = lon(indices);

disp("magX");
disp(magX);
disp("size = " + length(magX));
disp(" ");

disp("lon");
disp(lon);
disp("size = " + length(lon));

disp("---------------------------");
%% height -> naive spherical cut
disp("height -> naive spherical cut");

[posX,posY,posZ,magX,magY,magZ]=loadpds(baseFileName);

indices = find(r<3390+h);

posX = posX(indices);
posY = posY(indices);
posZ = posZ(indices);
magX = magX(indices);
magY = magY(indices);
magZ = magZ(indices);

[lon,~,r,~,~,~,~,~]=MAGcart2sph( ...
    posX,posY,posZ,magX,magY,magZ,[],[],[],[],[],[],[],[],[],[clon clat Th]);


disp("magX");
disp(magX);
disp("size = " + length(magX));
disp(" ");

disp("lon");
disp(lon);
disp("size = " + length(lon));

disp("---------------------------");
%% nighttime -> naive spherical -> height cut
disp("nighttime -> naive spherical -> height cut");

Th = 100;
h = 7000;



[posX,posY,posZ,magX,magY,magZ,~,~,~,date] = loadpds(baseFileName);

posX = posX(1:downsample:end);
posY = posY(1:downsample:end);
posZ = posZ(1:downsample:end);

magX = magX(1:downsample:end);
magY = magY(1:downsample:end);
magZ = magZ(1:downsample:end);

hod = date(:,3);
hod = hod(1:downsample:end);
clear date;



indices_hod = find(hod < 8 | hod > 20);

posX = posX(indices_hod);
posY = posY(indices_hod);
posZ = posZ(indices_hod);

magX = magX(indices_hod);
magY = magY(indices_hod);
magZ = magZ(indices_hod);

hod = hod(indices_hod);
clear indices_hod;


[lon_rad,cola_rad,r,~,~,~,~,~] = MAGcart2sph(...
    posX,posY,posZ,magX,magY,magZ,[],[],[],[],[],[],[],[],[],[clon clat Th]);

% clear posX posY posZ clon clat Th;





% Convert magnetic field vector from cartesian to spherical coordinates
[Blon,Bcola,Br] = dcart2dsph(lon_rad,cola_rad,magX,magY,magZ);
% clear magX magY magZ;


% Filter satellite measurements below a certain height
indices_r = find(r < 3390+h); % 3390 is radius of mars



magX = magX(indices_r);


hod = hod(indices_r);

lon_rad = lon_rad(indices_r);
cola_rad = cola_rad(indices_r);
r = r(indices_r);

Blon = Blon(indices_r);
Bcola = Bcola(indices_r);
Br = Br(indices_r);



clear indices_r;



disp("magX");
disp(magX);
disp("size = " + length(magX));
disp(" ");

disp("lon");
disp(lon_rad);
disp("size = " + length(lon_rad));

disp("---------------------------");
%% nighttime -> corrected spherical -> height cut
disp("nighttime -> corrected spherical -> height cut");

Th = 100;
h = 5000;



[posX,posY,posZ,magX,magY,magZ,~,~,~,date] = loadpds(baseFileName);

posX = posX(1:downsample:end);
posY = posY(1:downsample:end);
posZ = posZ(1:downsample:end);

magX = magX(1:downsample:end);
magY = magY(1:downsample:end);
magZ = magZ(1:downsample:end);

hod = date(:,3);
hod = hod(1:downsample:end);
clear date;



indices_hod = find(hod < 8 | hod > 20);

posX = posX(indices_hod);
posY = posY(indices_hod);
posZ = posZ(indices_hod);

magX = magX(indices_hod);
magY = magY(indices_hod);
magZ = magZ(indices_hod);

hod = hod(indices_hod);
clear indices_hod;


[lon_rad,cola_rad,r,~,~,~,~,indices_sph] = MAGcart2sph(...
    posX,posY,posZ,magX,magY,magZ,[],[],[],[],[],[],[],[],[],[clon clat Th]);

% clear posX posY posZ clon clat Th;


magX = magX(indices_sph);
magY = magY(indices_sph);
magZ = magZ(indices_sph);
hod = hod(indices_sph);
clear indices_sph;


% Convert magnetic field vector from cartesian to spherical coordinates
[Blon,Bcola,Br] = dcart2dsph(lon_rad,cola_rad,magX,magY,magZ);
% clear magX magY magZ;


% Filter satellite measurements below a certain height
indices_r = find(r < 3390+h); % 3390 is radius of mars



magX = magX(indices_r);


hod = hod(indices_r);

lon_rad = lon_rad(indices_r);
cola_rad = cola_rad(indices_r);
r = r(indices_r);

Blon = Blon(indices_r);
Bcola = Bcola(indices_r);
Br = Br(indices_r);



clear indices_r;


disp("magX");
disp(magX);
disp("size = " + length(magX));
disp(" ");

disp("lon");
disp(lon_rad);
disp("size = " + length(lon_rad));

disp("---------------------------");
