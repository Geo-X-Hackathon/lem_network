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

A = accumarray([clusterout clusterin],ones(size(clusterout)),[N N],@sum);
A = A./sum(A,2);
A(isnan(A)) = 0;