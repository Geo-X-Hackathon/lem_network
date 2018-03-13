function [ A, labels ] = regions2adjacencydirected( FD, clusteredGrid )

if isa(clusteredGrid,'GRIDobj')
    clusteredGrid = clusteredGrid.Z;
end

clusterout = clusteredGrid(FD.ix);
clusterin  = clusteredGrid(FD.ixc);

I = clusterin == clusterout;
clusterout(I) = [];
clusterin(I) = [];

labels = unique( clusteredGrid( ~isnan( clusteredGrid ) ) );
N = length( labels );

A = zeros( N );

ix = sub2ind(size(A),clusterout,clusterin);
A(ix) = 1;
