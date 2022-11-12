clc
clear

%%% INPUTS (see decription for more details)
VN_path = 'C:\Users\zk117\Documents\00.local_WL-202\Mars_Magnetics\geological_features\valley_network_shapefiles\VN_Hyneks\shapefiles\Hynek_Valleys_projected.shp';

saveLogs = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%{ 
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

global logs; %#ok<*GVMIS> 
logs = "";

tic



test = shaperead(VN_path);

%%
Lat = [test.Y];
Lon = [test.X];
mLat = mean(Lat);
mLon = mean(Lon); 









fprintf("Finished runnning in %.2f seconds.\n", toc);
































%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Functions


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

 