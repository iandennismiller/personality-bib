setwd("C:/Users/chris/Documents/GitHub/personality-bib/GRAPHML/Full Graph Analysis/Ian's Files/New Ian Data")
# setwd("~/Work/personality-bib/data/graphs")

library(tm)
library(stm)
library(igraph)

## Igraph Syntax

# Loading/Reading GRAPHML Files
co_authorship_1990 = read.graph("coauthors-merged-journals-1990s.GRAPHML", format = "graphml")
journal_1990 = read.graph("journals-1990s.GRAPHML", format = "graphml")

# Extracting Main Component
comp = igraph::clusters(co_authorship_1990, mode="weak")
biggest_cluster_id <- which.max(comp$csize)
vert_ids <- V(co_authorship_1990)[comp$membership == biggest_cluster_id]

sub = igraph::induced_subgraph(co_authorship_1990, vert_ids)


# Apply  clustering Algorithms
personality_clusters = cluster_louvain(sub)
personality_clusters_1 = cluster_edge_betweenness(sub)

# class(personality_clusters)
# is_hierarchical(personality_clusters)

class(personality_clusters_1)
is_hierarchical(personality_clusters_1)

# cut_at
dendro = as.dendrogram(personality_clusters_1)
ten_com = cut_at(personality_clusters_1,10)

# Convert numeric vecter or graph
# mem_v = V(co_authorship_1990)$membership
# V(co_authorship_1990)$membership = mem_v

# assign the vertices' membership to be equal to clustering membership
V(sub)$membership = ten_com

str(V(sub)[1])

summary(V(sub)$node_type)


# Add Title Vector
# Extracting Main Component
comp_1 = igraph::clusters(journal_1990, mode="weak")
biggest_cluster_id_1 <- which.max(comp_1$csize)
vert_ids_1 <- V(journal_1990)[comp_1$membership == biggest_cluster_id_1]

sub_1 = igraph::induced_subgraph(journal_1990, vert_ids_1)




summary(V(journal_1990)$node_type)

title_v = V(journal_1990)$title

none = ifelse(title_v == "None",1,0)
sum(none)



# Write GRAPHML

write_graph(sub, "Full personality Network-Nov 17th-1990-1990_10_communities_1.graphml", format="graphml")



author_vertices_in_subgraph = V(sub)
subgraph_scopus_ids = author_vertices_in_subgraph$scopus_id
author_ids_in_heterogeneous_graph = V(journal_1990)[V(journal_1990)$scopus_id %in% subgraph_scopus_ids]

documents = c()

# iterate one author at a time from subgraph, extract adjacent vertices, identify articles, and extract tiles
for (author_connections in adjacent_vertices(journal_1990, author_ids_in_heterogeneous_graph)) {
  for (target_vertex in author_connections) {
    if (V(journal_1990)[target_vertex]$node_type == 'article') {
      documents = c(documents, (V(journal_1990)[target_vertex]$title))
    }
  }
}

print(documents[1])
