clear
clc
altitudeCutoff = 200;

base = "C:\Users\zk117\Documents\00.local_WL-202\Mars_Magnetics\MAVEN_MAG\raw";

% files = ["mvn_mag_l2_2016190pc_20160708_v01_r01.sts"];


files = ["mvn_mag_l2_2016190pc_20160708_v01_r01.sts", ...
         "mvn_mag_l2_2016207pc_20160725_v01_r01.sts", ...
         "mvn_mag_l2_2016212pc_20160730_v01_r01.sts", ...
         "mvn_mag_l2_2019038pc_20190207_v01_r01.sts"];


for i=1 : length(files)
    files(i) = fullfile(base, files(i));
end

clear base

data = [];

for file = files

    % open and read data

    fid = fopen(file,'r');
    
    for i=1:140
        line = fgets(fid);
    end
    while ~contains(line, "20")
        line = fgets(fid);
    end

    this_data = textscan(fid,generate_formatSpec('%f',18));    

    fclose(fid); clear line

    % cut out daytime and >altitudeCutoff data

    this_data = cell2mat(this_data);

    hour = this_data(:,3);
    indices_hour = hour < 9 | hour > 19; clear hour
    this_data = this_data(indices_hour,:); clear indices_hour

    posX = this_data(:,12); posY = this_data(:,13); posZ = this_data(:,14);
    
    hypotXY = hypot(posX,posY);
    r = hypot(hypotXY,posZ); clear posX posY posZ hypotXY

    indices_alt = r < (3390 + altitudeCutoff); % 3390 is the avg radius of mars
    this_data = this_data(indices_alt,:); clear r indices_alt

    this_data = this_data(:,[8:10,12:14]);

    data = [data ; this_data];

end


mvn = array2table(data, ...
        'VariableNames',{'magX', 'magY', 'magZ', 'posX', 'posY', 'posZ'}); clear this_data

%%
path = "C:\Users\zk117\Documents\00.local_WL-202\Mars_Magnetics\MAVEN_MAG\reduced\matfiles\mvn_test.mat";
save(path, 'mvn');

%%
clear mvn

mvnmat = matfile(path);
mvn = mvnmat.mvn;
clear mvnmat
        

%%
function [formatSpec] = generate_formatSpec(base,numRepeat)
    formatSpec = '';
    for i=1:numRepeat
        formatSpec = strcat(formatSpec,base);
    end
end