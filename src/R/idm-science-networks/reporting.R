print("obtain distribution of graph components")
graph_components = component.dist(coauthors)
component_sizes = sort(graph_components$csize, decreasing=TRUE)

print("identify author-component membership")
author_membership = list()
for (i in 2:50) {
  component_id = match(component_sizes[i], graph_components$csize)
  author_ids = which(graph_components$membership %in% component_id)
  if (length(author_membership) == 0) {
    author_membership[[1]] = author_ids
  }
  else {
    if (author_ids != author_membership[[length(author_membership)]]) {
      author_membership[[length(author_membership)+1]] = author_ids
    }
  }
}

show_components = function() {
  for (i in 1:length(author_membership)) {
    cat(paste("component", i+1))
    print(network.vertex.names(coauthors)[as.vector(author_membership[[i]])])
    cat("\n")
  }
}

# igraph

set.seed(1620)
coauthors_igraph = asIgraph(coauthors)
V(coauthors_igraph)$name <- network.vertex.names(coauthors)
clustered_coauthors_igraph = cluster_louvain(coauthors_igraph)

set.seed(1620)
biggest_igraph = asIgraph(biggest)
V(biggest_igraph)$name <- network.vertex.names(biggest)
clustered_biggest_igraph = cluster_louvain(biggest_igraph)

set.seed(1620)
biggest_centrality = centrality_auto(biggest_igraph)

set.seed(1620)
biggest_clustcoef = clustcoef_auto(biggest_igraph)