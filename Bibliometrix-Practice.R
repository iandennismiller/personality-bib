D <- readFiles("http://www.bibliometrix.org/datasets/savedrecs.bib")
M <- convert2df(D, dbsource = "isi", format = "bibtex")

results <- biblioAnalysis(M, sep = ";")

S <- summary(object = results, k = 10, pause = FALSE)

#Co-Citation Network
NetMatrix <- biblioNetwork(M, analysis = "co-citation", network = "references", sep = ". ")

#Plot Co-Citation Network
net=networkPlot(NetMatrix, n = 30, Title = "Co-Citation Network", type = "fruchterman", size=T, remove.multiple=FALSE, labelsize=0.7,edgesize = 5)


#Network Summary 
netstat <- networkStat(NetMatrix, stat = "all", type = "degree")
summary(netstat)

# Co-Word Analysis
CS <- conceptualStructure(M,field="ID", method="CA", minDegree=4, k.max=8, stemming=FALSE, labelsize=10, documents=10)

# Country Collaboration
CC <- metaTagExtraction(M, Field = "AU_CO", sep = ";")
NetMatrix_1 <- biblioNetwork(CC, analysis = "collaboration", network = "countries", sep = ";")

# Plot Country Collaboration
net_1=networkPlot(NetMatrix, n = dim(NetMatrix)[1], Title = "Country Collaboration", type = "fruchterman", size=TRUE, remove.multiple=FALSE,labelsize=0.8)






