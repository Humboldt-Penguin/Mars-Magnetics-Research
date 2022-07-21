clc
clear

%%% INPUTS (see decription for more details)
minDiam = 70;
maxDiam = 150;

minAlt = 0;
maxAlt = 200;

padding = 10.0; % eg "0.5" means the shapefiles extend beyond the crater rim by 0.5 times the radius

crater_database_path = 'C:\Users\zk117\Documents\00.local_WL-202\Mars_Magnetics\geological_features\crater_database\Catalog_Mars_Release_2020_1kmPlus_FullMorphData.csv';

write_shape = false;
write_minmaxstats = false;
saveLogs = true;

% infile_mavenFolders = 'inputfile_mavenReduced.txt';
% infile_craters = 'craters_70km_to_150km.txt';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%{ 

write this out btw lol

v2 just uses a version of the maven measurements that is already converted to radial
    but this makes squares lol oopsie
    

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

fullTimer = tic;

% misc prep
    global logs; %#ok<*GVMIS> 
    logs = "";
    verbose(sprintf("Started running at %s \n\n" + ...
                    "* Minimum crater diameter = %f \n" + ...
                    "* Maximum crater diameter = %f \n" + ...
                    "* Maximum satellite altitude = %.0f \n" + ...
                    "* Crater padding for shapefiles = %.2f", ...
                    datestr(now,'HH:MM'), minDiam, maxDiam, maxAlt, padding));


% read crater locations inputfile into table
    % METHOD 1: read the input file (.txt) generated by generate_crater_locations.m
        % crater = read_crater_file(infile_craters);
    % METHOD 2: start from scratch and call `generate_crater_locations_f.m`, which reads + filters the crater database csv file
        cratersTimer = tic;
        craters = generate_crater_locations_f(crater_database_path, minDiam, maxDiam);
        lon = clon2lon(craters.clon);
        craters = [craters, table(lon)]; clear lon
        verbose(sprintf("\nLoaded crater data in %.2f seconds.", toc(cratersTimer)));
        verbose(sprintf("There are %.0f craters that fit the diameter constraints.", height(craters)));


% get angular radius (including padding) of shapefile surround crater
    theta = (diameter2angular( (craters.diam/2) ));
    theta_padded = (diameter2angular( (craters.diam/2) * (1+padding) ));
    craters = [craters, table(theta, theta_padded)];
    clear theta_padded theta


% load all maven data as a table (each line of each maven file) -- DO NOT MODIFY THIS ARRAY
    % METHOD 1: manually loading reduced maven files
%         [mavenFiles,~] = createFiles(getPaths('reducedMaven'), infile_mavenFolders);
%         mvn = load_maven_data(mavenFiles); 
%         clear mavenFiles
    % METHOD 2: loading from matfile (cart vers)
        preload_timer = tic;
        path = fullfile(getPaths('matfiles'), 'mvn_sph.mat');
        mvnmat = matfile(path); clear path
        mvn_sph = mvnmat.mvn_sph;
        clear mvnmat
        verbose(sprintf("\nLoaded Maven data in %.2f seconds.\n\n", toc(preload_timer)));

% %%
% % if generating mvn for the first time, save it as a matfile
%     path = fullfile(getPaths('matfiles'), 'mvn.mat');
%     save(path, 'mvn');
% %%

%%%

% initialize MinMaxStats table 
    components_stats = ["Bmag", "Br", "Blon", "Bcola"];
    varNames = ["id_matlab", "id_Robbins2012"];
    varTypes = ["uint64", "string"];
    for component=components_stats
        for deg = 0:3
            base = sprintf('%s_deg%u_', component, deg);
            varNames = [varNames, strcat(base,'mins'), strcat(base,'maxs'), strcat(base,'either')]; %#ok<AGROW> 
            varTypes = [varTypes, "double", "double", "double"]; %#ok<AGROW> 
        end
    end
    MinMaxStats = table('Size',[height(craters),length(varNames)],'VariableTypes',varTypes,'VariableNames',varNames);
    clear varNames varTypes;
    

% make folders (NOTE: in this folder naming scheme, the number refers to how far the child folder is from the main parent "folder_1"
    folder_1_diamRange = fullfile(getPaths('shapefiles'), ...
                                'craters', ...
                                sprintf('diam=[%.0f,%.0f]_alt=[%.0f,%.0f]_pad=%.0f', minDiam, maxDiam, minAlt, maxAlt, padding)); 
    [~,~] = mkdir(folder_1_diamRange);


% Save crater stats table as csv
    index = 1:height(craters);
    index = index';
    index = table(index);
    craters_csv = [index, craters];
    
    title = sprintf('CraterStats__diam=[%.0f,%.0f]_alt=[%.0f,%.0f].csv', minDiam, maxDiam, minAlt, maxAlt);
    writetable(craters_csv, fullfile(folder_1_diamRange, title));


% making crater shapefiles + plots of B-field cross-section

allCratersTimer = tic;

for i_crater=1 : height(craters)

    thisCraterTimer = tic;


    % If are any tracks that actually pass through the crater (as opposed to being captured in the padded radius), continue with processing
    if maxAlt < 200 % || craters.diam(i_crater) < 40
        inlon = abs(mvn_sph.lon - craters.lon(i_crater)) < craters.theta(i_crater);
        inlat = abs(mvn_sph.lat - craters.lat(i_crater)) < craters.theta(i_crater);
        incrater = any(inlon) && any(inlat);
    else
        incrater = true; % just setting this to true for optimization. The checks take abt 0.4 sec, but we can just discriminate via the plots
    end

    if ~incrater
        verbose(sprintf("--- Skipping crater %.0f/%.0f -- no tracks pass through this crater (%.2f sec).", i_crater, length(craters.id), toc(thisCraterTimer)));
        continue
    end

    clear incrater

    % Do a spherical cut around the padded crater
    % also collect varaibles into thisCrater table for easy indexing
        loncut = abs(mvn_sph.lon - craters.lon(i_crater)) < craters.theta_padded(i_crater);
        thisCrater = mvn_sph(loncut,:); clear loncut
        latcut = abs(thisCrater.lat - craters.lat(i_crater)) < craters.theta_padded(i_crater);
        thisCrater = thisCrater(latcut,:); clear latcut

        altitude = thisCrater.r - 3390;
        thisCrater = [thisCrater, table(altitude)]; clear altitude     %#ok<AGROW> 
        altcut = thisCrater.altitude < maxAlt;
        thisCrater = thisCrater(altcut,:); clear altcut

        Bmag = sqrt(thisCrater.Blon.^2 + thisCrater.Bcola.^2 + thisCrater.Br.^2);
        clon = lon2clon(thisCrater.lon);
        thisCrater = [thisCrater, table(Bmag, clon)]; clear Bmag clon     %#ok<AGROW> 



    % If there are still measurements within the altitude cut, write to shape file and do cross-sectional analysis
        if height(thisCrater) == 0
            verbose(sprintf("--- Skipping crater %.0f/%.0f -- no tracks fit within the altitude range (%.2f sec).", i_crater, length(craters.id), toc(thisCraterTimer)));
            continue
        end
    

    % Now write to shapefile and do cross-sectional track analysis   

    % Make folder
        thisCrater_title = sprintf...
            (...
                "%04d__(%.0f,%.0f)__%.0fkm", ...
                i_crater, ...
                craters.lon(i_crater), ...
                craters.lat(i_crater), ...
                craters.diam(i_crater) ...
            );
        folder_2_thisCrater = fullfile(folder_1_diamRange, thisCrater_title);
        [~,~] = mkdir(folder_2_thisCrater);

    % Write metadata
        metadata = sprintf...
            (...
                "CRATER_ID = %s \n" + ...
                "LON = %f \n" + ...
                "CLON = %f \n" + ...
                "LAT = %f \n" + ...
                "THETA (crater) = %f \n" + ...
                "THETA (padded) = %f \n" + ...
                "DIAMETER = %f \n" + ...
                "maxAlt = %.0f \n\n" + ...
                "Shapefile contains %.0f Maven data points \n" + ...
                "Generated on %s", ...
                craters.id{i_crater}, ...
                craters.lon(i_crater), ...
                craters.clon(i_crater), ...
                craters.lat(i_crater), ...
                craters.theta(i_crater), ...
                craters.theta_padded(i_crater), ...
                craters.diam(i_crater), ...
                maxAlt, ...
                height(thisCrater), ...
                datestr(now,'mm/dd/yyyy HH:MM') ...
            );
        writeMetadata(folder_2_thisCrater, metadata);                    


    % Isolate tracks that pass through the crater and apply in_crater flags (converted to function bc costly)
        % Addition 7/11/22: also create a Bmag_norm array to write to the shapefile
        [good_tracks, Bmag_norm] = isolateGoodTracks(thisCrater, craters(i_crater,:));

    % Add Bmag_norm to crater field
        thisCrater = [thisCrater, table(Bmag_norm)]; %#ok<AGROW> 

    % Quick detour now that we have Bmag_norm: write shapefile
        if write_shape
            shape_struct = struct...
                ( ...
                'Geometry', 'Multipoint', ...
                'CRATER_ID', craters.id{i_crater}, ...
                'Bmag', num2cell(thisCrater.Bmag), ...
                'Bmag_norm', num2cell(thisCrater.Bmag_norm), ...
                'Br', num2cell(thisCrater.Br), ...
                'Blon', num2cell(thisCrater.Blon), ...
                'Bcola', num2cell(thisCrater.Bcola), ...
                'Altitude', num2cell(thisCrater.altitude), ...
                'Lon', num2cell(thisCrater.lon), ...
                'Clon', num2cell(thisCrater.clon), ...
                'Lat',num2cell(thisCrater.lat) ...
                );
            shapewrite(shape_struct, fullfile(folder_2_thisCrater, thisCrater_title));
        end


    % Find the percentage of tracks where the max/min B value within 200% radius occurs within 150% radius
        if write_minmaxstats
    
            thisMinMaxStats = {i_crater, craters.id(i_crater)};
            
            for i=1:length(components_stats)
                component = components_stats(i);
                for deg = 0:3
                    numMin = 0;
                    numMax = 0;
                    for thisTrack = good_tracks
                        
                        thisTrack = thisTrack{1};  
                        B_array = thisTrack.(component);
                        B_array = smoothdata(B_array, 'sgolay', 200);
                        if deg > 0
                            B_array = detrend(B_array, deg);
                        end
            
                        start_200 = find(thisTrack.in_crater_200, 1, 'first');
                        end_200 = find(thisTrack.in_crater_200, 1, 'last');
            
                        minVal_200 = min(B_array(start_200:end_200));
                        maxVal_200 = max(B_array(start_200:end_200));
                        
                        minIndex = find(B_array == minVal_200);
                        maxIndex = find(B_array == maxVal_200);
                        
                        hasMin = thisTrack.in_crater_150(minIndex);
                        hasMax = thisTrack.in_crater_150(maxIndex);
                    
                        start_150 = find(thisTrack.in_crater_150, 1, 'first');
                        end_150 = find(thisTrack.in_crater_150, 1, 'last');
                        if start_150 == 1 || end_150 == height(thisTrack)
                            hasMin = false;
                            hasMax = false;
                        end
                        numMin = numMin + hasMin;
                        numMax = numMax + hasMax;
                    end
            
                    numTracks = length(good_tracks);
                    percentMin = numMin / numTracks;
                    percentMax = numMax / numTracks;
                    percentMinOrMax = (numMin + numMax) / numTracks;
            
                    thisMinMaxStats = [thisMinMaxStats(:)', {percentMin}, {percentMax}, {percentMinOrMax}]; 
                end
            end
            
            MinMaxStats(i_crater,:) = cell2table(thisMinMaxStats);
    
        end


    %{ 
    Make and save plots
        v1 makes 4 2x2 plots, each containing the 4 components but detrendeed to different degrees. The undetrended one is saved in _plots.
        v2 makes 1 4x4 plot, where each row is the 4 components but each row has different detrending. This is also saved in _plots.
            edit: v2 sucks (this implementation doesn't work, but more importantly the plots are just far far too small)
    %}
        components_plots = ["Bmag", "Bmag_norm", "altitude", ...
                      "Br", "Blon", "Bcola"];
        
        titles = ["$|B| \ [\rm{nT}]$", "$||B|| \ [\rm{nT}]$", "$\rm{Altitude} \ [\rm{km}]$"...
                  "$B_r \ [\rm{nT}]$", "$B_\theta \ [\rm{nT}]$", "$B_\phi \ [\rm{nT}]$"];

        orders = ["No", "Linear", "Quadratic", "Cubic"];
        trackColors = distinguishable_colors(length(good_tracks));

        % v1 of making plots
        for deg = 0:1
            fig = figure('visible','off');
            fig.Position = [0,0,1700,700];
        
            for comp = 1:6
                subplot(2,3,comp);
                hold on
                box on
                xlim('tight');
                ylim('padded');
                
                xline(craters.lat(i_crater) - craters.theta(i_crater));
                xline(craters.lat(i_crater) + craters.theta(i_crater));
                xline(craters.lat(i_crater) - 1.5*craters.theta(i_crater), '--black');
                xline(craters.lat(i_crater) + 1.5*craters.theta(i_crater), '--black');
                
                xlabel('Latitude $[^\circ]$','Interpreter','latex','FontSize',14);
                ylabel(titles(comp),'Interpreter','latex','FontSize',14);
        %             hYLabel = get(gca,'YLabel');
        %             set(hYLabel,'rotation',0,'VerticalAlignment','middle')
        
                for i=1 : length(good_tracks)
                    thisTrack = good_tracks{i}; 
                    B_array = thisTrack.(components_plots(comp));
                    B_array = smoothdata(B_array, 'sgolay', 200);
                    if deg > 0 && comp ~= 3
                        B_array = detrend(B_array, deg);
                    end

                    scatter(thisTrack.lat(~thisTrack.in_crater_150), B_array(~thisTrack.in_crater_150), 1, trackColors(i,:), '.');
                    scatter(thisTrack.lat(thisTrack.in_crater_150), B_array(thisTrack.in_crater_150), 50, trackColors(i,:), '.');
                end
                
                hold off
            end     % end component for loop
        
            sgtitle(sprintf('Crater #%04d (ID: %s) \nCoordinates = (%.1f, %.1f), Diameter = %.2fkm \n%s Detrending, %.0f Tracks', ...
                             i_crater, craters.id{i_crater}, ...
                             craters.lon(i_crater), craters.lat(i_crater), craters.diam(i_crater), ...
                             orders(deg+1), length(good_tracks)));
        
            thisPlot_title = sprintf('%04d__deg%u.png', i_crater, deg);
            saveas(fig, fullfile(folder_2_thisCrater, thisPlot_title));

            % option for saving the undetrended plots for individual inspection
                if deg == 0
                    folder_3_plots = fullfile(folder_1_diamRange, '_plots_raw');
                    [~,~] = mkdir(folder_3_plots);
                    saveas(fig, fullfile(folder_3_plots, thisPlot_title));
                elseif deg == 1
                    folder_3_plots = fullfile(folder_1_diamRange, '_plots_linearDetrend');
                    [~,~] = mkdir(folder_3_plots);
                    saveas(fig, fullfile(folder_3_plots, thisPlot_title));
                end

            close(fig);
        end     % end degree for loop
        

    verbose(sprintf("- Crater %.0f/%.0f (%s) was processed in %.2f seconds.", i_crater, height(craters), craters.id{i_crater}, toc(thisCraterTimer)));                                

end

% Save min/max stats table as csv
    if write_minmaxstats
        title = sprintf('MinMaxStats__diam=[%.0f,%.0f]_alt=[%.0f,%.0f].csv', minDiam, maxDiam, minAlt, maxAlt);
        writetable(MinMaxStats, fullfile(folder_1_diamRange, title));
    end
    

% Final times
    t = seconds(toc(allCratersTimer));
    t.Format = 'hh:mm';
    verbose(sprintf("\n\nFinished generating crater shapfiles in %s (hh:mm).\n", char(t)));
    
    t = seconds(toc(fullTimer));
    t.Format = 'hh:mm';
    verbose(sprintf("Script finished runnning in in %s (hh:mm).", char(t)));



% Save logs as metadata
    writeLogs(folder_1_diamRange, logs, saveLogs);



    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% Functions

%% general use

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

%% Old method of reading crater data
function [crater_data] = read_crater_file(infile_craters)
    crater_data = readData(infile_craters, "%s %f %f %f");
    crater_data = [crater_data{1}, num2cell(crater_data{2}), num2cell(crater_data{3}), num2cell(crater_data{4})];
    crater_data = cell2table(crater_data, ...
        'VariableNames', {'id', 'clon', 'lat', 'diam'});
    lon = table(clon2lon(crater_data.clon), 'VariableNames', {'lon'});
    crater_data = [crater_data, lon];
end


%% Old method of reading maven files

function [mavenFiles,inputFolders] = createFiles(mavenBasePath, infile_mavenFolders)

    file = fopen(infile_mavenFolders,'r');
        inputFolders = textscan(file,'%s');
    fclose(file);
    
    inputFolders = inputFolders{1};
    mavenFiles = [];
    
    for i=1 : length(inputFolders)
        thisFolder = fullfile(mavenBasePath,inputFolders{i}, '*sts');
        this_mavenFiles = dir(thisFolder);
        mavenFiles = [mavenFiles; this_mavenFiles];  %#ok<AGROW> 
    end
    
    return
end

function [mvn_data] = load_maven_data(mavenFiles) %#ok<*DEFNU> 
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


%% coordinate/angle conversions

% NOTE: default qgis projection uses lon
function [clon] = lon2clon(lon)  
    clon = mod(lon,360);
end

function [lon] = clon2lon(clon)  
    lon = mod(clon-180,360)-180;
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


%% maven track signal analysis

function [good_tracks, Bmag_norm] = isolateGoodTracks(thisCrater, craterMetaData)
    
    % Find the index where each track begins by searching for abrupt jumps in lat_deg and altitude
        epsilon_inCrater = 0.05;
        track_indices = 1;
        for ptr=1 : height(thisCrater)-1
            if abs(thisCrater.lat(ptr) - thisCrater.lat(ptr+1)) > epsilon_inCrater || abs(thisCrater.altitude(ptr) - thisCrater.altitude(ptr+1)) > 5
                track_indices = [track_indices; ptr+1]; %#ok<AGROW> 
            end
        end
        num_tracks = length(track_indices);

    
    % (1) Remove tracks that don't pass through the crater, and (2) apply the following flags to data points:
        % `in_crater`: point is within radius of crater
        % 'in_crater_plus50: point is within 1.5*radius of crater
        % 'in_crater_plus100`: point is within 2.0*radius of crater
    
        good_tracks = {};
        Bmag_norm = [];
    
        for i=1 : num_tracks
            % For a track, copy its information from `thisCrater` to `thisTrack`
                if i == num_tracks
                    endIndex = height(thisCrater);
                else
                    endIndex = track_indices(i+1)-1;
                end    
                thisTrack = thisCrater(track_indices(i):endIndex,:);


            % Addition 7/11/22: also create a Bmag_norm array to write to the shapefile
                this_Bmag_norm = thisTrack.Bmag / max(thisTrack.Bmag);
                thisTrack = [thisTrack, table(this_Bmag_norm, 'VariableNames', "Bmag_norm")]; %#ok<AGROW> 
                Bmag_norm = [Bmag_norm; this_Bmag_norm]; %#ok<AGROW> 


    
            % Loop over all points and check if in crater    
                in_crater = false(height(thisTrack),1);
                thisTrack = [thisTrack, table(in_crater)]; clear in_crater; %#ok<AGROW> 
                epsilon_in_crater = craterMetaData.theta; % * 0.9;
                for pt=1 : height(thisTrack)
                    in_lon = abs(craterMetaData.lon - thisTrack.lon(pt)) < epsilon_in_crater;
                    in_lat = abs(craterMetaData.lat - thisTrack.lat(pt)) < epsilon_in_crater;
                    if in_lon && in_lat
                        thisTrack.in_crater(pt) = true;
                    end
                end
                clear epsilon_in_crater in_lon in_lat;


            % If this track has points that pass through the crater, add other flags and append to good_tracks cell
                if ~all(~thisTrack.in_crater)
                    in_crater_150 = false(height(thisTrack),1);
                    in_crater_200 = false(height(thisTrack),1);
                    epsilon_in_crater_150 = craterMetaData.theta * 1.5;
                    epsilon_in_crater_200 = craterMetaData.theta * 2.0;
                    thisTrack = [thisTrack, table(in_crater_150, in_crater_200)]; clear in_crater_150 in_crater_200; %#ok<AGROW> 

                    for pt=1 : height(thisTrack)
                        in_lon = abs(craterMetaData.lon - thisTrack.lon(pt)) < epsilon_in_crater_150;
                        in_lat = abs(craterMetaData.lat - thisTrack.lat(pt)) < epsilon_in_crater_150;
                        if in_lon && in_lat
                            thisTrack.in_crater_150(pt) = true;
                        end
                        in_lon = abs(craterMetaData.lon - thisTrack.lon(pt)) < epsilon_in_crater_200;
                        in_lat = abs(craterMetaData.lat - thisTrack.lat(pt)) < epsilon_in_crater_200;
                        if in_lon && in_lat
                            thisTrack.in_crater_200(pt) = true;
                        end
                    end
                    clear epsilon_in_crater_150 epsilon_in_crater_200 in_lon in_lat;

                    good_tracks{end+1} = thisTrack; %#ok<AGROW> 
                end
        end
end

%% logging/metadata functions

function verbose(message)
    %{ 
    - For th sake of debugging, this function provides a centralized place 
    to control how outputs are handled.
    - We save logs as a string then write to a metadata file at the end
    instead of repeatedly opening + partially writing to a file
    %}
    
    global logs;
    message = strcat(message, "\n");
    fprintf(message);
    logs = strcat(logs, message);
end


function writeLogs(folder, logs, saveLogs)
    if saveLogs
        metadata = strcat(sprintf("Generated on %s \n\n------------- \nMATLAB logs: \n------------- \n", datestr(now,'mm/dd/yyyy HH:MM')), logs); %#ok<*UNRCH> 
        writeMetadata(folder, metadata);
    end
end


function writeMetadata(folder, metadata)
    [fid,msg] = fopen(fullfile(folder, 'metadata.txt'),'w');
        assert(fid>=3, msg)
        fprintf(fid, metadata);
    fclose(fid);
end

function writeMetadata_withTitle(folder, metadata, title)
    [fid,msg] = fopen(fullfile(folder, title),'w');
        assert(fid>=3, msg)
        fprintf(fid, metadata);
    fclose(fid);
end


