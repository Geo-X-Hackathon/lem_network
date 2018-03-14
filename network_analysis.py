import numpy as np
import matplotlib.pyplot as plt
from matplotlib.collections import LineCollection
from matplotlib.colors import BoundaryNorm
from matplotlib.cm import get_cmap
from pyunicorn.core.network import Network


# Plot scalar node data for a network:
def plot_network_data(network, node_data, node_x, node_y, fname,
                      mask=None, arrows=False, elevation=None,
                      cmap='YlOrBr_r', clabels=None, colors=None):
	global NODATA
	fig = plt.figure(figsize=(10,5))
	ax = fig.add_subplot(111)
	
	# Plot elevation as background:
	dx = node_x.max() - node_x.min()
	xlim = [node_x.min() - 0.01*dx, node_x.max() + 0.01*dx]
	dy = node_y.max() - node_y.min()
	ylim = [node_y.min() - 0.01*dy, node_y.max() + 0.01*dy]
	
	
	if elevation is not None:
		ax.imshow(elevation, vmin=elevation[elevation != NODATA].min(),
		          vmax=elevation[elevation != NODATA].max(),
		          extent=(xlim[0],xlim[1],ylim[0],ylim[1]),
		          cmap='gist_earth')
	
	
	# Plot links:
	edge_list = network.edge_list()
	if arrows:
		# For directed network: Black arrows overlain by white arrows.
		i0 = [edge[0] for edge in edge_list]
		i1 = [edge[1] for edge in edge_list]
		ax.quiver(node_x[i0], node_y[i0], node_x[i1]-node_x[i0],
		          node_y[i1]-node_y[i0], scale_units='xy',
		          angles='xy', scale=1, zorder=1,headwidth=4,
		          color='black')
		ax.quiver(node_x[i0], node_y[i0], node_x[i1]-node_x[i0],
		          node_y[i1]-node_y[i0], scale_units='xy',
		          angles='xy', scale=1, zorder=2,headwidth=6,
		          width=0.001, headlength=10, headaxislength=8,
		          color='white')
	else:
		line_segments = LineCollection([((node_x[edge[0]],node_y[edge[0]]),
	    	                             (node_x[edge[1]],node_y[edge[1]]))
	    	                            for edge in edge_list],
	    	                           colors='black', zorder=2)
		ax.add_collection(line_segments)
	
	# Scatter plot of node positions coloured by colours chose from colour
	# map according to supplied node_data.
	# Different use scenarios of paramters passed: 
	if mask is not None:
		s = np.ones(network.N)
		c = node_data[mask]/node_data[mask].max()
		h = ax.scatter(node_x[mask], node_y[mask], s=s, 
		       cmap=cmap, c=c, zorder=3)
	else:
		if colors:
			h = ax.scatter(node_x, node_y, s=20, 
			       c=colors, zorder=2)
		elif clabels:
			h = ax.scatter(node_x, node_y, s=20, 
			       cmap=cmap, c=node_data, zorder=2)
		else:
			h = ax.scatter(node_x, node_y, s=20, 
			       cmap=cmap, c=node_data/node_data.max(), zorder=2)
		mask = network.degree() == 0

	# Set clabels if given (for plotting node categories):
	if clabels is not None:
		cbar=fig.colorbar(h,ticklocation=clabels[0],ticks=clabels[0],
		                  spacing='proportional')
		cbar.set_ticks(clabels[0])
		cbar.set_ticklabels(clabels[1])
	else:
		fig.colorbar(h)
	
	# Final touch and saving:
	ax.set_axis_off()
	fig.tight_layout()
	fig.savefig(fname)



# Read adjacency matrices:
A_dir = np.loadtxt('adj_dir.txt',delimiter=',')
A_undir = np.loadtxt('adj_undir.txt',delimiter=',')

# Read node properties:
data_dir = np.loadtxt('adj_dir_nodes.txt',delimiter=',')
data_undir = np.loadtxt('adj_undir_nodes.txt',delimiter=',')
x_dir = data_dir[:,0]
y_dir = data_dir[:,1]
label_dir = data_dir[:,2]
x_undir = data_undir[:,0]
y_undir = data_undir[:,1]
label_undir = data_undir[:,2]

# Read elevation data:
elevation = np.loadtxt('elev.dat1.txt')
with open('elev.dat0.txt','r') as f:
	content=[x.strip().split() for x in f.readlines()[:6]]
	for line in content:
		if line[0] == 'xllcorner':
			print(line[1])
			xllcorner = float(line[1])
		elif line[0] == 'yllcorner':
			print(line[1])
			yllcorner = float(line[1])
		elif line[0] == 'cellsize':
			print(line[1])
			cellsize = float(line[1])
		elif line[0] == 'NODATA_value':
			print(line[1])
			NODATA = float(line[1])

# This does not quite seem to work. Hot fix, time is running out:
NODATA = -9999
	

# Generate networks (pyunicorn has both weighted and unweighted measures):
network_dir = Network(adjacency=A_dir>0, directed=True,silence_level=2)
print("A_dir:")
print(A_dir)
network_dir.set_link_attribute('weight', A_dir)

network_undir = Network(adjacency=A_undir, silence_level=2)

# Print some measures:
print("Directed network:")
print("mean degree:     ",network_dir.degree().mean())
print("mean clustering: ",network_dir.global_clustering())
print("transitivity:    ",network_dir.transitivity())
print("efficiency:      ",network_dir.global_efficiency())

print("Undirected network:")
print("mean degree:     ",network_undir.degree().mean())
print("mean clustering: ",network_undir.global_clustering())
print("transitivity:    ",network_undir.transitivity())
print("efficiency:      ",network_undir.global_efficiency())

# Plot various network measures:
#plot_network_data(network_undir, network_undir.degree(), x_undir, y_undir,
#                  'degree_undir.pdf')
#plot_network_data(network_undir, network_undir.closeness(), x_undir, 
#                  y_undir,'closeness_undir.pdf')
#plot_network_data(network_undir, network_undir.betweenness(), x_undir, 
#                  y_undir,'betweenness_undir.pdf')
#plot_network_data(network_undir, 
#                  network_dir.closeness(link_attribute='weight'),
#                  x_undir, y_undir,'closeness_dir.pdf')

# Calculate matrix of path lengths of directed network:
path_lengths = network_dir.path_lengths(link_attribute='weight')

# There may be cases of nodes not being reachable from other nodes
# because of directivity (and network decomposition).
# Handle these cases in a "sensible" way: Calculate average path
# length to reachable nodes. If no other node is reachable from a node
# set value its to the maximum otherwise achieved path length.
mask = ~np.logical_or(np.isinf(path_lengths),np.isnan(path_lengths))
path_lengths[~mask] = 0
N = network_dir.N
pl = N * np.ones(N)
m2 = np.any(mask, axis=1)
pl[m2] = (np.mean(path_lengths,axis=1) * N / np.sum(m2))[m2]
pl[network_dir.outdegree() == 0] = pl.max()

# Plot these average path lengths per node and also link structure:
plot_network_data(network_dir, pl,
                  x_dir, y_dir,'average_path_length_dir.pdf', arrows=True,
                  elevation=elevation)
# Betweenness:
plot_network_data(network_dir, network_dir.betweenness(),
                  x_dir, y_dir,'between_dir.pdf', arrows=True,
                  elevation=elevation)

# Plot label per node. Not an ideal color map situation, but time is
# running out:    
cmap = get_cmap('Spectral')
colors = [cmap(i / 6.0) for i in label_dir]
plot_network_data(network_dir, label_dir,
                  x_dir, y_dir,'labels_dir.pdf', arrows=True,
                  elevation=elevation, colors=colors,
                  clabels=([1,2,3,4,5,6],['Hillslopes (<20%)',
                           'Hillslopes (>20%)','Fluvial (1st order)',
                           'Fluvial (2nd order)','Fluvial (3rd order)',
                           'Fluvial (4th order)']))
