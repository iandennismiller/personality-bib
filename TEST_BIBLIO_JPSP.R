T <- readFiles("JPSP.txt")
T_1 = convert2df(T,dbsource = "isi", format = "bibtex"  )

results <- biblioAnalysis(T_1, sep = ";")
S <- summary(object = results, k = 10, pause = FALSE)

#Co-Citation 
PMatrix <- biblioNetwork(T_1, analysis = "co-citation", network = "references", sep = ". ")

#Plot Co-citation
net=networkPlot(PMatrix, n = 10, Title = "Co-Citation Network", type = "fruchterman", size=F, remove.multiple=FALSE, labelsize=0.7,edgesize = 1)


# Co-Word Analysis
CS <- conceptualStructure(T_1,field="ID", method="CA", minDegree=4, k.max=8, stemming=FALSE, labelsize=10, documents=10)

