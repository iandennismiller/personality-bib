setwd("C:/Users/christopher/work/personality-bib")
library(bibliometrix)
library(igraph)
library(dplyr)


options(max.print=100000000)

D <- readFiles("personality.bib")
M <- convert2df(file = D, dbsource = "scopus", format = "bibtex")

net = biblioNetwork(M, analysis = "collaboration", network = "authors")
G = networkStat(net)
write_graph(G$graph, "Data.graphml", format="graphml")
plot(G$graph)


Journal= data.frame(name=M$SO)

Journal_Freq = Journal %>% group_by(name) %>% mutate(count=n()) 
Journal_filter= Journal_Freq %>% filter(row_number()==2)
Journal_filter[order(Journal_filter$count, decreasing = TRUE),]


Journal_Freq = Journal %>% group_by(name) %>% mutate(count=n()) 

str(M)
summary(M)
M$TI


save.image("C:/Users/christopher/Desktop/scopus_data.RData")
load("C:/Users/christopher/Desktop/scopus_data.RData")