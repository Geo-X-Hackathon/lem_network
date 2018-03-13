function [ A, labels ] = regions2adjacency( clusteredGrid, categoryGrid )

if isa(clusteredGrid,'GRIDobj')
    clusteredGrid = clusteredGrid.Z;
end
if isa(categoryGrid,'GRIDobj')
	categoryGrid = categoryGrid.Z;
end

[ nrows, ncols ] = size( clusteredGrid );

labels = unique( clusteredGrid( ~isnan( clusteredGrid ) ) );
N = length( labels );

A = zeros( N );


% horizontally neighboring
for i=1:nrows
    for j=1:ncols-1
        regLeft = clusteredGrid( i, j );
        regRight = clusteredGrid( i, j+1 );
		catLeft  = categoryGrid( i, j );
		catRight = categoryGrid( i, j+1 );
        if any(isnan([regLeft regRight]))
            continue
        end
        
        if regLeft ~= regRight && catLeft ~= catRight
            A( regLeft, regRight ) = 1;
            A( regRight, regLeft ) = 1;
        end
    end
end

% vertically neighboring
for i=1:ncols
    for j=1:nrows-1
	    regUpper = clusteredGrid( j, i);
        regLower = clusteredGrid( j+1, i );
		catUpper = categoryGrid(j, i );
		catLower = categoryGrid(j+1, i);
        
        if any(isnan([regUpper regLower]))
            continue
        end
        
        if regUpper ~= regLower && catUpper ~= catLower
            A( regUpper, regLower ) = 1;
            A( regLower, regUpper ) = 1;
        end
    end
end

% labels = map.keys;

end

