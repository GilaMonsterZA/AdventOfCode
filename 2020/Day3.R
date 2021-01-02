library("dplyr")
library("stringr")
library("tidyr")

#input and setup
Input <- read.table("C:\\Users\\Gail\\Source\\AdventOfCode\\2020\\Day3Trees.txt", stringsAsFactors = FALSE, header = FALSE, comment.char="")
RepeatLength <- nchar(Input[1,1])
Height <- length(Input[,1])

Right <- 1
Down <- 2

Positions <- data.frame(Position=integer(), Collision=logical())
Row <- 1

for (i in seq(1, Height, Down)) {

  if (i==1) {
    NewPosition <- 1
  }
  else {
    NewPosition <- Positions[Row-1,1] + Right
    
  }

  print(i)
  print(Row)
    
  if (NewPosition > RepeatLength) {
    NewPosition <- NewPosition - RepeatLength
  }
  
  Trees <- str_locate_all(Input[i,1], "#")[[1]][,1]
  Collision <- NewPosition %in% Trees
  Positions <- rbind(Positions, setNames(data.frame(c(NewPosition), c(Collision)),names(Positions)))
  
  Row <- Row + 1
}

Positions %>% filter(Collision == TRUE) %>% count()

# R1D1 = 58
# R3D1 = 209
# R5D1 = 58
# R7D1 = 64
# R1D2 = 35

