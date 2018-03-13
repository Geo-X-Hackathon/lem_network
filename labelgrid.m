function [L,RR] = labelgrid(DEM,varargin)

%LABELGRID landscape segmentation


p = inputParser;
p.FunctionName = 'labelgrid';
addParamValue(p,'minarea',1e6,@(x) isscalar(x));
addParamValue(p,'removeshortstreams',200,@(x) isscalar(x));
addParamValue(p,'seglength',2000);
addParamValue(p,'gradientcutoff',20,@(x) isscalar(x)); % gradient in [%]
parse(p,varargin{:});


FD = FLOWobj(DEM);
S  = STREAMobj(FD,'minarea',p.Results.minarea,'unit','map');
S  = removeshortstreams(S,p.Results.removeshortstreams);

G  = gradient8(DEM,'perc');

L  = (G>p.Results.gradientcutoff);
L.Z = medfilt2(L.Z,[11 11]);
L.Z = L.Z+1;
L.Z(isnan(DEM.Z)) = 0;


IX = streampoi(S,{'confl','outlet'},'ix');
D  = drainagebasins(FD,IX);
[~,~,ix] = unique([L.Z(~isnan(DEM.Z)),D.Z(~isnan(DEM.Z))],'rows');

R  = GRIDobj(L);
R.Z(~isnan(DEM.Z)) = ix;


s  = streamorder(S);
% maximum stream order
maxs = max(s);

regioncounter = max(R)+1;
for r = 1:maxs
    Ss = modify(S,'streamorder',r);
    
    [label,ix] = labelreach(Ss,'seglength',p.Results.seglength);
    Ss = split(Ss,ix);
    
    Cs = STREAMobj2cell(Ss);
    for iter = 1:numel(Cs)
        I  = STREAMobj2GRIDobj(Cs{iter});
        I  = dilate(I,ones(3*r));
        L.Z(I.Z) = r+2;
        R.Z(I.Z) = regioncounter;
        regioncounter = regioncounter + 1;
    end
end


[~,~,ix] = unique(R.Z(~isnan(DEM.Z)));
R.Z(~isnan(DEM.Z)) = ix;

RR = GRIDobj(R);
counter = 0;
for r = 1:max(R)
    [LL,num] = bwlabel(R.Z==r,8);  
    LL(LL~=0) = LL(LL~=0)+counter;
    counter  = counter + num;
    RR.Z(LL~=0) = LL(LL~=0);
end

L.Z(isnan(DEM.Z)) = nan;
RR.Z(isnan(DEM.Z)) = nan;
    

