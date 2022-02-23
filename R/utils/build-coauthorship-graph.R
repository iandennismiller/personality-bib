# Ian Dennis Miller
# bibliometrics
# scoring: based on canonical data, calculate scores

load_files = function() {
  jpsp = read.csv("JPSP_personality.csv")
  jpa = read.csv("JPA.csv")
  ejp = read.csv("EJP.csv")
  jrp = read.csv("JRP.csv")
  jp = read.csv("JP.csv")
  pid = read.csv("PID.csv")
  ap = read.csv("AP.csv")
  SBP = read.csv("SBP.csv")
  pr = read.csv("PR_1.csv")
  pi = read.csv("PI_1.csv")
  a = read.csv("A.csv")
  spps = read.csv("SPPS.csv")
  pr = read.csv("PR_1.csv")
  pspr = read.csv("PSPR.csv")
  pspb = read.csv("PSPB.csv")
  ap = read.csv("AP.csv")
  pb = read.csv("PB_1.csv")

  df_names = rbind(jpsp,jpa,ejp,jrp,jp,pid,ap,SBP,pr,pi,a,spps,pr,pspr,pspb,ap,pb)

  return(df_names)
}

build_network = function(df_names) {
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

  coauthors = network(as.matrix(edge_list)[,1:2], directed = FALSE)
  set.edge.attribute(coauthors, "article", edge_list$article)

  return(coauthors)
}

get_largest_component = function(coauthors) {
  replaced_ID = list()
  for (auth_id in network.vertex.names(coauthors)){
    row_id = match(auth_id, df_names$scopus_id)
    auth_name = df_names[row_id,3]
    replaced_ID = append(replaced_ID, auth_name)
  }

  wthout_NA_biggest = get.inducedSubgraph(coauthors,v= which(!is.na(replaced_ID)))

  cl = component.largest(wthout_NA_biggest ,connected='weak')
  biggest = get.inducedSubgraph(wthout_NA_biggest,v=(1:network.size(wthout_NA_biggest))[cl])

  replaced_ID = replaced_ID[!is.na(replaced_ID)]
  network.vertex.names(biggest) = unlist(replaced_ID)

  biggest = asIgraph(biggest)

  return(biggest)
}

get_centrality = function(biggest) {
  degree_centrality = centr_degree(biggest)
  closeness_centrality = centr_clo(biggest)
  betweenness_centrality = centr_betw(biggest)
  eigencentrality = eigen_centrality(biggest)

  centrality = cbind(degree_centrality$res,closeness_centrality$res,betweenness_centrality$res, replaced_ID)
  centrality_df = data.frame(name = network.vertex.names(biggest), degree = degree_centrality$res, closeness = closeness_centrality$res, betweeness = betweenness_centrality$res, eigencentrality = eigencentrality$value)

  return(centrality_df)
}

main = function() {
  df_names = load_files()
  coauthors = build_network(df_names)

  biggest = get_largest_component(coauthors)
  write_graph(biggest, "Full personality Network-Nov 17th-1990-1990 With NA's.graphml", format="graphml")

  centrality_df = get_centrality(biggest)
  head(centrality_df)
}

main()

# save.image("data/canonical.RData.gz", compress=TRUE)
# load("data/canonical.RData.gz")
# clean_tmp()
