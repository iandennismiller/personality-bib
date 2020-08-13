setwd("C:/Users/christopher/documents/GitHub/personality-bib")
setwd("C:/Users/christopher/desktop")
load("C:/Users/christopher/documents/Bibliometric Mapping/R Enviroments/Collaboration with Author ID.RData")
library(bibliometrix)
library(igraph)
library(dplyr)
library(CINNA)
library(devtools)

# load the bibtex file

#jpsp = readFiles("JPSP.bib", "JRP.bib", "JP.bib", "EJP.bib", "PID.bib", "PSPB.bib", "PSPR.bib", "SPPS.bib","JPA.bib", "SBP.bib")
jpsp =  readFiles("JPSP.bib")
head(jpsp)

# Covert bibtex files to DF

scopus_df = scopus2df(jpsp)
#scopus_df = convert2df(file = jpsp, dbsource = 'scopus', format = "bibtex")
head(scopus_df)
scopus_df$AU

results = biblioAnalysis(scopus_df, sep = ";")
S <- summary(object = results, k = 10, pause = FALSE)
S = summary(results)

# identify collaboration graph

net = biblioNetwork(scopus_df, analysis = "collaboration", network = "authors")
G = networkStat(net)
plot(G$graph)

#Extract Main Component and Write Graphm

test = components(G$graph)
comp_size_order = sort(test$csize, decreasing = TRUE, na.last = NA)

demp_Comp_1 = decompose(G$graph, max.comps = NA,
                        min.vertices = 4000)
demp_Comp_2 = demp_Comp_1[[1]]

write_graph(demp_Comp_2, "main_comp_authorID.graphml", format="graphml")
