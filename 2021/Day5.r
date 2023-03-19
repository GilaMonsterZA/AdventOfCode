# open source file in notepad, replace -> with ;

Day5.Source <- read.csv("C:/Users/Gail/Source/AdventOfCode/2021/Day5 Source.txt", header=FALSE, sep=";", strip.white=TRUE)
start <- lapply(strsplit(Day5.Source[,1],','), FUN = as.numeric)
end <- lapply(strsplit(Day5.Source[,2],','), FUN = as.numeric)

Seafloor <- matrix(rep(0),nrow=1000,ncol=1000)

## for loop across 500 values
for (i in 1:500) {
  xstart <- start[[i]][1]
  xend <- end[[i]][1]
  ystart <- start[[i]][2]
  yend <- end[[i]][2]

# if horizontal or vertical - part 1
  if (xstart == xend || ystart == yend) {
    Seafloor[xstart:xend,ystart:yend] <- Seafloor[xstart:xend,ystart:yend] + 1
  }
# or not - part 2
  else {
    if ((xend > xstart && yend > ystart) || (xend < xstart && yend < ystart))
      yincrement <- 1
    else
      yincrement <- -1
    
    for (j in 0:(xend-xstart)) {
      Seafloor[xstart+j,ystart+(j*yincrement)] <- Seafloor[xstart+j,ystart+(j*yincrement)] + 1
    }
  }
}

print (sum(Seafloor>1)) # answer
