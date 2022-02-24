library(igraph)
library(dplyr)

find_author = function(graph, name) {
  return(V(graph)[V(graph)$node_type == "author" & V(graph)$author_name == name])
}

get_authors_df = function(journal_graph) {
  # obtain all vertices from graph as data frame
  vertices_data_frame = get.data.frame(journal_graph, what="vertices")

  # data frame with all authors and articles
  authors = vertices_data_frame[which(vertices_data_frame$node_type == "author"),]
  authors = authors[c('id', 'author_name', 'scopus_id')]

  return(authors)
}

get_articles_df = function(journal_graph) {
  # obtain all vertices from graph as data frame
  vertices_data_frame = get.data.frame(journal_graph, what="vertices")

  # data frame with all authors and articles
  articles = vertices_data_frame[which(vertices_data_frame$node_type == "article"),]
  articles = articles[c('id', 'doi', 'issn', 'journal', 'keywords', 'title', 'abstract', 'cover_date')]

  return(articles)
}

get_main_component = function(journal_graph) {
  # identify clusters in coauthorship graph
  coauthorship_components = igraph::clusters(journal_graph, mode="weak")

  # the main component is identified by cluster ID with the maximum cluster size
  biggest_component_id = which.max(coauthorship_components$csize)

  # obtain vertex IDs for members of this largest cluster
  component_membership = V(journal_graph)[coauthorship_components$membership == biggest_component_id]

  # obtain subgraph consisting of only the members of the main component
  main_component_graph = igraph::induced_subgraph(journal_graph, component_membership)

  coauthorship_communities = cluster_louvain(main_component_graph)
  V(main_component_graph)$membership = coauthorship_communities$membership

  return(main_component_graph)
}

get_authors_df_from_graph = function(graph) {
  tmp_data_frame = get.data.frame(graph, what="vertices")
  df_authors = tmp_data_frame[which(tmp_data_frame$node_type == "author"),]
  df_authors = df_authors[c('id', 'author_name', 'scopus_id', 'membership')]
  return(df_authors)
}

get_articles_df_from_graph = function(graph) {
  tmp_data_frame = get.data.frame(graph, what="vertices")
  df_authors = tmp_data_frame[which(tmp_data_frame$node_type == "article"),]
  df_authors = df_authors[c('id', 'author_name', 'scopus_id', 'membership')]
  return(df_authors)
}

get_article_communities = function(journal_graph, main_component_graph) {
  df_main_component = get.data.frame(main_component_graph, what="vertices")

  df_authors_articles = get.data.frame(journal_graph, what="edges")
  df_authors_articles = df_authors_articles[which(df_authors_articles$edge_type == "authored"),]
  df_authors_articles$from = paste0("n", df_authors_articles$from)
  df_authors_articles$to = paste0("n", df_authors_articles$to)

  df_all_authors = get.data.frame(journal_graph, what="vertices")
  df_all_authors = df_all_authors[which(df_all_authors$node_type == "author"),]

  df_all_articles = get.data.frame(journal_graph, what="vertices")
  df_all_articles = df_all_articles[which(df_all_articles$node_type == "article"),]

  df_all = df_authors_articles %>%
    left_join(df_all_authors, by=c("from"="id")) %>%
    left_join(df_all_articles, by=c("to"="id"))
  df_all = df_all[c('author_name.x', 'scopus_id.x', 'doi.y', 'title.y')]
  names(df_all) = c("author_name", "scopus_id", "doi", "title")

  df_all_membership = df_all %>%
    left_join(df_main_component, by=c("scopus_id" = "scopus_id"))

  return(df_all)
}

# create data frame with every article title, along with the community the first author belongs to
get_article_communities_graph = function(journal_graph, main_component_graph) {

  # we start with all authors in the main component
  df_authors = get_authors_df_from_graph(main_component_graph)

  # we will build a new data frame with the article titles
  df_article_communities = data.frame(
    id=character(),
    title=character(),
    community=integer()
  )

  # go one article at a time through the journal graph

  for (scopus_id_str in df_authors$scopus_id) {
    # obtain an author vertex based on Scopus ID
    author_in_articles_vertex = V(journal_graph)[which(V(journal_graph)$scopus_id == scopus_id_str )]
    author_in_component_vertex = V(main_component_graph)[which(V(main_component_graph)$scopus_id == scopus_id_str )]
    author_membership = author_in_component_vertex$membership

    # identify all edges emanating from this author
    author_relationships = E(journal_graph)[ from(author_in_articles_vertex) ]

    # filter edges to identify authorship edges only
    authorship_edges = author_relationships[author_relationships$edge_type == "authored"]

    # iterate article edges to individually add article IDs to list
    for (article_edge in authorship_edges) {
      if (article_edge < gorder(journal_graph)) {
        article = V(journal_graph)[article_edge]
        if (article$title != "None") {
          df_tmp = data.frame(id=as.character(article$id), title=article$title, community=author_membership)
          df_article_communities = rbind(df_article_communities, df_tmp)
        }
      }
    }

    # TODO: remove this, we are gonna return after a single iteration
    # return(df_article_communities)
  }


  return(df_article_communities)
}
