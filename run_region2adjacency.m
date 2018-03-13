


clusteredGrid = dlmread( './training_labelgrid.txt', ' ', 6, 0);

[A, labels] = regions2adjacency(clusteredGrid);

imagesc( A );

%% create a graph object from the adjacency matrix

if issymmetric(A)
    G = graph(A);
end

G = G.rmnode(1);

%%

plot( G, 'Layout', 'force' );


