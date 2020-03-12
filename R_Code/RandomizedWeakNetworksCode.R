setwd("C:/Users/Jessica/Box/McCowan Lab/Projects_Funded/SSD/SSD_DataPreparation/AffiliationData/NetworkStabilityAnalysis")

dat = read.csv("HU_First Year Single Interactions_EL.csv", head = TRUE, stringsAsFactors = FALSE)


subjects = sort(unique(c(dat$Initiator, dat$Recipient)))

degree = sapply(subjects, function(i){
       sum(c(dat$Initiator, dat$Recipient) == i)
})

#library(igraph)


#graph <- graph_from_data_frame(dat, directed = F, vertices = NULL)

#node.degree <- centr_degree(graph, mode =  "total", loops = F,
#       normalized = F)

#degCent.Orig <- node.degree$centralization/node.degree$theoretical_max

#clustCoeff <- transitivity(graph, type = "global", vids = NULL,
#       weights = NULL, isolates =  "zero")

library(sna)

dat$Initiator <- as.character(dat$Initiator)
dat$Recipient <- as.character(dat$Recipient)

sna.net = network(dat[,1:2], directed = F)

Cent.Orig <- centralization(sna.net,degree, mode = "graph")
Transitivity.Orig <- gtrans(sna.net, use.adjacency = F)
#triangles.Orig <- triad.census(sna.net, mode = "graph")[,"3"] ## takes too long to run on randomized graphs


### Pre-network average degree preserving randomization
#avg.degree = mean(degree)

#edges = t(sapply(1:nrow(dat), function(k){
#       sample(subjects,2)
#}))

#new.dat2 = data.frame(Initiator = edges[,1], Recipient = edges[,2], stringsAsFactors = FALSE)

#sna.net2 = network(new.dat2[,1:2], directed = F)

#new.degree2 = sapply(subjects, function(i){
#       sum(c(new.dat2$Initiator, new.dat2$Recipient) == i)
#})

#avg.degree2 = mean(new.degree2)

#Cent.New <- centralization(sna.net2,degree, mode = "graph")

#Transitivity.New <- gtrans(sna.net2)

## Now use this code to create multipl randomized networks and create a distribution of centralization and transitivity.
CentrDist = vector()
TransDist = vector()
#TrianglesDist = vector()
ctr = 0

while (ctr < 1000){
       print(ctr)
       edges = t(sapply(1:nrow(dat), function(k){
              sample(subjects,2)
       }))

       new.dat = data.frame(Initiator = edges[,1], Recipient = edges[,2], stringsAsFactors = FALSE)
       new.sna.net = network(new.dat[,1:2], directed = F)

       CentrDist <- c(CentrDist, centralization(new.sna.net,degree, mode = "graph"))
       TransDist <- c(TransDist, gtrans(new.sna.net, use.adjacency = F))
       #TrianglesDist <- c(TrianglesDist, triad.census(new.sna.net, mode = "graph")[,"3"])
       ctr = ctr+1
}
