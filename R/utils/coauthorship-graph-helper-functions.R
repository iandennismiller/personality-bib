library(igraph)

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

get_article_communities = function(journal_graph, main_component_graph) {
  tmp_data_frame = get.data.frame(main_component_graph, what="vertices")
  df_authors = tmp_data_frame[which(tmp_data_frame$node_type == "author"),]
  df_authors = df_authors[c('id', 'author_name', 'scopus_id', 'membership')]

  df_article_communities = data.frame(
    id=character(),
    title=character(),
    community=integer()
  )

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
  }


  return(df_article_communities)
}
