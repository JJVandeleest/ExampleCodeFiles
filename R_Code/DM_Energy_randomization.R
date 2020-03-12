
##Pull out the matrix as ordered by Data Mechanics and add column and row cluster membership as matrix attributes.

DMmatrixA <-tt5[[2]][[2]]
krA <- 8
kcA <- 4


DMmatrixB <-tt19[[2]][[2]]
krB <- 6
kcB <- 4


#attr(DMmatrix, "colclusters") <- tt5[[2]][[14]] 

#attr(DMmatrix, "rowclusters") <-tt5[[2]][[13]]


##Do an energy calculation on the final DM matrix.
energy <- function(inputdata){
  entropymatrix <- matrix(NA, nrow(DMmatrix), ncol(DMmatrix))
  entropymatrix 
  
  numrows <- nrow(DMmatrix)
  numcols <- ncol(DMmatrix)
  
  zerocolumn <- vector(mode = "integer", numrows)
  zerorow <- vector(mode = "integer", numcols)
  
  
  
  #Calculating the difference between each cell and the cell to the left
  targetcell <- DMmatrix[,2:numcols]
  cellstoleft <- DMmatrix[,1:(numcols-1)]
  leftdifference <- targetcell - cellstoleft
  leftdifference <- cbind(zerocolumn, leftdifference)
  
  #Calculating the difference between each cell and the cell to the right
  targetcell <- DMmatrix[,1:(numcols-1)]
  cellstoright <- DMmatrix[,2:numcols]
  rightdifference <- targetcell - cellstoright
  rightdifference <- cbind(rightdifference, zerocolumn)
  
  #Calculating the difference between each cell and the cell below
  targetcell <- DMmatrix[1:(numrows-1),]
  cellsbelow <- DMmatrix[2:numrows,]
  belowdifference <- targetcell - cellsbelow
  belowdifference <- rbind(belowdifference, zerorow)
  
  #Calculating the difference between each cell and the cell above
  targetcell <- DMmatrix[2:numrows,]
  cellsabove <- DMmatrix[1:(numrows-1),]
  abovedifference <- targetcell - cellsabove
  abovedifference <- rbind(zerorow, abovedifference)
  
  entropymatrix <- abs(leftdifference) + abs(rightdifference) + abs(abovedifference) + abs(belowdifference)
  entropy <- sum(entropymatrix)
  return(entropy)
}

## Now randomize the matrix.  Randomization should be structured so that each column is randomized within the row cluster.  
## Do not randomize across columns to maintain the empirical distribution for each column (i.e. maitain margins on columns).


randomizecols <- function(DMmatrix){
  newdf <- vector()
  for (i in 1:max(tt5[[2]][[14]])){
    columnsInCluster <- DMmatrix[,which(tt5[[2]][[14]]==i)] 
    newcolorder <- sample(1:ncol(columnsInCluster),ncol(columnsInCluster),replace=F)
    newdf <- cbind(newdf,columnsInCluster[,newcolorder])
  }
  return(newdf)
}


randomizerows <- function(df){
  newdf <- vector()
  for (i in 1:ncol(df)){
    newroworder <- sample(1:nrow(df),nrow(df),replace = F)
    newdf <- cbind(newdf,df[newroworder,i])
  }
  #newdf <- as.data.frame(newdf)
  colnames(newdf) <- names(df)
  return(newdf)
}



energydist <- function(DMmatrix, kr, kc, iter){
  DMenergy <- energy(DMmatrix)
  energylist <- vector()

  for (i in (1:iter)){
    randcols <- randomizecols(DMmatrix)
    
    newmatrix <- vector()
    
    
    for (g in (1:max(tt5[[2]][[13]]))){
    
      rowcluster <- randcols[(which(tt5[[2]][[13]] == g)),]
      
      randomizedcluster <- randomizerows(rowcluster)
      
      newmatrix <- rbind(newmatrix, randomizedcluster)
    }  
      
    energylist <- c(energylist,energy(newmatrix))
  }
  grouping <- rep(paste(kr, " x ", kc), iter)
  
  output <- data.frame(paste(kr,kc),energylist)
  energies <- list(output, DMenergy)
  return(energies)
}


energydistA <-energydist(DMmatrixA[[1]], krA, kcA, 1000)
energydistB <- energydist(DMmatrixB,krB, kcB, 1000)


###plotting


#compare <- as.data.frame(rbind(energydistA, energydistB), stringsAsFactors = F)

#library(sm)
#sm.density.compare(compare[,2],group = compare[,1])

library(ggplot2)

ggplot() + geom_density(compare, mapping = aes(x = compare[,2], colour = compare[,1]))

##To do:
# 1) Randomize columns within column cluster too--DONE
# 2) Add dotted line for "mean" or the energy of the DM plot as it is output
# 3) Automate running DM at multiple cluster sizes to facilitate comparissons.
