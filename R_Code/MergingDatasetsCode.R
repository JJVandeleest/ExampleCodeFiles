setwd("C:/Users/Jessica/Box/McCowan Lab/Projects_Funded/SSD/SSD_DataPreparation/AffiliationData/NetworkStabilityAnalysis/NetworkMetricFiles/Grooming/")

files <- list.files()
files

data <- read.csv(files[1],header = T, stringsAsFactors = F)
#data

IDs <- as.data.frame(data$name)
names(IDs) <- "name"

FullData <- IDs

for (i in 1:length(files)){ 
       data <- read.csv(files[i],header = T, stringsAsFactors = F)
       subset <- data[,c("name", "Indegree", "Outdegree", "EdgeCount", "PartnerOfMultiEdgedNodePairs")]
       subset$Degree <- subset$EdgeCount - subset$PartnerOfMultiEdgedNodePairs
       names(subset) <- c("name", paste("Indegree",i, sep = ""), paste("Outdegree",i, sep = ""), paste("EdgeCount",i, sep = ""), paste("PartnerOfMultiEdgedNodePairs",i, sep = ""),paste("Degree",i, sep = ""))
       FullData <- merge(FullData, subset, by = "name", all = T)
}

write.csv(FullData, file = "GR_MergedData.csv")

#data2 <- read.csv("gFirstYearWeakNetworkmetrics.csv", header = T, stringsAsFactors = F)
#subset2 <- data2[,c("name", "Indegree", "Outdegree", "EdgeCount", "PartnerOfMultiEdgedNodePairs")]
#subset2$Degree <- subset2$EdgeCount - subset2$PartnerOfMultiEdgedNodePairs
#names(subset2) <- c("name", "IndegreeW", "OutdegreeW", "EdgeCountW","PartnerOfMultiEdgedNodePairsW","DegreeW")

#FullData <- merge(FullData, subset2, by = "name", all=T)


CorrMatrixPearson <- cor(FullData[,2:ncol(FullData)], use = "pairwise.complete.obs")
roworder <-sort(rownames(CorrMatrixPearson))
CorrMatrixPearson <- CorrMatrixPearson[roworder,]
colorder <-sort(colnames(CorrMatrixPearson))
CorrMatrixPearson <- CorrMatrixPearson[,colorder]
colnames(CorrMatrixPearson) <- colorder       

CorrMatrixSpearman <- cor(FullData[,2:ncol(FullData)], use = "pairwise.complete.obs", method = "spearman")
roworder <-sort(rownames(CorrMatrixSpearman))
CorrMatrixSpearman <- CorrMatrixSpearman[roworder,]
colorder <-sort(colnames(CorrMatrixSpearman))
CorrMatrixSpearman <- CorrMatrixSpearman[,colorder]
colnames(CorrMatrixSpearman) <- colorder  

write.csv(CorrMatrixPearson, file = "GR_PearsonCorr.csv")
write.csv(CorrMatrixSpearman, file = "GR_SpearmanCorr.csv")

setwd("C:/Users/Jessica/Box/McCowan Lab/Projects_Funded/SSD/SSD_DataPreparation/AffiliationData/NetworkStabilityAnalysis/NetworkMetricFiles/Huddling/")

files <- list.files()
files

data <- read.csv(files[1],header = T, stringsAsFactors = F)
#data

IDs <- as.data.frame(data$name)
names(IDs) <- "name"

FullData <- IDs

for (i in 1:length(files)){ 
       data <- read.csv(files[i],header = T, stringsAsFactors = F)
       subset <- data[,c("name", "Degree")]
       names(subset) <- c("name", paste("Degree",i, sep = ""))
       FullData <- merge(FullData, subset, by = "name", all = T)
}

write.csv(FullData, file = "HU_MergedData.csv")


#CorrMatrixPearson <- cor(FullData[,2:ncol(FullData)], use = "pairwise.complete.obs")
#roworder <-sort(rownames(CorrMatrixPearson))
#CorrMatrixPearson <- CorrMatrixPearson[roworder,]
#colorder <-sort(colnames(CorrMatrixPearson))
#CorrMatrixPearson <- CorrMatrixPearson[,colorder]
#colnames(CorrMatrixPearson) <- colorder       

CorrMatrixSpearman <- cor(FullData[,2:ncol(FullData)], use = "pairwise.complete.obs", method = "spearman")
roworder <-sort(rownames(CorrMatrixSpearman))
CorrMatrixSpearman <- CorrMatrixSpearman[roworder,]
colorder <-sort(colnames(CorrMatrixSpearman))
CorrMatrixSpearman <- CorrMatrixSpearman[,colorder]
colnames(CorrMatrixSpearman) <- colorder  

#write.csv(CorrMatrixPearson, file = "HU_PearsonCorr.csv")
write.csv(CorrMatrixSpearman, file = "HU_SpearmanCorr.csv")

 cor(x = FullData$Degree7, y = HuddData$Degree4, use  = "pairwise.complete.obs", method = "pearson")
 0.4160268
 cor(x = FullData$Degree7, y = HuddData$Degree4, use  = "pairwise.complete.obs", method = "spearman")
 0.4566905
 
 cor(x = FullData$Degree1, y = HuddData$Degree1, use  = "pairwise.complete.obs", method = "pearson")
 0.5141626
 cor(x = FullData$Degree1, y = HuddData$Degree1, use  = "pairwise.complete.obs", method = "spearman")
 0.5474854
 
 
 setwd("C:/Users/Jessica/Box/McCowan Lab/Projects_Funded/SSD/SSD_DataPreparation/AffiliationData/NetworkStabilityAnalysis/")
 GR <- read.csv("GR_MergedData.csv", head = T, stringsAsFactors = F)
 HU <- read.csv("HU_MergedData.csv", head = T, stringsAsFactors = F)
 rank <- read.csv("NC8_SimulatedRankOrder.csv", head = T, stringsAsFactors = F) 
 
 netdata <- merge(GR, HU, by = "name", all = T)
NetRankData <- merge(rank, netdata, by.x = "BestSimulatedRankOrder.ID", by.y = "name", all = T)

cor(x = NetRankData$BestSimulatedRankOrder.ranking, y = NetRankData$Indegree1, use = "pairwise.complete.obs", method = "spearman")
-0.6601354
cor(x = NetRankData$BestSimulatedRankOrder.ranking, y = NetRankData$Indegree2, use = "pairwise.complete.obs", method = "spearman")
-0.6084113
cor(x = NetRankData$BestSimulatedRankOrder.ranking, y = NetRankData$Indegree3, use = "pairwise.complete.obs", method = "spearman")
-0.514327
cor(x = NetRankData$BestSimulatedRankOrder.ranking, y = NetRankData$Indegree7, use = "pairwise.complete.obs", method = "spearman")
-0.5570334

cor(x = NetRankData$BestSimulatedRankOrder.ranking, y = NetRankData$Outdegree1, use = "pairwise.complete.obs", method = "spearman")
-0.2899201
cor(x = NetRankData$BestSimulatedRankOrder.ranking, y = NetRankData$Outdegree2, use = "pairwise.complete.obs", method = "spearman")
-0.3490469
cor(x = NetRankData$BestSimulatedRankOrder.ranking, y = NetRankData$Outdegree3, use = "pairwise.complete.obs", method = "spearman")
-0.329248
cor(x = NetRankData$BestSimulatedRankOrder.ranking, y = NetRankData$Outdegree7, use = "pairwise.complete.obs", method = "spearman")
-0.1302376

cor(x = NetRankData$BestSimulatedRankOrder.ranking, y = NetRankData$Degree1.x, use = "pairwise.complete.obs", method = "spearman")
-0.576962
cor(x = NetRankData$BestSimulatedRankOrder.ranking, y = NetRankData$Degree2.x, use = "pairwise.complete.obs", method = "spearman")
-0.6056375
cor(x = NetRankData$BestSimulatedRankOrder.ranking, y = NetRankData$Degree3.x, use = "pairwise.complete.obs", method = "spearman")
-0.5465962
cor(x = NetRankData$BestSimulatedRankOrder.ranking, y = NetRankData$Degree7.x, use = "pairwise.complete.obs", method = "spearman")
-0.4544133
cor(x = NetRankData$BestSimulatedRankOrder.ranking, y = NetRankData$Degree2.y, use = "pairwise.complete.obs", method = "spearman")
-0.2596497
cor(x = NetRankData$BestSimulatedRankOrder.ranking, y = NetRankData$Degree7.y, use = "pairwise.complete.obs", method = "spearman")
-0.146164

cor(x = NetRankData$Degree1.x, y = NetRankData$Degree1.y, use = "pairwise.complete.obs", method = "spearman")
0.5474854
cor(x = NetRankData$Degree2.x, y = NetRankData$Degree2.y, use = "pairwise.complete.obs", method = "spearman")
0.493125
cor(x = NetRankData$Degree3.x, y = NetRankData$Degree2.y, use = "pairwise.complete.obs", method = "spearman")
0.5449017
cor(x = NetRankData$Degree3.x, y = NetRankData$Degree3.y, use = "pairwise.complete.obs", method = "spearman")
0.3612823
