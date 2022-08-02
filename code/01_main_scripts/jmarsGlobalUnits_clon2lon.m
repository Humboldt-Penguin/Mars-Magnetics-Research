clc
clear

tic;

folder = "C:\Users\zk117\jmars\shapes\noachian_tanaka";
file = "NoachianColor_Tanaka_JMARS.shp";

S = shaperead(fullfile(folder,file));


for i=1 : height(S)
    for j=1 : length(S(i).X)
        S(i).X(j) = clon2lon(S(i).X(j));
    end
end


shapewrite(S, fullfile(folder, "Nochian_lon.shp"));

toc;



function [lon] = clon2lon(clon)  
    lon = mod(clon-180,360)-180;
end