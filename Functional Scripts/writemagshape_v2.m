function writemagshape_v2(baseFileName,h,downsample,clon,clat,Th)

%{
Converts NASA MAVEN flux magnetometer track data (.sts file format) to
shape files (.shp, .shx, .dbf) that can be visualized in QGIS.

v1:
    - Given to me.
v2:
    - Almost completely rewritten by me.
    - Only collects data from night time (between 8pm and 8am).
    - Large variables cleared after use.
    - More comments + sections.
%}

% displays datapoints before/after filters, but this doesn't work with parallel processing
verbose = true; 

%% Load data and downsample

fprintf(1, 'Now reading %s\n\n', baseFileName);

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

if verbose
    fprintf(1, 'data points originally: %u\n', length(hod));
end

%% Filter out data from daytime (from 08:00 to 20:00)

indices = find(hod < 8 | hod > 20);

posX = posX(indices);
posY = posY(indices);
posZ = posZ(indices);

magX = magX(indices);
magY = magY(indices);
magZ = magZ(indices);

hod = hod(indices);

if verbose
    fprintf(1, 'data points after night filter: %u\n', length(hod));
end

%% Convert to spherical position/magnetic-field and filter out radial heights above input "h"

% Convert position vector from cartesian to spherical coordinates, 
% and do a spherical cut around a cap specified by [clon clat Th]
    % Note: "indices" var represents the values not removed by the spherical
    % cut -- mag and hod must be filtered accordingly.
[lon_rad,cola_rad,r,~,~,~,~,indices] = MAGcart2sph(...
    posX,posY,posZ,magX,magY,magZ,[],[],[],[],[],[],[],[],[],[clon clat Th]);

clear posX posY posZ clon clat Th;
magX = magX(indices);
magY = magY(indices);
magZ = magZ(indices);


% Convert magnetic field vector from cartesian to spherical coordinates
[Blon,Bcola,Br] = dcart2dsph(lon_rad,cola_rad,magX,magY,magZ);

clear magX magY magZ;
hod = hod(indices);

if verbose
    fprintf(1, 'data points after spherical cap filter: %u\n', length(hod));
end


% Filter satellite measurements below a certain height
indices = find(r < 3390+h); % 3390 is radius of mars

hod = hod(indices);

lon_rad = lon_rad(indices);
cola_rad = cola_rad(indices);
r = r(indices);

Blon = Blon(indices);
Bcola = Bcola(indices);
Br = Br(indices);

if verbose
    fprintf(1, 'data points after height filter: %u\n\n', length(hod));
end

%% Convert final parameters to shape file

Bmag = sqrt(Blon.^2 + Bcola.^2 + Br.^2);
height = r - 3390;
lon_deg = rad2deg(lon_rad);
cola_deg = 90 - rad2deg(cola_rad);

clear r lon_rad lat_rad;

shape_struct = struct...
( ...
    'Geometry', ...
    'Multipoint', ...
    'B', num2cell(Bmag), ...
    'Br', num2cell(Br), ...
    'Blon', num2cell(Blon), ...
    'Bcola', num2cell(Bcola), ...
    'Height', num2cell(height), ...
    'HOD',num2cell(hod), ...
    'Lon', num2cell(lon_deg), ...
    'Lat',num2cell(cola_deg) ...
 );

splitStr = regexp(baseFileName,'\.','split');


if numel(Bmag) > 1
    shapewrite(shape_struct, splitStr{1});
end


end



