%% LOAD DATA
disp('Loading data...')
datapath = '../CAESAR_data/D4/';

[datacube, metadata, DEM] = import_elevation(datapath);

%  datacube     3d matrix of all DEM time slices
%  metatdata    struct with meta information for each timeslice
%  DEM          GRIDobj of t=0 DEM     (w/o topotoolbox: 2D matrix)


% load regions:
regionsGO = GRIDobj('regions.txt');
regions = regionsGO.Z;


%% GENERATE STATISTICS:
disp('Calculating statistics')

%%  zonal statistic: MINIMUM area       time aggregation: STDEV

[stat_rMIN_tSTD, stat_rMIN_perslice, regionids]  = getstats( datacube, regions, @min, @std);
% %write statistics in file:
dlmwrite('stat_rMIN_tSTD.csv',stat_rMIN_tSTD)
dlmwrite('stat_rMIN__perslice.csv',stat_rMIN_perslice)

% Create GRIDobj output for MAP:
map_rMIN_tSTD = regionsGO;
map_rMIN_tSTD.Z = changem(map_rMIN_tSTD.Z, stat_rMIN_tSTD, regionids);

% show map:
imagesc(map_rMIN_tSTD)

%%  zonal statistic: STDEV area       time aggregation: STDEV
[stat_rSTD_tSTD, stat_rSTD_perslice, regionids]  = getstats( datacube, regions, @std, @std);

