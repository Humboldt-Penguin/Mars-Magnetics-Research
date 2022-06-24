clc
clear

%%% INPUTS (see decription for more details)
infile_craters = 'craters_70km_to_150km.txt';
infile_mavenFolders = 'inputfile_mavenReduced.txt';

maxAlt = 200;


% individual_folders = true;
% everything_in_one_folder = true;

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
    verbose(sprintf("Crater input file: %s\n", infile_craters));
    
    % minDiam = str2double(infile_craters(9:strfind(infile_craters,'km_to_')-1));
    % maxDiam = str2double(infile_craters(strfind(infile_craters,'km_to_')+6:strfind(infile_craters,'km.txt')-1)); % lol
    
    infile_craters = fullfile(getPaths('repo'), 'code', '03_input_files', 'locations', 'craters', infile_craters); % just to be safe
    infile_mavenFolders = fullfile(getPaths('repo'), 'code', '03_input_files', 'maven_folders', infile_mavenFolders); % just to be safe


% read crater locations inputfile into table
    crater = read_crater_file(infile_craters);

% get angular radius of shapefile, including padding
    theta = (diameter2angular( (crater.diam/2) ));
    theta_padded = (diameter2angular( (crater.diam/2) * (1+padding) ));
    thetas = table(theta, theta_padded);
    crater = [crater, thetas];
    clear theta theta_padded thetas
    

% load all maven data as a table (each line of each maven file) -- DO NOT MODIFY THIS ARRAY
    % METHOD 1: manually loading reduced maven files
%         [mavenFiles,~] = createFiles(getPaths('reducedMaven'), infile_mavenFolders);
%         mvn = load_maven_data(mavenFiles); 
%         clear mavenFiles
    % METHOD 2: loading from matfile
        preload_timer = tic;
        mvnmat = matfile(fullfile(getPaths('matfiles'), 'mvn.mat'));
        mvn = mvnmat.mvn;
        clear mvnmat
        verbose(sprintf("\nLoaded Maven data in %.2f seconds.\n", toc(preload_timer)));




% make folders (NOTE: in this folder naming scheme, the number refers to how far the child folder is from the main parent "folder_1"
    % baseOutputFolder = fullfile(getPaths('shapefiles'), 'craters', sprintf("%0.fkm_to_%0.fkm",minDiam,maxDiam)); 
    folder_1_kmRange = fullfile(getPaths('shapefiles'), ...
                                'craters', ...
                                infile_craters(strfind(infile_craters,'craters_')+8:strfind(infile_craters,'.txt'))); 
    % folder_2_individual = fullfile(folder_1_kmRange, 'individual');
    [~,~] = mkdir(folder_1_kmRange);


%% make creater shapefiles

crater_shapefiles_timer = tic;

for i_crater=1 : length(crater.id)

    % misc
        verbose(sprintf("Now processing crater %s", crater.id{i_crater}));
        thisCraterTimer = tic;

    % see if  there are any tracks that actually pass through the crater (as opposed to being captured in the padded radius)
        [TEST_clon_rad,~,~,~,~,~,~,~] = MAGcart2sph(...
            mvn.posX,mvn.posY,mvn.posZ,mvn.magX,mvn.magY,mvn.magZ,[],[],[],[],[],[],[],[],[],[crater.clon(i_crater) crater.lat(i_crater) crater.theta(i_crater)]);
        
        if ~isempty(TEST_clon_rad)
    
            % Convert position vector from cartesian to spherical coordinates, and do a spherical cut around a cap specified by [clon lat Th]
                [clon_rad,cola_rad,r,~,~,~,~,indices_sph] = MAGcart2sph(...
                    mvn.posX,mvn.posY,mvn.posZ,mvn.magX,mvn.magY,mvn.magZ,[],[],[],[],[],[],[],[],[],[crater.clon(i_crater) crater.lat(i_crater) crater.theta_padded(i_crater)]);
                
                magX = mvn.magX(indices_sph);
                magY = mvn.magY(indices_sph);
                magZ = mvn.magZ(indices_sph);
    
            % Altitude cut
                altitude = r - 3390; 
                indices_alt = find(altitude < maxAlt);
    
                altitude = altitude(indices_alt);
                magX = magX(indices_alt);
                magY = magY(indices_alt);
                magZ = magZ(indices_alt);
                clon_rad = clon_rad(indices_alt);
                cola_rad = cola_rad(indices_alt);
    
            % Convert magnetic field vector from cartesian to spherical coordinates
                [Blon,Bcola,Br] = dcart2dsph(clon_rad,cola_rad,magX,magY,magZ);
                Bmag = sqrt(Blon.^2 + Bcola.^2 + Br.^2);
    
            % Extra parameters
                clon_deg = rad2deg(clon_rad);
                lon_deg = clon2lon(clon_deg); % CHEEKY ADDITION FOR MY SHITTY QGIS
                lat_deg = 90 - rad2deg(cola_rad);

        
        end


    % Write shapefile if there's data for this crater
        if numel(Bmag) > 1
            % Make folder
                title = sprintf("lon=%.0f_lat=%.0f_diam=%.0f_id=%s", crater.lon(i_crater), crater.lat(i_crater), crater.diam(i_crater), crater.id{i_crater});
                folder_2_thisCrater = fullfile(folder_1_kmRange, title);
                [~,~] = mkdir(folder_2_thisCrater);

            % Write metadata
                metadata = sprintf("CRATER_ID = %s \nLON = %f \nCLON = %f \nLAT = %f \nTHETA (crater) = %f \nTHETA (padded) = %f \nDIAMETER = %f \n\nGenerated on %s", ...
                      crater.id{i_crater}, ...
                      crater.lon(i_crater), ...
                      crater.clon(i_crater), ...
                      crater.lat(i_crater), ...
                      crater.theta(i_crater), ...
                      crater.theta_padded(i_crater), ...
                      crater.diam(i_crater), ...
                      datestr(now,'mm/dd/yyyy HH:MM'));
                writeMetadata(folder_2_thisCrater, metadata);

            % Normalize Bmag
                Bmag_norm = Bmag / max(Bmag);

            % Write shapefile
                shape_struct = struct...
                    ( ...
                        'Geometry', 'Multipoint', ...
                        'CRATER_ID', crater.id{i_crater}, ...
                        'Bmag', num2cell(Bmag), ...
                        'Bmag_norm', num2cell(Bmag_norm), ...
                        'Br', num2cell(Br), ...
                        'Blon', num2cell(Blon), ...
                        'Bcola', num2cell(Bcola), ...
                        'Altitude', num2cell(altitude), ...
                        'Lon', num2cell(lon_deg), ...
                        'Clon', num2cell(clon_deg), ...
                        'Lat',num2cell(lat_deg) ...
                    );
    %             folder_3_shapefiles = fullfile(folder_2_thisCrater, 'shapefiles');
    %             [~,~] = mkdir(folder_3_shapefiles);
                shapewrite(shape_struct, fullfile(folder_2_thisCrater, title));
                verbose(sprintf("Crater %.0f/%.0f was processed in %.2f seconds", i_crater, length(crater.id), toc(thisCraterTimer)));
        else
            % if there are literally no maven measurements for this crater
                verbose(sprintf("Crater %.0f/%.0f has no data (%.2f sec).", i_crater, length(crater.id), toc(thisCraterTimer)));
        end


end

verbose(sprintf("\n\nFinished generating crater shapfiles in %.2f seconds.\n", toc(crater_shapefiles_timer)));

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

function [crater_data] = read_crater_file(infile_craters)
    crater_data = readData(infile_craters, "%s %f %f %f");
    crater_data = [crater_data{1}, num2cell(crater_data{2}), num2cell(crater_data{3}), num2cell(crater_data{4})];
    crater_data = cell2table(crater_data, ...
        'VariableNames', {'id', 'clon', 'lat', 'diam'});
    lon = table(clon2lon(crater_data.clon), 'VariableNames', {'lon'});
    crater_data = [crater_data, lon];
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

function [mvn_data] = load_maven_data(mavenFiles)
    %{
        reads the contents of many reduced maven files and returns a table
        containing the posX, posY, posZ, magX, magY, magZ
    %}
    preload_timer = tic;
    mvn_data = [];

%     % unfortunately preallocation does not work with parfor
%         num_measurements = 92825759; % the reduced maven files cumulatively have this many lines
%         mvn_data = zeros(num_measurements,6); % columns will be posX, posY, posZ, magX, magY, magZ

    parfor i_file=1 : length(mavenFiles)
        thisFile = fullfile(mavenFiles(i_file).folder, mavenFiles(i_file).name);
        this_mvn_data = loadpds_reduced_lite(thisFile);
        mvn_data = [mvn_data; this_mvn_data];
%         % unfortunately preallocation does not work with parfor
%             first_line_of_zeros = find(mvn_data(:,6) == zeros(1,6), 1);
%             mvn_data( first_line_of_zeros : first_line_of_zeros+size(this_mvn_data,1)-1 , : ) = this_mvn_data; 
    end

    mvn_data = array2table(mvn_data, ...
        'VariableNames',{'magX', 'magY', 'magZ', 'posX', 'posY', 'posZ'});
    
    verbose(sprintf("\nLoaded Maven data in %.2f seconds.\n", toc(preload_timer)));
end


function [dataArr] = loadpds_reduced_lite(fin)
    %{
        reads the contents of a reduced maven file and returns an array
        where the columsn are [posX, posY, posZ, magX, magY, magZ]
    %}

    [fid,msg] = fopen(fin,'r');
        assert(fid>=3, msg)
        data = textscan(fid, '%*f %*f %*f %*f %*f %*f %*f %f %f %f %*f %f %f %f %*f %*f %*f %*f'); 
    fclose(fid);

    dataArr = cell2mat(data); 
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
