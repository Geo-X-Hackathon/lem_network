
% Example how to import CAESAR model output as datacube
datapath = '../CAESAR_data/D4/';

[datacube, metadata, DEM] = import_elevation(datapath);

%  datacube     3d matrix of all DEM time slices
%  metatdata    struct with meta information for each timeslice
%  DEM          GRIDobj of t=0 DEM     (w/o topotoolbox: 2D matrix)
