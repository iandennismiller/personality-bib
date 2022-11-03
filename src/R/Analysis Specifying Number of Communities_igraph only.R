setwd("C:/Users/chris/Documents/GitHub/personality-bib/GRAPHML/Full Graph Analysis/Ian's Files/New Ian Data")
library(tm)
library(stm)

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


class(personality_clusters_1)
is_hierarchical(personality_clusters_1)

# cut_at
dendro = as.dendrogram(personality_clusters_1)
ten_com = cut_at(personality_clusters_1,10)


# Convert numeric vecter or graph

mem_v = V(co_authorship_1990)$membership
V(co_authorship_1990)$membership = mem_v

str(V(sub)[1])


summary(V(co_authorship_1990)$node_type)


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
