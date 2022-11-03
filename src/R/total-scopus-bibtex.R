# setwd("C:/Users/christopher/work/personality-bib")
library(bibliometrix)
library(igraph)
library(dplyr)

# options(max.print=100000000)

# load the bibtex file
raw_bib <- readFiles("python/JPSP.bib")

# convert the bibtex file to a data frame
scopus_df = scopus2df(raw_bib)

results = biblioAnalysis(scopus_df, sep = ";")
S <- summary(object = results, k = 10, pause = FALSE)

# identify collaboration graph
net = biblioNetwork(scopus_df, analysis = "collaboration", network = "authors")

# write graph as GraphML file
G = networkStat(net)
write_graph(G$graph, "data.graphml", format="graphml")

# plot graph
plot(G$graph)

# Journal= data.frame(name=M$SO)
#
# Journal_Freq = Journal %>% group_by(name) %>% mutate(count=n())
# Journal_filter= Journal_Freq %>% filter(row_number()==2)
# Journal_filter[order(Journal_filter$count, decreasing = TRUE),]
#
# Journal_Freq = Journal %>% group_by(name) %>% mutate(count=n())
#
# str(M)
# summary(M)
# M$TI
#
# save.image("C:/Users/christopher/Desktop/scopus_data.RData")
# load("C:/Users/christopher/Desktop/scopus_data.RData")
