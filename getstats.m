function [ T, S, region_ids ] = getstats( datacube, regionmat, spatialfun, timefun)
%GETSTATS Summary of this function goes here
%   [ T, S, region_ids ] = getstats( datacube, regionmatix, spatialfun, timefun)
%   apply function spatialfun for each unique region
%   and aggregate over time using timefun.
%   Returns: T  vector with statistics output for each region 
%               size(T) =  number_of_timeslices
%            S  matrix with statistics output for each region per
%               timeslice.
%               size(S) =  [ number_of_region_ids, number_of_timeslices ]
%            region_ids  vector with all unique regions
%  Example usage:
%  [T, S, region_ids] = getstats( datacube, regionmat, @min, @std);

if isa(regionmat,'GRIDobj')
    regionmat = regionmat.Z;
end


% replace NaN values with unique region ID
treatnans = logical( sum(isnan(regionmat(:))) );
nanvalue = max(regionmat(:)+1);
regionsNonan = regionmat; regionsNonan(isnan(regionmat)) = nanvalue;

% get all region IDs
region_ids = unique(regionsNonan);
regionIDX = repmat(1:(length(region_ids)-treatnans), 1, size(datacube,3))';

 
%timeIDX = repmat( (1:size(datacube,3)), size(datacube,3),1); timeIDX = timeIDX(:);


% allocate matrix for statistics output: 
S = nan(max(region_ids)-treatnans, size(datacube,3) );

for t=1:size(datacube,3) % loop though all time slices
    
    DEMt = datacube(:,:,t);
    A = accumarray(regionsNonan(:),DEMt(:),[],spatialfun);
    if treatnans==true
        A = A(1:end-1); %remove NaN region
    end %end if
    
    S(:,t)=A';
    
end %end for t


  T = accumarray(regionIDX,S(:),[],timefun);
  
  
    % remove region ID of NaN values:
  region_ids = region_ids(1:end-treatnans);

  
end

