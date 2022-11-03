setwd("C:/Users/chris/Documents/GitHub/personality-bib/GRAPHML/Full Graph Analysis/Ian's Files/New Ian Data")
library(tm)
library(stm)
library(igraph)
library(tidyverse)

## Load Enviroment
#load("Jan 11th_main component and title DF replication.RData")

# Load Journal and Coauthorship Graphs

co_authorship_1990 = read.graph("coauthors-merged-journals-1990s.GRAPHML", format = "graphml")
journal_1990 = read.graph("journals-1990s.GRAPHML", format = "graphml")



# edges
gsize(journal_1990)
# vertices
gorder(journal_1990)

# edges
#gsize(co_authorship_1990)
# vertices
#gorder(co_authorship_1990)

# Some useful graph operation examples
# print the title of the article represented by vertex_idx
vertex_idx = 1
V(journal_1990)[vertex_idx]$title
# print the name of the author represented by vertex #2 ("Seta, John J.")
V(journal_1990)[2]$author_name
# find an author node ID
author_idx = match("Smith, Eliot R.", V(journal_1990)$author_name)
# obtain author vertices
V(journal_1990)[V(journal_1990)$node_type == "author"]
# obtain article vertices
V(journal_1990)[V(journal_1990)$node_type == "article"]
# obtain author by index
V(journal_1990)[author_idx]
# obtain author relationships
relationships = E(journal_1990)[ from(author_idx) ]
# obtain all article relationships from an author
relationships[relationships$edge_type == "authored"]
# obtain all article vertices by an author
V(journal_1990)[relationships[relationships$edge_type == "authored"]]$title
# obtain all edges from graph as data frame
edges_data_frame = get.data.frame(journal_1990, what="edges")
# obtain all vertices from graph as data frame
vertices_data_frame = get.data.frame(journal_1990, what="vertices")
# data frame with all authors and articles
authors = vertices_data_frame[which(vertices_data_frame$node_type == "author"),]
articles = vertices_data_frame[which(vertices_data_frame$node_type == "article"),]


list.vertex.attributes(journal_1990)
list.vertex.attributes(co_authorship_1990)


article_vertices = V(journal_1990)[V(journal_1990)$node_type == "article"]

# obtain all vertices from graph as data frame
vertices_data_frame = get.data.frame(journal_1990, what="vertices")
# data frame with all authors and articles
authors = vertices_data_frame[which(vertices_data_frame$node_type == "author"),]
authors = authors[c('id', 'author_name', 'scopus_id')]
articles = vertices_data_frame[which(vertices_data_frame$node_type == "article"),]
articles = articles[c('id', 'doi', 'issn', 'journal', 'keywords', 'title', 'abstract', 'cover_date')]

# identify clusters in coauthorship graph
coauthorship_components = igraph::clusters(co_authorship_1990, mode="weak")
# the main component is identified by cluster ID with the maximum cluster size
biggest_component_id = which.max(coauthorship_components$csize)
# obtain vertex IDs for members of this largest cluster
component_membership = V(co_authorship_1990)[coauthorship_components$membership == biggest_component_id]
# obtain subgraph consisting of only the members of the main component
main_component_graph = igraph::induced_subgraph(co_authorship_1990, component_membership)


# obtain communities object using Newman and Girvan's 2004 betweenness clustering approach
coauthorship_communities = cluster_louvain(main_component_graph)
# ensure cluster algorithm returns something suitable for passing to communities()
class(coauthorship_communities)
# double-check that communities are hierarchically nested
is_hierarchical(coauthorship_communities)
# cut dendrogram at a specific number of merges to obtain desired number of communities
community_dendrogram = as.dendrogram(coauthorship_communities)
ten_communities = cut_at(coauthorship_communities, 10)
# assign main component author membership according to our 10 communities
V(main_component_graph)$membership = coauthorship_communities$membership

## Create author DF
tmp_data_frame = get.data.frame(main_component_graph, what="vertices")
df_authors = tmp_data_frame[which(tmp_data_frame$node_type == "author"),]
df_authors = df_authors[c('id', 'author_name', 'scopus_id', 'membership')]
head(df_authors)


df_article_communities = data.frame(
  id=character(),
  title=character(),
  community=integer()
)

for (scopus_id_str in df_authors$scopus_id) {
  # obtain an author vertex based on Scopus ID
  author_in_articles_vertex = V(journal_1990)[which(V(journal_1990)$scopus_id == scopus_id_str )]
  author_in_component_vertex = V(main_component_graph)[which(V(main_component_graph)$scopus_id == scopus_id_str )]
  author_membership = author_in_component_vertex$membership

  # identify all edges emanating from this author
  author_relationships = E(journal_1990)[ from(author_in_articles_vertex) ]
  # filter edges to identify authorship edges only
  authorship_edges = author_relationships[author_relationships$edge_type == "authored"]
  # iterate article edges to individually add article IDs to list
  for (article_edge in authorship_edges) {
    if (article_edge < gorder(journal_1990)) {
      article = V(journal_1990)[article_edge]
      if (article$title != "None") {
        df_tmp = data.frame(id=as.character(article$id), title=article$title, community=author_membership)
        df_article_communities = rbind(df_article_communities, df_tmp)
      }
    }
  }
}

head(df_article_communities)
nrow(df_article_communities)
names(df_article_communities)

df_article_communities.lou = df_article_communities

#save.image(file = "Jan 11th_main component and title DF replication.RData")


##Write GraphML file
main_component_graph

#1990s
write_graph(main_component_graph, "Full personality Network-sept 27th-1990s_communities.graphml", format="graphml")


### Check for individual articles

#This article does appear in the Df and demonstrates that the code works
sum(df_article_communities$title == "Authoritarianism of Parents and Offspring: Intergenerational Politics and Adjustment to College")

## The remaining articles do not appear in DF
sum(df_article_communities$title == "Construction of circumplex scales for the Inventory of Interpersonal Problems")
sum(df_article_communities$title == "Personality trait structure as a human universal")
sum(df_article_communities$title == "Evaluating Stability and Change in Personality and Depression")
sum(df_article_communities$title == "On the accuracy of personality judgment: A realistic approach")
sum(df_article_communities$title == "The divided self: Concurrent and longitudinal effects of psychological adjustment and social roles on self-concept differentiation")


df_article_communities %>% filter(df_article_communities$community == "29")


x = df_authors %>% filter(df_authors$membership == "29")
x = df_authors %>% filter(df_authors$author_name == "Wiggins, Jerry S.")
x = df_article_communities %>% filter(df_article_communities$title == "Authoritarianism of Parents and Offspring: Intergenerational Politics and Adjustment to College")

