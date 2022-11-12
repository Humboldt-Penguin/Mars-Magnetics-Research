clc
clear

tic;

% folder = "C:\Users\zk117\jmars\shapes\noachian_tanaka";
% file = "NoachianColor_Tanaka_JMARS.shp";

old_folder = "C:\Users\zk117\Documents\00.local_WL-202\Mars_Magnetics\QGIS\crater_outlines\old";
new_folder = "C:\Users\zk117\Documents\00.local_WL-202\Mars_Magnetics\QGIS\crater_outlines\lon_adjusted";
file = "Craters_60km_min.shp";

S = shaperead(fullfile(old_folder,file));

S_new = struct();

fn = fieldnames(S);
for i=1:numel(fn)
    S_new.(fn{i}) = [];
end



for i=1 : height(S)
    to_save = true;
    for j=1 : length(S(i).X)
        S(i).X(j) = clon2lon(S(i).X(j));
        if S(i).X(j) > 177 || S(i).X(j) < -177
            to_save = false;
        end
    end
    if to_save
        S_new = [S_new;S(i,:)]; %#ok<AGROW> 
    end
end

S_new = S_new(2:height(S_new));

shapewrite(S_new, fullfile(new_folder, strcat(file)));

toc;



function [lon] = clon2lon(clon)  
    lon = mod(clon-180,360)-180;
end