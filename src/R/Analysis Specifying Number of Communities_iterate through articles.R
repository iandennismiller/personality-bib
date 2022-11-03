setwd("C:/Users/chris/Documents/GitHub/personality-bib/GRAPHML/Full Graph Analysis/Ian's Files/New Ian Data")
library(tm)
library(stm)


load("Analysis Specifying Number of Communities.RData")
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
V(sub)$membership = ten_com


#mem_v = V(co_authorship_1990)$membership


#str(V(sub)[1])

#summary(sub)
#summary(V(co_authorship_1990)$node_type)


# Add Title Vector
# Extracting Main Component
documents = V(journal_1990)[V(journal_1990)$node_type == "article"]$title

documents_id = V(journal_1990)[V(journal_1990)$node_type == "author"]$scpus_id


comp_1 = igraph::clusters(journal_1990, mode="weak")
biggest_cluster_id_1 <- which.max(comp_1$csize)
vert_ids_1 <- V(journal_1990)[comp_1$membership == biggest_cluster_id_1]

sub_1 = igraph::induced_subgraph(journal_1990, vert_ids_1)


V(journal_1990)[V(journal_1990)$scopus_id %in% V(sub)$scopus_id]
V(journal_1990)[V(journal_1990)$node_type == 'article']


ten_com
summary(V(journal_1990)$node_type)

title_v = V(journal_1990)$title

none = ifelse(title_v == "None",1,0)
sum(none)

#Ian's Code
author_vertices_in_subgraph = V(sub)
subgraph_scopus_ids = author_vertices_in_subgraph$scopus_id
author_ids_in_heterogeneous_graph = V(sub)[V(sub)$scopus_id %in% subgraph_scopus_ids]

documents = c()

# iterate one author at a time from subgraph, extract adjacent vertices, identify articles, and extract tiles
for (author_connection in adjacent_vertices(journal_1990, author_ids_in_heterogeneous_graph)) {
  for (target_vertex in author_connection) {
    if (V(journal_1990)[target_vertex]$node_type == 'article') {
      documents = c(documents, (V(journal_1990)[target_vertex]$title))
    }
  }
}

print(documents[1:5])
length(documents)
length(unique(documents))
sum(duplicated(documents))


##############

#Ian's Code/Try to iterate through articles

# Extracting Main Component
comp_1 = igraph::clusters(journal_1990, mode="weak")
biggest_cluster_id_1 <- which.max(comp_1$csize)
vert_ids_1 <- V(journal_1990)[comp_1$membership == biggest_cluster_id_1]

sub_1 = igraph::induced_subgraph(journal_1990, vert_ids_1)





article_vertices_in_subgraph = V(sub_1)$node_type == 'article'
subgraph_article = article_vertices_in_subgraph == 'TRUE'
article_ids_in_heterogeneous_graph = V(journal_1990)[V(journal_1990)$title %in% subgraph_article]

documents = c()

# iterate one author at a time from subgraph, extract adjacent vertices, identify articles, and extract tiles
for (article_connections in adjacent_vertices(journal_1990, article_ids_in_heterogeneous_graph)) {
  for (author_vertex in article_connections) {
    if (V(journal_1990)[target_vertex]$node_type == 'article') {
      documents = c(documents, (V(journal_1990)[target_vertex]$title))
    }
  }
}

print(documents[1])
length(unique(documents))


#Ian's OG code

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
