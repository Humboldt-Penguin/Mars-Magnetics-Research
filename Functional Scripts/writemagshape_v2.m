function writemagshape_v2(baseFileName,h,downsample,clon,clat,Th)

%{
Converts NASA MAVEN flux magnetometer track data (.sts file format) to
shape files (.shp, .shx, .dbf) that can be visualized in QGIS.

v1:
    - Only height filtering, possibly inaccurate indexing with MAGcart2sph.
v2:
    - Almost completely rewritten.
    - filters by night time (between 8pm and 8am) and height.
    - Large variables cleared after use.
    - More comments + sections.
%}

% displays datapoints before/after filters, but this doesn't work with parallel processing
verbose = false; 

%% Load data and downsample

% fprintf(1, 'Now reading %s\n\n', baseFileName);

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
    fprintf(1, '# data points originally: %u\n', length(hod));
end

%% Filter out data from daytime (from 08:00 to 20:00)

indices_hod = find(hod < 8 | hod > 20);

posX = posX(indices_hod);
posY = posY(indices_hod);
posZ = posZ(indices_hod);

magX = magX(indices_hod);
magY = magY(indices_hod);
magZ = magZ(indices_hod);

hod = hod(indices_hod);
clear indices_hod;

if verbose
    fprintf(1, 'data points after night filter: %u\n', length(hod));
end



%% Convert to spherical position/magnetic-field and filter out radial heights above input "h"

% Convert position vector from cartesian to spherical coordinates, 
% and do a spherical cut around a cap specified by [clon clat Th]
    % Note: "indices" var represents the values not removed by the spherical
    % cut -- mag and hod must be filtered accordingly.
    
% if (isempty(magX) | isempty(magY) | isempty(magY)) % avoids an annoying error
%     return
% end

[lon_rad,cola_rad,r,~,~,~,~,indices_sph] = MAGcart2sph(...
    posX,posY,posZ,magX,magY,magZ,[],[],[],[],[],[],[],[],[],[clon clat Th]);

clear posX posY posZ clon clat Th;

magX = magX(indices_sph);
magY = magY(indices_sph);
magZ = magZ(indices_sph);
hod = hod(indices_sph);
clear indices_sph;


% Convert magnetic field vector from cartesian to spherical coordinates
[Blon,Bcola,Br] = dcart2dsph(lon_rad,cola_rad,magX,magY,magZ);
clear magX magY magZ;

if verbose
    fprintf(1, 'data points after spherical cap filter: %u\n', length(hod));
end


% Filter satellite measurements below a certain height
indices_r = find(r < 3390+h); % 3390 is radius of mars

hod = hod(indices_r);

lon_rad = lon_rad(indices_r);
cola_rad = cola_rad(indices_r);
r = r(indices_r);

Blon = Blon(indices_r);
Bcola = Bcola(indices_r);
Br = Br(indices_r);
clear indices_r;

if verbose
    fprintf(1, 'data points after height filter: %u\n\n', length(hod));
end

%% Convert final parameters to shape file

Bmag = sqrt(Blon.^2 + Bcola.^2 + Br.^2);
altitude = r - 3390;
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
    'Height', num2cell(altitude), ...
    'HOD',num2cell(hod), ...
    'Lon', num2cell(lon_deg), ...
    'Lat',num2cell(cola_deg) ...
 );

splitStr = regexp(baseFileName,'\.','split');


if numel(Bmag) > 1
    shapewrite(shape_struct, splitStr{1});
end


end
