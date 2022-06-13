lon = 48.3510;
lat = -42.3194;

left = -79.4;
right = -77.6;

% sep = left-right;
sep = 2;

diam = abs(sep)*50;

lon = mod(lon,360);

fprintf("hm\t%f\t%f\t%f\n\n", lon, lat, diam);