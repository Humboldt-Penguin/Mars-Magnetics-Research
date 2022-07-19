clc
clear

%%% load cartesian maven data

tic;

path = fullfile(getPaths('matfiles'), 'mvn.mat');
mvnmat = matfile(path); 
clear path
mvn = mvnmat.mvn;
clear mvnmat

verbose(sprintf("Loaded Maven data in %.2f seconds.\n", toc));

%%% convert to spherical + format

tic;

[clon_rad,cola_rad,r,data,~,~,~,~] = MAGcart2sph(mvn.posX,mvn.posY,mvn.posZ,mvn.magX,mvn.magY,mvn.magZ,[],[],[],[],[],[],[],[],[],[]);
clear mvn

data = cell2mat(data);
    Blon = data(:,3);
    Bcola = data(:,2);
    Br = data(:,1);
clear data

lon = clon2lon(rad2deg(clon_rad)); clear clon_rad
lat = 90 - rad2deg(cola_rad); clear cola_rad

mvn_sph = table(lon, lat, r, Blon, Bcola, Br);
clear lon lat r Blon Bcola Br

verbose(sprintf("Made table in in %.2f seconds.\n", toc));

%%% save

tic;

path = fullfile(getPaths('matfiles'), "mvn_sph.mat");
save(path, 'mvn_sph');
clear path

verbose(sprintf("Saved matfile in %.2f seconds.\n", toc));


%% functions

function verbose(message)
    %{ 
    - For th sake of debugging, this function provides a centralized place 
    to control how outputs are handled.
    - We save logs as a string then write to a metadata file at the end
    instead of repeatedly opening + partially writing to a file
    %}
    
%     global logs;
    message = strcat(message, "\n");
    fprintf(message);
%     logs = strcat(logs, message);
end

% function [clon] = lon2clon(lon)  
%     clon = mod(lon,360);
% end

function [lon] = clon2lon(clon)  
    lon = mod(clon-180,360)-180;
end