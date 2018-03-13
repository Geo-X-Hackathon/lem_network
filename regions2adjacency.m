function [ A, labels ] = regions2adjacency( clusteredGrid )

if isa(clusteredGrid,'GRIDobj')
    clusteredGrid = clusteredGrid.Z;
end

[ nrows, ncols ] = size( clusteredGrid );

labels = unique( clusteredGrid( ~isnan( clusteredGrid ) ) );
N = length( labels );

A = zeros( N );


% horizontally neighboring
for i=1:nrows
    for j=1:ncols-1
        left = clusteredGrid( i, j );
        right = clusteredGrid( i, j+1 );
        if any(isnan([left right]))
            continue
        end
        
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
        
        if any(isnan([upper lower]))
            continue
        end
        
        if upper ~= lower
            A( upper, lower ) = 1;
            A( lower, upper ) = 1;
        end
    end
end

% labels = map.keys;

end

