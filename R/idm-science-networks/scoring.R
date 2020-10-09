# Ian Dennis Miller
# bibliometrics
# scoring: based on canonical data, calculate scores

edge_list = data.frame()

print("build edge list")

for (paper in citations) {
  authors = unlist(paper$author)

  if (length(authors) > 1) {
    pairs = data.frame(combinations(n=length(authors), r=2, v=authors))
    names(pairs) <- c("from", "to")
    pairs$article = paper$title
    edge_list = rbind(edge_list, pairs)
  }
}

# update edge_list to replace scopus IDs with names here

print("build coauthorship network from edge list")

coauthors = network(as.matrix(edge_list)[,1:2], directed = FALSE)
set.edge.attribute(coauthors, "article", edge_list$article)

print("create adjacency matrix")
adjacency_matrix = as.sociomatrix(coauthors)

print("identify components")
cl = component.largest(coauthors)
biggest = get.inducedSubgraph(coauthors,v=(1:network.size(coauthors))[cl])

clean_tmp()
