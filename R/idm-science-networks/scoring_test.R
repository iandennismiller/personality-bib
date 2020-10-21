# Ian Dennis Miller
# bibliometrics
# scoring: based on canonical data, calculate scores

df_names = read.csv("JPSP_c.csv")
a = df_names$scopus_id
b = df_names$author
auth_ids = edge_list$from


replaced_ID= data.frame()

for (auth_ids in edge_list){
replaced_ID = ifelse(df_names$scopus_id %in% edge_list$from == TRUE, b,a)
#cbind(edge_list, test_1)

}

replaced_ID


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
cl = component.largest(coauthors ,connected='weak')
biggest = get.inducedSubgraph(coauthors,v=(1:network.size(coauthors))[cl])

save.image("data/canonical.RData.gz", compress=TRUE)
load("data/canonical.RData.gz")

clean_tmp()
