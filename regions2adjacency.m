function [ A, labels ] = regions2adjacency( clusteredGrid )

minValue = min( min( clusteredGrid ) );
clusteredGrid = clusteredGrid - minValue + 1;

clusteredGrid = int64(clusteredGrid);
[ nrows, ncols ] = size( clusteredGrid );

N = length( unique( clusteredGrid ) );

map = containers.Map( unique(clusteredGrid), 1:N );

clusteredGrid = arrayfun( @(x) map(x), clusteredGrid ) ;

A = zeros( N );


% horizontally neighboring
for i=1:nrows
    for j=1:ncols-1
        left = clusteredGrid( i, j );
        right = clusteredGrid( i, j+1 );
        if left ~= right
            A( left, right ) = 1;
            A( right, left ) = 1;
        end
    end
end

% vertically neighboring
for i=1:ncols
    for j=1:nrows-1
        upper = clusteredGrid( j, i);
        lower = clusteredGrid( j+1, i );
        if upper ~= lower
            A( upper, lower ) = 1;
            A( lower, upper ) = 1;
        end
    end
end

labels = map.keys;

end

