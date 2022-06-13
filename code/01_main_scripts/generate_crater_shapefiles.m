clc
clear

%%% INPUTS (see decription for more details)
infile_craters = 'hydrated_minerals_byhand.txt';
infile_mavenFolders = 'inputfile_mavenReduced.txt';

individual_folders = true;
everything_in_one_folder = true;

padding = 2.0; % eg "0.5" means the shapefiles extend beyond the crater rim by 50% of the radius

saveLogs = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%{ 

- open file and textscan id, lon, lat, diameter
- convert diameter to angular radius (make separate array)

- writemagshape
    - get maven measurements that fit those criteria
    - write to shape file
    

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% misc prep
    global logs; %#ok<*GVMIS> 
    logs = "";
    
    fullTimer = tic;
    verbose(sprintf("Started running at %s", datestr(now,'HH:MM')));
    verbose(sprintf("Crater input file: %s\nMaven folders input file: %s\n", infile_craters, infile_mavenFolders));
    
    % minDiam = str2double(infile_craters(9:strfind(infile_craters,'km_to_')-1));
    % maxDiam = str2double(infile_craters(strfind(infile_craters,'km_to_')+6:strfind(infile_craters,'km.txt')-1)); % lol
    
    infile_craters = fullfile(getPaths('repo'), 'code', '03_input_files', 'locations', 'craters', infile_craters); % just to be safe
    infile_mavenFolders = fullfile(getPaths('repo'), 'code', '03_input_files', 'maven_folders', infile_mavenFolders); % just to be safe


% extract contents from inputfile
    data = readData(infile_craters, "%s %f %f %f");
    
    id = data{1};
    clon = data{2};
    lon = clon2lon(clon);
    lat = data{3};
    diam = data{4};
    clear data


% get angular radius of shapefile, including padding
    theta = diameter2angular( (diam/2) * (1+padding) );


% get maven file paths
    [mavenFiles,~] = createFiles(getPaths('reducedMaven'), infile_mavenFolders);


% make folders (NOTE: in this folder naming scheme, the number refers to how far the child folder is from the main parent "folder_1"
    % baseOutputFolder = fullfile(getPaths('shapefiles'), 'craters', sprintf("%0.fkm_to_%0.fkm",minDiam,maxDiam)); 
    folder_1_kmRange = fullfile(getPaths('shapefiles'), 'craters', infile_craters(strfind(infile_craters,'craters_')+8:strfind(infile_craters,'.txt'))); 
    folder_2_individual = fullfile(folder_1_kmRange, 'individual');
    [~,~] = mkdir(folder_2_individual);


% make shapefiles for each crater

for i_crater=1 : length(id)

    thisCraterTimer = tic;

    % makefolder
        title = sprintf("lon=%.0f,lat=%.0f,diam=%.0f,id=%s", lon(i_crater), lat(i_crater), diam(i_crater), id{i_crater});
        folder_3_thisCrater = fullfile(folder_2_individual, title);
        [~,~] = mkdir(folder_3_thisCrater);

    % write metadata
        metadata = sprintf("CRATER_ID = %s \nLON = %f \nLON = %f \nLAT = %f \nTheta = %f \nDIAMETER = %f \n\nGenerated on %s", ...
                            id{i_crater},           lon(i_crater),    clon(i_crater),    lat(i_crater),    theta(i_crater),    diam(i_crater),          datestr(now,'mm/dd/yyyy HH:MM'));
        writeMetadata(folder_3_thisCrater, metadata)


    % write shapefiles

    thisClon = clon(i_crater);
    thisLat = lat(i_crater);
    thisTheta = theta(i_crater);

    Br_combined = [];
    Bmag_combined = [];
    lon_deg_combined = [];
    lat_deg_combined = [];


    parfor i_file=1 : length(mavenFiles) % loop over all maven files

        % extract position and magnitude of magnetic field
        thisFile = fullfile(mavenFiles(i_file).folder, mavenFiles(i_file).name);
        [posX,posY,posZ,magX,magY,magZ] = loadpds_reduced_lite(thisFile);


        % Convert position vector from cartesian to spherical
        % coordinates, and do a spherical cut around a cap specified by
        % [clon lat Th]
        [clon_rad,cola_rad,r,~,~,~,~,indices_sph] = MAGcart2sph(...
            posX,posY,posZ,magX,magY,magZ,[],[],[],[],[],[],[],[],[],[thisClon thisLat thisTheta]);
        
        magX = magX(indices_sph);
        magY = magY(indices_sph);
        magZ = magZ(indices_sph);
            

        % Convert magnetic field vector from cartesian to spherical coordinates
        [Blon,Bcola,Br] = dcart2dsph(clon_rad,cola_rad,magX,magY,magZ);


        % Get final parameters
        
        Bmag = sqrt(Blon.^2 + Bcola.^2 + Br.^2);
        altitude = r - 3390;

        clon_deg = rad2deg(clon_rad);
        lon_deg = clon2lon(clon_deg); % CHEEKY ADDITION FOR MY SHITTY QGIS

        lat_deg = 90 - rad2deg(cola_rad);

%         % debugging for checking values
%             if ~isempty(clon_rad) 
%                 x = 1; % set breakpoint here
%             else
%                 fprintf("no hits\n");
%             end


%             % I'm combining all outputs and writing a single shape file so i can better classify the min/max values 
% 
%             shape_struct = struct...
%             ( ...
%                 'Geometry', 'Multipoint', ...
%                 'B', num2cell(Bmag), ...
%                 'Br', num2cell(Br), ...
%                 'Blon', num2cell(Blon), ...
%                 'Bcola', num2cell(Bcola), ...
%                 'Height', num2cell(altitude), ... % ARE THESE NECESSARY????
%                 'Lon', num2cell(clon_deg), ...
%                 'Lat',num2cell(cola_deg) ...
%              );
%             
%             
%             temp = regexp(thisFile,'\\','split');
%             temp = temp{end};
%             temp = regexp(temp,'\.','split');
%             newFilePath = fullfile(folder_3_thisCrater, temp{1});
%             % newFilePath = newFilePath{1};
%             
%             if numel(Bmag) > 1
%                 shapewrite(shape_struct, newFilePath);
%             %     fprintf(1, "Shapefile created for %s\n", temp{1});
%             end


        % add to combined array for writing at the end
        Br_combined = [Br_combined; Br];
        Bmag_combined = [Bmag_combined; Bmag];
        lon_deg_combined = [lon_deg_combined; lon_deg];
        lat_deg_combined = [lat_deg_combined; lat_deg];



    end % end parfor for this crater

    


    if numel(Bmag_combined) > 1
        shape_struct = struct...
            ( ...
                'Geometry', 'Multipoint', ...
                'Br', num2cell(Br_combined), ...
                'Bmag', num2cell(Bmag_combined), ...
                'Lon', num2cell(lon_deg_combined), ...
%                 all vector components + normalized Bmag + id
                'Lat',num2cell(lat_deg_combined) ...
            );
  
        shapewrite(shape_struct, fullfile(folder_3_thisCrater, title));
        verbose(sprintf("Crater %.0f/%.0f was processed in %.2f seconds", i_crater, length(id), toc(thisCraterTimer)));
    else
        verbose(sprintf("Crater %.0f/%.0f has no data (%.2f sec).", i_crater, length(id), toc(thisCraterTimer)));
    end




end


verbose(sprintf("\nScript finished runnning in %.2f seconds.\n", toc(fullTimer)));

%%
% save logs
    metadata = strcat(sprintf("Generated on %s\n\n", datestr(now,'mm/dd/yyyy HH:MM')), logs);
    writeMetadata(folder_1_kmRange, metadata);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% Functions


function [data] = readData(infile, formatSpec)
    [fid,msg] = fopen(infile, 'r');
    assert(fid>=3, msg)
    
    % skip header
    line = "";
    while(~contains(line, "~~~~~START DATA~~~~~"))
        line = fgets(fid);
    end
    
    % read contents
    data = textscan(fid, formatSpec);
    
    fclose(fid);
end


function [theta] = diameter2angular(diameter)
    %{
        Converts a crater's diameter from kilometers to degrees. 
        
        This equation is obtained by looking at many craters on JMars and
        roughly measuring the angular separation between the left and right
        edges. We then plot this against diameter in km (accessed from
        generate_crater_locations.m) and then finding the line of best fit,
        which is linear. Rough calculations here:
            https://docs.google.com/spreadsheets/d/1Ylr_Oowq_jV1KNXEGuSvXbWNbPZNGUQF1jjv2eTC7Jg/edit?usp=sharing
    %}

    theta = 0.0186*diameter - 0.122;
end



function [mavenFiles,inputFolders] = createFiles(mavenBasePath, infile_mavenFolders)

    file = fopen(infile_mavenFolders,'r');
        inputFolders = textscan(file,'%s');
    fclose(file);
    
    inputFolders = inputFolders{1};
    mavenFiles = [];
    
    for i=1 : length(inputFolders)
        thisFolder = fullfile(mavenBasePath,inputFolders{i}, '*sts');
        this_mavenFiles = dir(thisFolder);
        mavenFiles = [mavenFiles; this_mavenFiles]; %#ok<AGROW> 
    end
    
    return
end


function writeMetadata(folder, metadata)
    [fid,msg] = fopen(fullfile(folder, 'metadata.txt'),'w');
        assert(fid>=3, msg)
        fprintf(fid, metadata);
    fclose(fid);
end


function [posX,posY,posZ,magX,magY,magZ] = loadpds_reduced_lite(fin)
    [fid,msg] = fopen(fin,'r');
        assert(fid>=3, msg)
        data = textscan(fid, '%*f %*f %*f %*f %*f %*f %*f %f %f %f %*f %f %f %f %*f %*f %*f %*f'); 
    fclose(fid);

    posX = data{4}; posY = data{5}; posZ = data{6};
    magX = data{1}; magY = data{2}; magZ = data{3};
end


% NOTE: default qgis projection uses lon
function [clon] = lon2clon(lon) %#ok<DEFNU> 
    clon = mod(lon,360);
end
function [lon] = clon2lon(clon)  
    lon = mod(clon-180,360)-180;
end



function verbose(message)
    % For the sake of debugging, this function provides a centralized place
    % to control how outputs are handled (printed to terminal, stored and
    % then written to a file at the end, etc)

    global logs;
    message = strcat(message, "\n \n");
    fprintf(message);
    logs = strcat(logs, message);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Self-notes: